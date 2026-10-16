// The player's record in this browser: coins from rounds and missions, the
// daily bonus, first visits, levels, the shop, and what survives a reload.
// And the Plaza's doors.
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { PlayerRecord, isWorn, wearing } from '../src/app/player';
import { buildPlaza, plazaGames } from '../src/app/plaza';
import { defaultProfile } from '../src/core/model/avatar';
import { CoinRate, itemsOf, shopItem, shopItems } from '../src/core/model/economy';
import { DailyBonus, MissionBook, PlayerLevel, dailyPick } from '../src/core/model/progress';
import { useLanguageForTests } from '../src/i18n';
import type { GameListing } from '../src/net/catalogue';

class MemoryStorage implements Storage {
  private map = new Map<string, string>();
  get length() { return this.map.size; }
  clear() { this.map.clear(); }
  getItem(k: string) { return this.map.get(k) ?? null; }
  key(i: number) { return [...this.map.keys()][i] ?? null; }
  removeItem(k: string) { this.map.delete(k); }
  setItem(k: string, v: string) { this.map.set(k, String(v)); }
}

beforeEach(() => useLanguageForTests('en'));
afterEach(() => vi.useRealTimers());

describe('PlayerRecord', () => {
  it('starts with nothing but the free looks', () => {
    const r = new PlayerRecord(new MemoryStorage());
    expect(r.wallet.coins).toBe(0);
    expect(r.wallet.owns('hat.none')).toBe(true);
    expect(r.wallet.owns('hat.crown')).toBe(false);
    expect(r.level.number).toBe(1);
    expect(r.recent).toEqual([]);
  });

  it('gives coins for the first visit to a game, once', () => {
    const r = new PlayerRecord(new MemoryStorage());
    const said = r.startedGame('tower', 'Tower');
    expect(r.wallet.coins).toBe(PlayerRecord.newGameCoins);
    expect(said[0]).toBe('First visit here: +10 coins');
    r.startedGame('tower', 'Tower');
    expect(r.wallet.coins).toBe(PlayerRecord.newGameCoins);
    expect(r.games.get('tower')!.plays).toBe(2);
    expect(r.recent.map((g) => g.id)).toEqual(['tower']);
  });

  it('banks a round as the iPad does: a coin a point and a bonus for finishing', () => {
    const r = new PlayerRecord(new MemoryStorage());
    r.startedGame('tower', 'Tower');
    const before = r.wallet.coins;
    const said = r.roundOver('tower', 40, true);
    expect(r.wallet.coins - before).toBeGreaterThanOrEqual(CoinRate.coins(40, true));
    expect(said[0]).toBe(`+${CoinRate.coins(40, true)} coins`);
    expect(r.counters.roundsWon).toBe(1);
    expect(r.games.get('tower')!.best).toBe(40);
    // A worse round keeps the best.
    r.roundOver('tower', 10, false);
    expect(r.games.get('tower')!.best).toBe(40);
    expect(r.counters.roundsWon).toBe(1);
  });

  it('counts play time towards today’s minutes mission and says when it is done', () => {
    const r = new PlayerRecord(new MemoryStorage());
    const minutes = r.todaysMissions.find((m) => m.kind === 'playMinutes')!;
    let said: string[] = [];
    for (let s = 0; s < minutes.target * 60; s += 5) said = said.concat(r.played(5));
    expect(r.missions.isDone(minutes, r.today)).toBe(true);
    expect(said.some((l) => l.startsWith('Mission done: '))).toBe(true);
    expect(r.secondsPlayed).toBe(minutes.target * 60);
    // Taken once, for its reward.
    const coins = r.wallet.coins;
    expect(r.claim(minutes)).toBe(minutes.reward);
    expect(r.claim(minutes)).toBeNull();
    expect(r.wallet.coins - coins).toBeGreaterThanOrEqual(minutes.reward);
    expect(r.counters.missionsClaimed).toBe(1);
  });

  it('pays the all-done bonus once every mission is done', () => {
    const r = new PlayerRecord(new MemoryStorage());
    expect(r.claimAllDone()).toBeNull();
    for (const m of r.todaysMissions) r.missions.counts[m.kind] = m.kind === 'playMinutes' ? m.target * 60 : m.target;
    r.missions.day = r.today;
    r.missions.games = Array.from({ length: 5 }, (_, i) => `g${i}`);
    expect(r.claimAllDone()).toBe(MissionBook.allDoneBonus);
    expect(r.claimAllDone()).toBeNull();
  });

  it('gives the daily bonus once a day, more for days in a row, and keeps the best run', () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date(2026, 9, 10, 12));
    const store = new MemoryStorage();
    const r = new PlayerRecord(store);
    expect(r.claimDailyBonus()).toBe(DailyBonus.base);
    expect(r.claimDailyBonus()).toBeNull();
    vi.setSystemTime(new Date(2026, 9, 11, 12));
    expect(r.claimDailyBonus()).toBe(DailyBonus.base + DailyBonus.perDay);
    vi.setSystemTime(new Date(2026, 9, 15, 12));
    expect(r.claimDailyBonus()).toBe(DailyBonus.base);
    expect(r.stats().bestStreak).toBe(2);
    expect(new PlayerRecord(store).stats().bestStreak).toBe(2);
  });

  it('rewards a new level once', () => {
    const r = new PlayerRecord(new MemoryStorage());
    // Ten rounds won and a few missions: 10×10 + 4×25 = 200 experience → level 2.
    r.counters.roundsWon = 10;
    r.counters.missionsClaimed = 4;
    const before = r.wallet.coins;
    const said = r.roundOver('x', 0, false);
    expect(r.level.number).toBe(2);
    expect(said).toContain(`Level 2! +${PlayerLevel.reward(2)} coins`);
    expect(r.wallet.coins - before).toBe(PlayerLevel.reward(2));
    expect(r.roundOver('x', 0, false)).toEqual([]);
  });

  it('opens a room for coins once a day', () => {
    const r = new PlayerRecord(new MemoryStorage());
    expect(r.hosted()).toEqual(['Hosting a room: +10 coins']);
    expect(r.hosted()).toEqual([]);
    expect(r.wallet.coins).toBe(PlayerRecord.hostCoins);
  });

  it('buys only what it can afford, and remembers it', () => {
    const store = new MemoryStorage();
    const r = new PlayerRecord(store);
    const crown = shopItem('hat.crown')!;
    expect(r.buy(crown)).toEqual({ kind: 'notEnoughCoins', shortfall: crown.price });
    r.wallet.earn(crown.price + 5);
    expect(r.buy(crown).kind).toBe('purchased');
    expect(r.wallet.coins).toBe(5);
    expect(r.buy(crown).kind).toBe('alreadyOwned');
    const again = new PlayerRecord(store);
    expect(again.wallet.owns(crown)).toBe(true);
    expect(again.wallet.coins).toBe(5);
    expect(again.stats().hatsOwned).toBe(1);
    expect(again.stats().itemsOwned).toBe(1);
  });

  it('keeps everything across a reload', () => {
    const store = new MemoryStorage();
    const r = new PlayerRecord(store);
    r.startedGame('a', 'A');
    r.played(125);
    r.emote();
    r.picture();
    r.toggleLike('a');
    const copy = new PlayerRecord(store);
    expect(copy.wallet.coins).toBe(r.wallet.coins);
    expect(copy.secondsPlayed).toBe(125);
    expect(copy.counters.emotes).toBe(1);
    expect(copy.pictures).toBe(1);
    expect([...copy.liked]).toEqual(['a']);
    expect(copy.games.get('a')!.plays).toBe(1);
    expect(copy.days.has(r.today)).toBe(true);
  });

  it('starts afresh from a broken save', () => {
    const store = new MemoryStorage();
    store.setItem('ablox.player', '{"wallet": "nope", "games": [null, 3, {"id": 5}], "days": "x"');
    const r = new PlayerRecord(store);
    expect(r.wallet.coins).toBe(0);
    store.setItem('ablox.player', JSON.stringify({ wallet: { coins: -50 }, games: [null, { id: 'ok', plays: 'two' }], days: [1, 'd'] }));
    const s = new PlayerRecord(store);
    expect(s.wallet.coins).toBe(0);
    expect([...s.games.keys()]).toEqual(['ok']);
    expect(s.games.get('ok')!.plays).toBe(0);
    expect([...s.days]).toEqual(['d']);
  });

  it('tells subscribers about changes', () => {
    const r = new PlayerRecord(new MemoryStorage());
    let n = 0;
    const stop = r.subscribe(() => { n += 1; });
    r.emote();
    stop();
    r.emote();
    expect(n).toBe(1);
  });
});

describe('wearing', () => {
  it('puts every kind of item on, and knows it is on', () => {
    for (const item of shopItems) {
      const p = wearing(defaultProfile(), item);
      expect(isWorn(p, item), item.id).toBe(true);
    }
    const p = wearing(defaultProfile(), shopItem('hat.crown')!);
    expect(isWorn(p, shopItem('hat.cap')!)).toBe(false);
    expect(p.hat).toBe('crown');
    expect(itemsOf('bodyColor').filter((i) => isWorn(defaultProfile(), i)).length).toBeLessThanOrEqual(1);
  });
});

describe('the Plaza', () => {
  const listing = (id: string, tags: string[] = []): GameListing => ({
    id, title: id.toUpperCase(), summary: '', author: '', tags, maxPlayers: 8, world: `${id}/world.ablox`,
  } as unknown as GameListing);
  const games = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k'].map((id, i) => listing(id, i % 3 === 0 ? ['top20'] : []));

  it('puts today’s pick first, then what was played last, without repeats', () => {
    const picked = plazaGames(games, ['c', 'c', 'zz', 'e']);
    expect(picked[0].id).toBe(dailyPick(games)!.id);
    expect(picked.length).toBe(8);
    expect(new Set(picked.map((g) => g.id)).size).toBe(8);
    const recent = picked.slice(1, 3).map((g) => g.id);
    for (const id of ['c', 'e']) if (id !== picked[0].id) expect(picked.map((g) => g.id)).toContain(id);
    expect(recent.length).toBe(2);
    // A game played twice, or one gone from the list, does not use up a door (as on the iPad).
    const few = plazaGames(games, ['c', 'c', 'zz', 'e'], 3).map((g) => g.id);
    for (const id of ['c', 'e']) expect(few).toContain(id);
    expect(plazaGames([], [])).toEqual([]);
  });

  it('has a door for each game and for the closet and the list, all walk-through', async () => {
    vi.stubGlobal('fetch', vi.fn(async () => { throw new Error('offline'); }));
    try {
      const plaza = await buildPlaza(games, ['b'], 'Mika');
      expect(plaza.doors.size).toBe(10);
      const doors = [...plaza.doors.entries()];
      expect(doors.filter(([, d]) => d.kind === 'tab').map(([, d]) => (d as { hash: string }).hash).sort()).toEqual(['games', 'me']);
      for (const [id] of doors) {
        const block = plaza.world.blocks.find((b) => b.id === id)!;
        expect(block.behavior).toBe('trigger');
        expect(block.label?.lines[0].text).toBeTruthy();
      }
      expect(plaza.world.blocks.filter((b) => b.behavior === 'spawn').length).toBe(1);
      expect(new Set(plaza.world.blocks.map((b) => b.id)).size).toBe(plaza.world.blocks.length);
      // Offline: no covers, and the doors are coloured glass instead.
      expect(plaza.world.images).toEqual([]);
      expect(plaza.world.scripts[0].source).toContain('Walk into a door');
    } finally {
      vi.unstubAllGlobals();
    }
  });
});
