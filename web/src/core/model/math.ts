// Vectors, rotations, transforms and boxes — AbloxCore/Math.swift.
// Right-handed, +Y up, -Z forward, as RealityKit and three.js both are.

export interface Vec3 { x: number; y: number; z: number }
export interface Quat { x: number; y: number; z: number; w: number }
export interface Transform3D { position: Vec3; rotation: Quat; scale: Vec3 }
export interface BoundingBox { min: Vec3; max: Vec3 }

export const v3 = (x = 0, y = 0, z = 0): Vec3 => ({ x, y, z });
export const ZERO: Readonly<Vec3> = Object.freeze(v3());
export const ONE: Readonly<Vec3> = Object.freeze(v3(1, 1, 1));
export const UP: Readonly<Vec3> = Object.freeze(v3(0, 1, 0));
export const FORWARD: Readonly<Vec3> = Object.freeze(v3(0, 0, -1));
export const RIGHT: Readonly<Vec3> = Object.freeze(v3(1, 0, 0));

export const add = (a: Vec3, b: Vec3): Vec3 => v3(a.x + b.x, a.y + b.y, a.z + b.z);
export const sub = (a: Vec3, b: Vec3): Vec3 => v3(a.x - b.x, a.y - b.y, a.z - b.z);
export const mul = (a: Vec3, b: Vec3): Vec3 => v3(a.x * b.x, a.y * b.y, a.z * b.z);
export const scale = (a: Vec3, s: number): Vec3 => v3(a.x * s, a.y * s, a.z * s);
export const dot = (a: Vec3, b: Vec3): number => a.x * b.x + a.y * b.y + a.z * b.z;
export const cross = (a: Vec3, b: Vec3): Vec3 => v3(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x);
export const length = (a: Vec3): number => Math.sqrt(dot(a, a));
export const lengthSquared = (a: Vec3): number => dot(a, a);
export const distance = (a: Vec3, b: Vec3): number => length(sub(a, b));
export const horizontalDistance = (a: Vec3, b: Vec3): number => Math.hypot(a.x - b.x, a.z - b.z);
export const lerp3 = (a: Vec3, b: Vec3, t: number): Vec3 => v3(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t, a.z + (b.z - a.z) * t);
export const isFiniteVec = (a: Vec3): boolean => Number.isFinite(a.x) && Number.isFinite(a.y) && Number.isFinite(a.z);
export const sameVec = (a: Vec3, b: Vec3): boolean => a.x === b.x && a.y === b.y && a.z === b.z;
export const copy3 = (a: Vec3): Vec3 => v3(a.x, a.y, a.z);

export function normalized(a: Vec3): Vec3 {
  const len = length(a);
  return len > 1e-6 ? scale(a, 1 / len) : v3();
}

export const lerp = (a: number, b: number, t: number): number => a + (b - a) * t;
export const clamp = (v: number, lo: number, hi: number): number => Math.min(Math.max(v, lo), hi);

/** Wraps an angle in degrees into (-180, 180]. */
export function normalizeDegrees(degrees: number): number {
  let d = degrees % 360;
  if (d > 180) d -= 360;
  if (d <= -180) d += 360;
  return d;
}

export const angularDelta = (a: number, b: number): number => normalizeDegrees(b - a);

// MARK: - Quaternions

export const IDENTITY: Readonly<Quat> = Object.freeze({ x: 0, y: 0, z: 0, w: 1 });

export function quatAxisAngle(axis: Vec3, angle: number): Quat {
  const n = normalized(axis);
  const s = Math.sin(angle / 2);
  return { x: n.x * s, y: n.y * s, z: n.z * s, w: Math.cos(angle / 2) };
}

/** `a * b`: applies `b` first, then `a`. */
export function quatMul(a: Quat, b: Quat): Quat {
  return {
    x: a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y,
    y: a.w * b.y - a.x * b.z + a.y * b.w + a.z * b.x,
    z: a.w * b.z + a.x * b.y - a.y * b.x + a.z * b.w,
    w: a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z,
  };
}

export function quatNormalized(q: Quat): Quat {
  const len = Math.sqrt(q.x * q.x + q.y * q.y + q.z * q.z + q.w * q.w);
  if (!(len > 1e-6)) return { ...IDENTITY };
  return { x: q.x / len, y: q.y / len, z: q.z / len, w: q.w / len };
}

export function quatInverse(q: Quat): Quat {
  const n = quatNormalized(q);
  return { x: -n.x, y: -n.y, z: -n.z, w: n.w };
}

/** Rotates `v` by `q`. */
export function rotate(q: Quat, v: Vec3): Vec3 {
  const u = v3(q.x, q.y, q.z);
  const s = q.w;
  return add(add(scale(u, 2 * dot(u, v)), scale(v, s * s - dot(u, u))), scale(cross(u, v), 2 * s));
}

/** Euler angles in degrees, intrinsic Y-X-Z (yaw, then pitch, then roll). */
export function quatEulerDegrees(e: Vec3): Quat {
  const r = Math.PI / 180;
  const yaw = quatAxisAngle(UP, e.y * r);
  const pitch = quatAxisAngle(RIGHT, e.x * r);
  const roll = quatAxisAngle(v3(0, 0, 1), e.z * r);
  return quatNormalized(quatMul(quatMul(yaw, pitch), roll));
}

export function eulerDegrees(q: Quat): Vec3 {
  const n = quatNormalized(q);
  const sinPitch = 2 * (n.w * n.x - n.y * n.z);
  const d = 180 / Math.PI;
  const yaw = Math.atan2(2 * (n.w * n.y + n.x * n.z), 1 - 2 * (n.x * n.x + n.y * n.y));
  if (Math.abs(sinPitch) >= 0.99999) return v3((sinPitch > 0 ? 90 : -90), yaw * d, 0);
  const roll = Math.atan2(2 * (n.w * n.z + n.x * n.y), 1 - 2 * (n.x * n.x + n.z * n.z));
  return v3(Math.asin(sinPitch) * d, yaw * d, roll * d);
}

export const quatYaw = (degrees: number): Quat => quatAxisAngle(UP, (degrees * Math.PI) / 180);

/** The yaw a rotation faces, in degrees (0 faces -Z). */
export function yawOf(q: Quat): number {
  const f = rotate(q, FORWARD);
  return (Math.atan2(f.x, -f.z) * 180) / Math.PI;
}

export function slerp(a: Quat, b: Quat, t: number): Quat {
  let qa = quatNormalized(a);
  const qb = quatNormalized(b);
  let c = qa.x * qb.x + qa.y * qb.y + qa.z * qb.z + qa.w * qb.w;
  if (c < 0) { qa = { x: -qa.x, y: -qa.y, z: -qa.z, w: -qa.w }; c = -c; }
  if (c > 0.9995) {
    return quatNormalized({ x: lerp(qa.x, qb.x, t), y: lerp(qa.y, qb.y, t), z: lerp(qa.z, qb.z, t), w: lerp(qa.w, qb.w, t) });
  }
  const theta = Math.acos(c), s = Math.sin(theta);
  const wa = Math.sin((1 - t) * theta) / s, wb = Math.sin(t * theta) / s;
  return quatNormalized({ x: qa.x * wa + qb.x * wb, y: qa.y * wa + qb.y * wb, z: qa.z * wa + qb.z * wb, w: qa.w * wa + qb.w * wb });
}

// MARK: - Transforms

export const identityTransform = (): Transform3D => ({ position: v3(), rotation: { ...IDENTITY }, scale: v3(1, 1, 1) });

/** `child` as a local transform inside `parent`, in `parent`'s space. */
export function concatenate(child: Transform3D, parent: Transform3D): Transform3D {
  return {
    position: add(parent.position, rotate(parent.rotation, mul(child.position, parent.scale))),
    rotation: quatNormalized(quatMul(parent.rotation, child.rotation)),
    scale: mul(parent.scale, child.scale),
  };
}

export function transformPoint(t: Transform3D, p: Vec3): Vec3 {
  return add(t.position, rotate(t.rotation, mul(p, t.scale)));
}

export function inverseTransformPoint(t: Transform3D, p: Vec3): Vec3 {
  const u = rotate(quatInverse(t.rotation), sub(p, t.position));
  return v3(t.scale.x === 0 ? 0 : u.x / t.scale.x, t.scale.y === 0 ? 0 : u.y / t.scale.y, t.scale.z === 0 ? 0 : u.z / t.scale.z);
}

// MARK: - Boxes

export function boxAround(center: Vec3, size: Vec3): BoundingBox {
  return { min: v3(center.x - size.x / 2, center.y - size.y / 2, center.z - size.z / 2),
    max: v3(center.x + size.x / 2, center.y + size.y / 2, center.z + size.z / 2) };
}

export const boxCenter = (b: BoundingBox): Vec3 => scale(add(b.min, b.max), 0.5);
export const boxSize = (b: BoundingBox): Vec3 => sub(b.max, b.min);

export function boxContains(b: BoundingBox, p: Vec3): boolean {
  return p.x >= b.min.x && p.x <= b.max.x && p.y >= b.min.y && p.y <= b.max.y && p.z >= b.min.z && p.z <= b.max.z;
}

/** Inclusive overlap: boxes that merely touch count. */
export function intersects(a: BoundingBox, b: BoundingBox): boolean {
  return a.min.x <= b.max.x && a.max.x >= b.min.x && a.min.y <= b.max.y && a.max.y >= b.min.y && a.min.z <= b.max.z && a.max.z >= b.min.z;
}

/** Strict overlap by more than `epsilon` on every axis — what collision needs. */
export function penetrates(a: BoundingBox, b: BoundingBox, epsilon = 1e-3): boolean {
  return Math.min(a.max.x, b.max.x) - Math.max(a.min.x, b.min.x) > epsilon
    && Math.min(a.max.y, b.max.y) - Math.max(a.min.y, b.min.y) > epsilon
    && Math.min(a.max.z, b.max.z) - Math.max(a.min.z, b.min.z) > epsilon;
}

export function expanded(b: BoundingBox, amount: number): BoundingBox {
  return { min: v3(b.min.x - amount, b.min.y - amount, b.min.z - amount), max: v3(b.max.x + amount, b.max.y + amount, b.max.z + amount) };
}

export function union(a: BoundingBox, b: BoundingBox): BoundingBox {
  return { min: v3(Math.min(a.min.x, b.min.x), Math.min(a.min.y, b.min.y), Math.min(a.min.z, b.min.z)),
    max: v3(Math.max(a.max.x, b.max.x), Math.max(a.max.y, b.max.y), Math.max(a.max.z, b.max.z)) };
}

export function distanceSquaredToBox(b: BoundingBox, p: Vec3): number {
  const dx = Math.max(b.min.x - p.x, 0, p.x - b.max.x);
  const dy = Math.max(b.min.y - p.y, 0, p.y - b.max.y);
  const dz = Math.max(b.min.z - p.z, 0, p.z - b.max.z);
  return dx * dx + dy * dy + dz * dz;
}

/** Slab-method ray/box test: the nearest non-negative hit distance, or null. */
export function rayHitsBox(origin: Vec3, direction: Vec3, box: BoundingBox): number | null {
  let tMin = 0, tMax = Number.MAX_VALUE;
  const axes: ['x', 'y', 'z'] = ['x', 'y', 'z'];
  for (const a of axes) {
    const o = origin[a], d = direction[a], lo = box.min[a], hi = box.max[a];
    if (Math.abs(d) < 1e-6) {
      if (o < lo || o > hi) return null;
      continue;
    }
    let t1 = (lo - o) / d, t2 = (hi - o) / d;
    if (t1 > t2) [t1, t2] = [t2, t1];
    tMin = Math.max(tMin, t1);
    tMax = Math.min(tMax, t2);
    if (tMin > tMax) return null;
  }
  return tMin;
}
