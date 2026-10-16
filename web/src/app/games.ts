// Play: every game in the list, by kind, with a search; the games you
// liked; and the internet rooms open now.
import { roomIsCompatible, roomIsFull, type CloudRoom } from '../core/model/cloud';
import { L } from '../i18n';
import { coverURL, stableGameID, type GameListing } from '../net/catalogue';
import type { InternetRooms } from '../net/internet';
import { icon, img, type ShellContext, type ShellPage } from './shell';
import { askGrownUp, el, familySheet } from './sheets';

interface Category { id: string; name: string; icon: string; tags: string[] }
export const categories: Category[] = [
  { id: 'all', name: 'All', icon: 'continue', tags: [] },
  { id: 'rooms', name: 'Internet rooms', icon: 'friends', tags: [] },
  { id: 'liked', name: 'Liked', icon: 'heart', tags: [] },
  { id: 'popular', name: 'Popular games', icon: 'cat-popular', tags: ['top20'] },
  { id: 'battle', name: 'Battle', icon: 'cat-battle', tags: ['pvp', 'teams', 'rpg'] },
  { id: 'obby', name: 'Obby', icon: 'cat-obby', tags: ['obby', 'escape', 'parkour'] },
  { id: 'sim', name: 'Simulator', icon: 'cat-sim', tags: ['simulator', 'tycoon', 'idle', 'pets', 'collect', 'rng', 'training'] },
  { id: 'horror', name: 'Horror', icon: 'cat-horror', tags: ['horror', 'survival'] },
  { id: 'vehicle', name: 'Vehicles', icon: 'cat-vehicle', tags: ['cars', 'racing', 'flying'] },
  { id: 'roleplay', name: 'Roleplay', icon: 'cat-roleplay', tags: ['rp', 'roleplay', 'town', 'build', 'building'] },
  { id: 'minigame', name: 'Minigames', icon: 'cat-minigame', tags: ['party', 'minigames', 'funny', 'puzzle', 'classic'] },
];

/** The game a room is playing, when it is one from the list. */
export function gameFor(games: GameListing[], room: CloudRoom): GameListing | undefined {
  return games.find((g) => stableGameID(g.id) === room.worldID) ?? games.find((g) => g.title === room.world);
}

export function roomsFor(internet: InternetRooms, g: GameListing): CloudRoom[] {
  const id = stableGameID(g.id);
  return internet.rooms.filter((r) => r.worldID === id || r.world === g.title);
}

export class GamesPage implements ShellPage {
  readonly root: HTMLElement;
  private category: string;
  private query = '';
  private unwatch: (() => void) | null = null;
  private unsubscribe: () => void;
  private readonly grid: HTMLElement;
  private readonly count: HTMLElement;
  private readonly chips: HTMLElement;

  constructor(parent: HTMLElement, private readonly ctx: ShellContext, category = 'all') {
    this.category = categories.some((c) => c.id === category) ? category : 'all';
    this.root = el('div', 'ab-tab ab-games', parent);
    const bar = el('div', 'ab-games-bar', this.root);
    const search = el('label', 'ab-search', bar);
    el('span', '', search, '🔍');
    const input = el('input', '', search);
    input.type = 'search';
    input.placeholder = L('Search games');
    input.oninput = () => {
      this.query = input.value;
      if (this.category === 'rooms' || this.category === 'liked') { this.setCategory('all'); return; }
      this.renderGrid();
    };
    this.chips = el('nav', 'ab-chips', this.root);
    this.count = el('div', 'ab-count', this.root);
    this.grid = el('div', 'ab-grid', this.root);
    this.unsubscribe = ctx.internet.subscribe(() => { if (this.category === 'rooms') this.renderGrid(); });
    this.redraw();
  }

  setCategory(id: string): void {
    if (!categories.some((c) => c.id === id)) id = 'all';
    if (id === this.category) return;
    this.category = id;
    // The address says which: back goes to the list before.
    const hash = id === 'rooms' ? 'rooms' : id === 'all' ? 'games' : `games/${id}`;
    if (location.hash.replace(/^#/, '') !== hash) history.replaceState(null, '', '#' + hash);
    this.redraw();
  }

  redraw(): void {
    this.chips.innerHTML = '';
    for (const c of categories) {
      const b = el('button', 'ab-cat' + (c.id === this.category ? ' on' : '') + (c.id === 'rooms' ? ' rooms' : '') + (c.id === 'liked' ? ' liked' : ''), this.chips);
      img(new URL(`icons/${c.icon}.webp`, document.baseURI).href, b);
      el('span', '', b, L(c.name));
      b.onclick = () => { this.ctx.sound.play('click'); this.setCategory(c.id); };
    }
    this.renderGrid();
  }

  private matches(g: GameListing): boolean {
    const c = categories.find((x) => x.id === this.category)!;
    if (this.category === 'liked' && !this.ctx.record.liked.has(g.id)) return false;
    if (c.tags.length && !g.tags.some((t) => c.tags.includes(t))) return false;
    const q = this.query.trim().toLowerCase();
    if (!q) return true;
    return [g.title, g.summary, g.author, ...g.tags].some((s) => s.toLowerCase().includes(q));
  }

  private renderGrid(): void {
    const { grid, count, ctx } = this;
    grid.innerHTML = '';
    const rooms = this.category === 'rooms';
    if (rooms && !this.unwatch && ctx.internet.allowsInternetPlay) this.unwatch = ctx.watchRooms();
    if (!rooms && this.unwatch) { this.unwatch(); this.unwatch = null; }
    if (rooms) { this.renderRooms(); return; }
    const games = ctx.games();
    const shown = games.filter((g) => this.matches(g));
    count.textContent = L('{} games', shown.length);
    if (!shown.length) {
      el('div', 'ab-empty', grid, !games.length ? L('Loading the game list…')
        : this.category === 'liked' && !this.query ? L('Tap ♥ on a game’s page to keep it here.') : L('No games match that.'));
      return;
    }
    for (const g of shown) {
      const card = el('button', 'ab-game', grid);
      const cover = el('div', 'ab-cover', card);
      const url = coverURL(g);
      if (url) img(url, cover, g.title);
      const players = el('span', 'players', cover);
      icon('badge-players', players, '');
      el('span', '', players, String(g.maxPlayers));
      if (g.tags.includes('top20')) el('span', 'top', cover, L('Hot'));
      if (ctx.record.liked.has(g.id)) el('span', 'liked', cover, '♥');
      const played = ctx.record.games.get(g.id);
      const info = el('div', 'info', card);
      el('div', 'title', info, g.title);
      el('div', 'summary', info, g.summary);
      if (played) el('div', 'played', info, L('{} plays', played.plays));
      card.onclick = () => ctx.go(`game/${g.id}`);
    }
  }

  /** The internet rooms open now, or why there are none to see. */
  private renderRooms(): void {
    const { grid, count, ctx } = this;
    const internet = ctx.internet;
    if (!internet.allowsInternetPlay) {
      count.textContent = '';
      const off = el('div', 'ab-rooms-off', grid);
      icon('family', off, '');
      el('b', '', off, L('Internet rooms are off'));
      el('span', '', off, L('Play with anyone who has Ablox, on an iPad or in a browser. A grown-up can turn this on in Settings → Family.'));
      const ask = el('button', 'ab-block', off, L('Family settings'));
      ask.onclick = () => askGrownUp(ctx.lock, () => familySheet(ctx.lock, internet, () => this.redraw()));
      return;
    }
    const state = internet.state;
    const rooms = internet.rooms;
    count.textContent = state.kind === 'connecting' ? L('Connecting…') : state.kind === 'failed' ? state.message : L('{} rooms open', rooms.length);
    const bar = el('div', 'ab-rooms-bar', grid);
    const refresh = el('button', 'ab-block secondary', bar, '⟳ ' + L('Refresh'));
    refresh.onclick = () => internet.refreshRooms().catch(() => {});
    el('span', 'note', bar, L('Open a game and choose “Open an internet room” to start one.'));
    if (!rooms.length) {
      el('div', 'ab-empty', grid, state.kind === 'ready' ? L('No rooms are open right now.') : L('Looking for rooms…'));
      return;
    }
    const games = ctx.games();
    for (const room of rooms) {
      const g = gameFor(games, room);
      const card = el('button', 'ab-game ab-room', grid);
      const cover = el('div', 'ab-cover', card);
      const url = g ? coverURL(g) : null;
      if (url) img(url, cover, room.world);
      else el('div', 'globe', cover, '🌐');
      const players = el('span', 'players', cover);
      icon('badge-players', players, '');
      el('span', '', players, `${room.players}/${room.capacity}`);
      const info = el('div', 'info', card);
      el('div', 'title', info, room.world);
      el('div', 'summary', info, L('Hosted by {}', room.hostName));
      const full = roomIsFull(room), old = !roomIsCompatible(room);
      if (full || old) el('span', 'badge', cover, full ? L('Full') : L('Different version'));
      card.disabled = full || old;
      card.onclick = () => ctx.go(`join/${room.id}`);
    }
  }

  dispose(): void {
    this.unwatch?.();
    this.unsubscribe();
    this.root.remove();
  }
}
