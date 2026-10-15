// What the Swift runtime tests share (RuntimeTestCase in GameRuntimeTests.swift):
// two players, a world, and ways to read what reached whom.
import './helpers';
import { colorFromHex } from '../src/core/model/color';
import { deepEqual } from '../src/core/model/equal';
import type { EventAction } from '../src/core/model/rules';
import type { ScriptEffect } from '../src/core/model/effects';
import { ScriptedPlayerState } from '../src/core/model/scriptedState';
import { playerSnapshot, type PlayerSnapshot } from '../src/core/model/player';
import { v3, type Vec3 } from '../src/core/model/math';
import { emptyWorld, makeBlock, placed, type BlockData, type WorldDocument } from '../src/core/model/world';
import { defaultLimits, type ScriptLimits } from '../src/core/script/interpreter';
import { GameRuntime, type Effect } from '../src/core/runtime/gameRuntime';
import { newID } from '../src/core/model/codec';

export const alice = 'AAAAAAAA-0000-0000-0000-000000000001';
export const bob = 'BBBBBBBB-0000-0000-0000-000000000002';

export function snapshot(peer: string, name: string, position: Vec3 = v3()): PlayerSnapshot {
  const s = playerSnapshot(peer, { position });
  s.profile.displayName = name;
  return s;
}

/** `BlockData.preset(.spawn, at:)`. */
export const spawnPad = (position: Vec3): BlockData => makeBlock({
  name: 'Spawn', shape: 'cylinder', transform: placed(position, v3(2, 0.2, 2)), color: colorFromHex('#22D3EE')!, material: 'neon', behavior: 'spawn',
});

/** `WorldDocument.blank()`: a floor and a spawn pad. */
export function blankWorld(extra: BlockData[] = []): WorldDocument {
  const world = emptyWorld('Blank World');
  world.blocks = [
    makeBlock({ name: 'Floor', transform: placed(v3(0, -0.5, 0), v3(40, 1, 40)), color: colorFromHex('#37474F')!, material: 'matte', tags: ['ground'] }),
    spawnPad(v3(0, 0.1, 0)),
    ...extra,
  ];
  return world;
}

export const script = (name: string, source: string, isEnabled = true) => ({ id: newID(), name: name.endsWith('.absc') ? name : name + '.absc', source, isEnabled });

export function game(source: string | null, world: WorldDocument = emptyWorld('Arena'), limits: Partial<ScriptLimits> = {}): GameRuntime {
  const w = structuredClone(world);
  w.scripts = source === null ? [] : [script('main', source)];
  return new GameRuntime(w, 0, 42n, { ...defaultLimits(), ...limits });
}

/** Alice and Bob, both there before the round starts. */
export function startWithBoth(g: GameRuntime): Effect[] {
  g.addPlayer(snapshot(alice, 'Alice'));
  g.addPlayer(snapshot(bob, 'Bob'));
  return g.handle({ kind: 'roundStarted' });
}

export function place(g: GameRuntime, peer: string, position: Vec3): void {
  g.updateTransform({ peerID: peer, position, yawDegrees: 0, velocity: v3(), isGrounded: true });
}

/** Alice at z = -10 shoots straight down +z, where Bob stands at the origin. */
export function aliceShootsBob(g: GameRuntime, time: number): Effect[] {
  place(g, alice, v3(0, 0, -10));
  place(g, bob, v3());
  return g.handleInput({ kind: 'fire', origin: v3(0, 1.6, -10), direction: v3(0, 0, 1) }, alice, time);
}

export const reaching = (peer: string, effects: Effect[]): EventAction[] =>
  effects.filter((e) => e.target === undefined || e.target === peer).map((e) => e.action);

export const scripted = (peer: string, effects: Effect[]): ScriptEffect[] =>
  reaching(peer, effects).flatMap((a) => (a.type === 'script' ? [a.effect] : []));

export function screen(peer: string, effects: Effect[]): ScriptedPlayerState {
  const state = new ScriptedPlayerState();
  for (const e of scripted(peer, effects)) state.apply(e);
  return state;
}

export const healths = (peer: string, effects: Effect[]): number[] =>
  scripted(peer, effects).flatMap((e) => (e.kind === 'health' ? [e.current] : []));

export const announcements = (peer: string, effects: Effect[]): string[] => reaching(peer, effects).flatMap((a) => {
  if (a.type === 'announce') return [a.message];
  if (a.type === 'endRound') return [a.message];
  if (a.type === 'script' && a.effect.kind === 'chat') return [a.effect.text];
  return [];
});

export const containsEqual = <T>(list: T[], item: T) => list.some((x) => deepEqual(x, item));
