// Draws a world's blocks — Engine/WorldScene.swift and BlockEntityFactory.swift,
// rebuilt for the browser: blocks of the same shape and material are one
// instanced mesh each, with the colour per instance, so a world of three
// thousand parts is a few dozen draw calls. A block that moves only changes
// its own matrix.
import * as THREE from 'three';
import { RoundedBoxGeometry } from 'three/addons/geometries/RoundedBoxGeometry.js';
import type { ColorRGBA } from '../core/model/color';
import { quatEulerDegrees, quatMul, type Quat, type Vec3 } from '../core/model/math';
import {
  materialInfo, type BlockAnimation, type BlockData, type BlockShape, type WorldDocument, type WorldImage,
} from '../core/model/world';
import { markTexture, patternTexture, pictureTexture, type MeaningMark } from './textures';

export interface GraphicsProfile {
  smoothShapes: boolean;
  roundSegments: number;
  sphereRings: number;
  shadowDistance: number | null;
  viewDistance: number | null;
  animationRange: number;
  particleBudget: number;
  pixelRatio: number;
  lamps: boolean;
}

export const graphicsProfiles: Record<'low' | 'medium' | 'high', GraphicsProfile> = {
  low: { smoothShapes: false, roundSegments: 10, sphereRings: 6, shadowDistance: null, viewDistance: 70, animationRange: 30, particleBudget: 150, pixelRatio: 1, lamps: false },
  medium: { smoothShapes: false, roundSegments: 16, sphereRings: 10, shadowDistance: 40, viewDistance: 130, animationRange: 50, particleBudget: 350, pixelRatio: 1.5, lamps: true },
  high: { smoothShapes: true, roundSegments: 24, sphereRings: 16, shadowDistance: 70, viewDistance: null, animationRange: 80, particleBudget: 600, pixelRatio: 2, lamps: true },
};

// MARK: - Shapes

const geometryCache = new Map<string, THREE.BufferGeometry>();

export function shapeGeometry(shape: BlockShape, profile: GraphicsProfile): THREE.BufferGeometry {
  const key = `${shape}:${profile.smoothShapes}:${profile.roundSegments}:${profile.sphereRings}`;
  const cached = geometryCache.get(key);
  if (cached) return cached;
  let g: THREE.BufferGeometry;
  switch (shape) {
    case 'box':
      g = profile.smoothShapes ? new RoundedBoxGeometry(1, 1, 1, 2, 0.02) : new THREE.BoxGeometry(1, 1, 1);
      break;
    case 'sphere':
      g = new THREE.SphereGeometry(0.5, profile.smoothShapes ? 32 : profile.roundSegments, profile.smoothShapes ? 20 : profile.sphereRings);
      break;
    case 'cylinder':
      g = new THREE.CylinderGeometry(0.5, 0.5, 1, profile.roundSegments);
      break;
    case 'cone':
      g = new THREE.ConeGeometry(0.5, 1, profile.roundSegments);
      break;
    case 'plane':
      g = new THREE.PlaneGeometry(1, 1);
      g.rotateX(-Math.PI / 2);
      break;
  }
  geometryCache.set(key, g);
  return g;
}

// MARK: - Materials

const byte = (v: number) => (Number.isFinite(v) ? Math.max(0, Math.min(255, Math.round(v * 255))) : 0);

export function tileCount(block: BlockData, marked: boolean): number {
  if (materialInfo[block.material].pattern === 'none' && !marked) return 1;
  const s = block.transform.scale;
  const span = Math.max(s.x, s.z, s.y * 0.5);
  const halved = (Number.isFinite(span) ? span : 1) / 2;
  return Math.round(Math.max(1, Math.min(24, halved)));
}

export function meaningMark(block: BlockData): MeaningMark | null {
  if (block.behavior === 'hazard') return 'danger';
  if (block.behavior === 'goal') return 'goal';
  return null;
}

const materialCache = new Map<string, THREE.Material>();

function materialFor(block: BlockData, alpha: number, tiles: number, mark: MeaningMark | null): { key: string; material: THREE.Material } {
  const kind = block.material;
  const key = `${kind}|${tiles}|${byte(alpha)}|${mark ?? ''}`;
  const cached = materialCache.get(key);
  if (cached) return { key, material: cached };
  const info = materialInfo[kind];
  const transparent = alpha < 0.999;
  let material: THREE.Material;
  if (mark) {
    const map = markTexture(mark, tiles);
    material = kind === 'neon'
      ? new THREE.MeshBasicMaterial({ map, toneMapped: false })
      : new THREE.MeshStandardMaterial({ map, roughness: info.roughness, metalness: 0 });
  } else if (kind === 'neon') {
    material = new THREE.MeshBasicMaterial({ color: 0xffffff, toneMapped: false });
  } else if (info.pattern !== 'none') {
    material = new THREE.MeshStandardMaterial({ map: patternTexture(info.pattern, tiles), roughness: info.roughness, metalness: 0 });
  } else {
    material = new THREE.MeshStandardMaterial({ roughness: info.roughness, metalness: kind === 'metal' ? 1 : 0 });
  }
  if (transparent) {
    material.transparent = true;
    material.opacity = alpha;
    material.depthWrite = false;
  }
  materialCache.set(key, material);
  return { key, material };
}

const tmpColor = new THREE.Color();
export function threeColor(c: ColorRGBA, target = tmpColor): THREE.Color {
  return target.setRGB(Math.max(0, Math.min(1, c.r)), Math.max(0, Math.min(1, c.g)), Math.max(0, Math.min(1, c.b)), THREE.SRGBColorSpace);
}

// MARK: - Instanced groups

class InstanceGroup {
  mesh: THREE.InstancedMesh;
  ids: string[] = [];

  constructor(readonly root: THREE.Group, readonly geometry: THREE.BufferGeometry, readonly material: THREE.Material,
    readonly shadows: boolean, capacity = 16) {
    this.mesh = this.make(capacity);
  }

  private make(capacity: number): THREE.InstancedMesh {
    const mesh = new THREE.InstancedMesh(this.geometry, this.material, capacity);
    mesh.count = 0;
    mesh.castShadow = this.shadows;
    mesh.receiveShadow = true;
    mesh.frustumCulled = false;
    mesh.instanceMatrix.setUsage(THREE.DynamicDrawUsage);
    this.root.add(mesh);
    return mesh;
  }

  add(id: string, matrix: THREE.Matrix4, color: THREE.Color): number {
    if (this.ids.length >= this.mesh.instanceMatrix.count) {
      const old = this.mesh;
      const bigger = this.make(old.instanceMatrix.count * 2);
      for (let i = 0; i < this.ids.length; i++) {
        old.getMatrixAt(i, m4);
        bigger.setMatrixAt(i, m4);
        old.getColorAt(i, tmpColor);
        bigger.setColorAt(i, tmpColor);
      }
      bigger.count = this.ids.length;
      this.root.remove(old);
      old.dispose();
      this.mesh = bigger;
    }
    const slot = this.ids.length;
    this.ids.push(id);
    this.mesh.setMatrixAt(slot, matrix);
    this.mesh.setColorAt(slot, color);
    this.mesh.count = this.ids.length;
    this.dirty();
    return slot;
  }

  /** Takes a slot out, moving the last into it; returns the id that moved, if any. */
  remove(slot: number): string | null {
    const last = this.ids.length - 1;
    let moved: string | null = null;
    if (slot !== last) {
      this.mesh.getMatrixAt(last, m4);
      this.mesh.setMatrixAt(slot, m4);
      this.mesh.getColorAt(last, tmpColor);
      this.mesh.setColorAt(slot, tmpColor);
      moved = this.ids[last];
      this.ids[slot] = moved;
    }
    this.ids.pop();
    this.mesh.count = this.ids.length;
    this.dirty();
    return moved;
  }

  setMatrix(slot: number, matrix: THREE.Matrix4): void {
    this.mesh.setMatrixAt(slot, matrix);
    this.mesh.instanceMatrix.needsUpdate = true;
  }

  setColor(slot: number, color: THREE.Color): void {
    this.mesh.setColorAt(slot, color);
    if (this.mesh.instanceColor) this.mesh.instanceColor.needsUpdate = true;
  }

  private dirty(): void {
    this.mesh.instanceMatrix.needsUpdate = true;
    if (this.mesh.instanceColor) this.mesh.instanceColor.needsUpdate = true;
  }

  dispose(): void {
    this.root.remove(this.mesh);
    this.mesh.dispose();
  }
}

const m4 = new THREE.Matrix4();
const tPos = new THREE.Vector3(), tScale = new THREE.Vector3();
const tQuat = new THREE.Quaternion();

function localMatrix(position: Vec3, rotation: Quat, scale: Vec3, target: THREE.Matrix4): THREE.Matrix4 {
  tPos.set(position.x, position.y, position.z);
  tQuat.set(rotation.x, rotation.y, rotation.z, rotation.w);
  tScale.set(scale.x || 1e-6, scale.y || 1e-6, scale.z || 1e-6);
  return target.compose(tPos, tQuat, tScale);
}

// MARK: - Animations

/** BlockAnimation.pose: the turn (degrees) and stretch at `time`, started at `phase`. */
export function animationPose(a: BlockAnimation, time: number, phase: number): { degrees: Vec3; stretch: Vec3 } {
  const t = time * a.speed + phase * 10;
  const still = { x: 1, y: 1, z: 1 };
  switch (a.kind) {
    case 'spin': return { degrees: { x: 0, y: (t * 90) % 360, z: 0 }, stretch: still };
    case 'sway': return { degrees: { x: 0, y: 0, z: Math.sin(t * 2.4) * 10 }, stretch: still };
    case 'dance': {
      const beat = Math.sin(t * 5);
      const squash = 1 + Math.abs(beat) * 0.08, thin = 1 / Math.sqrt(squash);
      return { degrees: { x: 0, y: Math.sin(t * 2.5) * 18, z: beat * 9 }, stretch: { x: thin, y: squash, z: thin } };
    }
    case 'bounce': {
      const hop = Math.sin(t * 6);
      const side = 1 - hop * 0.05;
      return { degrees: { x: 0, y: 0, z: 0 }, stretch: { x: side, y: 1 + hop * 0.1, z: side } };
    }
    case 'pulse': {
      const s = 1 + Math.sin(t * 3) * 0.06;
      return { degrees: { x: 0, y: 0, z: 0 }, stretch: { x: s, y: s, z: s } };
    }
    case 'wobble': return { degrees: { x: Math.sin(t * 2.8) * 8, y: 0, z: 0 }, stretch: still };
  }
}

/** Each block starts its own way through, from the first two bytes of its id. */
export function animationPhase(id: string): number {
  const hex = id.replace(/-/g, '');
  const a = parseInt(hex.slice(0, 2), 16) || 0, b = parseInt(hex.slice(2, 4), 16) || 0;
  return a / 255 + b / 65025;
}

// MARK: - The layer

interface BlockRecord {
  block: BlockData;
  world: THREE.Matrix4;
  group: InstanceGroup | null;
  slot: number;
  mesh: THREE.Mesh | null;
  light: THREE.Light | null;
  drawn: boolean;
}

/** Overrides for a block's own (local) transform this frame: a trip, an animation, a moving platform. */
export interface LocalOverride { position?: Vec3; rotation?: Quat; scale?: Vec3 }

export class BlockLayer {
  readonly root = new THREE.Group();
  private groups = new Map<string, InstanceGroup>();
  private records = new Map<string, BlockRecord>();
  private children = new Map<string, string[]>();
  private blocks = new Map<string, BlockData>();
  private images = new Map<string, WorldImage>();
  private lit = 0;
  /** Blocks hidden by a game effect rather than by the world. */
  readonly effectHidden = new Set<string>();
  /** Blocks whose colour a game effect is fading. */
  private tints = new Map<string, { from: ColorRGBA; to: ColorRGBA; start: number; duration: number; current: ColorRGBA }>();
  marksMeaning = false;
  private overrides = new Map<string, LocalOverride>();

  constructor(public profile: GraphicsProfile) {
    this.root.name = 'ablox.blocks';
  }

  get blockCount(): number { return this.records.size; }
  get drawCalls(): number { return this.groups.size; }

  /** Everything, from nothing: a world arriving. */
  load(world: WorldDocument): void {
    this.clear();
    for (const image of world.images) this.images.set(image.id, image);
    for (const b of world.blocks) if (!this.blocks.has(b.id)) this.blocks.set(b.id, b);
    for (const b of world.blocks) {
      if (b.parentID) {
        const list = this.children.get(b.parentID) ?? [];
        list.push(b.id);
        this.children.set(b.parentID, list);
      }
    }
    // Parents before children, so each child finds its parent's matrix ready.
    const roots = world.blocks.filter((b) => !b.parentID || !this.blocks.has(b.parentID));
    const queue = roots.map((b) => b.id);
    const seen = new Set<string>();
    while (queue.length) {
      const id = queue.shift()!;
      if (seen.has(id)) continue;
      seen.add(id);
      this.place(id);
      for (const child of this.children.get(id) ?? []) queue.push(child);
    }
  }

  clear(): void {
    for (const g of this.groups.values()) g.dispose();
    this.groups.clear();
    for (const r of this.records.values()) {
      if (r.mesh) this.root.remove(r.mesh);
      if (r.light) this.root.remove(r.light);
    }
    this.records.clear();
    this.children.clear();
    this.blocks.clear();
    this.images.clear();
    this.effectHidden.clear();
    this.tints.clear();
    this.overrides.clear();
    this.lit = 0;
  }

  /** Changes since the last call: blocks added, changed or removed. */
  applyChanges(world: WorldDocument, changed: Set<string>, removed: Set<string>): void {
    if (world.images.length !== this.images.size) {
      this.images.clear();
      for (const image of world.images) this.images.set(image.id, image);
    }
    for (const id of removed) this.forget(id);
    const now = new Map<string, BlockData>();
    for (const b of world.blocks) if (!now.has(b.id)) now.set(b.id, b);
    for (const id of changed) {
      const block = now.get(id);
      if (!block) { this.forget(id); continue; }
      const before = this.blocks.get(id);
      if (before && before.parentID !== block.parentID) this.unlink(id, before.parentID);
      if (!before || before.parentID !== block.parentID) this.link(id, block.parentID);
      this.blocks.set(id, block);
    }
    // Each changed block, and what hangs from it, placed again.
    const done = new Set<string>();
    for (const id of changed) if (this.blocks.has(id)) this.placeSubtree(id, done);
  }

  private link(id: string, parent?: string): void {
    if (!parent) return;
    const list = this.children.get(parent) ?? [];
    if (!list.includes(id)) list.push(id);
    this.children.set(parent, list);
  }

  private unlink(id: string, parent?: string): void {
    if (!parent) return;
    const list = this.children.get(parent);
    if (!list) return;
    const at = list.indexOf(id);
    if (at >= 0) list.splice(at, 1);
  }

  private forget(id: string): void {
    const block = this.blocks.get(id);
    if (block) this.unlink(id, block.parentID);
    this.undraw(id);
    const record = this.records.get(id);
    if (record?.light) { this.root.remove(record.light); this.lit -= 1; }
    this.records.delete(id);
    this.blocks.delete(id);
    this.tints.delete(id);
    this.overrides.delete(id);
    // Children of a removed block were removed with it by the world.
  }

  private placeSubtree(id: string, done: Set<string>): void {
    const stack = [id];
    while (stack.length) {
      const current = stack.pop()!;
      if (done.has(current)) continue;
      done.add(current);
      this.place(current);
      for (const child of this.children.get(current) ?? []) stack.push(child);
    }
  }

  /** Whether the block and every block it hangs from are shown. */
  private isShown(block: BlockData): boolean {
    let cursor: BlockData | undefined = block;
    let steps = 0;
    while (cursor && steps < 64) {
      if (!cursor.isVisible || this.effectHidden.has(cursor.id)) return false;
      cursor = cursor.parentID ? this.blocks.get(cursor.parentID) : undefined;
      steps++;
    }
    return true;
  }

  private worldMatrix(block: BlockData, target: THREE.Matrix4): THREE.Matrix4 {
    const o = this.overrides.get(block.id);
    const t = block.transform;
    localMatrix(o?.position ?? t.position, o?.rotation ?? t.rotation, o?.scale ?? t.scale, target);
    if (block.parentID) {
      const parent = this.records.get(block.parentID);
      if (parent) target.premultiply(parent.world);
    }
    return target;
  }

  private place(id: string): void {
    const block = this.blocks.get(id);
    if (!block) return;
    let record = this.records.get(id);
    if (!record) {
      record = { block, world: new THREE.Matrix4(), group: null, slot: -1, mesh: null, light: null, drawn: false };
      this.records.set(id, record);
    }
    const previous = record.block;
    record.block = block;
    this.worldMatrix(block, record.world);

    const shown = this.isShown(block);
    const lookChanged = previous !== block && (previous.shape !== block.shape || previous.material !== block.material
      || previous.imageID !== block.imageID || Math.abs(previous.color.a - block.color.a) > 1e-4
      || tileCount(previous, false) !== tileCount(block, false));
    if (!shown || lookChanged) this.undraw(id);
    if (shown) {
      if (!record.drawn) this.draw(record);
      else this.refresh(record);
    }
    this.updateLight(record, shown);
  }

  private draw(record: BlockRecord): void {
    const block = record.block;
    const picture = block.imageID ? this.images.get(block.imageID) : undefined;
    const alpha = block.color.a * materialInfo[block.material].alphaScale;
    const color = threeColor(this.tints.get(block.id)?.current ?? block.color);
    if (picture) {
      const material = new THREE.MeshStandardMaterial({ map: pictureTexture(picture.id, picture.data), roughness: 0.7 });
      if (alpha < 0.999) { material.transparent = true; material.opacity = alpha; }
      const mesh = new THREE.Mesh(shapeGeometry(block.shape, this.profile), material);
      mesh.matrixAutoUpdate = false;
      mesh.matrix.copy(record.world);
      mesh.castShadow = true;
      mesh.receiveShadow = true;
      this.root.add(mesh);
      record.mesh = mesh;
    } else {
      const mark = this.marksMeaning ? meaningMark(block) : null;
      const tiles = tileCount(block, mark !== null);
      const { key, material } = materialFor(block, alpha, tiles, mark);
      const groupKey = block.shape + '|' + key;
      let group = this.groups.get(groupKey);
      if (!group) {
        const shadows = !(block.material === 'glass' || block.material === 'water' || alpha < 0.5);
        group = new InstanceGroup(this.root, shapeGeometry(block.shape, this.profile), material, shadows);
        this.groups.set(groupKey, group);
      }
      record.group = group;
      record.slot = group.add(block.id, record.world, color);
    }
    record.drawn = true;
  }

  private refresh(record: BlockRecord): void {
    if (record.mesh) {
      record.mesh.matrix.copy(record.world);
      return;
    }
    if (record.group) {
      record.group.setMatrix(record.slot, record.world);
      record.group.setColor(record.slot, threeColor(this.tints.get(record.block.id)?.current ?? record.block.color));
    }
  }

  private undraw(id: string): void {
    const record = this.records.get(id);
    if (!record || !record.drawn) return;
    if (record.mesh) {
      this.root.remove(record.mesh);
      (record.mesh.material as THREE.Material).dispose();
      record.mesh = null;
    }
    if (record.group) {
      const moved = record.group.remove(record.slot);
      if (moved) {
        const other = this.records.get(moved);
        if (other) other.slot = record.slot;
      }
      record.group = null;
      record.slot = -1;
    }
    record.drawn = false;
  }

  private updateLight(record: BlockRecord, shown: boolean): void {
    const setting = record.block.light;
    if (!setting || !shown || !this.profile.lamps) {
      if (record.light) { this.root.remove(record.light); record.light = null; this.lit -= 1; }
      return;
    }
    if (!record.light) {
      if (this.lit >= 8) return;
      record.light = setting.kind === 'spot' ? new THREE.SpotLight() : new THREE.PointLight();
      this.root.add(record.light);
      if (record.light instanceof THREE.SpotLight) this.root.add(record.light.target);
      this.lit += 1;
    }
    const light = record.light as THREE.PointLight | THREE.SpotLight;
    threeColor(setting.color, light.color);
    light.intensity = (setting.kind === 'spot' ? 60 : 40) * setting.intensity;
    light.distance = setting.range;
    light.decay = 1.2;
    record.world.decompose(tPos, tQuat, tScale);
    light.position.copy(tPos);
    if (light instanceof THREE.SpotLight) {
      light.angle = Math.PI / 5;
      light.penumbra = 0.4;
      const up = new THREE.Vector3(0, 1, 0).applyQuaternion(tQuat);
      light.target.position.copy(tPos).add(up);
      light.target.updateMatrixWorld();
    }
  }

  // MARK: Every frame

  /** This frame's trips, animations and moving platforms, placed. */
  setOverrides(next: Map<string, LocalOverride>): void {
    const touched = new Set<string>([...this.overrides.keys(), ...next.keys()]);
    this.overrides = next;
    const done = new Set<string>();
    for (const id of touched) if (this.blocks.has(id)) this.placeSubtree(id, done);
  }

  /** Effects: a block faded to a colour, hidden, or shown again. */
  tint(id: string, to: ColorRGBA, duration: number, now: number): void {
    const block = this.blocks.get(id);
    if (!block) return;
    const from = this.tints.get(id)?.current ?? block.color;
    this.tints.set(id, { from, to, start: now, duration, current: duration > 0 ? from : to });
    const record = this.records.get(id);
    if (record?.drawn) this.refresh(record);
  }

  updateTints(now: number): void {
    for (const [id, tint] of this.tints) {
      const t = tint.duration > 0 ? Math.min(1, (now - tint.start) / tint.duration) : 1;
      tint.current = {
        r: tint.from.r + (tint.to.r - tint.from.r) * t, g: tint.from.g + (tint.to.g - tint.from.g) * t,
        b: tint.from.b + (tint.to.b - tint.from.b) * t, a: tint.from.a + (tint.to.a - tint.from.a) * t,
      };
      const record = this.records.get(id);
      if (record?.drawn) this.refresh(record);
    }
  }

  /** The world changed a block's colour: an effect's tint gives way. */
  clearTint(id: string): void { this.tints.delete(id); }

  setHidden(id: string, hidden: boolean): void {
    if (hidden) this.effectHidden.add(id); else this.effectHidden.delete(id);
    this.placeSubtree(id, new Set());
  }

  worldPosition(id: string): THREE.Vector3 | null {
    const r = this.records.get(id);
    if (!r) return null;
    return new THREE.Vector3().setFromMatrixPosition(r.world);
  }

  /** The top of a block in the world, for words over it. */
  topOf(id: string): THREE.Vector3 | null {
    const r = this.records.get(id);
    if (!r) return null;
    r.world.decompose(tPos, tQuat, tScale);
    const halfHeight = Math.abs(tScale.y) * 0.5 * (r.block.shape === 'plane' ? 0.01 : 1);
    return new THREE.Vector3(tPos.x, tPos.y + halfHeight, tPos.z);
  }

  isDrawn(id: string): boolean { return this.records.get(id)?.drawn ?? false; }
  block(id: string): BlockData | undefined { return this.blocks.get(id); }
  allBlocks(): IterableIterator<BlockData> { return this.blocks.values(); }

  setProfile(profile: GraphicsProfile, world: WorldDocument): void {
    const shapesChanged = profile.smoothShapes !== this.profile.smoothShapes || profile.roundSegments !== this.profile.roundSegments;
    const lampsChanged = profile.lamps !== this.profile.lamps;
    this.profile = profile;
    if (shapesChanged || lampsChanged) this.load(world);
  }
}

/** `rotation × euler(degrees)`, for a pose on top of a block's own turn. */
export function posedRotation(rotation: Quat, degrees: Vec3): Quat {
  return quatMul(rotation, quatEulerDegrees(degrees));
}
