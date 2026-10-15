// Reading what a script passed — the "Reading arguments" part of
// GameRuntimeAPI.swift. Each refuses with the same words the iPads use.
import { L } from '../../i18n';
import { parseScriptColor, type ColorRGBA } from '../model/color';
import { UILimits } from '../model/effects';
import { v3, type Vec3 } from '../model/math';
import { isLibraryID, soundCueNamed } from '../model/player';
import { prefix, trimmed } from '../model/text';
import { ScriptError } from '../script/lexer';
import {
  ScriptMap, ScriptNative, ScriptObject, displayText, toVector, typeName, vectorValue, type NativeBody, type ScriptValue,
} from '../script/values';
import { soundCues } from '../model/player';

export const runtimeError = (line: number, message: string) => new ScriptError(line, 'runtime', message);
export const limitError = (line: number, message: string) => new ScriptError(line, 'limit', message);

export const method = (name: string, body: NativeBody): ScriptValue => new ScriptNative(name, body);

export function number(value: ScriptValue, what: string, line: number): number {
  if (typeof value !== 'number' || !Number.isFinite(value)) {
    throw runtimeError(line, L('“{}” needs a number here, not {}.', what, value === null ? 'nil' : displayText(value)));
  }
  return value;
}

export function optionalNumber(args: ScriptValue[], index: number, fallback: number, line: number): number {
  if (index >= args.length || args[index] === null || args[index] === undefined) return fallback;
  return number(args[index], 'number', line);
}

export const arg = (args: ScriptValue[], index: number): ScriptValue => (index < args.length ? args[index] ?? null : null);

export const shortText = (value: ScriptValue) => prefix(displayText(value), UILimits.maximumTextLength);

export function optionsMap(value: ScriptValue, line: number): ScriptMap {
  if (value instanceof ScriptMap) return value;
  if (value === null || value === undefined) return new ScriptMap();
  throw runtimeError(line, L('This needs options in { }, like {x: 0.5, y: 0.1}.'));
}

/** A built-in cue's name, or a sound library id, as the wire spells it. */
export function soundName(value: ScriptValue, line: number): string {
  const cue = soundCueNamed(displayText(value));
  if (cue) return cue;
  const name = trimmed(displayText(value)).toLowerCase();
  if (!isLibraryID(name)) {
    throw runtimeError(line, L('There is no sound called “{}”. The sounds are: {}, or the name of one from the sound library (like “retro-game-coin-08”).',
      displayText(value), soundCues.join(', ')));
  }
  return name;
}

/** Swift's `.rounded()`: halves away from zero. */
export const roundAway = (x: number) => (x < 0 ? -Math.round(-x) : Math.round(x));

/** Positions to the centimetre, so `print(p.position)` reads well. */
export const rounded = (n: number) => roundAway(n * 100) / 100;

export const roundedVector = (p: Vec3): ScriptValue => vectorValue({ x: rounded(p.x), y: rounded(p.y), z: rounded(p.z) });

/** A `{x, y, z}` map as a vector. */
export function vector(value: ScriptValue, line: number): Vec3 {
  const v = toVector(value);
  if (!v || !Number.isFinite(v.x) || !Number.isFinite(v.y) || !Number.isFinite(v.z)) {
    throw runtimeError(line, L('That needs {x, y, z}, not {}.', typeName(value)));
  }
  return v3(v.x, v.y, v.z);
}

/** Three numbers, or one `{x, y, z}`. */
export function vectorArgument(args: ScriptValue[], line: number, what: string): Vec3 {
  if (args.length && toVector(args[0])) return vector(args[0], line);
  if (args.length < 3) throw runtimeError(line, L('“{}” needs {} values.', what, 3));
  return v3(number(args[0], what, line), number(args[1], what, line), number(args[2], what, line));
}

export function color(value: ScriptValue, line: number): ColorRGBA {
  const c = parseScriptColor(displayText(value));
  if (!c) throw runtimeError(line, L('“{}” is not a colour. Try “red”, “blue” or “#FF8800”.', displayText(value)));
  return c;
}

export const isObject = (value: ScriptValue): value is ScriptObject => value instanceof ScriptObject;
