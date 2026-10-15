// Swift's view of text, for the limits the iPads put on it: counted in
// characters as a person sees them ("👍🏽" is one), and trimmed of the same
// spaces and line breaks.

const simple = /^[\x00-\x0c\x0e-˿]*$/;
let segmenter: Intl.Segmenter | null = null;

export function graphemes(text: string): string[] {
  if (simple.test(text)) return text.split('');
  segmenter ??= new Intl.Segmenter(undefined, { granularity: 'grapheme' });
  return Array.from(segmenter.segment(text), (s) => s.segment);
}

export function graphemeCount(text: string): number {
  return simple.test(text) ? text.length : graphemes(text).length;
}

/** `String(text.prefix(n))`. */
export function prefix(text: string, n: number): string {
  if (n <= 0) return '';
  if (simple.test(text)) return text.length <= n ? text : text.slice(0, n);
  const parts = graphemes(text);
  return parts.length <= n ? text : parts.slice(0, n).join('');
}

/** `trimmingCharacters(in: .whitespacesAndNewlines)`. */
export function trimmed(text: string): string {
  return text.replace(/^[\p{Z}\t\n\v\f\r\u0085]+|[\p{Z}\t\n\v\f\r\u0085]+$/gu, '');
}

/** `trimmingCharacters(in: .whitespaces)`: spaces and tabs, not line breaks. */
export function trimmedSpaces(text: string): string {
  return text.replace(/^[\p{Zs}\t]+|[\p{Zs}\t]+$/gu, '');
}

/** `caseInsensitiveCompare(_:) == .orderedSame`, near enough: by lower case. */
export function sameIgnoringCase(a: string, b: string): boolean {
  return a === b || a.toLowerCase() === b.toLowerCase();
}
