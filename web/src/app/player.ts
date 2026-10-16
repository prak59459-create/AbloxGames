// What this browser's player has done and owns (the iPad's AppSettings:
// the wallet, the daily bonus, today's missions, play time and the counters
// behind badges and levels). Kept in this browser; nothing here leaves it.
import type { AvatarProfile } from '../core/model/avatar';
import { CoinRate, PlayerWallet, shopItem, type PurchaseResult, type ShopItem } from '../core/model/economy';
import {
  DailyBonus, MissionBook, PlayerLevel, dayKey, decodeCounters, emptyCounters, levelOf, missionTitle, progressStats,
  type LifetimeCounters, type Mission, type MissionKind, type ProgressStats,
} from '../core/model/progress';
import { L } from '../i18n';

function storage(): Storage | null {
  try { return typeof localStorage === 'undefined' ? null : localStorage; } catch { return null; }
}

const key = 'ablox.player';

/** A game this player has opened. */
export interface PlayedGame { id: string; title: string; plays: number; lastPlayed: string; best: number }

export class PlayerRecord {
  wallet = new PlayerWallet();
  bonus = new DailyBonus();
  missions = new MissionBook();
  counters: LifetimeCounters = emptyCounters();
  secondsPlayed = 0;
  days = new Set<string>();
  games = new Map<string, PlayedGame>();
  liked = new Set<string>();
  pictures = 0;
  /** The level whose reward has been given, so a level is rewarded once. */
  rewardedLevel = 1;
  /** The day a room was last opened here (the iPad's FirstTimes.hostedDay). */
  hostedDay = '';
  /** The longest run of days in a row, which a missed day does not take away. */
  bestStreak = 0;
  private listeners = new Set<() => void>();

  // The iPad's FirstTimes amounts.
  static readonly newGameCoins = 10;
  static readonly hostCoins = 10;
  static readonly keptGames = 1000;

  constructor(private readonly store: Storage | null = storage()) {
    this.load();
  }

  subscribe(l: () => void): () => void {
    this.listeners.add(l);
    return () => { this.listeners.delete(l); };
  }

  private changed(): void {
    this.save();
    for (const l of [...this.listeners]) l();
  }

  // MARK: Kept

  private load(): void {
    let o: Record<string, unknown> = {};
    try { o = JSON.parse(this.store?.getItem(key) ?? '{}') ?? {}; } catch { /* a fresh start */ }
    this.wallet = PlayerWallet.decode(o.wallet);
    this.bonus = DailyBonus.decode(o.bonus);
    this.missions = MissionBook.decode(o.missions);
    this.counters = decodeCounters(o.counters);
    this.secondsPlayed = typeof o.secondsPlayed === 'number' ? Math.max(0, o.secondsPlayed) : 0;
    this.days = new Set(Array.isArray(o.days) ? o.days.filter((d): d is string => typeof d === 'string') : []);
    this.games = new Map();
    if (Array.isArray(o.games)) {
      for (const g of o.games as PlayedGame[]) {
        if (g && typeof g.id === 'string') this.games.set(g.id, { id: g.id, title: String(g.title ?? g.id), plays: Number(g.plays) || 0, lastPlayed: String(g.lastPlayed ?? ''), best: Number(g.best) || 0 });
      }
    }
    this.liked = new Set(Array.isArray(o.liked) ? o.liked.filter((d): d is string => typeof d === 'string') : []);
    this.pictures = typeof o.pictures === 'number' ? Math.max(0, o.pictures) : 0;
    this.rewardedLevel = typeof o.rewardedLevel === 'number' ? Math.max(1, o.rewardedLevel) : levelOf(this.stats()).number;
    this.hostedDay = typeof o.hostedDay === 'string' ? o.hostedDay : '';
    this.bestStreak = Math.max(this.bonus.streak, typeof o.bestStreak === 'number' ? Math.trunc(o.bestStreak) : 0);
  }

  save(): void {
    try {
      this.store?.setItem(key, JSON.stringify({
        wallet: this.wallet, bonus: this.bonus, missions: this.missions, counters: this.counters, secondsPlayed: Math.round(this.secondsPlayed),
        days: [...this.days].sort().slice(-400), games: [...this.games.values()], liked: [...this.liked], pictures: this.pictures,
        rewardedLevel: this.rewardedLevel, hostedDay: this.hostedDay, bestStreak: this.bestStreak,
      }));
    } catch { /* full or private: kept for this visit */ }
  }

  // MARK: What it adds up to

  stats(): ProgressStats {
    const owned = (kind: string) => [...this.wallet.owned].filter((id) => id.startsWith(kind + '.') && (shopItem(id)?.price ?? 0) > 0).length;
    return progressStats({
      gamesPlayed: this.games.size,
      totalMinutes: Math.floor(this.secondsPlayed / 60),
      daysPlayed: this.days.size,
      lifetimeCoins: this.wallet.lifetimeEarned,
      itemsOwned: [...this.wallet.owned].filter((id) => (shopItem(id)?.price ?? 0) > 0).length,
      pictures: this.pictures,
      hasPet: [...this.wallet.owned].some((id) => id.startsWith('pet.') && id !== 'pet.none'),
      bestStreak: Math.max(this.bestStreak, this.bonus.streak),
      counters: { ...this.counters },
      hatsOwned: owned('hat'),
      petsOwned: owned('pet'),
      trailsOwned: owned('trail'),
      aurasOwned: owned('aura'),
      gamesLiked: this.liked.size,
      mostPlaysOfOneGame: Math.max(0, ...[...this.games.values()].map((g) => g.plays)),
    });
  }

  get level(): PlayerLevel { return levelOf(this.stats()); }
  get today(): string { return dayKey(); }
  get todaysMissions(): Mission[] { return this.missions.missions(this.today); }

  /** Recently played first. */
  get recent(): PlayedGame[] {
    return [...this.games.values()].filter((g) => g.lastPlayed).sort((a, b) => b.lastPlayed.localeCompare(a.lastPlayed));
  }

  // MARK: Playing (what the play screen reports)

  /** Missions finished by a change, to say so while playing. */
  private finished(change: () => void): string[] {
    const day = this.today;
    const before = this.missions.done(day);
    change();
    const after = this.missions.done(day);
    return this.missions.missions(day).filter((m) => after.has(m.kind) && !before.has(m.kind)).map((m) => L('Mission done: {}', missionTitle(m)));
  }

  private mission(kind: MissionKind, amount = 1): string[] {
    const out = this.finished(() => this.missions.record(kind, amount, this.today));
    this.changed();
    return out;
  }

  /** A game opened: counted once for "different games", and in the list of games played. The first visit to a game earns a little. */
  startedGame(id: string, title: string): string[] {
    const known = this.games.get(id);
    const g = known ?? { id, title, plays: 0, lastPlayed: '', best: 0 };
    g.title = title;
    g.plays += 1;
    g.lastPlayed = new Date().toISOString();
    this.games.set(id, g);
    this.days.add(this.today);
    const out = this.finished(() => this.missions.played(title, this.today));
    if (!known && this.games.size <= PlayerRecord.keptGames) {
      this.wallet.earn(PlayerRecord.newGameCoins);
      out.unshift(L('First visit here: +{} coins', PlayerRecord.newGameCoins));
    }
    this.changed();
    return out;
  }

  /** Coins the first time today a room is opened here. */
  hosted(): string[] {
    if (this.hostedDay === this.today) return [];
    this.hostedDay = this.today;
    this.wallet.earn(PlayerRecord.hostCoins);
    this.changed();
    return [L('Hosting a room: +{} coins', PlayerRecord.hostCoins)];
  }

  /** Time played, while the game is in front. */
  played(seconds: number): string[] {
    if (!(seconds > 0)) return [];
    this.secondsPlayed += seconds;
    this.days.add(this.today);
    return [...this.mission('playMinutes', Math.round(seconds)), ...this.levelUp()];
  }

  playedWithOthers(): string[] { return this.mission('playWithOthers'); }

  /** A round's score as coins, once a round. */
  roundOver(game: string, score: number, completed: boolean): string[] {
    const g = this.games.get(game);
    if (g && score > g.best) g.best = score;
    const coins = CoinRate.coins(score, completed);
    this.wallet.earn(coins);
    const out = [...this.mission('earnCoins', coins)];
    if (completed) {
      this.counters.roundsWon += 1;
      out.push(...this.mission('finishRound'));
    }
    if (coins > 0) out.unshift(L('+{} coins', coins));
    return [...out, ...this.levelUp()];
  }

  emote(): string[] {
    this.counters.emotes += 1;
    return this.mission('useEmote');
  }

  picture(): string[] {
    this.pictures += 1;
    return this.mission('takePicture');
  }

  /** Coins for reaching a new level, once each. */
  private levelUp(): string[] {
    const now = this.level.number;
    if (now <= this.rewardedLevel) return [];
    let coins = 0;
    for (let l = this.rewardedLevel + 1; l <= now; l++) coins += PlayerLevel.reward(l);
    this.rewardedLevel = now;
    this.wallet.earn(coins);
    this.changed();
    return [L('Level {}! +{} coins', now, coins)];
  }

  // MARK: Rewards

  claimDailyBonus(): number | null {
    const coins = this.bonus.claim();
    if (coins === null) return null;
    this.wallet.earn(coins);
    this.days.add(this.today);
    this.bestStreak = Math.max(this.bestStreak, this.bonus.streak);
    this.changed();
    return coins;
  }

  claim(mission: Mission): number | null {
    const coins = this.missions.claim(mission, this.today);
    if (coins === null) return null;
    this.wallet.earn(coins);
    this.counters.missionsClaimed += 1;
    this.levelUp();
    this.changed();
    return coins;
  }

  claimAllDone(): number | null {
    const coins = this.missions.claimAllDoneBonus(this.today);
    if (coins === null) return null;
    this.wallet.earn(coins);
    this.changed();
    return coins;
  }

  swap(mission: Mission): Mission | null {
    const next = this.missions.swap(mission, this.today);
    if (next) this.changed();
    return next;
  }

  buy(item: ShopItem): PurchaseResult {
    const result = this.wallet.purchase(item.id);
    if (result.kind === 'purchased') this.changed();
    return result;
  }

  toggleLike(game: string): boolean {
    if (this.liked.has(game)) this.liked.delete(game); else this.liked.add(game);
    this.changed();
    return this.liked.has(game);
  }
}

/** What an item puts on the avatar. */
export function wearing(profile: AvatarProfile, item: ShopItem): AvatarProfile {
  const p = { ...profile };
  switch (item.kind) {
    case 'bodyColor': p.bodyColor = item.color!; break;
    case 'headColor': p.headColor = item.color!; break;
    case 'accentColor': p.accentColor = item.color!; break;
    case 'hat': p.hat = item.hat!; break;
    case 'face': p.face = item.face!; break;
    case 'pet': p.pet = item.pet!; break;
    case 'trail': p.trail = item.trail!; break;
    case 'aura': p.aura = item.aura!; break;
    case 'nameplate': p.nameplate = item.nameplate!; break;
    case 'bubble': p.bubble = item.bubble!; break;
  }
  return p;
}

/** Whether the avatar has this item on. */
export function isWorn(profile: AvatarProfile, item: ShopItem): boolean {
  const same = (a: { r: number; g: number; b: number }, b?: { r: number; g: number; b: number }) =>
    !!b && Math.abs(a.r - b.r) < 0.004 && Math.abs(a.g - b.g) < 0.004 && Math.abs(a.b - b.b) < 0.004;
  switch (item.kind) {
    case 'bodyColor': return same(profile.bodyColor, item.color);
    case 'headColor': return same(profile.headColor, item.color);
    case 'accentColor': return same(profile.accentColor, item.color);
    case 'hat': return profile.hat === item.hat;
    case 'face': return profile.face === item.face;
    case 'pet': return profile.pet === item.pet;
    case 'trail': return profile.trail === item.trail;
    case 'aura': return profile.aura === item.aura;
    case 'nameplate': return profile.nameplate === item.nameplate;
    case 'bubble': return profile.bubble === item.bubble;
  }
}
