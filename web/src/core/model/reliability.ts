// What keeps a room safe and together, with no networking in it, so it is
// tested on its own: the room code's shape (RoomCodeFormat.swift), how much
// a guest may send (NetworkSafety.swift), why a connection ended and when to
// try again (Reconnection.swift).
import { L } from '../../i18n';

// MARK: - The room code

/** No I, L, O, U, 0 or 1, so a code read aloud cannot be mistyped into another valid one. */
export const roomCodeAlphabet = 'ABCDEFGHJKMNPQRSTVWXYZ23456789';
export const roomCodeLength = 6;
export const roomCodeNeverUsed = ['O', '0', 'I', '1', 'L', 'U'];

export const RoomCode = {
  /** Uppercased, and anything outside the alphabet dropped: "abc def", "ABC-DEF" and "abcdef" are one code. */
  normalize: (raw: string) => [...raw.toUpperCase()].filter((c) => roomCodeAlphabet.includes(c)).join(''),
  isPlausible: (raw: string) => RoomCode.normalize(raw).length >= 4,
  /** Grouped for showing: `ABC DEF`. */
  formatted(raw: string): string {
    const n = RoomCode.normalize(raw);
    if (n.length <= 4) return n;
    const mid = Math.floor(n.length / 2);
    return `${n.slice(0, mid)} ${n.slice(mid)}`;
  },
  /** A fresh code from the system's secure generator: the session's whole secret. */
  generate(length = roomCodeLength): string {
    const bytes = crypto.getRandomValues(new Uint8Array(length));
    return Array.from(bytes, (b) => roomCodeAlphabet[b % roomCodeAlphabet.length]).join('');
  },
  typing(key: string, code: string): string {
    const current = RoomCode.normalize(code);
    if (key.length !== 1 || !roomCodeAlphabet.includes(key) || current.length >= roomCodeLength) return current;
    return current + key;
  },
  deleting: (code: string) => RoomCode.normalize(code).slice(0, -1),
} as const;

/** A fresh salt for the key made from the room code, new every room. Not a secret. */
export function newKeySalt(): string {
  return Array.from(crypto.getRandomValues(new Uint8Array(16)), (b) => b.toString(16).padStart(2, '0')).join('');
}

export const isPlausibleSalt = (salt: string) => salt.length >= 8 && salt.length <= 64 && /^[0-9a-fA-F]+$/.test(salt);

// MARK: - How much a guest may send

export type BudgetVerdict = 'allow' | 'drop' | 'disconnect';

/** Per second, and how many at once, by packet kind (numbers as on the wire). */
export const packetLimits: ReadonlyMap<number, { rate: number; burst: number }> = new Map([
  [4, { rate: 40, burst: 60 }], // playerTransform: twice the 20 a second a client sends
  [12, { rate: 25, burst: 40 }], // playerInput
  [6, { rate: 40, burst: 80 }], // eventTrigger
  [8, { rate: 1.5, burst: 6 }], // chat
  [13, { rate: 3, burst: 8 }], // room: people tapping, not a stream
  [3, { rate: 400, burst: 800 }], // worldDelta: Studio co-editing, a drag sends one a frame
  [1, { rate: 1, burst: 3 }], // handshake
  [9, { rate: 5, burst: 10 }], // ping
  [10, { rate: 5, burst: 10 }], // pong
  [11, { rate: 2, burst: 4 }], // leave
]);

/**
 * A token bucket per kind: steady play never comes near the rate, a burst
 * is absorbed, and a flood is dropped before it reaches the game or anyone
 * else. A connection that keeps flooding is cut off.
 */
export class PacketBudget {
  static readonly floodLimit = 300;
  static readonly window = 10;

  private buckets = new Map<number, { tokens: number; last: number }>();
  private drops: number[] = [];

  admit(kind: number, time: number): BudgetVerdict {
    // Kinds a guest never sends have no budget; the host ignores them anyway.
    const limit = packetLimits.get(kind);
    if (!limit) return 'allow';
    const bucket = this.buckets.get(kind) ?? { tokens: limit.burst, last: time };
    bucket.tokens = Math.min(limit.burst, bucket.tokens + Math.max(0, time - bucket.last) * limit.rate);
    bucket.last = time;
    this.buckets.set(kind, bucket);
    if (bucket.tokens >= 1) {
      bucket.tokens -= 1;
      return 'allow';
    }
    this.drops.push(time);
    this.drops = this.drops.filter((t) => !(time - t > PacketBudget.window));
    return this.drops.length > PacketBudget.floodLimit ? 'disconnect' : 'drop';
  }
}

/** Remembers addresses that keep failing to get in, and turns them away for a while. */
export class AttemptLimiter {
  static readonly maximumFailures = 15;
  static readonly window = 60;
  static readonly banDuration = 120;

  private failures = new Map<string, number[]>();
  private bannedUntil = new Map<string, number>();

  /** The device itself: every internet guest comes through the relay from here, so one guest's mistakes must not shut out all. */
  static isLoopback(address: string): boolean {
    const bare = address.replace(/^\[|\]$/g, '');
    return bare.startsWith('127.') || bare === '::1' || bare.startsWith('::1%') || bare === 'localhost';
  }

  isBanned(address: string, time: number): boolean {
    if (AttemptLimiter.isLoopback(address)) return false;
    return (this.bannedUntil.get(address) ?? -Infinity) > time;
  }

  recordFailure(address: string, time: number): void {
    if (AttemptLimiter.isLoopback(address)) return;
    const list = (this.failures.get(address) ?? []).filter((t) => time - t <= AttemptLimiter.window);
    list.push(time);
    this.failures.set(address, list);
    if (list.length >= AttemptLimiter.maximumFailures) {
      this.bannedUntil.set(address, time + AttemptLimiter.banDuration);
      this.failures.set(address, []);
    }
  }

  recordSuccess(address: string): void { this.failures.delete(address); }
}

// MARK: - Why a connection ended

export type DisconnectReason =
  | { kind: 'userLeft' }
  | { kind: 'hostClosed' }
  /** The secure handshake failed: in practice, the wrong room code. */
  | { kind: 'authenticationFailed' }
  | { kind: 'protocolMismatch' }
  | { kind: 'sessionFull' }
  | { kind: 'networkLost' }
  | { kind: 'timedOut' }
  | { kind: 'removedByHost' }
  | { kind: 'refusedByHost' }
  | { kind: 'unknown'; detail: string };

export const Disconnect = {
  userLeft: { kind: 'userLeft' } as DisconnectReason,
  hostClosed: { kind: 'hostClosed' } as DisconnectReason,
  authenticationFailed: { kind: 'authenticationFailed' } as DisconnectReason,
  protocolMismatch: { kind: 'protocolMismatch' } as DisconnectReason,
  sessionFull: { kind: 'sessionFull' } as DisconnectReason,
  networkLost: { kind: 'networkLost' } as DisconnectReason,
  timedOut: { kind: 'timedOut' } as DisconnectReason,
  removedByHost: { kind: 'removedByHost' } as DisconnectReason,
  refusedByHost: { kind: 'refusedByHost' } as DisconnectReason,
  unknown: (detail: string): DisconnectReason => ({ kind: 'unknown', detail }),
} as const;

export function sameReason(a: DisconnectReason, b: DisconnectReason): boolean {
  return a.kind === b.kind && (a.kind !== 'unknown' || a.detail === (b as { detail: string }).detail);
}

/** Whether reconnecting stands a chance: a network blip does; a wrong room code does not. */
export function isRetryable(reason: DisconnectReason): boolean {
  return reason.kind === 'networkLost' || reason.kind === 'timedOut' || reason.kind === 'unknown';
}

/** What the player is told: something they can act on where there is an action. */
export function reasonMessage(reason: DisconnectReason): string {
  switch (reason.kind) {
    case 'userLeft': return L('You left the world.');
    case 'hostClosed': return L('The host closed the world.');
    case 'authenticationFailed': return L('Could not connect — check the room code is the same on both iPads.');
    case 'protocolMismatch': return L('That iPad is running a different version of Ablox. Update both to play together.');
    case 'sessionFull': return L('That world is full.');
    case 'networkLost': return L('Lost connection to the host.');
    case 'timedOut': return L('The host stopped responding.');
    case 'removedByHost': return L('The host took you out of this room.');
    case 'refusedByHost': return L("The host didn't let you in this time.");
    case 'unknown': return reason.detail ? reason.detail : L('Disconnected.');
  }
}

// MARK: - When to try again

export class ReconnectPolicy {
  constructor(
    readonly maximumAttempts = 5,
    readonly baseDelay = 0.5,
    readonly maximumDelay = 8,
    readonly jitterFraction = 0.25,
    readonly giveUpAfter = 45,
  ) {}

  static readonly default = new ReconnectPolicy();
  /** Never retries: for a host, which has nothing to reconnect to. */
  static readonly none = new ReconnectPolicy(0, 0.5, 8, 0.25, 0);

  static with(o: Partial<Pick<ReconnectPolicy, 'maximumAttempts' | 'baseDelay' | 'maximumDelay' | 'jitterFraction' | 'giveUpAfter'>>): ReconnectPolicy {
    const d = ReconnectPolicy.default;
    return new ReconnectPolicy(o.maximumAttempts ?? d.maximumAttempts, o.baseDelay ?? d.baseDelay, o.maximumDelay ?? d.maximumDelay,
      o.jitterFraction ?? d.jitterFraction, o.giveUpAfter ?? d.giveUpAfter);
  }

  /** Seconds before attempt `attempt` (1-based): exponential, capped, then jittered downward only. */
  delay(attempt: number, randomFraction = Math.random()): number {
    if (attempt < 1) return 0;
    const capped = Math.min(this.baseDelay * 2 ** (attempt - 1), this.maximumDelay);
    const fraction = Math.max(0, Math.min(1, randomFraction));
    const range = capped * Math.max(0, Math.min(1, this.jitterFraction));
    return Math.max(0, capped - range * fraction);
  }

  shouldAttempt(reason: DisconnectReason, attempt: number, elapsed: number): boolean {
    return isRetryable(reason) && attempt >= 1 && attempt <= this.maximumAttempts && elapsed < this.giveUpAfter;
  }
}

export type ReconnectStatus =
  | { kind: 'idle' }
  | { kind: 'waiting'; attempt: number; until: number }
  | { kind: 'attempting'; attempt: number }
  | { kind: 'gaveUp'; reason: DisconnectReason };

/** An in-progress reconnection — drop, wait, try, wait longer, give up — stepped by the caller's clock. */
export class ReconnectCoordinator {
  status: ReconnectStatus = { kind: 'idle' };
  private reason: DisconnectReason | null = null;
  private disconnectedAt = 0;
  private attempt = 0;

  constructor(public policy: ReconnectPolicy = ReconnectPolicy.default) {}

  get isReconnecting(): boolean { return this.status.kind === 'waiting' || this.status.kind === 'attempting'; }
  get attemptNumber(): number | null {
    return this.status.kind === 'waiting' || this.status.kind === 'attempting' ? this.status.attempt : null;
  }

  disconnected(reason: DisconnectReason, time: number, randomFraction = Math.random()): ReconnectStatus {
    this.reason = reason;
    this.disconnectedAt = time;
    this.attempt = 0;
    if (!this.policy.shouldAttempt(reason, 1, 0)) {
      this.status = { kind: 'gaveUp', reason };
      return this.status;
    }
    this.attempt = 1;
    this.status = { kind: 'waiting', attempt: 1, until: time + this.policy.delay(1, randomFraction) };
    return this.status;
  }

  /** On every tick: true when it is time to make an attempt. */
  shouldAttemptNow(time: number): boolean {
    if (this.status.kind !== 'waiting' || time < this.status.until) return false;
    const attempt = this.status.attempt;
    // The deadline is checked again here: a long backoff can push an attempt past it.
    if (!this.reason || !this.policy.shouldAttempt(this.reason, attempt, time - this.disconnectedAt)) {
      this.status = { kind: 'gaveUp', reason: this.reason ?? Disconnect.unknown('') };
      return false;
    }
    this.status = { kind: 'attempting', attempt };
    return true;
  }

  attemptFailed(time: number, randomFraction = Math.random()): ReconnectStatus {
    if (!this.reason) {
      this.status = { kind: 'idle' };
      return this.status;
    }
    const next = this.attempt + 1;
    const delay = this.policy.delay(next, randomFraction);
    // Checked against when the attempt would run, not now.
    if (!this.policy.shouldAttempt(this.reason, next, time - this.disconnectedAt + delay)) {
      this.status = { kind: 'gaveUp', reason: this.reason };
      return this.status;
    }
    this.attempt = next;
    this.status = { kind: 'waiting', attempt: next, until: time + delay };
    return this.status;
  }

  succeeded(): void {
    this.status = { kind: 'idle' };
    this.reason = null;
    this.attempt = 0;
    this.disconnectedAt = 0;
  }

  cancel(): void {
    this.status = { kind: 'idle' };
    this.reason = null;
    this.attempt = 0;
  }

  /** Brings the next attempt forward to now (the tab is back, so is its network). */
  retryImmediately(time: number): void {
    if (this.status.kind === 'waiting') this.status = { kind: 'waiting', attempt: this.status.attempt, until: time };
  }

  get progressDescription(): string | null {
    const n = this.attemptNumber;
    return n === null ? null : L('Reconnecting… ({} of {})', n, this.policy.maximumAttempts);
  }

  get failureReason(): DisconnectReason | null {
    return this.status.kind === 'gaveUp' ? this.status.reason : null;
  }
}
