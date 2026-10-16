// The game's referee in the browser: Net/AbloxHost.swift without the
// listener. It owns the GameRuntime — rules, scores, the world's script —
// ticks it ten times a second, and routes what comes out exactly as the
// iPad's host does: script problems first, then the world's changes and the
// roster, then the effects (ours to our own screen), then the NPCs' moves.
// Playing alone is this host with nobody else in it, so a game behaves the
// same alone as with friends. The room's network side plugs in through
// `HostLink` (net/, later), which hears everything that would go to others.
import type { AvatarProfile } from '../core/model/avatar';
import { sanitizedProfile } from '../core/model/avatar';
import { ChatModerator, maxChatLength } from '../core/model/chat';
import type { Leaderboard } from '../core/model/effects';
import type { WorldDelta } from '../core/model/liveWorld';
import { playerSnapshot, type PlayerInput, type PlayerSnapshot, type PlayerTransform } from '../core/model/player';
import type { EventAction } from '../core/model/rules';
import { prefix, trimmed } from '../core/model/text';
import type { WorldDocument } from '../core/model/world';
import { EventMachine, type Effect, type Observation } from '../core/runtime/eventMachine';
import { GameRuntime } from '../core/runtime/gameRuntime';
import type { ScriptError } from '../core/script/lexer';

export interface ChatPayload { senderName: string; text: string; senderID?: string }

/** What the room's network side is told: everything that goes to the other players. */
export interface HostLink {
  broadcastEffects(payload: { ruleID?: string; actions: EventAction[] }): void;
  sendEffects(peer: string, payload: { ruleID?: string; target: string; actions: EventAction[] }): void;
  broadcastDelta(delta: WorldDelta): void;
  broadcastRoster(roster: PlayerSnapshot[]): void;
  broadcastTransform(transform: PlayerTransform): void;
  broadcastChat(payload: ChatPayload, except?: string): void;
}

/** Swift structs are copied as they are passed; plain data is cloned here so nothing is shared by accident. */
function detached(action: EventAction): EventAction {
  if (action.type === 'script' && action.effect.kind === 'store') return action;
  return structuredClone(action);
}

export class LocalHost {
  readonly game: GameRuntime;
  /** How the host's own player looks. */
  profile: AvatarProfile;
  private timer: ReturnType<typeof setInterval> | null = null;
  private startedAt = performance.now();
  private pausedAt: number | null = null;
  private pausedTotal = 0;
  link: HostLink | null = null;

  onRoster: (roster: PlayerSnapshot[]) => void = () => {};
  onRemoteTransform: (t: PlayerTransform) => void = () => {};
  onLocalEffects: (actions: EventAction[]) => void = () => {};
  onChat: (sender: string, payload: ChatPayload) => void = () => {};
  onDelta: (delta: WorldDelta) => void = () => {};
  onDiagnostics: (errors: ScriptError[], output: string[]) => void = () => {};
  onLeaderboards: (boards: Map<string, Leaderboard>) => void = () => {};

  constructor(world: WorldDocument, readonly localPeerID: string, profile: AvatarProfile) {
    this.profile = profile;
    const seed = crypto.getRandomValues(new BigUint64Array(1))[0] || 1n;
    this.game = new GameRuntime(world, 0, seed);
    this.game.addPlayer(playerSnapshot(localPeerID, { profile }));
  }

  // MARK: Life

  start(): void {
    if (this.timer) return;
    this.timer = setInterval(() => this.tick(), 100);
    // Who is here from the first moment: the screen's score and our place come from it.
    this.publishRoster();
  }

  stop(): void {
    if (this.timer) clearInterval(this.timer);
    this.timer = null;
  }

  /** Seconds since the host started, less time spent paused: the one clock rules, scripts and shots use. */
  get elapsed(): number {
    const now = this.pausedAt ?? performance.now();
    return (now - this.startedAt - this.pausedTotal) / 1000;
  }

  get isPaused(): boolean { return this.pausedAt !== null; }

  /** Stops or restarts the game's clock. Only for a game with nobody else in it. */
  setPaused(paused: boolean): void {
    if (paused && this.pausedAt === null) {
      this.pausedAt = performance.now();
    } else if (!paused && this.pausedAt !== null) {
      this.pausedTotal += performance.now() - this.pausedAt;
      this.pausedAt = null;
    }
  }

  private tick(): void {
    if (this.pausedAt !== null) return;
    this.dispatch(this.game.advance(this.elapsed));
  }

  // MARK: The local player

  startRound(): void { this.dispatch(this.game.handle({ kind: 'roundStarted' })); }

  publishLocalTransform(s: PlayerSnapshot): void {
    const t: PlayerTransform = { peerID: this.localPeerID, position: { ...s.position }, yawDegrees: s.yawDegrees, velocity: { ...s.velocity }, isGrounded: s.isGrounded };
    this.game.updateTransform(t);
    this.link?.broadcastTransform(t);
  }

  reportObservation(observation: Observation): void { this.dispatch(this.game.handle(observation)); }

  /** Our own fire button and screen buttons, checked by the same rules as everyone else's. */
  reportInput(input: PlayerInput): void { this.dispatch(this.game.handleInput(input, this.localPeerID, this.elapsed)); }

  sendChat(text: string): void {
    const payload: ChatPayload = { senderName: this.profile.displayName, text, senderID: this.localPeerID };
    this.link?.broadcastChat(payload);
    this.onChat(this.localPeerID, payload);
    this.dispatch(this.game.handleChat(this.localPeerID, text));
  }

  updateLocalProfile(profile: AvatarProfile): void {
    this.profile = profile;
    this.dispatch(this.game.addPlayer(playerSnapshot(this.localPeerID, { profile })));
    this.publishRoster();
  }

  loadLeaderboards(boards: Map<string, Leaderboard>): void { this.game.loadLeaderboards(boards); }

  assignTeams(teams: Map<string, string>): void {
    this.game.assignTeams(teams);
    this.dispatch([]);
  }

  // MARK: Other players (for the network side)

  /**
   * Someone came in: added to the game, with the world as they should see
   * it (blocks on their way somewhere, where they have got to). The network
   * side sends that world, then `announceRoster`, then `welcome` with the
   * script's greeting — in that order, as the iPad's host does, because a
   * guest throws effects away until it has a world to apply them to.
   */
  admit(peer: string, rawProfile: AvatarProfile): { world: WorldDocument; welcome: Effect[] } {
    const profile = sanitizedProfile(rawProfile, ChatModerator.cleanName);
    const travelling = new Map(this.game.travels);
    const welcome = this.game.addPlayer(playerSnapshot(peer, { profile }));
    const joining = this.game.joiningWorld(peer, travelling);
    return { world: joining.world, welcome: [...welcome, ...joining.effects] };
  }

  announceRoster(): void { this.publishRoster(); }

  welcome(effects: Effect[]): void { this.dispatch(effects); }

  /** A guest already playing sent a new look. */
  updateRemoteProfile(peer: string, rawProfile: AvatarProfile): void {
    const profile = sanitizedProfile(rawProfile, ChatModerator.cleanName);
    this.dispatch(this.game.addPlayer(playerSnapshot(peer, { profile })));
    this.publishRoster();
  }

  /** Nobody else is in the game: only then may the clock stop. */
  get hasGuests(): boolean { return this.game.roster.some((p) => !p.isNPC && p.peerID !== this.localPeerID); }

  remoteLeft(peer: string): void {
    const farewell = this.game.removePlayer(peer);
    this.publishRoster();
    this.dispatch(farewell);
  }

  remoteTransform(t: PlayerTransform): void {
    this.game.updateTransform(t);
    this.onRemoteTransform(t);
  }

  remoteObservation(observation: Observation): void { this.dispatch(this.game.handle(observation)); }
  remoteInput(peer: string, input: PlayerInput): void { this.dispatch(this.game.handleInput(input, peer, this.elapsed)); }

  /** A guest's line, under the name the host knows them by — never their own claim. */
  remoteChat(peer: string, payload: ChatPayload): void {
    const text = prefix(trimmed(payload.text), maxChatLength);
    if (!text) return;
    const name = this.game.players.get(peer)?.profile.displayName ?? payload.senderName;
    const verified: ChatPayload = { senderName: name, text, senderID: peer };
    this.link?.broadcastChat(verified, peer);
    this.onChat(peer, verified);
    this.dispatch(this.game.handleChat(peer, text));
  }

  get roster(): PlayerSnapshot[] { return this.game.roster; }

  // MARK: Routing

  private publishRoster(): void {
    const roster = this.game.roster;
    this.link?.broadcastRoster(roster);
    this.onRoster(roster);
  }

  private dispatch(effects: Effect[]): void {
    this.reportDiagnostics();
    // The map and the roster first: an effect may be about a block the
    // script has only just made, or an NPC that only just appeared.
    this.sendWorldChanges();
    try {
      if (!effects.length) return;
      if (this.link) {
        const { broadcast, targeted } = EventMachine.payloads(effects);
        if (broadcast) this.link.broadcastEffects(broadcast);
        for (const [peer, payload] of targeted) if (peer !== this.localPeerID) this.link.sendEffects(peer, payload);
      }
      const local = effects.filter((e) => e.target === undefined || e.target === this.localPeerID).map((e) => detached(e.action));
      if (local.length) this.onLocalEffects(local);
      if (effects.some((e) => e.action.type === 'awardPoints')) this.publishRoster();
    } finally {
      for (const t of this.game.drainNPCTransforms()) {
        this.link?.broadcastTransform(t);
        this.onRemoteTransform(t);
      }
    }
  }

  private sendWorldChanges(): void {
    for (const delta of this.game.drainWorldDeltas()) {
      this.link?.broadcastDelta(delta);
      this.onDelta(structuredClone(delta));
    }
    if (this.game.takeRosterChange()) this.publishRoster();
    const boards = this.game.takeLeaderboardsIfChanged();
    if (boards) this.onLeaderboards(boards);
  }

  private reportDiagnostics(): void {
    const errors = this.game.drainErrors();
    const output = this.game.drainOutput();
    if (errors.length || output.length) this.onDiagnostics(errors, output);
  }
}
