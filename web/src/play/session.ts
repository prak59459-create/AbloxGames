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
import { LocalHost, type ChatPayload } from './host';

export type Role = 'offline' | 'hosting' | 'joined';

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

  private host: LocalHost | null = null;
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

  /** A new round of the same game. */
  startNewRound(): void {
    this.host?.startRound();
  }

  leave(): void {
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
    if (!this.isSolo || this.role !== 'hosting') return;
    this.isPaused = paused;
    this.host?.setPaused(paused);
    this.changed();
  }

  get localHost(): LocalHost | null { return this.host; }

  // MARK: What this player does

  /** Our movement, at the rate the transform publisher decides. */
  publishLocalTransform(snapshot: PlayerSnapshot): void {
    if (this.role === 'hosting') this.host?.publishLocalTransform(snapshot);
  }

  /** We touched or tapped a block. The host decides what that means. */
  report(blockID: string, cause: 'touched' | 'tapped' | 'proximityEntered'): void {
    if (this.role === 'hosting') this.host?.reportObservation({ kind: cause, peer: this.localPeerID, blockID });
  }

  send(input: PlayerInput): void {
    if (this.role === 'hosting') this.host?.reportInput(input);
  }

  sendChat(text: string): void {
    const line = prefix(trimmed(text), maxChatLength);
    if (!line || !this.allowsPlayerChat) return;
    if (this.role === 'hosting') this.host?.sendChat(line);
    else this.appendChat({ senderName: this.profile.displayName, text: line }, this.localPeerID);
  }

  updateProfile(profile: AvatarProfile): void {
    this.profile = profile;
    this.host?.updateLocalProfile(profile);
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
