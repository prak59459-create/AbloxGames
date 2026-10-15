// TLS 1.3 with a pre-shared key, against itself and against OpenSSL — a
// second, independent implementation of the same RFC, as the iPads' is.
import { spawn, type ChildProcess } from 'node:child_process';
import { createServer, Socket, type AddressInfo } from 'node:net';
import { afterEach, describe, expect, it } from 'vitest';
import { concat, fromUtf8, hex, utf8 } from '../src/net/bytes';
import { P256, TLSConnection, X25519, pskIdentity, roomKey } from '../src/net/tls13';

const psk = Uint8Array.from({ length: 32 }, (_, i) => (i * 7 + 3) & 0xff);
const children: ChildProcess[] = [];

afterEach(() => {
  for (const c of children.splice(0)) c.kill('SIGKILL');
});

/** Two connections wired to each other. */
function pair(client: Partial<ConstructorParameters<typeof TLSConnection>[0]> = {}, server: Partial<ConstructorParameters<typeof TLSConnection>[0]> = {}) {
  let c!: TLSConnection, s!: TLSConnection;
  c = new TLSConnection({ role: 'client', psk, identity: pskIdentity, send: (b) => queueMicrotask(() => s.receive(b)), ...client });
  s = new TLSConnection({ role: 'server', psk, identity: pskIdentity, send: (b) => queueMicrotask(() => c.receive(b)), ...server });
  s.start();
  c.start();
  return { c, s };
}

function collect(conn: TLSConnection): { text: () => string } {
  const parts: Uint8Array[] = [];
  conn.onData = (b) => parts.push(b);
  return { text: () => fromUtf8(concat(...parts)) };
}

const until = async (check: () => boolean, ms = 5000) => {
  const start = Date.now();
  while (!check()) {
    if (Date.now() - start > ms) throw new Error('timed out');
    await new Promise((r) => setTimeout(r, 10));
  }
};

describe('TLS 1.3 PSK, both ends ours', () => {
  it('connects and carries data both ways', async () => {
    const { c, s } = pair();
    const fromServer = collect(c), fromClient = collect(s);
    await Promise.all([c.ready, s.ready]);
    c.write(utf8('hello from the guest'));
    s.write(utf8('hello from the host'));
    await until(() => fromServer.text().length > 0 && fromClient.text().length > 0);
    expect(fromClient.text()).toBe('hello from the guest');
    expect(fromServer.text()).toBe('hello from the host');
  });

  it('carries a world-sized message in order', async () => {
    const { c, s } = pair();
    const parts: Uint8Array[] = [];
    s.onData = (b) => parts.push(b);
    const big = Uint8Array.from({ length: 600_000 }, (_, i) => (i * 31) & 0xff);
    c.write(big);
    await until(() => parts.reduce((n, p) => n + p.length, 0) >= big.length);
    expect(hex(concat(...parts)).slice(0, 4000)).toBe(hex(big).slice(0, 4000));
    expect(concat(...parts)).toEqual(big);
  });

  it('agrees on P-256 too', async () => {
    const { c, s } = pair({ groups: [P256] }, { groups: [P256] });
    await Promise.all([c.ready, s.ready]);
  });

  it('retries when the first key share is not one the host takes', async () => {
    const { c, s } = pair({ groups: [X25519, P256] }, { groups: [P256] });
    const got = collect(s);
    await Promise.all([c.ready, s.ready]);
    c.write(utf8('after a retry'));
    await until(() => got.text().length > 0);
    expect(got.text()).toBe('after a retry');
  });

  it('works without (EC)DHE when the host has no group in common', async () => {
    const { c, s } = pair({ groups: [X25519] }, { groups: [] });
    await Promise.all([c.ready, s.ready]);
  });

  it('refuses the wrong room code at both ends', async () => {
    const wrong = new Uint8Array(32).fill(9);
    const { c, s } = pair({ psk: wrong });
    await expect(s.ready).rejects.toThrow();
    await expect(c.ready).rejects.toThrow();
  });

  it('accepts a guest using the resumption binder label', async () => {
    const { c, s } = pair({ binderLabel: 'res binder' });
    await Promise.all([c.ready, s.ready]);
    expect(s.binderLabel).toBe('res binder');
  });
});

// MARK: - Against OpenSSL

function openssl(args: string[]): ChildProcess {
  const child = spawn('openssl', args, { stdio: ['pipe', 'pipe', 'pipe'] });
  children.push(child);
  return child;
}

async function freePort(): Promise<number> {
  const server = createServer();
  await new Promise<void>((r) => server.listen(0, '127.0.0.1', () => r()));
  const port = (server.address() as AddressInfo).port;
  await new Promise<void>((r) => server.close(() => r()));
  return port;
}

const common = ['-tls1_3', '-ciphersuites', 'TLS_AES_128_GCM_SHA256', '-psk', hex(psk), '-psk_identity', 'ablox'];

describe('TLS 1.3 PSK against OpenSSL', () => {
  for (const [name, groups] of [['X25519', 'X25519'], ['P-256', 'P-256']] as const) {
    it(`joins an OpenSSL host (${name})`, async () => {
      const port = await freePort();
      const server = openssl(['s_server', '-accept', String(port), '-nocert', '-rev', '-groups', groups, ...common]);
      let ready = false;
      server.stdout!.on('data', (d) => { if (String(d).includes('ACCEPT')) ready = true; });
      await until(() => ready);

      const socket = new Socket();
      await new Promise<void>((r) => socket.connect(port, '127.0.0.1', () => r()));
      const tls = new TLSConnection({ role: 'client', psk, identity: pskIdentity, send: (b) => socket.write(b) });
      socket.on('data', (d) => tls.receive(new Uint8Array(d)));
      const got = collect(tls);
      tls.start();
      await tls.ready;
      tls.write(utf8('ablox\n'));
      await until(() => got.text().includes('xolba'));
      socket.destroy();
    });
  }

  it('is joined by an OpenSSL guest', async () => {
    const server = createServer();
    await new Promise<void>((r) => server.listen(0, '127.0.0.1', () => r()));
    const port = (server.address() as AddressInfo).port;
    let received = '';
    server.on('connection', (socket) => {
      const tls = new TLSConnection({ role: 'server', psk, identity: pskIdentity, send: (b) => socket.write(b) });
      tls.onData = (b) => {
        received += fromUtf8(b);
        tls.write(utf8('HOST:' + fromUtf8(b)));
      };
      socket.on('data', (d) => tls.receive(new Uint8Array(d)));
      tls.start();
    });
    const client = openssl(['s_client', '-connect', `127.0.0.1:${port}`, '-quiet', ...common]);
    let output = '';
    client.stdout!.on('data', (d) => { output += String(d); });
    client.stdin!.write('ping\n');
    await until(() => output.includes('HOST:ping'));
    expect(received).toContain('ping');
    server.close();
  });

  it('is joined by an OpenSSL guest that offers P-256 only (a retry)', async () => {
    const server = createServer();
    await new Promise<void>((r) => server.listen(0, '127.0.0.1', () => r()));
    const port = (server.address() as AddressInfo).port;
    server.on('connection', (socket) => {
      const tls = new TLSConnection({ role: 'server', psk, identity: pskIdentity, groups: [X25519, P256], send: (b) => socket.write(b) });
      tls.onData = (b) => tls.write(utf8('HOST:' + fromUtf8(b)));
      socket.on('data', (d) => tls.receive(new Uint8Array(d)));
      tls.start();
    });
    const client = openssl(['s_client', '-connect', `127.0.0.1:${port}`, '-quiet', '-groups', 'P-256', ...common]);
    let output = '';
    client.stdout!.on('data', (d) => { output += String(d); });
    client.stdin!.write('retry\n');
    await until(() => output.includes('HOST:retry'));
    server.close();
  });
});

describe('the room code as a key', () => {
  it('is PBKDF2-SHA256 of the code with the session salt', async () => {
    const key = await roomKey('ABC234', 'dc2d3b58153e9d19b2efb617785d747a');
    expect(key.length).toBe(32);
    // The same derivation, done by OpenSSL's own PBKDF2.
    const child = openssl(['kdf', '-keylen', '32', '-kdfopt', 'digest:SHA256', '-kdfopt', 'pass:ABC234',
      '-kdfopt', 'salt:ablox.psk.v2:dc2d3b58153e9d19b2efb617785d747a', '-kdfopt', 'iter:120000', 'PBKDF2']);
    let out = '';
    child.stdout!.on('data', (d) => { out += String(d); });
    await until(() => out.includes(':'), 10000);
    expect(out.trim().replace(/:/g, '').toLowerCase()).toBe(hex(key));
  });
});
