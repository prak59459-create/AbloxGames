// The play screen: a game running in this browser. It joins the pieces the
// iPad joins in PlayScreen.swift and GameViewport's Coordinator — the
// session (what the host says), the 3D view (where we are), the HUD (what
// is on screen) and the speakers — and runs the viewport's per-frame steps
// in the same order: move, report touches, apply what the host sent, aim
// and fire, publish where we are when peers could not have guessed it.
import type { AvatarProfile } from '../core/model/avatar';
import { emotes } from '../core/model/avatar';
import { distance, v3, type Vec3 } from '../core/model/math';
import { playerSnapshot, type PlayerSnapshot } from '../core/model/player';
import { TransformPublisher } from '../core/model/roster';
import type { EventAction } from '../core/model/rules';
import type { WorldDocument } from '../core/model/world';
import { SoundPlayer } from '../engine/audio';
import type { GraphicsLevel } from '../engine/scene';
import { L } from '../i18n';
import type { RoomRoute } from '../net/client';
import type { HostMove } from '../net/packets';
import type { RoomHost } from '../net/roomHost';
import { PlayHUD, type HUDHost, type HUDLayout, type WaypointView } from './hud';
import { RoomOverlay } from './roomUI';
import { PlaySession, gamePeerID } from './session';
import { PlayView, type RemotePlayer } from './view';

/** How a play screen begins: a game here, alone (it can be opened to others later), or someone else's room. */
export type PlayStart =
  | { kind: 'solo'; world: WorldDocument; openRoom?: boolean }
  | { kind: 'join'; route: RoomRoute; title: string };

/** What the screen needs from the internet side, when internet rooms are allowed. */
export interface PlayNetwork {
  /** A grown-up allowed internet rooms on this browser. */
  readonly allowsRooms: boolean;
  /** List a room this screen hosts (opened here, or moved here). */
  list(room: RoomHost, world: WorldDocument, profile: AvatarProfile): Promise<unknown> | void;
  /** Take it out of the list again. */
  unlist(): void;
  findMovedRoom(move: HostMove): Promise<RoomRoute | null>;
  /** A link into the internet room this browser is in (hosting or joined), or null. */
  inviteLink(): string | null;
}

/**
 * What playing adds to the player's record (the iPad's PlayScreen →
 * AppSettings calls). Each returns what to say about it: coins, a finished
 * mission, a new level.
 */
export interface PlayProgress {
  /** The first five seconds in front: the game counts as played. */
  started(): string[];
  played(seconds: number): string[];
  together(): string[];
  /** The round's score as coins, once a round. */
  roundOver(score: number, completed: boolean): string[];
  emote(): string[];
  picture(): string[];
  hosted(): string[];
}

interface PlaySettings { graphics: GraphicsLevel; autoJump: boolean; cameraFollows: boolean; names: boolean; firstPerson: boolean; layout: HUDLayout }

function loadSettings(): PlaySettings {
  const fallback: PlaySettings = { graphics: defaultGraphics(), autoJump: true, cameraFollows: true, names: true, firstPerson: false, layout: 'normal' };
  try {
    return { ...fallback, ...(JSON.parse(localStorage.getItem('ablox.play') ?? 'null') ?? {}) };
  } catch {
    return fallback;
  }
}

/** Phones and small tablets start at medium; anything with a big screen and many cores at high. */
function defaultGraphics(): GraphicsLevel {
  if (typeof navigator === 'undefined') return 'high';
  const cores = navigator.hardwareConcurrency ?? 4;
  const coarse = typeof matchMedia === 'function' && matchMedia('(pointer: coarse)').matches;
  if (coarse && cores <= 4) return 'low';
  if (coarse) return 'medium';
  return cores >= 4 ? 'high' : 'medium';
}

export class PlayScreen implements HUDHost {
  readonly session: PlaySession;
  readonly view: PlayView;
  readonly hud: PlayHUD;
  private settingsState = loadSettings();
  private publisher = new TransformPublisher();
  private elapsed = 0;
  private lastShot = -Infinity;
  private rosterSeen: PlayerSnapshot[] | null = null;
  private chatSeen = 0;
  private musicKey = '';
  private shakeSerial = 0;
  private paused = false;
  private typingCount = 0;
  private disposed = false;
  private visibility = () => {
    this.updatePause();
    if (document.visibilityState === 'visible') this.session.becameVisible();
  };
  private readonly room: RoomOverlay;
  private readonly start: PlayStart;
  // What has been counted for the player's record.
  private countedStart = false;
  private countedTogether = false;
  private bankedThisRound = false;
  private announcementSeen: unknown = null;
  private playClock: ReturnType<typeof setInterval> | null = null;
  onExit: () => void = () => {};
  /** Set before the first five seconds pass. */
  progress: PlayProgress | null = null;
  /** Hosting: the player chose to take everyone on to another game (the page behind picks which). */
  onTakeEveryone: (() => void) | null = null;
  /** Joined: the host took the room on to another game; what to count it as. */
  onNewWorld: ((world: WorldDocument) => PlayProgress | null) | null = null;
  private worldID: string | null = null;
  /** A block walked into, before the game hears of it; true when it was handled here (the Plaza's doors). */
  onTouch: ((blockID: string) => boolean) | null = null;
  /** What there was to say as the screen closed (the last round's coins), for the page behind it to show. */
  onParting: (lines: string[]) => void = () => {};
  private leaving = false;

  constructor(readonly container: HTMLElement, start: PlayStart | WorldDocument, readonly localPeerID: string, profile: AvatarProfile,
    readonly sound: SoundPlayer = new SoundPlayer(), readonly network: PlayNetwork | null = null) {
    this.start = 'kind' in start && (start.kind === 'solo' || start.kind === 'join') ? start : { kind: 'solo', world: start as WorldDocument };
    this.session = new PlaySession(localPeerID, profile);
    this.session.findMovedRoom = (move) => this.network?.findMovedRoom(move) ?? Promise.resolve(null);
    this.session.onHosting = (room) => {
      // The game goes on either way; the host is told the room is not on the internet.
      Promise.resolve(this.network?.list(room, this.session.world, this.session.profile)).catch((e: unknown) => {
        this.hud?.showToast(L("This room couldn't go on the internet: {}", (e as Error)?.message ?? String(e)), 6);
      });
      // A room that moved here was opened by someone else: only one opened here earns the bonus.
      if (!this.session.roomMove && this.start.kind === 'solo') queueMicrotask(() => this.say(this.progress?.hosted()));
    };
    const begin = this.start;
    if (begin.kind === 'solo') {
      this.session.startSolo(begin.world);
      if (begin.openRoom && network?.allowsRooms) this.session.openRoom();
    } else {
      this.session.joinRoom(begin.route);
    }
    const world = this.session.world;
    this.view = new PlayView(container, this.session.live, localPeerID, profile, {
      level: this.settingsState.graphics, autoJump: this.settingsState.autoJump,
      cameraFollows: this.settingsState.cameraFollows, showNames: this.settingsState.names,
    });
    this.view.preferFirstPerson = this.settingsState.firstPerson;
    this.hud = new PlayHUD(container, this.session, this);
    this.hud.setLayout(this.settingsState.layout);
    if (begin.kind === 'solo') this.worldID = world.id;
    this.room = new RoomOverlay(this.hud.root, this.session, {
      leave: () => this.leave(),
      roomTitle: () => (begin.kind === 'join' ? begin.title : this.session.world.name),
    });

    this.view.onTouched = (id) => { if (!this.onTouch?.(id)) this.session.report(id, 'touched'); };
    this.view.onTapped = (id) => this.session.report(id, 'tapped');
    this.view.onFell = () => this.view.respawnAtStart();
    this.view.onFrame = (dt) => this.beforeMoving(dt);
    this.view.onMoved = () => this.afterMoving();
    this.view.input.onKey = (k) => this.key(k);
    this.view.scene.onThunder = () => this.sound.play({ name: 'explosion', volume: 0.35, pitch: 0.5 });

    this.sound.attach(window);
    this.sound.prepare(world);
    document.addEventListener('visibilitychange', this.visibility);
    this.view.start();
    this.playClock = setInterval(() => this.countPlay(5), 5000);
  }

  // MARK: The player's record

  /** Time played, only while the game is in front and running (the iPad's playClock). */
  private countPlay(seconds: number): void {
    const p = this.progress;
    if (!p || document.visibilityState !== 'visible' || this.session.live !== this.view.live) return;
    const status = this.session.status.kind;
    if (status === 'connecting' || status === 'reconnecting' || this.session.isWaitingForHost) return;
    const said: string[] = [];
    if (!this.countedStart) {
      this.countedStart = true;
      said.push(...p.started());
    }
    said.push(...p.played(seconds));
    if (!this.countedTogether && !this.session.isSolo && this.session.people.length > 1) {
      this.countedTogether = true;
      said.push(...p.together());
    }
    this.say(said);
  }

  /** The round's score as coins: from the end-of-round banner (the one signal that reaches host and guests alike), or on leaving. */
  private bankCoins(completed: boolean): void {
    const score = this.session.localPlayer?.score;
    if (score === undefined || this.bankedThisRound || !this.progress) return;
    this.bankedThisRound = true;
    this.say(this.progress.roundOver(score, completed));
  }

  /** Counting starts again, for another game. */
  private newGame(progress: PlayProgress | null): void {
    this.progress = progress;
    this.countedStart = false;
    this.countedTogether = false;
    this.bankedThisRound = false;
    this.announcementSeen = null;
  }

  /** A party: everyone here goes on to `world` together, this browser still the host. */
  moveEveryoneTo(world: WorldDocument, progress: PlayProgress | null): boolean {
    if (!this.canTakeEveryone()) return false;
    this.bankCoins(false);
    this.sound.reset();
    if (!this.session.moveRoomTo(world)) return false;
    this.newGame(progress);
    this.worldID = world.id;
    this.hud.showToast(L('Everyone is coming to {}', world.name), 3);
    return true;
  }

  private say(lines: string[] | undefined): void {
    if (!lines?.length || this.disposed) return;
    if (this.leaving) { this.onParting(lines); return; }
    for (const line of lines) this.hud.showReward(line);
    if (lines.some((l) => /coin|コイン/i.test(l))) this.sound.play('coin');
  }

  // MARK: The frame

  private beforeMoving(dt: number): void {
    this.elapsed += dt;
    const s = this.session;
    // The host's world arrived (or arrived again, after a reconnect or the room moving).
    if (this.view.live !== s.live) {
      this.view.replaceWorld(s.live);
      this.sound.prepare(s.world);
      this.rosterSeen = null;
      this.musicKey = '';
      // A different game, not the same one again after a reconnect: counted as a game of its own.
      if (s.role !== 'offline' && s.world.id !== this.worldID) {
        if (this.worldID !== null) this.newGame(this.onNewWorld?.(s.world) ?? this.progress);
        this.worldID = s.world.id;
      }
    }
    const scripted = s.scripted;
    this.view.camera = scripted.camera;
    this.view.movement = scripted.movement;
    this.view.aiming = !!scripted.weapon;
    this.view.input.wantsPointerLock = !!scripted.weapon || this.view.cameraMode === 'first';
    if (!this.view.input.wantsPointerLock) this.view.input.releasePointer();

    // Who is here: arrivals, leavings and looks when the roster changes; positions every frame.
    if (s.roster !== this.rosterSeen) {
      this.rosterSeen = s.roster;
      this.view.setRoster(s.roster.map(remote));
    }
    for (const p of s.otherPlayers) this.view.moveRemote(p.peerID, p.position, p.yawDegrees);

    // Speech bubbles, for every line that is not the game's own.
    const log = s.chatLog;
    const lastID = log.length ? log[log.length - 1].id : 0;
    if (lastID !== this.chatSeen) {
      for (const line of log) {
        if (line.id <= this.chatSeen) continue;
        if (line.senderID !== gamePeerID && !line.privateWith && s.muteList.allows(line.senderID, s.localPeerID)) this.view.say(line.senderID, line.text);
      }
      this.chatSeen = lastID;
    }
  }

  private afterMoving(): void {
    const s = this.session;
    const scripted = s.scripted;
    const effects = s.drainEffects();
    if (effects.length) this.apply(effects);

    this.view.setWeapon(scripted.weapon?.model ?? null);
    if (this.view.input.firing && !this.hud.isMenuOpen) this.fireIfReady();
    if (scripted.shake.serial !== this.shakeSerial) {
      this.shakeSerial = scripted.shake.serial;
      this.view.shakeCamera(scripted.shake.strength, scripted.shake.seconds);
    }
    this.updateMusic();
    this.publishIfDue();
    this.hud.frame(this.waypoint());
    // The end-of-round banner: a goal reached or a round won.
    const a = s.announcement;
    if (a && a !== this.announcementSeen) {
      this.announcementSeen = a;
      if (a.message.includes('goal') || /win/i.test(a.message)) this.bankCoins(true);
    }
  }

  /** What the host told this player's body and screen to do. */
  private apply(effects: EventAction[]): void {
    for (const effect of effects) {
      switch (effect.type) {
        case 'teleportPlayer':
          this.view.teleport(effect.position);
          // A teleport is exactly what dead reckoning cannot predict: tell peers at once.
          this.publisher.reset();
          break;
        case 'bouncePlayer':
          this.view.bounce(effect.speed);
          this.publisher.reset();
          break;
        case 'playSound': this.sound.play(effect.name); break;
        case 'tint': this.view.tint(effect.blockID, effect.color, effect.duration); break;
        case 'move': this.view.moveBlock(effect.blockID, effect.offset, effect.duration); break;
        case 'script': {
          const e = effect.effect;
          switch (e.kind) {
            case 'sound': this.sound.play(e.sound); break;
            case 'particles': this.view.burst(e.burst); break;
            case 'speak': this.sound.speak(e.text, this.sound.effectsVolume); break;
            case 'tracer': this.view.spawnTracer(e.from, e.to); break;
            case 'launch': this.view.launch(e.velocity); this.publisher.reset(); break;
            case 'face': this.view.face(e.yawDegrees); this.publisher.reset(); break;
            case 'gesture': this.view.gesture(e.speaker, e.wire); break;
            default: break;
          }
          break;
        }
        default: break;
      }
    }
  }

  /** A shot when the weapon is ready. Only a request: the host checks the rate, the ammo and where we are. */
  private fireIfReady(): void {
    const scripted = this.session.scripted;
    const weapon = scripted.weapon;
    if (!scripted.canFire || !weapon) return;
    const interval = 1 / Math.max(weapon.fireRate, 0.2);
    if (this.elapsed - this.lastShot < interval) return;
    this.lastShot = this.elapsed;
    this.view.kick();
    const eyes = this.view.eyes;
    this.session.send({ kind: 'fire', origin: eyes, direction: this.view.aimDirection(weapon.range) });
  }

  private publishIfDue(): void {
    const v = this.view;
    const snap = { position: v.position, yawDegrees: v.yaw, velocity: v.velocity, isGrounded: v.grounded };
    if (!this.publisher.shouldPublish(snap, this.elapsed)) return;
    this.session.publishLocalTransform(playerSnapshot(this.localPeerID, {
      profile: this.session.localAppearance, position: { ...v.position }, yawDegrees: v.yaw, velocity: { ...v.velocity }, isGrounded: v.grounded,
    }));
  }

  /** The script's music, or the world's. */
  private updateMusic(): void {
    const scripted = this.session.scripted.music;
    const track = scripted ? scripted.track : this.session.world.environment.music ?? null;
    const volume = scripted ? scripted.volume : 1;
    const key = `${track}@${volume}@${this.sound.soundEnabled}`;
    if (key === this.musicKey) return;
    this.musicKey = key;
    this.sound.setMusic(track ? { track, volume } : null);
  }

  /** The script's arrow: a pin on the place, or an arrow round the edge of the screen. */
  private waypoint(): WaypointView | null {
    const w = this.session.scripted.waypoint;
    if (!w) return null;
    const target = v3(w.position.x, w.position.y + 1, w.position.z);
    const eye = this.view.eyePosition;
    const dir = this.view.viewDirection;
    const to = v3(target.x - eye.x, target.y - eye.y, target.z - eye.z);
    const length = Math.hypot(to.x, to.y, to.z);
    const away = distance(this.view.position, w.position);
    const width = this.container.clientWidth, height = this.container.clientHeight;
    const facing = to.x * dir.x + to.y * dir.y + to.z * dir.z;
    if (facing > 0.15 * length) {
      const at = this.view.scene.project(target);
      if (at && at.x > 40 && at.x < width - 40 && at.y > 60 && at.y < height - 60) {
        return { x: at.x, y: at.y, onScreen: true, angle: 0, distance: away, label: w.label };
      }
    }
    // Which way round the screen: right along the camera's right, up along its up.
    const right = normalize(v3(-dir.z, 0, dir.x));
    const up = cross(right, dir);
    const ax = to.x * right.x + to.y * right.y + to.z * right.z;
    const ay = to.x * up.x + to.y * up.y + to.z * up.z + (facing < 0 ? -0.001 : 0);
    const angle = Math.atan2(ax, ay);
    const rx = width / 2 - 56, ry = height / 2 - 72;
    const sx = Math.sin(angle), sy = -Math.cos(angle);
    const t = Math.min(rx / Math.max(Math.abs(sx), 1e-6), ry / Math.max(Math.abs(sy), 1e-6));
    return { x: width / 2 + sx * t, y: height / 2 + sy * t, onScreen: false, angle, distance: away, label: w.label };
  }

  // MARK: Keys

  private key(k: string): void {
    if (this.typingCount > 0) return;
    if (this.hud.key(k)) return;
    if (k === 'r') this.view.input.look.yaw = -this.view.yaw;
    if (['1', '2', '3', '4'].includes(k)) {
      // A favourite emote: the first four.
      const emote = emotes[Number(k) - 1];
      if (emote) this.gesture(emote);
    }
  }

  // MARK: HUDHost

  leave(handOver = false): void {
    // A host with others here can hand the room on instead of closing it on them.
    if (handOver) this.session.handOverAndLeave();
    this.dispose();
    this.onExit();
  }

  inviteLink(): string | null {
    return this.session.isInRoom ? this.network?.inviteLink() ?? null : null;
  }

  canTakeEveryone(): boolean {
    return !!this.onTakeEveryone && !!this.network?.allowsRooms && this.session.role === 'hosting' && !!this.session.room;
  }

  takeEveryone(): void { if (this.canTakeEveryone()) this.onTakeEveryone?.(); }

  canOpenRoom(): boolean {
    return !!this.network?.allowsRooms && this.session.role === 'hosting' && !this.session.room;
  }

  openRoom(): void {
    if (!this.canOpenRoom()) return;
    this.session.openRoom();
    this.hud.showToast(L('Your room is on the internet now'), 3);
  }

  /** Who would take the room on, if the host left now. */
  successorName(): string | null {
    if (!this.session.canHandOver) return null;
    return this.session.people.find((p) => p.peerID !== this.localPeerID)?.profile.displayName ?? null;
  }

  setMenuOpen(open: boolean): void {
    this.view.input.enabled = !open;
    if (open) {
      this.view.input.clearHeld();
      this.view.input.releasePointer();
    }
    this.updatePause();
  }

  private updatePause(): void {
    const paused = this.hud.isMenuOpen || document.visibilityState === 'hidden';
    if (paused === this.paused) return;
    this.paused = paused;
    this.session.setPaused(paused);
    if (paused) this.view.input.clearHeld();
  }

  pressButton(id: string): void { this.session.send({ kind: 'button', id }); }
  submitText(id: string, text: string): void { this.session.send({ kind: 'text', id, value: text }); }
  sendChat(text: string): void { this.session.sendChat(text); }
  gesture(wire: string): void {
    this.session.send({ kind: 'gesture', wire });
    if (!wire.startsWith('stamp:')) this.say(this.progress?.emote());
  }
  reload(): void { this.session.send({ kind: 'reload' }); }
  restartRound(): void {
    this.sound.reset();
    this.bankCoins(false);
    this.bankedThisRound = false;
    this.session.startNewRound();
  }

  takePicture(): void {
    this.view.scene.render();
    this.view.scene.canvas.toBlob((blob) => {
      if (!blob) return;
      const a = document.createElement('a');
      const stamp = new Date().toISOString().slice(0, 19).replace(/[:T]/g, '-');
      a.download = `Ablox ${this.session.world.name} ${stamp}.png`;
      a.href = URL.createObjectURL(blob);
      a.click();
      setTimeout(() => URL.revokeObjectURL(a.href), 4000);
      this.sound.play('click');
      this.hud.showToast(L('Picture saved'));
      this.say(this.progress?.picture());
    }, 'image/png');
  }

  setJump(held: boolean): void { this.view.input.jumpHeld = held; }
  setFire(held: boolean): void { this.view.input.fireButton = held; }

  setFirstPerson(on: boolean): void {
    this.view.preferFirstPerson = on;
    this.change({ firstPerson: on });
  }

  firstPerson(): boolean { return this.view.preferFirstPerson; }

  setting(name: Parameters<HUDHost['setting']>[0], value: number | boolean | string): void {
    switch (name) {
      case 'effects': this.sound.effectsVolume = Number(value); break;
      case 'music': this.sound.musicVolume = Number(value); break;
      case 'sound': this.sound.soundEnabled = Boolean(value); this.musicKey = ''; break;
      case 'readLines': this.sound.readsLines = Boolean(value); break;
      case 'graphics': this.view.setGraphics(value as GraphicsLevel); this.change({ graphics: value as GraphicsLevel }); break;
      case 'autoJump': this.view.options.autoJump = Boolean(value); this.change({ autoJump: Boolean(value) }); break;
      case 'cameraFollows': this.view.options.cameraFollows = Boolean(value); this.change({ cameraFollows: Boolean(value) }); break;
      case 'names': this.view.scene.overlays.showNames = Boolean(value); this.change({ names: Boolean(value) }); break;
      case 'layout': this.hud.setLayout(value as HUDLayout); this.change({ layout: value as HUDLayout }); break;
    }
  }

  settings() {
    return {
      effects: this.sound.effectsVolume, music: this.sound.musicVolume, sound: this.sound.soundEnabled, readLines: this.sound.readsLines,
      graphics: this.view.options.level, autoJump: this.view.options.autoJump, cameraFollows: this.view.options.cameraFollows,
      names: this.view.scene.overlays.showNames, layout: this.settingsState.layout,
    };
  }

  typing(on: boolean): void {
    this.typingCount = Math.max(0, this.typingCount + (on ? 1 : -1));
    this.view.input.enabled = this.typingCount === 0 && !this.hud.isMenuOpen;
    if (on) this.view.input.clearHeld();
  }

  private change(patch: Partial<PlaySettings>): void {
    this.settingsState = { ...this.settingsState, ...patch };
    try { localStorage.setItem('ablox.play', JSON.stringify(this.settingsState)); } catch { /* private mode */ }
  }

  dispose(): void {
    if (this.disposed) return;
    this.leaving = true;
    this.bankCoins(false);
    this.disposed = true;
    if (this.playClock) clearInterval(this.playClock);
    document.removeEventListener('visibilitychange', this.visibility);
    this.room.dispose();
    this.session.leave();
    this.network?.unlist();
    this.sound.stopAll();
    this.sound.detach();
    this.hud.dispose();
    this.view.dispose();
  }
}

const remote = (p: PlayerSnapshot): RemotePlayer => ({
  id: p.peerID, profile: p.profile, position: p.position, yaw: p.yawDegrees, isNPC: p.isNPC, isHidden: p.isHidden, team: p.team, score: p.score,
});

const normalize = (a: Vec3): Vec3 => {
  const l = Math.hypot(a.x, a.y, a.z) || 1;
  return v3(a.x / l, a.y / l, a.z / l);
};
const cross = (a: Vec3, b: Vec3): Vec3 => normalize(v3(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x));
