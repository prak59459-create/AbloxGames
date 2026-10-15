// Reads the translation table of the iPad apps (AbloxCore/Strings.swift)
// and writes it as JSON for the web app, so both say the same words.
//
//   node tools/strings.mjs [path/to/Strings.swift]
import fs from 'node:fs';
import path from 'node:path';

const source = process.argv[2] ?? path.resolve('../../Ablox/Ablox.swiftpm/Sources/AbloxCore/Strings.swift');
const text = fs.readFileSync(source, 'utf8');

// A Swift string literal: "…" with \" \\ \n \t \u{…} escapes.
const literal = String.raw`"((?:[^"\\]|\\.)*)"`;
const pair = new RegExp(String.raw`\(\s*` + literal + String.raw`\s*,\s*` + literal + String.raw`\s*\)`, 'g');

function unescape(s) {
  return s.replace(/\\u\{([0-9a-fA-F]+)\}/g, (_, h) => String.fromCodePoint(parseInt(h, 16)))
    .replace(/\\(.)/g, (_, c) => ({ n: '\n', t: '\t', r: '\r', '0': '\0' })[c] ?? c);
}

const table = {};
let m;
while ((m = pair.exec(text))) table[unescape(m[1])] = unescape(m[2]);
const out = path.resolve('src/i18n/ja.json');
fs.writeFileSync(out, JSON.stringify(table, null, 0) + '\n');
console.log(`${Object.keys(table).length} strings → ${path.relative(process.cwd(), out)}`);
