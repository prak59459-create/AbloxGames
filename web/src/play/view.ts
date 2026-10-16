// The play screen's 3D side: the local player moved by the controls and the
// collider, everyone else eased toward where the network says they are,
// the camera, the moving parts and the words over everything — the per-
// frame loop of Engine/GameViewport.swift.
import * as THREE from 'three';
import type { AvatarProfile, Emote } from '../core/model/avatar';
import { emotes, trailColor, trailParticles } from '../core/model/avatar';
import { BlockTrips, movingOffset } from '../core/model/motion';
import {
  add, boxAround, distance, expanded, intersects, normalizeDegrees, quatEulerDegrees, rayHitsBox, rotate, scale, sub, v3, type Vec3,
} from '../core/model/math';
import { defaultBody, defaultMovement, resolve, solveMovement, surroundingsAt, type CharacterBody, type Surroundings } from '../core/physics/collider';
import type { WorldIndex } from '../core/physics/worldIndex';
import { spawnPosition, type ParticleKind } from '../core/model/world';
import { AvatarModel } from '../engine/avatar';
import { animationPhase, animationPose, posedRotation, type LocalOverride } from '../engine/blocks';
import { GameScene, type GraphicsLevel } from '../engine/scene';
import { makeWeapon, weaponMuzzle } from '../engine/weapons';
import { PlayInput } from './input';
import type { LiveWorld } from '../core/model/liveWorld';
import { normalMovement, standardCamera, type CameraSettings, type MovementScale, type ParticleBurst } from '../core/model/effects';
import { Hitscan, PlayerHitBody } from '../core/model/combat';
import type { ColorRGBA } from '../core/model/color';

export type { CameraMode, CameraSettings, MovementScale } from '../core/model/effects';
export { normalMovement, standardCamera };

export interface RemotePlayer {
  id: string;
  profile: AvatarProfile;
  position: Vec3;
  yaw: number;
  isNPC: boolean;
  isHidden: boolean;
  team: string;
  score: number;
}

interface Remote { avatar: AvatarModel; player: RemotePlayer; chat: { text: string; at: number }[] }

export interface ViewOptions {
  level?: GraphicsLevel;
  autoJump?: boolean;
  cameraFollows?: boolean;
  showNames?: boolean;
}

export class PlayView {
  readonly scene: GameScene;
  readonly input = new PlayInput();
  readonly local: AvatarModel;
  localProfile: AvatarProfile;
  localID: string;

  /** The local player, as the collider sees them. */
  position: Vec3;
  velocity: Vec3 = v3();
  yaw = 0;
  grounded = true;
  surroundings: Surroundings = { kind: 'normal' };
  camera: CameraSettings = standardCamera();
  movement: MovementScale = normalMovement();
  hidden = false;
  preferFirstPerson = false;
  /** Holding a weapon: the body faces where the camera looks, so walking sideways strafes. */
  aiming = false;
  options: Required<ViewOptions>;

  private remotes = new Map<string, Remote>();
  private touching = new Set<string>();
  private trips = new BlockTrips();
  private eye = new THREE.Vector3();
  private cameraAnchor = new THREE.Vector3();
  private shake = { left: 0, strength: 0 };
  private clock = 0;
  private animationClock = 0;
  private lastFrame = 0;
  private running = false;
  private frameHandle = 0;
  private cullClock = 0;
  private standingOn: string | null = null;
  private elevatorLast = new Map<string, Vec3>();
  private localChat: { text: string; at: number }[] = [];
  private followPause = 0;
  private followSeenYaw: number | null = null;
  private emitters: { id: string; kind: ParticleKind; position: Vec3 }[] = [];
  private emitterClock = 10;
  private tracers: { mesh: THREE.Mesh; age: number }[] = [];
  private viewModel: THREE.Group | null = null;
  private viewModelKind: string | null = null;
  private heldKind: string | null = null;
  private recoil = 0;
  private fellFor = 0;
  /** Where the camera looks, for aiming and the waypoint arrow. */
  viewDirection: Vec3 = v3(0, 0, -1);
  fps = 60;

  onTouched: (blockID: string) => void = () => {};
  onTapped: (blockID: string) => void = () => {};
  onFell: () => void = () => {};
  /** Every frame, after moving: for sending our transform. */
  onMoved: (position: Vec3, yaw: number, velocity: Vec3, grounded: boolean) => void = () => {};
  onFrame: (dt: number) => void = () => {};

  constructor(readonly container: HTMLElement, public live: LiveWorld, localID: string, profile: AvatarProfile, options: ViewOptions = {}) {
    this.options = { level: options.level ?? 'high', autoJump: options.autoJump ?? true, cameraFollows: options.cameraFollows ?? true, showNames: options.showNames ?? true };
    this.scene = new GameScene(container, this.options.level);
    this.scene.overlays.showNames = this.options.showNames;
    this.localID = localID;
    this.localProfile = profile;
    this.scene.load(live.world);
    this.position = spawnPosition(live.world, 0, live.find);
    this.local = new AvatarModel(profile, new THREE.Vector3(this.position.x, this.position.y, this.position.z));
    this.scene.avatarRoot.add(this.local.root);
    this.cameraAnchor.set(this.position.x, this.position.y + 4, this.position.z + 7);
    this.input.attach(container);
    this.input.onTap = (x, y) => this.tap(x, y);
    window.addEventListener('resize', this.resize);
    // The camera carries the first-person weapon, so it is part of the scene.
    this.scene.scene.add(this.scene.camera);
  }

  private resize = () => this.scene.resize();

  /**
   * Plays a different copy of the world: the host's, once it arrives, and
   * again after a reconnect or the room moving. A different world also puts
   * the player at its spawn point.
   */
  replaceWorld(live: LiveWorld): void {
    const isDifferent = live.world.id !== this.live.world.id;
    this.live = live;
    this.physicsBlocks = null;
    this.physicsRevision = -1;
    this.touching.clear();
    this.trips = new BlockTrips();
    this.standingOn = null;
    this.elevatorLast.clear();
    this.emitterClock = 10;
    this.scene.load(live.world);
    if (isDifferent) this.respawnAtStart();
  }

  start(): void {
    if (this.running) return;
    this.running = true;
    this.lastFrame = -1;
    const frame = (now: number) => {
      if (!this.running) return;
      // A frame's time can be from before start() was called (it is when the
      // frame began), and a step back in time throws the camera's easing far
      // off — into the sky, on a slow phone. Time only goes forward.
      const raw = this.lastFrame < 0 ? 0 : Math.max(0, (now - this.lastFrame) / 1000);
      this.lastFrame = now;
      this.fps += (1 / Math.max(raw, 1 / 240) - this.fps) * 0.05;
      this.tick(Math.min(raw, 1 / 20));
      this.frameHandle = requestAnimationFrame(frame);
    };
    this.frameHandle = requestAnimationFrame(frame);
  }

  stop(): void {
    this.running = false;
    cancelAnimationFrame(this.frameHandle);
  }

  dispose(): void {
    this.stop();
    this.input.detach();
    window.removeEventListener('resize', this.resize);
    this.scene.dispose();
  }

  // MARK: The roster

  setRoster(players: RemotePlayer[]): void {
    const seen = new Set<string>();
    for (const p of players) {
      if (p.id === this.localID) {
        if (JSON.stringify(p.profile) !== JSON.stringify(this.localProfile)) {
          this.localProfile = p.profile;
          this.local.apply(p.profile);
        }
        this.hidden = p.isHidden;
        continue;
      }
      seen.add(p.id);
      let remote = this.remotes.get(p.id);
      if (!remote) {
        const avatar = new AvatarModel(p.profile, new THREE.Vector3(p.position.x, p.position.y, p.position.z));
        avatar.teleport(new THREE.Vector3(p.position.x, p.position.y, p.position.z), p.yaw);
        this.scene.avatarRoot.add(avatar.root);
        remote = { avatar, player: p, chat: [] };
        this.remotes.set(p.id, remote);
      } else if (JSON.stringify(remote.player.profile) !== JSON.stringify(p.profile)) {
        remote.avatar.apply(p.profile);
      }
      remote.player = { ...p, position: remote.player.position, yaw: remote.player.yaw };
      remote.avatar.root.visible = !p.isHidden;
    }
    for (const [id, remote] of this.remotes) {
      if (!seen.has(id)) {
        remote.avatar.dispose();
        this.remotes.delete(id);
      }
    }
  }

  moveRemote(id: string, position: Vec3, yaw: number): void {
    const remote = this.remotes.get(id);
    if (!remote) return;
    remote.player.position = position;
    remote.player.yaw = yaw;
    const target = new THREE.Vector3(position.x, position.y, position.z);
    if (target.distanceTo(remote.avatar.root.position) > 25) remote.avatar.teleport(target, yaw);
    remote.avatar.target.copy(target);
    remote.avatar.targetYaw = yaw;
  }

  remoteIDs(): string[] { return [...this.remotes.keys()]; }
  remote(id: string): RemotePlayer | undefined { return this.remotes.get(id)?.player; }

  say(id: string, text: string): void {
    const list = id === this.localID ? this.localChat : this.remotes.get(id)?.chat;
    if (!list) return;
    list.push({ text, at: performance.now() });
    while (list.length > 3) list.shift();
  }

  gesture(id: string, wire: string): void {
    if (wire.startsWith('stamp:')) {
      this.scene.overlays.showStamp(id, wire.slice(6));
      return;
    }
    if (!(emotes as readonly string[]).includes(wire)) return;
    const avatar = id === this.localID ? this.local : this.remotes.get(id)?.avatar;
    avatar?.play(wire as Emote);
  }

  // MARK: Effects the view owns

  teleport(position: Vec3): void {
    this.position = { ...position };
    this.velocity = v3();
    this.local.teleport(new THREE.Vector3(position.x, position.y, position.z), this.yaw);
    // The blocks we stood in are no longer under us, and must be able to fire again.
    this.touching.clear();
    this.fellFor = 0;
  }

  /** A script's push: the whole velocity, not added to. */
  launch(velocity: Vec3): void {
    this.velocity = { ...velocity };
    this.grounded = false;
  }

  /** Turns us to face `yaw`, the camera with us, or the next frame would turn us back. */
  face(yaw: number): void {
    this.yaw = yaw;
    this.input.look.yaw = -yaw;
  }

  burst(b: ParticleBurst): void {
    this.scene.particles.burst(b.kind, b.position, b.amount, b.seconds, b.color);
  }

  tint(id: string, color: ColorRGBA, duration: number): void {
    this.scene.blocks.tint(id, color, duration, this.clock);
  }

  /** Our eyes, where shots leave from. */
  get eyes(): Vec3 {
    return add(this.position, v3(0, PlayerHitBody.eyeHeight * this.localProfile.height, 0));
  }

  get eyePosition(): Vec3 { return v3(this.eye.x, this.eye.y, this.eye.z); }

  /**
   * The shot leaves the eyes but must land under the crosshair, which in
   * third person sits on a ray from a camera several metres behind them:
   * find what the crosshair is on, then aim at that.
   */
  aimDirection(range: number): Vec3 {
    const origin = this.eyePosition;
    const eyes = this.eyes;
    const blocks = this.live.currentIndex().entries.filter((e) => e.hasCollision && e.isVisible);
    const players = [...this.remotes.entries()].filter(([, r]) => !r.player.isHidden).map(([peer, r]) => ({ peer, position: r.player.position }));
    const hit = Hitscan.cast(origin, this.viewDirection, range + distance(origin, eyes), this.localID, players, blocks);
    const direction = sub(hit.point, eyes);
    const l = Math.hypot(direction.x, direction.y, direction.z);
    if (l * l <= 0.25) return this.viewDirection;
    const unit = scale(direction, 1 / l);
    if (unit.x * this.viewDirection.x + unit.y * this.viewDirection.y + unit.z * this.viewDirection.z <= 0) return this.viewDirection;
    return unit;
  }

  /** A shot's line, gone in a tenth of a second. Our own starts at the gun, not the eyes. */
  spawnTracer(start: Vec3, end: Vec3): void {
    let from = new THREE.Vector3(start.x, start.y, start.z);
    if (distance(start, this.eyes) < 0.8) {
      const gun = this.viewModel ?? this.local.heldWeapon;
      const kind = this.viewModel ? this.viewModelKind : this.heldKind;
      if (gun && kind) {
        gun.updateWorldMatrix(true, false);
        from = gun.localToWorld(weaponMuzzle(kind));
      }
    }
    const to = new THREE.Vector3(end.x, end.y, end.z);
    const length = from.distanceTo(to);
    if (length <= 0.05) return;
    if (this.tracers.length >= 32) {
      const oldest = this.tracers.shift()!;
      oldest.mesh.removeFromParent();
    }
    const mesh = new THREE.Mesh(tracerGeometry, tracerMaterial);
    mesh.scale.set(1, 1, length);
    mesh.position.copy(from).add(to).multiplyScalar(0.5);
    mesh.lookAt(to);
    this.scene.effects.add(mesh);
    this.tracers.push({ mesh, age: 0 });
  }

  /** The script's weapon in our hand, and at the bottom of the screen in first person. */
  setWeapon(model: string | null): void {
    if (model !== this.heldKind) {
      this.heldKind = model;
      this.local.hold(model, makeWeapon);
    }
    const wanted = this.effectiveCamera().mode === 'first' ? model : null;
    if (wanted === this.viewModelKind) return;
    this.viewModel?.removeFromParent();
    this.viewModel = null;
    this.viewModelKind = wanted;
    if (wanted) {
      this.viewModel = makeWeapon(wanted);
      this.viewModel.traverse((o) => { o.renderOrder = 10; });
      this.scene.camera.add(this.viewModel);
    }
  }

  /** A shot went: the gun kicks. */
  kick(): void { this.recoil = 1; }

  get cameraMode() { return this.effectiveCamera().mode; }

  bounce(speed: number): void {
    this.velocity = { ...this.velocity, y: speed };
    this.grounded = false;
  }

  respawnAtStart(index = 0): void {
    this.teleport(spawnPosition(this.live.world, index, this.live.find));
  }

  moveBlock(id: string, offset: Vec3, duration: number): void {
    const block = this.live.block(id);
    if (!block) {
      this.trips.hold(id, offset, duration, this.clock);
      return;
    }
    const drawn = this.trips.position(id, this.clock) ?? block.transform.position;
    this.trips.start(id, drawn, offset, duration, this.clock);
  }

  shakeCamera(strength: number, seconds: number): void {
    this.shake = { left: seconds, strength };
  }

  setGraphics(level: GraphicsLevel): void {
    this.options.level = level;
    this.scene.setGraphics(level, this.live.world);
  }

  // MARK: The frame

  private tick(dt: number): void {
    this.clock += dt;
    this.onFrame(dt);
    const wall = Date.now() / 1000;
    this.syncWorld();

    // Moving platforms, where the clock puts them: drawn there and stood on there.
    const overrides = new Map<string, LocalOverride>();
    const elevators = this.live.world.blocks.filter((b) => b.behavior === 'elevator');
    const physicsChanges: string[] = [];
    for (const b of elevators) {
      const offset = movingOffset(b.gimmick, wall);
      const position = add(b.transform.position, offset);
      overrides.set(b.id, { position });
      physicsChanges.push(b.id);
    }
    const index = this.indexWith(elevators, overrides);

    // 1. Intent → velocity.
    this.input.poll();
    const config = defaultMovement();
    config.walkSpeed *= this.movement.speed;
    config.jumpSpeed *= this.movement.jump;
    const worldGravity = this.live.world.environment.gravity / -9.81;
    config.gravity *= this.movement.gravity * (Number.isFinite(worldGravity) ? Math.max(0, Math.min(5, worldGravity)) : 1);
    let stick = this.input.stick;
    let jumping = this.input.jumpWanted;
    if (this.movement.frozen) { stick = v3(); jumping = false; }
    const size = this.localProfile.height;
    const body: CharacterBody = { ...defaultBody(), radius: 0.4 * size, height: 1.8 * size };
    if (this.options.autoJump && !this.movement.frozen && this.grounded && this.shouldAutoJump(index, size)) jumping = true;
    this.surroundings = surroundingsAt(this.position, body, index);
    const motion = solveMovement({ position: this.position, velocity: this.velocity, yawDegrees: this.yaw, isGrounded: this.grounded },
      { stick, isJumping: jumping, isRunning: this.input.running, cameraYawDegrees: this.input.look.yaw },
      config, this.surroundings, this.localProfile.ride === 'hoverboard', dt);
    this.velocity = motion.velocity;
    const firstPerson = this.effectiveCamera().mode === 'first';
    this.yaw = firstPerson || this.aiming ? normalizeDegrees(-this.input.look.yaw) : motion.yawDegrees;
    if (!firstPerson && !this.aiming) this.followCamera(stick, dt);

    // 2. Carried by the platform underfoot.
    if (this.standingOn) {
      const now = overrides.get(this.standingOn)?.position;
      const before = this.elevatorLast.get(this.standingOn);
      if (now && before) this.position = add(this.position, sub(now, before));
    }
    for (const b of elevators) this.elevatorLast.set(b.id, overrides.get(b.id)!.position!);

    // 3. Velocity → position, against the world.
    const result = resolve(this.position, this.velocity, body, index, dt);
    this.position = result.position;
    this.velocity = result.velocity;
    this.grounded = result.isGrounded;
    this.standingOn = this.grounded ? this.platformUnder(index) : null;

    // 4. Newly touched blocks, once each on entry.
    const now = new Set(result.touched);
    for (const id of now) if (!this.touching.has(id)) this.onTouched(id);
    this.touching = now;

    // Below the kill plane the host sends us back; if nobody does, we are put back ourselves.
    if (this.position.y < this.live.world.environment.killPlaneHeight) {
      this.fellFor += dt;
      if (this.fellFor > 2.5) { this.fellFor = 0; this.onFell(); }
    } else {
      this.fellFor = 0;
    }

    // 5. Our avatar, directly; everyone else eased.
    const travelled = Math.hypot(this.position.x - this.local.root.position.x, this.position.z - this.local.root.position.z);
    this.local.teleport(new THREE.Vector3(this.position.x, this.position.y, this.position.z), this.yaw);
    this.local.animate(travelled, dt);
    this.local.root.visible = !this.hidden && this.effectiveCamera().mode !== 'first';
    for (const r of this.remotes.values()) r.avatar.update(dt);
    this.onMoved(this.position, this.yaw, this.velocity, this.grounded);

    // 6. Blocks on their way, animated blocks near the eye.
    for (const { id, position } of this.trips.advance(this.clock)) {
      const prior = overrides.get(id) ?? {};
      overrides.set(id, { ...prior, position });
    }
    this.animationClock += dt;
    const range = this.scene.profile.animationRange;
    for (const b of this.live.world.blocks) {
      if (!b.animation) continue;
      const wp = this.scene.blocks.worldPosition(b.id);
      if (wp && wp.distanceToSquared(this.eye) > range * range) continue;
      const pose = animationPose(b.animation, this.animationClock, animationPhase(b.id));
      const prior = overrides.get(b.id) ?? {};
      overrides.set(b.id, {
        ...prior,
        rotation: posedRotation(b.transform.rotation, pose.degrees),
        scale: v3(b.transform.scale.x * pose.stretch.x, b.transform.scale.y * pose.stretch.y, b.transform.scale.z * pose.stretch.z),
      });
    }
    this.scene.blocks.setOverrides(overrides);
    this.scene.blocks.updateTints(this.clock);

    this.updateCamera(dt, index);
    this.scene.focus.set(this.position.x, this.position.y, this.position.z);
    this.scene.updateAtmosphere(dt, wall);
    this.updateEmitters(dt);
    this.emitTrails(dt);
    this.scene.particles.update(dt);
    this.fadeTracers(dt);
    this.recoil = Math.max(0, this.recoil - dt * 9);
    if (this.viewModel) {
      // Lower right, like every shooter; knocked back by each shot.
      this.viewModel.position.set(0.2, -0.2 + this.recoil * 0.02, -0.42 + this.recoil * 0.06);
      this.viewModel.rotation.set(this.recoil * 0.12, 0, 0);
    }
    this.updateOverlays();
    this.cullClock += dt;
    this.scene.render();
  }

  private physicsBlocks: typeof this.live.world.blocks | null = null;
  private physicsRevision = -1;

  /** The collision index with the moving platforms where they are now. */
  private indexWith(elevators: typeof this.live.world.blocks, overrides: Map<string, LocalOverride>): WorldIndex {
    const base = this.live.currentIndex();
    if (!elevators.length) return base;
    if (this.physicsRevision !== this.live.revision || !this.physicsBlocks) {
      this.physicsBlocks = this.live.world.blocks.slice();
      this.physicsRevision = this.live.revision;
    }
    const blocks = this.physicsBlocks;
    const ids: string[] = [];
    for (let i = 0; i < blocks.length; i++) {
      const o = overrides.get(blocks[i].id);
      if (o?.position && blocks[i].behavior === 'elevator') {
        const original = this.live.block(blocks[i].id)!;
        blocks[i] = { ...original, transform: { ...original.transform, position: o.position } };
        ids.push(blocks[i].id);
      }
    }
    if (!base.update(blocks, ids)) base.rebuild(blocks);
    return base;
  }

  private platformUnder(index: WorldIndex): string | null {
    const feet = boxAround(v3(this.position.x, this.position.y - 0.1, this.position.z), v3(0.6, 0.25, 0.6));
    for (const e of index.near(feet)) if (e.behavior === 'elevator' && e.isVisible && intersects(e.bounds, feet)) return e.id;
    return null;
  }

  private syncWorld(): void {
    const { changed, removed, environment } = this.live.takeChanges();
    if (changed.size || removed.size) {
      for (const id of changed) {
        this.scene.blocks.clearTint(id);
        const block = this.live.block(id);
        if (block && this.trips.appeared(id, block.transform.position, this.clock)) continue;
        if (block) this.trips.mapHas(id, block.transform.position, undefined);
      }
      for (const id of removed) this.trips.forget(id);
      this.scene.blocks.applyChanges(this.live.world, changed, removed);
      this.emitterClock = 10;
    }
    if (environment) this.scene.setEnvironment(this.live.world.environment);
  }

  private shouldAutoJump(index: WorldIndex, size: number): boolean {
    const flat = v3(this.velocity.x, 0, this.velocity.z);
    const speed = Math.hypot(flat.x, flat.z);
    if (speed <= 1) return false;
    const dir = scale(flat, 1 / speed);
    const feet = this.position;
    const solid = (min: Vec3, max: Vec3) => {
      const box = { min, max };
      return index.near(box).some((e) => e.hasCollision && e.isVisible && intersects(e.bounds, box));
    };
    const near = add(feet, scale(dir, 0.4 * size + 0.3));
    if (solid(v3(near.x - 0.15, feet.y + 0.5, near.z - 0.15), v3(near.x + 0.15, feet.y + 1.1, near.z + 0.15))
      && !solid(v3(near.x - 0.15, feet.y + 1.4, near.z - 0.15), v3(near.x + 0.15, feet.y + 2.4 * size, near.z + 0.15))) return true;
    const ahead = add(feet, scale(dir, 0.4 * size + 0.6));
    if (solid(v3(ahead.x - 0.2, feet.y - 3, ahead.z - 0.2), v3(ahead.x + 0.2, feet.y + 0.05, ahead.z + 0.2))) return false;
    const landing = add(feet, scale(dir, 3));
    return solid(v3(landing.x - 0.4, feet.y - 1.5, landing.z - 0.4), v3(landing.x + 0.4, feet.y + 0.6, landing.z + 0.4));
  }

  /** The camera drifts round behind a player walking on, after a pause when they turn it. */
  private followCamera(stick: Vec3, dt: number): void {
    const look = this.input.look;
    if (!this.options.cameraFollows || this.effectiveCamera().mode !== 'third') return;
    if (this.followSeenYaw !== null && Math.abs(normalizeDegrees(look.yaw - this.followSeenYaw)) > 0.01) this.followPause = 1.5;
    if (this.followPause > 0) {
      this.followPause -= dt;
      this.followSeenYaw = look.yaw;
      return;
    }
    const moving = Math.hypot(stick.x, stick.z);
    if (moving > 0.2 && stick.z > moving * 0.5) {
      const gap = normalizeDegrees(-this.yaw - look.yaw);
      if (Math.abs(gap) > 2) look.yaw = normalizeDegrees(look.yaw + gap * (1 - Math.exp(-1.6 * Math.min(dt, 0.1))));
    }
    this.followSeenYaw = look.yaw;
  }

  private effectiveCamera(): CameraSettings {
    const c = { ...this.camera };
    if (c.mode === 'third' && this.preferFirstPerson) c.mode = 'first';
    return c;
  }

  private updateCamera(dt: number, index: WorldIndex): void {
    const settings = this.effectiveCamera();
    const cam = this.scene.camera;
    const size = this.localProfile.height;
    const fov = settings.fieldOfView || 65;
    if (Math.abs(cam.fov - fov) > 0.01) { cam.fov = fov; cam.updateProjectionMatrix(); }
    let jitter = v3();
    if (this.shake.left > 0) {
      this.shake.left -= dt;
      const a = this.shake.strength * Math.max(0, Math.min(1, this.shake.left * 3)) * 0.25;
      jitter = v3((Math.random() * 2 - 1) * a, (Math.random() * 2 - 1) * a, (Math.random() * 2 - 1) * a);
    }
    const look = this.input.look;
    const p = this.position;
    switch (settings.mode) {
      case 'first': {
        const pitch = Math.max(-80, Math.min(80, look.pitch));
        const dir = rotate(quatEulerDegrees(v3(pitch, look.yaw, 0)), v3(0, 0, -1));
        const eye = add(add(p, v3(0, 1.6 * size, 0)), jitter);
        cam.position.set(eye.x, eye.y, eye.z);
        cam.lookAt(eye.x + dir.x, eye.y + dir.y, eye.z + dir.z);
        this.cameraAnchor.copy(cam.position);
        break;
      }
      case 'top': {
        const focus = add(p, v3(0, size, 0));
        const height = settings.distance * look.zoom;
        const offset = rotate(quatEulerDegrees(v3(0, look.yaw, 0)), v3(0, height, height * 0.3));
        const target = add(add(focus, offset), jitter);
        this.cameraAnchor.lerp(new THREE.Vector3(target.x, target.y, target.z), 1 - Math.exp(-12 * dt));
        cam.position.copy(this.cameraAnchor);
        cam.lookAt(focus.x, focus.y, focus.z);
        break;
      }
      case 'fixed': {
        const eye = add(settings.position ?? add(p, v3(0, 5, 8)), jitter);
        const target = settings.target ?? add(p, v3(0, size, 0));
        cam.position.set(eye.x, eye.y, eye.z);
        cam.lookAt(target.x, target.y, target.z);
        this.cameraAnchor.copy(cam.position);
        break;
      }
      case 'third': {
        const pitch = Math.max(-75, Math.min(20, look.pitch));
        look.pitch = Math.max(-80, Math.min(80, look.pitch));
        const orbit = quatEulerDegrees(v3(pitch, look.yaw, 0));
        const focus = add(add(p, v3(0, 1.4 * size, 0)), jitter);
        const desired = settings.distance * look.zoom;
        const back = rotate(orbit, v3(0, 0, 1));
        const offset = scale(back, desired);
        let distance = desired;
        const end = add(focus, offset);
        const reach = expanded({ min: v3(Math.min(focus.x, end.x), Math.min(focus.y, end.y), Math.min(focus.z, end.z)),
          max: v3(Math.max(focus.x, end.x), Math.max(focus.y, end.y), Math.max(focus.z, end.z)) }, 0.5);
        for (const e of index.near(reach)) {
          if (!e.hasCollision || !e.isVisible) continue;
          const hit = rayHitsBox(focus, back, expanded(e.bounds, 0.25));
          if (hit !== null && hit < distance) distance = Math.max(1.5, hit);
        }
        const target = add(focus, scale(back, distance));
        this.cameraAnchor.lerp(new THREE.Vector3(target.x, target.y, target.z), 1 - Math.exp(-14 * dt));
        cam.position.copy(this.cameraAnchor);
        cam.lookAt(focus.x, focus.y, focus.z);
        break;
      }
    }
    this.eye.copy(cam.position);
    const dir = new THREE.Vector3();
    cam.getWorldDirection(dir);
    this.viewDirection = v3(dir.x, dir.y, dir.z);
  }

  private fadeTracers(dt: number): void {
    if (!this.tracers.length) return;
    for (const t of this.tracers) t.age += dt;
    for (const t of this.tracers) if (t.age > 0.12) t.mesh.removeFromParent();
    this.tracers = this.tracers.filter((t) => t.age <= 0.12);
  }

  /** Blocks that keep giving off bits: the nearest sixteen, looked for twice a second. */
  private updateEmitters(dt: number): void {
    this.emitterClock += dt;
    if (this.emitterClock > 0.5) {
      this.emitterClock = 0;
      const found: { id: string; kind: ParticleKind; position: Vec3; d: number }[] = [];
      for (const b of this.live.world.blocks) {
        if (!b.particles || !this.scene.blocks.isDrawn(b.id)) continue;
        const w = this.scene.blocks.worldPosition(b.id);
        if (!w) continue;
        const d = w.distanceTo(this.eye);
        if (d < 45) found.push({ id: b.id, kind: b.particles, position: v3(w.x, w.y, w.z), d });
      }
      this.emitters = found.sort((a, b) => a.d - b.d).slice(0, 16);
    }
    for (const e of this.emitters) {
      const block = this.live.block(e.id);
      if (!block) continue;
      const top = this.scene.blocks.topOf(e.id);
      const at = top ? v3(top.x, top.y, top.z) : e.position;
      const spec = e.kind;
      const s = block.transform.scale;
      this.scene.particles.stream(spec, e.id, at, particleRate(spec), dt, v3(s.x * 0.3, 0.05, s.z * 0.3));
    }
  }

  private emitTrails(dt: number): void {
    const all: [AvatarModel, AvatarProfile, string][] = [[this.local, this.localProfile, this.localID]];
    for (const [id, r] of this.remotes) if (!r.player.isHidden) all.push([r.avatar, r.player.profile, id]);
    for (const [avatar, profile, id] of all) {
      const kind = trailParticles[profile.trail] as ParticleKind | null;
      if (!kind || avatar.lastStep < 0.01) continue;
      const at = avatar.root.position;
      this.scene.particles.stream(kind, 'trail:' + id, v3(at.x, at.y + 0.3, at.z), 22, dt, v3(0.2, 0.1, 0.2),
        trailColor(profile.trail, this.clock) ?? undefined);
    }
  }

  private updateOverlays(): void {
    const overlays = this.scene.overlays;
    const top = new THREE.Vector3();
    const view = new THREE.Vector3();
    this.scene.camera.getWorldDirection(view);
    const visible = (point: THREE.Vector3, limit: number) => {
      const to = point.clone().sub(this.eye);
      const d = to.length();
      return d > 0.5 && d < limit && to.dot(view) > 0.2 * d;
    };
    const tags = [];
    const speakers = [];
    const now = performance.now();
    for (const [id, r] of this.remotes) {
      if (r.player.isHidden) continue;
      r.avatar.headTop(top);
      if (!visible(top, 70)) continue;
      const at = this.scene.project(top);
      if (!at) continue;
      tags.push({ id, name: r.player.profile.displayName, title: r.player.profile.title, plate: r.player.profile.nameplate, isNPC: r.player.isNPC, at });
      r.chat = r.chat.filter((c) => now - c.at < 8000);
      if (r.chat.length) speakers.push({ id, lines: r.chat.map((c) => c.text), style: r.player.profile.bubble, at: { ...at } });
    }
    this.localChat = this.localChat.filter((c) => now - c.at < 8000);
    if (this.localChat.length && this.local.root.visible) {
      this.local.headTop(top);
      const at = this.scene.project(top);
      if (at) speakers.push({ id: this.localID, lines: this.localChat.map((c) => c.text), style: this.localProfile.bubble, at });
    }
    overlays.updateNames(tags);
    overlays.updateBubbles(speakers);

    const labels = [];
    for (const b of this.live.world.blocks) {
      if (!b.label || !b.label.lines.length || !this.scene.blocks.isDrawn(b.id)) continue;
      const anchor = this.scene.blocks.topOf(b.id);
      if (!anchor) continue;
      anchor.y += b.label.height;
      if (!visible(anchor, b.label.range)) continue;
      const at = this.scene.project(anchor);
      if (at) labels.push({ id: b.id, label: b.label, at });
    }
    overlays.updateLabels(labels);
  }

  /** A tap on the 3D view: the nearest block under it, within reach. */
  private tap(x: number, y: number): void {
    const cam = this.scene.camera;
    const w = this.container.clientWidth, h = this.container.clientHeight;
    const ndc = new THREE.Vector2((x / w) * 2 - 1, -(y / h) * 2 + 1);
    const ray = new THREE.Raycaster();
    ray.setFromCamera(ndc, cam);
    const origin = v3(ray.ray.origin.x, ray.ray.origin.y, ray.ray.origin.z);
    const dir = v3(ray.ray.direction.x, ray.ray.direction.y, ray.ray.direction.z);
    const reach = 60;
    let best: { id: string; d: number } | null = null;
    for (const e of this.live.currentIndex().entries) {
      if (!e.isVisible) continue;
      const d = rayHitsBox(origin, dir, e.bounds);
      if (d !== null && d <= reach && (!best || d < best.d)) best = { id: e.id, d };
    }
    if (best) this.onTapped(best.id);
  }
}

const tracerGeometry = new THREE.BoxGeometry(0.03, 0.03, 1);
const tracerMaterial = new THREE.MeshBasicMaterial({ color: new THREE.Color(1, 0.86, 0.35), toneMapped: false });

function particleRate(kind: ParticleKind): number {
  const rates: Record<ParticleKind, number> = { fire: 40, smoke: 14, sparkles: 24, confetti: 60, rain: 220, snow: 90, bubbles: 12, hearts: 10, stars: 18, leaves: 8, magic: 30, dust: 16 };
  return rates[kind];
}
