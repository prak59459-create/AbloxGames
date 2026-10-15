// Everything a .absc script can call and read — AbloxCore/GameRuntimeAPI.swift:
// the globals, and the members of players, NPCs, blocks, the world, the game
// and screen items. The rule for what belongs here is "could a game need
// it?", not "is it small?".
import { L } from '../../i18n';
import { hats, rides, defaultProfile, emotes, type Hat, type Ride } from '../model/avatar';
import { colorFromHex, hexString, type ColorRGBA } from '../model/color';
import { ArmedState, PlayerHitBody, clampedWeapon, weaponPresets, weaponSpec } from '../model/combat';
import {
  UILimits, cameraModes, placeUI, standardCamera, uiElement, uiKinds, uiPresets,
  type CameraMode, type CameraSettings, type ScriptEffect, type UIElement, type UIKind,
} from '../model/effects';
import { add, eulerDegrees32, f32v, quatEulerDegrees32, quatYaw, rotate, sub, v3, type Vec3 } from '../model/math';
import { parseGesture, playerSnapshot } from '../model/player';
import { prefix, trimmed, trimmedSpaces } from '../model/text';
import {
  blockBehaviors, blockShapes, makeBlock, materialKinds, type BlockBehavior, type BlockData, type BlockShape, type MaterialKind,
} from '../model/world';
import { newID } from '../model/codec';
import type { ScriptInterpreter } from '../script/interpreter';
import {
  ScriptFunction, ScriptList, ScriptMap, ScriptNative, ScriptObject, displayText, isTruthy, scriptInt, toVector, typeName,
  vectorValue, type ScriptValue,
} from '../script/values';
import {
  arg, color, limitError, method, number, optionalNumber, optionsMap, rounded, roundedVector, roundAway, runtimeError, shortText,
  vector, vectorArgument,
} from './args';
import type { Effect, GameRuntime } from './gameRuntime';
import {
  RuntimeLimits, characterMemberNames, laterMemberNames, npcOnlyMemberNames, playerOnlyMemberNames, uiOptionNames,
} from './limits';
import {
  installPartsAPI, partsBlockMember, partsMember, partsWorldMember, setPartsBlockMember, setPartsWorldMember, soundEffect,
} from './parts';
import { installHelperAPI } from './helpers';
import { save, savedValue } from './saves';
import { PlayerState } from './state';

type Action = Effect['action'];
const script = (effect: ScriptEffect): Action => ({ type: 'script', effect });

// MARK: Globals

export function installGameAPI(rt: GameRuntime, I: ScriptInterpreter): void {
  I.defineValue('game', new ScriptObject('game', 'game', 'game'));
  I.defineValue('world', new ScriptObject('world', 'world', 'world'));

  I.define('players', () => new ScriptList(rt.orderedStates.filter((s) => !s.isNPC).map((s) => rt.object(s))));
  I.define('npcs', () => new ScriptList(rt.orderedStates.filter((s) => s.isNPC).map((s) => rt.object(s))));
  I.define('find_player', (args) => {
    const name = displayText(arg(args, 0)).toLowerCase();
    const match = rt.orderedStates.find((s) => !s.isNPC && s.name.toLowerCase() === name);
    return match ? rt.object(match) : null;
  });

  I.define('block', (args) => {
    const id = rt.blockLookup.firstBlock(displayText(arg(args, 0)));
    return id ? rt.blockObject(id) : null;
  });
  I.define('blocks', (args) => {
    if (!args.length || args[0] === null) return new ScriptList(rt.world.blocks.map((b) => rt.blockObject(b.id)));
    return new ScriptList(rt.blockLookup.blocksTagged(displayText(args[0])).map((id) => rt.blockObject(id)));
  });
  I.define('create_block', (args, line) => createBlock(rt, arg(args, 0), line));
  I.define('create_npc', (args, line) => createNPC(rt, arg(args, 0), line));

  I.define('distance', (args, line) => {
    if (args.length < 2) throw runtimeError(line, L('“{}” needs {} values.', 'distance', 2));
    const a = point(rt, args[0], line), b = point(rt, args[1], line);
    return Math.hypot(a.x - b.x, a.y - b.y, a.z - b.z);
  });
  I.define('raycast', (args, line) => raycast(rt, args, line));
  I.define('time', () => rt.clock - rt.roundStartedAt);

  I.define('after', (args, line) => addTimer(rt, args, false, line));
  I.define('every', (args, line) => addTimer(rt, args, true, line));
  I.define('cancel', (args) => {
    const id = arg(args, 0);
    if (typeof id !== 'number') return false;
    const before = rt.timers.length;
    const wanted = scriptInt(id);
    rt.timers = rt.timers.filter((t) => t.id !== wanted);
    return rt.timers.length < before;
  });

  I.define('announce', (args, line) => {
    const text = shortText(arg(args, 0));
    const seconds = optionalNumber(args, 1, 3, line);
    rt.pending.push(rt.broadcast({ type: 'announce', message: text, duration: Math.min(Math.max(seconds, 0.3), 120) }));
    return null;
  });
  I.define('sound', (args, line) => { rt.pending.push(rt.broadcast(soundEffect(args, line))); return null; });
  I.define('chat', (args) => { rt.pending.push(rt.broadcast(script({ kind: 'chat', text: shortText(arg(args, 0)) }))); return null; });
  I.define('fade', (args, line) => { rt.pending.push(rt.broadcast(script(fadeEffect(args, line)))); return null; });
  I.define('shake', (args, line) => { rt.pending.push(rt.broadcast(script(shakeEffect(args, line)))); return null; });
  I.define('end_round', (args) => {
    const text = !args.length || args[0] === null ? L('Round over') : shortText(args[0]);
    rt.pending.push(rt.broadcast({ type: 'endRound', message: text }));
    rt.machine.endRound();
    return null;
  });
  I.define('restart_round', () => {
    // At the next tick, not now: this call is inside the script a restart replaces.
    rt.pendingRestart = true;
    return null;
  });
  I.define('weapon', (args, line) => defineWeapon(rt, args, line));

  for (const kind of uiKinds) I.define('ui_' + kind, (args, line) => createUI(rt, kind, args, null, line));
  I.define('ui_set', (args, line) => setUI(rt, args, null, line));
  I.define('ui_remove', (args) => { removeUI(rt, uiID(arg(args, 0)), null); return null; });
  I.define('ui_clear', () => { clearUI(rt, null); return null; });

  installPartsAPI(rt, I);
  installHelperAPI(rt, I);
}

// MARK: Members

export function member(rt: GameRuntime, object: ScriptObject, name: string, line: number): ScriptValue {
  switch (object.kind) {
    case 'player': case 'npc': return characterMember(rt, object, name, line);
    case 'block': return blockMember(rt, object, name, line);
    case 'game': return gameMember(rt, name, line);
    case 'world': return worldMember(rt, name, line);
    case 'ui': return uiMember(rt, object, name, line);
    default: return null;
  }
}

export function setMember(rt: GameRuntime, object: ScriptObject, name: string, value: ScriptValue, line: number): void {
  switch (object.kind) {
    case 'player': case 'npc': setCharacterMember(rt, object, name, value, line); return;
    case 'block': setBlockMember(rt, object, name, value, line); return;
    case 'game': setGameMember(rt, name, value, line); return;
    case 'world': setWorldMember(rt, name, value, line); return;
    case 'ui': setUIMember(rt, object, name, value, line); return;
    default: throw runtimeError(line, L('“{}” cannot be changed here.', name));
  }
}

// MARK: Characters

function characterMember(rt: GameRuntime, object: ScriptObject, name: string, _line: number): ScriptValue {
  const state = rt.character(object);
  // Someone who has left still has a name, so a goodbye works.
  if (!state) return name === 'name' ? object.displayName : name === 'alive' ? false : null;
  // A world's own value under a name the API took later wins.
  if (laterMemberNames.has(name) && state.custom.has(name)) return state.custom.get(name)!;
  const body = rt.snapshot(state);
  const position = body?.position ?? v3();

  switch (name) {
    case 'name': return state.name;
    case 'id': return state.peer.slice(0, 8);
    case 'is_npc': return state.isNPC;
    case 'health': return state.health;
    case 'max_health': return state.maxHealth;
    case 'alive': return state.isAlive;
    case 'score': return state.isNPC ? state.npcScore : body?.score ?? 0;
    case 'team': return state.team ? state.team : null;
    case 'position': return roundedVector(position);
    case 'x': return rounded(position.x);
    case 'y': return rounded(position.y);
    case 'z': return rounded(position.z);
    case 'yaw': return body?.yawDegrees ?? 0;
    case 'look': return vectorValue(rotate(quatYaw(-(body?.yawDegrees ?? 0)), v3(0, 0, -1)));
    case 'velocity': return vectorValue(body?.velocity ?? v3());
    case 'weapon': return state.armed ? state.armed.weapon.name : null;
    case 'ammo': return state.armed ? state.armed.ammo : null;
    case 'speed': return state.movement.speed;
    case 'jump': return state.movement.jump;
    case 'gravity': return state.movement.gravity;
    case 'frozen': return state.movement.frozen;
    case 'color': return hexString(state.profile.bodyColor);
    case 'head_color': return hexString(state.profile.headColor);
    case 'leg_color': return hexString(state.profile.accentColor);
    case 'size': return state.profile.height;
    case 'hat': return state.profile.hat;
    case 'ride': return state.profile.ride;
    case 'ride_color': return hexString(state.profile.rideColor);
    case 'visible': return !state.isHidden;
    case 'camera': return state.camera.mode;
    case 'camera_distance': return state.camera.distance;
    case 'fov': return state.camera.fieldOfView;
    case 'controls': return state.showsControls;
    case 'default_ui': return state.showsDefaultUI;
    case 'saved': return savedValue(state);

    case 'save': return method(name, (a, l) => save(rt, a, state, l));
    case 'give': return method(name, (a, l) => {
      const weapon = weaponNamed(rt, arg(a, 0), l);
      state.armed = new ArmedState(weapon);
      rt.send(state, script({ kind: 'equip', weapon: clampedWeapon(weapon) }));
      rt.sendAmmo(state);
      // Someone with a weapon is in a fight: their health shows from now on.
      rt.sendHealth(state);
      return null;
    });
    case 'take': return method(name, () => {
      state.armed = null;
      rt.send(state, script({ kind: 'equip' }));
      return null;
    });
    case 'reload': return method(name, () => {
      if (state.armed?.startReload(rt.clock)) rt.sendAmmo(state);
      return null;
    });
    case 'teleport': return method(name, (a, l) => { rt.teleport(state, destination(rt, a, l)); return null; });
    case 'damage': return method(name, (a, l) => {
      const amount = number(arg(a, 0), 'damage', l);
      rt.applyDamage(amount, state, characterArgument(rt, a, 1) ?? null);
      return null;
    });
    case 'heal': return method(name, (a, l) => {
      const amount = number(arg(a, 0), 'heal', l);
      if (!state.isAlive || !(amount > 0)) return null;
      state.health = Math.min(state.maxHealth, state.health + amount);
      rt.sendHealth(state);
      return null;
    });
    case 'kill': return method(name, (a) => { rt.knockOut(state, characterArgument(rt, a, 0) ?? null); return null; });
    case 'respawn': return method(name, () => { rt.respawn(state); return null; });
    case 'launch': return method(name, (a, l) => { launch(rt, state, vectorArgument(a, l, 'launch')); return null; });
    case 'look_at': return method(name, (a, l) => {
      const target = point(rt, arg(a, 0), l);
      const offset = sub(target, position);
      if (!(offset.x * offset.x + offset.z * offset.z > 1e-6)) return null;
      face(rt, state, (Math.atan2(offset.x, -offset.z) * 180) / Math.PI);
      return null;
    });

    case 'camera_look': return method(name, (a, l) => {
      const camera: CameraSettings = { ...state.camera, mode: 'fixed', position: point(rt, arg(a, 0), l) };
      camera.target = a.length > 1 && a[1] !== null ? point(rt, a[1], l) : undefined;
      setCamera(rt, state, camera);
      return null;
    });
    case 'camera_reset': return method(name, () => { setCamera(rt, state, standardCamera()); return null; });
    case 'message': return method(name, (a, l) => {
      const text = shortText(arg(a, 0));
      const seconds = optionalNumber(a, 1, 3, l);
      rt.send(state, { type: 'announce', message: text, duration: Math.min(Math.max(seconds, 0.3), 120) });
      return null;
    });
    case 'sound': return method(name, (a, l) => { rt.send(state, soundEffect(a, l)); return null; });
    case 'chat': return method(name, (a) => { rt.send(state, script({ kind: 'chat', text: shortText(arg(a, 0)) })); return null; });
    case 'fade': return method(name, (a, l) => { rt.send(state, script(fadeEffect(a, l))); return null; });
    case 'shake': return method(name, (a, l) => { rt.send(state, script(shakeEffect(a, l))); return null; });
    case 'ui_text': case 'ui_button': case 'ui_panel': case 'ui_image': case 'ui_bar': case 'ui_input': {
      const kind = (uiKinds.includes(name.slice(3) as UIKind) ? name.slice(3) : 'text') as UIKind;
      return method(name, (a, l) => createUI(rt, kind, a, state, l));
    }
    case 'ui_set': return method(name, (a, l) => setUI(rt, a, state, l));
    case 'ui_remove': return method(name, (a) => { removeUI(rt, uiID(arg(a, 0)), state); return null; });
    case 'ui_clear': return method(name, () => { clearUI(rt, state); return null; });

    case 'move_to': return npcMethod(state, name, (a, l) => { state.goal = { kind: 'point', point: point(rt, arg(a, 0), l) }; return null; });
    case 'follow': return npcMethod(state, name, (a, l) => {
      const target = characterArgument(rt, a, 0);
      state.goal = target ? { kind: 'character', peer: target.peer } : { kind: 'point', point: point(rt, arg(a, 0), l) };
      return null;
    });
    case 'stop': return npcMethod(state, name, () => { state.goal = { kind: 'none' }; return null; });
    case 'jump_now': return npcMethod(state, name, () => { state.wantsJump = true; return null; });
    case 'shoot': return npcMethod(state, name, (a, l) => {
      const target = point(rt, arg(a, 0), l);
      if (characterArgument(rt, a, 0)) target.y += 1;
      const eyes = add(position, v3(0, PlayerHitBody.eyeHeight * state.profile.height, 0));
      rt.fire(state, eyes, sub(target, eyes));
      return null;
    });
    case 'say': return npcMethod(state, name, (a) => {
      rt.pending.push(rt.broadcast(script({ kind: 'say', speaker: state.peer, name: state.name, text: shortText(arg(a, 0)) })));
      return null;
    });
    case 'emote': return method(name, (a, l) => {
      const wire = displayText(arg(a, 0));
      const gesture = parseGesture(wire);
      if (!gesture) throw runtimeError(l, L('“{}” is not an emote. Try {}.', wire, emotes.join(', ')));
      rt.pending.push(rt.broadcast(script({ kind: 'gesture', speaker: state.peer, wire: gesture.wire })));
      return null;
    });
    case 'destroy': return npcMethod(state, name, () => { rt.removeNPC(state); return null; });

    default: {
      const part = partsMember(rt, state, name);
      if (part !== undefined) return part;
      return state.custom.get(name) ?? null;
    }
  }
}

function setCharacterMember(rt: GameRuntime, object: ScriptObject, name: string, value: ScriptValue, line: number): void {
  const state = rt.character(object);
  if (!state) return; // they left; nothing to change

  switch (name) {
    case 'health': {
      const target = Math.min(Math.max(number(value, name, line), 0), state.maxHealth);
      if (target < state.health) rt.applyDamage(state.health - target, state, null);
      else if (state.isAlive) {
        state.health = target;
        rt.sendHealth(state);
      }
      return;
    }
    case 'max_health': {
      const maximum = Math.min(Math.max(number(value, name, line), 1), RuntimeLimits.maximumHealth);
      state.maxHealth = maximum;
      state.health = Math.min(state.health, maximum);
      rt.sendHealth(state);
      return;
    }
    case 'score': {
      const score = number(value, name, line);
      if (!(Math.abs(score) < 1_000_000_000_000)) throw runtimeError(line, L('That number is too big.'));
      rt.setScore(state, roundAway(score));
      return;
    }
    case 'team': state.team = value === null ? '' : prefix(displayText(value), 32); return;
    case 'position': rt.teleport(state, point(rt, value, line)); return;
    case 'yaw': face(rt, state, number(value, name, line)); return;
    case 'velocity': launch(rt, state, vector(value, line)); return;
    case 'speed': case 'jump': case 'gravity': {
      const multiplier = Math.fround(Math.min(Math.max(number(value, name, line), 0), RuntimeLimits.maximumMovementMultiplier));
      state.movement = { ...state.movement, [name]: multiplier };
      if (state.isAlive) rt.send(state, script({ kind: 'movement', movement: { ...state.movement } }));
      return;
    }
    case 'frozen':
      state.movement = { ...state.movement, frozen: isTruthy(value) };
      if (state.isAlive) rt.send(state, script({ kind: 'movement', movement: { ...state.movement } }));
      return;
    case 'color': { const c = color(value, line); rt.updateProfile(state, (p) => { p.bodyColor = c; }); return; }
    case 'head_color': { const c = color(value, line); rt.updateProfile(state, (p) => { p.headColor = c; }); return; }
    case 'leg_color': { const c = color(value, line); rt.updateProfile(state, (p) => { p.accentColor = c; }); return; }
    case 'size': {
      const size = Math.fround(Math.min(Math.max(number(value, name, line), RuntimeLimits.minimumSize), RuntimeLimits.maximumSize));
      rt.updateProfile(state, (p) => { p.height = size; });
      return;
    }
    case 'hat': {
      const text = value === null ? 'none' : displayText(value).toLowerCase();
      if (!(hats as readonly string[]).includes(text)) throw runtimeError(line, L('“hat” is one of: {}.', hats.join(', ')));
      rt.updateProfile(state, (p) => { p.hat = text as Hat; });
      return;
    }
    case 'ride': {
      const text = value === null ? 'none' : displayText(value).toLowerCase();
      if (!(rides as readonly string[]).includes(text)) throw runtimeError(line, L('“ride” is one of: {}.', rides.join(', ')));
      rt.updateProfile(state, (p) => { p.ride = text as Ride; });
      return;
    }
    case 'ride_color': { const c = color(value, line); rt.updateProfile(state, (p) => { p.rideColor = c; }); return; }
    case 'name': {
      const text = prefix(trimmed(displayText(value)), 24);
      if (!text) return;
      rt.updateProfile(state, (p) => { p.displayName = text; });
      return;
    }
    case 'visible': {
      const hidden = !isTruthy(value);
      if (hidden !== state.isHidden) {
        state.isHidden = hidden;
        rt.rosterChanged = true;
      }
      return;
    }
    case 'camera': {
      const text = displayText(value).toLowerCase();
      const aliases: Record<string, CameraMode> = { first_person: 'first', third_person: 'third', top_down: 'top' };
      const mode = (cameraModes as string[]).includes(text) ? (text as CameraMode) : aliases[text];
      if (!mode) throw runtimeError(line, L('“camera” is one of: {}.', cameraModes.join(', ')));
      setCamera(rt, state, { ...state.camera, mode });
      return;
    }
    case 'camera_distance':
      setCamera(rt, state, { ...state.camera, distance: Math.fround(Math.min(Math.max(number(value, name, line), 0.5), 300)) });
      return;
    case 'fov':
      setCamera(rt, state, { ...state.camera, fieldOfView: Math.fround(Math.min(Math.max(number(value, name, line), 10), 150)) });
      return;
    case 'controls':
      state.showsControls = isTruthy(value);
      rt.send(state, script({ kind: 'interface', controls: state.showsControls, defaultUI: state.showsDefaultUI }));
      return;
    case 'default_ui':
      state.showsDefaultUI = isTruthy(value);
      rt.send(state, script({ kind: 'interface', controls: state.showsControls, defaultUI: state.showsDefaultUI }));
      return;
    case 'ammo': {
      const armed = state.armed;
      if (!armed) return;
      armed.ammo = Math.min(Math.max(scriptInt(number(value, name, line)), 0), armed.weapon.magazine);
      armed.reloadEnds = null;
      rt.sendAmmo(state);
      return;
    }
    case 'id': case 'is_npc': case 'alive': case 'x': case 'y': case 'z': case 'look': case 'weapon':
      throw runtimeError(line, L('A character’s “{}” cannot be set directly.', name));
    default:
      // Worlds written before items, vehicles and shops keep their own data
      // under those names (`p.items = {}`): storing it is allowed.
      if (!laterMemberNames.has(name)
        && (characterMemberNames.includes(name) || playerOnlyMemberNames.includes(name) || npcOnlyMemberNames.includes(name))) {
        throw runtimeError(line, L('“{}” is a function. Call it with ().', name));
      }
      if (value === null) {
        state.custom.delete(name);
      } else {
        if (!state.custom.has(name) && state.custom.size >= RuntimeLimits.maximumCustomValues) {
          throw limitError(line, L('Too many values stored on one character.'));
        }
        state.custom.set(name, value);
      }
  }
}

function npcMethod(state: PlayerState, name: string, body: (args: ScriptValue[], line: number) => ScriptValue): ScriptValue {
  return method(name, (args, line) => {
    if (!state.isNPC) throw runtimeError(line, L('Only an NPC can “{}”.', name));
    return body(args, line);
  });
}

function setCamera(rt: GameRuntime, state: PlayerState, camera: CameraSettings): void {
  state.camera = camera;
  rt.send(state, script({ kind: 'camera', camera: { ...camera } }));
}

function launch(rt: GameRuntime, state: PlayerState, velocity: Vec3): void {
  if (state.isNPC) {
    if (state.body) {
      state.body.velocity = { ...velocity };
      state.body.isGrounded = false;
    }
  } else {
    rt.send(state, script({ kind: 'launch', velocity: { ...velocity } }));
  }
}

function face(rt: GameRuntime, state: PlayerState, yaw: number): void {
  if (!Number.isFinite(yaw)) return;
  if (state.isNPC) {
    if (state.body) state.body.yawDegrees = yaw;
    state.needsTransformSend = true;
  } else {
    rt.send(state, script({ kind: 'face', yawDegrees: Math.fround(yaw) }));
  }
}

function createNPC(rt: GameRuntime, value: ScriptValue, line: number): ScriptValue {
  let npcs = 0;
  for (const s of rt.states.values()) if (s.isNPC) npcs++;
  if (npcs >= RuntimeLimits.maximumNPCs) throw limitError(line, L('Too many NPCs (the limit is {}).', RuntimeLimits.maximumNPCs));
  const options = optionsMap(value, line);
  const profile = defaultProfile();
  const nameOption = options.get('name');
  profile.displayName = nameOption !== undefined ? prefix(displayText(nameOption), 24) : 'NPC';
  const colorOption = (key: string) => options.get(key);
  if (colorOption('color') !== undefined) profile.bodyColor = color(colorOption('color')!, line);
  if (colorOption('head_color') !== undefined) profile.headColor = color(colorOption('head_color')!, line);
  if (colorOption('leg_color') !== undefined) profile.accentColor = color(colorOption('leg_color')!, line);
  const size = options.get('size');
  if (size !== undefined) profile.height = Math.fround(Math.min(Math.max(number(size, 'size', line), RuntimeLimits.minimumSize), RuntimeLimits.maximumSize));
  const hat = options.get('hat');
  if (hat !== undefined && (hats as readonly string[]).includes(displayText(hat).toLowerCase())) profile.hat = displayText(hat).toLowerCase() as Hat;
  const ride = options.get('ride');
  if (ride !== undefined && (rides as readonly string[]).includes(displayText(ride).toLowerCase())) profile.ride = displayText(ride).toLowerCase() as Ride;
  if (options.get('ride_color') !== undefined) profile.rideColor = color(options.get('ride_color')!, line);
  const start = optionalPoint(rt, options, line) ?? rt.live.spawnPosition(0);

  const peer = newID();
  const state = new PlayerState(peer, rt.joinCounter, profile.displayName, profile, true);
  rt.joinCounter++;
  state.body = playerSnapshot(peer, { profile, position: { ...start }, isNPC: true });
  state.home = { ...start };
  const health = options.get('health');
  if (health !== undefined) {
    state.maxHealth = Math.min(Math.max(number(health, 'health', line), 1), RuntimeLimits.maximumHealth);
    state.health = state.maxHealth;
  }
  const speed = options.get('speed');
  if (speed !== undefined) {
    state.movement.speed = Math.fround(Math.min(Math.max(number(speed, 'speed', line), 0), RuntimeLimits.maximumMovementMultiplier));
  }
  const team = options.get('team');
  if (team !== undefined && team !== null) state.team = prefix(displayText(team), 32);
  rt.states.set(peer, state);
  rt.rosterChanged = true;
  return rt.object(state);
}

// MARK: Blocks

function blockMember(rt: GameRuntime, object: ScriptObject, name: string, line: number): ScriptValue {
  // Through the index: a script looping over its blocks would otherwise search them all for each one.
  const index = rt.worldIndex;
  const id = rt.blockID(object);
  const entry = id ? index.entry(id) : undefined;
  if (!id || !entry) return name === 'name' ? object.displayName : null;
  const block = rt.world.blocks[entry.order];
  const position = entry.position;
  switch (name) {
    case 'name': return block.name;
    case 'id': return id.slice(0, 8);
    case 'position': return roundedVector(position);
    case 'x': return rounded(position.x);
    case 'y': return rounded(position.y);
    case 'z': return rounded(position.z);
    case 'size': return roundedVector(block.transform.scale);
    case 'rotation': return roundedVector(eulerDegrees32(block.transform.rotation));
    case 'color': return hexString(block.color);
    case 'material': return block.material;
    case 'shape': return block.shape;
    case 'visible': return block.isVisible;
    case 'solid': return block.hasCollision;
    case 'tags': return new ScriptList(block.tags.map((t) => t));
    case 'opacity': return block.color.a;
    case 'behavior': return block.behavior;
    case 'move': case 'move_to': return method(name, (a, l) => {
      let seconds: number;
      let offset: Vec3;
      if (name === 'move') {
        offset = vectorArgument(a, l, 'move');
        seconds = optionalNumber(a, toVector(arg(a, 0)) === null ? 3 : 1, 0, l);
      } else {
        offset = sub(point(rt, arg(a, 0), l), rt.live.worldPosition(id));
        seconds = optionalNumber(a, 1, 0, l);
      }
      moveBlock(rt, id, offset, Math.min(Math.max(seconds, 0), 600));
      return null;
    });
    case 'rotate': return method(name, (a, l) => {
      const turn = vectorArgument(a, l, 'rotate');
      changeBlock(rt, id, (b) => { b.transform = { ...b.transform, rotation: quatEulerDegrees32(f32v(add(eulerDegrees32(b.transform.rotation), turn))) }; });
      return null;
    });
    case 'destroy': return method(name, () => {
      if (rt.live.block(id)) rt.queue({ type: 'remove', blockID: id });
      return null;
    });
    case 'clone': return method(name, (_a, l) => {
      const original = rt.live.block(id);
      if (!original) return null;
      checkBlockLimit(rt, l);
      const copy: BlockData = structuredClone(original);
      copy.id = newID();
      rt.queue({ type: 'insert', block: copy });
      return rt.blockObject(copy.id);
    });
    default: {
      const part = partsBlockMember(rt, block, name);
      if (part !== undefined) return part;
      throw runtimeError(line, L('A block has no “{}”.', name));
    }
  }
}

function setBlockMember(rt: GameRuntime, object: ScriptObject, name: string, value: ScriptValue, line: number): void {
  const id = rt.blockID(object);
  if (!id) return;
  changeBlock(rt, id, (block) => applyBlockOption(rt, name, value, block, id, line));
}

const clampSize = (n: number) => Math.fround(Math.min(Math.max(n, 0.01), 2000));

/** One block property, shared by `b.color = …` and `create_block({color: …})`. */
function applyBlockOption(rt: GameRuntime, name: string, value: ScriptValue, block: BlockData, id: string | null, line: number): void {
  const t = block.transform;
  switch (name) {
    case 'name': block.name = prefix(displayText(value), 60); return;
    case 'position': {
      const target = point(rt, value, line);
      // A block inside another is placed relative to it.
      const parentOffset = id ? sub(rt.live.worldPosition(id), t.position) : v3();
      block.transform = { ...t, position: f32v(sub(target, parentOffset)) };
      return;
    }
    case 'x': case 'y': case 'z': {
      const n = Math.fround(number(value, name, line));
      block.transform = { ...t, position: { ...t.position, [name]: n } };
      return;
    }
    case 'size': {
      if (typeof value === 'number' && Number.isFinite(value)) {
        const s = clampSize(value);
        block.transform = { ...t, scale: v3(s, s, s) };
      } else {
        const s = vector(value, line);
        block.transform = { ...t, scale: v3(clampSize(s.x), clampSize(s.y), clampSize(s.z)) };
      }
      return;
    }
    case 'rotation': block.transform = { ...t, rotation: quatEulerDegrees32(vector(value, line)) }; return;
    case 'color': { const a = block.color.a; block.color = { ...color(value, line), a }; return; }
    case 'opacity': block.color = { ...block.color, a: Math.fround(Math.min(Math.max(number(value, name, line), 0), 1)) }; return;
    case 'material': {
      const text = displayText(value).toLowerCase();
      if (!(materialKinds as string[]).includes(text)) throw runtimeError(line, L('“material” is one of: {}.', materialKinds.join(', ')));
      block.material = text as MaterialKind;
      return;
    }
    case 'shape': {
      const text = displayText(value).toLowerCase();
      if (!(blockShapes as string[]).includes(text)) throw runtimeError(line, L('“shape” is one of: {}.', blockShapes.join(', ')));
      block.shape = text as BlockShape;
      return;
    }
    case 'visible': block.isVisible = isTruthy(value); return;
    case 'solid': block.hasCollision = isTruthy(value); return;
    case 'anchored': block.isAnchored = isTruthy(value); return;
    case 'behavior': {
      // Only a block with a behaviour reports `on touch`, so a script-made coin needs "trigger".
      const text = value === null ? 'none' : displayText(value).toLowerCase();
      if (!(blockBehaviors as string[]).includes(text)) throw runtimeError(line, L('“behavior” is one of: {}.', blockBehaviors.join(', ')));
      block.behavior = text as BlockBehavior;
      return;
    }
    case 'tags':
      if (!(value instanceof ScriptList)) throw runtimeError(line, L('“tags” needs a list, like ["coin"].'));
      block.tags = value.items.slice(0, 32).map((x) => prefix(displayText(x), 40));
      return;
    default:
      if (!setPartsBlockMember(rt, name, value, block, line)) throw runtimeError(line, L('A block’s “{}” cannot be set.', name));
  }
}

/** Changes a block and tells everyone, when it really changed. */
export function changeBlock(rt: GameRuntime, id: string, change: (block: BlockData) => void): void {
  const before = rt.live.block(id);
  if (!before) return;
  const block: BlockData = structuredClone(before);
  change(block);
  if (sameBlock(block, before)) return;
  rt.queue({ type: 'update', block });
}

function sameBlock(a: BlockData, b: BlockData): boolean {
  return JSON.stringify(a) === JSON.stringify(b);
}

export function moveBlock(rt: GameRuntime, id: string, offset: Vec3, seconds: number): void {
  const before = rt.live.block(id);
  if (!before) return;
  const block: BlockData = structuredClone(before);
  const from = { ...block.transform.position };
  block.transform.position = f32v(add(from, offset));
  if (!(seconds > 0)) {
    rt.travels.delete(id);
    rt.queue({ type: 'update', block });
    return;
  }
  rt.travels.set(id, { from, offset: { ...offset }, start: rt.clock, duration: seconds });
  // Everyone animates the move; the host's map takes the end position now,
  // and everyone else's copy gets it when the move is over.
  rt.machine.apply({ type: 'update', block });
  rt.pending.push(rt.broadcast({ type: 'move', blockID: id, offset: { ...offset }, duration: seconds }));
  rt.deferredUpdates.push({ due: rt.clock + seconds, blockID: id });
}

function checkBlockLimit(rt: GameRuntime, line: number): void {
  if (rt.world.blocks.length >= RuntimeLimits.maximumBlocks) {
    throw limitError(line, L('The world has too many blocks (the limit is {}).', RuntimeLimits.maximumBlocks));
  }
}

function createBlock(rt: GameRuntime, value: ScriptValue, line: number): ScriptValue {
  checkBlockLimit(rt, line);
  const options = optionsMap(value, line);
  const block = makeBlock({ name: 'Block' });
  block.transform.position = v3(0, 1, 0);
  // Hung from another block first: then `position` is measured from it.
  const parent = options.get('parent');
  if (parent !== undefined && parent !== null) {
    const parentID = parent instanceof ScriptObject ? rt.blockID(parent) : undefined;
    if (!parentID || !rt.live.block(parentID)) throw runtimeError(line, L('“parent” needs a block.'));
    block.parentID = parentID;
    block.transform.position = v3();
  }
  for (const key of options.keys) {
    if (key === 'parent') continue;
    const option = options.get(key);
    if (option === undefined) continue;
    applyBlockOption(rt, key, option, block, null, line);
  }
  rt.queue({ type: 'insert', block });
  return rt.blockObject(block.id);
}

// MARK: World and game

function worldMember(rt: GameRuntime, name: string, line: number): ScriptValue {
  const e = rt.world.environment;
  switch (name) {
    case 'gravity': return e.gravity;
    case 'sky': case 'sky_top': return hexString(e.skyTop);
    case 'sky_bottom': return hexString(e.skyBottom);
    case 'light': return e.ambientIntensity;
    case 'sun': return e.sunPitchDegrees;
    case 'sun_yaw': return e.sunYawDegrees;
    case 'ground': return e.showGroundPlane;
    case 'ground_color': return hexString(e.groundColor);
    case 'fall_height': return e.killPlaneHeight;
    default: {
      const part = partsWorldMember(rt, name);
      if (part !== undefined) return part;
      throw runtimeError(line, L('“world” has no “{}”.', name));
    }
  }
}

function setWorldMember(rt: GameRuntime, name: string, value: ScriptValue, line: number): void {
  const environment = structuredClone(rt.world.environment);
  switch (name) {
    case 'gravity': environment.gravity = Math.fround(Math.min(Math.max(number(value, name, line), -100), 0)); break;
    case 'sky': { const c = color(value, line); environment.skyTop = c; environment.skyBottom = { ...c }; break; }
    case 'sky_top': environment.skyTop = color(value, line); break;
    case 'sky_bottom': environment.skyBottom = color(value, line); break;
    case 'light': environment.ambientIntensity = Math.fround(Math.min(Math.max(number(value, name, line), 0), 3)); break;
    case 'sun': environment.sunPitchDegrees = Math.fround(number(value, name, line)); break;
    case 'sun_yaw': environment.sunYawDegrees = Math.fround(number(value, name, line)); break;
    case 'ground': environment.showGroundPlane = isTruthy(value); break;
    case 'ground_color': environment.groundColor = color(value, line); break;
    case 'fall_height': environment.killPlaneHeight = Math.fround(Math.min(Math.max(number(value, name, line), -10_000), 10_000)); break;
    default:
      if (!setPartsWorldMember(rt, name, value, environment, line)) throw runtimeError(line, L('“world.{}” cannot be set.', name));
  }
  if (JSON.stringify(environment) === JSON.stringify(rt.world.environment)) return;
  rt.queue({ type: 'environment', environment });
}

function gameMember(rt: GameRuntime, name: string, line: number): ScriptValue {
  switch (name) {
    case 'respawn_time': return rt.settings.respawnTime;
    case 'friendly_fire': return rt.settings.friendlyFire;
    case 'time': return rt.clock - rt.roundStartedAt;
    case 'round_over': return rt.isRoundOver;
    default: throw runtimeError(line, L('“game” has no “{}”.', name));
  }
}

function setGameMember(rt: GameRuntime, name: string, value: ScriptValue, line: number): void {
  switch (name) {
    case 'respawn_time': rt.settings.respawnTime = Math.min(number(value, name, line), 3600); return;
    case 'friendly_fire': rt.settings.friendlyFire = isTruthy(value); return;
    default: throw runtimeError(line, L('“game.{}” cannot be set.', name));
  }
}

// MARK: Screen GUI

/**
 * `ui_text("score", "Score: 0", {at: "top_left", size: 24})` and friends.
 * Calling one again with the same id updates it, keeping every option not given.
 */
function createUI(rt: GameRuntime, kind: UIKind, args: ScriptValue[], owner: PlayerState | null, line: number): ScriptValue {
  const id = uiID(arg(args, 0));
  if (!id || [...id].length > UILimits.maximumIDLength) {
    throw runtimeError(line, L('A screen item needs a short name first, like ui_text("score", …).'));
  }
  const existing = existingUI(rt, id, owner);
  const element: UIElement = existing ? { ...existing } : defaultElement(id, kind);
  element.kind = kind;
  let optionsIndex = 1;
  switch (kind) {
    case 'panel': break;
    case 'text': case 'button': case 'image': case 'input':
      if (args.length > 1 && !isOptions(args[1])) {
        element.text = shortText(args[1]);
        optionsIndex = 2;
      }
      break;
    case 'bar':
      if (args.length > 1 && !isOptions(args[1])) {
        element.value = number(args[1], 'ui_bar', line);
        optionsIndex = 2;
        if (args.length > 2 && !isOptions(args[2])) {
          const maximum = number(args[2], 'ui_bar', line);
          if (!(maximum > 0)) throw runtimeError(line, L('A bar’s maximum has to be more than 0.'));
          element.maximum = maximum;
          optionsIndex = 3;
        }
      }
      break;
  }
  if (optionsIndex < args.length) applyUIOptions(args[optionsIndex], element, line);
  showUI(rt, element, owner, line);
  return uiHandle(id, owner);
}

function setUI(rt: GameRuntime, args: ScriptValue[], owner: PlayerState | null, line: number): ScriptValue {
  const id = uiID(arg(args, 0));
  const existing = existingUI(rt, id, owner);
  if (!existing) throw runtimeError(line, L('There is no screen item called “{}”.', id));
  const element = { ...existing };
  if (args.length > 1) applyUIOptions(args[1], element, line);
  showUI(rt, element, owner, line);
  return uiHandle(id, owner);
}

const hexColor = (hex: string): ColorRGBA => colorFromHex(hex)!;
const white = (): ColorRGBA => ({ r: 1, g: 1, b: 1, a: 1 });

function defaultElement(id: string, kind: UIKind): UIElement {
  const e = uiElement(id, kind);
  switch (kind) {
    case 'panel':
      e.width = 320; e.height = 220; e.background = { r: 0, g: 0, b: 0, a: Math.fround(0.55) }; e.cornerRadius = 18;
      break;
    case 'text': e.color = white(); break;
    case 'button': e.color = white(); e.background = hexColor('#3B82F6'); e.fontSize = 20; e.bold = true; break;
    case 'image': e.text = 'star.fill'; e.color = white(); e.fontSize = 36; break;
    case 'bar':
      e.width = 200; e.height = 14; e.color = hexColor('#22D3EE'); e.background = { r: 0, g: 0, b: 0, a: Math.fround(0.4) }; e.cornerRadius = 7;
      break;
    case 'input': e.width = 260; e.color = white(); e.background = { r: 0, g: 0, b: 0, a: Math.fround(0.5) }; break;
  }
  return e;
}

const isOptions = (value: ScriptValue) => value instanceof ScriptMap && toVector(value) === null;

export function applyUIOptions(value: ScriptValue, element: UIElement, line: number): void {
  const options = optionsMap(value, line);
  for (const key of options.keys) {
    const option = options.get(key);
    if (option !== undefined) applyUIOption(key, option, element, line);
  }
}

const presetNames = () => Object.keys(uiPresets).sort().join(', ');

function applyUIOption(key: string, value: ScriptValue, e: UIElement, line: number): void {
  const finite = (what: string) => number(value, what, line);
  switch (key) {
    case 'at': {
      const preset = uiPresets[displayText(value).toLowerCase()];
      if (!preset) throw runtimeError(line, L('“at” is one of: {}.', presetNames()));
      placeUI(e, preset);
      return;
    }
    case 'x': e.x = finite(key); return;
    case 'y': e.y = finite(key); return;
    case 'pivot': {
      const preset = uiPresets[displayText(value).toLowerCase()];
      if (!preset) throw runtimeError(line, L('“pivot” is one of: {}.', presetNames()));
      e.pivotX = preset.x;
      e.pivotY = preset.y;
      return;
    }
    case 'dx': e.offsetX = finite(key); return;
    case 'dy': e.offsetY = finite(key); return;
    case 'w': case 'width': e.width = value === null ? undefined : Math.min(Math.max(finite(key), 0), 4000); return;
    case 'h': case 'height': e.height = value === null ? undefined : Math.min(Math.max(finite(key), 0), 4000); return;
    case 'color': e.color = value === null ? undefined : color(value, line); return;
    case 'bg': case 'background': e.background = value === null ? undefined : color(value, line); return;
    case 'size': {
      if (typeof value === 'number' && Number.isFinite(value)) {
        e.fontSize = Math.min(Math.max(value, 6), 300);
        return;
      }
      const named: Record<string, number> = { small: 14, medium: 18, large: 28, huge: 48 };
      const size = named[displayText(value).toLowerCase()];
      if (size === undefined) throw runtimeError(line, L('“size” is a number, or “small”, “medium”, “large” or “huge”.'));
      e.fontSize = size;
      return;
    }
    case 'bold': e.bold = isTruthy(value); return;
    case 'radius': e.cornerRadius = Math.min(Math.max(finite(key), 0), 1000); return;
    case 'opacity': e.opacity = Math.min(Math.max(finite(key), 0), 1); return;
    case 'visible': e.visible = isTruthy(value); return;
    case 'layer': e.layer = Math.trunc(Math.min(Math.max(finite(key), -1000), 1000)); return;
    case 'parent': {
      const parent = value === null ? '' : uiID(value);
      e.parent = !parent || parent === e.id ? undefined : parent;
      return;
    }
    case 'text': e.text = shortText(value); return;
    case 'value': e.value = finite(key); return;
    case 'max': {
      const maximum = finite(key);
      if (!(maximum > 0)) throw runtimeError(line, L('A bar’s maximum has to be more than 0.'));
      e.maximum = maximum;
      return;
    }
    default:
      throw runtimeError(line, L('A screen item has no “{}”. It can have: {}.', key, uiOptionNames.join(', ')));
  }
}

function existingUI(rt: GameRuntime, id: string, owner: PlayerState | null): UIElement | undefined {
  return owner ? owner.ui.get(id) ?? rt.globalUI.get(id) : rt.globalUI.get(id);
}

/** Shows an item to one player, or to everyone when `owner` is null. */
function showUI(rt: GameRuntime, element: UIElement, owner: PlayerState | null, line: number): void {
  const limit = UILimits.maximumElements;
  if (owner) {
    if (owner.isNPC) return;
    if (!owner.ui.has(element.id) && !rt.globalUI.has(element.id) && owner.ui.size + rt.globalUI.size >= limit) {
      throw limitError(line, L('Too many things on the screen (the limit is {}).', limit));
    }
    owner.ui.set(element.id, element);
    rt.send(owner, script({ kind: 'ui', element: { ...element } }));
  } else {
    if (!rt.globalUI.has(element.id)) {
      let busiest = 0;
      for (const s of rt.states.values()) busiest = Math.max(busiest, s.ui.size);
      if (!(rt.globalUI.size + busiest < limit)) throw limitError(line, L('Too many things on the screen (the limit is {}).', limit));
      rt.globalUIOrder.push(element.id);
    }
    rt.globalUI.set(element.id, element);
    rt.pending.push(rt.broadcast(script({ kind: 'ui', element: { ...element } })));
  }
}

function descendants(root: string, elements: Map<string, UIElement>): Set<string> {
  const found = new Set([root]);
  let grew = true;
  while (grew) {
    const before = found.size;
    for (const e of elements.values()) if (e.parent !== undefined && found.has(e.parent)) found.add(e.id);
    grew = found.size > before;
  }
  return found;
}

function removeUI(rt: GameRuntime, id: string, owner: PlayerState | null): void {
  // What sits inside a removed panel goes with it.
  if (owner) {
    for (const doomed of descendants(id, owner.ui)) owner.ui.delete(doomed);
    rt.send(owner, script({ kind: 'removeUI', id }));
  } else {
    const doomed = descendants(id, rt.globalUI);
    for (const gone of doomed) rt.globalUI.delete(gone);
    rt.globalUIOrder = rt.globalUIOrder.filter((x) => !doomed.has(x));
    rt.pending.push(rt.broadcast(script({ kind: 'removeUI', id })));
  }
}

function clearUI(rt: GameRuntime, owner: PlayerState | null): void {
  if (owner) {
    owner.ui.clear();
    // The client clears the lot, so what everyone sees is put back.
    rt.send(owner, script({ kind: 'clearUI' }));
    for (const id of rt.globalUIOrder) {
      const e = rt.globalUI.get(id);
      if (e) rt.send(owner, script({ kind: 'ui', element: { ...e } }));
    }
  } else {
    rt.globalUI.clear();
    rt.globalUIOrder = [];
    for (const s of rt.states.values()) s.ui.clear();
    rt.pending.push(rt.broadcast(script({ kind: 'clearUI' })));
  }
}

/** The id from a text or from a screen-item handle. */
function uiID(value: ScriptValue): string {
  if (value instanceof ScriptObject && value.kind === 'ui') {
    const bar = value.id.indexOf('|');
    return bar < 0 ? value.id : value.id.slice(bar + 1);
  }
  return displayText(value);
}

function uiHandle(id: string, owner: PlayerState | null): ScriptValue {
  return new ScriptObject('ui', `${owner?.peer ?? '*'}|${id}`, id);
}

function uiOwner(rt: GameRuntime, object: ScriptObject): { owner: PlayerState | null; id: string; known: boolean } {
  const bar = object.id.indexOf('|');
  if (bar < 0 || bar === object.id.length - 1 || bar === 0) return { owner: null, id: object.displayName, known: false };
  const head = object.id.slice(0, bar), id = object.id.slice(bar + 1);
  if (head === '*') return { owner: null, id, known: true };
  const owner = rt.states.get(head);
  return owner ? { owner, id, known: true } : { owner: null, id, known: false };
}

function uiMember(rt: GameRuntime, object: ScriptObject, name: string, line: number): ScriptValue {
  const { owner, id, known } = uiOwner(rt, object);
  const element = known ? existingUI(rt, id, owner) : undefined;
  if (!element) return name === 'id' ? id : null;
  switch (name) {
    case 'id': return element.id;
    case 'kind': return element.kind;
    case 'text': return element.text;
    case 'value': return element.value;
    case 'max': return element.maximum;
    case 'x': return element.x;
    case 'y': return element.y;
    case 'visible': return element.visible;
    case 'parent': return element.parent ?? null;
    case 'remove': return method(name, () => { removeUI(rt, id, owner); return null; });
    default: throw runtimeError(line, L('A screen item has no “{}”.', name));
  }
}

function setUIMember(rt: GameRuntime, object: ScriptObject, name: string, value: ScriptValue, line: number): void {
  const { owner, id, known } = uiOwner(rt, object);
  const existing = known ? existingUI(rt, id, owner) : undefined;
  if (!existing) return;
  const element = { ...existing };
  applyUIOption(name, value, element, line);
  showUI(rt, element, owner, line);
}

// MARK: Screen effects

function fadeEffect(args: ScriptValue[], line: number): ScriptEffect {
  const c = !args.length || args[0] === null ? undefined : color(args[0], line);
  const seconds = Math.min(Math.max(optionalNumber(args, 1, 0.5, line), 0), 60);
  return { kind: 'fade', color: c, seconds };
}

function shakeEffect(args: ScriptValue[], line: number): ScriptEffect {
  const strength = Math.min(Math.max(optionalNumber(args, 0, 0.3, line), 0), 5);
  const seconds = Math.min(Math.max(optionalNumber(args, 1, 0.4, line), 0), 30);
  return { kind: 'shake', strength: Math.fround(strength), seconds };
}

// MARK: Raycast

/** `raycast(from, direction, range)`: the first thing along a line, or nil. */
function raycast(rt: GameRuntime, args: ScriptValue[], line: number): ScriptValue {
  if (args.length < 2) throw runtimeError(line, L('“{}” needs {} values.', 'raycast', 2));
  const origin = point(rt, args[0], line);
  const from = characterArgument(rt, args, 0);
  if (from) origin.y += PlayerHitBody.eyeHeight * from.profile.height;
  const direction = vector(args[1], line);
  const range = Math.min(Math.max(optionalNumber(args, 2, 100, line), 0.1), 5000);
  const result = rt.cast(origin, direction, range, from?.peer ?? null);
  if (result.target.kind === 'nothing') return null;
  const map = new ScriptMap();
  map.set('point', roundedVector(result.point));
  map.set('distance', Math.fround(result.distance));
  if (result.target.kind === 'block') map.set('block', rt.blockObject(result.target.id));
  else {
    const state = rt.states.get(result.target.peer);
    if (state) map.set('player', rt.object(state));
  }
  return map;
}

// MARK: Timers and weapons

function addTimer(rt: GameRuntime, args: ScriptValue[], repeating: boolean, line: number): ScriptValue {
  const name = repeating ? 'every' : 'after';
  if (args.length < 2) throw runtimeError(line, L('“{}” needs {} values.', name, 2));
  let seconds = number(args[0], name, line);
  if (!(args[1] instanceof ScriptFunction || args[1] instanceof ScriptNative)) {
    throw runtimeError(line, L('“{}” needs a function to run, like func() … end.', name));
  }
  if (rt.timers.length >= RuntimeLimits.maximumTimers) {
    throw limitError(line, L('Too many timers at once (the limit is {}). Is “{}” inside “on tick”?', RuntimeLimits.maximumTimers, name));
  }
  if (repeating) seconds = Math.max(seconds, RuntimeLimits.minimumRepeatInterval);
  seconds = Math.max(seconds, 0);
  const id = rt.nextTimerID++;
  rt.timers.push({ id, due: rt.clock + seconds, interval: repeating ? seconds : null, callback: args[1], line });
  return id;
}

function defineWeapon(rt: GameRuntime, args: ScriptValue[], line: number): ScriptValue {
  const name = trimmedSpaces(displayText(arg(args, 0)));
  if (!name) throw runtimeError(line, L('A weapon needs a name.'));
  const key = name.toLowerCase();
  const presetCount = Object.keys(weaponPresets).length;
  if (!rt.weapons.has(key) && rt.weapons.size >= presetCount + RuntimeLimits.maximumCustomWeapons) {
    throw limitError(line, L('Too many weapons (the limit is {}).', RuntimeLimits.maximumCustomWeapons));
  }
  // Starts from the preset of the same model, so only what is different needs saying.
  const options = args.length > 1 ? optionsMap(args[1], line) : new ScriptMap();
  const modelOption = options.get('model');
  const modelName = modelOption !== undefined ? displayText(modelOption).toLowerCase() : rt.weapons.get(key)?.model ?? 'blaster';
  const spec = { ...(rt.weapons.get(key) ?? weaponPresets[modelName] ?? weaponSpec(name)) };
  spec.name = name;
  spec.model = weaponPresets[modelName] ? modelName : 'blaster';
  for (const option of options.keys) {
    const value = options.get(option) ?? null;
    switch (option) {
      case 'damage': spec.damage = number(value, 'damage', line); break;
      case 'rate': spec.fireRate = number(value, 'rate', line); break;
      case 'range': spec.range = Math.fround(number(value, 'range', line)); break;
      case 'ammo': spec.magazine = scriptInt(number(value, 'ammo', line)); break;
      case 'reload': spec.reloadTime = number(value, 'reload', line); break;
      case 'spread': spec.spread = Math.fround(number(value, 'spread', line)); break;
      case 'model': break;
      default:
        throw runtimeError(line, L('A weapon has no “{}”. It can have: {}.', option, 'damage, rate, range, ammo, reload, spread, model'));
    }
  }
  rt.weapons.set(key, clampedWeapon(spec));
  return name;
}

function weaponNamed(rt: GameRuntime, value: ScriptValue, line: number) {
  const name = displayText(value);
  const weapon = rt.weapons.get(name.toLowerCase());
  if (!weapon) {
    throw runtimeError(line, L('There is no weapon called “{}”. The weapons are: {}.', name, [...rt.weapons.keys()].sort().join(', ')));
  }
  return weapon;
}

// MARK: Places

/** Where a player, an NPC, a block or a `{x, y, z}` map is. */
export function point(rt: GameRuntime, value: ScriptValue, line: number): Vec3 {
  if (value instanceof ScriptObject) {
    const state = rt.character(value);
    const p = state ? rt.position(state) : null;
    if (p) return p;
    const id = rt.blockID(value);
    if (id) {
      const entry = rt.worldIndex.entry(id);
      return entry ? { ...entry.position } : rt.live.worldPosition(id);
    }
  } else if (value instanceof ScriptMap) {
    return vector(value, line);
  }
  throw runtimeError(line, L('That needs a player, a block or a position like {x: 0, y: 5, z: 0}, not {}.', typeName(value)));
}

/** Where `teleport` lands: on top of a block, at a character, a position, or three numbers. */
function destination(rt: GameRuntime, args: ScriptValue[], line: number): Vec3 {
  if (args.length >= 3) return vectorArgument(args, line, 'teleport');
  const value = arg(args, 0);
  if (value instanceof ScriptObject) {
    const id = rt.blockID(value);
    const entry = id ? rt.worldIndex.entry(id) : undefined;
    // A metre above the top face, as checkpoints do.
    if (entry) return v3(entry.position.x, entry.bounds.max.y + 1, entry.position.z);
  }
  return point(rt, value, line);
}

function optionalPoint(rt: GameRuntime, options: ScriptMap, line: number): Vec3 | null {
  const position = options.get('position');
  if (position !== undefined) return point(rt, position, line);
  if (options.get('x') === undefined && options.get('y') === undefined && options.get('z') === undefined) return null;
  return v3(
    optionalNumber([options.get('x') ?? null], 0, 0, line),
    optionalNumber([options.get('y') ?? null], 0, 2, line),
    optionalNumber([options.get('z') ?? null], 0, 0, line),
  );
}

export function characterArgument(rt: GameRuntime, args: ScriptValue[], index: number): PlayerState | undefined {
  const value = index < args.length ? args[index] : null;
  return value instanceof ScriptObject ? rt.character(value) : undefined;
}
