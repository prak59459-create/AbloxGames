// Who is in the session and where, as one device sees it (RosterState.swift),
// and when our own movement is worth sending (TransformPublisher.swift).
// The same bookkeeping for a host and a guest, so the two position bugs the
// iPads once had — a host that never saw anyone move, a guest who ignored
// the spawn point the host gave them — stay fixed here as well.
import { add, angularDelta, distance, length, scale, sub, type Vec3 } from './math';
import { copySnapshot, type PlayerSnapshot, type PlayerTransform } from './player';

export type RosterEvent = { kind: 'placeLocalPlayer'; position: Vec3 };

const applyTransform = (s: PlayerSnapshot, t: PlayerTransform) => {
  s.position = { ...t.position };
  s.yawDegrees = t.yawDegrees;
  s.velocity = { ...t.velocity };
  s.isGrounded = t.isGrounded;
};

export class RosterState {
  players: PlayerSnapshot[] = [];
  /** Movement for players the roster has not introduced yet: the newest, held until they appear. */
  private pending = new Map<string, PlayerTransform>();
  private hasPlacedLocalPlayer = false;

  constructor(readonly localPeerID: string) {}

  /**
   * A full roster from the host. Positions of players already known are
   * kept: transforms are newer than any roster, which only comes on joins,
   * leavings and scores.
   */
  replace(roster: PlayerSnapshot[]): RosterEvent[] {
    const events: RosterEvent[] = [];
    const known = new Map<string, PlayerSnapshot>();
    for (const p of this.players) if (!known.has(p.peerID)) known.set(p.peerID, p);
    this.players = roster.map((incoming) => {
      const merged = copySnapshot(incoming);
      const existing = known.get(incoming.peerID);
      if (existing && incoming.peerID !== this.localPeerID) {
        merged.position = { ...existing.position };
        merged.yawDegrees = existing.yawDegrees;
        merged.velocity = { ...existing.velocity };
        merged.isGrounded = existing.isGrounded;
      }
      const newer = this.pending.get(incoming.peerID);
      if (newer) {
        this.pending.delete(incoming.peerID);
        if (incoming.peerID !== this.localPeerID) applyTransform(merged, newer);
      }
      return merged;
    });
    if (!this.hasPlacedLocalPlayer) {
      const me = this.players.find((p) => p.peerID === this.localPeerID);
      if (me) {
        this.hasPlacedLocalPlayer = true;
        events.push({ kind: 'placeLocalPlayer', position: { ...me.position } });
      }
    }
    const present = new Set(this.players.map((p) => p.peerID));
    for (const id of [...this.pending.keys()]) if (!present.has(id)) this.pending.delete(id);
    return events;
  }

  /** Another player's movement. Our own comes back as an echo and is ignored. */
  apply(t: PlayerTransform): void {
    if (t.peerID === this.localPeerID) return;
    const player = this.players.find((p) => p.peerID === t.peerID);
    if (!player) {
      this.pending.set(t.peerID, t);
      return;
    }
    applyTransform(player, t);
  }

  get localPlayer(): PlayerSnapshot | undefined { return this.players.find((p) => p.peerID === this.localPeerID); }
  get otherPlayers(): PlayerSnapshot[] { return this.players.filter((p) => p.peerID !== this.localPeerID); }
  player(peer: string): PlayerSnapshot | undefined { return this.players.find((p) => p.peerID === peer); }

  reset(): void {
    this.players = [];
    this.pending.clear();
    this.hasPlacedLocalPlayer = false;
  }
}

// MARK: - Dead reckoning

export interface PublishThresholds { position: number; yawDegrees: number; velocity: number; maximumSilence: number; maximumRate: number }

export const transformHz = 20;
export const defaultThresholds: PublishThresholds = { position: 0.05, yawDegrees: 2, velocity: 0.5, maximumSilence: 1, maximumRate: transformHz };
export const conservativeThresholds: PublishThresholds = { position: 0.15, yawDegrees: 5, velocity: 1, maximumSilence: 1.5, maximumRate: 10 };

interface Sent { position: Vec3; yawDegrees: number; velocity: Vec3; isGrounded: boolean }

/** Sends our movement only when peers, carrying on from the last packet, would have it wrong. */
export class TransformPublisher {
  private lastSent: Sent | null = null;
  private lastSentAt = -Number.MAX_VALUE;
  consideredCount = 0;
  sentCount = 0;

  constructor(public thresholds: PublishThresholds = defaultThresholds) {}

  get suppressionRate(): number {
    return this.consideredCount > 0 ? (this.consideredCount - this.sentCount) / this.consideredCount : 0;
  }

  predictedPosition(after: number): Vec3 | null {
    if (!this.lastSent) return null;
    return add(this.lastSent.position, scale(this.lastSent.velocity, Math.max(0, after)));
  }

  shouldPublish(s: Sent, time: number): boolean {
    this.consideredCount += 1;
    const previous = this.lastSent;
    if (!previous) return this.record(s, time);
    const elapsed = time - this.lastSentAt;
    if (elapsed < 1 / Math.max(1, this.thresholds.maximumRate)) return false;
    if (elapsed >= this.thresholds.maximumSilence) return this.record(s, time);
    const predicted = add(previous.position, scale(previous.velocity, elapsed));
    if (distance(predicted, s.position) >= this.thresholds.position) return this.record(s, time);
    if (Math.abs(angularDelta(previous.yawDegrees, s.yawDegrees)) >= this.thresholds.yawDegrees) return this.record(s, time);
    if (length(sub(s.velocity, previous.velocity)) >= this.thresholds.velocity) return this.record(s, time);
    if (s.isGrounded !== previous.isGrounded) return this.record(s, time);
    return false;
  }

  private record(s: Sent, time: number): true {
    this.lastSent = { position: { ...s.position }, yawDegrees: s.yawDegrees, velocity: { ...s.velocity }, isGrounded: s.isGrounded };
    this.lastSentAt = time;
    this.sentCount += 1;
    return true;
  }

  reset(): void {
    this.lastSent = null;
    this.lastSentAt = -Number.MAX_VALUE;
  }
}
