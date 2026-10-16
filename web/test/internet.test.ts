// Internet rooms through a Firebase in memory (fakeFirebase.ts): two
// browsers, each signed in on its own, one listing a room and passing its
// game through the relay, the other finding it in the list and playing in
// it — with the database's rules enforced, so every write the relay makes is
// one the real database would take.
import { afterEach, describe, expect, it } from 'vitest';
import './helpers';
import { blankWorld, script } from './runtimeHelpers';
import { FakeFirebase } from './fakeFirebase';
import { defaultProfile } from '../src/core/model/avatar';
import { CloudSettings } from '../src/core/model/cloud';
import { colorFromHex } from '../src/core/model/color';
import { v3 } from '../src/core/model/math';
import { playerSnapshot } from '../src/core/model/player';
import { makeBlock, placed } from '../src/core/model/world';
import { useLanguageForTests } from '../src/i18n';
import { InternetRooms } from '../src/net/internet';
import { PlaySession } from '../src/play/session';

useLanguageForTests('en');

class MemoryStorage {
  private map = new Map<string, string>();
  get length() { return this.map.size; }
  key(i: number) { return [...this.map.keys()][i] ?? null; }
  getItem(k: string) { return this.map.get(k) ?? null; }
  setItem(k: string, v: string) { this.map.set(k, String(v)); }
  removeItem(k: string) { this.map.delete(k); }
  clear() { this.map.clear(); }
}

const until = async (check: () => boolean, what: string, ms = 15000) => {
  const start = Date.now();
  while (!check()) {
    if (Date.now() - start > ms) throw new Error('timed out waiting for ' + what);
    await new Promise((r) => setTimeout(r, 15));
  }
};

const allowed = () => {
  const s = new CloudSettings();
  s.allowInternetPlay = true;
  return s;
};

function profile(name: string) {
  const p = defaultProfile();
  p.displayName = name;
  return p;
}

let cleanup: (() => void)[] = [];
afterEach(() => { for (const c of cleanup.splice(0)) c(); });

function browser(fake: FakeFirebase, id: string, name: string, settings = allowed()) {
  const internet = new InternetRooms(settings, new MemoryStorage() as unknown as Storage, fake.fetch);
  const session = new PlaySession(id, profile(name));
  session.saveStore = null;
  session.findMovedRoom = (move) => internet.findMovedRoom(move);
  cleanup.push(() => { session.leave(); internet.stop(); });
  return { internet, session };
}

/** A world big enough that its snapshot goes through the relay in several pieces. */
function bigWorld() {
  const blocks = [];
  for (let i = 0; i < 1800; i++) {
    blocks.push(makeBlock({ name: 'Brick ' + i, transform: placed(v3((i % 40) * 2, 0.5, Math.floor(i / 40) * 2), v3(1, 1, 1)), color: colorFromHex('#A855F7')!, tags: ['wall', 'n' + i] }));
  }
  const w = blankWorld(blocks);
  w.name = 'Brick Town';
  w.scripts = [script('main', 'on join(p)\n  p.give_item("Key", 1, "🔑")\nend\non chat(p, text)\n  chat(p.name + " said " + text)\nend')];
  return w;
}

describe('internet rooms', () => {
  it('starts off: nothing is sent until a grown-up allows it', async () => {
    const fake = new FakeFirebase();
    let calls = 0;
    const counting = (input: string, init?: RequestInit) => { calls++; return fake.fetch(input, init); };
    const internet = new InternetRooms(new CloudSettings(), new MemoryStorage() as unknown as Storage, counting);
    expect(internet.allowsInternetPlay).toBe(false);
    await expect(internet.refreshRooms()).rejects.toThrow();
    await internet.start();
    expect(calls).toBe(0);
    expect(internet.state.kind).toBe('off');
  });

  it('lists a browser’s room, and another browser plays in it through the relay', async () => {
    const fake = new FakeFirebase();
    const a = browser(fake, 'AAAAAAAA-0000-4000-8000-00000000000A', 'Hana');
    const b = browser(fake, 'BBBBBBBB-0000-4000-8000-00000000000B', 'Gus');
    const world = bigWorld();

    const room = a.session.hostRoom(world);
    const key = await a.internet.host(room, world, a.session.profile);
    expect(a.internet.hostedRoom).toBe(key);

    const rooms = await b.internet.refreshRooms();
    expect(rooms.length).toBe(1);
    expect(rooms[0]).toMatchObject({ id: key, hostName: 'Hana', world: 'Brick Town', players: 1, capacity: 8, code: room.roomCode, salt: room.keySalt });
    // The host does not see its own room.
    expect(await a.internet.refreshRooms()).toEqual([]);

    b.session.joinRoom(b.internet.route(rooms[0]));
    await until(() => b.session.role === 'joined', 'the guest to be in', 30000);
    expect(b.session.world.blocks.length).toBe(world.blocks.length);
    // The world came in several pieces.
    expect(fake.writes.filter((w) => w.includes('/down/')).length).toBeGreaterThan(2);
    await until(() => b.session.scripted.inventory.some((i) => i.name === 'Key'), 'the welcome');

    b.session.sendChat('hello');
    await until(() => b.session.chatLog.some((c) => c.text === 'Gus said hello'), 'the script answering through the relay');
    b.session.publishLocalTransform(playerSnapshot(b.session.localPeerID, { position: v3(4, 1, 4) }));
    await until(() => a.session.otherPlayers.some((p) => p.position.x === 4), 'the guest moving on the host');
    a.session.publishLocalTransform(playerSnapshot(a.session.localPeerID, { position: v3(-7, 1, 3) }));
    await until(() => b.session.otherPlayers.some((p) => p.position.x === -7), 'the host moving on the guest');

    // The list says how full the room is, soon after someone comes in.
    await until(() => (fake.tree as any)?.lobby?.[key]?.players === 2, 'the listing to count the guest', 8000);

    // Read pieces are cleared as they go: nothing piles up in the database.
    await new Promise((r) => setTimeout(r, 300));
    const relay = (fake.tree as any)?.relay?.[key];
    const waiting = Object.values(relay?.up ?? {}).concat(Object.values(relay?.down ?? {})).reduce((n: number, link: any) => n + Object.keys(link ?? {}).length, 0);
    expect(waiting).toBeLessThan(6);
    expect(fake.realRefusals).toEqual([]);

    // The guest leaves: their link goes, and the host sees them go.
    b.session.leave();
    await until(() => a.session.people.length === 1, 'the host to see the guest leave');
    await until(() => Object.keys((fake.tree as any)?.relay?.[key]?.links ?? {}).length === 0, 'the link to be removed');

    // The host closes: the room leaves the list, and the relay is cleared.
    a.session.leave();
    a.internet.stopHosting();
    await until(() => !(fake.tree as any)?.lobby?.[key] && !(fake.tree as any)?.relay?.[key], 'the room to be gone');
    expect(fake.realRefusals).toEqual([]);
  });

  it('finds a room that moved to a guest, under the same code', async () => {
    const fake = new FakeFirebase();
    const a = browser(fake, 'AAAAAAAA-0000-4000-8000-00000000000A', 'Hana');
    const b = browser(fake, 'BBBBBBBB-0000-4000-8000-00000000000B', 'Gus');
    const c = browser(fake, 'CCCCCCCC-0000-4000-8000-00000000000C', 'Cleo');
    for (const x of [b, c]) x.session.onHosting = (room) => { void x.internet.host(room, x.session.world, x.session.profile); };
    const world = blankWorld();
    world.name = 'Moving Day';
    const room = a.session.hostRoom(world);
    await a.internet.host(room, world, a.session.profile);
    const [listed] = await b.internet.refreshRooms();
    b.session.joinRoom(b.internet.route(listed));
    await until(() => b.session.role === 'joined', 'Gus in');
    c.session.joinRoom(c.internet.route(listed));
    await until(() => c.session.role === 'joined' && a.session.people.length === 3, 'Cleo in');

    // Hana leaves, handing the room on: to the first in the list, by name, as the iPads do (Cleo).
    expect(a.session.handOverAndLeave()).toBe(true);
    a.internet.stopHosting();
    await until(() => c.session.role === 'hosting', 'Cleo to be the host');
    expect(c.session.roomCode).toBe(listed.code);
    await until(() => b.session.role === 'joined' && b.session.status.kind === 'active' && c.session.people.length === 2, 'Gus to follow the room', 30000);
    expect(b.session.world.name).toBe('Moving Day');
    // Hana's listing went; Cleo's took its place.
    await until(() => Object.keys((fake.tree as any)?.lobby ?? {}).length === 1, 'one listing');
    expect(fake.realRefusals).toEqual([]);
  });
});

describe('signing in once', () => {
  it('signs in once however often it is asked while it is signing in, even by its own listeners', async () => {
    const fake = new FakeFirebase();
    let signUps = 0;
    const counting = (input: string, init?: RequestInit) => {
      if (input.includes('accounts:signUp')) signUps++;
      return fake.fetch(input, init);
    };
    const internet = new InternetRooms(allowed(), new MemoryStorage() as unknown as Storage, counting);
    // A page that asks for the list whenever it is told something changed.
    let told = 0;
    const stopListening = internet.subscribe(() => { if (++told < 6) void internet.refreshRooms().catch(() => {}); });
    await Promise.all([internet.start(), internet.refreshRooms(), internet.start()]);
    await new Promise((r) => setTimeout(r, 200));
    expect(signUps).toBe(1);
    expect(internet.state.kind).toBe('ready');
    stopListening();
    internet.stop();
  });
});
