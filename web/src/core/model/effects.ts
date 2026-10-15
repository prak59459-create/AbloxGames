// What a world's script does to a player's screen and camera, and the panels
// the runtime puts up — AbloxCore/ScriptEffect.swift and ScriptPanels.swift.
//
// The JSON is what Swift's synthesized Codable writes, so these travel to and
// from iPads unchanged: an enum case is `{"name": {labels…}}`, an unlabelled
// value is `_0`, and an absent optional is an absent key.
import type { ColorRGBA } from './color';
import { decodeWeapon, encodeWeapon, type WeaponSpec } from './combat';
import { decodeColor, encodeColor, encodeVec, particleKinds, type ParticleKind } from './codec';
import { SaveData } from './save';
import { prefix } from './text';
import { v3, type Vec3 } from './math';

// MARK: - Screen items

export type UIKind = 'panel' | 'text' | 'button' | 'image' | 'bar' | 'input';
export const uiKinds: UIKind[] = ['panel', 'text', 'button', 'image', 'bar', 'input'];

export interface UIElement {
  id: string;
  kind: UIKind;
  parent?: string;
  text: string;
  value: number;
  maximum: number;
  x: number;
  y: number;
  pivotX: number;
  pivotY: number;
  offsetX: number;
  offsetY: number;
  width?: number;
  height?: number;
  color?: ColorRGBA;
  background?: ColorRGBA;
  fontSize: number;
  bold: boolean;
  cornerRadius: number;
  opacity: number;
  visible: boolean;
  layer: number;
}

export function uiElement(id: string, kind: UIKind, o: Partial<UIElement> = {}): UIElement {
  return {
    id, kind, parent: o.parent, text: o.text ?? '', value: o.value ?? 0, maximum: o.maximum ?? 100,
    x: o.x ?? 0.5, y: o.y ?? 0.5, pivotX: o.pivotX ?? 0.5, pivotY: o.pivotY ?? 0.5, offsetX: o.offsetX ?? 0, offsetY: o.offsetY ?? 0,
    width: o.width, height: o.height, color: o.color, background: o.background, fontSize: o.fontSize ?? 18, bold: o.bold ?? false,
    cornerRadius: o.cornerRadius ?? 12, opacity: o.opacity ?? 1, visible: o.visible ?? true, layer: o.layer ?? 0,
  };
}

export const UILimits = { maximumElements: 300, maximumIDLength: 48, maximumTextLength: 500 } as const;

export const uiFraction = (e: UIElement) => (e.maximum > 0 ? Math.min(Math.max(e.value / e.maximum, 0), 1) : 0);

export const uiPresets: Record<string, { x: number; y: number }> = {
  top_left: { x: 0, y: 0 }, top: { x: 0.5, y: 0 }, top_right: { x: 1, y: 0 },
  left: { x: 0, y: 0.5 }, center: { x: 0.5, y: 0.5 }, right: { x: 1, y: 0.5 },
  bottom_left: { x: 0, y: 1 }, bottom: { x: 0.5, y: 1 }, bottom_right: { x: 1, y: 1 },
};

/** At a named place, `margin` points in from the edge. */
export function placeUI(e: UIElement, preset: { x: number; y: number }, margin = 16): void {
  e.x = preset.x;
  e.y = preset.y;
  e.pivotX = preset.x;
  e.pivotY = preset.y;
  e.offsetX = preset.x === 0 ? margin : preset.x === 1 ? -margin : 0;
  e.offsetY = preset.y === 0 ? margin : preset.y === 1 ? -margin : 0;
}

// MARK: - Camera and movement

export type CameraMode = 'third' | 'first' | 'top' | 'fixed';
export const cameraModes: CameraMode[] = ['third', 'first', 'top', 'fixed'];

export interface CameraSettings { mode: CameraMode; distance: number; fieldOfView: number; position?: Vec3; target?: Vec3 }
export const standardCamera = (): CameraSettings => ({ mode: 'third', distance: 6.5, fieldOfView: 65 });

export interface MovementScale { speed: number; jump: number; gravity: number; frozen: boolean }
export const normalMovement = (): MovementScale => ({ speed: 1, jump: 1, gravity: 1, frozen: false });

// MARK: - Panels

export interface Waypoint { position: Vec3; label: string; color?: ColorRGBA }
export const waypoint = (position: Vec3, label = '', color?: ColorRGBA): Waypoint => ({ position, label: prefix(label, 40), color });

export interface InventoryItem { name: string; icon: string; count: number }
export const inventoryItem = (name: string, icon = '', count = 1): InventoryItem => ({ name: prefix(name, 32), icon: prefix(icon, 40), count });
export const maximumItems = 24;

export interface DialogBox { id: string; speaker: string; text: string; choices: string[] }
export const dialogBox = (id: string, speaker: string, text: string, choices: string[]): DialogBox => ({
  id: prefix(id, 40), speaker: prefix(speaker, 32), text: prefix(text, 400), choices: choices.slice(0, 4).map((c) => prefix(c, 40)),
});

export interface ShopOffer { name: string; price: number; icon: string }
export const shopOffer = (name: string, price: number, icon = ''): ShopOffer => ({ name: prefix(name, 32), price: Math.max(0, price), icon: prefix(icon, 40) });

export interface ShopPanel { id: string; title: string; currency: string; balance: number; offers: ShopOffer[] }
export const shopPanel = (id: string, title: string, currency: string, balance: number, offers: ShopOffer[]): ShopPanel => ({
  id: prefix(id, 40), title: prefix(title, 40), currency: prefix(currency, 20), balance, offers: offers.slice(0, 24),
});
export const maximumOffers = 24;

export interface CountdownDisplay { label: string; seconds: number }
export const countdownDisplay = (label: string, seconds: number): CountdownDisplay => ({
  label: prefix(label, 40), seconds: Math.max(0, Math.min(86_400, Number.isFinite(seconds) ? seconds : 0)),
});

export interface LeaderboardRow { name: string; value: number }
export interface LeaderboardPanel { title: string; rows: LeaderboardRow[]; lowerIsBetter: boolean }

/** A world's best scores, kept by the host between games. */
export class Leaderboard {
  static readonly keptRows = 10;
  rows: LeaderboardRow[] = [];
  readonly title: string;
  constructor(title: string, readonly lowerIsBetter = false) {
    this.title = prefix(title, 40);
  }

  /** Keeps a player's best. True when the table changed. */
  submit(rawName: string, value: number): boolean {
    if (!Number.isFinite(value)) return false;
    const name = prefix(rawName, 24);
    const index = this.rows.findIndex((r) => r.name === name);
    if (index >= 0) {
      const old = this.rows[index].value;
      if (!(this.lowerIsBetter ? value < old : value > old)) return false;
      this.rows[index] = { name, value };
    } else {
      this.rows.push({ name, value });
    }
    const before = this.rows.map((r) => ({ ...r }));
    // Stable, as Swift's is: equal scores stay in the order they arrived.
    this.rows.sort((a, b) => (this.lowerIsBetter ? a.value - b.value : b.value - a.value));
    if (this.rows.length > Leaderboard.keptRows) this.rows.length = Leaderboard.keptRows;
    const changed = this.rows.length !== before.length || this.rows.some((r, i) => r.name !== before[i].name || r.value !== before[i].value);
    return changed || this.rows.some((r) => r.name === name && r.value === value);
  }

  rank(name: string): number | null {
    const i = this.rows.findIndex((r) => r.name === name);
    return i >= 0 ? i + 1 : null;
  }

  get panel(): LeaderboardPanel {
    return { title: this.title, rows: this.rows.map((r) => ({ ...r })), lowerIsBetter: this.lowerIsBetter };
  }

  toJSON() { return { lowerIsBetter: this.lowerIsBetter, rows: this.rows, title: this.title }; }

  static decode(v: unknown): Leaderboard | null {
    const o = v as Record<string, unknown> | null;
    if (!o || typeof o.title !== 'string') return null;
    const board = new Leaderboard(o.title, o.lowerIsBetter === true);
    if (Array.isArray(o.rows)) {
      for (const r of o.rows.slice(0, Leaderboard.keptRows)) {
        const row = r as Record<string, unknown>;
        if (typeof row?.name === 'string' && typeof row.value === 'number') board.rows.push({ name: row.name, value: row.value });
      }
    }
    return board;
  }
}

export interface ParticleBurst { kind: ParticleKind; position: Vec3; amount: number; seconds: number; color?: ColorRGBA }
export function particleBurst(kind: ParticleKind, position: Vec3, amount = 30, seconds = 0, color?: ColorRGBA): ParticleBurst {
  return {
    kind, position, amount: Math.max(1, Math.min(200, Math.trunc(amount))),
    seconds: Math.max(0, Math.min(30, Number.isFinite(seconds) ? seconds : 0)), color,
  };
}

export interface SoundPlay { name: string; volume: number; pitch: number }
export const soundPlay = (name: string, volume = 1, pitch = 1): SoundPlay => ({
  name, volume: Math.max(0, Math.min(1, Number.isFinite(volume) ? volume : 1)), pitch: Math.max(0.25, Math.min(4, Number.isFinite(pitch) ? pitch : 1)),
});

export interface MusicPlay { track: string; volume: number }
export const musicPlay = (track: string, volume = 1): MusicPlay => ({ track, volume: Math.max(0, Math.min(1, Number.isFinite(volume) ? volume : 1)) });

// MARK: - ScriptEffect

export type ScriptEffect =
  | { kind: 'ui'; element: UIElement }
  | { kind: 'removeUI'; id: string }
  | { kind: 'clearUI' }
  | { kind: 'camera'; camera: CameraSettings }
  | { kind: 'shake'; strength: number; seconds: number }
  | { kind: 'fade'; color?: ColorRGBA; seconds: number }
  | { kind: 'interface'; controls: boolean; defaultUI: boolean }
  | { kind: 'equip'; weapon?: WeaponSpec }
  | { kind: 'ammo'; current: number; magazine: number; reloading: boolean }
  | { kind: 'health'; current: number; maximum: number }
  | { kind: 'movement'; movement: MovementScale }
  | { kind: 'launch'; velocity: Vec3 }
  | { kind: 'face'; yawDegrees: number }
  | { kind: 'hitMarker'; killed: boolean }
  | { kind: 'damageFlash' }
  | { kind: 'tracer'; from: Vec3; to: Vec3 }
  | { kind: 'chat'; text: string }
  | { kind: 'say'; speaker: string; name: string; text: string }
  | { kind: 'store'; data: SaveData }
  | { kind: 'gesture'; speaker: string; wire: string }
  | { kind: 'waypoint'; waypoint?: Waypoint }
  | { kind: 'inventory'; items: InventoryItem[] }
  | { kind: 'dialog'; dialog?: DialogBox }
  | { kind: 'shop'; shop?: ShopPanel }
  | { kind: 'countdown'; countdown?: CountdownDisplay }
  | { kind: 'leaderboard'; board?: LeaderboardPanel }
  | { kind: 'particles'; burst: ParticleBurst }
  | { kind: 'sound'; sound: SoundPlay }
  | { kind: 'music'; music?: MusicPlay }
  | { kind: 'speak'; text: string }
  | { kind: 'vehicle'; riding: boolean };

type Json = Record<string, unknown>;
const o = (v: unknown): Json => (v && typeof v === 'object' && !Array.isArray(v) ? (v as Json) : {});
const num = (v: unknown, d = 0) => (typeof v === 'number' && Number.isFinite(v) ? v : d);
const str = (v: unknown, d = '') => (typeof v === 'string' ? v : d);
const bool = (v: unknown, d = false) => (typeof v === 'boolean' ? v : d);
const vec = (v: unknown): Vec3 => { const x = o(v); return v3(num(x.x), num(x.y), num(x.z)); };
const optVec = (v: unknown): Vec3 | undefined => (v && typeof v === 'object' ? vec(v) : undefined);
const color = (v: unknown): ColorRGBA | undefined => (v && typeof v === 'object' ? decodeColor(v, { r: 1, g: 1, b: 1, a: 1 }) : undefined);
const white: ColorRGBA = { r: 1, g: 1, b: 1, a: 1 };

/** Puts the optional keys in only when they are there, as Swift does. */
function withOptional(out: Json, extra: Json): Json {
  for (const [k, v] of Object.entries(extra)) if (v !== undefined) out[k] = v;
  return out;
}

export function encodeUI(e: UIElement): Json {
  return withOptional({
    bold: e.bold, cornerRadius: e.cornerRadius, fontSize: e.fontSize, id: e.id, kind: e.kind, layer: e.layer, maximum: e.maximum,
    offsetX: e.offsetX, offsetY: e.offsetY, opacity: e.opacity, pivotX: e.pivotX, pivotY: e.pivotY, text: e.text, value: e.value,
    visible: e.visible, x: e.x, y: e.y,
  }, {
    background: e.background && encodeColor(e.background), color: e.color && encodeColor(e.color), height: e.height,
    parent: e.parent, width: e.width,
  });
}

export function decodeUI(v: unknown): UIElement {
  const x = o(v);
  const kind = uiKinds.includes(x.kind as UIKind) ? (x.kind as UIKind) : 'text';
  return uiElement(str(x.id), kind, {
    parent: typeof x.parent === 'string' ? x.parent : undefined, text: str(x.text), value: num(x.value), maximum: num(x.maximum, 100),
    x: num(x.x, 0.5), y: num(x.y, 0.5), pivotX: num(x.pivotX, 0.5), pivotY: num(x.pivotY, 0.5), offsetX: num(x.offsetX), offsetY: num(x.offsetY),
    width: typeof x.width === 'number' ? x.width : undefined, height: typeof x.height === 'number' ? x.height : undefined,
    color: color(x.color), background: color(x.background), fontSize: num(x.fontSize, 18), bold: bool(x.bold),
    cornerRadius: num(x.cornerRadius, 12), opacity: num(x.opacity, 1), visible: bool(x.visible, true), layer: Math.trunc(num(x.layer)),
  });
}

export const encodeCamera = (c: CameraSettings): Json => withOptional(
  { distance: c.distance, fieldOfView: c.fieldOfView, mode: c.mode },
  { position: c.position && encodeVec(c.position), target: c.target && encodeVec(c.target) },
);

export function decodeCamera(v: unknown): CameraSettings {
  const x = o(v);
  return {
    mode: cameraModes.includes(x.mode as CameraMode) ? (x.mode as CameraMode) : 'third', distance: num(x.distance, 6.5),
    fieldOfView: num(x.fieldOfView, 65), position: optVec(x.position), target: optVec(x.target),
  };
}

const encodeMovement = (m: MovementScale): Json => ({ frozen: m.frozen, gravity: m.gravity, jump: m.jump, speed: m.speed });
const decodeMovement = (v: unknown): MovementScale => {
  const x = o(v);
  return { speed: num(x.speed, 1), jump: num(x.jump, 1), gravity: num(x.gravity, 1), frozen: bool(x.frozen) };
};

const encodeWaypoint = (w: Waypoint): Json => withOptional({ label: w.label, position: encodeVec(w.position) }, { color: w.color && encodeColor(w.color) });
const encodeShop = (s: ShopPanel): Json => ({
  balance: s.balance, currency: s.currency, id: s.id, offers: s.offers.map((f) => ({ icon: f.icon, name: f.name, price: f.price })), title: s.title,
});
const encodeBurst = (b: ParticleBurst): Json => withOptional(
  { amount: b.amount, kind: b.kind, position: encodeVec(b.position), seconds: b.seconds }, { color: b.color && encodeColor(b.color) },
);

/** `{"name": payload}`, with `{}` for a case with nothing in it. */
const one = (name: string, payload: Json = {}): Json => ({ [name]: payload });

export function encodeEffect(e: ScriptEffect): Json {
  switch (e.kind) {
    case 'ui': return one('ui', { _0: encodeUI(e.element) });
    case 'removeUI': return one('removeUI', { id: e.id });
    case 'clearUI': return one('clearUI');
    case 'camera': return one('camera', { _0: encodeCamera(e.camera) });
    case 'shake': return one('shake', { seconds: e.seconds, strength: e.strength });
    case 'fade': return one('fade', withOptional({ seconds: e.seconds }, { color: e.color && encodeColor(e.color) }));
    case 'interface': return one('interface', { controls: e.controls, defaultUI: e.defaultUI });
    case 'equip': return one('equip', e.weapon ? { _0: encodeWeapon(e.weapon) } : {});
    case 'ammo': return one('ammo', { current: e.current, magazine: e.magazine, reloading: e.reloading });
    case 'health': return one('health', { current: e.current, maximum: e.maximum });
    case 'movement': return one('movement', { _0: encodeMovement(e.movement) });
    case 'launch': return one('launch', { _0: encodeVec(e.velocity) });
    case 'face': return one('face', { yawDegrees: e.yawDegrees });
    case 'hitMarker': return one('hitMarker', { killed: e.killed });
    case 'damageFlash': return one('damageFlash');
    case 'tracer': return one('tracer', { from: encodeVec(e.from), to: encodeVec(e.to) });
    case 'chat': return one('chat', { _0: e.text });
    case 'say': return one('say', { name: e.name, speaker: e.speaker, text: e.text });
    case 'store': return one('store', { _0: e.data.values });
    case 'gesture': return one('gesture', { speaker: e.speaker, wire: e.wire });
    case 'waypoint': return one('waypoint', e.waypoint ? { _0: encodeWaypoint(e.waypoint) } : {});
    case 'inventory': return one('inventory', { _0: e.items.map((i) => ({ count: i.count, icon: i.icon, name: i.name })) });
    case 'dialog': return one('dialog', e.dialog ? { _0: { ...e.dialog, choices: [...e.dialog.choices] } } : {});
    case 'shop': return one('shop', e.shop ? { _0: encodeShop(e.shop) } : {});
    case 'countdown': return one('countdown', e.countdown ? { _0: { label: e.countdown.label, seconds: e.countdown.seconds } } : {});
    case 'leaderboard': return one('leaderboard', e.board
      ? { _0: { lowerIsBetter: e.board.lowerIsBetter, rows: e.board.rows.map((r) => ({ name: r.name, value: r.value })), title: e.board.title } } : {});
    case 'particles': return one('particles', { _0: encodeBurst(e.burst) });
    case 'sound': return one('sound', { _0: { name: e.sound.name, pitch: e.sound.pitch, volume: e.sound.volume } });
    case 'music': return one('music', e.music ? { _0: { track: e.music.track, volume: e.music.volume } } : {});
    case 'speak': return one('speak', { _0: e.text });
    case 'vehicle': return one('vehicle', { _0: e.riding });
  }
}

/** An effect from an iPad's JSON; null for one this version does not know. */
export function decodeEffect(v: unknown): ScriptEffect | null {
  const x = o(v);
  const keys = Object.keys(x);
  if (keys.length !== 1) return null;
  const name = keys[0];
  const p = o(x[name]);
  const has = (k: string) => p[k] !== undefined && p[k] !== null;
  switch (name) {
    case 'ui': return { kind: 'ui', element: decodeUI(p._0) };
    case 'removeUI': return { kind: 'removeUI', id: str(p.id) };
    case 'clearUI': return { kind: 'clearUI' };
    case 'camera': return { kind: 'camera', camera: decodeCamera(p._0) };
    case 'shake': return { kind: 'shake', strength: num(p.strength), seconds: num(p.seconds) };
    case 'fade': return { kind: 'fade', color: color(p.color), seconds: num(p.seconds) };
    case 'interface': return { kind: 'interface', controls: bool(p.controls, true), defaultUI: bool(p.defaultUI, true) };
    case 'equip': return { kind: 'equip', weapon: has('_0') ? decodeWeapon(p._0) : undefined };
    case 'ammo': return { kind: 'ammo', current: Math.trunc(num(p.current)), magazine: Math.trunc(num(p.magazine)), reloading: bool(p.reloading) };
    case 'health': return { kind: 'health', current: num(p.current), maximum: num(p.maximum) };
    case 'movement': return { kind: 'movement', movement: decodeMovement(p._0) };
    case 'launch': return { kind: 'launch', velocity: vec(p._0) };
    case 'face': return { kind: 'face', yawDegrees: num(p.yawDegrees) };
    case 'hitMarker': return { kind: 'hitMarker', killed: bool(p.killed) };
    case 'damageFlash': return { kind: 'damageFlash' };
    case 'tracer': return { kind: 'tracer', from: vec(p.from), to: vec(p.to) };
    case 'chat': return { kind: 'chat', text: str(p._0) };
    case 'say': return { kind: 'say', speaker: str(p.speaker), name: str(p.name), text: str(p.text) };
    case 'store': return { kind: 'store', data: SaveData.decode(p._0) };
    case 'gesture': return { kind: 'gesture', speaker: str(p.speaker), wire: str(p.wire) };
    case 'waypoint': {
      if (!has('_0')) return { kind: 'waypoint' };
      const w = o(p._0);
      return { kind: 'waypoint', waypoint: waypoint(vec(w.position), str(w.label), color(w.color)) };
    }
    case 'inventory': return {
      kind: 'inventory',
      items: (Array.isArray(p._0) ? p._0 : []).slice(0, maximumItems).map((i) => { const y = o(i); return inventoryItem(str(y.name), str(y.icon), Math.trunc(num(y.count, 1))); }),
    };
    case 'dialog': {
      if (!has('_0')) return { kind: 'dialog' };
      const d = o(p._0);
      return { kind: 'dialog', dialog: dialogBox(str(d.id), str(d.speaker), str(d.text), (Array.isArray(d.choices) ? d.choices : []).map((c) => str(c))) };
    }
    case 'shop': {
      if (!has('_0')) return { kind: 'shop' };
      const s = o(p._0);
      const offers = (Array.isArray(s.offers) ? s.offers : []).map((f) => { const y = o(f); return shopOffer(str(y.name), Math.trunc(num(y.price)), str(y.icon)); });
      return { kind: 'shop', shop: shopPanel(str(s.id), str(s.title), str(s.currency, 'coins'), Math.trunc(num(s.balance)), offers) };
    }
    case 'countdown': {
      if (!has('_0')) return { kind: 'countdown' };
      const c = o(p._0);
      return { kind: 'countdown', countdown: countdownDisplay(str(c.label), num(c.seconds)) };
    }
    case 'leaderboard': {
      if (!has('_0')) return { kind: 'leaderboard' };
      const b = o(p._0);
      const rows = (Array.isArray(b.rows) ? b.rows : []).map((r) => { const y = o(r); return { name: str(y.name), value: num(y.value) }; });
      return { kind: 'leaderboard', board: { title: str(b.title), rows, lowerIsBetter: bool(b.lowerIsBetter) } };
    }
    case 'particles': {
      const b = o(p._0);
      if (!particleKinds.includes(b.kind as ParticleKind)) return null;
      return { kind: 'particles', burst: particleBurst(b.kind as ParticleKind, vec(b.position), num(b.amount, 30), num(b.seconds), color(b.color)) };
    }
    case 'sound': { const s = o(p._0); return { kind: 'sound', sound: soundPlay(str(s.name), num(s.volume, 1), num(s.pitch, 1)) }; }
    case 'music': {
      if (!has('_0')) return { kind: 'music' };
      const m = o(p._0);
      return { kind: 'music', music: musicPlay(str(m.track), num(m.volume, 1)) };
    }
    case 'speak': return { kind: 'speak', text: str(p._0) };
    case 'vehicle': return { kind: 'vehicle', riding: bool(p._0) };
    default: return null;
  }
}

export { white as whiteColor };

// MARK: - The runtime's own buttons

/** Buttons the runtime puts up for its parts, caught before the script's `on button`. */
export type ReservedButton =
  | { kind: 'use'; item: string }
  | { kind: 'choose'; dialog: string; index: number }
  | { kind: 'buy'; shop: string; item: string }
  | { kind: 'closeDialog' }
  | { kind: 'closeShop' }
  | { kind: 'closeLeaderboard' }
  | { kind: 'exitVehicle' };

export function reservedButtonID(b: ReservedButton): string {
  switch (b.kind) {
    case 'use': return `__use:${b.item}`;
    case 'choose': return `__choice:${b.index}:${b.dialog}`;
    case 'buy': return `__buy:${b.shop}:${b.item}`;
    case 'closeDialog': return '__close:dialog';
    case 'closeShop': return '__close:shop';
    case 'closeLeaderboard': return '__close:board';
    case 'exitVehicle': return '__exit_vehicle';
  }
}

export function parseReservedButton(id: string): ReservedButton | null {
  if (!id.startsWith('__')) return null;
  const body = id.slice(2);
  if (body.startsWith('use:')) return { kind: 'use', item: body.slice(4) };
  if (body.startsWith('choice:')) {
    const rest = body.slice(7);
    const colon = rest.indexOf(':');
    if (colon < 0) return null;
    const head = rest.slice(0, colon);
    if (!/^[+-]?\d+$/.test(head)) return null;
    return { kind: 'choose', dialog: rest.slice(colon + 1), index: Number(head) };
  }
  if (body.startsWith('buy:')) {
    const rest = body.slice(4);
    const colon = rest.indexOf(':');
    if (colon < 0) return null;
    return { kind: 'buy', shop: rest.slice(0, colon), item: rest.slice(colon + 1) };
  }
  if (body === 'close:dialog') return { kind: 'closeDialog' };
  if (body === 'close:shop') return { kind: 'closeShop' };
  if (body === 'close:board') return { kind: 'closeLeaderboard' };
  if (body === 'exit_vehicle') return { kind: 'exitVehicle' };
  return null;
}
