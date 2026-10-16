// The joining side of a room (Net/AbloxClient.swift): one secure link to the
// host, and the world, roster and effects it sends back. The host may be an
// iPad or another browser; either way the link goes through the internet
// relay (relay.ts) as the same TLS stream an iPad would send.
import type { AvatarProfile } from '../core/model/avatar';
import type { WorldDelta } from '../core/model/liveWorld';
import type { PlayerInput, PlayerSnapshot, PlayerTransform } from '../core/model/player';
import { Disconnect, RoomCode, sameReason, type DisconnectReason } from '../core/model/reliability';
import { repairWorld, type WorldDocument } from '../core/model/world';
import { PeerLink } from './link';
import {
  AbloxProtocol, PacketCodec, PacketKind, chatPayload, encodeChat, encodeHandshake, encodePlayerInput, encodeRoom, encodeTransformPayload,
  encodeTrigger, encodeWorldDelta, readPacket, type ChatPayload, type EventEffectPayload, type HostMove, type Packet, type RoomMessage, type TriggerCause,
} from './packets';
import type { BytePipe } from './relay';
import { roomKey, type BinderLabel } from './tls13';

export type ClientState =
  | { kind: 'idle' }
  | { kind: 'connecting' }
  /** Connected, but the world has not arrived yet. */
  | { kind: 'handshaking' }
  | { kind: 'playing' }
  | { kind: 'disconnected'; reason: DisconnectReason };

const sameState = (a: ClientState, b: ClientState) =>
  a.kind === b.kind && (a.kind !== 'disconnected' || sameReason(a.reason, (b as { reason: DisconnectReason }).reason));

/** How to reach a room: something that opens a fresh pipe to its host, and the code and salt its key is made from. */
export interface RoomRoute {
  open: () => Promise<BytePipe>;
  code: string;
  salt: string;
}

// The TLS binder label an iPad host takes is remembered once one works.
const binderKey = 'ablox.tls.binder';
function rememberedBinder(): BinderLabel {
  try {
    const v = localStorage.getItem(binderKey);
    if (v === 'res binder' || v === 'ext binder') return v;
  } catch { /* not kept */ }
  return 'ext binder';
}
function rememberBinder(label: BinderLabel): void {
  try { localStorage.setItem(binderKey, label); } catch { /* not kept */ }
}

const keys = new Map<string, Promise<Uint8Array>>();
/** The room's key, made once per code and salt (it is deliberately slow to make). */
export function keyFor(code: string, salt: string): Promise<Uint8Array> {
  const id = RoomCode.normalize(code) + ':' + salt;
  let key = keys.get(id);
  if (!key) {
    key = roomKey(RoomCode.normalize(code), salt);
    keys.set(id, key);
    key.catch(() => keys.delete(id));
  }
  return key;
}

export class RoomClient {
  onStateChange: (state: ClientState) => void = () => {};
  onWorld: (world: WorldDocument) => void = () => {};
  onDelta: (delta: WorldDelta) => void = () => {};
  onRoster: (roster: PlayerSnapshot[]) => void = () => {};
  onTransform: (transform: PlayerTransform) => void = () => {};
  onEffects: (payload: EventEffectPayload) => void = () => {};
  onChat: (sender: string, payload: ChatPayload) => void = () => {};
  /** The room: its state, whispers, waiting at the door. */
  onRoom: (message: RoomMessage) => void = () => {};
  /** The host is leaving and the room is moving to someone else. */
  onHostMove: (move: HostMove) => void = () => {};

  hostPeerID: string | null = null;
  worldName = '';
  /** How many the room takes, as its host said. */
  capacity: number | null = null;
  private _state: ClientState = { kind: 'idle' };
  private readonly codec: PacketCodec;
  private link: PeerLink | null = null;
  private pingTimer: ReturnType<typeof setInterval> | null = null;
  /** Kept so a reconnect needs nothing typed in again. */
  private lastRoute: RoomRoute | null = null;
  private attempt = 0;

  constructor(readonly localPeerID: string, private profile: AvatarProfile) {
    this.codec = new PacketCodec(localPeerID);
  }

  get state(): ClientState { return this._state; }
  private setState(state: ClientState): void {
    if (sameState(state, this._state)) return;
    this._state = state;
    this.onStateChange(state);
  }

  /** Round-trip time to the host, in milliseconds. */
  get pingMilliseconds(): number | null { return this.link?.roundTripMilliseconds ?? null; }

  // MARK: Life

  connect(route: RoomRoute): void {
    this.drop(null);
    this.lastRoute = route;
    this.setState({ kind: 'connecting' });
    void this.open(route, rememberedBinder(), true);
  }

  /** Back into the room this client was last in; false when there is nothing to go back to. */
  reconnect(): boolean {
    if (!this.lastRoute) return false;
    this.connect(this.lastRoute);
    return true;
  }

  /** Leaves on purpose: nothing will try to reconnect. */
  disconnect(): void {
    this.lastRoute = null;
    this.drop(Disconnect.userLeft);
  }

  private drop(reason: DisconnectReason | null): void {
    this.stopPinging();
    const link = this.link;
    this.link = null;
    this.attempt += 1;
    if (link) {
      link.sendEmpty(PacketKind.leave);
      link.close(reason ?? Disconnect.userLeft);
    }
    if (reason) this.setState({ kind: 'disconnected', reason });
  }

  private async open(route: RoomRoute, label: BinderLabel, mayRetry: boolean): Promise<void> {
    const attempt = this.attempt;
    let psk: Uint8Array, pipe: BytePipe;
    try {
      psk = await keyFor(route.code, route.salt);
      pipe = await route.open();
    } catch (e) {
      if (attempt !== this.attempt) return;
      // A room that has closed is not tried again; anything else (no network yet) may be.
      if ((e as Error)?.name === 'RoomClosedError') {
        this.lastRoute = null;
        this.setState({ kind: 'disconnected', reason: Disconnect.hostClosed });
      } else {
        this.setState({ kind: 'disconnected', reason: Disconnect.unknown(String((e as Error)?.message ?? e)) });
      }
      return;
    }
    if (attempt !== this.attempt) {
      pipe.close();
      return;
    }
    const link = new PeerLink({ role: 'client', psk, pipe, codec: this.codec, binderLabel: label });
    this.link = link;
    link.onReady = () => {
      if (this.link !== link) return;
      rememberBinder(label);
      this.setState({ kind: 'handshaking' });
      // Introduce ourselves; the host replies with the world.
      link.send(PacketKind.handshake, this.handshake());
      this.startPinging();
    };
    link.onPacket = (packet) => { if (this.link === link) this.handle(packet); };
    link.onClose = (reason) => {
      if (this.link !== link) return;
      this.link = null;
      this.stopPinging();
      // An iPad may take the other binder label: a wrong-code failure is tried once more with it.
      if (reason.kind === 'authenticationFailed' && mayRetry && this.lastRoute === route) {
        void this.open(route, label === 'ext binder' ? 'res binder' : 'ext binder', false);
        return;
      }
      if (this._state.kind !== 'disconnected') this.setState({ kind: 'disconnected', reason });
    };
    link.start();
  }

  private handshake() {
    return encodeHandshake({ protocolVersion: AbloxProtocol.version, peerID: this.localPeerID, profile: this.profile, worldName: '', isHost: false, capacity: AbloxProtocol.defaultCapacity });
  }

  // MARK: Packets

  private handle(packet: Packet): void {
    let message;
    try { message = readPacket(packet); } catch { return; }
    switch (message.kind) {
      case PacketKind.handshake: {
        if (message.handshake.protocolVersion !== AbloxProtocol.version) {
          // Retrying would fail the same way; say so instead.
          this.lastRoute = null;
          this.drop(Disconnect.protocolMismatch);
          return;
        }
        this.hostPeerID = message.handshake.peerID;
        this.worldName = message.handshake.worldName;
        this.capacity = message.handshake.capacity;
        return;
      }
      case PacketKind.worldSnapshot:
        // Mended as a file would be: one bad number from a host must not send the camera to infinity.
        this.setState({ kind: 'playing' });
        this.onWorld(repairWorld(message.world).world);
        return;
      case PacketKind.worldDelta: this.onDelta(message.delta); return;
      case PacketKind.roster: this.onRoster(message.players); return;
      case PacketKind.playerTransform:
        // Our own movement echoed back would fight the local simulation.
        if (message.transform.peerID !== this.localPeerID) this.onTransform(message.transform);
        return;
      case PacketKind.eventEffect: this.onEffects(message.effects); return;
      case PacketKind.chat:
        // Everything comes through the host, which stamps who really said it.
        this.onChat(message.chat.senderID ?? packet.header.senderID, message.chat);
        return;
      case PacketKind.leave:
        if (message.leave && message.leave.peerID === this.hostPeerID) {
          // Deliberate on the host's part: nothing to come back to.
          this.lastRoute = null;
          this.drop(Disconnect.hostClosed);
        }
        return;
      case PacketKind.room: {
        const room = message.room;
        if (room.type === 'removed' || room.type === 'refused') {
          this.lastRoute = null;
          this.drop(room.type === 'removed' ? Disconnect.removedByHost : Disconnect.refusedByHost);
        } else if (room.type === 'moving') {
          this.lastRoute = null;
          this.onHostMove(room.move);
        } else {
          this.onRoom(room);
        }
        return;
      }
      default: return;
    }
  }

  // MARK: Sending

  private get playing(): PeerLink | null { return this._state.kind === 'playing' ? this.link : null; }

  sendRoom(message: RoomMessage): void { this.playing?.send(PacketKind.room, encodeRoom(message)); }

  publishLocalTransform(s: PlayerSnapshot): void {
    this.playing?.send(PacketKind.playerTransform, encodeTransformPayload({ peerID: this.localPeerID, position: s.position, yawDegrees: s.yawDegrees, velocity: s.velocity, isGrounded: s.isGrounded }));
  }

  report(blockID: string, cause: TriggerCause): void {
    this.playing?.send(PacketKind.eventTrigger, encodeTrigger({ peerID: this.localPeerID, blockID, cause }));
  }

  /** Fire, reload, a screen button. The host decides what happened. */
  sendInput(input: PlayerInput): void {
    this.playing?.send(PacketKind.playerInput, encodePlayerInput({ peerID: this.localPeerID, input }));
  }

  sendChat(text: string): void {
    this.link?.send(PacketKind.chat, encodeChat(chatPayload(this.profile.displayName, text)));
  }

  /** Studio co-editing: an edit for the host to pass on. */
  publish(delta: WorldDelta): void { this.link?.send(PacketKind.worldDelta, encodeWorldDelta(delta)); }

  updateProfile(profile: AvatarProfile): void {
    this.profile = profile;
    this.link?.send(PacketKind.handshake, this.handshake());
  }

  // MARK: Ping

  private startPinging(): void {
    this.stopPinging();
    setTimeout(() => this.link?.ping(), 1000);
    this.pingTimer = setInterval(() => this.link?.ping(), 2000);
  }

  private stopPinging(): void {
    if (this.pingTimer) clearInterval(this.pingTimer);
    this.pingTimer = null;
  }
}
