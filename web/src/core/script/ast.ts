// AbloxScript's syntax tree, as in AbloxCore/ScriptAST.swift.

export type UnaryOp = '-' | 'not';
export type BinaryOp = '+' | '-' | '*' | '/' | '%' | '..' | '==' | '!=' | '<' | '<=' | '>' | '>=';

export type Expr =
  | { k: 'number'; v: number; line: number }
  | { k: 'string'; v: string; line: number }
  | { k: 'bool'; v: boolean; line: number }
  | { k: 'null'; line: number }
  | { k: 'list'; items: Expr[]; line: number }
  | { k: 'map'; entries: { key: string; value: Expr }[]; line: number }
  | { k: 'variable'; name: string; line: number }
  | { k: 'unary'; op: UnaryOp; operand: Expr; line: number }
  | { k: 'binary'; op: BinaryOp; left: Expr; right: Expr; line: number }
  | { k: 'logical'; isAnd: boolean; left: Expr; right: Expr; line: number }
  | { k: 'call'; callee: Expr; args: Expr[]; line: number }
  | { k: 'member'; object: Expr; name: string; line: number }
  | { k: 'index'; object: Expr; index: Expr; line: number }
  | { k: 'function'; params: string[]; body: Stmt[]; line: number };

export interface Branch { condition: Expr; body: Stmt[] }

export type Stmt =
  | { k: 'declare'; name: string; value?: Expr; line: number }
  | { k: 'assign'; target: Expr; value: Expr; line: number }
  | { k: 'expression'; expr: Expr; line: number }
  | { k: 'if'; branches: Branch[]; otherwise?: Stmt[]; line: number }
  | { k: 'while'; condition: Expr; body: Stmt[]; line: number }
  | { k: 'forRange'; variable: string; from: Expr; to: Expr; step?: Expr; body: Stmt[]; line: number }
  | { k: 'forEach'; variable: string; sequence: Expr; body: Stmt[]; line: number }
  | { k: 'function'; name: string; params: string[]; body: Stmt[]; line: number }
  | { k: 'handler'; event: string; params: string[]; body: Stmt[]; line: number }
  | { k: 'return'; value?: Expr; line: number }
  | { k: 'break'; line: number }
  | { k: 'continue'; line: number };

export interface Handler { event: string; params: string[]; body: Stmt[]; line: number }

export interface Program {
  statements: Stmt[];
  /** Event name → handlers, in file order. */
  handlers: Map<string, Handler[]>;
}

/** Several files as one program: top levels in order, handlers merged. */
export function combinePrograms(programs: Program[]): Program {
  const handlers = new Map<string, Handler[]>();
  for (const p of programs) {
    for (const [event, list] of p.handlers) {
      const existing = handlers.get(event) ?? [];
      existing.push(...list);
      handlers.set(event, existing);
    }
  }
  return { statements: programs.flatMap((p) => p.statements), handlers };
}
