// Who plays in this browser: a peer id made once and kept, and the avatar
// last chosen. Nothing here leaves the browser except the look and the name
// the player picked, when they join a room.
import { decodeProfile, encodeProfile, generatedProfile, type AvatarProfile } from '../core/model/avatar';
import { L } from '../i18n';

const peerKey = 'ablox.peerID';
const profileKey = 'ablox.profile';

function read(key: string): string | null {
  try { return localStorage.getItem(key); } catch { return null; }
}

function write(key: string, value: string): void {
  try { localStorage.setItem(key, value); } catch { /* private mode: forgotten when the tab closes */ }
}

let cachedPeer: string | null = null;

export function localPeerID(): string {
  if (cachedPeer) return cachedPeer;
  let id = read(peerKey);
  if (!id || !/^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$/.test(id)) {
    id = crypto.randomUUID().toUpperCase();
    write(peerKey, id);
  }
  cachedPeer = id;
  return id;
}

export function peerBytes(id: string): Uint8Array {
  const hex = id.replace(/-/g, '');
  return Uint8Array.from(hex.match(/../g)!.map((h) => parseInt(h, 16)));
}

/** The look last saved, or a cheerful one made from the peer id, as a new iPad gives. */
export function loadProfile(): AvatarProfile {
  const text = read(profileKey);
  if (text) {
    try { return decodeProfile(JSON.parse(text)); } catch { /* made again below */ }
  }
  const id = localPeerID();
  const number = parseInt(id.slice(0, 4), 16) % 900 + 100;
  return generatedProfile(peerBytes(id), `${L('Player')}${number}`);
}

export function saveProfile(profile: AvatarProfile): void {
  write(profileKey, JSON.stringify(encodeProfile(profile)));
}
