// What the host knows about one character — a person or an NPC — beyond
// their avatar: GameRuntime.PlayerState in GameRuntime.swift.
import type { AvatarProfile, Ride } from '../model/avatar';
import type { ArmedState } from '../model/combat';
import {
  normalMovement, standardCamera, type CameraSettings, type DialogBox, type InventoryItem, type MovementScale, type ShopPanel,
  type UIElement,
} from '../model/effects';
import type { Vec3 } from '../model/math';
import type { PlayerSnapshot } from '../model/player';
import type { SaveData } from '../model/save';
import type { ScriptValue } from '../script/values';

export type Goal = { kind: 'none' } | { kind: 'point'; point: Vec3 } | { kind: 'character'; peer: string };

export class PlayerState {
  lastGesture = -Infinity;
  health = 100;
  maxHealth = 100;
  team = '';
  isAlive = true;
  respawnAt: number | null = null;
  armed: ArmedState | null = null;
  camera: CameraSettings = standardCamera();
  movement: MovementScale = normalMovement();
  showsControls = true;
  showsDefaultUI = true;
  isHidden = false;
  /** This player's own screen items, by id. */
  ui = new Map<string, UIElement>();
  /** What the script keeps on the character: `p.kills = 3`. */
  custom = new Map<string, ScriptValue>();
  /** Their saved data once it has arrived; null until then, and `p.save` waits for it. */
  saved: SaveData | null = null;
  saveChanged = false;
  lastSaveSent = -Infinity;

  items: InventoryItem[] = [];
  dialog: DialogBox | null = null;
  shop: ShopPanel | null = null;
  shopCurrency = 'coins';
  vehicle: Ride | null = null;
  movementBeforeVehicle: MovementScale | null = null;

  // NPCs only.
  body: PlayerSnapshot | null = null;
  home: Vec3 | null = null;
  goal: Goal = { kind: 'none' };
  wantsJump = false;
  needsTransformSend = false;
  npcScore = 0;

  originalProfile: AvatarProfile;

  constructor(readonly peer: string, readonly joinOrder: number, public name: string, public profile: AvatarProfile, readonly isNPC = false) {
    this.originalProfile = profile;
  }

  get isFollowing(): boolean { return this.goal.kind === 'character'; }

  reset(): void {
    this.health = 100;
    this.maxHealth = 100;
    this.team = '';
    this.isAlive = true;
    this.respawnAt = null;
    this.armed = null;
    this.camera = standardCamera();
    this.movement = normalMovement();
    this.showsControls = true;
    this.showsDefaultUI = true;
    this.isHidden = false;
    this.profile = this.originalProfile;
    this.name = this.originalProfile.displayName;
    this.ui.clear();
    this.custom.clear();
    this.items = [];
    this.dialog = null;
    this.shop = null;
    this.vehicle = null;
    this.movementBeforeVehicle = null;
  }
}

export interface ScriptTimer { id: number; due: number; interval: number | null; callback: ScriptValue; line: number }

export interface HandlerCost { name: string; calls: number; steps: number; seconds: number }
