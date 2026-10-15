// The rule evaluator — AbloxCore/EventMachine.swift. It runs only on the
// host: players report what happened to them, and the host decides what it
// means, so nobody's iPad (or browser) can award itself points. It has no
// clock of its own; time is passed in, which is what makes it testable.
import { copySnapshot, type PlayerSnapshot, type PlayerTransform } from '../model/player';
import { LiveWorld, type WorldDelta } from '../model/liveWorld';
import { f32v, horizontalDistance, sameVec, v3, type Vec3 } from '../model/math';
import type { EventAction, EventRule, EventTrigger } from '../model/rules';
import { sameIgnoringCase } from '../model/text';
import { unitSize, type BlockData, type WorldDocument } from '../model/world';

export type Observation =
  | { kind: 'roundStarted' }
  | { kind: 'touched'; peer: string; blockID: string }
  | { kind: 'tapped'; peer: string; blockID: string }
  | { kind: 'proximityEntered'; peer: string; blockID: string }
  | { kind: 'scoreChanged'; peer: string; newScore: number };

/** A resolved effect: for one player when `target` is set, for everyone when it is not. */
export interface Effect { ruleID?: string; target?: string; action: EventAction }

type Scheduled = { due: number; action: 'hide' | 'show'; id: string };

const withAlpha = (c: { r: number; g: number; b: number }, a: number) => ({ r: c.r, g: c.g, b: c.b, a: Math.fround(a) });

export class EventMachine {
  readonly live: LiveWorld;
  readonly players = new Map<string, PlayerSnapshot>();
  private fireCounts = new Map<string, number>();
  private lastFiredAt = new Map<string, number>();
  private lastTimerFireAt = new Map<string, number>();
  private consumed = new Map<string, Set<string>>();
  private proximityInside = new Set<string>();
  private respawnPoints = new Map<string, Vec3>();
  private stages = new Map<string, number>();
  private blockCooldowns = new Map<string, number>();
  private scheduled: Scheduled[] = [];
  private now: number;
  private hasStarted = false;
  isRoundOver = false;

  constructor(world: WorldDocument | LiveWorld, startTime = 0) {
    this.live = world instanceof LiveWorld ? world : new LiveWorld(world);
    this.now = startTime;
  }

  get world(): WorldDocument { return this.live.world; }

  // MARK: Roster

  addPlayer(snapshot: PlayerSnapshot): void {
    const s = copySnapshot(snapshot);
    if (!this.respawnPoints.has(s.peerID)) {
      const spawn = this.live.spawnPosition(this.players.size);
      this.respawnPoints.set(s.peerID, spawn);
      // Someone joining mid-round starts at the spawn, not wherever their handshake said.
      s.position = f32v(spawn);
    }
    this.players.set(s.peerID, s);
  }

  updateProfile(profile: PlayerSnapshot['profile'], peer: string): void {
    const p = this.players.get(peer);
    if (p) p.profile = profile;
  }

  removePlayer(peer: string): void {
    this.players.delete(peer);
    this.consumed.delete(peer);
    this.respawnPoints.delete(peer);
    this.stages.delete(peer);
    for (const key of [...this.proximityInside]) if (key.startsWith(peer + '|')) this.proximityInside.delete(key);
  }

  updateTransform(t: PlayerTransform): void {
    const p = this.players.get(t.peerID);
    if (!p) return;
    p.position = f32v(t.position);
    p.yawDegrees = Math.fround(t.yawDegrees);
    p.velocity = f32v(t.velocity);
    p.isGrounded = t.isGrounded;
  }

  player(peer: string): PlayerSnapshot | undefined { return this.players.get(peer); }

  /** Everyone, by name. */
  get roster(): PlayerSnapshot[] {
    return [...this.players.values()].sort((a, b) => (a.profile.displayName < b.profile.displayName ? -1 : a.profile.displayName > b.profile.displayName ? 1 : 0));
  }

  respawnPoint(peer: string): Vec3 {
    return this.respawnPoints.get(peer) ?? this.live.spawnPosition(0);
  }

  consumedBlocks(peer: string): Set<string> { return new Set(this.consumed.get(peer) ?? []); }

  // MARK: World edits

  apply(delta: WorldDelta): void {
    this.live.apply(delta);
    const live = new Set(this.world.rules.map((r) => r.id));
    for (const map of [this.fireCounts, this.lastFiredAt, this.lastTimerFireAt]) {
      for (const id of [...map.keys()]) if (!live.has(id)) map.delete(id);
    }
  }

  endRound(): void { this.isRoundOver = true; }

  // MARK: Time

  advance(time: number): Effect[] {
    if (!(time >= this.now)) return [];
    this.now = time;
    if (!this.hasStarted || this.isRoundOver) return [];
    return [...this.fireScheduled(), ...this.fireTimerRules(), ...this.evaluateProximity(), ...this.enforceKillPlane()];
  }

  // MARK: Main entry point

  handle(observation: Observation): Effect[] {
    if (this.isRoundOver && observation.kind !== 'roundStarted') return [];
    const effects: Effect[] = [];

    switch (observation.kind) {
      case 'roundStarted':
        this.hasStarted = true;
        this.isRoundOver = false;
        this.fireCounts.clear();
        this.lastFiredAt.clear();
        this.lastTimerFireAt.clear();
        this.consumed.clear();
        this.proximityInside.clear();
        this.blockCooldowns.clear();
        this.scheduled = [];
        // Every timer counts from the start of the round.
        for (const rule of this.world.rules) if (rule.trigger.type === 'timer') this.lastTimerFireAt.set(rule.id, this.now);
        effects.push(...this.fireRules((t) => t.type === 'worldStart', undefined));
        break;

      case 'touched': {
        const { peer, blockID } = observation;
        effects.push(...this.applyBuiltInBehavior(peer, blockID));
        const tags = this.live.block(blockID)?.tags ?? [];
        effects.push(...this.fireRules((t) => (t.type === 'blockTouched' && t.blockID === blockID)
          || (t.type === 'tagTouched' && tags.some((tag) => sameIgnoringCase(tag, t.tag))), peer));
        break;
      }

      case 'tapped': {
        const { peer, blockID } = observation;
        effects.push(...this.fireRules((t) => t.type === 'blockTapped' && t.blockID === blockID, peer));
        break;
      }

      case 'proximityEntered': {
        const { peer, blockID } = observation;
        const key = peer + '|' + blockID;
        if (this.proximityInside.has(key)) break;
        this.proximityInside.add(key);
        effects.push(...this.fireRules((t) => t.type === 'proximity' && t.blockID === blockID, peer));
        break;
      }

      case 'scoreChanged': {
        const { peer, newScore } = observation;
        const p = this.players.get(peer);
        if (p) p.score = newScore;
        effects.push(...this.fireRules((t) => t.type === 'scoreReached' && newScore >= t.score, peer));
        break;
      }
    }

    // Points just given can trip a score rule: one level deep, enough for
    // "collect ten coins to win" without risking a loop.
    const scoreEffects = effects.filter((e) => e.action.type === 'awardPoints');
    for (const effect of scoreEffects) {
      const peer = effect.target;
      const score = peer ? this.players.get(peer)?.score : undefined;
      if (peer === undefined || score === undefined) continue;
      effects.push(...this.fireRules((t) => t.type === 'scoreReached' && score >= t.score, peer));
    }

    if (effects.some((e) => e.action.type === 'endRound')) this.isRoundOver = true;
    return effects;
  }

  // MARK: Built-in behaviours

  private applyBuiltInBehavior(peer: string, blockID: string): Effect[] {
    const block = this.live.block(blockID);
    if (!block) return [];
    switch (block.behavior) {
      case 'none': case 'spawn': case 'trigger':
        return [];

      case 'checkpoint': {
        const top = this.topSurfacePosition(block);
        const held = this.respawnPoints.get(peer);
        if (held && sameVec(held, top)) return [];
        const stage = block.gimmick.stage;
        if (stage > 0) {
          if (stage < (this.stages.get(peer) ?? 0)) return [];
          this.stages.set(peer, stage);
        }
        this.respawnPoints.set(peer, top);
        return [
          { target: peer, action: { type: 'announce', message: 'Checkpoint reached', duration: 1.5 } },
          { target: peer, action: { type: 'playSound', name: 'checkpoint' } },
        ];
      }

      case 'hazard': {
        const effects: Effect[] = [
          { target: peer, action: { type: 'teleportPlayer', position: this.respawnPoint(peer) } },
          { target: peer, action: { type: 'playSound', name: 'hurt' } },
        ];
        if (block.scoreValue !== 0) effects.push(...this.award(-Math.abs(block.scoreValue), peer, undefined));
        return effects;
      }

      case 'collectible': {
        const taken = this.consumed.get(peer) ?? new Set<string>();
        if (taken.has(blockID)) return [];
        taken.add(blockID);
        this.consumed.set(peer, taken);
        const effects: Effect[] = [
          { target: peer, action: { type: 'setVisible', blockID, visible: false } },
          { target: peer, action: { type: 'playSound', name: 'collect' } },
        ];
        if (block.scoreValue !== 0) effects.push(...this.award(block.scoreValue, peer, undefined));
        return effects;
      }

      case 'goal': {
        this.isRoundOver = true;
        const name = this.players.get(peer)?.profile.displayName ?? 'Someone';
        return [{ action: { type: 'endRound', message: `${name} reached the goal!` } }];
      }

      case 'bounce':
        if (!this.beginGimmick(block)) return [];
        return [
          { target: peer, action: { type: 'bouncePlayer', speed: block.gimmick.bounceSpeed } },
          { action: { type: 'playSound', name: 'bounce' } },
        ];

      case 'disappear': {
        if (!this.beginGimmick(block)) return [];
        // The grace period is the trap: the vanishing and the coming back
        // are both scheduled, and `advance` sends them.
        this.schedule('hide', block.id, this.now + block.gimmick.disappearDelay);
        this.schedule('show', block.id, this.now + block.gimmick.disappearDelay + Math.max(0.1, block.gimmick.respawnDelay));
        return [{ action: { type: 'tint', blockID: block.id, color: withAlpha(block.color, 0.35), duration: block.gimmick.disappearDelay } }];
      }

      case 'teleport': {
        const targetID = block.gimmick.teleportTargetID;
        const target = targetID ? this.live.block(targetID) : undefined;
        if (!target || targetID === block.id || !this.beginGimmick(block)) return [];
        return [
          { target: peer, action: { type: 'teleportPlayer', position: this.topSurfacePosition(target) } },
          { action: { type: 'playSound', name: 'teleport' } },
        ];
      }

      case 'door': {
        if (!block.isVisible || !this.beginGimmick(block)) return [];
        const open = Math.max(0.5, Math.min(60, block.gimmick.doorSeconds));
        this.schedule('hide', block.id, this.now + 0.2);
        this.schedule('show', block.id, this.now + 0.2 + open);
        return [
          { action: { type: 'tint', blockID: block.id, color: withAlpha(block.color, 0.2), duration: 0.2 } },
          { action: { type: 'playSound', name: 'door' } },
        ];
      }

      case 'ladder': case 'elevator': case 'vehicle': case 'pushable':
        return [];
    }
    return [];
  }

  private beginGimmick(block: BlockData): boolean {
    const last = this.blockCooldowns.get(block.id);
    if (last !== undefined && this.now - last < block.gimmick.cooldown) return false;
    this.blockCooldowns.set(block.id, this.now);
    return true;
  }

  private award(points: number, peer: string, ruleID: string | undefined): Effect[] {
    const p = this.players.get(peer);
    if (!p) return [];
    p.score += points;
    return [{ ruleID, target: peer, action: { type: 'awardPoints', points } }];
  }

  /** Just above a block's top face, where a checkpoint puts you. */
  private topSurfacePosition(block: BlockData): Vec3 {
    const t = this.live.worldTransform(block.id);
    const half = unitSize(block.shape).y * t.scale.y * 0.5;
    return v3(t.position.x, t.position.y + half + 1, t.position.z);
  }

  // MARK: Rule firing

  private fireRules(matching: (t: EventTrigger) => boolean, peer: string | undefined): Effect[] {
    const effects: Effect[] = [];
    for (const rule of this.world.rules) {
      if (!rule.isEnabled || !matching(rule.trigger) || !this.canFire(rule)) continue;
      this.noteFired(rule);
      effects.push(...this.resolve(rule, peer));
    }
    return effects;
  }

  private fireTimerRules(): Effect[] {
    const effects: Effect[] = [];
    for (const rule of this.world.rules) {
      if (!rule.isEnabled || rule.trigger.type !== 'timer' || !(rule.trigger.interval > 0)) continue;
      const last = this.lastTimerFireAt.get(rule.id);
      if (last === undefined) {
        // A timer added mid-round starts counting now.
        this.lastTimerFireAt.set(rule.id, this.now);
        continue;
      }
      if (!(this.now - last >= rule.trigger.interval)) continue;
      this.lastTimerFireAt.set(rule.id, this.now);
      if (!this.canFire(rule)) continue;
      this.noteFired(rule);
      effects.push(...this.resolve(rule, undefined));
    }
    return effects;
  }

  private evaluateProximity(): Effect[] {
    const effects: Effect[] = [];
    for (const rule of this.world.rules) {
      if (!rule.isEnabled || rule.trigger.type !== 'proximity') continue;
      const { blockID, radius } = rule.trigger;
      if (!this.live.block(blockID)) continue;
      const target = this.live.worldPosition(blockID);
      for (const [peer, p] of this.players) {
        const key = peer + '|' + blockID;
        const d = horizontalDistance(p.position, target);
        const inside = d <= radius;
        if (inside && !this.proximityInside.has(key)) {
          this.proximityInside.add(key);
          if (!this.canFire(rule)) continue;
          this.noteFired(rule);
          effects.push(...this.resolve(rule, peer));
        } else if (!inside && d > radius * 1.15) {
          // Leaving only once clearly outside, so the edge does not chatter.
          this.proximityInside.delete(key);
        }
      }
    }
    return effects;
  }

  private enforceKillPlane(): Effect[] {
    const effects: Effect[] = [];
    const floor = this.world.environment.killPlaneHeight;
    for (const [peer, p] of this.players) {
      if (!(p.position.y < floor)) continue;
      const spawn = this.respawnPoint(peer);
      p.position = { ...spawn };
      p.velocity = v3();
      effects.push({ target: peer, action: { type: 'teleportPlayer', position: { ...spawn } } });
    }
    return effects;
  }

  private schedule(action: 'hide' | 'show', id: string, due: number): void {
    // Already queued: a player bouncing on it mid-cycle cannot stack them.
    if (this.scheduled.some((s) => s.action === action && s.id === id)) return;
    this.scheduled.push({ due, action, id });
  }

  private fireScheduled(): Effect[] {
    if (!this.scheduled.length) return [];
    const due = this.scheduled.filter((s) => s.due <= this.now);
    if (!due.length) return [];
    this.scheduled = this.scheduled.filter((s) => !(s.due <= this.now));
    const effects: Effect[] = [];
    for (const item of due) {
      if (!this.live.block(item.id)) continue;
      const shown = item.action === 'show';
      this.live.mutate(item.id, (b) => { b.isVisible = shown; b.hasCollision = shown; });
      effects.push({ action: { type: 'setVisible', blockID: item.id, visible: shown } });
      effects.push({ action: { type: 'setCollision', blockID: item.id, enabled: shown } });
    }
    return effects;
  }

  private canFire(rule: EventRule): boolean {
    if (rule.maxFireCount !== undefined && (this.fireCounts.get(rule.id) ?? 0) >= rule.maxFireCount) return false;
    const last = this.lastFiredAt.get(rule.id);
    if (last !== undefined && this.now - last < rule.cooldown) return false;
    return true;
  }

  private noteFired(rule: EventRule): void {
    this.fireCounts.set(rule.id, (this.fireCounts.get(rule.id) ?? 0) + 1);
    this.lastFiredAt.set(rule.id, this.now);
  }

  private resolve(rule: EventRule, peer: string | undefined): Effect[] {
    const effects: Effect[] = [];
    for (const action of rule.actions) {
      switch (action.type) {
        case 'awardPoints':
          if (peer !== undefined) effects.push(...this.award(action.points, peer, rule.id));
          break;
        case 'teleportPlayer': case 'bouncePlayer':
          // Personal: only whoever set it off.
          if (peer !== undefined) effects.push({ ruleID: rule.id, target: peer, action });
          break;
        case 'endRound':
          this.isRoundOver = true;
          effects.push({ ruleID: rule.id, action });
          break;
        case 'setVisible':
          // Kept in the world too, so someone joining later sees it as it is.
          this.live.mutate(action.blockID, (b) => { b.isVisible = action.visible; });
          effects.push({ ruleID: rule.id, action });
          break;
        case 'setCollision':
          this.live.mutate(action.blockID, (b) => { b.hasCollision = action.enabled; });
          effects.push({ ruleID: rule.id, action });
          break;
        case 'tint':
          // An instant change of colour is kept; a fade is the players' to draw.
          if (action.duration <= 0) this.live.mutate(action.blockID, (b) => { b.color = { ...action.color }; });
          effects.push({ ruleID: rule.id, action });
          break;
        case 'move':
          if (action.duration <= 0) {
            this.live.mutate(action.blockID, (b) => {
              const p = b.transform.position;
              b.transform.position = f32v(v3(p.x + action.offset.x, p.y + action.offset.y, p.z + action.offset.z));
            });
          }
          effects.push({ ruleID: rule.id, action });
          break;
        case 'announce': case 'playSound':
          effects.push({ ruleID: rule.id, action });
          break;
        case 'script':
          // A screen change is for whoever set the rule off; a timer's is for everyone.
          effects.push({ ruleID: rule.id, target: peer, action });
          break;
      }
    }
    return effects;
  }

  /** Splits effects into what goes to everyone and what goes to each player. */
  static payloads(effects: Effect[]): { broadcast: { ruleID?: string; actions: EventAction[] } | null; targeted: Map<string, { ruleID?: string; target: string; actions: EventAction[] }> } {
    const shared = effects.filter((e) => e.target === undefined);
    const targeted = new Map<string, { ruleID?: string; target: string; actions: EventAction[] }>();
    for (const e of effects) {
      if (e.target === undefined) continue;
      const entry = targeted.get(e.target) ?? { ruleID: e.ruleID, target: e.target, actions: [] };
      entry.actions.push(e.action);
      targeted.set(e.target, entry);
    }
    return { broadcast: shared.length ? { ruleID: shared[0].ruleID, actions: shared.map((e) => e.action) } : null, targeted };
  }
}
