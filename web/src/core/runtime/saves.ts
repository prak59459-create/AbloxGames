// `p.saved` and `p.save(key, value)`: progress that outlives the session —
// GameRuntimeSave.swift. The data lives with each player; it arrives when
// they join, the script reads and changes it, and changes go back to them at
// most once a second.
import { L } from '../../i18n';
import { SaveData, SaveLimits, isValidSaveKey, type SaveValue } from '../model/save';
import { deepEqual } from '../model/equal';
import { ScriptList, ScriptMap, typeName, type ScriptValue } from '../script/values';
import { limitError, runtimeError } from './args';
import type { GameRuntime } from './gameRuntime';
import type { PlayerState } from './state';

const flushInterval = 1;

/** A player's saved data, as it arrived. Only the first copy counts. */
export function receiveSave(rt: GameRuntime, data: SaveData, state: PlayerState): void {
  if (state.saved !== null) return;
  state.saved = new SaveData(data.values);
  if (!rt.hasStarted || rt.isRoundOver) return;
  rt.run('loaded', [rt.object(state)]);
}

/** `p.saved`: a copy, so changing it saves nothing by accident. */
export function savedValue(state: PlayerState): ScriptValue {
  return state.saved ? scriptValue(state.saved.values) : null;
}

/** `p.save("coins", 120)`, or `p.save("coins")` to forget it. False before their data has arrived. */
export function save(_rt: GameRuntime, args: ScriptValue[], state: PlayerState, line: number): ScriptValue {
  const key = args[0];
  if (typeof key !== 'string' || !isValidSaveKey(key)) {
    throw runtimeError(line, L('“save” needs a name first, like p.save("coins", 10).'));
  }
  const saved = state.saved;
  if (state.isNPC || !saved) return false;
  const value = args.length > 1 ? args[1] : null;
  const converted = value === null ? undefined : saveValue(value, line);
  const current = saved.get(key);
  if (current === converted || (current !== undefined && converted !== undefined && deepEqual(current, converted))) return true;
  const next = saved.copy();
  if (!next.set(key, converted)) {
    throw limitError(line, L('That is too much to save (the limit is {} KB).', SaveLimits.maximumEncodedBytes / 1024));
  }
  state.saved = next;
  state.saveChanged = true;
  return true;
}

export function saveValue(value: ScriptValue, line: number, depth = 1): SaveValue {
  if (depth > SaveLimits.maximumDepth) {
    throw limitError(line, L('Saved lists and maps can only go {} deep.', SaveLimits.maximumDepth));
  }
  if (typeof value === 'boolean' || typeof value === 'string') return value;
  if (typeof value === 'number') {
    if (!Number.isFinite(value)) throw runtimeError(line, L('Only a real number can be saved.'));
    return value;
  }
  if (value instanceof ScriptList) return value.items.map((item) => (item === null ? null : saveValue(item, line, depth + 1)));
  if (value instanceof ScriptMap) {
    const out: Record<string, SaveValue> = {};
    for (const key of value.keys) {
      const item = value.get(key);
      if (item === undefined || item === null) continue;
      out[key] = saveValue(item, line, depth + 1);
    }
    return out;
  }
  throw runtimeError(line, L('Only numbers, text, true/false, lists and maps can be saved — not {}.', typeName(value)));
}

export function scriptValue(value: SaveValue | Record<string, SaveValue>): ScriptValue {
  if (value === null || typeof value !== 'object') return value;
  if (Array.isArray(value)) return new ScriptList(value.map(scriptValue));
  const map = new ScriptMap();
  for (const key of Object.keys(value).sort()) map.set(key, scriptValue(value[key]));
  return map;
}

/** Sends changed saves back to their players. */
export function flushSaves(rt: GameRuntime): void {
  for (const state of rt.orderedStates) {
    if (!state.saveChanged || !state.saved || rt.clock - state.lastSaveSent < flushInterval) continue;
    state.saveChanged = false;
    state.lastSaveSent = rt.clock;
    rt.send(state, { type: 'script', effect: { kind: 'store', data: state.saved.copy() } });
  }
}
