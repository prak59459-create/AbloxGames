// A world as it changes during a game: deltas folded in, edits made in
// place, and what changed remembered for the renderer and the collision
// index — WorldDelta.apply, WorldDocument's editing and LiveWorld on the
// iPad. The host's rule machine and every player's view each keep one.
import { WorldIndex } from '../physics/worldIndex';
import { identityTransform, type BoundingBox, type Transform3D, type Vec3 } from './math';
import { decodeRule, encodeRule, ruleReferences, type EventRule } from './rules';
import {
  blockBounds, decodeBlock, decodeEnvironment, decodeScriptFile, encodeBlock, encodeEnvironment, isoNow, spawnPosition,
  worldTransformOf, type BlockData, type EnvironmentSettings, type ScriptFile, type WorldDocument, type WorldImage,
} from './world';

export type WorldDelta =
  | { type: 'insert'; block: BlockData }
  | { type: 'update'; block: BlockData }
  | { type: 'remove'; blockID: string }
  | { type: 'reparent'; blockID: string; newParent?: string }
  | { type: 'environment'; environment: EnvironmentSettings }
  | { type: 'rulesReplaced'; rules: EventRule[] }
  | { type: 'scriptsReplaced'; scripts: ScriptFile[] }
  | { type: 'scriptSourceChanged'; scriptSource?: unknown }
  | { type: 'imagesReplaced'; images: WorldImage[] };

/** A delta from its JSON (as an iPad sends it). */
export function decodeDelta(json: unknown): WorldDelta | null {
  const o = json as Record<string, unknown>;
  if (!o || typeof o !== 'object') return null;
  const id = (v: unknown) => (typeof v === 'string' ? v.toUpperCase() : undefined);
  switch (o.type) {
    case 'insert': return { type: 'insert', block: decodeBlock(o.block) };
    case 'update': return { type: 'update', block: decodeBlock(o.block) };
    case 'remove': { const b = id(o.blockID); return b ? { type: 'remove', blockID: b } : null; }
    case 'reparent': { const b = id(o.blockID); return b ? { type: 'reparent', blockID: b, newParent: id(o.newParent) } : null; }
    case 'environment': return { type: 'environment', environment: decodeEnvironment(o.environment) };
    case 'rulesReplaced': return {
      type: 'rulesReplaced', rules: Array.isArray(o.rules) ? o.rules.map(decodeRule).filter((r): r is EventRule => r !== null) : [],
    };
    case 'scriptsReplaced': return { type: 'scriptsReplaced', scripts: Array.isArray(o.scripts) ? o.scripts.map(decodeScriptFile) : [] };
    case 'scriptSourceChanged': return { type: 'scriptSourceChanged', scriptSource: o.scriptSource ?? undefined };
    case 'imagesReplaced': return {
      type: 'imagesReplaced',
      images: Array.isArray(o.images) ? (o.images as WorldImage[]).filter((i) => typeof i?.data === 'string' && typeof i?.id === 'string').slice(0, 12) : [],
    };
    default: return null;
  }
}

export function encodeDelta(d: WorldDelta): Record<string, unknown> {
  switch (d.type) {
    case 'insert': case 'update': return { block: encodeBlock(d.block), type: d.type };
    case 'remove': return { blockID: d.blockID, type: d.type };
    case 'reparent': return d.newParent ? { blockID: d.blockID, newParent: d.newParent, type: d.type } : { blockID: d.blockID, type: d.type };
    case 'environment': return { environment: encodeEnvironment(d.environment), type: d.type };
    case 'rulesReplaced': return { rules: d.rules.map(encodeRule), type: d.type };
    case 'scriptsReplaced': return { scripts: d.scripts.map((s) => ({ id: s.id, isEnabled: s.isEnabled, name: s.name, source: s.source })), type: d.type };
    case 'scriptSourceChanged': return d.scriptSource === undefined ? { type: d.type } : { scriptSource: d.scriptSource, type: d.type };
    case 'imagesReplaced': return { images: d.images, type: d.type };
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
  private childrenCache: Map<string, string[]> | null = null;

  constructor(world: WorldDocument) {
    this.world = world;
    this.reorder();
  }

  private reorder(): void {
    this.orders.clear();
    this.world.blocks.forEach((b, i) => { if (!this.orders.has(b.id)) this.orders.set(b.id, i); });
    this.childrenCache = null;
  }

  get blocks(): BlockData[] { return this.world.blocks; }

  block(id: string): BlockData | undefined {
    const i = this.orders.get(id);
    return i === undefined ? undefined : this.world.blocks[i];
  }

  indexOf(id: string): number | undefined { return this.orders.get(id); }

  find = (id: string): BlockData | undefined => this.block(id);

  private children(): Map<string, string[]> {
    if (this.childrenCache) return this.childrenCache;
    const map = new Map<string, string[]>();
    for (const b of this.world.blocks) {
      if (!b.parentID) continue;
      const list = map.get(b.parentID) ?? [];
      list.push(b.id);
      map.set(b.parentID, list);
    }
    this.childrenCache = map;
    return map;
  }

  /** `id` and everything under it, parents before children. */
  subtree(id: string): string[] {
    const out: string[] = [];
    if (!this.block(id)) return out;
    const children = this.children();
    const seen = new Set<string>([id]);
    out.push(id);
    const queue = [id];
    while (queue.length) {
      const current = queue.pop()!;
      for (const c of children.get(current) ?? []) {
        if (seen.has(c)) continue;
        seen.add(c);
        out.push(c);
        queue.push(c);
      }
    }
    return out;
  }

  isDescendant(candidate: string, ofOrEqualTo: string): boolean {
    if (candidate === ofOrEqualTo) return true;
    const seen = new Set([candidate]);
    let cursor = this.block(candidate)?.parentID;
    while (cursor) {
      if (cursor === ofOrEqualTo) return true;
      if (seen.has(cursor)) return false;
      seen.add(cursor);
      cursor = this.block(cursor)?.parentID;
    }
    return false;
  }

  worldTransform(id: string): Transform3D {
    const b = this.block(id);
    return b ? worldTransformOf(b, this.find) : identityTransform();
  }

  worldPosition(id: string): Vec3 { return this.worldTransform(id).position; }

  worldBounds(id: string): BoundingBox | undefined {
    const b = this.block(id);
    return b ? blockBounds(b, this.worldTransform(id)) : undefined;
  }

  spawnPosition(index: number): Vec3 { return spawnPosition(this.world, index, this.find); }

  // MARK: Editing

  /** Changes one block where it is. False when there is no such block. */
  mutate(id: string, change: (block: BlockData) => void): boolean {
    const i = this.orders.get(id);
    if (i === undefined) return false;
    const before = this.world.blocks[i];
    const after: BlockData = { ...before, transform: { ...before.transform }, gimmick: { ...before.gimmick }, tags: [...before.tags] };
    change(after);
    this.world.blocks[i] = after;
    if (before.parentID !== after.parentID) { this.indexStructural = true; this.childrenCache = null; }
    this.noteChanged(id);
    this.revision++;
    this.world.modifiedAt = isoNow();
    return true;
  }

  apply(delta: WorldDelta): boolean {
    this.revision++;
    switch (delta.type) {
      case 'insert': {
        const at = this.orders.get(delta.block.id);
        if (at !== undefined) return this.replace(at, delta.block);
        this.world.blocks.push(delta.block);
        this.orders.set(delta.block.id, this.world.blocks.length - 1);
        this.changed.add(delta.block.id);
        this.removed.delete(delta.block.id);
        this.indexStructural = true;
        this.childrenCache = null;
        break;
      }
      case 'update': {
        const at = this.orders.get(delta.block.id);
        if (at === undefined) return false;
        return this.replace(at, delta.block);
      }
      case 'remove': {
        const doomed = new Set(this.subtree(delta.blockID));
        if (!doomed.size) return false;
        this.world.blocks = this.world.blocks.filter((b) => !doomed.has(b.id));
        this.world.rules = this.world.rules.filter((r) => !ruleReferences(r, doomed));
        for (const id of doomed) { this.removed.add(id); this.changed.delete(id); }
        this.reorder();
        this.indexStructural = true;
        break;
      }
      case 'reparent': {
        if (this.orders.get(delta.blockID) === undefined) return false;
        if (delta.newParent) {
          if (!this.block(delta.newParent)) return false;
          if (this.isDescendant(delta.newParent, delta.blockID)) return false;
        }
        return this.mutate(delta.blockID, (b) => { b.parentID = delta.newParent; });
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

  private replace(at: number, block: BlockData): boolean {
    const before = this.world.blocks[at];
    this.world.blocks[at] = block;
    if (before.parentID !== block.parentID) { this.indexStructural = true; this.childrenCache = null; }
    this.noteChanged(block.id);
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
