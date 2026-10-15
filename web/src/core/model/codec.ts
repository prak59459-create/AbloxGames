// Small pieces of the JSON the iPads write, shared by the world, rules and
// effects without any of them needing the others.
import type { ColorRGBA } from './color';
import type { Vec3 } from './math';

export type ParticleKind = 'fire' | 'smoke' | 'sparkles' | 'confetti' | 'rain' | 'snow' | 'bubbles' | 'hearts' | 'stars'
  | 'leaves' | 'magic' | 'dust';
export const particleKinds: ParticleKind[] = ['fire', 'smoke', 'sparkles', 'confetti', 'rain', 'snow', 'bubbles', 'hearts', 'stars', 'leaves', 'magic', 'dust'];

/** A new id, as Swift's `UUID().uuidString` writes one. */
export function newID(): string {
  return crypto.randomUUID().toUpperCase();
}

const finite = (n: number) => (Number.isFinite(n) ? n : 0);

export function encodeColor(c: ColorRGBA) { return { a: finite(c.a), b: finite(c.b), g: finite(c.g), r: finite(c.r) }; }
export function encodeVec(v: Vec3) { return { x: finite(v.x), y: finite(v.y), z: finite(v.z) }; }

/** A colour from JSON, with `fallback` for whatever is missing (alpha defaults to 1). */
export function decodeColor(v: unknown, fallback: ColorRGBA): ColorRGBA {
  if (!v || typeof v !== 'object' || Array.isArray(v)) return fallback;
  const o = v as Record<string, unknown>;
  const n = (x: unknown, d: number) => (typeof x === 'number' && Number.isFinite(x) ? x : d);
  return { r: n(o.r, fallback.r), g: n(o.g, fallback.g), b: n(o.b, fallback.b), a: n(o.a, 1) };
}
