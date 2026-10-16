// Ablox in the browser: the game list, a game's page, internet rooms and a
// game playing. Addresses are kept in the hash (#game/<id>, #play/<id>,
// #host/<id>, #join/<room>, #rooms), so the back button goes back and a
// link opens the same place.
import './play/hud.css';
import './app/app.css';
import { loadProfile, localPeerID, saveProfile } from './app/identity';
import { FamilyLock } from './app/family';
import { askGrownUp, el, familySheet, settingsSheet } from './app/sheets';
import { roomIsCompatible, roomIsFull, type CloudRoom } from './core/model/cloud';
import type { AvatarProfile } from './core/model/avatar';
import type { WorldDocument } from './core/model/world';
import { coverURL, fileURL, loadCatalogue, loadGame, stableGameID, type GameListing } from './net/catalogue';
import { InternetRooms } from './net/internet';
import { SoundPlayer } from './engine/audio';
import { PlayScreen, type PlayNetwork, type PlayStart } from './play/screen';
import { iconURL } from './play/hud';
import { L, language, setLanguage } from './i18n';

const app = document.getElementById('app')!;
const stage = document.getElementById('stage')!;
const sound = new SoundPlayer();
sound.attach(window);
const internet = new InternetRooms();
const lock = new FamilyLock();
let profile: AvatarProfile = loadProfile();

interface Category { id: string; name: string; icon: string; tags: string[] }
const categories: Category[] = [
  { id: 'rooms', name: 'Internet rooms', icon: 'friends', tags: [] },
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

function img(src: string, parent: HTMLElement, alt = ''): HTMLImageElement {
  const i = el('img', '', parent);
  i.src = src;
  i.alt = alt;
  i.loading = 'lazy';
  i.decoding = 'async';
  i.draggable = false;
  return i;
}

// MARK: The internet

/** What a play screen is told about the internet. */
const network: PlayNetwork = {
  get allowsRooms() { return internet.allowsInternetPlay; },
  list: (room, world, who) => internet.host(room, world, who),
  unlist: () => internet.stopHosting(),
  findMovedRoom: (move) => internet.findMovedRoom(move),
};

/** The game a room is playing, when it is one from the list. */
function gameFor(room: CloudRoom): GameListing | undefined {
  return games.find((g) => stableGameID(g.id) === room.worldID) ?? games.find((g) => g.title === room.world);
}

function roomsFor(g: GameListing): CloudRoom[] {
  const id = stableGameID(g.id);
  return internet.rooms.filter((r) => r.worldID === id || r.world === g.title);
}

let refreshTimer: ReturnType<typeof setInterval> | null = null;
/** While rooms are on screen, the list is fetched again every few seconds. */
function keepRoomsFresh(on: boolean): void {
  if (!on || !internet.allowsInternetPlay) {
    if (refreshTimer) clearInterval(refreshTimer);
    refreshTimer = null;
    return;
  }
  if (refreshTimer) return;
  const refresh = () => { if (!document.hidden && !playing) internet.refreshRooms().catch(() => {}); };
  refreshTimer = setInterval(refresh, 8000);
  refresh();
}

internet.subscribe(() => {
  if (category === 'rooms') renderGrid();
  if (sheetGame) renderSheetRooms(sheetGame);
});

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
  input.oninput = () => {
    query = input.value;
    if (category === 'rooms') { category = 'all'; buildList(); return; }
    renderGrid();
  };
  const lang = el('button', 'ab-head-button', header, language() === 'ja' ? 'English' : '日本語');
  lang.onclick = () => { setLanguage(language() === 'ja' ? 'en' : 'ja'); buildList(); };
  const gear = el('button', 'ab-head-button icon', header);
  img(iconURL('settings'), gear, '');
  gear.setAttribute('aria-label', L('Settings'));
  gear.title = L('Settings');
  gear.onclick = () => { location.hash = 'settings'; };

  const chips = el('nav', 'ab-chips', page);
  for (const c of categories) {
    const b = el('button', 'ab-cat' + (c.id === category ? ' on' : '') + (c.id === 'rooms' ? ' rooms' : ''), chips);
    img(iconURL(c.icon), b);
    el('span', '', b, L(c.name));
    b.onclick = () => { location.hash = c.id === 'rooms' ? 'rooms' : ''; category = c.id; buildList(); };
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
  const grid = page.querySelector('.ab-grid') as HTMLElement | null;
  const count = page.querySelector('.ab-count') as HTMLElement | null;
  if (!grid || !count) return;
  grid.innerHTML = '';
  if (category === 'rooms') {
    keepRoomsFresh(true);
    renderRooms(grid, count);
    return;
  }
  keepRoomsFresh(!!sheetGame);
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

/** The internet rooms open now, or why there are none to see. */
function renderRooms(grid: HTMLElement, count: HTMLElement): void {
  if (!internet.allowsInternetPlay) {
    count.textContent = '';
    const off = el('div', 'ab-rooms-off', grid);
    img(iconURL('family'), off);
    el('b', '', off, L('Internet rooms are off'));
    el('span', '', off, L('Play with anyone who has Ablox, on an iPad or in a browser. A grown-up can turn this on in Settings → Family.'));
    const ask = el('button', 'ab-block', off, L('Family settings'));
    ask.onclick = () => askGrownUp(lock, () => familySheet(lock, internet, () => buildList()));
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
  for (const room of rooms) {
    const g = gameFor(room);
    const card = el('button', 'ab-game ab-room', grid);
    const cover = el('div', 'ab-cover', card);
    const url = g ? coverURL(g) : null;
    if (url) img(url, cover, room.world);
    else el('div', 'globe', cover, '🌐');
    const players = el('span', 'players', cover);
    img(iconURL('badge-players'), players);
    el('span', '', players, `${room.players}/${room.capacity}`);
    const info = el('div', 'info', card);
    el('div', 'title', info, room.world);
    el('div', 'summary', info, L('Hosted by {}', room.hostName));
    const full = roomIsFull(room), old = !roomIsCompatible(room);
    if (full || old) el('span', 'badge', cover, full ? L('Full') : L('Different version'));
    card.disabled = full || old;
    card.onclick = () => { location.hash = `join/${room.id}`; };
  }
}

// MARK: A game's page

let sheet: HTMLElement[] = [];
let sheetGame: GameListing | null = null;

function closeSheet(): void {
  for (const e of sheet) e.remove();
  sheet = [];
  sheetGame = null;
  if (category !== 'rooms') keepRoomsFresh(false);
}

function showGame(g: GameListing): void {
  closeSheet();
  const scrim = el('div', 'ab-sheet-scrim', app);
  scrim.onclick = () => { location.hash = ''; };
  const card = el('div', 'ab-sheet', app);
  sheet = [scrim, card];
  sheetGame = g;
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
  if (g.maxPlayers > 1) el('div', 'ab-sheet-rooms', body);
  renderSheetRooms(g);
  keepRoomsFresh(true);
  play.focus();
}

/** Play with friends: open a room for this game, or join one already open. */
function renderSheetRooms(g: GameListing): void {
  const box = sheet[1]?.querySelector('.ab-sheet-rooms') as HTMLElement | null;
  if (!box) return;
  box.innerHTML = '';
  el('h3', '', box, L('Play with friends'));
  if (!internet.allowsInternetPlay) {
    const row = el('div', 'off', box);
    el('span', '', row, L('Internet rooms are off. A grown-up can turn them on in Settings → Family.'));
    const ask = el('button', 'ab-block secondary', row, L('Family settings'));
    ask.onclick = () => askGrownUp(lock, () => familySheet(lock, internet, () => { buildList(); renderSheetRooms(g); }));
    return;
  }
  const host = el('button', 'ab-block', box);
  img(iconURL('friends'), host);
  el('span', '', host, L('Open an internet room'));
  host.onclick = () => { location.hash = `host/${g.id}`; };
  const open = roomsFor(g);
  if (!open.length) {
    el('div', 'none', box, internet.state.kind === 'ready' ? L('No rooms for this game right now.') : L('Looking for rooms…'));
    return;
  }
  for (const room of open) {
    const row = el('div', 'ab-room-row', box);
    const who = el('div', 'who', row);
    el('b', '', who, L('{}’s room', room.hostName));
    el('small', '', who, L('{} of {} players', room.players, room.capacity));
    const join = el('button', 'ab-block green', row, L('Join'));
    join.disabled = roomIsFull(room) || !roomIsCompatible(room);
    if (roomIsFull(room)) join.textContent = L('Full');
    join.onclick = () => { location.hash = `join/${room.id}`; };
  }
}

// MARK: Playing

function showStage(): HTMLElement {
  closeSheet();
  stopPlaying();
  keepRoomsFresh(false);
  page.classList.add('ab-hidden');
  stage.classList.remove('ab-hidden');
  stage.innerHTML = '';
  return stage;
}

function startScreen(start: PlayStart): void {
  playing = new PlayScreen(stage, start, localPeerID(), profile, sound, network);
  playing.onExit = () => {
    playing = null;
    if (/^#(play|host|join)\//.test(location.hash)) history.back();
    setTimeout(() => { if (/^#(play|host|join)\//.test(location.hash)) location.hash = ''; }, 50);
  };
}

async function play(g: GameListing, openRoom: boolean): Promise<void> {
  showStage();
  const loading = el('div', 'ab-loading', stage);
  img(iconURL('continue'), loading).className = 'cube';
  el('div', 'title', loading, g.title);
  const bar = el('div', 'bar', loading);
  const fill = el('div', '', bar);
  const note = el('div', 'note', loading, L('Getting the game ready…'));
  const hash = location.hash;
  try {
    const world: WorldDocument = await loadGame(g, undefined, (received, expected) => {
      fill.style.width = expected > 0 ? `${Math.min(100, (received / expected) * 100)}%` : '60%';
      note.textContent = L('{} MB of {} MB', (received / 1048576).toFixed(1), (expected / 1048576).toFixed(1));
    });
    if (location.hash !== hash) return;
    fill.style.width = '100%';
    note.textContent = L('Building the world…');
    await new Promise((r) => setTimeout(r, 30));
    startScreen({ kind: 'solo', world, openRoom: openRoom && internet.allowsInternetPlay });
    loading.remove();
  } catch (e) {
    loading.remove();
    problem(L('That game could not be opened.'), String((e as Error)?.message ?? e));
  }
}

async function join(roomID: string): Promise<void> {
  if (!internet.allowsInternetPlay) {
    category = 'rooms';
    location.replace('#rooms');
    return;
  }
  showStage();
  const loading = el('div', 'ab-loading', stage);
  img(iconURL('friends'), loading).className = 'cube';
  el('div', 'title', loading, L('Finding the room…'));
  const hash = location.hash;
  try {
    let room = internet.rooms.find((r) => r.id === roomID);
    if (!room) room = (await internet.refreshRooms()).find((r) => r.id === roomID);
    if (location.hash !== hash) return;
    loading.remove();
    if (!room) { problem(L('That room has closed.'), L('Rooms close when their host leaves.')); return; }
    const g = gameFor(room);
    startScreen({ kind: 'join', route: internet.route(room), title: g?.title ?? room.world });
  } catch (e) {
    loading.remove();
    problem(L("Couldn't reach that internet room: {}", ''), String((e as Error)?.message ?? e));
  }
}

function problem(title: string, detail: string): void {
  const box = el('div', 'ab-error', stage);
  el('b', '', box, title);
  el('span', '', box, detail);
  const back = el('button', 'ab-block', box, L('Back to the games'));
  back.onclick = () => { location.hash = ''; };
  back.focus();
}

function stopPlaying(): void {
  playing?.dispose();
  playing = null;
  stage.innerHTML = '';
}

// MARK: Where we are

async function lab(n: string): Promise<void> {
  const { labWorld } = await import('./app/lab');
  showStage();
  playing = new PlayScreen(stage, { kind: 'solo', world: labWorld(n) }, localPeerID(), profile, sound, network);
  playing.onExit = () => { playing = null; location.hash = ''; };
}

let settingsOpen = false;

function route(): void {
  const hash = location.hash.replace(/^#/, '');
  const [kind, id] = hash.split('/');
  if (kind === 'lab' && import.meta.env.DEV) { void lab(id ?? '1'); return; }
  const g = games.find((x) => x.id === id);
  if (kind === 'play' && g) { void play(g, false); return; }
  if (kind === 'host' && g) { void play(g, true); return; }
  if (kind === 'join' && id) { void join(id); return; }
  if (playing || !stage.classList.contains('ab-hidden')) {
    stopPlaying();
    stage.classList.add('ab-hidden');
    page.classList.remove('ab-hidden');
  }
  if (kind === 'rooms' && category !== 'rooms') { category = 'rooms'; buildList(); }
  if (kind === 'settings') {
    closeSheet();
    if (!settingsOpen) {
      settingsOpen = true;
      settingsSheet(lock, internet, {
        profile: () => profile,
        saveProfile: (p) => { profile = p; saveProfile(p); },
        redraw: () => buildList(),
      }, () => {
        settingsOpen = false;
        if (location.hash === '#settings') history.back();
        buildList();
      });
    }
    return;
  }
  if (kind === 'game' && g) showGame(g);
  else closeSheet();
  if (category === 'rooms') renderGrid();
}

window.addEventListener('hashchange', route);
// For poking at a running game from the console while developing.
if (import.meta.env.DEV) Object.defineProperty(window, 'ablox', { get: () => ({ playing, internet }) });
document.documentElement.lang = language();
if (location.hash === '#rooms') category = 'rooms';
buildList();
if (internet.allowsInternetPlay) void internet.start();
try {
  games = await loadCatalogue();
} catch (e) {
  const grid = page.querySelector('.ab-grid') as HTMLElement;
  grid.innerHTML = '';
  el('div', 'ab-empty', grid, L('The game list could not be loaded: {}', String((e as Error)?.message ?? e)));
}
renderGrid();
route();
