// The game runtime's fixed numbers and names — GameRuntime.swift and the
// lists at the top of GameRuntimeAPI.swift, GameRuntimeParts.swift and
// GameRuntimeHelpers.swift.

/** The handlers a script can write. Anything else after `on` is a typo. */
export const runtimeEvents = [
  'start', 'tick', 'join', 'leave', 'touch', 'tap', 'fire', 'hit', 'hit_block', 'death', 'respawn', 'button', 'input', 'chat',
  'loaded', 'emote', 'use', 'choice', 'buy', 'countdown',
] as const;
export type RuntimeEvent = (typeof runtimeEvents)[number];

/** Fuses, not rules: far beyond what a game needs, there to stop a runaway script. */
export const RuntimeLimits = {
  maximumTimers: 1000,
  minimumRepeatInterval: 0.05,
  maximumCustomWeapons: 200,
  touchInterval: 0.5,
  maximumHealth: 1_000_000_000,
  maximumMovementMultiplier: 10,
  maximumNPCs: 100,
  maximumBlocks: 20_000,
  maximumCustomValues: 1000,
  maximumSize: 10,
  minimumSize: 0.2,
} as const;

export interface RuntimeSettings { respawnTime: number; friendlyFire: boolean }
export const defaultSettings = (): RuntimeSettings => ({ respawnTime: 3, friendlyFire: false });

export const partsAPINames = ['particles', 'music', 'speak', 'countdown', 'leaderboard', 'show_leaderboard', 'leaderboard_top'];
export const partsMemberNames = [
  'give_item', 'take_item', 'has_item', 'items', 'clear_items', 'dialog', 'close_dialog',
  'shop', 'close_shop', 'waypoint', 'music', 'speak', 'countdown', 'show_leaderboard', 'particles', 'vehicle',
];
export const partsWorldMemberNames = ['weather', 'time', 'day_length', 'sky_style', 'effect', 'shadows', 'music'];
export const helperAPINames = [
  'nearest_player', 'players_near', 'random_player', 'team_players', 'ranking', 'alive_players', 'nearest_block', 'blocks_near', 'today',
];

export const gameAPINames = [
  'game', 'world', 'players', 'npcs', 'find_player', 'block', 'blocks', 'create_block', 'create_npc',
  'distance', 'raycast', 'time', 'after', 'every', 'cancel',
  'announce', 'sound', 'chat', 'fade', 'shake', 'end_round', 'restart_round', 'weapon',
  'ui_text', 'ui_button', 'ui_panel', 'ui_image', 'ui_bar', 'ui_input', 'ui_set', 'ui_remove', 'ui_clear',
  ...partsAPINames, ...helperAPINames,
];

export const characterMemberNames = [
  'name', 'id', 'is_npc', 'health', 'max_health', 'alive', 'score', 'team',
  'position', 'x', 'y', 'z', 'yaw', 'look', 'velocity',
  'weapon', 'ammo', 'speed', 'jump', 'gravity', 'frozen',
  'color', 'head_color', 'leg_color', 'size', 'hat', 'ride', 'ride_color', 'visible',
  'give', 'take', 'reload', 'teleport', 'damage', 'heal', 'kill', 'respawn', 'launch', 'look_at',
];

export const playerOnlyMemberNames = [
  'camera', 'camera_distance', 'fov', 'controls', 'default_ui', 'saved', 'save',
  'camera_look', 'camera_reset', 'message', 'sound', 'chat', 'fade', 'shake',
  'ui_text', 'ui_button', 'ui_panel', 'ui_image', 'ui_bar', 'ui_input', 'ui_set', 'ui_remove', 'ui_clear',
  ...partsMemberNames,
];

/** Names the API took after worlds already used them for their own data. */
export const laterMemberNames = new Set(partsMemberNames);

export const npcOnlyMemberNames = ['move_to', 'follow', 'stop', 'jump_now', 'shoot', 'say', 'destroy'];

export const blockMemberNames = [
  'name', 'id', 'position', 'x', 'y', 'z', 'size', 'rotation', 'color', 'material', 'shape',
  'visible', 'solid', 'tags', 'opacity', 'behavior', 'move', 'move_to', 'rotate', 'destroy', 'clone',
  'particles', 'image', 'label', 'label_height', 'label_size', 'label_range', 'animation', 'animation_speed', 'parent',
];

export const worldMemberNames = [
  'gravity', 'sky', 'sky_top', 'sky_bottom', 'light', 'sun', 'sun_yaw', 'ground', 'ground_color', 'fall_height', ...partsWorldMemberNames,
];

export const uiOptionNames = [
  'at', 'x', 'y', 'pivot', 'dx', 'dy', 'w', 'h', 'color', 'bg', 'size', 'bold', 'radius',
  'opacity', 'visible', 'layer', 'parent', 'text', 'value', 'max',
];
