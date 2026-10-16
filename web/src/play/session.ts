// The one object the play screen reads for anything that happens in a game:
// Net/SessionCoordinator.swift. It keeps this browser's copy of the world
// (changes from the host applied in place, as they arrive), who is here
// and where (RosterState), what the world's script has given this player
// (ScriptedPlayerState), the chat, the banner, the script's log, and what
// is saved. Effects the 3D view has to act on — a teleport, a sound, a
// shake — wait in `pendingEffects` until the next frame takes them.
import type { AvatarProfile } from '../core/model/avatar';
import { ChatModerator, ChatTidy, MuteList, defaultTidyOptions, maxChatLength, type ChatTidyOptions } from '../core/model/chat';
import { Leaderboard } from '../core/model/effects';
import { LiveWorld, type WorldDelta } from '../core/model/liveWorld';
import type { PlayerInput, PlayerSnapshot, PlayerTransform } from '../core/model/player';
import { RosterState } from '../core/model/roster';
import type { EventAction } from '../core/model/rules';
import { SaveData } from '../core/model/save';
import { ScriptedPlayerState } from '../core/model/scriptedState';
import { prefix, trimmed } from '../core/model/text';
import { emptyWorld, hasScript, spawnPosition, type WorldDocument } from '../core/model/world';
import type { ScriptError } from '../core/script/lexer';
import { L } from '../i18n';
import { RoomClient, type ClientState, type RoomRoute } from '../net/client';
import { pollSecondsLeft, roomState, type HostMove, type RoomState } from '../net/packets';
import { RoomHost, type RoomOptions } from '../net/roomHost';
import { Disconnect, ReconnectCoordinator, RoomCode, reasonMessage, type DisconnectReason } from '../core/model/reliability';
import { v3 } from '../core/model/math';
import { LocalHost, type ChatPayload } from './host';

export type Role = 'offline' | 'hosting' | 'joined';

/** How the connection is, for the screen. */
export type SessionStatus =
  | { kind: 'idle' }
  | { kind: 'connecting' }
  | { kind: 'active' }
  /** Dropped, but trying to get back in: the progress line. */
  | { kind: 'reconnecting'; text: string }
  | { kind: 'error'; text: string };

export interface JoinRequest { id: string; name: string }

export interface ChatEntry {
  id: number;
  senderID: string;
  senderName: string;
  text: string;
  wasFiltered: boolean;
  at: number;
  /** A whisper: the other person's name. */
  privateWith?: string;
}

export interface ScriptLogLine { id: number; text: string; isError: boolean }
export interface Announcement { message: string; expiresAt: number }
export interface LogEntry { at: number; text: string }

/** Who the game's own chat lines come from: fixed, so muting the host never silences the game. */
export const gamePeerID = '00000000-0000-0000-0000-000000000001';

// MARK: - Saves and leaderboards, kept in this browser

/** Which slot's storage id a world plays with: slot 1 is the world's own id (SaveSlots.storageID). */
export function saveStorageID(world: string, slot: number): string {
  if (slot <= 1) return world;
  const hex = world.replace(/-/g, '');
  if (!/^[0-9a-fA-F]{32}$/.test(hex)) return world;
  const bytes = hex.match(/../g)!.map((h) => parseInt(h, 16));
  bytes[15] ^= (slot * 37) & 0xff;
  bytes[14] ^= 0xa5;
  const out = bytes.map((b) => b.toString(16).padStart(2, '0')).join('').toUpperCase();
  return `${out.slice(0, 8)}-${out.slice(8, 12)}-${out.slice(12, 16)}-${out.slice(16, 20)}-${out.slice(20)}`;
}

function storage(): Storage | null {
  try { return typeof localStorage === 'undefined' ? null : localStorage; } catch { return null; }
}

/** What games save for this browser's player (`p.save`), one entry a world and slot. */
export class SaveStore {
  constructor(private prefixKey = 'ablox.save.') {}

  load(id: string): SaveData | null {
    try {
      const text = storage()?.getItem(this.prefixKey + id);
      if (!text) return null;
      const json = JSON.parse(text) as { values?: unknown };
      return SaveData.decode(json.values);
    } catch {
      return null;
    }
  }

  save(data: SaveData, id: string, worldName: string): void {
    storage()?.setItem(this.prefixKey + id, JSON.stringify({ name: prefix(worldName, 60), savedAt: new Date().toISOString(), values: data.toJSON() }));
  }

  /** Every save kept, newest first: for Settings. */
  list(): { id: string; name: string; savedAt: string; bytes: number }[] {
    const store = storage();
    if (!store) return [];
    const out: { id: string; name: string; savedAt: string; bytes: number }[] = [];
    for (let i = 0; i < store.length; i++) {
      const key = store.key(i);
      if (!key?.startsWith(this.prefixKey)) continue;
      const text = store.getItem(key) ?? '';
      try {
        const json = JSON.parse(text) as { name?: string; savedAt?: string };
        out.push({ id: key.slice(this.prefixKey.length), name: json.name ?? '', savedAt: json.savedAt ?? '', bytes: text.length });
      } catch { /* not ours */ }
    }
    return out.sort((a, b) => b.savedAt.localeCompare(a.savedAt));
  }

  remove(id: string): void { storage()?.removeItem(this.prefixKey + id); }
}

export const LeaderboardStore = {
  load(world: string): Map<string, Leaderboard> {
    const boards = new Map<string, Leaderboard>();
    try {
      const json = JSON.parse(storage()?.getItem('ablox.boards.' + world) ?? '{}') as Record<string, unknown>;
      for (const [name, value] of Object.entries(json)) {
        const board = Leaderboard.decode(value);
        if (board) boards.set(name, board);
      }
    } catch { /* none kept */ }
    return boards;
  },
  save(boards: Map<string, Leaderboard>, world: string): void {
    const json: Record<string, unknown> = {};
    for (const [name, board] of boards) json[name] = board.toJSON();
    try { storage()?.setItem('ablox.boards.' + world, JSON.stringify(json)); } catch { /* full */ }
  },
};

// MARK: - The session

export class PlaySession {
  role: Role = 'offline';
  live: LiveWorld = new LiveWorld(emptyWorld('Blank World'));
  roster: PlayerSnapshot[] = [];
  chatLog: ChatEntry[] = [];
  messageLog: LogEntry[] = [];
  scriptLog: ScriptLogLine[] = [];
  announcement: Announcement | null = null;
  scripted = new ScriptedPlayerState();
  isSolo = false;
  isPaused = false;
  /** Effects the 3D view still has to apply; it takes them each frame. */
  pendingEffects: EventAction[] = [];

  saveStore: SaveStore | null = new SaveStore();
  saveSlotFor: (world: string) => number = () => 1;
  moderator = new ChatModerator();
  tidyOptions: ChatTidyOptions = { ...defaultTidyOptions };
  muteList = new MuteList();
  allowsPlayerChat = true;
  /** Family: only these people's lines are kept; null for everyone. */
  chatOnlyFrom: Set<string> | null = null;
  /** Settings → Family: whispers only with full chat. */
  allowsWhispers = true;

  // The room.
  status: SessionStatus = { kind: 'idle' };
  roomState: RoomState = roomState();
  /** When the vote in progress closes, on this browser's clock (milliseconds). */
  pollEndsAt: number | null = null;
  /** Hosting: people at the door, waiting for an answer. */
  joinRequests: JoinRequest[] = [];
  /** Joining: the host asks first, and has not answered yet. */
  isWaitingForHost = false;
  /** The room is moving to someone else (the host left). */
  roomMove: HostMove | null = null;
  roomCode = '';
  /** A room that moved: find where it went (the internet lobby knows). */
  findMovedRoom: (move: HostMove) => Promise<RoomRoute | null> = async () => null;
  /** This browser became a room's host (it opened one, or one moved here): for listing it. */
  onHosting: (room: RoomHost) => void = () => {};

  private host: LocalHost | null = null;
  private roomHost: RoomHost | null = null;
  private client: RoomClient | null = null;
  private reconnection = new ReconnectCoordinator();
  private reconnectTimer: ReturnType<typeof setInterval> | null = null;
  private moveSerial = 0;
  private readonly clockStart = typeof performance !== 'undefined' ? performance.now() : Date.now();
  private rosterState: RosterState;
  private nextID = 1;
  private listeners = new Set<() => void>();
  private announcementTimer: ReturnType<typeof setTimeout> | null = null;
  private notifyQueued = false;

  constructor(readonly localPeerID: string, public profile: AvatarProfile) {
    this.rosterState = new RosterState(localPeerID);
  }

  get world(): WorldDocument { return this.live.world; }

  // MARK: Being told

  /** Called (once a frame at most) after anything the screen shows has changed. */
  subscribe(listener: () => void): () => void {
    this.listeners.add(listener);
    return () => this.listeners.delete(listener);
  }

  private changed(): void {
    if (this.notifyQueued) return;
    this.notifyQueued = true;
    const run = () => {
      this.notifyQueued = false;
      for (const l of this.listeners) l();
    };
    if (typeof requestAnimationFrame === 'function') requestAnimationFrame(run); else queueMicrotask(run);
  }

  // MARK: Playing alone

  /** A round with nobody else in it, through the same host a room uses: rules and scripts behave exactly the same. */
  startSolo(world: WorldDocument): void {
    this.leave();
    this.beginHosting(world);
    this.isSolo = true;
    this.changed();
  }

  private beginHosting(world: WorldDocument): void {
    this.enter(world);
    this.status = { kind: 'active' };
    const host = new LocalHost(world, this.localPeerID, this.profile);
    host.onRoster = (roster) => this.replaceRoster(roster);
    host.onRemoteTransform = (t) => this.receiveTransform(t);
    host.onChat = (sender, payload) => this.appendChat(payload, sender);
    host.onLocalEffects = (actions) => this.apply(actions);
    host.onDiagnostics = (errors, output) => this.appendScriptLog(errors, output);
    host.onDelta = (delta) => this.receiveDelta(delta);
    const worldID = world.id;
    host.loadLeaderboards(LeaderboardStore.load(worldID));
    host.onLeaderboards = (boards) => LeaderboardStore.save(boards, worldID);
    this.host = host;
    this.role = 'hosting';
    host.start();
    host.startRound();
    // The host plays too: its saved data goes in the way a guest's does, straight after the round reads it.
    const saved = this.savedData(world);
    if (saved) host.reportInput({ kind: 'saved', data: saved });
  }

  /** A new round of the same game, for everyone. */
  startNewRound(): void {
    this.host?.startRound();
    this.roomHost?.clearReady();
  }

  // MARK: Rooms

  get room(): RoomHost | null { return this.roomHost; }
  /** Round trip to the host, while joined. */
  get pingMilliseconds(): number | null { return this.role === 'joined' ? this.client?.pingMilliseconds ?? null : null; }
  get isInRoom(): boolean { return this.roomHost !== null || this.role === 'joined'; }

  /** Opens the game being played alone to others, as it is: nobody's progress restarts. */
  openRoom(options: Omit<RoomOptions, 'worldName' | 'hostName'> = {}): RoomHost | null {
    if (this.role !== 'hosting' || !this.host) return null;
    if (this.roomHost) return this.roomHost;
    this.host.setPaused(false);
    this.isPaused = false;
    this.isSolo = false;
    const roomHost = new RoomHost(this.host, { worldName: this.world.name, hostName: this.profile.displayName, ...options });
    roomHost.onJoinRequest = (id, name) => {
      if (!this.joinRequests.some((r) => r.id === id)) this.joinRequests = [...this.joinRequests, { id, name }];
      this.changed();
    };
    roomHost.onJoinRequestEnded = (id) => { this.joinRequests = this.joinRequests.filter((r) => r.id !== id); this.changed(); };
    roomHost.onRoomState = (state) => this.receiveRoomState(state);
    roomHost.onWhisper = (from, name, text) => this.receiveWhisper(from, name, text);
    this.roomHost = roomHost;
    this.roomCode = roomHost.roomCode;
    this.roomState = roomHost.room;
    this.status = { kind: 'active' };
    this.onHosting(roomHost);
    this.changed();
    return roomHost;
  }

  /** Hosts `world` for others from the start. */
  hostRoom(world: WorldDocument, options: Omit<RoomOptions, 'worldName' | 'hostName'> = {}): RoomHost {
    this.leave();
    this.beginHosting(world);
    return this.openRoom(options)!;
  }

  /** Joins someone else's room. */
  joinRoom(route: RoomRoute): void {
    this.leave();
    this.roomMove = null;
    this.roomCode = RoomCode.normalize(route.code);
    this.makeClient().connect(route);
  }

  private makeClient(): RoomClient {
    this.reconnection = new ReconnectCoordinator();
    this.status = { kind: 'connecting' };
    const client = new RoomClient(this.localPeerID, this.profile);
    client.onStateChange = (state) => { if (this.client === client) this.clientState(state); };
    client.onWorld = (world) => {
      if (this.client !== client) return;
      // A fresh world means a fresh welcome from the host's script: whatever the last one put on screen goes first.
      this.scripted = new ScriptedPlayerState();
      this.enter(world);
      // Now that we know which game this is, hand the host what this browser has saved in it.
      const saved = this.savedData(world);
      if (saved) client.sendInput({ kind: 'saved', data: saved });
      this.changed();
    };
    client.onDelta = (delta) => { if (this.client === client) this.receiveDelta(delta); };
    client.onRoster = (roster) => { if (this.client === client) this.replaceRoster(roster); };
    client.onTransform = (t) => { if (this.client === client) this.receiveTransform(t); };
    client.onEffects = (payload) => { if (this.client === client) this.apply(payload.actions); };
    client.onChat = (sender, payload) => { if (this.client === client) this.appendChat(payload, sender); };
    client.onRoom = (message) => {
      if (this.client !== client) return;
      if (message.type === 'state') this.receiveRoomState(message.state);
      else if (message.type === 'whispered') this.receiveWhisper(message.from, message.name, message.text);
      else if (message.type === 'waitingForHost') { this.isWaitingForHost = true; this.changed(); }
    };
    client.onHostMove = (move) => { if (this.client === client) void this.follow(move); };
    this.client = client;
    return client;
  }

  private clientState(state: ClientState): void {
    switch (state.kind) {
      case 'playing':
        this.status = { kind: 'active' };
        this.role = 'joined';
        this.isWaitingForHost = false;
        // Back in: a later drop starts from the first attempt again.
        this.reconnection.succeeded();
        this.stopReconnecting();
        break;
      case 'disconnected': this.handleDisconnect(state.reason); break;
      case 'connecting': case 'handshaking':
        if (this.status.kind !== 'reconnecting') this.status = { kind: 'connecting' };
        break;
      default: break;
    }
    this.changed();
  }

  private get now(): number {
    return ((typeof performance !== 'undefined' ? performance.now() : Date.now()) - this.clockStart) / 1000;
  }

  /** A drop: either start trying to get back in, or say what happened. */
  private handleDisconnect(reason: DisconnectReason): void {
    if (this.role !== 'joined') {
      this.status = { kind: 'error', text: reasonMessage(reason) };
      this.role = 'offline';
      this.client = null;
      return;
    }
    // A failed attempt arrives here as another drop: counted as one, or the backoff would never grow.
    const outcome = this.reconnection.isReconnecting
      ? this.reconnection.attemptFailed(this.now)
      : this.reconnection.disconnected(reason, this.now);
    if (outcome.kind === 'gaveUp') {
      this.status = { kind: 'error', text: reasonMessage(outcome.reason) };
      this.role = 'offline';
      this.stopReconnecting();
    } else if (outcome.kind === 'waiting' || outcome.kind === 'attempting') {
      // The world and everyone stay on screen: coming back to where you were beats starting again.
      this.status = { kind: 'reconnecting', text: this.reconnection.progressDescription ?? L('Reconnecting…') };
      this.startReconnecting();
    }
  }

  private startReconnecting(): void {
    if (this.reconnectTimer) return;
    this.reconnectTimer = setInterval(() => {
      if (!this.reconnection.isReconnecting) { this.stopReconnecting(); return; }
      if (!this.reconnection.shouldAttemptNow(this.now)) return;
      this.status = { kind: 'reconnecting', text: this.reconnection.progressDescription ?? L('Reconnecting…') };
      if (!this.client?.reconnect()) {
        // Nothing to go back to.
        this.reconnection.cancel();
        this.status = { kind: 'error', text: reasonMessage(Disconnect.hostClosed) };
        this.role = 'offline';
        this.stopReconnecting();
      }
      this.changed();
    }, 200);
  }

  private stopReconnecting(): void {
    if (this.reconnectTimer) clearInterval(this.reconnectTimer);
    this.reconnectTimer = null;
  }

  /** The tab is back: its network probably is too, so waiting out the backoff is only delay. */
  becameVisible(): void {
    if (this.reconnection.isReconnecting) this.reconnection.retryImmediately(this.now);
  }

  /** Leaves, handing the room to whoever has been here longest. False when there is nobody to hand it to. */
  handOverAndLeave(): boolean {
    const room = this.roomHost;
    if (this.role !== 'hosting' || !room) return false;
    const next = this.people.find((p) => p.peerID !== this.localPeerID);
    if (!next) return false;
    room.handOver({
      newHost: next.peerID, newHostName: next.profile.displayName, roomCode: this.roomCode, isPublic: true,
      capacity: room.capacity, needsApproval: this.roomState.needsApproval, members: this.people.map((p) => p.peerID),
    });
    // The room closes itself once the news has gone out.
    this.roomHost = null;
    this.leave();
    return true;
  }

  get canHandOver(): boolean {
    return this.role === 'hosting' && this.roomHost !== null && this.people.some((p) => p.peerID !== this.localPeerID);
  }

  /** The room is moving: open it here, or go and find it. */
  private async follow(move: HostMove): Promise<void> {
    const serial = ++this.moveSerial;
    this.roomMove = move;
    const world = this.world;
    const old = this.client;
    this.client = null;
    old?.disconnect();
    this.stopReconnecting();
    if (move.newHost === this.localPeerID) {
      // This browser is the new host: the same world, as it is now, under the same code; everyone who was in it comes straight in.
      this.rosterState.reset();
      this.roster = [];
      this.beginHosting(world);
      this.openRoom({ roomCode: move.roomCode, capacity: move.capacity, needsApproval: move.needsApproval, alreadyApproved: move.members });
      this.roomMove = null;
      this.show(L('You are the host now.'), 4);
      this.changed();
      return;
    }
    this.status = { kind: 'reconnecting', text: L("Moving to {}'s iPad…", move.newHostName) };
    this.changed();
    const deadline = Date.now() + 25_000;
    while (serial === this.moveSerial && Date.now() < deadline) {
      const route = await this.findMovedRoom(move).catch(() => null);
      if (serial !== this.moveSerial) return;
      if (route) {
        this.roomMove = null;
        this.roomCode = RoomCode.normalize(route.code);
        // Kept on screen while the new host's world comes.
        this.makeClient().connect(route);
        return;
      }
      await new Promise((r) => setTimeout(r, 1500));
    }
    if (serial !== this.moveSerial) return;
    this.roomMove = null;
    this.status = { kind: 'error', text: L("Couldn't find the room on {}'s iPad.", move.newHostName) };
    this.role = 'offline';
    this.changed();
  }

  // MARK: The room's own messages

  private receiveRoomState(state: RoomState): void {
    const isNewPoll = state.poll?.id !== this.roomState.poll?.id || (state.poll?.isClosed === false && this.pollEndsAt === null);
    this.roomState = state;
    const left = pollSecondsLeft(state);
    if (left === null) this.pollEndsAt = null;
    else if (isNewPoll) this.pollEndsAt = Date.now() + left * 1000;
    this.changed();
  }

  private receiveWhisper(from: string, name: string, text: string): void {
    if (!this.allowsPlayerChat || !this.allowsWhispers || !this.muteList.allows(from, this.localPeerID)) return;
    if (this.chatOnlyFrom && !this.chatOnlyFrom.has(from)) return;
    const filtered = this.moderator.filter(text);
    this.chatLog.push({ id: this.nextID++, senderID: from, senderName: name, text: ChatTidy.tidy(filtered.text, this.tidyOptions), wasFiltered: filtered.wasFiltered, at: Date.now(), privateWith: name });
    if (this.chatLog.length > 100) this.chatLog.splice(0, this.chatLog.length - 100);
    this.changed();
  }

  get isQuietedByHost(): boolean { return this.roomState.quieted.has(this.localPeerID); }
  get isReady(): boolean { return this.roomState.ready.has(this.localPeerID); }

  /** Says something to one player only. */
  whisper(target: string, text: string): void {
    const line = prefix(trimmed(text), maxChatLength);
    if (!line || !this.allowsPlayerChat || !this.allowsWhispers || this.isQuietedByHost || target === this.localPeerID) return;
    if (this.role === 'hosting') this.roomHost?.whisper(target, line);
    else if (this.role === 'joined') this.client?.sendRoom({ type: 'whisper', to: target, text: line });
    else return;
    const name = this.roster.find((p) => p.peerID === target)?.profile.displayName ?? '';
    this.chatLog.push({ id: this.nextID++, senderID: this.localPeerID, senderName: this.profile.displayName, text: line, wasFiltered: false, at: Date.now(), privateWith: name });
    this.changed();
  }

  setReady(ready: boolean): void {
    if (this.role === 'hosting') this.roomHost?.setReady(ready);
    else if (this.role === 'joined') this.client?.sendRoom({ type: 'ready', flag: ready });
  }

  vote(choice: number): void {
    const poll = this.roomState.poll;
    if (!poll || poll.isClosed) return;
    if (this.role === 'hosting') this.roomHost?.vote(poll.id, choice);
    else if (this.role === 'joined') this.client?.sendRoom({ type: 'vote', poll: poll.id, choice });
  }

  /** Stands next to another player — a friend, usually — when the host allows it. */
  warp(target: string): void {
    if (!(this.role === 'hosting' || this.roomState.allowsWarp)) return;
    const player = this.rosterState.players.find((p) => p.peerID === target);
    if (!player) return;
    const yaw = (player.yawDegrees * Math.PI) / 180;
    const p = player.position;
    this.pendingEffects.push({ type: 'teleportPlayer', position: v3(p.x + Math.sin(yaw) * 1.6, p.y + 0.5, p.z + Math.cos(yaw) * 1.6) });
    this.changed();
  }

  answerJoinRequest(request: JoinRequest, allow: boolean): void {
    this.joinRequests = this.joinRequests.filter((r) => r.id !== request.id);
    this.roomHost?.answerJoinRequest(request.id, allow);
    this.changed();
  }

  removeFromRoom(peer: string): void { this.roomHost?.remove(peer); }
  setQuieted(peer: string, quiet: boolean): void { this.roomHost?.setQuieted(peer, quiet); }
  setNeedsApproval(ask: boolean): void { this.roomHost?.setNeedsApproval(ask); }
  setAllowsWarp(allow: boolean): void { this.roomHost?.setAllowsWarp(allow); }
  startPoll(question: string, options: string[]): boolean { return this.roomHost?.startPoll(question, options) ?? false; }
  endPoll(): void { this.roomHost?.endPoll(); }
  clearPoll(): void { this.roomHost?.clearPoll(); }

  leave(): void {
    this.moveSerial++;
    this.stopReconnecting();
    this.reconnection.cancel();
    this.roomHost?.stop();
    this.roomHost = null;
    // Let go first, so its goodbye is not taken for a drop.
    const client = this.client;
    this.client = null;
    client?.disconnect();
    this.status = { kind: 'idle' };
    this.roomState = roomState();
    this.pollEndsAt = null;
    this.joinRequests = [];
    this.isWaitingForHost = false;
    this.host?.stop();
    this.host = null;
    this.role = 'offline';
    this.rosterState.reset();
    this.roster = [];
    this.pendingEffects = [];
    this.scripted = new ScriptedPlayerState();
    this.scriptLog = [];
    this.chatLog = [];
    this.messageLog = [];
    this.isSolo = false;
    this.isPaused = false;
    if (this.announcementTimer) clearTimeout(this.announcementTimer);
    this.announcement = null;
    this.changed();
  }

  setPaused(paused: boolean): void {
    // Only a game with nobody else in it: pausing everyone's game from one screen would be a trick.
    if (!this.isSolo || this.role !== 'hosting' || this.roomHost) return;
    this.isPaused = paused;
    this.host?.setPaused(paused);
    this.changed();
  }

  get localHost(): LocalHost | null { return this.host; }

  // MARK: What this player does

  /** Our movement, at the rate the transform publisher decides. */
  publishLocalTransform(snapshot: PlayerSnapshot): void {
    if (this.role === 'hosting') this.host?.publishLocalTransform(snapshot);
    else if (this.role === 'joined') this.client?.publishLocalTransform(snapshot);
  }

  /** We touched or tapped a block. The host decides what that means. */
  report(blockID: string, cause: 'touched' | 'tapped' | 'proximityEntered'): void {
    if (this.role === 'hosting') this.host?.reportObservation({ kind: cause, peer: this.localPeerID, blockID });
    else if (this.role === 'joined') this.client?.report(blockID, cause);
  }

  send(input: PlayerInput): void {
    if (this.role === 'hosting') this.host?.reportInput(input);
    else if (this.role === 'joined') this.client?.sendInput(input);
  }

  sendChat(text: string): void {
    const line = prefix(trimmed(text), maxChatLength);
    if (!line || !this.allowsPlayerChat || this.isQuietedByHost) return;
    if (this.role === 'hosting') this.host?.sendChat(line);
    else if (this.role === 'joined') {
      this.client?.sendChat(line);
      // The host passes a line to everyone but its sender, so our own line (and its bubble) is added here.
      this.appendChat({ senderName: this.profile.displayName, text: line }, this.localPeerID);
    } else this.appendChat({ senderName: this.profile.displayName, text: line }, this.localPeerID);
  }

  updateProfile(profile: AvatarProfile): void {
    this.profile = profile;
    this.host?.updateLocalProfile(profile);
    this.client?.updateProfile(profile);
  }

  clearScriptLog(): void { this.scriptLog = []; this.changed(); }
  clearChat(): void { this.chatLog = []; this.changed(); }

  get visibleChatLog(): ChatEntry[] { return this.chatLog.filter((c) => this.muteList.allows(c.senderID, this.localPeerID)); }

  // MARK: Effects

  private apply(actions: EventAction[]): void {
    for (const action of actions) {
      switch (action.type) {
        case 'announce': this.show(action.message, action.duration); break;
        case 'setVisible': this.live.mutate(action.blockID, (b) => { b.isVisible = action.visible; }); break;
        case 'setCollision': this.live.mutate(action.blockID, (b) => { b.hasCollision = action.enabled; }); break;
        case 'endRound': this.show(action.message, 5); break;
        case 'script': {
          const e = action.effect;
          if (e.kind === 'chat') {
            this.appendChat({ senderName: L('Game'), text: e.text }, gamePeerID);
            this.remember(e.text);
          } else if (e.kind === 'say') {
            this.appendChat({ senderName: e.name, text: e.text }, e.speaker);
          } else if (e.kind === 'store') {
            this.keep(e.data);
          } else {
            this.scripted.apply(e);
          }
          break;
        }
        default: break;
      }
    }
    this.pendingEffects.push(...actions);
    this.changed();
  }

  drainEffects(): EventAction[] {
    if (!this.pendingEffects.length) return [];
    const out = this.pendingEffects;
    this.pendingEffects = [];
    return out;
  }

  // MARK: The world and who is in it

  /** Makes `world` the one being played. A different world also puts us at its spawn point first. */
  private enter(world: WorldDocument): void {
    const isDifferent = world.id !== this.live.world.id;
    this.live = new LiveWorld(structuredClone(world));
    this.scripted = new ScriptedPlayerState();
    if (isDifferent) this.pendingEffects.push({ type: 'teleportPlayer', position: spawnPosition(this.live.world, 0, this.live.find) });
  }

  private receiveDelta(delta: WorldDelta): void {
    this.live.apply(delta);
    this.changed();
  }

  private receiveTransform(t: PlayerTransform): void {
    this.rosterState.apply(t);
  }

  /** Everyone as they are this moment. */
  get livePlayers(): PlayerSnapshot[] { return this.rosterState.players; }
  get localPlayer(): PlayerSnapshot | undefined { return this.rosterState.localPlayer; }
  get otherPlayers(): PlayerSnapshot[] { return this.rosterState.otherPlayers; }
  get people(): PlayerSnapshot[] { return this.roster.filter((p) => !p.isNPC); }
  /** How we look: as the host last said (a script can recolour or resize us), or as set up here. */
  get localAppearance(): AvatarProfile { return this.localPlayer?.profile ?? this.profile; }

  private replaceRoster(incoming: PlayerSnapshot[]): void {
    for (const event of this.rosterState.replace(incoming)) {
      if (event.kind === 'placeLocalPlayer') this.pendingEffects.push({ type: 'teleportPlayer', position: event.position });
    }
    this.roster = this.rosterState.players.map((p) => ({ ...p }));
    this.changed();
  }

  // MARK: Words

  private show(message: string, duration: number): void {
    this.remember(L(message));
    if (this.announcementTimer) clearTimeout(this.announcementTimer);
    const seconds = Number.isFinite(duration) ? Math.max(0.5, Math.min(duration, 60)) : 3;
    this.announcement = { message, expiresAt: Date.now() + seconds * 1000 };
    this.announcementTimer = setTimeout(() => {
      this.announcement = null;
      this.changed();
    }, seconds * 1000);
  }

  private remember(text: string): void {
    const t = trimmed(text);
    if (!t) return;
    this.messageLog.push({ at: Date.now(), text: t });
    if (this.messageLog.length > 50) this.messageLog.splice(0, this.messageLog.length - 50);
  }

  private appendScriptLog(errors: ScriptError[], output: string[]): void {
    for (const text of output) this.scriptLog.push({ id: this.nextID++, text, isError: false });
    for (const e of errors) this.scriptLog.push({ id: this.nextID++, text: e.description, isError: true });
    if (this.scriptLog.length > 50) this.scriptLog.splice(0, this.scriptLog.length - 50);
    this.changed();
  }

  private appendChat(payload: ChatPayload, sender: string): void {
    const isPerson = sender !== gamePeerID && !this.roster.find((p) => p.peerID === sender)?.isNPC;
    if (!this.allowsPlayerChat && isPerson) return;
    if (isPerson && sender !== this.localPeerID && this.chatOnlyFrom && !this.chatOnlyFrom.has(sender)) return;
    const filtered = this.moderator.filter(payload.text);
    // The game's own lines are left as the game wrote them.
    const text = sender === gamePeerID ? filtered.text : ChatTidy.tidy(filtered.text, this.tidyOptions);
    this.chatLog.push({ id: this.nextID++, senderID: sender, senderName: payload.senderName, text, wasFiltered: filtered.wasFiltered, at: Date.now() });
    if (this.chatLog.length > 100) this.chatLog.splice(0, this.chatLog.length - 100);
    this.changed();
  }

  // MARK: Saved game data

  private saveID(world: WorldDocument): string { return saveStorageID(world.id, this.saveSlotFor(world.id)); }

  private savedData(world: WorldDocument): SaveData | null {
    if (!this.saveStore || !hasScript(world)) return null;
    return this.saveStore.load(this.saveID(world)) ?? new SaveData();
  }

  /** What the host's script saved, written at once (it is small, and at most once a second). */
  private keep(data: SaveData): void {
    const world = this.live.world;
    if (!this.saveStore || !hasScript(world)) return;
    try {
      const slot = this.saveSlotFor(world.id);
      this.saveStore.save(data, this.saveID(world), slot > 1 ? L('{} (slot {})', world.name, slot) : world.name);
    } catch (e) {
      this.scriptLog.push({ id: this.nextID++, text: L("Could not save this game's progress: {}", String(e)), isError: true });
    }
  }
}
