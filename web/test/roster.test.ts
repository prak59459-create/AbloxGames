// AbloxCoreTests/RosterStateTests.swift and TransformPublisherTests
// (NetworkOptimizationTests.swift).
import { describe, expect, it } from 'vitest';
import { spawnPad, snapshot as named } from './runtimeHelpers';
import { RosterState, TransformPublisher, conservativeThresholds, defaultThresholds, transformHz } from '../src/core/model/roster';
import { playerSnapshot, type PlayerTransform } from '../src/core/model/player';
import { scale, v3, type Vec3 } from '../src/core/model/math';
import { emptyWorld } from '../src/core/model/world';
import { EventMachine } from '../src/core/runtime/eventMachine';

const me = 'AAAAAAAA-0000-0000-0000-000000000001';
const host = 'BBBBBBBB-0000-0000-0000-000000000002';
const guest = 'CCCCCCCC-0000-0000-0000-000000000003';

function snapshot(peer: string, position: Vec3 = v3(), score = 0, name = 'P') {
  const s = playerSnapshot(peer, { position, score });
  s.profile.displayName = name;
  return s;
}

const transform = (peer: string, position: Vec3): PlayerTransform => ({ peerID: peer, position, yawDegrees: 90, velocity: v3(1, 0, 0), isGrounded: false });

describe('RosterState', () => {
  it("applies another player's movement, keeping their name and score", () => {
    const state = new RosterState(me);
    state.replace([snapshot(me), snapshot(guest, v3(3, 0, 0), 40, 'Mika')]);
    state.apply(transform(guest, v3(10, 2, -4)));
    expect(state.player(guest)?.position).toEqual(v3(10, 2, -4));
    expect(state.player(guest)?.yawDegrees).toBe(90);
    expect(state.player(guest)?.isGrounded).toBe(false);
    expect(state.player(guest)?.score).toBe(40);
    expect(state.player(guest)?.profile.displayName).toBe('Mika');
  });

  it('ignores our own echo', () => {
    const state = new RosterState(me);
    state.replace([snapshot(me, v3(5, 0, 5))]);
    state.apply(transform(me, v3(-100, 0, 0)));
    expect(state.localPlayer?.position).toEqual(v3(5, 0, 5));
  });

  it('keeps movement that arrives before the roster, the newest only, and drops it for someone who never arrives', () => {
    let state = new RosterState(me);
    state.replace([snapshot(me)]);
    state.apply(transform(guest, v3(7, 0, 7)));
    expect(state.player(guest)).toBeUndefined();
    state.replace([snapshot(me), snapshot(guest)]);
    expect(state.player(guest)?.position).toEqual(v3(7, 0, 7));

    state = new RosterState(me);
    state.apply(transform(guest, v3(1, 0, 0)));
    state.apply(transform(guest, v3(2, 0, 0)));
    state.replace([snapshot(guest)]);
    expect(state.player(guest)?.position).toEqual(v3(2, 0, 0));

    state = new RosterState(me);
    state.apply(transform(guest, v3(1, 0, 0)));
    state.replace([snapshot(me)]);
    state.replace([snapshot(me), snapshot(guest)]);
    expect(state.player(guest)?.position).toEqual(v3());
  });

  it('does not rewind players already moving, and removes those who left', () => {
    const state = new RosterState(me);
    state.replace([snapshot(me), snapshot(guest)]);
    state.apply(transform(guest, v3(20, 0, 0)));
    state.replace([snapshot(me), snapshot(guest, v3(15, 0, 0), 10)]);
    expect(state.player(guest)?.position).toEqual(v3(20, 0, 0));
    expect(state.player(guest)?.score).toBe(10);
    state.replace([snapshot(me)]);
    expect(state.player(guest)).toBeUndefined();
    expect(state.otherPlayers.length).toBe(0);
  });

  it('places the local player where the host put them, once, and again after a reset', () => {
    let state = new RosterState(me);
    expect(state.replace([snapshot(host), snapshot(me, v3(3, 0, 0))])).toEqual([{ kind: 'placeLocalPlayer', position: v3(3, 0, 0) }]);
    expect(state.replace([snapshot(me, v3(3, 0, 0)), snapshot(guest)])).toEqual([]);
    expect(state.replace([snapshot(me, v3(3, 0, 0), 5)])).toEqual([]);

    state = new RosterState(me);
    expect(state.replace([snapshot(host)])).toEqual([]);
    expect(state.replace([snapshot(host), snapshot(me, v3(1, 0, 1))])).toEqual([{ kind: 'placeLocalPlayer', position: v3(1, 0, 1) }]);
    state.reset();
    expect(state.players).toEqual([]);
    expect(state.replace([snapshot(me, v3(6, 0, 0))])).toEqual([{ kind: 'placeLocalPlayer', position: v3(6, 0, 0) }]);
  });

  it("agrees with the host's own spawn assignment", () => {
    const world = emptyWorld('Two pads');
    world.blocks = [spawnPad(v3(-4, 0.1, 0)), spawnPad(v3(4, 0.1, 0))];
    const machine = new EventMachine(world);
    machine.addPlayer(named(host, 'Host'));
    machine.addPlayer(named(me, 'Joiner'));
    const view = new RosterState(me);
    const events = view.replace(machine.roster);
    expect(events.length).toBe(1);
    expect(events[0].position).toEqual(machine.players.get(me)!.position);
    expect(events[0].position).not.toEqual(machine.players.get(host)!.position);
  });
});

describe('TransformPublisher', () => {
  const snap = (position = v3(), yawDegrees = 0, velocity = v3(), isGrounded = true) => ({ position, yawDegrees, velocity, isGrounded });

  it('always sends the first, then only the keepalive while standing still', () => {
    const publisher = new TransformPublisher();
    expect(publisher.shouldPublish(snap(), 0)).toBe(true);
    let sends = 0;
    for (let tick = 1; tick <= 20; tick++) if (publisher.shouldPublish(snap(), tick / 20)) sends++;
    expect(sends).toBeLessThanOrEqual(1);
    const p2 = new TransformPublisher();
    expect(p2.shouldPublish(snap(), 0)).toBe(true);
    expect(p2.shouldPublish(snap(), 0.5)).toBe(false);
    expect(p2.shouldPublish(snap(), 1.1)).toBe(true);
  });

  it('predicts steady running rather than resending it', () => {
    const publisher = new TransformPublisher();
    const velocity = v3(5, 0, 0);
    expect(publisher.shouldPublish(snap(v3(), 0, velocity), 0)).toBe(true);
    let sends = 0;
    for (let tick = 1; tick <= 40; tick++) {
      const t = tick / 20;
      if (publisher.shouldPublish(snap(scale(velocity, t), 0, velocity), t)) sends++;
    }
    expect(sends).toBeLessThanOrEqual(3);
  });

  it('sends at once on a change of direction, a jump or a turn, taking the short way round', () => {
    let p = new TransformPublisher();
    expect(p.shouldPublish(snap(v3(), 0, v3(5, 0, 0)), 0)).toBe(true);
    expect(p.shouldPublish(snap(v3(0.25, 0, 0), 0, v3(5, 0, 0)), 0.05)).toBe(false);
    expect(p.shouldPublish(snap(v3(0.5, 0, 0), 0, v3(-5, 0, 0)), 0.1)).toBe(true);

    p = new TransformPublisher();
    expect(p.shouldPublish(snap(), 0)).toBe(true);
    expect(p.shouldPublish(snap(v3(), 0, v3(0, 6, 0), false), 0.06)).toBe(true);

    p = new TransformPublisher();
    expect(p.shouldPublish(snap(v3(), 0), 0)).toBe(true);
    expect(p.shouldPublish(snap(v3(), 0.5), 0.06)).toBe(false);
    expect(p.shouldPublish(snap(v3(), 40), 0.12)).toBe(true);

    p = new TransformPublisher();
    expect(p.shouldPublish(snap(v3(), 179), 0)).toBe(true);
    expect(p.shouldPublish(snap(v3(), -179.5), 0.06)).toBe(false);
    expect(p.shouldPublish(snap(v3(), -90), 0.12)).toBe(true);
  });

  it('keeps to the rate ceiling, and sends after a reset', () => {
    const p = new TransformPublisher();
    expect(p.shouldPublish(snap(), 0)).toBe(true);
    expect(p.shouldPublish(snap(v3(500, 0, 0)), 0.001)).toBe(false);
    expect(p.shouldPublish(snap(v3(500, 0, 0)), 0.2)).toBe(true);
    const q = new TransformPublisher();
    expect(q.shouldPublish(snap(), 0)).toBe(true);
    expect(q.shouldPublish(snap(), 0.1)).toBe(false);
    q.reset();
    expect(q.shouldPublish(snap(), 0.15)).toBe(true);
  });

  it('measures what it saved, predicts from the last velocity, and sends less when conservative', () => {
    const p = new TransformPublisher();
    for (let tick = 0; tick <= 40; tick++) p.shouldPublish(snap(), tick / 20);
    expect(p.suppressionRate).toBeGreaterThan(0.8);
    expect(p.consideredCount).toBe(41);
    const r = new TransformPublisher();
    expect(r.predictedPosition(1)).toBeNull();
    r.shouldPublish(snap(v3(), 0, v3(4, 0, 0)), 0);
    expect(r.predictedPosition(0.5)!.x).toBeCloseTo(2, 4);
    const sends = (thresholds: typeof defaultThresholds) => {
      const pub = new TransformPublisher(thresholds);
      let count = 0;
      for (let tick = 0; tick <= 60; tick++) {
        const t = tick / 20;
        const wobble = Math.sin(t * 8) * 0.4;
        if (pub.shouldPublish(snap(v3(t * 2, 0, wobble), 0, v3(2, 0, wobble)), t)) count++;
      }
      return count;
    };
    expect(sends(conservativeThresholds)).toBeLessThan(sends(defaultThresholds));
    expect(transformHz).toBe(20);
  });
});
