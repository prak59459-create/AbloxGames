#!/usr/bin/env python3
"""Mirrors the whole SFXMint library (CC0), politely.

usage: harvest.py DATA_DIR SITEMAP_XML

  1. Reads every /sounds/<family> page the sitemap lists (one request each,
     cached), and takes the sound records the page carries: id, title,
     category, durations, MP3 bytes and SHA-256.
  2. Downloads each MP3 from /dl/<id>.mp3 into DATA_DIR/mp3/, one at a time,
     and keeps it only when its size and SHA-256 match the record.

Writes DATA_DIR/records.json (id -> record, with the family's title and
description) and DATA_DIR/harvest.log. A rerun skips what it already has.
"""
import hashlib, html, json, os, re, ssl, sys, time, urllib.request

DATA, SITEMAP = sys.argv[1], sys.argv[2]
os.makedirs(f"{DATA}/pages", exist_ok=True)
os.makedirs(f"{DATA}/mp3", exist_ok=True)
CTX = ssl.create_default_context(cafile="/root/.ccr/ca-bundle.crt")
UA = "AbloxSoundLibrary/1.0 (+https://github.com/prak59459-create/Ablox; one-time CC0 mirror, one request at a time)"
log = open(f"{DATA}/harvest.log", "a")


def say(text):
    log.write(text + "\n")
    log.flush()


def get(url, pause):
    for attempt in range(5):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": UA})
            with urllib.request.urlopen(req, context=CTX, timeout=90) as r:
                body = r.read()
            time.sleep(pause)
            return body
        except Exception as e:
            say(f"retry {attempt} {url} {e}")
            time.sleep(5 * (attempt + 1))
    return None


def page(family):
    path = f"{DATA}/pages/{family}.html"
    if os.path.exists(path):
        return open(path, encoding="utf-8", errors="replace").read()
    body = get(f"https://sfxmint.com/sounds/{family}", 0.6)
    if body is None:
        return ""
    open(path, "wb").write(body)
    return body.decode("utf-8", "replace")


def flight(text):
    """The React Server Components payload of a page, unescaped."""
    parts = re.findall(r'self\.__next_f\.push\(\[1,"((?:[^"\\]|\\.)*)"\]\)', text)
    out = []
    for p in parts:
        try:
            out.append(json.loads('"' + p + '"'))
        except Exception:
            pass
    return "".join(out)


def objects_after(text, marker):
    """Every JSON object that follows `marker` in `text`."""
    decoder = json.JSONDecoder()
    start = 0
    while True:
        i = text.find(marker, start)
        if i < 0:
            return
        j = i + len(marker)
        try:
            obj, end = decoder.raw_decode(text, j)
            yield obj
            start = end
        except Exception:
            start = j


families = re.findall(r"<loc>https://sfxmint\.com/sounds/([a-z0-9-]+)</loc>", open(SITEMAP).read())
records_path = f"{DATA}/records.json"
records = json.load(open(records_path)) if os.path.exists(records_path) else {}

for n, family in enumerate(families):
    text = page(family)
    if not text:
        say(f"page {family}: nothing")
        continue
    payload = flight(text)
    title = ""
    m = re.search(r'"aria-label":"([^"]+) variations"', payload)
    if m:
        title = m.group(1)
    else:
        m = re.search(r"<h1[^>]*>(.*?)</h1>", text, re.S)
        if m:
            title = html.unescape(re.sub(r"<[^>]+>", "", m.group(1))).strip()
    m = re.search(r'<meta name="description" content="([^"]*)"', text)
    description = html.unescape(m.group(1)) if m else ""
    found = 0
    for obj in objects_after(payload, '"sound":'):
        if not isinstance(obj, dict):
            continue
        sid = obj.get("id")
        mp3 = (obj.get("format_metadata") or {}).get("mp3") or {}
        if not sid or not re.fullmatch(r"[a-z0-9-]+", sid) or not mp3.get("sha256"):
            continue
        record = records.get(sid, {})
        record.update({k: obj.get(k) for k in ("id", "title", "category", "duration_ms")})
        record["mp3"] = {"bytes": mp3.get("bytes"), "sha256": mp3.get("sha256"), "duration_ms": mp3.get("duration_ms")}
        # Variations on a family's own page belong to it; a sound only
        # linked from elsewhere keeps the family it was first seen with.
        if obj.get("page_path", "").startswith(f"/sounds/{family}-") or "family" not in record:
            record["family"] = family
            record["family_title"] = title
            record["description"] = description
        if sid not in records:
            found += 1
        records[sid] = record
    if found:
        say(f"page {n + 1}/{len(families)} {family}: +{found} total {len(records)}")
    if n % 20 == 0:
        json.dump(records, open(records_path, "w"))
json.dump(records, open(records_path, "w"))
say(f"pages done: {len(records)} sounds")

total = 0
for n, (sid, record) in enumerate(sorted(records.items())):
    path = f"{DATA}/mp3/{sid}.mp3"
    want = record["mp3"]
    if os.path.exists(path):
        total += os.path.getsize(path)
        continue
    body = get(f"https://sfxmint.com/dl/{sid}.mp3", 0.15)
    if body is None:
        say(f"mp3 {sid}: failed")
        continue
    digest = hashlib.sha256(body).hexdigest()
    if digest != want["sha256"] or (want.get("bytes") and len(body) != want["bytes"]):
        say(f"mp3 {sid}: sha256 {digest} bytes {len(body)} does not match {want}")
        continue
    open(path + ".part", "wb").write(body)
    os.replace(path + ".part", path)
    total += len(body)
    if n % 50 == 0:
        say(f"mp3 {n + 1}/{len(records)} {total / 1e6:.1f} MB")
say(f"mp3 done: {len(os.listdir(f'{DATA}/mp3'))} files, {total / 1e6:.1f} MB")
