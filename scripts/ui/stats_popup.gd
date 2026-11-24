extends RefCounted
## Окно «Статистика»: общие счётчики и сколько дзена принёс каждый друг за всё время.
## Открывается из настроек и по нажатию на «Лучший приятель» в верхней панели.

const D = preload("res://scripts/data.gd")
const K = preload("res://scripts/ui/ui_kit.gd")

var popups: Control
var stage: Control


func _init(popups_node: Control, stage_node: Control) -> void:
	popups = popups_node
	stage = stage_node


func show_stats() -> void:
	# Из настроек: заменить их окно этим (без анимации и без очереди сообщений)
	var vb: VBoxContainer = popups.open_panel(popups.is_open())
	vb.custom_minimum_size = Vector2(minf(560.0, popups.size.x - 80.0), 0)
	vb.add_child(K.label(Game.txt("stats_title"), 30, K.C_BROWN, true))
	var general: String = Game.txt("stats") % [D.fmt(Game.all_total), Game.taps, Game.naps]
	general += "\n" + Game.txt("stats_more") % [Game.golden_caught, Game.upgrades_bought, Game.ach_claimed.size(), D.ACHIEVEMENTS.size()]
	vb.add_child(K.label(general, 18, K.C_BROWN_SOFT, true, true))
	vb.add_child(K.label(Game.txt("stats_friends"), 21, K.C_BROWN, true, true))

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, minf(520.0, popups.size.y * 0.42))
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vb.add_child(scroll)
	var list: VBoxContainer = K.vbox(6)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	var rows: Array = ranking()
	if rows.is_empty():
		list.add_child(K.label(Game.txt("stats_empty"), 18, K.C_BROWN_SOFT, true, true))
	var total: float = 0.0
	for r in rows:
		total += float(r[1])
	var best: int = Game.best_buddy()
	for r in rows:
		list.add_child(_row(int(r[0]), float(r[1]), total, int(r[0]) == best))
	vb.add_child(K.button(Game.txt("close"), K.C_GREEN, 24, Vector2(0, 60), popups.close))


## Друзья, которые хоть что-то принесли или есть сейчас, по убыванию вклада: [[индекс, дзен], ...].
static func ranking() -> Array:
	var rows: Array = []
	for i in D.HELPERS.size():
		var e: float = float(Game.friend_earned[i]) if i < Game.friend_earned.size() else 0.0
		if e > 0.0 or int(Game.owned[i]) > 0:
			rows.append([i, e])
	rows.sort_custom(func(a, b): return float(a[1]) > float(b[1]))
	return rows


func _row(i: int, earned: float, total: float, is_best: bool) -> PanelContainer:
	var h: Dictionary = D.HELPERS[i]
	var p: PanelContainer = PanelContainer.new()
	p.add_theme_stylebox_override("panel", K.sb(Color("ffe2b8") if is_best else K.C_ROW, 12, 8))
	var hb: HBoxContainer = K.hbox(10)
	p.add_child(hb)
	hb.add_child(K.icon(stage.friend_tex[h["icon"]], 48))
	var col: VBoxContainer = K.vbox(0)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(col)
	var nl: Label = K.label(str(h[Game.lang]), 20, K.C_BROWN)
	nl.clip_text = true
	col.add_child(nl)
	col.add_child(K.label(Game.txt("stats_now") % D.fmt(Game.helper_income(i) * Game.prestige_mult()), 15, K.C_BROWN_SOFT))
	var right: VBoxContainer = K.vbox(0)
	hb.add_child(right)
	right.add_child(K.label(D.fmt(earned), 20, K.C_MANDARIN, true))
	var pct: int = int(round(earned / total * 100.0)) if total > 0.0 else 0
	right.add_child(K.label("%d%%" % pct, 15, K.C_BROWN_SOFT, true))
	return p
