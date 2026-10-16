// Weapons built from boxes, like avatars (Engine/WeaponModel.swift). Every
// model points down -Z with its grip at the origin, so the same one sits in
// an avatar's hand or at the bottom corner of a first-person view.
import * as THREE from 'three';
import { RoundedBoxGeometry } from 'three/examples/jsm/geometries/RoundedBoxGeometry.js';

const metal = new THREE.MeshStandardMaterial({ color: new THREE.Color().setScalar(0.16).convertSRGBToLinear(), roughness: 0.35, metalness: 1 });
const body = new THREE.MeshStandardMaterial({ color: new THREE.Color().setScalar(0.32).convertSRGBToLinear(), roughness: 0.6 });
const accent = new THREE.MeshStandardMaterial({ color: new THREE.Color(0.13, 0.83, 0.93).convertSRGBToLinear(), roughness: 0.3, emissive: new THREE.Color(0.02, 0.12, 0.14) });

type Part = [size: [number, number, number], at: [number, number, number], material: THREE.Material];

const models: Record<string, Part[]> = {
  rifle: [
    [[0.07, 0.09, 0.62], [0, 0.02, -0.16], body],
    [[0.035, 0.035, 0.34], [0, 0.035, -0.62], metal],
    [[0.05, 0.05, 0.16], [0, 0.1, -0.14], accent],
    [[0.05, 0.13, 0.06], [0, -0.07, 0], metal],
  ],
  shotgun: [
    [[0.08, 0.09, 0.5], [0, 0.02, -0.12], body],
    [[0.07, 0.05, 0.36], [0, 0.05, -0.5], metal],
    [[0.075, 0.05, 0.14], [0, -0.02, -0.4], accent],
    [[0.05, 0.13, 0.06], [0, -0.07, 0], metal],
  ],
  pistol: [
    [[0.05, 0.075, 0.22], [0, 0.04, -0.06], metal],
    [[0.045, 0.12, 0.06], [0, -0.04, 0], body],
    [[0.052, 0.02, 0.06], [0, 0.085, -0.02], accent],
  ],
  blaster: [
    [[0.08, 0.1, 0.32], [0, 0.03, -0.1], body],
    [[0.045, 0.045, 0.2], [0, 0.04, -0.34], accent],
    [[0.05, 0.13, 0.06], [0, -0.07, 0], metal],
  ],
};

const muzzles: Record<string, [number, number, number]> = {
  rifle: [0, 0.035, -0.8], shotgun: [0, 0.05, -0.68], pistol: [0, 0.04, -0.18], blaster: [0, 0.04, -0.45],
};

const geometries = new Map<string, THREE.BufferGeometry>();

function box(size: [number, number, number]): THREE.BufferGeometry {
  const key = size.join(',');
  let g = geometries.get(key);
  if (!g) {
    const radius = Math.min(...size) * 0.2;
    g = new RoundedBoxGeometry(size[0], size[1], size[2], 2, radius);
    geometries.set(key, g);
  }
  return g;
}

/** The weapon for a WeaponSpec model name; unknown names get a blaster, as the host does. */
export function makeWeapon(model: string): THREE.Group {
  const root = new THREE.Group();
  root.name = 'ablox.weapon.' + model;
  for (const [size, at, material] of models[model] ?? models.blaster) {
    const mesh = new THREE.Mesh(box(size), material);
    mesh.position.set(at[0], at[1], at[2]);
    mesh.castShadow = true;
    root.add(mesh);
  }
  return root;
}

/** Where shots leave the weapon, in its own space. */
export function weaponMuzzle(model: string): THREE.Vector3 {
  const m = muzzles[model] ?? muzzles.blaster;
  return new THREE.Vector3(m[0], m[1], m[2]);
}
