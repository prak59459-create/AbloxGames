// AbloxCoreTests/SoundCueTests.swift, SoundLibraryTests.swift and the sound
// parts of WorldFeaturesTests.swift, and the thirty packed recordings decoded
// sample for sample as the iPad decodes them (fixtures/cues-swift.json was
// written by SoundClipDecoder itself).
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import { isLibraryID, soundCueNamed, soundCues } from '../src/core/model/player';
import {
  SoundThrottle, cueFeedback, cueTones, decodePackedClip, decodeSoundIndex, libraryIDsInScripts, libraryIDsInWorld, loopLength,
  musicNotes, noteFrequency, renderMusicLoop, renderTones, stepSeconds, tidyClip, type MusicTrack,
} from '../src/core/model/sound';
import { emptyWorld } from '../src/core/model/world';
import { eventRule } from '../src/core/model/rules';
import { musicPlay, soundPlay } from '../src/core/model/effects';

const tracks: MusicTrack[] = ['calm', 'adventure', 'spooky', 'race', 'boss', 'shop', 'party', 'space'];

describe('cues', () => {
  it('resolves names case- and whitespace-insensitively', () => {
    expect(soundCueNamed('collect')).toBe('collect');
    expect(soundCueNamed('COLLECT')).toBe('collect');
    expect(soundCueNamed('  Collect  ')).toBe('collect');
    expect(soundCueNamed('kerplunk')).toBeNull();
    expect(soundCueNamed('')).toBeNull();
  });

  it('knows every cue the engine emits, and the quiet ones are still felt', () => {
    for (const name of ['collect', 'checkpoint', 'hurt', 'bounce', 'teleport']) expect(soundCueNamed(name)).not.toBeNull();
    for (const cue of ['collect', 'checkpoint', 'hurt', 'goal'] as const) expect(cueFeedback(cue)).not.toBe('none');
  });

  it('throttles rapid repeats, per cue, and resets between rounds', () => {
    const throttle = new SoundThrottle();
    expect(throttle.shouldPlay('collect', 0)).toBe(true);
    expect(throttle.shouldPlay('collect', 0.02)).toBe(false);
    expect(throttle.shouldPlay('collect', 0.05)).toBe(false);
    expect(throttle.shouldPlay('collect', 0.2)).toBe(true);
    expect(throttle.shouldPlay('bounce', 0.2)).toBe(true);
    for (let step = 0; step < 10; step++) expect(throttle.shouldPlay('goal', step * 0.001)).toBe(true);
    expect(throttle.shouldPlay('collect', 0.21)).toBe(false);
    throttle.reset();
    expect(throttle.shouldPlay('collect', 0.22)).toBe(true);
  });

  it('gives every cue tones', () => {
    for (const cue of soundCues) {
      const tones = cueTones(cue);
      expect(tones.length).toBeGreaterThan(0);
      expect(tones.every((t) => t.duration > 0 && t.frequency > 0 && t.volume <= 1)).toBe(true);
      const samples = renderTones(tones, 44100);
      const total = tones.reduce((n, t) => n + Math.max(1, Math.trunc(t.duration * 44100)), 0);
      expect(samples.length).toBe(total);
      expect(Math.max(...samples.map(Math.abs))).toBeLessThanOrEqual(1);
      // Faded in and out, so nothing clicks.
      expect(Math.abs(samples[0])).toBeLessThan(0.01);
    }
  });

  it('keeps requests in range', () => {
    const loud = soundPlay('coin', 9, 100);
    expect(loud.volume).toBe(1);
    expect(loud.pitch).toBe(4);
    expect(musicPlay('calm', Number.NaN).volume).toBe(1);
  });
});

describe('recordings', () => {
  const packed = JSON.parse(readFileSync(new URL('../public/cues.json', import.meta.url), 'utf8')) as { rate: number; cues: Record<string, string> };
  const swift = JSON.parse(readFileSync(new URL('./fixtures/cues-swift.json', import.meta.url), 'utf8')) as Record<string, number[]>;

  it('has a recording for every cue', () => {
    expect(packed.rate).toBe(22050);
    expect(Object.keys(packed.cues).sort()).toEqual([...soundCues].sort());
  });

  it('decodes every recording exactly as the iPad does', () => {
    for (const [name, text] of Object.entries(packed.cues)) {
      const s = decodePackedClip(text)!;
      expect(s, name).not.toBeNull();
      let sum = 0, sq = 0;
      s.forEach((v, i) => { sum += v * ((i % 7) + 1); sq += v * v; });
      const [count, swiftSum, swiftSquares, middle, last] = swift[name];
      expect(s.length, name).toBe(count);
      expect(sum, name).toBeCloseTo(swiftSum, 6);
      // The iPad squared in Float; the difference is in the ninth figure.
      expect(Math.abs(sq - swiftSquares) / swiftSquares, name).toBeLessThan(1e-7);
      expect(s[Math.trunc(s.length / 2)], name).toBeCloseTo(middle, 9);
      expect(s[s.length - 1], name).toBeCloseTo(last, 9);
    }
  });

  it('refuses what it cannot read', () => {
    expect(decodePackedClip('')).toBeNull();
    expect(decodePackedClip(btoa('\u0003abc'))).toBeNull();
    expect(decodePackedClip(btoa('\u0001'))).toBeNull();
  });

  it('tidies a library sound: quiet ends cut, peak levelled, the end faded', () => {
    const rate = 1000;
    const raw = new Float32Array(1000);
    for (let i = 200; i < 600; i++) raw[i] = Math.sin(i) * 0.3;
    const tidy = tidyClip(raw, rate);
    expect(tidy.length).toBeLessThan(500);
    expect(Math.max(...tidy.map(Math.abs))).toBeCloseTo(0.9, 2);
    expect(tidy[tidy.length - 1]).toBe(0);
    expect(tidyClip(new Float32Array(100), rate).length).toBe(0);
  });
});

describe('music', () => {
  it('loops and stays in tune', () => {
    expect(noteFrequency(69)).toBeCloseTo(440, 2);
    for (const track of tracks) {
      expect(loopLength(track)).toBe(32);
      expect(musicNotes(track, 0)).toEqual(musicNotes(track, loopLength(track)));
      expect(musicNotes(track, 0).some((n) => n.voice === 'bass')).toBe(true);
      for (let step = 0; step < 32; step++) {
        expect(musicNotes(track, step).every((n) => n.midi >= 20 && n.midi <= 110), `${track} ${step}`).toBe(true);
      }
      expect(stepSeconds(track)).toBeGreaterThan(0.1);
    }
  });

  it('plays the same notes as the iPad, every step of every track', () => {
    // fixtures/music-swift.json: MusicTrack.notes(at:) for each step of each loop.
    const swift = JSON.parse(readFileSync(new URL('./fixtures/music-swift.json', import.meta.url), 'utf8')) as Record<string, { midi: number; steps: number; voice: string; velocity: number }[][]>;
    for (const track of tracks) {
      for (let step = 0; step < 32; step++) {
        const ours = musicNotes(track, step);
        const theirs = swift[track][step];
        expect(ours.map((n) => [n.midi, n.steps, n.voice]), `${track} ${step}`).toEqual(theirs.map((n) => [n.midi, n.steps, n.voice]));
        ours.forEach((n, i) => expect(n.velocity).toBeCloseTo(theirs[i].velocity, 6));
      }
    }
  });

  it('renders a loop that lasts its steps and stays in range', () => {
    const loop = renderMusicLoop('party', 8000);
    expect(loop.length).toBe(32 * Math.trunc(stepSeconds('party') * 8000));
    expect(Math.max(...loop.map(Math.abs))).toBeLessThan(2);
    expect(loop.some((v) => Math.abs(v) > 0.05)).toBe(true);
  });
});

describe('the sound library', () => {
  const hash = 'ab'.repeat(32);
  const index = (families: unknown[]) => ({ version: 1, license: 'CC0-1.0', categories: [], families });

  it('names sounds with hyphenated lowercase words', () => {
    expect(isLibraryID('retro-game-coin-08')).toBe(true);
    expect(isLibraryID('owner-backlog-20260922-decrease-ui-cue')).toBe(true);
    for (const cue of soundCues) expect(isLibraryID(cue)).toBe(false);
    for (const name of ['', '-coin', 'coin-', 'coin--08', 'Coin-08', 'coin 08', 'coin_08', '../etc-passwd', 'コイン-01', 'a-'.repeat(60) + 'b']) {
      expect(isLibraryID(name), name).toBe(false);
    }
  });

  it('reads the index and leaves out what cannot be what it claims', () => {
    const sounds = decodeSoundIndex(index([
      { id: 'retro-game-coin', en: 'Coin', c: 'retro-game', s: [['retro-game-coin-08', 1031, 16927, hash, 'Short 8-Bit Coin Pickup 08'], ['retro-game-coin-33', 2038, 33061, hash]] },
      { id: 'mixed', en: 'Mixed', c: 'animal', s: [['good-sound-01', 500, 1000, hash], ['Bad-Sound', 500, 1000, hash], ['short-hash-01', 500, 1000, 'abc'],
        ['not-hex-01', 500, 1000, 'zz'.repeat(32)], ['too-big-01', 500, 99999999, hash], ['empty-file-01', 500, 0, hash]] },
      { id: '../escape', en: 'Escape', c: 'animal', s: [['escape-01', 1, 1, hash]] },
      { id: 'bad-category', en: 'Bad', c: '../x', s: [['bad-category-01', 1, 1, hash]] },
    ]));
    expect([...sounds.keys()]).toEqual(['retro-game-coin-08', 'retro-game-coin-33', 'good-sound-01']);
    expect(sounds.get('retro-game-coin-08')).toMatchObject({ category: 'retro-game', milliseconds: 1031, bytes: 16927, title: 'Short 8-Bit Coin Pickup 08' });
    expect(sounds.get('retro-game-coin-33')?.title).toBe('');
    expect(() => decodeSoundIndex({ version: 2, categories: [], families: [] })).toThrow();
  });

  it('finds the ids in scripts and rules', () => {
    const source = [
      '-- don\'t forget: "not-this-one" is in a comment',
      'on touch(p, b)',
      '  sound("retro-game-coin-08")',
      "  p.sound('animal-dog-bark-02', {volume: 0.5})",
      '  sound("coin")',
      '  sound("retro-game-coin-08")',
      '  announce("red-team wins")',
      'end',
    ].join('\n');
    expect(libraryIDsInScripts([source])).toEqual(['retro-game-coin-08', 'animal-dog-bark-02']);
    const world = emptyWorld('Sounds');
    world.rules = [eventRule({ name: 'ding', trigger: { type: 'timer', interval: 1 }, actions: [{ type: 'playSound', name: 'ui-chime-15' }, { type: 'playSound', name: 'goal' }] })];
    world.scripts = [{ id: 'A', name: 'main', source, isEnabled: true }, { id: 'B', name: 'off', source: 'sound("switched-off-01")', isEnabled: false }];
    expect(libraryIDsInWorld(world)).toEqual(['ui-chime-15', 'retro-game-coin-08', 'animal-dog-bark-02']);
  });
});
