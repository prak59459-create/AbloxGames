// A browser hosting a room (Net/AbloxHost.swift, without the listener): the
// game's referee is LocalHost, the same one that runs a game alone; this is
// its network side. Each guest — an iPad or another browser, through the
// internet relay — is one secure link, checked as the iPad's host checks
// one: a packet budget, a deadline to say hello, only its own avatar and
// its own trigger finger, chat under the name the host knows it by.
import type { AvatarProfile } from '../core/model/avatar';
import type { WorldDelta } from '../core/model/liveWorld';
import type { PlayerSnapshot, PlayerTransform } from '../core/model/player';
import { Disconnect, PacketBudget, RoomCode, newKeySalt } from '../core/model/reliability';
import type { EventAction } from '../core/model/rules';
import { prefix, trimmed } from '../core/model/text';
import type { HostLink, LocalHost } from '../play/host';
import { keyFor } from './client';
import { PeerLink } from './link';
import {
  AbloxProtocol, PacketCodec, PacketKind, encodeChat, encodeEffects, encodeHandshake, encodeLeave, encodeRoom, encodeRoster,
  encodeTransformPayload, encodeWorldDelta, encodeWorldSnapshot, isPlausibleTransform, makePoll, pollLimits, readPacket, roomState,
  type ChatPayload, type Handshake, type HostMove, type Message, type Packet, type RoomMessage, type RoomState,
} from './packets';
import type { BytePipe } from './relay';

export interface RoomOptions {
  worldName: string;
  hostName: string;
  capacity?: number;
  roomCode?: string;
  /** Ask the host before anyone joins. */
  needsApproval?: boolean;
  /** Let in before (the room moved here): they come straight in. */
  alreadyApproved?: string[];
}

interface Guest {
  link: PeerLink;
  budget: PacketBudget;
  joined: boolean;
  /** At the door, waiting for the host: their handshake, kept. */
  awaiting: Handshake | null;
}

export class RoomHost implements HostLink {
  /** Connections still getting in at once, and how long one may take. */
  static readonly maximumPending = 6;
  static readonly handshakeDeadline = 10;
  /** How long someone waits at the door for the host to answer. */
  static readonly approvalDeadline = 60;

  readonly roomCode: string;
  readonly keySalt: string;
  readonly capacity: number;
  readonly worldName: string;
  readonly hostName: string;
  room: RoomState = roomState();

  onJoinRequest: (peer: string, name: string) => void = () => {};
  onJoinRequestEnded: (peer: string) => void = () => {};
  onRoomState: (state: RoomState) => void = () => {};
  /** A whisper for the host's own player. */
  onWhisper: (from: string, name: string, text: string) => void = () => {};
  /** Someone came or went: for the room's listing. */
  onPeopleChanged: (people: number) => void = () => {};

  private guests = new Set<Guest>();
  private removedPeers = new Set<string>();
  private approvedPeers: Set<string>;
  private readonly codec: PacketCodec;
  private readonly psk: Promise<Uint8Array>;
  private timer: ReturnType<typeof setInterval> | null = null;
  private stopped = false;

  constructor(readonly host: LocalHost, options: RoomOptions) {
    this.roomCode = RoomCode.normalize(options.roomCode ?? RoomCode.generate());
    this.keySalt = newKeySalt();
    this.capacity = Math.max(2, Math.min(50, options.capacity ?? AbloxProtocol.defaultCapacity));
    this.worldName = prefix(options.worldName, 60);
    this.hostName = options.hostName;
    this.room.needsApproval = options.needsApproval ?? false;
    this.approvedPeers = new Set(options.alreadyApproved ?? []);
    this.codec = new PacketCodec(host.localPeerID);
    this.psk = keyFor(this.roomCode, this.keySalt);
    host.link = this;
    this.timer = setInterval(() => this.tick(), 100);
  }

  get localPeerID(): string { return this.host.localPeerID; }
  get people(): number { return this.host.game.players.size; }
  get connectedCount(): number { return this.guests.size; }
  private get elapsed(): number { return this.host.elapsed; }

  /** The key is ready (it takes a moment to make): the room can be listed. */
  ready(): Promise<void> { return this.psk.then(() => {}); }

  // MARK: Connections

  /** A new connection, through the relay. */
  async accept(pipe: BytePipe): Promise<void> {
    // Full: closing at once is clearer than a handshake that hangs.
    const pending = [...this.guests].filter((g) => !g.joined).length;
    if (this.stopped || this.host.game.players.size >= this.capacity || pending >= RoomHost.maximumPending) {
      pipe.close();
      return;
    }
    const psk = await this.psk;
    if (this.stopped || pipe.isClosed) { pipe.close(); return; }
    const link = new PeerLink({ role: 'server', psk, pipe, codec: this.codec, handshakeTimeout: 30 });
    const guest: Guest = { link, budget: new PacketBudget(), joined: false, awaiting: null };
    this.guests.add(guest);
    // Wrong code, or never saying hello: the connection does not keep its place.
    setTimeout(() => {
      if (this.guests.has(guest) && !guest.joined && !guest.awaiting) link.close(Disconnect.timedOut);
    }, (RoomHost.handshakeDeadline + 20) * 1000);
    link.onPacket = (packet) => this.handle(packet, guest);
    link.onClose = () => this.drop(guest);
    link.start();
  }

  private drop(guest: Guest): void {
    if (!this.guests.delete(guest)) return;
    if (guest.awaiting) this.onJoinRequestEnded(guest.awaiting.peerID);
    guest.awaiting = null;
    const peer = guest.link.remotePeerID;
    if (!guest.joined || !peer) return;
    if (this.room.ready.delete(peer)) this.broadcastRoom();
    this.broadcast(PacketKind.leave, encodeLeave({ peerID: peer, reason: '' }));
    this.host.remoteLeft(peer);
    this.onPeopleChanged(this.people);
  }

  private guestFor(peer: string): Guest | undefined {
    for (const g of this.guests) if (g.joined && g.link.remotePeerID === peer) return g;
    return undefined;
  }

  // MARK: Packets

  private handle(packet: Packet, guest: Guest): void {
    const verdict = guest.budget.admit(packet.header.kind, this.elapsed);
    if (verdict === 'drop') return;
    if (verdict === 'disconnect') {
      // Flooding: broken, or trying to take the room down.
      guest.link.close(Disconnect.unknown('flood'));
      return;
    }
    // Until the handshake, only the handshake means anything.
    if (packet.header.kind !== PacketKind.handshake && !guest.joined) return;
    let message: Message;
    try { message = readPacket(packet); } catch {
      if (packet.header.kind === PacketKind.handshake) guest.link.close(Disconnect.unknown('bad handshake'));
      return;
    }
    const sender = guest.link.remotePeerID;
    switch (message.kind) {
      case PacketKind.handshake: this.handshake(message.handshake, guest); return;
      case PacketKind.playerTransform: {
        const t = message.transform;
        // Only your own avatar, and only somewhere a body could be.
        if (t.peerID !== sender || !isPlausibleTransform(t)) return;
        this.host.remoteTransform(t);
        // Numbered again by this host: a guest that keeps one count per kind
        // (as iPads do) would otherwise throw away whoever counts lower.
        this.relay(this.codec.encode(PacketKind.playerTransform, encodeTransformPayload(t), t.peerID), guest);
        return;
      }
      case PacketKind.eventTrigger: {
        const t = message.trigger;
        if (t.peerID !== sender) return;
        this.host.remoteObservation({ kind: t.cause, peer: t.peerID, blockID: t.blockID });
        return;
      }
      case PacketKind.playerInput:
        if (message.input.peerID !== sender) return;
        this.host.remoteInput(message.input.peerID, message.input.input);
        return;
      case PacketKind.chat:
        // Quieted by the host: said to no one.
        if (!sender || this.room.quieted.has(sender)) return;
        this.host.remoteChat(sender, message.chat);
        return;
      case PacketKind.room:
        if (sender) this.handleRoom(message.room, sender);
        return;
      case PacketKind.leave:
        guest.link.close(Disconnect.userLeft);
        return;
      default:
        // Host-written kinds (and Studio's edits, which a game does not take): ignored.
        return;
    }
  }

  private handshake(payload: Handshake, guest: Guest): void {
    if (payload.protocolVersion !== AbloxProtocol.version) {
      // Why, before hanging up, so the joining device can say something better than "connection lost".
      guest.link.send(PacketKind.chat, encodeChat({ senderName: 'Ablox', text: `Ablox versions differ (this one ${AbloxProtocol.version}, that one ${payload.protocolVersion}).` }));
      this.closeSoon(guest);
      return;
    }
    // Nobody may join as the host, and a connection keeps the identity of its first handshake.
    if (payload.peerID === this.localPeerID || payload.peerID !== guest.link.remotePeerID) {
      guest.link.close(Disconnect.unknown('identity'));
      return;
    }
    // Already playing: a new look, not a new arrival.
    if (guest.joined) {
      this.host.updateRemoteProfile(payload.peerID, payload.profile);
      return;
    }
    if (guest.awaiting) return;
    if (this.removedPeers.has(payload.peerID)) {
      guest.link.send(PacketKind.room, encodeRoom({ type: 'removed' }));
      this.closeSoon(guest);
      return;
    }
    // The same person on a second connection: the old one is a reconnect's leftover.
    const earlier = this.guestFor(payload.peerID);
    if (earlier) earlier.link.close(Disconnect.networkLost);
    if (this.room.needsApproval && !this.approvedPeers.has(payload.peerID)) {
      guest.awaiting = payload;
      guest.link.send(PacketKind.room, encodeRoom({ type: 'waitingForHost' }));
      this.onJoinRequest(payload.peerID, payload.profile.displayName);
      setTimeout(() => { if (this.guests.has(guest) && guest.awaiting) this.refuse(guest); }, RoomHost.approvalDeadline * 1000);
      return;
    }
    this.admit(guest, payload);
  }

  /** Into the game: the host's details, the world, everyone, the room, then the script's welcome. */
  private admit(guest: Guest, payload: Handshake): void {
    guest.joined = true;
    guest.awaiting = null;
    this.approvedPeers.add(payload.peerID);
    const { world, welcome } = this.host.admit(payload.peerID, payload.profile);
    guest.link.send(PacketKind.handshake, encodeHandshake({
      protocolVersion: AbloxProtocol.version, peerID: this.localPeerID, profile: this.host.profile, worldName: this.worldName,
      isHost: true, capacity: this.capacity,
    }));
    guest.link.send(PacketKind.worldSnapshot, encodeWorldSnapshot(world));
    this.host.announceRoster();
    this.room.clock = this.elapsed;
    guest.link.send(PacketKind.room, encodeRoom({ type: 'state', state: this.room }));
    this.host.welcome(welcome);
    this.onPeopleChanged(this.people);
  }

  private refuse(guest: Guest): void {
    if (guest.awaiting) this.onJoinRequestEnded(guest.awaiting.peerID);
    guest.awaiting = null;
    guest.link.send(PacketKind.room, encodeRoom({ type: 'refused' }));
    this.closeSoon(guest);
  }

  /** A moment for the last message to go before the line is cut. */
  private closeSoon(guest: Guest): void {
    setTimeout(() => guest.link.close(Disconnect.userLeft), 600);
  }

  // MARK: The room

  private handleRoom(message: RoomMessage, sender: string): void {
    switch (message.type) {
      case 'ready': {
        const changed = message.flag ? !this.room.ready.has(sender) : this.room.ready.has(sender);
        if (message.flag) this.room.ready.add(sender); else this.room.ready.delete(sender);
        if (changed) this.broadcastRoom();
        return;
      }
      case 'vote': {
        const poll = this.room.poll;
        if (!poll || poll.id !== message.poll || poll.isClosed || message.choice < 0 || message.choice >= poll.options.length) return;
        poll.votes.set(sender, message.choice);
        this.broadcastRoom();
        return;
      }
      case 'whisper': this.deliverWhisper(sender, message.to, message.text); return;
      default: return; // the host's to send, not a guest's
    }
  }

  private deliverWhisper(sender: string, target: string, text: string): void {
    const clean = prefix(trimmed(text), AbloxProtocol.maxChatLength);
    if (!clean || sender === target || this.room.quieted.has(sender)) return;
    const name = sender === this.localPeerID ? this.host.profile.displayName : (this.host.game.players.get(sender)?.profile.displayName ?? '');
    if (target === this.localPeerID) this.onWhisper(sender, name, clean);
    else this.guestFor(target)?.link.send(PacketKind.room, encodeRoom({ type: 'whispered', from: sender, name, text: clean }));
  }

  private broadcastRoom(): void {
    this.room.clock = this.elapsed;
    this.broadcast(PacketKind.room, encodeRoom({ type: 'state', state: this.room }));
    this.onRoomState(this.room);
  }

  answerJoinRequest(peer: string, allow: boolean): void {
    for (const g of this.guests) {
      if (g.awaiting?.peerID !== peer) continue;
      if (allow) {
        const payload = g.awaiting;
        this.onJoinRequestEnded(peer);
        this.admit(g, payload);
      } else {
        this.refuse(g);
      }
      return;
    }
  }

  /** Takes a player out of the room; they cannot come back into it. */
  remove(peer: string): void {
    if (peer === this.localPeerID) return;
    this.removedPeers.add(peer);
    this.approvedPeers.delete(peer);
    const g = this.guestFor(peer);
    if (!g) return;
    g.link.send(PacketKind.room, encodeRoom({ type: 'removed' }));
    this.closeSoon(g);
  }

  setQuieted(peer: string, quiet: boolean): void {
    if (peer === this.localPeerID) return;
    const changed = quiet !== this.room.quieted.has(peer);
    if (quiet) this.room.quieted.add(peer); else this.room.quieted.delete(peer);
    if (changed) this.broadcastRoom();
  }

  setNeedsApproval(ask: boolean): void {
    this.room.needsApproval = ask;
    // Everyone already inside counts as let in.
    for (const g of this.guests) if (g.joined && g.link.remotePeerID) this.approvedPeers.add(g.link.remotePeerID);
    this.broadcastRoom();
  }

  setAllowsWarp(allow: boolean): void { this.room.allowsWarp = allow; this.broadcastRoom(); }
  setReady(ready: boolean): void { this.handleRoom({ type: 'ready', flag: ready }, this.localPeerID); }
  clearReady(): void { if (this.room.ready.size) { this.room.ready.clear(); this.broadcastRoom(); } }
  vote(poll: string, choice: number): void { this.handleRoom({ type: 'vote', poll, choice }, this.localPeerID); }
  whisper(target: string, text: string): void { this.deliverWhisper(this.localPeerID, target, text); }

  startPoll(question: string, options: string[], seconds: number = pollLimits.defaultSeconds): boolean {
    const poll = makePoll(question, options, this.elapsed + seconds);
    if (!poll) return false;
    this.room.poll = poll;
    this.broadcastRoom();
    return true;
  }

  endPoll(): void { if (this.room.poll) { this.room.poll.isClosed = true; this.broadcastRoom(); } }
  clearPoll(): void { if (this.room.poll) { this.room.poll = undefined; this.broadcastRoom(); } }

  private tick(): void {
    const poll = this.room.poll;
    if (poll && !poll.isClosed && this.elapsed >= poll.closesAt) {
      poll.isClosed = true;
      this.broadcastRoom();
    }
  }

  /** Tells everyone the room is moving to `move.newHost`, then closes. */
  handOver(move: HostMove): void {
    this.broadcast(PacketKind.room, encodeRoom({ type: 'moving', move }));
    setTimeout(() => this.stop(), 500);
  }

  stop(): void {
    if (this.stopped) return;
    this.stopped = true;
    if (this.timer) clearInterval(this.timer);
    this.timer = null;
    for (const g of [...this.guests]) {
      // Goodbye from the host by name, so a guest knows there is nothing to come back to.
      g.link.send(PacketKind.leave, encodeLeave({ peerID: this.localPeerID, reason: '' }));
      const link = g.link;
      setTimeout(() => link.close(Disconnect.hostClosed), 400);
    }
    this.guests.clear();
    if (this.host.link === this) this.host.link = null;
  }

  // MARK: Broadcasting (HostLink)

  /** To everyone playing; a connection still getting in is sent nothing until it has shown it belongs. */
  private relay(packet: Packet, except?: Guest): void {
    for (const g of this.guests) if (g !== except && g.joined) g.link.sendPacket(packet);
  }

  private broadcast(kind: PacketKind, json: unknown): void {
    if (![...this.guests].some((g) => g.joined)) return;
    this.relay(this.codec.encode(kind, json));
  }

  broadcastEffects(payload: { ruleID?: string; actions: EventAction[] }): void {
    this.broadcast(PacketKind.eventEffect, encodeEffects(payload));
  }

  sendEffects(peer: string, payload: { ruleID?: string; target: string; actions: EventAction[] }): void {
    this.guestFor(peer)?.link.send(PacketKind.eventEffect, encodeEffects({ ruleID: payload.ruleID, targetPeerID: payload.target, actions: payload.actions }));
  }

  broadcastDelta(delta: WorldDelta): void { this.broadcast(PacketKind.worldDelta, encodeWorldDelta(delta)); }
  broadcastRoster(roster: PlayerSnapshot[]): void { this.broadcast(PacketKind.roster, encodeRoster(roster)); }
  broadcastTransform(t: PlayerTransform): void { this.broadcast(PacketKind.playerTransform, encodeTransformPayload(t)); }

  broadcastChat(payload: ChatPayload, except?: string): void {
    const packet = this.codec.encode(PacketKind.chat, encodeChat(payload));
    for (const g of this.guests) if (g.joined && g.link.remotePeerID !== except) g.link.sendPacket(packet);
  }

  /** For a profile the host shows: its own. */
  hostProfile(): AvatarProfile { return this.host.profile; }
}
