// The web runtime against the iPad's own: the same catalogue games played by
// the same two robot players, step by step, compared with what AbloxCore
// recorded (the Swift Oracle, kept outside this repository). Runs only when
// ORACLE_TRACES points at those recordings.
import './helpers';
import { existsSync, readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { describe, expect, it } from 'vitest';
import { GameRuntime, type Effect } from '../src/core/runtime/gameRuntime';
import { decodeAction, encodeAction } from '../src/core/model/rules';
import { decodeDelta, encodeDelta } from '../src/core/model/liveWorld';
import { decodeTransform, encodeTransform, playerSnapshot } from '../src/core/model/player';
import { ScriptedPlayerState } from '../src/core/model/scriptedState';
import { SaveData } from '../src/core/model/save';
import { add, sub, v3 } from '../src/core/model/math';
import { decodeWorld, mergeScripts, needsTouchDetection } from '../src/core/model/world';
import type { ScriptError } from '../src/core/script/lexer';

const traces = process.env.ORACLE_TRACES;
const root = join(import.meta.dirname, '..', '..');
const alice = 'AAAAAAAA-0000-0000-0000-000000000001';
const bob = 'BBBBBBBB-0000-0000-0000-000000000002';

interface Step { t: number; effects: { target?: string; action: unknown }[]; deltas: unknown[]; errors: string[]; output: string[]; roster: string[]; npcs: unknown[]; newBlocks: string[] }
interface Trace { game: string; compileErrors: string[]; steps: Step[] }

const describeError = (e: ScriptError) => `${e.file ?? ''}|${e.line}|${e.kind}|${e.message}`;

/** The web runtime, driven exactly as the Oracle drives AbloxCore. */
function play(listing: { id: string; world: string; scripts?: string[] }): Trace {
  const world = decodeWorld(JSON.parse(readFileSync(join(root, listing.world), 'utf8')));
  const downloaded = (listing.scripts ?? []).map((path) => ({ name: path.split('/').pop()!, source: readFileSync(join(root, path), 'utf8') }));
  world.scripts = mergeScripts(downloaded, world.scripts);
  const game = new GameRuntime(world, 0, 7n);
  game.wallClock = () => 1_760_000_000;
  game.timeZone = 'UTC';
  const originalIDs = new Set(world.blocks.map((b) => b.id));
  const targets = world.blocks.filter((b) => b.isVisible && (needsTouchDetection(b.behavior) || b.tags.length > 0)).map((b) => b.id);
  const trace: Trace = { game: listing.id, compileErrors: [], steps: [] };
  const screens = new Map([[alice, new ScriptedPlayerState()], [bob, new ScriptedPlayerState()]]);
  const pressed = new Set<string>();
  const next = new Map([[alice, 0], [bob, 1]]);

  const record = (t: number, effects: Effect[]) => {
    for (const e of effects) {
      if (e.action.type !== 'script') continue;
      for (const peer of [alice, bob]) if (e.target === undefined || e.target === peer) screens.get(peer)!.apply(e.action.effect);
    }
    trace.steps.push({
      t,
      effects: effects.map((e) => ({ target: e.target, action: encodeAction(e.action) })),
      deltas: game.drainWorldDeltas().map(encodeDelta),
      errors: game.drainErrors().map(describeError),
      output: game.drainOutput(),
      roster: game.roster.map((p) => `${p.peerID}|${p.profile.displayName}|${p.isNPC}|${p.isHidden}|${p.team}|${p.score}`),
      npcs: game.drainNPCTransforms().map(encodeTransform),
      newBlocks: game.world.blocks.map((b) => b.id).filter((id) => !originalIDs.has(id)),
    });
  };

  const person = (peer: string, name: string) => { const s = playerSnapshot(peer); s.profile.displayName = name; return s; };
  let effects: Effect[] = [];
  effects.push(...game.addPlayer(person(alice, 'Alice')));
  effects.push(...game.addPlayer(person(bob, 'Bob')));
  effects.push(...game.handle({ kind: 'roundStarted' }));
  trace.compileErrors = game.compileErrors.map(describeError);
  record(0, effects);

  let t = 0;
  const steps = Number(process.env.ORACLE_STEPS ?? 150);
  for (let step = 1; step <= steps; step++) {
    t += 0.1;
    effects = game.advance(t);
    if (step === 1) {
      effects.push(...game.handleInput({ kind: 'saved', data: new SaveData() }, alice, t));
      effects.push(...game.handleInput({ kind: 'saved', data: new SaveData({ coins: 5, level: 2 }) }, bob, t));
    }
    if (step === 20) effects.push(...game.handleChat(bob, 'hello'));
    if (step === 30) effects.push(...game.handleInput({ kind: 'gesture', wire: 'wave' }, alice, t));
    if (step % 5 === 0) {
      for (const peer of [alice, bob]) {
        if (targets.length) {
          const i = next.get(peer)! % targets.length;
          next.set(peer, i + 1);
          const id = targets[i];
          if (game.live.block(id)) {
            const p = add(game.live.worldPosition(id), v3(0, 0.5, 0));
            game.updateTransform({ peerID: peer, position: p, yawDegrees: 0, velocity: v3(), isGrounded: true });
            effects.push(...game.handle({ kind: 'touched', peer, blockID: id }));
          }
        }
        const buttons = screens.get(peer)!.ui.filter((e) => e.kind === 'button' && e.visible);
        const button = buttons.find((b) => !pressed.has(`${peer}|${b.id}`));
        if (button) {
          pressed.add(`${peer}|${button.id}`);
          effects.push(...game.handleInput({ kind: 'button', id: button.id }, peer, t));
        }
      }
    }
    const from = game.players.get(alice)?.position, to = game.players.get(bob)?.position;
    if (step % 10 === 0 && screens.get(alice)!.weapon && from && to) {
      const origin = add(from, v3(0, 1.6, 0));
      effects.push(...game.handleInput({ kind: 'fire', origin, direction: sub(add(to, v3(0, 1, 0)), origin) }, alice, t));
    }
    record(t, effects);
  }
  return trace;
}

// MARK: Comparing

const uuid = /[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}/g;

/** Ids made during the game are random on both sides: named by when they first turn up. */
function namer(trace: Trace, known: Set<string>): (s: string) => string {
  const names = new Map<string, string>();
  const see = (text: string) => {
    for (const id of text.match(uuid) ?? []) if (!known.has(id) && !names.has(id)) names.set(id, `#${names.size}`);
  };
  for (const step of trace.steps) {
    for (const r of step.roster) see(r);
    for (const b of step.newBlocks) see(b);
    see(JSON.stringify(step.effects));
    see(JSON.stringify(step.deltas));
    see(JSON.stringify(step.npcs));
  }
  return (s) => s.replace(uuid, (id) => names.get(id) ?? id);
}

/** Into the web's own shapes, so the two encoders' styles do not matter. */
function canonical(step: Step, rename: (s: string) => string) {
  const effects = step.effects.map((e) => JSON.parse(rename(JSON.stringify({ target: e.target ?? null, action: decodeAction(e.action) }))));
  const deltas = step.deltas.map((d) => JSON.parse(rename(JSON.stringify(decodeDelta(d)))));
  const npcs = step.npcs.map((n) => JSON.parse(rename(JSON.stringify(decodeTransform(n)))));
  return { errors: step.errors, output: step.output, roster: step.roster.map(rename), effects, deltas, npcs };
}

/** Swift keeps positions in 32-bit floats; the web in 64-bit. Close is equal. */
function close(a: unknown, b: unknown, path = ''): string | null {
  // A rotation and its negation are the same turn. Which one comes out at
  // exactly 180° rests on the last bit of the maths library's sin and atan2,
  // which differs between machines (an iPad's is not this Linux one).
  if (path.endsWith('.rotation') && isQuat(a) && isQuat(b)) {
    const negated = { x: -b.x, y: -b.y, z: -b.z, w: -b.w };
    return closeNumbers(a, b) || closeNumbers(a, negated) ? null : `${path}: ${JSON.stringify(a)} ≠ ${JSON.stringify(b)}`;
  }
  if (typeof a === 'number' && typeof b === 'number') {
    return Math.abs(a - b) <= 2e-3 * Math.max(1, Math.abs(a), Math.abs(b)) ? null : `${path}: ${a} ≠ ${b}`;
  }
  if (a === null || b === null || typeof a !== 'object' || typeof b !== 'object') return a === b ? null : `${path}: ${JSON.stringify(a)} ≠ ${JSON.stringify(b)}`;
  if (Array.isArray(a) !== Array.isArray(b)) return `${path}: list vs object`;
  const keys = new Set([...Object.keys(a as object), ...Object.keys(b as object)]);
  for (const k of keys) {
    const x = (a as Record<string, unknown>)[k], y = (b as Record<string, unknown>)[k];
    if (x === undefined && y === undefined) continue;
    const r = close(x ?? null, y ?? null, `${path}.${k}`);
    if (r) return r;
  }
  return null;
}

type Q = { x: number; y: number; z: number; w: number };
const isQuat = (v: unknown): v is Q => !!v && typeof v === 'object' && ['x', 'y', 'z', 'w'].every((k) => typeof (v as Record<string, unknown>)[k] === 'number');
const closeNumbers = (a: Q, b: Q) => (['x', 'y', 'z', 'w'] as const).every((k) => Math.abs(a[k] - b[k]) <= 2e-3);

/** Effects in a step may come in a different order (Swift's dictionaries); compare as sets. */
function sameSet(a: unknown[], b: unknown[], what: string): string | null {
  if (a.length !== b.length) return `${what}: ${a.length} vs ${b.length}\n  swift: ${JSON.stringify(a).slice(0, 600)}\n  web:   ${JSON.stringify(b).slice(0, 600)}`;
  const left = [...b];
  for (const x of a) {
    const i = left.findIndex((y) => close(x, y) === null);
    if (i < 0) {
      const nearest = left.map((y) => close(x, y)).find((r) => r !== null);
      return `${what}: no match for ${JSON.stringify(x).slice(0, 400)} (${nearest})`;
    }
    left.splice(i, 1);
  }
  return null;
}

function compare(swift: Trace, web: Trace, known: Set<string>): string | null {
  if (JSON.stringify(swift.compileErrors) !== JSON.stringify(web.compileErrors)) {
    return `compile errors:\n  swift: ${swift.compileErrors.join('\n')}\n  web:   ${web.compileErrors.join('\n')}`;
  }
  const rs = namer(swift, known), rw = namer(web, known);
  for (let i = 0; i < swift.steps.length; i++) {
    const s = canonical(swift.steps[i], rs), w = canonical(web.steps[i], rw);
    const where = `step ${i} (t=${swift.steps[i].t.toFixed(1)})`;
    for (const key of ['errors', 'output', 'roster'] as const) {
      if (JSON.stringify(s[key]) !== JSON.stringify(w[key])) return `${where} ${key}:\n  swift: ${JSON.stringify(s[key])}\n  web:   ${JSON.stringify(w[key])}`;
    }
    const d = sameSet(s.effects, w.effects, `${where} effects`) ?? sameSet(s.deltas, w.deltas, `${where} deltas`) ?? sameSet(s.npcs, w.npcs, `${where} npcs`);
    if (d) return d;
  }
  return null;
}

describe.skipIf(!traces)('the web runtime plays like the iPad', () => {
  const index = JSON.parse(readFileSync(join(root, 'index.json'), 'utf8')) as { games: { id: string; world: string; scripts?: string[] }[] };
  const only = process.env.ORACLE_GAMES?.split(',');
  const listings = index.games.filter((g) => existsSync(join(traces ?? '', g.id + '.json')) && (!only || only.includes(g.id)));

  it('on every game in the list', () => {
    const problems: string[] = [];
    for (const listing of listings) {
      const swift = JSON.parse(readFileSync(join(traces!, listing.id + '.json'), 'utf8')) as Trace;
      const world = JSON.parse(readFileSync(join(root, listing.world), 'utf8')) as { blocks: { id: string }[] };
      const known = new Set([alice, bob, ...world.blocks.map((b) => b.id.toUpperCase())]);
      let web: Trace;
      try {
        web = play(listing);
      } catch (error) {
        problems.push(`${listing.id}: crashed: ${(error as Error).stack}`);
        continue;
      }
      if (process.env.ORACLE_DUMP) writeFileSync(join(process.env.ORACLE_DUMP, listing.id + '.web.json'), JSON.stringify(web));
      const difference = compare(swift, web, known);
      if (difference) problems.push(`${listing.id}: ${difference}`);
    }
    console.log(`${listings.length - problems.length} of ${listings.length} games play the same`);
    if (problems.length) console.log(problems.join('\n\n'));
    expect(problems).toEqual([]);
  }, 600_000);
});
