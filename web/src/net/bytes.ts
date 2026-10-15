// Little byte helpers for the wire format and TLS.

export function concat(...parts: Uint8Array[]): Uint8Array {
  let length = 0;
  for (const p of parts) length += p.length;
  const out = new Uint8Array(length);
  let offset = 0;
  for (const p of parts) {
    out.set(p, offset);
    offset += p.length;
  }
  return out;
}

export function u8(n: number): Uint8Array { return Uint8Array.of(n & 0xff); }
export function u16(n: number): Uint8Array { return Uint8Array.of((n >>> 8) & 0xff, n & 0xff); }
export function u24(n: number): Uint8Array { return Uint8Array.of((n >>> 16) & 0xff, (n >>> 8) & 0xff, n & 0xff); }
export function u32(n: number): Uint8Array {
  return Uint8Array.of((n >>> 24) & 0xff, (n >>> 16) & 0xff, (n >>> 8) & 0xff, n & 0xff);
}

/** A vector with a length prefix of `size` bytes, as TLS writes them. */
export function vector(size: 1 | 2 | 3, body: Uint8Array): Uint8Array {
  const prefix = size === 1 ? u8(body.length) : size === 2 ? u16(body.length) : u24(body.length);
  return concat(prefix, body);
}

export function equalBytes(a: Uint8Array, b: Uint8Array): boolean {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a[i] ^ b[i];
  return diff === 0;
}

export function utf8(text: string): Uint8Array { return new TextEncoder().encode(text); }
export function fromUtf8(bytes: Uint8Array): string { return new TextDecoder().decode(bytes); }

export function hex(bytes: Uint8Array): string {
  return Array.from(bytes, (b) => b.toString(16).padStart(2, '0')).join('');
}

export function fromHex(text: string): Uint8Array {
  const out = new Uint8Array(text.length / 2);
  for (let i = 0; i < out.length; i++) out[i] = parseInt(text.slice(i * 2, i * 2 + 2), 16);
  return out;
}

export function randomBytes(n: number): Uint8Array {
  const out = new Uint8Array(n);
  crypto.getRandomValues(out);
  return out;
}

export function toBase64(bytes: Uint8Array): string {
  let text = '';
  const chunk = 0x8000;
  for (let i = 0; i < bytes.length; i += chunk) text += String.fromCharCode(...bytes.subarray(i, i + chunk));
  return btoa(text);
}

export function fromBase64(text: string): Uint8Array | null {
  try {
    const raw = atob(text);
    const out = new Uint8Array(raw.length);
    for (let i = 0; i < raw.length; i++) out[i] = raw.charCodeAt(i);
    return out;
  } catch {
    return null;
  }
}

/** Reads a byte string from the front. Throws on running out, which callers treat as a bad message. */
export class Reader {
  offset = 0;
  constructor(readonly bytes: Uint8Array) {}

  get remaining(): number { return this.bytes.length - this.offset; }
  get done(): boolean { return this.offset >= this.bytes.length; }

  private need(n: number): void {
    if (this.offset + n > this.bytes.length) throw new Error('short message');
  }
  u8(): number { this.need(1); return this.bytes[this.offset++]; }
  u16(): number { this.need(2); const v = (this.bytes[this.offset] << 8) | this.bytes[this.offset + 1]; this.offset += 2; return v; }
  u24(): number {
    this.need(3);
    const b = this.bytes, o = this.offset;
    this.offset += 3;
    return (b[o] << 16) | (b[o + 1] << 8) | b[o + 2];
  }
  u32(): number {
    this.need(4);
    const b = this.bytes, o = this.offset;
    this.offset += 4;
    return ((b[o] << 24) >>> 0) + ((b[o + 1] << 16) | (b[o + 2] << 8) | b[o + 3]);
  }
  take(n: number): Uint8Array { this.need(n); const v = this.bytes.subarray(this.offset, this.offset + n); this.offset += n; return v; }
  vector(size: 1 | 2 | 3): Uint8Array {
    const n = size === 1 ? this.u8() : size === 2 ? this.u16() : this.u24();
    return this.take(n);
  }
}
