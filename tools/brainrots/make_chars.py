#!/usr/bin/env python3
"""Makes Meme Heist's 300 characters (games/meme-heist/chars.absc).

Sixty are made by hand (specials.py); the rest are put together here from
an animal and a thing (vocab.py), with an Italian-sounding name, its
katakana, a line about it in Japanese, what it earns a second and what it
costs. The same seed gives the same 300 every time, so a save keeps
pointing at the same characters.

  python3 tools/brainrots/make_chars.py
"""

import math
import pathlib
import random
import re
import sys

HERE = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
from vocab import ANIMALS, THINGS, SOUNDS, ADJECTIVES, RHYMES, FORBIDDEN  # noqa: E402
from specials import SPECIALS  # noqa: E402

OUT = HERE.parent.parent / "games" / "meme-heist" / "chars.absc"

# rarity: (count, lowest income, highest income, price in seconds of income)
TIERS = {
    1: (60, 1, 75, 28),
    2: (55, 90, 700, 38),
    3: (50, 800, 6_000, 50),
    4: (45, 7_000, 50_000, 65),
    5: (35, 60_000, 450_000, 85),
    6: (25, 550_000, 5_000_000, 110),
    7: (20, 7_000_000, 150_000_000, 150),
    8: (10, 200_000_000, 1_500_000_000, 220),
}

# Which animals and things each rarity draws from: the common ones are
# everyday, the rare ones cosmic.
EVERYDAY_ANIMALS = ["Gatto", "Cane", "Topo", "Pollo", "Rana", "Maiale", "Criceto", "Coniglio", "Lumaca", "Capra",
                    "Mucca", "Pinguino", "Tartaruga", "Riccio", "Ape", "Gufo", "Scimmia", "Koala"]
WILD_ANIMALS = ["Squalo", "Coccodrillo", "Elefante", "Giraffa", "Polpo", "Leone", "Tigre", "Orso", "Ragno", "Delfino",
                "Cavallo", "Granchio", "Fenicottero", "Pappagallo", "Volpe", "Lupo", "Panda", "Canguro", "Cammello",
                "Struzzo", "Medusa", "Gamberetto", "Serpente", "Pipistrello"]
LEGEND_ANIMALS = ["Drago", "Unicorno", "Balena", "Robot", "Fantasma", "Alieno", "Renna"]
EVERYDAY_THINGS = ["Pizza", "Gelato", "Spaghetto", "Biscotto", "Limone", "Fragola", "Melone", "Pomodoro", "Cappuccio",
                   "Ciambella", "Panino", "Cornetto", "Raviolo", "Mozzarella", "Calzino", "Scarpone", "Matita", "Tazza",
                   "Cuscino", "Pallone", "Bottiglia", "Libro", "Cactus", "Fungo", "Anguria", "Ananas", "Taco", "Zucca"]
GADGET_THINGS = ["Telefono", "Lampadina", "Ombrello", "Cappellone", "Orologio", "Treno", "Chitarra", "Tromba",
                 "Tostapane", "Candela", "Palloncino", "Valigia", "Zaino", "Lavatrice", "Televisore", "Radio",
                 "Tamburo", "Frigorifero", "Lasagna", "Tiramisu", "Cannolo", "Panettone", "Nuvola", "Aereo", "Razzo"]
COSMIC_THINGS = ["Stella", "Luna", "Sole", "Fulmine", "Vulcano", "Arcobaleno", "Corona"]

POOLS = {
    1: (EVERYDAY_ANIMALS, EVERYDAY_THINGS),
    2: (EVERYDAY_ANIMALS + WILD_ANIMALS[:8], EVERYDAY_THINGS + GADGET_THINGS[:8]),
    3: (EVERYDAY_ANIMALS + WILD_ANIMALS, EVERYDAY_THINGS + GADGET_THINGS),
    4: (WILD_ANIMALS + EVERYDAY_ANIMALS[:8], GADGET_THINGS + EVERYDAY_THINGS[:10] + COSMIC_THINGS[:2]),
    5: (WILD_ANIMALS + LEGEND_ANIMALS[:3], GADGET_THINGS + COSMIC_THINGS),
    6: (WILD_ANIMALS[:12] + LEGEND_ANIMALS, COSMIC_THINGS + GADGET_THINGS[:10]),
    7: (LEGEND_ANIMALS + WILD_ANIMALS[:8], COSMIC_THINGS + ["Televisore", "Tamburo", "Razzo", "Aereo"]),
    8: (LEGEND_ANIMALS, COSMIC_THINGS),
}

FLAVOURS = [
    "いつもおどっている", "ねるのが大すき", "夜になると すこし光る", "歌がとくい", "くしゃみをすると ちょっと とぶ",
    "ひとりごとが多い", "お金のにおいが分かる", "かくれんぼの名人", "まいにち同じダンスをする", "ほめられると 大きくなる",
    "あさごはんを 3回たべる", "しゃっくりが とまらない", "空をとぶゆめを見る", "ともだちが100人いる", "スキップしか できない",
    "はずかしがりや", "さみしがりや", "なぜか いつも ぬれている", "口ぐせは「マンマミーア」", "せかい一 足がはやい（たぶん）",
    "ひなたぼっこが 大すき", "においで 天気が分かる", "うしろむきに 歩ける", "ほかのミームと なかよし", "とつぜん うたい出す",
    "ポーズを きめるのが うまい", "毎日ちがうリズムで歩く", "ピカピカのものが すき", "つかまえると くすぐったがる",
    "どこでも ねむれる", "ためいきが 音楽になる", "あくびが でかい", "あいさつが ていねい", "はしるとき 耳が回る",
    "雨の日は ごきげん", "ちいさな声で わらう", "おなかの音が 大きい", "ほしを数えるのが しゅみ", "ジャンプが 3センチ",
    "おこると ふくらむ",
]


def katakana_join(*parts):
    return "・".join(parts)


def name_for(tier, animal, thing, rng):
    """An Italian-sounding name and its katakana."""
    word, small, kana, small_kana = animal[0], animal[1], animal[2], animal[3]
    t_word, t_kana = thing[0], thing[1]
    if tier <= 2:
        pattern = rng.choice(["thing_small", "small_thing", "sounds", "thing_small"])
    elif tier <= 4:
        pattern = rng.choice(["la_adjective", "rhyme_pair", "augment", "small_thing", "sounds"])
    elif tier <= 6:
        pattern = rng.choice(["animal_thing_adjective", "rhyme_animal", "la_adjective", "augment"])
    else:
        pattern = rng.choice(["los", "rhyme_animal", "supremo"])
    if pattern == "thing_small":
        return f"{t_word} {small}", katakana_join(t_kana, small_kana)
    if pattern == "small_thing":
        return f"{small} {t_word}", katakana_join(small_kana, t_kana)
    if pattern == "sounds":
        s, sk = rng.choice(SOUNDS)
        return f"{s} {s} {small}", katakana_join(sk, sk, small_kana)
    if pattern == "la_adjective":
        feminine = t_word.endswith("a")
        adjective, adjective_kana = agree(rng.choice(ADJECTIVES), feminine)
        article, article_kana = ("La", "ラ") if feminine else ("Il", "イル")
        return f"{article} {t_word} {adjective}", katakana_join(article_kana, t_kana, adjective_kana)
    if pattern == "rhyme_pair":
        r = rng.choice(RHYMES)
        return f"{r[0]} {r[2]}", katakana_join(r[1], r[3])
    if pattern == "augment" and not t_word.endswith("one") and augment_kana(t_kana):
        stem = re.sub(r"[aeio]$", "", t_word)
        return f"{word} {stem}one", katakana_join(kana, augment_kana(t_kana))
    if pattern in ("animal_thing_adjective", "augment"):
        # An adjective goes with the animal, which comes first.
        adjective, adjective_kana = agree(rng.choice(ADJECTIVES), word.endswith("a"))
        return f"{word} {t_word} {adjective}", katakana_join(kana, t_kana, adjective_kana)
    if pattern == "rhyme_animal":
        r = rng.choice(RHYMES)
        return f"{r[0]} {word}", katakana_join(r[1], kana)
    if pattern == "los":
        return f"Los {small}s {t_word}", katakana_join("ロス", small_kana + "ス", t_kana)
    s, sk = rng.choice(SOUNDS)
    return f"{s}{s.lower()} {word} Supremo", katakana_join(sk + sk, kana, "スプレーモ")


# The last sound of a word moved to its "o" (Pizza → Pizzone: ツァ → ツォ).
TO_O = {"ア": "オ", "カ": "コ", "ガ": "ゴ", "サ": "ソ", "ザ": "ゾ", "タ": "ト", "ダ": "ド", "ナ": "ノ", "ハ": "ホ", "バ": "ボ",
        "パ": "ポ", "マ": "モ", "ヤ": "ヨ", "ラ": "ロ", "ァ": "ォ", "ャ": "ョ", "エ": "オ", "ケ": "コ", "ゲ": "ゴ", "セ": "ソ",
        "ゼ": "ゾ", "テ": "ト", "デ": "ド", "ネ": "ノ", "ヘ": "ホ", "ベ": "ボ", "ペ": "ポ", "メ": "モ", "レ": "ロ", "ェ": "ォ",
        "オ": "オ", "コ": "コ", "ゴ": "ゴ", "ソ": "ソ", "ゾ": "ゾ", "ト": "ト", "ド": "ド", "ノ": "ノ", "ホ": "ホ", "ボ": "ボ",
        "ポ": "ポ", "モ": "モ", "ロ": "ロ", "ォ": "ォ", "ョ": "ョ"}


def augment_kana(kana):
    """The katakana of the "big" form (Mozzarella → モッツァレッローネ), or
    nil when the word does not end in a sound that turns cleanly."""
    last = kana[-1]
    if last not in TO_O:
        return None
    return kana[:-1] + TO_O[last] + "ーネ"


def agree(adjective, feminine):
    """The adjective's form, and its katakana, for a feminine or masculine noun."""
    return (adjective[0], adjective[2]) if feminine else (adjective[1], adjective[3])


def forbidden(name):
    low = name.lower()
    return any(f.strip() and (f.strip() in low or low in f.strip()) for f in FORBIDDEN)


def round_nice(n):
    """Numbers a child can read: 1, 2, 5, 12, 340, 4 500, 1 200 000…"""
    if n < 10:
        return max(1, int(round(n)))
    digits = int(math.floor(math.log10(n)))
    step = 10 ** max(0, digits - 1)
    return int(round(n / step) * step)


def main():
    rng = random.Random(4)
    animals = {a[0]: a for a in ANIMALS}
    things = {t[0]: t for t in THINGS}
    used_names = set()
    used_pairs = set()
    tiers = {tier: [] for tier in TIERS}

    for name, kana, tier, animal, thing, about, source in SPECIALS:
        assert not forbidden(name), name
        used_names.add(name.lower())
        used_pairs.add((animal, thing))
        tiers[tier].append({"n": name, "k": kana, "a": animal, "t": thing, "d": about, "src": source, "hand": True})

    for tier, (count, _, _, _) in TIERS.items():
        animal_pool, thing_pool = POOLS[tier]
        tries = 0
        while len(tiers[tier]) < count:
            tries += 1
            assert tries < 20_000, f"rarity {tier} ran out of names"
            a = animals[rng.choice(animal_pool)]
            t = things[rng.choice(thing_pool)]
            if (a[0], t[0]) in used_pairs:
                continue
            name, kana = name_for(tier, a, t, rng)
            if name.lower() in used_names or forbidden(name):
                continue
            used_names.add(name.lower())
            used_pairs.add((a[0], t[0]))
            about = f"{t[2]}と{a[4]}が合体したミーム。{rng.choice(FLAVOURS)}"
            tiers[tier].append({"n": name, "k": kana, "a": a[0], "t": t[0], "d": about, "src": "carpet", "hand": False})

    lines = []
    number = 0
    for tier, (count, low, high, seconds) in TIERS.items():
        group = tiers[tier]
        # Made ones first in a little shuffle, then the hand-made ones mixed in
        # toward the top of the rarity: they are the special ones.
        made = [c for c in group if not c["hand"]]
        hand = [c for c in group if c["hand"]]
        rng.shuffle(made)
        order = made[:]
        for i, c in enumerate(hand):
            order.insert(min(len(order), int(len(order) * (0.55 + 0.45 * (i + 1) / (len(hand) + 1)))), c)
        assert len(order) == count, (tier, len(order))
        for i, c in enumerate(order):
            number += 1
            f = i / max(1, count - 1)
            income = round_nice(low * (high / low) ** f)
            price = round_nice(income * seconds)
            # Cheaper ones come along more often.
            weight = round(1.6 - f * 1.3, 2)
            variant = rng.randint(0, 2)
            size = round(rng.uniform(0.92, 1.08), 2)
            about = c["d"].replace('"', "'")
            lines.append(
                f'  {{id: {number}, n: "{c["n"]}", k: "{c["k"]}", r: {tier}, inc: {income}, pr: {price}, '
                f'a: "{c["a"]}", t: "{c["t"]}", v: {variant}, s: {size}, w: {weight}, src: "{c["src"]}", d: "{about}"}}'
            )

    header = (
        "-- chars.absc — Meme Heist の300体（tools/brainrots/make_chars.py が作ります。手で書きかえないでね）\n"
        "-- id: ばんごう / n: なまえ / k: よみかた / r: めずらしさ 1〜8 / inc: 1秒にうむお金 / pr: ねだん\n"
        "-- a: どうぶつ（からだ）/ t: がったいしたもの / v: 色のちがい / s: 大きさ / w: カーペットでの出やすさ\n"
        "-- src: どこで手に入るか（carpet・ritual:…・event:…・admin）/ d: せつめい\n\n"
    )
    looks = ["", "-- どうぶつ: からだのつくり（plan）・色・日本語", "let ANIMALS = {"]
    looks.append(",\n".join(f'  {a[0]}: {{plan: "{a[5]}", c1: "{a[6]}", c2: "{a[7]}", jp: "{a[4]}"}}' for a in ANIMALS))
    looks += ["}", "", "-- がったいするもの: つく場所（fit）・色・日本語", "let THINGS = {"]
    looks.append(",\n".join(f'  {t[0]}: {{fit: "{t[3]}", c: "{t[4]}", jp: "{t[2]}"}}' for t in THINGS))
    looks.append("}")
    OUT.write_text(header + "let CHARS = [\n" + ",\n".join(lines) + "\n]\n" + "\n".join(looks) + "\n")
    counts = {t: len(v) for t, v in tiers.items()}
    print(f"wrote {number} characters to {OUT.relative_to(HERE.parent.parent)}: {counts}")


if __name__ == "__main__":
    main()
