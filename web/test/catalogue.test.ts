import { afterEach, describe, expect, it, vi } from 'vitest';
import { fetchLimited, gameFileURL, inTurn, mergeIndexes, readListings } from '../src/net/catalogue';

const entry = (id: string, updatedAt = '2026-10-01T00:00:00Z') => ({
  id, title: `Game ${id}`, author: 'Ablox Games', world: `games/${id}/world.ablox`, cover: `games/${id}/cover-1.png`,
  scripts: ['lib/kit.absc', `games/${id}/main.absc`], tags: ['obby'], blockCount: 10, maxPlayers: 8, schemaVersion: 1, updatedAt,
});
const live = 'https://raw.githubusercontent.com/prak59459-create/AbloxGames/main/';
const copy = 'https://example.github.io/AbloxGames/catalogue/';

describe('the game list on GitHub Pages', () => {
  it('reads a game unchanged since the site was published from the site', () => {
    const games = mergeIndexes([entry('a'), entry('b', '2026-10-09T00:00:00Z')], [entry('a'), entry('b')], live, copy);
    expect(games.map((g) => [g.id, g.base])).toEqual([['a', copy], ['b', live]]);
    expect(gameFileURL(games[0], 'games/a/main.absc')).toBe(copy + 'games/a/main.absc');
    expect(gameFileURL(games[1], 'lib/kit.absc')).toBe(live + 'lib/kit.absc');
  });

  it('takes a game added since from GitHub, and a game taken away is gone', () => {
    const games = mergeIndexes([entry('a'), entry('new')], [entry('a'), entry('old')], live, copy);
    expect(games.map((g) => [g.id, g.base])).toEqual([['a', copy], ['new', live]]);
  });

  it('falls back to the copy when GitHub cannot be reached, and to GitHub with no copy', () => {
    expect(mergeIndexes(null, [entry('a')], live, copy).map((g) => g.base)).toEqual([copy]);
    expect(mergeIndexes([entry('a')], null, live, copy).map((g) => g.base)).toEqual([live]);
    expect(mergeIndexes(null, null, live, copy)).toEqual([]);
  });

  it('still leaves out listings that are not whole or safe', () => {
    const games = readListings([entry('ok'), { ...entry('bad'), world: '../secret.ablox' }, { id: 'Nope', title: 'x', world: 'w.ablox' }, entry('ok')], () => copy);
    expect(games.map((g) => g.id)).toEqual(['ok']);
  });
});

describe('fetching a file', () => {
  afterEach(() => { vi.unstubAllGlobals(); vi.useRealTimers(); });

  const reply = (status: number, body = 'hello') => new Response(status === 200 ? body : 'no', { status });

  it('tries again after a dropped connection or a busy server', async () => {
    const calls: string[] = [];
    const answers = [() => { throw new TypeError('Failed to fetch'); }, () => reply(429), () => reply(200)];
    vi.stubGlobal('fetch', vi.fn(async (url: string) => { calls.push(url); return answers[calls.length - 1](); }));
    const counted: number[] = [];
    const bytes = await fetchLimited('https://x/file', 1024, (n) => counted.push(n));
    expect(new TextDecoder().decode(bytes)).toBe('hello');
    expect(calls.length).toBe(3);
    expect(counted.reduce((a, b) => a + b, 0)).toBe(5);
  });

  it('does not ask again for what is not there, and gives up after three tries', async () => {
    const missing = vi.fn(async () => reply(404));
    vi.stubGlobal('fetch', missing);
    await expect(fetchLimited('https://x/missing', 1024)).rejects.toThrow('HTTP 404');
    expect(missing).toHaveBeenCalledTimes(1);
    const busy = vi.fn(async () => reply(503));
    vi.stubGlobal('fetch', busy);
    await expect(fetchLimited('https://x/busy', 1024)).rejects.toThrow('HTTP 503');
    expect(busy).toHaveBeenCalledTimes(3);
  });

  it('refuses a file larger than allowed', async () => {
    const big = vi.fn(async () => reply(200, 'x'.repeat(2000)));
    vi.stubGlobal('fetch', big);
    await expect(fetchLimited('https://x/big', 1000)).rejects.toThrow('too big');
    expect(big).toHaveBeenCalledTimes(1);
  });
});

describe('a few at a time', () => {
  it('keeps the order and never runs more than asked at once', async () => {
    let running = 0;
    let most = 0;
    const out = await inTurn([5, 1, 4, 2, 3, 6, 7], 3, async (n) => {
      running++;
      most = Math.max(most, running);
      await new Promise((r) => setTimeout(r, n));
      running--;
      return n * 10;
    });
    expect(out).toEqual([50, 10, 40, 20, 30, 60, 70]);
    expect(most).toBe(3);
    expect(await inTurn([], 4, async (n: number) => n)).toEqual([]);
  });
});
