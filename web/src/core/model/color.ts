// Colours, as AbloxCore/ColorRGBA.swift keeps them: four numbers from 0 to 1,
// stored as Float there — so the arithmetic here rounds to 32 bits where the
// Swift does, and a colour comes out as the same hex on both.

export interface ColorRGBA { r: number; g: number; b: number; a: number }

const f = Math.fround;

export function rgba(r: number, g: number, b: number, a = 1): ColorRGBA {
  return { r: f(r), g: f(g), b: f(b), a: f(a) };
}

/** `#RGB`, `#RGBA`, `#RRGGBB` or `#RRGGBBAA`, the `#` optional; null otherwise. */
export function colorFromHex(hex: string): ColorRGBA | null {
  let s = hex.trim();
  if (s.startsWith('#')) s = s.slice(1);
  if (!/^[0-9a-fA-F]*$/.test(s)) return null;
  if (s.length === 3 || s.length === 4) {
    const v = [...s].map((c) => parseInt(c, 16) / 15);
    return rgba(v[0], v[1], v[2], s.length === 4 ? v[3] : 1);
  }
  if (s.length === 6 || s.length === 8) {
    const v: number[] = [];
    for (let i = 0; i < s.length; i += 2) v.push(parseInt(s.slice(i, i + 2), 16) / 255);
    return rgba(v[0], v[1], v[2], v.length === 4 ? v[3] : 1);
  }
  return null;
}

function byte(value: number): number {
  const clamped = f(Math.max(0, Math.min(1, value)));
  const scaled = f(clamped * 255);
  return Math.floor(scaled + 0.5);
}

const two = (n: number) => n.toString(16).toUpperCase().padStart(2, '0');

/** Uppercase `#RRGGBB`, or `#RRGGBBAA` when the colour is see-through. */
export function hexString(c: ColorRGBA): string {
  const base = '#' + two(byte(c.r)) + two(byte(c.g)) + two(byte(c.b));
  return c.a >= f(0.999) ? base : base + two(byte(c.a));
}

export function lerpColor(from: ColorRGBA, to: ColorRGBA, t: number): ColorRGBA {
  const clamped = f(Math.max(0, Math.min(1, t)));
  const mix = (a: number, b: number) => f(a + f(f(b - a) * clamped));
  return { r: mix(from.r, to.r), g: mix(from.g, to.g), b: mix(from.b, to.b), a: mix(from.a, to.a) };
}

/** A CSS colour for the screen. */
export function cssColor(c: ColorRGBA): string {
  const ch = (v: number) => Math.round(Math.max(0, Math.min(1, v)) * 255);
  return c.a >= 0.999 ? `rgb(${ch(c.r)} ${ch(c.g)} ${ch(c.b)})` : `rgb(${ch(c.r)} ${ch(c.g)} ${ch(c.b)} / ${c.a.toFixed(3)})`;
}

/** Colours a script can name, in English and Japanese (ScriptColor in GameRuntimeAPI.swift). */
export const namedColors: Record<string, string> = {
  red: '#EF4444', orange: '#F97316', yellow: '#FACC15', green: '#22C55E',
  blue: '#3B82F6', cyan: '#22D3EE', purple: '#A855F7', pink: '#EC4899',
  white: '#FFFFFF', black: '#111111', gray: '#9CA3AF', grey: '#9CA3AF', brown: '#92400E',
  gold: '#F59E0B', clear: '#00000000',
  '赤': '#EF4444', 'オレンジ': '#F97316', '黄': '#FACC15', '黄色': '#FACC15', '緑': '#22C55E',
  '青': '#3B82F6', '水色': '#22D3EE', '紫': '#A855F7', 'ピンク': '#EC4899',
  '白': '#FFFFFF', '黒': '#111111', '灰色': '#9CA3AF', '茶色': '#92400E', '金': '#F59E0B', '透明': '#00000000',
};

export function parseScriptColor(text: string): ColorRGBA | null {
  const key = text.trim();
  const hex = namedColors[key.toLowerCase()] ?? namedColors[key];
  if (hex) return colorFromHex(hex);
  if (!key.startsWith('#')) return null;
  return colorFromHex(key);
}

export const palette: ColorRGBA[] = [
  '#FF5A5F', '#FF9F1C', '#FFD60A', '#4ADE80', '#22D3EE', '#3B82F6', '#A855F7', '#EC4899',
  '#F5F5F5', '#9CA3AF', '#4B5563', '#1F2937', '#A3E635', '#14B8A6', '#C4B5FD', '#FDBA74', '#7C4A2D',
].map((h) => colorFromHex(h)!);

export const rainbow: ColorRGBA[] = ['#EF4444', '#F97316', '#FACC15', '#4ADE80', '#22D3EE', '#3B82F6', '#A855F7']
  .map((h) => colorFromHex(h)!);

export const defaultBlockColor = colorFromHex('#9CA3AF')!;
export const defaultGroundColor = colorFromHex('#2F4F3E')!;
export const white = rgba(1, 1, 1);
export const black = rgba(0, 0, 0);
