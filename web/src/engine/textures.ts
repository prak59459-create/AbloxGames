// Pictures the engine paints for itself — Engine/SurfaceTextures.swift: the
// natural materials' patterns (grey, so the block's colour tints them), the
// sky, the colour-vision marks, and the pictures a world carries.
import * as THREE from 'three';
import type { ColorRGBA } from '../core/model/color';
import type { SkyStyle, SurfacePattern } from '../core/model/world';

/** xorshift64 from Engine/SurfaceTextures.swift, so a pattern is the same on every device. */
export class SeededRandom {
  private state: bigint;
  constructor(seed: bigint) { this.state = seed === 0n ? 0x9e3779b97f4a7c15n : BigInt.asUintN(64, seed); }
  nextUInt(): bigint {
    let s = this.state;
    s ^= BigInt.asUintN(64, s << 13n);
    s ^= s >> 7n;
    s ^= BigInt.asUintN(64, s << 17n);
    this.state = s;
    return s;
  }
  next(lo: number, hi: number): number {
    const unit = Number(this.nextUInt() >> 11n) / 9007199254740992;
    return lo + (hi - lo) * unit;
  }
}

function patternSeed(name: string): bigint {
  let seed = 7n;
  for (const ch of name) seed = BigInt.asUintN(64, seed * 31n + BigInt(ch.codePointAt(0)!));
  return seed;
}

const grey = (v: number, a = 1) => `rgba(${Math.round(v * 255)},${Math.round(v * 255)},${Math.round(v * 255)},${a})`;

function canvas(w: number, h: number): [HTMLCanvasElement | OffscreenCanvas, CanvasRenderingContext2D | OffscreenCanvasRenderingContext2D] {
  if (typeof document !== 'undefined') {
    const c = document.createElement('canvas');
    c.width = w;
    c.height = h;
    return [c, c.getContext('2d')!];
  }
  const c = new OffscreenCanvas(w, h);
  return [c, c.getContext('2d')!];
}

function drawPattern(pattern: SurfacePattern): HTMLCanvasElement | OffscreenCanvas {
  const size = 128;
  const [c, g] = canvas(size, size);
  const random = new SeededRandom(patternSeed(pattern));
  const fill = (v: number) => { g.fillStyle = grey(v); g.fillRect(0, 0, size, size); };
  switch (pattern) {
    case 'none':
      fill(1);
      break;
    case 'grain': {
      fill(0.93);
      for (let line = 0; line < 18; line++) {
        const y = line * 7.1 + random.next(0, 3);
        g.strokeStyle = grey(0.72 + random.next(0, 0.12), 0.9);
        g.lineWidth = random.next(0.8, 2.2);
        g.beginPath();
        g.moveTo(0, y);
        let x = 0;
        while (x < size) { x += 16; g.lineTo(x, y + random.next(-1.6, 1.6)); }
        g.stroke();
      }
      g.strokeStyle = grey(0.66);
      g.lineWidth = 1.5;
      g.beginPath();
      g.ellipse(87, 48, 7, 4, 0, 0, Math.PI * 2);
      g.stroke();
      break;
    }
    case 'speckle':
      fill(0.9);
      for (let i = 0; i < 420; i++) {
        const dot = random.next(1, 3.5);
        g.fillStyle = grey(random.next(0.62, 1), 0.8);
        const x = random.next(0, 128), y = random.next(0, 128);
        g.beginPath();
        g.ellipse(x + dot / 2, y + dot / 2, dot / 2, dot / 2, 0, 0, Math.PI * 2);
        g.fill();
      }
      break;
    case 'bricks': {
      fill(0.62);
      const rows = 8, h = size / rows;
      for (let row = 0; row < rows; row++) {
        let x = -32 + (row % 2 === 0 ? 0 : 16);
        while (x < size) {
          g.fillStyle = grey(0.86 + random.next(-0.06, 0.08));
          g.fillRect(x + 1.5, row * h + 1.5, 29, h - 3);
          x += 32;
        }
      }
      break;
    }
    case 'blades':
      fill(0.82);
      g.lineWidth = 1.2;
      for (let i = 0; i < 520; i++) {
        const x = random.next(0, 128), y = random.next(0, 128);
        g.strokeStyle = grey(random.next(0.7, 1), 0.9);
        g.beginPath();
        g.moveTo(x, y);
        g.lineTo(x + random.next(-2, 2), y - random.next(3, 7));
        g.stroke();
      }
      break;
    case 'cracks':
      fill(0.97);
      g.strokeStyle = grey(0.8, 0.9);
      g.lineWidth = 1;
      for (let i = 0; i < 7; i++) {
        let px = random.next(0, 128), py = random.next(0, 128);
        g.beginPath();
        g.moveTo(px, py);
        for (let j = 0; j < 5; j++) { px += random.next(-18, 18); py += random.next(-18, 18); g.lineTo(px, py); }
        g.stroke();
      }
      break;
    case 'ripples':
      fill(0.9);
      g.lineWidth = 2;
      for (let line = 0; line < 14; line++) {
        const y = line * 9.3;
        g.strokeStyle = grey(1, 0.8);
        g.beginPath();
        g.moveTo(0, y);
        for (let x = 0; x <= size; x += 4) g.lineTo(x, y + Math.sin((x / 128) * 4 * Math.PI + line) * 2.5);
        g.stroke();
      }
      break;
  }
  return c;
}

const patternCache = new Map<string, THREE.Texture>();

/** A pattern repeating `tiles` times across a face. */
export function patternTexture(pattern: SurfacePattern, tiles: number): THREE.Texture | null {
  if (pattern === 'none') return null;
  const key = pattern + ':' + tiles;
  const cached = patternCache.get(key);
  if (cached) return cached;
  const base = patternCache.get(pattern + ':base') ?? (() => {
    const t = new THREE.CanvasTexture(drawPattern(pattern) as HTMLCanvasElement);
    t.colorSpace = THREE.SRGBColorSpace;
    t.wrapS = t.wrapT = THREE.RepeatWrapping;
    t.anisotropy = 4;
    patternCache.set(pattern + ':base', t);
    return t;
  })();
  const texture = base.clone();
  texture.repeat.set(tiles, tiles);
  texture.needsUpdate = true;
  patternCache.set(key, texture);
  return texture;
}

export type MeaningMark = 'danger' | 'goal';

export function markTexture(mark: MeaningMark, tiles: number): THREE.Texture {
  const key = 'mark:' + mark + ':' + tiles;
  const cached = patternCache.get(key);
  if (cached) return cached;
  const size = 128;
  const [c, g] = canvas(size, size);
  g.fillStyle = '#fff';
  g.fillRect(0, 0, size, size);
  g.fillStyle = grey(0.12);
  if (mark === 'danger') {
    g.beginPath();
    for (let start = -size; start < size * 2; start += size / 2) {
      g.moveTo(start, 0);
      g.lineTo(start + size / 4, 0);
      g.lineTo(start + size / 4 - size, size);
      g.lineTo(start - size, size);
      g.closePath();
    }
    g.fill();
  } else {
    const cell = size / 4;
    for (let row = 0; row < 4; row++) for (let col = 0; col < 4; col++) if ((row + col) % 2 === 0) g.fillRect(col * cell, row * cell, cell, cell);
  }
  const t = new THREE.CanvasTexture(c as HTMLCanvasElement);
  t.colorSpace = THREE.SRGBColorSpace;
  t.wrapS = t.wrapT = THREE.RepeatWrapping;
  t.repeat.set(tiles, tiles);
  patternCache.set(key, t);
  return t;
}

// MARK: - The sky

const css = (c: ColorRGBA) => `rgb(${Math.round(c.r * 255)},${Math.round(c.g * 255)},${Math.round(c.b * 255)})`;

/** The inside of the sky: the top of the picture straight up, the middle the horizon. */
export function drawSky(style: SkyStyle, top: ColorRGBA, bottom: ColorRGBA, night: number): HTMLCanvasElement | OffscreenCanvas {
  const width = 512, height = 256, horizon = height / 2;
  const [c, g] = canvas(width, height);
  const random = new SeededRandom(42n);
  const gradient = g.createLinearGradient(0, 0, 0, height);
  gradient.addColorStop(0, css(top));
  gradient.addColorStop(0.5, css(bottom));
  gradient.addColorStop(1, css(bottom));
  g.fillStyle = gradient;
  g.fillRect(0, 0, width, height);

  const stars = style === 'space' ? 1 : style === 'stars' ? Math.max(0.55, night) : night;
  if (stars > 0.05) {
    const count = style === 'space' ? 900 : 420;
    const biggest = style === 'space' ? 2.6 : 1.9;
    for (let i = 0; i < count; i++) {
      const s = random.next(0.6, biggest);
      const y = random.next(0, horizon * 0.96);
      const x = random.next(0, width);
      const b = random.next(0.35, 1);
      g.fillStyle = `rgba(255,255,255,${stars * b})`;
      g.beginPath();
      g.ellipse(x + s / 2, y + s / 2, s / 2, s / 2, 0, 0, Math.PI * 2);
      g.fill();
    }
  }
  switch (style) {
    case 'clouds': {
      const alpha = 0.55 * (1 - night * 0.6);
      g.fillStyle = `rgba(255,255,255,${alpha})`;
      for (let i = 0; i < 26; i++) {
        const x = random.next(0, width), y = random.next(horizon * 0.35, horizon * 0.92), w = random.next(40, 110);
        for (let puff = 0; puff < 4; puff++) {
          const along = x + puff * w * 0.22, lift = (puff % 2) * 5;
          g.beginPath();
          g.ellipse(along + w * 0.25, y - lift + w * 0.09, w * 0.25, w * 0.09, 0, 0, Math.PI * 2);
          g.fill();
        }
      }
      break;
    }
    case 'sunset': {
      const warm = g.createLinearGradient(0, horizon * 0.45, 0, horizon);
      warm.addColorStop(0, 'rgba(255,140,64,0)');
      warm.addColorStop(0.7, 'rgba(255,128,77,0.75)');
      warm.addColorStop(1, 'rgba(255,209,115,0.9)');
      g.fillStyle = warm;
      g.fillRect(0, horizon * 0.45, width, horizon * 0.55);
      g.fillStyle = 'rgb(255,230,153)';
      g.beginPath();
      g.ellipse(140, horizon - 6, 20, 20, 0, 0, Math.PI * 2);
      g.fill();
      break;
    }
    case 'aurora':
      for (let band = 0; band < 3; band++) {
        g.strokeStyle = band === 1 ? 'rgba(153,89,255,0.35)' : 'rgba(77,255,153,0.4)';
        g.lineWidth = 14 - band * 3;
        const base = horizon * (0.35 + band * 0.12);
        g.beginPath();
        g.moveTo(0, base);
        for (let x = 0; x <= width; x += 8) g.lineTo(x, base + Math.sin((x / width) * 6 * Math.PI + band) * 12);
        g.stroke();
      }
      break;
    case 'space':
      g.fillStyle = 'rgb(140,115,230)';
      g.beginPath();
      g.ellipse(330, horizon * 0.4 + 30, 30, 30, 0, 0, Math.PI * 2);
      g.fill();
      g.strokeStyle = 'rgba(217,204,255,0.8)';
      g.lineWidth = 3;
      g.beginPath();
      g.ellipse(330, horizon * 0.4 + 31, 46, 7, 0, 0, Math.PI * 2);
      g.stroke();
      break;
    default:
      break;
  }
  return c;
}

// MARK: - Pictures from the world

const pictureCache = new Map<string, THREE.Texture>();

export function pictureTexture(id: string, base64: string): THREE.Texture {
  const cached = pictureCache.get(id + base64.length);
  if (cached) return cached;
  const texture = new THREE.TextureLoader().load('data:image/png;base64,' + base64);
  texture.colorSpace = THREE.SRGBColorSpace;
  if (pictureCache.size > 64) pictureCache.clear();
  pictureCache.set(id + base64.length, texture);
  return texture;
}
