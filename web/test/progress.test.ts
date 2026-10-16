// EconomyTests.swift, PlayerProgressTests.swift and MissionsAndHabitsTests
// .swift — and today's missions and pick checked against the iPad's own
// for every day of two years (fixtures/missions-swift.json, written by
// tools/wireoracle: `WireOracle missions`).
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import './helpers';
import { CoinRate, PlayerWallet, freeItemIDs, isFree, purchaseMessage, rarity, shopItem, shopItems, type ShopKind } from '../src/core/model/economy';
import {
  DailyBonus, MissionBook, PlayerLevel, achievements, badgeDetail, badgeProgress, badgeTitle, dailyPick, earnedBadges, experience, isEarned,
  levelOf, nextBadges, progressStats, type Mission,
} from '../src/core/model/progress';
import { useLanguageForTests } from '../src/i18n';

useLanguageForTests('en');
const day = (d: number, hour = 10) => new Date(2026, 8, d, hour);

describe('the shop', () => {
  it('has unique ids, the payload each kind needs, and free choices for a new player', () => {
    const ids = shopItems.map((i) => i.id);
    expect(new Set(ids).size).toBe(ids.length);
    const field: Record<ShopKind, keyof typeof shopItems[number]> = {
      bodyColor: 'color', headColor: 'color', accentColor: 'color', hat: 'hat', face: 'face', pet: 'pet', trail: 'trail', aura: 'aura',
      nameplate: 'nameplate', bubble: 'bubble',
    };
    for (const item of shopItems) {
      expect(item[field[item.kind]], item.id).toBeDefined();
      expect(item.price).toBeGreaterThanOrEqual(0);
      expect(item.name.length).toBeGreaterThan(0);
    }
    const wallet = new PlayerWallet();
    for (const kind of ['bodyColor', 'headColor', 'accentColor'] as const) expect(wallet.ownedItems(kind).length).toBeGreaterThanOrEqual(4);
    expect(wallet.ownedItems('hat').length).toBeGreaterThan(0);
    expect(wallet.lockedItems('hat').length).toBeGreaterThan(0);
    expect(wallet.lockedItems('bodyColor').length).toBeGreaterThan(0);
    expect(shopItems.some((i) => rarity(i.price) === 'legendary')).toBe(true);
    // The iPad's ids, which a saved wallet keeps.
    for (const id of ['bodyColor.coral', 'headColor.chocolate', 'hat.crown', 'hat.top_hat', 'face.star_eyes', 'pet.unicorn', 'trail.rainbow', 'aura.galaxy', 'nameplate.gold', 'bubble.gold']) {
      expect(shopItem(id), id).toBeDefined();
    }
    expect(shopItem('bodyColor.cyan')!.price).toBe(20);
    expect(shopItem('bodyColor.mint')!.price).toBe(0);
  });

  it('earns, buys once, never goes below nothing and keeps a lifetime total', () => {
    const w = new PlayerWallet();
    w.earn(30);
    w.earn(20);
    w.earn(0);
    w.earn(-100);
    expect(w.coins).toBe(50);
    expect(w.lifetimeEarned).toBe(50);
    const crown = shopItem('hat.crown')!;
    expect(w.purchase(crown.id)).toEqual({ kind: 'notEnoughCoins', shortfall: crown.price - 50 });
    expect(w.coins).toBe(50);
    w.earn(500);
    expect(w.purchase(crown.id).kind).toBe('purchased');
    expect(w.owns(crown)).toBe(true);
    const after = w.coins;
    expect(w.purchase(crown.id).kind).toBe('alreadyOwned');
    expect(w.coins).toBe(after);
    expect(w.lifetimeEarned).toBe(550);
    expect(w.purchase('hat.sombrero').kind).toBe('unknownItem');
    expect(purchaseMessage({ kind: 'notEnoughCoins', shortfall: 1 })).toContain('1 more coin');
    expect(purchaseMessage({ kind: 'notEnoughCoins', shortfall: 5 })).toContain('5 more coins');
    const poor = new PlayerWallet();
    poor.earn(10);
    for (const item of shopItems) poor.purchase(item.id);
    expect(poor.coins).toBeGreaterThanOrEqual(0);
  });

  it('keeps free items owned after saving, including ones added later', () => {
    const w = new PlayerWallet(40, ['hat.crown'], 300);
    const back = PlayerWallet.decode(JSON.parse(JSON.stringify(w)));
    expect(back.coins).toBe(40);
    expect(back.owns('hat.crown')).toBe(true);
    expect(back.lifetimeEarned).toBe(300);
    const old = PlayerWallet.decode({ coins: 5 });
    for (const id of freeItemIDs()) expect(old.owns(id)).toBe(true);
    expect(old.owns(shopItems.find(isFree)!)).toBe(true);
    expect(old.refund('hat.crown', 100)).toBe(false);
  });

  it('turns a round into coins', () => {
    expect(CoinRate.coins(40)).toBe(40);
    expect(CoinRate.coins(-10)).toBe(0);
    expect(CoinRate.coins(40, true)).toBe(40 + CoinRate.roundCompletionBonus);
    expect([rarity(0), rarity(99), rarity(100), rarity(300), rarity(600)]).toEqual(['common', 'common', 'rare', 'epic', 'legendary']);
  });
});

describe('the daily bonus', () => {
  it('grows with the streak, once a day, up to a cap, and starts again after a missed day', () => {
    const b = new DailyBonus();
    expect(b.isWaiting(day(1))).toBe(true);
    expect(b.claim(day(1))).toBe(DailyBonus.base);
    expect(b.claim(day(1, 22))).toBeNull();
    expect(b.isWaiting(day(1, 23))).toBe(false);
    expect(b.claim(day(2))).toBe(DailyBonus.base + DailyBonus.perDay);
    expect(b.claim(day(3))).toBe(DailyBonus.base + 2 * DailyBonus.perDay);
    expect(b.streak).toBe(3);

    const m = new DailyBonus();
    m.claim(day(1));
    m.claim(day(2));
    expect(m.claim(day(4))).toBe(DailyBonus.base);
    expect(m.streak).toBe(1);

    const cap = new DailyBonus();
    let last = 0;
    for (let d = 1; d <= 20; d++) last = cap.claim(day(d)) ?? 0;
    expect(last).toBe(DailyBonus.maximum);

    const saved = new DailyBonus();
    saved.claim(day(5));
    const back = DailyBonus.decode(JSON.parse(JSON.stringify(saved)));
    expect(back.claim(day(5, 20))).toBeNull();
  });

  it('lets a week in a row cover one missed day', () => {
    const b = new DailyBonus();
    for (let d = 1; d <= 7; d++) b.claim(day(d));
    expect(b.freezes).toBe(1);
    expect(b.claim(day(9))).not.toBeNull();
    expect(b.streak).toBe(8);
    expect(b.freezes).toBe(0);
  });
});

describe('levels and badges', () => {
  it('needs more for each level', () => {
    expect([0, -50, 99, 100, 299, 300].map((x) => new PlayerLevel(x).number)).toEqual([1, 1, 1, 2, 2, 3]);
    const mid = new PlayerLevel(350);
    expect([mid.progress, mid.span]).toEqual([50, 300]);
    for (let level = 2; level <= 20; level++) {
      const start = PlayerLevel.experience(level);
      expect(new PlayerLevel(start).number).toBe(level);
      expect(new PlayerLevel(start - 1).number).toBe(level - 1);
    }
    const top = new PlayerLevel(Number.MAX_SAFE_INTEGER);
    expect([top.number, top.progress]).toEqual([PlayerLevel.maximum, 0]);
    expect([PlayerLevel.reward(1), PlayerLevel.reward(2), PlayerLevel.reward(99)]).toEqual([0, 70, 500]);
  });

  it('gets experience from playing, winning and missions', () => {
    const s = progressStats({ totalMinutes: 30, daysPlayed: 2 });
    expect(experience(s)).toBe(100);
    expect(levelOf(s).number).toBe(2);
    s.counters.roundsWon = 5;
    s.counters.missionsClaimed = 4;
    expect(experience(s)).toBe(250);
  });

  it('earns badges for what was done, and shows the nearest next', () => {
    expect(earnedBadges(progressStats())).toEqual([]);
    const s = progressStats({ gamesPlayed: 12, totalMinutes: 90, daysPlayed: 3, lifetimeCoins: 600, itemsOwned: 16, pictures: 2, worldsMade: 1, hasPet: true, bestStreak: 2 });
    expect(new Set(earnedBadges(s))).toEqual(new Set(['firstGame', 'explorer', 'playtime', 'saver', 'stylist', 'builder', 'petFriend']));
    expect(achievements.length).toBe(40);
    const t = progressStats();
    t.counters.roundsWon = 1;
    expect(isEarned('winner', t)).toBe(true);
    expect(badgeProgress('champion', t)).toEqual([1, 25]);
    t.counters.emotes = 45;
    const next = nextBadges(t);
    expect(next[0]).toBe('emoteFan');
    expect(next).not.toContain('winner');
    expect(next.length).toBeLessThanOrEqual(3);
    const titles = achievements.map(badgeTitle);
    expect(new Set(titles).size).toBe(titles.length);
    for (const a of achievements) expect(badgeDetail(a).length).toBeGreaterThan(0);
  });
});

describe('missions', () => {
  it('are the same three all day, differ from day to day, and never repeat a kind', () => {
    const a = MissionBook.missions('2026-09-28');
    expect(MissionBook.missions('2026-09-28')).toEqual(a);
    expect(a.length).toBe(3);
    expect(a[0].kind).toBe('playMinutes');
    expect(new Set(a.map((m) => m.kind)).size).toBe(3);
    const sets = new Set(Array.from({ length: 28 }, (_, i) => MissionBook.missions(`2026-10-${String(i + 1).padStart(2, '0')}`).map((m) => m.kind).join(',')));
    expect(sets.size).toBeGreaterThan(3);
  });

  it('count up, are claimed once, and start afresh the next day', () => {
    const d = '2026-09-28';
    const b = new MissionBook();
    const minutes = MissionBook.missions(d)[0];
    expect(b.claim(minutes, d)).toBeNull();
    b.record('playMinutes', minutes.target * 60 - 1, d);
    expect(b.isDone(minutes, d)).toBe(false);
    b.record('playMinutes', 1, d);
    expect(b.isDone(minutes, d)).toBe(true);
    expect(b.waitingRewards(d)).toBe(1);
    expect(b.claim(minutes, d)).toBe(minutes.reward);
    expect(b.claim(minutes, d)).toBeNull();
    expect(b.progress(minutes, '2026-09-29')).toBe(0);
    b.record('useEmote', 1, '2026-09-29');
    expect(b.isClaimed(minutes, '2026-09-29')).toBe(false);

    const g = new MissionBook();
    const different: Mission = { kind: 'differentGames', target: 2, reward: 26 };
    g.played('Obby', d);
    g.played('Obby', d);
    expect(g.progress(different, d)).toBe(1);
    g.played('Tycoon', d);
    expect(g.isDone(different, d)).toBe(true);

    const saved = new MissionBook();
    saved.record('takePicture', 1, d);
    saved.played('Obby', d);
    expect(MissionBook.decode(JSON.parse(JSON.stringify(saved))).toJSON()).toEqual(saved.toJSON());
  });

  it('give a bonus for all three, and one swap a day', () => {
    const d = '2026-10-16';
    const b = new MissionBook();
    const [, second] = b.missions(d);
    const swapped = b.swap(second, d)!;
    expect(swapped).not.toBeNull();
    expect(b.missions(d).map((m) => m.kind)).toContain(swapped.kind);
    expect(b.swap(b.missions(d)[2], d)).toBeNull();
    for (const m of b.missions(d)) {
      if (m.kind === 'playMinutes') b.record('playMinutes', m.target * 60, d);
      else if (m.kind === 'differentGames') for (let i = 0; i < m.target; i++) b.played('g' + i, d);
      else b.record(m.kind, m.target, d);
    }
    expect(b.isAllDoneBonusWaiting(d)).toBe(true);
    expect(b.claimAllDoneBonus(d)).toBe(MissionBook.allDoneBonus);
    expect(b.claimAllDoneBonus(d)).toBeNull();
  });

  it('match the iPad’s, with its swap and its pick, for every day of two years', () => {
    const fixture = JSON.parse(readFileSync(new URL('./fixtures/missions-swift.json', import.meta.url), 'utf8')) as {
      days: { day: string; missions: Mission[]; swap: Mission | null; pick: string }[];
    };
    expect(fixture.days.length).toBe(730);
    const listings = Array.from({ length: 37 }, (_, i) => ({ id: `game-${i + 1}` }));
    for (const entry of fixture.days) {
      const book = new MissionBook();
      const missions = book.missions(entry.day);
      expect(missions, entry.day).toEqual(entry.missions);
      expect(book.swap(missions[1], entry.day), entry.day).toEqual(entry.swap);
      const [y, m, d] = entry.day.split('-').map(Number);
      expect(dailyPick(listings, new Date(y, m - 1, d, 12))?.id, entry.day).toBe(entry.pick);
    }
  });
});
