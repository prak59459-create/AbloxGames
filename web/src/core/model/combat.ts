// Weapons a script hands out, and shots resolved on the host —
// AbloxCore/Combat.swift. A client says where it fired from and which way;
// the host, with its own idea of where everyone is, decides what was hit.
import {
  add, dot, normalized, quatEulerDegrees, rayHitsBox, rotate, scale, sub, v3, lengthSquared, distance,
  type BoundingBox, type Vec3,
} from './math';
import { prefix } from './text';

export interface WeaponSpec {
  name: string;
  damage: number;
  /** Shots per second. */
  fireRate: number;
  range: number;
  magazine: number;
  reloadTime: number;
  /** Random cone, in degrees. */
  spread: number;
  /** Which model is drawn. */
  model: string;
}

export function weaponSpec(name: string, o: Partial<WeaponSpec> = {}): WeaponSpec {
  return {
    name, damage: o.damage ?? 20, fireRate: o.fireRate ?? 4, range: o.range ?? 60, magazine: o.magazine ?? 12,
    reloadTime: o.reloadTime ?? 1.5, spread: o.spread ?? 1, model: o.model ?? 'blaster',
  };
}

const within = (v: number, lo: number, hi: number, otherwise: number) => (Number.isFinite(v) ? Math.min(Math.max(v, lo), hi) : otherwise);

/** The same weapon with every number in a range the host can simulate. */
export function clampedWeapon(w: WeaponSpec): WeaponSpec {
  return {
    name: prefix(w.name, 32),
    damage: within(w.damage, 0, 1_000_000, 0),
    fireRate: within(w.fireRate, 0.1, 30, 1),
    range: within(w.range, 1, 1000, 60),
    magazine: Math.min(Math.max(Math.trunc(w.magazine), 1), 1000),
    reloadTime: within(w.reloadTime, 0, 60, 1),
    spread: within(w.spread, 0, 45, 0),
    model: w.model,
  };
}

export const weaponPresets: Record<string, WeaponSpec> = {
  blaster: weaponSpec('blaster', { damage: 20, fireRate: 4, range: 60, magazine: 12, reloadTime: 1.5, spread: 1, model: 'blaster' }),
  rifle: weaponSpec('rifle', { damage: 34, fireRate: 2, range: 120, magazine: 6, reloadTime: 2, spread: 0.2, model: 'rifle' }),
  shotgun: weaponSpec('shotgun', { damage: 45, fireRate: 1, range: 18, magazine: 4, reloadTime: 2.2, spread: 6, model: 'shotgun' }),
  pistol: weaponSpec('pistol', { damage: 15, fireRate: 5, range: 45, magazine: 10, reloadTime: 1, spread: 1.5, model: 'pistol' }),
};

export function decodeWeapon(v: unknown): WeaponSpec | undefined {
  const o = v as Record<string, unknown> | null;
  if (!o || typeof o !== 'object' || typeof o.name !== 'string') return undefined;
  const n = (x: unknown, d: number) => (typeof x === 'number' && Number.isFinite(x) ? x : d);
  return {
    name: o.name, damage: n(o.damage, 20), fireRate: n(o.fireRate, 4), range: n(o.range, 60), magazine: Math.trunc(n(o.magazine, 12)),
    reloadTime: n(o.reloadTime, 1.5), spread: n(o.spread, 1), model: typeof o.model === 'string' ? o.model : 'blaster',
  };
}

export const encodeWeapon = (w: WeaponSpec) => ({
  damage: w.damage, fireRate: w.fireRate, magazine: w.magazine, model: w.model, name: w.name, range: w.range,
  reloadTime: w.reloadTime, spread: w.spread,
});

/** A standing character's hit capsule. */
export const PlayerHitBody = { radius: 0.4, height: 1.8, eyeHeight: 1.6 } as const;

export type HitTarget = { kind: 'player'; peer: string } | { kind: 'block'; id: string } | { kind: 'nothing' };
export interface HitResult { target: HitTarget; point: Vec3; distance: number }

/** Where a ray first enters a sphere, or null. */
function sphereDistance(origin: Vec3, direction: Vec3, centre: Vec3, radius: number): number | null {
  const offset = sub(origin, centre);
  const b = dot(offset, direction);
  const c = dot(offset, offset) - radius * radius;
  const discriminant = b * b - c;
  if (discriminant < 0) return null;
  const t = -b - Math.sqrt(discriminant);
  return t >= 0 ? t : null;
}

/** Where a ray first enters a standing character's capsule, or null. */
export function capsuleDistance(origin: Vec3, direction: Vec3, feet: Vec3, size = 1): number | null {
  const radius = PlayerHitBody.radius * size;
  const bottom = add(feet, v3(0, radius, 0));
  const top = add(feet, v3(0, PlayerHitBody.height * size - radius, 0));
  let best: number | null = null;
  const ox = origin.x - bottom.x, oz = origin.z - bottom.z;
  const a = direction.x * direction.x + direction.z * direction.z;
  if (a > 1e-8) {
    const b = 2 * (ox * direction.x + oz * direction.z);
    const c = ox * ox + oz * oz - radius * radius;
    const discriminant = b * b - 4 * a * c;
    if (discriminant >= 0) {
      const t = (-b - Math.sqrt(discriminant)) / (2 * a);
      if (t >= 0) {
        const y = origin.y + direction.y * t;
        if (y >= bottom.y && y <= top.y) best = t;
      }
    }
  }
  for (const centre of [bottom, top]) {
    const t = sphereDistance(origin, direction, centre, radius);
    if (t !== null && (best === null || t < best)) best = t;
  }
  return best;
}

export const Hitscan = {
  /** The first thing a shot meets. Blocks stop shots, so cover works. */
  cast(origin: Vec3, rawDirection: Vec3, range: number, shooter: string,
    players: { peer: string; position: Vec3 }[], blocks: { id: string; bounds: BoundingBox }[],
    sizes: Map<string, number> = new Map()): HitResult {
    const direction = normalized(rawDirection);
    if (!(lengthSquared(direction) > 0.5) || !(range > 0)) return { target: { kind: 'nothing' }, point: origin, distance: 0 };
    let nearest: HitResult = { target: { kind: 'nothing' }, point: add(origin, scale(direction, range)), distance: range };
    for (const block of blocks) {
      const d = rayHitsBox(origin, direction, block.bounds);
      if (d !== null && d >= 0 && d < nearest.distance) {
        nearest = { target: { kind: 'block', id: block.id }, point: add(origin, scale(direction, d)), distance: d };
      }
    }
    for (const player of players) {
      if (player.peer === shooter) continue;
      const d = capsuleDistance(origin, direction, player.position, sizes.get(player.peer) ?? 1);
      if (d !== null && d < nearest.distance) {
        nearest = { target: { kind: 'player', peer: player.peer }, point: add(origin, scale(direction, d)), distance: d };
      }
    }
    return nearest;
  },

  /** A direction nudged at random within a cone of `degrees`. */
  spread(direction: Vec3, degrees: number, unit: () => number): Vec3 {
    if (!(degrees > 0)) return normalized(direction);
    const yaw = (unit() * 2 - 1) * degrees;
    const pitch = (unit() * 2 - 1) * degrees;
    return normalized(rotate(quatEulerDegrees(v3(pitch, yaw, 0)), normalized(direction)));
  },
};

export type ShotRefusal = 'tooSoon' | 'reloading' | 'tooFarFromBody' | 'badDirection';

/** The host's record of one player's weapon, and the checks a shot must pass. */
export class ArmedState {
  static readonly rateTolerance = 0.35;
  static readonly maximumOriginError = 2.5;

  weapon: WeaponSpec;
  ammo: number;
  lastShot = -Infinity;
  reloadEnds: number | null = null;

  constructor(weapon: WeaponSpec) {
    this.weapon = clampedWeapon(weapon);
    this.ammo = this.weapon.magazine;
  }

  get isReloading(): boolean { return this.reloadEnds !== null; }

  copy(): ArmedState {
    const out = new ArmedState(this.weapon);
    out.ammo = this.ammo;
    out.lastShot = this.lastShot;
    out.reloadEnds = this.reloadEnds;
    return out;
  }

  refusal(time: number, origin: Vec3, direction: Vec3, shooterFeet: Vec3, size = 1): ShotRefusal | null {
    if (this.reloadEnds !== null) return 'reloading';
    const interval = 1 / this.weapon.fireRate;
    if (time - this.lastShot < interval * (1 - ArmedState.rateTolerance)) return 'tooSoon';
    if (!Number.isFinite(direction.x) || !Number.isFinite(direction.y) || !Number.isFinite(direction.z)
      || !(lengthSquared(direction) > 0.25)) return 'badDirection';
    const eyes = add(shooterFeet, v3(0, PlayerHitBody.eyeHeight * size, 0));
    if (!(distance(origin, eyes) <= ArmedState.maximumOriginError)) return 'tooFarFromBody';
    return null;
  }

  shoot(time: number): void {
    this.lastShot = time;
    this.ammo -= 1;
    if (this.ammo <= 0) {
      this.ammo = 0;
      this.reloadEnds = time + this.weapon.reloadTime;
    }
  }

  startReload(time: number): boolean {
    if (this.reloadEnds !== null || this.ammo >= this.weapon.magazine) return false;
    this.reloadEnds = time + this.weapon.reloadTime;
    return true;
  }

  advance(time: number): boolean {
    if (this.reloadEnds === null || time < this.reloadEnds) return false;
    this.reloadEnds = null;
    this.ammo = this.weapon.magazine;
    return true;
  }
}
