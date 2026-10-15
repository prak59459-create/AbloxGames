// A world as it changes during a game: deltas folded in, and what changed
// remembered for the renderer and the collision index — LiveWorld and
// WorldDelta.apply on the iPad.
import { WorldIndex } from '../core/physics/worldIndex';
import {
  decodeBlock, decodeEnvironment, decodeScriptFile, isoNow, type BlockData, type WorldDocument, type WorldImage,
} from '../core/model/world';

export type WorldDelta =
  | { type: 'insert'; block: BlockData }
  | { type: 'update'; block: BlockData }
  | { type: 'remove'; blockID: string }
  | { type: 'reparent'; blockID: string; newParent?: string }
  | { type: 'environment'; environment: WorldDocument['environment'] }
  | { type: 'rulesReplaced'; rules: unknown[] }
  | { type: 'scriptsReplaced'; scripts: WorldDocument['scripts'] }
  | { type: 'scriptSourceChanged'; scriptSource?: unknown }
  | { type: 'imagesReplaced'; images: WorldImage[] };

/** A delta from its JSON (as an iPad sends it). */
export function decodeDelta(json: unknown): WorldDelta | null {
  const o = json as Record<string, unknown>;
  if (!o || typeof o !== 'object') return null;
  switch (o.type) {
    case 'insert': return { type: 'insert', block: decodeBlock(o.block) };
    case 'update': return { type: 'update', block: decodeBlock(o.block) };
    case 'remove': return typeof o.blockID === 'string' ? { type: 'remove', blockID: o.blockID } : null;
    case 'reparent': return typeof o.blockID === 'string'
      ? { type: 'reparent', blockID: o.blockID, newParent: typeof o.newParent === 'string' ? o.newParent : undefined } : null;
    case 'environment': return { type: 'environment', environment: decodeEnvironment(o.environment) };
    case 'rulesReplaced': return { type: 'rulesReplaced', rules: Array.isArray(o.rules) ? o.rules : [] };
    case 'scriptsReplaced': return { type: 'scriptsReplaced', scripts: Array.isArray(o.scripts) ? o.scripts.map(decodeScriptFile) : [] };
    case 'scriptSourceChanged': return { type: 'scriptSourceChanged', scriptSource: o.scriptSource };
    case 'imagesReplaced': return {
      type: 'imagesReplaced',
      images: Array.isArray(o.images) ? (o.images as WorldImage[]).filter((i) => typeof i?.data === 'string').slice(0, 12) : [],
    };
    default: return null;
  }
}

export class LiveWorld {
  world: WorldDocument;
  private orders = new Map<string, number>();
  /** For the renderer: blocks changed or added, and removed, since the last take. */
  changed = new Set<string>();
  removed = new Set<string>();
  environmentChanged = false;
  /** Bumped on every change, for anyone caching on it. */
  revision = 0;
  readonly index = new WorldIndex();
  private indexDirty = new Set<string>();
  private indexStructural = true;

  constructor(world: WorldDocument) {
    this.world = world;
    this.reorder();
  }

  private reorder(): void {
    this.orders.clear();
    this.world.blocks.forEach((b, i) => { if (!this.orders.has(b.id)) this.orders.set(b.id, i); });
  }

  block(id: string): BlockData | undefined {
    const i = this.orders.get(id);
    return i === undefined ? undefined : this.world.blocks[i];
  }

  find = (id: string): BlockData | undefined => this.block(id);

  /** `id` and everything under it. */
  subtree(id: string): string[] {
    const out: string[] = [];
    if (!this.block(id)) return out;
    const children = new Map<string, string[]>();
    for (const b of this.world.blocks) {
      if (!b.parentID) continue;
      const list = children.get(b.parentID) ?? [];
      list.push(b.id);
      children.set(b.parentID, list);
    }
    const seen = new Set<string>();
    const stack = [id];
    while (stack.length) {
      const current = stack.pop()!;
      if (seen.has(current)) continue;
      seen.add(current);
      out.push(current);
      for (const c of children.get(current) ?? []) stack.push(c);
    }
    return out;
  }

  apply(delta: WorldDelta): boolean {
    this.revision++;
    switch (delta.type) {
      case 'insert': {
        const at = this.orders.get(delta.block.id);
        if (at !== undefined) {
          this.world.blocks[at] = delta.block;
          this.noteChanged(delta.block.id);
          return true;
        }
        this.world.blocks.push(delta.block);
        this.orders.set(delta.block.id, this.world.blocks.length - 1);
        this.changed.add(delta.block.id);
        this.removed.delete(delta.block.id);
        this.indexStructural = true;
        return true;
      }
      case 'update': {
        const at = this.orders.get(delta.block.id);
        if (at === undefined) return false;
        const before = this.world.blocks[at];
        this.world.blocks[at] = delta.block;
        if (before.parentID !== delta.block.parentID) this.indexStructural = true;
        this.noteChanged(delta.block.id);
        return true;
      }
      case 'remove': {
        const doomed = new Set(this.subtree(delta.blockID));
        if (!doomed.size) return false;
        this.world.blocks = this.world.blocks.filter((b) => !doomed.has(b.id));
        for (const id of doomed) { this.removed.add(id); this.changed.delete(id); }
        this.reorder();
        this.indexStructural = true;
        return true;
      }
      case 'reparent': {
        const at = this.orders.get(delta.blockID);
        if (at === undefined) return false;
        if (delta.newParent) {
          if (!this.block(delta.newParent)) return false;
          if (this.subtree(delta.blockID).includes(delta.newParent)) return false;
        }
        this.world.blocks[at] = { ...this.world.blocks[at], parentID: delta.newParent };
        this.changed.add(delta.blockID);
        this.indexStructural = true;
        return true;
      }
      case 'environment':
        this.world.environment = delta.environment;
        this.environmentChanged = true;
        break;
      case 'rulesReplaced': this.world.rules = delta.rules; break;
      case 'scriptsReplaced': this.world.scripts = delta.scripts; break;
      case 'scriptSourceChanged': this.world.scriptSource = delta.scriptSource; break;
      case 'imagesReplaced':
        this.world.images = delta.images;
        for (const b of this.world.blocks) if (b.imageID) this.changed.add(b.id);
        break;
    }
    this.world.modifiedAt = isoNow();
    return true;
  }

  private noteChanged(id: string): void {
    this.changed.add(id);
    this.indexDirty.add(id);
  }

  /** The collision index, brought up to date. */
  currentIndex(): WorldIndex {
    if (this.indexStructural) {
      this.index.rebuild(this.world.blocks);
      this.indexStructural = false;
      this.indexDirty.clear();
    } else if (this.indexDirty.size) {
      if (!this.index.update(this.world.blocks, this.indexDirty)) this.index.rebuild(this.world.blocks);
      this.indexDirty.clear();
    }
    return this.index;
  }

  takeChanges(): { changed: Set<string>; removed: Set<string>; environment: boolean } {
    const out = { changed: this.changed, removed: this.removed, environment: this.environmentChanged };
    this.changed = new Set();
    this.removed = new Set();
    this.environmentChanged = false;
    return out;
  }
}
