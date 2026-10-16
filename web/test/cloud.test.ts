// CloudTests.swift, NetworkSafetyTests.swift, ReconnectionTests.swift and
// RoomCodeFormatTests.swift: the internet's plain data, how much a guest may
// send, and getting back in after a drop.
import { describe, expect, it } from 'vitest';
import './helpers';
import {
  CloudConfig, CloudEventParser, CloudIDs, CloudMirror, CloudPath, CloudSettings, RelayInbox, RelayOutbox, cleanedProfile,
  decodeCloudRoom, encodeCloudRoom, isPublicOnRouter, jsonObject, jsonPatching, jsonSetting, makeCloudRoom, profileIsOnline,
  roomIsFresh, roomStaleAfter, type CloudEvent, type Json,
} from '../src/core/model/cloud';
import {
  AttemptLimiter, Disconnect, PacketBudget, ReconnectCoordinator, ReconnectPolicy, RoomCode, isRetryable, reasonMessage,
  roomCodeAlphabet, roomCodeNeverUsed, type DisconnectReason,
} from '../src/core/model/reliability';
import { defaultProfile } from '../src/core/model/avatar';
import { AbloxProtocol } from '../src/net/packets';
import { useLanguageForTests } from '../src/i18n';

useLanguageForTests('en');

describe('settings', () => {
  it('accepts only a Firebase database', () => {
    expect(new CloudConfig('https://ablox-kids-default-rtdb.asia-southeast1.firebasedatabase.app/', 'AIzaSyA1234567890abcdefghijklmnopqrstu').isUsable).toBe(true);
    expect(new CloudConfig('https://ablox-kids.firebaseio.com', 'AIzaSyA1234567890abcdefghij').isUsable).toBe(true);
    expect(new CloudConfig('http://ablox.firebaseio.com', 'AIzaSyA1234567890abcdefghij').isUsable).toBe(false);
    expect(new CloudConfig('https://example.com', 'AIzaSyA1234567890abcdefghij').isUsable).toBe(false);
    expect(new CloudConfig('https://a.firebaseio.com/users', 'AIzaSyA1234567890abcdefghij').isUsable).toBe(false);
    expect(new CloudConfig('https://a.firebaseio.com', 'short').isUsable).toBe(false);
    expect(new CloudConfig('https://a.firebaseio.com', 'AIzaSyA1234567890abc/efghij').isUsable).toBe(false);
    expect(new CloudConfig('https://evil.com?x=.firebaseio.com', 'AIzaSyA1234567890abcdefghij').isUsable).toBe(false);
    expect(new CloudConfig('https://user@a.firebaseio.com', 'AIzaSyA1234567890abcdefghij').isUsable).toBe(false);
    expect(CloudConfig.builtIn.isUsable).toBe(true);
    expect(new CloudSettings().config.equals(CloudConfig.builtIn)).toBe(true);
  });

  it('starts with everything off, and a setting added later takes its default', () => {
    const fresh = new CloudSettings();
    expect(fresh.allowInternetPlay).toBe(false);
    expect(fresh.allowFriends).toBe(false);
    expect(fresh.allowFriendChat).toBe(false);
    expect(fresh.isActive).toBe(false);
    const old = CloudSettings.decode({ allowFriends: true });
    expect(old.allowFriends).toBe(true);
    expect(old.shareWhatIPlay).toBe(true);
    expect(CloudSettings.decode(JSON.parse(JSON.stringify(old))).allowFriends).toBe(true);
  });

  it('knows the three kinds of room', () => {
    expect(isPublicOnRouter('internet')).toBe(true);
    expect(isPublicOnRouter('routerPublic')).toBe(true);
    expect(isPublicOnRouter('routerPrivate')).toBe(false);
  });
});

describe('codes and paths', () => {
  it('makes friend codes that read back', () => {
    let state = 7;
    const next = () => { state ^= state << 13; state ^= state >>> 17; state ^= state << 5; return state >>> 0; };
    for (let i = 0; i < 50; i++) {
      const code = CloudIDs.newFriendCode(next);
      expect(CloudIDs.normalizeFriendCode(code)).toBe(code);
      expect(CloudPath.isSafeKey(code)).toBe(true);
    }
    expect(CloudIDs.normalizeFriendCode(CloudIDs.newFriendCode())).not.toBeNull();
    expect(CloudIDs.normalizeFriendCode(' abcd-2345 ')).toBe('ABCD2345');
    expect(CloudIDs.normalizeFriendCode('ABCD-234O')).toBeNull();
    expect(CloudIDs.normalizeFriendCode('ABC')).toBeNull();
    expect(CloudIDs.displayFriendCode('ABCD2345')).toBe('ABCD-2345');
  });

  it('keeps a chat the same whoever asks', () => {
    expect(CloudIDs.pair('zed', 'amy')).toBe(CloudIDs.pair('amy', 'zed'));
    expect(CloudIDs.other(CloudIDs.pair('zed', 'amy'), 'amy')).toBe('zed');
    expect(CloudIDs.other('a_b', 'c')).toBeNull();
  });

  it('checks path steps from other players', () => {
    expect(CloudPath.isSafeKey('Xy12_ab-9')).toBe(true);
    for (const bad of ['', 'a/b', 'a.b', 'a$b', 'a#b', 'a[b]', 'a'.repeat(65), 'ü', 5, null]) expect(CloudPath.isSafeKey(bad)).toBe(false);
    const link = CloudIDs.newLinkID();
    expect(link).toMatch(/^[a-z0-9]{20}$/);
    expect(CloudPath.isSafeKey(link)).toBe(true);
    expect(CloudPath.down('room', link)).toBe(`relay/room/down/${link}`);
  });

  it('numbers pieces so they sort as numbers, as the rules require', () => {
    const keys = [0, 9, 10, 100, 12345].map(CloudIDs.sequenceKey);
    expect(keys).toEqual([...keys].sort());
    expect(CloudIDs.sequenceKey(42)).toBe('0000000042');
    for (const k of keys) expect(k).toMatch(/^[0-9]{10}$/);
  });
});

describe('JSON as Firebase sends it', () => {
  it('puts and patches like Firebase', () => {
    let tree: Json = null;
    tree = jsonSetting(tree, ['a', 'b'], 1);
    tree = jsonSetting(tree, ['a', 'c'], 2);
    expect(jsonObject(jsonObject(tree)!.a)!.b).toBe(1);
    tree = jsonPatching(tree, ['a'], { b: null, d: 'x' });
    expect(jsonObject(jsonObject(tree)!.a)!.b).toBeUndefined();
    expect(jsonObject(jsonObject(tree)!.a)!.d).toBe('x');
    tree = jsonSetting(tree, ['a'], null);
    expect(tree).toBeNull();
    expect(jsonObject([5, null, 7])!['2']).toBe(7);
    expect(Object.keys(jsonObject([5, null, 7])!)).toEqual(['0', '2']);
  });

  it('does not change a tree it was given', () => {
    const before: Json = { a: { b: 1 } };
    const after = jsonSetting(before, ['a', 'c'], 2);
    expect(before).toEqual({ a: { b: 1 } });
    expect(after).toEqual({ a: { b: 1, c: 2 } });
  });

  it('reads events from the stream', () => {
    const parser = new CloudEventParser();
    const events: CloudEvent[] = [];
    const text = 'event: put\ndata: {"path":"/","data":{"a":1}}\n\nevent: keep-alive\ndata: null\n\nevent: patch\r\ndata: {"path":"/b","data":{"c":"d"}}\r\n\r\nevent: odd\ndata: 1\n\nevent: put\ndata: not json\n\n';
    for (const line of text.split('\n')) {
      const e = parser.feed(line);
      if (e) events.push(e);
    }
    expect(events.map((e) => e.kind)).toEqual(['put', 'keep-alive', 'patch']);
    expect(events[2].path).toEqual(['b']);
    const mirror = new CloudMirror();
    for (const e of events) mirror.apply(e);
    expect(jsonObject(mirror.value)!.a).toBe(1);
    expect(jsonObject(jsonObject(mirror.value)!.b)!.c).toBe('d');
    mirror.apply({ kind: 'put', path: ['a'], data: null });
    expect(jsonObject(mirror.value)!.a).toBeUndefined();
    mirror.apply({ kind: 'put', path: [], data: null });
    expect(mirror.value).toBeNull();
  });
});

describe('the relay', () => {
  it('hands pieces on in order, whatever order they come in', () => {
    const outbox = new RelayOutbox();
    const message = Uint8Array.from({ length: 600_000 }, (_, i) => i % 251);
    outbox.append(message.subarray(0, 1000));
    outbox.append(message.subarray(1000));
    const pieces: [string, string][] = [];
    for (let p = outbox.take(); p; p = outbox.take()) pieces.push([p.key, p.base64]);
    expect(pieces.length).toBe(3);
    expect(outbox.isEmpty).toBe(true);
    for (const [, b] of pieces) expect(b.length).toBeLessThanOrEqual(360_000);

    const inbox = new RelayInbox();
    const received: Uint8Array[] = [];
    received.push(inbox.receive({ [pieces[2][0]]: pieces[2][1] }));
    expect(received[0].length).toBe(0);
    const all: Record<string, Json> = Object.fromEntries(pieces);
    received.push(inbox.receive(all));
    received.push(inbox.receive(all));
    const joined = new Uint8Array(received.reduce((n, r) => n + r.length, 0));
    let at = 0;
    for (const r of received) { joined.set(r, at); at += r.length; }
    expect(joined).toEqual(message);
    expect(inbox.takeConsumed().length).toBe(3);
    expect(inbox.takeConsumed()).toEqual([]);
  });

  it('keeps what was appended even if the caller reuses its buffer', () => {
    const outbox = new RelayOutbox();
    const buffer = Uint8Array.of(1, 2, 3);
    outbox.append(buffer);
    buffer.fill(9);
    const piece = outbox.take()!;
    expect(new RelayInbox().receive({ [piece.key]: piece.base64 })).toEqual(Uint8Array.of(1, 2, 3));
  });

  it('ignores garbage', () => {
    const inbox = new RelayInbox();
    expect(inbox.receive({ '0000000000': 5, x: 'AAAA', '0000000001': '!!!' }).length).toBe(0);
    expect(inbox.receive({ '0000000000': 'AAA' }).length).toBe(0);
    expect(inbox.receive({ '0000000000': 'AA==' })).toEqual(Uint8Array.of(0));
  });
});

describe('what friends and rooms look like', () => {
  it('cleans a friend’s profile, which can go stale', () => {
    const avatar = { ...defaultProfile(), displayName: 'N'.repeat(80) };
    const clean = cleanedProfile({ avatar, code: 'abcd2345', online: true, seen: 1_000_000, game: 'Obby', room: 'bad/room' });
    expect([...clean.avatar.displayName].length).toBeLessThanOrEqual(AbloxProtocol.maxNameLength);
    expect(clean.room).toBeUndefined();
    expect(clean.code).toBe('ABCD2345');
    expect(profileIsOnline(clean, 1_000_000 + 60_000)).toBe(true);
    expect(profileIsOnline(clean, 1_000_000 + 10 * 60_000)).toBe(false);
  });

  it('writes and reads a room as the iPads do', () => {
    const room = makeCloudRoom({ id: 'k', host: 'h', hostName: 'Mika', world: 'Obby', worldID: 'w', players: 2, capacity: 8, code: 'ABC234', salt: '0123456789abcdef', at: 5_000 });
    expect(roomIsFresh(room, 5_000 + 60_000)).toBe(true);
    expect(roomIsFresh(room, 5_000 + roomStaleAfter + 1)).toBe(false);
    const json = encodeCloudRoom(room);
    expect(json.protocol).toBe(AbloxProtocol.version);
    expect(Object.keys(json).sort()).toEqual(['at', 'capacity', 'code', 'host', 'hostName', 'players', 'protocol', 'salt', 'world', 'worldID']);
    const back = decodeCloudRoom(JSON.parse(JSON.stringify(json)), 'k');
    expect(back).toEqual(room);
    expect(decodeCloudRoom({ ...json, players: 2.5 })).toBeNull();
    expect(decodeCloudRoom({ ...json, code: undefined })).toBeNull();
    expect(makeCloudRoom({ host: 'h', hostName: 'x'.repeat(90), world: 'y'.repeat(90), worldID: 'w', players: 1, capacity: 8, code: 'C', salt: 'S' }).hostName.length).toBe(40);
  });

  it('never locks out guests coming through the relay', () => {
    const limiter = new AttemptLimiter();
    for (let i = 0; i < 50; i++) limiter.recordFailure('127.0.0.1', 1);
    expect(limiter.isBanned('127.0.0.1', 2)).toBe(false);
    for (let i = 0; i < 50; i++) limiter.recordFailure('192.168.1.9', 1);
    expect(limiter.isBanned('192.168.1.9', 2)).toBe(true);
  });
});

describe('how much a guest may send', () => {
  it('never drops steady play', () => {
    const budget = new PacketBudget();
    let time = 0;
    for (let i = 0; i < 2000; i++) {
      time += 1 / 20;
      expect(budget.admit(4, time)).toBe('allow');
    }
  });

  it('absorbs a burst and cuts a flood', () => {
    const budget = new PacketBudget();
    const verdicts = Array.from({ length: 20 }, () => budget.admit(8, 1));
    expect(verdicts.slice(0, 6).filter((v) => v === 'allow').length).toBe(6);
    expect(verdicts.at(-1)).toBe('drop');
    expect(budget.admit(8, 3)).toBe('allow');
    const flood = new PacketBudget();
    let last = 'allow';
    for (let i = 0; i < 2000; i++) last = flood.admit(12, 5 + i * 0.001);
    expect(last).toBe('disconnect');
    expect(new PacketBudget().admit(2, 0)).toBe('allow');
  });

  it('turns repeated failures away for a while', () => {
    const limiter = new AttemptLimiter();
    for (let i = 0; i < AttemptLimiter.maximumFailures; i++) limiter.recordFailure('10.0.0.9', i);
    expect(limiter.isBanned('10.0.0.9', 20)).toBe(true);
    expect(limiter.isBanned('10.0.0.8', 20)).toBe(false);
    expect(limiter.isBanned('10.0.0.9', 20 + AttemptLimiter.banDuration)).toBe(false);
  });
});

describe('getting back in', () => {
  const all: DisconnectReason[] = [Disconnect.userLeft, Disconnect.hostClosed, Disconnect.authenticationFailed, Disconnect.protocolMismatch,
    Disconnect.sessionFull, Disconnect.networkLost, Disconnect.timedOut, Disconnect.unknown('detail'), Disconnect.unknown('')];

  it('retries only what a retry can fix, and says something for every ending', () => {
    expect(isRetryable(Disconnect.networkLost)).toBe(true);
    expect(isRetryable(Disconnect.timedOut)).toBe(true);
    expect(isRetryable(Disconnect.unknown('odd'))).toBe(true);
    for (const r of [Disconnect.userLeft, Disconnect.hostClosed, Disconnect.authenticationFailed, Disconnect.protocolMismatch, Disconnect.sessionFull]) {
      expect(isRetryable(r)).toBe(false);
    }
    for (const r of all) expect(reasonMessage(r).length).toBeGreaterThan(0);
    expect(reasonMessage(Disconnect.authenticationFailed).toLowerCase()).toContain('room code');
  });

  it('backs off exponentially, capped, jittered downward only', () => {
    const p = ReconnectPolicy.with({ baseDelay: 0.5, maximumDelay: 100, jitterFraction: 0 });
    expect([1, 2, 3, 4].map((a) => p.delay(a, 0))).toEqual([0.5, 1, 2, 4]);
    expect(ReconnectPolicy.with({ baseDelay: 0.5, maximumDelay: 3, jitterFraction: 0 }).delay(10, 0)).toBe(3);
    const j = ReconnectPolicy.with({ baseDelay: 1, maximumDelay: 4, jitterFraction: 0.25 });
    for (let f = 0; f <= 1.0001; f += 0.1) {
      const d = j.delay(10, f);
      expect(d).toBeLessThanOrEqual(4 + 1e-9);
      expect(d).toBeGreaterThanOrEqual(3 - 1e-9);
    }
    const spread = ReconnectPolicy.with({ baseDelay: 2, maximumDelay: 8, jitterFraction: 0.5 });
    expect(new Set([0, 0.25, 0.5, 0.75, 1].map((f) => spread.delay(2, f))).size).toBeGreaterThan(1);
    const full = ReconnectPolicy.with({ baseDelay: 1, maximumDelay: 4, jitterFraction: 1 });
    expect(full.delay(3, 1)).toBeGreaterThanOrEqual(0);
    expect(full.delay(0, 0)).toBe(0);
  });

  it('bounds attempts and keeps the overall deadline', () => {
    const p = ReconnectPolicy.with({ maximumAttempts: 3, giveUpAfter: 1000 });
    expect(p.shouldAttempt(Disconnect.networkLost, 3, 0)).toBe(true);
    expect(p.shouldAttempt(Disconnect.networkLost, 4, 0)).toBe(false);
    const d = ReconnectPolicy.with({ maximumAttempts: 99, giveUpAfter: 10 });
    expect(d.shouldAttempt(Disconnect.networkLost, 2, 9)).toBe(true);
    expect(d.shouldAttempt(Disconnect.networkLost, 2, 11)).toBe(false);
    expect(ReconnectPolicy.default.shouldAttempt(Disconnect.authenticationFailed, 1, 0)).toBe(false);
    expect(ReconnectPolicy.default.shouldAttempt(Disconnect.userLeft, 1, 0)).toBe(false);
  });

  it('steps through drop, wait, try, wait longer, give up', () => {
    let c = new ReconnectCoordinator(ReconnectPolicy.with({ baseDelay: 1, jitterFraction: 0 }));
    expect(c.disconnected(Disconnect.networkLost, 0, 0)).toEqual({ kind: 'waiting', attempt: 1, until: 1 });
    expect(c.isReconnecting).toBe(true);
    expect(c.attemptNumber).toBe(1);
    expect(c.shouldAttemptNow(0.5)).toBe(false);
    expect(c.shouldAttemptNow(1)).toBe(true);
    expect(c.status).toEqual({ kind: 'attempting', attempt: 1 });
    expect(c.shouldAttemptNow(1.1)).toBe(false);

    c = new ReconnectCoordinator();
    expect(c.disconnected(Disconnect.authenticationFailed, 0)).toEqual({ kind: 'gaveUp', reason: Disconnect.authenticationFailed });
    expect(c.isReconnecting).toBe(false);
    expect(c.failureReason).toEqual(Disconnect.authenticationFailed);

    c = new ReconnectCoordinator(new ReconnectPolicy(3, 1, 100, 0, 1000));
    c.disconnected(Disconnect.networkLost, 0, 0);
    expect(c.shouldAttemptNow(1)).toBe(true);
    expect(c.attemptFailed(1, 0)).toEqual({ kind: 'waiting', attempt: 2, until: 3 });
    expect(c.shouldAttemptNow(3)).toBe(true);
    expect(c.attemptFailed(3, 0)).toEqual({ kind: 'waiting', attempt: 3, until: 7 });
    expect(c.shouldAttemptNow(7)).toBe(true);
    expect(c.attemptFailed(7, 0)).toEqual({ kind: 'gaveUp', reason: Disconnect.networkLost });

    c = new ReconnectCoordinator(new ReconnectPolicy(99, 5, 100, 0, 6));
    c.disconnected(Disconnect.networkLost, 0, 0);
    expect(c.shouldAttemptNow(5)).toBe(true);
    expect(c.attemptFailed(5, 0)).toEqual({ kind: 'gaveUp', reason: Disconnect.networkLost });
  });

  it('starts over after succeeding, stops when cancelled, and hurries when the tab comes back', () => {
    let c = new ReconnectCoordinator(ReconnectPolicy.with({ baseDelay: 1, maximumDelay: 100, jitterFraction: 0 }));
    c.disconnected(Disconnect.networkLost, 0, 0);
    c.shouldAttemptNow(1);
    c.attemptFailed(1, 0);
    c.succeeded();
    expect(c.status).toEqual({ kind: 'idle' });
    expect(c.disconnected(Disconnect.networkLost, 100, 0)).toEqual({ kind: 'waiting', attempt: 1, until: 101 });

    c = new ReconnectCoordinator();
    c.disconnected(Disconnect.networkLost, 0);
    c.cancel();
    expect(c.shouldAttemptNow(1000)).toBe(false);

    c = new ReconnectCoordinator(ReconnectPolicy.with({ baseDelay: 8, maximumDelay: 8, jitterFraction: 0 }));
    c.disconnected(Disconnect.networkLost, 0, 0);
    expect(c.shouldAttemptNow(2)).toBe(false);
    c.retryImmediately(2);
    expect(c.shouldAttemptNow(2)).toBe(true);

    c = new ReconnectCoordinator();
    c.retryImmediately(5);
    expect(c.status).toEqual({ kind: 'idle' });
  });

  it('says where it is, and a host never reconnects', () => {
    const c = new ReconnectCoordinator(ReconnectPolicy.with({ maximumAttempts: 5 }));
    expect(c.progressDescription).toBeNull();
    c.disconnected(Disconnect.networkLost, 0);
    expect(c.progressDescription).toBe('Reconnecting… (1 of 5)');
    expect(new ReconnectCoordinator(ReconnectPolicy.none).disconnected(Disconnect.networkLost, 0)).toEqual({ kind: 'gaveUp', reason: Disconnect.networkLost });
  });
});

describe('the room code', () => {
  it('leaves out lookalikes, and the hint names exactly those', () => {
    for (const c of 'ILOU01') expect(roomCodeAlphabet.includes(c)).toBe(false);
    expect(roomCodeAlphabet.length).toBe(30);
    expect(new Set(roomCodeAlphabet).size).toBe(30);
    const everyone = new Set('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789');
    const missing = [...everyone].filter((c) => !roomCodeAlphabet.includes(c));
    expect(new Set(missing)).toEqual(new Set(roomCodeNeverUsed));
  });

  it('reads it however it is typed, and shows it grouped', () => {
    expect(RoomCode.normalize('abc def')).toBe('ABCDEF');
    expect(RoomCode.normalize('ABC-DEF')).toBe('ABCDEF');
    expect(RoomCode.normalize('  abcdef \n')).toBe('ABCDEF');
    expect(RoomCode.formatted('abcdef')).toBe('ABC DEF');
    expect(RoomCode.formatted('abc')).toBe('ABC');
    for (const raw of ['ABCDEF', 'abc def', 'A', '', 'ABCDEFGH']) expect(RoomCode.normalize(RoomCode.formatted(raw))).toBe(RoomCode.normalize(raw));
  });

  it('types on the pad and stops at six', () => {
    let code = '';
    for (const k of 'ABC234') code = RoomCode.typing(k, code);
    expect(code).toBe('ABC234');
    expect(RoomCode.isPlausible(code)).toBe(true);
    expect(RoomCode.typing('G', 'ABCDEF')).toBe('ABCDEF');
    expect(RoomCode.typing('O', 'AB')).toBe('AB');
    expect(RoomCode.typing('!', 'AB')).toBe('AB');
    expect(RoomCode.deleting('ABC')).toBe('AB');
    expect(RoomCode.deleting('')).toBe('');
    expect(RoomCode.typing('E', 'abc d')).toBe('ABCDE');
    expect(RoomCode.deleting('ABC D')).toBe('ABC');
    const fresh = RoomCode.generate();
    expect(fresh.length).toBe(6);
    expect(RoomCode.normalize(fresh)).toBe(fresh);
  });
});
