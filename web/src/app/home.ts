// Home: who you are and what is waiting today — the daily bonus, three
// missions, the games you were playing, today's pick, the Plaza and the
// rooms open now. Everything here is one tap from playing.
import { roomIsCompatible, roomIsFull } from '../core/model/cloud';
import {
  DailyBonus, MissionBook, badgeDetail, badgeProgress, badgeTitle, badges, dailyPick, dayKey, missionHint, missionIcon, missionTitle, nextBadges,
  type Mission,
} from '../core/model/progress';
import { L } from '../i18n';
import { coverURL, type GameListing } from '../net/catalogue';
import { AvatarStage } from './avatarStage';
import { coinBurst } from './effects';
import { card, formatNumber, icon, img, meter, type ShellContext, type ShellPage } from './shell';
import { el } from './sheets';

function greeting(name: string, now = new Date()): string {
  const h = now.getHours();
  if (h >= 5 && h < 11) return L('Good morning, {}!', name);
  if (h >= 11 && h < 17) return L('Good afternoon, {}!', name);
  return L('Good evening, {}!', name);
}

/** Whole hours until midnight, when the missions change. */
function hoursUntilTomorrow(now = new Date()): number {
  const midnight = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1);
  return Math.max(1, Math.ceil((midnight.getTime() - now.getTime()) / 3_600_000));
}

/** What the daily bonus gives on a given day of a streak. */
const bonusOnDay = (day: number) => Math.min(DailyBonus.maximum, DailyBonus.base + DailyBonus.perDay * (Math.max(1, day) - 1));

export class HomePage implements ShellPage {
  readonly root: HTMLElement;
  private stage: AvatarStage | null = null;
  private stageBox: HTMLElement | null = null;
  private dynamic: HTMLElement;
  private unwatch: () => void = () => {};

  constructor(parent: HTMLElement, private readonly ctx: ShellContext) {
    this.root = el('div', 'ab-tab ab-home', parent);
    const hero = el('section', 'ab-hero', this.root);
    this.stageBox = el('div', 'ab-hero-stage', hero);
    this.stageBox.title = L('Change my look');
    this.stageBox.onclick = () => ctx.go('me');
    try {
      this.stage = new AvatarStage(this.stageBox, ctx.profile(), { zoom: 1.05 });
    } catch {
      // No WebGL here: the mascot stands in.
      img(new URL('icons/mascot.webp', document.baseURI).href, this.stageBox, '', 'ab-hero-mascot');
    }
    el('div', 'ab-hero-who', hero);
    this.dynamic = el('div', 'ab-home-grid', this.root);
    if (ctx.internet.allowsInternetPlay) this.unwatch = ctx.watchRooms();
    this.redraw();
  }

  redraw(): void {
    const ctx = this.ctx;
    const r = ctx.record;
    const profile = ctx.profile();
    this.stage?.show(profile);

    // Who you are.
    const who = this.root.querySelector('.ab-hero-who') as HTMLElement;
    who.innerHTML = '';
    el('h1', '', who, greeting(profile.displayName));
    if (profile.title) el('div', 'ab-hero-title', who, profile.title);
    const level = r.level;
    const pills = el('div', 'ab-pills', who);
    const lp = el('span', 'ab-pill level', pills);
    icon('level', lp);
    el('b', '', lp, L('Level {}', level.number));
    const cp = el('span', 'ab-pill coins', pills);
    icon('coin', cp);
    el('b', '', cp, formatNumber(r.wallet.coins));
    const streak = r.bonus.streak;
    if (streak > 1) {
      const sp = el('span', 'ab-pill streak', pills, '🔥 ');
      el('b', '', sp, L('{} days in a row', streak));
    }
    meter(who, level.span ? level.progress / level.span : 1, 'xp');
    el('small', 'ab-hero-note', who, level.number >= 99 ? L('Level {}', level.number)
      : L('{} more to level {}. Play, win and finish missions.', level.span - level.progress, level.number + 1));
    const actions = el('div', 'ab-hero-actions', who);
    const look = el('button', 'ab-block secondary', actions);
    icon('me-shirt', look);
    el('span', '', look, L('Change my look'));
    look.onclick = () => ctx.go('me');
    const plaza = el('button', 'ab-block', actions);
    icon('mascot', plaza);
    el('span', '', plaza, L('Go to the Plaza'));
    plaza.onclick = () => ctx.go('plaza');

    // What is waiting today.
    const grid = this.dynamic;
    grid.innerHTML = '';
    // Two columns side by side: the bonus and the badges nearly earned, then the missions.
    const left = el('div', 'ab-home-col', grid);
    this.drawBonus(left);
    this.drawNearly(left);
    this.drawMissions(el('div', 'ab-home-col', grid));
    this.drawPick(grid);
    this.drawRecent(grid);
    this.drawRooms(grid);
  }

  private drawBonus(grid: HTMLElement): void {
    const r = this.ctx.record;
    const { card: c, body } = card(grid, L('Daily bonus'), 'bell', 'ab-bonus');
    const waiting = r.bonus.isWaiting();
    // Where today falls in the week of the streak.
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    const continuing = r.bonus.lastDay === r.today || r.bonus.lastDay === dayKey(yesterday);
    const todayStreak = waiting ? (continuing ? r.bonus.streak + 1 : 1) : r.bonus.streak;
    const week = el('div', 'ab-week', body);
    const first = Math.floor((todayStreak - 1) / 7) * 7 + 1;
    for (let d = first; d < first + 7; d++) {
      const cell = el('div', 'day' + (d < todayStreak || (d === todayStreak && !waiting) ? ' got' : d === todayStreak ? ' today' : ''), week);
      el('small', '', cell, L('Day {}', d));
      icon('coin', cell);
      el('b', '', cell, String(bonusOnDay(d)));
    }
    if (waiting) {
      const take = el('button', 'ab-block gold big', body);
      icon('coin', take);
      el('span', '', take, L('Take {}', bonusOnDay(todayStreak)));
      take.onclick = () => {
        const coins = r.claimDailyBonus();
        if (coins === null) return;
        coinBurst(take);
        this.ctx.toast(L('+{} coins', coins), 'coins');
      };
      c.classList.add('waiting');
    } else {
      el('div', 'ab-note', body, L('Come back tomorrow for {} coins.', bonusOnDay(r.bonus.streak + 1)));
    }
    if (r.bonus.freezes > 0) el('div', 'ab-note', body, '❄️ ' + L('{} days you can miss', r.bonus.freezes));
  }

  /** The badges closest to being earned, as goals. */
  private drawNearly(parent: HTMLElement): void {
    const stats = this.ctx.record.stats();
    const next = nextBadges(stats, 3);
    if (!next.length) return;
    const { body, head } = card(parent, L('Nearly there'), 'me-trophies', 'ab-nearly');
    const all = el('button', 'ab-link', head, L('Badges') + ' ›');
    all.onclick = () => this.ctx.go('me/badges');
    for (const a of next) {
      const [c, t] = badgeProgress(a, stats);
      const row = el('div', 'ab-nearly-row', body);
      el('span', 'emoji', row, badges[a].icon);
      const text = el('div', 'text', row);
      el('b', '', text, badgeTitle(a));
      el('small', '', text, badgeDetail(a));
      meter(text, Math.max(0, c) / Math.max(1, t));
      el('span', 'count', row, `${Math.min(c, t)}/${t}`);
    }
  }

  private drawMissions(grid: HTMLElement): void {
    const r = this.ctx.record;
    const day = r.today;
    const book = r.missions;
    const { head, body } = card(grid, L("Today's missions"), 'mission', 'ab-missions');
    el('span', 'ab-box-side', head, L('New in {} h', hoursUntilTomorrow()));
    for (const m of r.todaysMissions) this.missionRow(body, m, book, day);
    if (book.isAllDoneBonusWaiting(day)) {
      const all = el('button', 'ab-block gold', body);
      icon('coin', all);
      el('span', '', all, L('All done! Take {} more', MissionBook.allDoneBonus));
      all.onclick = () => {
        const coins = r.claimAllDone();
        if (coins === null) return;
        coinBurst(all);
        this.ctx.toast(L('+{} coins', coins), 'coins');
      };
    } else if (book.allDone(day)) {
      el('div', 'ab-note good', body, '🎉 ' + L('All of today’s missions are done!'));
    }
  }

  private missionRow(parent: HTMLElement, m: Mission, book: MissionBook, day: string): void {
    const r = this.ctx.record;
    const done = book.isDone(m, day), claimed = book.isClaimed(m, day);
    const row = el('div', 'ab-mission' + (claimed ? ' claimed' : done ? ' done' : ''), parent);
    el('div', 'emoji', row, missionIcon[m.kind]);
    const text = el('div', 'text', row);
    el('b', '', text, missionTitle(m));
    el('small', '', text, missionHint(m.kind));
    const progress = Math.min(m.target, book.progress(m, day));
    const line = el('div', 'line', text);
    meter(line, progress / m.target);
    el('span', 'count', line, `${progress}/${m.target}`);
    const side = el('div', 'side', row);
    if (claimed) {
      el('span', 'tick', side, '✓');
    } else if (done) {
      const take = el('button', 'ab-block green', side);
      icon('coin', take);
      el('span', '', take, String(m.reward));
      take.title = L('Take {}', m.reward);
      take.onclick = () => {
        const coins = r.claim(m);
        if (coins === null) return;
        coinBurst(take);
        this.ctx.toast(L('+{} coins', coins), 'coins');
      };
    } else {
      const reward = el('span', 'reward', side);
      icon('coin', reward);
      el('span', '', reward, String(m.reward));
      if (book.canSwap(m, day)) {
        const swap = el('button', 'ab-swap', side, '⟳');
        swap.title = L('Swap for another mission');
        swap.setAttribute('aria-label', L('Swap for another mission'));
        swap.onclick = () => {
          if (r.swap(m)) this.ctx.sound.play('pop');
        };
      }
    }
  }

  private drawPick(grid: HTMLElement): void {
    const games = this.ctx.games();
    const pick = dailyPick(games);
    if (!pick) return;
    const banner = el('section', 'ab-pick', grid);
    const url = coverURL(pick);
    if (url) img(url, banner, pick.title, 'bg');
    const text = el('div', 'text', banner);
    const label = el('span', 'label', text);
    icon('cat-popular', label);
    el('span', '', label, L("Today's pick"));
    el('h2', '', text, pick.title);
    el('p', '', text, pick.summary);
    const row = el('div', 'row', text);
    const play = el('button', 'ab-block green', row);
    icon('tool-play', play);
    el('span', '', play, L('Play'));
    play.onclick = (e) => { e.stopPropagation(); this.ctx.go(`play/${pick.id}`); };
    const more = el('button', 'ab-block secondary', row, L('Details'));
    more.onclick = (e) => { e.stopPropagation(); this.ctx.go(`game/${pick.id}`); };
    banner.onclick = () => this.ctx.go(`game/${pick.id}`);
  }

  private drawRecent(grid: HTMLElement): void {
    const games = this.ctx.games();
    const byID = new Map(games.map((g) => [g.id, g]));
    const recent = this.ctx.record.recent.map((p) => ({ played: p, game: byID.get(p.id) })).filter((x): x is { played: typeof x.played; game: GameListing } => !!x.game).slice(0, 10);
    const { body, head } = card(grid, recent.length ? L('Continue playing') : L('Find a game'), 'continue', 'ab-recent wide');
    const all = el('button', 'ab-link', head, L('All games') + ' ›');
    all.onclick = () => this.ctx.go('games');
    const shelf = el('div', 'ab-shelf', body);
    const list = recent.length ? recent.map((x) => x.game) : games.filter((g) => g.tags.includes('top20')).slice(0, 10);
    if (!list.length) {
      el('div', 'ab-note', body, games.length ? L('Games you play show up here.') : L('Loading the game list…'));
      return;
    }
    for (const g of list) {
      const tile = el('button', 'ab-tile', shelf);
      const cover = el('div', 'cover', tile);
      const url = coverURL(g);
      if (url) img(url, cover, g.title);
      const played = this.ctx.record.games.get(g.id);
      if (played) el('span', 'plays', cover, L('{} plays', played.plays));
      el('b', '', tile, g.title);
      tile.onclick = () => this.ctx.go(`game/${g.id}`);
    }
  }

  private drawRooms(grid: HTMLElement): void {
    const internet = this.ctx.internet;
    const { body, head } = card(grid, L('Internet rooms'), 'friends', 'ab-home-rooms wide');
    if (!internet.allowsInternetPlay) {
      el('div', 'ab-note', body, L('Internet rooms are off. A grown-up can turn them on in Settings → Family.'));
      return;
    }
    const see = el('button', 'ab-link', head, L('See all') + ' ›');
    see.onclick = () => this.ctx.go('rooms');
    const rooms = internet.rooms.filter((room) => !roomIsFull(room) && roomIsCompatible(room)).slice(0, 4);
    if (!rooms.length) {
      el('div', 'ab-note', body, internet.state.kind === 'ready' ? L('No rooms are open right now.') : L('Looking for rooms…'));
      return;
    }
    for (const room of rooms) {
      const row = el('div', 'ab-room-row', body);
      const who = el('div', 'who', row);
      el('b', '', who, room.world);
      el('small', '', who, L('Hosted by {}', room.hostName) + ' · ' + L('{} of {} players', room.players, room.capacity));
      const join = el('button', 'ab-block green', row, L('Join'));
      join.onclick = () => this.ctx.go(`join/${room.id}`);
    }
  }

  dispose(): void {
    this.unwatch();
    this.stage?.dispose();
    this.stage = null;
    this.root.remove();
  }
}

