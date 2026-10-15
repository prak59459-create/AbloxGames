// ScriptWorldTests.swift, on the web: NPCs, building the map, the world's
// settings, raycasts, many .absc files, and folding effects into a screen.
import { describe, expect, it } from 'vitest';
import { alice, announcements, bob, containsEqual, game, place, reaching, scripted, script, snapshot, startWithBoth } from './runtimeHelpers';
import { GameRuntime } from '../src/core/runtime/gameRuntime';
import { LiveWorld, decodeDelta, encodeDelta } from '../src/core/model/liveWorld';
import { colorFromHex, parseScriptColor } from '../src/core/model/color';
import { weaponPresets } from '../src/core/model/combat';
import { placeUI, uiElement, uiPresets, type ScriptEffect } from '../src/core/model/effects';
import { ScriptedPlayerState } from '../src/core/model/scriptedState';
import { decodeProfile, encodeProfile } from '../src/core/model/avatar';
import { v3 } from '../src/core/model/math';
import { cleanScriptName, emptyWorld, isSolidForPlayers, makeBlock, needsTouchDetection, placed, type WorldDocument } from '../src/core/model/world';
import { WorldIndex } from '../src/core/physics/worldIndex';
import { resolve, defaultBody } from '../src/core/physics/collider';

function floorWorld(): WorldDocument {
  const world = emptyWorld('Arena');
  world.blocks.push(makeBlock({ name: 'Floor', transform: placed(v3(0, -0.5, 0), v3(100, 1, 100)), tags: ['ground'] }));
  return world;
}

describe('names the API took later', () => {
  it('a world keeps its own data under them', () => {
    const g = game('on join(p)\n  p.items = {}\n  p.items["ball"] = 5\n  p.vehicle = "bike"\n  p.shop = ["apple"]\n  print(p.items["ball"])\n  print(p.vehicle)\n  print(len(p.shop))\n  p.give_item("coin", 2)\n  print(p.has_item("coin"))\nend');
    startWithBoth(g);
    expect(g.drainErrors()).toEqual([]);
    expect(g.drainOutput()).toEqual(['5', 'bike', '1', 'true', '5', 'bike', '1', 'true']);
  });

  it('other built-in names still cannot be replaced', () => {
    const g = game('on join(p)\n  p.teleport = 3\nend');
    startWithBoth(g);
    expect(g.drainErrors().length).toBeGreaterThan(0);
  });
});

describe('touchable blocks', () => {
  it('a script-made block is touchable only with a behaviour', () => {
    const g = game('on start()\n  create_block({name: "Coin", position: {x: 0, y: 1, z: 0}, behavior: "trigger"})\n  create_block({name: "Rock", position: {x: 5, y: 1, z: 0}})\nend\non touch(p, b)\n  announce(p.name + " touched " + b.name + " (" + b.behavior + ")")\nend', floorWorld());
    startWithBoth(g);
    const coin = g.world.blocks.find((b) => b.name === 'Coin')!;
    const rock = g.world.blocks.find((b) => b.name === 'Rock')!;
    expect(coin.behavior).toBe('trigger');
    expect(needsTouchDetection(coin.behavior)).toBe(true);
    expect(needsTouchDetection(rock.behavior)).toBe(false);
    const touching = resolve(v3(0, 0.5, 0), v3(), defaultBody(), new WorldIndex(g.world), 0.1);
    expect(touching.touched).toContain(coin.id);
    expect(announcements(alice, g.handle({ kind: 'touched', peer: alice, blockID: coin.id }))).toContain('Alice touched Coin (trigger)');
  });

  it('a bad behaviour names the choices', () => {
    const g = game('on start()\n  create_block({name: "X", behavior: "lava"})\nend');
    startWithBoth(g);
    expect(g.drainErrors()[0]?.message).toContain('trigger');
  });
});

describe('NPCs', () => {
  it('walk to where they are sent, on the floor', () => {
    const g = game('let guard = nil\non start()\n  guard = create_npc({name: "Guard", position: {x: 0, y: 1, z: 0}, color: "red"})\n  guard.move_to({x: 10, y: 0, z: 0})\nend', floorWorld());
    startWithBoth(g);
    expect(g.takeRosterChange()).toBe(true);
    const npc = g.roster.find((p) => p.isNPC);
    expect(npc?.profile.displayName).toBe('Guard');
    expect(npc?.profile.bodyColor).toEqual(parseScriptColor('red'));
    for (let step = 1; step <= 60; step++) g.advance(step * 0.1);
    const moved = g.roster.find((p) => p.isNPC)!;
    expect(Math.abs(moved.position.x - 10)).toBeLessThan(0.5);
    expect(Math.abs(moved.position.y)).toBeLessThan(0.1);
    expect(g.drainNPCTransforms().length).toBeGreaterThan(0);
  });

  it('can be shot, and a knocked-out one is removed', () => {
    const g = game('on start()\n  let z = create_npc({name: "Zombie", position: {x: 0, y: 0, z: 0}, health: 30})\nend\non join(p)\n  p.give("rifle")\nend\non death(victim, killer)\n  if victim.is_npc then announce(killer.name + " got the " + victim.name) end\nend', floorWorld());
    startWithBoth(g);
    g.advance(0.1);
    place(g, alice, v3(0, 0, -10));
    const effects = g.handleInput({ kind: 'fire', origin: v3(0, 1.6, -10), direction: v3(0, 0, 1) }, alice, 1);
    expect(containsEqual(scripted(alice, effects), { kind: 'hitMarker', killed: true } as ScriptEffect)).toBe(true);
    expect(announcements(alice, effects)).toContain('Alice got the Zombie');
    expect(g.roster.every((p) => !p.isNPC)).toBe(true);
  });

  it('can hurt players', () => {
    const g = game('let z = nil\non start()\n  z = create_npc({name: "Zombie"})\nend\non tick(dt)\n  for p in players() do p.damage(10, z) end\nend\non death(victim, killer)\n  announce(victim.name + " was got by " + killer.name)\nend');
    startWithBoth(g);
    const heard: string[] = [];
    for (let step = 1; step <= 12; step++) heard.push(...announcements(alice, g.advance(step * 0.1)));
    expect(heard).toContain('Alice was got by Zombie');
  });

  it('a ride is part of how a character looks; an unknown one names the choices', () => {
    const g = game('on join(p)\n  p.ride = "sports"\n  p.ride_color = "#FACC15"\n  print(p.ride, p.ride_color)\nend\non start()\n  let n = create_npc({name: "Cabbie", ride: "car", ride_color: "yellow"})\n  print(n.ride)\nend');
    startWithBoth(g);
    const a = g.roster.find((p) => p.peerID === alice)!;
    expect(a.profile.ride).toBe('sports');
    expect(a.profile.rideColor).toEqual(colorFromHex('#FACC15'));
    expect(g.roster.find((p) => p.isNPC)?.profile.ride).toBe('car');
    expect(g.drainOutput()).toContain('sports #FACC15');
    const h = game('on join(p)\n  p.ride = "rocket"\nend');
    startWithBoth(h);
    expect(h.drainErrors()[0]?.message).toContain('hoverboard');
  });

  it('a profile saved before rides still loads', () => {
    const old = JSON.parse('{"displayName":"Aoi","bodyColor":{"r":1,"g":0,"b":0,"a":1},"headColor":{"r":1,"g":1,"b":0,"a":1},"accentColor":{"r":0,"g":0,"b":1,"a":1},"hat":"cap","height":1}');
    const profile = decodeProfile(old);
    expect(profile.displayName).toBe('Aoi');
    expect(profile.hat).toBe('cap');
    expect(profile.ride).toBe('none');
    expect(decodeProfile(JSON.parse(JSON.stringify(encodeProfile(profile))))).toEqual(profile);
  });

  it('speaks in a bubble everyone sees', () => {
    const g = game('on start()\n  let n = create_npc({name: "Nurse"})\n  n.say("Next, please!")\nend');
    const effects = startWithBoth(g);
    const npc = g.roster.find((p) => p.isNPC)!;
    const line = { kind: 'say', speaker: npc.peerID, name: 'Nurse', text: 'Next, please!' } as ScriptEffect;
    expect(containsEqual(scripted(alice, effects), line)).toBe(true);
    expect(containsEqual(scripted(bob, effects), line)).toBe(true);
  });

  it('cannot be moved by clients, are not players, and go with a restart', () => {
    const g = game('on start()\n  create_npc({name: "A", position: {x: 1, y: 1, z: 1}})\nend');
    startWithBoth(g);
    const npc = g.roster.find((p) => p.isNPC)!;
    g.updateTransform({ peerID: npc.peerID, position: v3(99, 99, 99), yawDegrees: 0, velocity: v3(), isGrounded: true });
    expect(g.roster.find((p) => p.isNPC)?.position).toEqual(v3(1, 1, 1));
    g.handle({ kind: 'roundStarted' });
    expect(g.roster.filter((p) => p.isNPC).length).toBe(1);
    const h = game('on start()\n  create_npc({})\n  print(len(players()), len(npcs()))\nend');
    startWithBoth(h);
    expect(h.drainOutput()).toEqual(['2 1']);
    expect(h.players.size).toBe(2);
  });
});

describe('building the map', () => {
  it('scripts create, change and destroy blocks', () => {
    const world = emptyWorld('Arena');
    world.blocks.push(makeBlock({ name: 'Door' }));
    const g = game('on start()\n  let b = create_block({name: "Tower", shape: "cylinder", position: {x: 0, y: 5, z: 0}, size: {x: 2, y: 10, z: 2},\n                        color: "blue", material: "neon", tags: ["tall"]})\n  b.color = "red"\n  b.rotation = {x: 0, y: 45, z: 0}\n  let copy = b.clone()\n  copy.position = {x: 10, y: 5, z: 0}\n  block("Door").destroy()\n  print(len(blocks("tall")), len(blocks()))\nend', world);
    startWithBoth(g);
    expect(g.drainOutput()).toEqual(['2 2']);
    const tower = g.world.blocks.find((b) => b.name === 'Tower' && b.transform.position.x === 0)!;
    expect(tower.shape).toBe('cylinder');
    expect(tower.transform.scale).toEqual(v3(2, 10, 2));
    expect(tower.color).toEqual(parseScriptColor('red'));
    expect(tower.material).toBe('neon');
    expect(g.world.blocks.find((b) => b.name === 'Door')).toBeUndefined();
    const deltas = g.drainWorldDeltas();
    expect(deltas.some((d) => d.type === 'remove')).toBe(true);
    expect(deltas.filter((d) => d.type === 'insert').length).toBe(2);
  });

  it('every copy that applies the deltas has the host’s map', () => {
    const world = emptyWorld('Arena');
    world.blocks.push(makeBlock({ name: 'Door' }));
    const g = game('on start()\n  block("Door").destroy()\n  let b = create_block({name: "Bridge", size: {x: 8, y: 0.5, z: 2}})\n  b.position = {x: 4, y: 3, z: 0}\n  b.color = "brown"\n  world.gravity = -5\nend', world);
    const client = new LiveWorld(structuredClone(world));
    startWithBoth(g);
    // Through the wire format too, as a browser joining an iPad would get them.
    for (const delta of g.drainWorldDeltas()) client.apply(decodeDelta(JSON.parse(JSON.stringify(encodeDelta(delta))))!);
    expect(client.world.blocks).toEqual(g.world.blocks);
    expect(client.world.environment).toEqual(g.world.environment);
  });

  it('a restart puts the map back', () => {
    const world = emptyWorld('Arena');
    const door = makeBlock({ name: 'Door' });
    world.blocks.push(door);
    const g = game('on start()\n  if block("Door") then block("Door").destroy() end\n  create_block({name: "Rubble"})\n  world.sky = "red"\nend', world);
    startWithBoth(g);
    g.drainWorldDeltas();
    g.handle({ kind: 'roundStarted' });
    const deltas = g.drainWorldDeltas();
    expect(deltas.some((d) => d.type === 'insert' && JSON.stringify(d.block) === JSON.stringify(door))).toBe(true);
    expect(g.world.blocks.filter((b) => b.name === 'Rubble').length).toBe(1);
  });

  it('animated moves reach everyone when they finish', () => {
    const world = emptyWorld('Arena');
    const lift = makeBlock({ name: 'Lift' });
    world.blocks.push(lift);
    const g = game('on start()\n  block("Lift").move(0, 5, 0, 1)\nend', world);
    const opening = startWithBoth(g);
    expect(containsEqual(reaching(alice, opening), { type: 'move', blockID: lift.id, offset: v3(0, 5, 0), duration: 1 })).toBe(true);
    expect(g.live.block(lift.id)?.transform.position).toEqual(v3(0, 5, 0));
    expect(g.drainWorldDeltas()).toEqual([]);
    g.advance(0.5);
    expect(g.drainWorldDeltas()).toEqual([]);
    g.advance(1.1);
    expect(g.drainWorldDeltas().length).toBe(1);
  });

  it('the world itself', () => {
    const g = game('on start()\n  world.gravity = -3\n  world.sky = "black"\n  world.light = 0.2\n  world.fall_height = -5\nend');
    startWithBoth(g);
    expect(g.world.environment.gravity).toBe(-3);
    expect(g.world.environment.skyTop).toEqual(parseScriptColor('black'));
    expect(g.world.environment.ambientIntensity).toBeCloseTo(0.2, 4);
    expect(g.world.environment.killPlaneHeight).toBe(-5);
    expect(g.drainWorldDeltas().some((d) => d.type === 'environment')).toBe(true);
  });

  it('raycasts', () => {
    const world = emptyWorld('Arena');
    world.blocks.push(makeBlock({ name: 'Wall', transform: placed(v3(0, 1, 10), v3(10, 4, 1)) }));
    const g = game('on start()\n  let hit = raycast({x: 0, y: 1, z: 0}, {x: 0, y: 0, z: 1}, 50)\n  print(hit.block.name, hit.distance)\n  print(raycast({x: 0, y: 1, z: 0}, {x: 0, y: 0, z: -1}, 50))\nend', world);
    startWithBoth(g);
    expect(g.drainOutput()).toEqual(['Wall 9.5', 'nil']);
    expect(isSolidForPlayers(world.blocks[0])).toBe(true);
  });
});

describe('many .absc files', () => {
  it('run together, each handling the same event, skipping switched-off ones', () => {
    const world = emptyWorld('Arena');
    world.scripts = [
      script('main', 'let shared = 1\non join(p)\n  print("main " + p.name)\nend'),
      script('ui.absc', 'on join(p)\n  print("ui " + p.name + " " + shared)\nend'),
      script('off', 'on join(p)\n  print("never")\nend', false),
    ];
    const g = new GameRuntime(world);
    g.addPlayer(snapshot(alice, 'Alice'));
    g.handle({ kind: 'roundStarted' });
    expect(g.drainOutput()).toEqual(['main Alice', 'ui Alice 1']);
  });

  it('errors name their file', () => {
    const errors = GameRuntime.check([script('main', 'on start()\nend'), script('broken', '\n\nlet = 3'), script('also broken', 'on start(\n')]);
    expect(errors.map((e) => e.file)).toEqual(['broken.absc', 'also broken.absc']);
    expect(errors[0].line).toBe(3);
    expect(errors[0].description).toContain('broken.absc');
    const world = emptyWorld('Arena');
    world.scripts = [script('a', 'on start()\nend'), script('b', 'on start()\n  let x = nil\n  print(x.y)\nend')];
    const g = new GameRuntime(world);
    g.handle({ kind: 'roundStarted' });
    const runtime = g.drainErrors()[0];
    expect(runtime?.file).toBe('b.absc');
    expect(runtime?.line).toBe(3);
  });

  it('file names are cleaned', () => {
    expect(cleanScriptName('main')).toBe('main.absc');
    expect(cleanScriptName('Main.ABSC')).toBe('Main.absc');
    expect(cleanScriptName('../../etc/passwd')).toBe('passwd.absc');
    expect(cleanScriptName('   ')).toBe('main.absc');
    expect(cleanScriptName('ゲーム')).toBe('ゲーム.absc');
  });

  it('scripts travel as a delta', () => {
    const files = [script('main', 'on start()\nend')];
    const restored = decodeDelta(JSON.parse(JSON.stringify(encodeDelta({ type: 'scriptsReplaced', scripts: files }))))!;
    expect(restored).toEqual({ type: 'scriptsReplaced', scripts: files });
    const live = new LiveWorld(emptyWorld('Co-edit'));
    expect(live.apply(restored)).toBe(true);
    expect(live.world.scripts).toEqual(files);
  });
});

describe('folding host effects into a screen', () => {
  it('items keep their place when updated, and go when removed', () => {
    const s = new ScriptedPlayerState();
    s.apply({ kind: 'ui', element: uiElement('a', 'text', { text: '1' }) });
    s.apply({ kind: 'ui', element: uiElement('b', 'text', { text: '2' }) });
    s.apply({ kind: 'ui', element: uiElement('a', 'text', { text: '3' }) });
    expect(s.ui.map((e) => e.id)).toEqual(['a', 'b']);
    expect(s.element('a')?.text).toBe('3');
    s.apply({ kind: 'removeUI', id: 'a' });
    expect(s.ui.map((e) => e.id)).toEqual(['b']);
    s.apply({ kind: 'clearUI' });
    expect(s.ui).toEqual([]);
  });

  it('layers decide the drawing order', () => {
    const s = new ScriptedPlayerState();
    s.apply({ kind: 'ui', element: uiElement('top', 'text', { layer: 2 }) });
    s.apply({ kind: 'ui', element: uiElement('bottom', 'text', { layer: -1 }) });
    s.apply({ kind: 'ui', element: uiElement('middle', 'text') });
    expect(s.children(null).map((e) => e.id)).toEqual(['bottom', 'middle', 'top']);
  });

  it('firing needs a weapon, ammo and health', () => {
    const s = new ScriptedPlayerState();
    expect(s.canFire).toBe(false);
    s.apply({ kind: 'equip', weapon: weaponPresets.pistol });
    expect(s.canFire).toBe(true);
    s.apply({ kind: 'ammo', current: 0, magazine: 10, reloading: true });
    expect(s.canFire).toBe(false);
    s.apply({ kind: 'ammo', current: 10, magazine: 10, reloading: false });
    s.apply({ kind: 'health', current: 0, maximum: 100 });
    expect(s.isKnockedOut).toBe(true);
    expect(s.canFire).toBe(false);
    s.apply({ kind: 'equip' });
    expect(s.ammo).toBeNull();
  });

  it('each hit and fade is counted; presets sit inside the edge', () => {
    const s = new ScriptedPlayerState();
    s.apply({ kind: 'hitMarker', killed: false });
    s.apply({ kind: 'hitMarker', killed: true });
    s.apply({ kind: 'damageFlash' });
    s.apply({ kind: 'fade', color: { r: 0, g: 0, b: 0, a: 1 }, seconds: 1 });
    s.apply({ kind: 'fade', color: { r: 0, g: 0, b: 0, a: 1 }, seconds: 1 });
    expect(s.hitMarkerCount).toBe(2);
    expect(s.lastHitWasKnockout).toBe(true);
    expect(s.damageFlashCount).toBe(1);
    expect(s.fade.serial).toBe(2);
    const e = uiElement('a', 'text');
    placeUI(e, uiPresets.bottom_right);
    expect([e.x, e.pivotX, e.offsetX, e.offsetY]).toEqual([1, 1, -16, -16]);
  });
});
