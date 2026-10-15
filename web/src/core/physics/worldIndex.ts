// Every block's world-space bounds, worked out once, and a grid for finding
// the ones near a place — AbloxCore/WorldIndex.swift. Answers come back in
// document order, so "the first block that…" is the same block on the web
// as on an iPad.
import { intersects, type BoundingBox, type Vec3 } from '../model/math';
import {
  blockBounds, isSolidForPlayers, worldTransformOf, type BlockBehavior, type BlockData, type WorldDocument,
} from '../model/world';

export interface IndexEntry {
  id: string;
  order: number;
  bounds: BoundingBox;
  position: Vec3;
  isVisible: boolean;
  hasCollision: boolean;
  behavior: BlockBehavior;
  isLiquid: boolean;
  isSolid: boolean;
}

const CELL = 4;
const MAX_CELLS = 256;

const cell = (v: number) => (Number.isFinite(v) ? Math.max(-2147483648, Math.min(2147483647, Math.floor(v / CELL))) : v > 0 ? 2147483647 : -2147483648);

interface Range { x0: number; x1: number; z0: number; z1: number }
const rangeOf = (b: BoundingBox): Range => ({ x0: cell(b.min.x), x1: cell(b.max.x), z0: cell(b.min.z), z1: cell(b.max.z) });
const fits = (r: Range, limit: number) => {
  const w = r.x1 - r.x0 + 1, d = r.z1 - r.z0 + 1;
  return w > 0 && d > 0 && w <= limit && d <= limit && w * d <= limit;
};
const key = (x: number, z: number) => x * 4294967296 + (z >>> 0);

export class WorldIndex {
  entries: IndexEntry[] = [];
  private byID = new Map<string, number>();
  private cells = new Map<number, number[]>();
  private large: number[] = [];
  private children = new Map<string, number[]>();
  private blocks: BlockData[] = [];

  constructor(world?: WorldDocument) {
    if (world) this.rebuild(world.blocks);
  }

  rebuild(blocks: BlockData[]): void {
    this.blocks = blocks;
    this.entries = [];
    this.byID.clear();
    this.cells.clear();
    this.large = [];
    this.children.clear();
    blocks.forEach((b, i) => { if (!this.byID.has(b.id)) this.byID.set(b.id, i); });
    blocks.forEach((b, i) => {
      if (b.parentID) {
        const list = this.children.get(b.parentID) ?? [];
        list.push(i);
        this.children.set(b.parentID, list);
      }
      const entry = this.makeEntry(b, i);
      this.entries.push(entry);
      this.place(i, entry.bounds);
    });
  }

  private find = (id: string): BlockData | undefined => {
    const i = this.byID.get(id);
    return i === undefined ? undefined : this.blocks[i];
  };

  private makeEntry(b: BlockData, order: number): IndexEntry {
    const t = worldTransformOf(b, this.find);
    const liquid = b.material === 'water';
    return {
      id: b.id, order, bounds: blockBounds(b, t), position: t.position, isVisible: b.isVisible,
      hasCollision: b.hasCollision && !liquid, behavior: b.behavior, isLiquid: liquid, isSolid: isSolidForPlayers(b),
    };
  }

  private place(order: number, bounds: BoundingBox): void {
    const r = rangeOf(bounds);
    if (!fits(r, MAX_CELLS)) {
      this.large.push(order);
      return;
    }
    for (let x = r.x0; x <= r.x1; x++) {
      for (let z = r.z0; z <= r.z1; z++) {
        const k = key(x, z);
        const list = this.cells.get(k);
        if (list) list.push(order);
        else this.cells.set(k, [order]);
      }
    }
  }

  private unplace(order: number, bounds: BoundingBox): void {
    const r = rangeOf(bounds);
    if (!fits(r, MAX_CELLS)) {
      this.large = this.large.filter((o) => o !== order);
      return;
    }
    for (let x = r.x0; x <= r.x1; x++) {
      for (let z = r.z0; z <= r.z1; z++) {
        const k = key(x, z);
        const list = this.cells.get(k);
        if (!list) continue;
        const at = list.indexOf(order);
        if (at >= 0) list.splice(at, 1);
        if (list.length === 0) this.cells.delete(k);
      }
    }
  }

  /**
   * Re-reads blocks changed in place (and what hangs from them). False when
   * the change is one this cannot follow — a block added, removed or given
   * another parent — and the caller should rebuild.
   */
  update(blocks: BlockData[], changedIDs: Iterable<string>): boolean {
    if (blocks.length !== this.entries.length) return false;
    this.blocks = blocks;
    const queue: number[] = [];
    for (const id of changedIDs) {
      const order = this.byID.get(id);
      if (order === undefined || blocks[order]?.id !== id) return false;
      queue.push(order);
    }
    const seen = new Set(queue);
    for (let i = 0; i < queue.length; i++) {
      for (const child of this.children.get(blocks[queue[i]].id) ?? []) {
        if (!seen.has(child)) { seen.add(child); queue.push(child); }
      }
    }
    for (const order of queue) {
      const old = this.entries[order];
      const entry = this.makeEntry(blocks[order], order);
      this.entries[order] = entry;
      const a = rangeOf(old.bounds), b = rangeOf(entry.bounds);
      if (a.x0 !== b.x0 || a.x1 !== b.x1 || a.z0 !== b.z0 || a.z1 !== b.z1) {
        this.unplace(order, old.bounds);
        this.place(order, entry.bounds);
      }
    }
    return true;
  }

  entry(id: string): IndexEntry | undefined {
    const i = this.byID.get(id);
    return i === undefined ? undefined : this.entries[i];
  }

  /** Every block whose bounds touch `box`, in document order. */
  near(box: BoundingBox): IndexEntry[] {
    const r = rangeOf(box);
    if (!fits(r, 4 * MAX_CELLS)) return this.entries.filter((e) => intersects(e.bounds, box));
    const found = new Set<number>();
    for (let x = r.x0; x <= r.x1; x++) {
      for (let z = r.z0; z <= r.z1; z++) {
        const list = this.cells.get(key(x, z));
        if (!list) continue;
        for (const i of list) if (intersects(this.entries[i].bounds, box)) found.add(i);
      }
    }
    for (const i of this.large) if (intersects(this.entries[i].bounds, box)) found.add(i);
    return [...found].sort((a, b) => a - b).map((i) => this.entries[i]);
  }

  /** Visible, colliding blocks: what a shot or the camera can hit. */
  get solidBlocks(): IndexEntry[] {
    return this.entries.filter((e) => e.isSolid);
  }
}
