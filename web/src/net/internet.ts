// Internet rooms in the browser: the parts of Net/CloudService.swift a
// browser needs — signing in, the list of rooms, putting a room this
// browser hosts in that list (and through the relay), and the way into a
// room someone else hosts. Off unless a grown-up has allowed internet play
// on this browser; nothing is sent before then, not even a sign-in.
import { sanitizedProfile, type AvatarProfile } from '../core/model/avatar';
import { ChatModerator } from '../core/model/chat';
import {
  CloudIDs, CloudPath, CloudSettings, decodeCloudRoom, encodeCloudRoom, jsonObject, makeCloudRoom, roomIsFresh, serverTime, type CloudRoom, type Json,
} from '../core/model/cloud';
import type { WorldDocument } from '../core/model/world';
import { L } from '../i18n';
import type { RoomRoute } from './client';
import { CloudAuth, CloudDatabase, CloudError } from './cloud';
import type { HostMove } from './packets';
import { RelayHost, openGuestLink } from './relay';
import type { RoomHost } from './roomHost';

export type InternetState = { kind: 'off' } | { kind: 'connecting' } | { kind: 'ready' } | { kind: 'failed'; message: string };

type Fetcher = (input: string, init?: RequestInit) => Promise<Response>;

function browserStorage(): Storage | null {
  try { return typeof localStorage === 'undefined' ? null : localStorage; } catch { return null; }
}

const settingsKey = 'ablox.cloud.settings';

/** What a grown-up allowed on this browser. */
export function loadCloudSettings(storage: Storage | null = browserStorage()): CloudSettings {
  try { return CloudSettings.decode(JSON.parse(storage?.getItem(settingsKey) ?? '{}')); } catch { return new CloudSettings(); }
}

export function saveCloudSettings(settings: CloudSettings, storage: Storage | null = browserStorage()): void {
  try { storage?.setItem(settingsKey, JSON.stringify(settings.toJSON())); } catch { /* private mode */ }
}

interface Hosted {
  key: string;
  room: RoomHost;
  relay: RelayHost;
  timer: ReturnType<typeof setInterval>;
  refreshSoon: ReturnType<typeof setTimeout> | null;
  entry: () => Json;
}

export class InternetRooms {
  state: InternetState = { kind: 'off' };
  uid: string | null = null;
  /** The rooms open now, newest first. */
  rooms: CloudRoom[] = [];
  /** Someone who has been blocked: their rooms are not shown. */
  blocked = new Set<string>();
  private listeners = new Set<() => void>();

  private settings: CloudSettings;
  private database: CloudDatabase | null = null;
  private hosted: Hosted | null = null;
  private starting: Promise<void> | null = null;
  private readonly leaving = () => this.closeWhileLeaving();

  constructor(settings: CloudSettings = loadCloudSettings(), private readonly storage: Storage | null = browserStorage(), private readonly fetcher?: Fetcher) {
    this.settings = settings;
    try { for (const id of JSON.parse(storage?.getItem('ablox.cloud.blocked') ?? '[]') as string[]) this.blocked.add(id); } catch { /* none */ }
  }

  /** Told whenever the state, the list or the hosted room changes. */
  subscribe(listener: () => void): () => void {
    this.listeners.add(listener);
    return () => { this.listeners.delete(listener); };
  }

  private onChange(): void {
    for (const l of [...this.listeners]) l();
  }

  get allowsInternetPlay(): boolean { return this.settings.allowInternetPlay && this.settings.config.isUsable; }
  get isReady(): boolean { return this.state.kind === 'ready'; }
  get hostedRoom(): string | null { return this.hosted?.key ?? null; }
  get cloudSettings(): CloudSettings { return this.settings; }

  /** Applies Settings → Family → Internet. Switching it off ends anything open. */
  configure(settings: CloudSettings): void {
    const changed = !settings.config.equals(this.settings.config) || settings.allowInternetPlay !== this.settings.allowInternetPlay;
    this.settings = settings;
    saveCloudSettings(settings, this.storage);
    if (!changed) return;
    this.stop();
    if (this.allowsInternetPlay) void this.start();
  }

  /** Signs in, once allowed. */
  start(): Promise<void> {
    if (!this.allowsInternetPlay) return Promise.resolve();
    if (this.state.kind === 'ready') return Promise.resolve();
    if (this.starting) return this.starting;
    this.state = { kind: 'connecting' };
    // Kept before anyone is told: a listener asking for the rooms must find this sign-in, not start another.
    this.starting = (async () => {
      try {
        const auth = new CloudAuth(this.settings.config, this.storage, this.fetcher);
        const database = new CloudDatabase(auth, this.fetcher);
        this.uid = await auth.signIn();
        this.database = database;
        this.state = { kind: 'ready' };
      } catch (e) {
        this.state = { kind: 'failed', message: e instanceof Error ? e.message : String(e) };
      } finally {
        this.starting = null;
        this.onChange();
      }
    })();
    this.onChange();
    return this.starting;
  }

  stop(): void {
    this.stopHosting();
    this.database = null;
    this.state = { kind: 'off' };
    this.rooms = [];
    this.onChange();
  }

  private async ready(): Promise<CloudDatabase> {
    if (!this.allowsInternetPlay) throw new CloudError('notConfigured');
    await this.start();
    if (!this.database) throw new Error(this.state.kind === 'failed' ? this.state.message : L("The internet settings aren't filled in yet."));
    return this.database;
  }

  // MARK: The list

  /** The rooms open now, newest first: fresh, made by this version, not this browser's own and not a blocked host's. */
  async refreshRooms(now = Date.now()): Promise<CloudRoom[]> {
    const database = await this.ready();
    const value = await database.get(CloudPath.lobby, { orderBy: '"at"', limitToLast: '40' });
    const rooms: CloudRoom[] = [];
    for (const [key, entry] of Object.entries(jsonObject(value) ?? {})) {
      if (!CloudPath.isSafeKey(key)) continue;
      const room = decodeCloudRoom(entry, key);
      if (!room || !roomIsFresh(room, now) || room.host === this.uid || this.blocked.has(room.host)) continue;
      room.hostName = ChatModerator.cleanName(room.hostName);
      room.world = ChatModerator.cleanName(room.world);
      rooms.push(room);
    }
    this.rooms = rooms.sort((a, b) => b.at - a.at);
    this.onChange();
    return this.rooms;
  }

  /** The room this browser last went into, so a move is not followed back into it. */
  private joined: string | null = null;

  /** The way into a listed room: a fresh relay link each time it is opened (a reconnect is a new link). */
  route(room: CloudRoom): RoomRoute {
    this.joined = room.id;
    return {
      code: room.code,
      salt: room.salt,
      open: async () => openGuestLink(await this.ready(), room.id),
    };
  }

  /**
   * Where a room that moved went: the new host lists it under the same code.
   * The old listing can still be there for a moment (its host is saying
   * goodbye), so it is passed over, and the new host's name is preferred.
   */
  async findMovedRoom(move: HostMove): Promise<RoomRoute | null> {
    const rooms = (await this.refreshRooms()).filter((r) => r.code === move.roomCode && r.id !== this.joined);
    const room = rooms.find((r) => r.hostName === ChatModerator.cleanName(move.newHostName)) ?? rooms[0];
    return room ? this.route(room) : null;
  }

  // MARK: Hosting

  /** Puts the room this browser hosts on the internet: in the list, and reachable through the relay. */
  async host(room: RoomHost, world: WorldDocument, profile: AvatarProfile): Promise<string> {
    const database = await this.ready();
    this.stopHosting();
    await room.ready();
    const uid = this.uid!;
    const key = CloudIDs.newLinkID();
    const entry = (): Json => ({
      ...encodeCloudRoom(makeCloudRoom({
        host: uid, hostName: sanitizedProfile(profile, ChatModerator.cleanName).displayName, world: world.name, worldID: world.id,
        players: Math.max(1, room.people), capacity: room.capacity, code: room.roomCode, salt: room.keySalt,
      })),
      at: serverTime,
    });
    await database.put(CloudPath.room(key), entry());
    const relay = new RelayHost(database, key);
    relay.onLink = (_link, pipe) => { void room.accept(pipe); };
    relay.start();
    // Still here, and how full: every half minute, and soon after someone comes or goes.
    const hosted: Hosted = {
      key, room, relay, entry, refreshSoon: null,
      timer: setInterval(() => { database.put(CloudPath.room(key), entry()).catch(() => {}); }, 30_000),
    };
    room.onPeopleChanged = () => {
      if (this.hosted !== hosted || hosted.refreshSoon) return;
      hosted.refreshSoon = setTimeout(() => {
        hosted.refreshSoon = null;
        if (this.hosted === hosted) database.put(CloudPath.room(key), entry()).catch(() => {});
      }, 2000);
    };
    this.hosted = hosted;
    if (typeof window !== 'undefined') window.addEventListener('pagehide', this.leaving);
    this.onChange();
    return key;
  }

  stopHosting(): void {
    const hosted = this.hosted;
    if (!hosted) return;
    this.hosted = null;
    clearInterval(hosted.timer);
    if (hosted.refreshSoon) clearTimeout(hosted.refreshSoon);
    if (typeof window !== 'undefined') window.removeEventListener('pagehide', this.leaving);
    const database = this.database;
    void (async () => {
      // Last messages out first (the room moving, goodbyes), while the room is still listed:
      // the rules let the host write to the relay, and clear it, only then.
      await hosted.relay.stop(3);
      if (!database) return;
      await database.delete(CloudPath.relay(hosted.key)).catch(() => {});
      await database.delete(CloudPath.room(hosted.key)).catch(() => {});
    })();
    this.onChange();
  }

  /** The tab is closing: take the room out of the list with requests that outlive the page. */
  private closeWhileLeaving(): void {
    const hosted = this.hosted;
    if (!hosted || !this.database) return;
    this.database.deleteWhileLeaving([CloudPath.relay(hosted.key), CloudPath.room(hosted.key)]);
  }

  block(host: string): void {
    this.blocked.add(host);
    try { this.storage?.setItem('ablox.cloud.blocked', JSON.stringify([...this.blocked])); } catch { /* not kept */ }
    this.rooms = this.rooms.filter((r) => r.host !== host);
    this.onChange();
  }

  /** Forgets this browser's sign-in altogether. */
  async forget(): Promise<void> {
    this.stop();
    const auth = new CloudAuth(this.settings.config, this.storage, this.fetcher);
    await auth.deleteAccount().catch(() => auth.forget());
    this.uid = null;
  }
}
