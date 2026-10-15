// The 3D view of a world: renderer, camera, sky, sun, ground, haze and the
// layers drawn into it — Engine/WorldScene.swift and Atmosphere.swift.
import * as THREE from 'three';
import { RoomEnvironment } from 'three/addons/environments/RoomEnvironment.js';
import type { ColorRGBA } from '../core/model/color';
import { daylight, mixColor, skyAt, sunHeight, sunPitch, sunYaw, worldHour } from '../core/model/daycycle';
import { FORWARD, quatEulerDegrees, rotate, v3, type Vec3 } from '../core/model/math';
import { weatherInfo, type EnvironmentSettings, type ScreenEffect, type WorldDocument } from '../core/model/world';
import { BlockLayer, graphicsProfiles, threeColor, type GraphicsProfile } from './blocks';
import { Overlays } from './overlays';
import { ParticleField } from './particles';
import { drawSky } from './textures';

export type GraphicsLevel = 'low' | 'medium' | 'high';

const screenFilters: Record<ScreenEffect, string> = {
  none: '',
  bloom: 'brightness(1.08) contrast(1.05) saturate(1.1)',
  vivid: 'saturate(1.45) contrast(1.08)',
  warm: 'sepia(0.18) saturate(1.15) hue-rotate(-8deg)',
  cool: 'saturate(1.05) hue-rotate(12deg) brightness(1.02)',
  noir: 'grayscale(1) contrast(1.15)',
  retro: 'contrast(1.2) saturate(1.3)',
  dream: 'saturate(1.15) brightness(1.06) blur(0.6px)',
};

export class GameScene {
  readonly renderer: THREE.WebGLRenderer;
  readonly scene = new THREE.Scene();
  readonly camera = new THREE.PerspectiveCamera(65, 1, 0.1, 1200);
  readonly blocks: BlockLayer;
  readonly particles = new ParticleField();
  readonly overlays: Overlays;
  readonly avatarRoot = new THREE.Group();
  readonly effects = new THREE.Group();
  readonly canvas: HTMLCanvasElement;
  profile: GraphicsProfile;
  level: GraphicsLevel;

  private readonly sun = new THREE.DirectionalLight(0xffffff, 2.6);
  private readonly hemi = new THREE.HemisphereLight(0xdfe9ff, 0x4b5a46, 0.6);
  private readonly sky: THREE.Mesh;
  private readonly skyMaterial = new THREE.MeshBasicMaterial({ side: THREE.BackSide, depthWrite: false, fog: false });
  private ground: THREE.Mesh | null = null;
  private skyKey = '';
  private skyClock = 10;
  private environment: EnvironmentSettings | null = null;
  private lightning = 9;
  private flash = 0;
  private readonly haze: HTMLDivElement;
  private readonly flashLayer: HTMLDivElement;
  onThunder: () => void = () => {};
  reduceFlashing = false;
  /** How strong each light is, per unit of the world's brightness. */
  lighting = { sun: 2.8, hemi: 0.42, env: 0.32, exposure: 1, toneMapping: 'neutral' as 'neutral' | 'aces' | 'agx' | 'none' };
  /** Where shadows are centred: the player. */
  focus = new THREE.Vector3();

  constructor(readonly container: HTMLElement, level: GraphicsLevel = 'high') {
    this.level = level;
    this.profile = graphicsProfiles[level];
    this.renderer = new THREE.WebGLRenderer({ antialias: level !== 'low', powerPreference: 'high-performance', alpha: false });
    this.renderer.outputColorSpace = THREE.SRGBColorSpace;
    this.renderer.toneMapping = THREE.ACESFilmicToneMapping;
    this.renderer.toneMappingExposure = 1.05;
    this.renderer.shadowMap.enabled = true;
    this.renderer.shadowMap.type = THREE.PCFShadowMap;
    this.canvas = this.renderer.domElement;
    this.canvas.className = 'ab-canvas';
    container.appendChild(this.canvas);
    this.haze = document.createElement('div');
    this.haze.className = 'ab-haze';
    container.appendChild(this.haze);
    this.flashLayer = document.createElement('div');
    this.flashLayer.className = 'ab-flash';
    container.appendChild(this.flashLayer);
    this.overlays = new Overlays(container);

    const pmrem = new THREE.PMREMGenerator(this.renderer);
    this.scene.environment = pmrem.fromScene(new RoomEnvironment(), 0.04).texture;
    this.scene.environmentIntensity = 0.45;

    this.sky = new THREE.Mesh(new THREE.SphereGeometry(1, 48, 24), this.skyMaterial);
    this.sky.scale.setScalar(600);
    this.sky.renderOrder = -1;
    this.sky.frustumCulled = false;
    this.scene.add(this.sky);

    this.sun.castShadow = true;
    this.sun.shadow.mapSize.set(2048, 2048);
    this.sun.shadow.bias = -0.0004;
    this.sun.shadow.normalBias = 0.03;
    this.scene.add(this.sun, this.sun.target, this.hemi);

    this.blocks = new BlockLayer(this.profile);
    this.particles.budget = this.profile.particleBudget;
    this.scene.add(this.blocks.root, this.avatarRoot, this.particles.root, this.effects);
    this.applyProfile();
    this.resize();
  }

  setGraphics(level: GraphicsLevel, world: WorldDocument | null): void {
    if (level === this.level) return;
    this.level = level;
    this.profile = graphicsProfiles[level];
    this.particles.budget = this.profile.particleBudget;
    if (world) this.blocks.setProfile(this.profile, world);
    this.applyProfile();
  }

  private applyProfile(): void {
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, this.profile.pixelRatio));
    this.applyShadows();
  }

  private applyShadows(): void {
    const wanted = (this.environment?.shadows ?? true) && this.profile.shadowDistance !== null;
    this.sun.castShadow = wanted;
    if (wanted) {
      const d = Math.min(60, this.profile.shadowDistance!);
      const cam = this.sun.shadow.camera;
      cam.left = -d; cam.right = d; cam.top = d; cam.bottom = -d; cam.near = 1; cam.far = 400;
      cam.updateProjectionMatrix();
    }
  }

  resize(): void {
    const w = this.container.clientWidth || window.innerWidth;
    const h = this.container.clientHeight || window.innerHeight;
    this.renderer.setSize(w, h, false);
    this.canvas.style.width = '100%';
    this.canvas.style.height = '100%';
    this.camera.aspect = w / Math.max(1, h);
    this.camera.updateProjectionMatrix();
  }

  load(world: WorldDocument): void {
    this.blocks.load(world);
    this.particles.clear();
    this.overlays.clear();
    this.skyKey = '';
    this.environment = null;
    this.setEnvironment(world.environment);
  }

  setEnvironment(env: EnvironmentSettings): void {
    this.environment = env;
    if (env.showGroundPlane) {
      if (!this.ground) {
        this.ground = new THREE.Mesh(new THREE.PlaneGeometry(400, 400), new THREE.MeshStandardMaterial({ roughness: 1 }));
        this.ground.rotation.x = -Math.PI / 2;
        this.ground.position.y = -0.05;
        this.ground.receiveShadow = true;
        this.scene.add(this.ground);
      }
      threeColor(env.groundColor, (this.ground.material as THREE.MeshStandardMaterial).color);
    } else if (this.ground) {
      this.scene.remove(this.ground);
      this.ground = null;
    }
    this.canvas.style.filter = screenFilters[env.screenEffect];
    this.canvas.style.imageRendering = env.screenEffect === 'retro' ? 'pixelated' : '';
    this.applyShadows();
  }

  /** The sky, the sun and the weather for this frame. */
  updateAtmosphere(dt: number, wallClock: number): void {
    const env = this.environment;
    if (!env) return;
    this.sky.position.copy(this.camera.position);
    let top = env.skyTop, bottom = env.skyBottom;
    let pitch = env.sunPitchDegrees, yaw = env.sunYawDegrees;
    let brightness = Math.max(0.1, env.ambientIntensity);
    let night = 0;
    const hour = worldHour(env, wallClock);
    if (hour !== null) {
      ({ top, bottom } = skyAt(hour, top, bottom));
      pitch = sunPitch(hour);
      yaw = sunYaw(hour);
      brightness *= daylight(hour);
      night = Math.max(0, Math.min(1, -sunHeight(hour) * 3));
    }
    const weather = weatherInfo[env.weather];
    if (weather.gloom > 0) {
      const greyish: ColorRGBA = { r: 0.42, g: 0.45, b: 0.5, a: 1 };
      top = mixColor(top, greyish, weather.gloom * 1.4);
      bottom = mixColor(bottom, greyish, weather.gloom * 1.2);
      brightness *= 1 - weather.gloom;
    }

    this.skyClock += dt;
    const step = (c: ColorRGBA) => [c.r, c.g, c.b].map((v) => Math.round(v * 40)).join(',');
    const key = `${env.skyStyle}|${step(top)}|${step(bottom)}|${Math.round(night * 8)}`;
    if (key !== this.skyKey && (this.skyClock > 0.5 || this.skyKey === '')) {
      this.skyKey = key;
      this.skyClock = 0;
      const old = this.skyMaterial.map;
      const texture = new THREE.CanvasTexture(drawSky(env.skyStyle, top, bottom, night) as HTMLCanvasElement);
      texture.colorSpace = THREE.SRGBColorSpace;
      this.skyMaterial.map = texture;
      this.skyMaterial.needsUpdate = true;
      old?.dispose();
      this.scene.background = threeColor(bottom, new THREE.Color());
    }

    // The sun: a light shining along its direction, from far up the other way.
    const direction = rotate(quatEulerDegrees(v3(pitch, yaw, 0)), FORWARD);
    const strength = Math.max(0.05, brightness);
    const l = this.lighting;
    this.sun.intensity = l.sun * strength;
    this.hemi.intensity = l.hemi * (0.4 + 0.6 * strength);
    this.scene.environmentIntensity = l.env * (0.4 + 0.6 * strength);
    const mapping = { neutral: THREE.NeutralToneMapping, aces: THREE.ACESFilmicToneMapping, agx: THREE.AgXToneMapping, none: THREE.NoToneMapping }[l.toneMapping];
    if (this.renderer.toneMapping !== mapping) this.renderer.toneMapping = mapping;
    this.renderer.toneMappingExposure = l.exposure;
    this.sun.target.position.copy(this.focus);
    this.sun.position.set(this.focus.x - direction.x * 120, this.focus.y - direction.y * 120, this.focus.z - direction.z * 120);
    this.sun.target.updateMatrixWorld();

    // Haze: distance fades into the horizon colour.
    const hazeAmount = weather.haze;
    const fogColor = threeColor(bottom, new THREE.Color());
    const fog = (this.scene.fog as THREE.Fog | null) ?? (this.scene.fog = new THREE.Fog(fogColor, 180, 520)) as THREE.Fog;
    fog.color.copy(fogColor);
    if (hazeAmount > 0) {
      fog.far = 260 - hazeAmount * 210;
      fog.near = Math.max(4, fog.far * 0.15);
    } else {
      fog.near = 180;
      fog.far = this.profile.viewDistance ? this.profile.viewDistance * 1.6 : 520;
    }
    this.haze.style.background = `rgba(${Math.round(bottom.r * 255)},${Math.round(bottom.g * 255)},${Math.round(bottom.b * 255)},${hazeAmount * 0.25})`;

    if (env.weather === 'storm') {
      this.lightning -= dt;
      if (this.lightning <= 0) {
        this.lightning = 7 + Math.random() * 9;
        if (!this.reduceFlashing) this.flash = 0.55;
        this.onThunder();
      }
    }
    if (this.flash > 0) this.flash = Math.max(0, this.flash - dt / 0.35 * 0.55);
    this.flashLayer.style.opacity = String(this.flash);

    // What falls from the sky, around the camera.
    if (weather.falling) {
      const p = this.camera.position;
      this.particles.stream(weather.falling, 'weather', v3(p.x, p.y + 12, p.z), weather.falling === 'rain' ? 220 : 90, dt, v3(18, 2, 18));
    }
  }

  /** Where a world point is on screen, or null when behind the camera. */
  project(point: Vec3 | THREE.Vector3, out = { x: 0, y: 0, distance: 0 }): { x: number; y: number; distance: number } | null {
    const v = new THREE.Vector3(point.x, point.y, point.z);
    const distance = v.distanceTo(this.camera.position);
    v.project(this.camera);
    if (v.z > 1 || v.z < -1) return null;
    const w = this.container.clientWidth, h = this.container.clientHeight;
    out.x = (v.x * 0.5 + 0.5) * w;
    out.y = (-v.y * 0.5 + 0.5) * h;
    out.distance = distance;
    return out;
  }

  render(): void {
    this.renderer.render(this.scene, this.camera);
  }

  dispose(): void {
    this.renderer.dispose();
    this.canvas.remove();
    this.haze.remove();
    this.flashLayer.remove();
    this.overlays.root.remove();
  }
}
