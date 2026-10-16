// Playing and keeping in touch over the internet, through the Firebase
// Realtime Database the iPads use: AbloxCore/Cloud.swift. Only plain data and
// parsing is here — settings, where things live, the codes, JSON as Firebase
// sends it, its event stream, and the relay's numbered pieces — so it is
// tested without a network; net/cloud.ts and net/relay.ts do the talking.
//
// What goes up, and who can read it, is decided by the database's rules
// (CloudRules.swift), which the browser shares with the iPads:
//
// - A game in progress is never readable by Firebase: the players' own
//   encrypted stream (TLS with the room code) passes through it in pieces.
// - The list of internet rooms is readable by anyone signed in.
import type { AvatarProfile } from './avatar';
import { sanitizedProfile } from './avatar';
import { ChatModerator } from './chat';
import { prefix } from './text';
import { AbloxProtocol } from '../../net/packets';
import { fromBase64, toBase64 } from '../../net/bytes';

export type Json = null | boolean | number | string | Json[] | { [key: string]: Json };

// MARK: - Settings

/** Which database, and the key to sign in to it. */
export class CloudConfig {
  readonly databaseURL: string;
  readonly apiKey: string;

  constructor(databaseURL = '', apiKey = '') {
    this.databaseURL = databaseURL.trim();
    this.apiKey = apiKey.trim();
  }

  /** Ablox's own database, the one the iPads use with nothing typed in. */
  static readonly builtIn = new CloudConfig('https://ablox-ee138-default-rtdb.asia-southeast1.firebasedatabase.app',
    'AIzaSyCPUcRIkBS69RJf38uPoO5YZMC4RxjXmpc');

  /** The database's address with nothing after it — only a Firebase Realtime Database, so the key is never sent anywhere else. */
  get baseURL(): string | null {
    let text = this.databaseURL.trim();
    while (text.endsWith('/')) text = text.slice(0, -1);
    let url: URL;
    try { url = new URL(text); } catch { return null; }
    const host = url.hostname.toLowerCase();
    if (url.protocol !== 'https:') return null;
    if (!(host.endsWith('.firebaseio.com') || host.endsWith('.firebasedatabase.app'))) return null;
    if (!(url.pathname === '' || url.pathname === '/') || url.search || url.hash || url.username || url.password || url.port) return null;
    return `https://${host}`;
  }

  get isUsable(): boolean {
    const key = this.apiKey;
    return this.baseURL !== null && key.length >= 20 && key.length <= 80 && /^[A-Za-z0-9_-]+$/.test(key);
  }

  equals(other: CloudConfig): boolean { return this.databaseURL === other.databaseURL && this.apiKey === other.apiKey; }

  toJSON(): { databaseURL: string; apiKey: string } { return { databaseURL: this.databaseURL, apiKey: this.apiKey }; }

  static decode(v: unknown): CloudConfig {
    const o = (v && typeof v === 'object' ? v : {}) as Record<string, unknown>;
    return new CloudConfig(typeof o.databaseURL === 'string' ? o.databaseURL : '', typeof o.apiKey === 'string' ? o.apiKey : '');
  }
}

/** What a grown-up has allowed over the internet (Settings → Family → Internet). Everything starts off. */
export class CloudSettings {
  /** Internet rooms: hosting one, and seeing and joining others'. */
  allowInternetPlay = false;
  allowFriends = false;
  allowFriendChat = false;
  shareWhatIPlay = true;
  allowSuggestions = false;
  /** A database typed in here, instead of the one built in. */
  custom = new CloudConfig();

  get config(): CloudConfig { return this.custom.isUsable ? this.custom : CloudConfig.builtIn; }

  get isActive(): boolean {
    return this.config.isUsable && (this.allowInternetPlay || this.allowFriends || this.allowSuggestions);
  }

  toJSON(): Record<string, unknown> {
    return {
      allowInternetPlay: this.allowInternetPlay, allowFriends: this.allowFriends, allowFriendChat: this.allowFriendChat,
      shareWhatIPlay: this.shareWhatIPlay, allowSuggestions: this.allowSuggestions, custom: this.custom.toJSON(),
    };
  }

  /** Whatever was kept, a setting added later taking its default. */
  static decode(v: unknown): CloudSettings {
    const s = new CloudSettings();
    const o = (v && typeof v === 'object' ? v : {}) as Record<string, unknown>;
    const flag = (k: keyof CloudSettings) => { if (typeof o[k] === 'boolean') (s as unknown as Record<string, boolean>)[k] = o[k] as boolean; };
    flag('allowInternetPlay');
    flag('allowFriends');
    flag('allowFriendChat');
    flag('shareWhatIPlay');
    flag('allowSuggestions');
    if (o.custom !== undefined) s.custom = CloudConfig.decode(o.custom);
    return s;
  }
}

/** The three kinds of room an iPad can open. A browser can only open the first: it has no router to listen on. */
export type RoomAccess = 'internet' | 'routerPublic' | 'routerPrivate';
export const isPublicOnRouter = (access: RoomAccess) => access !== 'routerPrivate';

// MARK: - Where things live

export const CloudPath = {
  profile: (uid: string) => `users/${uid}/profile`,
  friendCode: (code: string) => `codes/${code}`,
  requests: (uid: string) => `requests/${uid}`,
  request: (to: string, from: string) => `requests/${to}/${from}`,
  friends: (uid: string) => `friends/${uid}`,
  friend: (uid: string, other: string) => `friends/${uid}/${other}`,
  chat: (pair: string) => `chats/${pair}`,
  lobby: 'lobby',
  room: (key: string) => `lobby/${key}`,
  relay: (key: string) => `relay/${key}`,
  links: (key: string) => `relay/${key}/links`,
  link: (key: string, link: string) => `relay/${key}/links/${link}`,
  upAll: (key: string) => `relay/${key}/up`,
  up: (key: string, link: string) => `relay/${key}/up/${link}`,
  down: (key: string, link: string) => `relay/${key}/down/${link}`,

  /** Safe as one step of a path: Firebase refuses `. $ # [ ] /`, and anything from another player is checked before it is used. */
  isSafeKey(key: unknown): key is string {
    return typeof key === 'string' && key.length >= 1 && key.length <= 64 && /^[A-Za-z0-9_-]+$/.test(key);
  },
} as const;

function randomIndex(n: number): number {
  // Rejection sampling, so every letter is as likely as the next.
  const limit = Math.floor(256 / n) * n;
  const byte = new Uint8Array(1);
  for (;;) {
    crypto.getRandomValues(byte);
    if (byte[0] < limit) return byte[0] % n;
  }
}

export const CloudIDs = {
  /** One chat between two people, the same whichever of them asks. */
  pair: (a: string, b: string) => [a, b].sort().join('_'),

  other(pair: string, uid: string): string | null {
    const parts = pair.split('_').filter((p) => p.length);
    if (parts.length !== 2 || !parts.includes(uid)) return null;
    return parts[0] === uid ? parts[1] : parts[0];
  },

  /** Letters and numbers that cannot be mistaken for each other. */
  codeAlphabet: 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789',

  /** A friend code: eight characters, shown as ABCD-2345. */
  newFriendCode(random: () => number = () => randomIndex(CloudIDs.codeAlphabet.length)): string {
    let out = '';
    for (let i = 0; i < 8; i++) out += CloudIDs.codeAlphabet[random() % CloudIDs.codeAlphabet.length];
    return out;
  },

  normalizeFriendCode(text: string): string | null {
    const code = [...text.toUpperCase()].filter((c) => !/\s/.test(c) && c !== '-').join('');
    if (code.length !== 8 || ![...code].every((c) => CloudIDs.codeAlphabet.includes(c))) return null;
    return code;
  },

  displayFriendCode: (code: string) => (code.length === 8 ? `${code.slice(0, 4)}-${code.slice(4)}` : code),

  /** A random key for a relay link (and for a room). */
  newLinkID(): string {
    const letters = 'abcdefghijklmnopqrstuvwxyz0123456789';
    let out = '';
    for (let i = 0; i < 20; i++) out += letters[randomIndex(letters.length)];
    return out;
  },

  /** Piece numbers as keys that sort the way the numbers do. */
  sequenceKey: (n: number) => String(Math.max(0, Math.trunc(n))).padStart(10, '0'),
} as const;

// MARK: - What is kept there

/** An internet room, as the list of rooms shows it. */
export interface CloudRoom {
  id: string;
  host: string;
  hostName: string;
  world: string;
  worldID: string;
  players: number;
  capacity: number;
  protocolVersion: number;
  /** The room code and key salt: everyone who can see the room may join it, so they are in the list. */
  code: string;
  salt: string;
  /** When it was last refreshed, by the server's clock (milliseconds). */
  at: number;
}

/** A room not heard from for this long is gone. */
export const roomStaleAfter = 2 * 60_000;

export function makeCloudRoom(r: Omit<CloudRoom, 'id' | 'protocolVersion' | 'at'> & Partial<Pick<CloudRoom, 'id' | 'protocolVersion' | 'at'>>): CloudRoom {
  return {
    id: r.id ?? '', host: r.host, hostName: prefix(r.hostName, 40), world: prefix(r.world, 60), worldID: r.worldID,
    players: r.players, capacity: r.capacity, protocolVersion: r.protocolVersion ?? AbloxProtocol.version,
    code: r.code, salt: r.salt, at: r.at ?? 0,
  };
}

export const roomIsFresh = (r: CloudRoom, now: number) => now - r.at < roomStaleAfter;
export const roomIsFull = (r: CloudRoom) => r.players >= r.capacity;
export const roomIsCompatible = (r: CloudRoom) => r.protocolVersion === AbloxProtocol.version;

/** As the iPads write it: `protocol`, never the room's own key. */
export function encodeCloudRoom(r: CloudRoom): { [key: string]: Json } {
  return {
    host: r.host, hostName: r.hostName, world: r.world, worldID: r.worldID, players: r.players,
    capacity: r.capacity, protocol: r.protocolVersion, code: r.code, salt: r.salt, at: r.at,
  };
}

/** One entry of the list, or null if it is not a room (every field there, of the right kind). */
export function decodeCloudRoom(v: unknown, id = ''): CloudRoom | null {
  if (!v || typeof v !== 'object' || Array.isArray(v)) return null;
  const o = v as Record<string, unknown>;
  const str = (k: string) => (typeof o[k] === 'string' ? (o[k] as string) : null);
  const int = (k: string) => (typeof o[k] === 'number' && Number.isInteger(o[k]) ? (o[k] as number) : null);
  const host = str('host'), hostName = str('hostName'), world = str('world'), worldID = str('worldID');
  const code = str('code'), salt = str('salt');
  const players = int('players'), capacity = int('capacity'), protocolVersion = int('protocol');
  const at = typeof o.at === 'number' && Number.isFinite(o.at) ? o.at : null;
  if (host === null || hostName === null || world === null || worldID === null || code === null || salt === null
    || players === null || capacity === null || protocolVersion === null || at === null) return null;
  return { id, host, hostName, world, worldID, players, capacity, protocolVersion, code, salt, at };
}

/** What friends see of a player. */
export interface CloudProfile {
  avatar: AvatarProfile;
  code: string;
  online: boolean;
  /** When last seen, in milliseconds since 1970 (the server's). */
  seen: number;
  game?: string;
  room?: string;
}

/** Made safe to show, whatever was written. */
export function cleanedProfile(p: CloudProfile): CloudProfile {
  const out: CloudProfile = {
    avatar: sanitizedProfile(p.avatar, ChatModerator.cleanName),
    code: CloudIDs.normalizeFriendCode(p.code) ?? '',
    online: p.online,
    seen: Number.isFinite(p.seen) ? p.seen : 0,
  };
  if (p.game !== undefined) out.game = ChatModerator.cleanName(prefix(p.game, 60));
  if (p.room !== undefined && CloudPath.isSafeKey(p.room)) out.room = p.room;
  return out;
}

/** On, and heard from in the last five minutes (a device that went flat never gets to say it is leaving). */
export const profileIsOnline = (p: CloudProfile, now: number) => p.online && now - p.seen < 300_000;

export const cloudMessageMaximumLength = 200;
export const cloudKeptMessages = 60;

/** Firebase fills this in with its own clock when it is written. */
export const serverTime: Json = { '.sv': 'timestamp' };

// MARK: - JSON as Firebase sends it

/** A value's children by key; Firebase sends a map with keys 0, 1, 2… as an array. */
export function jsonObject(value: unknown): Record<string, Json> | null {
  if (Array.isArray(value)) {
    const map: Record<string, Json> = {};
    value.forEach((v, i) => { if (v !== null && v !== undefined) map[String(i)] = v as Json; });
    return map;
  }
  if (value && typeof value === 'object') return value as Record<string, Json>;
  return null;
}

export function jsonChild(value: unknown, key: string): Json {
  return jsonObject(value)?.[key] ?? null;
}

/** Writes `value` at `path`, as Firebase does for a `put`: null removes, and a parent left empty goes too. */
export function jsonSetting(tree: Json, path: string[], value: Json): Json {
  if (!path.length) return value;
  const [first, ...rest] = path;
  const map: Record<string, Json> = { ...(jsonObject(tree) ?? {}) };
  const child = jsonSetting(map[first] ?? null, rest, value);
  if (child === null) delete map[first]; else map[first] = child;
  return Object.keys(map).length ? map : null;
}

/** Merges `value`'s children in at `path`, as Firebase does for a `patch`. */
export function jsonPatching(tree: Json, path: string[], value: Json): Json {
  let result = tree;
  for (const [key, child] of Object.entries(jsonObject(value) ?? {})) result = jsonSetting(result, [...path, key], child);
  return result;
}

// MARK: - The stream

export type CloudEventKind = 'put' | 'patch' | 'keep-alive' | 'cancel' | 'auth_revoked';
export interface CloudEvent { kind: CloudEventKind; path: string[]; data: Json }

const eventKinds = new Set<string>(['put', 'patch', 'keep-alive', 'cancel', 'auth_revoked']);

/** Reads Firebase's event stream ("server-sent events") a line at a time. */
export class CloudEventParser {
  private event: string | null = null;
  private dataLines: string[] = [];

  /** A line without its newline. Returns an event when a blank line ends one. */
  feed(raw: string): CloudEvent | null {
    const line = raw.endsWith('\r') ? raw.slice(0, -1) : raw;
    if (!line.length) {
      const name = this.event;
      const body = this.dataLines.join('\n');
      this.event = null;
      this.dataLines = [];
      if (!name || !eventKinds.has(name)) return null;
      const kind = name as CloudEventKind;
      if (kind !== 'put' && kind !== 'patch') return { kind, path: [], data: null };
      let parsed: unknown;
      try { parsed = JSON.parse(body); } catch { return null; }
      const pathText = jsonChild(parsed, 'path');
      const path = (typeof pathText === 'string' ? pathText : '/').split('/').filter((s) => s.length);
      return { kind, path, data: jsonChild(parsed, 'data') };
    }
    if (line.startsWith('event:')) this.event = line.slice(6).trim();
    else if (line.startsWith('data:')) this.dataLines.push(line.slice(5).trim());
    return null;
  }
}

/** A copy of a streamed location, kept up to date by its events. */
export class CloudMirror {
  value: Json = null;

  apply(event: CloudEvent): void {
    if (event.kind === 'put') this.value = jsonSetting(this.value, event.path, event.data);
    else if (event.kind === 'patch') this.value = jsonPatching(this.value, event.path, event.data);
  }
}

// MARK: - A stream of bytes, in numbered pieces

/** Base64 as Foundation reads it: the alphabet, padded, nothing else. */
export function strictBase64(text: string): Uint8Array | null {
  if (text.length % 4 !== 0 || !/^[A-Za-z0-9+/]*={0,2}$/.test(text)) return null;
  return fromBase64(text);
}

/** What one side of a relay link has to send: bytes gathered while the last piece was on its way, sent as the next numbered piece. */
export class RelayOutbox {
  /** Firebase takes up to 10 MB a write; a quarter of a megabyte keeps each one quick. */
  static readonly maximumChunk = 256 * 1024;

  nextSequence = 0;
  private parts: Uint8Array[] = [];
  private length = 0;

  get isEmpty(): boolean { return this.length === 0; }
  get pendingBytes(): number { return this.length; }

  append(bytes: Uint8Array): void {
    if (!bytes.length) return;
    this.parts.push(bytes.slice());
    this.length += bytes.length;
  }

  /** The next piece to send, numbered. */
  take(): { key: string; base64: string } | null {
    if (!this.length) return null;
    const size = Math.min(RelayOutbox.maximumChunk, this.length);
    const piece = new Uint8Array(size);
    let filled = 0;
    while (filled < size) {
      const head = this.parts[0];
      const n = Math.min(head.length, size - filled);
      piece.set(head.subarray(0, n), filled);
      filled += n;
      if (n === head.length) this.parts.shift(); else this.parts[0] = head.subarray(n);
    }
    this.length -= size;
    const key = CloudIDs.sequenceKey(this.nextSequence);
    this.nextSequence += 1;
    return { key, base64: toBase64(piece) };
  }
}

/** The other side: numbered pieces as they arrive, in whatever order, handed on in order. */
export class RelayInbox {
  nextSequence = 0;
  private waiting = new Map<number, Uint8Array>();
  /** Keys handed on, for deleting from the database. */
  private consumed: string[] = [];

  /** Everything under the link (key → base64), however much of it is new. */
  receive(pieces: Record<string, Json>): Uint8Array {
    for (const [key, value] of Object.entries(pieces)) {
      if (!/^[+-]?\d+$/.test(key)) continue;
      const number = parseInt(key, 10);
      if (!Number.isSafeInteger(number) || number < this.nextSequence || this.waiting.has(number) || typeof value !== 'string') continue;
      const bytes = strictBase64(value);
      if (!bytes) continue;
      this.waiting.set(number, bytes);
    }
    const ready: Uint8Array[] = [];
    let total = 0;
    for (let bytes = this.waiting.get(this.nextSequence); bytes; bytes = this.waiting.get(this.nextSequence)) {
      this.waiting.delete(this.nextSequence);
      ready.push(bytes);
      total += bytes.length;
      this.consumed.push(CloudIDs.sequenceKey(this.nextSequence));
      this.nextSequence += 1;
    }
    const out = new Uint8Array(total);
    let at = 0;
    for (const r of ready) { out.set(r, at); at += r.length; }
    return out;
  }

  /** Keys to delete now; forgets them. */
  takeConsumed(): string[] {
    const out = this.consumed;
    this.consumed = [];
    return out;
  }
}
