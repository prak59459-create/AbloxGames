// One avatar on a little stage, for Home and the closet: it turns slowly,
// can be spun with a finger or the mouse, and plays an emote when asked.
// Each stage owns a WebGL context, so it must be disposed when its page goes.
import * as THREE from 'three';
import { RoomEnvironment } from 'three/addons/environments/RoomEnvironment.js';
import type { AvatarProfile, Emote } from '../core/model/avatar';
import { AvatarModel } from '../engine/avatar';

export class AvatarStage {
  readonly canvas: HTMLCanvasElement;
  private readonly renderer: THREE.WebGLRenderer;
  private readonly scene = new THREE.Scene();
  private readonly camera = new THREE.PerspectiveCamera(32, 1, 0.1, 50);
  private readonly avatar: AvatarModel;
  private readonly owned: { dispose(): void }[] = [];
  private readonly resizer: ResizeObserver | null;
  private frame = 0;
  private last = 0;
  private yaw = 200;
  private spin = 18;
  private dragging: { x: number; yaw: number } | null = null;
  private visible = true;
  private readonly watcher: IntersectionObserver | null;

  constructor(readonly parent: HTMLElement, profile: AvatarProfile, options: { zoom?: number; turning?: boolean } = {}) {
    this.renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true, powerPreference: 'low-power' });
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
    this.renderer.outputColorSpace = THREE.SRGBColorSpace;
    this.renderer.toneMapping = THREE.ACESFilmicToneMapping;
    this.renderer.toneMappingExposure = 1.1;
    this.renderer.shadowMap.enabled = true;
    this.canvas = this.renderer.domElement;
    this.canvas.className = 'ab-avatar-stage';
    parent.appendChild(this.canvas);

    const pmrem = new THREE.PMREMGenerator(this.renderer);
    const environment = pmrem.fromScene(new RoomEnvironment(), 0.04).texture;
    this.scene.environment = environment;
    this.scene.environmentIntensity = 0.55;
    this.owned.push(environment, pmrem);

    const sun = new THREE.DirectionalLight(0xffffff, 2.4);
    sun.position.set(2.5, 6, 4);
    sun.castShadow = true;
    sun.shadow.mapSize.set(1024, 1024);
    const cam = sun.shadow.camera;
    cam.left = -3; cam.right = 3; cam.top = 3; cam.bottom = -3; cam.near = 0.5; cam.far = 20;
    this.scene.add(sun, new THREE.HemisphereLight(0xdfe9ff, 0x404a66, 0.7));

    // The stage: a round block with a glowing rim.
    const top = new THREE.CylinderGeometry(1.25, 1.35, 0.28, 48);
    const rim = new THREE.TorusGeometry(1.3, 0.035, 8, 64);
    const topMaterial = new THREE.MeshStandardMaterial({ color: 0x1f2a52, roughness: 0.5, metalness: 0.1 });
    const rimMaterial = new THREE.MeshBasicMaterial({ color: 0x22d3ee });
    const pedestal = new THREE.Mesh(top, topMaterial);
    pedestal.position.y = -0.14;
    pedestal.receiveShadow = true;
    const glow = new THREE.Mesh(rim, rimMaterial);
    glow.rotation.x = Math.PI / 2;
    glow.position.y = 0.0;
    this.scene.add(pedestal, glow);
    this.owned.push(top, rim, topMaterial, rimMaterial);

    this.avatar = new AvatarModel(profile);
    this.avatar.root.traverse((o) => { if ((o as THREE.Mesh).isMesh) o.castShadow = true; });
    this.scene.add(this.avatar.root);

    const zoom = options.zoom ?? 1;
    this.camera.position.set(0, 1.55, 6.4 / zoom);
    this.camera.lookAt(0, 1.05, 0);
    if (options.turning === false) this.spin = 0;

    this.canvas.addEventListener('pointerdown', this.down);
    window.addEventListener('pointermove', this.move);
    window.addEventListener('pointerup', this.up);
    this.resizer = typeof ResizeObserver === 'function' ? new ResizeObserver(() => this.resize()) : null;
    this.resizer?.observe(parent);
    // Off screen (scrolled away, or a hidden tab): no drawing.
    this.watcher = typeof IntersectionObserver === 'function'
      ? new IntersectionObserver((entries) => { this.visible = entries.some((e) => e.isIntersecting); })
      : null;
    this.watcher?.observe(this.canvas);
    this.resize();
    this.frame = requestAnimationFrame(this.tick);
  }

  /** New clothes, a new hat: rebuilt in place. */
  show(profile: AvatarProfile): void {
    this.avatar.apply(profile);
    this.avatar.root.traverse((o) => { if ((o as THREE.Mesh).isMesh) o.castShadow = true; });
  }

  play(emote: Emote): void {
    this.avatar.play(emote);
  }

  private resize(): void {
    const w = Math.max(1, this.parent.clientWidth), h = Math.max(1, this.parent.clientHeight);
    this.renderer.setSize(w, h, false);
    this.canvas.style.width = '100%';
    this.canvas.style.height = '100%';
    this.camera.aspect = w / h;
    this.camera.updateProjectionMatrix();
  }

  private readonly tick = (now: number) => {
    this.frame = requestAnimationFrame(this.tick);
    const dt = this.last ? Math.min(0.1, (now - this.last) / 1000) : 0;
    this.last = now;
    if (!this.visible || document.hidden) return;
    if (!this.dragging) this.yaw = (this.yaw + this.spin * dt) % 360;
    this.avatar.teleport(new THREE.Vector3(0, 0, 0), this.yaw);
    this.avatar.animate(0, dt);
    this.renderer.render(this.scene, this.camera);
  };

  private readonly down = (e: PointerEvent) => {
    this.dragging = { x: e.clientX, yaw: this.yaw };
    this.canvas.setPointerCapture?.(e.pointerId);
  };

  private readonly move = (e: PointerEvent) => {
    if (!this.dragging) return;
    this.yaw = this.dragging.yaw - (e.clientX - this.dragging.x) * 0.8;
  };

  private readonly up = () => { this.dragging = null; };

  dispose(): void {
    cancelAnimationFrame(this.frame);
    this.canvas.removeEventListener('pointerdown', this.down);
    window.removeEventListener('pointermove', this.move);
    window.removeEventListener('pointerup', this.up);
    this.resizer?.disconnect();
    this.watcher?.disconnect();
    this.avatar.dispose();
    for (const o of this.owned) o.dispose();
    this.renderer.dispose();
    this.renderer.forceContextLoss();
    this.canvas.remove();
  }
}
