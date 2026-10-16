// Everything drawn over the 3D view while playing: the top bar, the
// world script's own screen (ScriptHUDView.swift), the runtime's parts —
// countdown, leaderboard, dialog, inventory, shop, "Get out"
// (PartsHUD.swift) — the shooter furniture, the banner, the chat and the
// pause menu (PlayScreen.swift). Plain DOM: one element per thing, kept and
// changed in place, so a script that rewrites its score ten times a second
// moves one text node, not the screen.
import './hud.css';
import { emotes, type Emote } from '../core/model/avatar';
import { chatEmoji, quickChatGroups, ChatRateLimiter } from '../core/model/chat';
import type { ColorRGBA } from '../core/model/color';
import { reservedButtonID, uiFraction, type ReservedButton, type UIElement } from '../core/model/effects';
import { stamps } from '../core/model/player';
import { L, language, setLanguage } from '../i18n';
import type { PlaySession } from './session';
import { gamePeerID } from './session';

export const iconURL = (name: string) => new URL(`icons/${name}.webp`, document.baseURI).href;

function el<K extends keyof HTMLElementTagNameMap>(tag: K, className = '', parent?: HTMLElement, text?: string): HTMLElementTagNameMap[K] {
  const e = document.createElement(tag);
  if (className) e.className = className;
  if (text !== undefined) e.textContent = text;
  parent?.appendChild(e);
  return e;
}

function icon(name: string, parent: HTMLElement, big = false): HTMLImageElement {
  const img = el('img', big ? 'ab-icon big' : 'ab-icon', parent);
  img.src = iconURL(name);
  img.alt = '';
  img.draggable = false;
  return img;
}

const css = (c: ColorRGBA | undefined, fallback: string) =>
  c ? `rgba(${Math.round(c.r * 255)}, ${Math.round(c.g * 255)}, ${Math.round(c.b * 255)}, ${c.a})` : fallback;

/** The nearest of the nine places to a pivot, as the iPad lays a script's element out. */
const snap = (v: number) => (v < 0.34 ? 0 : v > 0.66 ? 1 : 0.5);

/** SF Symbol names a script may use for ui_image, drawn as emoji in the browser. */
const symbolGlyphs: Record<string, string> = {
  'star.fill': '⭐', star: '⭐', 'star.circle.fill': '🌟', 'heart.fill': '❤️', heart: '🤍', 'bolt.fill': '⚡', 'flame.fill': '🔥',
  'crown.fill': '👑', 'trophy.fill': '🏆', 'flag.fill': '🚩', 'flag.checkered': '🏁', 'bell.fill': '🔔', 'gift.fill': '🎁', 'cart.fill': '🛒',
  'dollarsign.circle.fill': '🪙', 'bitcoinsign.circle.fill': '🪙', timer: '⏱️', 'clock.fill': '🕒', 'hourglass': '⏳', 'key.fill': '🔑',
  'lock.fill': '🔒', 'lock.open.fill': '🔓', 'shield.fill': '🛡️', 'gamecontroller.fill': '🎮', 'person.fill': '👤', 'person.2.fill': '👥',
  'person.3.fill': '👥', 'house.fill': '🏠', 'map.fill': '🗺️', 'leaf.fill': '🍃', 'drop.fill': '💧', snowflake: '❄️', 'sun.max.fill': '☀️',
  'moon.fill': '🌙', 'moon.stars.fill': '🌙', 'cloud.fill': '☁️', 'cloud.rain.fill': '🌧️', 'cloud.bolt.fill': '⛈️', sparkles: '✨',
  'wand.and.stars': '🪄', 'hammer.fill': '🔨', 'wrench.fill': '🔧', 'checkmark.circle.fill': '✅', checkmark: '✔️', 'xmark.circle.fill': '❌',
  xmark: '✖️', 'exclamationmark.triangle.fill': '⚠️', 'questionmark.circle.fill': '❓', 'music.note': '🎵', 'speaker.wave.2.fill': '🔊',
  'camera.fill': '📷', 'car.fill': '🚗', airplane: '✈️', bicycle: '🚲', 'hare.fill': '🐇', 'tortoise.fill': '🐢', 'pawprint.fill': '🐾',
  'fish.fill': '🐟', 'ant.fill': '🐜', 'ladybug.fill': '🐞', 'bird.fill': '🐦', 'cat.fill': '🐱', 'dog.fill': '🐶', 'diamond.fill': '💎',
  'circle.fill': '⚪', 'square.fill': '⬛', 'triangle.fill': '🔺', 'arrow.up': '⬆️', 'arrow.down': '⬇️', 'arrow.left': '⬅️', 'arrow.right': '➡️',
  'arrow.up.circle.fill': '⬆️', target: '🎯', scope: '🎯', 'medal.fill': '🏅', 'cube.fill': '🧊', 'cube': '🧊', 'theatermasks.fill': '🎭',
  'paintbrush.fill': '🖌️', 'paintpalette.fill': '🎨', pencil: '✏️', 'book.fill': '📖', 'envelope.fill': '✉️', 'bag.fill': '👜',
  'basket.fill': '🧺', 'fork.knife': '🍴', 'cup.and.saucer.fill': '☕', 'birthday.cake.fill': '🎂', 'balloon.fill': '🎈',
  'party.popper.fill': '🎉', 'figure.run': '🏃', 'figure.walk': '🚶', 'hand.wave.fill': '👋', 'hand.thumbsup.fill': '👍', 'eye.fill': '👁️',
  brain: '🧠', 'battery.100': '🔋', 'lightbulb.fill': '💡', 'flashlight.on.fill': '🔦', 'gearshape.fill': '⚙️', globe: '🌍', mappin: '📍',
  'mappin.circle.fill': '📍', 'location.fill': '📍', 'tent.fill': '⛺', 'mountain.2.fill': '⛰️', 'tree.fill': '🌳', 'carrot.fill': '🥕',
  'apple.logo': '🍎', 'bolt.heart.fill': '💖', 'heart.circle.fill': '💗', 'skull.fill': '💀', 'ghost.fill': '👻', 'sword': '⚔️',
  'crossed.swords': '⚔️', 'scissors': '✂️', 'pills.fill': '💊', 'cross.case.fill': '🩹', 'bandage.fill': '🩹', 'shippingbox.fill': '📦',
  'trash.fill': '🗑️', 'tag.fill': '🏷️', 'ticket.fill': '🎟️', 'puzzlepiece.fill': '🧩', 'dice.fill': '🎲', 'die.face.5.fill': '🎲',
  'rosette': '🏵️', 'seal.fill': '🏵️', 'atom': '⚛️', 'tornado': '🌪️', 'hurricane': '🌀', 'rainbow': '🌈', 'flame': '🔥',
};

const emoteGlyphs: Record<Emote, string> = {
  wave: '👋', dance: '💃', clap: '👏', cheer: '🙌', bow: '🙇', point: '👉', laugh: '😂', sit: '🪑', hop: '🦘', spin: '🌀', flex: '💪',
  shrug: '🤷', think: '🤔', facepalm: '🤦', salute: '🫡', thumbs_up: '👍', heart_hands: '🫶', yawn: '🥱', stretch: '🧘', dab: '🙆',
  floss: '🕺', robot: '🤖', flip: '🤸', cry: '😢', stomp: '🦶', victory: '✌️', guitar: '🎸', peace: '☮️',
};

const emoteNames: Record<Emote, string> = {
  wave: 'Wave', dance: 'Dance', clap: 'Clap', cheer: 'Cheer', bow: 'Bow', point: 'Point', laugh: 'Laugh', sit: 'Sit', hop: 'Hop for joy',
  spin: 'Spin', flex: 'Flex', shrug: 'Shrug', think: 'Think', facepalm: 'Facepalm', salute: 'Salute', thumbs_up: 'Thumbs up',
  heart_hands: 'Heart hands', yawn: 'Yawn', stretch: 'Stretch', dab: 'Dab', floss: 'Floss', robot: 'Robot dance', flip: 'Flip', cry: 'Cry',
  stomp: 'Stomp', victory: 'Victory', guitar: 'Air guitar', peace: 'Peace',
};

/** An emoji, an SF Symbol name the browser can draw as one, or a box. */
function partGlyph(icon: string): string {
  if (!icon) return '📦';
  if (symbolGlyphs[icon]) return symbolGlyphs[icon];
  if (/^[a-z0-9.]+$/.test(icon)) return '📦';
  return [...icon].slice(0, 2).join('');
}

function formatSeconds(seconds: number): string {
  const whole = Math.ceil(seconds);
  return whole >= 60 ? `${Math.floor(whole / 60)}:${String(whole % 60).padStart(2, '0')}` : String(whole);
}

const formatValue = (v: number) => (Math.round(v) === v ? String(v) : v.toFixed(2));

export interface HUDHost {
  /** Leaves the game; a host with others here may hand the room on instead of closing it. */
  leave(handOver?: boolean): void;
  /** Playing alone, with internet rooms allowed: the game can be opened to others. */
  canOpenRoom(): boolean;
  openRoom(): void;
  /** Who would host if this host left now, or null. */
  successorName(): string | null;
  setMenuOpen(open: boolean): void;
  pressButton(id: string): void;
  submitText(id: string, text: string): void;
  sendChat(text: string): void;
  gesture(wire: string): void;
  reload(): void;
  restartRound(): void;
  takePicture(): void;
  setJump(held: boolean): void;
  setFire(held: boolean): void;
  setFirstPerson(on: boolean): void;
  firstPerson(): boolean;
  setting(name: 'effects' | 'music' | 'sound' | 'readLines' | 'graphics' | 'autoJump' | 'cameraFollows' | 'names', value: number | boolean | string): void;
  settings(): { effects: number; music: number; sound: boolean; readLines: boolean; graphics: string; autoJump: boolean; cameraFollows: boolean; names: boolean };
  /** Keyboard focus left the game for a text box, or came back. */
  typing(on: boolean): void;
}

export interface WaypointView { x: number; y: number; onScreen: boolean; angle: number; distance: number; label: string }

interface UINode { el: HTMLElement; kind: string; inner?: HTMLElement; input?: HTMLInputElement; canvas?: HTMLElement }

export class PlayHUD {
  readonly root: HTMLDivElement;
  private top: HTMLDivElement;
  private smallLeave: HTMLButtonElement;
  private worldChip: HTMLDivElement;
  private worldName: HTMLSpanElement;
  private scoreChip: HTMLDivElement;
  private scoreText: HTMLSpanElement;
  private chatButton: HTMLButtonElement;
  private chatBadge: HTMLSpanElement;
  private viewButton: HTMLButtonElement;
  private playersButton: HTMLButtonElement;
  private emotesButton: HTMLButtonElement;
  private side: HTMLDivElement;
  private playersCard: HTMLDivElement;
  private emotesCard: HTMLDivElement;
  private boardCard: HTMLDivElement;
  private canvasLayer: HTMLDivElement;
  private nodes = new Map<string, UINode>();
  private crosshair: HTMLDivElement;
  private hitmark: HTMLDivElement;
  private health: HTMLDivElement;
  private healthFill: HTMLDivElement;
  private healthNum: HTMLSpanElement;
  private knocked: HTMLDivElement;
  private damage: HTMLDivElement;
  private fade: HTMLDivElement;
  private countdown: HTMLDivElement;
  private countdownLabel: HTMLElement;
  private countdownTime: HTMLElement;
  private bottom: HTMLDivElement;
  private vehicleButton: HTMLButtonElement;
  private dialogCard: HTMLDivElement;
  private inventory: HTMLDivElement;
  private shopScrim: HTMLDivElement | null = null;
  private shopCard: HTMLDivElement | null = null;
  private announce: HTMLDivElement;
  private chat: HTMLDivElement;
  private chatLog: HTMLDivElement;
  private chatInput: HTMLInputElement;
  private chatNote: HTMLDivElement;
  private scriptLog: HTMLDivElement;
  private waypoint: HTMLDivElement;
  private touch: HTMLDivElement;
  private combat: HTMLDivElement;
  private ammo: HTMLDivElement;
  private fireButton: HTMLButtonElement;
  private menu: HTMLDivElement;
  private menuScrim: HTMLDivElement;
  private hint: HTMLDivElement;
  private toast: HTMLDivElement | null = null;

  private showPlayers = false;
  private showEmotes = false;
  private showChat = false;
  private menuOpen = false;
  private seenChat = 0;
  private hitSerial = 0;
  private damageSerial = 0;
  private fadeSerial = 0;
  private countdownSerial = -1;
  private countdownEnds = 0;
  private dialogKey = '';
  private shopKey = '';
  private inventoryKey = '';
  private boardKey = '';
  private playersKey = '';
  private logKey = '';
  private announceKey = '';
  private uiRevision = -1;
  private limiter = new ChatRateLimiter();
  readonly coarse = typeof matchMedia === 'function' && matchMedia('(pointer: coarse)').matches;

  constructor(container: HTMLElement, private session: PlaySession, private host: HUDHost) {
    this.root = el('div', 'ab-hud', container);
    const r = this.root;

    this.damage = el('div', 'ab-damage', r);
    this.canvasLayer = el('div', 'ab-canvas-layer below-bar', r);
    this.crosshair = el('div', 'ab-crosshair ab-hidden', r);
    this.hitmark = el('div', 'ab-hitmark', r, '✕');
    this.health = el('div', 'ab-health ab-glass ab-hidden', r);
    el('span', '', this.health, '❤️');
    const track = el('div', 'track', this.health);
    this.healthFill = el('div', 'fill', track);
    this.healthNum = el('span', 'num', this.health);
    this.knocked = el('div', 'ab-knocked ab-hidden', r);
    el('b', '', this.knocked, L('Knocked out'));
    el('small', '', this.knocked, L("You'll be back in a moment."));

    // Top bar.
    this.top = el('div', 'ab-top', r);
    const leave = this.roundButton('✕', L('Leave world'), () => this.host.leave());
    leave.style.fontSize = '18px';
    this.roundButton('', L('Menu'), () => this.setMenu(true), 'hud-menu');
    this.worldChip = el('div', 'ab-chip ab-glass world', this.top);
    icon('continue', this.worldChip);
    this.worldName = el('span', '', this.worldChip);
    el('div', 'ab-spacer', this.top);
    this.scoreChip = el('div', 'ab-chip ab-glass', this.top);
    icon('coin', this.scoreChip);
    this.scoreText = el('span', '', this.scoreChip, '0');
    this.viewButton = this.roundButton('👁', L('First or third person'), () => {
      this.host.setFirstPerson(!this.host.firstPerson());
      this.render();
    });
    this.emotesButton = this.roundButton('', L('Emotes'), () => { this.showEmotes = !this.showEmotes; this.showPlayers = false; this.render(); }, 'hud-emote');
    this.playersButton = this.roundButton('', L('Scoreboard'), () => { this.showPlayers = !this.showPlayers; this.showEmotes = false; this.render(); }, 'hud-players');
    this.roundButton('', L('Take a picture'), () => this.host.takePicture(), 'hud-camera');
    this.chatButton = this.roundButton('', L('Chat'), () => this.toggleChat(), 'hud-chat');
    this.chatBadge = el('span', 'ab-badge ab-hidden', this.chatButton);
    this.smallLeave = el('button', 'ab-round ab-x-small ab-hidden', r, '✕');
    this.smallLeave.setAttribute('aria-label', L('Leave world'));
    this.smallLeave.onclick = () => this.host.leave();

    this.side = el('div', 'ab-side', r);
    this.playersCard = el('div', 'ab-card ab-glass ab-players ab-hidden', this.side);
    this.emotesCard = el('div', 'ab-card ab-glass ab-emotes ab-hidden', this.side);
    this.buildEmotes();
    this.boardCard = el('div', 'ab-card ab-board ab-hidden', this.side);

    this.countdown = el('div', 'ab-countdown ab-hidden', r);
    this.countdownLabel = el('small', '', this.countdown);
    this.countdownTime = el('b', '', this.countdown);

    this.bottom = el('div', 'ab-bottom', r);
    this.vehicleButton = el('button', 'ab-block secondary ab-hidden', this.bottom, '🚶 ' + L('Get out'));
    this.vehicleButton.onclick = () => this.press({ kind: 'exitVehicle' });
    this.dialogCard = el('div', 'ab-dialog ab-hidden', this.bottom);
    this.inventory = el('div', 'ab-inventory ab-hidden', this.bottom);

    this.announce = el('div', 'ab-announce ab-glass ab-hidden', r);

    this.chat = el('div', 'ab-chat ab-glass ab-hidden', r);
    this.chatLog = el('div', 'ab-chat-log', this.chat);
    const quick = el('div', 'ab-quick', this.chat);
    for (const e of chatEmoji) {
      const b = el('button', 'emoji', quick, e);
      b.onclick = () => this.sendChat(e);
    }
    for (const group of quickChatGroups) {
      for (const phrase of group.phrases.slice(0, 3)) {
        const b = el('button', '', quick, L(phrase));
        b.onclick = () => this.sendChat(L(phrase));
      }
    }
    const form = el('form', 'ab-chat-form', this.chat);
    this.chatInput = el('input', '', form);
    this.chatInput.maxLength = 240;
    this.chatInput.placeholder = L('Say something…');
    this.chatInput.enterKeyHint = 'send';
    this.chatInput.autocomplete = 'off';
    this.chatInput.onfocus = () => this.host.typing(true);
    this.chatInput.onblur = () => this.host.typing(false);
    this.chatInput.onkeydown = (e) => { if (e.key === 'Escape') { this.chatInput.blur(); e.stopPropagation(); } };
    const send = el('button', 'ab-block', form, L('Send'));
    send.type = 'submit';
    form.onsubmit = (e) => {
      e.preventDefault();
      const text = this.chatInput.value;
      if (this.sendChat(text)) this.chatInput.value = '';
    };
    this.chatNote = el('div', 'ab-chat-note ab-hidden', this.chat);

    this.scriptLog = el('div', 'ab-scriptlog ab-glass ab-hidden', r);
    this.waypoint = el('div', 'ab-waypoint ab-hidden', r);

    this.touch = el('div', 'ab-touch', r);
    this.combat = el('div', 'ab-combat ab-hidden', this.touch);
    const combatSide = el('div', 'ab-combat-side', this.combat);
    this.ammo = el('div', 'ab-ammo ab-glass ab-hidden', combatSide);
    const reload = el('button', 'ab-round ab-reload', combatSide, '⟳');
    reload.setAttribute('aria-label', L('Reload'));
    reload.onclick = () => this.host.reload();
    this.fireButton = el('button', 'ab-fire', this.combat, '🎯');
    this.fireButton.setAttribute('aria-label', L('Fire'));
    this.hold(this.fireButton, (held) => this.host.setFire(held));
    if (this.coarse) {
      const jump = el('button', 'ab-jump', this.touch);
      jump.setAttribute('aria-label', L('Jump'));
      icon('hud-jump', jump);
      this.hold(jump, (held) => this.host.setJump(held));
    }
    this.hint = el('div', 'ab-desk-hint' + (this.coarse ? ' ab-hidden' : ''), r);
    this.hint.innerHTML = '';
    for (const line of [L('W A S D: walk · Space: jump · Shift: run'), L('Drag: look · Wheel: zoom · T: chat · F: fire · V: view')]) el('div', '', this.hint, line);
    setTimeout(() => this.hint.classList.add('ab-hidden'), 12000);

    this.fade = el('div', 'ab-fade', r);
    this.menuScrim = el('div', 'ab-scrim ab-hidden', r);
    this.menuScrim.onclick = () => this.setMenu(false);
    this.menu = el('div', 'ab-menu ab-glass ab-hidden', r);

    session.subscribe(() => this.render());
    this.render();
  }

  private roundButton(text: string, label: string, action: () => void, iconName?: string): HTMLButtonElement {
    const b = el('button', 'ab-round', this.top, text);
    if (iconName) icon(iconName, b);
    b.setAttribute('aria-label', label);
    b.title = label;
    b.onclick = action;
    return b;
  }

  /** Held, not tapped: pressing keeps firing (or jumping) until let go. */
  private hold(button: HTMLElement, set: (held: boolean) => void): void {
    const down = (e: PointerEvent) => { e.preventDefault(); button.setPointerCapture(e.pointerId); button.classList.add('down'); set(true); };
    const up = () => { button.classList.remove('down'); set(false); };
    button.addEventListener('pointerdown', down);
    button.addEventListener('pointerup', up);
    button.addEventListener('pointercancel', up);
    button.addEventListener('contextmenu', (e) => e.preventDefault());
  }

  private press(button: ReservedButton): void { this.host.pressButton(reservedButtonID(button)); }

  // MARK: Keys

  /** One-press keys, as the iPad's keyboard has them. True when the HUD used the key. */
  key(k: string): boolean {
    if (k === 'escape') {
      if (this.session.scripted.shop) { this.press({ kind: 'closeShop' }); return true; }
      if (this.showChat) { this.toggleChat(); return true; }
      this.setMenu(!this.menuOpen);
      return true;
    }
    if (this.menuOpen) return false;
    if (k === 't' || k === 'enter' || k === '/') {
      if (!this.showChat) this.toggleChat();
      setTimeout(() => this.chatInput.focus(), 0);
      return true;
    }
    if (k === 'tab') { this.showPlayers = !this.showPlayers; this.render(); return true; }
    if (k === 'v') { this.host.setFirstPerson(!this.host.firstPerson()); this.render(); return true; }
    if (k === 'p') { this.host.takePicture(); return true; }
    if (/^[1-9]$/.test(k)) {
      const item = this.session.scripted.inventory[Number(k) - 1];
      if (item) { this.press({ kind: 'use', item: item.name }); return true; }
    }
    if (k === 'enter' && this.session.scripted.dialog?.choices.length === 0) { this.press({ kind: 'closeDialog' }); return true; }
    return false;
  }

  get isMenuOpen(): boolean { return this.menuOpen; }

  // MARK: Chat

  private toggleChat(): void {
    this.showChat = !this.showChat;
    if (this.showChat) this.seenChat = this.session.chatLog.length;
    else this.chatInput.blur();
    this.render();
  }

  private sendChat(text: string): boolean {
    const line = text.trim();
    if (!line) return false;
    const verdict = this.limiter.allow(line, performance.now() / 1000);
    if (verdict.kind === 'repeated') { this.note(L('You just said that.')); return false; }
    if (verdict.kind === 'tooFast') { this.note(L('Slow down a little — wait {} seconds.', verdict.seconds)); return false; }
    this.chatNote.classList.add('ab-hidden');
    this.host.sendChat(line);
    return true;
  }

  private note(text: string): void {
    this.chatNote.textContent = text;
    this.chatNote.classList.remove('ab-hidden');
  }

  // MARK: Menu

  setMenu(open: boolean): void {
    if (open === this.menuOpen) return;
    this.menuOpen = open;
    this.menuScrim.classList.toggle('ab-hidden', !open);
    this.menu.classList.toggle('ab-hidden', !open);
    if (open) this.buildMenu();
    this.host.setMenuOpen(open);
  }

  private buildMenu(): void {
    const m = this.menu;
    m.innerHTML = '';
    const h = el('h2', '', m);
    icon('continue', h, true);
    el('span', '', h, this.session.world.name);
    const s0 = this.session;
    el('div', 'sub', m, s0.isSolo ? L('Paused — playing alone')
      : s0.role === 'hosting' && s0.room ? L('Your internet room · {}', s0.roomCode)
      : s0.role === 'joined' ? L('In an internet room') : L('Menu'));
    const stack = el('div', 'stack', m);
    const item = (cls: string, iconName: string, text: string, action: () => void) => {
      const b = el('button', 'ab-block ' + cls, stack);
      icon(iconName, b);
      el('span', '', b, text);
      b.onclick = action;
      return b;
    };
    item('green', 'tool-play', L('Keep playing'), () => this.setMenu(false)).focus();
    if (this.session.role === 'hosting') {
      item('secondary', 'tool-rotate', L('Start the round again'), () => { this.host.restartRound(); this.setMenu(false); });
    }
    if (this.host.canOpenRoom()) {
      item('secondary', 'friends', L('Let friends join over the internet'), () => { this.host.openRoom(); this.setMenu(false); });
    }
    m.appendChild(el('hr'));

    const s = this.host.settings();
    const settings = el('div', '', m);
    const range = (label: string, value: number, set: (v: number) => void) => {
      const row = el('div', 'ab-setting', settings);
      el('label', '', row, label);
      const input = el('input', '', row);
      input.type = 'range';
      input.min = '0';
      input.max = '1';
      input.step = '0.05';
      input.value = String(value);
      input.oninput = () => set(Number(input.value));
    };
    const toggle = (label: string, on: boolean, set: (v: boolean) => void) => {
      const row = el('div', 'ab-setting', settings);
      el('label', '', row, label);
      const t = el('button', 'ab-toggle' + (on ? ' on' : ''), row);
      t.setAttribute('role', 'switch');
      t.setAttribute('aria-checked', String(on));
      t.setAttribute('aria-label', label);
      t.onclick = () => {
        const next = !t.classList.contains('on');
        t.classList.toggle('on', next);
        t.setAttribute('aria-checked', String(next));
        set(next);
      };
    };
    const segments = (label: string, options: [string, string][], value: string, set: (v: string) => void) => {
      const row = el('div', 'ab-setting', settings);
      el('label', '', row, label);
      const seg = el('div', 'ab-seg', row);
      for (const [key, text] of options) {
        const b = el('button', key === value ? 'on' : '', seg, text);
        b.onclick = () => {
          for (const c of seg.children) c.classList.remove('on');
          b.classList.add('on');
          set(key);
        };
      }
    };
    toggle(L('Sound'), s.sound, (v) => this.host.setting('sound', v));
    range(L('Sound effects'), s.effects, (v) => this.host.setting('effects', v));
    range(L('Music'), s.music, (v) => this.host.setting('music', v));
    segments(L('Graphics'), [['low', L('Low')], ['medium', L('Medium')], ['high', L('High')]], s.graphics, (v) => this.host.setting('graphics', v));
    toggle(L('Jump up steps by myself'), s.autoJump, (v) => this.host.setting('autoJump', v));
    toggle(L('Camera follows behind me'), s.cameraFollows, (v) => this.host.setting('cameraFollows', v));
    toggle(L('Names over heads'), s.names, (v) => this.host.setting('names', v));
    toggle(L('Read lines aloud'), s.readLines, (v) => this.host.setting('readLines', v));
    segments(L('Language'), [['ja', '日本語'], ['en', 'English']], language(), (v) => {
      setLanguage(v as 'ja' | 'en');
      this.buildMenu();
      this.render();
    });
    m.appendChild(el('hr'));
    const next = this.host.successorName();
    if (next) {
      const hand = el('button', 'ab-block secondary', m);
      hand.style.width = '100%';
      hand.style.marginBottom = '10px';
      el('span', '', hand, L('Leave, and let {} host', next));
      hand.onclick = () => this.host.leave(true);
    }
    const leave = el('button', 'ab-block danger', m);
    leave.style.width = '100%';
    el('span', '', leave, '✕ ' + (next ? L('Close the room for everyone') : L('Leave world')));
    leave.onclick = () => this.host.leave();
  }

  // MARK: Showing

  /** Brief words in the middle of the screen. */
  showToast(text: string, seconds = 2.2): void {
    this.toast?.remove();
    const t = el('div', 'ab-toast ab-glass', this.root, text);
    this.toast = t;
    setTimeout(() => { if (this.toast === t) { t.remove(); this.toast = null; } }, seconds * 1000);
  }

  /** Everything that follows the session: called when it changes. */
  render(): void {
    const s = this.session;
    const scripted = s.scripted;
    const defaultUI = scripted.showsDefaultUI;
    this.top.classList.toggle('ab-hidden', !defaultUI);
    this.smallLeave.classList.toggle('ab-hidden', defaultUI);
    this.side.classList.toggle('ab-hidden', !defaultUI && !scripted.leaderboard);
    this.canvasLayer.classList.toggle('below-bar', defaultUI);
    this.countdown.classList.toggle('bare', !defaultUI);

    this.worldName.textContent = s.world.name;
    this.scoreText.textContent = String(s.localPlayer?.score ?? 0);
    this.viewButton.classList.toggle('ab-hidden', scripted.camera.mode !== 'third');
    this.viewButton.classList.toggle('on', this.host.firstPerson());
    this.emotesButton.classList.toggle('on', this.showEmotes);
    this.playersButton.classList.toggle('on', this.showPlayers);
    this.chatButton.classList.toggle('on', this.showChat);

    // Chat.
    const log = s.visibleChatLog;
    if (this.showChat) this.seenChat = s.chatLog.length;
    const unread = Math.max(0, s.chatLog.length - this.seenChat);
    this.chatBadge.classList.toggle('ab-hidden', unread === 0 || this.showChat);
    this.chatBadge.textContent = unread > 9 ? '9+' : String(unread);
    this.chat.classList.toggle('ab-hidden', !this.showChat || !defaultUI);
    const lastID = log.length ? log[log.length - 1].id : 0;
    if (this.showChat && this.chatLog.dataset.last !== String(lastID)) {
      this.chatLog.dataset.last = String(lastID);
      this.chatLog.innerHTML = '';
      for (const line of log.slice(-40)) {
        const row = el('div', 'ab-chat-line' + (line.senderID === gamePeerID ? ' game' : '') + (line.wasFiltered ? ' filtered' : ''), this.chatLog);
        const who = el('span', 'who', row, line.senderName + ':');
        if (line.senderID === s.localPeerID) who.style.color = 'var(--ab-accent)';
        el('span', 'text', row, line.text);
        if (line.wasFiltered) el('span', 'flag', row, L('(filtered)'));
      }
      this.chatLog.scrollTop = this.chatLog.scrollHeight;
    }

    // Players.
    this.playersCard.classList.toggle('ab-hidden', !this.showPlayers);
    if (this.showPlayers) {
      const people = [...s.people].sort((a, b) => b.score - a.score);
      const key = people.map((p) => `${p.peerID}:${p.score}:${p.profile.displayName}`).join('|');
      if (key !== this.playersKey) {
        this.playersKey = key;
        this.playersCard.innerHTML = '';
        el('h3', '', this.playersCard, L('Players'));
        if (!people.length) el('div', '', this.playersCard, L('Just you so far.'));
        for (const p of people) {
          const row = el('div', 'ab-player' + (p.peerID === s.localPeerID ? ' me' : ''), this.playersCard);
          const dot = el('span', 'dot', row);
          dot.style.background = css(p.profile.bodyColor, '#888');
          el('span', 'name', row, p.profile.displayName);
          el('span', 'score', row, String(p.score));
        }
      }
    }
    this.emotesCard.classList.toggle('ab-hidden', !this.showEmotes);

    // The script's screen.
    if (scripted.revision !== this.uiRevision) {
      this.uiRevision = scripted.revision;
      this.renderScriptUI();
      this.renderParts();
    }

    // Banner.
    const a = s.announcement;
    const announceKey = a ? `${a.message}@${a.expiresAt}` : '';
    if (announceKey !== this.announceKey) {
      this.announceKey = announceKey;
      this.announce.classList.toggle('ab-hidden', !a);
      if (a) {
        this.announce.textContent = L(a.message);
        // Restart the bounce for a new message.
        this.announce.style.animation = 'none';
        void this.announce.offsetWidth;
        this.announce.style.animation = '';
      }
    }

    // Script problems, for the host, who can fix the world.
    const lines = s.scriptLog.slice(-4);
    const logKey = lines.map((l) => l.id).join(',');
    if (logKey !== this.logKey) {
      this.logKey = logKey;
      this.scriptLog.classList.toggle('ab-hidden', !lines.length || s.role !== 'hosting');
      this.scriptLog.innerHTML = '';
      const head = el('div', 'head', this.scriptLog);
      el('span', '', head, '{ } ' + L('Script'));
      const close = el('button', 'ab-close', head, '✕');
      close.setAttribute('aria-label', L('Dismiss'));
      close.onclick = () => s.clearScriptLog();
      for (const line of lines) el('div', 'line' + (line.isError ? ' error' : ''), this.scriptLog, line.text);
    }
    this.scriptLog.style.bottom = this.showChat ? 'calc(max(130px, env(safe-area-inset-bottom) + 120px) + 290px)' : '';
  }

  private buildEmotes(): void {
    const c = this.emotesCard;
    el('h3', '', c, L('Emotes'));
    const grid = el('div', 'ab-emote-grid', c);
    for (const e of emotes) {
      const b = el('button', '', grid);
      el('span', 'glyph', b, emoteGlyphs[e]);
      el('span', '', b, L(emoteNames[e]));
      b.onclick = () => { this.host.gesture(e); this.showEmotes = false; this.render(); };
    }
    const stampGrid = el('div', 'ab-stamp-grid', c);
    for (const stamp of stamps) {
      const b = el('button', '', stampGrid, stamp);
      b.onclick = () => { this.host.gesture('stamp:' + stamp); this.showEmotes = false; this.render(); };
    }
  }

  // MARK: The script's own elements

  private renderScriptUI(): void {
    const scripted = this.session.scripted;
    const seen = new Set<string>();
    const place = (parent: string | null, container: HTMLElement) => {
      for (const e of scripted.children(parent)) {
        seen.add(e.id);
        const node = this.nodeFor(e, container);
        this.style(node, e);
        if (node.canvas) place(e.id, node.canvas);
      }
    };
    place(null, this.canvasLayer);
    for (const [id, node] of this.nodes) {
      if (!seen.has(id)) {
        node.el.remove();
        this.nodes.delete(id);
      }
    }
  }

  private nodeFor(e: UIElement, container: HTMLElement): UINode {
    let node = this.nodes.get(e.id);
    if (node && node.kind !== e.kind) {
      node.el.remove();
      this.nodes.delete(e.id);
      node = undefined;
    }
    if (!node) {
      const id = e.id;
      switch (e.kind) {
        case 'button': {
          const b = el('button', 'ab-ui button');
          b.onclick = () => this.host.pressButton(id);
          node = { el: b, kind: e.kind };
          break;
        }
        case 'bar': {
          const d = el('div', 'ab-ui bar');
          node = { el: d, kind: e.kind, inner: el('div', '', d) };
          break;
        }
        case 'input': {
          const form = el('form', 'ab-ui input');
          const input = el('input', '', form);
          input.maxLength = 500;
          input.autocomplete = 'off';
          input.onfocus = () => this.host.typing(true);
          input.onblur = () => this.host.typing(false);
          const send = el('button', '', form, '↑');
          send.type = 'submit';
          send.setAttribute('aria-label', L('Send'));
          form.onsubmit = (ev) => {
            ev.preventDefault();
            const text = input.value.trim();
            if (!text) return;
            this.host.submitText(id, text);
            input.value = '';
          };
          node = { el: form, kind: e.kind, input };
          break;
        }
        case 'panel': {
          const d = el('div', 'ab-ui panel');
          node = { el: d, kind: e.kind, canvas: el('div', 'ab-canvas-layer', d) };
          break;
        }
        default:
          node = { el: el('div', `ab-ui ${e.kind}`), kind: e.kind };
      }
      this.nodes.set(e.id, node);
    }
    // Appended in order every time, so a later layer is always on top.
    container.appendChild(node.el);
    return node;
  }

  private style(node: UINode, e: UIElement): void {
    const st = node.el.style;
    const px = snap(e.pivotX), py = snap(e.pivotY);
    st.left = `calc(${e.x * 100}% + ${e.offsetX}px)`;
    st.top = `calc(${e.y * 100}% + ${e.offsetY}px)`;
    st.transform = `translate(${-px * 100}%, ${-py * 100}%)`;
    st.opacity = String(e.opacity);
    st.fontSize = `${e.fontSize}px`;
    st.fontWeight = e.bold ? '800' : '500';
    st.borderRadius = `${e.cornerRadius}px`;
    st.color = css(e.color, '#fff');
    st.width = e.width !== undefined ? `${e.width}px` : '';
    st.height = e.height !== undefined ? `${e.height}px` : '';
    switch (e.kind) {
      case 'panel':
        st.width = `${e.width ?? 320}px`;
        st.height = `${e.height ?? 220}px`;
        st.background = css(e.background, 'rgba(0,0,0,0.5)');
        break;
      case 'text':
        node.el.textContent = e.text;
        node.el.classList.toggle('boxed', !!e.background);
        st.background = css(e.background, 'transparent');
        break;
      case 'button':
        node.el.textContent = e.text;
        st.background = css(e.background, 'var(--ab-accent-deep)');
        break;
      case 'image':
        node.el.textContent = symbolGlyphs[e.text] ?? (/^[a-z0-9.]+$/.test(e.text) ? '' : e.text);
        st.background = css(e.background, 'transparent');
        break;
      case 'bar':
        st.width = `${e.width ?? 200}px`;
        st.height = `${e.height ?? 14}px`;
        st.background = css(e.background, 'rgba(0,0,0,0.4)');
        node.inner!.style.width = `${uiFraction(e) * 100}%`;
        node.inner!.style.background = css(e.color, 'var(--ab-accent)');
        node.inner!.style.borderRadius = `${e.cornerRadius}px`;
        break;
      case 'input':
        st.width = `${e.width ?? 260}px`;
        st.background = css(e.background, 'rgba(0,0,0,0.5)');
        node.input!.placeholder = e.text;
        break;
    }
  }

  // MARK: The runtime's parts

  private renderParts(): void {
    const scripted = this.session.scripted;

    // Countdown, from when it was last set.
    if (scripted.countdownSerial !== this.countdownSerial) {
      this.countdownSerial = scripted.countdownSerial;
      this.countdownEnds = performance.now() + (scripted.countdown?.seconds ?? 0) * 1000;
    }
    this.countdown.classList.toggle('ab-hidden', !scripted.countdown);
    this.countdownLabel.textContent = scripted.countdown?.label ?? '';
    this.countdownLabel.classList.toggle('ab-hidden', !scripted.countdown?.label);

    // Leaderboard.
    const board = scripted.leaderboard;
    const boardKey = board ? JSON.stringify(board) : '';
    if (boardKey !== this.boardKey) {
      this.boardKey = boardKey;
      this.boardCard.classList.toggle('ab-hidden', !board);
      this.boardCard.innerHTML = '';
      if (board) {
        const head = el('div', 'ab-board-head', this.boardCard);
        icon('me-trophies', head);
        el('span', 'title', head, board.title);
        const close = el('button', 'ab-close', head, '✕');
        close.setAttribute('aria-label', L('Close'));
        close.onclick = () => this.press({ kind: 'closeLeaderboard' });
        if (!board.rows.length) el('div', '', this.boardCard, L('No scores yet.')).style.color = 'var(--ab-ink-muted)';
        board.rows.forEach((row, i) => {
          const r = el('div', 'ab-board-row', this.boardCard);
          el('span', 'rank', r, String(i + 1));
          el('span', 'name', r, row.name);
          el('span', 'value', r, formatValue(row.value));
        });
      }
    }

    this.vehicleButton.classList.toggle('ab-hidden', !scripted.inVehicle);

    // Dialog.
    const dialog = scripted.dialog;
    const dialogKey = dialog ? JSON.stringify(dialog) : '';
    if (dialogKey !== this.dialogKey) {
      this.dialogKey = dialogKey;
      this.dialogCard.classList.toggle('ab-hidden', !dialog);
      this.dialogCard.innerHTML = '';
      if (dialog) {
        if (dialog.speaker) el('div', 'speaker', this.dialogCard, dialog.speaker);
        el('div', 'words', this.dialogCard, dialog.text);
        const choices = el('div', 'choices', this.dialogCard);
        if (!dialog.choices.length) {
          const ok = el('button', 'ab-block', choices, L('OK'));
          ok.onclick = () => this.press({ kind: 'closeDialog' });
        } else {
          dialog.choices.forEach((choice, index) => {
            const b = el('button', index === 0 ? 'ab-block' : 'ab-block secondary', choices, choice);
            b.onclick = () => this.press({ kind: 'choose', dialog: dialog.id, index });
          });
        }
      }
    }

    // Inventory.
    const items = scripted.inventory;
    const inventoryKey = JSON.stringify(items);
    if (inventoryKey !== this.inventoryKey) {
      this.inventoryKey = inventoryKey;
      this.inventory.classList.toggle('ab-hidden', !items.length);
      this.inventory.innerHTML = '';
      items.forEach((item, i) => {
        const b = el('button', 'ab-item', this.inventory);
        b.setAttribute('aria-label', L('Use {}', item.name));
        el('span', 'glyph', b, partGlyph(item.icon));
        el('span', 'label', b, item.name);
        if (item.count > 1) el('span', 'count', b, String(item.count));
        if (!this.coarse && i < 9) el('span', 'key', b, String(i + 1));
        b.onclick = () => this.press({ kind: 'use', item: item.name });
      });
    }

    // Shop.
    const shop = scripted.shop;
    const shopKey = shop ? JSON.stringify(shop) : '';
    if (shopKey !== this.shopKey) {
      this.shopKey = shopKey;
      if (!shop) {
        this.shopCard?.remove();
        this.shopScrim?.remove();
      } else {
        this.shopScrim?.remove();
        this.shopCard?.remove();
        this.shopScrim = el('div', 'ab-scrim', this.root);
        this.shopScrim.onclick = () => this.press({ kind: 'closeShop' });
        this.shopCard = el('div', 'ab-shop', this.root);
        const head = el('div', 'ab-shop-head', this.shopCard);
        el('span', 'title', head, shop.title || L('Shop'));
        const balance = el('span', 'balance', head);
        icon('coin', balance);
        el('span', '', balance, `${shop.balance} ${L(shop.currency)}`);
        const close = el('button', 'ab-close', head, '✕');
        close.setAttribute('aria-label', L('Close'));
        close.onclick = () => this.press({ kind: 'closeShop' });
        const grid = el('div', 'ab-shop-grid', this.shopCard);
        for (const offer of shop.offers) {
          const affordable = shop.balance >= offer.price;
          const b = el('button', 'ab-offer' + (affordable ? '' : ' poor'), grid);
          el('span', 'glyph', b, partGlyph(offer.icon));
          el('span', '', b, offer.name);
          el('span', 'price', b, offer.price === 0 ? L('Free') : String(offer.price));
          b.onclick = () => this.press({ kind: 'buy', shop: shop.id, item: offer.name });
        }
      }
    }

    // Combat.
    const armed = !!scripted.weapon;
    this.combat.classList.toggle('ab-hidden', !armed || !this.coarse || !scripted.showsControls);
    this.crosshair.classList.toggle('ab-hidden', !(armed || scripted.camera.mode === 'first'));
    const ammo = scripted.ammo;
    this.ammo.classList.toggle('ab-hidden', !ammo);
    if (ammo) {
      this.ammo.textContent = ammo.isReloading ? '…' : `${ammo.current} / ${ammo.magazine}`;
      this.ammo.classList.toggle('empty', ammo.current === 0);
    }
    this.fireButton.classList.toggle('off', !scripted.canFire);
    this.touch.classList.toggle('ab-hidden', !scripted.showsControls);

    const health = scripted.health;
    this.health.classList.toggle('ab-hidden', !health);
    if (health) {
      const f = scripted.healthFraction;
      this.healthFill.style.width = `${f * 100}%`;
      this.healthFill.style.background = f > 0.5 ? 'var(--ab-success)' : f > 0.25 ? 'var(--ab-warning)' : 'var(--ab-danger)';
      this.healthNum.textContent = String(Math.round(health.current));
    }
    this.knocked.classList.toggle('ab-hidden', !scripted.isKnockedOut);
    this.bottom.classList.toggle('raised', !!health);

    // A hit, a hurt, a fade: each once per new count.
    if (scripted.hitMarkerCount !== this.hitSerial) {
      this.hitSerial = scripted.hitMarkerCount;
      this.hitmark.classList.toggle('ko', scripted.lastHitWasKnockout);
      this.hitmark.classList.add('show');
      setTimeout(() => this.hitmark.classList.remove('show'), 180);
    }
    if (scripted.damageFlashCount !== this.damageSerial) {
      this.damageSerial = scripted.damageFlashCount;
      const gentle = false;
      this.damage.style.transition = 'none';
      this.damage.style.opacity = gentle ? '0.35' : '1';
      void this.damage.offsetWidth;
      this.damage.style.transition = `opacity ${gentle ? 0.8 : 0.45}s ease-out`;
      this.damage.style.opacity = '0';
    }
    if (scripted.fade.serial !== this.fadeSerial) {
      this.fadeSerial = scripted.fade.serial;
      const f = scripted.fade;
      this.fade.style.transition = `opacity ${Math.max(0, f.seconds)}s ease-in-out`;
      if (f.color) this.fade.style.background = css({ ...f.color, a: 1 }, '#000');
      this.fade.style.opacity = f.color ? '1' : '0';
    }
  }

  // MARK: Every frame

  /** The parts that move with time or the camera. */
  frame(waypoint: WaypointView | null): void {
    const scripted = this.session.scripted;
    if (scripted.countdown) {
      const left = Math.max(0, (this.countdownEnds - performance.now()) / 1000);
      const text = formatSeconds(left);
      if (this.countdownTime.textContent !== text) this.countdownTime.textContent = text;
      this.countdownTime.classList.toggle('low', left <= 10);
    }
    if (!waypoint) {
      this.waypoint.classList.add('ab-hidden');
      return;
    }
    const w = this.waypoint;
    w.classList.remove('ab-hidden');
    w.classList.toggle('edge', !waypoint.onScreen);
    const label = `${waypoint.label ? waypoint.label + ' · ' : ''}${Math.round(waypoint.distance)}m`;
    if (w.dataset.label !== label || w.dataset.edge !== String(!waypoint.onScreen)) {
      w.dataset.label = label;
      w.dataset.edge = String(!waypoint.onScreen);
      w.innerHTML = '';
      const pin = el('div', 'pin', w, waypoint.onScreen ? '📍' : '➤');
      pin.dataset.role = 'pin';
      el('div', 'tag', w, label);
    }
    w.style.left = `${waypoint.x}px`;
    w.style.top = `${waypoint.y}px`;
    const pin = w.firstElementChild as HTMLElement | null;
    if (pin) pin.style.transform = waypoint.onScreen ? '' : `rotate(${waypoint.angle - Math.PI / 2}rad)`;
  }

  dispose(): void {
    this.root.remove();
  }
}
