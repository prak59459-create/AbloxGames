// The real thing, when asked for (ABLOX_LIVE=1, and NODE_USE_ENV_PROXY=1
// behind a proxy): two browsers' worth of Ablox in this process, each
// signed in to Ablox's own Firebase database as its own anonymous user, one
// listing a room and the other playing in it through the real relay, under
// the real rules. Everything it made is removed at the end: the room, the
// relay and both sign-ins.
import { describe, expect, it } from 'vitest';
import './helpers';
import { blankWorld, script } from './runtimeHelpers';
import { defaultProfile } from '../src/core/model/avatar';
import { CloudSettings } from '../src/core/model/cloud';
import { v3 } from '../src/core/model/math';
import { playerSnapshot } from '../src/core/model/player';
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

const until = async (check: () => boolean, what: string, ms = 30000) => {
  const start = Date.now();
  while (!check()) {
    if (Date.now() - start > ms) throw new Error('timed out waiting for ' + what);
    await new Promise((r) => setTimeout(r, 50));
  }
};

describe.skipIf(!process.env.ABLOX_LIVE)('the real database', () => {
  it('lists a room, and another browser plays in it through the relay', { timeout: 120_000 }, async () => {
    const settings = new CloudSettings();
    settings.allowInternetPlay = true;
    const hostNet = new InternetRooms(settings, new MemoryStorage() as unknown as Storage);
    const guestNet = new InternetRooms(settings, new MemoryStorage() as unknown as Storage);
    const hostProfile = { ...defaultProfile(), displayName: 'Web Check' };
    const host = new PlaySession('A11A0000-0000-4000-8000-0000000000A1', hostProfile);
    const guest = new PlaySession('B22B0000-0000-4000-8000-0000000000B2', { ...defaultProfile(), displayName: 'Web Guest' });
    host.saveStore = null;
    guest.saveStore = null;
    const timings: Record<string, number> = {};
    const t0 = Date.now();
    try {
      await Promise.all([hostNet.start(), guestNet.start()]);
      expect(hostNet.state.kind).toBe('ready');
      expect(guestNet.state.kind).toBe('ready');
      timings.signIn = Date.now() - t0;

      const world = blankWorld();
      world.name = 'Ablox web check';
      world.scripts = [script('main', 'on chat(p, text)\n  chat(p.name + " said " + text)\nend')];
      const room = host.hostRoom(world, { capacity: 2 });
      const key = await hostNet.host(room, world, hostProfile);
      timings.listed = Date.now() - t0;

      let listed = null;
      for (let i = 0; i < 10 && !listed; i++) {
        listed = (await guestNet.refreshRooms()).find((r) => r.id === key) ?? null;
        if (!listed) await new Promise((r) => setTimeout(r, 500));
      }
      expect(listed).not.toBeNull();
      expect(listed!.code).toBe(room.roomCode);

      const joinStart = Date.now();
      guest.joinRoom(guestNet.route(listed!));
      await until(() => guest.role === 'joined', 'the guest to be in');
      timings.join = Date.now() - joinStart;
      expect(guest.world.name).toBe('Ablox web check');

      const chatStart = Date.now();
      guest.sendChat('hello');
      await until(() => guest.chatLog.some((c) => c.text === 'Web Guest said hello'), 'the script’s answer');
      timings.chatRoundTrip = Date.now() - chatStart;

      const moveStart = Date.now();
      guest.publishLocalTransform(playerSnapshot(guest.localPeerID, { position: v3(3, 1, 3) }));
      await until(() => host.otherPlayers.some((p) => p.position.x === 3), 'the guest moving at the host');
      timings.moveOneWay = Date.now() - moveStart;
      await until(() => guest.pingMilliseconds !== null || Date.now() - moveStart > 6000, 'a ping');
      timings.ping = guest.pingMilliseconds ?? -1;
      console.log('live timings (ms)', JSON.stringify(timings));
    } finally {
      guest.leave();
      host.leave();
      hostNet.stopHosting();
      await new Promise((r) => setTimeout(r, 5000));
      await hostNet.forget();
      await guestNet.forget();
    }
  });
});
