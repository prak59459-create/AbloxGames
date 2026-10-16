// One secure connection to another player, in either direction
// (Net/PeerConnection.swift): TLS 1.3 keyed by the room code over a byte
// pipe, cut into whole packets. The rest of the web version deals in typed
// packets rather than bytes; this is where they become bytes.
import type { AvatarProfile } from '../core/model/avatar';
import { Disconnect, type DisconnectReason } from '../core/model/reliability';
import {
  PacketCodec, PacketKind, StreamReassembler, WireError, decodeHandshake, decodePing, encodePing, isSequenceNewer, type Packet,
} from './packets';
import type { BytePipe } from './relay';
import { TLSConnection, TLSError, pskIdentity, type BinderLabel } from './tls13';

export type LinkState = 'connecting' | 'ready' | 'closed';

export interface LinkOptions {
  role: 'client' | 'server';
  psk: Uint8Array;
  pipe: BytePipe;
  codec: PacketCodec;
  binderLabel?: BinderLabel;
  /** Seconds the secure handshake may take before the link gives up. */
  handshakeTimeout?: number;
}

export class PeerLink {
  /** Who is on the other end, from its first Ablox handshake. */
  remotePeerID: string | null = null;
  remoteProfile: AvatarProfile | null = null;
  roundTripMilliseconds: number | null = null;
  state: LinkState = 'connecting';
  /** Which binder label the secure handshake used (a server learns it from the client). */
  binderLabel: BinderLabel;

  onReady: () => void = () => {};
  onPacket: (packet: Packet) => void = () => {};
  /** Once: the link is over, and why. */
  onClose: (reason: DisconnectReason) => void = () => {};

  readonly tls: TLSConnection;
  private readonly pipe: BytePipe;
  private readonly codec: PacketCodec;
  private readonly reassembler = new StreamReassembler();
  /**
   * Last transform sequence seen from each sender, so a late one cannot pull
   * an avatar backwards. By sender: a host passes on several players'
   * packets, each numbered by its own sender.
   */
  private lastSequence = new Map<string, number>();
  private pendingPings = new Map<number, number>();
  private pingNonce = 0;
  private handshakeTimer: ReturnType<typeof setTimeout> | null = null;
  private closeReason: DisconnectReason | null = null;

  constructor(options: LinkOptions) {
    this.pipe = options.pipe;
    this.codec = options.codec;
    this.binderLabel = options.binderLabel ?? 'ext binder';
    this.tls = new TLSConnection({
      role: options.role, psk: options.psk, identity: pskIdentity, binderLabel: options.binderLabel,
      send: (bytes) => this.pipe.write(bytes),
    });
    this.tls.onData = (bytes) => this.receive(bytes);
    this.tls.onClose = (error) => this.finish(this.classify(error));
    this.pipe.onData = (bytes) => this.tls.receive(bytes);
    // What came just before the line went (the room moving, a goodbye) is read before the link says it has gone.
    this.pipe.whenClosed(() => { void this.tls.settled.then(() => this.finish(Disconnect.networkLost)); });
    const seconds = options.handshakeTimeout ?? 25;
    this.handshakeTimer = setTimeout(() => {
      if (this.state === 'connecting') this.close(Disconnect.timedOut);
    }, seconds * 1000);
    this.tls.ready.then(() => {
      if (this.state !== 'connecting') return;
      this.clearTimer();
      this.state = 'ready';
      this.binderLabel = this.tls.binderLabel;
      this.onReady();
    }, () => {});
  }

  start(): void { this.tls.start(); }

  /** A wrong room code shows up as the secure handshake failing; anything later is the line, not the code. */
  private classify(error?: Error): DisconnectReason {
    if (this.closeReason) return this.closeReason;
    if (this.state === 'connecting' && error instanceof TLSError) return Disconnect.authenticationFailed;
    if (error && !(error instanceof TLSError)) return Disconnect.unknown(error.message);
    return Disconnect.networkLost;
  }

  private clearTimer(): void {
    if (this.handshakeTimer) clearTimeout(this.handshakeTimer);
    this.handshakeTimer = null;
  }

  // MARK: Sending

  send(kind: PacketKind, json: unknown, sender?: string): void {
    if (this.state === 'closed') return;
    this.sendPacket(this.codec.encode(kind, json, sender));
  }

  sendEmpty(kind: PacketKind): void {
    if (this.state === 'closed') return;
    this.sendPacket(this.codec.encodeEmpty(kind));
  }

  sendPacket(packet: Packet): void {
    if (this.state === 'closed') return;
    this.tls.write(PacketCodec.bytes(packet));
  }

  ping(): void {
    if (this.state !== 'ready') return;
    this.pingNonce = (this.pingNonce + 1) >>> 0;
    const now = Date.now();
    this.pendingPings.set(this.pingNonce, now);
    // A peer that never answers must not grow this without limit.
    if (this.pendingPings.size > 16) {
      for (const [nonce, at] of this.pendingPings) if (now - at > 10_000) this.pendingPings.delete(nonce);
    }
    this.send(PacketKind.ping, encodePing({ nonce: this.pingNonce, sentAtMilliseconds: now }));
  }

  // MARK: Receiving

  private receive(bytes: Uint8Array): void {
    let packets: Packet[];
    try {
      packets = this.reassembler.append(bytes);
    } catch (e) {
      this.close(Disconnect.unknown(e instanceof WireError ? e.message : String(e)));
      return;
    }
    for (const packet of packets) {
      if (this.state === 'closed') return;
      this.deliver(packet);
    }
  }

  private deliver(packet: Packet): void {
    const kind = packet.header.kind;
    // Late transforms are dropped; everything else always arrives, or the world would drift apart.
    if (kind === PacketKind.playerTransform) {
      const sender = packet.header.senderID;
      const last = this.lastSequence.get(sender);
      if (last !== undefined && !isSequenceNewer(packet.header.sequence, last)) return;
      this.lastSequence.set(sender, packet.header.sequence);
      if (this.lastSequence.size > 256) this.lastSequence.delete(this.lastSequence.keys().next().value!);
    }

    if (kind === PacketKind.handshake) {
      try {
        const payload = decodeHandshake(PacketCodec.json(packet));
        // Who is on the other end is settled by the first handshake; a later one may change how they look, never who they are.
        if (this.remotePeerID === null) this.remotePeerID = payload.peerID;
        if (payload.peerID === this.remotePeerID) this.remoteProfile = payload.profile;
      } catch { /* the owner decides what a bad handshake means */ }
    } else if (kind === PacketKind.ping) {
      // Answered here, so the measured time is the network's, not how busy the page is.
      try { this.send(PacketKind.pong, encodePing(decodePing(PacketCodec.json(packet)))); } catch { /* not a ping */ }
    } else if (kind === PacketKind.pong) {
      try {
        const pong = decodePing(PacketCodec.json(packet));
        const sentAt = this.pendingPings.get(pong.nonce);
        if (sentAt !== undefined) {
          this.pendingPings.delete(pong.nonce);
          this.roundTripMilliseconds = Date.now() - sentAt;
        }
      } catch { /* not a pong */ }
    }
    this.onPacket(packet);
  }

  // MARK: Ending

  /** Ends the link (saying goodbye to the secure session) and the pipe under it. */
  close(reason: DisconnectReason = Disconnect.userLeft): void {
    if (this.state === 'closed') return;
    this.closeReason = reason;
    this.tls.close();
    // A moment for the goodbye to be written before the pipe goes.
    setTimeout(() => this.pipe.close(), 50);
    this.finish(reason);
  }

  private finish(reason: DisconnectReason): void {
    if (this.state === 'closed') return;
    this.state = 'closed';
    this.clearTimer();
    if (!this.pipe.isClosed) setTimeout(() => this.pipe.close(), 50);
    this.onClose(this.closeReason ?? reason);
  }
}
