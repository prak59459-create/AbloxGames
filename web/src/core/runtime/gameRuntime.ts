// Everything the host decides about a game in progress — the world's rules
// (EventMachine) and its .absc scripts — AbloxCore/GameRuntime.swift.
//
// No clock and no network: time and inputs go in, and out come effects for
// players' screens, world deltas for everyone's copy of the map, NPC
// movement and a flag saying the roster changed. The script API itself is in
// api.ts, the ready-made parts in parts.ts.
import { L } from '../../i18n';
import { ArmedState, Hitscan, PlayerHitBody, weaponPresets, type HitResult, type WeaponSpec } from '../model/combat';
import { clone, deepEqual } from '../model/equal';
import { Leaderboard, normalMovement, standardCamera, type ScriptEffect, type UIElement } from '../model/effects';
import { LiveWorld, type WorldDelta } from '../model/liveWorld';
import { add, distance, f32v, lengthSquared, sameVec, v3, type Vec3 } from '../model/math';
import { travelEnd, travelPosition, type BlockTravel } from '../model/motion';
import {
  copySnapshot, parseGesture, playerSnapshot, sameProfile, transformOf, gestureInterval,
  type PlayerInput, type PlayerSnapshot, type PlayerTransform,
} from '../model/player';
import type { AvatarProfile } from '../model/avatar';
import { prefix } from '../model/text';
import { hasScript, type ScriptFile, type WorldDocument } from '../model/world';
import { resolve as resolveCollision, defaultMovement } from '../physics/collider';
import type { WorldIndex } from '../physics/worldIndex';
import { ScriptInterpreter, defaultLimits, type ScriptLimits, type ScriptObjectResolver } from '../script/interpreter';
import { ScriptError, ScriptLocation } from '../script/lexer';
import { standardLibraryNames } from '../script/stdlib';
import { ScriptObject, ScriptRandom, type ScriptScope, type ScriptValue } from '../script/values';
import { installGameAPI, member as apiMember, setMember as apiSetMember } from './api';
import { checkScripts, checkSource, compileScripts } from './bundle';
import { EventMachine, type Effect, type Observation } from './eventMachine';
import { defaultSettings, gameAPINames, RuntimeLimits, type RuntimeEvent } from './limits';
import { BlockLookup } from './lookup';
import { handleReserved, partsTouched, advanceCountdowns } from './parts';
import { flushSaves, receiveSave } from './saves';
import { parseReservedButton } from '../model/effects';
import { PlayerState, type HandlerCost, type ScriptTimer } from './state';

export type { Effect, Observation };

const golden = 0x9e3779b97f4a7c15n;

export class GameRuntime implements ScriptObjectResolver {
  machine: EventMachine;
  settings = defaultSettings();
  /** Syntax errors, one per broken file. The rules still run. */
  compileErrors: ScriptError[] = [];
  hasStarted = false;

  interpreter: ScriptInterpreter | null = null;
  fileNames: string[] = [];
  states = new Map<string, PlayerState>();
  joinCounter = 0;
  clock: number;
  roundStartedAt = 0;
  lineWatch: { lines: Set<number>; found: (line: number, scope: ScriptScope, builtins: Set<string>) => void } | null = null;
  /** Studio's profiler: what each handler and timer cost. */
  measuresCosts = false;
  handlerCosts = new Map<string, HandlerCost>();
  /** Seconds since 1970: the day and moving platforms are counted on it. */
  wallClock: () => number = () => Date.now() / 1000;
  /** Where `today()` is read; undefined for the browser's own. */
  timeZone: string | undefined;
  lastTick: number | null = null;
  lastNPCStep: number | null = null;
  timers: ScriptTimer[] = [];
  nextTimerID = 1;
  weapons = new Map<string, WeaponSpec>(Object.entries(weaponPresets));
  globalUI = new Map<string, UIElement>();
  globalUIOrder: string[] = [];
  lastTouch = new Map<string, number>();
  random: ScriptRandom;
  readonly seed: bigint;
  readonly scriptLimits: ScriptLimits;
  /** The world before any script touched it, so a restart starts from the real map. */
  readonly originalWorld: WorldDocument;
  pendingRestart = false;
  /** Animated moves whose end position has not yet been sent to everyone. */
  deferredUpdates: { due: number; blockID: string }[] = [];
  /** The same moves, for bringing someone who joins halfway up to date. */
  travels = new Map<string, BlockTravel>();

  pending: Effect[] = [];
  pendingDeltas: WorldDelta[] = [];
  npcTransforms = new Map<string, PlayerTransform>();
  rosterChanged = false;
  newErrors: ScriptError[] = [];
  leaderboards = new Map<string, Leaderboard>();
  leaderboardsChanged = false;
  countdowns: { label: string; due: number; peer?: string }[] = [];
  lastPush = new Map<string, number>();
  reportedErrors = new Set<string>();
  output: string[] = [];
  /** Teams the host picked, kept across rounds. */
  hostTeams = new Map<string, string>();
  lookupCache: BlockLookup | null = null;

  constructor(world: WorldDocument, startTime = 0, seed: bigint | number = 1n, limits: ScriptLimits = defaultLimits()) {
    this.machine = new EventMachine(clone(world), startTime);
    this.originalWorld = clone(world);
    this.clock = startTime;
    this.seed = BigInt.asUintN(64, BigInt(seed));
    this.scriptLimits = limits;
    this.random = new ScriptRandom(this.seed ^ golden);
  }

  get world(): WorldDocument { return this.machine.world; }
  get live(): LiveWorld { return this.machine.live; }
  get worldIndex(): WorldIndex { return this.machine.live.currentIndex(); }
  get players(): Map<string, PlayerSnapshot> { return this.machine.players; }
  get isRoundOver(): boolean { return this.machine.isRoundOver; }
  get isScriptRunning(): boolean { return this.interpreter !== null; }

  /** Everyone to draw: people, then NPCs, with the script's hidden flags and teams. */
  get roster(): PlayerSnapshot[] {
    const list = this.machine.roster.map((s) => {
      const copy = copySnapshot(s);
      const state = this.states.get(s.peerID);
      copy.isHidden = state?.isHidden ?? false;
      copy.team = state?.team ?? '';
      return copy;
    });
    for (const state of this.orderedStates) {
      if (!state.isNPC || !state.body) continue;
      const body = copySnapshot(state.body);
      body.isNPC = true;
      body.isHidden = state.isHidden;
      body.team = state.team;
      list.push(body);
    }
    return list;
  }

  // MARK: Roster

  /** Adds a player, or updates the look of one already here. */
  addPlayer(snapshot: PlayerSnapshot): Effect[] {
    return this.collect(() => {
      const existing = this.states.get(snapshot.peerID);
      if (existing) {
        this.machine.updateProfile(snapshot.profile, snapshot.peerID);
        existing.name = snapshot.profile.displayName;
        existing.originalProfile = snapshot.profile;
        return;
      }
      this.machine.addPlayer(snapshot);
      const state = new PlayerState(snapshot.peerID, this.joinCounter, snapshot.profile.displayName, snapshot.profile);
      this.joinCounter++;
      this.states.set(snapshot.peerID, state);
      if (!this.hasStarted || this.isRoundOver) return;
      this.welcome(state, true);
    });
  }

  removePlayer(peer: string): Effect[] {
    return this.collect(() => {
      const state = this.states.get(peer);
      if (state && this.hasStarted && !this.isRoundOver) this.run('leave', [this.object(state)]);
      this.machine.removePlayer(peer);
      this.states.delete(peer);
      for (const key of [...this.lastTouch.keys()]) if (key.startsWith(peer + '|')) this.lastTouch.delete(key);
    });
  }

  updateTransform(t: PlayerTransform): void {
    // NPCs are the host's own; nobody else may move them.
    if (this.states.get(t.peerID)?.isNPC) return;
    this.machine.updateTransform(t);
  }

  // MARK: Observations and time

  handle(observation: Observation): Effect[] {
    return this.collect(() => {
      this.pending.push(...this.machine.handle(observation));
      switch (observation.kind) {
        case 'roundStarted': this.beginRound(); break;
        case 'touched': {
          const state = this.states.get(observation.peer);
          if (this.hasStarted && !this.isRoundOver && state) this.touched(state, observation.blockID);
          break;
        }
        case 'tapped': {
          const state = this.states.get(observation.peer);
          if (!this.hasStarted || this.isRoundOver || !state || !this.live.block(observation.blockID)) return;
          this.run('tap', [this.object(state), this.blockObject(observation.blockID)]);
          break;
        }
        default: break;
      }
    });
  }

  advance(time: number): Effect[] {
    return this.collect(() => {
      this.clock = Math.max(this.clock, time);
      if (this.pendingRestart) {
        this.pendingRestart = false;
        this.pending.push(...this.machine.handle({ kind: 'roundStarted' }));
        this.beginRound();
        return;
      }
      this.pending.push(...this.machine.advance(time));
      this.flushDeferredUpdates();
      // Before the round-over check: what was saved as a round ended still has to arrive.
      flushSaves(this);
      if (!this.hasStarted || this.isRoundOver) return;

      for (const state of this.orderedStates) {
        if (state.armed?.advance(this.clock)) this.sendAmmo(state);
        if (!state.isAlive && state.respawnAt !== null && this.clock >= state.respawnAt) this.respawn(state);
      }

      this.stepNPCs();
      this.runDueTimers();
      advanceCountdowns(this);
      if (this.isRoundOver) return;

      const delta = this.clock - (this.lastTick ?? this.clock);
      this.lastTick = this.clock;
      this.run('tick', [delta]);
    });
  }

  /** A press from a player. The host checks it; nothing here is believed as a result. */
  handleInput(input: PlayerInput, peer: string, time: number): Effect[] {
    return this.collect(() => {
      this.clock = Math.max(this.clock, time);
      const state = this.states.get(peer);
      // Saved data is kept even between rounds.
      if (input.kind === 'saved') {
        if (state && !state.isNPC) receiveSave(this, input.data, state);
        return;
      }
      // Waving works between rounds too: waving at the end is half the point.
      if (input.kind === 'gesture') {
        const gesture = parseGesture(input.wire);
        if (!state || state.isNPC || !gesture || this.clock - state.lastGesture < gestureInterval) return;
        state.lastGesture = this.clock;
        this.pending.push(this.broadcast({ type: 'script', effect: { kind: 'gesture', speaker: peer, wire: gesture.wire } }));
        if (this.hasStarted && !this.isRoundOver) this.run('emote', [this.object(state), gesture.wire]);
        return;
      }
      if (!this.hasStarted || this.isRoundOver || !state || state.isNPC) return;
      switch (input.kind) {
        case 'fire': this.fire(state, input.origin, input.direction); break;
        case 'button': {
          const reserved = parseReservedButton(input.id);
          if (reserved) { handleReserved(this, reserved, state); return; }
          // Only a button that player can see: otherwise anyone could press the winner's.
          if (this.element(input.id, state)?.kind !== 'button') return;
          this.run('button', [this.object(state), input.id]);
          break;
        }
        case 'text':
          if (this.element(input.id, state)?.kind !== 'input') return;
          this.run('input', [this.object(state), input.id, prefix(input.value, 500)]);
          break;
        case 'reload':
          if (!state.isAlive || !state.armed?.startReload(this.clock)) return;
          this.sendAmmo(state);
          this.send(state, { type: 'playSound', name: 'reload' });
          break;
      }
    });
  }

  /** A chat message, for `on chat(p, text)`: commands, passwords, quizzes. */
  handleChat(peer: string, text: string): Effect[] {
    return this.collect(() => {
      const state = this.states.get(peer);
      if (!this.hasStarted || this.isRoundOver || !state) return;
      this.run('chat', [this.object(state), prefix(text, 240)]);
    });
  }

  apply(delta: WorldDelta): void {
    this.forgetLookup(delta);
    this.machine.apply(delta);
  }

  // MARK: What the host sends on

  drainWorldDeltas(): WorldDelta[] {
    const out = this.pendingDeltas;
    this.pendingDeltas = [];
    return out;
  }

  drainNPCTransforms(): PlayerTransform[] {
    const out = [...this.npcTransforms.values()].sort((a, b) => (a.peerID < b.peerID ? -1 : a.peerID > b.peerID ? 1 : 0));
    this.npcTransforms.clear();
    return out;
  }

  /** True once after anyone's name, look or visibility changed, or an NPC came or went. */
  takeRosterChange(): boolean {
    const changed = this.rosterChanged;
    this.rosterChanged = false;
    return changed;
  }

  assignTeams(teams: Map<string, string>): void {
    for (const [peer, team] of teams) {
      const name = prefix(team, 32);
      if (name) this.hostTeams.set(peer, name); else this.hostTeams.delete(peer);
      const state = this.states.get(peer);
      if (!state || state.isNPC) continue;
      state.team = name;
      this.rosterChanged = true;
    }
  }

  // MARK: Diagnostics

  drainErrors(): ScriptError[] {
    const out = this.newErrors;
    this.newErrors = [];
    return out;
  }

  drainOutput(): string[] {
    if (this.interpreter) this.output.push(...this.interpreter.drainOutput());
    const out = this.output;
    this.output = [];
    return out;
  }

  static check(files: ScriptFile[]): ScriptError[] { return checkScripts(files); }
  static checkSource(source: string): ScriptError[] { return checkSource(source); }

  // MARK: Round

  beginRound(): void {
    const isRestart = this.hasStarted;
    if (this.interpreter) this.output.push(...this.interpreter.drainOutput());

    this.hasStarted = true;
    this.roundStartedAt = this.clock;
    this.lastTick = this.clock;
    this.lastNPCStep = this.clock;
    this.timers = [];
    this.globalUI.clear();
    this.globalUIOrder = [];
    this.lastTouch.clear();
    this.deferredUpdates = [];
    this.travels.clear();
    this.settings = defaultSettings();
    this.weapons = new Map(Object.entries(weaponPresets));

    for (const state of this.orderedStates) {
      if (!state.isNPC) continue;
      this.states.delete(state.peer);
      this.rosterChanged = true;
    }
    for (const state of this.states.values()) {
      if (!sameProfile(state.profile, state.originalProfile) || state.isHidden) {
        this.machine.updateProfile(state.originalProfile, state.peer);
        this.rosterChanged = true;
      }
      state.reset();
      // Teams the host picked outlast the round; a script's own start again.
      const team = this.hostTeams.get(state.peer);
      if (team !== undefined) {
        state.team = team;
        this.rosterChanged = true;
      }
    }

    if (isRestart) {
      this.restoreOriginalWorld();
      // Whatever the last round put on screens and in hands goes.
      this.countdowns = [];
      this.lastPush.clear();
      const resets: ScriptEffect[] = [
        { kind: 'clearUI' }, { kind: 'camera', camera: standardCamera() }, { kind: 'equip' }, { kind: 'movement', movement: normalMovement() },
        { kind: 'interface', controls: true, defaultUI: true }, { kind: 'fade', seconds: 0 }, { kind: 'inventory', items: [] },
        { kind: 'dialog' }, { kind: 'shop' }, { kind: 'countdown' }, { kind: 'leaderboard' }, { kind: 'waypoint' },
        { kind: 'music' }, { kind: 'vehicle', riding: false },
      ];
      for (const effect of resets) this.pending.push(this.broadcast({ type: 'script', effect }));
    }

    this.startTheDay();
    this.loadScript();
    this.run('start', []);
    for (const state of this.orderedStates) {
      if (this.isRoundOver || state.isNPC) continue;
      this.welcome(state, false);
      // Saved data survives a restart; `on loaded` runs again so the new round reads it the same way.
      if (state.saved !== null && !this.isRoundOver) this.run('loaded', [this.object(state)]);
    }
  }

  /** A world that keeps time starts its day now, on everyone's clock. */
  private startTheDay(): void {
    const environment = structuredClone(this.world.environment);
    if (environment.timeOfDay === undefined || !(environment.dayLengthMinutes > 0)) return;
    environment.dayEpoch = this.wallClock();
    this.queue({ type: 'environment', environment });
  }

  /** Puts back every block and setting a script changed, as deltas. */
  private restoreOriginalWorld(): void {
    const current = new Map(this.world.blocks.map((b) => [b.id, b] as const));
    const originalIDs = new Set(this.originalWorld.blocks.map((b) => b.id));
    for (const id of current.keys()) if (!originalIDs.has(id)) this.queue({ type: 'remove', blockID: id });
    for (const block of this.originalWorld.blocks) {
      const now = current.get(block.id);
      if (now) {
        if (!deepEqual(now, block)) this.queue({ type: 'update', block: clone(block) });
      } else {
        this.queue({ type: 'insert', block: clone(block) });
      }
    }
    if (!deepEqual(this.world.environment, this.originalWorld.environment)) {
      this.queue({ type: 'environment', environment: clone(this.originalWorld.environment) });
    }
  }

  private loadScript(): void {
    this.interpreter = null;
    this.compileErrors = [];
    this.fileNames = [];
    if (!hasScript(this.world)) return;

    const compiled = compileScripts(this.world.scripts);
    if (!compiled.ok) {
      this.compileErrors = compiled.errors;
      for (const e of compiled.errors) this.report(e);
      return;
    }
    this.fileNames = compiled.fileNames;
    const interpreter = new ScriptInterpreter(compiled.program, this.seed, this.scriptLimits);
    interpreter.resolver = this;
    installGameAPI(this, interpreter);
    this.interpreter = interpreter;
    const watch = this.lineWatch;
    if (watch) {
      interpreter.watchedLines = watch.lines;
      const builtins = new Set([...gameAPINames, ...standardLibraryNames]);
      interpreter.onWatchedLine = (line, scope) => watch.found(line, scope, builtins);
    }
    try {
      interpreter.start();
    } catch (error) {
      // The top level failed part-way; handlers may still work, so the script stays loaded.
      this.report(error);
    }
  }

  /** Someone arriving: the shared screen items they missed, then `on join`. */
  private welcome(state: PlayerState, replayingScreen: boolean): void {
    if (replayingScreen) {
      for (const id of this.globalUIOrder) {
        const element = this.globalUI.get(id);
        if (element) this.send(state, { type: 'script', effect: { kind: 'ui', element } });
      }
    }
    this.run('join', [this.object(state)]);
  }

  touched(state: PlayerState, blockID: string): void {
    // The no-script parts that need the player: vehicles and pushing.
    partsTouched(this, state, blockID);
    if (!this.hasHandler('touch') || !state.isAlive || !this.live.block(blockID)) return;
    const key = state.peer + '|' + blockID;
    const last = this.lastTouch.get(key);
    if (last !== undefined && this.clock - last < RuntimeLimits.touchInterval) return;
    this.lastTouch.set(key, this.clock);
    this.run('touch', [this.object(state), this.blockObject(blockID)]);
  }

  // MARK: Combat

  fire(state: PlayerState, origin: Vec3, direction: Vec3): void {
    const armed = state.armed;
    const feet = this.position(state);
    if (!state.isAlive || !armed || !feet) return;
    armed.advance(this.clock);
    const refusal = armed.refusal(this.clock, origin, direction, feet, state.profile.height);
    if (refusal) {
      // The client thought it could shoot; show it why not.
      if (refusal === 'reloading') this.sendAmmo(state);
      return;
    }
    armed.shoot(this.clock);

    const aimed = Hitscan.spread(direction, armed.weapon.spread, () => this.random.unit());
    const result = this.cast(origin, aimed, armed.weapon.range, state.peer);

    this.pending.push(this.broadcast({ type: 'script', effect: { kind: 'tracer', from: { ...origin }, to: result.point } }));
    this.send(state, { type: 'playSound', name: 'shoot' });
    this.sendAmmo(state);
    if (armed.isReloading) this.send(state, { type: 'playSound', name: 'reload' });

    this.run('fire', [this.object(state)]);

    if (result.target.kind === 'player') {
      const victim = this.states.get(result.target.peer);
      if (victim) this.hit(victim, state, armed.weapon.damage);
    } else if (result.target.kind === 'block') {
      this.run('hit_block', [this.object(state), this.blockObject(result.target.id)]);
    }
  }

  /** A ray through the world, against every standing character and every solid block. */
  cast(origin: Vec3, direction: Vec3, range: number, shooter: string | null): HitResult {
    const targets: { peer: string; position: Vec3 }[] = [];
    const sizes = new Map<string, number>();
    for (const other of this.states.values()) {
      if (!other.isAlive || other.peer === shooter) continue;
      const feet = this.position(other);
      if (!feet) continue;
      targets.push({ peer: other.peer, position: feet });
      sizes.set(other.peer, other.profile.height);
    }
    return Hitscan.cast(origin, direction, range, shooter ?? '', targets, this.solidBlocks(), sizes);
  }

  private hit(victim: PlayerState, attacker: PlayerState, damage: number): void {
    if (!victim.isAlive) return;
    if (!this.settings.friendlyFire && victim.team && victim.team === attacker.team) return;
    let amount = damage;
    // `on hit` may change the damage by returning a number: 0 cancels it.
    const returned = this.run('hit', [this.object(victim), this.object(attacker), damage]);
    if (typeof returned === 'number' && Number.isFinite(returned)) amount = returned;
    if (!(amount > 0) || !victim.isAlive) return;
    const knockedOut = this.applyDamage(amount, victim, attacker);
    this.send(attacker, { type: 'script', effect: { kind: 'hitMarker', killed: knockedOut } });
    this.send(attacker, { type: 'playSound', name: 'hit' });
  }

  /** True when the damage knocked them out. */
  applyDamage(amount: number, victim: PlayerState, attacker: PlayerState | null): boolean {
    if (!victim.isAlive || !(amount > 0)) return false;
    victim.health = Math.max(0, victim.health - amount);
    this.sendHealth(victim);
    this.send(victim, { type: 'script', effect: { kind: 'damageFlash' } });
    this.send(victim, { type: 'playSound', name: 'hurt' });
    if (victim.health <= 0) {
      this.knockOut(victim, attacker);
      return true;
    }
    return false;
  }

  knockOut(victim: PlayerState, attacker: PlayerState | null): void {
    if (!victim.isAlive) return;
    victim.isAlive = false;
    victim.health = 0;
    victim.respawnAt = this.settings.respawnTime >= 0 && !victim.isNPC ? this.clock + this.settings.respawnTime : null;
    this.sendHealth(victim);
    this.send(victim, { type: 'script', effect: { kind: 'movement', movement: { speed: 0, jump: 0, gravity: victim.movement.gravity, frozen: true } } });
    this.send(victim, { type: 'playSound', name: 'defeat' });
    this.run('death', [this.object(victim), attacker ? this.object(attacker) : null]);
    // An NPC that stays down after its `on death` is gone.
    if (victim.isNPC && !victim.isAlive && this.states.has(victim.peer)) this.removeNPC(victim);
  }

  respawn(state: PlayerState): void {
    state.isAlive = true;
    state.respawnAt = null;
    state.health = state.maxHealth;
    if (state.armed) state.armed = new ArmedState(state.armed.weapon);
    const home = state.isNPC ? state.home ?? v3() : this.machine.respawnPoint(state.peer);
    this.teleport(state, home);
    this.sendHealth(state);
    this.send(state, { type: 'script', effect: { kind: 'movement', movement: { ...state.movement } } });
    if (state.armed) this.sendAmmo(state);
    this.run('respawn', [this.object(state)]);
  }

  solidBlocks(): { id: string; bounds: { min: Vec3; max: Vec3 } }[] {
    return this.worldIndex.solidBlocks;
  }

  // MARK: NPCs

  /** Walks every NPC toward its goal with the players' own collision. */
  private stepNPCs(): void {
    const step = Math.min(this.clock - (this.lastNPCStep ?? this.clock), 0.1);
    this.lastNPCStep = this.clock;
    if (!(step > 0)) return;
    const config = defaultMovement();
    const gravityScale = this.worldGravityScale;
    const index = this.worldIndex;

    for (const state of this.orderedStates) {
      if (!state.isNPC || !state.body) continue;
      const body = state.body;
      const still = !state.isAlive || state.movement.frozen;

      // In 32-bit floats, as the iPad works it out: an NPC arriving exactly
      // at the stopping distance must stop, or not, on both.
      const f = Math.fround;
      let desired = v3();
      const target = still ? null : this.goalPosition(state);
      if (target) {
        const ox = f(target.x - body.position.x), oz = f(target.z - body.position.z);
        const length = f(Math.sqrt(f(f(ox * ox) + f(oz * oz))));
        const arrive = state.isFollowing ? 1.6 : 0.25;
        if (length > f(arrive)) {
          const speed = f(config.walkSpeed * state.movement.speed);
          desired = length > 1e-6 ? v3(f(f(ox / length) * speed), 0, f(f(oz / length) * speed)) : v3();
        } else if (!state.isFollowing) {
          state.goal = { kind: 'none' };
        }
      }

      const velocity = v3(desired.x, body.velocity.y, desired.z);
      if (state.wantsJump && body.isGrounded && !still) velocity.y = f(config.jumpSpeed * state.movement.jump);
      else velocity.y = Math.max(config.maxFallSpeed, f(velocity.y + f(f(f(config.gravity * f(gravityScale)) * state.movement.gravity) * f(step))));
      state.wantsJump = false;

      const size = state.profile.height;
      const raw = resolveCollision(body.position, velocity, { radius: f(0.4 * size), height: f(1.8 * size), stepHeight: f(0.45) }, index, f(step));
      const result = { ...raw, position: f32v(raw.position), velocity: f32v(raw.velocity) };
      // Walking into a step it cannot climb: hop, as a player would.
      const wanted = Math.hypot(desired.x, desired.z);
      const got = Math.hypot(result.velocity.x, result.velocity.z);
      if (wanted > 0.5 && got < wanted * 0.3 && result.isGrounded) state.wantsJump = true;

      const moved = distance(result.position, body.position) > 0.005;
      body.position = result.position;
      body.velocity = result.velocity;
      body.isGrounded = result.isGrounded;
      if (lengthSquared(desired) > 0.01) body.yawDegrees = (Math.atan2(desired.x, -desired.z) * 180) / Math.PI;
      if (moved || state.needsTransformSend) {
        this.npcTransforms.set(state.peer, transformOf(body));
        state.needsTransformSend = false;
      }

      for (const id of result.touched) this.touched(state, id);

      if (body.position.y < this.world.environment.killPlaneHeight && state.isAlive) this.knockOut(state, null);
    }
  }

  private goalPosition(state: PlayerState): Vec3 | null {
    switch (state.goal.kind) {
      case 'none': return null;
      case 'point': return state.goal.point;
      case 'character': {
        const other = this.states.get(state.goal.peer);
        return other && other.isAlive ? this.position(other) : null;
      }
    }
  }

  /** The world's gravity against Earth's, for movement tuned at 1 g. */
  get worldGravityScale(): number {
    const s = this.world.environment.gravity / -9.81;
    return Number.isFinite(s) ? Math.min(Math.max(s, 0), 5) : 1;
  }

  removeNPC(state: PlayerState): void {
    if (!state.isNPC) return;
    this.states.delete(state.peer);
    this.npcTransforms.delete(state.peer);
    for (const key of [...this.lastTouch.keys()]) if (key.startsWith(state.peer + '|')) this.lastTouch.delete(key);
    this.rosterChanged = true;
  }

  // MARK: Timers

  private runDueTimers(): void {
    const due = this.timers.filter((t) => t.due <= this.clock).sort((a, b) => a.due - b.due).map((t) => t.id);
    for (const id of due) {
      if (this.isRoundOver) continue;
      const i = this.timers.findIndex((t) => t.id === id);
      if (i < 0) continue;
      const timer = this.timers[i];
      if (timer.interval !== null) {
        const next = timer.due + timer.interval;
        timer.due = next > this.clock ? next : this.clock + timer.interval;
      } else {
        this.timers.splice(i, 1);
      }
      const interpreter = this.interpreter;
      if (!interpreter) continue;
      const steps = interpreter.totalSteps;
      const started = this.measuresCosts ? performance.now() : 0;
      try {
        interpreter.invoke(timer.callback, [], timer.line);
      } catch (error) {
        this.report(error);
      }
      if (this.measuresCosts) {
        const file = ScriptLocation.file(timer.line);
        this.recordCost(L('timer at {}:{}', file !== undefined && file < this.fileNames.length ? this.fileNames[file] : '', ScriptLocation.line(timer.line)),
          steps, started);
      }
    }
  }

  /** Sends where blocks ended up once their animated move is over. */
  private flushDeferredUpdates(): void {
    if (!this.deferredUpdates.length) return;
    const due = this.deferredUpdates.filter((d) => d.due <= this.clock);
    this.deferredUpdates = this.deferredUpdates.filter((d) => !(d.due <= this.clock));
    for (const [id, travel] of [...this.travels]) if (!(travelEnd(travel) > this.clock)) this.travels.delete(id);
    for (const item of due) {
      const block = this.live.block(item.blockID);
      if (block) this.pendingDeltas.push({ type: 'update', block: clone(block) });
    }
  }

  // MARK: Sending state to players

  sendAmmo(state: PlayerState): void {
    const armed = state.armed;
    if (!armed) return;
    this.send(state, { type: 'script', effect: { kind: 'ammo', current: armed.ammo, magazine: armed.weapon.magazine, reloading: armed.isReloading } });
  }

  sendHealth(state: PlayerState): void {
    this.send(state, { type: 'script', effect: { kind: 'health', current: state.health, maximum: state.maxHealth } });
  }

  /** An effect for one person. NPCs have no screen, so theirs go nowhere. */
  send(state: PlayerState, action: Effect['action']): void {
    if (state.isNPC) return;
    this.pending.push({ target: state.peer, action });
  }

  broadcast(action: Effect['action']): Effect {
    return { action };
  }

  /** Changes the map for everyone: the rule machine's copy now, every player's when sent on. */
  queue(delta: WorldDelta): void {
    this.forgetLookup(delta);
    this.machine.apply(delta);
    this.pendingDeltas.push(this.travelling(delta));
  }

  /** A block changed while it is on its way somewhere goes out where everyone's copy has it. */
  private travelling(delta: WorldDelta): WorldDelta {
    if (delta.type !== 'update') return delta;
    const travel = this.travels.get(delta.block.id);
    if (!travel || !(travelEnd(travel) > this.clock) || !sameVec(delta.block.transform.position, add(travel.from, travel.offset))) return delta;
    return { type: 'update', block: { ...delta.block, transform: { ...delta.block.transform, position: { ...travel.from } } } };
  }

  teleport(state: PlayerState, position: Vec3): void {
    if (state.isNPC) {
      if (state.body) {
        state.body.position = { ...position };
        state.body.velocity = v3();
        this.npcTransforms.set(state.peer, transformOf(state.body));
      }
      state.needsTransformSend = true;
      return;
    }
    // Moved here too, so shots and proximity look for them where they now are.
    const yaw = this.machine.player(state.peer)?.yawDegrees ?? 0;
    this.machine.updateTransform({ peerID: state.peer, position: { ...position }, yawDegrees: yaw, velocity: v3(), isGrounded: true });
    this.send(state, { type: 'teleportPlayer', position: { ...position } });
  }

  setScore(state: PlayerState, newScore: number): void {
    if (state.isNPC) {
      state.npcScore = newScore;
      return;
    }
    const old = this.machine.player(state.peer)?.score;
    if (old === undefined || old === newScore) return;
    this.send(state, { type: 'awardPoints', points: newScore - old });
    this.pending.push(...this.machine.handle({ kind: 'scoreChanged', peer: state.peer, newScore }));
  }

  /** Changes how a character looks, for everyone. */
  updateProfile(state: PlayerState, change: (p: AvatarProfile) => void): void {
    const profile = structuredClone(state.profile);
    change(profile);
    if (sameProfile(profile, state.profile)) return;
    state.profile = profile;
    if (state.isNPC) {
      if (state.body) state.body.profile = profile;
    } else {
      this.machine.updateProfile(profile, state.peer);
    }
    state.name = profile.displayName;
    this.rosterChanged = true;
  }

  snapshot(state: PlayerState): PlayerSnapshot | undefined {
    return state.isNPC ? state.body ?? undefined : this.machine.player(state.peer);
  }

  position(state: PlayerState): Vec3 | null {
    const p = this.snapshot(state)?.position;
    return p ? { ...p } : null;
  }

  // MARK: Plumbing

  collect(body: () => void): Effect[] {
    body();
    const out = this.pending;
    this.pending = [];
    return out;
  }

  get orderedStates(): PlayerState[] {
    return [...this.states.values()].sort((a, b) => a.joinOrder - b.joinOrder);
  }

  hasHandler(event: RuntimeEvent): boolean {
    return this.interpreter?.hasHandler(event) ?? false;
  }

  /** Runs a handler, keeping its errors rather than throwing: one broken handler must not stop the game. */
  run(event: RuntimeEvent, args: ScriptValue[]): ScriptValue | undefined {
    const interpreter = this.interpreter;
    if (!interpreter || !interpreter.hasHandler(event)) return undefined;
    const steps = interpreter.totalSteps;
    const started = this.measuresCosts ? performance.now() : 0;
    try {
      return interpreter.run(event, args);
    } catch (error) {
      this.report(error);
      return undefined;
    } finally {
      if (this.measuresCosts) this.recordCost('on ' + event, steps, started);
    }
  }

  watchLines(lines: Set<number>, found: (line: number, scope: ScriptScope, builtins: Set<string>) => void): void {
    if (!lines.size) return;
    this.lineWatch = { lines, found };
  }

  recordCost(name: string, steps: number, started: number): void {
    const interpreter = this.interpreter;
    if (!interpreter) return;
    const cost = this.handlerCosts.get(name) ?? { name, calls: 0, steps: 0, seconds: 0 };
    cost.calls++;
    cost.steps += interpreter.totalSteps - steps;
    cost.seconds += (performance.now() - started) / 1000;
    this.handlerCosts.set(name, cost);
  }

  report(error: unknown): void {
    const raw = error instanceof ScriptError ? error
      : new ScriptError(0, 'runtime', error instanceof RangeError ? L('The script went too deep (a function calling itself without end?).') : String((error as Error)?.message ?? error));
    const e = raw.resolved(this.fileNames);
    const key = `${e.file ?? ''}|${e.line}|${e.message}`;
    if (this.reportedErrors.has(key)) return;
    this.reportedErrors.add(key);
    if (this.newErrors.length < 50) this.newErrors.push(e);
  }

  /** The item with that id on this player's screen, theirs or everyone's. */
  element(id: string, state: PlayerState): UIElement | undefined {
    const element = state.ui.get(id) ?? this.globalUI.get(id);
    return element && element.visible ? element : undefined;
  }

  // MARK: Objects

  object(state: PlayerState): ScriptObject {
    return new ScriptObject(state.isNPC ? 'npc' : 'player', state.peer, state.name);
  }

  blockObject(id: string): ScriptValue {
    const block = this.live.block(id);
    return block ? new ScriptObject('block', id, block.name) : null;
  }

  character(object: ScriptObject): PlayerState | undefined {
    if (object.kind !== 'player' && object.kind !== 'npc') return undefined;
    return this.states.get(object.id);
  }

  blockID(object: ScriptObject): string | undefined {
    if (object.kind !== 'block' || this.live.indexOf(object.id) === undefined) return undefined;
    return object.id;
  }

  member(object: ScriptObject, name: string, line: number): ScriptValue {
    return apiMember(this, object, name, line);
  }

  setMember(object: ScriptObject, name: string, value: ScriptValue, line: number): void {
    apiSetMember(this, object, name, value, line);
  }

  // MARK: Names and tags

  get blockLookup(): BlockLookup {
    this.lookupCache ??= new BlockLookup(this.world.blocks);
    return this.lookupCache;
  }

  /** Called just before `delta` reaches the world. */
  forgetLookup(delta: WorldDelta): void {
    const cached = this.lookupCache;
    if (!cached) return;
    if (delta.type === 'insert' && cached.add(delta.block)) return;
    if (cached.isAffected(delta)) this.lookupCache = null;
  }

  // MARK: Leaderboards, kept by the host

  loadLeaderboards(boards: Map<string, Leaderboard>): void {
    this.leaderboards = boards;
    this.leaderboardsChanged = false;
  }

  takeLeaderboardsIfChanged(): Map<string, Leaderboard> | null {
    if (!this.leaderboardsChanged) return null;
    this.leaderboardsChanged = false;
    return this.leaderboards;
  }

  // MARK: Someone joining while blocks are on their way

  /** The map for someone joining now, and the rest of each trip for them. */
  joiningWorld(peer: string, before: Map<string, BlockTravel>): { world: WorldDocument; effects: Effect[] } {
    const copy = clone(this.world);
    const effects: Effect[] = [];
    for (const [id, travel] of before) {
      const nowTravel = this.travels.get(id);
      if (!nowTravel || !deepEqual(nowTravel, travel) || !(travelEnd(travel) > this.clock)) continue;
      const block = copy.blocks.find((b) => b.id === id);
      const end = add(travel.from, travel.offset);
      if (!block || !sameVec(block.transform.position, end)) continue;
      const now = travelPosition(travel, this.clock);
      block.transform = { ...block.transform, position: now };
      effects.push({ target: peer, action: { type: 'move', blockID: id, offset: { x: end.x - now.x, y: end.y - now.y, z: end.z - now.z }, duration: travelEnd(travel) - this.clock } });
    }
    return { world: copy, effects };
  }

  /** A person, as the tests and the host make one. */
  static person(peer: string, name: string): PlayerSnapshot {
    const s = playerSnapshot(peer);
    s.profile.displayName = name;
    return s;
  }
}

export { PlayerHitBody };
