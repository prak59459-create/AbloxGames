#!/usr/bin/env python3
"""Puts the downloaded sounds into sounds/ and writes sounds/index.json.

    python3 -I tools/sounds/build_index.py DATA_DIR

DATA_DIR is what tools/sounds/harvest.py and walk.py filled: records.json
(each sound's id, title, category and its MP3's size and SHA-256), mp3/ (the
files) and pages/ (each family's page, for the family's name). A file goes
into sounds/<category>/<id>.mp3 only if its size and SHA-256 are the ones
SFXMint lists. Run it again after a harvest: files already there are kept.

The index is what the app reads (AbloxCore/SoundLibrary.swift):

  {"version": 1, "license": "CC0-1.0", "source": ..., "updated": ...,
   "categories": [{"id", "en", "ja", "k"}],
   "families": [{"id", "en", "ja", "k", "c", "s": [[id, ms, bytes, sha256, title]]}]}
"""
import collections, datetime, hashlib, html, json, os, re, shutil, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ja_words import CATEGORIES, WORDS  # noqa: E402

DATA = sys.argv[1]
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
SOUNDS = os.path.join(ROOT, "sounds")
ID = re.compile(r"[a-z0-9]+(-[a-z0-9]+)+")
MAX_BYTES = 4 * 1024 * 1024

records = json.load(open(os.path.join(DATA, "records.json")))


def family_of(sid):
    return re.sub(r"-\d+$", "", sid)


def stem(title):
    title = re.sub(r"\(No Reverb\)", "", title or "")
    title = re.sub(r"\b\d+\b", "", title)
    return title.split()


def page_title(family):
    path = os.path.join(DATA, "pages", f"{family}.html")
    if not os.path.exists(path):
        return ""
    text = open(path, encoding="utf-8", errors="replace").read()
    m = re.search(r'aria-label\\?":\\?"([^"\\]+) variations', text)
    return html.unescape(m.group(1)).strip() if m else ""


def common_title(titles):
    stems = [stem(t) for t in titles if t]
    if not stems:
        return ""
    common = stems[0]
    for s in stems[1:]:
        n = 0
        while n < min(len(common), len(s)) and common[-1 - n].lower() == s[-1 - n].lower():
            n += 1
        common = common[len(common) - n:]
    return " ".join(common or stems[0])


def japanese(title, more, category):
    """The family's name in Japanese words, and more words to find it by:
    readings, the words in its takes' own titles, its category's."""
    shown, words = [], []
    for word in re.findall(r"[A-Za-z0-9][A-Za-z0-9'-]*", title):
        entry = WORDS.get(word.lower())
        if not entry:
            continue
        parts = entry.split()
        if parts[0] not in shown:
            shown.append(parts[0])
        words.extend(parts[1:])
    for word in re.findall(r"[A-Za-z0-9][A-Za-z0-9'-]*", more):
        words.extend(WORDS.get(word.lower(), "").split())
    words.extend(CATEGORIES[category][2].split())
    extra = []
    for w in words:
        if w not in shown and w not in extra:
            extra.append(w)
    return " ".join(shown[:6]), " ".join(extra[:30])


kept = collections.defaultdict(list)
copied = skipped = 0
for sid, r in sorted(records.items()):
    mp3 = r.get("mp3") or {}
    category = r.get("category")
    if not ID.fullmatch(sid) or category not in CATEGORIES or not mp3.get("sha256"):
        skipped += 1
        continue
    # The app takes files up to 4 MB (SoundLibrary.Limits.maximumSoundBytes):
    # that leaves out only an hour of rain, which is no sound effect.
    if (mp3.get("bytes") or 0) > MAX_BYTES:
        print(f"left out {sid}: {mp3['bytes'] / 1048576:.0f} MB")
        stale = os.path.join(SOUNDS, category, f"{sid}.mp3")
        if os.path.exists(stale):
            os.remove(stale)
        skipped += 1
        continue
    source = os.path.join(DATA, "mp3", f"{sid}.mp3")
    target = os.path.join(SOUNDS, category, f"{sid}.mp3")
    have = target if os.path.exists(target) else source if os.path.exists(source) else None
    if not have:
        skipped += 1
        continue
    data = open(have, "rb").read()
    if hashlib.sha256(data).hexdigest() != mp3["sha256"] or len(data) != mp3.get("bytes"):
        print(f"skipped {sid}: not the file SFXMint lists")
        skipped += 1
        continue
    if have != target:
        os.makedirs(os.path.dirname(target), exist_ok=True)
        shutil.copyfile(source, target)
        copied += 1
    kept[family_of(sid)].append((sid, r, len(data)))

families = []
for family, members in kept.items():
    category = collections.Counter(r["category"] for _, r, _ in members).most_common(1)[0][0]
    title = page_title(family) or common_title([r.get("title") for _, r, _ in members]) or family.replace("-", " ").title()
    ja, k = japanese(title, " ".join(r.get("title") or "" for _, r, _ in members), category)
    families.append({
        "id": family, "en": title, "ja": ja, "k": k, "c": category,
        "s": [[sid, int(mp3.get("duration_ms") or r.get("duration_ms") or 0), size, r["mp3"]["sha256"], r.get("title") or ""]
              for sid, r, size in sorted(members, key=lambda m: m[0])
              for mp3 in [r["mp3"]]],
    })
order = list(CATEGORIES)
families.sort(key=lambda f: (order.index(f["c"]), f["en"].lower()))

index = {
    "version": 1,
    "license": "CC0-1.0",
    "source": "SFXMint (https://sfxmint.com), every file CC0 1.0",
    "updated": datetime.date.today().isoformat(),
    "categories": [{"id": c, "en": en, "ja": ja, "k": k} for c, (en, ja, k) in CATEGORIES.items()
                   if any(f["c"] == c for f in families)],
    "families": families,
}
os.makedirs(SOUNDS, exist_ok=True)
with open(os.path.join(SOUNDS, "index.json"), "w", encoding="utf-8") as out:
    json.dump(index, out, ensure_ascii=False, separators=(",", ":"))

count = sum(len(f["s"]) for f in families)
size = sum(s[2] for f in families for s in f["s"])
per = collections.Counter()
per_bytes = collections.Counter()
for f in families:
    per[f["c"]] += len(f["s"])
    per_bytes[f["c"]] += sum(s[2] for s in f["s"])
with open(os.path.join(DATA, "summary.json"), "w") as out:
    json.dump({"sounds": count, "families": len(families), "bytes": size,
               "categories": {c: [per[c], per_bytes[c]] for c in order if per[c]}}, out)
rows = "\n".join(f"| {CATEGORIES[c][1]}（{CATEGORIES[c][0]}） | `sounds/{c}/` | {per[c]:,} | {per_bytes[c] / 1048576:.1f} MB |"
                 for c in order if per[c])
readme = f"""# 効果音ライブラリ（sounds/）

Ablox の「効果音ライブラリ」と、スクリプトの `sound("名前")` が読む効果音です。
**{count:,} 個**、ぜんぶで **{size / 1048576:.0f} MB**。

> The sound library Ablox reads: {count:,} sound effects ({size / 1048576:.0f} MB), every one
> CC0 1.0 from [SFXMint](https://sfxmint.com). `index.json` lists each with its size and
> SHA-256; the app keeps a file only when both match.

## ライセンス

すべて [SFXMint](https://sfxmint.com) の音で、**CC0 1.0**（パブリックドメイン）です。
どのゲームでも自由に使えて、作った人の名前を書く必要もありません。
SFXMint のサイトにある元のファイルと、1バイトも変えていません（SHA-256 で確かめています）。

## 使い方

- Ablox: **設定 → 効果音ライブラリ** で聞く・名前をコピー・**すべてダウンロード**
- スクリプト: `sound("retro-game-coin-08")`、`p.sound("animal-cat-meow-02", {{volume: 0.6}})`
- Ablox Studio: ルールの「音を鳴らす」の ♪ ボタン、スクリプトの「効果音ライブラリ」ボタン

## カテゴリ

| カテゴリ | フォルダ | 数 | 大きさ |
|---|---|---|---|
{rows}

## 作り方

```
python3 -I tools/sounds/harvest.py DATA sitemap.xml   # 一覧のページを読み、MP3 を1つずつダウンロード
python3 -I tools/sounds/walk.py DATA META             # 一覧のページにない テイクを たどって見つける
python3 -I tools/sounds/build_index.py DATA           # SHA-256 を確かめて sounds/ に置き、index.json を書く
```

どれも 1回に1つずつ、間をあけて SFXMint にたずねます（サイトに負担をかけないため）。
日本語の名前と検索語は `tools/sounds/ja_words.py` の単語表から作っています。
"""
open(os.path.join(SOUNDS, "README.md"), "w", encoding="utf-8").write(readme)
print(f"{count} sounds in {len(families)} families, {size / 1e6:.1f} MB; {copied} copied, {skipped} skipped")
