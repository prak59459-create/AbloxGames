// Ablox in the browser. A dock of four tabs — Home, Play, Me and Create —
// under a bar with your coins and level; a game's page over them; and a
// game playing on the whole screen. Addresses are kept in the hash (#games,
// #me/hat, #game/<id>, #play/<id>, #host/<id>, #join/<room>, #plaza…), so
// the back button goes back and a link opens the same place.
import './play/hud.css';
import './app/app.css';
import './app/next.css';
import { loadProfile, localPeerID, saveProfile } from './app/identity';
import { FamilyLock } from './app/family';
import { askGrownUp, el, familySheet, settingsSheet } from './app/sheets';
import { PlayerRecord } from './app/player';
import { HomePage } from './app/home';
import { GamesPage, gameFor, roomsFor } from './app/games';
import { MePage, isMeSection } from './app/me';
import { CreatePage, readWorldFile } from './app/create';
import { buildPlaza, type PlazaDoor } from './app/plaza';
import { hasBeenWelcomed, welcome } from './app/welcome';
import { confetti } from './app/effects';
import { formatNumber, icon, img, type ShellContext, type ShellPage } from './app/shell';
import { roomIsCompatible, roomIsFull } from './core/model/cloud';
import { PlayerLevel } from './core/model/progress';
import type { AvatarProfile } from './core/model/avatar';
import type { WorldDocument } from './core/model/world';
import { coverURL, fileURL, loadCatalogue, loadGame, type GameListing } from './net/catalogue';
import { InternetRooms } from './net/internet';
import { SoundPlayer } from './engine/audio';
import { PlayScreen, type PlayNetwork, type PlayProgress, type PlayStart } from './play/screen';
import { iconURL } from './play/hud';
import { L, language, setLanguage } from './i18n';

const app = document.getElementById('app')!;
const stage = document.getElementById('stage')!;
const sound = new SoundPlayer();
sound.attach(window);
const internet = new InternetRooms();
const lock = new FamilyLock();
const record = new PlayerRecord();
let profile: AvatarProfile = loadProfile();

let games: GameListing[] = [];
let playing: PlayScreen | null = null;

// MARK: The internet

/** What a play screen is told about the internet. */
const network: PlayNetwork = {
  get allowsRooms() { return internet.allowsInternetPlay; },
  list: (room, world, who) => internet.host(room, world, who),
  unlist: () => internet.stopHosting(),
  findMovedRoom: (move) => internet.findMovedRoom(move),
};

let roomWatchers = 0;
let refreshTimer: ReturnType<typeof setInterval> | null = null;
/** While anything on screen shows rooms, the list is fetched again every few seconds. */
function watchRooms(): () => void {
  roomWatchers += 1;
  if (!refreshTimer && internet.allowsInternetPlay) {
    const refresh = () => { if (!document.hidden && !playing) internet.refreshRooms().catch(() => {}); };
    refreshTimer = setInterval(refresh, 8000);
    refresh();
  }
  let stopped = false;
  return () => {
    if (stopped) return;
    stopped = true;
    roomWatchers -= 1;
    if (roomWatchers <= 0 && refreshTimer) { clearInterval(refreshTimer); refreshTimer = null; }
  };
}

// MARK: The shell

type Tab = 'home' | 'games' | 'me' | 'create';
const shell = el('div', 'ab-shell', app);
const top = el('header', 'ab-top', shell);
const view = el('main', 'ab-view', shell);
const dock = el('nav', 'ab-dock', shell);
dock.setAttribute('aria-label', 'Ablox');
let tab: Tab | null = null;
let page: ShellPage | null = null;
let dirty = false;

const toaster = el('div', 'ab-page-toasts', document.body);
function toast(text: string, kind: 'coins' | 'plain' = 'plain'): void {
  const t = el('div', 'ab-page-toast' + (kind === 'coins' ? ' coins' : ''), toaster);
  if (kind === 'coins') icon('coin', t);
  el('span', '', t, text);
  if (kind === 'coins') sound.play('coin');
  setTimeout(() => { t.classList.add('going'); setTimeout(() => t.remove(), 400); }, 2600);
  while (toaster.children.length > 3) toaster.firstElementChild?.remove();
}

const ctx: ShellContext = {
  record,
  profile: () => profile,
  setProfile: (p) => { profile = p; saveProfile(p); drawTop(); },
  games: () => games,
  internet,
  lock,
  sound,
  toast,
  go: (hash) => { if (location.hash.replace(/^#/, '') === hash) route(); else location.hash = hash; },
  watchRooms,
  playWorld: (world, openRoom) => { pendingWorld = { world, openRoom }; location.hash = 'file'; },
};

function drawTop(): void {
  top.innerHTML = '';
  const brand = el('button', 'ab-brand', top);
  img(iconURL('continue'), brand, 'Ablox');
  el('span', '', brand, 'Ablox');
  el('small', '', brand, 'web');
  brand.onclick = () => ctx.go('');
  el('div', 'spacer', top);
  const level = record.level;
  const lv = el('button', 'ab-pill level', top);
  icon('level', lv);
  el('b', '', lv, String(level.number));
  lv.title = L('Level {}', level.number);
  lv.onclick = () => ctx.go('me/badges');
  const coins = el('button', 'ab-pill coins', top);
  icon('coin', coins);
  el('b', '', coins, formatNumber(record.wallet.coins));
  coins.title = L('Coins');
  coins.onclick = () => ctx.go('me');
  const lang = el('button', 'ab-head-button', top, language() === 'ja' ? 'EN' : '日本語');
  lang.title = language() === 'ja' ? 'English' : '日本語';
  lang.onclick = () => { setLanguage(language() === 'ja' ? 'en' : 'ja'); redrawAll(); };
  const gear = el('button', 'ab-head-button icon', top);
  img(iconURL('settings'), gear, '');
  gear.setAttribute('aria-label', L('Settings'));
  gear.title = L('Settings');
  gear.onclick = () => ctx.go('settings');
}

/** Rewards waiting on Home: today's bonus and missions done but not taken. */
function waitingOnHome(): number {
  const day = record.today;
  return (record.bonus.isWaiting() ? 1 : 0) + record.missions.waitingRewards(day) + (record.missions.isAllDoneBonusWaiting(day) ? 1 : 0);
}

function drawDock(): void {
  dock.innerHTML = '';
  const tabs: [Tab, string, string][] = [['home', 'home', L('Home')], ['games', 'play', L('Play')], ['me', 'me', L('Me')], ['create', 'create', L('Create')]];
  for (const [id, iconName, name] of tabs) {
    const b = el('button', 'ab-dock-tab' + (id === tab ? ' on' : ''), dock);
    b.setAttribute('aria-current', id === tab ? 'page' : 'false');
    icon(iconName, b);
    el('span', '', b, name);
    if (id === 'home') {
      const n = waitingOnHome();
      if (n > 0) el('i', 'dot', b, String(n));
    }
    b.onclick = () => {
      sound.play('click');
      ctx.go(id === 'home' ? '' : id);
    };
  }
}

function showTab(next: Tab, sub?: string): void {
  if (tab === next && page) {
    if (next === 'me' && page instanceof MePage) page.open(isMeSection(sub) ? sub : 'colors');
    if (next === 'games' && page instanceof GamesPage) page.setCategory(sub ?? 'all');
    return;
  }
  page?.dispose();
  tab = next;
  view.scrollTop = 0;
  switch (next) {
    case 'home': page = new HomePage(view, ctx); break;
    case 'games': page = new GamesPage(view, ctx, sub); break;
    case 'me': page = new MePage(view, ctx, isMeSection(sub) ? sub : undefined); break;
    case 'create': page = new CreatePage(view, ctx); break;
  }
  drawDock();
}

/** The language changed: every word again. */
function redrawAll(): void {
  document.documentElement.lang = language();
  drawTop();
  const current = tab;
  page?.dispose();
  page = null;
  tab = null;
  if (current) {
    const [, sub] = location.hash.replace(/^#/, '').split('/');
    showTab(current, sub);
  }
  drawDock();
  if (sheetGame) showGame(sheetGame);
}

// The player's record changed: coins, a mission, a new level.
let level = record.level.number;
let redrawQueued = false;
record.subscribe(() => {
  const now = record.level.number;
  if (now > level) {
    let coins = 0;
    for (let l = level + 1; l <= now; l++) coins += PlayerLevel.reward(l);
    if (!playing) {
      confetti();
      sound.play('win');
      toast(L('Level {}! +{} coins', now, coins), 'coins');
    }
  }
  level = now;
  if (playing) { dirty = true; return; }
  if (redrawQueued) return;
  redrawQueued = true;
  requestAnimationFrame(() => {
    redrawQueued = false;
    drawTop();
    drawDock();
    page?.redraw();
  });
});

internet.subscribe(() => {
  if (sheetGame) renderSheetRooms(sheetGame);
  if (tab === 'home' && !playing) page?.redraw();
});

// MARK: A game's page

let sheet: HTMLElement[] = [];
let sheetGame: GameListing | null = null;
let sheetUnwatch: (() => void) | null = null;

function closeSheet(): void {
  for (const e of sheet) e.remove();
  sheet = [];
  sheetGame = null;
  sheetUnwatch?.();
  sheetUnwatch = null;
}

/** A game's page opened straight from a link has nothing behind it to go back to. */
let landedOnSheet = /^#game\//.test(location.hash);

/** Back to the tab under the sheet. */
function closeGame(): void {
  if (!landedOnSheet) { history.back(); return; }
  landedOnSheet = false;
  location.replace('#' + (tab === 'home' || !tab ? '' : tab));
}

function showGame(g: GameListing): void {
  closeSheet();
  const scrim = el('div', 'ab-sheet-scrim', app);
  scrim.onclick = closeGame;
  const card = el('div', 'ab-sheet', app);
  card.setAttribute('role', 'dialog');
  card.setAttribute('aria-label', g.title);
  sheet = [scrim, card];
  sheetGame = g;
  const hero = el('div', 'hero', card);
  const url = coverURL(g);
  if (url) img(url, hero, g.title);
  const close = el('button', 'close', hero, '✕');
  close.setAttribute('aria-label', L('Close'));
  close.onclick = closeGame;
  const body = el('div', 'body', card);
  el('h1', '', body, g.title);
  const meta = el('div', 'meta', body);
  const chip = (iconName: string, text: string) => { const s = el('span', '', meta); img(iconURL(iconName), s); el('span', '', s, text); };
  chip('badge-players', L('Up to {} players', g.maxPlayers));
  if (g.author) chip('create', g.author);
  if (g.bytes) chip('badge-downloaded', `${(g.bytes / 1024 / 1024).toFixed(1)} MB`);
  const played = record.games.get(g.id);
  if (played) {
    chip('badge-time', L('{} plays', played.plays));
    if (played.best > 0) chip('level', L('Best: {}', formatNumber(played.best)));
  }
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
  const like = el('button', 'ab-block secondary like' + (record.liked.has(g.id) ? ' on' : ''), actions);
  const drawLike = () => {
    like.innerHTML = '';
    const on = record.liked.has(g.id);
    like.classList.toggle('on', on);
    el('span', 'heart', like, on ? '♥' : '♡');
    el('span', '', like, on ? L('Liked') : L('Like'));
    like.setAttribute('aria-pressed', String(on));
  };
  drawLike();
  like.onclick = () => {
    const on = record.toggleLike(g.id);
    sound.play(on ? 'pop' : 'click');
    drawLike();
  };
  if (g.maxPlayers > 1) el('div', 'ab-sheet-rooms', body);
  renderSheetRooms(g);
  if (internet.allowsInternetPlay) sheetUnwatch = watchRooms();
  // Ready for Enter, without scrolling the picture away.
  play.focus({ preventScroll: true });
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
    ask.onclick = () => askGrownUp(lock, () => familySheet(lock, internet, () => { redrawAll(); renderSheetRooms(g); }));
    return;
  }
  const host = el('button', 'ab-block', box);
  img(iconURL('friends'), host);
  el('span', '', host, L('Open an internet room'));
  host.onclick = () => { location.hash = `host/${g.id}`; };
  const open = roomsFor(internet, g);
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
  shell.classList.add('ab-hidden');
  stage.classList.remove('ab-hidden');
  stage.innerHTML = '';
  return stage;
}

/** What playing adds to the player's record, for one game. */
function progressFor(id: string, title: string): PlayProgress {
  return {
    started: () => record.startedGame(id, title),
    played: (s) => record.played(s),
    together: () => record.playedWithOthers(),
    roundOver: (score, completed) => record.roundOver(id, score, completed),
    emote: () => record.emote(),
    picture: () => record.picture(),
    hosted: () => record.hosted(),
  };
}

/** The Plaza is not a game: only emotes and pictures count there. */
const plazaProgress: PlayProgress = {
  started: () => [], played: () => [], together: () => record.playedWithOthers(), roundOver: () => [],
  emote: () => record.emote(), picture: () => record.picture(), hosted: () => record.hosted(),
};

function startScreen(start: PlayStart, progress: PlayProgress | null): PlayScreen {
  const screen = new PlayScreen(stage, start, localPeerID(), profile, sound, network);
  screen.progress = progress;
  screen.onParting = (lines) => toast(lines.join('  ·  '), lines.some((l) => /coin|コイン/i.test(l)) ? 'coins' : 'plain');
  screen.onExit = () => {
    playing = null;
    if (/^#(play|host|join|plaza|file)/.test(location.hash)) history.back();
    setTimeout(() => { if (/^#(play|host|join|plaza|file)/.test(location.hash)) location.hash = ''; }, 50);
  };
  playing = screen;
  return screen;
}

function loadingCard(title: string, iconName = 'continue'): { fill: HTMLElement; note: HTMLElement; box: HTMLElement } {
  const box = el('div', 'ab-loading', stage);
  img(iconURL(iconName), box).className = 'cube';
  el('div', 'title', box, title);
  const bar = el('div', 'bar', box);
  const fill = el('div', '', bar);
  const note = el('div', 'note', box, L('Getting the game ready…'));
  return { fill, note, box };
}

async function play(g: GameListing, openRoom: boolean): Promise<void> {
  showStage();
  const { fill, note, box } = loadingCard(g.title);
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
    startScreen({ kind: 'solo', world, openRoom: openRoom && internet.allowsInternetPlay }, progressFor(g.id, g.title));
    box.remove();
  } catch (e) {
    box.remove();
    problem(L('That game could not be opened.'), String((e as Error)?.message ?? e));
  }
}

let pendingWorld: { world: WorldDocument; openRoom: boolean } | null = null;

function playFile(): void {
  const pending = pendingWorld;
  if (!pending) { location.replace('#create'); return; }
  showStage();
  const { world, openRoom } = pending;
  startScreen({ kind: 'solo', world, openRoom: openRoom && internet.allowsInternetPlay }, progressFor('file:' + world.id, world.name));
}

async function plaza(): Promise<void> {
  showStage();
  const { fill, box } = loadingCard(L('Ablox Plaza'), 'mascot');
  fill.style.width = '40%';
  const hash = location.hash;
  try {
    if (!games.length) games = await loadCatalogue().catch(() => []);
    const built = await buildPlaza(games, record.recent.map((r) => r.id), profile.displayName);
    if (location.hash !== hash) return;
    box.remove();
    const screen = startScreen({ kind: 'solo', world: built.world }, plazaProgress);
    screen.onTouch = (blockID) => {
      const door: PlazaDoor | undefined = built.doors.get(blockID);
      if (!door) return false;
      sound.play('whoosh');
      // Through the door: the Plaza closes, and what was behind it opens.
      location.replace('#' + (door.kind === 'game' ? `game/${door.id}` : door.hash));
      return true;
    };
  } catch (e) {
    box.remove();
    problem(L('The Plaza could not be opened.'), String((e as Error)?.message ?? e));
  }
}

async function join(roomID: string): Promise<void> {
  if (!internet.allowsInternetPlay) {
    location.replace('#rooms');
    return;
  }
  showStage();
  const { box } = loadingCard(L('Finding the room…'), 'friends');
  const hash = location.hash;
  try {
    let room = internet.rooms.find((r) => r.id === roomID);
    if (!room) room = (await internet.refreshRooms()).find((r) => r.id === roomID);
    if (location.hash !== hash) return;
    box.remove();
    if (!room) { problem(L('That room has closed.'), L('Rooms close when their host leaves.')); return; }
    const g = gameFor(games, room);
    const title = g?.title ?? room.world;
    startScreen({ kind: 'join', route: internet.route(room), title }, progressFor(g?.id ?? 'room:' + room.worldID, title));
  } catch (e) {
    box.remove();
    problem(L("Couldn't reach that internet room: {}", ''), String((e as Error)?.message ?? e));
  }
}

function problem(title: string, detail: string): void {
  const box = el('div', 'ab-error', stage);
  el('b', '', box, title);
  el('span', '', box, detail);
  const back = el('button', 'ab-block', box, L('Back to the games'));
  back.onclick = () => { location.hash = 'games'; };
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
  startScreen({ kind: 'solo', world: labWorld(n) }, null).onExit = () => { playing = null; location.hash = ''; };
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
  if (kind === 'plaza') { void plaza(); return; }
  if (kind === 'file') { playFile(); return; }
  if (playing || !stage.classList.contains('ab-hidden')) {
    stopPlaying();
    stage.classList.add('ab-hidden');
    shell.classList.remove('ab-hidden');
    if (dirty) { dirty = false; drawTop(); drawDock(); page?.redraw(); }
  }
  // The tab: the one named, or the one already under a sheet.
  switch (kind) {
    case '': case 'home': showTab('home'); break;
    case 'games': showTab('games', id); break;
    case 'rooms': showTab('games', 'rooms'); break;
    case 'me': showTab('me', id); break;
    case 'create': showTab('create'); break;
    default: if (!tab) showTab(kind === 'game' ? 'games' : 'home');
  }
  if (kind === 'settings') {
    closeSheet();
    if (!settingsOpen) {
      settingsOpen = true;
      settingsSheet(lock, internet, {
        profile: () => profile,
        saveProfile: (p) => { profile = p; saveProfile(p); page?.redraw(); },
        redraw: () => redrawAll(),
      }, () => {
        settingsOpen = false;
        if (location.hash === '#settings') history.back();
      });
    }
    return;
  }
  if (kind === 'game' && g) {
    showGame(g);
  } else {
    closeSheet();
  }
}

// A world file dropped on the page plays at once.
shell.addEventListener('dragover', (e) => { if (e.dataTransfer?.types.includes('Files')) { e.preventDefault(); shell.classList.add('dropping'); } });
shell.addEventListener('dragleave', (e) => { if (e.target === shell || !shell.contains(e.relatedTarget as Node)) shell.classList.remove('dropping'); });
shell.addEventListener('drop', (e) => {
  shell.classList.remove('dropping');
  const file = e.dataTransfer?.files?.[0];
  if (!file) return;
  e.preventDefault();
  readWorldFile(file).then((world) => ctx.playWorld(world, false), (err: unknown) => { sound.play('lose'); toast(String((err as Error)?.message ?? err)); });
});

window.addEventListener('hashchange', route);
// For poking at a running game from the console while developing.
if (import.meta.env.DEV) Object.defineProperty(window, 'ablox', { get: () => ({ playing, internet, record }) });
document.documentElement.lang = language();
drawTop();
drawDock();
if (internet.allowsInternetPlay) void internet.start();
route();
if (!hasBeenWelcomed() && !/^#(play|host|join|lab)\//.test(location.hash)) welcome(ctx, () => { drawTop(); page?.redraw(); });
try {
  games = await loadCatalogue();
} catch (e) {
  toast(L('The game list could not be loaded: {}', String((e as Error)?.message ?? e)));
}
(page as ShellPage | null)?.redraw();
// A link to a game, or to play one, waits for the list.
if (/^#(game|play|host)\//.test(location.hash)) route();
