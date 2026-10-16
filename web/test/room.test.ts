// A room in the browser, end to end without a network: real sessions as the
// host and as guests, joined by in-memory pipes that carry exactly what the
// internet relay would — the TLS stream keyed by the room code, the
// packets, the game's script on the host — and every rule the iPad's host
// keeps: the world before the roster, chat under the host's name for the
// sender, only your own avatar, removal, a wrong code, the host closing.
import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import './helpers';
import { blankWorld, script } from './runtimeHelpers';
import { defaultProfile } from '../src/core/model/avatar';
import { v3 } from '../src/core/model/math';
import { playerSnapshot } from '../src/core/model/player';
import { useLanguageForTests } from '../src/i18n';
import type { RoomRoute } from '../src/net/client';
import { PacketCodec, PacketKind, encodeTransformPayload } from '../src/net/packets';
import type { BytePipe } from '../src/net/relay';
import { PlaySession } from '../src/play/session';

useLanguageForTests('en');

const hostID = 'AAAAAAAA-0000-4000-8000-00000000000A';
const guestID = 'BBBBBBBB-0000-4000-8000-00000000000B';
const thirdID = 'CCCCCCCC-0000-4000-8000-00000000000C';

function profile(name: string) {
  const p = defaultProfile();
  p.displayName = name;
  return p;
}

/** Two ends of a byte stream, cut into odd pieces and a little late, as a relay would deliver them. Like RelayPipe, it holds what comes before anyone listens. */
class MemoryPipe implements BytePipe {
  other!: MemoryPipe;
  private receiver: ((bytes: Uint8Array) => void) | null = null;
  private early: Uint8Array[] = [];
  private handlers: (() => void)[] = [];
  private closedFlag = false;

  get isClosed() { return this.closedFlag; }
  get onData() { return this.receiver ?? (() => {}); }
  set onData(h: (bytes: Uint8Array) => void) {
    this.receiver = h;
    for (const b of this.early.splice(0)) h(b);
  }

  write(bytes: Uint8Array) {
    if (this.closedFlag) return;
    const copy = bytes.slice();
    // Split at an odd place, so nothing relies on writes arriving whole.
    const cut = copy.length > 7 ? 7 : copy.length;
    setTimeout(() => { this.other.deliver(copy.subarray(0, cut)); if (cut < copy.length) this.other.deliver(copy.subarray(cut)); }, 1);
  }

  deliver(bytes: Uint8Array) {
    if (this.closedFlag) return;
    if (this.receiver) this.receiver(bytes); else this.early.push(bytes);
  }

  whenClosed(h: () => void) { if (this.closedFlag) h(); else this.handlers.push(h); }

  close() {
    if (this.closedFlag) return;
    this.closedFlag = true;
    for (const h of this.handlers.splice(0)) h();
    this.other.close();
  }
}

function pipePair(): [BytePipe, BytePipe] {
  const a = new MemoryPipe(), b = new MemoryPipe();
  a.other = b;
  b.other = a;
  return [a, b];
}

const until = async (check: () => boolean, what: string, ms = 8000) => {
  const start = Date.now();
  while (!check()) {
    if (Date.now() - start > ms) throw new Error('timed out waiting for ' + what);
    await new Promise((r) => setTimeout(r, 10));
  }
};

function routeTo(host: PlaySession, code?: string): RoomRoute {
  const room = host.room!;
  return {
    code: code ?? room.roomCode,
    salt: room.keySalt,
    open: async () => {
      const [hostEnd, guestEnd] = pipePair();
      void host.room!.accept(hostEnd);
      return guestEnd;
    },
  };
}

const world = () => {
  const w = blankWorld();
  w.name = 'Test Room';
  w.scripts = [script('main', [
    'on join(p)',
    '  p.message("Welcome " + p.name, 3)',
    '  p.give_item("Apple", 3, "🍎")',
    'end',
    'on chat(p, text)',
    '  if text == "hi" then',
    '    chat("Hello, " + p.name)',
    '  end',
    'end',
  ].join('\n'))];
  return w;
};

let sessions: PlaySession[] = [];
const session = (id: string, name: string) => {
  const s = new PlaySession(id, profile(name));
  s.saveStore = null;
  sessions.push(s);
  return s;
};

beforeEach(() => { sessions = []; });
afterEach(() => { for (const s of sessions) s.leave(); });

describe('a room in the browser', () => {
  it('lets a guest in: the world, everyone, the script’s welcome, chat both ways', async () => {
    const host = session(hostID, 'Hana');
    host.hostRoom(world());
    expect(host.role).toBe('hosting');
    expect(host.isSolo).toBe(false);
    expect(host.roomCode).toMatch(/^[A-Z2-9]{6}$/);

    const guest = session(guestID, 'Gus');
    guest.joinRoom(routeTo(host));
    expect(guest.status.kind).toBe('connecting');
    await until(() => guest.role === 'joined' && guest.people.length === 2, 'the guest to be in');
    expect(guest.status.kind).toBe('active');
    expect(guest.world.name).toBe('Test Room');
    expect(guest.world.blocks.length).toBe(host.world.blocks.length);
    await until(() => host.people.length === 2, 'the host to see the guest');
    expect(host.people.map((p) => p.profile.displayName).sort()).toEqual(['Gus', 'Hana']);
    await until(() => guest.scripted.inventory.some((i) => i.name === 'Apple' && i.count === 3), 'the script’s welcome');

    // Chat: the host passes the guest's line on under the name it knows them by, and its script answers.
    guest.sendChat('hi');
    await until(() => host.chatLog.some((c) => c.senderID === guestID && c.text === 'hi'), 'the guest’s line at the host');
    expect(host.chatLog.find((c) => c.senderID === guestID)!.senderName).toBe('Gus');
    await until(() => guest.chatLog.some((c) => c.text === 'Hello, Gus'), 'the script’s answer at the guest');
    expect(guest.chatLog.filter((c) => c.text === 'hi').length).toBe(1);
    host.sendChat('welcome!');
    await until(() => guest.chatLog.some((c) => c.senderID === hostID && c.text === 'welcome!'), 'the host’s line at the guest');

    // The room's own messages: ready and a whisper.
    guest.setReady(true);
    await until(() => host.roomState.ready.has(guestID), 'ready at the host');
    await until(() => guest.isReady, 'ready back at the guest');
    host.whisper(guestID, 'psst');
    await until(() => guest.chatLog.some((c) => c.privateWith === 'Hana' && c.text === 'psst'), 'the whisper');
  });

  it('passes everyone’s movement on, whoever counts their packets lower', async () => {
    const host = session(hostID, 'Hana');
    host.hostRoom(world());
    const a = session(guestID, 'Gus');
    a.joinRoom(routeTo(host));
    await until(() => a.role === 'joined', 'the first guest');
    // Gus sends a lot first, so his packet count is far ahead of the next guest's.
    for (let i = 0; i < 200; i++) a.publishLocalTransform(playerSnapshot(guestID, { position: v3(1, 1, i / 100) }));
    // That was a flood, which the host drops; a moment for Gus's budget to fill up again.
    await new Promise((r) => setTimeout(r, 1700));
    const b = session(thirdID, 'Cleo');
    b.joinRoom(routeTo(host));
    await until(() => b.role === 'joined' && a.people.length === 3, 'the second guest');

    b.publishLocalTransform(playerSnapshot(thirdID, { position: v3(5, 1, 5) }));
    a.publishLocalTransform(playerSnapshot(guestID, { position: v3(-3, 1, 2) }));
    b.publishLocalTransform(playerSnapshot(thirdID, { position: v3(6, 1, 6) }));
    await until(() => a.otherPlayers.find((p) => p.peerID === thirdID)?.position.x === 6, 'Cleo moving on Gus’s screen');
    await until(() => b.otherPlayers.find((p) => p.peerID === guestID)?.position.x === -3, 'Gus moving on Cleo’s screen');
    await until(() => host.otherPlayers.find((p) => p.peerID === thirdID)?.position.x === 6, 'Cleo moving at the host');
    host.publishLocalTransform(playerSnapshot(hostID, { position: v3(9, 1, 9) }));
    await until(() => b.otherPlayers.find((p) => p.peerID === hostID)?.position.x === 9, 'the host moving on Cleo’s screen');
  });

  it('keeps each avatar its owner’s: a guest cannot move someone else', async () => {
    const host = session(hostID, 'Hana');
    host.hostRoom(world());
    const guest = session(guestID, 'Gus');
    guest.joinRoom(routeTo(host));
    await until(() => guest.role === 'joined', 'the guest');
    // Sneak a packet in claiming to be the host's avatar.
    const client = (guest as unknown as { client: { link: { sendPacket(p: unknown): void } } }).client;
    const codec = new PacketCodec(guestID);
    client.link.sendPacket(codec.encode(PacketKind.playerTransform, encodeTransformPayload({ peerID: hostID, position: v3(500, 1, 500), yawDegrees: 0, velocity: v3(), isGrounded: true })));
    guest.publishLocalTransform(playerSnapshot(guestID, { position: v3(2, 1, 2) }));
    await until(() => host.otherPlayers.find((p) => p.peerID === guestID)?.position.x === 2, 'the guest’s own move');
    expect(host.localHost!.game.players.get(hostID)!.position.x).not.toBe(500);
  });

  it('turns away the wrong code, with a message that says so', async () => {
    const host = session(hostID, 'Hana');
    host.hostRoom(world());
    const guest = session(guestID, 'Gus');
    const wrong = host.roomCode === 'ABCDEF' ? 'ABCDEG' : 'ABCDEF';
    guest.joinRoom(routeTo(host, wrong));
    await until(() => guest.status.kind === 'error', 'the refusal', 15000);
    expect((guest.status as { text: string }).text.toLowerCase()).toContain('room code');
    expect(host.people.length).toBe(1);
  });

  it('asks the host first when the room asks, and takes a guest out', async () => {
    const host = session(hostID, 'Hana');
    host.hostRoom(world(), { needsApproval: true });
    const guest = session(guestID, 'Gus');
    guest.joinRoom(routeTo(host));
    await until(() => host.joinRequests.length === 1, 'the request');
    expect(host.joinRequests[0].name).toBe('Gus');
    await until(() => guest.isWaitingForHost, 'waiting at the door');
    host.answerJoinRequest(host.joinRequests[0], true);
    await until(() => guest.role === 'joined', 'let in');

    host.removeFromRoom(guestID);
    await until(() => guest.status.kind === 'error', 'taken out');
    expect((guest.status as { text: string }).text).toBe('The host took you out of this room.');
    await until(() => host.people.length === 1, 'gone from the host');
  });

  it('tells guests when the host closes the room, and does not try to come back', async () => {
    const host = session(hostID, 'Hana');
    host.hostRoom(world());
    const guest = session(guestID, 'Gus');
    guest.joinRoom(routeTo(host));
    await until(() => guest.role === 'joined', 'the guest');
    host.leave();
    await until(() => guest.status.kind === 'error', 'the room closing');
    expect((guest.status as { text: string }).text).toBe('The host closed the world.');
  });

  it('gets a dropped guest back in, with the world kept on screen', async () => {
    const host = session(hostID, 'Hana');
    host.hostRoom(world());
    const guest = session(guestID, 'Gus');
    let pipes: BytePipe[] = [];
    const route: RoomRoute = {
      code: host.room!.roomCode, salt: host.room!.keySalt,
      open: async () => {
        const [h, g] = pipePair();
        void host.room!.accept(h);
        pipes.push(g);
        return g;
      },
    };
    guest.joinRoom(route);
    await until(() => guest.role === 'joined', 'the guest');
    // The line drops (Wi-Fi, a sleeping laptop).
    pipes[0].close();
    await until(() => guest.status.kind === 'reconnecting', 'reconnecting');
    expect(guest.world.name).toBe('Test Room');
    await until(() => guest.status.kind === 'active' && pipes.length === 2, 'back in', 15000);
    await until(() => host.people.length === 2, 'the host to have them once');
    expect(host.people.filter((p) => p.peerID === guestID).length).toBe(1);
    pipes = [];
  });

  it('opens a game being played alone, as it is', async () => {
    const host = session(hostID, 'Hana');
    host.startSolo(world());
    expect(host.isSolo).toBe(true);
    const room = host.openRoom()!;
    expect(room).not.toBeNull();
    expect(host.isSolo).toBe(false);
    host.setPaused(true);
    expect(host.isPaused).toBe(false);
    const guest = session(guestID, 'Gus');
    guest.joinRoom(routeTo(host));
    await until(() => guest.role === 'joined' && guest.people.length === 2, 'the guest');
  });

  it('takes everyone on to another game together (a party), under a new code', async () => {
    const host = session(hostID, 'Hana');
    host.hostRoom(world());
    const firstCode = host.roomCode;
    const a = session(guestID, 'Gus');
    const b = session(thirdID, 'Cleo');
    // Where a moved room is found: the lobby, which here is the host itself.
    let lookedFor = '';
    for (const g of [a, b]) {
      g.findMovedRoom = async (move) => {
        lookedFor = move.roomCode;
        return host.room && host.roomCode === move.roomCode ? routeTo(host) : null;
      };
      g.joinRoom(routeTo(host));
    }
    await until(() => a.role === 'joined' && b.role === 'joined' && host.people.length === 3, 'both guests');

    const next = blankWorld();
    next.name = 'Second Game';
    next.id = 'SECOND00-0000-4000-8000-000000000002';
    expect(host.moveRoomTo(next)).toBe(true);
    expect(host.role).toBe('hosting');
    expect(host.world.name).toBe('Second Game');
    expect(host.roomCode).not.toBe(firstCode);
    await until(() => a.status.kind === 'reconnecting' || a.world.name === 'Second Game', 'the guest to be told');
    await until(() => a.world.name === 'Second Game' && a.role === 'joined' && a.status.kind === 'active', 'Gus in the next game', 15000);
    await until(() => b.world.name === 'Second Game' && b.role === 'joined' && b.status.kind === 'active', 'Cleo in the next game', 15000);
    expect(lookedFor).toBe(host.roomCode);
    // Let straight in: they had been let in before.
    await until(() => host.people.length === 3 && a.people.length === 3, 'everyone together again');
    expect(host.joinRequests).toEqual([]);
  });

  it('says a party move is not a hand-over', async () => {
    const host = session(hostID, 'Hana');
    host.hostRoom(world());
    const guest = session(guestID, 'Gus');
    guest.findMovedRoom = async () => null;
    guest.joinRoom(routeTo(host));
    await until(() => guest.role === 'joined', 'the guest');
    host.moveRoomTo(blankWorld());
    await until(() => guest.status.kind === 'reconnecting', 'moving');
    expect((guest.status as { text: string }).text).toBe('Going on to the next game with Hana…');
  });
});
