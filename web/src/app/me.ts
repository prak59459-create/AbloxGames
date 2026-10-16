// Me: your avatar on a stage and everything it can wear — colours, hats,
// faces, pets, trails, auras, name cards and chat bubbles — with the shop
// built in: anything not yet yours can be tried on before it is bought.
// Then the emotes to try, and the badges, the title under your name and
// your records.
import { bubbleColours, emotes, namePlateColours, type AvatarProfile, type Emote } from '../core/model/avatar';
import { cssColor } from '../core/model/color';
import {
  itemName, itemsOf, purchaseMessage, rarity, rarityColor, rarityName, shopItems, type ShopItem, type ShopKind,
} from '../core/model/economy';
import { achievements, badgeDetail, badgeProgress, badgeTitle, badges, earnedBadges, isEarned } from '../core/model/progress';
import { L } from '../i18n';
import { emoteGlyphs, emoteNames } from '../play/hud';
import { AvatarStage } from './avatarStage';
import { coinBurst, confetti } from './effects';
import { isWorn, wearing } from './player';
import { duration, formatNumber, icon, meter, type ShellContext, type ShellPage } from './shell';
import { el } from './sheets';
import { thumbnails } from './thumbnails';

export type MeSection = 'colors' | 'hat' | 'face' | 'pet' | 'trail' | 'aura' | 'cards' | 'emotes' | 'badges';

const sections: { id: MeSection; icon: string; name: string }[] = [
  { id: 'colors', icon: 'me-shirt', name: 'Colours' },
  { id: 'hat', icon: 'me-hat', name: 'Hat' },
  { id: 'face', icon: 'me-face', name: 'Face' },
  { id: 'pet', icon: 'me-pet', name: 'Pet' },
  { id: 'trail', icon: 'me-trail', name: 'Trail' },
  { id: 'aura', icon: 'me-aura', name: 'Aura' },
  { id: 'cards', icon: 'hud-chat', name: 'Name card' },
  { id: 'emotes', icon: 'me-emote', name: 'Emotes' },
  { id: 'badges', icon: 'me-trophies', name: 'Badges' },
];

export const isMeSection = (s: string | undefined): s is MeSection => sections.some((x) => x.id === s);

const trailGlyphs: Record<string, string> = {
  none: '🚫', sparkle: '✨', fire: '🔥', bubbles: '🫧', hearts: '💕', stars: '⭐', rainbow: '🌈', snow: '❄️', leaves: '🍃', smoke: '💨',
  confetti: '🎉', magic: '🔮', sand: '⏳',
};

export class MePage implements ShellPage {
  readonly root: HTMLElement;
  private stage: AvatarStage | null = null;
  private section: MeSection = 'colors';
  /** A locked item on, to see before buying. */
  private trying: ShopItem | null = null;
  private readonly side: HTMLElement;
  private readonly main: HTMLElement;

  constructor(parent: HTMLElement, private readonly ctx: ShellContext, section?: MeSection) {
    if (section) this.section = section;
    this.root = el('div', 'ab-tab ab-me', parent);
    this.side = el('aside', 'ab-me-side', this.root);
    const stageBox = el('div', 'ab-me-stage', this.side);
    try {
      this.stage = new AvatarStage(stageBox, ctx.profile());
    } catch {
      el('div', 'ab-note', stageBox, L('This browser cannot show 3D here.'));
    }
    el('div', 'ab-me-card', this.side);
    el('div', 'ab-try', this.side);
    this.main = el('div', 'ab-me-main', this.root);
    this.redraw();
  }

  open(section: MeSection): void {
    if (section === this.section) return;
    this.section = section;
    this.trying = null;
    this.redraw();
  }

  /** What the stage shows: what you wear, or that with the item being tried. */
  private shown(): AvatarProfile {
    const p = this.ctx.profile();
    return this.trying ? wearing(p, this.trying) : p;
  }

  redraw(): void {
    this.stage?.show(this.shown());
    this.drawCard();
    this.drawTry();
    this.drawMain();
  }

  // MARK: The side: who, and what is being tried

  private drawCard(): void {
    const box = this.side.querySelector('.ab-me-card') as HTMLElement;
    box.innerHTML = '';
    const p = this.shown();
    const colours = namePlateColours[p.nameplate];
    const plate = el('div', 'ab-nameplate', box);
    plate.style.background = cssColor(colours.background);
    plate.style.color = cssColor(colours.text);
    if (colours.border) plate.style.boxShadow = `0 0 0 2px ${cssColor(colours.border)}`;
    el('b', '', plate, p.displayName);
    if (p.title) {
      const t = el('small', '', plate, p.title);
      t.style.color = cssColor(colours.accent);
    }
    const row = el('div', 'ab-me-buttons', box);
    const surprise = el('button', 'ab-block secondary', row, '🎲 ' + L('Surprise me'));
    surprise.onclick = () => this.surprise();
    const name = el('button', 'ab-block secondary', row, '✏️ ' + L('Display name'));
    name.onclick = () => this.ctx.go('settings');
  }

  private drawTry(): void {
    const box = this.side.querySelector('.ab-try') as HTMLElement;
    box.innerHTML = '';
    const item = this.trying;
    box.classList.toggle('on', !!item);
    if (!item) return;
    const r = rarity(item.price);
    const head = el('div', 'head', box);
    el('b', '', head, itemName(item));
    const chip = el('span', 'ab-rarity', head, rarityName(r));
    chip.style.setProperty('--rarity', rarityColor[r]);
    const coins = this.ctx.record.wallet.coins;
    const row = el('div', 'row', box);
    const buy = el('button', 'ab-block gold', row);
    icon('coin', buy);
    el('span', '', buy, L('Buy for {} coins', item.price));
    if (coins < item.price) {
      buy.disabled = true;
      el('div', 'ab-note', box, item.price - coins === 1 ? L('You need 1 more coin') : L('You need {} more coins', item.price - coins));
    }
    buy.onclick = () => this.buy(item, buy);
    const off = el('button', 'ab-block secondary', row, L('Take it off'));
    off.onclick = () => { this.trying = null; this.redraw(); };
  }

  // MARK: The closet

  private drawMain(): void {
    const main = this.main;
    const scroll = main.querySelector('.ab-closet-body')?.scrollTop ?? 0;
    main.innerHTML = '';
    const tabs = el('nav', 'ab-closet-tabs', main);
    for (const s of sections) {
      const b = el('button', 'ab-closet-tab' + (s.id === this.section ? ' on' : ''), tabs);
      icon(s.icon, b);
      el('span', '', b, L(s.name));
      b.onclick = () => { this.ctx.sound.play('click'); this.ctx.go(`me/${s.id}`); };
    }
    const body = el('div', 'ab-closet-body', main);
    switch (this.section) {
      case 'colors':
        this.group(body, L('Body'), itemsOf('bodyColor'));
        this.group(body, L('Head & arms'), itemsOf('headColor'));
        this.group(body, L('Legs & hat'), itemsOf('accentColor'));
        break;
      case 'cards':
        this.group(body, L('Name card'), itemsOf('nameplate'));
        this.group(body, L('Chat bubble'), itemsOf('bubble'));
        break;
      case 'emotes': this.drawEmotes(body); break;
      case 'badges': this.drawBadges(body); break;
      default: this.group(body, '', this.ordered(this.section)); break;
    }
    body.scrollTop = scroll;
  }

  /** Yours first, then what is left from cheapest up: the next thing within reach is always near the top. */
  private ordered(kind: ShopKind): ShopItem[] {
    const w = this.ctx.record.wallet;
    return [...w.ownedItems(kind), ...w.lockedItems(kind)];
  }

  private group(parent: HTMLElement, title: string, items: ShopItem[]): void {
    const w = this.ctx.record.wallet;
    if (title) {
      const h = el('h3', 'ab-closet-heading', parent, title);
      const owned = items.filter((i) => w.owns(i)).length;
      el('small', '', h, ` ${owned}/${items.length}`);
    }
    const grid = el('div', 'ab-looks' + (items[0] && /Color$/.test(items[0].kind) ? ' swatches' : ''), parent);
    for (const item of items) this.tile(grid, item);
  }

  private tile(grid: HTMLElement, item: ShopItem): void {
    const w = this.ctx.record.wallet;
    const p = this.ctx.profile();
    const owned = w.owns(item), worn = isWorn(p, item), trying = this.trying?.id === item.id;
    const r = rarity(item.price);
    const t = el('button', `ab-look ${r}` + (worn ? ' worn' : '') + (owned ? '' : ' locked') + (trying ? ' trying' : ''), grid);
    t.style.setProperty('--rarity', rarityColor[r]);
    t.title = itemName(item);
    const pic = el('div', 'pic', t);
    this.picture(pic, item, p);
    if (!/Color$/.test(item.kind)) el('span', 'name', t, itemName(item));
    if (worn) el('span', 'mark', t, '✓');
    else if (!owned) {
      const price = el('span', 'price' + (w.coins >= item.price ? ' can' : ''), t);
      icon('coin', price);
      el('span', '', price, formatNumber(item.price));
    }
    t.onclick = () => this.choose(item);
  }

  private picture(pic: HTMLElement, item: ShopItem, p: AvatarProfile): void {
    switch (item.kind) {
      case 'bodyColor': case 'headColor': case 'accentColor':
        pic.classList.add('swatch');
        pic.style.background = item.color ? cssColor(item.color) : '#888';
        return;
      case 'trail':
        el('span', 'glyph', pic, trailGlyphs[item.trail ?? 'none'] ?? '✨');
        return;
      case 'nameplate': {
        const c = namePlateColours[item.nameplate ?? 'classic'];
        const s = el('span', 'mini-card', pic, p.displayName.slice(0, 10) || 'Ablox');
        s.style.background = cssColor(c.background);
        s.style.color = cssColor(c.text);
        if (c.border) s.style.boxShadow = `0 0 0 2px ${cssColor(c.border)}`;
        return;
      }
      case 'bubble': {
        const c = bubbleColours[item.bubble ?? 'classic'];
        const s = el('span', 'mini-bubble', pic, L('Hi!'));
        s.style.background = cssColor(c.background);
        s.style.color = cssColor(c.text);
        s.style.setProperty('--tail', cssColor(c.background));
        return;
      }
      default: {
        if ((item.kind === 'pet' && item.pet === 'none') || (item.kind === 'aura' && item.aura === 'none') || (item.kind === 'hat' && item.hat === 'none')) {
          el('span', 'glyph', pic, '🚫');
          return;
        }
        const image = el('img', 'thumb', pic);
        image.alt = '';
        image.draggable = false;
        const now = thumbnails.picture(p, item, (url) => { if (url) image.src = url; else image.remove(); });
        if (now) image.src = now;
        else pic.classList.add('loading');
        image.onload = () => pic.classList.remove('loading');
      }
    }
  }

  private choose(item: ShopItem): void {
    const r = this.ctx.record;
    // On already (a look made before the shop, or one a code gave): nothing to buy.
    if (isWorn(this.ctx.profile(), item)) {
      this.trying = null;
      this.ctx.sound.play('click');
      this.redraw();
      return;
    }
    if (r.wallet.owns(item)) {
      this.trying = null;
      if (!isWorn(this.ctx.profile(), item)) {
        this.ctx.setProfile(wearing(this.ctx.profile(), item));
        this.ctx.sound.play('pop');
        if (item.kind === 'pet' || item.kind === 'aura') this.stage?.play('cheer');
      }
      this.redraw();
      return;
    }
    // Not yours yet: on, to see; the bar under the stage buys it.
    this.trying = this.trying?.id === item.id ? null : item;
    this.ctx.sound.play('click');
    this.redraw();
  }

  private buy(item: ShopItem, button: HTMLElement): void {
    const result = this.ctx.record.buy(item);
    this.ctx.toast(purchaseMessage(result), result.kind === 'purchased' ? 'plain' : 'plain');
    if (result.kind !== 'purchased') { this.ctx.sound.play('lose'); return; }
    this.trying = null;
    this.ctx.setProfile(wearing(this.ctx.profile(), item));
    this.ctx.sound.play('powerup');
    coinBurst(button, 5);
    const r = rarity(item.price);
    if (r === 'epic' || r === 'legendary') confetti();
    this.stage?.play('victory');
    this.redraw();
  }

  /** A random look from what you own. */
  private surprise(): void {
    const w = this.ctx.record.wallet;
    let p = this.ctx.profile();
    const pick = (kind: ShopKind) => {
      const owned = w.ownedItems(kind);
      if (owned.length) p = wearing(p, owned[Math.floor(Math.random() * owned.length)]);
    };
    for (const kind of ['bodyColor', 'headColor', 'accentColor', 'hat', 'face'] as ShopKind[]) pick(kind);
    this.trying = null;
    this.ctx.setProfile(p);
    this.ctx.sound.play('magic');
    this.stage?.play('spin');
    this.redraw();
  }

  // MARK: Emotes

  private drawEmotes(body: HTMLElement): void {
    el('p', 'ab-note', body, L('Tap one to see it. While playing, the smiley button does them.'));
    const grid = el('div', 'ab-looks emotes', body);
    for (const e of emotes) {
      const t = el('button', 'ab-look common', grid);
      el('div', 'pic', t).appendChild(document.createTextNode(emoteGlyphs[e as Emote]));
      el('span', 'name', t, L(emoteNames[e as Emote]));
      t.onclick = () => this.stage?.play(e as Emote);
    }
  }

  // MARK: Badges and records

  private drawBadges(body: HTMLElement): void {
    const r = this.ctx.record;
    const stats = r.stats();
    const earned = earnedBadges(stats);
    const top = el('div', 'ab-medal-summary', body);
    el('b', '', top, L('{} of {} badges', earned.length, achievements.length));
    meter(top, earned.length / achievements.length);

    // The title under your name: any badge earned.
    const titles = el('div', 'ab-titles', body);
    el('h3', 'ab-closet-heading', titles, L('Title under your name'));
    const chips = el('div', 'ab-tags', titles);
    const current = this.ctx.profile().title;
    const choices = ['', ...earned.map(badgeTitle)];
    for (const t of choices) {
      const c = el('button', 'ab-tag' + (t === current ? ' on' : ''), chips, t || L('None'));
      c.onclick = () => {
        this.ctx.setProfile({ ...this.ctx.profile(), title: t });
        this.ctx.sound.play('click');
        this.redraw();
      };
    }
    if (!earned.length) el('div', 'ab-note', titles, L('Earn a badge to wear its title.'));

    const grid = el('div', 'ab-medals', body);
    for (const a of achievements) {
      const got = isEarned(a, stats);
      const [c, t] = badgeProgress(a, stats);
      const b = el('div', 'ab-medal' + (got ? ' got' : ''), grid);
      el('div', 'emoji', b, badges[a].icon);
      el('b', '', b, badgeTitle(a));
      el('small', '', b, badgeDetail(a));
      if (!got) {
        meter(b, Math.max(0, c) / Math.max(1, t));
        el('span', 'count', b, `${formatNumber(Math.min(c, t))}/${formatNumber(t)}`);
      }
    }

    el('h3', 'ab-closet-heading', body, L('Records'));
    const records = el('div', 'ab-records', body);
    const most = [...r.games.values()].sort((x, y) => y.plays - x.plays)[0];
    const rows: [string, string, string][] = [
      ['🎮', L('Games played'), formatNumber(stats.gamesPlayed)],
      ['⏰', L('Time played'), duration(r.secondsPlayed)],
      ['📅', L('Days played'), formatNumber(stats.daysPlayed)],
      ['🪙', L('Coins earned'), formatNumber(stats.lifetimeCoins)],
      ['👕', L('Items owned'), formatNumber(stats.itemsOwned)],
      ['🔥', L('Best streak'), L('{} days', stats.bestStreak)],
      ['📷', L('Pictures'), formatNumber(stats.pictures)],
      ['🏆', L('Most played'), most ? most.title : L('None')],
    ];
    for (const [emoji, title, value] of rows) {
      const row = el('div', 'ab-record', records);
      el('span', 'emoji', row, emoji);
      el('span', 'title', row, title);
      el('b', '', row, value);
    }
    // Everything the shop holds, for a sense of how much there is left.
    el('div', 'ab-note', body, L('{} of {} looks collected', r.wallet.owned.size, shopItems.length));
  }

  dispose(): void {
    this.stage?.dispose();
    this.stage = null;
    this.root.remove();
  }
}
