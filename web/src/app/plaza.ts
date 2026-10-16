// The Plaza: a little world to walk around between games. A fountain in
// the middle, trees and lamps round the edge, and a ring of doors, each
// with a game's cover on it — today's pick, what you played last, the most
// popular — and two doors of the menu's own: your closet and every game.
// Walking into a door opens what is behind it.
import { colorFromHex, type ColorRGBA } from '../core/model/color';
import { quatEulerDegrees, v3 } from '../core/model/math';
import { dailyPick } from '../core/model/progress';
import { defaultEnvironment, emptyWorld, makeBlock, placed, type BlockData, type WorldDocument } from '../core/model/world';
import { L } from '../i18n';
import { coverURL, type GameListing } from '../net/catalogue';

const hex = (h: string) => colorFromHex(h)!;
const white = hex('#FFFFFF');

/** Where a door goes: a game's page, or a tab of the menu. */
export type PlazaDoor = { kind: 'game'; id: string } | { kind: 'tab'; hash: string };

export interface Plaza { world: WorldDocument; doors: Map<string, PlazaDoor> }

/** A fixed id, so the Plaza's saves and leaderboards (it has none) never mix with a game's. */
export const plazaWorldID = 'AB10C000-0000-4000-8000-0000000F1A2A';

const doorColours = ['#22D3EE', '#F472B6', '#FFC93C', '#4ADE80', '#A855F7', '#FF9F1C', '#38BDF8', '#FB7185', '#A3E635', '#F59E0B'];

async function base64Cover(url: string): Promise<string | null> {
  try {
    const response = await fetch(url);
    if (!response.ok) return null;
    const bytes = new Uint8Array(await response.arrayBuffer());
    if (bytes.length > 3 * 1024 * 1024) return null;
    let text = '';
    for (let i = 0; i < bytes.length; i += 0x8000) text += String.fromCharCode(...bytes.subarray(i, i + 0x8000));
    return btoa(text);
  } catch {
    return null;
  }
}

/** The games behind the doors: today's pick, the last few played, then the most popular. */
export function plazaGames(games: GameListing[], recent: string[], count = 8): GameListing[] {
  const out: GameListing[] = [];
  const add = (g: GameListing | undefined | null) => { if (g && !out.some((x) => x.id === g.id) && out.length < count) out.push(g); };
  add(dailyPick(games));
  for (const id of recent.slice(0, 3)) add(games.find((g) => g.id === id));
  for (const g of games.filter((x) => x.tags.includes('top20'))) add(g);
  for (const g of games) add(g);
  return out;
}

export async function buildPlaza(games: GameListing[], recent: string[], playerName: string): Promise<Plaza> {
  const world = emptyWorld(L('Ablox Plaza'), 'Ablox');
  world.id = plazaWorldID;
  const env = defaultEnvironment();
  env.skyTop = hex('#3B8EEA');
  env.skyBottom = hex('#BFE3FF');
  env.skyStyle = 'clouds';
  env.sunPitchDegrees = -52;
  env.sunYawDegrees = 40;
  env.ambientIntensity = 0.62;
  env.groundColor = hex('#4CAF50');
  env.music = 'calm';
  world.environment = env;
  const blocks: BlockData[] = [];
  const add = (b: Partial<BlockData>) => { const block = makeBlock(b); blocks.push(block); return block; };
  const yaw = (degrees: number) => quatEulerDegrees(v3(0, degrees, 0));

  // The ground and the plaza.
  add({ name: 'Meadow', shape: 'cylinder', transform: placed(v3(0, -0.6, 0), v3(130, 1, 130)), color: hex('#5DBB63'), material: 'grass', tags: ['ground'] });
  add({ name: 'Plaza', shape: 'cylinder', transform: placed(v3(0, -0.05, 0), v3(48, 0.2, 48)), color: hex('#E8E1D5'), material: 'stone' });
  add({ name: 'Inner ring', shape: 'cylinder', transform: placed(v3(0, 0.02, 0), v3(20, 0.08, 20)), color: hex('#C9BFAE'), material: 'stone' });
  add({ name: 'Spawn', shape: 'cylinder', transform: placed(v3(0, 0.08, 13), v3(2.6, 0.12, 2.6)), color: hex('#22D3EE'), material: 'neon', behavior: 'spawn' });

  // The fountain.
  add({ name: 'Fountain basin', shape: 'cylinder', transform: placed(v3(0, 0.45, 0), v3(7.5, 0.9, 7.5)), color: hex('#B8C4D6'), material: 'stone' });
  add({ name: 'Fountain water', shape: 'cylinder', transform: placed(v3(0, 0.85, 0), v3(6.6, 0.15, 6.6)), color: { ...hex('#4FC3F7'), a: 0.8 }, material: 'water', hasCollision: false });
  add({ name: 'Fountain column', shape: 'cylinder', transform: placed(v3(0, 2, 0), v3(1, 3, 1)), color: hex('#DDE6F2'), material: 'stone' });
  const top = add({ name: 'Ablox cube', transform: placed(v3(0, 4.6, 0), v3(1.8, 1.8, 1.8)), color: hex('#22D3EE'), material: 'neon',
    animation: { kind: 'spin', speed: 0.6 }, light: { kind: 'point', color: hex('#7DE9FF'), intensity: 1.4, range: 12 },
    particles: 'sparkles' });
  top.label = { lines: [{ text: L('Ablox Plaza'), color: white }, { text: L('Welcome, {}!', playerName), color: hex('#FFE27A') }], height: 1.1, size: 1.25, range: 60 };

  // Doors round the plaza, all facing the fountain, with the side the player starts on left open.
  const picked = plazaGames(games, recent);
  const doors = new Map<string, PlazaDoor>();
  const specials: { title: string; colour: string; door: PlazaDoor }[] = [
    { title: L('My closet'), colour: '#F472B6', door: { kind: 'tab', hash: 'me' } },
    { title: L('All games'), colour: '#4ADE80', door: { kind: 'tab', hash: 'games' } },
  ];
  const entries = [
    ...picked.map((g, i) => ({ title: g.title, colour: doorColours[i % doorColours.length], door: { kind: 'game', id: g.id } as PlazaDoor, cover: coverURL(g) })),
    ...specials.map((s) => ({ ...s, cover: null as string | null })),
  ];
  const covers = await Promise.all(entries.map((e) => (e.cover ? base64Cover(e.cover) : Promise.resolve(null))));
  const radius = 17;
  const span = 290;
  entries.forEach((e, i) => {
    // 0° is straight ahead from the start (−Z); doors run from the left round to the right.
    const angle = -span / 2 + (span * i) / Math.max(1, entries.length - 1);
    const r = (angle * Math.PI) / 180;
    const x = Math.sin(r) * radius, z = -Math.cos(r) * radius;
    const facing = yaw(-angle);
    const colour = hex(e.colour);
    const local = (dx: number, dy: number, dz = 0) => v3(x + Math.cos(r) * dx - Math.sin(r) * dz, dy, z + Math.sin(r) * dx + Math.cos(r) * dz);
    const id = (s: string) => `${s}-${i}`;
    add({ name: id('Door step'), shape: 'cylinder', transform: placed(local(0, 0.08, 1.4), v3(3.6, 0.12, 3.6)), color: colour, material: 'neon' });
    for (const side of [-1, 1]) {
      add({ name: id('Door post'), transform: placed(local(side * 2.6, 2.7), v3(0.7, 5.4, 0.7), facing), color: hex('#F8FAFC'), material: 'plastic' });
    }
    add({ name: id('Door top'), transform: placed(local(0, 5.7), v3(6, 0.8, 0.9), facing), color: colour, material: 'plastic',
      light: { kind: 'point', color: colour, intensity: 1.2, range: 9 } });
    const screen = add({
      name: id('Door'), transform: placed(local(0, 2.6, -0.05), v3(4.5, 5, 0.2), facing), color: { ...colour, a: covers[i] ? 1 : 0.65 },
      material: covers[i] ? 'plastic' : 'glass', behavior: 'trigger', tags: ['door'],
    });
    if (covers[i]) {
      const imageID = `cover-${i}`;
      world.images.push({ id: imageID, name: e.title, data: covers[i]! });
      screen.imageID = imageID;
    }
    screen.label = { lines: [{ text: e.title, color: white }], height: 1.5, size: 1.3, range: 45 };
    doors.set(screen.id, e.door);
  });

  // Trees and lamps round the edge.
  for (let i = 0; i < 14; i++) {
    const a = (i / 14) * Math.PI * 2 + 0.2;
    const r = 30 + (i % 3) * 3;
    const x = Math.sin(a) * r, z = Math.cos(a) * r;
    add({ name: 'Tree trunk', shape: 'cylinder', transform: placed(v3(x, 1.4, z), v3(0.8, 2.8, 0.8)), color: hex('#8D5A3B'), material: 'wood' });
    add({ name: 'Tree top', shape: 'sphere', transform: placed(v3(x, 3.8, z), v3(3.6, 3.4, 3.6)), color: i % 4 === 0 ? hex('#F9A8D4') : hex('#3FAE4C'), material: 'grass' });
  }
  for (let i = 0; i < 8; i++) {
    const a = (i / 8) * Math.PI * 2 + Math.PI / 8;
    const x = Math.sin(a) * 23, z = Math.cos(a) * 23;
    add({ name: 'Lamp post', shape: 'cylinder', transform: placed(v3(x, 1.8, z), v3(0.25, 3.6, 0.25)), color: hex('#334155'), material: 'metal' });
    add({ name: 'Lamp', shape: 'sphere', transform: placed(v3(x, 3.8, z), v3(0.7, 0.7, 0.7)), color: hex('#FFF3C4'), material: 'neon',
      light: { kind: 'point', color: hex('#FFE7A0'), intensity: 0.9, range: 8 } });
  }
  // Benches by the fountain, and some floating blocks for fun.
  for (const a of [60, 120, 240, 300]) {
    const r = (a * Math.PI) / 180;
    add({ name: 'Bench', transform: placed(v3(Math.sin(r) * 7.2, 0.45, Math.cos(r) * 7.2), v3(2.6, 0.3, 0.9), yaw(a)), color: hex('#B7794B'), material: 'wood' });
  }
  const floaters: [number, number, number, string][] = [[-9, 6, -6, '#F472B6'], [10, 7, -4, '#FFC93C'], [-6, 8, 8, '#A855F7'], [8, 6.5, 7, '#4ADE80']];
  for (const [x, y, z, c] of floaters) {
    add({ name: 'Floating block', transform: placed(v3(x, y, z), v3(1.2, 1.2, 1.2)), color: hex(c), material: 'neon', hasCollision: false,
      animation: { kind: 'bounce', speed: 0.8 } });
  }

  world.blocks = blocks;
  const hello = L('Walk into a door to visit a game.').replace(/["\\]/g, '');
  world.scripts = [{ id: 'AB10C000-0000-4000-8000-00000000A11A', name: 'main.absc', isEnabled: true, source: `on join(p)\n  p.message("${hello}", 5)\nend\n` }];
  return { world, doors };
}

/** For tests and the cover-less: a colour for each door. */
export const doorColour = (i: number): ColorRGBA => hex(doorColours[i % doorColours.length]);
