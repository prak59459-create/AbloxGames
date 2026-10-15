// The ready-made parts a script can use without building them —
// GameRuntimeParts.swift: things to carry, conversations, shops, countdowns,
// leaderboards, particles, sounds and music, speech, the arrow that points
// the way, the weather and the time of day, and the no-script blocks that
// need the player: vehicles and pushable blocks.
import { L } from '../../i18n';
import { rides, type Ride } from '../model/avatar';
import { worldHour } from '../model/daycycle';
import {
  Leaderboard, countdownDisplay, dialogBox, inventoryItem, maximumItems, maximumOffers, musicPlay, particleBurst, shopOffer, shopPanel,
  soundPlay, waypoint, type InventoryItem, type MusicPlay, type ParticleBurst, type ReservedButton, type ScriptEffect,
} from '../model/effects';
import { add, boxCenter, expanded, intersects, penetrates, sub, v3, type BoundingBox } from '../model/math';
import { musicTracks } from '../model/player';
import { prefix, sameIgnoringCase, trimmed } from '../model/text';
import {
  particleKinds, type BlockAnimation, type BlockData, type BlockLabel, type EnvironmentSettings, type MusicTrack, type ParticleKind,
  type ScreenEffect, type SkyStyle, type Weather,
} from '../model/world';
import type { ScriptInterpreter } from '../script/interpreter';
import { ScriptList, ScriptMap, displayText, isTruthy, scriptInt, type ScriptValue } from '../script/values';
import { characterArgument, moveBlock, point } from './api';
import { arg, color, limitError, method, number, optionalNumber, optionsMap, runtimeError, shortText, soundName } from './args';
import type { Effect, GameRuntime } from './gameRuntime';
import type { PlayerState } from './state';

type Action = Effect['action'];
const script = (effect: ScriptEffect): Action => ({ type: 'script', effect });

const weathers: Weather[] = ['clear', 'rain', 'snow', 'fog', 'storm'];
const skyStyles: SkyStyle[] = ['gradient', 'clouds', 'sunset', 'stars', 'aurora', 'space'];
const screenEffects: ScreenEffect[] = ['none', 'bloom', 'vivid', 'warm', 'cool', 'noir', 'retro', 'dream'];
const animationKinds: BlockAnimation['kind'][] = ['spin', 'sway', 'dance', 'bounce', 'pulse', 'wobble'];

/** Swift's `String(clock.bitPattern, radix: 36)`: the clock's 64 bits, in base 36. */
function bitPatternBase36(x: number): string {
  const view = new DataView(new ArrayBuffer(8));
  view.setFloat64(0, x);
  return view.getBigUint64(0).toString(36);
}

// MARK: Globals

export function installPartsAPI(rt: GameRuntime, I: ScriptInterpreter): void {
  I.define('particles', (args, line) => { rt.pending.push(rt.broadcast(script({ kind: 'particles', burst: burstFrom(rt, args, line) }))); return null; });
  I.define('music', (args, line) => { rt.pending.push(rt.broadcast(script({ kind: 'music', music: musicFrom(args, line) }))); return null; });
  I.define('speak', (args) => { rt.pending.push(rt.broadcast(script({ kind: 'speak', text: shortText(arg(args, 0)) }))); return null; });
  I.define('countdown', (args, line) => { startCountdown(rt, args, null, line); return null; });
  I.define('leaderboard', (args, line) => submitScore(rt, args, line));
  I.define('show_leaderboard', (args, line) => {
    const name = displayText(arg(args, 0));
    const board = rt.leaderboards.get(name);
    if (!board) throw runtimeError(line, L('There is no leaderboard called “{}” yet.', name));
    const state = characterArgument(rt, args, 1);
    if (state) rt.send(state, script({ kind: 'leaderboard', board: board.panel }));
    else rt.pending.push(rt.broadcast(script({ kind: 'leaderboard', board: board.panel })));
    return null;
  });
  I.define('leaderboard_top', (args, line) => {
    const name = displayText(arg(args, 0));
    const count = scriptInt(optionalNumber(args, 1, 10, line));
    const rows = (rt.leaderboards.get(name)?.rows ?? []).slice(0, Math.max(0, count));
    return new ScriptList(rows.map((row) => ScriptMap.from({ name: row.name, value: row.value })));
  });
}

// MARK: A person's members

/** The parts' members of a person, or undefined when `name` is not one of them. */
export function partsMember(rt: GameRuntime, state: PlayerState, name: string): ScriptValue | undefined {
  switch (name) {
    case 'items': {
      const map = new ScriptMap();
      for (const item of state.items) map.set(item.name, item.count);
      return map;
    }
    case 'vehicle': return state.vehicle ?? null;
    case 'give_item': return method(name, (a, l) => {
      const item = shortName(arg(a, 0));
      if (!item) throw runtimeError(l, L('“{}” needs a name.', 'give_item'));
      const count = scriptInt(optionalNumber(a, 1, 1, l));
      const icon = a.length > 2 ? prefix(displayText(a[2]), 40) : '';
      changeItems(rt, state, (items) => {
        const i = items.findIndex((x) => x.name === item);
        if (i >= 0) {
          items[i] = { ...items[i], count: Math.min(999_999, items[i].count + Math.max(1, count)), icon: icon || items[i].icon };
        } else if (items.length < maximumItems) {
          items.push(inventoryItem(item, icon, Math.min(999_999, Math.max(1, count))));
        }
      });
      return null;
    });
    case 'take_item': return method(name, (a, l) => {
      const item = shortName(arg(a, 0));
      const count = scriptInt(optionalNumber(a, 1, 1, l));
      const have = state.items.find((x) => x.name === item);
      if (!have || have.count < count) return false;
      changeItems(rt, state, (items) => {
        const i = items.findIndex((x) => x.name === item);
        if (i < 0) return;
        items[i] = { ...items[i], count: items[i].count - count };
        if (items[i].count <= 0) items.splice(i, 1);
      });
      return true;
    });
    case 'has_item': return method(name, (a, l) => {
      const item = shortName(arg(a, 0));
      const count = scriptInt(optionalNumber(a, 1, 1, l));
      return (state.items.find((x) => x.name === item)?.count ?? 0) >= count;
    });
    case 'clear_items': return method(name, () => { changeItems(rt, state, (items) => { items.length = 0; }); return null; });
    case 'dialog': return method(name, (a, l) => {
      // p.dialog("Shopkeeper", "Want a sword?", ["Yes", "No"])
      const speaker = shortText(arg(a, 0));
      const text = a.length > 1 ? prefix(displayText(a[1]), 400) : '';
      let choices: string[] = [];
      if (a.length > 2) {
        if (!(a[2] instanceof ScriptList)) throw runtimeError(l, L('The answers go in a list, like ["Yes", "No"].'));
        choices = a[2].items.map((x) => displayText(x));
      }
      const box = dialogBox(bitPatternBase36(rt.clock), speaker, text, choices.length ? choices : [L('OK')]);
      state.dialog = box;
      rt.send(state, script({ kind: 'dialog', dialog: box }));
      return null;
    });
    case 'close_dialog': return method(name, () => {
      state.dialog = null;
      rt.send(state, script({ kind: 'dialog' }));
      return null;
    });
    case 'shop': return method(name, (a, l) => { openShop(rt, a, state, l); return null; });
    case 'close_shop': return method(name, () => {
      state.shop = null;
      rt.send(state, script({ kind: 'shop' }));
      return null;
    });
    case 'waypoint': return method(name, (a, l) => {
      // p.waypoint(block("Exit"), "The exit"), p.waypoint(nil)
      const target = arg(a, 0);
      if (target === null) {
        rt.send(state, script({ kind: 'waypoint' }));
        return null;
      }
      const label = a.length > 1 ? shortText(a[1]) : '';
      const tint = a.length > 2 ? color(a[2], l) : undefined;
      rt.send(state, script({ kind: 'waypoint', waypoint: waypoint(point(rt, target, l), label, tint) }));
      return null;
    });
    case 'music': return method(name, (a, l) => { rt.send(state, script({ kind: 'music', music: musicFrom(a, l) })); return null; });
    case 'speak': return method(name, (a) => { rt.send(state, script({ kind: 'speak', text: shortText(arg(a, 0)) })); return null; });
    case 'countdown': return method(name, (a, l) => { startCountdown(rt, a, state, l); return null; });
    case 'show_leaderboard': return method(name, (a, l) => {
      const board = displayText(arg(a, 0));
      const found = rt.leaderboards.get(board);
      if (!found) throw runtimeError(l, L('There is no leaderboard called “{}” yet.', board));
      rt.send(state, script({ kind: 'leaderboard', board: found.panel }));
      return null;
    });
    case 'particles': return method(name, (a, l) => {
      // Around this person, seen by everyone.
      const burst = burstFrom(rt, [arg(a, 0), rt.object(state), ...a.slice(1)], l);
      burst.position.y += 1;
      rt.pending.push(rt.broadcast(script({ kind: 'particles', burst })));
      return null;
    });
    default: return undefined;
  }
}

const shortName = (value: ScriptValue) => prefix(trimmed(displayText(value)), 32);

function changeItems(rt: GameRuntime, state: PlayerState, change: (items: InventoryItem[]) => void): void {
  const items = state.items.map((x) => ({ ...x }));
  change(items);
  if (items.length === state.items.length && items.every((x, i) => x.name === state.items[i].name && x.count === state.items[i].count && x.icon === state.items[i].icon)) return;
  state.items = items;
  rt.send(state, script({ kind: 'inventory', items: items.map((x) => ({ ...x })) }));
}

function openShop(rt: GameRuntime, args: ScriptValue[], state: PlayerState, line: number): void {
  const title = shortText(arg(args, 0));
  const list = args[1];
  if (!(list instanceof ScriptList)) throw runtimeError(line, L('A shop needs a list of things, like [{name: "Sword", price: 50}].'));
  const offers = [];
  for (const entry of list.items.slice(0, maximumOffers)) {
    const map = optionsMap(entry, line);
    const name = displayText(map.get('name') ?? null);
    if (!name) continue;
    const price = scriptInt(optionalNumber([map.get('price') ?? null], 0, 0, line));
    const icon = map.get('icon') ?? null;
    offers.push(shopOffer(name, price, icon === null ? '' : displayText(icon)));
  }
  const options = optionsMap(arg(args, 2), line);
  const currencyOption = options.get('currency');
  const currency = currencyOption !== undefined ? displayText(currencyOption) : 'coins';
  state.shopCurrency = currency;
  const panel = shopPanel(bitPatternBase36(rt.clock), title, currency, balance(rt, state, currency), offers);
  state.shop = panel;
  rt.send(state, script({ kind: 'shop', shop: panel }));
}

/** A player's money for a shop: the number the script keeps on them, or their score. */
function balance(rt: GameRuntime, state: PlayerState, currency: string): number {
  if (currency === 'score') return rt.snapshot(state)?.score ?? 0;
  const value = state.custom.get(currency);
  return typeof value === 'number' && Number.isFinite(value) ? scriptInt(value) : 0;
}

function musicFrom(args: ScriptValue[], line: number): MusicPlay | undefined {
  const first = arg(args, 0);
  if (first === null) return undefined;
  // Quiet, rather than back to the world's own music.
  if (['none', 'off', 'stop'].includes(displayText(first).toLowerCase())) return musicPlay('none', 0);
  const track = displayText(first).toLowerCase();
  if (!(musicTracks as readonly string[]).includes(track)) {
    throw runtimeError(line, L('There is no music called “{}”. The music is: {}.', displayText(first), musicTracks.join(', ')));
  }
  const options = optionsMap(arg(args, 1), line);
  return musicPlay(track, optionalNumber([options.get('volume') ?? null], 0, 1, line));
}

/** `particles("fire", where, {seconds: 2, amount: 40, color: "red"})`. */
function burstFrom(rt: GameRuntime, args: ScriptValue[], line: number): ParticleBurst {
  const name = displayText(arg(args, 0)).toLowerCase();
  if (!(particleKinds as string[]).includes(name)) {
    throw runtimeError(line, L('There are no particles called “{}”. Try: {}.', name, particleKinds.join(', ')));
  }
  const position = point(rt, arg(args, 1), line);
  const options = optionsMap(arg(args, 2), line);
  const seconds = optionalNumber([options.get('seconds') ?? null], 0, 0, line);
  const amount = optionalNumber([options.get('amount') ?? null], 0, 30, line);
  const tint = options.get('color');
  return particleBurst(name as ParticleKind, position, Math.trunc(amount), seconds, tint !== undefined ? color(tint, line) : undefined);
}

/** `sound("coin", {volume: 0.5, pitch: 1.5})`, or one from the library. */
export function soundEffect(args: ScriptValue[], line: number): Action {
  const name = soundName(arg(args, 0), line);
  if (args.length < 2 || args[1] === null) return { type: 'playSound', name };
  const options = optionsMap(args[1], line);
  const volume = optionalNumber([options.get('volume') ?? null], 0, 1, line);
  const pitch = optionalNumber([options.get('pitch') ?? null], 0, 1, line);
  return script({ kind: 'sound', sound: soundPlay(name, Math.fround(volume), Math.fround(pitch)) });
}

// MARK: Countdowns

function startCountdown(rt: GameRuntime, args: ScriptValue[], state: PlayerState | null, line: number): void {
  const first = arg(args, 0);
  const label = args.length > 1 ? shortText(args[1]) : '';
  const peer = state?.peer;
  const show = (effect: ScriptEffect) => {
    if (state) rt.send(state, script(effect));
    else rt.pending.push(rt.broadcast(script(effect)));
  };
  if (first === null) {
    rt.countdowns = rt.countdowns.filter((c) => !(c.peer === peer && (!label || c.label === label)));
    show({ kind: 'countdown' });
    return;
  }
  const seconds = Math.max(0, Math.min(86_400, number(first, 'countdown', line)));
  rt.countdowns = rt.countdowns.filter((c) => !(c.peer === peer && c.label === label));
  rt.countdowns.push({ label, due: rt.clock + seconds, peer });
  show({ kind: 'countdown', countdown: countdownDisplay(label, seconds) });
}

export function advanceCountdowns(rt: GameRuntime): void {
  if (!rt.countdowns.length) return;
  const due = rt.countdowns.filter((c) => c.due <= rt.clock);
  if (!due.length) return;
  rt.countdowns = rt.countdowns.filter((c) => !(c.due <= rt.clock));
  for (const item of due) {
    const person = item.peer !== undefined ? rt.states.get(item.peer) : undefined;
    if (person) rt.send(person, script({ kind: 'countdown' }));
    else rt.pending.push(rt.broadcast(script({ kind: 'countdown' })));
    rt.run('countdown', [item.label, person ? rt.object(person) : null]);
  }
}

// MARK: Leaderboards

/** `leaderboard("fastest", p, time, {lower: true})`: their place, or nil when off the table. */
function submitScore(rt: GameRuntime, args: ScriptValue[], line: number): ScriptValue {
  const name = prefix(displayText(arg(args, 0)), 40);
  const state = characterArgument(rt, args, 1);
  if (!name || !state || state.isNPC) throw runtimeError(line, L('“{}” needs a name, a player and a number.', 'leaderboard'));
  const value = number(arg(args, 2), 'leaderboard', line);
  const options = optionsMap(arg(args, 3), line);
  const existing = rt.leaderboards.get(name);
  if (!existing && rt.leaderboards.size >= 20) throw limitError(line, L('A world can keep at most {} leaderboards.', 20));
  const lower = options.get('lower');
  const board = existing ?? new Leaderboard(name, lower !== undefined && isTruthy(lower));
  if (board.submit(state.name, value)) {
    rt.leaderboards.set(name, board);
    rt.leaderboardsChanged = true;
  }
  return board.rank(state.name);
}

// MARK: The runtime's own buttons

export function handleReserved(rt: GameRuntime, button: ReservedButton, state: PlayerState): void {
  switch (button.kind) {
    case 'use':
      if (!state.items.some((x) => x.name === button.item)) return;
      rt.run('use', [rt.object(state), button.item]);
      return;
    case 'choose': {
      const dialog = state.dialog;
      if (!dialog || dialog.id !== button.dialog || button.index < 0 || button.index >= dialog.choices.length) return;
      state.dialog = null;
      rt.send(state, script({ kind: 'dialog' }));
      rt.run('choice', [rt.object(state), dialog.choices[button.index], button.index + 1]);
      return;
    }
    case 'buy': {
      const shop = state.shop;
      const offer = shop && shop.id === button.shop ? shop.offers.find((o) => o.name === button.item) : undefined;
      if (!shop || !offer) return;
      const money = balance(rt, state, state.shopCurrency);
      if (money < offer.price) {
        rt.send(state, { type: 'announce', message: L('Not enough {}.', L(state.shopCurrency)), duration: 2 });
        rt.send(state, { type: 'playSound', name: 'error' });
        return;
      }
      if (state.shopCurrency === 'score') rt.setScore(state, money - offer.price);
      else state.custom.set(state.shopCurrency, money - offer.price);
      rt.send(state, { type: 'playSound', name: 'coin' });
      rt.run('buy', [rt.object(state), offer.name, offer.price]);
      // The window stays open with the new balance, unless the handler closed it.
      const open = state.shop;
      if (open && open.id === button.shop) {
        const updated = { ...open, balance: balance(rt, state, state.shopCurrency) };
        state.shop = updated;
        rt.send(state, script({ kind: 'shop', shop: updated }));
      }
      return;
    }
    case 'closeDialog':
      if (!state.dialog) return;
      state.dialog = null;
      rt.send(state, script({ kind: 'dialog' }));
      return;
    case 'closeShop':
      if (!state.shop) return;
      state.shop = null;
      rt.send(state, script({ kind: 'shop' }));
      return;
    case 'closeLeaderboard':
      rt.send(state, script({ kind: 'leaderboard' }));
      return;
    case 'exitVehicle':
      leaveVehicle(rt, state);
      return;
  }
}

// MARK: Vehicles and pushing

export function partsTouched(rt: GameRuntime, state: PlayerState, blockID: string): void {
  const block = rt.live.block(blockID);
  if (!state.isAlive || state.isNPC || !block) return;
  if (block.behavior === 'vehicle') enterVehicle(rt, state, block);
  else if (block.behavior === 'pushable') push(rt, blockID, state);
}

function enterVehicle(rt: GameRuntime, state: PlayerState, block: BlockData): void {
  const ride = block.gimmick.vehicle.toLowerCase();
  if (state.vehicle !== null || !(rides as readonly string[]).includes(ride) || ride === 'none') return;
  state.vehicle = ride as Ride;
  state.movementBeforeVehicle = { ...state.movement };
  const movement = { ...state.movement, speed: Math.fround(state.movement.speed * Math.max(0.5, Math.min(4, block.gimmick.vehicleSpeed))) };
  state.movement = movement;
  rt.send(state, script({ kind: 'movement', movement: { ...movement } }));
  rt.updateProfile(state, (p) => { p.ride = ride as Ride; p.rideColor = { ...block.color }; });
  rt.send(state, script({ kind: 'vehicle', riding: true }));
  rt.send(state, { type: 'playSound', name: 'door' });
}

export function leaveVehicle(rt: GameRuntime, state: PlayerState): void {
  if (state.vehicle === null) return;
  state.vehicle = null;
  const movement = state.movementBeforeVehicle ?? { speed: 1, jump: 1, gravity: 1, frozen: false };
  state.movementBeforeVehicle = null;
  state.movement = movement;
  rt.send(state, script({ kind: 'movement', movement: { ...movement } }));
  rt.updateProfile(state, (p) => { p.ride = 'none'; });
  rt.send(state, script({ kind: 'vehicle', riding: false }));
}

/** One step along the side it was walked into, unless something solid is in the way. */
function push(rt: GameRuntime, blockID: string, state: PlayerState): void {
  const last = rt.lastPush.get(blockID);
  if (last !== undefined && rt.clock - last < 0.35) return;
  const feet = rt.position(state);
  const bounds = rt.worldIndex.entry(blockID)?.bounds;
  if (!feet || !bounds) return;
  const away = sub(boxCenter(bounds), feet);
  away.y = 0;
  if (!(Math.hypot(away.x, away.y, away.z) > 0.05)) return;
  const step = Math.abs(away.x) > Math.abs(away.z) ? v3(away.x > 0 ? 1 : -1, 0, 0) : v3(0, 0, away.z > 0 ? 1 : -1);
  const moved = expanded({ min: add(bounds.min, step), max: add(bounds.max, step) }, -0.05);
  const blocked = rt.worldIndex.near(moved).some((e) => e.id !== blockID && e.isVisible && e.hasCollision && penetrates(moved, e.bounds));
  if (blocked) return;
  rt.lastPush.set(blockID, rt.clock);
  const drop = dropBelow(rt, moved, blockID);
  moveBlock(rt, blockID, add(step, v3(0, -drop, 0)), 0.3 + drop * 0.06);
}

/** How far a box would fall onto whatever is under it. */
function dropBelow(rt: GameRuntime, box: BoundingBox, id: string): number {
  const floor = rt.world.environment.killPlaneHeight;
  const column: BoundingBox = { min: v3(box.min.x, Math.max(floor, box.min.y - 60), box.min.z), max: v3(box.max.x, box.min.y, box.max.z) };
  let highest = floor - 10;
  for (const e of rt.worldIndex.near(column)) {
    if (e.id === id || !e.isVisible || !e.hasCollision) continue;
    const top = e.bounds.max.y;
    if (top <= box.min.y + 0.1 && top > highest && intersects(column, e.bounds)) highest = top;
  }
  return Math.max(0, Math.min(60, box.min.y + 0.05 - highest));
}

// MARK: The world: weather, time, sky

export function partsWorldMember(rt: GameRuntime, name: string): ScriptValue | undefined {
  const e = rt.world.environment;
  switch (name) {
    case 'weather': return e.weather;
    case 'time': {
      const hour = worldHour(e, rt.wallClock());
      return hour === null ? null : Math.round(hour * 100) / 100;
    }
    case 'day_length': return e.dayLengthMinutes;
    case 'sky_style': return e.skyStyle;
    case 'effect': return e.screenEffect;
    case 'shadows': return e.shadows;
    case 'music': return e.music ?? null;
    default: return undefined;
  }
}

/** True when `name` was one of the parts' world settings. */
export function setPartsWorldMember(rt: GameRuntime, name: string, value: ScriptValue, e: EnvironmentSettings, line: number): boolean {
  const choice = <T extends string>(list: readonly T[]): T => {
    const text = displayText(value).toLowerCase();
    if (!(list as readonly string[]).includes(text)) throw runtimeError(line, L('“{}” is one of: {}.', name, list.join(', ')));
    return text as T;
  };
  const wrap = (h: number) => { if (!Number.isFinite(h)) return 12; const w = h % 24; return w < 0 ? w + 24 : w; };
  switch (name) {
    case 'weather': e.weather = choice(weathers); return true;
    case 'time':
      if (value === null) e.timeOfDay = undefined;
      else {
        // Counted from now.
        e.timeOfDay = Math.fround(wrap(Math.fround(number(value, name, line))));
        e.dayEpoch = rt.wallClock();
      }
      return true;
    case 'day_length': {
      // The hour it is now stays; only the speed changes.
      const now = worldHour(e, rt.wallClock()) ?? 12;
      e.dayLengthMinutes = Math.fround(Math.max(0, Math.min(1440, number(value, name, line))));
      e.timeOfDay = now;
      e.dayEpoch = rt.wallClock();
      return true;
    }
    case 'sky_style': e.skyStyle = choice(skyStyles); return true;
    case 'effect': e.screenEffect = choice(screenEffects); return true;
    case 'shadows': e.shadows = isTruthy(value); return true;
    case 'music': e.music = value === null ? undefined : choice(musicTracks as readonly MusicTrack[]); return true;
    default: return false;
  }
}

// MARK: Blocks

export function partsBlockMember(rt: GameRuntime, block: BlockData, name: string): ScriptValue | undefined {
  switch (name) {
    case 'particles': return block.particles ?? null;
    case 'image': {
      const image = block.imageID ? rt.world.images.find((i) => i.id === block.imageID) : undefined;
      return image ? image.name : null;
    }
    case 'label': return block.label ? block.label.lines.map((l) => l.text).join('\n') : null;
    case 'label_height': return block.label ? block.label.height : null;
    case 'label_size': return block.label ? block.label.size : null;
    case 'label_range': return block.label ? block.label.range : null;
    case 'animation': return block.animation ? block.animation.kind : null;
    case 'animation_speed': return block.animation ? block.animation.speed : null;
    case 'parent': return block.parentID && rt.live.block(block.parentID) ? rt.blockObject(block.parentID) : null;
    default: return undefined;
  }
}

const clampLabel = (v: number, lo: number, hi: number) => (Number.isFinite(v) ? Math.min(Math.max(v, lo), hi) : lo);
const makeLabel = (lines: BlockLabel['lines'], height = 0.6, size = 1, range = 60): BlockLabel => ({
  lines: lines.slice(0, 4), height: Math.fround(clampLabel(height, 0, 40)), size: Math.fround(clampLabel(size, 0.3, 4)),
  range: Math.fround(clampLabel(range, 4, 250)),
});
const labelLine = (text: string, tint = { r: 1, g: 1, b: 1, a: 1 }) => ({ text: prefix(text, 60), color: tint });

/** True when `name` was one of the parts' block settings. */
export function setPartsBlockMember(rt: GameRuntime, name: string, value: ScriptValue, block: BlockData, line: number): boolean {
  switch (name) {
    case 'particles': {
      if (value === null) { block.particles = undefined; return true; }
      const kind = displayText(value).toLowerCase();
      if (!(particleKinds as string[]).includes(kind)) {
        throw runtimeError(line, L('There are no particles called “{}”. Try: {}.', displayText(value), particleKinds.join(', ')));
      }
      block.particles = kind as ParticleKind;
      return true;
    }
    case 'image': {
      if (value === null) { block.imageID = undefined; return true; }
      const found = rt.world.images.find((i) => sameIgnoringCase(i.name, displayText(value)));
      if (!found) throw runtimeError(line, L('This world has no picture called “{}”.', displayText(value)));
      block.imageID = found.id;
      return true;
    }
    case 'label': setLabel(value, block, line); return true;
    case 'animation': {
      if (value === null) { block.animation = undefined; return true; }
      const kind = displayText(value).toLowerCase();
      if (!(animationKinds as string[]).includes(kind)) throw runtimeError(line, L('“animation” is one of: {}.', animationKinds.join(', ')));
      block.animation = { kind: kind as BlockAnimation['kind'], speed: block.animation?.speed ?? 1 };
      return true;
    }
    case 'animation_speed': {
      const speed = Math.fround(number(value, name, line));
      block.animation = { kind: block.animation?.kind ?? 'sway', speed };
      return true;
    }
    case 'parent':
      throw runtimeError(line, L('A block’s parent is chosen when it is made: create_block({parent: …}).'));
    case 'label_height': case 'label_size': case 'label_range': {
      const n = Math.fround(number(value, name, line));
      const old = block.label ?? makeLabel([]);
      block.label = name === 'label_height' ? makeLabel(old.lines, n, old.size, old.range)
        : name === 'label_size' ? makeLabel(old.lines, old.height, n, old.range)
          : makeLabel(old.lines, old.height, old.size, n);
      return true;
    }
    default: return false;
  }
}

/** `b.label = "Hello"` (lines split at "\n"), a list of lines, or nil to take the words away. */
function setLabel(value: ScriptValue, block: BlockData, line: number): void {
  const old = block.label ?? makeLabel([]);
  let lines: BlockLabel['lines'] = [];
  if (value === null) {
    block.label = undefined;
    return;
  }
  if (value instanceof ScriptList) {
    for (const item of value.items.slice(0, 4)) {
      if (item instanceof ScriptMap) {
        const options = optionsMap(item, line);
        const tint = options.get('color');
        lines.push(labelLine(displayText(options.get('text') ?? '') , tint !== undefined ? color(tint, line) : undefined));
      } else {
        lines.push(labelLine(displayText(item)));
      }
    }
  } else {
    lines = displayText(value).split('\n').map((t) => labelLine(t));
  }
  const label = makeLabel(lines, old.height, old.size, old.range);
  const empty = label.lines.every((l) => l.text.replace(/^[\p{Zs}\t]+|[\p{Zs}\t]+$/gu, '') === '');
  block.label = empty && block.label === undefined ? undefined : label;
}

