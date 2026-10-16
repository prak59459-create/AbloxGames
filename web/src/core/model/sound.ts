// Sounds as numbers, with no audio device: the tones each cue is made of
// (AbloxCore/ToneSounds.swift), how often a cue may repeat and how it should
// feel (SoundCue.swift), the music loops (MusicTracks.swift), the packed
// recordings of the thirty cues (Engine/SoundClips.swift), and which library
// sounds a world names (SoundLibrary.swift). The browser's speakers are
// engine/audio.ts; everything here is plain arithmetic, so it is tested.
import type { SoundCue } from './player';
import { isLibraryID } from './player';
import { trimmed } from './text';
import type { WorldDocument } from './world';

// MARK: - Tones

export type Wave = 'sine' | 'square' | 'triangle' | 'saw' | 'noise';

/** One tone of a cue: a pitch sliding from `frequency` to `endFrequency`. */
export interface ToneStep { frequency: number; endFrequency: number; duration: number; wave: Wave; volume: number }

const t = (frequency: number, duration: number, wave: Wave = 'square', volume = 0.5, endFrequency = frequency): ToneStep =>
  ({ frequency, endFrequency, duration, wave, volume });
const slide = (frequency: number, to: number, duration: number, wave: Wave = 'square', volume = 0.5): ToneStep =>
  t(frequency, duration, wave, volume, to);

export function cueTones(cue: SoundCue): ToneStep[] {
  switch (cue) {
    case 'collect': case 'coin': return [t(988, 0.06), t(1319, 0.14)];
    case 'checkpoint': return [t(523, 0.09, 'triangle'), t(659, 0.09, 'triangle'), t(784, 0.2, 'triangle')];
    case 'hurt': return [slide(300, 120, 0.22, 'saw', 0.45)];
    case 'bounce': return [slide(220, 660, 0.18, 'sine', 0.6)];
    case 'teleport': return [slide(300, 1400, 0.3, 'sine', 0.4)];
    case 'goal': case 'win': return [t(523, 0.12), t(659, 0.12), t(784, 0.12), t(1047, 0.35)];
    case 'join': return [t(660, 0.08, 'triangle'), t(880, 0.12, 'triangle')];
    case 'leave': return [t(880, 0.08, 'triangle'), t(660, 0.12, 'triangle')];
    case 'tick': return [t(1600, 0.03, 'square', 0.25)];
    case 'error': return [t(200, 0.12), t(150, 0.18)];
    case 'shoot': case 'laser': return [slide(1800, 300, 0.12, 'square', 0.35)];
    case 'hit': return [slide(150, 80, 0.08, 'noise', 0.5)];
    case 'reload': return [t(400, 0.04, 'noise', 0.3), t(700, 0.05, 'noise', 0.3)];
    case 'defeat': case 'lose': return [t(392, 0.18, 'triangle'), t(330, 0.18, 'triangle'), t(262, 0.4, 'triangle')];
    case 'jump': return [slide(330, 700, 0.12, 'square', 0.35)];
    case 'powerup': return [t(392, 0.07), t(523, 0.07), t(659, 0.07), t(784, 0.07), t(1047, 0.2)];
    case 'explosion': return [slide(120, 40, 0.6, 'noise', 0.8)];
    case 'splash': return [slide(900, 200, 0.35, 'noise', 0.45)];
    case 'door': return [slide(180, 140, 0.25, 'saw', 0.3)];
    case 'click': return [t(1200, 0.02, 'square', 0.3)];
    case 'whoosh': return [slide(300, 1200, 0.3, 'noise', 0.35)];
    case 'magic': return [t(784, 0.06, 'sine'), t(988, 0.06, 'sine'), t(1319, 0.06, 'sine'), t(1760, 0.25, 'sine')];
    case 'pop': return [slide(500, 1100, 0.06, 'sine', 0.6)];
    case 'bell': return [t(1319, 0.6, 'sine', 0.5)];
    case 'alarm': return [t(880, 0.15), t(660, 0.15), t(880, 0.15), t(660, 0.15)];
    case 'drum': return [slide(90, 50, 0.18, 'sine', 0.9)];
  }
}

export type Feedback = 'none' | 'light' | 'medium' | 'heavy' | 'success' | 'warning' | 'failure';

/** How strongly a cue should be felt: often the only feedback on a muted device. */
export function cueFeedback(cue: SoundCue): Feedback {
  switch (cue) {
    case 'collect': case 'join': case 'leave': case 'shoot': case 'coin': case 'pop': case 'click': case 'jump': return 'light';
    case 'checkpoint': case 'goal': case 'powerup': case 'win': case 'magic': case 'bell': return 'success';
    case 'hurt': return 'failure';
    case 'bounce': case 'teleport': case 'hit': case 'splash': case 'door': case 'whoosh': case 'laser': return 'medium';
    case 'tick': case 'reload': return 'none';
    case 'error': case 'lose': case 'alarm': return 'warning';
    case 'defeat': case 'explosion': case 'drum': return 'heavy';
  }
}

/** The shortest gap between two of the same cue, so a row of coins is taps, not a buzz. */
export function cueMinimumInterval(cue: SoundCue): number {
  switch (cue) {
    case 'collect': case 'tick': case 'shoot': case 'hit': case 'coin': case 'click': case 'laser': case 'pop': case 'drum': case 'jump': return 0.08;
    case 'bounce': return 0.15;
    default: return 0;
  }
}

export class SoundThrottle {
  private last = new Map<SoundCue, number>();

  shouldPlay(cue: SoundCue, time: number): boolean {
    const interval = cueMinimumInterval(cue);
    if (interval <= 0) return true;
    const last = this.last.get(cue);
    if (last !== undefined && time - last < interval) return false;
    this.last.set(cue, time);
    return true;
  }

  reset(): void { this.last.clear(); }
}

// MARK: - The synthesiser's voice

/** One sounding tone, sample by sample, as SoundSynth.sample does it. */
export interface Voice {
  phase: number; start: number; end: number; length: number; position: number; delay: number; wave: Wave; volume: number;
}

export class Noise {
  constructor(private state = 0x9e3779b9) {}
  next(): number {
    let x = this.state >>> 0;
    x ^= x << 13; x >>>= 0;
    x ^= x >>> 17;
    x ^= x << 5; x >>>= 0;
    this.state = x;
    return (x / 0xffffffff) * 2 - 1;
  }
}

export function voiceSample(v: Voice, rate: number, noise: Noise): number {
  const progress = v.position / v.length;
  const frequency = v.start + (v.end - v.start) * progress;
  const phase = v.phase;
  let value: number;
  switch (v.wave) {
    case 'sine': value = Math.sin(phase * 2 * Math.PI); break;
    case 'square': value = phase < 0.5 ? 0.6 : -0.6; break;
    case 'triangle': value = 4 * Math.abs(phase - 0.5) - 1; break;
    case 'saw': value = (2 * phase - 1) * 0.7; break;
    case 'noise': value = noise.next(); break;
  }
  let next = phase + frequency / rate;
  if (next >= 1) next -= Math.floor(next);
  v.phase = next;
  const attackFrames = Math.max(1, Math.min(Math.trunc(v.length / 8), Math.trunc(rate * 0.006)));
  const releaseFrames = Math.max(1, Math.trunc(v.length / 4));
  const attack = Math.min(1, v.position / attackFrames);
  const release = Math.min(1, (v.length - v.position) / releaseFrames);
  v.position += 1;
  return value * v.volume * attack * release;
}

/** A cue's tones, one after another, as samples at `rate`. */
export function renderTones(tones: ToneStep[], rate: number, pitch = 1, volume = 1): Float32Array {
  const voices: Voice[] = [];
  let offset = 0;
  for (const tone of tones) {
    const length = Math.max(1, Math.trunc(tone.duration * rate));
    voices.push({ phase: 0, start: tone.frequency * pitch, end: tone.endFrequency * pitch, length, position: 0, delay: offset,
      wave: tone.wave, volume: tone.volume * volume });
    offset += length;
  }
  const out = new Float32Array(offset);
  const noise = new Noise();
  for (const v of voices) {
    for (let i = 0; i < v.length; i++) out[v.delay + i] += voiceSample(v, rate, noise);
  }
  return out;
}

// MARK: - Music

export type MusicTrack = 'calm' | 'adventure' | 'spooky' | 'race' | 'boss' | 'shop' | 'party' | 'space';
export type MusicVoice = 'lead' | 'bass' | 'pad' | 'drum';
export interface MusicNote { midi: number; steps: number; voice: MusicVoice; velocity: number }

export const noteFrequency = (midi: number) => 440 * Math.pow(2, (midi - 69) / 12);

interface TrackShape { tempo: number; root: number; scale: number[]; progression: number[]; melody: number[]; drums: boolean }

const major = [0, 2, 4, 7, 9];
const harmonicMinor = [0, 2, 3, 5, 7, 8, 11];
const lydian = [0, 2, 4, 6, 7, 9, 11];

const tracks: Record<MusicTrack, TrackShape> = {
  calm: { tempo: 84, root: 60, scale: major, progression: [0, 3, 4, 2], melody: [4, -1, 5, 4, 2, -1, 1, -1, 2, -1, 4, 2, 1, -1, 0, -1], drums: false },
  adventure: { tempo: 118, root: 62, scale: major, progression: [0, 4, 3, 4], melody: [0, 2, 4, 5, 4, 2, 4, -1, 5, 4, 2, 4, 2, 1, 0, -1], drums: true },
  spooky: { tempo: 72, root: 57, scale: harmonicMinor, progression: [0, 0, 5, 4], melody: [0, -1, 2, 1, 0, -1, -2, -1, 3, -1, 2, 1, 0, -1, -1, -1], drums: false },
  race: { tempo: 150, root: 64, scale: major, progression: [0, 3, 0, 4], melody: [4, 4, 5, 4, 2, 4, 5, 7, 7, 5, 4, 2, 4, 2, 1, 0], drums: true },
  boss: { tempo: 140, root: 52, scale: harmonicMinor, progression: [0, 5, 3, 4], melody: [0, 0, 3, 0, 4, 0, 3, 2, 0, 0, 5, 4, 3, 2, 1, -1], drums: true },
  shop: { tempo: 104, root: 65, scale: major, progression: [0, 2, 3, 4], melody: [2, 4, 5, -1, 4, 2, 0, -1, 1, 2, 4, -1, 2, 1, 0, -1], drums: false },
  party: { tempo: 124, root: 60, scale: major, progression: [0, 3, 4, 3], melody: [0, 2, 4, 2, 5, 4, 2, 4, 0, 2, 4, 5, 7, 5, 4, -1], drums: true },
  space: { tempo: 90, root: 55, scale: lydian, progression: [0, 1, 0, 5], melody: [4, -1, -1, 6, -1, -1, 5, -1, 4, -1, -1, 2, -1, -1, 1, -1], drums: false },
};

export const isMusicTrack = (name: string): name is MusicTrack => name in tracks;
export const loopLength = (track: MusicTrack) => tracks[track].progression.length * 8;
export const stepSeconds = (track: MusicTrack) => 60 / tracks[track].tempo / 2;

function pitchOf(shape: TrackShape, degree: number): number {
  const count = shape.scale.length;
  const octave = Math.floor(degree / count);
  const index = ((degree % count) + count) % count;
  return shape.root + octave * 12 + shape.scale[index];
}

/** What plays on eighth note `step`. */
export function musicNotes(track: MusicTrack, step: number): MusicNote[] {
  const shape = tracks[track];
  const length = loopLength(track);
  const local = ((step % length) + length) % length;
  const bar = Math.trunc(local / 8);
  const beat = local % 8;
  const chord = shape.progression[bar % shape.progression.length];
  const notes: MusicNote[] = [];
  if (beat % 2 === 0) notes.push({ midi: pitchOf(shape, chord) - 12 + (beat === 4 ? 7 : 0), steps: 2, voice: 'bass', velocity: 0.55 });
  if (beat === 0) for (const offset of [0, 2, 4]) notes.push({ midi: pitchOf(shape, chord + offset), steps: 8, voice: 'pad', velocity: 0.22 });
  const degree = shape.melody[local % shape.melody.length];
  if (degree !== -1) notes.push({ midi: pitchOf(shape, degree) + 12, steps: 1, voice: 'lead', velocity: 0.4 });
  if (shape.drums) {
    if (beat % 4 === 0) notes.push({ midi: 36, steps: 1, voice: 'drum', velocity: 0.7 });
    if (beat % 4 === 2) notes.push({ midi: 38, steps: 1, voice: 'drum', velocity: 0.45 });
  }
  return notes;
}

function noteVoice(note: MusicNote, stepSamples: number, rate: number, delay: number): Voice {
  const length = Math.max(1, Math.trunc(stepSamples * note.steps * 0.92));
  const f = noteFrequency(note.midi);
  const v = (start: number, end: number, len: number, wave: Wave, volume: number): Voice =>
    ({ phase: 0, start, end, length: len, position: 0, delay, wave, volume });
  switch (note.voice) {
    case 'drum': return note.midi === 36 ? v(120, 45, Math.trunc(0.16 * rate), 'sine', note.velocity * 0.9)
      : v(1000, 400, Math.trunc(0.09 * rate), 'noise', note.velocity * 0.35);
    case 'bass': return v(f, f, length, 'triangle', note.velocity * 0.5);
    case 'pad': return v(f, f, length, 'sine', note.velocity * 0.5);
    case 'lead': return v(f, f, length, 'square', note.velocity * 0.22);
  }
}

/** One pass of a track as samples; nothing sounds past its end, so it loops cleanly. */
export function renderMusicLoop(track: MusicTrack, rate: number): Float32Array {
  const stepSamples = Math.max(1, Math.trunc(stepSeconds(track) * rate));
  const steps = loopLength(track);
  const out = new Float32Array(steps * stepSamples);
  const noise = new Noise();
  for (let step = 0; step < steps; step++) {
    for (const note of musicNotes(track, step)) {
      const v = noteVoice(note, stepSamples, rate, step * stepSamples);
      for (let i = 0; i < v.length; i++) {
        const at = (v.delay + i) % out.length;
        out[at] += voiceSample(v, rate, noise);
      }
    }
  }
  return out;
}

// MARK: - Recordings

/** The loudest sample after `tidy`. */
export const clipPeak = 0.9;

const adpcmSteps = [
  7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 19, 21, 23, 25, 28, 31, 34, 37, 41, 45, 50, 55, 60, 66, 73, 80, 88, 97, 107,
  118, 130, 143, 157, 173, 190, 209, 230, 253, 279, 307, 337, 371, 408, 449, 494, 544, 598, 658, 724, 796, 876, 963,
  1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066, 2272, 2499, 2749, 3024, 3327, 3660, 4026, 4428, 4871, 5358, 5894,
  6484, 7132, 7845, 8630, 9493, 10442, 11487, 12635, 13899, 15289, 16818, 18500, 20350, 22385, 24623, 27086, 29794,
  32767,
];
const adpcmIndex = [-1, -1, -1, -1, 2, 4, 6, 8, -1, -1, -1, -1, 2, 4, 6, 8];

const muLawTable = Float32Array.from({ length: 256 }, (_, value) => {
  const byte = ~value & 0xff;
  const sign = byte & 0x80 ? -1 : 1;
  const exponent = (byte >> 4) & 0x07;
  const mantissa = byte & 0x0f;
  const magnitude = ((mantissa << 3) + 0x84) << exponent;
  return (sign * (magnitude - 0x84)) / 32635;
});

function base64Bytes(text: string): Uint8Array {
  const clean = text.replace(/[^A-Za-z0-9+/=]/g, '');
  const binary = atob(clean);
  const out = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) out[i] = binary.charCodeAt(i);
  return out;
}

/**
 * A recording packed as base64, as the app keeps the cues (CueRecordings):
 * the first byte says how — 1, μ-law, a byte a sample; 2, IMA ADPCM, three
 * bytes of starting state and then two samples a byte, low half first.
 */
export function decodePackedClip(text: string): Float32Array | null {
  let bytes: Uint8Array;
  try { bytes = base64Bytes(text); } catch { return null; }
  if (bytes.length <= 1) return null;
  let samples: Float32Array;
  if (bytes[0] === 1) {
    samples = new Float32Array(bytes.length - 1);
    for (let i = 1; i < bytes.length; i++) samples[i - 1] = muLawTable[bytes[i]];
  } else if (bytes[0] === 2) {
    if (bytes.length <= 4) return null;
    let index = Math.min(88, bytes[1]);
    let predictor = ((bytes[2] | (bytes[3] << 8)) << 16) >> 16;
    samples = new Float32Array(1 + (bytes.length - 4) * 2);
    let n = 0;
    samples[n++] = predictor / 32768;
    for (let p = 4; p < bytes.length; p++) {
      const byte = bytes[p];
      for (const code of [byte & 0x0f, byte >> 4]) {
        const step = adpcmSteps[index];
        let delta = step >> 3;
        if (code & 4) delta += step;
        if (code & 2) delta += step >> 1;
        if (code & 1) delta += step >> 2;
        predictor = code & 8 ? predictor - delta : predictor + delta;
        predictor = Math.max(-32768, Math.min(32767, predictor));
        index = Math.max(0, Math.min(88, index + adpcmIndex[code]));
        samples[n++] = predictor / 32768;
      }
    }
  } else {
    return null;
  }
  return samples.length > 1 ? samples : null;
}

/** Quiet cut from both ends, the last few milliseconds faded, the peak brought to `clipPeak`. */
export function tidyClip(samples: Float32Array, rate: number): Float32Array {
  let loudest = 0;
  for (const v of samples) loudest = Math.max(loudest, Math.abs(v));
  if (loudest <= 0.0001) return new Float32Array(0);
  const threshold = loudest * 0.003;
  let first = samples.findIndex((v) => Math.abs(v) > threshold);
  if (first < 0) first = 0;
  let last = samples.length - 1;
  while (last > 0 && Math.abs(samples[last]) <= threshold) last--;
  const start = Math.max(0, first - Math.trunc(rate * 0.002));
  const end = Math.min(samples.length, last + Math.trunc(rate * 0.02));
  const cut = samples.slice(start, end);
  const gain = Math.min(8, clipPeak / loudest);
  const fade = Math.min(cut.length, Math.trunc(rate * 0.008));
  const count = cut.length;
  for (let i = 0; i < count; i++) {
    let v = cut[i] * gain;
    const fromEnd = count - i;
    if (fromEnd <= fade) v *= fromEnd / fade;
    cut[i] = v;
  }
  return cut;
}

// MARK: - The sound library

export interface LibrarySound { id: string; category: string; milliseconds: number; bytes: number; sha256: string; title: string }

const safeName = (name: string) => name.length > 0 && (isLibraryID(name) || (name.length <= 40 && /^[a-z0-9]+$/.test(name)));

/** `sounds/index.json`: every sound by id. Rows that could not be what they claim are left out. */
export function decodeSoundIndex(json: unknown): Map<string, LibrarySound> {
  const index = json as { version?: number; families?: { id?: unknown; c?: unknown; s?: unknown[] }[] };
  if (!index || index.version !== 1) throw new Error('The sound list needs a newer Ablox.');
  const out = new Map<string, LibrarySound>();
  for (const family of index.families ?? []) {
    const category = typeof family?.c === 'string' ? family.c : '';
    if (typeof family.id !== 'string' || !safeName(family.id) || !safeName(category) || !Array.isArray(family.s)) continue;
    for (const row of family.s) {
      if (!Array.isArray(row) || out.size >= 50000) continue;
      const [id, milliseconds, bytes, sha256, title] = row as [unknown, unknown, unknown, unknown, unknown];
      if (typeof id !== 'string' || !isLibraryID(id) || typeof bytes !== 'number' || bytes <= 0 || bytes > 4 * 1024 * 1024) continue;
      if (typeof sha256 !== 'string' || !/^[0-9a-fA-F]{64}$/.test(sha256)) continue;
      out.set(id, { id, category, milliseconds: Math.max(0, Number(milliseconds) || 0), bytes, sha256: sha256.toLowerCase(),
        title: typeof title === 'string' ? title.slice(0, 80) : '' });
    }
  }
  return out;
}

const quotes = new Set(['"', "'", '“', '”', '‘', '’', '＂']);

/** Every quoted string in script text shaped like a library id; `--` comments skipped. */
export function libraryIDsInScripts(sources: string[], soundNames: string[] = []): string[] {
  const limit = 200;
  const seen = new Set<string>();
  const found: string[] = [];
  const add = (name: string) => {
    if (found.length < limit && isLibraryID(name) && !seen.has(name)) { seen.add(name); found.push(name); }
  };
  for (const name of soundNames) add(trimmed(name).toLowerCase());
  for (const source of sources) {
    let inString = false, inComment = false, current = '', previous = ' ';
    for (const ch of source) {
      if (ch === '\n' || ch === '\r' || ch === ' ' || ch === ' ' || ch === '\u0085' || ch === '\v' || ch === '\f') {
        inString = false; inComment = false; current = '';
      } else if (inComment) {
        // skipped to the end of the line
      } else if (inString) {
        if (quotes.has(ch)) { inString = false; add(current); current = ''; } else if ([...current].length <= 96) current += ch;
      } else if (quotes.has(ch)) {
        inString = true;
      } else if (ch === '-' && previous === '-') {
        inComment = true;
      }
      previous = ch;
    }
    if (found.length >= limit) break;
  }
  return found;
}

/** The library sounds a world's rules and scripts name: what to fetch before the first coin. */
export function libraryIDsInWorld(world: WorldDocument): string[] {
  const names: string[] = [];
  for (const rule of world.rules) for (const action of rule.actions) if (action.type === 'playSound') names.push(action.name);
  return libraryIDsInScripts(world.scripts.filter((s) => s.isEnabled).map((s) => s.source), names);
}
