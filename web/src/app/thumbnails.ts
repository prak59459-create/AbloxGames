// Pictures of shop items drawn from the real avatar: a hat on your head, a
// face on your face, a pet on its own, an aura around you. One small
// renderer draws them a few at a time between frames, and each picture is
// kept until your colours change.
import * as THREE from 'three';
import { RoomEnvironment } from 'three/addons/environments/RoomEnvironment.js';
import type { AvatarProfile } from '../core/model/avatar';
import type { ShopItem } from '../core/model/economy';
import { hexString } from '../core/model/color';
import { AvatarModel } from '../engine/avatar';
import { wearing } from './player';

const size = 144;

interface Job { key: string; profile: AvatarProfile; kind: ShopItem['kind']; done: (url: string) => void }

class ThumbnailMaker {
  private renderer: THREE.WebGLRenderer | null = null;
  private scene = new THREE.Scene();
  private camera = new THREE.PerspectiveCamera(30, 1, 0.05, 40);
  private avatar: AvatarModel | null = null;
  private cache = new Map<string, string>();
  private waiting = new Map<string, ((url: string) => void)[]>();
  private queue: Job[] = [];
  private scheduled = false;
  private broken = false;

  private setUp(): boolean {
    if (this.renderer) return true;
    if (this.broken) return false;
    try {
      const canvas = document.createElement('canvas');
      const renderer = new THREE.WebGLRenderer({ canvas, antialias: true, alpha: true, preserveDrawingBuffer: true });
      renderer.setPixelRatio(1);
      renderer.setSize(size, size, false);
      renderer.outputColorSpace = THREE.SRGBColorSpace;
      renderer.toneMapping = THREE.ACESFilmicToneMapping;
      renderer.toneMappingExposure = 1.1;
      const pmrem = new THREE.PMREMGenerator(renderer);
      this.scene.environment = pmrem.fromScene(new RoomEnvironment(), 0.04).texture;
      this.scene.environmentIntensity = 0.6;
      const sun = new THREE.DirectionalLight(0xffffff, 2.4);
      sun.position.set(2, 5, 4);
      // A light from the front too, so a dark head still shows what it wears.
      const front = new THREE.DirectionalLight(0xffffff, 1.3);
      front.position.set(0, 1.5, 5);
      this.scene.add(sun, front, new THREE.HemisphereLight(0xdfe9ff, 0x404a66, 1.0));
      this.renderer = renderer;
      return true;
    } catch {
      this.broken = true;
      return false;
    }
  }

  /** The picture of `item` on this avatar, now if it was drawn before, or later through `done`. */
  picture(profile: AvatarProfile, item: ShopItem, done: (url: string) => void): string | null {
    const key = keyFor(profile, item);
    const cached = this.cache.get(key);
    if (cached) return cached;
    const list = this.waiting.get(key);
    if (list) { list.push(done); return null; }
    this.waiting.set(key, [done]);
    this.queue.push({ key, profile: wearing(plain(profile, item.kind), item), kind: item.kind, done: (url) => {
      this.cache.set(key, url);
      for (const d of this.waiting.get(key) ?? []) d(url);
      this.waiting.delete(key);
    } });
    this.schedule();
    return null;
  }

  private schedule(): void {
    if (this.scheduled) return;
    this.scheduled = true;
    requestAnimationFrame(() => this.work());
  }

  private work(): void {
    this.scheduled = false;
    if (!this.setUp()) { this.queue = []; return; }
    const started = performance.now();
    // A few a frame, so the page keeps moving while they are drawn.
    let drawn = 0;
    while (this.queue.length && drawn < 3 && performance.now() - started < 8) {
      drawn += 1;
      const job = this.queue.shift()!;
      try { job.done(this.draw(job)); } catch { job.done(''); }
    }
    if (this.queue.length) this.schedule();
  }

  private draw(job: Job): string {
    const renderer = this.renderer!;
    if (!this.avatar) {
      this.avatar = new AvatarModel(job.profile);
      this.scene.add(this.avatar.root);
    } else {
      this.avatar.apply(job.profile);
    }
    const a = this.avatar;
    a.teleport(new THREE.Vector3(), job.kind === 'pet' ? 210 : job.kind === 'hat' ? 195 : 180);
    a.animate(0, 0.016);
    a.rig.visible = job.kind !== 'pet';
    a.root.updateMatrixWorld(true);
    const box = new THREE.Box3();
    if (job.kind === 'pet') {
      for (const child of a.root.children) if (child !== a.rig) box.expandByObject(child);
    } else if (job.kind === 'hat' || job.kind === 'face') {
      box.setFromCenterAndSize(new THREE.Vector3(0, job.kind === 'hat' ? 1.78 : 1.55, 0), new THREE.Vector3(0.9, job.kind === 'hat' ? 1.0 : 0.62, 0.9));
    } else {
      box.setFromCenterAndSize(new THREE.Vector3(0, 1.1, 0), new THREE.Vector3(1.6, 2.6, 1.6));
    }
    if (box.isEmpty()) box.setFromCenterAndSize(new THREE.Vector3(0, 0.5, 0), new THREE.Vector3(1, 1, 1));
    const centre = box.getCenter(new THREE.Vector3());
    const extent = box.getSize(new THREE.Vector3()).length();
    const distance = (extent / 2) / Math.tan((this.camera.fov * Math.PI) / 360) * 1.05;
    const from = new THREE.Vector3(job.kind === 'pet' ? 0.5 : 0.18, job.kind === 'hat' ? 0.45 : 0.15, 1).normalize();
    this.camera.position.copy(centre).addScaledVector(from, distance);
    this.camera.lookAt(centre);
    renderer.render(this.scene, this.camera);
    return renderer.domElement.toDataURL('image/png');
  }
}

/** The avatar with nothing else that would get in the way of this kind of item. */
function plain(p: AvatarProfile, kind: ShopItem['kind']): AvatarProfile {
  const q = { ...p, ride: 'none' as const, height: 1 };
  if (kind !== 'pet') q.pet = 'none';
  if (kind !== 'aura') q.aura = 'none';
  if (kind === 'face') q.hat = 'none';
  return q;
}

function keyFor(p: AvatarProfile, item: ShopItem): string {
  const colours = [p.bodyColor, p.headColor, p.accentColor].map(hexString).join('');
  switch (item.kind) {
    case 'pet': return `${item.id}|${hexString(p.petColor)}`;
    case 'face': return `${item.id}|${colours}`;
    case 'hat': return `${item.id}|${colours}|${p.face}`;
    default: return `${item.id}|${colours}|${p.face}|${p.hat}`;
  }
}

export const thumbnails = new ThumbnailMaker();
