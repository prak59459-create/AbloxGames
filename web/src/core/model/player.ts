// A player as the room sees them, what they send the host, and the small
// fixed lists a game names things from — Player.swift, Packets.swift,
// Gestures.swift, SoundCue.swift and MusicTracks.swift.
import { decodeProfile, defaultProfile, emotes, encodeProfile, type AvatarProfile } from './avatar';
import { encodeVec } from './codec';
import { deepEqual } from './equal';
import { angularDelta, lerp3, normalizeDegrees, v3, type Vec3 } from './math';
import { SaveData } from './save';
import { prefix } from './text';

export interface PlayerSnapshot {
  peerID: string;
  profile: AvatarProfile;
  position: Vec3;
  yawDegrees: number;
  velocity: Vec3;
  isGrounded: boolean;
  score: number;
  isReady: boolean;
  isNPC: boolean;
  isHidden: boolean;
  team: string;
}

export function playerSnapshot(peerID: string, o: Partial<PlayerSnapshot> = {}): PlayerSnapshot {
  return {
    peerID, profile: o.profile ?? defaultProfile(), position: o.position ?? v3(), yawDegrees: o.yawDegrees ?? 0,
    velocity: o.velocity ?? v3(), isGrounded: o.isGrounded ?? true, score: o.score ?? 0, isReady: o.isReady ?? false,
    isNPC: o.isNPC ?? false, isHidden: o.isHidden ?? false, team: o.team ?? '',
  };
}

export const copySnapshot = (s: PlayerSnapshot): PlayerSnapshot => ({
  ...s, profile: structuredClone(s.profile), position: { ...s.position }, velocity: { ...s.velocity },
});

type Json = Record<string, unknown>;
const o = (v: unknown): Json => (v && typeof v === 'object' && !Array.isArray(v) ? (v as Json) : {});
const num = (v: unknown, d = 0) => (typeof v === 'number' && Number.isFinite(v) ? v : d);
const vec = (v: unknown): Vec3 => { const x = o(v); return v3(Math.fround(num(x.x)), Math.fround(num(x.y)), Math.fround(num(x.z))); };

export function decodeSnapshot(v: unknown): PlayerSnapshot | null {
  const x = o(v);
  if (typeof x.peerID !== 'string') return null;
  return {
    peerID: x.peerID.toUpperCase(), profile: decodeProfile(x.profile), position: vec(x.position), yawDegrees: num(x.yawDegrees),
    velocity: vec(x.velocity), isGrounded: x.isGrounded !== false, score: Math.trunc(num(x.score)), isReady: x.isReady === true,
    isNPC: x.isNPC === true, isHidden: x.isHidden === true, team: prefix(typeof x.team === 'string' ? x.team : '', 32),
  };
}

export function encodeSnapshot(s: PlayerSnapshot): Json {
  const out: Json = {
    isGrounded: s.isGrounded, isHidden: s.isHidden, isNPC: s.isNPC, isReady: s.isReady, peerID: s.peerID,
    position: encodeVec(s.position), profile: encodeProfile(s.profile), score: s.score, velocity: encodeVec(s.velocity), yawDegrees: s.yawDegrees,
  };
  if (s.team) out.team = s.team;
  return out;
}

/** Part of the way toward `target`, yaw the short way round. */
export function interpolated(from: PlayerSnapshot, target: PlayerSnapshot, t: number): PlayerSnapshot {
  return {
    ...target,
    position: lerp3(from.position, target.position, t),
    yawDegrees: normalizeDegrees(from.yawDegrees + angularDelta(from.yawDegrees, target.yawDegrees) * t),
    velocity: lerp3(from.velocity, target.velocity, t),
  };
}

export const sameProfile = (a: AvatarProfile, b: AvatarProfile) => deepEqual(a, b);

export interface PlayerTransform { peerID: string; position: Vec3; yawDegrees: number; velocity: Vec3; isGrounded: boolean }

export const transformOf = (s: PlayerSnapshot): PlayerTransform => ({
  peerID: s.peerID, position: { ...s.position }, yawDegrees: s.yawDegrees, velocity: { ...s.velocity }, isGrounded: s.isGrounded,
});

export function decodeTransform(v: unknown): PlayerTransform | null {
  const x = o(v);
  if (typeof x.peerID !== 'string') return null;
  return { peerID: x.peerID.toUpperCase(), position: vec(x.position), yawDegrees: num(x.yawDegrees), velocity: vec(x.velocity), isGrounded: x.isGrounded !== false };
}

export const encodeTransform = (t: PlayerTransform): Json => ({
  isGrounded: t.isGrounded, peerID: t.peerID, position: encodeVec(t.position), velocity: encodeVec(t.velocity), yawDegrees: t.yawDegrees,
});

// MARK: - What a player presses

export type PlayerInput =
  | { kind: 'fire'; origin: Vec3; direction: Vec3 }
  | { kind: 'button'; id: string }
  | { kind: 'reload' }
  | { kind: 'text'; id: string; value: string }
  | { kind: 'saved'; data: SaveData }
  | { kind: 'gesture'; wire: string };

export function encodeInput(i: PlayerInput): Json {
  switch (i.kind) {
    case 'fire': return { fire: { direction: encodeVec(i.direction), origin: encodeVec(i.origin) } };
    case 'button': return { button: { id: i.id } };
    case 'reload': return { reload: {} };
    case 'text': return { text: { id: i.id, value: i.value } };
    case 'saved': return { saved: { _0: i.data.values } };
    case 'gesture': return { gesture: { _0: i.wire } };
  }
}

export function decodeInput(v: unknown): PlayerInput | null {
  const x = o(v);
  const keys = Object.keys(x);
  if (keys.length !== 1) return null;
  const p = o(x[keys[0]]);
  switch (keys[0]) {
    case 'fire': return { kind: 'fire', origin: vec(p.origin), direction: vec(p.direction) };
    case 'button': return typeof p.id === 'string' ? { kind: 'button', id: p.id } : null;
    case 'reload': return { kind: 'reload' };
    case 'text': return typeof p.id === 'string' && typeof p.value === 'string' ? { kind: 'text', id: p.id, value: p.value } : null;
    case 'saved': return { kind: 'saved', data: SaveData.decode(p._0) };
    case 'gesture': return typeof p._0 === 'string' ? { kind: 'gesture', wire: p._0 } : null;
    default: return null;
  }
}

// MARK: - Gestures

export const stamps = ['😀', '😂', '👍', '❤️', '🎉', '😮', '😢', '😡', '🔥', '⭐️', '👋', '💯',
  '😎', '🤔', '😴', '🥳', '😱', '🤩', '👏', '🙏', '🏆', '🍕', '🐱', '🌈'];

/** "wave", or "stamp:🎉": what travels. Null for anything else. */
export function parseGesture(wire: string): { kind: 'emote'; emote: string; wire: string } | { kind: 'stamp'; stamp: string; wire: string } | null {
  if ((emotes as readonly string[]).includes(wire)) return { kind: 'emote', emote: wire, wire };
  if (wire.startsWith('stamp:') && stamps.includes(wire.slice(6))) return { kind: 'stamp', stamp: wire.slice(6), wire };
  return null;
}

export const gestureInterval = 0.8;

// MARK: - Sounds and music

export const soundCues = ['collect', 'checkpoint', 'hurt', 'bounce', 'teleport', 'goal', 'join', 'leave', 'tick', 'error', 'shoot', 'hit',
  'reload', 'defeat', 'coin', 'jump', 'powerup', 'explosion', 'splash', 'door', 'click', 'whoosh', 'win', 'lose', 'magic', 'pop', 'bell',
  'laser', 'alarm', 'drum'] as const;
export type SoundCue = (typeof soundCues)[number];

/** A built-in cue by its authored name, ignoring case and spaces round it. */
export function soundCueNamed(raw: string): SoundCue | null {
  const key = raw.replace(/^[\p{Z}\t\n\v\f\r\u0085]+|[\p{Z}\t\n\v\f\r\u0085]+$/gu, '').toLowerCase();
  return (soundCues as readonly string[]).includes(key) ? (key as SoundCue) : null;
}

/** A sound library id, like "retro-game-coin-08". */
export function isLibraryID(name: string): boolean {
  if (name.length > 96 || !name.includes('-') || name.startsWith('-') || name.endsWith('-') || name.includes('--')) return false;
  return /^[a-z0-9-]+$/.test(name);
}

export const musicTracks = ['calm', 'adventure', 'spooky', 'race', 'boss', 'shop', 'party', 'space'] as const;
