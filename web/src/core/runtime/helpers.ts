// Finding people and blocks near a place, players by team, score or chance,
// and today's date — GameRuntimeHelpers.swift: the searches nearly every
// game wrote for itself with a loop over players().
import { distance, type Vec3 } from '../model/math';
import type { ScriptInterpreter } from '../script/interpreter';
import { ScriptList, ScriptMap, ScriptObject, displayText, type ScriptValue } from '../script/values';
import { point } from './api';
import { arg, number } from './args';
import type { GameRuntime } from './gameRuntime';
import type { PlayerState } from './state';

/** The date and time where the host is: `weekday` is 1 for Sunday to 7 for Saturday. */
export function today(rt: GameRuntime): ScriptValue {
  const date = new Date(rt.wallClock() * 1000);
  const parts = new Intl.DateTimeFormat('en-US', {
    timeZone: rt.timeZone, year: 'numeric', month: 'numeric', day: 'numeric', weekday: 'short',
    hour: 'numeric', minute: 'numeric', second: 'numeric', hourCycle: 'h23',
  }).formatToParts(date);
  const get = (type: string) => parts.find((p) => p.type === type)?.value ?? '0';
  const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  const map = new ScriptMap();
  map.set('year', Number(get('year')));
  map.set('month', Number(get('month')));
  map.set('day', Number(get('day')));
  map.set('weekday', weekdays.indexOf(get('weekday')) + 1);
  map.set('hour', Number(get('hour')) % 24);
  map.set('minute', Number(get('minute')));
  map.set('second', Number(get('second')));
  return map;
}

interface Found<T> { item: T; order: number; key: number }

/** Smallest key first, then the order made or joined, so every run agrees. */
const sorted = <T>(found: Found<T>[]) => found.sort((a, b) => (a.key !== b.key ? a.key - b.key : a.order - b.order)).map((f) => f.item);

interface SearchOrigin { point: Vec3; person?: string; block?: string }

function origin(rt: GameRuntime, args: ScriptValue[], line: number): SearchOrigin {
  const value = arg(args, 0);
  const p = point(rt, value, line);
  if (!(value instanceof ScriptObject)) return { point: p };
  return { point: p, person: rt.character(value)?.peer, block: rt.blockID(value) };
}

function people(rt: GameRuntime, from: SearchOrigin, radius: number): PlayerState[] {
  const found: Found<PlayerState>[] = [];
  for (const state of rt.orderedStates) {
    if (state.isNPC || !state.isAlive || state.peer === from.person) continue;
    const position = rt.position(state);
    if (!position) continue;
    const d = distance(position, from.point);
    if (d <= radius) found.push({ item: state, order: state.joinOrder, key: d });
  }
  return sorted(found);
}

function blocksNear(rt: GameRuntime, from: SearchOrigin, radius: number, tag: string | null): string[] {
  const index = rt.worldIndex;
  const found: Found<string>[] = [];
  const consider = (id: string, position: Vec3, order: number) => {
    if (id === from.block) return;
    const d = distance(position, from.point);
    if (d <= radius) found.push({ item: id, order, key: d });
  };
  if (tag !== null) {
    for (const id of rt.blockLookup.blocksTagged(tag)) {
      const entry = index.entry(id);
      consider(id, entry?.position ?? rt.live.worldPosition(id), entry?.order ?? 0);
    }
  } else {
    for (const entry of index.entries) consider(entry.id, entry.position, entry.order);
  }
  return sorted(found);
}

export function installHelperAPI(rt: GameRuntime, I: ScriptInterpreter): void {
  I.define('today', () => today(rt));
  I.define('nearest_player', (args, line) => {
    const from = origin(rt, args, line);
    const limit = args.length > 1 ? number(args[1], 'nearest_player', line) : Infinity;
    const first = people(rt, from, limit)[0];
    return first ? rt.object(first) : null;
  });
  I.define('players_near', (args, line) => {
    const from = origin(rt, args, line);
    const radius = number(arg(args, 1), 'players_near', line);
    return new ScriptList(people(rt, from, radius).map((s) => rt.object(s)));
  });
  I.define('random_player', () => {
    const list = rt.orderedStates.filter((s) => !s.isNPC);
    if (!list.length) return null;
    return rt.object(list[I.random.integer(0, list.length - 1)]);
  });
  I.define('team_players', (args) => {
    const team = displayText(arg(args, 0));
    return new ScriptList(rt.orderedStates.filter((s) => !s.isNPC && s.team === team).map((s) => rt.object(s)));
  });
  I.define('ranking', () => {
    const found: Found<PlayerState>[] = [];
    for (const state of rt.orderedStates) {
      if (state.isNPC) continue;
      found.push({ item: state, order: state.joinOrder, key: -(rt.snapshot(state)?.score ?? 0) });
    }
    return new ScriptList(sorted(found).map((s) => rt.object(s)));
  });
  I.define('alive_players', () => new ScriptList(rt.orderedStates.filter((s) => !s.isNPC && s.isAlive).map((s) => rt.object(s))));
  I.define('nearest_block', (args, line) => {
    const from = origin(rt, args, line);
    const tag = args.length > 1 && args[1] !== null ? displayText(args[1]) : null;
    const first = blocksNear(rt, from, Infinity, tag)[0];
    return first ? rt.blockObject(first) : null;
  });
  I.define('blocks_near', (args, line) => {
    const from = origin(rt, args, line);
    const radius = number(arg(args, 1), 'blocks_near', line);
    const tag = args.length > 2 && args[2] !== null ? displayText(args[2]) : null;
    const found = blocksNear(rt, from, radius, tag);
    I.checkSize(found.length, line);
    return new ScriptList(found.map((id) => rt.blockObject(id)));
  });
}
