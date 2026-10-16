// Chat safety and tidying, as on the iPads (ChatModeration.swift,
// ChatExtras.swift, FamilySafety.swift): a short, mild word filter that masks
// rather than deletes, personal details hidden, shouting softened, long runs
// cut, a flood guard, and the one-tap phrases. Filtering happens on receipt,
// so it covers everyone's lines, not only what this browser sends.
import { graphemeCount, graphemes, trimmed } from './text';

export const defaultBlockedTerms = [
  'damn', 'crap', 'stupid', 'idiot', 'dumb', 'loser',
  'shutup', 'shut up', 'hate you', 'kill you', 'ugly',
  // Japanese has no spaces, so these match inside a sentence: only words
  // with no innocent longer word round them (not ばか, which is in ばかり).
  '死ね', '殺す', 'ころす', 'きもい', 'キモい', 'キモイ', 'うざい', 'ウザい', 'ウザイ', 'ブス', 'アホ', 'バーカ',
];

export const strictTerms = [
  'noob', 'cringe', 'weirdo', 'you suck', 'nobody likes you', 'crybaby',
  // Not くそ, which is in やくそく ("a promise").
  'へたくそ', '下手くそ', 'ヘタクソ', '雑魚', 'ザコ', '消えろ', 'きえろ', 'クソ',
];

export interface FilterResult { text: string; wasFiltered: boolean }

const escape = (s: string) => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
const wordCharacter = /[\p{L}\p{N}]/u;
const isASCII = (s: string) => /^[\x00-\x7f]*$/.test(s);

function lastCharacter(text: string, end: number): string | null {
  if (end <= 0) return null;
  const before = graphemes(text.slice(Math.max(0, end - 8), end));
  return before.length ? before[before.length - 1] : null;
}

function firstCharacter(text: string, start: number): string | null {
  if (start >= text.length) return null;
  return graphemes(text.slice(start, start + 8))[0] ?? null;
}

export class ChatModerator {
  private readonly terms: string[];

  constructor(readonly additionalTerms: string[] = [], readonly isFilterEnabled = true, readonly isStrict = false) {
    // Longest first, so "shut up" goes as one phrase rather than leaving "up".
    this.terms = [...defaultBlockedTerms, ...(isStrict ? strictTerms : []), ...additionalTerms]
      .map((t) => t.toLowerCase())
      .filter((t) => t.length > 0)
      .sort((a, b) => graphemeCount(b) - graphemeCount(a));
  }

  /** Blocked terms masked with asterisks, one for each character, so the shape of the line still reads. */
  filter(text: string): FilterResult {
    if (!this.isFilterEnabled || !text) return { text, wasFiltered: false };
    let output = text;
    let filtered = false;
    for (const term of this.terms) {
      const pattern = new RegExp(escape(term), 'giu');
      const spaced = isASCII(term);
      let from = 0;
      for (;;) {
        pattern.lastIndex = from;
        const match = pattern.exec(output);
        if (!match) break;
        const start = match.index;
        const end = start + match[0].length;
        if (!spaced || ChatModerator.isWholeWord(output, start, end)) {
          const mask = '*'.repeat(graphemeCount(match[0]));
          output = output.slice(0, start) + mask + output.slice(end);
          filtered = true;
          from = start + mask.length;
        } else {
          if (end >= output.length) break;
          from = end;
        }
      }
    }
    return { text: output, wasFiltered: filtered };
  }

  private static isWholeWord(text: string, start: number, end: number): boolean {
    const before = lastCharacter(text, start);
    if (before && wordCharacter.test(before)) return false;
    const after = firstCharacter(text, end);
    if (after && wordCharacter.test(after)) return false;
    return true;
  }

  /** A name the filter would mask becomes "Player": names are checked even with chat filtering off. */
  static cleanName(name: string): string {
    return new ChatModerator().filter(name).wasFiltered ? 'Player' : name;
  }
}

/** Who this browser chose not to hear from. Never leaves the device; our own lines always show. */
export class MuteList {
  private muted: Set<string>;
  constructor(muted: Iterable<string> = []) { this.muted = new Set(muted); }
  get count(): number { return this.muted.size; }
  get all(): string[] { return [...this.muted]; }
  isMuted(peer: string): boolean { return this.muted.has(peer); }
  mute(peer: string): void { this.muted.add(peer); }
  unmute(peer: string): void { this.muted.delete(peer); }
  toggle(peer: string): boolean {
    if (this.muted.delete(peer)) return false;
    this.muted.add(peer);
    return true;
  }
  allows(sender: string, localPeerID: string): boolean { return sender === localPeerID || !this.muted.has(sender); }
}

// MARK: - Tidying

export interface ChatTidyOptions { hidePersonalInfo: boolean; softenShouting: boolean; squashRepeats: boolean }
export const defaultTidyOptions: ChatTidyOptions = { hidePersonalInfo: true, softenShouting: true, squashRepeats: true };

const hidden = '•••';
const email = /[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}/gi;
const link = /\b((https?:\/\/|www\.)\S+|[a-z0-9-]+\.(com|net|org|jp|io|co|me|gg|tv|app|xyz)(\/\S*)?)/gi;
const phone = /[+＋]?[0-9０-９](?:[\s\-.()（）ー－]*[0-9０-９]){6,}/g;

export const ChatTidy = {
  /** Phone numbers, email addresses and links hidden; numbers of up to six digits (scores, times) stay. */
  personalInfoHidden(text: string): string {
    return text.replace(email, hidden).replace(link, hidden).replace(phone, hidden);
  },

  /** "HELLO EVERYONE" as "Hello everyone"; short ones ("OK", "GG") are left. */
  shoutingSoftened(text: string): string {
    const letters = [...text].filter((c) => /[A-Za-z]/.test(c));
    if (letters.length < 8) return text;
    const upper = letters.filter((c) => /[A-Z]/.test(c)).length;
    if (upper / letters.length <= 0.8) return text;
    const lower = text.toLowerCase();
    const [first, ...rest] = graphemes(lower);
    return (first ?? '').toUpperCase() + rest.join('');
  },

  /** More than three of the same character in a row cut to three. */
  repeatsSquashed(text: string): string {
    let output = '';
    let last: string | null = null;
    let run = 0;
    for (const c of graphemes(text)) {
      if (c === last) run += 1;
      else { last = c; run = 1; }
      if (run <= 3) output += c;
    }
    return output;
  },

  /** Whether a line names the player: their name as a word, in any case, or after an @. */
  mentions(name: string, text: string): boolean {
    const n = trimmed(name);
    if (graphemeCount(n) < 2) return false;
    const pattern = new RegExp(escape(n), 'giu');
    for (let match = pattern.exec(text); match; match = pattern.exec(text)) {
      const before = lastCharacter(text, match.index);
      const after = firstCharacter(text, match.index + match[0].length);
      if (!(before && wordCharacter.test(before)) && !(after && wordCharacter.test(after))) return true;
    }
    return false;
  },

  tidy(text: string, options: ChatTidyOptions = defaultTidyOptions): string {
    let output = text;
    if (options.hidePersonalInfo) output = ChatTidy.personalInfoHidden(output);
    if (options.softenShouting) output = ChatTidy.shoutingSoftened(output);
    if (options.squashRepeats) output = ChatTidy.repeatsSquashed(output);
    return output;
  },
};

// MARK: - The flood guard

export type ChatVerdict = { kind: 'ok' } | { kind: 'repeated' } | { kind: 'tooFast'; seconds: number };

/** Five lines in ten seconds at most, and not the same line twice in five. */
export class ChatRateLimiter {
  static readonly window = 10;
  static readonly maximumInWindow = 5;
  static readonly repeatGap = 5;
  private sent: [number, string][] = [];

  private static key = (text: string) => trimmed(text).toLowerCase();

  check(text: string, time: number): ChatVerdict {
    const key = ChatRateLimiter.key(text);
    const recent = this.sent.filter(([t]) => time - t < ChatRateLimiter.window);
    const last = [...recent].reverse().find(([, k]) => k === key);
    if (last && time - last[0] < ChatRateLimiter.repeatGap) return { kind: 'repeated' };
    if (recent.length >= ChatRateLimiter.maximumInWindow) {
      return { kind: 'tooFast', seconds: Math.max(1, Math.ceil(ChatRateLimiter.window - (time - recent[0][0]))) };
    }
    return { kind: 'ok' };
  }

  allow(text: string, time: number): ChatVerdict {
    const verdict = this.check(text, time);
    if (verdict.kind === 'ok') {
      this.sent.push([time, ChatRateLimiter.key(text)]);
      this.sent = this.sent.filter(([t]) => time - t < ChatRateLimiter.window);
    }
    return verdict;
  }
}

// MARK: - One tap

export const quickChatGroups: { id: string; name: string; icon: string; phrases: string[] }[] = [
  { id: 'hello', name: 'Hello', icon: '👋', phrases: ['Hi!', 'Hello everyone!', 'Good morning!', 'Good afternoon!', 'Good evening!', 'Nice to meet you!', 'Welcome!', "What's your name?"] },
  { id: 'play', name: 'Playing', icon: '🎮', phrases: ["Let's play together!", 'Follow me!', 'Over here!', "Let's go!", 'One more round?', 'Ready?', 'Race you!', "Let's team up!", 'Your turn!', 'Watch this!', "Let's build something!", "Let's explore!"] },
  { id: 'help', name: 'Help', icon: '🛟', phrases: ['Help!', 'Wait for me!', "I'm stuck!", 'How do I do this?', 'Can you help me?', 'Where are you?', "I'm on my way!", 'Hold on!'] },
  { id: 'feelings', name: 'Feelings', icon: '❤️', phrases: ['Nice!', 'Good game!', 'Thank you!', 'Sorry!', 'Well done!', 'That was fun!', 'Wow!', 'Cool!', 'Haha!', 'Oops!'] },
  { id: 'bye', name: 'Goodbye', icon: '🚶', phrases: ['See you!', 'I have to go.', 'Bye for now!', 'See you tomorrow!', 'Thanks for playing!', 'Be right back!'] },
];

export const chatEmoji = ['👍', '😂', '❤️', '🎉', '😮', '😢', '😎', '🔥', '👋', '🙏', '⭐️', '💯'];

export const maxChatLength = 240;
