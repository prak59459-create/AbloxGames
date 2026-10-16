// The browser's speakers: Engine/FeedbackPlayer.swift and SoundSynth.swift
// over Web Audio. The thirty cues play their recordings, decoded from the
// same packed text the app carries (public/cues.json, made from
// CueRecordings.swift); a cue still has its tones for when recordings are
// off or not yet loaded. Library sounds come from the game list's sounds/
// folder when a game names one, checked against the index's SHA-256 and
// kept decoded. Music is a track's loop, made from its notes once and
// played round. Phones that can vibrate get the cue's feel as well.
import { soundCueNamed, isLibraryID, type SoundCue } from '../core/model/player';
import type { MusicPlay, SoundPlay } from '../core/model/effects';
import type { WorldDocument } from '../core/model/world';
import {
  SoundThrottle, cueFeedback, cueTones, decodePackedClip, decodeSoundIndex, isMusicTrack, libraryIDsInWorld, renderMusicLoop,
  renderTones, tidyClip, type Feedback, type LibrarySound, type MusicTrack,
} from '../core/model/sound';
import { trimmed } from '../core/model/text';
import { fileURL, inTurn, type CatalogueSource } from '../net/catalogue';

const masterLevel = 0.6;
const libraryLateness = 0.8;
const cacheLimitBytes = 48 * 1024 * 1024;

interface Settings { sound: boolean; haptics: boolean; recorded: boolean; effects: number; music: number; readLines: boolean }

function loadSettings(): Settings {
  const fallback: Settings = { sound: true, haptics: true, recorded: true, effects: 1, music: 0.7, readLines: false };
  try {
    const saved = JSON.parse(localStorage.getItem('ablox.sound') ?? 'null') as Partial<Settings> | null;
    return { ...fallback, ...(saved ?? {}) };
  } catch {
    return fallback;
  }
}

export class SoundPlayer {
  private settings = loadSettings();
  private context: AudioContext | null = null;
  private master: GainNode | null = null;
  private effects: GainNode | null = null;
  private musicBus: GainNode | null = null;
  private failed = false;
  private throttle = new SoundThrottle();
  private started = performance.now();
  private cues = new Map<SoundCue, AudioBuffer>();
  private cueText: Promise<Record<string, string> | null> | null = null;
  private tones = new Map<string, AudioBuffer>();
  private library = new Map<string, AudioBuffer>();
  private libraryOrder: string[] = [];
  private libraryBytes = 0;
  private libraryLoading = new Map<string, Promise<AudioBuffer | null>>();
  private libraryPlayed = new Map<string, number>();
  private index: Promise<Map<string, LibrarySound>> | null = null;
  private music: { track: MusicTrack; node: AudioBufferSourceNode; gain: GainNode } | null = null;
  private musicLoops = new Map<MusicTrack, AudioBuffer>();
  private voices: AudioBufferSourceNode[] = [];
  private unlockers: (() => void) | null = null;

  /** Told of every cue played, for sound captions. */
  onPlayed: (cue: SoundCue) => void = () => {};

  constructor(private source?: CatalogueSource) {}

  // MARK: Settings

  get soundEnabled() { return this.settings.sound; }
  set soundEnabled(on: boolean) { this.change({ sound: on }); if (!on) this.stopAll(); }
  get hapticsEnabled() { return this.settings.haptics; }
  set hapticsEnabled(on: boolean) { this.change({ haptics: on }); }
  get recordedCues() { return this.settings.recorded; }
  set recordedCues(on: boolean) { this.change({ recorded: on }); }
  get effectsVolume() { return this.settings.effects; }
  set effectsVolume(v: number) { this.change({ effects: clamp01(v) }); }
  get musicVolume() { return this.settings.music; }
  set musicVolume(v: number) { this.change({ music: clamp01(v) }); }
  get readsLines() { return this.settings.readLines; }
  set readsLines(on: boolean) { this.change({ readLines: on }); if (!on) speechSynthesis?.cancel(); }

  private change(patch: Partial<Settings>): void {
    this.settings = { ...this.settings, ...patch };
    try { localStorage.setItem('ablox.sound', JSON.stringify(this.settings)); } catch { /* private mode */ }
    if (this.effects) this.effects.gain.value = this.settings.effects;
    if (this.musicBus) this.musicBus.gain.value = this.settings.music;
  }

  // MARK: Starting

  /**
   * Browsers keep sound off until the page is touched: the first tap,
   * click or key starts it, and the recordings are decoded then.
   */
  attach(target: EventTarget = window): void {
    if (this.unlockers) return;
    const unlock = () => {
      const context = this.start();
      if (context && context.state !== 'suspended') this.detach();
    };
    for (const name of ['pointerdown', 'keydown', 'touchend']) target.addEventListener(name, unlock, { passive: true });
    this.unlockers = () => { for (const name of ['pointerdown', 'keydown', 'touchend']) target.removeEventListener(name, unlock); };
  }

  detach(): void {
    this.unlockers?.();
    this.unlockers = null;
  }

  private start(): AudioContext | null {
    if (this.failed) return null;
    if (!this.context) {
      try {
        const Context = window.AudioContext ?? (window as unknown as { webkitAudioContext?: typeof AudioContext }).webkitAudioContext;
        if (!Context) { this.failed = true; return null; }
        const context = new Context({ latencyHint: 'interactive' });
        this.master = context.createGain();
        this.master.gain.value = masterLevel;
        // Many sounds at once stay sounds rather than a crackle.
        const limiter = context.createDynamicsCompressor();
        limiter.threshold.value = -3;
        limiter.knee.value = 0;
        limiter.ratio.value = 20;
        limiter.attack.value = 0.002;
        limiter.release.value = 0.1;
        this.master.connect(limiter).connect(context.destination);
        this.effects = context.createGain();
        this.effects.gain.value = this.settings.effects;
        this.effects.connect(this.master);
        this.musicBus = context.createGain();
        this.musicBus.gain.value = this.settings.music;
        this.musicBus.connect(this.master);
        this.context = context;
        void this.loadCues();
      } catch {
        this.failed = true;
        return null;
      }
    }
    if (this.context.state === 'suspended') void this.context.resume().catch(() => {});
    return this.context;
  }

  private loadCues(): Promise<Record<string, string> | null> {
    this.cueText ??= fetch(new URL('cues.json', document.baseURI).href)
      .then((r) => (r.ok ? r.json() : null))
      .then((json: { rate?: number; cues?: Record<string, string> } | null) => {
        const context = this.context;
        if (!json?.cues || !context) return null;
        const rate = json.rate ?? 22050;
        for (const [name, text] of Object.entries(json.cues)) {
          const cue = soundCueNamed(name);
          const samples = cue ? decodePackedClip(text) : null;
          if (!cue || !samples) continue;
          this.cues.set(cue, this.buffer(samples, rate));
        }
        return json.cues;
      })
      .catch(() => null);
    return this.cueText;
  }

  private buffer(samples: Float32Array, rate: number): AudioBuffer {
    const context = this.context!;
    const buffer = context.createBuffer(1, Math.max(1, samples.length), rate);
    buffer.copyToChannel(samples as Float32Array<ArrayBuffer>, 0);
    return buffer;
  }

  private now(): number { return (performance.now() - this.started) / 1000; }

  // MARK: Effects

  /** A cue, or a library sound, by the name a rule or script used. Unknown names are silent. */
  play(request: string | SoundPlay): void {
    const r = typeof request === 'string' ? { name: request, volume: 1, pitch: 1 } : request;
    const cue = soundCueNamed(r.name);
    if (cue) this.playCue(cue, r.volume, r.pitch);
    else this.playLibrary(r);
  }

  playCue(cue: SoundCue, volume = 1, pitch = 1): void {
    if (!this.throttle.shouldPlay(cue, this.now())) return;
    this.onPlayed(cue);
    if (this.settings.haptics) vibrate(cueFeedback(cue));
    if (!this.settings.sound) return;
    const context = this.start();
    if (!context) return;
    const recorded = this.settings.recorded ? this.cues.get(cue) : undefined;
    if (recorded) {
      this.voice(recorded, volume, pitch);
      return;
    }
    // Tones: made once for each pitch asked for.
    const key = `${cue}@${pitch.toFixed(3)}`;
    let buffer = this.tones.get(key);
    if (!buffer) {
      buffer = this.buffer(renderTones(cueTones(cue), context.sampleRate, pitch), context.sampleRate);
      if (this.tones.size > 200) this.tones.clear();
      this.tones.set(key, buffer);
    }
    this.voice(buffer, volume, 1);
  }

  private voice(buffer: AudioBuffer, volume: number, pitch: number): void {
    const context = this.context;
    if (!context || !this.effects) return;
    // The oldest gives way: the newest sound is the one just asked for.
    if (this.voices.length >= 32) {
      const oldest = this.voices.shift();
      try { oldest?.stop(); } catch { /* already over */ }
    }
    const node = context.createBufferSource();
    node.buffer = buffer;
    node.playbackRate.value = Math.max(0.25, Math.min(4, Number.isFinite(pitch) ? pitch : 1));
    const gain = context.createGain();
    gain.gain.value = clamp01(volume);
    node.connect(gain).connect(this.effects);
    node.onended = () => {
      const i = this.voices.indexOf(node);
      if (i >= 0) this.voices.splice(i, 1);
      node.disconnect();
      gain.disconnect();
    };
    this.voices.push(node);
    node.start();
  }

  /**
   * A sound from the library: at once if it has been played before,
   * otherwise when it arrives — unless that is long after the moment it was for.
   */
  private playLibrary(request: SoundPlay): void {
    const id = trimmed(request.name).toLowerCase();
    if (!this.settings.sound || !isLibraryID(id)) return;
    const now = this.now();
    const last = this.libraryPlayed.get(id);
    if (last !== undefined && now - last < 0.05) return;
    this.libraryPlayed.set(id, now);
    if (this.libraryPlayed.size > 400) { this.libraryPlayed.clear(); this.libraryPlayed.set(id, now); }
    if (!this.start()) return;
    const ready = this.library.get(id);
    if (ready) {
      this.touch(id);
      this.voice(ready, request.volume, request.pitch);
      return;
    }
    const asked = now;
    void this.libraryClip(id).then((clip) => {
      if (clip && this.now() - asked < libraryLateness) this.voice(clip, request.volume, request.pitch);
    });
  }

  /** Fetches a world's library sounds before they are needed. */
  prepare(world: WorldDocument): void {
    const ids = libraryIDsInWorld(world);
    if (!ids.length) return;
    if (!this.start()) return;
    // Four at a time, so a world full of sounds does not ask for sixty files at once.
    void inTurn(ids.slice(0, 60), 4, (id) => this.libraryClip(id));
  }

  private soundIndex(): Promise<Map<string, LibrarySound>> {
    this.index ??= fetch(fileURL('sounds/index.json', this.source))
      .then((r) => { if (!r.ok) throw new Error(`HTTP ${r.status}`); return r.json(); })
      .then((json) => decodeSoundIndex(json))
      .catch(() => { this.index = null; return new Map<string, LibrarySound>(); });
    return this.index;
  }

  private libraryClip(id: string): Promise<AudioBuffer | null> {
    const ready = this.library.get(id);
    if (ready) return Promise.resolve(ready);
    let loading = this.libraryLoading.get(id);
    if (!loading) {
      loading = this.fetchLibrary(id).finally(() => this.libraryLoading.delete(id));
      this.libraryLoading.set(id, loading);
    }
    return loading;
  }

  private async fetchLibrary(id: string): Promise<AudioBuffer | null> {
    const context = this.context;
    if (!context) return null;
    const sound = (await this.soundIndex()).get(id);
    if (!sound) return null;
    try {
      const response = await fetch(fileURL(`sounds/${sound.category}/${sound.id}.mp3`, this.source));
      if (!response.ok) return null;
      const bytes = await response.arrayBuffer();
      if (bytes.byteLength !== sound.bytes || bytes.byteLength > 4 * 1024 * 1024) return null;
      if (crypto.subtle) {
        const digest = new Uint8Array(await crypto.subtle.digest('SHA-256', bytes));
        const hex = [...digest].map((b) => b.toString(16).padStart(2, '0')).join('');
        if (hex !== sound.sha256) return null;
      }
      const decoded = await context.decodeAudioData(bytes);
      const seconds = Math.min(decoded.length, Math.trunc(decoded.sampleRate * 12));
      const mono = new Float32Array(seconds);
      const share = 1 / decoded.numberOfChannels;
      for (let c = 0; c < decoded.numberOfChannels; c++) {
        const channel = decoded.getChannelData(c);
        for (let i = 0; i < seconds; i++) mono[i] += channel[i] * share;
      }
      const tidy = tidyClip(mono, decoded.sampleRate);
      if (tidy.length <= 1) return null;
      const buffer = this.buffer(tidy, decoded.sampleRate);
      this.store(id, buffer);
      return buffer;
    } catch {
      return null;
    }
  }

  private store(id: string, buffer: AudioBuffer): void {
    this.library.set(id, buffer);
    this.libraryOrder.push(id);
    this.libraryBytes += buffer.length * 4;
    while (this.libraryBytes > cacheLimitBytes && this.libraryOrder.length > 1) {
      const oldest = this.libraryOrder.shift()!;
      const dropped = this.library.get(oldest);
      this.library.delete(oldest);
      if (dropped) this.libraryBytes -= dropped.length * 4;
    }
  }

  private touch(id: string): void {
    const i = this.libraryOrder.indexOf(id);
    if (i >= 0) { this.libraryOrder.splice(i, 1); this.libraryOrder.push(id); }
  }

  // MARK: Music

  /** A track on a loop, or no music with nil. Changing only the volume keeps it playing. */
  setMusic(request: MusicPlay | null | undefined): void {
    const track = request && isMusicTrack(request.track) ? request.track : null;
    const volume = request?.volume ?? 1;
    if (this.music && track === this.music.track) {
      this.music.gain.gain.setTargetAtTime(volume, this.context!.currentTime, 0.05);
      return;
    }
    this.stopMusic();
    if (!track || !this.settings.sound) return;
    const context = this.start();
    if (!context || !this.musicBus) return;
    let loop = this.musicLoops.get(track);
    if (!loop) {
      loop = this.buffer(renderMusicLoop(track, context.sampleRate), context.sampleRate);
      this.musicLoops.set(track, loop);
    }
    const node = context.createBufferSource();
    node.buffer = loop;
    node.loop = true;
    const gain = context.createGain();
    gain.gain.value = volume;
    node.connect(gain).connect(this.musicBus);
    node.start();
    this.music = { track, node, gain };
  }

  stopMusic(): void {
    if (!this.music) return;
    const { node, gain } = this.music;
    const context = this.context;
    if (context) {
      gain.gain.setTargetAtTime(0, context.currentTime, 0.08);
      try { node.stop(context.currentTime + 0.4); } catch { /* already stopped */ }
    }
    setTimeout(() => { node.disconnect(); gain.disconnect(); }, 600);
    this.music = null;
  }

  // MARK: Lines read aloud

  /** A character's line, read aloud when the player asked for it; Japanese text in a Japanese voice. */
  speak(text: string, volume = 1): void {
    const line = trimmed(text);
    if (!line || !this.settings.readLines || typeof speechSynthesis === 'undefined') return;
    speechSynthesis.cancel();
    const utterance = new SpeechSynthesisUtterance([...line].slice(0, 300).join(''));
    const japanese = /[぀-ヿ一-鿿]/.test(line);
    utterance.lang = japanese ? 'ja-JP' : navigator.language;
    utterance.volume = clamp01(volume);
    speechSynthesis.speak(utterance);
  }

  // MARK: Between games

  /** Clears the throttle between rounds, so the first coin of a new round is never swallowed. */
  reset(): void { this.throttle.reset(); }

  stopAll(): void {
    for (const v of this.voices) { try { v.stop(); } catch { /* over */ } }
    this.voices = [];
    this.stopMusic();
    if (typeof speechSynthesis !== 'undefined') speechSynthesis.cancel();
  }
}

const clamp01 = (v: number) => Math.max(0, Math.min(1, Number.isFinite(v) ? v : 1));

const canVibrate = typeof matchMedia === 'function' && matchMedia('(pointer: coarse)').matches;

function vibrate(feedback: Feedback): void {
  if (!canVibrate || typeof navigator === 'undefined' || !('vibrate' in navigator)) return;
  // Before the first tap the browser refuses, and says so in the console.
  const activation = (navigator as Navigator & { userActivation?: { hasBeenActive: boolean } }).userActivation;
  if (activation && !activation.hasBeenActive) return;
  const patterns: Record<Feedback, number | number[]> = {
    none: 0, light: 8, medium: 16, heavy: 30, success: [10, 50, 14], warning: [18, 60, 18], failure: [28, 50, 28],
  };
  const pattern = patterns[feedback];
  if (pattern) {
    try { navigator.vibrate(pattern); } catch { /* not allowed yet */ }
  }
}
