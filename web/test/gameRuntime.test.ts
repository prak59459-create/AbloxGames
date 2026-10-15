// GameRuntimeTests.swift, on the web: the script game API played headlessly.
import { describe, expect, it } from 'vitest';
import {
  alice, aliceShootsBob, announcements, bob, containsEqual, game, healths, place, reaching, screen, scripted, snapshot, startWithBoth,
} from './runtimeHelpers';
import { GameRuntime } from '../src/core/runtime/gameRuntime';
import { runtimeEvents } from '../src/core/runtime/limits';
import { parseScriptColor } from '../src/core/model/color';
import { weaponPresets } from '../src/core/model/combat';
import { decodeAction, encodeAction, eventRule } from '../src/core/model/rules';
import { decodeInput, decodeSnapshot, encodeInput, encodeSnapshot, playerSnapshot, type PlayerInput } from '../src/core/model/player';
import { uiElement, type ScriptEffect } from '../src/core/model/effects';
import { f32v, v3 } from '../src/core/model/math';
import { emptyWorld, makeBlock, placed } from '../src/core/model/world';

const oneVersusOne = `let goal = 3

on start()
  game.respawn_time = 2
  ui_text("title", "1v1", {at: "top"})
end

on join(p)
  p.camera = "first"
  p.give("rifle")
  p.kills = 0
  p.ui_text("kills", "Kills: 0", {at: "top_left"})
end

on death(victim, killer)
  if killer then
    killer.kills = killer.kills + 1
    killer.score = killer.kills
    killer.ui_text("kills", "Kills: " + killer.kills)
    if killer.kills >= goal then
      end_round(killer.name + " wins!")
    end
  end
end
`;

describe('a whole 1v1', () => {
  it('plays to the end', () => {
    const g = game(oneVersusOne);
    const opening = startWithBoth(g);
    expect(g.compileErrors).toEqual([]);
    expect(g.drainErrors()).toEqual([]);
    for (const peer of [alice, bob]) {
      const mine = screen(peer, opening);
      expect(mine.camera.mode).toBe('first');
      expect(mine.weapon).toEqual(weaponPresets.rifle);
      expect(mine.element('title')?.text).toBe('1v1');
    }
    expect(opening.filter((e) => e.action.type === 'script' && e.action.effect.kind === 'camera').length).toBe(2);

    expect(healths(bob, aliceShootsBob(g, 1.0))).toEqual([66]);
    expect(healths(bob, aliceShootsBob(g, 1.6))).toEqual([32]);
    const killingShot = aliceShootsBob(g, 2.2);
    expect(healths(bob, killingShot).at(-1)).toBe(0);
    expect(containsEqual(scripted(alice, killingShot), { kind: 'hitMarker', killed: true } as ScriptEffect)).toBe(true);
    expect(screen(bob, killingShot).movement.frozen).toBe(true);
    expect(containsEqual(reaching(alice, killingShot), { type: 'awardPoints', points: 1 })).toBe(true);
    expect(g.players.get(alice)?.score).toBe(1);

    expect(healths(bob, aliceShootsBob(g, 2.8))).toEqual([]);

    expect(healths(bob, g.advance(4.0))).toEqual([]);
    const comeback = g.advance(4.3);
    expect(healths(bob, comeback)).toEqual([100]);
    expect(reaching(bob, comeback).some((a) => a.type === 'teleportPlayer')).toBe(true);

    aliceShootsBob(g, 4.4);
    const lastRound = aliceShootsBob(g, 5.0);
    expect(healths(bob, lastRound)).toEqual([32]);
    expect(containsEqual(scripted(alice, lastRound), { kind: 'ammo', current: 0, magazine: 6, reloading: true } as ScriptEffect)).toBe(true);
    expect(healths(bob, aliceShootsBob(g, 5.6))).toEqual([]);
    expect(containsEqual(scripted(alice, g.advance(7.1)), { kind: 'ammo', current: 6, magazine: 6, reloading: false } as ScriptEffect)).toBe(true);
    expect(healths(bob, aliceShootsBob(g, 7.2)).at(-1)).toBe(0);

    g.advance(9.3);
    aliceShootsBob(g, 9.4);
    aliceShootsBob(g, 10.0);
    const winner = aliceShootsBob(g, 10.6);
    expect(announcements(bob, winner)).toContain('Alice wins!');
    expect(screen(alice, winner).element('kills')?.text).toBe('Kills: 3');
    expect(g.isRoundOver).toBe(true);
    expect(g.players.get(alice)?.score).toBe(3);
    expect(aliceShootsBob(g, 14)).toEqual([]);
    expect(g.drainErrors()).toEqual([]);
  });

  it('updating a screen item keeps where it was', () => {
    const g = game(oneVersusOne);
    const before = screen(alice, startWithBoth(g)).element('kills');
    expect(before?.x).toBe(0);
    aliceShootsBob(g, 1);
    aliceShootsBob(g, 1.6);
    const after = screen(alice, aliceShootsBob(g, 2.2)).element('kills');
    expect(after?.text).toBe('Kills: 1');
    expect(after?.x).toBe(before?.x);
    expect(after?.offsetX).toBe(before?.offsetX);
  });

  it('a restart puts everyone back to the start', () => {
    const g = game(oneVersusOne);
    startWithBoth(g);
    aliceShootsBob(g, 1);
    const restart = g.handle({ kind: 'roundStarted' });
    expect(containsEqual(scripted(bob, restart), { kind: 'clearUI' } as ScriptEffect)).toBe(true);
    expect(healths(bob, aliceShootsBob(g, 5))).toEqual([66]);
  });

  it('restart_round from a script runs the script from the top, fresh', () => {
    const g = game('let rounds = 0\non start()\n  rounds = rounds + 1\n  print(rounds)\nend\non chat(p, text)\n  if text == "again" then restart_round() end\nend');
    startWithBoth(g);
    g.handleChat(alice, 'again');
    g.advance(0.1);
    expect(g.drainOutput()).toEqual(['1', '1']);
  });
});

describe('combat rules', () => {
  it('teammates cannot hurt each other, unless friendly fire is on', () => {
    const g = game('on join(p)\n  p.team = "red"\n  p.give("blaster")\nend');
    startWithBoth(g);
    expect(healths(bob, aliceShootsBob(g, 1))).toEqual([]);
    const f = game('on start()\n  game.friendly_fire = true\nend\non join(p)\n  p.team = "red"\n  p.give("blaster")\nend');
    startWithBoth(f);
    expect(healths(bob, aliceShootsBob(f, 1))).toEqual([80]);
  });

  it('on hit can change the damage', () => {
    const g = game('on join(p)\n  p.give("blaster")\nend\non hit(victim, attacker, amount)\n  if victim.name == "Bob" then\n    return amount * 2\n  end\n  return 0\nend');
    startWithBoth(g);
    expect(healths(bob, aliceShootsBob(g, 1))).toEqual([60]);
    place(g, bob, v3(0, 0, -10));
    place(g, alice, v3());
    expect(healths(alice, g.handleInput({ kind: 'fire', origin: v3(0, 1.6, -10), direction: v3(0, 0, 1) }, bob, 2))).toEqual([]);
  });

  it('without a weapon nothing fires', () => {
    const g = game('on start()\nend');
    startWithBoth(g);
    expect(aliceShootsBob(g, 1)).toEqual([]);
  });

  it('custom weapons go far beyond the presets', () => {
    const g = game('on start()\n  weapon("railgun", {model: "rifle", damage: 5000, range: 900, ammo: 1})\nend\non join(p)\n  p.give("Railgun")\n  p.max_health = 10000\n  p.health = 10000\nend');
    const equipped = screen(alice, startWithBoth(g)).weapon;
    expect(equipped?.damage).toBe(5000);
    expect(equipped?.range).toBe(900);
    expect(equipped?.magazine).toBe(1);
    expect(healths(bob, aliceShootsBob(g, 1))[0]).toBe(5000);
  });

  it('an unknown weapon is a helpful error, reported once', () => {
    const g = game('on join(p)\n  p.give("banana")\nend');
    startWithBoth(g);
    const errors = g.drainErrors();
    expect(errors.length).toBe(1);
    expect(errors[0].line).toBe(2);
    expect(errors[0].file).toBe('main.absc');
    expect(errors[0].message).toContain('rifle');
  });

  it('the knocked-out stay down when the script says so, and cannot shoot', () => {
    const g = game('on start()\n  game.respawn_time = -1\nend\non join(p)\n  p.give("pistol")\n  p.max_health = 10\n  p.ui_button("revive", "Revive")\nend\non button(p, id)\n  for each in players() do\n    if not each.alive then each.respawn() end\n  end\nend');
    startWithBoth(g);
    expect(healths(bob, aliceShootsBob(g, 1)).at(-1)).toBe(0);
    expect(healths(bob, g.advance(60))).toEqual([]);
    expect(healths(bob, g.handleInput({ kind: 'button', id: 'revive' }, alice, 61))).toEqual([10]);

    const h = game('on join(p)\n  p.give("pistol")\n  p.max_health = 10\nend');
    startWithBoth(h);
    aliceShootsBob(h, 1);
    place(h, bob, v3(0, 0, -10));
    place(h, alice, v3());
    expect(h.handleInput({ kind: 'fire', origin: v3(0, 1.6, -10), direction: v3(0, 0, 1) }, bob, 1.5)).toEqual([]);
  });
});

describe('moving and looking', () => {
  it('movement can go far but not forever', () => {
    const movement = screen(alice, startWithBoth(game('on join(p)\n  p.speed = 50\n  p.jump = -2\n  p.gravity = 0.2\nend'))).movement;
    expect(movement.speed).toBe(10);
    expect(movement.jump).toBe(0);
    expect(movement.gravity).toBeCloseTo(0.2, 4);
  });

  it('camera modes and screen control', () => {
    const mine = screen(alice, startWithBoth(game('on join(p)\n  p.camera = "top"\n  p.camera_distance = 30\n  p.fov = 90\n  p.controls = false\n  p.default_ui = false\n  p.fade("black", 2)\n  p.shake(1, 0.5)\nend')));
    expect(mine.camera.mode).toBe('top');
    expect(mine.camera.distance).toBe(30);
    expect(mine.camera.fieldOfView).toBe(90);
    expect(mine.showsControls).toBe(false);
    expect(mine.showsDefaultUI).toBe(false);
    expect(mine.fade.color).toEqual(parseScriptColor('black'));
    expect(mine.fade.seconds).toBe(2);
    expect(mine.shake.strength).toBe(1);
  });

  it('a fixed camera looks at something', () => {
    const world = emptyWorld('Arena');
    world.blocks.push(makeBlock({ name: 'Stage', transform: placed(v3(0, 0, 10)) }));
    const camera = screen(alice, startWithBoth(game('on join(p)\n  p.camera_look({x: 0, y: 10, z: 0}, block("Stage"))\nend', world))).camera;
    expect(camera.mode).toBe('fixed');
    expect(camera.position).toEqual(v3(0, 10, 0));
    expect(camera.target).toEqual(v3(0, 0, 10));
  });

  it('teleport, launch and facing', () => {
    const g = game('on join(p)\n  if p.name == "Alice" then\n    p.position = {x: 5, y: 10, z: 5}\n    p.launch(0, 20, 0)\n    p.yaw = 90\n  end\nend');
    const opening = startWithBoth(g);
    expect(containsEqual(reaching(alice, opening), { type: 'teleportPlayer', position: v3(5, 10, 5) })).toBe(true);
    expect(containsEqual(scripted(alice, opening), { kind: 'launch', velocity: v3(0, 20, 0) } as ScriptEffect)).toBe(true);
    expect(containsEqual(scripted(alice, opening), { kind: 'face', yawDegrees: 90 } as ScriptEffect)).toBe(true);
    expect(g.players.get(alice)?.position).toEqual(v3(5, 10, 5));
  });

  it('appearance changes reach everyone, and a restart gives looks back', () => {
    const g = game('on join(p)\n  p.color = "red"\n  p.size = 3\n  p.hat = "crown"\n  p.name = "Big " + p.name\n  if p.name == "Big Bob" then p.visible = false end\nend');
    startWithBoth(g);
    expect(g.takeRosterChange()).toBe(true);
    const aliceNow = g.roster.find((p) => p.peerID === alice);
    expect(aliceNow?.profile.bodyColor).toEqual(parseScriptColor('red'));
    expect(aliceNow?.profile.height).toBe(3);
    expect(aliceNow?.profile.hat).toBe('crown');
    expect(aliceNow?.profile.displayName).toBe('Big Alice');
    expect(g.roster.find((p) => p.peerID === bob)?.isHidden).toBe(true);
    expect(g.takeRosterChange()).toBe(false);
    g.handle({ kind: 'roundStarted' });
    expect(g.roster.find((p) => p.peerID === alice)?.profile.displayName).toBe('Big Alice');
  });

  it('big characters are big targets', () => {
    const g = game('on join(p)\n  p.give("rifle")\n  if p.name == "Bob" then p.size = 4 end\nend');
    startWithBoth(g);
    place(g, alice, v3(0, 0, -10));
    place(g, bob, v3());
    expect(healths(bob, g.handleInput({ kind: 'fire', origin: v3(0, 1.6, -10), direction: v3(0, 4.4, 10) }, alice, 1)).length).toBeGreaterThan(0);
  });
});

describe('screen GUI', () => {
  it('a late joiner sees what everyone else sees', () => {
    const g = game('on start()\n  ui_text("title", "Capture the flag", {at: "top", color: "red", size: "large"})\n  ui_bar("time", 30, 60)\nend\non join(p)\n  p.ui_text("hello", "Hi " + p.name)\nend');
    g.addPlayer(snapshot(alice, 'Alice'));
    g.handle({ kind: 'roundStarted' });
    const arrival = g.addPlayer(snapshot(bob, 'Bob'));
    const bobSees = screen(bob, arrival);
    expect(bobSees.element('title')?.color).toEqual(parseScriptColor('red'));
    expect(bobSees.element('title')?.fontSize).toBe(28);
    const time = bobSees.element('time')!;
    expect(time.value / time.maximum).toBe(0.5);
    expect(bobSees.element('hello')?.text).toBe('Hi Bob');
    expect(arrival.every((e) => e.target === bob)).toBe(true);
  });

  it('free positions, panels and handles', () => {
    const mine = screen(alice, startWithBoth(game('on join(p)\n  let menu = p.ui_panel("menu", {x: 0.25, y: 0.75, w: 300, h: 200, bg: "#00000080"})\n  p.ui_text("label", "Shop", {parent: "menu", y: 0.1, size: 30, bold: true})\n  let b = p.ui_button("buy", "Buy", {parent: menu, x: 0.5, y: 0.8})\n  b.text = "Buy now"\n  b.layer = 5\n  menu.visible = false\nend')));
    const menu = mine.element('menu');
    expect(menu?.x).toBe(0.25);
    expect(menu?.width).toBe(300);
    expect(menu?.visible).toBe(false);
    expect(mine.element('label')?.parent).toBe('menu');
    expect(mine.element('buy')?.parent).toBe('menu');
    expect(mine.element('buy')?.text).toBe('Buy now');
    expect(mine.element('buy')?.layer).toBe(5);
    expect(mine.children(null)).toEqual([]);
  });

  it('removing a panel removes what is in it', () => {
    const mine = screen(alice, startWithBoth(game('on join(p)\n  p.ui_panel("menu")\n  p.ui_text("a", "A", {parent: "menu"})\n  p.ui_text("b", "B")\n  p.ui_remove("menu")\nend')));
    expect(mine.ui.map((e) => e.id)).toEqual(['b']);
  });

  it('only buttons on screen can be pressed', () => {
    const g = game('on join(p)\n  if p.name == "Alice" then p.ui_button("shop", "Shop") end\nend\non button(p, id)\n  p.score = p.score + 1\nend');
    startWithBoth(g);
    expect(containsEqual(reaching(alice, g.handleInput({ kind: 'button', id: 'shop' }, alice, 1)), { type: 'awardPoints', points: 1 })).toBe(true);
    expect(g.handleInput({ kind: 'button', id: 'shop' }, bob, 1)).toEqual([]);
    expect(g.handleInput({ kind: 'button', id: 'secret' }, alice, 1)).toEqual([]);
  });

  it('text boxes and chat commands', () => {
    const g = game('on join(p)\n  p.ui_input("answer", "Type the password")\nend\non input(p, id, text)\n  if text == "swordfish" then p.message("Correct!") end\nend');
    startWithBoth(g);
    expect(announcements(alice, g.handleInput({ kind: 'text', id: 'answer', value: 'swordfish' }, alice, 1))).toEqual(['Correct!']);
    expect(g.handleInput({ kind: 'text', id: 'other', value: 'swordfish' }, alice, 1)).toEqual([]);
    const c = game('on chat(p, text)\n  if text == "/fly" then p.gravity = 0.1 end\nend');
    startWithBoth(c);
    expect(screen(bob, c.handleChat(bob, '/fly')).movement.gravity).toBeCloseTo(0.1, 4);
  });

  it('the screen has a limit, and bad options are explained', () => {
    const g = game('on join(p)\n  for i in 1 to 400 do\n    p.ui_text("item" + i, "x")\n  end\nend');
    startWithBoth(g);
    expect(g.drainErrors()[0]?.kind).toBe('limit');
    const h = game('on start()\n  ui_text("a", "b", {at: "middle"})\nend');
    startWithBoth(h);
    expect(h.drainErrors()[0]?.message).toContain('top_left');
  });
});

describe('rules, touches, leaving', () => {
  it('scores from scripts trip score rules', () => {
    const world = emptyWorld('Arena');
    world.rules = [eventRule({ name: 'Win', trigger: { type: 'scoreReached', score: 3 }, actions: [{ type: 'endRound', message: 'Winner' }] })];
    expect(announcements(alice, startWithBoth(game('on join(p)\n  if p.name == "Bob" then p.score = 3 end\nend', world)))).toContain('Winner');
  });

  it('rules still run when the script does not parse', () => {
    const world = emptyWorld('Arena');
    world.rules = [eventRule({ name: 'Hello', trigger: { type: 'worldStart' }, actions: [{ type: 'announce', message: 'Welcome', duration: 2 }] })];
    const g = game('on start(\n', world);
    const opening = startWithBoth(g);
    expect(g.compileErrors.length).toBe(1);
    expect(g.compileErrors[0].file).toBe('main.absc');
    expect(g.drainErrors().length).toBe(1);
    expect(announcements(alice, opening)).toContain('Welcome');
    expect(g.isScriptRunning).toBe(false);
  });

  it('touches are throttled', () => {
    const world = emptyWorld('Arena');
    const lava = makeBlock({ name: 'Lava' });
    world.blocks.push(lava);
    const g = game('on touch(p, b)\n  if b.name == "Lava" then p.damage(10) end\nend', world);
    startWithBoth(g);
    let hits = 0;
    for (let step = 0; step < 10; step++) {
      g.advance(step * 0.1);
      hits += healths(alice, g.handle({ kind: 'touched', peer: alice, blockID: lava.id })).length;
    }
    expect(hits).toBe(2);
  });

  it('on leave can still read the name', () => {
    const g = game('on leave(p)\n  announce(p.name + " left")\nend');
    startWithBoth(g);
    expect(announcements(alice, g.removePlayer(bob))).toEqual(['Bob left']);
  });
});

describe('time', () => {
  it('timers', () => {
    const g = game('let ticks = 0\non start()\n  after(1, func() announce("one") end)\n  let id = every(0.5, func()\n    ticks = ticks + 1\n    if ticks == 3 then announce("three") end\n  end)\n  after(10, func() cancel(id) end)\nend');
    startWithBoth(g);
    const heard: string[] = [];
    for (let step = 1; step <= 30; step++) heard.push(...announcements(alice, g.advance(step * 0.1)));
    expect(heard).toEqual(['one', 'three']);
  });

  it('tick gets the time since the last tick', () => {
    const g = game('on tick(dt)\n  print(dt)\nend');
    startWithBoth(g);
    g.advance(0.1);
    g.advance(0.3);
    expect(g.drainOutput()).toEqual(['0.1', '0.2']);
  });
});

describe('safety', () => {
  it('an error in tick is reported once and the game goes on', () => {
    const g = game('on join(p)\n  p.give("pistol")\nend\non tick(dt)\n  let broken = nil\n  print(broken.health)\nend');
    startWithBoth(g);
    for (let step = 1; step <= 20; step++) g.advance(step * 0.1);
    const errors = g.drainErrors();
    expect(errors.length).toBe(1);
    expect(errors[0].line).toBe(6);
    expect(healths(bob, aliceShootsBob(g, 3)).length).toBeGreaterThan(0);
  });

  it('an endless loop cannot freeze the host; the default budget is generous', () => {
    const g = game('on tick(dt)\n  while true do\n  end\nend', emptyWorld('Arena'), { stepsPerCall: 20_000 });
    startWithBoth(g);
    g.advance(0.1);
    expect(g.drainErrors()[0]?.kind).toBe('limit');
    const h = game('on start()\n  let total = 0\n  for i in 1 to 100000 do total = total + i end\n  print(total)\nend');
    startWithBoth(h);
    expect(h.drainOutput()).toEqual(['5000050000']);
    expect(h.drainErrors()).toEqual([]);
  });

  it('timers cannot pile up forever', () => {
    const g = game('on tick(dt)\n  for i in 1 to 50 do every(100, func() end) end\nend');
    startWithBoth(g);
    for (let step = 1; step <= 30; step++) g.advance(step * 0.1);
    expect(g.drainErrors()[0]?.kind).toBe('limit');
  });
});

describe("Studio's Check button", () => {
  it('finds misspelled events, accepts every real one, reports syntax errors', () => {
    const problems = GameRuntime.checkSource('on joni(p)\nend\n\non start()\nend\n');
    expect(problems.length).toBe(1);
    expect(problems[0].line).toBe(1);
    expect(problems[0].message).toContain('join');
    expect(GameRuntime.checkSource(runtimeEvents.map((e) => `on ${e}()\nend`).join('\n'))).toEqual([]);
    const syntax = GameRuntime.checkSource('let x = \n');
    expect(syntax.length).toBe(1);
    expect(syntax[0].kind).toBe('syntax');
  });
});

describe('wire format', () => {
  it('script effects survive the wire', () => {
    const effects: ScriptEffect[] = [
      { kind: 'ui', element: uiElement('a', 'text', { parent: 'p', text: 'Hi', x: 0.1, y: 0.9, width: 100, color: { r: 1, g: 1, b: 1, a: 1 } }) },
      { kind: 'ui', element: uiElement('b', 'bar', { value: 3, maximum: 10 }) },
      { kind: 'removeUI', id: 'a' }, { kind: 'clearUI' },
      { kind: 'camera', camera: { mode: 'fixed', distance: 3, fieldOfView: 80, position: v3(1, 2, 3) } },
      { kind: 'shake', strength: 0.5, seconds: 1 }, { kind: 'fade', color: { r: 0, g: 0, b: 0, a: 1 }, seconds: 2 }, { kind: 'fade', seconds: 0 },
      { kind: 'interface', controls: false, defaultUI: true }, { kind: 'equip', weapon: weaponPresets.pistol }, { kind: 'equip' },
      { kind: 'ammo', current: 3, magazine: 10, reloading: true }, { kind: 'health', current: 50, maximum: 100 },
      { kind: 'movement', movement: { speed: 2, jump: 0.5, gravity: 0.3, frozen: true } }, { kind: 'launch', velocity: v3(0, 10, 0) },
      { kind: 'face', yawDegrees: 45 }, { kind: 'hitMarker', killed: true }, { kind: 'damageFlash' },
      { kind: 'tracer', from: v3(1, 2, 3), to: v3(4, 5, 6) }, { kind: 'chat', text: 'hello' },
    ];
    for (const effect of effects) {
      const action = { type: 'script' as const, effect };
      expect(decodeAction(JSON.parse(JSON.stringify(encodeAction(action))))).toEqual(action);
    }
  });

  it('as Swift writes them', () => {
    expect(encodeAction({ type: 'script', effect: { kind: 'clearUI' } })).toEqual({ effect: { clearUI: {} }, type: 'script' });
    expect(encodeAction({ type: 'script', effect: { kind: 'equip' } })).toEqual({ effect: { equip: {} }, type: 'script' });
    expect(encodeAction({ type: 'script', effect: { kind: 'chat', text: 'hi' } })).toEqual({ effect: { chat: { _0: 'hi' } }, type: 'script' });
    expect(encodeAction({ type: 'script', effect: { kind: 'removeUI', id: 'x' } })).toEqual({ effect: { removeUI: { id: 'x' } }, type: 'script' });
  });

  it('player inputs survive the wire, and old roster entries still decode', () => {
    const inputs: PlayerInput[] = [
      { kind: 'fire', origin: v3(0, 1.6, 0), direction: v3(0, 0, -1) }, { kind: 'button', id: 'shop' }, { kind: 'reload' },
      { kind: 'text', id: 'name', value: 'Mika' }, { kind: 'gesture', wire: 'wave' },
    ];
    // Positions travel as 32-bit floats, as the iPads keep them.
    const asFloats = (i: PlayerInput): PlayerInput => (i.kind === 'fire' ? { ...i, origin: f32v(i.origin), direction: f32v(i.direction) } : i);
    for (const input of inputs) expect(decodeInput(JSON.parse(JSON.stringify(encodeInput(input))))).toEqual(asFloats(input));
    const json = encodeSnapshot(playerSnapshot(alice)) as Record<string, unknown>;
    delete json.isNPC;
    delete json.isHidden;
    const decoded = decodeSnapshot(JSON.parse(JSON.stringify(json)))!;
    expect(decoded.isNPC).toBe(false);
    expect(decoded.isHidden).toBe(false);
  });

  it('named colours', () => {
    expect(parseScriptColor('red')).toEqual(parseScriptColor('赤'));
    expect(parseScriptColor(' Blue ')).toEqual(parseScriptColor('#3B82F6'));
    expect(parseScriptColor('透明')?.a).toBe(0);
    expect(parseScriptColor('bleu')).toBeNull();
    expect(parseScriptColor('123456')).toBeNull();
  });
});
