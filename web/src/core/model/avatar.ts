// How a player looks — AbloxCore/AvatarProfile.swift and AvatarStyles.swift.
import { L } from '../../i18n';
import { colorFromHex, palette, rainbow, type ColorRGBA } from './color';
import { decodeColor, encodeColor } from './world';

export const hats = ['none', 'cap', 'crown', 'antenna', 'halo', 'top_hat', 'beanie', 'cowboy', 'wizard', 'pirate', 'chef', 'party',
  'headphones', 'bunny_ears', 'horns', 'flower_crown', 'bow', 'helmet', 'viking', 'beret', 'propeller', 'graduate', 'santa',
  'witch', 'headband'] as const;
export type Hat = (typeof hats)[number];
export const legacyHats: Hat[] = ['none', 'cap', 'crown', 'antenna', 'halo'];

export const faces = ['smile', 'grin', 'wink', 'cool', 'surprised', 'sleepy', 'cat', 'robot', 'heart', 'angry', 'sad', 'tongue',
  'star_eyes', 'dizzy', 'glasses', 'monocle', 'blush', 'alien', 'eyepatch', 'ninja', 'joy', 'mustache', 'fangs', 'happy'] as const;
export type Face = (typeof faces)[number];
export const legacyFaces: Face[] = ['smile', 'grin', 'wink', 'cool', 'surprised', 'sleepy', 'cat', 'robot', 'heart'];

export const pets = ['none', 'cat', 'dog', 'bunny', 'bird', 'slime', 'robot', 'dragon', 'fox', 'panda', 'penguin', 'frog', 'turtle',
  'duck', 'bee', 'ghost', 'unicorn', 'owl'] as const;
export type Pet = (typeof pets)[number];
export const legacyPets: Pet[] = ['none', 'cat', 'dog', 'bunny', 'bird', 'slime', 'robot', 'dragon'];
export const flyingPets: Pet[] = ['bird', 'dragon', 'bee', 'ghost', 'owl'];

export const rides = ['none', 'car', 'sports', 'truck', 'kart', 'bike', 'scooter', 'jetpack', 'hoverboard'] as const;
export type Ride = (typeof rides)[number];
export const seatedRides: Ride[] = ['car', 'sports', 'truck', 'kart'];

export const trails = ['none', 'sparkle', 'fire', 'bubbles', 'hearts', 'stars', 'rainbow', 'snow', 'leaves', 'smoke', 'confetti',
  'magic', 'sand'] as const;
export type Trail = (typeof trails)[number];

export const auras = ['none', 'gold', 'rainbow', 'fire', 'ice', 'shadow', 'electric', 'nature', 'galaxy'] as const;
export type Aura = (typeof auras)[number];

export const namePlates = ['classic', 'sky', 'candy', 'mint', 'sunset', 'gold', 'neon', 'midnight', 'ice', 'lava', 'royal'] as const;
export type NamePlate = (typeof namePlates)[number];

export const bubbleStyles = ['classic', 'night', 'candy', 'sky', 'mint', 'sun', 'comic', 'lava', 'grape', 'cloud', 'gold'] as const;
export type BubbleStyle = (typeof bubbleStyles)[number];

export interface AvatarProfile {
  displayName: string;
  bodyColor: ColorRGBA;
  headColor: ColorRGBA;
  accentColor: ColorRGBA;
  hat: Hat;
  height: number;
  ride: Ride;
  rideColor: ColorRGBA;
  title: string;
  face: Face;
  hatColor?: ColorRGBA;
  pet: Pet;
  petColor: ColorRGBA;
  trail: Trail;
  aura: Aura;
  nameplate: NamePlate;
  bubble: BubbleStyle;
}

const hex = (h: string) => colorFromHex(h)!;

export const defaultProfile = (): AvatarProfile => ({
  displayName: 'Player', bodyColor: hex('#22D3EE'), headColor: hex('#FFD60A'), accentColor: hex('#A855F7'), hat: 'none',
  height: 1, ride: 'none', rideColor: hex('#EF4444'), title: '', face: 'smile', pet: 'none', petColor: hex('#F59E0B'),
  trail: 'none', aura: 'none', nameplate: 'classic', bubble: 'classic',
});

const pick = <T extends string>(list: readonly T[], v: unknown): T | undefined => list.find((x) => x === v);

export function decodeProfile(v: unknown): AvatarProfile {
  const d = defaultProfile();
  const o = (v && typeof v === 'object' ? v : {}) as Record<string, unknown>;
  return {
    displayName: typeof o.displayName === 'string' ? o.displayName : d.displayName,
    bodyColor: decodeColor(o.bodyColor, d.bodyColor),
    headColor: decodeColor(o.headColor, d.headColor),
    accentColor: decodeColor(o.accentColor, d.accentColor),
    hat: pick(hats, o.hatNew) ?? pick(hats, o.hat) ?? 'none',
    height: typeof o.height === 'number' ? Math.fround(o.height) : 1,
    ride: pick(rides, o.ride) ?? 'none',
    rideColor: decodeColor(o.rideColor, d.rideColor),
    title: typeof o.title === 'string' ? o.title : '',
    face: pick(faces, o.faceNew) ?? pick(faces, o.face) ?? 'smile',
    hatColor: o.hatColor ? decodeColor(o.hatColor, d.accentColor) : undefined,
    pet: pick(pets, o.petNew) ?? pick(pets, o.pet) ?? 'none',
    petColor: decodeColor(o.petColor, d.petColor),
    trail: pick(trails, o.trail) ?? 'none',
    aura: pick(auras, o.aura) ?? 'none',
    nameplate: pick(namePlates, o.nameplate) ?? 'classic',
    bubble: pick(bubbleStyles, o.bubble) ?? 'classic',
  };
}

/** As an iPad writes it: newer items under keys of their own, so older iPads still read the rest. */
export function encodeProfile(p: AvatarProfile): Record<string, unknown> {
  const out: Record<string, unknown> = {
    accentColor: encodeColor(p.accentColor), bodyColor: encodeColor(p.bodyColor), displayName: p.displayName,
    headColor: encodeColor(p.headColor), height: p.height, ride: p.ride, rideColor: encodeColor(p.rideColor),
  };
  if (legacyHats.includes(p.hat)) out.hat = p.hat;
  else { out.hat = 'none'; out.hatNew = p.hat; }
  if (p.title) out.title = p.title;
  if (legacyFaces.includes(p.face)) { if (p.face !== 'smile') out.face = p.face; } else out.faceNew = p.face;
  if (p.hatColor) out.hatColor = encodeColor(p.hatColor);
  if (p.pet !== 'none') {
    if (legacyPets.includes(p.pet)) out.pet = p.pet; else out.petNew = p.pet;
    out.petColor = encodeColor(p.petColor);
  }
  if (p.trail !== 'none') out.trail = p.trail;
  if (p.aura !== 'none') out.aura = p.aura;
  if (p.nameplate !== 'classic') out.nameplate = p.nameplate;
  if (p.bubble !== 'classic') out.bubble = p.bubble;
  return out;
}

const control = /[\u0000-\u001f\u007f-\u009f]/g;

/** Safe to show everyone: a short one-line name, a sensible size, real colours. */
export function sanitizedProfile(p: AvatarProfile, cleanName: (s: string) => string = (s) => s): AvatarProfile {
  const unit = (c: ColorRGBA): ColorRGBA => {
    const u = (v: number) => (Number.isFinite(v) ? Math.min(1, Math.max(0, v)) : 0);
    return { r: u(c.r), g: u(c.g), b: u(c.b), a: u(c.a) };
  };
  let name = cleanName([...p.displayName.replace(control, '').trim()].slice(0, 24).join(''));
  if (!name) name = 'Player';
  let title = cleanName([...p.title.replace(control, '').trim()].slice(0, 24).join(''));
  if (title === 'Player') title = '';
  return {
    ...p, displayName: name, title,
    height: Number.isFinite(p.height) ? Math.min(Math.max(p.height, 0.5), 1.6) : 1,
    bodyColor: unit(p.bodyColor), headColor: unit(p.headColor), accentColor: unit(p.accentColor), rideColor: unit(p.rideColor),
  };
}

// MARK: - A look from a peer id

export function stableHash(peerBytes: Uint8Array, seed: number): bigint {
  let hash = BigInt.asUintN(64, 0xcbf29ce484222325n + BigInt(seed));
  for (const byte of peerBytes) {
    hash ^= BigInt(byte);
    hash = BigInt.asUintN(64, hash * 0x100000001b3n);
  }
  return hash;
}

/** The look every iPad gives a player who never chose one. */
export function generatedProfile(peerBytes: Uint8Array, name: string): AvatarProfile {
  const original = palette.slice(0, 12);
  const at = (seed: number, n: number) => Number(stableHash(peerBytes, seed) % BigInt(n));
  return {
    ...defaultProfile(),
    displayName: name,
    bodyColor: original[at(0x9e37, original.length)],
    headColor: original[at(0x85eb, original.length)],
    accentColor: original[at(0xc2b2, original.length)],
    hat: legacyHats[at(0x27d4, legacyHats.length)],
    height: Math.fround(0.9 + Math.fround(at(0x1656, 20)) / 100),
  };
}

// MARK: - Shop facts

export const hatPrice: Record<Hat, number> = {
  none: 0, cap: 75, crown: 75, antenna: 75, halo: 75, beanie: 60, headband: 60, bow: 75, party: 75, beret: 75, headphones: 100,
  bunny_ears: 100, chef: 100, cowboy: 120, pirate: 120, propeller: 120, flower_crown: 120, top_hat: 150, helmet: 150, graduate: 150,
  santa: 150, wizard: 180, witch: 180, horns: 180, viking: 250,
};

export const facePrice: Record<Face, number> = {
  smile: 0, grin: 0, wink: 30, happy: 30, surprised: 40, sleepy: 40, sad: 40, tongue: 40, blush: 40, angry: 60, glasses: 60, dizzy: 60,
  cool: 80, mustache: 80, eyepatch: 80, monocle: 100, joy: 100, fangs: 100, cat: 120, robot: 120, ninja: 120, alien: 140, star_eyes: 140,
  heart: 160,
};

export const petPrice: Record<Pet, number> = {
  none: 0, cat: 150, dog: 150, frog: 150, duck: 150, bunny: 200, turtle: 200, penguin: 200, bird: 250, fox: 250, bee: 250, slime: 300,
  panda: 300, owl: 300, robot: 400, ghost: 400, dragon: 600, unicorn: 600,
};

export const trailPrice: Record<Trail, number> = {
  none: 0, sand: 150, smoke: 150, leaves: 150, bubbles: 200, snow: 200, confetti: 200, sparkle: 250, hearts: 250, stars: 250, fire: 350,
  magic: 350, rainbow: 500,
};

export const auraPrice: Record<Aura, number> = {
  none: 0, nature: 300, ice: 300, shadow: 300, fire: 400, electric: 400, gold: 500, rainbow: 700, galaxy: 700,
};

export const namePlatePrice: Record<NamePlate, number> = {
  classic: 0, sky: 120, candy: 120, mint: 120, sunset: 180, ice: 180, midnight: 180, neon: 250, lava: 250, gold: 400, royal: 400,
};

export const bubblePrice: Record<BubbleStyle, number> = {
  classic: 0, sky: 100, mint: 100, sun: 100, cloud: 100, candy: 150, night: 150, comic: 150, lava: 200, grape: 200, gold: 350,
};

export const hatNames: Record<Hat, string> = {
  none: 'None', cap: 'Cap', crown: 'Crown', antenna: 'Antenna', halo: 'Halo', top_hat: 'Top hat', beanie: 'Beanie', cowboy: 'Cowboy hat',
  wizard: 'Wizard hat', pirate: 'Pirate hat', chef: "Chef's hat", party: 'Party hat', headphones: 'Headphones', bunny_ears: 'Bunny ears',
  horns: 'Horns', flower_crown: 'Flower crown', bow: 'Ribbon bow', helmet: 'Helmet', viking: 'Viking helmet', beret: 'Beret',
  propeller: 'Propeller cap', graduate: 'Graduation cap', santa: 'Santa hat', witch: 'Witch hat', headband: 'Headband',
};
export const hatName = (h: Hat) => L(hatNames[h]);

export const faceNames: Record<Face, string> = {
  smile: 'Smile', grin: 'Grin', wink: 'Wink', cool: 'Sunglasses', surprised: 'Surprised', sleepy: 'Sleepy', cat: 'Cat', robot: 'Robot',
  heart: 'Heart eyes', angry: 'Angry', sad: 'Sad', tongue: 'Tongue out', star_eyes: 'Star eyes', dizzy: 'Dizzy', glasses: 'Round glasses',
  monocle: 'Monocle', blush: 'Blushing', alien: 'Alien', eyepatch: 'Eyepatch', ninja: 'Ninja mask', joy: 'Tears of joy',
  mustache: 'Moustache', fangs: 'Fangs', happy: 'Happy',
};
export const faceName = (f: Face) => L(faceNames[f]);

export const petName = (p: Pet) => L(p === 'none' ? 'None' : p[0].toUpperCase() + p.slice(1));

export const trailNames: Record<Trail, string> = {
  none: 'None', sparkle: 'Sparkle trail', fire: 'Fire trail', bubbles: 'Bubble trail', hearts: 'Heart trail', stars: 'Star trail',
  rainbow: 'Rainbow trail', snow: 'Snow trail', leaves: 'Leaf trail', smoke: 'Smoke trail', confetti: 'Confetti trail',
  magic: 'Magic trail', sand: 'Sand trail',
};
export const trailName = (t: Trail) => L(trailNames[t]);
export const auraName = (a: Aura) => L(a === 'none' ? 'None' : a[0].toUpperCase() + a.slice(1) + ' aura');
/** English names, as the shop keeps them (translated when shown). */
export const capitalized = (raw: string) => raw[0].toUpperCase() + raw.slice(1);
export const petEnglish = (p: Pet) => (p === 'none' ? 'None' : capitalized(p));
export const auraEnglish = (a: Aura) => (a === 'none' ? 'None' : capitalized(a) + ' aura');
export const namePlateEnglish = (n: NamePlate) => (n === 'classic' ? 'Classic' : capitalized(n) + ' name');
export const bubbleEnglish = (b: BubbleStyle) => (b === 'classic' ? 'Classic' : capitalized(b) + ' bubble');
export const namePlateName = (n: NamePlate) => L(n === 'classic' ? 'Classic' : n[0].toUpperCase() + n.slice(1) + ' name');
export const bubbleName = (b: BubbleStyle) => L(b === 'classic' ? 'Classic' : b[0].toUpperCase() + b.slice(1) + ' bubble');

export const trailParticles: Record<Trail, string | null> = {
  none: null, sparkle: 'sparkles', fire: 'fire', bubbles: 'bubbles', hearts: 'hearts', stars: 'stars', rainbow: 'confetti',
  confetti: 'confetti', snow: 'snow', leaves: 'leaves', smoke: 'smoke', magic: 'magic', sand: 'dust',
};

export function trailColor(trail: Trail, time: number): ColorRGBA | null {
  if (trail !== 'rainbow') return null;
  return rainbow[Math.floor(time * 6) % rainbow.length];
}

export const auraColors: Record<Aura, ColorRGBA[]> = {
  none: [],
  gold: [hex('#FACC15'), hex('#FDE68A')],
  rainbow,
  fire: [hex('#F97316'), hex('#EF4444'), hex('#FACC15')],
  ice: [hex('#7DD3FC'), hex('#E0F2FE')],
  shadow: [hex('#4C1D95'), hex('#1E1B4B')],
  electric: [hex('#22D3EE'), hex('#FDE047')],
  nature: [hex('#4ADE80'), hex('#A3E635')],
  galaxy: [hex('#A855F7'), hex('#3B82F6'), hex('#EC4899')],
};

export const auraOrbs: Record<Aura, number> = { none: 0, gold: 0, rainbow: 0, fire: 3, ice: 0, shadow: 0, electric: 4, nature: 3, galaxy: 4 };

export interface CardColours { background: ColorRGBA; text: ColorRGBA; border?: ColorRGBA; accent: ColorRGBA }
const withAlpha = (c: ColorRGBA, a: number): ColorRGBA => ({ ...c, a });
const white = hex('#FFFFFF');

export const namePlateColours: Record<NamePlate, CardColours> = {
  classic: { background: { r: 0, g: 0, b: 0, a: 0.42 }, text: white, accent: hex('#FFD64D') },
  sky: { background: withAlpha(hex('#0EA5E9'), 0.85), text: white, accent: hex('#E0F2FE') },
  candy: { background: withAlpha(hex('#F9A8D4'), 0.92), text: hex('#831843'), border: white, accent: hex('#9D174D') },
  mint: { background: withAlpha(hex('#6EE7B7'), 0.9), text: hex('#064E3B'), accent: hex('#065F46') },
  sunset: { background: withAlpha(hex('#F97316'), 0.88), text: white, border: hex('#FDE047'), accent: hex('#FEF08A') },
  gold: { background: withAlpha(hex('#422006'), 0.85), text: hex('#FACC15'), border: hex('#FACC15'), accent: hex('#FDE68A') },
  neon: { background: { r: 0.02, g: 0.02, b: 0.08, a: 0.8 }, text: hex('#22D3EE'), border: hex('#E879F9'), accent: hex('#E879F9') },
  midnight: { background: withAlpha(hex('#1E1B4B'), 0.9), text: hex('#C7D2FE'), accent: hex('#A5B4FC') },
  ice: { background: withAlpha(hex('#E0F2FE'), 0.9), text: hex('#075985'), border: hex('#7DD3FC'), accent: hex('#0369A1') },
  lava: { background: withAlpha(hex('#7F1D1D'), 0.9), text: hex('#FDBA74'), border: hex('#EF4444'), accent: hex('#FCA5A5') },
  royal: { background: withAlpha(hex('#581C87'), 0.9), text: white, border: hex('#FACC15'), accent: hex('#FACC15') },
};

const dark = hex('#1C1F26');
export const bubbleColours: Record<BubbleStyle, CardColours> = {
  classic: { background: white, text: dark, accent: dark },
  night: { background: hex('#1F2937'), text: hex('#F9FAFB'), accent: white },
  candy: { background: hex('#FBCFE8'), text: hex('#831843'), accent: dark },
  sky: { background: hex('#BAE6FD'), text: hex('#0C4A6E'), accent: dark },
  mint: { background: hex('#BBF7D0'), text: hex('#14532D'), accent: dark },
  sun: { background: hex('#FEF08A'), text: hex('#713F12'), accent: dark },
  comic: { background: white, text: dark, border: dark, accent: dark },
  lava: { background: hex('#EA580C'), text: white, accent: white },
  grape: { background: hex('#7E22CE'), text: white, accent: white },
  cloud: { background: hex('#F1F5F9'), text: hex('#334155'), border: hex('#93C5FD'), accent: dark },
  gold: { background: hex('#FDE68A'), text: hex('#78350F'), border: hex('#D97706'), accent: dark },
};

export const emotes = ['wave', 'dance', 'clap', 'cheer', 'bow', 'point', 'laugh', 'sit', 'hop', 'spin', 'flex', 'shrug', 'think',
  'facepalm', 'salute', 'thumbs_up', 'heart_hands', 'yawn', 'stretch', 'dab', 'floss', 'robot', 'flip', 'cry', 'stomp', 'victory',
  'guitar', 'peace'] as const;
export type Emote = (typeof emotes)[number];
