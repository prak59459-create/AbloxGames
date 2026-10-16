// The Ablox wire format, byte for byte as the iPads speak it (Packets.swift,
// WireFormat.swift, Room.swift): a 33-byte big-endian header — kind,
// sender, sequence, timestamp, payload length — then a JSON body written the
// way Swift's JSONEncoder writes it (sorted keys). Every payload the iPads
// send has its reader and writer here; they are checked against the iPads'
// own encoder and decoder (test/wire.test.ts, fixtures from the Swift side).
import { decodeProfile, encodeProfile, type AvatarProfile } from '../core/model/avatar';
import { decodeEffect } from '../core/model/effects';
import { decodeDelta, encodeDelta, type WorldDelta } from '../core/model/liveWorld';
import {
  decodeInput, decodeSnapshot, decodeTransform, encodeInput, encodeSnapshot, encodeTransform,
  type PlayerInput, type PlayerSnapshot, type PlayerTransform,
} from '../core/model/player';
import { decodeAction, encodeAction, type EventAction } from '../core/model/rules';
import { prefix, trimmed } from '../core/model/text';
import { decodeWorld, encodeWorld, type WorldDocument } from '../core/model/world';

export const PacketKind = {
  handshake: 1, worldSnapshot: 2, worldDelta: 3, playerTransform: 4, roster: 5, eventTrigger: 6, eventEffect: 7,
  chat: 8, ping: 9, pong: 10, leave: 11, playerInput: 12, room: 13,
} as const;
export type PacketKind = (typeof PacketKind)[keyof typeof PacketKind];
const kinds = new Set<number>(Object.values(PacketKind));

export const AbloxProtocol = {
  version: 8,
  maxPayloadLength: 8 * 1024 * 1024,
  maxChatLength: 240,
  transformHz: 20,
  defaultCapacity: 8,
  headerSize: 33,
  maxNameLength: 24,
} as const;

export class WireError extends Error {
  constructor(readonly code: 'malformedHeader' | 'payloadTooLarge' | 'decodingFailed' | 'protocolMismatch', message: string) {
    super(message);
  }
}

// MARK: - Ids as bytes

const uuidPattern = /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/;
export const isUUID = (s: unknown): s is string => typeof s === 'string' && uuidPattern.test(s);

export function uuidBytes(id: string): Uint8Array {
  const hex = id.replace(/-/g, '');
  const out = new Uint8Array(16);
  for (let i = 0; i < 16; i++) out[i] = parseInt(hex.slice(i * 2, i * 2 + 2), 16);
  return out;
}

export function uuidFromBytes(bytes: Uint8Array): string {
  const hex = [...bytes].map((b) => b.toString(16).padStart(2, '0')).join('').toUpperCase();
  return `${hex.slice(0, 8)}-${hex.slice(8, 12)}-${hex.slice(12, 16)}-${hex.slice(16, 20)}-${hex.slice(20)}`;
}

/** The host's own messages, when no player said them. */
export const hostSentinel = '00000000-0000-0000-0000-000000000001';

// MARK: - The header

export interface PacketHeader {
  kind: PacketKind;
  senderID: string;
  sequence: number;
  timestamp: number;
  payloadLength: number;
}

export interface Packet { header: PacketHeader; payload: Uint8Array }

export function encodeHeader(h: PacketHeader): Uint8Array {
  const out = new Uint8Array(AbloxProtocol.headerSize);
  const view = new DataView(out.buffer);
  out[0] = h.kind;
  out.set(uuidBytes(h.senderID), 1);
  view.setUint32(17, h.sequence >>> 0);
  view.setBigUint64(21, BigInt(Math.max(0, Math.round(h.timestamp))));
  view.setUint32(29, h.payloadLength >>> 0);
  return out;
}

/** Nil when the buffer is short or the kind is not one Ablox has. */
export function decodeHeader(bytes: Uint8Array): PacketHeader | null {
  if (bytes.length < AbloxProtocol.headerSize || !kinds.has(bytes[0])) return null;
  const view = new DataView(bytes.buffer, bytes.byteOffset, AbloxProtocol.headerSize);
  return {
    kind: bytes[0] as PacketKind,
    senderID: uuidFromBytes(bytes.subarray(1, 17)),
    sequence: view.getUint32(17),
    timestamp: Number(view.getBigUint64(21)),
    payloadLength: view.getUint32(29),
  };
}

/** Whether `candidate` is newer than `reference`, with the 32-bit wrap: 1 is newer than 0xFFFFFFFF. */
export function isSequenceNewer(candidate: number, reference: number): boolean {
  return candidate !== reference && ((candidate - reference) >>> 0) < 0x8000_0000;
}

// MARK: - JSON as Swift writes it

/** JSON with every object's keys in order, as JSONEncoder's `.sortedKeys` writes it. */
export function sortedJSON(value: unknown): string {
  return JSON.stringify(sortKeys(value));
}

function sortKeys(value: unknown): unknown {
  if (Array.isArray(value)) return value.map(sortKeys);
  if (value && typeof value === 'object') {
    const out: Record<string, unknown> = {};
    for (const key of Object.keys(value as object).sort()) {
      const v = (value as Record<string, unknown>)[key];
      if (v !== undefined) out[key] = sortKeys(v);
    }
    return out;
  }
  return value;
}

const encoder = new TextEncoder();
const decoder = new TextDecoder();

export class PacketCodec {
  private sequence = 0;
  constructor(readonly localPeerID: string) {}

  encode(kind: PacketKind, payload: unknown, sender?: string): Packet {
    const body = encoder.encode(sortedJSON(payload));
    if (body.length > AbloxProtocol.maxPayloadLength) {
      throw new WireError('payloadTooLarge', `A message too big to send (${body.length} bytes).`);
    }
    return { header: this.header(kind, body.length, sender), payload: body };
  }

  encodeEmpty(kind: PacketKind, sender?: string): Packet {
    return { header: this.header(kind, 0, sender), payload: new Uint8Array(0) };
  }

  private header(kind: PacketKind, length: number, sender?: string): PacketHeader {
    this.sequence = (this.sequence + 1) >>> 0;
    return { kind, senderID: (sender ?? this.localPeerID).toUpperCase(), sequence: this.sequence, timestamp: Date.now(), payloadLength: length };
  }

  static bytes(packet: Packet): Uint8Array {
    const out = new Uint8Array(AbloxProtocol.headerSize + packet.payload.length);
    out.set(encodeHeader({ ...packet.header, payloadLength: packet.payload.length }), 0);
    out.set(packet.payload, AbloxProtocol.headerSize);
    return out;
  }

  static json(packet: Packet): unknown {
    if (!packet.payload.length) return null;
    try {
      return JSON.parse(decoder.decode(packet.payload));
    } catch {
      throw new WireError('decodingFailed', 'Could not read message contents.');
    }
  }
}

// MARK: - Reassembly

/** Bytes from a stream in, whole packets out: a header split across reads, several in one, a tail held back. */
export class StreamReassembler {
  // Kept as the pieces they came in, and joined only once a whole packet is
  // here: a world of several megabytes arrives as hundreds of TLS records,
  // and joining at every record would copy it hundreds of times.
  private chunks: Uint8Array[] = [];
  private length = 0;
  constructor(readonly payloadLimit: number = AbloxProtocol.maxPayloadLength) {}

  get bufferedByteCount(): number { return this.length; }

  append(incoming: Uint8Array): Packet[] {
    if (incoming.length) {
      this.chunks.push(incoming.slice());
      this.length += incoming.length;
    }
    const packets: Packet[] = [];
    for (;;) {
      if (this.length < AbloxProtocol.headerSize) break;
      const header = decodeHeader(this.read(AbloxProtocol.headerSize, false));
      if (!header) throw new WireError('malformedHeader', 'Received a message Ablox could not read.');
      if (header.payloadLength > this.payloadLimit) {
        throw new WireError('payloadTooLarge', `A peer sent an oversized message (${header.payloadLength} bytes, limit ${this.payloadLimit}).`);
      }
      if (this.length < AbloxProtocol.headerSize + header.payloadLength) break;
      this.read(AbloxProtocol.headerSize, true);
      packets.push({ header, payload: this.read(header.payloadLength, true) });
    }
    return packets;
  }

  /** The first `n` bytes, copied into one array; taken off the front when `consume`. */
  private read(n: number, consume: boolean): Uint8Array {
    const out = new Uint8Array(n);
    let filled = 0, index = 0;
    while (filled < n) {
      const chunk = this.chunks[index];
      const count = Math.min(chunk.length, n - filled);
      out.set(chunk.subarray(0, count), filled);
      filled += count;
      if (!consume) { index++; continue; }
      if (count === chunk.length) this.chunks.shift(); else this.chunks[0] = chunk.subarray(count);
    }
    if (consume) this.length -= n;
    return out;
  }

  reset(): void { this.chunks = []; this.length = 0; }
}

// MARK: - Payloads

type Json = Record<string, unknown>;
const obj = (v: unknown): Json => (v && typeof v === 'object' && !Array.isArray(v) ? (v as Json) : {});
const str = (v: unknown, d = ''): string => (typeof v === 'string' ? v : d);
const num = (v: unknown, d = 0): number => (typeof v === 'number' && Number.isFinite(v) ? v : d);
const int = (v: unknown, d = 0): number => Math.trunc(num(v, d));
const bool = (v: unknown, d = false): boolean => (typeof v === 'boolean' ? v : d);
const peer = (v: unknown): string | null => (isUUID(v) ? v.toUpperCase() : null);
const need = <T>(v: T | null | undefined, what: string): T => {
  if (v === null || v === undefined) throw new WireError('decodingFailed', `Could not read ${what}.`);
  return v;
};

export interface Handshake { protocolVersion: number; peerID: string; profile: AvatarProfile; worldName: string; isHost: boolean; capacity: number }

export const encodeHandshake = (h: Handshake): Json => ({
  capacity: h.capacity, isHost: h.isHost, peerID: h.peerID, profile: encodeProfile(h.profile), protocolVersion: h.protocolVersion, worldName: h.worldName,
});

export function decodeHandshake(v: unknown): Handshake {
  const o = obj(v);
  if (typeof o.protocolVersion !== 'number') throw new WireError('decodingFailed', 'Could not read the handshake.');
  return {
    protocolVersion: int(o.protocolVersion), peerID: need(peer(o.peerID), 'the handshake'), profile: decodeProfile(o.profile),
    worldName: str(o.worldName), isHost: bool(o.isHost), capacity: int(o.capacity, AbloxProtocol.defaultCapacity),
  };
}

export const encodeRoster = (players: PlayerSnapshot[]): Json => ({ players: players.map(encodeSnapshot) });

export function decodeRoster(v: unknown): PlayerSnapshot[] {
  const list = obj(v).players;
  if (!Array.isArray(list)) throw new WireError('decodingFailed', 'Could not read the roster.');
  return list.map(decodeSnapshot).filter((s): s is PlayerSnapshot => s !== null);
}

export type TriggerCause = 'touched' | 'tapped' | 'proximityEntered';
export interface EventTriggerPayload { peerID: string; blockID: string; cause: TriggerCause }

export const encodeTrigger = (t: EventTriggerPayload): Json => ({ blockID: t.blockID, cause: t.cause, peerID: t.peerID });

export function decodeTriggerPayload(v: unknown): EventTriggerPayload {
  const o = obj(v);
  const cause = o.cause;
  if (cause !== 'touched' && cause !== 'tapped' && cause !== 'proximityEntered') throw new WireError('decodingFailed', 'Could not read a touch.');
  return { peerID: need(peer(o.peerID), 'a touch'), blockID: need(peer(o.blockID), 'a touch'), cause };
}

export interface EventEffectPayload { ruleID?: string; targetPeerID?: string; actions: EventAction[] }

export function encodeEffects(p: EventEffectPayload): Json {
  const out: Json = { actions: p.actions.map(encodeAction) };
  if (p.ruleID) out.ruleID = p.ruleID;
  if (p.targetPeerID) out.targetPeerID = p.targetPeerID;
  return out;
}

export function decodeEffects(v: unknown): EventEffectPayload {
  const o = obj(v);
  if (!Array.isArray(o.actions)) throw new WireError('decodingFailed', 'Could not read effects.');
  return {
    ruleID: peer(o.ruleID) ?? undefined,
    targetPeerID: peer(o.targetPeerID) ?? undefined,
    actions: o.actions.map(decodeAction).filter((a): a is EventAction => a !== null),
  };
}

export interface ChatPayload { senderName: string; text: string; senderID?: string }

export function chatPayload(senderName: string, text: string, senderID?: string): ChatPayload {
  return { senderName, text: prefix(text, AbloxProtocol.maxChatLength), senderID };
}

export function encodeChat(c: ChatPayload): Json {
  const out: Json = { senderName: c.senderName, text: prefix(c.text, AbloxProtocol.maxChatLength) };
  if (c.senderID) out.senderID = c.senderID;
  return out;
}

export function decodeChat(v: unknown): ChatPayload {
  const o = obj(v);
  if (typeof o.text !== 'string' || typeof o.senderName !== 'string') throw new WireError('decodingFailed', 'Could not read a chat line.');
  return chatPayload(o.senderName, o.text, peer(o.senderID) ?? undefined);
}

export interface PingPayload { nonce: number; sentAtMilliseconds: number }
export const encodePing = (p: PingPayload): Json => ({ nonce: p.nonce >>> 0, sentAtMilliseconds: Math.round(p.sentAtMilliseconds) });
export function decodePing(v: unknown): PingPayload {
  const o = obj(v);
  return { nonce: int(o.nonce) >>> 0, sentAtMilliseconds: num(o.sentAtMilliseconds) };
}

export interface LeavePayload { peerID: string; reason: string }
export const encodeLeave = (l: LeavePayload): Json => ({ peerID: l.peerID, reason: l.reason });
export function decodeLeave(v: unknown): LeavePayload {
  const o = obj(v);
  return { peerID: need(peer(o.peerID), 'a goodbye'), reason: str(o.reason) };
}

export interface PlayerInputPayload { peerID: string; input: PlayerInput }
export const encodePlayerInput = (p: PlayerInputPayload): Json => ({ input: encodeInput(p.input), peerID: p.peerID });
export function decodePlayerInput(v: unknown): PlayerInputPayload {
  const o = obj(v);
  return { peerID: need(peer(o.peerID), 'a press'), input: need(decodeInput(o.input), 'a press') };
}

export const encodeTransformPayload = (t: PlayerTransform): Json => encodeTransform(t);
export function decodeTransformPayload(v: unknown): PlayerTransform {
  return need(decodeTransform(v), 'a movement');
}

/** NaN, or a position light-years away, would poison every distance check it touched. */
export function isPlausibleTransform(t: PlayerTransform): boolean {
  const values = [t.position.x, t.position.y, t.position.z, t.velocity.x, t.velocity.y, t.velocity.z, t.yawDegrees];
  if (!values.every(Number.isFinite)) return false;
  const limit = 100_000;
  if (Math.abs(t.position.x) >= limit || Math.abs(t.position.y) >= limit || Math.abs(t.position.z) >= limit) return false;
  return Math.hypot(t.velocity.x, t.velocity.y, t.velocity.z) < 2_000;
}

export const encodeWorldSnapshot = (w: WorldDocument): Json => encodeWorld(w);
export const decodeWorldSnapshot = (v: unknown): WorldDocument => decodeWorld(v);
export const encodeWorldDelta = (d: WorldDelta): Json => encodeDelta(d);
export function decodeWorldDelta(v: unknown): WorldDelta {
  return need(decodeDelta(v), 'a world change');
}

// MARK: - The room

export interface Poll {
  id: string;
  question: string;
  options: string[];
  votes: Map<string, number>;
  closesAt: number;
  isClosed: boolean;
}

export const pollLimits = { maximumOptions: 4, maximumQuestionLength: 80, maximumOptionLength: 24, defaultSeconds: 30 } as const;

/** Nil when there are not two usable answers. */
export function makePoll(question: string, options: string[], closesAt: number, id = crypto.randomUUID().toUpperCase()): Poll | null {
  const answers = options.map((o) => prefix(trimmed(o), pollLimits.maximumOptionLength)).filter((o) => o.length > 0);
  const asked = prefix(trimmed(question), pollLimits.maximumQuestionLength);
  if (!asked || answers.length < 2 || answers.length > pollLimits.maximumOptions) return null;
  return { id, question: asked, options: answers, votes: new Map(), closesAt, isClosed: false };
}

export function pollTally(p: Poll): number[] {
  return p.options.map((_, i) => [...p.votes.values()].filter((v) => v === i).length);
}

export function pollWinner(p: Poll): number | null {
  const counts = pollTally(p);
  const best = Math.max(...counts);
  if (!(best > 0) || counts.filter((c) => c === best).length !== 1) return null;
  return counts.indexOf(best);
}

/** Swift writes a dictionary whose keys are not strings as one list: key, value, key, value. */
function encodePoll(p: Poll): Json {
  const votes: unknown[] = [];
  for (const [who, choice] of p.votes) votes.push(who, choice);
  return { closesAt: p.closesAt, id: p.id, isClosed: p.isClosed, options: p.options, question: p.question, votes };
}

function decodePoll(v: unknown): Poll | undefined {
  const o = obj(v);
  if (!isUUID(o.id) || typeof o.question !== 'string' || !Array.isArray(o.options) || typeof o.closesAt !== 'number') return undefined;
  const votes = new Map<string, number>();
  if (Array.isArray(o.votes)) {
    for (let i = 0; i + 1 < o.votes.length; i += 2) {
      const who = peer(o.votes[i]);
      if (who && typeof o.votes[i + 1] === 'number') votes.set(who, Math.trunc(o.votes[i + 1] as number));
    }
  }
  return {
    id: o.id.toUpperCase(), question: o.question, options: o.options.filter((x): x is string => typeof x === 'string'),
    votes, closesAt: o.closesAt, isClosed: bool(o.isClosed),
  };
}

export interface RoomState {
  ready: Set<string>;
  poll?: Poll;
  quieted: Set<string>;
  allowsWarp: boolean;
  needsApproval: boolean;
  clock: number;
}

export const roomState = (): RoomState => ({ ready: new Set(), quieted: new Set(), allowsWarp: true, needsApproval: false, clock: 0 });

export function encodeRoomState(s: RoomState): Json {
  const out: Json = {
    allowsWarp: s.allowsWarp, clock: s.clock, needsApproval: s.needsApproval, quieted: [...s.quieted], ready: [...s.ready],
  };
  if (s.poll) out.poll = encodePoll(s.poll);
  return out;
}

export function decodeRoomState(v: unknown): RoomState {
  const o = obj(v);
  const ids = (x: unknown) => new Set((Array.isArray(x) ? x : []).map(peer).filter((p): p is string => p !== null));
  return {
    ready: ids(o.ready), poll: decodePoll(o.poll), quieted: ids(o.quieted), allowsWarp: bool(o.allowsWarp, true),
    needsApproval: bool(o.needsApproval), clock: num(o.clock),
  };
}

/** Seconds left in the vote, by the host's clock when this was sent. */
export function pollSecondsLeft(s: RoomState): number | null {
  if (!s.poll || s.poll.isClosed) return null;
  return Math.max(0, s.poll.closesAt - s.clock);
}

export interface HostMove {
  newHost: string;
  newHostName: string;
  roomCode: string;
  isPublic: boolean;
  capacity: number;
  needsApproval: boolean;
  members: string[];
}

const encodeMove = (m: HostMove): Json => ({
  capacity: m.capacity, isPublic: m.isPublic, members: m.members, needsApproval: m.needsApproval, newHost: m.newHost,
  newHostName: m.newHostName, roomCode: m.roomCode,
});

function decodeMove(v: unknown): HostMove {
  const o = obj(v);
  if (typeof o.roomCode !== 'string' || typeof o.newHostName !== 'string') throw new WireError('decodingFailed', 'Could not read where the room went.');
  return {
    newHost: need(peer(o.newHost), 'where the room went'), newHostName: prefix(o.newHostName, AbloxProtocol.maxNameLength), roomCode: o.roomCode,
    isPublic: bool(o.isPublic), capacity: int(o.capacity, AbloxProtocol.defaultCapacity), needsApproval: bool(o.needsApproval),
    members: (Array.isArray(o.members) ? o.members : []).map(peer).filter((p): p is string => p !== null).slice(0, 64),
  };
}

export type RoomMessage =
  | { type: 'ready'; flag: boolean }
  | { type: 'vote'; poll: string; choice: number }
  | { type: 'whisper'; to: string; text: string }
  | { type: 'state'; state: RoomState }
  | { type: 'whispered'; from: string; name: string; text: string }
  | { type: 'waitingForHost' }
  | { type: 'refused' }
  | { type: 'removed' }
  | { type: 'moving'; move: HostMove };

export function encodeRoom(m: RoomMessage): Json {
  switch (m.type) {
    case 'ready': return { flag: m.flag, type: 'ready' };
    case 'vote': return { choice: m.choice, poll: m.poll, type: 'vote' };
    case 'whisper': return { peer: m.to, text: m.text, type: 'whisper' };
    case 'state': return { state: encodeRoomState(m.state), type: 'state' };
    case 'whispered': return { name: m.name, peer: m.from, text: m.text, type: 'whispered' };
    case 'waitingForHost': case 'refused': case 'removed': return { type: m.type };
    case 'moving': return { move: encodeMove(m.move), type: 'moving' };
  }
}

export function decodeRoom(v: unknown): RoomMessage {
  const o = obj(v);
  switch (o.type) {
    case 'ready':
      if (typeof o.flag !== 'boolean') break;
      return { type: 'ready', flag: o.flag };
    case 'vote':
      if (!isUUID(o.poll) || typeof o.choice !== 'number') break;
      return { type: 'vote', poll: o.poll.toUpperCase(), choice: Math.trunc(o.choice) };
    case 'whisper':
      return { type: 'whisper', to: need(peer(o.peer), 'a whisper'), text: prefix(str(o.text), AbloxProtocol.maxChatLength) };
    case 'state': return { type: 'state', state: decodeRoomState(o.state) };
    case 'whispered':
      return {
        type: 'whispered', from: need(peer(o.peer), 'a whisper'), name: prefix(str(o.name), AbloxProtocol.maxNameLength),
        text: prefix(str(o.text), AbloxProtocol.maxChatLength),
      };
    case 'waitingForHost': case 'refused': case 'removed': return { type: o.type };
    case 'moving': return { type: 'moving', move: decodeMove(o.move) };
  }
  throw new WireError('decodingFailed', 'Could not read a room message.');
}

// MARK: - Everything, by kind

/** Every payload a packet can carry, read by its kind: what both a host and a guest act on. */
export type Message =
  | { kind: typeof PacketKind.handshake; handshake: Handshake }
  | { kind: typeof PacketKind.worldSnapshot; world: WorldDocument }
  | { kind: typeof PacketKind.worldDelta; delta: WorldDelta }
  | { kind: typeof PacketKind.playerTransform; transform: PlayerTransform }
  | { kind: typeof PacketKind.roster; players: PlayerSnapshot[] }
  | { kind: typeof PacketKind.eventTrigger; trigger: EventTriggerPayload }
  | { kind: typeof PacketKind.eventEffect; effects: EventEffectPayload }
  | { kind: typeof PacketKind.chat; chat: ChatPayload }
  | { kind: typeof PacketKind.ping; ping: PingPayload }
  | { kind: typeof PacketKind.pong; ping: PingPayload }
  | { kind: typeof PacketKind.leave; leave: LeavePayload | null }
  | { kind: typeof PacketKind.playerInput; input: PlayerInputPayload }
  | { kind: typeof PacketKind.room; room: RoomMessage };

export function readPacket(packet: Packet): Message {
  const json = PacketCodec.json(packet);
  switch (packet.header.kind) {
    case PacketKind.handshake: return { kind: PacketKind.handshake, handshake: decodeHandshake(json) };
    case PacketKind.worldSnapshot: return { kind: PacketKind.worldSnapshot, world: decodeWorldSnapshot(json) };
    case PacketKind.worldDelta: return { kind: PacketKind.worldDelta, delta: decodeWorldDelta(json) };
    case PacketKind.playerTransform: return { kind: PacketKind.playerTransform, transform: decodeTransformPayload(json) };
    case PacketKind.roster: return { kind: PacketKind.roster, players: decodeRoster(json) };
    case PacketKind.eventTrigger: return { kind: PacketKind.eventTrigger, trigger: decodeTriggerPayload(json) };
    case PacketKind.eventEffect: return { kind: PacketKind.eventEffect, effects: decodeEffects(json) };
    case PacketKind.chat: return { kind: PacketKind.chat, chat: decodeChat(json) };
    case PacketKind.ping: return { kind: PacketKind.ping, ping: decodePing(json) };
    case PacketKind.pong: return { kind: PacketKind.pong, ping: decodePing(json) };
    case PacketKind.leave: return { kind: PacketKind.leave, leave: json === null ? null : decodeLeave(json) };
    case PacketKind.playerInput: return { kind: PacketKind.playerInput, input: decodePlayerInput(json) };
    case PacketKind.room: return { kind: PacketKind.room, room: decodeRoom(json) };
  }
}

/** The JSON a message is written as. */
export function messageJSON(m: Message): unknown {
  switch (m.kind) {
    case PacketKind.handshake: return encodeHandshake(m.handshake);
    case PacketKind.worldSnapshot: return encodeWorldSnapshot(m.world);
    case PacketKind.worldDelta: return encodeWorldDelta(m.delta);
    case PacketKind.playerTransform: return encodeTransformPayload(m.transform);
    case PacketKind.roster: return encodeRoster(m.players);
    case PacketKind.eventTrigger: return encodeTrigger(m.trigger);
    case PacketKind.eventEffect: return encodeEffects(m.effects);
    case PacketKind.chat: return encodeChat(m.chat);
    case PacketKind.ping: case PacketKind.pong: return encodePing(m.ping);
    case PacketKind.leave: return m.leave ? encodeLeave(m.leave) : null;
    case PacketKind.playerInput: return encodePlayerInput(m.input);
    case PacketKind.room: return encodeRoom(m.room);
  }
}

// Kept so a script effect arriving alone (in tests) can be read the same way.
export { decodeEffect };
