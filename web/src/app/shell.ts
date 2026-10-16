// What every tab of the menu is given: the player, their look, the games,
// the internet, the speakers, and a way to say something or go somewhere.
// And the small pieces every tab draws with.
import type { AvatarProfile } from '../core/model/avatar';
import type { WorldDocument } from '../core/model/world';
import type { SoundPlayer } from '../engine/audio';
import { L } from '../i18n';
import type { GameListing } from '../net/catalogue';
import type { InternetRooms } from '../net/internet';
import { iconURL } from '../play/hud';
import type { PlayerRecord } from './player';
import type { FamilyLock } from './family';
import { el } from './sheets';

export interface ShellContext {
  record: PlayerRecord;
  profile(): AvatarProfile;
  setProfile(p: AvatarProfile): void;
  games(): GameListing[];
  internet: InternetRooms;
  lock: FamilyLock;
  sound: SoundPlayer;
  toast(text: string, kind?: 'coins' | 'plain'): void;
  go(hash: string): void;
  /** While the returned function has not been called, the list of internet rooms is kept fresh. */
  watchRooms(): () => void;
  /** Plays a world that is not in the game list (a file from Studio). */
  playWorld(world: WorldDocument, openRoom: boolean): void;
}

/** A tab's page: drawn into `root`, redrawn when the player's record changes, and told when it goes. */
export interface ShellPage {
  readonly root: HTMLElement;
  redraw(): void;
  dispose(): void;
}

export function img(src: string, parent: HTMLElement, alt = '', className = ''): HTMLImageElement {
  const i = el('img', className, parent);
  i.src = src;
  i.alt = alt;
  i.loading = 'lazy';
  i.decoding = 'async';
  i.draggable = false;
  return i;
}

export const icon = (name: string, parent: HTMLElement, className = 'ab-icon') => img(iconURL(name), parent, '', className);

/** A bar filled to `fraction`. */
export function meter(parent: HTMLElement, fraction: number, className = ''): HTMLElement {
  const bar = el('div', 'ab-meter' + (className ? ' ' + className : ''), parent);
  const fill = el('div', '', bar);
  fill.style.width = `${Math.round(Math.max(0, Math.min(1, fraction)) * 100)}%`;
  return bar;
}

/** A card with a heading row: an icon, a title and, on the right, whatever goes there. */
export function card(parent: HTMLElement, title: string, iconName?: string, className = ''): { card: HTMLElement; head: HTMLElement; body: HTMLElement } {
  const c = el('section', 'ab-box' + (className ? ' ' + className : ''), parent);
  const head = el('div', 'ab-box-head', c);
  if (iconName) icon(iconName, head);
  el('h2', '', head, title);
  const body = el('div', 'ab-box-body', c);
  return { card: c, head, body };
}

/** "1 h 20 min", "35 min". */
export function duration(seconds: number): string {
  const minutes = Math.floor(seconds / 60);
  if (minutes >= 60) return L('{} h {} min', Math.floor(minutes / 60), minutes % 60);
  return L('{} min', minutes);
}

export const formatNumber = (n: number) => n.toLocaleString();
