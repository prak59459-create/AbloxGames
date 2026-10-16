// Ablox in the browser: the game list, a game's page, and a game playing.
// Addresses are kept in the hash (#game/<id>, #play/<id>), so the back
// button goes back and a link opens the same game.
import './play/hud.css';
import './app/app.css';
import { loadProfile, localPeerID } from './app/identity';
import { coverURL, fileURL, loadCatalogue, loadGame, type GameListing } from './net/catalogue';
import { SoundPlayer } from './engine/audio';
import { PlayScreen } from './play/screen';
import { iconURL } from './play/hud';
import { L, language, setLanguage } from './i18n';

const app = document.getElementById('app')!;
const stage = document.getElementById('stage')!;
const sound = new SoundPlayer();
sound.attach(window);

interface Category { id: string; name: string; icon: string; tags: string[] }
const categories: Category[] = [
  { id: 'all', name: 'All', icon: 'continue', tags: [] },
  { id: 'popular', name: 'Popular', icon: 'cat-popular', tags: ['top20'] },
  { id: 'battle', name: 'Battle', icon: 'cat-battle', tags: ['pvp', 'teams', 'rpg'] },
  { id: 'obby', name: 'Obby', icon: 'cat-obby', tags: ['obby', 'escape', 'parkour'] },
  { id: 'sim', name: 'Simulator', icon: 'cat-sim', tags: ['simulator', 'tycoon', 'idle', 'pets', 'collect', 'rng', 'training'] },
  { id: 'horror', name: 'Horror', icon: 'cat-horror', tags: ['horror', 'survival'] },
  { id: 'vehicle', name: 'Vehicles', icon: 'cat-vehicle', tags: ['cars', 'racing', 'flying'] },
  { id: 'roleplay', name: 'Roleplay', icon: 'cat-roleplay', tags: ['rp', 'roleplay', 'town', 'build', 'building'] },
  { id: 'minigame', name: 'Minigames', icon: 'cat-minigame', tags: ['party', 'minigames', 'funny', 'puzzle', 'classic'] },
];

let games: GameListing[] = [];
let category = 'all';
let query = '';
let playing: PlayScreen | null = null;

function el<K extends keyof HTMLElementTagNameMap>(tag: K, className = '', parent?: HTMLElement, text?: string): HTMLElementTagNameMap[K] {
  const e = document.createElement(tag);
  if (className) e.className = className;
  if (text !== undefined) e.textContent = text;
  parent?.appendChild(e);
  return e;
}

function img(src: string, parent: HTMLElement, alt = ''): HTMLImageElement {
  const i = el('img', '', parent);
  i.src = src;
  i.alt = alt;
  i.loading = 'lazy';
  i.decoding = 'async';
  i.draggable = false;
  return i;
}

// MARK: The list

const page = el('div', 'ab-page', app);

function buildList(): void {
  page.innerHTML = '';
  const header = el('header', 'ab-header', page);
  const brand = el('div', 'ab-brand', header);
  img(iconURL('continue'), brand, 'Ablox');
  el('span', '', brand, 'Ablox');
  el('small', '', brand, 'web');
  const search = el('label', 'ab-search', header);
  el('span', '', search, '🔍');
  const input = el('input', '', search);
  input.type = 'search';
  input.placeholder = L('Search games');
  input.value = query;
  input.oninput = () => { query = input.value; renderGrid(); };
  const lang = el('button', 'ab-head-button', header, language() === 'ja' ? 'English' : '日本語');
  lang.onclick = () => { setLanguage(language() === 'ja' ? 'en' : 'ja'); buildList(); };

  const chips = el('nav', 'ab-chips', page);
  for (const c of categories) {
    const b = el('button', 'ab-cat' + (c.id === category ? ' on' : ''), chips);
    img(iconURL(c.icon), b);
    el('span', '', b, L(c.name));
    b.onclick = () => { category = c.id; buildList(); };
  }
  el('div', 'ab-count', page);
  el('div', 'ab-grid', page);
  renderGrid();
}

function matches(g: GameListing): boolean {
  const c = categories.find((x) => x.id === category)!;
  if (c.tags.length && !g.tags.some((t) => c.tags.includes(t))) return false;
  const q = query.trim().toLowerCase();
  if (!q) return true;
  return [g.title, g.summary, g.author, ...g.tags].some((s) => s.toLowerCase().includes(q));
}

function renderGrid(): void {
  const grid = page.querySelector('.ab-grid') as HTMLElement;
  const count = page.querySelector('.ab-count') as HTMLElement;
  grid.innerHTML = '';
  const shown = games.filter(matches);
  count.textContent = L('{} games', shown.length);
  if (!shown.length) {
    el('div', 'ab-empty', grid, games.length ? L('No games match that.') : L('Loading the game list…'));
    return;
  }
  for (const g of shown) {
    const card = el('button', 'ab-game', grid);
    const cover = el('div', 'ab-cover', card);
    const url = coverURL(g);
    if (url) img(url, cover, g.title);
    const players = el('span', 'players', cover);
    img(iconURL('badge-players'), players);
    el('span', '', players, String(g.maxPlayers));
    if (g.tags.includes('top20')) el('span', 'top', cover, L('Popular'));
    const info = el('div', 'info', card);
    el('div', 'title', info, g.title);
    el('div', 'summary', info, g.summary);
    card.onclick = () => { location.hash = `game/${g.id}`; };
  }
}

// MARK: A game's page

let sheet: HTMLElement[] = [];

function closeSheet(): void {
  for (const e of sheet) e.remove();
  sheet = [];
}

function showGame(g: GameListing): void {
  closeSheet();
  const scrim = el('div', 'ab-sheet-scrim', app);
  scrim.onclick = () => { location.hash = ''; };
  const card = el('div', 'ab-sheet', app);
  sheet = [scrim, card];
  const hero = el('div', 'hero', card);
  const url = coverURL(g);
  if (url) img(url, hero, g.title);
  const close = el('button', 'close', hero, '✕');
  close.setAttribute('aria-label', L('Close'));
  close.onclick = () => { location.hash = ''; };
  const body = el('div', 'body', card);
  el('h1', '', body, g.title);
  const meta = el('div', 'meta', body);
  const chip = (icon: string, text: string) => { const s = el('span', '', meta); img(iconURL(icon), s); el('span', '', s, text); };
  chip('badge-players', L('Up to {} players', g.maxPlayers));
  if (g.author) chip('create', g.author);
  if (g.bytes) chip('badge-downloaded', `${(g.bytes / 1024 / 1024).toFixed(1)} MB`);
  el('p', '', body, g.summary);
  if (g.shots?.length) {
    const shots = el('div', 'ab-shots', body);
    for (const s of g.shots) img(fileURL(s), shots);
  }
  const actions = el('div', 'ab-actions', body);
  const play = el('button', 'ab-block green', actions);
  img(iconURL('tool-play'), play);
  el('span', '', play, L('Play'));
  play.onclick = () => { location.hash = `play/${g.id}`; };
  el('span', 'note', actions, L('Playing with friends in the browser is coming next.'));
  play.focus();
}

// MARK: Playing

async function play(g: GameListing): Promise<void> {
  closeSheet();
  stopPlaying();
  page.classList.add('ab-hidden');
  stage.classList.remove('ab-hidden');
  stage.innerHTML = '';
  const loading = el('div', 'ab-loading', stage);
  img(iconURL('continue'), loading).className = 'cube';
  el('div', 'title', loading, g.title);
  const bar = el('div', 'bar', loading);
  const fill = el('div', '', bar);
  const note = el('div', 'note', loading, L('Getting the game ready…'));
  try {
    const world = await loadGame(g, undefined, (received, expected) => {
      fill.style.width = expected > 0 ? `${Math.min(100, (received / expected) * 100)}%` : '60%';
      note.textContent = L('{} MB of {} MB', (received / 1048576).toFixed(1), (expected / 1048576).toFixed(1));
    });
    if (location.hash !== `#play/${g.id}`) return;
    fill.style.width = '100%';
    note.textContent = L('Building the world…');
    await new Promise((r) => setTimeout(r, 30));
    playing = new PlayScreen(stage, world, localPeerID(), loadProfile(), sound);
    playing.onExit = () => {
      playing = null;
      if (location.hash.startsWith('#play/')) history.back();
      setTimeout(() => { if (location.hash.startsWith('#play/')) location.hash = ''; }, 50);
    };
    loading.remove();
  } catch (e) {
    loading.remove();
    const box = el('div', 'ab-error', stage);
    el('b', '', box, L('That game could not be opened.'));
    el('span', '', box, String((e as Error)?.message ?? e));
    const back = el('button', 'ab-block', box, L('Back to the games'));
    back.onclick = () => { location.hash = ''; };
  }
}

function stopPlaying(): void {
  playing?.dispose();
  playing = null;
  stage.innerHTML = '';
}

// MARK: Where we are

async function lab(n: string): Promise<void> {
  const { labWorld } = await import('./app/lab');
  closeSheet();
  stopPlaying();
  page.classList.add('ab-hidden');
  stage.classList.remove('ab-hidden');
  playing = new PlayScreen(stage, labWorld(n), localPeerID(), loadProfile(), sound);
  playing.onExit = () => { playing = null; location.hash = ''; };
}

function route(): void {
  const hash = location.hash.replace(/^#/, '');
  const [kind, id] = hash.split('/');
  if (kind === 'lab' && import.meta.env.DEV) {
    void lab(id ?? '1');
    return;
  }
  const g = games.find((x) => x.id === id);
  if (kind === 'play' && g) {
    void play(g);
    return;
  }
  if (playing || !stage.classList.contains('ab-hidden')) {
    stopPlaying();
    stage.classList.add('ab-hidden');
    page.classList.remove('ab-hidden');
  }
  if (kind === 'game' && g) showGame(g);
  else closeSheet();
}

window.addEventListener('hashchange', route);
// For poking at a running game from the console while developing.
if (import.meta.env.DEV) Object.defineProperty(window, 'ablox', { get: () => playing });
document.documentElement.lang = language();
buildList();
try {
  games = await loadCatalogue();
} catch (e) {
  const grid = page.querySelector('.ab-grid') as HTMLElement;
  grid.innerHTML = '';
  el('div', 'ab-empty', grid, L('The game list could not be loaded: {}', String((e as Error)?.message ?? e)));
}
renderGrid();
route();
