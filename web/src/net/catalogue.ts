// The game list and the games in it, read from the AbloxGames repository —
// AbloxCore/GameCatalogue.swift and Net/GameLibrary.swift. The same files
// the iPads read, from the same place: raw.githubusercontent.com, so a game
// merged on GitHub is playable here at once.
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

export function fileURL(path: string, source?: CatalogueSource): string {
  return baseURL(source) + path.split('/').map(encodeURIComponent).join('/');
}

export const coverURL = (l: GameListing, source?: CatalogueSource) =>
  l.cover && validPath(l.cover, ['.png', '.jpg', '.jpeg']) ? fileURL(l.cover, source) : null;

async function fetchLimited(url: string, limit: number, onBytes?: (n: number) => void): Promise<Uint8Array> {
  const response = await fetch(url, { cache: 'no-cache' });
  if (!response.ok) throw new Error(`HTTP ${response.status}`);
  const length = Number(response.headers.get('content-length') ?? 0);
  if (length > limit) throw new Error('too big');
  if (!response.body) return new Uint8Array(await response.arrayBuffer());
  const reader = response.body.getReader();
  const parts: Uint8Array[] = [];
  let total = 0;
  for (;;) {
    const { done, value } = await reader.read();
    if (done) break;
    total += value.length;
    if (total > limit) { reader.cancel(); throw new Error('too big'); }
    parts.push(value);
    onBytes?.(value.length);
  }
  const out = new Uint8Array(total);
  let offset = 0;
  for (const p of parts) { out.set(p, offset); offset += p.length; }
  return out;
}

export async function loadCatalogue(source?: CatalogueSource): Promise<GameListing[]> {
  const bytes = await fetchLimited(fileURL('index.json', source), 4 * 1024 * 1024);
  const index = JSON.parse(new TextDecoder().decode(bytes)) as { catalogueVersion?: number; games?: unknown[] };
  if ((index.catalogueVersion ?? 1) > 1) throw new Error('This list needs a newer Ablox.');
  const seen = new Set<string>();
  const games: GameListing[] = [];
  for (const raw of index.games ?? []) {
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
    });
  }
  return games;
}

const worldCache = new Map<string, WorldDocument>();

/** A game ready to play: its world, with the repository's script files merged in. */
export async function loadGame(listing: GameListing, source?: CatalogueSource,
  progress?: (received: number, expected: number) => void): Promise<WorldDocument> {
  const key = listing.id + '@' + listing.updatedAt;
  const cached = worldCache.get(key);
  if (cached) return structuredClone(cached);
  const expected = listing.bytes ?? 0;
  let received = 0;
  const note = (n: number) => { received += n; progress?.(received, expected); };
  const worldBytes = await fetchLimited(fileURL(listing.world, source), 40 * 1024 * 1024, note);
  const world = decodeWorld(JSON.parse(new TextDecoder().decode(worldBytes)));
  if (world.blocks.length > 20000) throw new Error('That world has too many parts to open safely.');
  world.id = crypto.randomUUID().toUpperCase();
  const scripts = await Promise.all((listing.scripts ?? []).map(async (path) => {
    const bytes = await fetchLimited(fileURL(path, source), 2 * 1024 * 1024, note);
    return { name: path.split('/').pop() ?? 'main.absc', source: new TextDecoder().decode(bytes) };
  }));
  world.scripts = mergeScripts(scripts, world.scripts);
  worldCache.set(key, world);
  return structuredClone(world);
}
