extends Node
## Состояние игры, экономика и сохранения. Автозагрузка под именем Game.

signal chapter_unlocked(index: int)
signal friend_joined(index: int)
signal offline_earned(amount: float)
signal achievement_ready(id: String)

const D = preload("res://scripts/data.gd")
const SAVE_PATH: String = "user://capy_save.json"
const SAVE_TMP: String = "user://capy_save.json.tmp"
const SAVE_BAK: String = "user://capy_save.json.bak"
const SAVE_VERSION: int = 2
## Офлайн копится в 5 раз медленнее, чем в игре: пока играешь — быстро,
## а сутки вне игры не дают абсурдных сумм.
const OFFLINE_RATE: float = 0.2
const OFFLINE_CAP: float = 8.0 * 3600.0
const OFFLINE_MIN: float = 60.0
## Больше этого шаг кадра не бывает: после сворачивания на Android первый delta
## может равняться всему времени в фоне (= 100% дохода без лимита 8 ч).
const MAX_DELTA: float = 0.5
const SAVE_INTERVAL: float = 10.0

var zen: float = 0.0
var run_total: float = 0.0
var all_total: float = 0.0
var taps: int = 0
var owned: Array = []
var upgrades: Dictionary = {}
var chapter: int = 0
var mandarins: int = 0
var naps: int = 0
var lang: String = "ru"
var friends_met: Dictionary = {}
var golden_caught: int = 0
var upgrades_bought: int = 0
var ach_claimed: Dictionary = {}
var music_vol: float = 0.6
var sfx_vol: float = 0.8

var frenzy_time: float = 0.0
var tap_frenzy_time: float = 0.0
var pending_offline: float = 0.0

var upgrade_list: Array = []
var helper_mult: Array = []
var tap_mult: float = 1.0
var tap_zps: float = 0.0
var golden_often: bool = false
var golden_long: bool = false
var all_mult: float = 1.0
var base_zps: float = 0.0
var _ach_timer: float = 0.0
var _ach_ready_seen: Dictionary = {}

var _save_timer: float = 0.0
## Максимальное время по часам устройства, которое мы видели. Не даёт
## накрутить офлайн-доход переводом часов назад-вперёд.
var last_seen_time: float = 0.0
var _paused: bool = false


func _ready() -> void:
	var loc: String = OS.get_locale_language()
	lang = "ru" if loc in ["ru", "uk", "be", "kk"] else "en"
	upgrade_list = D.build_upgrades()
	_reset_run()
	load_game()
	recalc()
	_check_chapter(false)


func txt(key: String) -> String:
	return D.text(key, lang)


func _reset_run() -> void:
	zen = 0.0
	run_total = 0.0
	owned = []
	for i in D.HELPERS.size():
		owned.append(0)
	upgrades = {}
	frenzy_time = 0.0
	tap_frenzy_time = 0.0


func _process(delta: float) -> void:
	delta = minf(delta, MAX_DELTA)
	if frenzy_time > 0.0:
		frenzy_time = maxf(0.0, frenzy_time - delta)
	if tap_frenzy_time > 0.0:
		tap_frenzy_time = maxf(0.0, tap_frenzy_time - delta)
	var z: float = zps()
	if z > 0.0:
		earn(z * delta)
	_ach_timer += delta
	if _ach_timer >= 1.0:
		_ach_timer = 0.0
		_check_achievements()
	_save_timer += delta
	if _save_timer >= SAVE_INTERVAL:
		_save_timer = 0.0
		save_game()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_PAUSED:
			# Android/iOS: приложение ушло в фон, _process дальше не идёт.
			save_game()
			_paused = true
		NOTIFICATION_APPLICATION_RESUMED:
			# Без этого игрок, вернувшийся из фона (а не после убийства процесса),
			# не получал офлайн-доход вообще.
			if _paused:
				_paused = false
				var gain: float = _offline_gain()
				_touch_time()
				if gain >= 1.0:
					pending_offline += gain
					offline_earned.emit(pending_offline)
		NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_EXIT_TREE:
			save_game()


func _now() -> float:
	return Time.get_unix_time_from_system()


func _touch_time() -> void:
	last_seen_time = maxf(last_seen_time, _now())


## Офлайн-доход с момента last_seen_time. Часы, переведённые назад, дают 0,
## а last_seen_time никогда не уменьшается: «назад, сохранить, вперёд» не работает.
func _offline_gain() -> float:
	if last_seen_time <= 0.0:
		return 0.0
	var away: float = _now() - last_seen_time
	if away < OFFLINE_MIN or not is_finite(away):
		return 0.0
	return base_zps * prestige_mult() * minf(away, OFFLINE_CAP) * OFFLINE_RATE


## Забрать накопленный офлайн-доход (вызывает UI, показывая окно).
func claim_offline() -> float:
	var g: float = pending_offline
	pending_offline = 0.0
	if g > 0.0:
		earn(g)
	return g


# ---------- экономика ----------

func recalc() -> void:
	helper_mult = []
	for i in D.HELPERS.size():
		helper_mult.append(1.0)
	tap_mult = 1.0
	tap_zps = 0.0
	golden_often = false
	golden_long = false
	all_mult = 1.0
	for u in upgrade_list:
		if not upgrades.has(u["id"]):
			continue
		match u["type"]:
			"helper":
				helper_mult[u["target"]] *= float(u["mult"])
			"tap":
				tap_mult *= float(u["mult"])
			"tapzps":
				tap_zps += float(u["value"])
			"golden_often":
				golden_often = true
			"golden_long":
				golden_long = true
			"all":
				all_mult *= float(u["mult"])
	base_zps = 0.0
	for i in D.HELPERS.size():
		base_zps += helper_zps_each(i) * float(owned[i])


func helper_zps_each(i: int) -> float:
	return float(D.HELPERS[i]["zps"]) * float(helper_mult[i]) * all_mult * D.ZPS_BOOST


## Постоянный множитель: мандарины (+5% каждый) и достижения (+2% каждое).
func prestige_mult() -> float:
	return (1.0 + D.MANDARIN_BONUS * float(mandarins)) * achievement_mult()


## Бонус мандаринов в процентах (для подписей в интерфейсе).
func mandarin_pct() -> int:
	return int(round(float(mandarins) * D.MANDARIN_BONUS * 100.0))


func achievement_mult() -> float:
	return 1.0 + D.ACH_BONUS * float(ach_claimed.size())


func frenzy_mult() -> float:
	return 7.0 if frenzy_time > 0.0 else 1.0


func zps() -> float:
	return base_zps * prestige_mult() * frenzy_mult()


func tap_value() -> float:
	var v: float = tap_mult * prestige_mult() + zps() * tap_zps
	if tap_frenzy_time > 0.0:
		v *= 77.0
	return v


func earn(amount: float) -> void:
	zen += amount
	run_total += amount
	all_total += amount
	_check_chapter(true)


func tap() -> float:
	var v: float = tap_value()
	taps += 1
	earn(v)
	return v


func _check_chapter(notify: bool) -> void:
	while chapter + 1 < D.CHAPTERS.size() and all_total >= float(D.CHAPTERS[chapter + 1]["at"]):
		chapter += 1
		if notify:
			chapter_unlocked.emit(chapter)


func helper_cost(i: int, n: int) -> float:
	var base: float = float(D.HELPERS[i]["cost"]) * pow(D.COST_GROWTH, float(owned[i]))
	return base * (pow(D.COST_GROWTH, float(n)) - 1.0) / (D.COST_GROWTH - 1.0)


func helper_max_affordable(i: int) -> int:
	var base: float = float(D.HELPERS[i]["cost"]) * pow(D.COST_GROWTH, float(owned[i]))
	if zen < base:
		return 0
	var n: int = int(floor(log(zen * (D.COST_GROWTH - 1.0) / base + 1.0) / log(D.COST_GROWTH)))
	n = mini(n, helper_room(i))
	while n > 0 and helper_cost(i, n) > zen:
		n -= 1
	return n


## Сколько друзей одного вида помещается в источник сейчас (растёт с главами).
func helper_cap() -> int:
	return D.friend_cap(chapter)


## Сколько ещё можно позвать этого друга (0 — мест нет).
func helper_room(i: int) -> int:
	return maxi(0, helper_cap() - int(owned[i]))


func buy_helper(i: int, n: int) -> bool:
	if n <= 0 or not helper_revealed(i) or n > helper_room(i):
		return false
	var cost: float = helper_cost(i, n)
	if zen < cost:
		return false
	zen -= cost
	owned[i] = int(owned[i]) + n
	recalc()
	var key: String = str(i)
	if not friends_met.has(key):
		friends_met[key] = true
		friend_joined.emit(i)
	return true


func helper_revealed(i: int) -> bool:
	if i == 0 or int(owned[i]) > 0 or friends_met.has(str(i)):
		return true
	# Друзья второй книги приходят не раньше своей главы
	if chapter < int(D.HELPERS[i].get("chapter_req", 0)):
		return false
	return int(owned[i - 1]) > 0 and all_total >= float(D.HELPERS[i]["cost"]) * 0.3


func upgrade_visible(u: Dictionary) -> bool:
	if upgrades.has(u["id"]):
		return false
	if u["type"] == "helper":
		return int(owned[u["target"]]) >= int(u["req"])
	return run_total >= float(u["cost"]) * 0.15


func visible_upgrades() -> Array:
	var list: Array = []
	for u in upgrade_list:
		if upgrade_visible(u):
			list.append(u)
	list.sort_custom(func(a, b): return float(a["cost"]) < float(b["cost"]))
	return list


func buy_upgrade(u: Dictionary) -> bool:
	if upgrades.has(u["id"]) or zen < float(u["cost"]):
		return false
	zen -= float(u["cost"])
	upgrades[u["id"]] = true
	upgrades_bought += 1
	recalc()
	return true


func upgrade_name(u: Dictionary) -> String:
	var title: String = u[lang] if u.has(lang) else u["en"]
	if u["type"] == "helper":
		return "%s: %s" % [D.HELPERS[u["target"]][lang], title]
	return title


func upgrade_desc(u: Dictionary) -> String:
	match u["type"]:
		"helper":
			if float(u["mult"]) >= 2.0:
				return txt("up_helper") % D.HELPERS[u["target"]][lang]
			return txt("up_helper_pct") % [D.HELPERS[u["target"]][lang], int(round((float(u["mult"]) - 1.0) * 100.0))]
		"tap":
			return txt("up_tap")
		"tapzps":
			return txt("up_tapzps") % int(round(float(u["value"]) * 100.0))
		"golden_often":
			return txt("up_golden_often")
		"golden_long":
			return txt("up_golden_long")
		"all":
			return txt("up_all") % int(round((float(u["mult"]) - 1.0) * 100.0))
	return ""


# ---------- золотой мандарин ----------

func golden_interval() -> float:
	# Базово раз в 35–90 с (раньше 60–150), с «Мандариновым деревом» ещё на 30% чаще
	var t: float = randf_range(35.0, 90.0)
	return t * 0.7 if golden_often else t


## Возвращает текст награды
func golden_reward() -> String:
	var dur_mult: float = 2.0 if golden_long else 1.0
	golden_caught += 1
	var r: float = randf()
	if r < 0.5 and base_zps > 0.0:
		frenzy_time = 30.0 * dur_mult
		return txt("g_frenzy")
	elif r < 0.85 or base_zps <= 0.0:
		var gain: float = minf(zen * 0.15, zps() * 900.0) + 13.0 + tap_value() * 10.0
		earn(gain)
		return txt("g_lucky") % D.fmt(gain)
	tap_frenzy_time = 10.0 * dur_mult
	return txt("g_tap")


# ---------- Великий Сон (престиж) ----------

func nap_unlocked() -> bool:
	return chapter >= D.NAP_CHAPTER


func nap_gain() -> int:
	# Корень 4-й степени (v1.2): мандарины копятся медленнее, чем раньше с кубическим.
	# Пороги глав 9–24 подобраны симуляцией под эту формулу (tools/sched.gd).
	var potential: int = int(floor(pow(all_total / D.NAP_DIVISOR, 1.0 / D.NAP_ROOT)))
	return maxi(0, potential - mandarins)


func do_nap() -> void:
	var g: int = nap_gain()
	if not nap_unlocked() or g <= 0:
		return
	mandarins += g
	naps += 1
	_reset_run()
	recalc()
	save_game()


# ---------- сохранения ----------

## Атомарное сохранение: пишем во временный файл, проверяем, затем
## текущий файл становится .bak, а временный — основным. Если процесс убьют
## посреди записи, основной файл не пострадает. Раньше FileAccess.WRITE сразу
## обрезал файл, и падение/нехватка места = потеря всего прогресса.
func save_game() -> void:
	if not (is_finite(zen) and is_finite(run_total) and is_finite(all_total)):
		push_error("save_game: non-finite numbers, save skipped")
		return
	_touch_time()
	var data: Dictionary = {
		"v": SAVE_VERSION, "zen": zen, "run_total": run_total, "all_total": all_total,
		"taps": taps, "owned": owned, "upgrades": upgrades.keys(), "chapter": chapter,
		"mandarins": mandarins, "naps": naps, "lang": lang, "friends": friends_met.keys(),
		"time": _now(), "seen": last_seen_time,
		"golden": golden_caught, "ups": upgrades_bought, "ach": ach_claimed.keys(),
		"music": music_vol, "sfx": sfx_vol,
	}
	var text: String = JSON.stringify(data, "", false, true)
	var f: FileAccess = FileAccess.open(SAVE_TMP, FileAccess.WRITE)
	if f == null:
		push_error("save_game: cannot open tmp (%d)" % FileAccess.get_open_error())
		return
	f.store_string(text)
	f.flush()
	var err: Error = f.get_error()
	f.close()
	if err != OK:
		push_error("save_game: write failed (%d)" % err)
		return
	var dir: DirAccess = DirAccess.open("user://")
	if dir == null:
		return
	if dir.file_exists(SAVE_PATH.get_file()):
		if dir.file_exists(SAVE_BAK.get_file()):
			dir.remove(SAVE_BAK.get_file())
		dir.rename(SAVE_PATH.get_file(), SAVE_BAK.get_file())
	if dir.rename(SAVE_TMP.get_file(), SAVE_PATH.get_file()) != OK:
		push_error("save_game: rename failed")


func _read_save(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var f: FileAccess = FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("all_total"):
		return {}
	return parsed


## Миграции формата: сюда добавлять шаги при изменении структуры сохранения.
func _migrate(d: Dictionary) -> Dictionary:
	var v: int = int(_num(d.get("v", 1)))
	if v < 2:
		# v1 не хранил "seen": берём время последнего сохранения
		d["seen"] = d.get("time", 0.0)
		v = 2
	d["v"] = v
	return d


func _num(x, def: float = 0.0) -> float:
	if typeof(x) != TYPE_FLOAT and typeof(x) != TYPE_INT:
		return def
	var f: float = float(x)
	return f if is_finite(f) else def


func _arr(x) -> Array:
	return x if typeof(x) == TYPE_ARRAY else []


func load_game() -> void:
	var d: Dictionary = _read_save(SAVE_PATH)
	if d.is_empty():
		# основной файл повреждён или отсутствует — пробуем резервную копию
		d = _read_save(SAVE_BAK)
		if d.is_empty():
			return
		push_warning("load_game: main save broken, restored from backup")
	d = _migrate(d)
	zen = maxf(0.0, _num(d.get("zen")))
	run_total = maxf(zen, _num(d.get("run_total")))
	all_total = maxf(run_total, _num(d.get("all_total")))
	taps = int(maxf(0.0, _num(d.get("taps"))))
	mandarins = int(maxf(0.0, _num(d.get("mandarins"))))
	naps = int(maxf(0.0, _num(d.get("naps"))))
	var l: String = str(d.get("lang", lang))
	if l in ["ru", "en"]:
		lang = l
	var o: Array = _arr(d.get("owned"))
	for i in mini(o.size(), owned.size()):
		owned[i] = int(maxf(0.0, _num(o[i])))
	upgrades = {}
	for id in _arr(d.get("upgrades")):
		upgrades[str(id)] = true
	friends_met = {}
	for k in _arr(d.get("friends")):
		friends_met[str(k)] = true
	golden_caught = int(maxf(0.0, _num(d.get("golden"))))
	upgrades_bought = int(maxf(0.0, _num(d.get("ups"))))
	ach_claimed = {}
	for k in _arr(d.get("ach")):
		ach_claimed[str(k)] = true
	music_vol = clampf(_num(d.get("music"), music_vol), 0.0, 1.0)
	sfx_vol = clampf(_num(d.get("sfx"), sfx_vol), 0.0, 1.0)
	# Глава выводится из all_total: сохранённый индекс может не совпасть,
	# если список CHAPTERS в data.gd изменился (добавили/убрали главы).
	chapter = 0
	_check_chapter(false)
	recalc()
	last_seen_time = maxf(_num(d.get("seen")), _num(d.get("time")))
	pending_offline = _offline_gain()


func wipe() -> void:
	_reset_run()
	all_total = 0.0
	taps = 0
	chapter = 0
	mandarins = 0
	naps = 0
	friends_met = {}
	golden_caught = 0
	upgrades_bought = 0
	ach_claimed = {}
	_ach_ready_seen = {}
	pending_offline = 0.0
	recalc()
	save_game()


# ---------- достижения ----------

## Текущее значение счётчика, к которому привязано достижение.
func ach_value(a: Dictionary) -> float:
	match str(a["stat"]):
		"taps":
			return float(taps)
		"total":
			return all_total
		"friends":
			var s: int = 0
			for o in owned:
				s += int(o)
			return float(s)
		"kinds":
			return float(friends_met.size())
		"golden":
			return float(golden_caught)
		"chapter":
			return float(chapter + 1)
		"naps":
			return float(naps)
		"ups":
			return float(upgrades_bought)
	return 0.0


func ach_done(a: Dictionary) -> bool:
	return ach_value(a) >= float(a["goal"])


func ach_claimable_count() -> int:
	var n: int = 0
	for a in D.ACHIEVEMENTS:
		if not ach_claimed.has(a["id"]) and ach_done(a):
			n += 1
	return n


## Забрать награду: +2% ко всему дзену навсегда (не сгорает при Великом Сне).
func claim_achievement(id: String) -> bool:
	for a in D.ACHIEVEMENTS:
		if a["id"] == id and not ach_claimed.has(id) and ach_done(a):
			ach_claimed[id] = true
			recalc()
			save_game()
			return true
	return false


## Раз в секунду: сообщить интерфейсу о новых выполненных достижениях.
func _check_achievements() -> void:
	for a in D.ACHIEVEMENTS:
		var id: String = a["id"]
		if ach_claimed.has(id) or _ach_ready_seen.has(id):
			continue
		if ach_done(a):
			_ach_ready_seen[id] = true
			achievement_ready.emit(id)
