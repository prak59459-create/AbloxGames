// Runs an AbloxScript program, with limits — AbloxCore/ScriptInterpreter.swift.
//
// Every statement and expression costs a step, and a handler that spends more
// than its budget is stopped with an error on the line it had reached. A
// script cannot freeze the page, recurse until the stack overflows, or grow a
// list until the tab runs out of memory. The only way out of a script is the
// game API it was given.
import { L } from '../../i18n';
import type { BinaryOp, Expr, Program, Stmt } from './ast';
import { ScriptError } from './lexer';
import {
  ScriptFunction, ScriptList, ScriptMap, ScriptNative, ScriptObject, ScriptRandom, ScriptScope,
  characterCount, characters, compareText, displayText, formatNumber, isEqual, isTruthy, toVector,
  typeName, vec, vectorValue, type NativeBody, type ScriptValue,
} from './values';
import { installStandardLibrary } from './stdlib';

/** Answers `player.health`, `block.visible = false` and the like. */
export interface ScriptObjectResolver {
  member(object: ScriptObject, name: string, line: number): ScriptValue;
  setMember(object: ScriptObject, name: string, value: ScriptValue, line: number): void;
}

export interface ScriptLimits {
  stepsPerCall: number;
  maximumCallDepth: number;
  maximumCollectionSize: number;
  maximumTextLength: number;
  maximumOutputLines: number;
}

export const defaultLimits = (): ScriptLimits => ({
  stepsPerCall: 2_000_000,
  maximumCallDepth: 200,
  maximumCollectionSize: 100_000,
  maximumTextLength: 1_000_000,
  maximumOutputLines: 500,
});

type Flow =
  | { f: 'normal' }
  | { f: 'break'; line: number }
  | { f: 'continue'; line: number }
  | { f: 'return'; value: ScriptValue };

const NORMAL: Flow = { f: 'normal' };

export class ScriptInterpreter {
  readonly globals = new ScriptScope(null);
  limits: ScriptLimits;
  resolver: ScriptObjectResolver | null = null;
  random: ScriptRandom;
  output: string[] = [];

  private stepsRemaining = 0;
  private callDepth = 0;
  private entryDepth = 0;
  private builtinNames = new Set<string>();

  totalSteps = 0;
  watchedLines = new Set<number>();
  onWatchedLine: ((line: number, scope: ScriptScope) => void) | null = null;

  constructor(readonly program: Program, seed: bigint | number = 1, limits: ScriptLimits = defaultLimits()) {
    this.random = new ScriptRandom(seed);
    this.limits = limits;
    installStandardLibrary(this);
  }

  // MARK: Entry points

  /** Runs the top level once: `let`, `func` and anything outside a handler. */
  start(): void {
    this.withBudget(() => {
      this.executeBlock(this.program.statements, this.globals, true);
    });
  }

  hasHandler(event: string): boolean {
    return (this.program.handlers.get(event)?.length ?? 0) > 0;
  }

  fire(event: string, args: ScriptValue[] = []): boolean {
    return this.run(event, args) !== undefined;
  }

  /**
   * Like `fire`, but hands back what the handlers returned: undefined when
   * there is no handler, null when none returned anything, otherwise the
   * last value one returned. Each file's handler gets its own budget.
   */
  run(event: string, args: ScriptValue[] = []): ScriptValue | undefined {
    const handlers = this.program.handlers.get(event);
    if (!handlers || handlers.length === 0) return undefined;
    let result: ScriptValue = null;
    for (const handler of handlers) {
      this.withBudget(() => {
        const scope = new ScriptScope(this.globals);
        handler.params.forEach((name, i) => scope.declare(name, i < args.length ? args[i] : null));
        const flow = this.executeBlock(handler.body, scope, false);
        this.checkFlowAtBoundary(flow, handler.line);
        if (flow.f === 'return' && flow.value !== null) result = flow.value;
      });
    }
    return result;
  }

  /** Calls a function value — timers set with `after`, callbacks. */
  invoke(callable: ScriptValue, args: ScriptValue[] = [], line: number): ScriptValue {
    let result: ScriptValue = null;
    this.withBudget(() => {
      result = this.call(callable, args, line);
    });
    return result;
  }

  define(name: string, body: NativeBody): void {
    this.globals.declare(name, new ScriptNative(name, body));
    this.builtinNames.add(name);
  }

  defineValue(name: string, value: ScriptValue): void {
    this.globals.declare(name, value);
    this.builtinNames.add(name);
  }

  drainOutput(): string[] {
    const out = this.output;
    this.output = [];
    return out;
  }

  log(line: string): void {
    this.output.push(line);
    if (this.output.length > this.limits.maximumOutputLines) {
      this.output.splice(0, this.output.length - this.limits.maximumOutputLines);
    }
  }

  private withBudget(body: () => void): void {
    // Re-entrant: a callback spends from the same budget, so it cannot
    // launder an infinite loop.
    if (this.entryDepth === 0) {
      this.stepsRemaining = this.limits.stepsPerCall;
      this.callDepth = 0;
    }
    this.entryDepth += 1;
    try {
      body();
    } catch (error) {
      throw this.asScriptError(error);
    } finally {
      this.entryDepth -= 1;
    }
  }

  /** A JavaScript stack overflow becomes the script's own "too deep" error. */
  private asScriptError(error: unknown): unknown {
    if (error instanceof RangeError && /call stack/i.test(error.message)) {
      return new ScriptError(0, 'limit', L('Functions called each other too deeply. Does “{}” call itself forever?', 'func'));
    }
    return error;
  }

  get remainingSteps(): number { return this.stepsRemaining; }

  private step(line: number): void {
    this.totalSteps += 1;
    this.stepsRemaining -= 1;
    if (this.stepsRemaining < 0) {
      throw new ScriptError(line, 'limit', L('This took too long and was stopped. Is there a loop that never ends?'));
    }
  }

  // MARK: Statements

  private checkFlowAtBoundary(flow: Flow, _line: number): void {
    if (flow.f === 'break') throw new ScriptError(flow.line, 'syntax', L('“break” can only be used inside a loop.'));
    if (flow.f === 'continue') throw new ScriptError(flow.line, 'syntax', L('“continue” can only be used inside a loop.'));
  }

  private executeBlock(statements: Stmt[], scope: ScriptScope, isTopLevel: boolean): Flow {
    for (const statement of statements) {
      const flow = this.execute(statement, scope, isTopLevel);
      if (flow.f !== 'normal') return flow;
    }
    return NORMAL;
  }

  private execute(s: Stmt, scope: ScriptScope, isTopLevel: boolean): Flow {
    this.step(s.line);
    if (this.watchedLines.size > 0 && this.watchedLines.has(s.line)) this.onWatchedLine?.(s.line, scope);

    switch (s.k) {
      case 'declare':
        scope.declare(s.name, s.value ? this.evaluate(s.value, scope) : null);
        break;

      case 'assign':
        this.assign(this.evaluate(s.value, scope), s.target, scope);
        break;

      case 'expression':
        this.evaluate(s.expr, scope);
        break;

      case 'if':
        for (const branch of s.branches) {
          if (isTruthy(this.evaluate(branch.condition, scope))) {
            return this.executeBlock(branch.body, new ScriptScope(scope), isTopLevel);
          }
        }
        if (s.otherwise) return this.executeBlock(s.otherwise, new ScriptScope(scope), isTopLevel);
        break;

      case 'while':
        while (isTruthy(this.evaluate(s.condition, scope))) {
          const flow = this.executeBlock(s.body, new ScriptScope(scope), isTopLevel);
          if (flow.f === 'break') return NORMAL;
          if (flow.f === 'return') return flow;
        }
        break;

      case 'forRange': {
        const from = this.number(this.evaluate(s.from, scope), 'for', s.line);
        const to = this.number(this.evaluate(s.to, scope), 'for', s.line);
        // Counting down needs no `step -1`: `for i in 10 to 1` does what it says.
        const increment = s.step ? this.number(this.evaluate(s.step, scope), 'step', s.line) : (from <= to ? 1 : -1);
        if (increment === 0) {
          throw new ScriptError(s.line, 'runtime', L('“step” cannot be 0 — the loop would never end.'));
        }
        let value = from;
        while (increment > 0 ? value <= to : value >= to) {
          const iteration = new ScriptScope(scope);
          iteration.declare(s.variable, value);
          const flow = this.executeBlock(s.body, iteration, isTopLevel);
          if (flow.f === 'break') return NORMAL;
          if (flow.f === 'return') return flow;
          value += increment;
          this.step(s.line);
        }
        break;
      }

      case 'forEach': {
        const sequence = this.evaluate(s.sequence, scope);
        let items: ScriptValue[];
        if (sequence instanceof ScriptList) {
          // A copy, so adding to the list inside the loop cannot make it run forever.
          items = sequence.items.slice();
        } else if (sequence instanceof ScriptMap) {
          items = sequence.keys;
        } else if (typeof sequence === 'string') {
          items = characters(sequence);
        } else {
          throw new ScriptError(s.line, 'runtime', L('“for … in” needs a list, a map or text, not {}.', typeName(sequence)));
        }
        for (const item of items) {
          const iteration = new ScriptScope(scope);
          iteration.declare(s.variable, item);
          const flow = this.executeBlock(s.body, iteration, isTopLevel);
          if (flow.f === 'break') return NORMAL;
          if (flow.f === 'return') return flow;
        }
        break;
      }

      case 'function':
        scope.declare(s.name, new ScriptFunction(s.name, s.params, s.body, scope, s.line));
        break;

      case 'handler':
        // Collected by the parser; running the top level passes over them.
        break;

      case 'return':
        if (isTopLevel) {
          throw new ScriptError(s.line, 'syntax', L('“return” can only be used inside a function or an “on”.'));
        }
        return { f: 'return', value: s.value ? this.evaluate(s.value, scope) : null };

      case 'break':
        return { f: 'break', line: s.line };

      case 'continue':
        return { f: 'continue', line: s.line };
    }
    return NORMAL;
  }

  private assign(value: ScriptValue, target: Expr, scope: ScriptScope): void {
    switch (target.k) {
      case 'variable':
        if (!scope.assign(target.name, value)) {
          throw new ScriptError(target.line, 'runtime', this.undefinedMessage(target.name, scope, true));
        }
        return;

      case 'member': {
        const base = this.evaluate(target.object, scope);
        const name = target.name;
        if (base instanceof ScriptMap) {
          // Setting an entry to nil removes it.
          base.set(name, value === null ? undefined : value);
          this.checkSize(base.count, target.line);
        } else if (base instanceof ScriptObject) {
          if (!this.resolver) throw new ScriptError(target.line, 'runtime', L('“{}” cannot be changed here.', name));
          this.resolver.setMember(base, name, value, target.line);
        } else if (base === null) {
          throw new ScriptError(target.line, 'runtime', L('This is nil, so it has no “{}” to set.', name));
        } else {
          throw new ScriptError(target.line, 'runtime', L('A {} has no “{}” to set.', typeName(base), name));
        }
        return;
      }

      case 'index': {
        const base = this.evaluate(target.object, scope);
        const index = this.evaluate(target.index, scope);
        if (base instanceof ScriptList && typeof index === 'number') {
          const offset = this.listOffset(index, base.items.length, target.line);
          base.items[offset] = value;
        } else if (base instanceof ScriptMap && typeof index === 'string') {
          base.set(index, value === null ? undefined : value);
          this.checkSize(base.count, target.line);
        } else if (base instanceof ScriptObject && typeof index === 'string') {
          if (!this.resolver) throw new ScriptError(target.line, 'runtime', L('“{}” cannot be changed here.', index));
          this.resolver.setMember(base, index, value, target.line);
        } else {
          throw new ScriptError(target.line, 'runtime', L('A {} cannot be indexed with a {}.', typeName(base), typeName(index)));
        }
        return;
      }

      default:
        throw new ScriptError(target.line, 'syntax', L('The left side of “=” has to be a name.'));
    }
  }

  // MARK: Expressions

  private evaluate(e: Expr, scope: ScriptScope): ScriptValue {
    this.step(e.line);
    const line = e.line;

    switch (e.k) {
      case 'number': return e.v;
      case 'string': return e.v;
      case 'bool': return e.v;
      case 'null': return null;

      case 'list': {
        this.checkSize(e.items.length, line);
        return new ScriptList(e.items.map((item) => this.evaluate(item, scope)));
      }

      case 'map': {
        const map = new ScriptMap();
        for (const entry of e.entries) map.set(entry.key, this.evaluate(entry.value, scope));
        this.checkSize(map.count, line);
        return map;
      }

      case 'variable': {
        const value = scope.lookup(e.name);
        if (value === undefined) throw new ScriptError(line, 'runtime', this.undefinedMessage(e.name, scope, false));
        return value;
      }

      case 'unary': {
        const value = this.evaluate(e.operand, scope);
        if (e.op === 'not') return !isTruthy(value);
        const v = toVector(value);
        if (v) return vectorValue(vec.scale(v, -1));
        return -this.number(value, '-', line);
      }

      case 'logical': {
        // Returns an operand, so `name or "Guest"` gives a default.
        const first = this.evaluate(e.left, scope);
        if (e.isAnd) return isTruthy(first) ? this.evaluate(e.right, scope) : first;
        return isTruthy(first) ? first : this.evaluate(e.right, scope);
      }

      case 'binary': {
        const left = this.evaluate(e.left, scope);
        const right = this.evaluate(e.right, scope);
        return this.binary(e.op, left, right, line);
      }

      case 'call': {
        const callee = this.evaluate(e.callee, scope);
        const args = e.args.map((a) => this.evaluate(a, scope));
        if (callee === null && e.callee.k === 'variable') {
          throw new ScriptError(line, 'runtime', L('“{}” is nil, not a function.', e.callee.name));
        }
        return this.call(callee, args, line);
      }

      case 'member': {
        const base = this.evaluate(e.object, scope);
        return this.member(base, e.name, line, e.object);
      }

      case 'index': {
        const base = this.evaluate(e.object, scope);
        const index = this.evaluate(e.index, scope);
        if (base instanceof ScriptList && typeof index === 'number') {
          // Reading past the end gives nil, so a loop can test `if list[i] == nil`.
          if (!Number.isInteger(index) || index < 1 || index > base.items.length) return null;
          return base.items[index - 1];
        }
        if (base instanceof ScriptMap && typeof index === 'string') return base.get(index) ?? null;
        if (base instanceof ScriptObject && typeof index === 'string') {
          if (!this.resolver) return null;
          return this.resolver.member(base, index, line);
        }
        if (typeof base === 'string' && typeof index === 'number') {
          if (!Number.isInteger(index) || index < 1) return null;
          const chars = characters(base);
          return index <= chars.length ? chars[index - 1] : null;
        }
        throw new ScriptError(line, 'runtime', L('A {} cannot be indexed with a {}.', typeName(base), typeName(index)));
      }

      case 'function':
        return new ScriptFunction('func', e.params, e.body, scope, line);
    }
  }

  private member(base: ScriptValue, name: string, line: number, baseExpression: Expr): ScriptValue {
    if (base instanceof ScriptMap) return base.get(name) ?? null;
    if (base instanceof ScriptObject) {
      if (!this.resolver) return null;
      return this.resolver.member(base, name, line);
    }
    if (base instanceof ScriptList && name === 'length') return base.items.length;
    if (typeof base === 'string' && name === 'length') return characterCount(base);
    if (base === null) {
      // The single most common runtime error, so it names the variable.
      if (baseExpression.k === 'variable') {
        throw new ScriptError(line, 'runtime', L('“{}” is nil, so it has no “{}”.', baseExpression.name, name));
      }
      throw new ScriptError(line, 'runtime', L('This is nil, so it has no “{}”.', name));
    }
    throw new ScriptError(line, 'runtime', L('A {} has no “{}”.', typeName(base), name));
  }

  /** Calls a function value; the library's `sort`, `map` and `filter` call back through here. */
  call(callee: ScriptValue, args: ScriptValue[], line: number): ScriptValue {
    if (callee instanceof ScriptNative) return callee.body(args, line);
    if (callee instanceof ScriptFunction) {
      this.callDepth += 1;
      try {
        if (this.callDepth > this.limits.maximumCallDepth) {
          throw new ScriptError(line, 'limit',
            L('Functions called each other too deeply. Does “{}” call itself forever?', callee.name));
        }
        const scope = new ScriptScope(callee.closure);
        callee.params.forEach((name, i) => scope.declare(name, i < args.length ? args[i] : null));
        const flow = this.executeBlock(callee.body, scope, false);
        this.checkFlowAtBoundary(flow, callee.line);
        return flow.f === 'return' ? flow.value : null;
      } finally {
        this.callDepth -= 1;
      }
    }
    throw new ScriptError(line, 'runtime', L('A {} cannot be called like a function.', typeName(callee)));
  }

  // MARK: Operators

  private binary(op: BinaryOp, left: ScriptValue, right: ScriptValue, line: number): ScriptValue {
    switch (op) {
      case '==': return isEqual(left, right);
      case '!=': return !isEqual(left, right);
      case '..': return this.text(displayText(left) + displayText(right), line);

      case '+': {
        // `+` joins text when either side is text: "Score: " + score.
        if (typeof left === 'string' || typeof right === 'string') {
          return this.text(displayText(left) + displayText(right), line);
        }
        if (typeof left === 'number' && typeof right === 'number') return left + right;
        const a = toVector(left), b = toVector(right);
        if (a && b) return vectorValue(vec.add(a, b));
        return this.number(left, '+', line) + this.number(right, '+', line);
      }

      case '-': {
        if (typeof left === 'number' && typeof right === 'number') return left - right;
        const a = toVector(left), b = toVector(right);
        if (a && b) return vectorValue(vec.sub(a, b));
        return this.number(left, '-', line) - this.number(right, '-', line);
      }

      case '*': {
        if (typeof left === 'number' && typeof right === 'number') return left * right;
        const a = toVector(left);
        if (a && typeof right === 'number') return vectorValue(vec.scale(a, right));
        const b = toVector(right);
        if (typeof left === 'number' && b) return vectorValue(vec.scale(b, left));
        return this.number(left, '*', line) * this.number(right, '*', line);
      }

      case '/': {
        const a = toVector(left);
        if (a && typeof right === 'number') {
          if (right === 0) throw new ScriptError(line, 'runtime', L('Cannot divide by zero.'));
          return vectorValue(vec.scale(a, 1 / right));
        }
        const divisor = this.number(right, '/', line);
        if (divisor === 0) throw new ScriptError(line, 'runtime', L('Cannot divide by zero.'));
        return this.number(left, '/', line) / divisor;
      }

      case '%': {
        const divisor = this.number(right, '%', line);
        if (divisor === 0) throw new ScriptError(line, 'runtime', L('Cannot divide by zero.'));
        const dividend = this.number(left, '%', line);
        // Floored, so `-1 % 4` is 3 — what wrapping an index needs.
        return dividend - Math.floor(dividend / divisor) * divisor;
      }

      case '<': case '<=': case '>': case '>=': {
        let order: number;
        if (typeof left === 'number' && typeof right === 'number') {
          return op === '<' ? left < right : op === '<=' ? left <= right : op === '>' ? left > right : left >= right;
        } else if (typeof left === 'string' && typeof right === 'string') {
          order = compareText(left, right);
        } else {
          throw new ScriptError(line, 'runtime', L('Cannot compare a {} with a {}.', typeName(left), typeName(right)));
        }
        return op === '<' ? order < 0 : op === '<=' ? order <= 0 : op === '>' ? order > 0 : order >= 0;
      }
    }
  }

  // MARK: Checks

  number(value: ScriptValue, what: string, line: number): number {
    if (typeof value === 'number') return value;
    throw new ScriptError(line, 'runtime',
      L('“{}” needs a number here, not {}.', what, value === null ? 'nil' : displayText(value)));
  }

  text(value: string, line: number): string {
    if (value.length > this.limits.maximumTextLength && characterCount(value) > this.limits.maximumTextLength) {
      throw new ScriptError(line, 'limit', L('That text is too long.'));
    }
    return value;
  }

  checkSize(count: number, line: number): void {
    if (count > this.limits.maximumCollectionSize) {
      throw new ScriptError(line, 'limit',
        L('That list or map is too big (the limit is {}).', this.limits.maximumCollectionSize));
    }
  }

  private listOffset(position: number, count: number, line: number): number {
    if (!Number.isInteger(position) || position < 1 || position > count) {
      throw new ScriptError(line, 'runtime',
        L('There is no item {} — the list has {}. Use append() to add one.', formatNumber(position), count));
    }
    return position - 1;
  }

  // MARK: Helpful errors

  private undefinedMessage(name: string, scope: ScriptScope, assigning: boolean): string {
    const suggestion = this.closestName(name, scope);
    if (suggestion !== null) return L('“{}” is not defined. Did you mean “{}”?', name, suggestion);
    if (assigning) return L('“{}” is not defined. Use “let {} = …” to make it first.', name, name);
    return L('“{}” is not defined.', name);
  }

  /** The nearest known name within two edits: `scroe` for `score`. */
  private closestName(name: string, scope: ScriptScope): string | null {
    const candidates = new Set(this.builtinNames);
    for (let s: ScriptScope | null = scope; s; s = s.parent) for (const key of s.values.keys()) candidates.add(key);
    const wanted = name.toLowerCase();
    const ceiling = Math.max(characterCount(name), 2);
    let best: { name: string; distance: number } | null = null;
    for (const candidate of [...candidates].sort(compareText)) {
      const distance = editDistance(wanted, candidate.toLowerCase());
      if (distance > 2 || distance >= ceiling) continue;
      if (best === null || distance < best.distance) best = { name: candidate, distance };
    }
    return best?.name ?? null;
  }
}

export function editDistance(a: string, b: string): number {
  const x = characters(a), y = characters(b);
  if (x.length === 0) return y.length;
  if (y.length === 0) return x.length;
  let previous = Array.from({ length: y.length + 1 }, (_, i) => i);
  for (let i = 1; i <= x.length; i++) {
    const current = [i, ...new Array<number>(y.length).fill(0)];
    for (let j = 1; j <= y.length; j++) {
      current[j] = Math.min(previous[j] + 1, current[j - 1] + 1, previous[j - 1] + (x[i - 1] === y[j - 1] ? 0 : 1));
    }
    previous = current;
  }
  return previous[y.length];
}
