extends RefCounted
## Все игровые данные: друзья, главы сюжета, улучшения и тексты (ru/en).

const COST_GROWTH: float = 1.15

const HELPERS: Array = [
	{"icon": "chick", "cost": 15.0, "zps": 0.1,
		"ru": "Цыплёнок", "en": "Chick",
		"line_ru": "Пип! Тут тепло? Я останусь!", "line_en": "Peep! Is it warm here? I'm staying!"},
	{"icon": "frog", "cost": 100.0, "zps": 1.0,
		"ru": "Лягушка", "en": "Frog",
		"line_ru": "Ква-а. Лучшее место для медитации.", "line_en": "Rib-bit. Best meditation spot ever."},
	{"icon": "duck", "cost": 1100.0, "zps": 8.0,
		"ru": "Селезень", "en": "Drake",
		"line_ru": "Кря! Вода тёплая, как в детстве.", "line_en": "Quack! The water is warm, just like when I was little."},
	{"icon": "penguin", "cost": 12000.0, "zps": 47.0,
		"ru": "Пингвин", "en": "Penguin",
		"line_ru": "Я с холодных берегов. Здесь мне нравится больше.", "line_en": "I'm from the cold shores. I like it better here."},
	{"icon": "sloth", "cost": 130000.0, "zps": 260.0,
		"ru": "Ленивец", "en": "Sloth",
		"line_ru": "Я... не спешил... но... дошёл.", "line_en": "I... took... my time... but... I'm here."},
	{"icon": "monkey", "cost": 1400000.0, "zps": 1400.0,
		"ru": "Снежная макака", "en": "Snow Monkey",
		"line_ru": "Мы, макаки, знаем толк в горячих источниках.", "line_en": "We monkeys know a thing or two about hot springs."},
	{"icon": "owl", "cost": 20000000.0, "zps": 7800.0,
		"ru": "Мудрая сова", "en": "Wise Owl",
		"line_ru": "Я помню, каким этот источник был раньше.", "line_en": "I remember what this spring used to be."},
	{"icon": "panda", "cost": 330000000.0, "zps": 44000.0,
		"ru": "Панда", "en": "Panda",
		"line_ru": "Можно я просто полежу рядом?", "line_en": "Can I just lie here next to you?"},
	{"icon": "orca", "cost": 5100000000.0, "zps": 260000.0,
		"ru": "Косатка", "en": "Orca",
		"line_ru": "Я приплыла по реке. Не спрашивай как.", "line_en": "I swam up the river. Don't ask how."},
	{"icon": "rabbit", "cost": 75000000000.0, "zps": 1600000.0,
		"ru": "Лунный кролик", "en": "Moon Rabbit",
		"line_ru": "Я видела тебя с Луны. Ты светишься.", "line_en": "I saw you from the Moon. You glow."},
	# --- Книга вторая (chapter_req: с какой главы друг может появиться) ---
	{"icon": "goat", "cost": 1000000000000.0, "zps": 9500000.0, "chapter_req": 8,
		"ru": "Горная коза", "en": "Mountain Goat",
		"line_ru": "Мее! Я знаю на перевале каждый камень. Пойдём, покажу дорогу.",
		"line_en": "Meh-eh! I know every rock on this pass. Come on, I'll show you the way."},
	{"icon": "walrus", "cost": 14000000000000.0, "zps": 56000000.0, "chapter_req": 9,
		"ru": "Морж", "en": "Walrus",
		"line_ru": "Я сто лет сторожил это озеро. Можно теперь я посторожу его отсюда, из тёплой воды?",
		"line_en": "I've guarded this lake for a hundred years. Mind if I guard it from the warm water now?"},
	{"icon": "parrot", "cost": 200000000000000.0, "zps": 330000000.0, "chapter_req": 10,
		"ru": "Попугай", "en": "Parrot",
		"line_ru": "Весна! Зима! Лето! Осень! Ой, я всё перепутал. Погода тоже.",
		"line_en": "Spring! Winter! Summer! Autumn! Oops, I mixed them up. So did the weather."},
	{"icon": "moose", "cost": 2900000000000000.0, "zps": 2000000000.0, "chapter_req": 11,
		"ru": "Лось", "en": "Moose",
		"line_ru": "Я хожу во сне. Зато всегда прихожу куда нужно.",
		"line_en": "I sleepwalk. But I always end up exactly where I need to be."},
	{"icon": "hippo", "cost": 42000000000000000.0, "zps": 12000000000.0, "chapter_req": 12,
		"ru": "Бегемот", "en": "Hippo",
		"line_ru": "Тёплая вода? Мягкая грязь? Можешь больше ничего не говорить.",
		"line_en": "Warm water? Soft mud? Say no more."},
	{"icon": "elephant", "cost": 610000000000000000.0, "zps": 70000000000.0, "chapter_req": 13,
		"ru": "Слониха", "en": "Elephant",
		"line_ru": "Я помню все вёсны до одной. Хочешь, расскажу про самую первую?",
		"line_en": "I remember every spring there ever was. Want to hear about the very first one?"},
	{"icon": "giraffe", "cost": 9000000000000000000.0, "zps": 410000000000.0, "chapter_req": 14,
		"ru": "Жираф", "en": "Giraffe",
		"line_ru": "Сверху видно, где спит Весна. Совсем рядом с небом.",
		"line_en": "From up here I can see where Spring sleeps. Right next to the sky."},
	{"icon": "bear", "cost": 135000000000000000000.0, "zps": 2400000000000.0, "chapter_req": 14,
		"ru": "Медведь", "en": "Bear",
		"line_ru": "Я берёг её сон. Но, кажется, мы оба проспали.",
		"line_en": "I was watching over her sleep. But I think we both overslept."},
]

const CHAPTERS: Array = [
	{"at": 0.0, "tint": Color(0.72, 0.82, 1.0),
		"place_ru": "Остывший источник", "place_en": "The Cold Spring",
		"text_ru": "Капи проснулась у старого источника. Вода ледяная, долина пуста: звери ушли, когда пришёл Вечный Холод.\n\nНо если просто сидеть спокойно... вода чуть-чуть теплеет.\n\nНажимай на Капи и копи дзен.",
		"text_en": "Capy woke up by the old spring. The water is icy and the valley is empty: the animals left when the Endless Cold came.\n\nBut if you just sit calmly... the water gets a tiny bit warmer.\n\nTap Capy to gather zen."},
	{"at": 500.0, "tint": Color(0.86, 0.92, 1.0),
		"place_ru": "Тёплая лужица", "place_en": "The Warm Puddle",
		"text_ru": "Пар! Над водой поднялась первая струйка пара. Снег вокруг подтаял.\n\nИз камышей выглянул кто-то маленький и любопытный. Спокойствие заразительно.",
		"text_en": "Steam! The first wisp of steam rises over the water. The snow around starts to melt.\n\nSomeone small and curious peeks out of the reeds. Calm is contagious."},
	{"at": 50000.0, "tint": Color(0.9, 1.0, 0.9),
		"place_ru": "Бамбуковая роща", "place_en": "The Bamboo Grove",
		"text_ru": "Слух о тёплом источнике разлетелся по роще. Звери возвращаются один за другим.\n\nКто-то шепчет, что Холод спустился с вершины горы.",
		"text_en": "Word of the warm spring spreads through the grove. The animals come back one by one.\n\nSomeone whispers that the Cold came down from the mountain top."},
	{"at": 5000000.0, "tint": Color(1.0, 1.0, 1.0),
		"place_ru": "Речная долина", "place_en": "The River Valley",
		"text_ru": "Река снова течёт, вдоль берегов распускаются цветы.\n\nМудрая сова вспоминает: «Раньше на горе жил Дух Зимы. Он никогда не был злым. Просто ему было одиноко».",
		"text_en": "The river flows again and flowers bloom along its banks.\n\nThe wise owl remembers: \"A Winter Spirit used to live on the mountain. He was never evil. He was just lonely.\""},
	{"at": 500000000.0, "tint": Color(1.0, 0.94, 0.88),
		"place_ru": "Горный онсэн", "place_en": "The Mountain Onsen",
		"text_ru": "Капи с друзьями поднялась к горному онсэну. Здесь холодно, но дзен всей долины греет лучше любого огня.\n\nНаверху, в тумане, что-то шевелится.\n\nОткрыт Великий Сон: можно начать заново, но сильнее.",
		"text_en": "Capy and friends climb up to the mountain onsen. It's cold here, but the zen of the whole valley is warmer than any fire.\n\nSomething stirs in the fog above.\n\nThe Great Nap is unlocked: start over, but stronger."},
	{"at": 100000000000.0, "tint": Color(1.0, 0.92, 1.0),
		"place_ru": "Облачный сад", "place_en": "The Cloud Garden",
		"text_ru": "Над облаками есть сад, где время течёт медленно. Каждый Великий Сон оставляет после себя золотой мандарин.\n\nДух Зимы наблюдает издалека.",
		"text_en": "Above the clouds there is a garden where time flows slowly. Every Great Nap leaves a golden mandarin behind.\n\nThe Winter Spirit watches from afar."},
	{"at": 50000000000000.0, "tint": Color(0.93, 0.9, 1.0),
		"place_ru": "Небесный источник", "place_en": "The Sky Spring",
		"text_ru": "Дух Зимы спустился к воде. Он огромный, весь из инея и тишины.\n\nКапи подвинулась и молча освободила ему место. Иногда это лучшее, что можно сказать.",
		"text_en": "The Winter Spirit comes down to the water. He is huge, made of frost and silence.\n\nCapy scoots over and quietly makes room. Sometimes that's the best thing you can say."},
	{"at": 10000000000000000.0, "tint": Color(0.82, 0.84, 1.0),
		"place_ru": "Лунная гладь", "place_en": "The Moon Mirror",
		"text_ru": "Впервые за сто лет Дух Зимы улыбнулся. Снег превратился в тёплый туман, и долина снова полна жизни.\n\nА Капи... Капи просто отдыхает.\n\nКонец первой книги. Только почему-то почки на деревьях до сих пор не раскрылись...",
		"text_en": "For the first time in a hundred years, the Winter Spirit smiles. The snow turns into warm mist and the valley is full of life again.\n\nAnd Capy... Capy just rests.\n\nEnd of book one. But for some reason, the buds on the trees still haven't opened..."},
	# --- Книга вторая «Спящая Весна» ---
	{"at": 2.0e17, "tint": Color(0.92, 0.95, 1.0),
		"place_ru": "Тропа за перевалом", "place_en": "The Path Beyond the Pass",
		"text_ru": "Долина тёплая, но деревья так и не зацвели: почки сидят закрытыми, будто ждут чьего-то разрешения.\n\nДух Зимы смущённо кашляет снежинкой: «Это из-за меня. Пока я грустил, никто не разбудил мою младшую сестру, Весну. Она спит уже сто лет».\n\nКапи знает о сне почти всё. Значит, идти ей. За перевалом уже ждёт кто-то с рогами и очень уверенной походкой.",
		"text_en": "The valley is warm, but the trees still haven't bloomed. The buds stay shut, as if waiting for permission.\n\nThe Winter Spirit coughs up a shy little snowflake: \"It's my fault. While I was sad, nobody woke my little sister, Spring. She's been asleep for a hundred years.\"\n\nCapy knows almost everything about sleep. So Capy is the one to go. Beyond the pass, someone with horns and a very confident stride is already waiting."},
	{"at": 1.0e19, "tint": Color(0.82, 0.93, 1.0),
		"place_ru": "Поющее озеро", "place_en": "The Singing Lake",
		"text_ru": "За перевалом лежит озеро. Лёд на нём тонкий и звенит под лапами, как стеклянный колокольчик.\n\nСтранное дело: у одного берега цветут кувшинки, а у другого метёт метель. Старый морж греет живот на солнечной стороне, а ласты студит на снежной. Говорит, так и живёт лет сто.\n\nВремена года перепутались. Без Весны некому подсказать им, чья сейчас очередь.",
		"text_en": "Beyond the pass lies a lake. Its ice is thin and rings under your paws like a glass bell.\n\nOddly, water lilies bloom by one shore while a blizzard blows by the other. An old walrus warms his belly on the sunny side and cools his flippers on the snowy one. He says he's lived like this for about a hundred years.\n\nThe seasons have gotten tangled. Without Spring, nobody tells them whose turn it is."},
	{"at": 3.0e20, "tint": Color(1.0, 0.93, 0.85),
		"place_ru": "Пёстрый лес", "place_en": "The Patchwork Forest",
		"text_ru": "В этом лесу всё сразу: на одной ветке иней, на соседней сакура, а жёлтые листья падают... вверх.\n\nПопугай кричит: «Лето! Зима! Осень!» — и погода каждый раз послушно меняется. Пришлось вежливо попросить его помолчать.\n\nМудрая сова объясняет: времена года ходят по кругу, как друзья вокруг источника. Если кто-то уснул и не встал, весь круг останавливается.",
		"text_en": "This forest has everything at once: frost on one branch, cherry blossoms on the next, and yellow leaves falling... upward.\n\nA parrot shouts, \"Summer! Winter! Autumn!\" and every time, the weather obediently changes. Someone had to politely ask him to hush.\n\nThe wise owl explains: the seasons walk in a circle, like friends around the spring. If one falls asleep and doesn't get up, the whole circle stops."},
	{"at": 1.0e22, "tint": Color(0.88, 0.86, 1.0),
		"place_ru": "Сонные холмы", "place_en": "The Drowsy Hills",
		"text_ru": "Чем ближе к Весне, тем сильнее клонит в сон. На этих холмах зевают даже ромашки.\n\nДорогу показывает лось. Он идёт с закрытыми глазами и ни разу не споткнулся: во сне, говорит, тропу видно лучше.\n\nНа привале Капи сворачивается клубочком и попадает в чужой сон. Там цветы, тёплый дождь и кто-то маленький, кто очень боится проснуться.",
		"text_en": "The closer you get to Spring, the sleepier you feel. On these hills even the daisies yawn.\n\nA moose leads the way. He walks with his eyes closed and hasn't tripped once: the path, he says, is easier to see in your sleep.\n\nDuring a rest, Capy curls up and drifts into someone else's dream. There are flowers, warm rain, and someone small who is very afraid to wake up."},
	{"at": 3.0e23, "tint": Color(1.0, 0.9, 0.8),
		"place_ru": "Грязевые ванны", "place_en": "The Mud Baths",
		"text_ru": "В низине булькают тёплые грязевые ванны. Бегемот лежит в самой большой и называет это работой.\n\nЦветы здесь распускаются, только пока кто-нибудь рядом спит. Это сны Весны понемногу просачиваются наружу.\n\nИ Капи понимает главное: Весна не просто проспала. Она боится, что разучилась делать весну. И что все давно привыкли жить без неё.",
		"text_en": "Warm mud baths bubble in the lowlands. A hippo lies in the biggest one and calls it work.\n\nHere, flowers only bloom while someone is sleeping nearby. Spring's dreams are slowly leaking out.\n\nAnd Capy understands the most important thing: Spring didn't just oversleep. She's afraid she's forgotten how to make spring. And that everyone got used to living without her long ago."},
	{"at": 1.0e25, "tint": Color(0.95, 1.0, 0.88),
		"place_ru": "Сад воспоминаний", "place_en": "The Garden of Memories",
		"text_ru": "Старая слониха бережёт сад, где каждое дерево — чья-то весна. Она помнит их все, до самой первой.\n\nДрузья по очереди вспоминают, за что любят весну. Цыплёнок — за первые лужи. Ленивец — за то, что она никуда не торопится. Панда — за молодой бамбук, конечно.\n\nСлониха собирает воспоминания в букет. «Отнесём ей, — говорит она. — Пусть знает, что её ждут».",
		"text_en": "An old elephant tends a garden where every tree is somebody's spring. She remembers them all, back to the very first.\n\nThe friends take turns sharing what they love about spring. Chick loves the first puddles. Sloth loves that spring never rushes. Panda loves the young bamboo, of course.\n\nThe elephant gathers the memories into a bouquet. \"Let's take it to her,\" she says. \"So she knows she's been missed.\""},
	{"at": 3.0e26, "tint": Color(0.86, 0.87, 1.0),
		"place_ru": "Звёздная лестница", "place_en": "The Starlit Stairs",
		"text_ru": "К пещере Весны ведёт лестница из светлячков. Она висит прямо в небе, и первую ступеньку видит только жираф.\n\nНаверху, в мягком мху, спит Весна: маленькая, тёплая, с ромашкой за ухом. А вокруг неё, свернувшись калачиком, храпит огромный медведь.\n\n«Я ждал, когда она проснётся, — шепчет он, приоткрыв один глаз. — А она, кажется, ждала меня». Сто лет они вежливо ждали друг друга.",
		"text_en": "A staircase of fireflies leads to Spring's cave. It hangs right in the sky, and only the giraffe can see the first step.\n\nAt the top, in soft moss, Spring is asleep: small, warm, with a daisy behind her ear. Curled around her, a huge bear is snoring.\n\n\"I was waiting for her to wake up,\" he whispers, opening one eye. \"And I think she was waiting for me.\" For a hundred years, they politely waited for each other."},
	{"at": 1.0e28, "tint": Color(1.0, 0.94, 0.97),
		"place_ru": "Первая весна", "place_en": "The First Spring",
		"text_ru": "Капи не будит Весну. Она просто садится рядом и молчит — совсем как когда-то с Духом Зимы.\n\nДух Зимы кладёт у её лап одну-единственную снежинку. Друзья приносят букет воспоминаний. А Капи шепчет: «Ничего не нужно уметь. Просто просыпайся. Мы рядом».\n\nВесна открывает глаза — и вся долина зацветает разом. Колесо времён года скрипит и снова поворачивается. Брат и сестра обнимаются у источника впервые за сто лет.\n\nКонец второй книги. Говорят, у них есть ещё Лето и Осень... Но это уже совсем другая история.",
		"text_en": "Capy doesn't wake Spring. Capy just sits beside her in silence, just like with the Winter Spirit long ago.\n\nThe Winter Spirit lays a single snowflake by her paws. The friends bring the bouquet of memories. And Capy whispers: \"You don't have to know how. Just wake up. We're here.\"\n\nSpring opens her eyes, and the whole valley blooms at once. The Wheel of Seasons creaks and starts turning again. For the first time in a hundred years, brother and sister hug by the spring.\n\nEnd of book two. They say there are also Summer and Autumn... But that's a whole other story."},
]

## Индекс первой главы второй книги (разделитель во вкладке «История»).
const BOOK2_FIRST_CHAPTER: int = 8

const NAP_CHAPTER: int = 4

## Уровни улучшений друзей. Новые уровни ДОПИСЫВАТЬ В КОНЕЦ: id улучшения = h<друг>_<индекс>,
## и сейвы хранят эти id. Уровни 8–11 (5/15/35/75 шт.) — промежуточные x1.5, чтобы улучшения
## появлялись чаще.
const TIER_REQ: Array = [1, 10, 25, 50, 100, 150, 200, 5, 15, 35, 75]
const TIER_COST: Array = [10.0, 50.0, 500.0, 50000.0, 5000000.0, 5000000000.0, 5000000000000.0, 25.0, 150.0, 5000.0, 500000.0]
const TIER_MULT: Array = [2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 1.2, 1.2, 1.2, 1.2]
const TIER_RU: Array = ["Тёплый плед", "Травяной чай", "Песни у воды", "Общий сон", "Легенда долины", "Цветущий венок", "Свет первой весны", "Мягкое полотенце", "Тёплый камушек", "Вечерний костёр", "Звёздная ночёвка"]
const TIER_EN: Array = ["Warm Blanket", "Herbal Tea", "Songs by the Water", "Shared Nap", "Valley Legend", "Blossom Wreath", "Light of the First Spring", "Soft Towel", "Warm Pebble", "Evening Campfire", "Starlit Sleepover"]

## Во сколько раз друзья дают больше дзена (по отзывам игроков пассив был слабым).
const ZPS_BOOST: float = 2.0

## Общие улучшения «все друзья +ALL_MULT»: стоимость, ru, en.
const ALL_MULT: float = 1.2
const ALL_UPGRADES: Array = [
	[10000.0, "Тёплые камни", "Warm Stones"],
	[10000000.0, "Бамбуковые циновки", "Bamboo Mats"],
	[10000000000.0, "Общий чайник", "Shared Teapot"],
	[1.0e13, "Фонарики над водой", "Lanterns over the Water"],
	[1.0e16, "Песни сверчков", "Cricket Songs"],
	[1.0e19, "Мандариновый пар", "Mandarin Steam"],
	[1.0e22, "Звёздное небо", "Starry Sky"],
	[1.0e25, "Облачные подушки", "Cloud Pillows"],
	[1.0e28, "Лунный свет", "Moonlight"],
]

## Каждое полученное достижение навсегда даёт +2% ко всему дзену.
const ACH_BONUS: float = 0.02

## Достижения: stat — что считаем (см. Game.ach_value), goal — сколько нужно.
const ACHIEVEMENTS: Array = [
	{"id": "tap_100", "stat": "taps", "goal": 100, "ru": "Первые шаги", "en": "First Steps", "d_ru": "Нажать на Капи 100 раз", "d_en": "Tap Capy 100 times"},
	{"id": "tap_1k", "stat": "taps", "goal": 1000, "ru": "Тёплые лапки", "en": "Warm Paws", "d_ru": "Нажать на Капи 1 000 раз", "d_en": "Tap Capy 1,000 times"},
	{"id": "tap_10k", "stat": "taps", "goal": 10000, "ru": "Мастер дзена", "en": "Zen Master", "d_ru": "Нажать на Капи 10 000 раз", "d_en": "Tap Capy 10,000 times"},
	{"id": "tap_50k", "stat": "taps", "goal": 50000, "ru": "Неутомимая лапка", "en": "Tireless Paw", "d_ru": "Нажать на Капи 50 000 раз", "d_en": "Tap Capy 50,000 times"},
	{"id": "fr_10", "stat": "friends", "goal": 10, "ru": "Тёплая компания", "en": "Cozy Company", "d_ru": "Позвать 10 друзей", "d_en": "Invite 10 friends"},
	{"id": "fr_100", "stat": "friends", "goal": 100, "ru": "Шумная заводь", "en": "Busy Pond", "d_ru": "Позвать 100 друзей", "d_en": "Invite 100 friends"},
	{"id": "fr_500", "stat": "friends", "goal": 500, "ru": "Целая долина", "en": "A Whole Valley", "d_ru": "Позвать 500 друзей", "d_en": "Invite 500 friends"},
	{"id": "fr_1500", "stat": "friends", "goal": 1500, "ru": "Источник не резиновый", "en": "Standing Room Only", "d_ru": "Позвать 1 500 друзей", "d_en": "Invite 1,500 friends"},
	{"id": "kind_5", "stat": "kinds", "goal": 5, "ru": "Новые лица", "en": "New Faces", "d_ru": "Познакомиться с 5 видами зверей", "d_en": "Meet 5 kinds of animals"},
	{"id": "kind_10", "stat": "kinds", "goal": 10, "ru": "Все в сборе", "en": "Everyone's Here", "d_ru": "Познакомиться с 10 видами зверей", "d_en": "Meet 10 kinds of animals"},
	{"id": "kind_18", "stat": "kinds", "goal": 18, "ru": "Друг каждому", "en": "Friend to All", "d_ru": "Познакомиться со всеми 18 зверями", "d_en": "Meet all 18 animals"},
	{"id": "gold_1", "stat": "golden", "goal": 1, "ru": "Сладкая находка", "en": "Sweet Find", "d_ru": "Поймать золотой мандарин", "d_en": "Catch a golden mandarin"},
	{"id": "gold_10", "stat": "golden", "goal": 10, "ru": "Мандариновый сбор", "en": "Mandarin Harvest", "d_ru": "Поймать 10 золотых мандаринов", "d_en": "Catch 10 golden mandarins"},
	{"id": "gold_50", "stat": "golden", "goal": 50, "ru": "Ловкие лапки", "en": "Quick Paws", "d_ru": "Поймать 50 золотых мандаринов", "d_en": "Catch 50 golden mandarins"},
	{"id": "gold_200", "stat": "golden", "goal": 200, "ru": "Мандариновый король", "en": "Mandarin Royalty", "d_ru": "Поймать 200 золотых мандаринов", "d_en": "Catch 200 golden mandarins"},
	{"id": "ups_10", "stat": "ups", "goal": 10, "ru": "Обустройство", "en": "Settling In", "d_ru": "Купить 10 улучшений", "d_en": "Buy 10 upgrades"},
	{"id": "ups_50", "stat": "ups", "goal": 50, "ru": "Уютный дом", "en": "Cozy Home", "d_ru": "Купить 50 улучшений", "d_en": "Buy 50 upgrades"},
	{"id": "ups_200", "stat": "ups", "goal": 200, "ru": "Курорт мечты", "en": "Dream Resort", "d_ru": "Купить 200 улучшений", "d_en": "Buy 200 upgrades"},
	{"id": "zen_1m", "stat": "total", "goal": 1000000, "ru": "Миллион вдохов", "en": "A Million Breaths", "d_ru": "Накопить всего 1M дзена", "d_en": "Gather 1M zen in total"},
	{"id": "zen_1b", "stat": "total", "goal": 1000000000, "ru": "Миллиард улыбок", "en": "A Billion Smiles", "d_ru": "Накопить всего 1B дзена", "d_en": "Gather 1B zen in total"},
	{"id": "zen_1t", "stat": "total", "goal": 1000000000000, "ru": "Океан спокойствия", "en": "Ocean of Calm", "d_ru": "Накопить всего 1T дзена", "d_en": "Gather 1T zen in total"},
	{"id": "zen_1qa", "stat": "total", "goal": 1.0e15, "ru": "Безмятежность", "en": "Serenity", "d_ru": "Накопить всего 1Qa дзена", "d_en": "Gather 1Qa zen in total"},
	{"id": "ch_3", "stat": "chapter", "goal": 3, "ru": "Роща оживает", "en": "The Grove Awakens", "d_ru": "Дойти до главы 3", "d_en": "Reach chapter 3"},
	{"id": "ch_5", "stat": "chapter", "goal": 5, "ru": "На вершине", "en": "At the Top", "d_ru": "Дойти до главы 5", "d_en": "Reach chapter 5"},
	{"id": "ch_8", "stat": "chapter", "goal": 8, "ru": "Конец первой книги", "en": "End of Book One", "d_ru": "Дойти до главы 8", "d_en": "Reach chapter 8"},
	{"id": "ch_12", "stat": "chapter", "goal": 12, "ru": "Пёстрая тропа", "en": "Patchwork Path", "d_ru": "Дойти до главы 12", "d_en": "Reach chapter 12"},
	{"id": "ch_16", "stat": "chapter", "goal": 16, "ru": "Весна пришла", "en": "Spring Has Come", "d_ru": "Дойти до главы 16", "d_en": "Reach chapter 16"},
	{"id": "nap_1", "stat": "naps", "goal": 1, "ru": "Сладкий сон", "en": "Sweet Dreams", "d_ru": "Впервые уснуть Великим Сном", "d_en": "Take your first Great Nap"},
	{"id": "nap_5", "stat": "naps", "goal": 5, "ru": "Соня", "en": "Sleepyhead", "d_ru": "Уснуть Великим Сном 5 раз", "d_en": "Take 5 Great Naps"},
	{"id": "nap_20", "stat": "naps", "goal": 20, "ru": "Мастер сновидений", "en": "Dream Master", "d_ru": "Уснуть Великим Сном 20 раз", "d_en": "Take 20 Great Naps"},
]

const STRINGS: Dictionary = {
	"per_sec": {"ru": "%s дзена в секунду", "en": "%s zen per second"},
	"zen": {"ru": "дзен", "en": "zen"},
	"tab_friends": {"ru": "Друзья", "en": "Friends"},
	"tab_upgrades": {"ru": "Улучшения", "en": "Upgrades"},
	"tab_story": {"ru": "История", "en": "Story"},
	"tab_more": {"ru": "Сон", "en": "Nap"},
	"owned": {"ru": "x%d · %s/с", "en": "x%d · %s/s"},
	"each": {"ru": "каждый +%s/с", "en": "each +%s/s"},
	"locked": {"ru": "???", "en": "???"},
	"locked_hint": {"ru": "Кто-то прячется в камышах...", "en": "Someone is hiding in the reeds..."},
	"no_upgrades": {"ru": "Пока нет улучшений. Копи дзен и зови друзей!", "en": "No upgrades yet. Gather zen and invite friends!"},
	"up_helper": {"ru": "%s: в 2 раза больше дзена", "en": "%s: 2x more zen"},
	"up_tap": {"ru": "Нажатие даёт в 2 раза больше", "en": "Taps give 2x more"},
	"up_tapzps": {"ru": "Нажатие +%d%% от дзена в секунду", "en": "Taps get +%d%% of zen per second"},
	"up_golden_often": {"ru": "Золотые мандарины появляются чаще", "en": "Golden mandarins appear more often"},
	"up_golden_long": {"ru": "Эффекты мандаринов длятся вдвое дольше", "en": "Mandarin effects last twice as long"},
	"next_chapter": {"ru": "Следующая глава: накопи всего %s дзена", "en": "Next chapter: gather %s zen in total"},
	"chapter": {"ru": "Глава %d", "en": "Chapter %d"},
	"continue": {"ru": "Дальше", "en": "Continue"},
	"nice": {"ru": "Отлично", "en": "Nice"},
	"nap_title": {"ru": "Великий Сон", "en": "The Great Nap"},
	"nap_desc": {"ru": "Капи засыпает и видит сон о новой весне. Дзен, друзья и улучшения сбросятся, но ты получишь золотые мандарины. Каждый мандарин навсегда даёт +5% ко всему дзену.", "en": "Capy falls asleep and dreams of a new spring. Zen, friends and upgrades reset, but you get golden mandarins. Each mandarin permanently gives +5% to all zen."},
	"nap_locked": {"ru": "Откроется в главе 5 «Горный онсэн».", "en": "Unlocks in chapter 5, \"The Mountain Onsen\"."},
	"nap_gain": {"ru": "Уснуть и получить %s мандаринов", "en": "Nap and get %s mandarins"},
	"nap_none": {"ru": "Нужно больше дзена для нового мандарина", "en": "Need more zen for a new mandarin"},
	"nap_confirm": {"ru": "Точно? Нажми ещё раз", "en": "Sure? Tap again"},
	"mandarins": {"ru": "Мандарины: %d (+%d%%)", "en": "Mandarins: %d (+%d%%)"},
	"stats": {"ru": "Всего дзена: %s\nНажатий: %d\nВеликих Снов: %d", "en": "Total zen: %s\nTaps: %d\nGreat Naps: %d"},
	"lang": {"ru": "Language: English", "en": "Язык: Русский"},
	"reset": {"ru": "Стереть прогресс", "en": "Erase progress"},
	"reset_confirm": {"ru": "Точно стереть всё? Нажми ещё раз", "en": "Erase everything? Tap again"},
	"offline_title": {"ru": "С возвращением!", "en": "Welcome back!"},
	"offline_text": {"ru": "Пока тебя не было, друзья накопили %s дзена.", "en": "While you were away, your friends gathered %s zen."},
	"friend_joined": {"ru": "%s теперь с вами!", "en": "%s joined you!"},
	"g_frenzy": {"ru": "Мандариновый вихрь! Дзен x7", "en": "Mandarin frenzy! Zen x7"},
	"g_lucky": {"ru": "Удача! +%s дзена", "en": "Lucky! +%s zen"},
	"g_tap": {"ru": "Лапки-молнии! Нажатия x77", "en": "Lightning paws! Taps x77"},
	"buff_frenzy": {"ru": "Вихрь x7: %d с", "en": "Frenzy x7: %ds"},
	"buff_tap": {"ru": "Лапки x77: %d с", "en": "Paws x77: %ds"},
	"buy_mode": {"ru": "Покупать: %s", "en": "Buy: %s"},
	"up_all": {"ru": "Все друзья дают на %d%% больше", "en": "All friends give %d%% more"},
	"up_helper_pct": {"ru": "%s: на %d%% больше дзена", "en": "%s: %d%% more zen"},
	"tab_awards": {"ru": "Награды", "en": "Awards"},
	"ach_claim": {"ru": "Забрать", "en": "Claim"},
	"ach_done": {"ru": "Получено", "en": "Claimed"},
	"ach_reward": {"ru": "+2% ко всему дзену навсегда", "en": "+2% to all zen forever"},
	"ach_ready": {"ru": "Достижение: %s! Загляни в «Награды»", "en": "Achievement: %s! Check Awards"},
	"ach_header": {"ru": "Получено %d из %d · бонус +%d%%", "en": "%d of %d claimed · bonus +%d%%"},
	"settings": {"ru": "Настройки", "en": "Settings"},
	"music": {"ru": "Музыка", "en": "Music"},
	"sounds": {"ru": "Звуки", "en": "Sounds"},
	"close": {"ru": "Закрыть", "en": "Close"},
	"chapter_progress": {"ru": "До главы %d: %d%%", "en": "To chapter %d: %d%%"},
	# --- Книга вторая ---
	"story_end": {"ru": "Обе книги прочитаны! Третья уже пишется, а дзен можно копить бесконечно.", "en": "You've read both books! Book three is on its way, and zen is endless."},
	"book": {"ru": "Книга %d", "en": "Book %d"},
	"book1_title": {"ru": "Книга первая · Вечный Холод", "en": "Book One · The Endless Cold"},
	"book2_title": {"ru": "Книга вторая · Спящая Весна", "en": "Book Two · The Sleeping Spring"},
	"friend_talk": {"ru": "%s хочет что-то сказать", "en": "%s has something to say"},
	"friendship": {"ru": "Дружба: %d/%d", "en": "Friendship: %d/%d"},
	"friend_line_locked": {"ru": "Станьте ближе, чтобы услышать (x%d)", "en": "Get closer to hear more (x%d)"},
	"locked_hint_book2": {"ru": "Кто-то ждёт дальше по тропе...", "en": "Someone is waiting further down the path..."},
	"event_ends": {"ru": "Праздник продлится ещё %d дн.", "en": "Event ends in %d days"},
	"event_collected": {"ru": "Собрано: %d", "en": "Collected: %d"},
}


# ---------- Реплики дружбы ----------
# Ключ — icon друга. "at" — сколько штук нужно иметь (owned), чтобы реплика открылась.

const FRIEND_LINES: Dictionary = {
	"chick": [
		{"at": 10, "ru": "Я подрос на целое пёрышко! Ну, почти.", "en": "I grew a whole new feather! Well, almost."},
		{"at": 25, "ru": "Капи, как ты такая спокойная? Научи! Только быстро!", "en": "Capy, how are you so calm? Teach me! Quickly!"},
		{"at": 50, "ru": "Я больше не боюсь холода. У меня же есть вы.", "en": "I'm not afraid of the cold anymore. I have all of you."},
	],
	"frog": [
		{"at": 10, "ru": "Ква. Я досчитала до ста вдохов. А потом уснула.", "en": "Ribbit. I counted a hundred breaths. Then I fell asleep."},
		{"at": 25, "ru": "Говорят, если долго сидеть на кувшинке, сам станешь кувшинкой. Проверяю.", "en": "They say if you sit on a lily pad long enough, you become one. Testing it."},
		{"at": 50, "ru": "Раньше я подпрыгивала от каждого шороха. А теперь просто сижу. Так лучше.", "en": "I used to jump at every little sound. Now I just sit. It's better."},
	],
	"duck": [
		{"at": 10, "ru": "Я научил утят плавать кругами. Они думают, что это танец.", "en": "I taught the ducklings to swim in circles. They think it's a dance."},
		{"at": 25, "ru": "Кря. Если что, за пузырьки здесь отвечаю я.", "en": "Quack. Just so you know, I'm in charge of bubbles here."},
		{"at": 50, "ru": "Мама говорила: найди свою тёплую воду. Кажется, нашёл.", "en": "Mom used to say: find your warm water. I think I did."},
	],
	"penguin": [
		{"at": 10, "ru": "Я привёз с собой льдинку на память. Она растаяла. Не жалею.", "en": "I brought an ice cube as a keepsake. It melted. No regrets."},
		{"at": 25, "ru": "Дома мы жались друг к другу, чтобы не замёрзнуть. Здесь жмёмся просто так. От любви.", "en": "Back home we huddled to keep from freezing. Here we huddle just because. Out of love."},
		{"at": 50, "ru": "Я написал домой: «Приезжайте все». Ждём восемьсот пингвинов.", "en": "I wrote home: \"Everyone, come.\" Expect eight hundred penguins."},
	],
	"sloth": [
		{"at": 10, "ru": "Я... стал... говорить... быстрее. Заметно?", "en": "I've... started... talking... faster. Can you... tell?"},
		{"at": 25, "ru": "Вчера... я... моргнул. Было... здорово.", "en": "Yesterday... I... blinked. It was... great."},
		{"at": 50, "ru": "Спешить... некуда. Всё... хорошее... уже... здесь.", "en": "No... rush. Everything... good... is... already... here."},
	],
	"monkey": [
		{"at": 10, "ru": "Главное правило онсэна: голова над водой, заботы на берегу.", "en": "Rule one of the onsen: head above the water, worries on the shore."},
		{"at": 25, "ru": "Я слепила снежок. Просто подержать. Кидаться — это не дзен.", "en": "I made a snowball. Just to hold. Throwing it wouldn't be very zen."},
		{"at": 50, "ru": "Мы с Капи молчим уже час. Лучший разговор за год.", "en": "Capy and I have been quiet for an hour. Best talk I've had all year."},
	],
	"owl": [
		{"at": 10, "ru": "Я записываю всё, что здесь происходит. Пока что: все отдыхают.", "en": "I'm writing down everything that happens here. So far: everyone is resting."},
		{"at": 25, "ru": "Мудрость — это знать, когда промолчать. И когда пора пить чай.", "en": "Wisdom is knowing when to stay quiet. And when it's time for tea."},
		{"at": 50, "ru": "Раньше я помнила, каким был источник. Теперь мне больше нравится, какой он сейчас.", "en": "I used to remember what the spring was like. Now I like what it is today even more."},
	],
	"panda": [
		{"at": 10, "ru": "Я несла бамбук на всех. Почти весь съела по дороге.", "en": "I brought bamboo for everyone. Ate most of it on the way."},
		{"at": 25, "ru": "Лежать рядом — это тоже дело. Причём важное.", "en": "Lying next to someone counts as doing something. Something important."},
		{"at": 50, "ru": "Если станет грустно, приходи. У меня очень мягкий бок.", "en": "If you ever feel sad, come over. My side is very soft."},
	],
	"orca": [
		{"at": 10, "ru": "Ладно, расскажу: я плыла по реке задом наперёд. Не смейтесь.", "en": "Fine, I'll tell you: I swam up the river backwards. Don't laugh."},
		{"at": 25, "ru": "В океане много места, но тёплой водой там никто не делится. А здесь делятся все.", "en": "The ocean is huge, but nobody there shares warm water. Here, everyone does."},
		{"at": 50, "ru": "Я пою песни китов, а лягушка подпевает. Выходит странно, но красиво.", "en": "I sing whale songs and Frog sings along. It's strange, but beautiful."},
	],
	"rabbit": [
		{"at": 10, "ru": "На Луне я лепила рисовые лепёшки. Здесь — мандариновые. Тоже вкусно.", "en": "On the Moon I made rice cakes. Here I make mandarin ones. Just as tasty."},
		{"at": 25, "ru": "По ночам я показываю всем, где мой дом. Вон та круглая, видите?", "en": "At night I show everyone where my home is. That round one, see?"},
		{"at": 50, "ru": "Я думала, что вернусь на Луну. Но дом, похоже, там, где тепло.", "en": "I thought I'd go back to the Moon. But home seems to be wherever it's warm."},
	],
	# --- Книга вторая ---
	"goat": [
		{"at": 10, "ru": "Я взбиралась на эту скалу тысячу раз. Сегодня впервые просто села и посмотрела вниз.", "en": "I've climbed this rock a thousand times. Today I finally sat down and just looked."},
		{"at": 25, "ru": "Когда я нервничаю, я жую всё подряд. Здесь почти ничего не жую.", "en": "When I'm nervous, I chew on everything. Here I hardly chew anything at all."},
		{"at": 50, "ru": "Самая крутая тропа ведёт сюда. Проверено.", "en": "The steepest path in the world leads right here. I checked."},
	],
	"walrus": [
		{"at": 10, "ru": "Я сто лет сторожил лёд. Оказалось, его не надо было сторожить. Он сам растаял.", "en": "I guarded the ice for a hundred years. Turns out it didn't need guarding. It melted on its own."},
		{"at": 25, "ru": "Мои усы отлично ловят пар. Так я и ловлю дзен.", "en": "My whiskers are great at catching steam. That's how I catch zen."},
		{"at": 50, "ru": "Мы с пингвином раньше спорили, чей берег холоднее. Теперь оба тёплые, и спорить не о чем.", "en": "Penguin and I used to argue whose shore was colder. Now they're both warm, and there's nothing to argue about."},
	],
	"parrot": [
		{"at": 10, "ru": "Капи хорошая! Капи хорошая! Это я сам придумал.", "en": "Good Capy! Good Capy! I came up with that myself."},
		{"at": 25, "ru": "Я выучил, как молчит Капи. Слушай: ...... Похоже?", "en": "I learned how Capy stays quiet. Listen: ...... Sounds right?"},
		{"at": 50, "ru": "Раньше я повторял чужие слова. А теперь у меня есть свои: спасибо, что ты здесь.", "en": "I used to repeat other people's words. Now I have my own: thank you for being here."},
	],
	"moose": [
		{"at": 10, "ru": "Опять проснулся непонятно где. Но тут уютно, так что ладно.", "en": "Woke up somewhere new again. But it's cozy, so that's fine."},
		{"at": 25, "ru": "Мои рога — лучшая вешалка для полотенец в долине. Пользуйтесь.", "en": "My antlers are the best towel rack in the valley. Help yourselves."},
		{"at": 50, "ru": "Во сне я всегда иду к теплу. Вот и пришёл. Насовсем.", "en": "In my sleep I always walk toward warmth. And here I am. For good."},
	],
	"hippo": [
		{"at": 10, "ru": "Грязевая ванна, потом тёплая вода, потом опять грязевая. Вот и весь план.", "en": "Mud bath, then warm water, then mud bath again. That's the whole plan."},
		{"at": 25, "ru": "Меня называют тяжеловесом. А я просто очень основательно отдыхаю.", "en": "People call me a heavyweight. I just rest very thoroughly."},
		{"at": 50, "ru": "Когда я залезаю в воду, она поднимается для всех. Вот что значит делиться.", "en": "When I get into the water, it rises for everyone. That's what sharing means."},
	],
	"elephant": [
		{"at": 10, "ru": "Я поливаю цветы хоботом. Иногда и тебя. Случайно.", "en": "I water the flowers with my trunk. Sometimes you too. By accident."},
		{"at": 25, "ru": "Говорят, слоны ничего не забывают. А я и не хочу забывать ничего из того, что было здесь.", "en": "They say elephants never forget. I don't want to forget a single thing that happened here."},
		{"at": 50, "ru": "Самая первая весна началась с того, что кто-то просто сел рядом с другим. Я помню.", "en": "The very first spring began when someone simply sat down next to someone else. I remember."},
	],
	"giraffe": [
		{"at": 10, "ru": "Сверху пар похож на облака, а облака — на пар. Я запутался, но мне нравится.", "en": "From up here the steam looks like clouds, and the clouds look like steam. I'm confused, but I like it."},
		{"at": 25, "ru": "Я первым вижу рассвет и сразу всем рассказываю. Все ещё спят, но я всё равно рассказываю.", "en": "I see the sunrise first and tell everyone right away. They're all still asleep, but I tell them anyway."},
		{"at": 50, "ru": "С такой шеей трудно обниматься. Поэтому я обнимаю шеей. Всех сразу.", "en": "It's hard to hug with a neck like mine. So I hug with my neck. Everyone at once."},
	],
	"bear": [
		{"at": 10, "ru": "Сто лет спячки. Голова не болит, только очень хочется мёду.", "en": "A hundred years of hibernation. No headache, just a serious craving for honey."},
		{"at": 25, "ru": "Весна говорит, что я храплю. А я говорю, что это колыбельная.", "en": "Spring says I snore. I say it's a lullaby."},
		{"at": 50, "ru": "Теперь буду засыпать каждой осенью и просыпаться каждой весной. Как положено. Рядом с вами.", "en": "Now I'll fall asleep every autumn and wake up every spring. The way it should be. Right next to you."},
	],
}


# ---------- Мысли Капи (облачко над головой) ----------
# Капи в ru — женского рода (как в CHAPTERS). К игроку — без рода.

const CAPY_THOUGHTS: Array = [
	{"ru": "Если долго смотреть на пар, пар начинает смотреть на тебя. Приятно.", "en": "If you stare at the steam long enough, it stares back. Nice."},
	{"ru": "Мандарин на голове — это не шапка. Это образ жизни.", "en": "A mandarin on your head isn't a hat. It's a lifestyle."},
	{"ru": "Можно ничего не делать. Это тоже считается.", "en": "Doing nothing is allowed. It counts too."},
	{"ru": "Тёплая вода. Тихий ветер. Больше ничего не нужно.", "en": "Warm water. A gentle breeze. That's all I need."},
	{"ru": "Интересно, о чём думают камни? Наверное, ни о чём. Молодцы.", "en": "I wonder what rocks think about. Probably nothing. Good for them."},
	{"ru": "Вдох... выдох... ещё мандаринку?", "en": "Breathe in... breathe out... one more mandarin?"},
	{"ru": "Спешить некуда. Источник никуда не убежит.", "en": "No need to hurry. The spring isn't going anywhere."},
	{"ru": "Кажется, я слышу, как растёт трава.", "en": "I think I can hear the grass growing."},
	{"ru": "Хороший день, чтобы немного полежать. Впрочем, как и любой другой.", "en": "A good day to lie around a bit. Like any other day."},
	{"ru": "Облако похоже на капибару. Или это я похожа на облако?", "en": "That cloud looks like a capybara. Or do I look like a cloud?"},
	{"ru": "Все друзья рядом. Можно закрыть глаза.", "en": "All my friends are here. I can close my eyes."},
	{"ru": "Иногда лучший ответ — подвинуться и освободить место.", "en": "Sometimes the best answer is to scoot over and make room."},
	{"ru": "Я не ленюсь. Я берегу силы для отдыха.", "en": "I'm not lazy. I'm saving my energy for resting."},
	{"ru": "Пузырьки поднимаются, заботы опускаются на дно.", "en": "Bubbles float up, worries sink down."},
	{"ru": "Если холодно, просто сядь поближе к кому-нибудь.", "en": "If you feel cold, just sit a little closer to someone."},
	{"ru": "Ещё пять минуточек. Ну ладно, десять.", "en": "Five more minutes. Okay, ten."},
	{"ru": "Хорошо, что ты здесь. Посиди со мной.", "en": "I'm glad you're here. Sit with me."},
	{"ru": "Счастье пахнет мандаринами и мокрой травой.", "en": "Happiness smells like mandarins and wet grass."},
	{"ru": "Планов на сегодня нет. Всё идёт по плану.", "en": "No plans for today. Everything is going according to plan."},
	{"ru": "Мне на нос упала капля. Лучший момент дня.", "en": "A drop just landed on my nose. Best moment of the day."},
]

# Бонус: мысли, которые появляются только во второй книге ("ch" — минимальный индекс главы).
const CAPY_THOUGHTS_BOOK2: Array = [
	{"ch": 8, "ru": "Интересно, Весне снятся сны про нас?", "en": "I wonder if Spring dreams about us."},
	{"ch": 10, "ru": "Сегодня на мне снежинка и лепесток сакуры. Погода не может решиться.", "en": "Today I've got a snowflake and a cherry petal on me. The weather can't make up its mind."},
	{"ch": 11, "ru": "Лось опять спит стоя. Надо у него поучиться.", "en": "Moose is sleeping standing up again. I should take lessons."},
	{"ch": 15, "ru": "Весна проснулась. Можно наконец вздремнуть.", "en": "Spring is awake. Finally, time for a nap."},
]


# ---------- Сезонные события (live-ops) ----------
# Даты — локальные, включительно. "item" заменяет золотой мандарин на время события
# (появляется в 1 из 3 раз вместо обычного), "hat" — косметика на голове Капи.

const EVENTS: Array = [
	{"id": "new_year", "start": [12, 20], "end": [1, 10], "tint": Color(0.9, 0.95, 1.0), "snow": true,
		"item": "gift_mandarin", "hat": "pompom_hat",
		"title_ru": "Мандариновый Новый год", "title_en": "Mandarin New Year",
		"item_ru": "Мандарин в фольге", "item_en": "Foil-Wrapped Mandarin",
		"intro_ru": "Снова идёт снег, но совсем не холодный. Дух Зимы стоит у края долины и мнётся: «Можно мне прийти на праздник? Я ведь… зима».\n\nКапи уже двигается, освобождая место.",
		"intro_en": "It's snowing again, but it isn't cold at all. The Winter Spirit hovers at the edge of the valley: \"Can I come to the party? I mean... I'm winter.\"\n\nCapy is already scooting over to make room.",
		"outro_ru": "Под ёлкой у источника хватило подарков на всех. Даже на Духа Зимы — ему подарили шарф. Он совершенно не знает, зачем шарф Духу Зимы, но носит его не снимая.",
		"outro_en": "There were enough presents under the tree by the spring for everyone. Even the Winter Spirit got one: a scarf. He has no idea why a Winter Spirit needs a scarf, but he never takes it off."},
	{"id": "hanami", "start": [3, 20], "end": [4, 10], "tint": Color(1.0, 0.92, 0.96), "snow": false,
		"item": "sakura_petal", "hat": "sakura_wreath",
		"title_ru": "Ханами у источника", "title_en": "Hanami by the Spring",
		"item_ru": "Лепесток сакуры", "item_en": "Cherry Petal",
		"intro_ru": "Над источником расцвела сакура. Лепестки падают прямо в воду и плывут, как маленькие лодочки.\n\nСнежная макака объявляет: ханами — это когда смотришь на цветы и ничего не делаешь. Капи давно готова.",
		"intro_en": "A cherry tree has bloomed over the spring. Petals drift down into the water and float like tiny boats.\n\nThe snow monkey announces: hanami means looking at flowers and doing nothing. Capy has been ready for years.",
		"outro_ru": "Лепестки облетели, но все успели на них насмотреться. Лягушка утверждает, что одна сакура ей подмигнула. Никто не спорит.",
		"outro_en": "The petals have fallen, but everyone got to enjoy them. Frog insists one of the blossoms winked at her. Nobody argues."},
	{"id": "lanterns", "start": [10, 25], "end": [11, 7], "tint": Color(1.0, 0.88, 0.75), "snow": false,
		"item": "pumpkin_lantern", "hat": "leaf_cap",
		"title_ru": "Ночь тыквенных фонариков", "title_en": "Pumpkin Lantern Night",
		"item_ru": "Тыквенный фонарик", "item_en": "Pumpkin Lantern",
		"intro_ru": "В долине самая длинная и тёплая ночь осени. Над водой плывут тыквенные фонарики, а панда завернулась в плед и говорит, что она привидение.\n\nСова обещает рассказать очень страшную историю.",
		"intro_en": "It's the longest, coziest night of autumn in the valley. Pumpkin lanterns float over the water, and Panda has wrapped herself in a blanket and claims to be a ghost.\n\nOwl promises to tell a very scary story.",
		"outro_ru": "Страшная история оказалась про носок, который потерялся и нашёлся. Все очень испугались, а потом очень обрадовались. Фонарики догорели, и долина уснула.",
		"outro_en": "The scary story turned out to be about a sock that got lost and then found. Everyone was very frightened, then very relieved. The lanterns burned down, and the valley fell asleep."},
]



static func text(key: String, lang: String) -> String:
	if STRINGS.has(key):
		var entry: Dictionary = STRINGS[key]
		if entry.has(lang):
			return entry[lang]
		return entry["en"]
	return key


static func build_upgrades() -> Array:
	var list: Array = []
	# Улучшения друзей: x2 (или x1.5 у промежуточных уровней)
	for i in HELPERS.size():
		var h: Dictionary = HELPERS[i]
		for t in TIER_REQ.size():
			list.append({
				"id": "h%d_%d" % [i, t], "type": "helper", "target": i,
				"req": TIER_REQ[t], "cost": float(h["cost"]) * float(TIER_COST[t]), "mult": float(TIER_MULT[t]),
				"ru": TIER_RU[t], "en": TIER_EN[t], "icon": h["icon"],
			})
	# Нажатия
	list.append({"id": "tap_0", "type": "tap", "cost": 100.0, "mult": 2.0, "ru": "Мягкая лапка", "en": "Soft Paw", "icon": "paw"})
	list.append({"id": "tap_1", "type": "tap", "cost": 500.0, "mult": 2.0, "ru": "Тёплая лапка", "en": "Warm Paw", "icon": "paw"})
	list.append({"id": "tap_2", "type": "tap", "cost": 10000.0, "mult": 2.0, "ru": "Уверенная лапка", "en": "Steady Paw", "icon": "paw"})
	list.append({"id": "tap_3", "type": "tap", "cost": 1000000.0, "mult": 2.0, "ru": "Пушистая лапка", "en": "Fluffy Paw", "icon": "paw"})
	list.append({"id": "tap_4", "type": "tap", "cost": 100000000.0, "mult": 2.0, "ru": "Сияющая лапка", "en": "Glowing Paw", "icon": "paw"})
	list.append({"id": "tap_5", "type": "tap", "cost": 10000000000.0, "mult": 2.0, "ru": "Лапка-облачко", "en": "Cloud Paw", "icon": "paw"})
	var tz: Array = [[50000.0, 0.01, "Дзен-касание", "Zen Touch"], [5000000.0, 0.02, "Глубокое касание", "Deep Touch"],
		[500000000.0, 0.04, "Касание мудреца", "Sage Touch"], [50000000000.0, 0.08, "Касание вечности", "Eternal Touch"],
		[5.0e14, 0.1, "Касание весны", "Spring Touch"], [5.0e18, 0.15, "Касание звёзд", "Starlight Touch"]]
	for k in tz.size():
		list.append({"id": "tz_%d" % k, "type": "tapzps", "cost": tz[k][0], "value": tz[k][1], "ru": tz[k][2], "en": tz[k][3], "icon": "paw"})
	# Мандарины
	list.append({"id": "g_often", "type": "golden_often", "cost": 777777.0, "ru": "Мандариновое дерево", "en": "Mandarin Tree", "icon": "mandarin"})
	list.append({"id": "g_long", "type": "golden_long", "cost": 77777777.0, "ru": "Долгий аромат", "en": "Lasting Scent", "icon": "mandarin"})
	# Общие: все друзья x1.5
	for k in ALL_UPGRADES.size():
		list.append({"id": "all_%d" % k, "type": "all", "cost": ALL_UPGRADES[k][0], "mult": ALL_MULT,
			"ru": ALL_UPGRADES[k][1], "en": ALL_UPGRADES[k][2], "icon": "capy"})
	return list


const SUFFIXES: Array = ["", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"]


## Форматирование чисел. Округление всегда ВНИЗ: на экране не может быть
## больше, чем есть на самом деле (иначе «1.00M» на счёте и неактивная кнопка за 1.00M).
## Экспонента считается с поправкой: log(1e6)/log(10) = 5.999…, из-за этого
## раньше 1 000 000 показывалось как «1000K», 1e9 как «1000M» и т.д.
static func fmt(n: float) -> String:
	if is_nan(n):
		return "0"
	if is_inf(n):
		return "-∞" if n < 0.0 else "∞"
	if n < 0.0:
		return "-" + fmt(-n)
	if n < 10.0 and n != floor(n):
		return "%.1f" % (floor(n * 10.0) / 10.0)
	if n < 1000.0:
		return str(int(floor(n)))
	var e10: int = int(floor(log(n) / log(10.0)))
	if pow(10.0, e10 + 1) <= n:
		e10 += 1
	elif pow(10.0, e10) > n:
		e10 -= 1
	var e3: int = floori(e10 / 3.0)
	var v: float = n / pow(1000.0, e3)
	if v >= 1000.0:  # последняя страховка от ошибок округления pow/деления
		e3 += 1
		v /= 1000.0
	if e3 < SUFFIXES.size():
		if v >= 100.0:
			return "%d%s" % [int(floor(v)), SUFFIXES[e3]]
		if v >= 10.0:
			return "%.1f%s" % [floor(v * 10.0) / 10.0, SUFFIXES[e3]]
		return "%.2f%s" % [floor(v * 100.0) / 100.0, SUFFIXES[e3]]
	var m: float = n / pow(10.0, e10)
	if m >= 10.0:
		m /= 10.0
		e10 += 1
	return "%.2fe%d" % [floor(m * 100.0) / 100.0, e10]
