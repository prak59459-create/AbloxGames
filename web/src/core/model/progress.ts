// A player's progress across every game (PlayerProgress.swift and
// DailyMissions.swift): the daily bonus, experience and levels, badges,
// today's pick from the catalogue and three missions a day. All rules, no
// screens, and the same answers as the iPad's for the same day.
import { L } from '../../i18n';

/** "2026-10-16", in this device's own calendar (PlaytimeLog.dayKey). */
export function dayKey(date: Date = new Date()): string {
  return `${String(date.getFullYear()).padStart(4, '0')}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
}

function addDays(date: Date, n: number): Date {
  const d = new Date(date.getTime());
  d.setDate(d.getDate() + n);
  return d;
}

// MARK: - Daily bonus

/** Coins for coming back: more for each day in a row, up to a cap. */
export class DailyBonus {
  static readonly base = 10;
  static readonly perDay = 5;
  static readonly maximum = 50;
  static readonly maximumFreezes = 2;

  lastDay: string | null = null;
  streak = 0;
  /** Days that may be missed without losing the streak: one for every seven days in a row, two at most. */
  freezes = 0;

  /** Coins to give today, or null when today's has been given. */
  claim(date: Date = new Date()): number | null {
    const today = dayKey(date);
    if (today === this.lastDay) return null;
    if (this.lastDay !== null && this.lastDay === dayKey(addDays(date, -1))) {
      this.streak += 1;
    } else if (this.lastDay !== null && this.lastDay === dayKey(addDays(date, -2)) && this.freezes > 0) {
      // One day missed, and a freeze to cover it.
      this.freezes -= 1;
      this.streak += 1;
    } else {
      this.streak = 1;
    }
    if (this.streak % 7 === 0) this.freezes = Math.min(DailyBonus.maximumFreezes, this.freezes + 1);
    this.lastDay = today;
    return Math.min(DailyBonus.maximum, DailyBonus.base + DailyBonus.perDay * (this.streak - 1));
  }

  isWaiting(date: Date = new Date()): boolean { return dayKey(date) !== this.lastDay; }

  toJSON() { return { lastDay: this.lastDay ?? undefined, streak: this.streak, freezes: this.freezes }; }

  static decode(v: unknown): DailyBonus {
    const o = (v && typeof v === 'object' ? v : {}) as Record<string, unknown>;
    const b = new DailyBonus();
    if (typeof o.lastDay === 'string') b.lastDay = o.lastDay;
    if (typeof o.streak === 'number') b.streak = Math.max(0, Math.trunc(o.streak));
    if (typeof o.freezes === 'number') b.freezes = Math.max(0, Math.min(DailyBonus.maximumFreezes, Math.trunc(o.freezes)));
    return b;
  }
}

// MARK: - Levels and badges

/** Things done over time that nothing else counts. */
export interface LifetimeCounters { emotes: number; stamps: number; roundsWon: number; missionsClaimed: number; lookCodesWorn: number; clipsSaved: number }
export const emptyCounters = (): LifetimeCounters => ({ emotes: 0, stamps: 0, roundsWon: 0, missionsClaimed: 0, lookCodesWorn: 0, clipsSaved: 0 });

export function decodeCounters(v: unknown): LifetimeCounters {
  const o = (v && typeof v === 'object' ? v : {}) as Record<string, unknown>;
  const c = emptyCounters();
  for (const k of Object.keys(c) as (keyof LifetimeCounters)[]) c[k] = Math.max(0, Math.trunc(typeof o[k] === 'number' ? (o[k] as number) : 0));
  return c;
}

export interface ProgressStats {
  gamesPlayed: number;
  totalMinutes: number;
  daysPlayed: number;
  lifetimeCoins: number;
  itemsOwned: number;
  pictures: number;
  worldsMade: number;
  hasPet: boolean;
  bestStreak: number;
  counters: LifetimeCounters;
  hatsOwned: number;
  petsOwned: number;
  trailsOwned: number;
  aurasOwned: number;
  friends: number;
  gamesLiked: number;
  outfitsSaved: number;
  mostPlaysOfOneGame: number;
}

export const progressStats = (s: Partial<ProgressStats> = {}): ProgressStats => ({
  gamesPlayed: 0, totalMinutes: 0, daysPlayed: 0, lifetimeCoins: 0, itemsOwned: 0, pictures: 0, worldsMade: 0, hasPet: false, bestStreak: 0,
  counters: emptyCounters(), hatsOwned: 0, petsOwned: 0, trailsOwned: 0, aurasOwned: 0, friends: 0, gamesLiked: 0, outfitsSaved: 0,
  mostPlaysOfOneGame: 0, ...s,
});

/** Experience, from everything done: time, days, wins and missions. */
export const experience = (s: ProgressStats) => s.totalMinutes * 2 + s.daysPlayed * 20 + s.counters.roundsWon * 10 + s.counters.missionsClaimed * 25;

/** Each level needs 100 more than the one before: 100 for level 2, 300 in all for level 3… */
export class PlayerLevel {
  static readonly maximum = 99;
  readonly number: number;
  readonly progress: number;
  readonly span: number;

  constructor(xp: number) {
    let level = 1;
    let remaining = Math.max(0, xp);
    while (level < PlayerLevel.maximum && remaining >= level * 100) {
      remaining -= level * 100;
      level += 1;
    }
    this.number = level;
    this.progress = level === PlayerLevel.maximum ? 0 : remaining;
    this.span = level * 100;
  }

  static experience(level: number): number {
    let total = 0;
    for (let l = 1; l < Math.max(1, level); l++) total += l * 100;
    return total;
  }

  static reward(level: number): number { return level <= 1 ? 0 : Math.min(500, 30 + level * 20); }
}

export const levelOf = (s: ProgressStats) => new PlayerLevel(experience(s));

interface BadgeSpec { title: string; detail: string; icon: string; progress: (s: ProgressStats) => [number, number] }

/** Badges earned across every game, each one a title to wear: the iPad's forty, in its order. */
export const badges = {
  firstGame: { title: 'Newcomer', detail: 'Play a game', icon: '✨', progress: (s) => [s.gamesPlayed, 1] },
  explorer: { title: 'Adventurer', detail: 'Play 10 different games', icon: '🗺️', progress: (s) => [s.gamesPlayed, 10] },
  globetrotter: { title: 'Globetrotter', detail: 'Play 30 different games', icon: '🌏', progress: (s) => [s.gamesPlayed, 30] },
  playtime: { title: 'Gamer', detail: 'Play for an hour in all', icon: '⏰', progress: (s) => [s.totalMinutes, 60] },
  marathon: { title: 'Marathon Player', detail: 'Play for 10 hours in all', icon: '🏃', progress: (s) => [s.totalMinutes, 600] },
  regular: { title: 'Regular', detail: 'Play on 7 different days', icon: '📅', progress: (s) => [s.daysPlayed, 7] },
  saver: { title: 'Saver', detail: 'Earn 500 coins', icon: '💵', progress: (s) => [s.lifetimeCoins, 500] },
  rich: { title: 'Rich', detail: 'Earn 3,000 coins', icon: '💰', progress: (s) => [s.lifetimeCoins, 3000] },
  tycoon: { title: 'Tycoon', detail: 'Earn 20,000 coins', icon: '👑', progress: (s) => [s.lifetimeCoins, 20000] },
  stylist: { title: 'Stylist', detail: 'Own 15 items', icon: '👕', progress: (s) => [s.itemsOwned, 15] },
  collector: { title: 'Collector', detail: 'Own 40 items', icon: '🧩', progress: (s) => [s.itemsOwned, 40] },
  photographer: { title: 'Photographer', detail: 'Take 10 pictures', icon: '📷', progress: (s) => [s.pictures, 10] },
  builder: { title: 'Builder', detail: 'Make a world of your own', icon: '🔨', progress: (s) => [s.worldsMade, 1] },
  petFriend: { title: 'Pet Friend', detail: 'Have a pet', icon: '🐾', progress: (s) => [s.hasPet ? 1 : 0, 1] },
  loyal: { title: 'Loyal', detail: 'Come back 7 days in a row', icon: '❤️', progress: (s) => [s.bestStreak, 7] },
  emoteFan: { title: 'Show-off', detail: 'Use 50 emotes', icon: '💃', progress: (s) => [s.counters.emotes, 50] },
  stampFan: { title: 'Stamp Fan', detail: 'Send 30 stamps', icon: '😊', progress: (s) => [s.counters.stamps, 30] },
  winner: { title: 'Winner', detail: 'Win a round', icon: '🏵️', progress: (s) => [s.counters.roundsWon, 1] },
  champion: { title: 'Champion', detail: 'Win 25 rounds', icon: '🏆', progress: (s) => [s.counters.roundsWon, 25] },
  missionStarter: { title: 'Go-getter', detail: 'Finish 10 missions', icon: '🎯', progress: (s) => [s.counters.missionsClaimed, 10] },
  missionMaster: { title: 'Mission Master', detail: 'Finish 60 missions', icon: '🔭', progress: (s) => [s.counters.missionsClaimed, 60] },
  hatCollector: { title: 'Hat Collector', detail: 'Own 10 hats', icon: '🎩', progress: (s) => [s.hatsOwned, 10] },
  petKeeper: { title: 'Zookeeper', detail: 'Own 5 pets', icon: '🐇', progress: (s) => [s.petsOwned, 5] },
  trailBlazer: { title: 'Trailblazer', detail: 'Own a trail', icon: '🌟', progress: (s) => [s.trailsOwned, 1] },
  glowing: { title: 'Glowing', detail: 'Own an aura', icon: '☀️', progress: (s) => [s.aurasOwned, 1] },
  friendly: { title: 'Friendly', detail: 'Make 3 friends', icon: '🧑‍🤝‍🧑', progress: (s) => [s.friends, 3] },
  popular: { title: 'Popular', detail: 'Make 15 friends', icon: '👨‍👩‍👧', progress: (s) => [s.friends, 15] },
  critic: { title: 'Critic', detail: 'Like 10 games', icon: '👍', progress: (s) => [s.gamesLiked, 10] },
  fashionista: { title: 'Fashionista', detail: 'Save 3 outfits', icon: '🧥', progress: (s) => [s.outfitsSaved, 3] },
  lookSharer: { title: 'Copycat', detail: "Wear a friend's look code", icon: '🔳', progress: (s) => [s.counters.lookCodesWorn, 1] },
  dedicated: { title: 'Dedicated', detail: 'Play on 30 different days', icon: '🗓️', progress: (s) => [s.daysPlayed, 30] },
  veteran: { title: 'Veteran', detail: 'Play on 100 different days', icon: '🎖️', progress: (s) => [s.daysPlayed, 100] },
  legend: { title: 'Legend', detail: 'Play for 50 hours in all', icon: '⭐', progress: (s) => [s.totalMinutes, 3000] },
  millionaire: { title: 'Coin Master', detail: 'Earn 100,000 coins', icon: '🪙', progress: (s) => [s.lifetimeCoins, 100000] },
  worldMaker: { title: 'World Maker', detail: 'Make 5 worlds', icon: '🧊', progress: (s) => [s.worldsMade, 5] },
  architect: { title: 'Architect', detail: 'Make 20 worlds', icon: '🏛️', progress: (s) => [s.worldsMade, 20] },
  superFan: { title: 'Super Fan', detail: 'Play one game 20 times', icon: '🎮', progress: (s) => [s.mostPlaysOfOneGame, 20] },
  streakMaster: { title: 'Streak Master', detail: 'Come back 30 days in a row', icon: '🔥', progress: (s) => [s.bestStreak, 30] },
  clipMaker: { title: 'Director', detail: 'Save 5 clips', icon: '🎬', progress: (s) => [s.counters.clipsSaved, 5] },
  levelTen: { title: 'Level 10', detail: 'Reach level 10', icon: '🔟', progress: (s) => [levelOf(s).number, 10] },
} satisfies Record<string, BadgeSpec>;

export type Achievement = keyof typeof badges;
export const achievements = Object.keys(badges) as Achievement[];
export const badgeTitle = (a: Achievement) => L(badges[a].title);
export const badgeDetail = (a: Achievement) => L(badges[a].detail);
export const badgeProgress = (a: Achievement, s: ProgressStats) => badges[a].progress(s);
export const isEarned = (a: Achievement, s: ProgressStats) => { const [c, t] = badgeProgress(a, s); return c >= t; };
export const earnedBadges = (s: ProgressStats) => achievements.filter((a) => isEarned(a, s));

/** The badges not yet earned that are closest, most done first. */
export function nextBadges(s: ProgressStats, count = 3): Achievement[] {
  const share = (a: Achievement) => { const [c, t] = badgeProgress(a, s); return Math.max(0, c) / Math.max(1, t); };
  // A stable sort, as Swift's is not guaranteed to be: ties keep the iPad's order.
  return achievements.filter((a) => !isEarned(a, s)).map((a, i) => ({ a, i, v: share(a) }))
    .sort((x, y) => y.v - x.v || x.i - y.i).slice(0, count).map((x) => x.a);
}

// MARK: - The catalogue in the menu

const fnvOffset = 0xcbf29ce484222325n, fnvPrime = 0x100000001b3n;
/** FNV-1a over UTF-8: the same on every device and every launch. */
export function stableHash(text: string): bigint {
  let hash = fnvOffset;
  for (const byte of new TextEncoder().encode(text)) hash = BigInt.asUintN(64, (hash ^ BigInt(byte)) * fnvPrime);
  return hash;
}

/** The same game for everyone all day, a different one tomorrow. */
export function dailyPick<T extends { id: string }>(listings: T[], date: Date = new Date()): T | null {
  if (!listings.length) return null;
  // The iPad multiplies by 0x1000_0000_01b3 here — one zero more than FNV's
  // prime — and it is the iPad's pick that everyone must agree on.
  let hash = fnvOffset;
  for (const byte of new TextEncoder().encode(dayKey(date))) hash = BigInt.asUintN(64, (hash ^ BigInt(byte)) * 0x1000000001b3n);
  const sorted = [...listings].sort((a, b) => (a.id < b.id ? -1 : a.id > b.id ? 1 : 0));
  return sorted[Number(hash % BigInt(sorted.length))];
}

// MARK: - Today's missions

export type MissionKind = 'playMinutes' | 'differentGames' | 'earnCoins' | 'takePicture' | 'useEmote' | 'playWithOthers' | 'finishRound';
export const missionKinds: MissionKind[] = ['playMinutes', 'differentGames', 'earnCoins', 'takePicture', 'useEmote', 'playWithOthers', 'finishRound'];

export interface Mission { kind: MissionKind; target: number; reward: number }
export const missionID = (m: Mission) => m.kind;

export function missionTitle(m: Mission): string {
  const t = m.target;
  switch (m.kind) {
    case 'playMinutes': return L('Play for {} minutes', t);
    case 'differentGames': return L('Play {} different games', t);
    case 'earnCoins': return L('Earn {} coins in games', t);
    case 'takePicture': return t === 1 ? L('Take a picture in a game') : L('Take {} pictures in games', t);
    case 'useEmote': return L('Use {} emotes', t);
    case 'playWithOthers': return L('Play with someone else');
    case 'finishRound': return t === 1 ? L('Finish a round') : L('Finish {} rounds', t);
  }
}

export function missionHint(kind: MissionKind): string {
  switch (kind) {
    case 'playMinutes': return L('Any game counts, alone or with friends.');
    case 'differentGames': return L('Try something new from the Games tab.');
    case 'earnCoins': return L('Score points and finish rounds.');
    case 'takePicture': return L('Tap the camera button while playing.');
    case 'useEmote': return L('Tap the smiley face while playing.');
    case 'playWithOthers': return L("Host a room or join a friend's.");
    case 'finishRound': return L("Reach the end of a game's round.");
  }
}

export const missionIcon: Record<MissionKind, string> = {
  playMinutes: '⏰', differentGames: '🎮', earnCoins: '🪙', takePicture: '📷', useEmote: '👋', playWithOthers: '🧑‍🤝‍🧑', finishRound: '🏁',
};

/** Today's three missions and how far along they are; a new day starts afresh. */
export class MissionBook {
  static readonly missionsPerDay = 3;
  static readonly allDoneBonus = 40;

  day = '';
  /** Progress by kind: play time in seconds, the rest as counts. */
  counts: Partial<Record<MissionKind, number>> = {};
  games: string[] = [];
  claimed = new Set<string>();
  swapped: Partial<Record<MissionKind, MissionKind>> | null = null;

  /** The same three for everyone on the same day: always some play time, then two others (the iPad's own sums). */
  static missions(day: string): Mission[] {
    let seed = stableHash(day);
    const next = (bound: number) => {
      seed = BigInt.asUintN(64, seed * 6364136223846793005n + 1442695040888963407n);
      return Number((seed >> 33n) % BigInt(bound));
    };
    const minutes = [10, 15, 20][next(3)];
    const missions: Mission[] = [{ kind: 'playMinutes', target: minutes, reward: 10 + minutes }];
    const others: MissionKind[] = ['differentGames', 'earnCoins', 'takePicture', 'useEmote', 'playWithOthers', 'finishRound'];
    while (missions.length < MissionBook.missionsPerDay && others.length) {
      const kind = others.splice(next(others.length), 1)[0];
      let target: number, reward: number;
      switch (kind) {
        case 'differentGames': target = [2, 3][next(2)]; reward = 10 + 8 * target; break;
        case 'earnCoins': target = [30, 50, 80][next(3)]; reward = 10 + Math.trunc(target / 5); break;
        case 'takePicture': target = 1; reward = 15; break;
        case 'useEmote': target = 3; reward = 15; break;
        case 'playWithOthers': target = 1; reward = 30; break;
        case 'finishRound': target = [1, 2][next(2)]; reward = 5 + 15 * target; break;
        default: target = 10; reward = 20;
      }
      missions.push({ kind, target, reward });
    }
    return missions;
  }

  static standard(kind: MissionKind): Mission {
    switch (kind) {
      case 'playMinutes': return { kind, target: 10, reward: 20 };
      case 'differentGames': return { kind, target: 2, reward: 26 };
      case 'earnCoins': return { kind, target: 50, reward: 20 };
      case 'takePicture': return { kind, target: 1, reward: 15 };
      case 'useEmote': return { kind, target: 3, reward: 15 };
      case 'playWithOthers': return { kind, target: 1, reward: 30 };
      case 'finishRound': return { kind, target: 1, reward: 20 };
    }
  }

  missions(day: string): Mission[] {
    const base = MissionBook.missions(day);
    if (day !== this.day || !this.swapped || !Object.keys(this.swapped).length) return base;
    return base.map((m) => (this.swapped![m.kind] ? MissionBook.standard(this.swapped![m.kind]!) : m));
  }

  canSwap(m: Mission, day: string): boolean {
    const unused = day !== this.day || !this.swapped || !Object.keys(this.swapped).length;
    return unused && m.kind !== 'playMinutes' && !this.isDone(m, day) && !this.isClaimed(m, day);
  }

  swap(m: Mission, day: string): Mission | null {
    this.roll(day);
    if (!this.canSwap(m, day)) return null;
    const current = new Set(this.missions(day).map((x) => x.kind));
    const choices = missionKinds.filter((k) => !current.has(k) && k !== 'playMinutes');
    if (!choices.length) return null;
    const kind = choices[Number(stableHash('swap:' + day + m.kind) % BigInt(choices.length))];
    this.swapped = { [m.kind]: kind };
    return MissionBook.standard(kind);
  }

  allDone(day: string): boolean { return this.missions(day).every((m) => this.isDone(m, day)); }
  isAllDoneBonusWaiting(day: string): boolean { return this.allDone(day) && !(day === this.day && this.claimed.has('all')); }

  claimAllDoneBonus(day: string): number | null {
    this.roll(day);
    if (!this.allDone(day) || this.claimed.has('all')) return null;
    this.claimed.add('all');
    return MissionBook.allDoneBonus;
  }

  roll(day: string): void {
    if (day === this.day) return;
    this.day = day;
    this.counts = {};
    this.games = [];
    this.claimed = new Set();
    this.swapped = null;
  }

  record(kind: MissionKind, amount: number, day: string): void {
    this.roll(day);
    if (!(amount > 0)) return;
    this.counts[kind] = (this.counts[kind] ?? 0) + Math.trunc(amount);
  }

  played(game: string, day: string): void {
    this.roll(day);
    if (!game || this.games.includes(game)) return;
    this.games.push(game);
    if (this.games.length > 20) this.games.splice(0, this.games.length - 20);
  }

  progress(m: Mission, day: string): number {
    if (day !== this.day) return 0;
    if (m.kind === 'playMinutes') return Math.floor((this.counts.playMinutes ?? 0) / 60);
    if (m.kind === 'differentGames') return this.games.length;
    return this.counts[m.kind] ?? 0;
  }

  isDone(m: Mission, day: string): boolean { return this.progress(m, day) >= m.target; }
  isClaimed(m: Mission, day: string): boolean { return day === this.day && this.claimed.has(m.kind); }

  claim(m: Mission, day: string): number | null {
    this.roll(day);
    if (!this.isDone(m, day) || this.claimed.has(m.kind)) return null;
    this.claimed.add(m.kind);
    return m.reward;
  }

  waitingRewards(day: string): number { return this.missions(day).filter((m) => this.isDone(m, day) && !this.isClaimed(m, day)).length; }
  done(day: string): Set<string> { return new Set(this.missions(day).filter((m) => this.isDone(m, day)).map((m) => m.kind)); }

  toJSON() {
    return { day: this.day, counts: this.counts, games: this.games, claimed: [...this.claimed].sort(), ...(this.swapped ? { swapped: this.swapped } : {}) };
  }

  static decode(v: unknown): MissionBook {
    const o = (v && typeof v === 'object' ? v : {}) as Record<string, unknown>;
    const b = new MissionBook();
    if (typeof o.day === 'string') b.day = o.day;
    if (o.counts && typeof o.counts === 'object') {
      for (const [k, n] of Object.entries(o.counts as Record<string, unknown>)) {
        if ((missionKinds as string[]).includes(k) && typeof n === 'number') b.counts[k as MissionKind] = Math.max(0, Math.trunc(n));
      }
    }
    if (Array.isArray(o.games)) b.games = o.games.filter((g): g is string => typeof g === 'string').slice(-20);
    if (Array.isArray(o.claimed)) b.claimed = new Set(o.claimed.filter((g): g is string => typeof g === 'string'));
    if (o.swapped && typeof o.swapped === 'object') {
      const s: Partial<Record<MissionKind, MissionKind>> = {};
      for (const [k, n] of Object.entries(o.swapped as Record<string, unknown>)) {
        if ((missionKinds as string[]).includes(k) && (missionKinds as unknown[]).includes(n)) s[k as MissionKind] = n as MissionKind;
      }
      b.swapped = s;
    }
    return b;
  }
}
