// What a game saves for a player — AbloxCore/GameSave.swift. Plain JSON: a
// number, text, true/false, or lists and maps of those, held to the same
// limits as on the iPads both when a script saves and when a file is read.
import { graphemeCount, prefix } from './text';

export type SaveValue = null | number | string | boolean | SaveValue[] | { [key: string]: SaveValue };

export const SaveLimits = {
  maximumKeys: 200,
  maximumKeyLength: 64,
  maximumStringLength: 2000,
  maximumDepth: 6,
  maximumNodes: 5000,
  maximumEncodedBytes: 64 * 1024,
} as const;

const isMap = (v: SaveValue): v is { [key: string]: SaveValue } => !!v && typeof v === 'object' && !Array.isArray(v);

export function nodeCount(v: SaveValue): number {
  if (Array.isArray(v)) return 1 + v.reduce<number>((n, x) => n + nodeCount(x), 0);
  if (isMap(v)) return 1 + Object.values(v).reduce<number>((n, x) => n + nodeCount(x), 0);
  return 1;
}

export const isValidSaveKey = (key: string) => key.length > 0 && graphemeCount(key) <= SaveLimits.maximumKeyLength;

/** The value with over-long text cut, or null when something in it cannot be saved. */
export function cleanedSave(value: SaveValue, depth = 1): SaveValue | undefined {
  if (depth > SaveLimits.maximumDepth) return undefined;
  if (value === null || typeof value === 'boolean') return value;
  if (typeof value === 'number') return Number.isFinite(value) ? value : undefined;
  if (typeof value === 'string') return prefix(value, SaveLimits.maximumStringLength);
  if (Array.isArray(value)) {
    const out: SaveValue[] = [];
    for (const item of value) {
      const c = cleanedSave(item, depth + 1);
      if (c === undefined) return undefined;
      out.push(c);
    }
    return out;
  }
  if (isMap(value)) {
    const out: { [key: string]: SaveValue } = {};
    for (const [key, item] of Object.entries(value)) {
      if (item === null) continue;
      const c = isValidSaveKey(key) ? cleanedSave(item, depth + 1) : undefined;
      if (c === undefined) return undefined;
      out[key] = c;
    }
    return out;
  }
  return undefined;
}

const encoder = new TextEncoder();
const encodedSize = (values: Record<string, SaveValue>) => encoder.encode(JSON.stringify(values)).length;

/** Everything one player has saved in one game. */
export class SaveData {
  private store = new Map<string, SaveValue>();

  constructor(values: Record<string, SaveValue> = {}) {
    for (const key of Object.keys(values).sort()) this.set(key, values[key]);
  }

  get count(): number { return this.store.size; }
  get isEmpty(): boolean { return this.store.size === 0; }
  get(key: string): SaveValue | undefined { return this.store.get(key); }
  keys(): string[] { return [...this.store.keys()]; }

  /** The values as a plain object, keys sorted. */
  get values(): Record<string, SaveValue> {
    const out: Record<string, SaveValue> = {};
    for (const key of [...this.store.keys()].sort()) out[key] = this.store.get(key)!;
    return out;
  }

  /** Stores a value, or removes the key for null/undefined. False, changing nothing, past a limit. */
  set(key: string, value: SaveValue | undefined): boolean {
    if (value === undefined || value === null) {
      this.store.delete(key);
      return true;
    }
    if (!isValidSaveKey(key)) return false;
    const clean = cleanedSave(value);
    if (clean === undefined) return false;
    if (!this.store.has(key) && this.store.size >= SaveLimits.maximumKeys) return false;
    const candidate = new Map(this.store);
    candidate.set(key, clean);
    let nodes = 0;
    for (const v of candidate.values()) nodes += nodeCount(v);
    if (nodes > SaveLimits.maximumNodes) return false;
    if (encodedSize(Object.fromEntries(candidate)) > SaveLimits.maximumEncodedBytes) return false;
    this.store = candidate;
    return true;
  }

  get encodedSize(): number { return encodedSize(Object.fromEntries(this.store)); }

  copy(): SaveData {
    const out = new SaveData();
    out.store = new Map(this.store);
    return out;
  }

  toJSON(): Record<string, SaveValue> { return this.values; }

  /** From JSON as an iPad (or a hand-edited file) wrote it: the same limits. */
  static decode(json: unknown): SaveData {
    if (!json || typeof json !== 'object' || Array.isArray(json)) return new SaveData();
    return new SaveData(json as Record<string, SaveValue>);
  }
}
