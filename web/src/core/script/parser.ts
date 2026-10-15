// AbloxScript's parser, ported from AbloxCore/ScriptParser.swift.
// Recursive descent with precedence climbing; a missing `end` names the
// statement that opened the block and its line.
import { L } from '../../i18n';
import { tokenize, ScriptError, ScriptLocation, type Token, type Keyword, type Sym } from './lexer';
import type { Expr, Stmt, Program, Handler, Branch, BinaryOp } from './ast';

export const maximumNesting = 64;

export function parse(source: string, file?: number): Program {
  const parser = new Parser(tokenize(source, file));
  const statements = parser.block([], undefined);
  const handlers = new Map<string, Handler[]>();
  for (const s of statements) {
    if (s.k !== 'handler') continue;
    const existing = handlers.get(s.event)?.[0];
    if (existing) {
      throw new ScriptError(s.line, 'syntax',
        L('There is already an “on {}” on line {}. Put both parts in one.', s.event, ScriptLocation.line(existing.line)));
    }
    handlers.set(s.event, [{ event: s.event, params: s.params, body: s.body, line: s.line }]);
  }
  return { statements, handlers };
}

class Parser {
  private position = 0;
  private depth = 0;
  constructor(private tokens: Token[]) {}

  private get current(): Token { return this.tokens[this.position]; }
  private get line(): number { return this.current.line; }

  private advance(): Token {
    const t = this.tokens[this.position];
    if (this.position < this.tokens.length - 1) this.position += 1;
    return t;
  }
  private checkK(k: Keyword): boolean { const c = this.current.kind; return c.t === 'keyword' && c.v === k; }
  private checkS(s: Sym): boolean { const c = this.current.kind; return c.t === 'symbol' && c.v === s; }
  private matchK(k: Keyword): boolean { if (!this.checkK(k)) return false; this.advance(); return true; }
  private matchS(s: Sym): boolean { if (!this.checkS(s)) return false; this.advance(); return true; }
  private expectK(k: Keyword, message: () => string): void {
    if (!this.matchK(k)) throw new ScriptError(this.line, 'syntax', message());
  }
  private expectS(s: Sym, message: () => string): void {
    if (!this.matchS(s)) throw new ScriptError(this.line, 'syntax', message());
  }
  private expectAfterCondition(k: Keyword, message: () => string): void {
    if (this.checkS('=')) throw new ScriptError(this.line, 'syntax', L('To compare two things, use “==”, not “=”.'));
    this.expectK(k, message);
  }
  private identifier(message: () => string): string {
    const c = this.current.kind;
    if (c.t === 'identifier') { this.advance(); return c.v; }
    if (c.t === 'keyword') {
      throw new ScriptError(this.line, 'syntax', L('“{}” is a reserved word and cannot be used as a name.', c.v));
    }
    throw new ScriptError(this.line, 'syntax', message());
  }
  private nested<T>(body: () => T): T {
    this.depth += 1;
    try {
      if (this.depth > maximumNesting) throw new ScriptError(this.line, 'limit', L('This is nested too deeply.'));
      return body();
    } finally {
      this.depth -= 1;
    }
  }

  block(terminators: Keyword[], opener: { word: string; line: number } | undefined): Stmt[] {
    const statements: Stmt[] = [];
    for (;;) {
      if (this.current.kind.t === 'end') {
        if (opener) {
          throw new ScriptError(opener.line, 'syntax', L('The “{}” on this line is never closed with “end”.', opener.word));
        }
        return statements;
      }
      if (terminators.some((t) => this.checkK(t))) return statements;
      statements.push(this.statement());
    }
  }

  private statement(): Stmt {
    const startLine = this.line;
    return this.nested(() => {
      if (this.matchK('let')) return this.declaration(startLine);
      if (this.matchK('if')) return this.ifStatement(startLine);
      if (this.matchK('while')) return this.whileStatement(startLine);
      if (this.matchK('for')) return this.forStatement(startLine);
      if (this.matchK('func')) return this.functionStatement(startLine);
      if (this.matchK('on')) return this.handlerStatement(startLine);
      if (this.matchK('return')) return this.returnStatement(startLine);
      if (this.matchK('break')) return { k: 'break', line: startLine };
      if (this.matchK('continue')) return { k: 'continue', line: startLine };
      for (const word of ['end', 'else', 'elif', 'then', 'do'] as Keyword[]) {
        if (this.checkK(word)) {
          throw new ScriptError(startLine, 'syntax', L('There is an extra “{}” here, or something above it is missing.', word));
        }
      }
      return this.expressionOrAssignment(startLine);
    });
  }

  private declaration(line: number): Stmt {
    const name = this.identifier(() => L('“let” needs a name after it.'));
    const value = this.matchS('=') ? this.expression() : undefined;
    return { k: 'declare', name, value, line };
  }

  private ifStatement(line: number): Stmt {
    const branches: Branch[] = [];
    let otherwise: Stmt[] | undefined;
    let condition = this.expression();
    this.expectAfterCondition('then', () => L('“if” needs “then” after its condition.'));
    let body = this.block(['elif', 'else', 'end'], { word: 'if', line });
    branches.push({ condition, body });
    while (this.matchK('elif')) {
      const elifLine = this.line;
      condition = this.expression();
      this.expectAfterCondition('then', () => L('“elif” needs “then” after its condition.'));
      body = this.block(['elif', 'else', 'end'], { word: 'elif', line: elifLine });
      branches.push({ condition, body });
    }
    if (this.matchK('else')) otherwise = this.block(['end'], { word: 'else', line: this.line });
    this.expectK('end', () => L('The “if” on line {} is never closed with “end”.', ScriptLocation.line(line)));
    return { k: 'if', branches, otherwise, line };
  }

  private whileStatement(line: number): Stmt {
    const condition = this.expression();
    this.expectAfterCondition('do', () => L('“while” needs “do” after its condition.'));
    const body = this.block(['end'], { word: 'while', line });
    this.expectK('end', () => L('The “while” on line {} is never closed with “end”.', ScriptLocation.line(line)));
    return { k: 'while', condition, body, line };
  }

  private forStatement(line: number): Stmt {
    const variable = this.identifier(() => L('“for” needs a name, as in “for i in 1 to 10 do”.'));
    this.expectK('in', () => L('“for” needs “in”, as in “for i in 1 to 10 do”.'));
    const first = this.expression();
    if (this.matchK('to')) {
      const last = this.expression();
      const step = this.matchK('step') ? this.expression() : undefined;
      this.expectK('do', () => L('“for” needs “do” before its body.'));
      const body = this.block(['end'], { word: 'for', line });
      this.expectK('end', () => L('The “for” on line {} is never closed with “end”.', ScriptLocation.line(line)));
      return { k: 'forRange', variable, from: first, to: last, step, body, line };
    }
    this.expectK('do', () => L('“for” needs “do” before its body.'));
    const body = this.block(['end'], { word: 'for', line });
    this.expectK('end', () => L('The “for” on line {} is never closed with “end”.', ScriptLocation.line(line)));
    return { k: 'forEach', variable, sequence: first, body, line };
  }

  private parameters(): string[] {
    this.expectS('(', () => L('A function needs “(” after its name, even with nothing inside.'));
    const names: string[] = [];
    if (!this.checkS(')')) {
      do {
        const name = this.identifier(() => L('Expected a parameter name.'));
        if (names.includes(name)) throw new ScriptError(this.line, 'syntax', L('“{}” is listed twice.', name));
        names.push(name);
      } while (this.matchS(','));
    }
    this.expectS(')', () => L('Expected “)” after the parameters.'));
    return names;
  }

  private functionStatement(line: number): Stmt {
    const name = this.identifier(() => L('“func” needs a name after it.'));
    const params = this.parameters();
    const body = this.block(['end'], { word: 'func', line });
    this.expectK('end', () => L('The “func” on line {} is never closed with “end”.', ScriptLocation.line(line)));
    return { k: 'function', name, params, body, line };
  }

  private handlerStatement(line: number): Stmt {
    if (this.depth !== 1) throw new ScriptError(line, 'syntax', L('“on” can only be used at the top of a script.'));
    const event = this.identifier(() => L('“on” needs an event name, as in “on start()”.'));
    const params = this.parameters();
    const body = this.block(['end'], { word: 'on', line });
    this.expectK('end', () => L('The “on” on line {} is never closed with “end”.', ScriptLocation.line(line)));
    return { k: 'handler', event, params, body, line };
  }

  private returnStatement(line: number): Stmt {
    const endsHere = this.checkK('end') || this.checkK('else') || this.checkK('elif') || this.current.kind.t === 'end';
    return { k: 'return', value: endsHere ? undefined : this.expression(), line };
  }

  private expressionOrAssignment(line: number): Stmt {
    const target = this.expression();
    if (this.matchS('=')) {
      if (target.k === 'variable' || target.k === 'member' || target.k === 'index') {
        return { k: 'assign', target, value: this.expression(), line };
      }
      throw new ScriptError(line, 'syntax', L('The left side of “=” has to be a name.'));
    }
    if (target.k !== 'call') {
      throw new ScriptError(line, 'syntax', L('This line does nothing. Did you mean to use “=” or call something?'));
    }
    return { k: 'expression', expr: target, line };
  }

  // Expressions

  expression(): Expr { return this.nested(() => this.or()); }

  private or(): Expr {
    let left = this.and();
    while (this.checkK('or')) {
      const at = this.line; this.advance();
      left = { k: 'logical', isAnd: false, left, right: this.and(), line: at };
    }
    return left;
  }
  private and(): Expr {
    let left = this.not();
    while (this.checkK('and')) {
      const at = this.line; this.advance();
      left = { k: 'logical', isAnd: true, left, right: this.not(), line: at };
    }
    return left;
  }
  private not(): Expr {
    if (this.checkK('not')) {
      const at = this.line; this.advance();
      return { k: 'unary', op: 'not', operand: this.nested(() => this.not()), line: at };
    }
    return this.comparison();
  }
  private comparison(): Expr {
    let left = this.concatenation();
    const ops: BinaryOp[] = ['==', '!=', '<=', '>=', '<', '>'];
    for (;;) {
      const op = ops.find((o) => this.checkS(o as Sym));
      if (!op) return left;
      const at = this.line; this.advance();
      left = { k: 'binary', op, left, right: this.concatenation(), line: at };
    }
  }
  private concatenation(): Expr {
    const left = this.additive();
    if (this.checkS('..')) {
      const at = this.line; this.advance();
      return { k: 'binary', op: '..', left, right: this.nested(() => this.concatenation()), line: at };
    }
    return left;
  }
  private additive(): Expr {
    let left = this.multiplicative();
    while (this.checkS('+') || this.checkS('-')) {
      const op: BinaryOp = this.checkS('+') ? '+' : '-';
      const at = this.line; this.advance();
      left = { k: 'binary', op, left, right: this.multiplicative(), line: at };
    }
    return left;
  }
  private multiplicative(): Expr {
    let left = this.unary();
    while (this.checkS('*') || this.checkS('/') || this.checkS('%')) {
      const op: BinaryOp = this.checkS('*') ? '*' : this.checkS('/') ? '/' : '%';
      const at = this.line; this.advance();
      left = { k: 'binary', op, left, right: this.unary(), line: at };
    }
    return left;
  }
  private unary(): Expr {
    if (this.checkS('-')) {
      const at = this.line; this.advance();
      return { k: 'unary', op: '-', operand: this.nested(() => this.unary()), line: at };
    }
    return this.postfix();
  }
  private postfix(): Expr {
    let expr = this.primary();
    for (;;) {
      const at = this.line;
      if (this.matchS('(')) {
        const args: Expr[] = [];
        if (!this.checkS(')')) {
          do { args.push(this.expression()); } while (this.matchS(','));
        }
        this.expectS(')', () => L('Expected “)” to close the call.'));
        expr = { k: 'call', callee: expr, args, line: at };
      } else if (this.matchS('.')) {
        const name = this.identifier(() => L('Expected a name after “.”.'));
        expr = { k: 'member', object: expr, name, line: at };
      } else if (this.matchS('[')) {
        const index = this.expression();
        this.expectS(']', () => L('Expected “]”.'));
        expr = { k: 'index', object: expr, index, line: at };
      } else {
        return expr;
      }
    }
  }
  private primary(): Expr {
    const at = this.line;
    const token = this.advance();
    const t = token.kind;
    switch (t.t) {
      case 'number': return { k: 'number', v: t.v, line: at };
      case 'string': return { k: 'string', v: t.v, line: at };
      case 'identifier': return { k: 'variable', name: t.v, line: at };
      case 'end': throw new ScriptError(at, 'syntax', L('The script ends in the middle of something.'));
      case 'keyword':
        if (t.v === 'true') return { k: 'bool', v: true, line: at };
        if (t.v === 'false') return { k: 'bool', v: false, line: at };
        if (t.v === 'nil') return { k: 'null', line: at };
        if (t.v === 'func') {
          const params = this.parameters();
          const body = this.block(['end'], { word: 'func', line: at });
          this.expectK('end', () => L('The “func” on line {} is never closed with “end”.', ScriptLocation.line(at)));
          return { k: 'function', params, body, line: at };
        }
        throw new ScriptError(at, 'syntax', L('“{}” cannot be used here.', t.v));
      case 'symbol':
        if (t.v === '(') {
          const inner = this.expression();
          this.expectS(')', () => L('Expected “)”.'));
          return inner;
        }
        if (t.v === '[') {
          const items: Expr[] = [];
          if (!this.checkS(']')) {
            do {
              if (this.checkS(']')) break;
              items.push(this.expression());
            } while (this.matchS(','));
          }
          this.expectS(']', () => L('Expected “]” to close the list.'));
          return { k: 'list', items, line: at };
        }
        if (t.v === '{') {
          const entries: { key: string; value: Expr }[] = [];
          if (!this.checkS('}')) {
            do {
              if (this.checkS('}')) break;
              let key: string;
              const c = this.current.kind;
              if (c.t === 'string') { this.advance(); key = c.v; } else key = this.identifier(() => L('Expected a name inside “{ }”.'));
              this.expectS(':', () => L('Expected “:” after “{}”.', key));
              entries.push({ key, value: this.expression() });
            } while (this.matchS(','));
          }
          this.expectS('}', () => L('Expected “}” to close the map.'));
          return { k: 'map', entries, line: at };
        }
        if (t.v === '=') throw new ScriptError(at, 'syntax', L('To compare two things, use “==”, not “=”.'));
        throw new ScriptError(at, 'syntax', L('“{}” cannot be used here.', t.v));
    }
  }
}
