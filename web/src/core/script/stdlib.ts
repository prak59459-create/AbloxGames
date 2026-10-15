// The functions every script has, whatever game it is in —
// AbloxCore/ScriptStandardLibrary.swift and ScriptStandardLibraryMore.swift.
import { L } from '../../i18n';
import { hexString, lerpColor, parseScriptColor, rgba, type ColorRGBA } from '../model/color';
import { ScriptError } from './lexer';
import type { ScriptInterpreter } from './interpreter';
import {
  ScriptList, ScriptMap, ScriptObject, characterCount, characters, compareText, displayText, formatNumber,
  isEqual, isFunction, isTruthy, parseDouble, printfFixed, roundHalfAway, scriptInt, smax, smin, toVector,
  trimSpaces, typeName, vec, vectorValue, type ScriptValue, type Vector,
} from './values';

export const standardLibraryNames = [
  'print', 'type', 'str', 'num',
  'floor', 'ceil', 'round', 'abs', 'sqrt', 'sin', 'cos', 'tan', 'asin', 'acos', 'atan', 'atan2',
  'pow', 'log', 'exp', 'sign', 'lerp', 'pi', 'min', 'max', 'clamp', 'random',
  'vec', 'magnitude', 'normalize', 'dot', 'cross',
  'len', 'append', 'remove', 'insert', 'contains', 'index_of', 'keys', 'join', 'shuffle',
  'range', 'slice', 'reverse', 'copy', 'sum', 'sort', 'map', 'filter',
  'upper', 'lower', 'trim', 'split', 'replace', 'starts_with', 'ends_with', 'fixed',
  'int', 'average', 'median', 'smoothstep', 'inverse_lerp', 'remap', 'approach', 'wrap', 'snap',
  'angle_diff', 'gcd', 'chance', 'random_float', 'pick_weighted',
  'unique', 'flatten', 'zip', 'first', 'last', 'find', 'any', 'all', 'reduce', 'count',
  'min_by', 'max_by', 'sort_by', 'group_by', 'chunk', 'repeat',
  'values', 'entries', 'merge', 'get',
  'pad_left', 'pad_right', 'capitalize', 'words', 'lines', 'format', 'comma', 'short_number', 'time_text',
  'direction', 'forward', 'yaw_to', 'rotate_y', 'angle_between',
  'rgb', 'hsv', 'mix_color', 'random_color',
];

const DEG = Math.PI / 180;

const arg = (args: ScriptValue[], i: number): ScriptValue => (i < args.length ? args[i] : null);

function tooLong(line: number): ScriptError {
  return new ScriptError(line, 'limit', L('That text is too long.'));
}

/** A stable sort whose comparison may throw — a script comparator can fail. */
export function mergeSort(items: ScriptValue[], before: (a: ScriptValue, b: ScriptValue) => boolean): ScriptValue[] {
  if (items.length <= 1) return items.slice();
  const middle = Math.floor(items.length / 2);
  const left = mergeSort(items.slice(0, middle), before);
  const right = mergeSort(items.slice(middle), before);
  const merged: ScriptValue[] = [];
  let i = 0, j = 0;
  while (i < left.length && j < right.length) {
    if (before(right[j], left[i])) merged.push(right[j++]);
    else merged.push(left[i++]);
  }
  while (i < left.length) merged.push(left[i++]);
  while (j < right.length) merged.push(right[j++]);
  return merged;
}

/** A position: {x, y, z}, or a player, NPC or block (their position). */
export function place(interp: ScriptInterpreter, value: ScriptValue, _name: string, line: number): Vector {
  const v = toVector(value);
  if (v) return v;
  if (value instanceof ScriptObject && interp.resolver) {
    const p = toVector(interp.resolver.member(value, 'position', line));
    if (p) return p;
  }
  throw new ScriptError(line, 'runtime',
    L('That needs a player, a block or a position like {x: 0, y: 5, z: 0}, not {}.', typeName(value)));
}

export function shortestTurn(a: number, b: number): number {
  const d = (b - a) % 360;
  if (!Number.isFinite(d)) return 0;
  return d > 180 ? d - 360 : d <= -180 ? d + 360 : d;
}

export function withCommas(value: number): string {
  const text = formatNumber(value);
  if (!Number.isFinite(value)) return text;
  const negative = text.startsWith('-');
  const unsigned = negative ? text.slice(1) : text;
  const dot = unsigned.indexOf('.');
  let whole = dot >= 0 ? unsigned.slice(0, dot) : unsigned;
  const fraction = dot >= 0 ? unsigned.slice(dot + 1) : null;
  let grouped = '';
  while (whole.length > 3) {
    grouped = ',' + whole.slice(-3) + grouped;
    whole = whole.slice(0, -3);
  }
  grouped = whole + grouped;
  return (negative ? '-' : '') + grouped + (fraction !== null ? '.' + fraction : '');
}

export function shortNumber(value: number): string {
  if (!Number.isFinite(value)) return formatNumber(value);
  const units: [number, string][] = [[1e3, 'K'], [1e6, 'M'], [1e9, 'B'], [1e12, 'T']];
  const tenths = (x: number) => roundHalfAway(x * 10) / 10;
  const size = Math.abs(value);
  let index = -1;
  for (let i = units.length - 1; i >= 0; i--) if (size >= units[i][0]) { index = i; break; }
  // Rounding up to 1000 of one unit shows as one of the next: 999,960 is 1M.
  if (index >= 0) {
    if (index + 1 < units.length && tenths(size / units[index][0]) >= 1000) index += 1;
  } else if (tenths(size) >= 1000) {
    index = 0;
  }
  if (index < 0) return formatNumber(tenths(value));
  return formatNumber(tenths(value / units[index][0])) + units[index][1];
}

export function clockText(seconds: number): string {
  const total = scriptInt(smax(0, Math.floor(seconds)));
  const hours = Math.floor(total / 3600), minutes = Math.floor((total % 3600) / 60), rest = total % 60;
  const two = (n: number) => (n < 10 ? `0${n}` : `${n}`);
  return hours > 0 ? `${hours}:${two(minutes)}:${two(rest)}` : `${minutes}:${two(rest)}`;
}

export function hsv(hue: number, saturation: number, value: number): ColorRGBA {
  const turn = Number.isFinite(hue) ? hue % 360 : 0;
  const h = (turn < 0 ? turn + 360 : turn) / 60;
  const s = Number.isFinite(saturation) ? smin(smax(saturation, 0), 1) : 0;
  const v = Number.isFinite(value) ? smin(smax(value, 0), 1) : 0;
  const c = v * s;
  const x = c * (1 - Math.abs((h % 2) - 1));
  const m = v - c;
  let r: number, g: number, b: number;
  switch (Math.trunc(h)) {
    case 0: [r, g, b] = [c, x, 0]; break;
    case 1: [r, g, b] = [x, c, 0]; break;
    case 2: [r, g, b] = [0, c, x]; break;
    case 3: [r, g, b] = [0, x, c]; break;
    case 4: [r, g, b] = [x, 0, c]; break;
    default: [r, g, b] = [c, 0, x];
  }
  return rgba(r + m, g + m, b + m);
}

/** Text, one character at a time, split at line ends — "\r\n" is one. */
const newline = /\r\n|[\n\v\f\r\u0085\u2028\u2029]/;

export function installStandardLibrary(I: ScriptInterpreter): void {
  const define = I.define.bind(I);
  const num = (v: ScriptValue, what: string, line: number) => I.number(v, what, line);

  const needs = (args: ScriptValue[], count: number, name: string, line: number) => {
    if (args.length < count) throw new ScriptError(line, 'runtime', L('“{}” needs {} values.', name, count));
  };
  const listArg = (v: ScriptValue, name: string, line: number): ScriptList => {
    if (!(v instanceof ScriptList)) throw new ScriptError(line, 'runtime', L('“{}” needs a list first.', name));
    return v;
  };
  const mapArg = (v: ScriptValue, name: string, line: number): ScriptMap => {
    if (!(v instanceof ScriptMap)) throw new ScriptError(line, 'runtime', L('“{}” needs a map first.', name));
    return v;
  };
  const numbersIn = (list: ScriptList, name: string, line: number) => list.items.map((v) => num(v, name, line));
  const checkedText = (result: string, line: number): string => {
    if (result.length > I.limits.maximumTextLength && characterCount(result) > I.limits.maximumTextLength) throw tooLong(line);
    return result;
  };
  const comesBefore = (a: ScriptValue, b: ScriptValue, line: number): boolean => {
    if (typeof a === 'number' && typeof b === 'number') return a < b;
    if (typeof a === 'string' && typeof b === 'string') return compareText(a, b) < 0;
    throw new ScriptError(line, 'runtime', L('Cannot compare a {} with a {}.', typeName(a), typeName(b)));
  };
  const vector = (v: ScriptValue, line: number): Vector => {
    const out = toVector(v);
    if (!out) throw new ScriptError(line, 'runtime', L('That needs {x, y, z}, not {}.', typeName(v)));
    return out;
  };

  // MARK: Output

  define('print', (args) => {
    I.log(args.map((a) => displayText(a)).join(' '));
    return null;
  });

  // MARK: Types and conversion

  define('type', (args) => typeName(arg(args, 0)));
  define('str', (args) => displayText(arg(args, 0)));
  define('num', (args) => {
    const v = arg(args, 0);
    if (typeof v === 'number') return v;
    if (typeof v === 'string') {
      const value = parseDouble(trimSpaces(v));
      return value !== null && Number.isFinite(value) ? value : null;
    }
    if (typeof v === 'boolean') return v ? 1 : 0;
    return null;
  });

  // MARK: Maths

  const unary = (name: string, body: (x: number) => number) =>
    define(name, (args, line) => body(num(arg(args, 0), name, line)));
  unary('floor', Math.floor);
  unary('ceil', Math.ceil);
  define('round', (args, line) => {
    const value = num(arg(args, 0), 'round', line);
    if (args.length <= 1) return roundHalfAway(value);
    const digits = smin(smax(scriptInt(num(args[1], 'round', line)), 0), 10);
    const scale = 10 ** digits;
    return roundHalfAway(value * scale) / scale;
  });
  unary('abs', Math.abs);
  unary('sqrt', (x) => (x < 0 ? NaN : Math.sqrt(x)));
  unary('sin', (x) => Math.sin(x * DEG));
  unary('cos', (x) => Math.cos(x * DEG));

  define('min', (args, line) => {
    if (args.length === 0) return null;
    const values = args.map((a) => num(a, 'min', line));
    let result = values[0];
    for (const v of values) if (v < result) result = v;
    return result;
  });
  define('max', (args, line) => {
    if (args.length === 0) return null;
    const values = args.map((a) => num(a, 'max', line));
    let result = values[0];
    for (const v of values) if (result < v) result = v;
    return result;
  });
  define('clamp', (args, line) => {
    if (args.length < 3) throw new ScriptError(line, 'runtime', L('“{}” needs {} values.', 'clamp', 3));
    const value = num(args[0], 'clamp', line), low = num(args[1], 'clamp', line), high = num(args[2], 'clamp', line);
    return smin(smax(value, low), high);
  });

  /** random() is in 0..1; random(1, 6) a whole number, both ends included. */
  define('random', (args, line) => {
    if (args.length >= 2) {
      const low = scriptInt(roundHalfAway(num(args[0], 'random', line)));
      const high = scriptInt(roundHalfAway(num(args[1], 'random', line)));
      return I.random.integer(Math.min(low, high), Math.max(low, high));
    }
    const first = arg(args, 0);
    if (first instanceof ScriptList) {
      if (first.items.length === 0) return null;
      return first.items[I.random.integer(0, first.items.length - 1)];
    }
    return I.random.unit();
  });

  // MARK: Lists

  define('len', (args) => {
    const v = arg(args, 0);
    if (v instanceof ScriptList) return v.items.length;
    if (v instanceof ScriptMap) return v.count;
    if (typeof v === 'string') return characterCount(v);
    return 0;
  });

  define('append', (args, line) => {
    const list = arg(args, 0);
    if (!(list instanceof ScriptList)) throw new ScriptError(line, 'runtime', L('“{}” needs a list first.', 'append'));
    list.items.push(args.length > 1 ? args[1] : null);
    I.checkSize(list.items.length, line);
    return list;
  });

  define('remove', (args, line) => {
    const list = arg(args, 0);
    if (!(list instanceof ScriptList)) {
      if (list instanceof ScriptMap && args.length > 1 && typeof args[1] === 'string') {
        const old = list.get(args[1]) ?? null;
        list.set(args[1], undefined);
        return old;
      }
      throw new ScriptError(line, 'runtime', L('“{}” needs a list first.', 'remove'));
    }
    if (list.items.length === 0) return null;
    // Without a position, the last item — the one `append` added.
    const position = args.length > 1 ? scriptInt(num(args[1], 'remove', line)) : list.items.length;
    if (position < 1 || position > list.items.length) return null;
    return list.items.splice(position - 1, 1)[0];
  });

  define('contains', (args) => {
    if (args.length < 2) return false;
    const [a, b] = args;
    if (a instanceof ScriptList) return a.items.some((item) => isEqual(item, b));
    if (a instanceof ScriptMap) return a.get(displayText(b)) !== undefined;
    if (typeof a === 'string') return a.includes(displayText(b));
    return false;
  });

  define('keys', (args) => {
    const map = arg(args, 0);
    if (!(map instanceof ScriptMap)) return new ScriptList();
    return new ScriptList(map.keys);
  });

  define('join', (args, line) => {
    const list = arg(args, 0);
    if (!(list instanceof ScriptList)) return '';
    const separator = args.length > 1 ? displayText(args[1]) : ', ';
    return checkedText(list.items.map((v) => displayText(v)).join(separator), line);
  });

  /** In place, with the world's seeded randomness. */
  define('shuffle', (args) => {
    const list = arg(args, 0);
    if (!(list instanceof ScriptList)) return null;
    if (list.items.length <= 1) return list;
    for (let index = list.items.length - 1; index > 0; index--) {
      const other = I.random.integer(0, index);
      [list.items[index], list.items[other]] = [list.items[other], list.items[index]];
    }
    return list;
  });

  // MARK: More maths

  unary('tan', (x) => Math.tan(x * DEG));
  unary('asin', (x) => Math.asin(x) / DEG);
  unary('acos', (x) => Math.acos(x) / DEG);
  unary('atan', (x) => Math.atan(x) / DEG);
  unary('log', (x) => (x <= 0 ? NaN : Math.log(x)));
  unary('exp', (x) => Math.exp(smin(x, 700)));
  unary('sign', (x) => (x > 0 ? 1 : x < 0 ? -1 : 0));
  I.defineValue('pi', Math.PI);

  define('pow', (args, line) => {
    if (args.length < 2) throw new ScriptError(line, 'runtime', L('“{}” needs {} values.', 'pow', 2));
    const base = num(args[0], 'pow', line), exponent = num(args[1], 'pow', line);
    // C's pow: 1 to any power, and anything to the 0th, is 1.
    const result = base === 1 || exponent === 0 ? 1 : base ** exponent;
    return Number.isFinite(result) ? result : 0;
  });
  define('atan2', (args, line) => {
    if (args.length < 2) throw new ScriptError(line, 'runtime', L('“{}” needs {} values.', 'atan2', 2));
    return Math.atan2(num(args[0], 'atan2', line), num(args[1], 'atan2', line)) / DEG;
  });
  define('lerp', (args, line) => {
    if (args.length < 3) throw new ScriptError(line, 'runtime', L('“{}” needs {} values.', 'lerp', 3));
    const t = num(args[2], 'lerp', line);
    const a = toVector(args[0]), b = toVector(args[1]);
    if (a && b) return vectorValue(vec.add(a, vec.scale(vec.sub(b, a), t)));
    const x = num(args[0], 'lerp', line), y = num(args[1], 'lerp', line);
    return x + (y - x) * t;
  });

  // MARK: Vectors

  define('vec', (args, line) => vectorValue({
    x: num(args.length > 0 ? args[0] : 0, 'vec', line),
    y: num(args.length > 1 ? args[1] : 0, 'vec', line),
    z: num(args.length > 2 ? args[2] : 0, 'vec', line),
  }));
  define('magnitude', (args, line) => vec.length(vector(arg(args, 0), line)));
  define('normalize', (args, line) => {
    const v = vector(arg(args, 0), line);
    const length = vec.length(v);
    return vectorValue(length > 0 ? vec.scale(v, 1 / length) : v);
  });
  define('dot', (args, line) => {
    if (args.length < 2) return 0;
    const a = vector(args[0], line), b = vector(args[1], line);
    return a.x * b.x + a.y * b.y + a.z * b.z;
  });
  define('cross', (args, line) => {
    if (args.length < 2) return null;
    const a = vector(args[0], line), b = vector(args[1], line);
    return vectorValue({ x: a.y * b.z - a.z * b.y, y: a.z * b.x - a.x * b.z, z: a.x * b.y - a.y * b.x });
  });

  // MARK: More lists

  define('range', (args, line) => {
    const from = num(arg(args, 0), 'range', line);
    const to = args.length > 1 ? num(args[1], 'range', line) : from;
    const start = args.length > 1 ? from : 1;
    const step = start <= to ? 1 : -1;
    // Checked as a number first: range(1, 1e300) is too big, not a crash.
    const span = Math.floor(Math.abs(to - start));
    I.checkSize(Number.isFinite(span) ? scriptInt(span + 1) : Number.MAX_SAFE_INTEGER, line);
    const items: ScriptValue[] = [];
    for (let i = 0; i <= span; i++) items.push(start + i * step);
    return new ScriptList(items);
  });
  define('insert', (args, line) => {
    const list = args[0];
    if (args.length < 3 || !(list instanceof ScriptList)) {
      throw new ScriptError(line, 'runtime', L('“{}” needs a list first.', 'insert'));
    }
    const position = scriptInt(num(args[1], 'insert', line));
    list.items.splice(Math.min(Math.max(position - 1, 0), list.items.length), 0, args[2]);
    I.checkSize(list.items.length, line);
    return list;
  });
  define('index_of', (args) => {
    if (args.length < 2) return null;
    const [a, b] = args;
    if (a instanceof ScriptList) {
      const index = a.items.findIndex((item) => isEqual(item, b));
      return index >= 0 ? index + 1 : null;
    }
    if (typeof a === 'string') {
      const part = displayText(b);
      if (part === '') return null;
      const at = a.indexOf(part);
      return at < 0 ? null : characterCount(a.slice(0, at)) + 1;
    }
    return null;
  });
  define('slice', (args, line) => {
    const from = scriptInt(num(args.length > 1 ? args[1] : 1, 'slice', line));
    const v = arg(args, 0);
    if (v instanceof ScriptList) {
      const to = args.length > 2 ? scriptInt(num(args[2], 'slice', line)) : v.items.length;
      const low = Math.max(from, 1), high = Math.min(to, v.items.length);
      return new ScriptList(low <= high ? v.items.slice(low - 1, high) : []);
    }
    if (typeof v === 'string') {
      const chars = characters(v);
      const to = args.length > 2 ? scriptInt(num(args[2], 'slice', line)) : chars.length;
      const low = Math.max(from, 1), high = Math.min(to, chars.length);
      return low <= high ? chars.slice(low - 1, high).join('') : '';
    }
    return null;
  });
  define('reverse', (args) => {
    const v = arg(args, 0);
    if (v instanceof ScriptList) return new ScriptList(v.items.slice().reverse());
    if (typeof v === 'string') return characters(v).reverse().join('');
    return null;
  });
  define('copy', (args) => {
    const v = arg(args, 0);
    if (v instanceof ScriptList) return new ScriptList(v.items.slice());
    if (v instanceof ScriptMap) {
      const out = new ScriptMap();
      for (const [k, value] of v.values) out.set(k, value);
      return out;
    }
    return v;
  });
  define('sum', (args, line) => {
    const list = arg(args, 0);
    if (!(list instanceof ScriptList)) return 0;
    let total = 0;
    for (const item of list.items) total += num(item, 'sum', line);
    return total;
  });
  /** A sorted copy: numbers and text in order, or by a function saying whether a comes before b. */
  define('sort', (args, line) => {
    const list = arg(args, 0);
    if (!(list instanceof ScriptList)) return null;
    let before: (a: ScriptValue, b: ScriptValue) => boolean;
    if (args.length > 1) {
      const comparator = args[1];
      before = (a, b) => isTruthy(I.call(comparator, [a, b], line));
    } else {
      before = (a, b) => comesBefore(a, b, line);
    }
    return new ScriptList(mergeSort(list.items, before));
  });
  define('map', (args, line) => {
    const list = args[0];
    if (args.length < 2 || !(list instanceof ScriptList)) return null;
    return new ScriptList(list.items.slice().map((item) => I.call(args[1], [item], line)));
  });
  define('filter', (args, line) => {
    const list = args[0];
    if (args.length < 2 || !(list instanceof ScriptList)) return null;
    return new ScriptList(list.items.slice().filter((item) => isTruthy(I.call(args[1], [item], line))));
  });

  // MARK: Text

  define('replace', (args, line) => {
    if (args.length < 3) return arg(args, 0);
    const text = displayText(args[0]), target = displayText(args[1]), replacement = displayText(args[2]);
    if (target === '') return text;
    return checkedText(text.split(target).join(replacement), line);
  });
  define('starts_with', (args) => (args.length < 2 ? false : displayText(args[0]).startsWith(displayText(args[1]))));
  define('ends_with', (args) => (args.length < 2 ? false : displayText(args[0]).endsWith(displayText(args[1]))));
  /** fixed(3.14159, 2) is "3.14". */
  define('fixed', (args, line) => {
    const value = num(arg(args, 0), 'fixed', line);
    const digits = args.length > 1 ? scriptInt(num(args[1], 'fixed', line)) : 0;
    return printfFixed(value, Math.min(Math.max(digits, 0), 10));
  });
  define('upper', (args) => displayText(arg(args, 0)).toUpperCase());
  define('lower', (args) => displayText(arg(args, 0)).toLowerCase());
  define('trim', (args) => displayText(arg(args, 0)).trim());
  define('split', (args, line) => {
    const text = displayText(arg(args, 0));
    const separator = args.length > 1 ? displayText(args[1]) : ' ';
    const parts = separator === '' ? characters(text) : text.split(separator);
    I.checkSize(parts.length, line);
    return new ScriptList(parts);
  });

  // MARK: Maths, the second round

  define('int', (args) => {
    const v = arg(args, 0);
    if (typeof v === 'number') return Math.trunc(v);
    if (typeof v === 'string') {
      const value = parseDouble(trimSpaces(v));
      return value !== null && Number.isFinite(value) ? Math.trunc(value) : null;
    }
    if (typeof v === 'boolean') return v ? 1 : 0;
    return null;
  });
  define('average', (args, line) => {
    const values = numbersIn(listArg(arg(args, 0), 'average', line), 'average', line);
    if (values.length === 0) return null;
    return values.reduce((a, b) => a + b, 0) / values.length;
  });
  define('median', (args, line) => {
    const values = numbersIn(listArg(arg(args, 0), 'median', line), 'median', line).sort((a, b) => a - b);
    if (values.length === 0) return null;
    const middle = Math.floor(values.length / 2);
    return values.length % 2 === 1 ? values[middle] : (values[middle - 1] + values[middle]) / 2;
  });
  define('smoothstep', (args, line) => {
    needs(args, 3, 'smoothstep', line);
    const a = num(args[0], 'smoothstep', line), b = num(args[1], 'smoothstep', line), t = num(args[2], 'smoothstep', line);
    if (a === b) return t < a ? 0 : 1;
    const x = smin(smax((t - a) / (b - a), 0), 1);
    return x * x * (3 - 2 * x);
  });
  define('inverse_lerp', (args, line) => {
    needs(args, 3, 'inverse_lerp', line);
    const a = num(args[0], 'inverse_lerp', line), b = num(args[1], 'inverse_lerp', line), v = num(args[2], 'inverse_lerp', line);
    return a === b ? 0 : (v - a) / (b - a);
  });
  define('remap', (args, line) => {
    needs(args, 5, 'remap', line);
    const n = args.slice(0, 5).map((a) => num(a, 'remap', line));
    const t = n[1] === n[2] ? 0 : (n[0] - n[1]) / (n[2] - n[1]);
    return n[3] + (n[4] - n[3]) * t;
  });
  /** Moves towards a target by at most `step`, never past it. Numbers or positions. */
  define('approach', (args, line) => {
    needs(args, 3, 'approach', line);
    const step = Math.abs(num(args[2], 'approach', line));
    if (typeof args[0] === 'number') {
      const current = args[0];
      const target = num(args[1], 'approach', line);
      return current < target ? smin(current + step, target) : smax(current - step, target);
    }
    const current = place(I, args[0], 'approach', line);
    const target = place(I, args[1], 'approach', line);
    const offset = vec.sub(target, current);
    const length = vec.length(offset);
    if (!(length > step && length > 0)) return vectorValue(target);
    return vectorValue(vec.add(current, vec.scale(offset, step / length)));
  });
  /** Round like a clock: wrap(370, 0, 360) is 10 and wrap(-1, 0, 4) is 3. */
  define('wrap', (args, line) => {
    needs(args, 3, 'wrap', line);
    const value = num(args[0], 'wrap', line), low = num(args[1], 'wrap', line), high = num(args[2], 'wrap', line);
    const span = high - low;
    if (span === 0) return low;
    const offset = value - low;
    return low + offset - Math.floor(offset / span) * span;
  });
  /** To the nearest step: snap(7.3, 2) is 8. Positions snap each part. */
  define('snap', (args, line) => {
    needs(args, 2, 'snap', line);
    const step = num(args[1], 'snap', line);
    const snapped = (v: number) => (step > 0 ? roundHalfAway(v / step) * step : v);
    const v = toVector(args[0]);
    if (v) return vectorValue({ x: snapped(v.x), y: snapped(v.y), z: snapped(v.z) });
    return snapped(num(args[0], 'snap', line));
  });
  define('angle_diff', (args, line) => {
    needs(args, 2, 'angle_diff', line);
    return shortestTurn(num(args[0], 'angle_diff', line), num(args[1], 'angle_diff', line));
  });
  define('gcd', (args, line) => {
    needs(args, 2, 'gcd', line);
    let a = Math.abs(scriptInt(Math.trunc(num(args[0], 'gcd', line))));
    let b = Math.abs(scriptInt(Math.trunc(num(args[1], 'gcd', line))));
    while (b !== 0) [a, b] = [b, a % b];
    return a;
  });

  // MARK: Choosing

  /** True this many times in a hundred: chance(25). */
  define('chance', (args, line) => {
    const percent = num(arg(args, 0), 'chance', line);
    return I.random.unit() * 100 < percent;
  });
  define('random_float', (args, line) => {
    needs(args, 2, 'random_float', line);
    const low = num(args[0], 'random_float', line), high = num(args[1], 'random_float', line);
    return low + (high - low) * I.random.unit();
  });
  /** By weight: from a map, a name; from a list of weights, a position. */
  define('pick_weighted', (args, line) => {
    const choices: [ScriptValue, number][] = [];
    const source = arg(args, 0);
    if (source instanceof ScriptMap) {
      for (const [key, value] of source.values) choices.push([key, num(value, 'pick_weighted', line)]);
    } else if (source instanceof ScriptList) {
      source.items.forEach((item, i) => choices.push([i + 1, num(item, 'pick_weighted', line)]));
    } else {
      throw new ScriptError(line, 'runtime', L('“{}” needs a list first.', 'pick_weighted'));
    }
    const weights = choices.map(([, w]) => (Number.isFinite(w) ? smax(w, 0) : 0));
    const total = weights.reduce((a, b) => a + b, 0);
    if (!(total > 0)) return null;
    let roll = I.random.unit() * total;
    for (let i = 0; i < weights.length; i++) {
      if (!(weights[i] > 0)) continue;
      if (roll < weights[i]) return choices[i][0];
      roll -= weights[i];
    }
    let last = 0;
    for (let i = weights.length - 1; i >= 0; i--) if (weights[i] > 0) { last = i; break; }
    return choices[last][0];
  });

  // MARK: Lists, the second round

  /** Each item once, in the order first seen. */
  define('unique', (args, line) => {
    const list = listArg(arg(args, 0), 'unique', line);
    const seen = new Set<unknown>();
    const objects = new Set<string>();
    return new ScriptList(list.items.filter((item) => {
      if (item instanceof ScriptObject) {
        const key = item.kind + '\u0000' + item.id;
        if (objects.has(key)) return false;
        objects.add(key);
        return true;
      }
      if (typeof item === 'number' && Number.isNaN(item)) return true;
      const key = typeof item === 'number' && item === 0 ? 0 : item;
      if (seen.has(key)) return false;
      seen.add(key);
      return true;
    }));
  });
  define('flatten', (args, line) => {
    const list = listArg(arg(args, 0), 'flatten', line);
    const items: ScriptValue[] = [];
    for (const item of list.items) {
      if (item instanceof ScriptList) items.push(...item.items);
      else items.push(item);
      I.checkSize(items.length, line);
    }
    return new ScriptList(items);
  });
  define('zip', (args, line) => {
    needs(args, 2, 'zip', line);
    const a = listArg(args[0], 'zip', line), b = listArg(args[1], 'zip', line);
    const n = Math.min(a.items.length, b.items.length);
    const out: ScriptValue[] = [];
    for (let i = 0; i < n; i++) out.push(new ScriptList([a.items[i], b.items[i]]));
    return new ScriptList(out);
  });
  define('first', (args, line) => listArg(arg(args, 0), 'first', line).items[0] ?? null);
  define('last', (args, line) => {
    const items = listArg(arg(args, 0), 'last', line).items;
    return items.length ? items[items.length - 1] : null;
  });
  define('chunk', (args, line) => {
    needs(args, 2, 'chunk', line);
    const list = listArg(args[0], 'chunk', line);
    const size = Math.max(1, scriptInt(num(args[1], 'chunk', line)));
    const groups: ScriptValue[] = [];
    for (let start = 0; start < list.items.length; start += size) {
      groups.push(new ScriptList(list.items.slice(start, Math.min(start + size, list.items.length))));
    }
    return new ScriptList(groups);
  });
  define('repeat', (args, line) => {
    needs(args, 2, 'repeat', line);
    const times = Math.max(0, scriptInt(num(args[1], 'repeat', line)));
    if (typeof args[0] === 'string') {
      const text = args[0];
      const count = characterCount(text);
      if (!(text === '' || times <= Math.floor(I.limits.maximumTextLength / count))) throw tooLong(line);
      return text.repeat(times);
    }
    I.checkSize(times, line);
    return new ScriptList(new Array<ScriptValue>(times).fill(args[0]));
  });

  // MARK: Functions over lists

  define('find', (args, line) => {
    needs(args, 2, 'find', line);
    for (const item of listArg(args[0], 'find', line).items.slice()) {
      if (isTruthy(I.call(args[1], [item], line))) return item;
    }
    return null;
  });
  define('any', (args, line) => {
    needs(args, 2, 'any', line);
    for (const item of listArg(args[0], 'any', line).items.slice()) {
      if (isTruthy(I.call(args[1], [item], line))) return true;
    }
    return false;
  });
  define('all', (args, line) => {
    needs(args, 2, 'all', line);
    for (const item of listArg(args[0], 'all', line).items.slice()) {
      if (!isTruthy(I.call(args[1], [item], line))) return false;
    }
    return true;
  });
  define('reduce', (args, line) => {
    needs(args, 2, 'reduce', line);
    const items = listArg(args[0], 'reduce', line).items.slice();
    let total: ScriptValue = args.length > 2 ? args[2] : (items[0] ?? null);
    for (const item of items.slice(args.length > 2 ? 0 : 1)) total = I.call(args[1], [total, item], line);
    return total;
  });
  /** How many: of a value, of items a function says yes to, or of some text inside text. */
  define('count', (args, line) => {
    needs(args, 2, 'count', line);
    if (typeof args[0] === 'string') {
      const part = displayText(args[1]);
      if (part === '') return 0;
      return args[0].split(part).length - 1;
    }
    const items = listArg(args[0], 'count', line).items.slice();
    if (isFunction(args[1])) return items.filter((item) => isTruthy(I.call(args[1], [item], line))).length;
    return items.filter((item) => isEqual(item, args[1])).length;
  });
  const extreme = (args: ScriptValue[], name: string, smallest: boolean, line: number): ScriptValue => {
    needs(args, 2, name, line);
    let best: { item: ScriptValue; key: ScriptValue } | null = null;
    for (const item of listArg(args[0], name, line).items.slice()) {
      const key = I.call(args[1], [item], line);
      if (best) {
        const better = smallest ? comesBefore(key, best.key, line) : comesBefore(best.key, key, line);
        if (better) best = { item, key };
      } else {
        best = { item, key };
      }
    }
    return best?.item ?? null;
  };
  define('min_by', (args, line) => extreme(args, 'min_by', true, line));
  define('max_by', (args, line) => extreme(args, 'max_by', false, line));
  define('sort_by', (args, line) => {
    needs(args, 2, 'sort_by', line);
    const items = listArg(args[0], 'sort_by', line).items.slice();
    const keys = items.map((item) => I.call(args[1], [item], line));
    const order = mergeSort(items.map((_, i) => i), (a, b) => comesBefore(keys[a as number], keys[b as number], line));
    return new ScriptList(order.map((i) => items[i as number]));
  });
  define('group_by', (args, line) => {
    needs(args, 2, 'group_by', line);
    const groups = new ScriptMap();
    for (const item of listArg(args[0], 'group_by', line).items.slice()) {
      const key = displayText(I.call(args[1], [item], line));
      const group = groups.get(key);
      if (group instanceof ScriptList) {
        group.items.push(item);
      } else {
        groups.set(key, new ScriptList([item]));
        I.checkSize(groups.count, line);
      }
    }
    return groups;
  });

  // MARK: Maps

  define('values', (args, line) => new ScriptList([...mapArg(arg(args, 0), 'values', line).values.values()]));
  define('entries', (args, line) => {
    const map = mapArg(arg(args, 0), 'entries', line);
    return new ScriptList([...map.values].map(([k, v]) => new ScriptList([k, v])));
  });
  define('merge', (args, line) => {
    needs(args, 2, 'merge', line);
    const merged = new ScriptMap();
    for (const value of args.slice(0, 2)) {
      for (const [k, v] of mapArg(value, 'merge', line).values) merged.set(k, v);
    }
    I.checkSize(merged.count, line);
    return merged;
  });
  /** get(p.saved, "coins", 0): a value, or a default when it is not there. */
  define('get', (args) => {
    const fallback = arg(args, 2), key = arg(args, 1), source = arg(args, 0);
    if (source instanceof ScriptMap) return source.get(displayText(key)) ?? fallback;
    if (source instanceof ScriptList) {
      if (typeof key !== 'number' || !Number.isInteger(key) || key < 1 || key > source.items.length) return fallback;
      return source.items[key - 1];
    }
    return fallback;
  });

  // MARK: Text, the second round

  const pad = (name: string, left: boolean) => define(name, (args, line) => {
    const text = displayText(arg(args, 0));
    const width = Math.min(scriptInt(num(arg(args, 1), name, line)), I.limits.maximumTextLength);
    const fill = args.length > 2 ? (characters(displayText(args[2]))[0] ?? ' ') : ' ';
    const count = characterCount(text);
    if (!(width > count)) return text;
    const padding = fill.repeat(width - count);
    return left ? padding + text : text + padding;
  });
  pad('pad_left', true);
  pad('pad_right', false);

  define('capitalize', (args) => {
    const chars = characters(displayText(arg(args, 0)));
    if (chars.length === 0) return '';
    return chars[0].toUpperCase() + chars.slice(1).join('');
  });
  define('words', (args, line) => {
    const parts = displayText(arg(args, 0)).split(/\s+/u).filter((p) => p !== '');
    I.checkSize(parts.length, line);
    return new ScriptList(parts);
  });
  define('lines', (args, line) => {
    const parts = displayText(arg(args, 0)).split(newline);
    I.checkSize(parts.length, line);
    return new ScriptList(parts);
  });
  /** format("{} has {} coins", p.name, 5). */
  define('format', (args, line) => {
    const template = displayText(arg(args, 0));
    let result = '';
    let next = 1;
    let rest = template;
    for (;;) {
      const at = rest.indexOf('{}');
      if (at < 0) break;
      result += rest.slice(0, at);
      result += next < args.length ? displayText(args[next]) : '{}';
      next += 1;
      rest = rest.slice(at + 2);
      if (result.length > I.limits.maximumTextLength) break;
    }
    return checkedText(result + rest, line);
  });

  // MARK: Numbers as text

  define('comma', (args, line) => withCommas(num(arg(args, 0), 'comma', line)));
  define('short_number', (args, line) => shortNumber(num(arg(args, 0), 'short_number', line)));
  define('time_text', (args, line) => clockText(num(arg(args, 0), 'time_text', line)));

  // MARK: Directions

  // cos(90°) is 6e-17 in floating point; a direction reads 0 there, never "-0".
  const clean = (v: number) => (Math.abs(v) < 1e-9 ? 0 : v);

  define('direction', (args, line) => {
    needs(args, 2, 'direction', line);
    const offset = vec.sub(place(I, args[1], 'direction', line), place(I, args[0], 'direction', line));
    const length = vec.length(offset);
    return vectorValue(length > 0 ? vec.scale(offset, 1 / length) : offset);
  });
  define('forward', (args, line) => {
    const yaw = num(arg(args, 0), 'forward', line) * DEG;
    return vectorValue({ x: clean(Math.sin(yaw)), y: 0, z: clean(-Math.cos(yaw)) });
  });
  define('yaw_to', (args, line) => {
    needs(args, 2, 'yaw_to', line);
    const offset = vec.sub(place(I, args[1], 'yaw_to', line), place(I, args[0], 'yaw_to', line));
    if (!(offset.x * offset.x + offset.z * offset.z > 1e-12)) return 0;
    return Math.atan2(offset.x, -offset.z) / DEG;
  });
  define('rotate_y', (args, line) => {
    needs(args, 2, 'rotate_y', line);
    const v = place(I, args[0], 'rotate_y', line);
    const angle = num(args[1], 'rotate_y', line) * DEG;
    const c = Math.cos(angle), s = Math.sin(angle);
    return vectorValue({ x: clean(v.x * c - v.z * s), y: v.y, z: clean(v.x * s + v.z * c) });
  });
  define('angle_between', (args, line) => {
    needs(args, 2, 'angle_between', line);
    const a = place(I, args[0], 'angle_between', line), b = place(I, args[1], 'angle_between', line);
    const lengths = vec.length(a) * vec.length(b);
    if (!(lengths > 0)) return 0;
    const cosine = smin(smax((a.x * b.x + a.y * b.y + a.z * b.z) / lengths, -1), 1);
    return Math.acos(cosine) / DEG;
  });

  // MARK: Colours

  define('rgb', (args, line) => {
    needs(args, 3, 'rgb', line);
    const parts = args.slice(0, 3).map((a) => Math.fround(num(a, 'rgb', line) / 255));
    const alpha = args.length > 3 ? Math.fround(num(args[3], 'rgb', line)) : 1;
    return hexString(rgba(parts[0], parts[1], parts[2], alpha));
  });
  define('hsv', (args, line) => {
    needs(args, 3, 'hsv', line);
    const n = args.slice(0, 3).map((a) => num(a, 'hsv', line));
    return hexString(hsv(n[0], n[1], n[2]));
  });
  define('mix_color', (args, line) => {
    needs(args, 3, 'mix_color', line);
    const colours = args.slice(0, 2).map((value) => {
      const colour = parseScriptColor(displayText(value));
      if (!colour) {
        throw new ScriptError(line, 'runtime',
          L('“{}” is not a colour. Try “red”, “blue” or “#FF8800”.', displayText(value)));
      }
      return colour;
    });
    const t = Math.fround(num(args[2], 'mix_color', line));
    return hexString(lerpColor(colours[0], colours[1], Number.isFinite(t) ? t : 0));
  });
  define('random_color', () => hexString(hsv(I.random.unit() * 360, 0.75, 1)));
}
