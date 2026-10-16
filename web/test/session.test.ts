// Playing alone in the browser, end to end without a screen: a world with
// rules and a script, through the same host a room would use, into the
// session the play screen reads.
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { blankWorld, script } from './runtimeHelpers';
import { defaultProfile } from '../src/core/model/avatar';
import { colorFromHex } from '../src/core/model/color';
import { v3 } from '../src/core/model/math';
import { eventRule } from '../src/core/model/rules';
import { makeBlock, placed } from '../src/core/model/world';
import { PlaySession, gamePeerID, saveStorageID } from '../src/play/session';

const me = 'AAAAAAAA-0000-0000-0000-00000000000A';

class MemoryStorage {
  private map = new Map<string, string>();
  get length() { return this.map.size; }
  key(i: number) { return [...this.map.keys()][i] ?? null; }
  getItem(k: string) { return this.map.get(k) ?? null; }
  setItem(k: string, v: string) { this.map.set(k, String(v)); }
  removeItem(k: string) { this.map.delete(k); }
  clear() { this.map.clear(); }
}

function profile(name = 'Mika') {
  const p = defaultProfile();
  p.displayName = name;
  return p;
}

beforeEach(() => {
  vi.useFakeTimers({ toFake: ['setInterval', 'clearInterval', 'setTimeout', 'clearTimeout', 'performance', 'Date', 'queueMicrotask'] });
  (globalThis as unknown as { localStorage: MemoryStorage }).localStorage = new MemoryStorage();
});

afterEach(() => {
  vi.useRealTimers();
});

describe('playing alone', () => {
  it('starts the round, places us at the spawn and shows what the script puts up', () => {
    const world = blankWorld();
    world.scripts = [script('main', [
      'on join(p)',
      '  announce("Welcome " + p.name, 3)',
      '  ui_text("score", "Coins: 0", {x: 0.5, y: 0.1})',
      '  p.health = 80',
      'end',
    ].join('\n'))];
    const session = new PlaySession(me, profile());
    session.startSolo(world);
    expect(session.role).toBe('hosting');
    expect(session.isSolo).toBe(true);
    expect(session.people.map((p) => p.profile.displayName)).toEqual(['Mika']);
    expect(session.announcement?.message).toBe('Welcome Mika');
    expect(session.scripted.ui.map((e) => e.text)).toEqual(['Coins: 0']);
    const effects = session.drainEffects();
    expect(effects[0]).toEqual({ type: 'teleportPlayer', position: expect.anything() });
    expect(session.drainEffects()).toEqual([]);
    expect(session.scriptLog).toEqual([]);
    session.leave();
  });

  it('runs rules from touches, keeps the score and the chat, and the banner goes', () => {
    const coin = makeBlock({ name: 'Coin', transform: placed(v3(3, 0.5, 0), v3(0.6, 0.6, 0.6)), color: colorFromHex('#FFD54F')!, behavior: 'collectible', scoreValue: 1 });
    const world = blankWorld([coin]);
    world.rules = [eventRule({ name: 'hello', trigger: { type: 'blockTouched', blockID: coin.id }, actions: [{ type: 'announce', message: 'Got it!', duration: 2 }] })];
    world.scripts = [script('main', 'on chat(p, text)\n  if text == "hi" then\n    chat("Hello, " + p.name)\n  end\nend')];
    const session = new PlaySession(me, profile());
    session.startSolo(world);
    session.drainEffects();
    session.report(coin.id, 'touched');
    expect(session.announcement?.message).toBe('Got it!');
    const effects = session.drainEffects();
    expect(effects.some((e) => e.type === 'playSound' && e.name === 'collect')).toBe(true);
    expect(session.localPlayer?.score).toBe(1);
    expect(session.live.block(coin.id)?.isVisible).toBe(false);

    session.sendChat('  hi  ');
    expect(session.chatLog.map((c) => [c.senderName, c.text])).toEqual([['Mika', 'hi'], ['Game', 'Hello, Mika']]);
    expect(session.chatLog[1].senderID).toBe(gamePeerID);

    vi.advanceTimersByTime(2500);
    expect(session.announcement).toBeNull();
    expect(session.messageLog.map((m) => m.text)).toEqual(['Got it!', 'Hello, Mika']);
    session.leave();
  });

  it('filters and tidies chat on arrival', () => {
    const session = new PlaySession(me, profile());
    session.startSolo(blankWorld());
    session.sendChat('you are STUPID call 090-1234-5678');
    // Masked, then tidied as the iPad does: the run of asterisks is squashed too.
    expect(session.chatLog[0].text).toBe('you are *** call •••');
    expect(session.chatLog[0].wasFiltered).toBe(true);
    session.leave();
  });

  it('ticks timers ten times a second, and stops the clock while paused', () => {
    const world = blankWorld();
    world.scripts = [script('main', 'let count = 0\non start()\n  every(1, func()\n    count = count + 1\n    print(count)\n  end)\nend')];
    const session = new PlaySession(me, profile());
    session.startSolo(world);
    vi.advanceTimersByTime(3050);
    expect(session.scriptLog.map((l) => l.text)).toEqual(['1', '2', '3']);
    session.setPaused(true);
    vi.advanceTimersByTime(5000);
    expect(session.scriptLog.length).toBe(3);
    session.setPaused(false);
    vi.advanceTimersByTime(1000);
    expect(session.scriptLog.map((l) => l.text)).toEqual(['1', '2', '3', '4']);
    session.leave();
  });

  it('keeps what a game saves, in this browser, by slot', () => {
    const world = blankWorld();
    world.scripts = [script('main', [
      'on loaded(p)',
      '  let seen = p.saved.visits or 0',
      '  p.save("visits", seen + 1)',
      '  announce("Visit " + (seen + 1), 2)',
      'end',
    ].join('\n'))];
    const first = new PlaySession(me, profile());
    first.startSolo(world);
    vi.advanceTimersByTime(1500);
    first.leave();

    const second = new PlaySession(me, profile());
    second.startSolo(world);
    expect(second.announcement?.message).toBe('Visit 2');
    second.leave();

    const other = new PlaySession(me, profile());
    other.saveSlotFor = () => 2;
    other.startSolo(world);
    expect(other.announcement?.message).toBe('Visit 1');
    other.leave();
    expect(saveStorageID(world.id, 1)).toBe(world.id);
    expect(saveStorageID(world.id, 2)).not.toBe(world.id);
    expect(saveStorageID(world.id, 2)).toMatch(/^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$/);
  });

  it('reports script problems to the player who can fix them', () => {
    const world = blankWorld();
    world.scripts = [script('main', 'on start()\n  nothing_here()\nend')];
    const session = new PlaySession(me, profile());
    session.startSolo(world);
    expect(session.scriptLog.some((l) => l.isError)).toBe(true);
    session.leave();
  });
});
