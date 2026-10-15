// A world, as its JSON says: AbloxCore/WorldDocument.swift, BlockData.swift
// and the files beside them. Decoding is as lenient as the Swift (a missing
// field takes the default the iPad would), and encoding writes what an iPad
// needs to read it back — the web can host a game an iPad joins.
import { colorFromHex, defaultBlockColor, defaultGroundColor, type ColorRGBA } from './color';
import { decodeColor, encodeColor, encodeVec, newID, particleKinds, type ParticleKind } from './codec';
import { decodeRule, encodeRule, type EventRule } from './rules';
import {
  boxAround, concatenate, identityTransform, rotate, v3, type BoundingBox, type Transform3D, type Vec3,
} from './math';

export type BlockShape = 'box' | 'sphere' | 'cylinder' | 'cone' | 'plane';
export const blockShapes: BlockShape[] = ['box', 'sphere', 'cylinder', 'cone', 'plane'];

export type MaterialKind =
  | 'plastic' | 'metal' | 'glass' | 'neon' | 'matte'
  | 'wood' | 'stone' | 'brick' | 'grass' | 'sand' | 'ice' | 'water';
export const materialKinds: MaterialKind[] = ['plastic', 'metal', 'glass', 'neon', 'matte', 'wood', 'stone', 'brick', 'grass', 'sand', 'ice', 'water'];

export type SurfacePattern = 'none' | 'grain' | 'speckle' | 'bricks' | 'blades' | 'cracks' | 'ripples';

export const materialInfo: Record<MaterialKind, { roughness: number; alphaScale: number; pattern: SurfacePattern }> = {
  plastic: { roughness: 0.45, alphaScale: 1, pattern: 'none' },
  metal: { roughness: 0.15, alphaScale: 1, pattern: 'none' },
  glass: { roughness: 0.05, alphaScale: 0.35, pattern: 'none' },
  neon: { roughness: 1, alphaScale: 1, pattern: 'none' },
  matte: { roughness: 0.95, alphaScale: 1, pattern: 'none' },
  wood: { roughness: 0.85, alphaScale: 1, pattern: 'grain' },
  stone: { roughness: 0.95, alphaScale: 1, pattern: 'speckle' },
  brick: { roughness: 0.95, alphaScale: 1, pattern: 'bricks' },
  grass: { roughness: 0.85, alphaScale: 1, pattern: 'blades' },
  sand: { roughness: 0.95, alphaScale: 1, pattern: 'speckle' },
  ice: { roughness: 0.1, alphaScale: 0.8, pattern: 'cracks' },
  water: { roughness: 0.05, alphaScale: 0.6, pattern: 'ripples' },
};

export type BlockBehavior =
  | 'none' | 'spawn' | 'checkpoint' | 'hazard' | 'collectible' | 'goal' | 'trigger'
  | 'bounce' | 'disappear' | 'teleport' | 'ladder' | 'door' | 'elevator' | 'vehicle' | 'pushable';
export const blockBehaviors: BlockBehavior[] = ['none', 'spawn', 'checkpoint', 'hazard', 'collectible', 'goal', 'trigger',
  'bounce', 'disappear', 'teleport', 'ladder', 'door', 'elevator', 'vehicle', 'pushable'];

/** Whether the runtime must be told when a player touches a block like this. */
export function needsTouchDetection(b: BlockBehavior): boolean {
  return !(b === 'none' || b === 'spawn' || b === 'ladder' || b === 'elevator');
}

export function isGimmick(b: BlockBehavior): boolean {
  return b === 'bounce' || b === 'disappear' || b === 'teleport' || b === 'door' || b === 'vehicle' || b === 'pushable';
}

/** Walked through rather than into. */
export function isPassThrough(b: BlockBehavior): boolean {
  return b === 'collectible' || b === 'checkpoint' || b === 'spawn' || b === 'trigger' || b === 'teleport'
    || b === 'ladder' || b === 'vehicle';
}

export interface GimmickSettings {
  bounceSpeed: number;
  disappearDelay: number;
  respawnDelay: number;
  teleportTargetID?: string;
  cooldown: number;
  doorSeconds: number;
  moveOffset: Vec3;
  moveSeconds: number;
  movePause: number;
  vehicle: string;
  vehicleSpeed: number;
  stage: number;
}

export const defaultGimmick = (): GimmickSettings => ({
  bounceSpeed: 14, disappearDelay: 0.3, respawnDelay: 3, cooldown: 1.5, doorSeconds: 3,
  moveOffset: v3(0, 6, 0), moveSeconds: 3, movePause: 1.5, vehicle: 'car', vehicleSpeed: 2, stage: 0,
});

export { decodeColor, encodeColor, encodeVec, newID, particleKinds, type ParticleKind };

export interface BlockLight { kind: 'point' | 'spot'; color: ColorRGBA; intensity: number; range: number }
export interface BlockLabelLine { text: string; color: ColorRGBA }
export interface BlockLabel { lines: BlockLabelLine[]; height: number; size: number; range: number }
export type AnimationKind = 'spin' | 'sway' | 'dance' | 'bounce' | 'pulse' | 'wobble';
export interface BlockAnimation { kind: AnimationKind; speed: number }

export interface BlockData {
  id: string;
  name: string;
  shape: BlockShape;
  transform: Transform3D;
  color: ColorRGBA;
  material: MaterialKind;
  isAnchored: boolean;
  hasCollision: boolean;
  isVisible: boolean;
  behavior: BlockBehavior;
  scoreValue: number;
  parentID?: string;
  tags: string[];
  gimmick: GimmickSettings;
  particles?: ParticleKind;
  imageID?: string;
  light?: BlockLight;
  label?: BlockLabel;
  animation?: BlockAnimation;
  layer?: string;
  lockedFlag?: boolean;
}

export type Weather = 'clear' | 'rain' | 'snow' | 'fog' | 'storm';
export type SkyStyle = 'gradient' | 'clouds' | 'sunset' | 'stars' | 'aurora' | 'space';
export type ScreenEffect = 'none' | 'bloom' | 'vivid' | 'warm' | 'cool' | 'noir' | 'retro' | 'dream';
export type MusicTrack = 'calm' | 'adventure' | 'spooky' | 'race' | 'boss' | 'shop' | 'party' | 'space';

export const weatherInfo: Record<Weather, { haze: number; gloom: number; falling?: ParticleKind }> = {
  clear: { haze: 0, gloom: 0 },
  rain: { haze: 0.18, gloom: 0.2, falling: 'rain' },
  snow: { haze: 0.22, gloom: 0, falling: 'snow' },
  fog: { haze: 0.6, gloom: 0.2 },
  storm: { haze: 0.3, gloom: 0.45, falling: 'rain' },
};

export interface EnvironmentSettings {
  skyTop: ColorRGBA;
  skyBottom: ColorRGBA;
  ambientIntensity: number;
  sunPitchDegrees: number;
  sunYawDegrees: number;
  gravity: number;
  killPlaneHeight: number;
  showGroundPlane: boolean;
  groundColor: ColorRGBA;
  weather: Weather;
  timeOfDay?: number;
  dayLengthMinutes: number;
  dayEpoch?: number;
  skyStyle: SkyStyle;
  screenEffect: ScreenEffect;
  shadows: boolean;
  music?: MusicTrack;
}

export const defaultEnvironment = (): EnvironmentSettings => ({
  skyTop: colorFromHex('#0B1026')!, skyBottom: colorFromHex('#1B2A4A')!, ambientIntensity: Math.fround(0.55),
  sunPitchDegrees: -45, sunYawDegrees: 35, gravity: Math.fround(-9.81), killPlaneHeight: -50, showGroundPlane: true,
  groundColor: defaultGroundColor, weather: 'clear', dayLengthMinutes: 0, skyStyle: 'gradient', screenEffect: 'none', shadows: true,
});

export interface ScriptFile { id: string; name: string; source: string; isEnabled: boolean }
export interface WorldImage { id: string; name: string; data: string /* base64 */ }

export interface WorldDocument {
  id: string;
  schemaVersion: number;
  name: string;
  authorName: string;
  createdAt: string;
  modifiedAt: string;
  environment: EnvironmentSettings;
  blocks: BlockData[];
  /** The picker-made rules (see rules.ts); one that cannot be read is left out. */
  rules: EventRule[];
  scripts: ScriptFile[];
  scriptSource?: unknown;
  images: WorldImage[];
}

export const currentSchemaVersion = 2;

// MARK: - Decoding

type Json = Record<string, unknown>;
const obj = (v: unknown): Json | null => (v && typeof v === 'object' && !Array.isArray(v) ? (v as Json) : null);
const num = (v: unknown, fallback: number): number => (typeof v === 'number' && Number.isFinite(v) ? v : fallback);
/** A Swift `Float`: read as the 32-bit value the iPad holds. */
const float = (v: unknown, fallback: number): number => Math.fround(num(v, fallback));
const bool = (v: unknown, fallback: boolean): boolean => (typeof v === 'boolean' ? v : fallback);
const str = (v: unknown, fallback: string): string => (typeof v === 'string' ? v : fallback);
const oneOf = <T extends string>(v: unknown, list: readonly T[], fallback: T): T => (list.includes(v as T) ? (v as T) : fallback);


export function decodeVec(v: unknown, fallback: Vec3 = v3()): Vec3 {
  const o = obj(v);
  if (!o) return { ...fallback };
  return v3(float(o.x, fallback.x), float(o.y, fallback.y), float(o.z, fallback.z));
}

export function decodeTransform(v: unknown): Transform3D {
  const o = obj(v);
  const t = identityTransform();
  if (!o) return t;
  t.position = decodeVec(o.position);
  const r = obj(o.rotation);
  if (r) t.rotation = { x: float(r.x, 0), y: float(r.y, 0), z: float(r.z, 0), w: float(r.w, 1) };
  t.scale = decodeVec(o.scale, v3(1, 1, 1));
  return t;
}

function decodeGimmick(v: unknown): GimmickSettings {
  const d = defaultGimmick();
  const o = obj(v);
  if (!o) return d;
  return {
    bounceSpeed: float(o.bounceSpeed, d.bounceSpeed),
    disappearDelay: num(o.disappearDelay, d.disappearDelay),
    respawnDelay: num(o.respawnDelay, d.respawnDelay),
    teleportTargetID: typeof o.teleportTargetID === 'string' ? o.teleportTargetID.toUpperCase() : undefined,
    cooldown: num(o.cooldown, d.cooldown),
    doorSeconds: num(o.doorSeconds, d.doorSeconds),
    moveOffset: decodeVec(o.moveOffset, d.moveOffset),
    moveSeconds: num(o.moveSeconds, d.moveSeconds),
    movePause: num(o.movePause, d.movePause),
    vehicle: str(o.vehicle, d.vehicle),
    vehicleSpeed: float(o.vehicleSpeed, d.vehicleSpeed),
    stage: num(o.stage, d.stage),
  };
}

const clampTo = (v: number, lo: number, hi: number) => (Number.isFinite(v) ? Math.min(Math.max(v, lo), hi) : lo);

function decodeLabel(v: unknown): BlockLabel | undefined {
  const o = obj(v);
  if (!o) return undefined;
  const lines = Array.isArray(o.lines) ? o.lines : [];
  return {
    lines: lines.slice(0, 4).map((l) => {
      const lo = obj(l) ?? {};
      return { text: [...str(lo.text, '')].slice(0, 60).join(''), color: decodeColor(lo.color, { r: 1, g: 1, b: 1, a: 1 }) };
    }),
    height: Math.fround(clampTo(num(o.height, 0.6), 0, 40)),
    size: Math.fround(clampTo(num(o.size, 1), 0.3, 4)),
    range: Math.fround(clampTo(num(o.range, 60), 4, 250)),
  };
}

function decodeLight(v: unknown): BlockLight | undefined {
  const o = obj(v);
  if (!o) return undefined;
  return {
    kind: o.kind === 'spot' ? 'spot' : 'point',
    color: decodeColor(o.color, { r: 1, g: 0.9, b: 0.7, a: 1 }),
    intensity: Math.fround(Math.max(0, Math.min(1, num(o.intensity, 0.6)))),
    range: Math.fround(Math.max(1, Math.min(50, num(o.range, 10)))),
  };
}

function decodeAnimation(v: unknown): BlockAnimation | undefined {
  const o = obj(v);
  if (!o) return undefined;
  const kinds: AnimationKind[] = ['spin', 'sway', 'dance', 'bounce', 'pulse', 'wobble'];
  if (!kinds.includes(o.kind as AnimationKind)) return undefined;
  return { kind: o.kind as AnimationKind, speed: Math.fround(clampTo(num(o.speed, 1), 0.1, 5)) };
}


export function decodeBlock(v: unknown): BlockData {
  const o = obj(v) ?? {};
  return {
    id: str(o.id, '').toUpperCase() || newID(),
    name: str(o.name, 'Part'),
    shape: oneOf(o.shape, blockShapes, 'box'),
    transform: decodeTransform(o.transform),
    color: decodeColor(o.color, defaultBlockColor),
    material: oneOf(o.material, materialKinds, 'plastic'),
    isAnchored: bool(o.isAnchored, true),
    hasCollision: bool(o.hasCollision, true),
    isVisible: bool(o.isVisible, true),
    behavior: oneOf(o.behavior, blockBehaviors, 'none'),
    scoreValue: num(o.scoreValue, 0),
    parentID: typeof o.parentID === 'string' ? o.parentID.toUpperCase() : undefined,
    tags: Array.isArray(o.tags) ? o.tags.filter((t): t is string => typeof t === 'string') : [],
    gimmick: decodeGimmick(o.gimmick),
    particles: particleKinds.includes(o.particles as ParticleKind) ? (o.particles as ParticleKind) : undefined,
    imageID: typeof o.imageID === 'string' ? o.imageID.toUpperCase() : undefined,
    light: decodeLight(o.light),
    label: decodeLabel(o.label),
    animation: decodeAnimation(o.animation),
    layer: typeof o.layer === 'string' ? o.layer.slice(0, 40) : undefined,
    lockedFlag: o.lockedFlag === true ? true : undefined,
  };
}

export function decodeEnvironment(v: unknown): EnvironmentSettings {
  const d = defaultEnvironment();
  const o = obj(v);
  if (!o) return d;
  return {
    skyTop: decodeColor(o.skyTop, d.skyTop),
    skyBottom: decodeColor(o.skyBottom, d.skyBottom),
    ambientIntensity: float(o.ambientIntensity, d.ambientIntensity),
    sunPitchDegrees: float(o.sunPitchDegrees, d.sunPitchDegrees),
    sunYawDegrees: float(o.sunYawDegrees, d.sunYawDegrees),
    gravity: float(o.gravity, d.gravity),
    killPlaneHeight: float(o.killPlaneHeight, d.killPlaneHeight),
    showGroundPlane: bool(o.showGroundPlane, d.showGroundPlane),
    groundColor: decodeColor(o.groundColor, d.groundColor),
    weather: oneOf(o.weather, ['clear', 'rain', 'snow', 'fog', 'storm'] as const, 'clear'),
    timeOfDay: typeof o.timeOfDay === 'number' ? Math.fround(o.timeOfDay) : undefined,
    dayLengthMinutes: float(o.dayLengthMinutes, 0),
    dayEpoch: typeof o.dayEpoch === 'number' ? o.dayEpoch : undefined,
    skyStyle: oneOf(o.skyStyle, ['gradient', 'clouds', 'sunset', 'stars', 'aurora', 'space'] as const, 'gradient'),
    screenEffect: oneOf(o.screenEffect, ['none', 'bloom', 'vivid', 'warm', 'cool', 'noir', 'retro', 'dream'] as const, 'none'),
    shadows: bool(o.shadows, true),
    music: (['calm', 'adventure', 'spooky', 'race', 'boss', 'shop', 'party', 'space'] as const).find((m) => m === o.music),
  };
}

export function decodeScriptFile(v: unknown): ScriptFile {
  const o = obj(v) ?? {};
  return { id: str(o.id, '') || newID(), name: cleanScriptName(str(o.name, 'main')), source: str(o.source, ''), isEnabled: bool(o.isEnabled, true) };
}

export class WorldFormatError extends Error {}

/** A world from its JSON, mended where an iPad would mend it. */
export function decodeWorld(json: unknown): WorldDocument {
  const o = obj(json);
  if (!o) throw new WorldFormatError('not a world');
  const schemaVersion = num(o.schemaVersion, 1);
  if (schemaVersion > currentSchemaVersion) {
    throw new WorldFormatError(`This world was made with a newer version of Ablox (format ${schemaVersion}).`);
  }
  let scripts: ScriptFile[] = [];
  if (Array.isArray(o.scripts)) scripts = o.scripts.map(decodeScriptFile);
  else if (typeof o.script === 'string') scripts = [{ id: newID(), name: 'main.absc', source: o.script, isEnabled: true }];
  const images = Array.isArray(o.images)
    ? o.images.map((i) => obj(i)).filter((i): i is Json => !!i && typeof i.data === 'string' && typeof i.id === 'string')
      .map((i) => ({ id: i.id as string, name: str(i.name, ''), data: i.data as string }))
      .filter((i) => i.data.length <= 340_000).slice(0, 12)
    : [];
  return repairWorld({
    id: str(o.id, '').toUpperCase() || newID(),
    schemaVersion: Math.max(schemaVersion, currentSchemaVersion),
    name: str(o.name, 'Untitled World'),
    authorName: str(o.authorName, ''),
    createdAt: str(o.createdAt, isoNow()),
    modifiedAt: str(o.modifiedAt, isoNow()),
    environment: decodeEnvironment(o.environment),
    blocks: Array.isArray(o.blocks) ? o.blocks.map(decodeBlock) : [],
    rules: Array.isArray(o.rules) ? o.rules.map(decodeRule).filter((r): r is EventRule => r !== null) : [],
    scripts,
    scriptSource: o.scriptSource ?? undefined,
    images,
  }).world;
}

// MARK: - Repair

export interface RepairReport { badNumbers: number; badSizes: number; duplicateIDs: number; brokenParents: number; badColours: number }

const farthest = 1_000_000;
const sizeFixed = (v: number) => (Number.isFinite(v) ? Math.min(2000, Math.max(0.01, Math.abs(v))) : 1);
const unitFixed = (v: number, fallback = 0) => (Number.isFinite(v) ? Math.min(1, Math.max(0, v)) : fallback);

/**
 * Mends what would misbehave — WorldRepair.swift: a size or a place that is
 * not a number, two parts sharing an id, a part whose parent is gone or is
 * its own grandchild. A world with nothing wrong comes out as it went in.
 */
export function repairWorld(world: WorldDocument): { world: WorldDocument; report: RepairReport } {
  const report: RepairReport = { badNumbers: 0, badSizes: 0, duplicateIDs: 0, brokenParents: 0, badColours: 0 };
  const seen = new Set<string>();
  const blocks = world.blocks.map((original) => {
    let block = original;
    const edit = () => { if (block === original) block = { ...original, transform: { ...original.transform } }; };
    if (seen.has(block.id)) {
      edit();
      block.id = newID();
      report.duplicateIDs++;
    }
    seen.add(block.id);
    const p = block.transform.position;
    if (![p.x, p.y, p.z].every((n) => Number.isFinite(n) && Math.abs(n) <= farthest)) {
      edit();
      block.transform.position = v3();
      report.badNumbers++;
    }
    const q = block.transform.rotation;
    if (![q.x, q.y, q.z, q.w].every(Number.isFinite) || q.x * q.x + q.y * q.y + q.z * q.z + q.w * q.w < 1e-6) {
      edit();
      block.transform.rotation = { x: 0, y: 0, z: 0, w: 1 };
      report.badNumbers++;
    }
    const sc = block.transform.scale;
    const fixed = v3(sizeFixed(sc.x), sizeFixed(sc.y), sizeFixed(sc.z));
    if (fixed.x !== sc.x || fixed.y !== sc.y || fixed.z !== sc.z) {
      edit();
      block.transform.scale = fixed;
      report.badSizes++;
    }
    const c = block.color;
    const colour = { r: unitFixed(c.r), g: unitFixed(c.g), b: unitFixed(c.b), a: unitFixed(c.a, 1) };
    if (colour.r !== c.r || colour.g !== c.g || colour.b !== c.b || colour.a !== c.a) {
      edit();
      block.color = colour;
      report.badColours++;
    }
    return block;
  });
  const ids = new Set(blocks.map((b) => b.id));
  const parentOf = new Map<string, string | undefined>();
  for (const b of blocks) if (!parentOf.has(b.id)) parentOf.set(b.id, b.parentID);
  blocks.forEach((b, index) => {
    const parent = b.parentID;
    if (!parent) return;
    let broken = !ids.has(parent) || parent === b.id;
    if (!broken) {
      const visited = new Set([b.id]);
      let next: string | undefined = parent;
      while (next) {
        if (visited.has(next)) { broken = true; break; }
        visited.add(next);
        next = parentOf.get(next);
      }
    }
    if (broken) {
      blocks[index] = { ...b, parentID: undefined };
      parentOf.set(b.id, undefined);
      report.brokenParents++;
    }
  });
  const total = report.badNumbers + report.badSizes + report.duplicateIDs + report.brokenParents + report.badColours;
  return { world: total ? { ...world, blocks } : world, report };
}

/** ISO 8601 without fractions: what Swift's `.iso8601` reads. */
export function isoNow(): string {
  return new Date().toISOString().replace(/\.\d{3}Z$/, 'Z');
}

/** `ScriptFile.cleanName`: a safe name ending in .absc. */
export function cleanScriptName(raw: string): string {
  let name = raw.trim();
  const slash = Math.max(name.lastIndexOf('/'), name.lastIndexOf('\\'));
  if (slash >= 0) name = name.slice(slash + 1);
  if (name.toLowerCase().endsWith('.absc')) name = name.slice(0, -5);
  const allowed = [...name].filter((c) => /[\p{L}\p{N}_\- ]/u.test(c)).slice(0, 40).join('').trim();
  return (allowed || 'main') + '.absc';
}

/** Repository scripts over the world's own: same name replaces, others are added. */
export function mergeScripts(downloaded: { name: string; source: string }[], files: ScriptFile[]): ScriptFile[] {
  const merged = files.map((f) => ({ ...f }));
  for (const file of downloaded) {
    const name = cleanScriptName(file.name);
    const existing = merged.find((m) => m.name.toLowerCase() === name.toLowerCase());
    if (existing) existing.source = file.source;
    else if (merged.length < 32) merged.push({ id: newID(), name, source: file.source, isEnabled: true });
  }
  return merged;
}

export function hasScript(world: WorldDocument): boolean {
  return world.scripts.some((s) => s.isEnabled && s.source.trim() !== '');
}

// MARK: - Encoding (for iPads)


export function encodeBlock(b: BlockData): Json {
  const out: Json = {
    behavior: b.behavior, color: encodeColor(b.color),
    gimmick: encodeGimmick(b.gimmick), hasCollision: b.hasCollision, id: b.id, isAnchored: b.isAnchored, isVisible: b.isVisible,
    material: b.material, name: b.name, scoreValue: Math.round(b.scoreValue), shape: b.shape, tags: b.tags,
    transform: { position: encodeVec(b.transform.position), rotation: { w: b.transform.rotation.w, x: b.transform.rotation.x, y: b.transform.rotation.y, z: b.transform.rotation.z }, scale: encodeVec(b.transform.scale) },
  };
  if (b.parentID) out.parentID = b.parentID;
  if (b.particles) out.particles = b.particles;
  if (b.imageID) out.imageID = b.imageID;
  if (b.light) out.light = { color: encodeColor(b.light.color), intensity: b.light.intensity, kind: b.light.kind, range: b.light.range };
  if (b.label) out.label = { height: b.label.height, lines: b.label.lines.map((l) => ({ color: encodeColor(l.color), text: l.text })), range: b.label.range, size: b.label.size };
  if (b.animation) out.animation = { kind: b.animation.kind, speed: b.animation.speed };
  if (b.layer) out.layer = b.layer;
  if (b.lockedFlag) out.lockedFlag = true;
  return out;
}

function encodeGimmick(g: GimmickSettings): Json {
  const d = defaultGimmick();
  const out: Json = { bounceSpeed: g.bounceSpeed, cooldown: g.cooldown, disappearDelay: g.disappearDelay, respawnDelay: g.respawnDelay };
  if (g.teleportTargetID) out.teleportTargetID = g.teleportTargetID;
  if (g.doorSeconds !== d.doorSeconds) out.doorSeconds = g.doorSeconds;
  if (g.moveOffset.x !== d.moveOffset.x || g.moveOffset.y !== d.moveOffset.y || g.moveOffset.z !== d.moveOffset.z) out.moveOffset = encodeVec(g.moveOffset);
  if (g.moveSeconds !== d.moveSeconds) out.moveSeconds = g.moveSeconds;
  if (g.movePause !== d.movePause) out.movePause = g.movePause;
  if (g.vehicle !== d.vehicle) out.vehicle = g.vehicle;
  if (g.vehicleSpeed !== d.vehicleSpeed) out.vehicleSpeed = g.vehicleSpeed;
  if (g.stage !== d.stage) out.stage = Math.round(g.stage);
  return out;
}

export function encodeEnvironment(e: EnvironmentSettings): Json {
  const out: Json = {
    ambientIntensity: e.ambientIntensity, gravity: e.gravity, groundColor: encodeColor(e.groundColor), killPlaneHeight: e.killPlaneHeight,
    showGroundPlane: e.showGroundPlane, skyBottom: encodeColor(e.skyBottom), skyTop: encodeColor(e.skyTop),
    sunPitchDegrees: e.sunPitchDegrees, sunYawDegrees: e.sunYawDegrees,
  };
  if (e.weather !== 'clear') out.weather = e.weather;
  if (e.timeOfDay !== undefined) out.timeOfDay = e.timeOfDay;
  if (e.dayLengthMinutes !== 0) out.dayLengthMinutes = e.dayLengthMinutes;
  if (e.skyStyle !== 'gradient') out.skyStyle = e.skyStyle;
  if (e.screenEffect !== 'none') out.screenEffect = e.screenEffect;
  if (!e.shadows) out.shadows = false;
  if (e.music) out.music = e.music;
  if (e.dayEpoch !== undefined) out.dayEpoch = e.dayEpoch;
  return out;
}

export function encodeWorld(w: WorldDocument): Json {
  const out: Json = {
    authorName: w.authorName, blocks: w.blocks.map(encodeBlock), createdAt: w.createdAt, environment: encodeEnvironment(w.environment),
    id: w.id, modifiedAt: w.modifiedAt, name: w.name, rules: w.rules.map(encodeRule), schemaVersion: neededSchemaVersion(w),
  };
  if (w.scripts.length) out.scripts = w.scripts.map((s) => ({ id: s.id, isEnabled: s.isEnabled, name: s.name, source: s.source }));
  if (w.scriptSource !== undefined) out.scriptSource = w.scriptSource;
  if (w.images.length) out.images = w.images;
  return out;
}

function neededSchemaVersion(w: WorldDocument): number {
  const e = w.environment;
  const env2 = e.weather !== 'clear' || e.timeOfDay !== undefined || e.dayLengthMinutes !== 0 || e.skyStyle !== 'gradient'
    || e.screenEffect !== 'none' || !e.shadows || e.music !== undefined;
  const block2 = w.blocks.some((b) => !['plastic', 'metal', 'glass', 'neon', 'matte'].includes(b.material)
    || ['ladder', 'door', 'elevator', 'vehicle', 'pushable'].includes(b.behavior) || b.particles || b.imageID);
  return w.images.length || env2 || block2 ? 2 : 1;
}

// MARK: - Shapes and places

/** Local bounds for a unit block of this shape. */
export function unitSize(shape: BlockShape): Vec3 {
  return shape === 'plane' ? v3(1, 0.01, 1) : v3(1, 1, 1);
}

/** The axis-aligned box of `block` placed at world transform `t`, grown to cover any tilt. */
export function blockBounds(block: BlockData, t: Transform3D): BoundingBox {
  const u = unitSize(block.shape);
  const h = v3(u.x * t.scale.x * 0.5, u.y * t.scale.y * 0.5, u.z * t.scale.z * 0.5);
  const ax = rotate(t.rotation, v3(h.x, 0, 0));
  const ay = rotate(t.rotation, v3(0, h.y, 0));
  const az = rotate(t.rotation, v3(0, 0, h.z));
  const extent = v3(
    Math.abs(ax.x) + Math.abs(ay.x) + Math.abs(az.x),
    Math.abs(ax.y) + Math.abs(ay.y) + Math.abs(az.y),
    Math.abs(ax.z) + Math.abs(ay.z) + Math.abs(az.z),
  );
  return boxAround(t.position, v3(extent.x * 2, extent.y * 2, extent.z * 2));
}

/** World transform of a block, through its parents (a cycle stops the walk). */
export function worldTransformOf(block: BlockData, find: (id: string) => BlockData | undefined): Transform3D {
  let result = block.transform;
  if (!block.parentID) return result;
  const seen = new Set([block.id]);
  let cursor: string | undefined = block.parentID;
  while (cursor) {
    const parent = find(cursor);
    if (!parent || seen.has(cursor)) break;
    seen.add(cursor);
    result = concatenate(result, parent.transform);
    cursor = parent.parentID;
  }
  return result;
}

export function hasTag(block: BlockData, tag: string): boolean {
  const t = tag.toLowerCase();
  return block.tags.some((x) => x.toLowerCase() === t);
}

export function isSolidForPlayers(b: BlockData): boolean {
  return b.isVisible && b.hasCollision && b.material !== 'water';
}

/** Where player number `index` starts: spawn blocks in order, cycled. */
export function spawnPosition(world: WorldDocument, index: number, find: (id: string) => BlockData | undefined): Vec3 {
  const spawns = world.blocks.filter((b) => b.behavior === 'spawn');
  if (spawns.length === 0) return v3(0, 2, 0);
  const spawn = spawns[((index % spawns.length) + spawns.length) % spawns.length];
  const t = worldTransformOf(spawn, find);
  const top = t.position.y + unitSize(spawn.shape).y * t.scale.y * 0.5;
  return v3(t.position.x, top + 1, t.position.z);
}

/** A map from id to block, for the world's own lookups. */
export function blockMap(world: WorldDocument): Map<string, BlockData> {
  const map = new Map<string, BlockData>();
  for (const b of world.blocks) if (!map.has(b.id)) map.set(b.id, b);
  return map;
}

/** `BlockData(…)` with Swift's defaults: a grey plastic box at the origin. */
export function makeBlock(o: Partial<BlockData> = {}): BlockData {
  return {
    id: o.id ?? newID(), name: o.name ?? 'Part', shape: o.shape ?? 'box', transform: o.transform ?? identityTransform(),
    color: o.color ?? { ...defaultBlockColor }, material: o.material ?? 'plastic', isAnchored: o.isAnchored ?? true,
    hasCollision: o.hasCollision ?? true, isVisible: o.isVisible ?? true, behavior: o.behavior ?? 'none', scoreValue: o.scoreValue ?? 0,
    parentID: o.parentID, tags: o.tags ?? [], gimmick: o.gimmick ?? defaultGimmick(), particles: o.particles, imageID: o.imageID,
    light: o.light, label: o.label, animation: o.animation, layer: o.layer, lockedFlag: o.lockedFlag,
  };
}

/** A transform at `position`, optionally scaled and turned (Euler degrees). */
export function placed(position: Vec3, size: Vec3 = v3(1, 1, 1), rotation?: Transform3D['rotation']): Transform3D {
  return { position, rotation: rotation ?? { x: 0, y: 0, z: 0, w: 1 }, scale: size };
}

/** A world with nothing in it, as `WorldDocument(name:)` makes. */
export function emptyWorld(name = 'Untitled World', author = ''): WorldDocument {
  const now = isoNow();
  return {
    id: newID(), schemaVersion: currentSchemaVersion, name, authorName: author, createdAt: now, modifiedAt: now,
    environment: defaultEnvironment(), blocks: [], rules: [], scripts: [], images: [],
  };
}
