// WireFormatTests.swift, and every packet kind checked against the iPad's
// own encoder: fixtures/wire-swift.json was written by PacketCodec in Swift
// (the WireOracle tool), one packet of every kind and case. Each is read
// here and written again, and must say the same thing.
//
// With WIRE_OUT set, the packets this side writes are saved too, for the
// Swift tool to read back (`WireOracle check`); with WIRE_CHECKED set to its
// answer, that answer is compared here.
import { readFileSync, writeFileSync, existsSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import './helpers';
import {
  AbloxProtocol, PacketCodec, PacketKind, StreamReassembler, WireError, chatPayload, decodeHeader, encodeHeader, isSequenceNewer,
  messageJSON, readPacket, uuidBytes, uuidFromBytes, type Packet,
} from '../src/net/packets';

const peer = '11112222-3333-4444-5555-666677778888';

describe('the header', () => {
  it('keeps a peer id as its sixteen bytes', () => {
    expect(uuidFromBytes(uuidBytes(peer))).toBe(peer);
    expect(uuidBytes(peer).length).toBe(16);
  });

  it('round-trips, big-endian, 33 bytes', () => {
    const header = { kind: PacketKind.playerTransform, senderID: peer, sequence: 0xdeadbeef, timestamp: 1_700_000_000_123, payloadLength: 4096 };
    const bytes = encodeHeader(header);
    expect(bytes.length).toBe(33);
    expect(decodeHeader(bytes)).toEqual(header);
    const ping = encodeHeader({ kind: PacketKind.ping, senderID: peer, sequence: 1, timestamp: 0, payloadLength: 0 });
    expect([...ping.subarray(17, 21)]).toEqual([0, 0, 0, 1]);
  });

  it('refuses a short buffer and an unknown kind', () => {
    const full = encodeHeader({ kind: PacketKind.ping, senderID: peer, sequence: 1, timestamp: 1, payloadLength: 0 });
    expect(decodeHeader(full.subarray(0, 32))).toBeNull();
    const odd = full.slice();
    odd[0] = 0xfe;
    expect(decodeHeader(odd)).toBeNull();
  });

  it('counts sequences, and knows which is newer across the wrap', () => {
    const codec = new PacketCodec(peer);
    const a = codec.encode(PacketKind.ping, { nonce: 1, sentAtMilliseconds: 0 });
    const b = codec.encode(PacketKind.ping, { nonce: 2, sentAtMilliseconds: 0 });
    expect(b.header.sequence).toBe(a.header.sequence + 1);
    expect(isSequenceNewer(2, 1)).toBe(true);
    expect(isSequenceNewer(1, 2)).toBe(false);
    expect(isSequenceNewer(5, 5)).toBe(false);
    expect(isSequenceNewer(1, 0xffffffff)).toBe(true);
    expect(isSequenceNewer(0xffffffff, 1)).toBe(false);
  });

  it('clamps chat to the protocol limit, and keeps the constants', () => {
    expect([...chatPayload('spammer', 'あ'.repeat(5000)).text].length).toBe(AbloxProtocol.maxChatLength);
    expect(AbloxProtocol.version).toBe(8);
    expect(AbloxProtocol.headerSize).toBe(33);
    expect([PacketKind.handshake, PacketKind.leave, PacketKind.playerInput, PacketKind.room]).toEqual([1, 11, 12, 13]);
  });
});

describe('reassembly', () => {
  const codec = new PacketCodec(peer);
  const chat = (n: string, t: string) => codec.encode(PacketKind.chat, { senderName: n, text: t });
  const join = (packets: Packet[]) => {
    const parts = packets.map(PacketCodec.bytes);
    const out = new Uint8Array(parts.reduce((n, p) => n + p.length, 0));
    let at = 0;
    for (const p of parts) { out.set(p, at); at += p.length; }
    return out;
  };

  it('takes one, several, a split header, byte by byte, and keeps a partial tail', () => {
    const one = chat('a', 'b');
    let r = new StreamReassembler();
    const out = r.append(join([one]));
    expect(out.length).toBe(1);
    expect(out[0].payload).toEqual(one.payload);
    expect(r.bufferedByteCount).toBe(0);

    const five = [0, 1, 2, 3, 4].map((i) => chat('n' + i, 'msg ' + i));
    r = new StreamReassembler();
    const got = r.append(join(five));
    expect(got.map((p) => p.header.sequence)).toEqual(five.map((p) => p.header.sequence));

    const split = join([chat('split', 'across reads')]);
    r = new StreamReassembler();
    expect(r.append(split.subarray(0, 3))).toEqual([]);
    expect(r.append(split.subarray(3, 23))).toEqual([]);
    expect(r.append(split.subarray(23)).length).toBe(1);

    r = new StreamReassembler();
    let count = 0;
    for (const byte of split) count += r.append(Uint8Array.of(byte)).length;
    expect(count).toBe(1);

    const two = join([chat('a', 'first'), chat('b', 'second')]);
    r = new StreamReassembler();
    expect(r.append(two.subarray(0, two.length - 4)).length).toBe(1);
    expect(r.bufferedByteCount).toBeGreaterThan(0);
    expect(r.append(two.subarray(two.length - 4)).length).toBe(1);
    expect(r.bufferedByteCount).toBe(0);
  });

  it('refuses an oversized payload and a garbage header, and frames an empty one', () => {
    const big = encodeHeader({ kind: PacketKind.worldSnapshot, senderID: peer, sequence: 1, timestamp: 0, payloadLength: AbloxProtocol.maxPayloadLength + 1 });
    expect(() => new StreamReassembler().append(big)).toThrow(WireError);
    expect(() => new StreamReassembler().append(new Uint8Array(33).fill(0xff))).toThrow(/could not read/);
    const empty = codec.encodeEmpty(PacketKind.leave);
    const out = new StreamReassembler().append(PacketCodec.bytes(empty));
    expect(out.length).toBe(1);
    expect(out[0].header.kind).toBe(PacketKind.leave);
    expect(out[0].payload.length).toBe(0);
  });
});

// MARK: - Against the iPad

interface Fixture { sender: string; items: { name: string; kind: number; bytes: string; json: string; sequence: number }[] }

const fromBase64 = (s: string) => Uint8Array.from(Buffer.from(s, 'base64'));

/** The same data, in a form two writers can be compared in: sets sorted, Swift's key/value lists as pairs. */
function normalized(value: unknown, key = ''): unknown {
  if (Array.isArray(value)) {
    if (key === 'ready' || key === 'quieted') return [...value].map(String).sort();
    if (key === 'votes') {
      const pairs: string[] = [];
      for (let i = 0; i + 1 < value.length; i += 2) pairs.push(`${value[i]}=${value[i + 1]}`);
      return pairs.sort();
    }
    return value.map((v) => normalized(v));
  }
  if (value && typeof value === 'object') {
    const out: Record<string, unknown> = {};
    for (const k of Object.keys(value).sort()) out[k] = normalized((value as Record<string, unknown>)[k], k);
    return out;
  }
  return value;
}

/** Differences between two JSON values, with Swift's Float written shorter than a double. */
function differences(a: unknown, b: unknown, path = '$', out: string[] = []): string[] {
  if (out.length > 12) return out;
  if (typeof a === 'number' && typeof b === 'number') {
    if (!(Math.abs(a - b) <= 1e-6 * Math.max(1, Math.abs(a), Math.abs(b)))) out.push(`${path}: ${a} ≠ ${b}`);
    return out;
  }
  if (Array.isArray(a) && Array.isArray(b)) {
    if (a.length !== b.length) out.push(`${path}: length ${a.length} ≠ ${b.length}`);
    for (let i = 0; i < Math.min(a.length, b.length); i++) differences(a[i], b[i], `${path}[${i}]`, out);
    return out;
  }
  if (a && b && typeof a === 'object' && typeof b === 'object') {
    const keys = new Set([...Object.keys(a), ...Object.keys(b)]);
    for (const k of keys) {
      const x = (a as Record<string, unknown>)[k], y = (b as Record<string, unknown>)[k];
      if (x === undefined) out.push(`${path}.${k}: missing here (Swift has ${JSON.stringify(y)?.slice(0, 60)})`);
      else if (y === undefined) out.push(`${path}.${k}: extra here (${JSON.stringify(x)?.slice(0, 60)})`);
      else differences(x, y, `${path}.${k}`, out);
    }
    return out;
  }
  if (a !== b) out.push(`${path}: ${JSON.stringify(a)?.slice(0, 80)} ≠ ${JSON.stringify(b)?.slice(0, 80)}`);
  return out;
}

describe('every packet the iPad writes', () => {
  const fixture = JSON.parse(readFileSync(new URL('./fixtures/wire-swift.json', import.meta.url), 'utf8')) as Fixture;

  it('covers every kind', () => {
    expect(new Set(fixture.items.map((i) => i.kind))).toEqual(new Set(Object.values(PacketKind)));
  });

  for (const item of fixture.items) {
    it(`reads and writes ${item.name} as the iPad does`, () => {
      const packets = new StreamReassembler().append(fromBase64(item.bytes));
      expect(packets.length).toBe(1);
      const packet = packets[0];
      expect(packet.header.kind).toBe(item.kind);
      expect(packet.header.senderID).toBe(fixture.sender);
      expect(packet.header.sequence).toBe(item.sequence);
      const message = readPacket(packet);
      const ours = normalized(JSON.parse(JSON.stringify(messageJSON(message) ?? null)));
      const theirs = normalized(JSON.parse(item.json));
      expect(differences(ours, theirs)).toEqual([]);
    });
  }

  it('writes them back for the iPad to read (WIRE_OUT, WIRE_CHECKED)', () => {
    const codec = new PacketCodec(fixture.sender);
    const out = process.env.WIRE_OUT;
    const checked = process.env.WIRE_CHECKED;
    if (out) {
      const items = fixture.items.map((item) => {
        const packet = new StreamReassembler().append(fromBase64(item.bytes))[0];
        const json = messageJSON(readPacket(packet));
        const again = json === null ? codec.encodeEmpty(packet.header.kind) : codec.encode(packet.header.kind, json);
        return { name: item.name, bytes: Buffer.from(PacketCodec.bytes(again)).toString('base64') };
      });
      writeFileSync(out, JSON.stringify({ items }));
    }
    if (checked && existsSync(checked)) {
      const answer = JSON.parse(readFileSync(checked, 'utf8')) as { items: { name: string; ok: boolean; error?: string; json?: string }[] };
      for (const result of answer.items) {
        expect(result.ok, `${result.name}: ${result.error}`).toBe(true);
        const original = fixture.items.find((i) => i.name === result.name)!;
        expect(differences(normalized(JSON.parse(result.json!)), normalized(JSON.parse(original.json))), result.name).toEqual([]);
      }
    }
  });
});
