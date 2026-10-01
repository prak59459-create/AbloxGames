# Words for Meme Heist's characters: Italian-sounding, with their katakana and
# what they are in Japanese. The script draws each character from its animal
# (the body) and its thing (what is fused onto it), so both lists carry the
# look too: `kind` is the body plan in models.absc, `fit` where the thing goes.

# animal: (word, small form, katakana, small katakana, japanese, body plan, colour 1, colour 2)
ANIMALS = [
    ("Gatto", "Gattino", "ガット", "ガッティーノ", "ネコ", "quad", "#F59E0B", "#FDE68A"),
    ("Cane", "Cagnolino", "カーネ", "カニョリーノ", "イヌ", "quad", "#A16207", "#FDE68A"),
    ("Squalo", "Squalino", "スクアーロ", "スクアリーノ", "サメ", "fish", "#64748B", "#E2E8F0"),
    ("Coccodrillo", "Coccodrillino", "コッコドリッロ", "コッコドリッリーノ", "ワニ", "long", "#15803D", "#86EFAC"),
    ("Elefante", "Elefantino", "エレファンテ", "エレファンティーノ", "ゾウ", "quad", "#9CA3AF", "#E5E7EB"),
    ("Giraffa", "Giraffina", "ジラッファ", "ジラッフィーナ", "キリン", "tall", "#FBBF24", "#92400E"),
    ("Pinguino", "Pinguinetto", "ピングイーノ", "ピングイネット", "ペンギン", "biped", "#1E293B", "#F8FAFC"),
    ("Scimmia", "Scimmietta", "シンミア", "シンミエッタ", "サル", "biped", "#78350F", "#D6A77A"),
    ("Rana", "Ranocchio", "ラーナ", "ラノッキオ", "カエル", "squat", "#22C55E", "#BBF7D0"),
    ("Tartaruga", "Tartarughina", "タルタルーガ", "タルタルギーナ", "カメ", "shell", "#16A34A", "#A16207"),
    ("Polpo", "Polpetto", "ポルポ", "ポルペット", "タコ", "octo", "#C026D3", "#F0ABFC"),
    ("Pollo", "Pulcino", "ポッロ", "プルチーノ", "ニワトリ", "bird", "#F8FAFC", "#EF4444"),
    ("Mucca", "Mucchina", "ムッカ", "ムッキーナ", "ウシ", "quad", "#F8FAFC", "#1F2937"),
    ("Maiale", "Maialino", "マイアーレ", "マイアリーノ", "ブタ", "quad", "#F9A8D4", "#FBCFE8"),
    ("Topo", "Topolino", "トーポ", "トポリーノ", "ネズミ", "small", "#9CA3AF", "#F9A8D4"),
    ("Leone", "Leoncino", "レオーネ", "レオンチーノ", "ライオン", "quad", "#F59E0B", "#92400E"),
    ("Tigre", "Tigrotto", "ティーグレ", "ティグロット", "トラ", "quad", "#F97316", "#1F2937"),
    ("Orso", "Orsetto", "オルソ", "オルセット", "クマ", "biped", "#92400E", "#D6A77A"),
    ("Ape", "Apetta", "アーペ", "アペッタ", "ハチ", "bug", "#FACC15", "#1F2937"),
    ("Ragno", "Ragnetto", "ラーニョ", "ラニェット", "クモ", "spider", "#1F2937", "#EF4444"),
    ("Delfino", "Delfinetto", "デルフィーノ", "デルフィネット", "イルカ", "fish", "#60A5FA", "#DBEAFE"),
    ("Cavallo", "Cavallino", "カヴァッロ", "カヴァッリーノ", "ウマ", "tall", "#A16207", "#451A03"),
    ("Capra", "Capretta", "カプラ", "カプレッタ", "ヤギ", "quad", "#F5F5F4", "#A8A29E"),
    ("Gufo", "Gufetto", "グーフォ", "グフェット", "フクロウ", "bird", "#92400E", "#FDE68A"),
    ("Lumaca", "Lumachina", "ルマーカ", "ルマキーナ", "カタツムリ", "snail", "#A3E635", "#B45309"),
    ("Granchio", "Granchietto", "グランキオ", "グランキエット", "カニ", "crab", "#EF4444", "#FCA5A5"),
    ("Fenicottero", "Fenicotterino", "フェニコッテロ", "フェニコッテリーノ", "フラミンゴ", "stilt", "#F472B6", "#FBCFE8"),
    ("Pappagallo", "Pappagallino", "パッパガッロ", "パッパガッリーノ", "オウム", "bird", "#22C55E", "#EF4444"),
    ("Riccio", "Riccetto", "リッチョ", "リチェット", "ハリネズミ", "spiky", "#78350F", "#FDE68A"),
    ("Volpe", "Volpina", "ヴォルペ", "ヴォルピーナ", "キツネ", "quad", "#EA580C", "#FFF7ED"),
    ("Lupo", "Lupetto", "ルーポ", "ルペット", "オオカミ", "quad", "#6B7280", "#E5E7EB"),
    ("Coniglio", "Coniglietto", "コニーリョ", "コニリエット", "ウサギ", "bunny", "#F8FAFC", "#F9A8D4"),
    ("Criceto", "Cricetino", "クリチェート", "クリチェティーノ", "ハムスター", "small", "#FBBF24", "#FFF7ED"),
    ("Panda", "Pandino", "パンダ", "パンディーノ", "パンダ", "biped", "#F8FAFC", "#111827"),
    ("Koala", "Koalino", "コアラ", "コアリーノ", "コアラ", "biped", "#9CA3AF", "#F5F5F4"),
    ("Canguro", "Cangurino", "カングーロ", "カングリーノ", "カンガルー", "biped", "#D97706", "#FDE68A"),
    ("Cammello", "Cammellino", "カンメッロ", "カンメッリーノ", "ラクダ", "tall", "#D6A77A", "#92400E"),
    ("Struzzo", "Struzzino", "ストルッツォ", "ストルッツィーノ", "ダチョウ", "stilt", "#44403C", "#F5F5F4"),
    ("Medusa", "Medusina", "メドゥーザ", "メドゥズィーナ", "クラゲ", "jelly", "#C4B5FD", "#F0ABFC"),
    ("Balena", "Balenottera", "バレーナ", "バレノッテラ", "クジラ", "fish", "#1D4ED8", "#BFDBFE"),
    ("Gamberetto", "Gamberettino", "ガンベレット", "ガンベレッティーノ", "エビ", "long", "#FB923C", "#FED7AA"),
    ("Serpente", "Serpentello", "セルペンテ", "セルペンテッロ", "ヘビ", "long", "#65A30D", "#FACC15"),
    ("Drago", "Draghetto", "ドラーゴ", "ドラゲット", "ドラゴン", "dragon", "#DC2626", "#FDE047"),
    ("Unicorno", "Unicornino", "ウニコルノ", "ウニコルニーノ", "ユニコーン", "quad", "#F8FAFC", "#F0ABFC"),
    ("Robot", "Robottino", "ロボット", "ロボッティーノ", "ロボット", "robot", "#94A3B8", "#22D3EE"),
    ("Pipistrello", "Pipistrellino", "ピピストレッロ", "ピピストレッリーノ", "コウモリ", "bat", "#4C1D95", "#C4B5FD"),
    ("Renna", "Rennina", "レンナ", "レンニーナ", "トナカイ", "quad", "#92400E", "#F8FAFC"),
    ("Fantasma", "Fantasmino", "ファンタズマ", "ファンタズミーノ", "おばけ", "ghost", "#F8FAFC", "#C4B5FD"),
    ("Alieno", "Alienino", "アリエーノ", "アリエニーノ", "うちゅう人", "alien", "#4ADE80", "#1E293B"),
]

# thing: (word, katakana, japanese, where it goes, colour)
#   fit: head (replaces the head), hat (on the head), body (the body is it),
#        held (in the hands/at the side), back (on the back), feet (on the feet), ring (round the body)
THINGS = [
    ("Pizza", "ピッツァ", "ピザ", "hat", "#FBBF24"),
    ("Gelato", "ジェラート", "アイス", "hat", "#F9A8D4"),
    ("Spaghetto", "スパゲット", "スパゲッティ", "hat", "#FDE68A"),
    ("Biscotto", "ビスコット", "クッキー", "body", "#D97706"),
    ("Limone", "リモーネ", "レモン", "head", "#FDE047"),
    ("Fragola", "フラーゴラ", "イチゴ", "head", "#EF4444"),
    ("Melone", "メローネ", "メロン", "body", "#86EFAC"),
    ("Pomodoro", "ポモドーロ", "トマト", "head", "#DC2626"),
    ("Cappuccio", "カップッチョ", "コーヒー", "head", "#78350F"),
    ("Ciambella", "チャンベッラ", "ドーナツ", "ring", "#F472B6"),
    ("Panino", "パニーノ", "サンドイッチ", "body", "#FCD34D"),
    ("Cornetto", "コルネット", "クロワッサン", "hat", "#F59E0B"),
    ("Lasagna", "ラザーニャ", "ラザニア", "body", "#F97316"),
    ("Raviolo", "ラヴィオーロ", "ラビオリ", "head", "#FDE68A"),
    ("Mozzarella", "モッツァレッラ", "チーズ", "head", "#F8FAFC"),
    ("Tiramisu", "ティラミス", "ティラミス", "body", "#A16207"),
    ("Cannolo", "カンノーロ", "カンノーロ", "held", "#FDE68A"),
    ("Panettone", "パネットーネ", "パネットーネ", "hat", "#D97706"),
    ("Ananas", "アナナス", "パイナップル", "head", "#FACC15"),
    ("Anguria", "アングーリア", "スイカ", "body", "#16A34A"),
    ("Telefono", "テレーフォノ", "でんわ", "body", "#3B82F6"),
    ("Lampadina", "ランパディーナ", "でんきゅう", "head", "#FEF08A"),
    ("Ombrello", "オンブレッロ", "かさ", "hat", "#EF4444"),
    ("Scarpone", "スカルポーネ", "くつ", "feet", "#F8FAFC"),
    ("Calzino", "カルツィーノ", "くつした", "body", "#F472B6"),
    ("Cappellone", "カッペッローネ", "ぼうし", "hat", "#111827"),
    ("Orologio", "オロロージョ", "とけい", "body", "#FDE68A"),
    ("Razzo", "ラッツォ", "ロケット", "back", "#EF4444"),
    ("Aereo", "アエーレオ", "ひこうき", "back", "#E2E8F0"),
    ("Treno", "トレーノ", "でんしゃ", "body", "#16A34A"),
    ("Chitarra", "キタッラ", "ギター", "held", "#B45309"),
    ("Tromba", "トロンバ", "ラッパ", "held", "#FACC15"),
    ("Tostapane", "トスタパーネ", "トースター", "body", "#CBD5E1"),
    ("Tazza", "タッツァ", "カップ", "head", "#F8FAFC"),
    ("Bottiglia", "ボッティーリア", "ボトル", "body", "#22C55E"),
    ("Candela", "カンデーラ", "ろうそく", "hat", "#FEF3C7"),
    ("Palloncino", "パッロンチーノ", "ふうせん", "held", "#F43F5E"),
    ("Pallone", "パッローネ", "ボール", "head", "#F8FAFC"),
    ("Cuscino", "クッシーノ", "まくら", "body", "#BFDBFE"),
    ("Valigia", "ヴァリージャ", "スーツケース", "back", "#92400E"),
    ("Zaino", "ザイノ", "リュック", "back", "#2563EB"),
    ("Matita", "マティータ", "えんぴつ", "held", "#FACC15"),
    ("Libro", "リーブロ", "本", "held", "#7C3AED"),
    ("Lavatrice", "ラヴァトリーチェ", "せんたくき", "body", "#F8FAFC"),
    ("Televisore", "テレヴィゾーレ", "テレビ", "head", "#1F2937"),
    ("Radio", "ラーディオ", "ラジオ", "held", "#DC2626"),
    ("Cactus", "カクトゥス", "サボテン", "body", "#15803D"),
    ("Fungo", "フンゴ", "キノコ", "hat", "#DC2626"),
    ("Nuvola", "ヌーヴォラ", "くも", "ring", "#F8FAFC"),
    ("Stella", "ステッラ", "ほし", "hat", "#FDE047"),
    ("Luna", "ルーナ", "月", "back", "#FEF9C3"),
    ("Sole", "ソーレ", "たいよう", "head", "#FBBF24"),
    ("Fulmine", "フルミネ", "かみなり", "back", "#FDE047"),
    ("Vulcano", "ヴルカーノ", "火山", "body", "#7C2D12"),
    ("Arcobaleno", "アルコバレーノ", "にじ", "back", "#EC4899"),
    ("Tamburo", "タンブーロ", "たいこ", "body", "#B91C1C"),
    ("Frigorifero", "フリゴリーフェロ", "れいぞうこ", "body", "#E2E8F0"),
    ("Corona", "コローナ", "おうかん", "hat", "#FACC15"),
    ("Taco", "ターコ", "タコス", "body", "#FCD34D"),
    ("Zucca", "ズッカ", "かぼちゃ", "head", "#F97316"),
]

# Small sounds for the rhythmic names, with their katakana.
SOUNDS = [("Bum", "ブン"), ("Tum", "トゥン"), ("Pim", "ピン"), ("Pam", "パン"), ("Tric", "トリック"), ("Trac", "トラック"),
          ("Zip", "ジップ"), ("Zap", "ザップ"), ("Bing", "ビン"), ("Bong", "ボン"), ("Plin", "プリン"), ("Plon", "プロン"),
          ("Dun", "ドゥン"), ("Din", "ディン"), ("Tic", "ティック"), ("Toc", "トック"), ("Ciuf", "チュフ"), ("Paf", "パフ"),
          ("Boing", "ボイン"), ("Zum", "ズン"), ("Pop", "ポップ"), ("Bip", "ビップ")]

# Adjectives: (feminine, masculine, katakana f, katakana m, Japanese). The
# noun they go with decides which: a word ending in "a" is feminine.
ADJECTIVES = [("Volante", "Volante", "ヴォランテ", "ヴォランテ", "とぶ"), ("Danzante", "Danzante", "ダンツァンテ", "ダンツァンテ", "おどる"),
              ("Spaziale", "Spaziale", "スパツィアーレ", "スパツィアーレ", "うちゅうの"), ("Dorata", "Dorato", "ドラータ", "ドラート", "金の"),
              ("Pazzerella", "Pazzerello", "パッツェレッラ", "パッツェレッロ", "おかしな"), ("Gigante", "Gigante", "ジガンテ", "ジガンテ", "きょだいな"),
              ("Magica", "Magico", "マージカ", "マージコ", "まほうの"), ("Notturna", "Notturno", "ノットゥルナ", "ノットゥルノ", "夜の"),
              ("Felice", "Felice", "フェリーチェ", "フェリーチェ", "しあわせな"), ("Turbo", "Turbo", "トゥルボ", "トゥルボ", "ターボの"),
              ("Ruggente", "Ruggente", "ルッジェンテ", "ルッジェンテ", "ほえる"), ("Cantante", "Cantante", "カンタンテ", "カンタンテ", "うたう"),
              ("Saltellante", "Saltellante", "サルテッランテ", "サルテッランテ", "はねる"), ("Misteriosa", "Misterioso", "ミステリオーザ", "ミステリオーゾ", "なぞの"),
              ("Elegante", "Elegante", "エレガンテ", "エレガンテ", "おしゃれな")]

# Rhythmic first halves: "Bimbalero Bambalà"-like, with katakana.
RHYMES = [("Bimbalero", "ビンバレーロ", "Bambala", "バンバラ"), ("Pimpirello", "ピンピレッロ", "Pompirella", "ポンピレッラ"),
          ("Zumbarino", "ズンバリーノ", "Zambarina", "ザンバリーナ"), ("Tirolino", "ティロリーノ", "Tarolina", "タロリーナ"),
          ("Ciribiri", "チリビリ", "Ciribiro", "チリビロ"), ("Pataflino", "パタフリーノ", "Pataflina", "パタフリーナ"),
          ("Bombolino", "ボンボリーノ", "Bombolina", "ボンボリーナ"), ("Frullino", "フルッリーノ", "Frullina", "フルッリーナ"),
          ("Dindolo", "ディンドロ", "Dandola", "ダンドラ"), ("Ghirigoro", "ギリゴーロ", "Ghirigora", "ギリゴーラ"),
          ("Trottolino", "トロットリーノ", "Trottolina", "トロットリーナ"), ("Zigozago", "ジゴザーゴ", "Zigozaga", "ジゴザーガ")]

# Names from the real game this one takes after, and other well-known
# characters of that meme: never used, not even close.
FORBIDDEN = """tralalero tralala; tung tung tung sahur; bombardiro crocodilo; brr brr patapim; lirili larila;
chimpanzini bananini; cappuccino assassino; noobini pizzanini; la vacca saturno saturnita; strawberry elephant;
dragon cannelloni; los 67; ballerina cappuccina; frigo camelo; glorbo fruttodrillo; trippi troppi; boneca ambalabu;
tric trac baraboom; garamararam; sigma boy; bombombini gusini; burbaloni loliloli; trulimero trulicina;
pipi kiwi; gangster footera; bandito bobritto; cacto hipopotamo; pinealotto fruttarino; salamino penguino;
ganganzelli trulala; burguro and fryuro; matteo; spiderini; gerro digitali; migatito; car car; lasas; los mateos;
orcalero orcala; tigroligre frutonni; odin din din dun; ta ta ta ta sahur; espresso signora; svinina bombardino;
girafa celestre; cocofanto elefanto; graipuss medussi; nooo my hotspot; la grande combinasion; chicleteira bicicleteira""".split(";")
