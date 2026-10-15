// What a world's script has done to this player, built only from effects the
// host sent — AbloxCore/ScriptedPlayerState.swift. The play screen draws it;
// the tests read it.
import type { ColorRGBA } from './color';
import type { WeaponSpec } from './combat';
import {
  UILimits, maximumItems, normalMovement, standardCamera, type CameraSettings, type CountdownDisplay, type DialogBox,
  type InventoryItem, type LeaderboardPanel, type MovementScale, type MusicPlay, type ScriptEffect, type ShopPanel,
  type UIElement, type Waypoint,
} from './effects';

export class ScriptedPlayerState {
  ui: UIElement[] = [];
  camera: CameraSettings = standardCamera();
  weapon: WeaponSpec | null = null;
  ammo: { current: number; magazine: number; isReloading: boolean } | null = null;
  health: { current: number; maximum: number } | null = null;
  movement: MovementScale = normalMovement();
  showsControls = true;
  showsDefaultUI = true;
  fade: { color?: ColorRGBA; seconds: number; serial: number } = { seconds: 0, serial: 0 };
  shake = { strength: 0, seconds: 0, serial: 0 };
  hitMarkerCount = 0;
  lastHitWasKnockout = false;
  damageFlashCount = 0;
  waypoint: Waypoint | null = null;
  inventory: InventoryItem[] = [];
  dialog: DialogBox | null = null;
  shop: ShopPanel | null = null;
  countdown: CountdownDisplay | null = null;
  countdownSerial = 0;
  leaderboard: LeaderboardPanel | null = null;
  music: MusicPlay | null = null;
  inVehicle = false;
  /** Bumped on every change, for a screen redrawing only when it must. */
  revision = 0;

  get isKnockedOut(): boolean { return !!this.health && this.health.current <= 0; }

  get healthFraction(): number {
    const h = this.health;
    return h && h.maximum > 0 ? Math.min(Math.max(h.current / h.maximum, 0), 1) : 0;
  }

  /** Whether pressing fire now could be accepted. The host checks again. */
  get canFire(): boolean {
    if (!this.weapon || this.isKnockedOut) return false;
    return !this.ammo || (!this.ammo.isReloading && this.ammo.current > 0);
  }

  element(id: string): UIElement | undefined { return this.ui.find((e) => e.id === id); }

  /** The visible elements directly inside `parent` (null: the screen), bottom layer first. */
  children(parent: string | null): UIElement[] {
    return this.ui
      .map((element, offset) => ({ element, offset }))
      .filter(({ element }) => (element.parent ?? null) === parent && element.visible)
      .sort((a, b) => (a.element.layer !== b.element.layer ? a.element.layer - b.element.layer : a.offset - b.offset))
      .map(({ element }) => element);
  }

  apply(effect: ScriptEffect): void {
    this.revision++;
    switch (effect.kind) {
      case 'ui': {
        const i = this.ui.findIndex((e) => e.id === effect.element.id);
        if (i >= 0) this.ui[i] = effect.element;
        else if (this.ui.length < UILimits.maximumElements) this.ui.push(effect.element);
        break;
      }
      case 'removeUI': {
        const doomed = new Set([effect.id]);
        let grew = true;
        while (grew) {
          const before = doomed.size;
          for (const e of this.ui) if (e.parent !== undefined && doomed.has(e.parent)) doomed.add(e.id);
          grew = doomed.size > before;
        }
        this.ui = this.ui.filter((e) => !doomed.has(e.id));
        break;
      }
      case 'clearUI': this.ui = []; break;
      case 'camera': this.camera = effect.camera; break;
      case 'shake': this.shake = { strength: effect.strength, seconds: effect.seconds, serial: this.shake.serial + 1 }; break;
      case 'fade': this.fade = { color: effect.color, seconds: effect.seconds, serial: this.fade.serial + 1 }; break;
      case 'interface': this.showsControls = effect.controls; this.showsDefaultUI = effect.defaultUI; break;
      case 'equip':
        this.weapon = effect.weapon ?? null;
        if (!effect.weapon) this.ammo = null;
        break;
      case 'ammo': this.ammo = { current: effect.current, magazine: effect.magazine, isReloading: effect.reloading }; break;
      case 'health': this.health = { current: effect.current, maximum: effect.maximum }; break;
      case 'movement': this.movement = effect.movement; break;
      case 'hitMarker': this.hitMarkerCount++; this.lastHitWasKnockout = effect.killed; break;
      case 'damageFlash': this.damageFlashCount++; break;
      case 'waypoint': this.waypoint = effect.waypoint ?? null; break;
      case 'inventory': this.inventory = effect.items.slice(0, maximumItems); break;
      case 'dialog': this.dialog = effect.dialog ?? null; break;
      case 'shop': this.shop = effect.shop ?? null; break;
      case 'countdown': this.countdown = effect.countdown ?? null; this.countdownSerial++; break;
      case 'leaderboard': this.leaderboard = effect.board ?? null; break;
      case 'music': this.music = effect.music ?? null; break;
      case 'vehicle': this.inVehicle = effect.riding; break;
      default: this.revision--; break;
    }
  }
}
