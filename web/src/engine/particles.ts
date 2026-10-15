// Little bits that fly, fall and fade — ParticleField in Engine/Atmosphere.swift.
// Small cubes, as on the iPad, drawn as two instanced meshes (glowing and
// lit) with a colour each, recycled rather than made and thrown away.
import * as THREE from 'three';
import { colorFromHex, type ColorRGBA } from '../core/model/color';
import type { Vec3 } from '../core/model/math';
import type { ParticleKind } from '../core/model/world';
import { threeColor } from './blocks';

export interface ParticleSpec {
  colors: ColorRGBA[]; rate: number; lifetime: [number, number]; speed: number; spread: number; upward: number; gravity: number;
  size: number; shrinks: boolean; glows: boolean;
}

const hex = (h: string) => colorFromHex(h)!;

export const particleSpecs: Record<ParticleKind, ParticleSpec> = {
  fire: { colors: [hex('#FDE047'), hex('#FB923C'), hex('#EF4444')], rate: 40, lifetime: [0.4, 0.9], speed: 1.2, spread: 25, upward: 2.2, gravity: 1.5, size: 0.22, shrinks: true, glows: true },
  smoke: { colors: [hex('#9CA3AF'), hex('#6B7280')], rate: 14, lifetime: [1.4, 2.6], speed: 0.5, spread: 30, upward: 1.1, gravity: 0.3, size: 0.45, shrinks: false, glows: false },
  sparkles: { colors: [hex('#FEF08A'), hex('#FFFFFF'), hex('#A5F3FC')], rate: 24, lifetime: [0.5, 1.1], speed: 1.6, spread: 180, upward: 0.4, gravity: -0.5, size: 0.1, shrinks: true, glows: true },
  confetti: { colors: [hex('#F43F5E'), hex('#22D3EE'), hex('#FACC15'), hex('#A855F7'), hex('#4ADE80')], rate: 60, lifetime: [1.6, 2.6], speed: 5, spread: 55, upward: 5, gravity: -7, size: 0.12, shrinks: false, glows: false },
  rain: { colors: [hex('#93C5FD')], rate: 220, lifetime: [0.7, 1.0], speed: 0.2, spread: 5, upward: -16, gravity: -4, size: 0.05, shrinks: false, glows: false },
  snow: { colors: [hex('#FFFFFF'), hex('#E0F2FE')], rate: 90, lifetime: [3, 5], speed: 0.5, spread: 180, upward: -1.3, gravity: 0, size: 0.1, shrinks: false, glows: true },
  bubbles: { colors: [hex('#BAE6FD'), hex('#E0F2FE')], rate: 12, lifetime: [1.5, 3], speed: 0.4, spread: 40, upward: 1.2, gravity: 0.2, size: 0.18, shrinks: false, glows: false },
  hearts: { colors: [hex('#F472B6'), hex('#FB7185')], rate: 10, lifetime: [1.2, 2], speed: 0.6, spread: 50, upward: 1.4, gravity: 0.2, size: 0.2, shrinks: true, glows: true },
  stars: { colors: [hex('#FDE047'), hex('#FFFFFF')], rate: 18, lifetime: [0.8, 1.5], speed: 2.2, spread: 180, upward: 1, gravity: -2, size: 0.16, shrinks: true, glows: true },
  leaves: { colors: [hex('#84CC16'), hex('#F59E0B'), hex('#EA580C')], rate: 8, lifetime: [3, 5], speed: 0.8, spread: 180, upward: -0.9, gravity: 0, size: 0.18, shrinks: false, glows: false },
  magic: { colors: [hex('#C084FC'), hex('#818CF8'), hex('#F0ABFC')], rate: 30, lifetime: [0.7, 1.4], speed: 1, spread: 180, upward: 1.2, gravity: 0.5, size: 0.12, shrinks: true, glows: true },
  dust: { colors: [hex('#D6D3D1'), hex('#A8A29E')], rate: 16, lifetime: [0.6, 1.2], speed: 1.4, spread: 70, upward: 0.4, gravity: -1, size: 0.14, shrinks: true, glows: false },
};

interface Particle {
  position: THREE.Vector3; velocity: THREE.Vector3; age: number; life: number; size: THREE.Vector3; shrinks: boolean; gravity: number;
  spin: THREE.Quaternion; color: THREE.Color; glows: boolean;
}

interface Stream { kind: ParticleKind; position: Vec3; rate: number; remaining: number; color?: ColorRGBA; carry: number }

const rand = (lo: number, hi: number) => lo + Math.random() * (hi - lo);
const spinAxis = new THREE.Vector3(0.3, 1, 0.5).normalize();

export class ParticleField {
  readonly root = new THREE.Group();
  private live: Particle[] = [];
  private streams: Stream[] = [];
  private carry = new Map<string, number>();
  private glowing: THREE.InstancedMesh;
  private matte: THREE.InstancedMesh;
  budget = 600;

  constructor() {
    const cube = new THREE.BoxGeometry(1, 1, 1);
    this.glowing = new THREE.InstancedMesh(cube, new THREE.MeshBasicMaterial({ toneMapped: false }), 800);
    this.matte = new THREE.InstancedMesh(cube, new THREE.MeshStandardMaterial({ roughness: 0.8 }), 800);
    for (const mesh of [this.glowing, this.matte]) {
      mesh.count = 0;
      mesh.frustumCulled = false;
      mesh.instanceMatrix.setUsage(THREE.DynamicDrawUsage);
      this.root.add(mesh);
    }
    this.root.name = 'ablox.particles';
  }

  clear(): void {
    this.live = [];
    this.streams = [];
    this.carry.clear();
  }

  /** A script's puff, or a few seconds of them. */
  burst(kind: ParticleKind, position: Vec3, amount: number, seconds: number, color?: ColorRGBA): void {
    if (seconds > 0) this.streams.push({ kind, position, rate: amount, remaining: seconds, color, carry: 0 });
    else this.emit(kind, position, amount, color);
  }

  /** A steady source: `rate` a second, kept smooth across frames by `key`. */
  stream(kind: ParticleKind, key: string, position: Vec3, rate: number, dt: number, spread?: Vec3, color?: ColorRGBA): void {
    let amount = (this.carry.get(key) ?? 0) + rate * dt;
    const whole = Math.floor(amount);
    amount -= whole;
    this.carry.set(key, amount);
    if (whole > 0) this.emit(kind, position, whole, color, spread);
  }

  emit(kind: ParticleKind, at: Vec3, count: number, color?: ColorRGBA, spread?: Vec3): void {
    const spec = particleSpecs[kind];
    const room = Math.min(this.budget, 800) - this.live.length;
    for (let i = 0; i < Math.min(count, room); i++) {
      const tint = color ?? spec.colors[Math.floor(Math.random() * spec.colors.length)];
      const angle = rand(0, 2 * Math.PI);
      const tilt = (rand(0, Math.max(0.001, spec.spread)) * Math.PI) / 180;
      const push = spec.speed * rand(0.6, 1.2);
      const velocity = new THREE.Vector3(Math.sin(tilt) * Math.cos(angle), Math.cos(tilt), Math.sin(tilt) * Math.sin(angle))
        .multiplyScalar(push).add(new THREE.Vector3(0, spec.upward, 0));
      const position = new THREE.Vector3(at.x + rand(-1, 1) * (spread?.x ?? 0), at.y + rand(-1, 1) * (spread?.y ?? 0), at.z + rand(-1, 1) * (spread?.z ?? 0));
      const base = spec.size * rand(0.7, 1.3);
      const size = kind === 'rain' ? new THREE.Vector3(base * 0.6, base * 8, base * 0.6) : new THREE.Vector3(base, base, base);
      const spin = kind === 'rain' ? new THREE.Quaternion() : new THREE.Quaternion().setFromAxisAngle(spinAxis, rand(0, 2 * Math.PI));
      this.live.push({ position, velocity, age: 0, life: rand(spec.lifetime[0], spec.lifetime[1]), size, shrinks: spec.shrinks,
        gravity: spec.gravity, spin, color: threeColor(tint, new THREE.Color()), glows: spec.glows });
    }
  }

  update(dt: number): void {
    for (const s of this.streams) {
      s.remaining -= dt;
      let amount = s.carry + s.rate * dt;
      const whole = Math.floor(amount);
      amount -= whole;
      s.carry = amount;
      if (whole > 0) this.emit(s.kind, s.position, whole, s.color);
    }
    this.streams = this.streams.filter((s) => s.remaining > 0);

    const m = new THREE.Matrix4();
    const scale = new THREE.Vector3();
    let glow = 0, matte = 0;
    let i = 0;
    while (i < this.live.length) {
      const p = this.live[i];
      p.age += dt;
      if (p.age >= p.life) {
        this.live[i] = this.live[this.live.length - 1];
        this.live.pop();
        continue;
      }
      p.velocity.y += p.gravity * dt;
      p.position.addScaledVector(p.velocity, dt);
      scale.copy(p.size);
      if (p.shrinks) scale.multiplyScalar(Math.max(0.05, 1 - p.age / p.life));
      m.compose(p.position, p.spin, scale);
      if (p.glows) {
        this.glowing.setMatrixAt(glow, m);
        this.glowing.setColorAt(glow, p.color);
        glow++;
      } else {
        this.matte.setMatrixAt(matte, m);
        this.matte.setColorAt(matte, p.color);
        matte++;
      }
      i++;
    }
    for (const [mesh, n] of [[this.glowing, glow], [this.matte, matte]] as [THREE.InstancedMesh, number][]) {
      mesh.count = n;
      mesh.instanceMatrix.needsUpdate = true;
      if (mesh.instanceColor) mesh.instanceColor.needsUpdate = true;
    }
  }

  get count(): number { return this.live.length; }
}
