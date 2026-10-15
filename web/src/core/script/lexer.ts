// AbloxScript's lexer, ported from AbloxCore/ScriptLexer.swift.
//
// Lua-like: `if … then … end`, `for i in 1 to 10 do`, `on hit(a, b) … end`.
// Full-width letters, digits and symbols typed on a Japanese keyboard are read
// as their plain versions, and curly quotes close strings, as on the iPad.
import { L } from '../../i18n';

export const KEYWORDS = [
  'let', 'if', 'then', 'elif', 'else', 'end', 'while', 'do', 'for', 'in', 'to', 'step',
  'func', 'return', 'on', 'and', 'or', 'not', 'true', 'false', 'nil', 'break', 'continue',
] as const;
export type Keyword = (typeof KEYWORDS)[number];
const keywordSet = new Set<string>(KEYWORDS);

export const SYMBOLS = [
  '==', '!=', '<=', '>=', '..',
  '+', '-', '*', '/', '%', '<', '>', '=',
  '(', ')', '[', ']', '{', '}', ',', '.', ':',
] as const;
export type Sym = (typeof SYMBOLS)[number];
const symbolSet = new Set<string>(SYMBOLS);

export type TokenKind =
  | { t: 'identifier'; v: string }
  | { t: 'number'; v: number }
  | { t: 'string'; v: string }
  | { t: 'keyword'; v: Keyword }
  | { t: 'symbol'; v: Sym }
  | { t: 'end' };

export interface Token { kind: TokenKind; line: number }

export type ScriptErrorKind = 'syntax' | 'runtime' | 'limit';

/** Something wrong with a script, and where (`line` may be packed — see ScriptLocation). */
export class ScriptError extends Error {
  constructor(public line: number, public kind: ScriptErrorKind, message: string, public file?: string) {
    super(message);
  }
  get description(): string {
    return this.file ? L('{}, line {}: {}', this.file, this.line, this.message) : L('Line {}: {}', this.line, this.message);
  }
  resolved(files: string[]): ScriptError {
    const index = ScriptLocation.file(this.line);
    if (this.file !== undefined || index === undefined || index >= files.length) return this;
    return new ScriptError(ScriptLocation.line(this.line), this.kind, this.message, files[index]);
  }
}

/** A file index packed into the high bits of a line number. */
export const ScriptLocation = {
  shift: 20,
  mask: (1 << 20) - 1,
  pack(line: number, file?: number): number {
    return file === undefined ? line : ((file + 1) * (1 << 20)) + (line & this.mask);
  },
  line(packed: number): number { return packed & this.mask; },
  file(packed: number): number | undefined {
    const index = Math.floor(packed / (1 << 20));
    return index === 0 ? undefined : index - 1;
  },
};

export const maximumSourceLength = 1_000_000;

/** The plain ASCII version of a full-width character. */
export function plain(ch: string): string {
  const c = ch.codePointAt(0)!;
  if (ch.length <= 2 && c >= 0xff01 && c <= 0xff5e) return String.fromCodePoint(c - 0xfee0);
  if (c === 0x3000) return ' ';
  return ch;
}

const isLetter = (c: string) => /\p{L}/u.test(c);
const isNumberChar = (c: string) => /\p{N}/u.test(c);
const isAsciiDigit = (c: string) => c >= '0' && c <= '9';
const isWhitespace = (c: string) => /\s/u.test(c);

function closingQuotes(ch: string): string[] | null {
  switch (ch) {
    case '"': case '“': case '”': case '„': return ['"', '“', '”', '＂'];
    case "'": case '‘': case '’': return ["'", '‘', '’'];
    default: return null;
  }
}

export function tokenize(source: string, file?: number): Token[] {
  const chars = Array.from(source);
  if (chars.length > maximumSourceLength) {
    throw new ScriptError(ScriptLocation.pack(1, file), 'syntax', L('The script is too long.'));
  }
  const tokens: Token[] = [];
  let index = 0;
  let line = ScriptLocation.pack(1, file);
  const peek = (o = 0): string | undefined => chars[index + o];
  const peekPlain = (o = 0): string | undefined => { const c = peek(o); return c === undefined ? undefined : plain(c); };

  for (;;) {
    const ch = peekPlain();
    if (ch === undefined) break;
    if (ch === '\n') { line += 1; index += 1; continue; }
    if (isWhitespace(ch)) { index += 1; continue; }
    if (ch === '#' || (ch === '-' && peek(1) === '-')) {
      while (peek() !== undefined && peek() !== '\n') index += 1;
      continue;
    }
    if (isAsciiDigit(ch)) {
      const start = index;
      while (peekPlain() !== undefined && isAsciiDigit(peekPlain()!)) index += 1;
      if (peekPlain() === '.' && peekPlain(1) !== undefined && isAsciiDigit(peekPlain(1)!)) {
        index += 1;
        while (peekPlain() !== undefined && isAsciiDigit(peekPlain()!)) index += 1;
      }
      const text = chars.slice(start, index).map(plain).join('');
      const value = Number(text);
      if (!Number.isFinite(value)) throw new ScriptError(line, 'syntax', L('“{}” is not a number.', text));
      tokens.push({ kind: { t: 'number', v: value }, line });
      continue;
    }
    if (isLetter(ch) || ch === '_') {
      const start = index;
      while (peekPlain() !== undefined && (isLetter(peekPlain()!) || isNumberChar(peekPlain()!) || peekPlain() === '_')) index += 1;
      const word = chars.slice(start, index).map(plain).join('');
      tokens.push({ kind: keywordSet.has(word) ? { t: 'keyword', v: word as Keyword } : { t: 'identifier', v: word }, line });
      continue;
    }
    const closers = closingQuotes(ch);
    if (closers) {
      const startLine = line;
      index += 1;
      let value = '';
      let closed = false;
      for (;;) {
        const next = peek();
        if (next === undefined || next === '\n') break;
        if (closers.includes(next)) { index += 1; closed = true; break; }
        if (next === '\\') {
          index += 1;
          const e = peek();
          switch (e) {
            case 'n': value += '\n'; break;
            case 't': value += '\t'; break;
            case '\\': value += '\\'; break;
            case '"': value += '"'; break;
            case "'": value += "'"; break;
            case undefined: break;
            default: value += '\\' + e;
          }
          index += 1;
          continue;
        }
        value += next;
        index += 1;
      }
      if (!closed) throw new ScriptError(startLine, 'syntax', L('A text value was never closed with a quote.'));
      tokens.push({ kind: { t: 'string', v: value }, line });
      continue;
    }
    const next = peekPlain(1);
    if (next !== undefined && symbolSet.has(ch + next)) {
      tokens.push({ kind: { t: 'symbol', v: (ch + next) as Sym }, line });
      index += 2;
      continue;
    }
    if (symbolSet.has(ch)) {
      tokens.push({ kind: { t: 'symbol', v: ch as Sym }, line });
      index += 1;
      continue;
    }
    throw new ScriptError(line, 'syntax', L('“{}” cannot be used here.', ch));
  }
  tokens.push({ kind: { t: 'end' }, line });
  return tokens;
}
