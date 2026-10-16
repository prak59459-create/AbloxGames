// Settings → Family on this browser (FamilySafety.swift's passcode): what a
// grown-up decides is kept behind a family passcode when one is set, and
// behind a grown-up's question when it is not — a child can open Settings,
// but switching internet rooms on takes someone who knows their times
// tables, or the passcode.
import { hex, utf8 } from '../net/bytes';

function storage(): Storage | null {
  try { return typeof localStorage === 'undefined' ? null : localStorage; } catch { return null; }
}

interface Stored { hash: string; salt: string; hint?: string }

async function digest(code: string, salt: string): Promise<string> {
  return hex(new Uint8Array(await crypto.subtle.digest('SHA-256', utf8(salt + ':' + code) as BufferSource)));
}

export class FamilyLock {
  private stored: Stored | null;

  constructor(private readonly store: Storage | null = storage(), private readonly key = 'ablox.family.lock') {
    try { this.stored = JSON.parse(store?.getItem(key) ?? 'null') as Stored | null; } catch { this.stored = null; }
    if (this.stored && (typeof this.stored.hash !== 'string' || typeof this.stored.salt !== 'string')) this.stored = null;
  }

  get isLocked(): boolean { return this.stored !== null; }
  get hint(): string | null { return this.stored?.hint ?? null; }

  /** Four to eight digits. */
  static isValid(code: string): boolean { return /^[0-9]{4,8}$/.test(code); }

  async accepts(code: string): Promise<boolean> {
    if (!this.stored) return true;
    return (await digest(code, this.stored.salt)) === this.stored.hash;
  }

  /** Sets the passcode, or with null takes it away. */
  async set(code: string | null, hint?: string): Promise<void> {
    if (code === null) {
      this.stored = null;
      try { this.store?.removeItem(this.key); } catch { /* not kept */ }
      return;
    }
    if (!FamilyLock.isValid(code)) throw new Error('A passcode is four to eight digits.');
    const salt = crypto.randomUUID();
    this.stored = { hash: await digest(code, salt), salt, ...(hint ? { hint: hint.slice(0, 40) } : {}) };
    try { this.store?.setItem(this.key, JSON.stringify(this.stored)); } catch { /* not kept */ }
  }
}

/** A question a grown-up answers without thinking and a young child cannot: two numbers from 6 to 9, multiplied. */
export function grownUpQuestion(random: () => number = Math.random): { a: number; b: number; answer: number } {
  const a = 6 + Math.floor(random() * 4), b = 6 + Math.floor(random() * 4);
  return { a, b, answer: a * b };
}
