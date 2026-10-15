// A world's .absc files parsed together into one program, and Studio's
// Check: ScriptBundle in ScriptFile.swift and GameRuntime.check.
import { L } from '../../i18n';
import { combinePrograms, type Program } from '../script/ast';
import { editDistance } from '../script/interpreter';
import { ScriptError } from '../script/lexer';
import { parse } from '../script/parser';
import { trimmed } from '../model/text';
import type { ScriptFile } from '../model/world';
import { runtimeEvents } from './limits';

export type Compiled = { ok: true; program: Program; fileNames: string[] } | { ok: false; errors: ScriptError[] };

const asScriptError = (error: unknown, file?: string): ScriptError =>
  error instanceof ScriptError ? error : new ScriptError(1, 'syntax', String((error as Error)?.message ?? error), file);

/** Every switched-on, non-empty file, with every file's syntax error at once. */
export function compileScripts(files: ScriptFile[]): Compiled {
  const active = files.filter((f) => f.isEnabled && trimmed(f.source) !== '');
  const names = active.map((f) => f.name);
  const programs: Program[] = [];
  const errors: ScriptError[] = [];
  active.forEach((file, index) => {
    try {
      programs.push(parse(file.source, index));
    } catch (error) {
      errors.push(error instanceof ScriptError ? error.resolved(names) : asScriptError(error, file.name));
    }
  });
  if (errors.length) return { ok: false, errors };
  return { ok: true, program: combinePrograms(programs), fileNames: names };
}

function unknownEvents(program: Program): ScriptError[] {
  const known = runtimeEvents as readonly string[];
  const handlers = [...program.handlers.values()].flat().sort((a, b) => a.line - b.line);
  const problems: ScriptError[] = [];
  for (const handler of handlers) {
    if (known.includes(handler.event)) continue;
    let nearest = known[0];
    for (const name of known) if (editDistance(handler.event, name) < editDistance(handler.event, nearest)) nearest = name;
    problems.push(editDistance(handler.event, nearest) <= 2
      ? new ScriptError(handler.line, 'syntax', L('“on {}” never happens. Did you mean “on {}”?', handler.event, nearest))
      : new ScriptError(handler.line, 'syntax', L('“on {}” never happens. The events are: {}.', handler.event, known.join(', '))));
  }
  return problems;
}

/** What is wrong with a world's files without running them. */
export function checkScripts(files: ScriptFile[]): ScriptError[] {
  const compiled = compileScripts(files);
  if (!compiled.ok) return compiled.errors;
  return unknownEvents(compiled.program).map((e) => e.resolved(compiled.fileNames));
}

/** One source on its own, with plain line numbers. */
export function checkSource(source: string): ScriptError[] {
  try {
    return unknownEvents(parse(source));
  } catch (error) {
    return [asScriptError(error)];
  }
}
