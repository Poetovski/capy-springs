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
	# --- Книга третья «Лето и Осень» (новых друзей — только в конец: сейвы хранят индексы) ---
	{"icon": "redpanda", "cost": 1.9e21, "zps": 1.4e13, "chapter_req": 16,
		"ru": "Малая панда", "en": "Red Panda",
		"line_ru": "Жарко... Можно я посижу в тени твоего мандарина?",
		"line_en": "So hot... Can I sit in the shade of your mandarin?"},
	{"icon": "otter", "cost": 2.7e22, "zps": 8.3e13, "chapter_req": 17,
		"ru": "Выдра", "en": "Otter",
		"line_ru": "Я нашла свой камешек! Давай теперь держаться вместе, чтобы не потеряться.",
		"line_en": "I found my pebble! Let's stick together now, so neither of us gets lost."},
	{"icon": "koi", "cost": 3.8e23, "zps": 4.9e14, "chapter_req": 18,
		"ru": "Карп кои", "en": "Koi",
		"line_ru": "Буль. Я помню каждое лето. Это — самое тёплое.",
		"line_en": "Blub. I remember every summer. This one's the warmest."},
	{"icon": "crane", "cost": 5.4e24, "zps": 2.9e15, "chapter_req": 19,
		"ru": "Журавль", "en": "Crane",
		"line_ru": "Я всегда возвращаюсь. Сюда — особенно.",
		"line_en": "I always come back. Especially here."},
	{"icon": "turtle", "cost": 7.6e25, "zps": 1.7e16, "chapter_req": 20,
		"ru": "Черепаха", "en": "Turtle",
		"line_ru": "Я. Шла. Сюда. Двести. Лет. Оно. Того. Стоило.",
		"line_en": "I. Walked. Here. For. Two. Hundred. Years. Worth. It."},
	{"icon": "fox", "cost": 1.07e27, "zps": 1.0e17, "chapter_req": 21,
		"ru": "Лиса", "en": "Fox",
		"line_ru": "Осень стесняется, поэтому пришла я. Он скоро тоже подойдёт.",
		"line_en": "Autumn is shy, so I came first. He'll join us soon."},
]

## Сюжетные тексты лежат в data/story.gd; здесь — короткие имена, чтобы код писал D.CHAPTERS.
const Story = preload("res://scripts/data/story.gd")
const CHAPTERS: Array = Story.CHAPTERS
const FRIEND_LINES: Dictionary = Story.FRIEND_LINES
const CAPY_THOUGHTS: Array = Story.CAPY_THOUGHTS
const CAPY_THOUGHTS_BOOK2: Array = Story.CAPY_THOUGHTS_BOOK2
const CAPY_THOUGHTS_FRIENDS: Array = Story.CAPY_THOUGHTS_FRIENDS
const CAPY_THOUGHTS_MEME: Array = Story.CAPY_THOUGHTS_MEME
const EVENTS: Array = Story.EVENTS

## Индексы первых глав второй и третьей книги (разделители во вкладке «История»).
const BOOK2_FIRST_CHAPTER: int = 8
const BOOK3_FIRST_CHAPTER: int = 16

## Лимит друзей одного вида: источник не резиновый. С каждой главой места
## становится больше, так что сначала нельзя бесконечно копить цыплят,
## а позже лимит перестаёт мешать.
const CAP_BASE: int = 50
const CAP_PER_CHAPTER: int = 25
const CAP_MAX: int = 400


static func friend_cap(chapter: int) -> int:
	return mini(CAP_MAX, CAP_BASE + CAP_PER_CHAPTER * maxi(0, chapter))

const NAP_CHAPTER: int = 4
## Великий Сон: мандарины = корень NAP_ROOT-й степени из (всего дзена / NAP_DIVISOR),
## каждый даёт +MANDARIN_BONUS. Корень 4-й степени (а не 3-й): мандарины копятся медленнее.
const NAP_DIVISOR: float = 1.0e6
const NAP_ROOT: float = 4.0
const MANDARIN_BONUS: float = 0.05

## Уровни улучшений друзей. Новые уровни ДОПИСЫВАТЬ В КОНЕЦ: id улучшения = h<друг>_<индекс>,
## и сейвы хранят эти id. Уровни 8–11 (5/15/35/75 шт.) — промежуточные x1.2, чтобы улучшения
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
	[1.0e29, "Солнечные зайчики", "Sunbeams"],
	[1.0e30, "Светлячковые фонари", "Firefly Lanterns"],
	[1.0e31, "Кленовые пледы", "Maple Blankets"],
	[1.0e32, "Колесо времён года", "Wheel of Seasons"],
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
	{"id": "kind_18", "stat": "kinds", "goal": 18, "ru": "Друг каждому", "en": "Friend to All", "d_ru": "Познакомиться с 18 видами зверей", "d_en": "Meet 18 kinds of animals"},
	{"id": "kind_24", "stat": "kinds", "goal": 24, "ru": "Весь лес в гостях", "en": "The Whole Forest Came", "d_ru": "Познакомиться со всеми 24 зверями", "d_en": "Meet all 24 animals"},
	{"id": "fr_3000", "stat": "friends", "goal": 3000, "ru": "Аншлаг", "en": "Full House", "d_ru": "Позвать 3 000 друзей", "d_en": "Invite 3,000 friends"},
	{"id": "tap_100k", "stat": "taps", "goal": 100000, "ru": "Лапка-легенда", "en": "Legendary Paw", "d_ru": "Нажать на Капи 100 000 раз", "d_en": "Tap Capy 100,000 times"},
	{"id": "zen_1e20", "stat": "total", "goal": 1.0e20, "ru": "Тёплое море", "en": "A Warm Sea", "d_ru": "Накопить всего 100Qi дзена", "d_en": "Gather 100Qi zen in total"},
	{"id": "zen_1e30", "stat": "total", "goal": 1.0e30, "ru": "Бескрайнее лето", "en": "Endless Summer", "d_ru": "Накопить всего 1No дзена", "d_en": "Gather 1No zen in total"},
	{"id": "ch_20", "stat": "chapter", "goal": 20, "ru": "Первый закат", "en": "The First Sunset", "d_ru": "Дойти до главы 20", "d_en": "Reach chapter 20"},
	{"id": "ch_24", "stat": "chapter", "goal": 24, "ru": "Все четыре сезона", "en": "All Four Seasons", "d_ru": "Дойти до главы 24", "d_en": "Reach chapter 24"},
	{"id": "nap_50", "stat": "naps", "goal": 50, "ru": "Хранитель снов", "en": "Keeper of Dreams", "d_ru": "Уснуть Великим Сном 50 раз", "d_en": "Take 50 Great Naps"},
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
	"story_end": {"ru": "Все три книги прочитаны! Четвёртая уже пишется, а дзен можно копить бесконечно.", "en": "You've read all three books! Book four is on its way, and zen is endless."},
	"book3_title": {"ru": "Книга третья · Лето и Осень", "en": "Book Three · Summer and Autumn"},
	"locked_hint_book3": {"ru": "Кто-то прячется от солнца в тени...", "en": "Someone is hiding from the sun in the shade..."},
	"owned_cap": {"ru": "x%d из %d · %s/с", "en": "x%d of %d · %s/s"},
	"cap_full": {"ru": "Мест нет", "en": "No room"},
	"cap_hint": {"ru": "В источнике больше нет места. В следующей главе станет просторнее.", "en": "No more room in the spring. It gets roomier in the next chapter."},
	# --- Онлайн-топ ---
	"top_title": {"ru": "Топ по нажатиям", "en": "Top Tappers"},
	"top_disabled": {"ru": "Онлайн-топ пока недоступен.", "en": "The online leaderboard isn't available yet."},
	"top_loading": {"ru": "Загружаю...", "en": "Loading..."},
	"top_empty": {"ru": "Пока здесь пусто. Стань первым!", "en": "Nobody here yet. Be the first!"},
	"top_need_login": {"ru": "Войди, чтобы попасть в топ. Нужна почта: на неё придёт код, так в топ не пролезут боты.", "en": "Sign in to join the leaderboard. You'll need an email: we send a code to it, which keeps bots out."},
	"top_you": {"ru": "Ты: %s · %s нажатий", "en": "You: %s · %s taps"},
	"top_login": {"ru": "Войти", "en": "Sign in"},
	"top_register": {"ru": "Регистрация", "en": "Sign up"},
	"top_logout": {"ru": "Выйти", "en": "Sign out"},
	"top_back": {"ru": "Назад", "en": "Back"},
	"top_nick": {"ru": "Ник (его увидят в топе)", "en": "Nickname (shown on the leaderboard)"},
	"top_email": {"ru": "Почта", "en": "Email"},
	"top_password": {"ru": "Пароль (от 8 символов)", "en": "Password (8+ characters)"},
	"top_code_sent": {"ru": "Мы отправили код на твою почту. Введи его:", "en": "We sent a code to your email. Enter it here:"},
	"top_code": {"ru": "Код из письма", "en": "Code from the email"},
	"top_send": {"ru": "Подтвердить", "en": "Confirm"},
	"top_welcome": {"ru": "Готово! Ты в топе, %s", "en": "Done! You're on the board, %s"},
	"err_no_network": {"ru": "Нет связи с сервером. Проверь интернет.", "en": "Can't reach the server. Check your connection."},
	"err_INVALID_CREDENTIALS": {"ru": "Неверный ник или пароль.", "en": "Wrong nickname or password."},
	"err_IDENTIFIER_TAKEN": {"ru": "Такой ник уже занят.", "en": "That nickname is taken."},
	"err_EMAIL_TAKEN": {"ru": "Эта почта уже используется.", "en": "That email is already in use."},
	"err_INVALID_EMAIL": {"ru": "Проверь адрес почты.", "en": "Please check the email address."},
	"err_VERIFICATION_CODE_INVALID": {"ru": "Код не подходит. Проверь письмо.", "en": "That code doesn't match. Check the email."},
	"err_IDENTIFIER_PROFANITY": {"ru": "Выбери другой ник, пожалуйста.", "en": "Please pick a different nickname."},
	"err_form": {"ru": "Проверь поля. Ник: 3–20 букв или цифр (можно _ - .), без @. Пароль: от 8 символов и не такой, как ник.", "en": "Check the fields. Nickname: 3–20 letters or digits (_ - . allowed), no @. Password: 8+ characters, different from the nickname."},
	"err_too_many": {"ru": "Слишком много попыток. Подожди %d с.", "en": "Too many attempts. Wait %d s."},
	"top_pass_hint": {"ru": "Придумай новый пароль. Не используй пароль от почты или других сайтов.", "en": "Pick a new password. Don't reuse the one from your email or other sites."},
	"err_other": {"ru": "Что-то пошло не так. Попробуй ещё раз.", "en": "Something went wrong. Please try again."},
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


static func text(key: String, lang: String) -> String:
	if STRINGS.has(key):
		var entry: Dictionary = STRINGS[key]
		if entry.has(lang):
			return entry[lang]
		return entry["en"]
	return key


static func build_upgrades() -> Array:
	var list: Array = []
	# Улучшения друзей: x2 (или x1.2 у промежуточных уровней)
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
	# Общие: все друзья x1.2
	for k in ALL_UPGRADES.size():
		list.append({"id": "all_%d" % k, "type": "all", "cost": ALL_UPGRADES[k][0], "mult": ALL_MULT,
			"ru": ALL_UPGRADES[k][1], "en": ALL_UPGRADES[k][2], "icon": "capy"})
	return list


const SUFFIXES: Array = ["", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc", "Ud", "Dd", "Td", "Qad"]


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
