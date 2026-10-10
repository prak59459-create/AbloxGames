#!/usr/bin/env python3
"""Finds the takes the family pages leave out, politely.

usage: walk.py DATA_DIR API_META_DIR

A family page shows some of its takes; each take's own page
(/sounds/<id>) shows it and the next eight takes that exist. Walking from
take 01 along those lists reaches every take of a family. Adds what it finds
to DATA_DIR/records.json (same shape as harvest.py writes), and the sounds
the search API found in API_META_DIR.
"""
import json, os, re, ssl, sys, time, urllib.request

DATA, META = sys.argv[1], sys.argv[2]
os.makedirs(f"{DATA}/takes", exist_ok=True)
CTX = ssl.create_default_context(cafile="/root/.ccr/ca-bundle.crt")
UA = "AbloxSoundLibrary/1.0 (+https://github.com/prak59459-create/Ablox; one-time CC0 mirror, one request at a time)"
log = open(f"{DATA}/walk.log", "a")
records_path = f"{DATA}/records.json"
records = json.load(open(records_path))


def say(text):
    log.write(text + "\n")
    log.flush()


def page(sid):
    """The page's text and whether it is the take's own (not a redirect)."""
    path = f"{DATA}/takes/{sid}.html"
    if os.path.exists(path):
        return open(path, encoding="utf-8", errors="replace").read(), True
    if os.path.exists(path + ".missing"):
        return "", False
    for attempt in range(5):
        try:
            req = urllib.request.Request(f"https://sfxmint.com/sounds/{sid}", headers={"User-Agent": UA})
            with urllib.request.urlopen(req, context=CTX, timeout=90) as r:
                final = r.geturl()
                body = r.read()
            time.sleep(0.8)
            if not final.rstrip("/").endswith(f"/sounds/{sid}"):
                open(path + ".missing", "w").write(final)
                return "", False
            open(path, "wb").write(body)
            return body.decode("utf-8", "replace"), True
        except urllib.error.HTTPError as e:
            if e.code == 404:
                open(path + ".missing", "w").write("404")
                return "", False
            say(f"retry {attempt} {sid} {e}")
            time.sleep(5 * (attempt + 1))
        except Exception as e:
            say(f"retry {attempt} {sid} {e}")
            time.sleep(5 * (attempt + 1))
    return "", False


def flight(text):
    parts = re.findall(r'self\.__next_f\.push\(\[1,"((?:[^"\\]|\\.)*)"\]\)', text)
    out = []
    for p in parts:
        try:
            out.append(json.loads('"' + p + '"'))
        except Exception:
            pass
    return "".join(out)


def sounds_on(text):
    decoder = json.JSONDecoder()
    payload = flight(text)
    found = []
    start = 0
    while True:
        i = payload.find('"sound":', start)
        if i < 0:
            return found, payload
        j = i + len('"sound":')
        try:
            obj, end = decoder.raw_decode(payload, j)
            start = end
        except Exception:
            start = j
            continue
        if isinstance(obj, dict) and obj.get("id") and ((obj.get("format_metadata") or {}).get("mp3") or {}).get("sha256"):
            found.append(obj)


def keep(obj, family, title, description):
    sid = obj["id"]
    if not re.fullmatch(r"[a-z0-9-]+", sid):
        return False
    mp3 = obj["format_metadata"]["mp3"]
    new = sid not in records
    record = records.get(sid, {})
    record.update({k: obj.get(k) for k in ("id", "title", "category", "duration_ms")})
    record["mp3"] = {"bytes": mp3.get("bytes"), "sha256": mp3.get("sha256"), "duration_ms": mp3.get("duration_ms")}
    record.setdefault("family", family)
    record.setdefault("family_title", title)
    record.setdefault("description", description)
    records[sid] = record
    return new


# The search API's finds, in the same shape.
for name in os.listdir(META):
    d = json.load(open(f"{META}/{name}"))
    sid = d.get("slug")
    mp3 = (d.get("format_metadata") or {}).get("mp3") or {}
    if sid and sid not in records and mp3.get("sha256"):
        fam = re.sub(r"-\d+$", "", sid)
        records[sid] = {"id": sid, "title": d.get("title"), "category": d.get("category"), "duration_ms": d.get("duration_ms"),
                        "mp3": {"bytes": mp3.get("bytes"), "sha256": mp3.get("sha256"), "duration_ms": mp3.get("duration_ms")},
                        "family": fam, "family_title": "", "description": d.get("description") or "", "tags": d.get("tags") or []}
say(f"with the search finds: {len(records)}")


def number(sid):
    m = re.search(r"-(\d+)$", sid)
    return int(m.group(1)) if m else -1


families = {}
for sid, r in records.items():
    if number(sid) >= 0:
        families.setdefault(re.sub(r"-\d+$", "", sid), set()).add(sid)

for n, (family, known) in enumerate(sorted(families.items())):
    sample = records[sorted(known)[0]]
    title, description = sample.get("family_title") or "", sample.get("description") or ""
    width = max(2, len(re.search(r"-(\d+)$", sorted(known)[0]).group(1)))
    first = f"{family}-{1:0{width}d}"
    text, real = page(first)
    current = first if real else min(known, key=number)
    if not real:
        text, real = page(current)
    visited = set()
    added = 0
    while real and current not in visited:
        visited.add(current)
        found, payload = sounds_on(text)
        mine = [o for o in found if re.sub(r"-\d+$", "", o["id"]) == family]
        for o in mine:
            if keep(o, family, title, description):
                added += 1
        ahead = [o["id"] for o in mine if number(o["id"]) > number(current)]
        if not ahead:
            break
        current = max(ahead, key=number)
        text, real = page(current)
    if added:
        say(f"family {n + 1}/{len(families)} {family}: +{added} total {len(records)}")
    if n % 10 == 0:
        json.dump(records, open(records_path + ".tmp", "w"))
        os.replace(records_path + ".tmp", records_path)
json.dump(records, open(records_path + ".tmp", "w"))
os.replace(records_path + ".tmp", records_path)
say(f"walk done: {len(records)} sounds")
