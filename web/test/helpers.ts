import { useLanguageForTests } from '../src/i18n';
import { ScriptInterpreter, defaultLimits, type ScriptLimits } from '../src/core/script/interpreter';
import { ScriptError } from '../src/core/script/lexer';
import { parse } from '../src/core/script/parser';

useLanguageForTests('en');

/** Runs a script's top level and returns what it printed. */
export function run(source: string, limits: Partial<ScriptLimits> = {}): string[] {
  const interpreter = new ScriptInterpreter(parse(source), 1, { ...defaultLimits(), ...limits });
  interpreter.start();
  return interpreter.drainOutput();
}

export function error(source: string, limits: Partial<ScriptLimits> = {}): ScriptError | null {
  try {
    run(source, limits);
    return null;
  } catch (e) {
    if (e instanceof ScriptError) return e;
    throw e;
  }
}

export function interpreter(source: string, limits: Partial<ScriptLimits> = {}): ScriptInterpreter {
  return new ScriptInterpreter(parse(source), 1, { ...defaultLimits(), ...limits });
}
