// Coins, what they buy, and how a round turns into them (Economy.swift).
// Items only ever change how an avatar looks: nothing in the shop changes
// movement, reach or score, because a game where the richest player is
// also the fastest is a game children stop playing together.
import {
  auraEnglish, auraPrice, auras, bubbleEnglish, bubblePrice, bubbleStyles, faceNames, facePrice, faces, hatNames, hatPrice, hats,
  namePlateEnglish, namePlatePrice, namePlates, petEnglish, petPrice, pets, trailNames, trailPrice, trails,
  type Aura, type BubbleStyle, type Face, type Hat, type NamePlate, type Pet, type Trail,
} from './avatar';
import { palette, type ColorRGBA } from './color';
import { L } from '../../i18n';

export type ShopKind = 'bodyColor' | 'headColor' | 'accentColor' | 'hat' | 'face' | 'pet' | 'trail' | 'aura' | 'nameplate' | 'bubble';
export const shopKinds: ShopKind[] = ['bodyColor', 'headColor', 'accentColor', 'hat', 'face', 'pet', 'trail', 'aura', 'nameplate', 'bubble'];

export function shopKindName(kind: ShopKind): string {
  switch (kind) {
    case 'bodyColor': return L('Body');
    case 'headColor': return L('Head & arms');
    case 'accentColor': return L('Legs & hat');
    case 'hat': return L('Hat');
    case 'face': return L('Face');
    case 'pet': return L('Pet');
    case 'trail': return L('Trail');
    case 'aura': return L('Aura');
    case 'nameplate': return L('Name card');
    case 'bubble': return L('Chat bubble');
  }
}

export interface ShopItem {
  /** Stable, and readable in a saved wallet: `color.cyan`, `hat.crown`. */
  id: string;
  /** English; translated when shown. */
  name: string;
  kind: ShopKind;
  price: number;
  color?: ColorRGBA;
  hat?: Hat;
  face?: Face;
  pet?: Pet;
  trail?: Trail;
  aura?: Aura;
  nameplate?: NamePlate;
  bubble?: BubbleStyle;
}

export const itemName = (item: ShopItem) => L(item.name);
export const isFree = (item: ShopItem) => item.price <= 0;

export type ItemRarity = 'common' | 'rare' | 'epic' | 'legendary';
export const rarityOrder: ItemRarity[] = ['common', 'rare', 'epic', 'legendary'];
export function rarity(price: number): ItemRarity {
  if (price < 100) return 'common';
  if (price < 250) return 'rare';
  if (price < 450) return 'epic';
  return 'legendary';
}
export const rarityName = (r: ItemRarity) => L(r[0].toUpperCase() + r.slice(1));
export const rarityColor: Record<ItemRarity, string> = { common: '#94A3B8', rare: '#38BDF8', epic: '#C084FC', legendary: '#FACC15' };

const colourNames = ['coral', 'amber', 'sun', 'mint', 'cyan', 'blue', 'violet', 'pink', 'chalk', 'concrete', 'slate', 'graphite',
  'lime', 'teal', 'lavender', 'peach', 'chocolate'];

/** Everything purchasable, in the iPad's order. */
export const shopItems: ShopItem[] = (() => {
  const out: ShopItem[] = [];
  palette.forEach((color, index) => {
    const name = index < colourNames.length ? colourNames[index] : `colour${index}`;
    // The first four colours are free: a new player can look like themselves before earning a coin.
    const price = index < 4 ? 0 : 20 + (index - 4) * 15;
    for (const kind of ['bodyColor', 'headColor', 'accentColor'] as const) {
      out.push({ id: `${kind}.${name}`, name: name[0].toUpperCase() + name.slice(1), kind, price, color });
    }
  });
  for (const hat of hats) out.push({ id: `hat.${hat}`, name: hatNames[hat], kind: 'hat', price: hatPrice[hat], hat });
  for (const face of faces) out.push({ id: `face.${face}`, name: faceNames[face], kind: 'face', price: facePrice[face], face });
  for (const pet of pets) out.push({ id: `pet.${pet}`, name: petEnglish(pet), kind: 'pet', price: petPrice[pet], pet });
  for (const trail of trails) out.push({ id: `trail.${trail}`, name: trailNames[trail], kind: 'trail', price: trailPrice[trail], trail });
  for (const aura of auras) out.push({ id: `aura.${aura}`, name: auraEnglish(aura), kind: 'aura', price: auraPrice[aura], aura });
  for (const plate of namePlates) out.push({ id: `nameplate.${plate}`, name: namePlateEnglish(plate), kind: 'nameplate', price: namePlatePrice[plate], nameplate: plate });
  for (const bubble of bubbleStyles) out.push({ id: `bubble.${bubble}`, name: bubbleEnglish(bubble), kind: 'bubble', price: bubblePrice[bubble], bubble });
  return out;
})();

const byID = new Map(shopItems.map((i) => [i.id, i]));
export const shopItem = (id: string) => byID.get(id);
export const itemsOf = (kind: ShopKind) => shopItems.filter((i) => i.kind === kind);
export const freeItemIDs = (): Set<string> => new Set(shopItems.filter(isFree).map((i) => i.id));

export type PurchaseResult =
  | { kind: 'purchased'; item: ShopItem }
  | { kind: 'alreadyOwned' }
  | { kind: 'notEnoughCoins'; shortfall: number }
  | { kind: 'unknownItem' };

export function purchaseMessage(r: PurchaseResult): string {
  switch (r.kind) {
    case 'purchased': return L('Unlocked {}', itemName(r.item));
    case 'alreadyOwned': return L('You already have this');
    case 'notEnoughCoins': return r.shortfall === 1 ? L('You need 1 more coin') : L('You need {} more coins', r.shortfall);
    case 'unknownItem': return L('That item is no longer available');
  }
}

/** A player's coins and what they own, kept on this device. */
export class PlayerWallet {
  coins: number;
  readonly owned: Set<string>;
  /** Never goes down: "you have earned 500 coins" stays true after spending. */
  lifetimeEarned: number;

  constructor(coins = 0, owned: Iterable<string> = [], lifetimeEarned = 0) {
    this.coins = Math.max(0, Math.trunc(coins) || 0);
    // Free items are always owned, including ones a later version adds.
    this.owned = new Set([...owned, ...freeItemIDs()]);
    this.lifetimeEarned = Math.max(Math.trunc(lifetimeEarned) || 0, this.coins);
  }

  owns(item: ShopItem | string): boolean { return this.owned.has(typeof item === 'string' ? item : item.id); }
  canAfford(item: ShopItem): boolean { return this.coins >= item.price; }

  /** Coins from a round. Nothing below one: a bad round never takes coins already banked. */
  earn(amount: number): void {
    if (!(amount > 0)) return;
    const n = Math.trunc(amount);
    this.coins += n;
    this.lifetimeEarned += n;
  }

  /** At its price, or at `price` (a deal), never more than its price. */
  purchase(id: string, price?: number): PurchaseResult {
    const item = shopItem(id);
    if (!item) return { kind: 'unknownItem' };
    if (this.owns(item)) return { kind: 'alreadyOwned' };
    const cost = Math.max(0, Math.min(item.price, price ?? item.price));
    if (this.coins < cost) return { kind: 'notEnoughCoins', shortfall: cost - this.coins };
    this.coins -= cost;
    this.owned.add(item.id);
    return { kind: 'purchased', item };
  }

  refund(id: string, paid: number): boolean {
    const item = shopItem(id);
    if (!item || isFree(item) || !this.owns(item) || !(paid > 0)) return false;
    this.owned.delete(item.id);
    this.coins += paid;
    return true;
  }

  ownedItems(kind: ShopKind): ShopItem[] { return itemsOf(kind).filter((i) => this.owns(i)); }
  /** Cheapest first: the next thing within reach is always at the top. */
  lockedItems(kind: ShopKind): ShopItem[] { return itemsOf(kind).filter((i) => !this.owns(i)).sort((a, b) => a.price - b.price); }

  toJSON(): { coins: number; ownedItemIDs: string[]; lifetimeEarned: number } {
    return { coins: this.coins, ownedItemIDs: [...this.owned].sort(), lifetimeEarned: this.lifetimeEarned };
  }

  static decode(v: unknown): PlayerWallet {
    const o = (v && typeof v === 'object' ? v : {}) as Record<string, unknown>;
    const ids = Array.isArray(o.ownedItemIDs) ? o.ownedItemIDs.filter((x): x is string => typeof x === 'string') : [];
    return new PlayerWallet(typeof o.coins === 'number' ? o.coins : 0, ids, typeof o.lifetimeEarned === 'number' ? o.lifetimeEarned : 0);
  }

  reset(): void {
    this.coins = 0;
    this.owned.clear();
    for (const id of freeItemIDs()) this.owned.add(id);
    this.lifetimeEarned = 0;
  }
}

/** A round's score as coins: one a point, and a bonus for finishing. */
export const CoinRate = {
  perScorePoint: 1,
  roundCompletionBonus: 25,
  coins(score: number, completedRound = false): number {
    return Math.max(0, Math.trunc(score)) * this.perScorePoint + (completedRound ? this.roundCompletionBonus : 0);
  },
};
