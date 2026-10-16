// The game list and the games in it, read from the AbloxGames repository —
// AbloxCore/GameCatalogue.swift and Net/GameLibrary.swift. The same files
// the iPads read, from the same place: raw.githubusercontent.com, so a game
// merged on GitHub is playable here at once.
//
// On GitHub Pages the site also carries a copy of the games, made when it
// was published (catalogue/ beside the page). A game unchanged since then is
// read from that copy: it comes faster, and is never turned away for asking
// too often, as raw.githubusercontent.com can be when a whole class shares
// one connection. A game changed since comes from GitHub, all its files.
import { decodeWorld, mergeScripts, type WorldDocument } from '../core/model/world';

export interface GameListing {
  id: string;
  title: string;
  author: string;
  summary: string;
  world: string;
  cover?: string;
  shots?: string[];
  scripts?: string[];
  tags: string[];
  blockCount: number;
  maxPlayers: number;
  schemaVersion: number;
  updatedAt: string;
  bytes?: number;
  /** Where this game's files are read from (set as the list is read). */
  base?: string;
}

export interface CatalogueSource { repository: string; reference: string }
export const defaultSource: CatalogueSource = { repository: 'prak59459-create/AbloxGames', reference: 'main' };

const validID = /^[a-z0-9][a-z0-9-]{0,63}$/;
const validPath = (path: string, extensions: string[]) =>
  path.length <= 200 && !path.startsWith('/') && !path.includes('..') && !path.includes('\\') && !path.includes('//')
  && /^[A-Za-z0-9._\-/]+$/.test(path) && extensions.some((e) => path.toLowerCase().endsWith(e));

export function isValidRepository(repository: string): boolean {
  const parts = repository.split('/');
  return parts.length === 2 && parts.every((p) => p.length > 0 && p.length <= 100 && !p.startsWith('.') && /^[A-Za-z0-9._-]+$/.test(p));
}

export function isValidReference(reference: string): boolean {
  return reference.length > 0 && reference.length <= 100 && !reference.startsWith('/') && !reference.endsWith('/')
    && !reference.startsWith('-') && !reference.startsWith('.') && !reference.includes('//') && !reference.includes('..')
    && /^[A-Za-z0-9._/-]+$/.test(reference);
}

/** Where the files are: this repository on GitHub, or while developing, the folder beside this one. */
export function baseURL(source: CatalogueSource = defaultSource): string {
  if (import.meta.env?.DEV && source === defaultSource) return new URL('catalogue/', location.href).href;
  if (!isValidRepository(source.repository) || !isValidReference(source.reference)) return baseURL(defaultSource);
  return `https://raw.githubusercontent.com/${source.repository}/${source.reference}/`;
}

const encodePath = (path: string) => path.split('/').map(encodeURIComponent).join('/');

export function fileURL(path: string, source?: CatalogueSource): string {
  return baseURL(source) + encodePath(path);
}

/** One of a game's files, from wherever the list said its files are. */
export function gameFileURL(l: GameListing, path: string, source?: CatalogueSource): string {
  return (source ? baseURL(source) : l.base ?? baseURL()) + encodePath(path);
}

export const coverURL = (l: GameListing, source?: CatalogueSource) =>
  l.cover && validPath(l.cover, ['.png', '.jpg', '.jpeg']) ? gameFileURL(l, l.cover, source) : null;

/** The copy of the games published with the site, beside the page. */
export const bundledBase = (): string => new URL('catalogue/', location.href).href;

const wait = (ms: number) => new Promise((r) => setTimeout(r, ms));

/**
 * A file, at most `limit` bytes. A dropped connection, a server too busy
 * (429, 5xx) or one that stops sending for 20 seconds is tried twice more,
 * a little later each time, so a game never waits on its loading card for
 * good: it opens, or says it could not.
 */
export async function fetchLimited(url: string, limit: number, onBytes?: (n: number) => void,
  options: { attempts?: number; fresh?: boolean } = {}): Promise<Uint8Array> {
  const attempts = options.attempts ?? 3;
  let last: unknown = null;
  for (let attempt = 0; attempt < attempts; attempt++) {
    if (attempt > 0) await wait(600 * 3 ** (attempt - 1));
    let counted = 0;
    try {
      return await fetchOnce(url, limit, options.fresh ?? false, (n) => { counted += n; onBytes?.(n); });
    } catch (e) {
      last = e;
      // What was counted towards the loading bar comes off again before the next try.
      if (counted) onBytes?.(-counted);
      if (e instanceof FetchRefused) throw e;
    }
  }
  throw last instanceof Error ? last : new Error(String(last));
}

/** A reply that trying again would not change: not found, too big. */
class FetchRefused extends Error {}

async function fetchOnce(url: string, limit: number, fresh: boolean, onBytes: (n: number) => void): Promise<Uint8Array> {
  const control = new AbortController();
  let timer = setTimeout(() => control.abort(), 20000);
  const stillGoing = () => { clearTimeout(timer); timer = setTimeout(() => control.abort(), 20000); };
  try {
    const response = await fetch(url, { cache: fresh ? 'no-cache' : 'default', signal: control.signal });
    if (!response.ok) {
      if (response.status === 429 || response.status >= 500) throw new Error(`HTTP ${response.status}`);
      throw new FetchRefused(`HTTP ${response.status}`);
    }
    const length = Number(response.headers.get('content-length') ?? 0);
    if (length > limit) throw new FetchRefused('too big');
    if (!response.body) return new Uint8Array(await response.arrayBuffer());
    const reader = response.body.getReader();
    const parts: Uint8Array[] = [];
    let total = 0;
    for (;;) {
      const { done, value } = await reader.read();
      if (done) break;
      stillGoing();
      total += value.length;
      if (total > limit) { void reader.cancel(); throw new FetchRefused('too big'); }
      parts.push(value);
      onBytes(value.length);
    }
    const out = new Uint8Array(total);
    let offset = 0;
    for (const p of parts) { out.set(p, offset); offset += p.length; }
    return out;
  } catch (e) {
    if (control.signal.aborted) throw new Error('The connection stopped.');
    throw e;
  } finally {
    clearTimeout(timer);
  }
}

/** `work` for each item, at most `width` at a time, in order. */
export async function inTurn<T, R>(items: T[], width: number, work: (item: T) => Promise<R>): Promise<R[]> {
  const out: R[] = new Array(items.length);
  let next = 0;
  const lane = async () => {
    while (next < items.length) {
      const i = next++;
      out[i] = await work(items[i]);
    }
  };
  await Promise.all(Array.from({ length: Math.min(width, items.length) }, lane));
  return out;
}

async function readIndex(base: string, fresh: boolean): Promise<unknown[]> {
  const bytes = await fetchLimited(base + 'index.json', 4 * 1024 * 1024, undefined, { fresh });
  const index = JSON.parse(new TextDecoder().decode(bytes)) as { catalogueVersion?: number; games?: unknown[] };
  if ((index.catalogueVersion ?? 1) > 1) throw new Error('This list needs a newer Ablox.');
  return Array.isArray(index.games) ? index.games : [];
}

/** The listings of an index, those that are whole and safe; each told where its files are. */
export function readListings(entries: unknown[], baseFor: (raw: unknown, id: string) => string): GameListing[] {
  const seen = new Set<string>();
  const games: GameListing[] = [];
  for (const raw of entries) {
    const g = raw as GameListing;
    if (!g || typeof g.id !== 'string' || !validID.test(g.id) || seen.has(g.id)) continue;
    if (typeof g.title !== 'string' || !g.title || typeof g.world !== 'string' || !validPath(g.world, ['.ablox', '.json'])) continue;
    if ((g.schemaVersion ?? 1) > 2) continue;
    seen.add(g.id);
    games.push({
      id: g.id, title: g.title.slice(0, 60), author: String(g.author ?? '').slice(0, 40), summary: String(g.summary ?? '').slice(0, 300),
      world: g.world, cover: g.cover, shots: (g.shots ?? []).filter((s) => validPath(s, ['.png', '.jpg', '.jpeg'])).slice(0, 6),
      scripts: (g.scripts ?? []).filter((s) => validPath(s, ['.absc'])).slice(0, 32), tags: (g.tags ?? []).slice(0, 12),
      blockCount: g.blockCount ?? 0, maxPlayers: g.maxPlayers ?? 4, schemaVersion: g.schemaVersion ?? 1, updatedAt: g.updatedAt ?? '', bytes: g.bytes,
      base: baseFor(raw, g.id),
    });
  }
  return games;
}

/**
 * The list on GitHub, each game read from the site's own copy when that copy
 * is the same game, word for word, and from GitHub when it has changed. If
 * GitHub cannot be reached the copy is the list; if there is no copy (the
 * page is not on GitHub Pages), GitHub is.
 */
export function mergeIndexes(live: unknown[] | null, copy: unknown[] | null, liveBase: string, copyBase: string): GameListing[] {
  if (!live) return readListings(copy ?? [], () => copyBase);
  const copies = new Map<string, string>();
  for (const raw of copy ?? []) {
    const id = (raw as { id?: unknown })?.id;
    if (typeof id === 'string') copies.set(id, JSON.stringify(raw));
  }
  return readListings(live, (raw, id) => (copies.get(id) === JSON.stringify(raw) ? copyBase : liveBase));
}

export async function loadCatalogue(source?: CatalogueSource): Promise<GameListing[]> {
  const live = baseURL(source);
  const copy = bundledBase();
  if (live === copy) return readListings(await readIndex(live, true), () => live);
  if (source && source !== defaultSource) return readListings(await readIndex(live, true), () => live);
  const [fromGitHub, fromSite] = await Promise.allSettled([readIndex(live, true), readIndex(copy, false)]);
  if (fromGitHub.status === 'rejected' && fromSite.status === 'rejected') throw fromGitHub.reason;
  return mergeIndexes(fromGitHub.status === 'fulfilled' ? fromGitHub.value : null,
    fromSite.status === 'fulfilled' ? fromSite.value : null, live, copy);
}

const worldCache = new Map<string, WorldDocument>();

/**
 * The id this browser gives a catalogue game, kept from visit to visit, so
 * what a game saves (and its leaderboards) are found again next time — even
 * after the game is updated on GitHub.
 */
export function stableGameID(listingID: string): string {
  const key = 'ablox.gameIDs';
  let ids: Record<string, string> = {};
  try { ids = JSON.parse(localStorage.getItem(key) ?? '{}') as Record<string, string>; } catch { /* none yet */ }
  let id = ids[listingID];
  if (typeof id !== 'string' || !/^[0-9A-F-]{36}$/.test(id)) {
    id = crypto.randomUUID().toUpperCase();
    ids[listingID] = id;
    try { localStorage.setItem(key, JSON.stringify(ids)); } catch { /* private mode: a new id each visit */ }
  }
  return id;
}

/** A game ready to play: its world, with the repository's script files merged in. */
export async function loadGame(listing: GameListing, source?: CatalogueSource,
  progress?: (received: number, expected: number) => void): Promise<WorldDocument> {
  const key = listing.id + '@' + listing.updatedAt;
  const cached = worldCache.get(key);
  if (cached) return structuredClone(cached);
  const expected = listing.bytes ?? 0;
  let received = 0;
  const note = (n: number) => { received += n; progress?.(received, expected); };
  const worldBytes = await fetchLimited(gameFileURL(listing, listing.world, source), 40 * 1024 * 1024, note);
  const world = decodeWorld(JSON.parse(new TextDecoder().decode(worldBytes)));
  if (world.blocks.length > 20000) throw new Error('That world has too many parts to open safely.');
  world.id = stableGameID(listing.id);
  // A few at a time: thirty files asked for at once are what a busy server turns away.
  const scripts = await inTurn(listing.scripts ?? [], 6, async (path) => {
    const bytes = await fetchLimited(gameFileURL(listing, path, source), 2 * 1024 * 1024, note);
    return { name: path.split('/').pop() ?? 'main.absc', source: new TextDecoder().decode(bytes) };
  });
  world.scripts = mergeScripts(scripts, world.scripts);
  worldCache.set(key, world);
  return structuredClone(world);
}
