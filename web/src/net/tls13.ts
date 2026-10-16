// TLS 1.3 with a pre-shared key (RFC 8446), client and server, on WebCrypto.
//
// The iPads secure every game with TLS 1.3 keyed by the room code
// (Net/TLSPeerSecurity.swift): PBKDF2 of the code is the PSK, "ablox" its
// identity, TLS_AES_128_GCM_SHA256 the only cipher suite. Over the internet
// that TLS stream is passed through Firebase byte for byte (CloudRelay.swift),
// so a browser that speaks the same TLS can sit at either end of it: join an
// iPad's room, or host one an iPad joins — with nothing changed on the iPads.
//
// Only what that needs is here: one cipher suite, the PSK modes with and
// without (EC)DHE on X25519 or P-256, HelloRetryRequest both ways, key
// updates, and no certificates at all.
import { Reader, concat, equalBytes, randomBytes, u16, u24, u32, u8, utf8, vector } from './bytes';

const subtle = globalThis.crypto.subtle;

// MARK: - Constants

const enum ContentType { changeCipherSpec = 20, alert = 21, handshake = 22, applicationData = 23 }

const enum Handshake {
  clientHello = 1, serverHello = 2, newSessionTicket = 4, endOfEarlyData = 5, encryptedExtensions = 8,
  certificate = 11, certificateRequest = 13, certificateVerify = 15, finished = 20, keyUpdate = 24, messageHash = 254,
}

const enum Extension {
  supportedGroups = 10, signatureAlgorithms = 13, preSharedKey = 41, earlyData = 42, supportedVersions = 43,
  cookie = 44, pskKeyExchangeModes = 45, keyShare = 51,
}

const enum Alert {
  closeNotify = 0, unexpectedMessage = 10, badRecordMac = 20, handshakeFailure = 40, illegalParameter = 47,
  decodeError = 50, decryptError = 51, protocolVersion = 70, internalError = 80, missingExtension = 109,
}

export const X25519 = 0x001d;
export const P256 = 0x0017;
const TLS13 = 0x0304;
const AES_128_GCM_SHA256 = 0x1301;
const PSK_KE = 0, PSK_DHE_KE = 1;
const MAX_FRAGMENT = 16384;

const helloRetryMagic = Uint8Array.from([
  0xcf, 0x21, 0xad, 0x74, 0xe5, 0x9a, 0x61, 0x11, 0xbe, 0x1d, 0x8c, 0x02, 0x1e, 0x65, 0xb8, 0x91,
  0xc2, 0xa2, 0x11, 0x16, 0x7a, 0xbb, 0x8c, 0x5e, 0x07, 0x9e, 0x09, 0xe2, 0xc8, 0xa8, 0x33, 0x9c,
]);

export class TLSError extends Error {
  constructor(message: string, readonly alert: number = Alert.handshakeFailure, readonly fromPeer = false) {
    super(message);
  }
}

// MARK: - Hashing and key derivation

const zeros32: Uint8Array = new Uint8Array(32);

async function sha256(data: Uint8Array): Promise<Uint8Array> {
  return new Uint8Array(await subtle.digest('SHA-256', data as BufferSource));
}

async function hmac(key: Uint8Array, data: Uint8Array): Promise<Uint8Array> {
  const k = await subtle.importKey('raw', key as BufferSource, { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']);
  return new Uint8Array(await subtle.sign('HMAC', k, data as BufferSource));
}

async function hkdfExtract(salt: Uint8Array, ikm: Uint8Array): Promise<Uint8Array> {
  return hmac(salt.length ? salt : zeros32, ikm);
}

async function hkdfExpand(prk: Uint8Array, info: Uint8Array, length: number): Promise<Uint8Array> {
  const out = new Uint8Array(length);
  let previous: Uint8Array = new Uint8Array(0);
  let filled = 0;
  for (let i = 1; filled < length; i++) {
    previous = await hmac(prk, concat(previous, info, u8(i)));
    out.set(previous.subarray(0, Math.min(previous.length, length - filled)), filled);
    filled += previous.length;
  }
  return out;
}

async function expandLabel(secret: Uint8Array, label: string, context: Uint8Array, length: number): Promise<Uint8Array> {
  const info = concat(u16(length), vector(1, utf8('tls13 ' + label)), vector(1, context));
  return hkdfExpand(secret, info, length);
}

async function deriveSecret(secret: Uint8Array, label: string, transcriptHash: Uint8Array): Promise<Uint8Array> {
  return expandLabel(secret, label, transcriptHash, 32);
}

const emptyHash = sha256(new Uint8Array(0));

/** The binder label: RFC 8446 says "ext binder" for a key agreed outside TLS. */
export type BinderLabel = 'ext binder' | 'res binder';

// MARK: - Key exchange

interface KeyShare {
  group: number;
  publicKey: Uint8Array;
  agree(peer: Uint8Array): Promise<Uint8Array>;
}

let x25519Supported: Promise<boolean> | null = null;

/** Whether this browser's WebCrypto has X25519 (new ones do; older fall back to P-256). */
export function supportsX25519(): Promise<boolean> {
  x25519Supported ??= subtle.generateKey({ name: 'X25519' } as Algorithm, false, ['deriveBits'])
    .then(() => true, () => false);
  return x25519Supported;
}

export async function supportedGroups(): Promise<number[]> {
  return (await supportsX25519()) ? [X25519, P256] : [P256];
}

async function makeKeyShare(group: number): Promise<KeyShare> {
  const algorithm: EcKeyGenParams | Algorithm = group === X25519 ? { name: 'X25519' } : { name: 'ECDH', namedCurve: 'P-256' };
  const pair = (await subtle.generateKey(algorithm, true, ['deriveBits'])) as CryptoKeyPair;
  const publicKey = new Uint8Array(await subtle.exportKey('raw', pair.publicKey));
  return {
    group,
    publicKey,
    async agree(peer: Uint8Array): Promise<Uint8Array> {
      if (group === X25519 && peer.length !== 32) throw new TLSError('bad key share', Alert.illegalParameter);
      if (group === P256 && (peer.length !== 65 || peer[0] !== 4)) throw new TLSError('bad key share', Alert.illegalParameter);
      const imported = await subtle.importKey('raw', peer as BufferSource, algorithm, false, []);
      const bits = new Uint8Array(await subtle.deriveBits({ name: algorithm.name, public: imported } as EcdhKeyDeriveParams,
        pair.privateKey, 256));
      if (equalBytes(bits, zeros32)) throw new TLSError('zero shared secret', Alert.illegalParameter);
      return bits;
    },
  };
}

// MARK: - Record protection

class Cipher {
  private sequence = 0;
  private constructor(private readonly key: CryptoKey, private readonly iv: Uint8Array, readonly secret: Uint8Array) {}

  static async from(secret: Uint8Array): Promise<Cipher> {
    const key = await expandLabel(secret, 'key', new Uint8Array(0), 16);
    const iv = await expandLabel(secret, 'iv', new Uint8Array(0), 12);
    const imported = await subtle.importKey('raw', key as BufferSource, 'AES-GCM', false, ['encrypt', 'decrypt']);
    return new Cipher(imported, iv, secret);
  }

  /** Taken in order, before any await, so records keep their numbers. */
  nextNonce(): Uint8Array {
    const nonce = this.iv.slice();
    let n = this.sequence++;
    for (let i = 11; i >= 4 && n > 0; i--) {
      nonce[i] ^= n & 0xff;
      n = Math.floor(n / 256);
    }
    return nonce;
  }

  async seal(nonce: Uint8Array, header: Uint8Array, plaintext: Uint8Array): Promise<Uint8Array> {
    return new Uint8Array(await subtle.encrypt({ name: 'AES-GCM', iv: nonce as BufferSource, additionalData: header as BufferSource },
      this.key, plaintext as BufferSource));
  }

  async open(nonce: Uint8Array, header: Uint8Array, ciphertext: Uint8Array): Promise<Uint8Array> {
    try {
      return new Uint8Array(await subtle.decrypt({ name: 'AES-GCM', iv: nonce as BufferSource, additionalData: header as BufferSource },
        this.key, ciphertext as BufferSource));
    } catch {
      throw new TLSError('a record failed to decrypt', Alert.badRecordMac);
    }
  }
}

// MARK: - The connection

export interface TLSOptions {
  role: 'client' | 'server';
  psk: Uint8Array;
  identity: Uint8Array;
  /** Bytes for the other end, in order. */
  send: (bytes: Uint8Array) => void;
  /** Which groups to offer or accept; defaults to what this browser has. */
  groups?: number[];
  /** For a client: which binder label to use (see BinderLabel). */
  binderLabel?: BinderLabel;
}

type State =
  | 'start' | 'waitServerHello' | 'waitEncryptedExtensions' | 'waitFinished'
  | 'waitClientHello' | 'waitClientFinished' | 'connected' | 'closed';

interface Message { type: number; bytes: Uint8Array; body: Uint8Array }

/**
 * One TLS 1.3 connection over any byte stream. Feed what arrives to
 * `receive`; what it wants sent comes out through `options.send`.
 */
export class TLSConnection {
  /** Application data, decrypted, in order. */
  onData: (bytes: Uint8Array) => void = () => {};
  /** Once: the connection is over, cleanly (no error) or not. */
  onClose: (error?: Error) => void = () => {};

  readonly ready: Promise<void>;
  /** The binder label the other end used (a server learns it from the client). */
  binderLabel: BinderLabel;

  private state: State = 'start';
  private resolveReady!: () => void;
  private rejectReady!: (e: Error) => void;
  private inbound: Uint8Array = new Uint8Array(0);
  private handshakeBuffer: Uint8Array = new Uint8Array(0);
  private work: Promise<void> = Promise.resolve();
  private sending: Promise<void> = Promise.resolve();
  private readCipher: Cipher | null = null;
  private writeCipher: Cipher | null = null;
  private pendingWrites: Uint8Array[] = [];
  private transcript: Uint8Array[] = [];
  private sentChangeCipherSpec = false;

  // Handshake values.
  private random = randomBytes(32);
  private sessionID = randomBytes(32);
  private keyShares: KeyShare[] = [];
  private retried = false;
  private cookie: Uint8Array | null = null;
  private earlySecret: Uint8Array | null = null;
  private clientHandshakeSecret: Uint8Array | null = null;
  private serverHandshakeSecret: Uint8Array | null = null;
  private clientAppSecret: Uint8Array | null = null;
  private serverAppSecret: Uint8Array | null = null;
  private retryGroup: number | null = null;

  constructor(private readonly options: TLSOptions) {
    this.binderLabel = options.binderLabel ?? 'ext binder';
    this.ready = new Promise((resolve, reject) => {
      this.resolveReady = resolve;
      this.rejectReady = reject;
    });
    this.ready.catch(() => {});
  }

  get isConnected(): boolean { return this.state === 'connected'; }

  /** Settles once everything received so far has been read (decrypting takes a moment). */
  get settled(): Promise<void> { return this.work; }

  /** A client says hello; a server waits for one. */
  start(): void {
    if (this.state !== 'start') return;
    if (this.options.role === 'server') {
      this.state = 'waitClientHello';
      return;
    }
    this.state = 'waitServerHello';
    this.enqueue(async () => {
      const groups = this.options.groups ?? (await supportedGroups());
      this.keyShares = [await makeKeyShare(groups[0])];
      const hello = await this.clientHello(groups, new Uint8Array(0));
      this.writePlain(ContentType.handshake, hello, 0x0301);
      this.transcript.push(hello);
    });
  }

  /** Bytes from the other end. */
  receive(bytes: Uint8Array): void {
    if (this.state === 'closed') return;
    this.inbound = concat(this.inbound, bytes);
    this.enqueue(() => this.readRecords());
  }

  /** Application data; held until the handshake is done. */
  write(bytes: Uint8Array): void {
    if (this.state === 'closed') return;
    if (this.state !== 'connected') {
      this.pendingWrites.push(bytes);
      return;
    }
    for (let i = 0; i < bytes.length; i += MAX_FRAGMENT) {
      this.writeSealed(ContentType.applicationData, bytes.subarray(i, i + MAX_FRAGMENT));
    }
  }

  close(): void {
    if (this.state === 'closed') return;
    this.sendAlert(Alert.closeNotify, 1);
    this.finish();
  }

  // MARK: Plumbing

  private enqueue(job: () => Promise<void>): void {
    this.work = this.work.then(job).catch((error: unknown) => this.fail(error));
  }

  private fail(error: unknown): void {
    if (this.state === 'closed') return;
    const tls = error instanceof TLSError ? error : new TLSError(String((error as Error)?.message ?? error), Alert.internalError);
    if (!tls.fromPeer) this.sendAlert(tls.alert, 2);
    this.finish(tls);
  }

  private finish(error?: Error): void {
    if (this.state === 'closed') return;
    this.state = 'closed';
    if (error) this.rejectReady(error);
    else this.rejectReady(new TLSError('closed before the handshake finished'));
    this.onClose(error);
  }

  private sendAlert(description: number, level: number): void {
    const body = Uint8Array.of(level, description);
    if (this.writeCipher) this.writeSealed(ContentType.alert, body);
    else this.writePlain(ContentType.alert, body);
  }

  private writePlain(type: number, body: Uint8Array, version = 0x0303): void {
    const record = concat(u8(type), u16(version), u16(body.length), body);
    this.sending = this.sending.then(() => this.options.send(record));
  }

  private writeChangeCipherSpec(): void {
    if (this.sentChangeCipherSpec) return;
    this.sentChangeCipherSpec = true;
    this.writePlain(ContentType.changeCipherSpec, Uint8Array.of(1));
  }

  private writeSealed(type: number, body: Uint8Array): void {
    const cipher = this.writeCipher;
    if (!cipher) throw new TLSError('no key to write with', Alert.internalError);
    const inner = concat(body, u8(type));
    const header = concat(u8(ContentType.applicationData), u16(0x0303), u16(inner.length + 16));
    const nonce = cipher.nextNonce();
    const sealed = cipher.seal(nonce, header, inner);
    this.sending = this.sending.then(async () => {
      const ciphertext = await sealed;
      this.options.send(concat(header, ciphertext));
    }).catch((e) => this.fail(e));
  }

  // MARK: Records in

  private async readRecords(): Promise<void> {
    while (this.state !== 'closed' && this.inbound.length >= 5) {
      const type = this.inbound[0];
      const length = (this.inbound[3] << 8) | this.inbound[4];
      if (length > MAX_FRAGMENT + 256) throw new TLSError('record too long', Alert.decodeError);
      if (this.inbound.length < 5 + length) return;
      // Views, not copies: a world arrives as hundreds of records at once.
      const header = this.inbound.subarray(0, 5);
      const fragment = this.inbound.subarray(5, 5 + length);
      this.inbound = this.inbound.subarray(5 + length);
      await this.readRecord(type, header, fragment);
    }
  }

  private async readRecord(type: number, header: Uint8Array, fragment: Uint8Array): Promise<void> {
    if (type === ContentType.changeCipherSpec) {
      // Sent for middleboxes' sake during the handshake; means nothing.
      if (this.state === 'connected' || fragment.length !== 1 || fragment[0] !== 1) {
        throw new TLSError('unexpected change_cipher_spec', Alert.unexpectedMessage);
      }
      return;
    }
    let contentType = type;
    let content = fragment;
    if (type === ContentType.applicationData) {
      if (!this.readCipher) throw new TLSError('encrypted record before keys', Alert.unexpectedMessage);
      const cipher = this.readCipher;
      const plain = await cipher.open(cipher.nextNonce(), header, fragment);
      let end = plain.length - 1;
      while (end >= 0 && plain[end] === 0) end--;
      if (end < 0) throw new TLSError('record with no content type', Alert.unexpectedMessage);
      contentType = plain[end];
      content = plain.subarray(0, end);
    } else if (this.readCipher && type !== ContentType.alert) {
      throw new TLSError('plain record after keys', Alert.unexpectedMessage);
    }

    switch (contentType) {
      case ContentType.alert:
        if (content.length < 2) throw new TLSError('short alert', Alert.decodeError);
        if (content[1] === Alert.closeNotify) {
          this.finish();
          return;
        }
        throw new TLSError(`the other end sent alert ${content[1]}`, content[1], true);
      case ContentType.handshake:
        this.handshakeBuffer = concat(this.handshakeBuffer, content);
        await this.readHandshakeMessages();
        return;
      case ContentType.applicationData:
        if (this.state !== 'connected') throw new TLSError('data before the handshake finished', Alert.unexpectedMessage);
        if (content.length) this.onData(content.slice());
        return;
      default:
        throw new TLSError('unknown record type', Alert.unexpectedMessage);
    }
  }

  private async readHandshakeMessages(): Promise<void> {
    while (this.handshakeBuffer.length >= 4 && this.state !== 'closed') {
      const length = (this.handshakeBuffer[1] << 16) | (this.handshakeBuffer[2] << 8) | this.handshakeBuffer[3];
      if (this.handshakeBuffer.length < 4 + length) return;
      const bytes = this.handshakeBuffer.slice(0, 4 + length);
      this.handshakeBuffer = this.handshakeBuffer.slice(4 + length);
      await this.handle({ type: bytes[0], bytes, body: bytes.subarray(4) });
    }
  }

  private async handle(message: Message): Promise<void> {
    switch (this.state) {
      case 'waitServerHello':
        if (message.type !== Handshake.serverHello) throw unexpected(message);
        return this.serverHello(message);
      case 'waitEncryptedExtensions':
        if (message.type !== Handshake.encryptedExtensions) throw unexpected(message);
        this.transcript.push(message.bytes);
        this.state = 'waitFinished';
        return;
      case 'waitFinished':
        if (message.type !== Handshake.finished) throw unexpected(message);
        return this.serverFinished(message);
      case 'waitClientHello':
        if (message.type !== Handshake.clientHello) throw unexpected(message);
        return this.clientHelloArrived(message);
      case 'waitClientFinished':
        if (message.type !== Handshake.finished) throw unexpected(message);
        return this.clientFinished(message);
      case 'connected':
        if (message.type === Handshake.newSessionTicket) return; // never resumed
        if (message.type === Handshake.keyUpdate) return this.keyUpdate(message);
        throw unexpected(message);
      default:
        throw unexpected(message);
    }
  }

  // MARK: Key schedule

  private async transcriptHash(): Promise<Uint8Array> {
    return sha256(concat(...this.transcript));
  }

  private async binderKey(label: BinderLabel): Promise<Uint8Array> {
    this.earlySecret ??= await hkdfExtract(zeros32, this.options.psk);
    const binder = await deriveSecret(this.earlySecret, label, await emptyHash);
    return expandLabel(binder, 'finished', new Uint8Array(0), 32);
  }

  private async handshakeSecrets(shared: Uint8Array): Promise<void> {
    this.earlySecret ??= await hkdfExtract(zeros32, this.options.psk);
    const derived = await deriveSecret(this.earlySecret, 'derived', await emptyHash);
    const handshakeSecret = await hkdfExtract(derived, shared);
    const hash = await this.transcriptHash();
    this.clientHandshakeSecret = await deriveSecret(handshakeSecret, 'c hs traffic', hash);
    this.serverHandshakeSecret = await deriveSecret(handshakeSecret, 's hs traffic', hash);
    const derivedAgain = await deriveSecret(handshakeSecret, 'derived', await emptyHash);
    this.masterSecret = await hkdfExtract(derivedAgain, zeros32);
  }
  private masterSecret: Uint8Array | null = null;

  /** After the server's Finished is in the transcript. */
  private async applicationSecrets(): Promise<void> {
    const hash = await this.transcriptHash();
    this.clientAppSecret = await deriveSecret(this.masterSecret!, 'c ap traffic', hash);
    this.serverAppSecret = await deriveSecret(this.masterSecret!, 's ap traffic', hash);
  }

  private async finishedData(secret: Uint8Array): Promise<Uint8Array> {
    const key = await expandLabel(secret, 'finished', new Uint8Array(0), 32);
    return hmac(key, await this.transcriptHash());
  }

  private connected(): void {
    this.state = 'connected';
    this.resolveReady();
    const waiting = this.pendingWrites;
    this.pendingWrites = [];
    for (const bytes of waiting) this.write(bytes);
  }

  private async keyUpdate(message: Message): Promise<void> {
    if (message.body.length !== 1 || message.body[0] > 1) throw new TLSError('bad key update', Alert.decodeError);
    const next = await expandLabel(this.readCipher!.secret, 'traffic upd', new Uint8Array(0), 32);
    this.readCipher = await Cipher.from(next);
    if (message.body[0] === 1) {
      const write = await expandLabel(this.writeCipher!.secret, 'traffic upd', new Uint8Array(0), 32);
      const cipher = await Cipher.from(write);
      // The KeyUpdate goes under the old key, everything after it under the new.
      this.writeSealed(ContentType.handshake, concat(u8(Handshake.keyUpdate), u24(1), u8(0)));
      this.writeCipher = cipher;
    }
  }

  // MARK: Client

  private async clientHello(groups: number[], prefix: Uint8Array): Promise<Uint8Array> {
    const identity = this.options.identity;
    const extensions = concat(
      extension(Extension.supportedVersions, vector(1, u16(TLS13))),
      extension(Extension.supportedGroups, vector(2, concat(...groups.map(u16)))),
      extension(Extension.signatureAlgorithms, vector(2, concat(
        u16(0x0403), u16(0x0804), u16(0x0401), u16(0x0503), u16(0x0805), u16(0x0501), u16(0x0806), u16(0x0601),
      ))),
      extension(Extension.keyShare, vector(2, concat(...this.keyShares.map((k) => concat(u16(k.group), vector(2, k.publicKey)))))),
      extension(Extension.pskKeyExchangeModes, vector(1, Uint8Array.of(PSK_DHE_KE, PSK_KE))),
      this.cookie ? extension(Extension.cookie, vector(2, this.cookie)) : new Uint8Array(0),
      // Last, as it must be: the binder covers everything before it.
      extension(Extension.preSharedKey, concat(
        vector(2, concat(vector(2, identity), u32(0))),
        vector(2, vector(1, zeros32)),
      )),
    );
    const body = concat(
      u16(0x0303), this.random, vector(1, this.sessionID), vector(2, u16(AES_128_GCM_SHA256)), vector(1, u8(0)),
      vector(2, extensions),
    );
    const hello = concat(u8(Handshake.clientHello), u24(body.length), body);
    // The binder: the hello up to (not including) the binders list.
    const truncated = hello.subarray(0, hello.length - 35);
    const key = await this.binderKey(this.binderLabel);
    const binder = await hmac(key, await sha256(concat(prefix, truncated)));
    hello.set(binder, hello.length - 32);
    return hello;
  }

  private async serverHello(message: Message): Promise<void> {
    const r = new Reader(message.body);
    r.u16();
    const random = r.take(32);
    const echo = r.vector(1);
    const suite = r.u16();
    r.u8();
    const extensions = parseExtensions(r.vector(2));
    if (!equalBytes(echo, this.sessionID)) throw new TLSError('session id not echoed', Alert.illegalParameter);
    if (suite !== AES_128_GCM_SHA256) throw new TLSError('cipher suite not offered', Alert.illegalParameter);
    const version = extensions.get(Extension.supportedVersions);
    if (!version || new Reader(version).u16() !== TLS13) throw new TLSError('not TLS 1.3', Alert.protocolVersion);

    if (equalBytes(random, helloRetryMagic)) return this.helloRetry(message, extensions);

    const psk = extensions.get(Extension.preSharedKey);
    if (!psk || new Reader(psk).u16() !== 0) throw new TLSError('the room code was not accepted', Alert.handshakeFailure);
    let shared: Uint8Array = zeros32;
    const share = extensions.get(Extension.keyShare);
    if (share) {
      const sr = new Reader(share);
      const group = sr.u16();
      const key = sr.vector(2);
      const mine = this.keyShares.find((k) => k.group === group);
      if (!mine) throw new TLSError('key share for a group not offered', Alert.illegalParameter);
      shared = await mine.agree(key);
    }
    this.transcript.push(message.bytes);
    await this.handshakeSecrets(shared);
    this.readCipher = await Cipher.from(this.serverHandshakeSecret!);
    this.state = 'waitEncryptedExtensions';
  }

  private async helloRetry(message: Message, extensions: Map<number, Uint8Array>): Promise<void> {
    if (this.retried) throw new TLSError('a second HelloRetryRequest', Alert.unexpectedMessage);
    this.retried = true;
    const share = extensions.get(Extension.keyShare);
    const groups = this.options.groups ?? (await supportedGroups());
    if (share) {
      const group = new Reader(share).u16();
      if (!groups.includes(group) || this.keyShares.some((k) => k.group === group)) {
        throw new TLSError('retry asks for a group not offered', Alert.illegalParameter);
      }
      this.keyShares = [await makeKeyShare(group)];
    }
    this.cookie = extensions.get(Extension.cookie)?.slice(2) ?? null;
    // The first hello becomes its hash.
    const first = this.transcript[0];
    this.transcript = [messageHash(await sha256(first)), message.bytes];
    const prefix = concat(...this.transcript);
    const hello = await this.clientHello(groups, prefix);
    this.writeChangeCipherSpec();
    this.writePlain(ContentType.handshake, hello);
    this.transcript.push(hello);
  }

  private async serverFinished(message: Message): Promise<void> {
    const expected = await this.finishedData(this.serverHandshakeSecret!);
    if (!equalBytes(expected, message.body)) throw new TLSError('server Finished did not match', Alert.decryptError);
    this.transcript.push(message.bytes);
    await this.applicationSecrets();
    const verify = await this.finishedData(this.clientHandshakeSecret!);
    this.writeChangeCipherSpec();
    this.writeCipher = await Cipher.from(this.clientHandshakeSecret!);
    this.writeSealed(ContentType.handshake, concat(u8(Handshake.finished), u24(verify.length), verify));
    this.writeCipher = await Cipher.from(this.clientAppSecret!);
    this.readCipher = await Cipher.from(this.serverAppSecret!);
    this.connected();
  }

  // MARK: Server

  private async clientHelloArrived(message: Message): Promise<void> {
    const r = new Reader(message.body);
    r.u16();
    r.take(32);
    const sessionID = r.vector(1);
    const suites = new Reader(r.vector(2));
    let offersSuite = false;
    while (!suites.done) if (suites.u16() === AES_128_GCM_SHA256) offersSuite = true;
    r.vector(1);
    const extensionsStart = 4 + r.offset + 2;
    const extensions = parseExtensions(r.vector(2), true);
    if (!r.done) throw new TLSError('trailing bytes', Alert.decodeError);

    const versions = extensions.get(Extension.supportedVersions);
    let tls13 = false;
    if (versions) {
      const vr = new Reader(versions.subarray(1));
      while (!vr.done) if (vr.u16() === TLS13) tls13 = true;
    }
    if (!tls13) throw new TLSError('client does not offer TLS 1.3', Alert.protocolVersion);
    if (!offersSuite) throw new TLSError('client does not offer TLS_AES_128_GCM_SHA256', Alert.handshakeFailure);

    // The key: find our identity and check its binder.
    const pskBytes = extensions.get(Extension.preSharedKey);
    const modesBytes = extensions.get(Extension.pskKeyExchangeModes);
    if (!pskBytes || !modesBytes) throw new TLSError('client offers no pre-shared key', Alert.missingExtension);
    const pr = new Reader(pskBytes);
    const identities = new Reader(pr.vector(2));
    let chosen = -1;
    for (let i = 0; !identities.done; i++) {
      const identity = identities.vector(2);
      identities.u32();
      if (chosen < 0 && equalBytes(identity, this.options.identity)) chosen = i;
    }
    const bindersStart = pr.offset;
    const binders = new Reader(pr.vector(2));
    const list: Uint8Array[] = [];
    while (!binders.done) list.push(binders.vector(1));
    if (chosen < 0 || chosen >= list.length) throw new TLSError('unknown key identity', Alert.handshakeFailure);
    const pskOffset = extensions.offsets.get(Extension.preSharedKey)!;
    const truncated = message.bytes.subarray(0, extensionsStart + pskOffset + bindersStart);
    const prefix = concat(...this.transcript);
    const hash = await sha256(concat(prefix, truncated));
    let accepted = false;
    for (const label of ['ext binder', 'res binder'] as BinderLabel[]) {
      if (equalBytes(await hmac(await this.binderKey(label), hash), list[chosen])) {
        this.binderLabel = label;
        accepted = true;
        break;
      }
    }
    if (!accepted) throw new TLSError('wrong room code', Alert.decryptError);

    // How to agree the keys.
    const modes = Array.from(modesBytes.subarray(1));
    const ours = this.options.groups ?? (await supportedGroups());
    const shares = new Map<number, Uint8Array>();
    const shareBytes = extensions.get(Extension.keyShare);
    if (shareBytes) {
      const sr = new Reader(new Reader(shareBytes).vector(2));
      while (!sr.done) {
        const group = sr.u16();
        shares.set(group, sr.vector(2));
      }
    }
    const offeredGroups: number[] = [];
    const groupBytes = extensions.get(Extension.supportedGroups);
    if (groupBytes) {
      const gr = new Reader(new Reader(groupBytes).vector(2));
      while (!gr.done) offeredGroups.push(gr.u16());
    }
    let shared: Uint8Array = zeros32;
    let serverShare: KeyShare | null = null;
    if (modes.includes(PSK_DHE_KE)) {
      const group = ours.find((g) => shares.has(g));
      if (group !== undefined) {
        if (this.retryGroup !== null && group !== this.retryGroup) throw new TLSError('wrong group after retry', Alert.illegalParameter);
        serverShare = await makeKeyShare(group);
        shared = await serverShare.agree(shares.get(group)!);
      } else if (!this.retried && ours.some((g) => offeredGroups.includes(g))) {
        return this.sendHelloRetry(message, sessionID, ours.find((g) => offeredGroups.includes(g))!);
      } else if (!modes.includes(PSK_KE)) {
        throw new TLSError('no key share in common', Alert.handshakeFailure);
      }
    } else if (!modes.includes(PSK_KE)) {
      throw new TLSError('no key exchange mode in common', Alert.handshakeFailure);
    }

    this.transcript.push(message.bytes);
    const serverExtensions = concat(
      extension(Extension.supportedVersions, u16(TLS13)),
      serverShare ? extension(Extension.keyShare, concat(u16(serverShare.group), vector(2, serverShare.publicKey))) : new Uint8Array(0),
      extension(Extension.preSharedKey, u16(chosen)),
    );
    const body = concat(u16(0x0303), randomBytes(32), vector(1, sessionID), u16(AES_128_GCM_SHA256), u8(0), vector(2, serverExtensions));
    const hello = concat(u8(Handshake.serverHello), u24(body.length), body);
    this.writePlain(ContentType.handshake, hello);
    this.transcript.push(hello);
    if (sessionID.length) this.writeChangeCipherSpec();

    await this.handshakeSecrets(shared);
    this.writeCipher = await Cipher.from(this.serverHandshakeSecret!);
    this.readCipher = await Cipher.from(this.clientHandshakeSecret!);
    const encrypted = concat(u8(Handshake.encryptedExtensions), u24(2), u16(0));
    this.transcript.push(encrypted);
    const verify = await this.finishedData(this.serverHandshakeSecret!);
    const finished = concat(u8(Handshake.finished), u24(verify.length), verify);
    this.transcript.push(finished);
    this.writeSealed(ContentType.handshake, concat(encrypted, finished));
    await this.applicationSecrets();
    this.writeCipher = await Cipher.from(this.serverAppSecret!);
    this.state = 'waitClientFinished';
  }

  private async sendHelloRetry(message: Message, sessionID: Uint8Array, group: number): Promise<void> {
    this.retried = true;
    this.retryGroup = group;
    const extensions = concat(
      extension(Extension.supportedVersions, u16(TLS13)),
      extension(Extension.keyShare, u16(group)),
    );
    const body = concat(u16(0x0303), helloRetryMagic, vector(1, sessionID), u16(AES_128_GCM_SHA256), u8(0), vector(2, extensions));
    const retry = concat(u8(Handshake.serverHello), u24(body.length), body);
    this.transcript = [messageHash(await sha256(message.bytes)), retry];
    this.writePlain(ContentType.handshake, retry);
    if (sessionID.length) this.writeChangeCipherSpec();
    this.state = 'waitClientHello';
  }

  private async clientFinished(message: Message): Promise<void> {
    const expected = await this.finishedData(this.clientHandshakeSecret!);
    if (!equalBytes(expected, message.body)) throw new TLSError('client Finished did not match', Alert.decryptError);
    this.transcript.push(message.bytes);
    this.readCipher = await Cipher.from(this.clientAppSecret!);
    this.connected();
  }
}

// MARK: - Messages

function extension(type: number, body: Uint8Array): Uint8Array {
  return concat(u16(type), vector(2, body));
}

interface Extensions extends Map<number, Uint8Array> { offsets: Map<number, number> }

/** Extension bodies by type, and where each starts (for the binder). */
function parseExtensions(bytes: Uint8Array, pskMustBeLast = false): Extensions {
  const map = new Map<number, Uint8Array>() as Extensions;
  map.offsets = new Map();
  const r = new Reader(bytes);
  while (!r.done) {
    const start = r.offset;
    const type = r.u16();
    const body = r.vector(2);
    if (map.has(type)) throw new TLSError('an extension twice', Alert.illegalParameter);
    if (pskMustBeLast && map.has(Extension.preSharedKey)) throw new TLSError('pre_shared_key not last', Alert.illegalParameter);
    map.set(type, body);
    map.offsets.set(type, start + 4);
  }
  return map;
}

function messageHash(hash: Uint8Array): Uint8Array {
  return concat(u8(Handshake.messageHash), u24(hash.length), hash);
}

function unexpected(message: Message): TLSError {
  return new TLSError(`unexpected handshake message ${message.type}`, Alert.unexpectedMessage);
}

// MARK: - The room code as a key

/**
 * PBKDF2-HMAC-SHA256 of the normalised room code, salted with
 * "ablox.psk.v2:" + the session's salt, 120,000 rounds: the iPads' key.
 */
export async function roomKey(normalizedCode: string, salt: string): Promise<Uint8Array> {
  const base = await subtle.importKey('raw', utf8(normalizedCode) as BufferSource, 'PBKDF2', false, ['deriveBits']);
  const bits = await subtle.deriveBits({ name: 'PBKDF2', hash: 'SHA-256', salt: utf8('ablox.psk.v2:' + salt) as BufferSource, iterations: 120_000 },
    base, 256);
  return new Uint8Array(bits);
}

export const pskIdentity = utf8('ablox');
