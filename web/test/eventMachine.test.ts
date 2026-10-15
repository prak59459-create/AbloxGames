// EventMachineTests.swift, on the web.
import { describe, expect, it } from 'vitest';
import { alice, blankWorld, bob, snapshot, spawnPad } from './runtimeHelpers';
import { EventMachine, type Effect } from '../src/core/runtime/eventMachine';
import { eventRule, type EventAction } from '../src/core/model/rules';
import { colorFromHex } from '../src/core/model/color';
import { deepEqual } from '../src/core/model/equal';
import { normalizeDegrees, v3 } from '../src/core/model/math';
import { interpolated, playerSnapshot } from '../src/core/model/player';
import { defaultMovement, solveMovement, type MovementInput } from '../src/core/physics/collider';
import { makeBlock, placed, type BlockData } from '../src/core/model/world';
import { newID } from '../src/core/model/codec';

const started = (m: EventMachine) => m.handle({ kind: 'roundStarted' });
const touch = (m: EventMachine, peer: string, block: BlockData | string) =>
  m.handle({ kind: 'touched', peer, blockID: typeof block === 'string' ? block : block.id });
const has = (effects: Effect[], action: EventAction) => effects.some((e) => deepEqual(e.action, action));
const move = (m: EventMachine, peer: string, x: number, y = 0, z = 0, vy = 0) =>
  m.updateTransform({ peerID: peer, position: v3(x, y, z), yawDegrees: 0, velocity: v3(0, vy, 0), isGrounded: true });

describe('built-in behaviours', () => {
  it('a coin awards points once and hides', () => {
    const coin = makeBlock({ name: 'Coin', behavior: 'collectible', scoreValue: 10 });
    const m = new EventMachine(blankWorld([coin]));
    m.addPlayer(snapshot(alice, 'Alice'));
    started(m);
    const first = touch(m, alice, coin);
    expect(has(first, { type: 'setVisible', blockID: coin.id, visible: false })).toBe(true);
    expect(has(first, { type: 'awardPoints', points: 10 })).toBe(true);
    expect(m.player(alice)?.score).toBe(10);
    expect(touch(m, alice, coin)).toEqual([]);
    expect(m.player(alice)?.score).toBe(10);
  });

  it('coins are counted per player', () => {
    const coin = makeBlock({ name: 'Coin', behavior: 'collectible', scoreValue: 5 });
    const m = new EventMachine(blankWorld([coin]));
    m.addPlayer(snapshot(alice, 'Alice'));
    m.addPlayer(snapshot(bob, 'Bob'));
    started(m);
    touch(m, alice, coin);
    expect(touch(m, bob, coin).length).toBeGreaterThan(0);
    expect(m.player(alice)?.score).toBe(5);
    expect(m.player(bob)?.score).toBe(5);
    expect([...m.consumedBlocks(alice)]).toEqual([coin.id]);
  });

  it('a hazard sends you back and takes points, only for you', () => {
    const lava = makeBlock({ name: 'Lava', behavior: 'hazard', scoreValue: 3 });
    const m = new EventMachine(blankWorld([lava]));
    m.addPlayer(snapshot(alice, 'Alice'));
    started(m);
    const effects = touch(m, alice, lava);
    expect(effects.some((e) => e.action.type === 'teleportPlayer')).toBe(true);
    expect(has(effects, { type: 'awardPoints', points: -3 })).toBe(true);
    expect(m.player(alice)?.score).toBe(-3);
    expect(effects.every((e) => e.target === alice)).toBe(true);
  });

  it('a checkpoint moves where you respawn, once', () => {
    const cp = makeBlock({ name: 'CP', transform: placed(v3(20, 5, 0), v3(2, 1, 2)), behavior: 'checkpoint' });
    const m = new EventMachine(blankWorld([cp]));
    m.addPlayer(snapshot(alice, 'Alice'));
    started(m);
    expect(touch(m, alice, cp).length).toBeGreaterThan(0);
    expect(m.respawnPoint(alice).x).toBeCloseTo(20, 4);
    expect(m.respawnPoint(alice).y).toBeGreaterThan(5);
    expect(touch(m, alice, cp)).toEqual([]);
  });

  it('a hazard after a checkpoint returns you to the checkpoint', () => {
    const cp = makeBlock({ name: 'CP', transform: placed(v3(30, 0, 0)), behavior: 'checkpoint' });
    const lava = makeBlock({ name: 'Lava', behavior: 'hazard' });
    const m = new EventMachine(blankWorld([cp, lava]));
    m.addPlayer(snapshot(alice, 'Alice'));
    started(m);
    touch(m, alice, cp);
    const to = touch(m, alice, lava).flatMap((e) => (e.action.type === 'teleportPlayer' ? [e.action.position] : []))[0];
    expect(to.x).toBeCloseTo(30, 4);
  });

  it('the goal ends the round for everyone', () => {
    const goal = makeBlock({ name: 'Finish', behavior: 'goal' });
    const m = new EventMachine(blankWorld([goal]));
    m.addPlayer(snapshot(alice, 'Alice'));
    started(m);
    const effects = touch(m, alice, goal);
    expect(m.isRoundOver).toBe(true);
    expect(effects.flatMap((e) => (e.action.type === 'endRound' ? [e.action.message] : []))[0]).toBe('Alice reached the goal!');
    expect(effects[0].target).toBeUndefined();
  });

  it('nothing happens after the round ends, and a new round clears it', () => {
    const goal = makeBlock({ name: 'Finish', behavior: 'goal' });
    const coin = makeBlock({ name: 'Coin', behavior: 'collectible', scoreValue: 10 });
    const m = new EventMachine(blankWorld([goal, coin]));
    m.addPlayer(snapshot(alice, 'Alice'));
    started(m);
    touch(m, alice, goal);
    expect(touch(m, alice, coin)).toEqual([]);
    expect(m.player(alice)?.score).toBe(0);
    expect(m.handle({ kind: 'roundStarted' })).toEqual([]);
    expect(m.isRoundOver).toBe(false);
    expect(touch(m, alice, coin).length).toBeGreaterThan(0);
  });

  it('scenery and unknown blocks do nothing', () => {
    const rock = makeBlock({ name: 'Rock' });
    const m = new EventMachine(blankWorld([rock]));
    m.addPlayer(snapshot(alice, 'Alice'));
    started(m);
    expect(touch(m, alice, rock)).toEqual([]);
    expect(touch(m, alice, newID())).toEqual([]);
  });
});

describe('authored rules', () => {
  it('worldStart fires once', () => {
    const world = blankWorld();
    world.rules = [eventRule({ name: 'intro', trigger: { type: 'worldStart' }, actions: [{ type: 'announce', message: 'Go!', duration: 2 }] })];
    const effects = new EventMachine(world).handle({ kind: 'roundStarted' });
    expect(effects.length).toBe(1);
    expect(effects[0].action).toEqual({ type: 'announce', message: 'Go!', duration: 2 });
  });

  it('a tag rule matches any tagged block, ignoring case', () => {
    const a = makeBlock({ name: 'A', behavior: 'trigger', tags: ['coin'] });
    const b = makeBlock({ name: 'B', behavior: 'trigger', tags: ['COIN'] });
    const c = makeBlock({ name: 'C', behavior: 'trigger', tags: ['rock'] });
    const world = blankWorld([a, b, c]);
    world.rules = [eventRule({ name: 'sparkle', trigger: { type: 'tagTouched', tag: 'coin' }, actions: [{ type: 'playSound', name: 'ding' }], cooldown: 0 })];
    const m = new EventMachine(world);
    m.addPlayer(snapshot(alice, 'Alice'));
    started(m);
    expect(touch(m, alice, a).length).toBeGreaterThan(0);
    expect(touch(m, alice, b).length).toBeGreaterThan(0);
    expect(touch(m, alice, c)).toEqual([]);
  });

  it('a cooldown stops rapid refiring', () => {
    const pad = makeBlock({ name: 'Pad', behavior: 'trigger' });
    const world = blankWorld([pad]);
    world.rules = [eventRule({ name: 'beep', trigger: { type: 'blockTouched', blockID: pad.id }, actions: [{ type: 'playSound', name: 'beep' }], cooldown: 1 })];
    const m = new EventMachine(world, 0);
    m.addPlayer(snapshot(alice, 'Alice'));
    started(m);
    expect(touch(m, alice, pad).length).toBeGreaterThan(0);
    expect(touch(m, alice, pad)).toEqual([]);
    m.advance(1.5);
    expect(touch(m, alice, pad).length).toBeGreaterThan(0);
  });

  it('maxFireCount and disabled rules are honoured', () => {
    const pad = makeBlock({ name: 'Pad', behavior: 'trigger' });
    const world = blankWorld([pad]);
    world.rules = [
      eventRule({ name: 'once', trigger: { type: 'blockTouched', blockID: pad.id }, actions: [{ type: 'announce', message: 'only once', duration: 1 }], maxFireCount: 1, cooldown: 0 }),
      eventRule({ name: 'off', isEnabled: false, trigger: { type: 'blockTouched', blockID: pad.id }, actions: [{ type: 'playSound', name: 'x' }], cooldown: 0 }),
    ];
    const m = new EventMachine(world);
    m.addPlayer(snapshot(alice, 'Alice'));
    started(m);
    expect(touch(m, alice, pad).length).toBe(1);
    expect(touch(m, alice, pad)).toEqual([]);
  });

  it('showing and hiding is kept in the world for late joiners', () => {
    const door = makeBlock({ name: 'Door' });
    const lever = makeBlock({ name: 'Lever', behavior: 'trigger' });
    const world = blankWorld([door, lever]);
    world.rules = [eventRule({
      name: 'open', trigger: { type: 'blockTouched', blockID: lever.id }, cooldown: 0,
      actions: [{ type: 'setVisible', blockID: door.id, visible: false }, { type: 'setCollision', blockID: door.id, enabled: false }],
    })];
    const m = new EventMachine(world);
    m.addPlayer(snapshot(alice, 'Alice'));
    started(m);
    touch(m, alice, lever);
    expect(m.live.block(door.id)?.isVisible).toBe(false);
    expect(m.live.block(door.id)?.hasCollision).toBe(false);
  });

  it('an instant tint is kept; an animated one is only sent', () => {
    const lamp = makeBlock({ name: 'Lamp' });
    const pad = makeBlock({ name: 'Pad', behavior: 'trigger' });
    const red = colorFromHex('#FF0000')!;
    const make = (duration: number) => {
      const world = blankWorld([structuredClone(lamp), structuredClone(pad)]);
      world.rules = [eventRule({ name: 't', trigger: { type: 'blockTouched', blockID: pad.id }, actions: [{ type: 'tint', blockID: lamp.id, color: red, duration }], cooldown: 0 })];
      const m = new EventMachine(world);
      m.addPlayer(snapshot(alice, 'A'));
      started(m);
      return { m, effects: touch(m, alice, pad) };
    };
    expect(make(0).m.live.block(lamp.id)?.color).toEqual(red);
    const animated = make(2);
    expect(animated.m.live.block(lamp.id)?.color).not.toEqual(red);
    expect(animated.effects.length).toBeGreaterThan(0);
  });

  it('points need someone to give them to', () => {
    const world = blankWorld();
    world.rules = [eventRule({ name: 'bonus', trigger: { type: 'worldStart' }, actions: [{ type: 'awardPoints', points: 50 }] })];
    const m = new EventMachine(world);
    m.addPlayer(snapshot(alice, 'Alice'));
    expect(m.handle({ kind: 'roundStarted' })).toEqual([]);
    expect(m.player(alice)?.score).toBe(0);
  });

  it('collecting cascades into a score rule', () => {
    const coin = makeBlock({ name: 'Coin', behavior: 'collectible', scoreValue: 100 });
    const world = blankWorld([coin]);
    world.rules = [eventRule({ name: 'win', trigger: { type: 'scoreReached', score: 100 }, actions: [{ type: 'endRound', message: '100 points!' }], cooldown: 0 })];
    const m = new EventMachine(world);
    m.addPlayer(snapshot(alice, 'Alice'));
    started(m);
    expect(has(touch(m, alice, coin), { type: 'endRound', message: '100 points!' })).toBe(true);
    expect(m.isRoundOver).toBe(true);
  });
});

describe('timers, proximity and the kill plane', () => {
  it('a timer fires on schedule, and only once the round has started', () => {
    const world = blankWorld();
    world.rules = [eventRule({ name: 'tick', trigger: { type: 'timer', interval: 1 }, actions: [{ type: 'playSound', name: 'tick' }], cooldown: 0 })];
    const idle = new EventMachine(structuredClone(world), 0);
    expect(idle.advance(10)).toEqual([]);
    const m = new EventMachine(world, 0);
    started(m);
    expect(m.advance(0.5)).toEqual([]);
    expect(m.advance(1.1).length).toBeGreaterThan(0);
    expect(m.advance(1.5)).toEqual([]);
    expect(m.advance(2.2).length).toBeGreaterThan(0);
  });

  it('the clock never runs backwards', () => {
    const m = new EventMachine(blankWorld(), 10);
    started(m);
    expect(m.advance(5)).toEqual([]);
  });

  it('proximity fires on entry only, ignores height, and has hysteresis', () => {
    const sensor = makeBlock({ name: 'Sensor', transform: placed(v3(10, 0, 0)), behavior: 'trigger' });
    const world = blankWorld([sensor]);
    world.rules = [eventRule({ name: 'near', trigger: { type: 'proximity', blockID: sensor.id, radius: 3 }, actions: [{ type: 'announce', message: 'close', duration: 1 }], cooldown: 0 })];
    const m = new EventMachine(world, 0);
    m.addPlayer(snapshot(alice, 'Alice'));
    started(m);
    expect(m.advance(1)).toEqual([]);
    move(m, alice, 9);
    expect(m.advance(2).length).toBeGreaterThan(0);
    move(m, alice, 10);
    expect(m.advance(3)).toEqual([]);

    const s2 = makeBlock({ name: 'Sensor', behavior: 'trigger' });
    const w2 = blankWorld([s2]);
    w2.rules = [eventRule({ name: 'near', trigger: { type: 'proximity', blockID: s2.id, radius: 10 }, actions: [{ type: 'playSound', name: 'ping' }], cooldown: 0 })];
    const h = new EventMachine(w2, 0);
    h.addPlayer(snapshot(alice, 'Alice'));
    started(h);
    move(h, alice, 5, 40);
    expect(h.advance(1).length).toBeGreaterThan(0);
    move(h, alice, 10.5);
    h.advance(2);
    move(h, alice, 9);
    expect(h.advance(3)).toEqual([]);
    move(h, alice, 50);
    h.advance(4);
    move(h, alice, 0);
    expect(h.advance(5).length).toBeGreaterThan(0);
  });

  it('falling below the kill plane respawns you, still', () => {
    const world = blankWorld();
    world.environment.killPlaneHeight = -10;
    const m = new EventMachine(world, 0);
    m.addPlayer(snapshot(alice, 'Alice'));
    started(m);
    move(m, alice, 0, -50, 0, -30);
    const effects = m.advance(1);
    expect(effects.some((e) => e.action.type === 'teleportPlayer')).toBe(true);
    expect(m.player(alice)!.position.y).toBeGreaterThan(-10);
    expect(m.player(alice)!.velocity).toEqual(v3());
  });
});

describe('roster and live editing', () => {
  it('a joiner starts at a spawn, not where their handshake said', () => {
    const world = blankWorld([spawnPad(v3(7, 0, 7))]);
    const m = new EventMachine(world);
    m.addPlayer(snapshot(alice, 'Alice', v3(999, 999, 999)));
    expect(m.player(alice)?.position).not.toEqual(v3(999, 999, 999));
  });

  it('leaving clears a player, the roster is sorted, strangers cannot move', () => {
    const coin = makeBlock({ name: 'Coin', behavior: 'collectible', scoreValue: 1 });
    const m = new EventMachine(blankWorld([coin]));
    m.addPlayer(snapshot(bob, 'Bob'));
    m.addPlayer(snapshot(alice, 'Alice'));
    expect(m.roster.map((p) => p.profile.displayName)).toEqual(['Alice', 'Bob']);
    started(m);
    touch(m, alice, coin);
    m.removePlayer(alice);
    expect(m.player(alice)).toBeUndefined();
    expect(m.consumedBlocks(alice).size).toBe(0);
    move(m, alice, 1, 2, 3);
    expect(m.player(alice)).toBeUndefined();
  });

  it('replacing the rules gives them a clean slate', () => {
    const pad = makeBlock({ name: 'Pad', behavior: 'trigger' });
    const world = blankWorld([pad]);
    const rule = () => eventRule({ name: 'once', trigger: { type: 'blockTouched', blockID: pad.id }, actions: [{ type: 'playSound', name: 'x' }], maxFireCount: 1, cooldown: 0 });
    world.rules = [rule()];
    const m = new EventMachine(world);
    m.addPlayer(snapshot(alice, 'Alice'));
    started(m);
    expect(touch(m, alice, pad).length).toBeGreaterThan(0);
    expect(touch(m, alice, pad)).toEqual([]);
    m.apply({ type: 'rulesReplaced', rules: [rule()] });
    expect(touch(m, alice, pad).length).toBeGreaterThan(0);
  });

  it('a block added mid-round is seen by the rules', () => {
    const m = new EventMachine(blankWorld());
    m.addPlayer(snapshot(alice, 'Alice'));
    started(m);
    const coin = makeBlock({ name: 'Late Coin', behavior: 'collectible', scoreValue: 7 });
    m.apply({ type: 'insert', block: coin });
    expect(touch(m, alice, coin).length).toBeGreaterThan(0);
    expect(m.player(alice)?.score).toBe(7);
  });

  it('removing a block drops the rules about it', () => {
    const pad = makeBlock({ name: 'Pad', behavior: 'trigger' });
    const world = blankWorld([pad]);
    world.rules = [eventRule({ name: 'r', trigger: { type: 'blockTouched', blockID: pad.id }, actions: [] })];
    const m = new EventMachine(world);
    m.apply({ type: 'remove', blockID: pad.id });
    expect(m.world.rules).toEqual([]);
  });
});

describe('grouping effects', () => {
  it('splits into one broadcast and one payload per player', () => {
    const effects: Effect[] = [
      { action: { type: 'announce', message: 'everyone', duration: 1 } },
      { target: alice, action: { type: 'awardPoints', points: 10 } },
      { target: alice, action: { type: 'playSound', name: 'ding' } },
      { target: bob, action: { type: 'teleportPlayer', position: v3() } },
    ];
    const { broadcast, targeted } = EventMachine.payloads(effects);
    expect(broadcast?.actions.length).toBe(1);
    expect(targeted.get(alice)?.actions.length).toBe(2);
    expect(targeted.get(bob)?.actions.length).toBe(1);
    expect(targeted.get(alice)?.target).toBe(alice);
    const empty = EventMachine.payloads([]);
    expect(empty.broadcast).toBeNull();
    expect(empty.targeted.size).toBe(0);
  });
});

describe('movement (CharacterSolver)', () => {
  const step = (body: { velocity?: ReturnType<typeof v3>; yaw?: number; grounded?: boolean }, input: Partial<MovementInput>, dt = 1 / 60) =>
    solveMovement(
      { position: v3(), velocity: body.velocity ?? v3(), yawDegrees: body.yaw ?? 0, isGrounded: body.grounded ?? true },
      { stick: v3(), isJumping: false, isRunning: false, cameraYawDegrees: 0, ...input },
      defaultMovement(), { kind: 'normal' }, false, dt,
    );

  it('jumps only from the ground, and falls no faster than terminal speed', () => {
    expect(step({}, { isJumping: true }).velocity.y).toBeCloseTo(defaultMovement().jumpSpeed, 4);
    expect(step({ velocity: v3(0, -2, 0), grounded: false }, { isJumping: true }).velocity.y).toBeLessThan(0);
    let velocity = v3();
    for (let i = 0; i < 600; i++) velocity = step({ velocity, grounded: false }, {}).velocity;
    expect(velocity.y).toBeCloseTo(defaultMovement().maxFallSpeed, 3);
    expect(step({ grounded: false }, {}, 30).velocity.y).toBeGreaterThan(defaultMovement().gravity * 0.2);
  });

  it('the stick follows the camera; diagonals are not faster; running is', () => {
    const forward = step({}, { stick: v3(0, 0, 1) }).velocity;
    expect(forward.z).toBeLessThan(-1);
    expect(forward.x).toBeCloseTo(0, 4);
    const turned = step({}, { stick: v3(0, 0, 1), cameraYawDegrees: 90 }).velocity;
    expect(turned.x).toBeLessThan(-1);
    expect(turned.z).toBeCloseTo(0, 3);
    const diagonal = step({}, { stick: v3(1, 0, 1) }).velocity;
    expect(Math.hypot(diagonal.x, diagonal.z)).toBeCloseTo(Math.hypot(forward.x, forward.z), 3);
    expect(Math.abs(step({}, { stick: v3(0, 0, 1), isRunning: true }).velocity.z)).toBeGreaterThan(Math.abs(forward.z));
  });

  it('letting go slows to a stop; facing turns gradually and stays when idle', () => {
    let velocity = v3(5, 0, 0);
    for (let i = 0; i < 120; i++) velocity = step({ velocity }, {}).velocity;
    expect(Math.hypot(velocity.x, velocity.z)).toBeCloseTo(0, 1);
    expect(Math.abs(step({}, { stick: v3(1, 0, 0) }).yawDegrees)).toBeLessThan(90);
    let yaw = 0;
    for (let i = 0; i < 60; i++) yaw = step({ yaw }, { stick: v3(1, 0, 0) }).yawDegrees;
    expect(Math.abs(normalizeDegrees(yaw - 90))).toBeLessThan(1);
    expect(step({ yaw: 137 }, {}).yawDegrees).toBeCloseTo(137, 4);
  });

  it('interpolation takes the short way round', () => {
    const from = playerSnapshot(alice, { yawDegrees: 170 });
    const to = playerSnapshot(alice, { position: v3(10, 0, 0), yawDegrees: -170 });
    const mid = interpolated(from, to, 0.5);
    expect(Math.abs(mid.yawDegrees)).toBeCloseTo(180, 3);
    expect(mid.position.x).toBeCloseTo(5, 4);
  });
});
