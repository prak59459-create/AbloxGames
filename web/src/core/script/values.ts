// AbloxScript's values, as in AbloxCore/ScriptValue.swift.
//
// Plain values are plain JavaScript: null, booleans, numbers and strings.
// Lists, maps, functions and game objects are classes, compared by identity,
// as the Swift reference types are.
import type { Stmt } from './ast';

export type ScriptValue =
  | null
  | boolean
  | number
  | string
  | ScriptList
  | ScriptMap
  | ScriptFunction
  | ScriptNative
  | ScriptObject;

export class ScriptList {
  constructor(public items: ScriptValue[] = []) {}
}

/** Insertion order is kept, so a map prints and iterates the way it was written. */
export class ScriptMap {
  readonly values = new Map<string, ScriptValue>();

  get count(): number { return this.values.size; }
  get keys(): string[] { return [...this.values.keys()]; }

  get(key: string): ScriptValue | undefined { return this.values.get(key); }

  /** Setting `undefined` removes the key, as setting nil does in Swift. */
  set(key: string, value: ScriptValue | undefined): void {
    if (value === undefined) this.values.delete(key);
    else this.values.set(key, value);
  }

  static from(entries: Record<string, ScriptValue>): ScriptMap {
    const map = new ScriptMap();
    for (const key of Object.keys(entries)) map.set(key, entries[key]);
    return map;
  }
}

/** A function written in AbloxScript, with the scope it was defined in. */
export class ScriptFunction {
  constructor(
    public readonly name: string,
    public readonly params: string[],
    public readonly body: Stmt[],
    public readonly closure: ScriptScope,
    public readonly line: number,
  ) {}
}

export type NativeBody = (args: ScriptValue[], line: number) => ScriptValue;

/** A function provided by the game or the standard library. */
export class ScriptNative {
  constructor(public readonly name: string, public readonly body: NativeBody) {}
}

/** Something the game owns — a player, a block — seen from a script. */
export class ScriptObject {
  constructor(public readonly kind: string, public readonly id: string, public readonly displayName: string) {}
}

/** Variables, nested by block. */
export class ScriptScope {
  readonly values = new Map<string, ScriptValue>();
  constructor(public readonly parent: ScriptScope | null) {}

  declare(name: string, value: ScriptValue): void { this.values.set(name, value); }

  lookup(name: string): ScriptValue | undefined {
    for (let scope: ScriptScope | null = this; scope; scope = scope.parent) {
      const value = scope.values.get(name);
      if (value !== undefined) return value;
    }
    return undefined;
  }

  /** Assigns to the nearest scope that declared `name`; false when none did. */
  assign(name: string, value: ScriptValue): boolean {
    for (let scope: ScriptScope | null = this; scope; scope = scope.parent) {
      if (scope.values.has(name)) {
        scope.values.set(name, value);
        return true;
      }
    }
    return false;
  }
}

// MARK: - Questions about values

export function isTruthy(value: ScriptValue): boolean {
  return value !== null && value !== false;
}

export function isFunction(value: ScriptValue): value is ScriptFunction | ScriptNative {
  return value instanceof ScriptFunction || value instanceof ScriptNative;
}

export function typeName(value: ScriptValue): string {
  if (value === null) return 'nil';
  switch (typeof value) {
    case 'boolean': return 'bool';
    case 'number': return 'number';
    case 'string': return 'text';
  }
  if (value instanceof ScriptList) return 'list';
  if (value instanceof ScriptMap) return 'map';
  if (value instanceof ScriptObject) return value.kind;
  return 'function';
}

/** How the value prints: `3` not `3.0`, `[1, 2]`, `{hp: 10}`. */
export function displayText(value: ScriptValue, depth = 0): string {
  // A list that contains itself would otherwise print forever.
  if (depth >= 6) return '…';
  if (value === null) return 'nil';
  switch (typeof value) {
    case 'boolean': return value ? 'true' : 'false';
    case 'number': return formatNumber(value);
    case 'string': return value;
  }
  if (value instanceof ScriptList) return '[' + value.items.map((v) => quotedText(v, depth + 1)).join(', ') + ']';
  if (value instanceof ScriptMap) {
    const parts: string[] = [];
    for (const [key, v] of value.values) parts.push(`${key}: ${quotedText(v, depth + 1)}`);
    return '{' + parts.join(', ') + '}';
  }
  if (value instanceof ScriptObject) return value.displayName;
  return `func ${value.name}`;
}

function quotedText(value: ScriptValue, depth: number): string {
  return typeof value === 'string' ? `"${value}"` : displayText(value, depth);
}

/** Equality as a script sees it: by value for plain values, by identity otherwise. */
export function isEqual(a: ScriptValue, b: ScriptValue): boolean {
  if (a instanceof ScriptObject && b instanceof ScriptObject) return a.kind === b.kind && a.id === b.id;
  return a === b;
}

// MARK: - Numbers as text

/** Whole numbers without a decimal point; others to at most four places. */
export function formatNumber(value: number): string {
  if (Number.isNaN(value)) return 'nan';
  if (!Number.isFinite(value)) return value > 0 ? 'inf' : '-inf';
  if (Number.isInteger(value) && Math.abs(value) < 1e15) return String(value === 0 ? 0 : value);
  let text = printfFixed(value, 4);
  while (text.endsWith('0')) text = text.slice(0, -1);
  if (text.endsWith('.')) text = text.slice(0, -1);
  return text;
}

/**
 * `String(format: "%.<digits>f", value)`: the exact decimal value of the
 * double, rounded half to even at the last digit, as C's printf does.
 * `toFixed` rounds exact ties up (0.125 → "0.13" where printf says "0.12"),
 * so ties are worked out exactly with BigInt.
 */
export function printfFixed(value: number, digits: number): string {
  if (Number.isNaN(value)) return 'nan';
  if (!Number.isFinite(value)) return value > 0 ? 'inf' : '-inf';
  const negative = value < 0 || Object.is(value, -0);
  const size = Math.abs(value);
  let body: string;
  if (size >= 1e21) {
    // Already a whole number; toFixed would switch to exponents.
    body = BigInt(size).toString() + (digits > 0 ? '.' + '0'.repeat(digits) : '');
  } else {
    const scaled = size * 10 ** digits;
    const fraction = scaled - Math.floor(scaled);
    body = Math.abs(fraction - 0.5) < 1e-6 ? exactFixed(size, digits) : size.toFixed(digits);
  }
  return (negative ? '-' : '') + body;
}

/** A non-negative finite double to `digits` decimals, exactly, ties to even. */
function exactFixed(value: number, digits: number): string {
  const [mantissa, exponent] = decompose(value);
  const ten = 10n ** BigInt(digits);
  let whole: bigint;
  if (exponent >= 0) {
    whole = (mantissa << BigInt(exponent)) * ten;
  } else {
    const denominator = 1n << BigInt(-exponent);
    const numerator = mantissa * ten;
    whole = numerator / denominator;
    const twice = (numerator % denominator) * 2n;
    if (twice > denominator || (twice === denominator && whole % 2n === 1n)) whole += 1n;
  }
  const text = whole.toString().padStart(digits + 1, '0');
  return digits === 0 ? text : text.slice(0, -digits) + '.' + text.slice(-digits);
}

/** value = mantissa × 2^exponent, exactly. */
function decompose(value: number): [bigint, number] {
  const view = new DataView(new ArrayBuffer(8));
  view.setFloat64(0, value);
  const bits = view.getBigUint64(0);
  const rawExponent = Number((bits >> 52n) & 0x7ffn);
  const fraction = bits & ((1n << 52n) - 1n);
  if (rawExponent === 0) return [fraction, -1074];
  return [fraction | (1n << 52n), rawExponent - 1075];
}

// MARK: - Numbers as Swift handles them

/** `Swift.min(x, y)`: `y < x ? y : x`, which is what NaN does there. */
export function smin(x: number, y: number): number { return y < x ? y : x; }
/** `Swift.max(x, y)`: `y >= x ? y : x`. */
export function smax(x: number, y: number): number { return y >= x ? y : x; }

/** `rounded()`: to the nearest whole number, halves away from zero. */
export function roundHalfAway(x: number): number {
  if (!Number.isFinite(x)) return x;
  const whole = Math.trunc(x);
  const rest = x - whole;
  if (rest >= 0.5) return whole + 1;
  if (rest <= -0.5) return whole - 1;
  return whole === 0 && (x < 0 || Object.is(x, -0)) ? -0 : whole;
}

/** `Double.scriptInt`: nan is 0 and anything past ±10¹⁵ stops there. */
export function scriptInt(x: number): number {
  if (Number.isNaN(x)) return 0;
  return Math.trunc(smin(smax(x, -1e15), 1e15));
}

/** Swift's `Double(text)`: decimal or hexadecimal, nothing else. */
export function parseDouble(text: string): number | null {
  if (/^[+-]?(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?$/.test(text)) return Number(text);
  const hex = /^([+-]?)0[xX]([0-9a-fA-F]+)$/.exec(text);
  if (hex) {
    const value = Number('0x' + hex[2]);
    return hex[1] === '-' ? -value : value;
  }
  if (/^[+-]?(inf|infinity)$/i.test(text)) return text.startsWith('-') ? -Infinity : Infinity;
  if (/^[+-]?nan$/i.test(text)) return NaN;
  return null;
}

/** `trimmingCharacters(in: .whitespaces)`: spaces and tabs, not newlines. */
export function trimSpaces(text: string): string {
  return text.replace(/^[\p{Zs}\t]+|[\p{Zs}\t]+$/gu, '');
}

// MARK: - Text by characters
//
// Swift counts characters as a person sees them: "👍🏽" and "が" written as
// two code points are one each. Scripts index text the same way on the web.

const simpleText = /^[\x00-\x0c\x0e-˿]*$/;
let segmenter: Intl.Segmenter | null = null;

export function characters(text: string): string[] {
  if (simpleText.test(text)) return text.split('');
  segmenter ??= new Intl.Segmenter(undefined, { granularity: 'grapheme' });
  const out: string[] = [];
  for (const part of segmenter.segment(text)) out.push(part.segment);
  return out;
}

export function characterCount(text: string): number {
  if (simpleText.test(text)) return text.length;
  return characters(text).length;
}

/** Text order as Swift has it: by Unicode scalars of the composed forms. */
export function compareText(a: string, b: string): number {
  if (!(/[^\x00-\x7f]/.test(a) || /[^\x00-\x7f]/.test(b))) return a < b ? -1 : a > b ? 1 : 0;
  const x = [...a.normalize('NFC')], y = [...b.normalize('NFC')];
  const n = Math.min(x.length, y.length);
  for (let i = 0; i < n; i++) {
    const p = x[i].codePointAt(0)!, q = y[i].codePointAt(0)!;
    if (p !== q) return p < q ? -1 : 1;
  }
  return x.length - y.length;
}

// MARK: - Randomness

const golden = 0x9e3779b97f4a7c15n;
const mix1 = 0xbf58476d1ce4e5b9n;
const mix2 = 0x94d049bb133111ebn;
const mask64 = (1n << 64n) - 1n;

/** SplitMix64, seeded, so a world's randomness replays the same as on the iPad. */
export class ScriptRandom {
  private state: bigint;

  constructor(seed: bigint | number) {
    this.state = BigInt.asUintN(64, BigInt(seed));
  }

  next(): bigint {
    this.state = (this.state + golden) & mask64;
    let z = this.state;
    z = ((z ^ (z >> 30n)) * mix1) & mask64;
    z = ((z ^ (z >> 27n)) * mix2) & mask64;
    return z ^ (z >> 31n);
  }

  /** In 0 ..< 1. */
  unit(): number {
    return Number(this.next() >> 11n) / 9007199254740992;
  }

  /** A whole number in low ... high, both included. */
  integer(low: number, high: number): number {
    if (!(high > low)) return low;
    const span = BigInt(high - low + 1);
    return low + Number(this.next() % span);
  }
}

// MARK: - Vectors

export interface Vector { x: number; y: number; z: number }

/** {x, y, z} when the value is a map with numbers there; null otherwise. */
export function toVector(value: ScriptValue): Vector | null {
  if (!(value instanceof ScriptMap)) return null;
  const x = value.get('x'), y = value.get('y'), z = value.get('z');
  if (typeof x !== 'number' || typeof y !== 'number' || typeof z !== 'number') return null;
  return { x, y, z };
}

export function vectorValue(v: Vector): ScriptMap {
  const map = new ScriptMap();
  map.set('x', v.x);
  map.set('y', v.y);
  map.set('z', v.z);
  return map;
}

export const vec = {
  add: (a: Vector, b: Vector): Vector => ({ x: a.x + b.x, y: a.y + b.y, z: a.z + b.z }),
  sub: (a: Vector, b: Vector): Vector => ({ x: a.x - b.x, y: a.y - b.y, z: a.z - b.z }),
  scale: (a: Vector, n: number): Vector => ({ x: a.x * n, y: a.y * n, z: a.z * n }),
  length: (a: Vector): number => Math.sqrt(a.x * a.x + a.y * a.y + a.z * a.z),
  isFinite: (a: Vector): boolean => Number.isFinite(a.x) && Number.isFinite(a.y) && Number.isFinite(a.z),
};

// MARK: - Plain data in and out
//
// Saves, effects and the network carry script values as JSON.

/** A script value from parsed JSON: objects become maps, arrays lists. */
export function fromJSON(value: unknown): ScriptValue {
  if (value === null || value === undefined) return null;
  if (typeof value === 'boolean' || typeof value === 'number' || typeof value === 'string') return value;
  if (Array.isArray(value)) return new ScriptList(value.map(fromJSON));
  if (typeof value === 'object') {
    const map = new ScriptMap();
    for (const [k, v] of Object.entries(value as Record<string, unknown>)) {
      const converted = fromJSON(v);
      if (converted !== null) map.set(k, converted);
    }
    return map;
  }
  return null;
}
