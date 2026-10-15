// Character collision and movement — AbloxCore/WorldCollider.swift,
// Player.swift (MovementConfig, CharacterSolver) and Surroundings.swift.
// The same box-against-boxes rules as the iPads, so a jump that works there
// works here.
import {
  angularDelta, boxAround, boxContains, expanded, lerp3, normalizeDegrees, normalized, penetrates, quatYaw, rotate, v3,
  type BoundingBox, type Vec3,
} from '../model/math';
import { isPassThrough, needsTouchDetection } from '../model/world';
import type { IndexEntry, WorldIndex } from './worldIndex';

export interface CharacterBody { radius: number; height: number; stepHeight: number }
export const defaultBody = (): CharacterBody => ({ radius: 0.4, height: 1.8, stepHeight: 0.45 });

export function bodyBounds(body: CharacterBody, p: Vec3): BoundingBox {
  return boxAround(v3(p.x, p.y + body.height / 2, p.z), v3(body.radius * 2, body.height, body.radius * 2));
}

export interface CollisionResult { position: Vec3; velocity: Vec3; isGrounded: boolean; touched: string[] }

const groundProbe = 0.05;

const isSolid = (e: IndexEntry) => e.isVisible && e.hasCollision && !isPassThrough(e.behavior);

function isTrigger(e: IndexEntry): boolean {
  if (!e.isVisible) return false;
  if (e.hasCollision) return isPassThrough(e.behavior) || needsTouchDetection(e.behavior);
  return needsTouchDetection(e.behavior);
}

function firstSolid(index: WorldIndex, box: BoundingBox): BoundingBox | null {
  for (const e of index.near(box)) if (isSolid(e) && penetrates(box, e.bounds)) return e.bounds;
  return null;
}

function resolveAxis(axis: 'x' | 'z', p: Vec3, velocity: number, body: CharacterBody, index: WorldIndex): boolean {
  if (velocity === 0) return false;
  let hit = false;
  for (let i = 0; i < 4; i++) {
    const box = bodyBounds(body, p);
    const blocker = firstSolid(index, box);
    if (!blocker) break;
    const rise = blocker.max.y - p.y;
    if (rise > 0 && rise <= body.stepHeight) {
      const stepped = v3(p.x, blocker.max.y, p.z);
      if (!firstSolid(index, bodyBounds(body, stepped))) {
        p.y = stepped.y;
        continue;
      }
    }
    hit = true;
    if (axis === 'x') p.x += velocity > 0 ? blocker.min.x - box.max.x : blocker.max.x - box.min.x;
    else p.z += velocity > 0 ? blocker.min.z - box.max.z : blocker.max.z - box.min.z;
  }
  return hit;
}

/** One collision step: X, then Z, then up or down. */
export function resolve(position: Vec3, velocity: Vec3, body: CharacterBody, index: WorldIndex, deltaTime: number): CollisionResult {
  const dt = Math.max(0, Math.min(deltaTime, 0.1));
  const p = v3(position.x, position.y, position.z);
  const v = v3(velocity.x, velocity.y, velocity.z);
  let grounded = false;

  p.x += v.x * dt;
  if (resolveAxis('x', p, v.x, body, index)) v.x = 0;
  p.z += v.z * dt;
  if (resolveAxis('z', p, v.z, body, index)) v.z = 0;

  const movingUp = v.y > 0;
  p.y += v.y * dt;
  let landed = false;
  for (let i = 0; i < 4; i++) {
    const box = bodyBounds(body, p);
    const blocker = firstSolid(index, box);
    if (!blocker) break;
    if (movingUp) p.y += blocker.min.y - box.max.y;
    else { p.y += blocker.max.y - box.min.y; landed = true; }
    v.y = 0;
  }
  if (landed && !movingUp) grounded = true;

  if (!grounded && v.y <= 0) {
    grounded = firstSolid(index, bodyBounds(body, v3(p.x, p.y - groundProbe, p.z))) !== null;
  }

  const reach = expanded(bodyBounds(body, p), groundProbe);
  const touched = index.near(reach).filter(isTrigger).map((e) => e.id);
  return { position: p, velocity: v, isGrounded: grounded, touched };
}

// MARK: - Swimming and climbing

export type Surroundings = { kind: 'normal' } | { kind: 'water'; surface: number } | { kind: 'ladder' };

export function surroundingsAt(position: Vec3, body: CharacterBody, index: WorldIndex): Surroundings {
  const reach = expanded(bodyBounds(body, position), 0.3);
  const chest = v3(position.x, position.y + body.height * 0.45, position.z);
  for (const e of index.near(reach)) {
    if (!e.isVisible) continue;
    if (e.isLiquid && boxContains(e.bounds, chest)) return { kind: 'water', surface: e.bounds.max.y };
    if (e.behavior === 'ladder' && penetrates(reach, e.bounds)) return { kind: 'ladder' };
  }
  return { kind: 'normal' };
}

// MARK: - Movement

export interface MovementConfig {
  walkSpeed: number;
  runMultiplier: number;
  jumpSpeed: number;
  gravity: number;
  airControl: number;
  groundFriction: number;
  maxFallSpeed: number;
  turnSpeedDegreesPerSecond: number;
}

export const defaultMovement = (): MovementConfig => ({
  walkSpeed: 5, runMultiplier: 1.8, jumpSpeed: 6, gravity: -18, airControl: 0.45, groundFriction: 12, maxFallSpeed: -45,
  turnSpeedDegreesPerSecond: 540,
});

export interface MovementInput {
  /** Stick in -1…1; z is forward. */
  stick: Vec3;
  isJumping: boolean;
  isRunning: boolean;
  cameraYawDegrees: number;
}

export interface MovingBody { position: Vec3; velocity: Vec3; yawDegrees: number; isGrounded: boolean }

function stickDirection(input: MovementInput): [Vec3, number] {
  const dir = normalized(rotate(quatYaw(input.cameraYawDegrees), v3(input.stick.x, 0, -input.stick.z)));
  return [dir, Math.min(1, Math.hypot(input.stick.x, input.stick.z))];
}

function turned(yaw: number, dir: Vec3, magnitude: number, config: MovementConfig, dt: number): number {
  if (magnitude <= 0.01) return yaw;
  const target = (Math.atan2(dir.x, -dir.z) * 180) / Math.PI;
  const delta = angularDelta(yaw, target);
  const step = config.turnSpeedDegreesPerSecond * dt;
  return normalizeDegrees(yaw + Math.max(-step, Math.min(step, delta)));
}

/** New velocity and facing for one step; position is the collider's job. */
export function solveMovement(body: MovingBody, input: MovementInput, config: MovementConfig, surroundings: Surroundings,
  floats: boolean, deltaTime: number): { velocity: Vec3; yawDegrees: number } {
  const dt = Math.max(0, Math.min(deltaTime, 0.1));
  const [dir, magnitude] = stickDirection(input);

  if (surroundings.kind === 'water') {
    const speed = config.walkSpeed * (floats ? 1.1 : 0.6) * (input.isRunning ? 1.3 : 1) * magnitude;
    const horizontal = lerp3(v3(body.velocity.x, 0, body.velocity.z), v3(dir.x * speed, 0, dir.z * speed), Math.min(1, 4 * dt));
    const depth = surroundings.surface - body.position.y;
    let vertical = body.velocity.y;
    if (floats) vertical = (depth - 0.3) * 4;
    else if (input.isJumping) vertical = depth > 1.3 ? 3.2 : config.jumpSpeed * 0.8;
    else vertical = Math.max(-2.5, vertical + config.gravity * 0.15 * dt);
    return { velocity: v3(horizontal.x, vertical, horizontal.z), yawDegrees: turned(body.yawDegrees, dir, magnitude, config, dt) };
  }
  if (surroundings.kind === 'ladder') {
    if (input.isJumping) return { velocity: v3(-dir.x * 3, config.jumpSpeed * 0.8, -dir.z * 3), yawDegrees: body.yawDegrees };
    const side = config.walkSpeed * 0.4 * magnitude;
    return { velocity: v3(dir.x * side, input.stick.z * 3.2, dir.z * side), yawDegrees: turned(body.yawDegrees, dir, magnitude, config, dt) };
  }

  const targetSpeed = config.walkSpeed * (input.isRunning ? config.runMultiplier : 1) * magnitude;
  const target = v3(dir.x * targetSpeed, 0, dir.z * targetSpeed);
  let horizontal = v3(body.velocity.x, 0, body.velocity.z);
  if (body.isGrounded) {
    if (magnitude > 0.01) horizontal = target;
    else {
      const decay = Math.max(0, 1 - config.groundFriction * dt);
      horizontal = v3(horizontal.x * decay, 0, horizontal.z * decay);
    }
  } else {
    horizontal = lerp3(horizontal, target, Math.min(1, config.airControl * dt * 6));
  }
  let vertical = body.velocity.y;
  if (input.isJumping && body.isGrounded) vertical = config.jumpSpeed;
  else vertical = Math.max(config.maxFallSpeed, vertical + config.gravity * dt);
  return { velocity: v3(horizontal.x, vertical, horizontal.z), yawDegrees: turned(body.yawDegrees, dir, magnitude, config, dt) };
}
