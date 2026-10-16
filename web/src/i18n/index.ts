// The same words as the iPad apps: `L("Play")` is looked up in the Japanese
// table made from AbloxCore/Strings.swift (tools/strings.mjs). An unknown
// string comes back as itself, in English, never as a key.
import ja from './ja.json';
// Words only the web version uses, which the iPad apps' table does not have.
import webJa from './web-ja.json';

export type Language = 'en' | 'ja';

const table = { ...(ja as Record<string, string>), ...(webJa as Record<string, string>) };
let current: Language = pickLanguage();

function pickLanguage(): Language {
  try {
    const saved = localStorage.getItem('ablox.language');
    if (saved === 'en' || saved === 'ja') return saved;
  } catch { /* private mode */ }
  const langs = typeof navigator !== 'undefined' ? navigator.languages ?? [navigator.language] : [];
  return langs.some((l) => l?.toLowerCase().startsWith('ja')) ? 'ja' : 'en';
}

export function language(): Language { return current; }

export function setLanguage(lang: Language): void {
  current = lang;
  try { localStorage.setItem('ablox.language', lang); } catch { /* ignore */ }
  document.documentElement.lang = lang;
}

/** Fills each `{}` with the next argument, in order. */
export function fill(template: string, args: unknown[]): string {
  if (args.length === 0) return template;
  let i = 0;
  return template.replace(/\{\}/g, () => (i < args.length ? String(args[i++]) : '{}'));
}

export function L(english: string, ...args: unknown[]): string {
  const text = current === 'ja' ? table[english] ?? english : english;
  return fill(text, args);
}

/** For tests: the language without touching storage. */
export function useLanguageForTests(lang: Language): void { current = lang; }
