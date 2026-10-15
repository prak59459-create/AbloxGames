// `block("Door")` and `blocks("coin")` without searching every block —
// GameRuntimeLookup.swift. Names and tags change rarely; the answers are
// kept until a block is added, removed, renamed or retagged.
import type { WorldDelta } from '../model/liveWorld';
import type { BlockData } from '../model/world';

export class BlockLookup {
  private firstByName = new Map<string, string>();
  private firstByFoldedName = new Map<string, string>();
  private byTag = new Map<string, string[]>();
  private labels = new Map<string, { name: string; tags: string[] }>();

  constructor(blocks: BlockData[]) {
    for (const b of blocks) this.record(b);
  }

  /** A block just made, on the end of the world. False when it is already known. */
  add(block: BlockData): boolean {
    if (this.labels.has(block.id)) return false;
    this.record(block);
    return true;
  }

  private record(block: BlockData): void {
    if (!this.firstByName.has(block.name)) this.firstByName.set(block.name, block.id);
    const folded = block.name.toLowerCase();
    if (!this.firstByFoldedName.has(folded)) this.firstByFoldedName.set(folded, block.id);
    for (const tag of new Set(block.tags.map((t) => t.toLowerCase()))) {
      const list = this.byTag.get(tag) ?? [];
      list.push(block.id);
      this.byTag.set(tag, list);
    }
    if (!this.labels.has(block.id)) this.labels.set(block.id, { name: block.name, tags: [...block.tags] });
  }

  firstBlock(name: string): string | undefined {
    return this.firstByName.get(name) ?? this.firstByFoldedName.get(name.toLowerCase());
  }

  blocksTagged(tag: string): string[] {
    return this.byTag.get(tag.toLowerCase()) ?? [];
  }

  isAffected(delta: WorldDelta): boolean {
    switch (delta.type) {
      case 'insert': case 'remove': case 'reparent': return true;
      case 'update': {
        const label = this.labels.get(delta.block.id);
        if (!label) return true;
        return label.name !== delta.block.name || label.tags.length !== delta.block.tags.length
          || label.tags.some((t, i) => t !== delta.block.tags[i]);
      }
      default: return false;
    }
  }
}
