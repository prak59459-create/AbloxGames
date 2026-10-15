// A blocky avatar — Engine/AvatarEntity.swift, AvatarWardrobe.swift,
// AvatarPoses.swift and AvatarMoves.swift — built from the same boxes,
// cylinders, cones and spheres at the same sizes, so a player looks the same
// in a browser as on an iPad.
import * as THREE from 'three';
import { RoundedBoxGeometry } from 'three/addons/geometries/RoundedBoxGeometry.js';
import { mergeGeometries } from 'three/addons/utils/BufferGeometryUtils.js';
import type { ColorRGBA } from '../core/model/color';
import { auraColors, auraOrbs, flyingPets, seatedRides, type AvatarProfile, type Emote, type Face, type Hat, type Pet, type Ride } from '../core/model/avatar';
import { angularDelta, normalizeDegrees } from '../core/model/math';
import { threeColor } from './blocks';

type V3 = [number, number, number];

// MARK: - Shared meshes and materials

const geometries = new Map<string, THREE.BufferGeometry>();

function box(w: number, h: number, d: number, corner = 0): THREE.BufferGeometry {
  const key = `b${w},${h},${d},${corner}`;
  let g = geometries.get(key);
  if (!g) {
    g = corner > 0 ? new RoundedBoxGeometry(w, h, d, 2, Math.min(corner, Math.min(w, h, d) / 2 - 1e-4)) : new THREE.BoxGeometry(w, h, d);
    geometries.set(key, g);
  }
  return g;
}

function ball(r: number): THREE.BufferGeometry {
  const key = `s${r}`;
  let g = geometries.get(key);
  if (!g) { g = new THREE.SphereGeometry(r, 20, 14); geometries.set(key, g); }
  return g;
}

function tube(h: number, r: number): THREE.BufferGeometry {
  const key = `c${h},${r}`;
  let g = geometries.get(key);
  if (!g) { g = new THREE.CylinderGeometry(r, r, h, 24); geometries.set(key, g); }
  return g;
}

function cone(h: number, r: number): THREE.BufferGeometry {
  const key = `k${h},${r}`;
  let g = geometries.get(key);
  if (!g) { g = new THREE.ConeGeometry(r, h, 24); geometries.set(key, g); }
  return g;
}

const materials = new Map<string, THREE.Material>();

/** A lit, slightly rough colour, as the avatar's SimpleMaterial. */
function lit(c: ColorRGBA, metallic = 0): THREE.Material {
  const key = `l${c.r.toFixed(3)},${c.g.toFixed(3)},${c.b.toFixed(3)},${metallic}`;
  let m = materials.get(key);
  if (!m) {
    m = new THREE.MeshStandardMaterial({ color: threeColor(c, new THREE.Color()), roughness: 0.55, metalness: metallic });
    materials.set(key, m);
  }
  return m;
}

/** Unlit: ink for eyes, a lamp, a flame. */
function flat(r: number, g: number, b: number): THREE.Material {
  const key = `u${r},${g},${b}`;
  let m = materials.get(key);
  if (!m) {
    m = new THREE.MeshBasicMaterial({ color: new THREE.Color().setRGB(r, g, b, THREE.SRGBColorSpace), toneMapped: false });
    materials.set(key, m);
  }
  return m;
}

const rgb = (r: number, g: number, b: number): ColorRGBA => ({ r, g, b, a: 1 });
const ink = () => flat(0.1, 0.11, 0.14);
const W = {
  white: () => lit(rgb(0.97, 0.97, 0.96)),
  dark: () => lit(rgb(0.14, 0.15, 0.18)),
  gold: () => lit(rgb(0.98, 0.78, 0.2), 0.6),
  pink: () => flat(0.98, 0.45, 0.62),
  orange: () => flat(1, 0.6, 0.15),
  tearBlue: () => flat(0.35, 0.7, 1),
  yellow: () => flat(1, 0.86, 0.2),
  red: () => lit(rgb(0.86, 0.15, 0.2)),
  green: () => lit(rgb(0.35, 0.8, 0.4)),
};

const X = new THREE.Vector3(1, 0, 0), Y = new THREE.Vector3(0, 1, 0), Z = new THREE.Vector3(0, 0, 1);
const turn = (angle: number, axis: THREE.Vector3) => new THREE.Quaternion().setFromAxisAngle(axis, angle);

function add(parent: THREE.Object3D, geometry: THREE.BufferGeometry, material: THREE.Material, at: V3,
  angle = 0, axis: THREE.Vector3 = Z, scale?: V3): THREE.Mesh {
  const mesh = new THREE.Mesh(geometry, material);
  mesh.position.set(...at);
  if (angle !== 0) mesh.quaternion.copy(turn(angle, axis));
  if (scale) mesh.scale.set(...scale);
  mesh.castShadow = true;
  parent.add(mesh);
  return mesh;
}

/** Bakes a group of parts into one mesh per material: fewer draw calls for a crowd. */
function merged(group: THREE.Group, keep?: THREE.Object3D): THREE.Group {
  const byMaterial = new Map<THREE.Material, THREE.BufferGeometry[]>();
  group.updateMatrixWorld(true);
  const inverse = new THREE.Matrix4().copy(group.matrixWorld).invert();
  const loose: THREE.Object3D[] = [];
  group.traverse((o) => {
    if (o === group || o === keep || (keep && isInside(o, keep))) return;
    if (o instanceof THREE.Mesh) {
      const g = (o.geometry as THREE.BufferGeometry).clone();
      g.applyMatrix4(new THREE.Matrix4().multiplyMatrices(inverse, o.matrixWorld));
      const list = byMaterial.get(o.material as THREE.Material) ?? [];
      list.push(g.index ? g : g);
      byMaterial.set(o.material as THREE.Material, list);
    }
  });
  if (keep) loose.push(keep);
  const out = new THREE.Group();
  out.name = group.name;
  out.position.copy(group.position);
  out.quaternion.copy(group.quaternion);
  out.scale.copy(group.scale);
  for (const [material, list] of byMaterial) {
    const indexed = list.map((g) => (g.index ? g : g.toNonIndexed()));
    const allIndexed = indexed.every((g) => g.index);
    const geometry = mergeGeometries(allIndexed ? indexed : indexed.map((g) => (g.index ? g.toNonIndexed() : g)), false);
    if (!geometry) continue;
    const mesh = new THREE.Mesh(geometry, material);
    mesh.castShadow = true;
    out.add(mesh);
  }
  for (const o of loose) {
    o.removeFromParent();
    out.add(o);
  }
  return out;
}

function isInside(o: THREE.Object3D, ancestor: THREE.Object3D): boolean {
  for (let p = o.parent; p; p = p.parent) if (p === ancestor) return true;
  return false;
}

// MARK: - Faces

function buildFace(face: Face, headMaterial: THREE.Material): THREE.Group {
  const group = new THREE.Group();
  const front = -0.228;
  const part = (w: number, h: number, x: number, y: number, m: THREE.Material = ink(), angle = 0) =>
    add(group, box(w, h, 0.012), m, [x, y, front], angle);
  const eyes = (w = 0.07, h = 0.09) => { part(w, h, -0.1, 0.05); part(w, h, 0.1, 0.05); };
  const closedEye = (x: number) => { part(0.06, 0.022, x - 0.022, 0.05, ink(), 0.5); part(0.06, 0.022, x + 0.022, 0.05, ink(), -0.5); };
  switch (face) {
    case 'smile': eyes(); part(0.16, 0.035, 0, -0.09); break;
    case 'grin': eyes(); part(0.24, 0.07, 0, -0.09, flat(1, 1, 1)); part(0.26, 0.02, 0, -0.05); break;
    case 'wink': part(0.09, 0.022, -0.1, 0.05); part(0.07, 0.09, 0.1, 0.05); part(0.16, 0.035, 0.02, -0.09); break;
    case 'cool': part(0.38, 0.1, 0, 0.05); part(0.14, 0.03, 0, -0.1); break;
    case 'surprised': eyes(0.08, 0.1); part(0.08, 0.08, 0, -0.1); break;
    case 'sleepy': part(0.09, 0.022, -0.1, 0.04); part(0.09, 0.022, 0.1, 0.04); part(0.07, 0.03, 0, -0.1); break;
    case 'cat':
      eyes(0.06, 0.1);
      part(0.05, 0.03, -0.035, -0.08); part(0.05, 0.03, 0.035, -0.08);
      part(0.04, 0.03, 0, -0.05, flat(0.96, 0.45, 0.6));
      for (const side of [-1, 1]) add(group, box(0.1, 0.12, 0.06), headMaterial, [side * 0.14, 0.27, 0], side * 0.3);
      break;
    case 'robot':
      part(0.34, 0.09, 0, 0.05, flat(0.3, 0.85, 1));
      for (let i = 0; i < 4; i++) part(0.03, 0.05, -0.06 + i * 0.04, -0.1);
      break;
    case 'heart': {
      const pink = flat(0.98, 0.3, 0.5);
      for (const x of [-0.1, 0.1]) { part(0.05, 0.05, x - 0.022, 0.07, pink); part(0.05, 0.05, x + 0.022, 0.07, pink); part(0.06, 0.05, x, 0.035, pink); }
      part(0.16, 0.035, 0, -0.09);
      break;
    }
    case 'angry': eyes(0.07, 0.07); part(0.1, 0.025, -0.1, 0.12, ink(), -0.35); part(0.1, 0.025, 0.1, 0.12, ink(), 0.35); part(0.14, 0.03, 0, -0.1); break;
    case 'sad':
      eyes(0.06, 0.08); part(0.09, 0.02, -0.1, 0.12, ink(), 0.3); part(0.09, 0.02, 0.1, 0.12, ink(), -0.3);
      part(0.1, 0.025, 0, -0.1); part(0.025, 0.05, -0.12, -0.02, W.tearBlue());
      break;
    case 'tongue': eyes(); part(0.16, 0.03, 0, -0.08); part(0.07, 0.07, 0.03, -0.12, W.pink()); break;
    case 'star_eyes':
      for (const x of [-0.1, 0.1]) {
        part(0.1, 0.035, x, 0.05, W.yellow()); part(0.035, 0.1, x, 0.05, W.yellow());
        part(0.07, 0.035, x, 0.05, W.yellow(), Math.PI / 4); part(0.07, 0.035, x, 0.05, W.yellow(), -Math.PI / 4);
      }
      part(0.16, 0.035, 0, -0.09);
      break;
    case 'dizzy':
      for (const x of [-0.1, 0.1]) { part(0.1, 0.022, x, 0.05, ink(), Math.PI / 4); part(0.1, 0.022, x, 0.05, ink(), -Math.PI / 4); }
      for (let i = 0; i < 4; i++) part(0.045, 0.02, -0.07 + i * 0.045, -0.09 + (i % 2 === 0 ? 0.01 : -0.01));
      break;
    case 'glasses':
      eyes(0.05, 0.06);
      for (const x of [-0.1, 0.1]) { part(0.13, 0.02, x, 0.1); part(0.13, 0.02, x, 0); part(0.02, 0.1, x - 0.065, 0.05); part(0.02, 0.1, x + 0.065, 0.05); }
      part(0.06, 0.02, 0, 0.07); part(0.14, 0.03, 0, -0.1);
      break;
    case 'monocle':
      eyes();
      part(0.14, 0.018, 0.1, 0.11, W.gold()); part(0.14, 0.018, 0.1, -0.01, W.gold());
      part(0.018, 0.12, 0.03, 0.05, W.gold()); part(0.018, 0.12, 0.17, 0.05, W.gold()); part(0.012, 0.16, 0.17, -0.09, W.gold());
      part(0.14, 0.03, -0.02, -0.1);
      break;
    case 'blush': eyes(); part(0.16, 0.035, 0, -0.09); part(0.07, 0.035, -0.16, -0.03, W.pink()); part(0.07, 0.035, 0.16, -0.03, W.pink()); break;
    case 'alien': part(0.12, 0.15, -0.1, 0.04, ink(), 0.35); part(0.12, 0.15, 0.1, 0.04, ink(), -0.35); part(0.06, 0.02, 0, -0.11); break;
    case 'eyepatch': part(0.1, 0.1, -0.1, 0.05); part(0.5, 0.02, 0, 0.09, ink(), -0.25); part(0.07, 0.09, 0.1, 0.05); part(0.16, 0.035, 0.02, -0.09); break;
    case 'ninja': part(0.46, 0.2, 0, -0.08); eyes(0.08, 0.05); part(0.46, 0.05, 0, 0.13); break;
    case 'joy':
      closedEye(-0.1); closedEye(0.1); part(0.18, 0.07, 0, -0.1, W.white());
      part(0.03, 0.07, -0.17, 0, W.tearBlue()); part(0.03, 0.07, 0.17, 0, W.tearBlue());
      break;
    case 'mustache': eyes(); part(0.11, 0.035, -0.055, -0.07, ink(), 0.25); part(0.11, 0.035, 0.055, -0.07, ink(), -0.25); part(0.07, 0.02, 0, -0.12); break;
    case 'fangs':
      part(0.07, 0.09, -0.1, 0.05, W.red()); part(0.07, 0.09, 0.1, 0.05, W.red()); part(0.18, 0.03, 0, -0.08);
      part(0.025, 0.045, -0.05, -0.11, W.white()); part(0.025, 0.045, 0.05, -0.11, W.white());
      break;
    case 'happy':
      closedEye(-0.1); closedEye(0.1); part(0.18, 0.035, 0, -0.09);
      part(0.04, 0.03, -0.09, -0.07, ink(), 0.4); part(0.04, 0.03, 0.09, -0.07, ink(), -0.4);
      break;
  }
  return merged(group);
}

// MARK: - Hats

const SPIN = 'ablox.avatar.hat.spin';

function buildHat(hat: Hat, main: THREE.Material): THREE.Group | null {
  const root = new THREE.Group();
  root.name = 'ablox.avatar.hat';
  let spinning: THREE.Mesh | undefined;
  switch (hat) {
    case 'none': return null;
    case 'cap': add(root, box(0.5, 0.12, 0.5, 0.04), main, [0, 1.8, 0]); break;
    case 'crown': add(root, tube(0.2, 0.26), main, [0, 1.86, 0]); break;
    case 'antenna': add(root, tube(0.5, 0.03), main, [0, 2.0, 0]); break;
    case 'halo': add(root, tube(0.04, 0.32), main, [0, 2.05, 0]); break;
    case 'top_hat': add(root, tube(0.03, 0.34), main, [0, 1.77, 0]); add(root, tube(0.34, 0.21), main, [0, 1.95, 0]); add(root, tube(0.06, 0.215), W.dark(), [0, 1.82, 0]); break;
    case 'beanie': add(root, ball(0.26), main, [0, 1.74, 0], 0, Z, [1, 0.72, 1]); add(root, tube(0.07, 0.255), W.white(), [0, 1.72, 0]); add(root, ball(0.07), W.white(), [0, 1.95, 0]); break;
    case 'cowboy': add(root, tube(0.03, 0.44), main, [0, 1.77, 0], 0, Z, [1, 1, 0.8]); add(root, tube(0.22, 0.2), main, [0, 1.9, 0]); add(root, tube(0.04, 0.205), W.dark(), [0, 1.81, 0]); break;
    case 'wizard':
      add(root, tube(0.03, 0.36), main, [0, 1.77, 0]); add(root, cone(0.55, 0.25), main, [0, 2.06, 0], 0.15);
      add(root, ball(0.04), W.yellow(), [0.1, 2.0, -0.2]); add(root, ball(0.03), W.yellow(), [-0.08, 1.92, -0.22]);
      break;
    case 'pirate': add(root, box(0.62, 0.2, 0.3, 0.05), W.dark(), [0, 1.86, 0]); add(root, box(0.12, 0.1, 0.02), W.white(), [0, 1.88, -0.16]); add(root, box(0.64, 0.04, 0.32), main, [0, 1.77, 0]); break;
    case 'chef': add(root, tube(0.28, 0.2), W.white(), [0, 1.9, 0]); add(root, ball(0.25), W.white(), [0, 2.1, 0], 0, Z, [1, 0.7, 1]); break;
    case 'party': add(root, cone(0.42, 0.15), main, [0, 1.97, 0]); add(root, ball(0.055), W.yellow(), [0, 2.2, 0]); add(root, tube(0.03, 0.12), W.white(), [0, 1.88, 0]); break;
    case 'headphones':
      add(root, box(0.54, 0.05, 0.08, 0.02), W.dark(), [0, 1.8, 0]);
      for (const side of [-1, 1]) { add(root, box(0.05, 0.22, 0.08), W.dark(), [side * 0.27, 1.68, 0]); add(root, tube(0.08, 0.1), main, [side * 0.27, 1.53, 0], Math.PI / 2); }
      break;
    case 'bunny_ears':
      for (const side of [-1, 1]) {
        add(root, box(0.09, 0.32, 0.05, 0.03), W.white(), [side * 0.1, 1.94, 0], -side * 0.15);
        add(root, box(0.05, 0.24, 0.01), W.pink(), [side * 0.1, 1.94, -0.03], -side * 0.15);
      }
      break;
    case 'horns': for (const side of [-1, 1]) add(root, cone(0.18, 0.055), W.white(), [side * 0.16, 1.83, -0.04], -side * 0.45); break;
    case 'flower_crown': {
      add(root, tube(0.04, 0.24), W.green(), [0, 1.76, 0]);
      const colours = [W.pink(), W.yellow(), W.white(), main];
      for (let i = 0; i < 8; i++) { const a = (i / 8) * 2 * Math.PI; add(root, ball(0.055), colours[i % 4], [Math.cos(a) * 0.24, 1.79, Math.sin(a) * 0.24]); }
      break;
    }
    case 'bow':
      add(root, box(0.16, 0.12, 0.05, 0.03), main, [-0.1, 1.82, -0.05], 0.35); add(root, box(0.16, 0.12, 0.05, 0.03), main, [0.1, 1.82, -0.05], -0.35);
      add(root, box(0.06, 0.06, 0.06, 0.02), main, [0, 1.82, -0.05]);
      break;
    case 'helmet': add(root, ball(0.3), main, [0, 1.66, 0], 0, Z, [1, 0.78, 1]); add(root, box(0.4, 0.12, 0.04), W.dark(), [0, 1.6, -0.27]); break;
    case 'viking':
      add(root, ball(0.27), W.dark(), [0, 1.74, 0], 0, Z, [1, 0.62, 1]); add(root, tube(0.05, 0.27), W.gold(), [0, 1.72, 0]);
      for (const side of [-1, 1]) add(root, cone(0.24, 0.06), W.white(), [side * 0.3, 1.86, 0], -side * 0.9);
      break;
    case 'beret': add(root, tube(0.08, 0.27), main, [0.03, 1.8, 0], -0.12); add(root, tube(0.05, 0.015), main, [0.03, 1.86, 0]); break;
    case 'propeller':
      add(root, ball(0.25), main, [0, 1.74, 0], 0, Z, [1, 0.55, 1]); add(root, tube(0.08, 0.02), W.dark(), [0, 1.88, 0]);
      spinning = add(root, box(0.5, 0.012, 0.07, 0.005), W.red(), [0, 1.93, 0]);
      spinning.name = SPIN;
      break;
    case 'graduate':
      add(root, tube(0.12, 0.22), W.dark(), [0, 1.8, 0]); add(root, box(0.56, 0.03, 0.56), W.dark(), [0, 1.88, 0], Math.PI / 4, Y);
      add(root, box(0.02, 0.18, 0.02), W.gold(), [0.26, 1.8, -0.1]);
      break;
    case 'santa': add(root, cone(0.42, 0.24), W.red(), [0, 1.98, 0.05], 0.35, X); add(root, tube(0.07, 0.25), W.white(), [0, 1.78, 0]); add(root, ball(0.06), W.white(), [0, 2.14, 0.17]); break;
    case 'witch': add(root, tube(0.03, 0.42), main, [0, 1.77, 0]); add(root, cone(0.6, 0.22), main, [0, 2.08, 0.02], -0.12, X); add(root, tube(0.05, 0.225), W.gold(), [0, 1.82, 0]); break;
    case 'headband':
      add(root, tube(0.08, 0.235), main, [0, 1.66, 0]);
      for (const side of [-1, 1]) add(root, box(0.05, 0.16, 0.02), main, [side * 0.06, 1.6, 0.25], side * 0.4);
      break;
  }
  return merged(root, spinning);
}

// MARK: - Pets

function buildPet(pet: Pet, skin: THREE.Material): THREE.Group | null {
  if (pet === 'none') return null;
  const root = new THREE.Group();
  root.name = 'ablox.avatar.pet';
  const dark = ink();
  const part = (size: V3, at: V3, m?: THREE.Material, tilt = 0) => add(root, box(size[0], size[1], size[2], Math.min(...size) * 0.2), m ?? skin, at, tilt);
  const eyes = (y: number, z: number, spread = 0.04, size = 0.03) => { part([size, size, 0.01], [-spread, y, z], dark); part([size, size, 0.01], [spread, y, z], dark); };
  switch (pet) {
    case 'cat': case 'dog':
      part([0.22, 0.2, 0.36], [0, 0.2, 0]); part([0.22, 0.2, 0.2], [0, 0.36, -0.2]);
      for (const x of [-0.07, 0.07]) {
        part([0.06, 0.12, 0.06], [x, 0.05, -0.12]); part([0.06, 0.12, 0.06], [x, 0.05, 0.12]);
        part([0.035, 0.035, 0.01], [x * 0.8, 0.39, -0.305], dark);
      }
      if (pet === 'cat') {
        part([0.06, 0.08, 0.04], [-0.07, 0.5, -0.2], undefined, 0.3); part([0.06, 0.08, 0.04], [0.07, 0.5, -0.2], undefined, -0.3);
        part([0.04, 0.24, 0.04], [0, 0.35, 0.2], undefined, 0.2);
      } else {
        part([0.06, 0.12, 0.05], [-0.12, 0.4, -0.2], undefined, -0.4); part([0.06, 0.12, 0.05], [0.12, 0.4, -0.2], undefined, 0.4);
        part([0.08, 0.06, 0.08], [0, 0.33, -0.32]); part([0.04, 0.16, 0.04], [0, 0.32, 0.2], undefined, -0.5);
      }
      break;
    case 'bunny':
      part([0.22, 0.22, 0.26], [0, 0.14, 0]); part([0.18, 0.18, 0.18], [0, 0.3, -0.12]);
      part([0.05, 0.22, 0.04], [-0.05, 0.5, -0.12]); part([0.05, 0.22, 0.04], [0.05, 0.5, -0.12]);
      part([0.03, 0.03, 0.01], [-0.04, 0.33, -0.215], dark); part([0.03, 0.03, 0.01], [0.04, 0.33, -0.215], dark);
      break;
    case 'bird':
      part([0.14, 0.14, 0.2], [0, 0, 0]); part([0.04, 0.03, 0.06], [0, 0.02, -0.13], flat(1, 0.5, 0));
      part([0.18, 0.02, 0.1], [-0.12, 0.03, 0.02], undefined, 0.4); part([0.18, 0.02, 0.1], [0.12, 0.03, 0.02], undefined, -0.4);
      break;
    case 'slime':
      add(root, ball(0.17), skin, [0, 0.14, 0], 0, Z, [1.1, 0.8, 1.1]);
      part([0.03, 0.05, 0.01], [-0.05, 0.18, -0.17], dark); part([0.03, 0.05, 0.01], [0.05, 0.18, -0.17], dark);
      break;
    case 'robot':
      part([0.24, 0.22, 0.2], [0, 0.22, 0]); part([0.18, 0.14, 0.16], [0, 0.41, 0]);
      part([0.12, 0.03, 0.01], [0, 0.42, -0.085], flat(0.3, 0.9, 1)); part([0.02, 0.12, 0.02], [0, 0.54, 0]); part([0.1, 0.1, 0.1], [0, 0.06, 0], dark);
      break;
    case 'dragon':
      part([0.18, 0.16, 0.3], [0, 0, 0]); part([0.14, 0.13, 0.16], [0, 0.1, -0.2]);
      part([0.26, 0.02, 0.16], [-0.2, 0.08, 0.02], undefined, 0.5); part([0.26, 0.02, 0.16], [0.2, 0.08, 0.02], undefined, -0.5);
      part([0.05, 0.05, 0.22], [0, -0.02, 0.24]);
      part([0.03, 0.03, 0.01], [-0.04, 0.13, -0.285], flat(1, 1, 0)); part([0.03, 0.03, 0.01], [0.04, 0.13, -0.285], flat(1, 1, 0));
      break;
    case 'fox':
      part([0.2, 0.18, 0.34], [0, 0.19, 0]); part([0.2, 0.18, 0.2], [0, 0.34, -0.2]); part([0.08, 0.06, 0.1], [0, 0.31, -0.33], W.white());
      for (const x of [-0.07, 0.07]) {
        part([0.06, 0.11, 0.06], [x, 0.05, -0.12]); part([0.06, 0.11, 0.06], [x, 0.05, 0.12]);
        part([0.06, 0.1, 0.04], [x, 0.47, -0.2], undefined, x < 0 ? 0.25 : -0.25);
      }
      part([0.1, 0.1, 0.26], [0, 0.26, 0.28]); part([0.1, 0.1, 0.08], [0, 0.26, 0.43], W.white());
      eyes(0.37, -0.305, 0.055);
      break;
    case 'panda':
      part([0.26, 0.24, 0.34], [0, 0.2, 0], W.white()); part([0.24, 0.22, 0.22], [0, 0.4, -0.2], W.white());
      for (const x of [-0.08, 0.08]) {
        part([0.08, 0.13, 0.08], [x, 0.06, -0.12], W.dark()); part([0.08, 0.13, 0.08], [x, 0.06, 0.12], W.dark());
        part([0.07, 0.07, 0.05], [x * 1.1, 0.53, -0.2], W.dark()); part([0.06, 0.07, 0.01], [x * 0.7, 0.42, -0.311], W.dark());
      }
      part([0.04, 0.03, 0.01], [0, 0.36, -0.312], dark);
      break;
    case 'penguin':
      part([0.22, 0.34, 0.2], [0, 0.2, 0], W.dark()); part([0.16, 0.26, 0.02], [0, 0.18, -0.1], W.white());
      part([0.06, 0.04, 0.08], [0, 0.3, -0.13], W.orange()); part([0.06, 0.03, 0.08], [-0.05, 0.02, -0.04], W.orange()); part([0.06, 0.03, 0.08], [0.05, 0.02, -0.04], W.orange());
      part([0.03, 0.18, 0.1], [-0.12, 0.2, 0], W.dark(), 0.2); part([0.03, 0.18, 0.1], [0.12, 0.2, 0], W.dark(), -0.2);
      eyes(0.34, -0.105, 0.045, 0.025);
      break;
    case 'frog':
      part([0.3, 0.14, 0.26], [0, 0.09, 0]);
      for (const x of [-0.08, 0.08]) {
        add(root, ball(0.05), W.white(), [x, 0.19, -0.08]); part([0.03, 0.03, 0.01], [x, 0.2, -0.13], dark); part([0.08, 0.04, 0.1], [x * 1.9, 0.02, 0.06]);
      }
      part([0.16, 0.012, 0.01], [0, 0.07, -0.131], dark);
      break;
    case 'turtle':
      add(root, ball(0.18), W.green(), [0, 0.12, 0], 0, Z, [1, 0.55, 1.2]); part([0.1, 0.09, 0.12], [0, 0.1, -0.24]);
      for (const x of [-0.12, 0.12]) { part([0.06, 0.06, 0.06], [x, 0.03, -0.12]); part([0.06, 0.06, 0.06], [x, 0.03, 0.12]); }
      eyes(0.12, -0.301, 0.03, 0.02);
      break;
    case 'duck':
      part([0.2, 0.16, 0.26], [0, 0.12, 0]); part([0.14, 0.14, 0.14], [0, 0.26, -0.1]); part([0.08, 0.03, 0.08], [0, 0.24, -0.2], W.orange());
      part([0.03, 0.08, 0.14], [-0.11, 0.14, 0.02]); part([0.03, 0.08, 0.14], [0.11, 0.14, 0.02]);
      eyes(0.3, -0.171, 0.04, 0.022);
      break;
    case 'bee':
      part([0.16, 0.14, 0.22], [0, 0, 0], W.yellow()); part([0.165, 0.145, 0.04], [0, 0, 0], dark); part([0.165, 0.145, 0.04], [0, 0, 0.07], dark);
      part([0.16, 0.012, 0.1], [-0.13, 0.08, 0.02], W.white(), 0.4); part([0.16, 0.012, 0.1], [0.13, 0.08, 0.02], W.white(), -0.4);
      eyes(0.02, -0.111, 0.035, 0.025);
      break;
    case 'ghost':
      add(root, ball(0.16), W.white(), [0, 0, 0], 0, Z, [1, 1.25, 1]); part([0.3, 0.05, 0.3], [0, -0.17, 0], W.white());
      part([0.035, 0.06, 0.01], [-0.05, 0.04, -0.16], dark); part([0.035, 0.06, 0.01], [0.05, 0.04, -0.16], dark); part([0.04, 0.04, 0.01], [0, -0.03, -0.16], dark);
      break;
    case 'unicorn':
      part([0.22, 0.2, 0.36], [0, 0.22, 0], W.white()); part([0.18, 0.2, 0.2], [0, 0.4, -0.2], W.white());
      add(root, cone(0.16, 0.03), W.gold(), [0, 0.57, -0.24], -0.3, X);
      part([0.06, 0.24, 0.24], [0, 0.4, -0.05], W.pink()); part([0.06, 0.2, 0.06], [0, 0.26, 0.21], W.pink());
      for (const x of [-0.07, 0.07]) { part([0.06, 0.13, 0.06], [x, 0.06, -0.12], W.white()); part([0.06, 0.13, 0.06], [x, 0.06, 0.12], W.white()); }
      eyes(0.43, -0.301, 0.05);
      break;
    case 'owl':
      part([0.2, 0.24, 0.18], [0, 0, 0]);
      for (const x of [-0.05, 0.05]) {
        add(root, ball(0.045), W.white(), [x, 0.05, -0.08]); part([0.025, 0.025, 0.01], [x, 0.05, -0.125], dark);
        part([0.05, 0.06, 0.03], [x * 1.4, 0.14, 0], undefined, x < 0 ? 0.3 : -0.3);
      }
      part([0.035, 0.04, 0.04], [0, 0, -0.1], W.orange());
      part([0.03, 0.16, 0.12], [-0.11, -0.02, 0.02], undefined, 0.15); part([0.03, 0.16, 0.12], [0.11, -0.02, 0.02], undefined, -0.15);
      break;
  }
  return merged(root);
}

// MARK: - Rides

const seatHeights: Record<Ride, number> = { none: 0, car: -0.45, sports: -0.55, truck: -0.1, kart: -0.55, bike: 0.15, scooter: 0.1, jetpack: 0, hoverboard: 0.18 };

function buildRide(ride: Ride, color: ColorRGBA): THREE.Group | null {
  if (ride === 'none') return null;
  const root = new THREE.Group();
  root.name = 'ablox.avatar.ride';
  const paint = lit(color), dark = lit(rgb(0.12, 0.13, 0.16)), glass = lit(rgb(0.73, 0.9, 0.99));
  const lamp = flat(1, 0.97, 0.78), brake = flat(0.94, 0.27, 0.27), flame = flat(1, 0.55, 0.1), glow = flat(0.2, 0.9, 1);
  const b = (size: V3, at: V3, m: THREE.Material, corner = 0.03, tilt = 0) => add(root, box(size[0], size[1], size[2], corner), m, at, tilt, X);
  const wheel = (r: number, w: number, at: V3) => add(root, tube(w, r), dark, at, Math.PI / 2, Z);
  const four = (r: number, w: number, x: number, z: number) => { for (const sx of [-1, 1]) for (const sz of [-1, 1]) wheel(r, w, [sx * x, r, sz * z]); };
  const lights = (x: number, y: number, front: number, back: number) => {
    for (const sx of [-1, 1]) { b([0.34, 0.16, 0.06], [sx * x, y, front], lamp, 0.02); b([0.34, 0.14, 0.06], [sx * x, y, back], brake, 0.02); }
  };
  switch (ride) {
    case 'car': b([1.9, 0.6, 3.6], [0, 0.5, 0], paint, 0.14); b([1.7, 0.5, 0.08], [0, 1.0, -0.6], glass, 0.03, 0.45); b([1.5, 0.45, 0.14], [0, 0.95, 0.55], dark); four(0.36, 0.32, 0.95, 1.15); lights(0.6, 0.62, -1.81, 1.81); break;
    case 'sports':
      b([1.9, 0.45, 4.0], [0, 0.42, 0], paint, 0.18); b([1.6, 0.35, 0.08], [0, 0.78, -0.5], glass, 0.03, 0.7); b([1.8, 0.07, 0.4], [0, 0.98, 1.8], paint);
      for (const sx of [-1, 1]) b([0.08, 0.3, 0.08], [sx * 0.7, 0.8, 1.8], dark);
      four(0.34, 0.34, 0.97, 1.3); lights(0.62, 0.5, -2.01, 2.01);
      break;
    case 'truck': b([2.2, 0.8, 4.4], [0, 0.75, 0], paint, 0.1); b([2.0, 0.6, 0.08], [0, 1.45, -0.75], glass, 0.03, 0.3); b([2.2, 0.55, 1.8], [0, 1.42, 1.25], dark, 0.05); four(0.5, 0.4, 1.05, 1.5); lights(0.72, 0.9, -2.21, 2.21); break;
    case 'kart': b([1.3, 0.3, 2.0], [0, 0.3, 0], paint, 0.1); b([1.5, 0.12, 0.2], [0, 0.25, -1.05], dark); b([0.8, 0.5, 0.14], [0, 0.6, 0.5], dark); b([0.5, 0.06, 0.06], [0, 0.72, -0.45], dark); four(0.25, 0.26, 0.72, 0.72); break;
    case 'bike': wheel(0.35, 0.08, [0, 0.35, -0.65]); wheel(0.35, 0.08, [0, 0.35, 0.65]); b([0.08, 0.08, 1.2], [0, 0.62, 0], paint); b([0.06, 0.55, 0.06], [0, 0.8, -0.6], paint); b([0.7, 0.06, 0.06], [0, 1.08, -0.6], dark); break;
    case 'scooter': b([0.42, 0.08, 1.1], [0, 0.2, 0], paint); wheel(0.15, 0.1, [0, 0.15, -0.5]); wheel(0.15, 0.1, [0, 0.15, 0.5]); b([0.07, 1.0, 0.07], [0, 0.72, -0.52], paint); b([0.6, 0.06, 0.06], [0, 1.2, -0.52], dark); break;
    case 'jetpack':
      b([0.5, 0.6, 0.25], [0, 1.0, 0.32], paint, 0.06);
      for (const sx of [-1, 1]) { add(root, tube(0.25, 0.09), dark, [sx * 0.14, 0.62, 0.35]); b([0.12, 0.28, 0.12], [sx * 0.14, 0.38, 0.35], flame, 0.05); }
      break;
    case 'hoverboard': b([0.8, 0.1, 1.6], [0, 0.12, 0], paint, 0.05); b([0.6, 0.02, 1.4], [0, 0.05, 0], glow, 0.01); break;
  }
  return merged(root);
}

// MARK: - Poses

const SHOULDER_X = 0.42, SHOULDER_Y = 1.25, HIP_X = 0.15, HIP_Y = 0.6, LIMB = 0.6, AIR_SPEED = 2.2;

interface Limbs {
  armSwing: [number, number]; legSwing: [number, number]; armSpread: [number, number]; legSpread: [number, number]; lean: number;
}
const settled = (): Limbs => ({ armSwing: [0, 0], legSwing: [0, 0], armSpread: [0, 0], legSpread: [0, 0], lean: 0 });

export const emoteSeconds = (e: Emote): number => {
  switch (e) {
    case 'wave': case 'clap': case 'point': case 'salute': case 'thumbs_up': case 'peace': return 2;
    case 'dance': case 'floss': case 'robot': case 'guitar': return 4;
    case 'cheer': case 'laugh': case 'spin': case 'hop': case 'victory': case 'stomp': return 2.5;
    case 'bow': return 1.8;
    case 'flip': return 1.2;
    case 'flex': case 'shrug': case 'think': case 'facepalm': case 'heart_hands': case 'dab': return 2.2;
    case 'yawn': case 'stretch': case 'cry': return 3;
    case 'sit': return 30;
  }
};

// MARK: - The avatar

export class AvatarModel {
  readonly root = new THREE.Group();
  readonly rig = new THREE.Group();
  private readonly body: THREE.Mesh;
  private readonly head: THREE.Mesh;
  private readonly leftArm: THREE.Mesh;
  private readonly rightArm: THREE.Mesh;
  private readonly leftLeg: THREE.Mesh;
  private readonly rightLeg: THREE.Mesh;
  private hat: THREE.Group | null = null;
  private spinning: THREE.Object3D | null = null;
  private faceGroup: THREE.Group | null = null;
  private pet: THREE.Group | null = null;
  private ride: THREE.Group | null = null;
  private aura: THREE.Group | null = null;
  private auraRing: THREE.Mesh[] = [];
  private auraOrbsList: THREE.Mesh[] = [];
  private auraMaterials: THREE.Material[] = [];
  private held: THREE.Object3D | null = null;
  heldModel: string | null = null;

  profile: AvatarProfile;
  private applied: Partial<Record<string, string>> = {};
  /** Where the network says this avatar is; it eases toward it. */
  target = new THREE.Vector3();
  targetYaw = 0;
  yaw = 0;

  private stride = 0;
  private seat = 0;
  private limbs = settled();
  private previousHeight: number | null = null;
  private verticalSpeed = 0;
  private airTime = 0;
  private breath = 0;
  private idleTime = 0;
  private petPhase = 0;
  private petTrick = 0;
  private auraTime = 0;
  private gesture: Emote | null = null;
  private gestureTime = 0;
  lastStep = 0;

  constructor(profile: AvatarProfile, position = new THREE.Vector3()) {
    this.profile = profile;
    this.root.name = 'ablox.avatar';
    const m = lit(profile.bodyColor);
    this.body = add(this.rig, box(0.6, 0.7, 0.34, 0.05), m, [0, 0.95, 0]);
    this.head = add(this.rig, box(0.45, 0.45, 0.45, 0.06), m, [0, 1.53, 0]);
    this.leftArm = add(this.rig, box(0.24, 0.6, 0.26, 0.05), m, [-SHOULDER_X, 0.95, 0]);
    this.rightArm = add(this.rig, box(0.24, 0.6, 0.26, 0.05), m, [SHOULDER_X, 0.95, 0]);
    this.leftLeg = add(this.rig, box(0.29, 0.6, 0.3, 0.05), m, [-HIP_X, 0.3, 0]);
    this.rightLeg = add(this.rig, box(0.29, 0.6, 0.3, 0.05), m, [HIP_X, 0.3, 0]);
    this.root.add(this.rig);
    this.root.position.copy(position);
    this.target.copy(position);
    this.apply(profile);
  }

  apply(profile: AvatarProfile): void {
    this.profile = profile;
    const accent = lit(profile.accentColor);
    const headM = lit(profile.headColor);
    this.body.material = lit(profile.bodyColor);
    this.head.material = headM;
    this.leftArm.material = headM;
    this.rightArm.material = headM;
    this.leftLeg.material = accent;
    this.rightLeg.material = accent;
    this.root.scale.setScalar(profile.height);

    const key = (...parts: unknown[]) => JSON.stringify(parts);
    const hatKey = key(profile.hat, profile.hatColor ?? profile.accentColor);
    if (this.applied.hat !== hatKey) {
      this.applied.hat = hatKey;
      this.hat?.removeFromParent();
      this.hat = buildHat(profile.hat, profile.hatColor ? lit(profile.hatColor) : accent);
      this.spinning = this.hat?.getObjectByName(SPIN) ?? null;
      if (this.hat) this.rig.add(this.hat);
    }
    const faceKey = key(profile.face, profile.face === 'cat' ? profile.headColor : null);
    if (this.applied.face !== faceKey) {
      this.applied.face = faceKey;
      this.faceGroup?.removeFromParent();
      this.faceGroup = buildFace(profile.face, headM);
      this.head.add(this.faceGroup);
    }
    const rideKey = key(profile.ride, profile.rideColor);
    if (this.applied.ride !== rideKey) {
      this.applied.ride = rideKey;
      this.ride?.removeFromParent();
      this.ride = buildRide(profile.ride, profile.rideColor);
      if (this.ride) this.root.add(this.ride);
      this.seat = seatHeights[profile.ride];
      this.rig.position.y = this.seat;
      const seated = seatedRides.includes(profile.ride);
      this.leftLeg.visible = !seated;
      this.rightLeg.visible = !seated;
    }
    const petKey = key(profile.pet, profile.petColor);
    if (this.applied.pet !== petKey) {
      this.applied.pet = petKey;
      this.pet?.removeFromParent();
      this.pet = buildPet(profile.pet, lit(profile.petColor));
      if (this.pet) { this.pet.position.copy(this.petHome); this.root.add(this.pet); }
    }
    if (this.applied.aura !== profile.aura) {
      this.applied.aura = profile.aura;
      this.buildAura();
    }
  }

  private get petHome(): THREE.Vector3 {
    return flyingPets.includes(this.profile.pet) ? new THREE.Vector3(0.55, 1.75, 0.25) : new THREE.Vector3(0.7, 0, 0.35);
  }

  private buildAura(): void {
    this.aura?.removeFromParent();
    this.aura = null;
    this.auraRing = [];
    this.auraOrbsList = [];
    const colours = auraColors[this.profile.aura];
    if (!colours.length) return;
    this.auraMaterials = colours.map((c) => {
      const m = new THREE.MeshBasicMaterial({ color: threeColor(c, new THREE.Color()), toneMapped: false });
      return m;
    });
    const root = new THREE.Group();
    for (let i = 0; i < 20; i++) {
      const a = (i / 20) * 2 * Math.PI;
      const piece = new THREE.Mesh(box(0.17, 0.02, 0.05), this.auraMaterials[0]);
      piece.position.set(Math.cos(a) * 0.58, 0.02, Math.sin(a) * 0.58);
      piece.quaternion.copy(turn(-a + Math.PI / 2, Y));
      root.add(piece);
      this.auraRing.push(piece);
    }
    for (let i = 0; i < auraOrbs[this.profile.aura]; i++) {
      const orb = new THREE.Mesh(ball(0.05), this.auraMaterials[i % this.auraMaterials.length]);
      root.add(orb);
      this.auraOrbsList.push(orb);
    }
    this.root.add(root);
    this.aura = root;
  }

  /** Puts a script's weapon in the right hand, or empties it. */
  hold(model: string | null, make: (model: string) => THREE.Object3D): void {
    if (model === this.heldModel) return;
    this.held?.removeFromParent();
    this.held = null;
    this.heldModel = model;
    if (!model) return;
    const weapon = make(model);
    weapon.position.set(0, -0.3, -0.1);
    this.rightArm.add(weapon);
    this.held = weapon;
  }

  get heldWeapon(): THREE.Object3D | null { return this.held; }

  /** Snaps there: a spawn or a teleport. */
  teleport(position: THREE.Vector3, yaw: number): void {
    if (position.distanceTo(this.root.position) > 3) this.previousHeight = null;
    this.target.copy(position);
    this.targetYaw = yaw;
    this.root.position.copy(position);
    this.setYaw(yaw);
  }

  private setYaw(yaw: number): void {
    this.yaw = yaw;
    // A bearing: 0 faces -Z, 90 faces +X — the rotation is the other way round.
    this.root.quaternion.copy(turn((-yaw * Math.PI) / 180, Y));
  }

  /** Eases toward the network's position and animates the walk. */
  update(dt: number, smoothing = 12): void {
    const blend = 1 - Math.exp(-smoothing * dt);
    const before = this.root.position.clone();
    this.root.position.lerp(this.target, blend);
    this.setYaw(normalizeDegrees(this.yaw + angularDelta(this.yaw, this.targetYaw) * blend));
    const travelled = Math.hypot(this.root.position.x - before.x, this.root.position.z - before.z);
    this.animate(travelled, dt);
  }

  play(emote: Emote): void {
    this.resetPose();
    this.gesture = emote;
    this.gestureTime = 0;
    this.petTrick = 0.9;
  }

  animate(travelled: number, dt: number): void {
    this.stride += travelled;
    this.lastStep = travelled;
    this.animateAura(dt);
    if (this.spinning) this.spinning.quaternion.premultiply(turn(dt * 9, Y));
    if (this.pet) {
      this.petPhase += dt * (travelled > 0.01 ? 12 : 3);
      const flies = flyingPets.includes(this.profile.pet);
      const bob = flies ? Math.sin(this.petPhase * 0.5) * 0.08 : Math.abs(Math.sin(this.petPhase)) * 0.06;
      const home = this.petHome;
      this.pet.position.set(home.x, home.y + bob + this.petTrickLift(dt), home.z);
    }
    const speed = travelled / Math.max(dt, 1e-4);
    this.trackHeight(dt);
    if (this.animateGesture(dt, speed)) return;
    this.poseBody(speed, dt);
    this.lookAbout(speed, dt);
  }

  private trackHeight(dt: number): void {
    const height = this.root.position.y;
    const previous = this.previousHeight;
    this.previousHeight = height;
    if (previous === null || dt <= 1e-4) return;
    const raw = (height - previous) / dt;
    if (Math.abs(raw) >= 40) { this.verticalSpeed = 0; this.airTime = 0; return; }
    this.verticalSpeed += (raw - this.verticalSpeed) * (1 - Math.exp(-14 * dt));
    this.airTime = Math.abs(this.verticalSpeed) > AIR_SPEED ? this.airTime + dt : 0;
  }

  private poseBody(speed: number, dt: number): void {
    this.breath = (this.breath + dt) % 600;
    const ride = this.profile.ride;
    let move: 'standing' | 'walking' | 'jumping' | 'falling' | 'riding' = 'standing';
    if (ride !== 'none' && ride !== 'jetpack') move = 'riding';
    else if (this.airTime > 0.12) move = this.verticalSpeed > 0 ? 'jumping' : 'falling';
    if (move === 'standing' && speed > 0.2) move = 'walking';
    const target = settled();
    switch (move) {
      case 'standing': {
        const b = Math.sin(this.breath * 2.1);
        target.armSwing = [0.03 * b, 0.03 * b];
        target.armSpread = [0.06 + 0.025 * b, 0.06 + 0.025 * b];
        break;
      }
      case 'walking': {
        const amplitude = Math.min(0.85, 0.1 * speed);
        const swing = Math.sin(this.stride * 3) * amplitude;
        target.legSwing = [swing, -swing];
        target.armSwing = [-swing * 0.9, swing * 0.9];
        target.armSpread = [0.05, 0.05];
        target.lean = speed > 6.5 ? Math.min(0.16, (speed - 6.5) * 0.05 + 0.06) : 0;
        break;
      }
      case 'jumping':
        target.armSwing = [2.75, 2.75]; target.armSpread = [0.18, 0.18]; target.legSwing = [0.45, -0.12];
        break;
      case 'falling': {
        const f = Math.sin(this.breath * 9) * 0.12;
        target.armSwing = [2.3 + f, 2.3 - f]; target.armSpread = [0.75, 0.75];
        target.legSwing = [0.25 - f, -0.2 + f]; target.legSpread = [0.14, 0.14];
        break;
      }
      case 'riding':
        switch (ride) {
          case 'car': case 'sports': case 'truck': case 'kart': {
            const steer = speed > 0.5 ? Math.sin(this.breath * 1.3) * 0.06 : 0;
            target.armSwing = [1.25 + steer, 1.25 - steer]; target.armSpread = [-0.18, -0.18];
            break;
          }
          case 'bike': {
            const pedal = speed > 0.3 ? Math.sin(this.stride * 2.2) * 0.45 : 0;
            target.armSwing = [1.05, 1.05]; target.armSpread = [0.08, 0.08]; target.legSwing = [0.75 + pedal, 0.75 - pedal]; target.lean = 0.12;
            break;
          }
          case 'scooter': target.armSwing = [1, 1]; target.armSpread = [0.1, 0.1]; target.legSwing = [0.1, -0.15]; break;
          case 'hoverboard': {
            const sway = Math.sin(this.breath * 1.8) * 0.12;
            target.armSwing = [0.25, 0.25]; target.armSpread = [0.95 + sway, 0.95 - sway]; target.legSpread = [0.12, 0.12];
            target.lean = speed > 4 ? 0.1 : 0;
            break;
          }
          default: break;
        }
        break;
    }
    const ease = 1 - Math.exp(-(move === 'walking' ? 26 : 12) * dt);
    const l = this.limbs;
    for (let i = 0; i < 2; i++) {
      l.armSwing[i] += (target.armSwing[i] - l.armSwing[i]) * ease;
      l.legSwing[i] += (target.legSwing[i] - l.legSwing[i]) * ease;
      l.armSpread[i] += (target.armSpread[i] - l.armSpread[i]) * ease;
      l.legSpread[i] += (target.legSpread[i] - l.legSpread[i]) * ease;
    }
    l.lean += (target.lean - l.lean) * ease;
    this.applyLimbs();
  }

  private applyLimbs(): void {
    const half = new THREE.Vector3(0, -LIMB / 2, 0);
    const place = (limb: THREE.Mesh, side: number, swing: number, spread: number, x: number, y: number) => {
      const q = turn(spread * side, Z).multiply(turn(swing, X));
      limb.quaternion.copy(q);
      limb.position.set(side * x, y, 0).add(half.clone().applyQuaternion(q));
    };
    place(this.leftArm, -1, this.limbs.armSwing[0], this.limbs.armSpread[0], SHOULDER_X, SHOULDER_Y);
    place(this.rightArm, 1, this.limbs.armSwing[1], this.limbs.armSpread[1], SHOULDER_X, SHOULDER_Y);
    place(this.leftLeg, -1, this.limbs.legSwing[0], this.limbs.legSpread[0], HIP_X, HIP_Y);
    place(this.rightLeg, 1, this.limbs.legSwing[1], this.limbs.legSpread[1], HIP_X, HIP_Y);
    this.rig.quaternion.copy(turn(-this.limbs.lean, X));
    this.head.quaternion.copy(turn(this.limbs.lean, X));
  }

  private lookAbout(speed: number, dt: number): void {
    if (speed > 0.2) {
      if (this.idleTime > 5) this.head.quaternion.identity();
      this.idleTime = 0;
      return;
    }
    this.idleTime += dt;
    if (this.idleTime <= 5) return;
    this.head.quaternion.copy(turn(Math.sin((this.idleTime - 5) * 0.7) * 0.4, Y));
  }

  private petTrickLift(dt: number): number {
    if (this.petTrick <= 0 || !this.pet) return 0;
    this.petTrick = Math.max(0, this.petTrick - dt);
    const progress = 1 - this.petTrick / 0.9;
    this.pet.quaternion.copy(turn(progress * 2 * Math.PI, Y));
    if (this.petTrick === 0) this.pet.quaternion.identity();
    return Math.sin(progress * Math.PI) * 0.3;
  }

  private animateAura(dt: number): void {
    if (!this.aura) return;
    this.auraTime += dt;
    this.aura.quaternion.copy(turn(this.auraTime * 0.8, Y));
    this.auraOrbsList.forEach((orb, i) => {
      const a = this.auraTime * 2 + (i / Math.max(1, this.auraOrbsList.length)) * 2 * Math.PI;
      orb.position.set(Math.cos(a) * 0.55, 0.4 + Math.sin(this.auraTime * 3 + i) * 0.3, Math.sin(a) * 0.55);
    });
    if (this.auraMaterials.length > 1) {
      const index = Math.floor(this.auraTime * 3) % this.auraMaterials.length;
      for (const piece of this.auraRing) piece.material = this.auraMaterials[index];
    }
  }

  // MARK: Emotes

  private resetPose(): void {
    this.rig.position.set(0, this.seat, 0);
    this.rig.quaternion.identity();
    this.head.quaternion.identity();
    this.leftArm.position.set(-SHOULDER_X, 0.95, 0); this.leftArm.quaternion.identity();
    this.rightArm.position.set(SHOULDER_X, 0.95, 0); this.rightArm.quaternion.identity();
    this.leftLeg.position.set(-HIP_X, 0.3, 0); this.leftLeg.quaternion.identity();
    this.rightLeg.position.set(HIP_X, 0.3, 0); this.rightLeg.quaternion.identity();
    this.limbs = settled();
  }

  private animateGesture(dt: number, speed: number): boolean {
    const emote = this.gesture;
    if (!emote) return false;
    this.gestureTime += dt;
    if (this.gestureTime > emoteSeconds(emote) || (speed > 1.2 && this.gestureTime > 0.3)) {
      this.gesture = null;
      this.resetPose();
      return false;
    }
    this.pose(emote, this.gestureTime);
    return true;
  }

  private raise(arm: THREE.Mesh, side: number, swing = 0): void {
    arm.position.set(side * (0.42 + Math.abs(swing) * 0.1), 1.5, 0);
    arm.quaternion.copy(turn(side * swing, Z));
  }
  private lower(arm: THREE.Mesh, side: number): void { arm.position.set(side * SHOULDER_X, 0.95, 0); }
  private outwards(arm: THREE.Mesh, side: number, lift = 0): void { arm.position.set(side * 0.62, 1.2 + lift, 0); arm.quaternion.copy(turn((side * Math.PI) / 2, Z)); }
  private reach(arm: THREE.Mesh, at: V3, angle: number): void { arm.position.set(...at); arm.quaternion.copy(turn(angle, X)); }

  private pose(emote: Emote, t: number): void {
    const L = this.leftArm, R = this.rightArm, rig = this.rig, head = this.head, s = this.seat;
    switch (emote) {
      case 'wave': this.raise(R, 1, 0.35 * Math.sin(t * 12)); this.lower(L, -1); break;
      case 'dance': {
        const beat = Math.sin(t * 9);
        rig.position.set(0, s + Math.abs(beat) * 0.12, 0);
        rig.quaternion.copy(turn(Math.sin(t * 4.5) * 0.35, Y));
        if (beat > 0) { this.raise(R, 1, 0.4); this.lower(L, -1); } else { this.raise(L, -1, 0.4); this.lower(R, 1); }
        this.leftLeg.quaternion.copy(turn(beat * 0.35, X));
        this.rightLeg.quaternion.copy(turn(-beat * 0.35, X));
        break;
      }
      case 'clap': {
        const open = (Math.sin(t * 16) + 1) * 0.18;
        L.position.set(-0.25 - open, 1.05, -0.28); R.position.set(0.25 + open, 1.05, -0.28);
        L.quaternion.copy(turn(-1.35, X)); R.quaternion.copy(turn(-1.35, X));
        break;
      }
      case 'cheer': this.raise(L, -1, 0.35); this.raise(R, 1, 0.35); rig.position.set(0, s + Math.abs(Math.sin(t * 7)) * 0.3, 0); break;
      case 'bow': rig.quaternion.copy(turn(-Math.sin(Math.min(1, t / 1.8) * Math.PI) * 0.7, X)); break;
      case 'point': R.position.set(SHOULDER_X, 1.2, -0.3); R.quaternion.copy(turn(-1.5, X)); break;
      case 'laugh': head.quaternion.copy(turn(0.3 + Math.sin(t * 20) * 0.08, X)); rig.position.set(0, s + Math.abs(Math.sin(t * 18)) * 0.04, 0); break;
      case 'sit':
        rig.position.set(0, s - 0.32, 0);
        this.leftLeg.position.set(-HIP_X, 0.55, -0.25); this.leftLeg.quaternion.copy(turn(-1.45, X));
        this.rightLeg.position.set(HIP_X, 0.55, -0.25); this.rightLeg.quaternion.copy(turn(-1.45, X));
        break;
      case 'hop': rig.position.set(0, s + Math.abs(Math.sin(t * 6)) * 0.45, 0); this.raise(L, -1, 0.5); this.raise(R, 1, 0.5); break;
      case 'spin': rig.quaternion.copy(turn(t * 8, Y)); this.outwards(L, -1); this.outwards(R, 1); break;
      case 'flex': {
        const p = Math.sin(t * 8) * 0.05;
        this.raise(L, -1, 1.1 + p); this.raise(R, 1, 1.1 + p); rig.position.set(0, s + Math.abs(p), 0);
        break;
      }
      case 'shrug': {
        const up = Math.min(1, t * 4) * 0.1;
        L.position.set(-0.45, 0.95 + up, -0.05); L.quaternion.copy(turn(-0.45, Z));
        R.position.set(0.45, 0.95 + up, -0.05); R.quaternion.copy(turn(0.45, Z));
        head.quaternion.copy(turn(0.2, Z));
        break;
      }
      case 'think': this.reach(R, [0.22, 1.24, -0.2], -2.2); head.quaternion.copy(turn(0.15 + Math.sin(t * 2) * 0.05, Z)); break;
      case 'facepalm': this.reach(R, [0.12, 1.34, -0.24], -2.6); head.quaternion.copy(turn(0.3 + Math.sin(t * 3) * 0.04, X)); break;
      case 'salute': this.reach(R, [0.3, 1.46, -0.1], -2.4); break;
      case 'thumbs_up': this.reach(R, [SHOULDER_X, 1.15, -0.3], -1.4); rig.position.set(0, s + Math.abs(Math.sin(t * 5)) * 0.05, 0); break;
      case 'heart_hands':
        L.position.set(-0.22, 1.5, -0.2); R.position.set(0.22, 1.5, -0.2);
        L.quaternion.copy(turn(-0.7, Z)); R.quaternion.copy(turn(0.7, Z));
        rig.quaternion.copy(turn(Math.sin(t * 3) * 0.1, Z));
        break;
      case 'yawn': {
        const open = Math.sin(Math.min(1, t / 3) * Math.PI);
        this.raise(L, -1, 0.3 * open); this.raise(R, 1, 0.3 * open); head.quaternion.copy(turn(-0.35 * open, X));
        break;
      }
      case 'stretch': this.raise(L, -1, 0.1); this.raise(R, 1, 0.1); rig.quaternion.copy(turn(Math.sin(t * 2.2) * 0.25, Z)); break;
      case 'dab': this.raise(R, 1, 0.9); this.reach(L, [-0.05, 1.42, -0.26], -1.9); head.quaternion.copy(turn(0.4, X)); break;
      case 'floss': {
        const swing = Math.sin(t * 10);
        for (const [arm, side] of [[L, -1], [R, 1]] as [THREE.Mesh, number][]) {
          arm.position.set(side * SHOULDER_X + swing * 0.18, 0.9, swing * side * 0.15);
          arm.quaternion.copy(turn(swing * 0.4, Z));
        }
        rig.quaternion.copy(turn(-swing * 0.15, Y));
        break;
      }
      case 'robot': {
        const step = Math.sin(t * 5) > 0 ? 1 : -1;
        this.reach(L, [-SHOULDER_X, 1.15, -0.3], step > 0 ? -1.5 : 0);
        this.reach(R, [SHOULDER_X, 1.15, -0.3], step > 0 ? 0 : -1.5);
        if (step < 0) this.lower(L, -1); else this.lower(R, 1);
        head.quaternion.copy(turn(step * 0.4, Y));
        break;
      }
      case 'flip': {
        const p = Math.min(1, t / 1.2);
        rig.position.set(0, s + Math.sin(p * Math.PI) * 0.9 + 0.5 * Math.sin(p * Math.PI), 0);
        rig.quaternion.copy(turn(-p * 2 * Math.PI, X));
        break;
      }
      case 'cry':
        this.reach(L, [-0.12, 1.3, -0.24], -2.5); this.reach(R, [0.12, 1.3, -0.24], -2.5);
        head.quaternion.copy(turn(0.35, X)); rig.position.set(Math.sin(t * 30) * 0.015, s, 0);
        break;
      case 'stomp': {
        const beat = Math.sin(t * 9);
        this.leftLeg.position.set(-HIP_X, 0.3 + Math.max(0, beat) * 0.2, 0);
        this.rightLeg.position.set(HIP_X, 0.3 + Math.max(0, -beat) * 0.2, 0);
        this.lower(L, -1); this.lower(R, 1);
        L.quaternion.copy(turn(-0.3, Z)); R.quaternion.copy(turn(0.3, Z));
        break;
      }
      case 'victory': this.raise(R, 1, 0); this.lower(L, -1); rig.position.set(0, s + Math.abs(Math.sin(t * 6)) * 0.3, 0); rig.quaternion.copy(turn(t * 2.5, Y)); break;
      case 'guitar':
        this.reach(L, [-0.45, 1.1, -0.3], -1.2);
        this.reach(R, [0.12, 0.95, -0.25], -1.0 + Math.sin(t * 18) * 0.25);
        head.quaternion.copy(turn(Math.abs(Math.sin(t * 9)) * 0.3, X));
        break;
      case 'peace': this.reach(R, [0.3, 1.5, -0.18], -2.8); head.quaternion.copy(turn(-0.18, Z)); rig.position.set(0, s + Math.abs(Math.sin(t * 4)) * 0.04, 0); break;
    }
  }

  /** Top of the head in the world, for the name and the bubble. */
  headTop(target = new THREE.Vector3()): THREE.Vector3 {
    return target.copy(this.root.position).add(new THREE.Vector3(0, 2.15 * this.profile.height, 0));
  }

  dispose(): void {
    this.root.removeFromParent();
  }
}
