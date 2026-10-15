// Rules made with pickers, and what anything that happens in a game sends
// players — AbloxCore/EventRule.swift. Each has a `type` key in its JSON,
// which is how a world file and the network write them.
import type { ColorRGBA } from './color';
import { decodeEffect, encodeEffect, type ScriptEffect } from './effects';
import { decodeColor, encodeColor, encodeVec, newID } from './codec';
import { v3, type Vec3 } from './math';

export type EventTrigger =
  | { type: 'blockTouched'; blockID: string }
  | { type: 'tagTouched'; tag: string }
  | { type: 'blockTapped'; blockID: string }
  | { type: 'proximity'; blockID: string; radius: number }
  | { type: 'worldStart' }
  | { type: 'timer'; interval: number }
  | { type: 'scoreReached'; score: number };

export type EventAction =
  | { type: 'tint'; blockID: string; color: ColorRGBA; duration: number }
  | { type: 'move'; blockID: string; offset: Vec3; duration: number }
  | { type: 'setVisible'; blockID: string; visible: boolean }
  | { type: 'setCollision'; blockID: string; enabled: boolean }
  | { type: 'teleportPlayer'; position: Vec3 }
  | { type: 'awardPoints'; points: number }
  | { type: 'announce'; message: string; duration: number }
  | { type: 'playSound'; name: string }
  | { type: 'endRound'; message: string }
  | { type: 'bouncePlayer'; speed: number }
  | { type: 'script'; effect: ScriptEffect };

export interface EventRule {
  id: string;
  name: string;
  isEnabled: boolean;
  trigger: EventTrigger;
  actions: EventAction[];
  /** How many times it may fire in a round; undefined is no limit. */
  maxFireCount?: number;
  cooldown: number;
}

export function eventRule(o: Partial<EventRule> & { trigger: EventTrigger }): EventRule {
  return {
    id: o.id ?? newID(), name: o.name ?? 'New Rule', isEnabled: o.isEnabled ?? true, trigger: o.trigger,
    actions: o.actions ?? [], maxFireCount: o.maxFireCount, cooldown: o.cooldown ?? 0.5,
  };
}

type Json = Record<string, unknown>;
const obj = (v: unknown): Json | null => (v && typeof v === 'object' && !Array.isArray(v) ? (v as Json) : null);
const num = (v: unknown): number | undefined => (typeof v === 'number' && Number.isFinite(v) ? v : undefined);
const vec = (v: unknown): Vec3 | undefined => {
  const o = obj(v);
  if (!o) return undefined;
  const x = num(o.x), y = num(o.y), z = num(o.z);
  return x === undefined || y === undefined || z === undefined ? undefined : v3(x, y, z);
};
const id = (v: unknown): string | undefined => (typeof v === 'string' && v.length > 0 ? v.toUpperCase() : undefined);

export function decodeTrigger(v: unknown): EventTrigger | null {
  const o = obj(v);
  if (!o) return null;
  switch (o.type) {
    case 'blockTouched': { const b = id(o.blockID); return b ? { type: 'blockTouched', blockID: b } : null; }
    case 'tagTouched': return typeof o.tag === 'string' ? { type: 'tagTouched', tag: o.tag } : null;
    case 'blockTapped': { const b = id(o.blockID); return b ? { type: 'blockTapped', blockID: b } : null; }
    case 'proximity': { const b = id(o.blockID); return b ? { type: 'proximity', blockID: b, radius: num(o.radius) ?? 3 } : null; }
    case 'worldStart': return { type: 'worldStart' };
    case 'timer': return { type: 'timer', interval: num(o.interval) ?? 1 };
    case 'scoreReached': { const s = num(o.score); return s === undefined ? null : { type: 'scoreReached', score: Math.trunc(s) }; }
    default: return null;
  }
}

export function encodeTrigger(t: EventTrigger): Json {
  switch (t.type) {
    case 'blockTouched': case 'blockTapped': return { blockID: t.blockID, type: t.type };
    case 'tagTouched': return { tag: t.tag, type: t.type };
    case 'proximity': return { blockID: t.blockID, radius: t.radius, type: t.type };
    case 'worldStart': return { type: t.type };
    case 'timer': return { interval: t.interval, type: t.type };
    case 'scoreReached': return { score: t.score, type: t.type };
  }
}

export function decodeAction(v: unknown): EventAction | null {
  const o = obj(v);
  if (!o) return null;
  switch (o.type) {
    case 'tint': {
      const b = id(o.blockID), c = obj(o.color);
      return b && c ? { type: 'tint', blockID: b, color: decodeColor(c, { r: 1, g: 1, b: 1, a: 1 }), duration: num(o.duration) ?? 0 } : null;
    }
    case 'move': {
      const b = id(o.blockID), offset = vec(o.offset);
      return b && offset ? { type: 'move', blockID: b, offset, duration: num(o.duration) ?? 0 } : null;
    }
    case 'setVisible': { const b = id(o.blockID); return b ? { type: 'setVisible', blockID: b, visible: typeof o.visible === 'boolean' ? o.visible : true } : null; }
    case 'setCollision': { const b = id(o.blockID); return b ? { type: 'setCollision', blockID: b, enabled: typeof o.enabled === 'boolean' ? o.enabled : true } : null; }
    case 'teleportPlayer': { const p = vec(o.position); return p ? { type: 'teleportPlayer', position: p } : null; }
    case 'awardPoints': { const p = num(o.points); return p === undefined ? null : { type: 'awardPoints', points: Math.trunc(p) }; }
    case 'announce': return typeof o.message === 'string' ? { type: 'announce', message: o.message, duration: num(o.duration) ?? 2 } : null;
    case 'playSound': return typeof o.name === 'string' ? { type: 'playSound', name: o.name } : null;
    case 'endRound': return { type: 'endRound', message: typeof o.message === 'string' ? o.message : 'Round over' };
    case 'bouncePlayer': return { type: 'bouncePlayer', speed: num(o.speed) ?? 14 };
    case 'script': { const e = decodeEffect(o.effect); return e ? { type: 'script', effect: e } : null; }
    default: return null;
  }
}

export function encodeAction(a: EventAction): Json {
  switch (a.type) {
    case 'tint': return { blockID: a.blockID, color: encodeColor(a.color), duration: a.duration, type: a.type };
    case 'move': return { blockID: a.blockID, duration: a.duration, offset: encodeVec(a.offset), type: a.type };
    case 'setVisible': return { blockID: a.blockID, type: a.type, visible: a.visible };
    case 'setCollision': return { blockID: a.blockID, enabled: a.enabled, type: a.type };
    case 'teleportPlayer': return { position: encodeVec(a.position), type: a.type };
    case 'awardPoints': return { points: a.points, type: a.type };
    case 'announce': return { duration: a.duration, message: a.message, type: a.type };
    case 'playSound': return { name: a.name, type: a.type };
    case 'endRound': return { message: a.message, type: a.type };
    case 'bouncePlayer': return { speed: a.speed, type: a.type };
    case 'script': return { effect: encodeEffect(a.effect), type: a.type };
  }
}

/** A rule from a world file; null when its trigger cannot be read. */
export function decodeRule(v: unknown): EventRule | null {
  const o = obj(v);
  if (!o) return null;
  const trigger = decodeTrigger(o.trigger);
  if (!trigger) return null;
  const actions = Array.isArray(o.actions) ? o.actions.map(decodeAction).filter((a): a is EventAction => a !== null) : [];
  return {
    id: id(o.id) ?? newID(), name: typeof o.name === 'string' ? o.name : 'Rule', isEnabled: typeof o.isEnabled === 'boolean' ? o.isEnabled : true,
    trigger, actions, maxFireCount: num(o.maxFireCount) === undefined ? undefined : Math.trunc(num(o.maxFireCount)!), cooldown: num(o.cooldown) ?? 0.5,
  };
}

export function encodeRule(r: EventRule): Json {
  const out: Json = {
    actions: r.actions.map(encodeAction), cooldown: r.cooldown, id: r.id, isEnabled: r.isEnabled, name: r.name, trigger: encodeTrigger(r.trigger),
  };
  if (r.maxFireCount !== undefined) out.maxFireCount = r.maxFireCount;
  return out;
}

export function referencedBlockIDs(r: EventRule): string[] {
  const out: string[] = [];
  const t = r.trigger;
  if (t.type === 'blockTouched' || t.type === 'blockTapped' || t.type === 'proximity') out.push(t.blockID);
  for (const a of r.actions) {
    if (a.type === 'tint' || a.type === 'move' || a.type === 'setVisible' || a.type === 'setCollision') out.push(a.blockID);
  }
  return out;
}

export const ruleReferences = (r: EventRule, ids: Set<string>) => referencedBlockIDs(r).some((x) => ids.has(x));
