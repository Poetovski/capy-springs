extends Control
## Главный экран. Собирает интерфейс из модулей в scripts/ui и связывает их с Game:
##   backdrop    — окружение главы (небо, горы, деревья, погода)
##   capy_stage  — Капи, друзья в источнике, мысли, золотой мандарин
##   tabs/*      — вкладки нижнего списка
##   popups      — сюжетные окна и настройки
##   audio       — музыка и звуки

const D = preload("res://scripts/data.gd")
const K = preload("res://scripts/ui/ui_kit.gd")
const Backdrop = preload("res://scripts/ui/backdrop.gd")
const CapyStage = preload("res://scripts/ui/capy_stage.gd")
const Popups = preload("res://scripts/ui/popups.gd")
const Audio = preload("res://scripts/ui/audio.gd")
const Online = preload("res://scripts/net/talo_client.gd")
const LeaderboardPopup = preload("res://scripts/ui/leaderboard_popup.gd")
const TABS: Array = [
	["tab_friends", preload("res://scripts/ui/tabs/friends_tab.gd")],
	["tab_upgrades", preload("res://scripts/ui/tabs/upgrades_tab.gd")],
	["tab_story", preload("res://scripts/ui/tabs/story_tab.gd")],
	["tab_awards", preload("res://scripts/ui/tabs/awards_tab.gd")],
	["tab_more", preload("res://scripts/ui/tabs/nap_tab.gd")],
]
const TAB_STORY: int = 2
const TAB_AWARDS: int = 3
const TAB_NAP: int = 4

const MAX_TAPS_PER_SEC: int = 20      # защита от автокликеров / 10 пальцев
const FPS_ACTIVE: int = 60            # 90/120 Гц экраны иначе жгут батарею
const FPS_IDLE: int = 30
const IDLE_AFTER: float = 20.0        # с без касаний -> снижаем FPS
const TOUCH_MOUSE_GAP_MS: int = 500   # клик мыши сразу после касания = эмуляция касания

var backdrop: Control
var stage: Control
var popups: Control
var audio: Node
var online: Node                 # онлайн-топ (Talo)
var leaderboard: RefCounted
var top_btn: TextureButton
var margin: MarginContainer
var top_panel: PanelContainer
var place_label: Label
var zen_label: Label
var zps_label: Label
var mandarin_label: Label
var chapter_bar: ProgressBar
var chapter_bar_label: Label
var gear_btn: TextureButton
var tab_buttons: Array = []
var tabs: Array = []
var scroll: ScrollContainer
var list_box: VBoxContainer
var toast_label: Label

var current_tab: int = 0
var last_claimable: int = -1
var idle_time: float = 0.0
var label_timer: float = 0.0
var refresh_timer: float = 0.0
var tap_stamps: Array[int] = []
var last_touch_ms: int = -100000
var _toast_tween: Tween


func _ready() -> void:
	_setup_theme()
	# Android: «Назад» обрабатываем сами (закрыть окно / первая вкладка / выход с сохранением)
	get_tree().quit_on_go_back = false
	Engine.max_fps = FPS_ACTIVE
	audio = Audio.new()
	add_child(audio)
	online = Online.new()
	add_child(online)
	_build_ui()
	Game.chapter_unlocked.connect(_on_chapter_unlocked)
	Game.friend_joined.connect(_on_friend_joined)
	Game.offline_earned.connect(_on_offline_earned)
	Game.achievement_ready.connect(_on_achievement_ready)
	stage.sync_friends()
	_apply_chapter(false)
	set_tab(0)
	if Game.all_total <= 0.0:
		_show_chapter_popup(0)
	if Game.pending_offline >= 1.0:
		_on_offline_earned(Game.pending_offline)
	resized.connect(_layout)
	_layout()


func _setup_theme() -> void:
	var th: Theme = Theme.new()
	th.default_font_size = 22
	# Шрифт Nunito (OFL, есть кириллица): вариативный, берём насыщенность 700
	var font_file: Font = load("res://assets/fonts/Nunito-Variable.ttf")
	if font_file:
		var fv: FontVariation = FontVariation.new()
		fv.base_font = font_file
		var ts: TextServer = TextServerManager.get_primary_interface()
		fv.variation_opentype = {ts.name_to_tag("wght"): 700}
		th.default_font = fv
	theme = th


# ---------- построение ----------

func _build_ui() -> void:
	backdrop = Backdrop.new()
	add_child(backdrop)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	margin = MarginContainer.new()
	add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var root: VBoxContainer = K.vbox(10)
	margin.add_child(root)

	root.add_child(_build_top_panel())

	stage = CapyStage.new()
	stage.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stage.size_flags_stretch_ratio = 1.15
	root.add_child(stage)
	stage.resized.connect(_layout)
	stage.golden_pressed.connect(_on_golden)

	var tab_row: HBoxContainer = K.hbox(6)
	root.add_child(tab_row)
	for i in TABS.size():
		var b: Button = K.button("", K.C_TAB, 18, Vector2(0, 58), set_tab.bind(i))
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.clip_text = true
		tab_row.add_child(b)
		tab_buttons.append(b)

	var lp: PanelContainer = PanelContainer.new()
	lp.add_theme_stylebox_override("panel", K.sb(K.C_PANEL, 22, 10))
	lp.size_flags_vertical = Control.SIZE_EXPAND_FILL
	lp.size_flags_stretch_ratio = 1.0
	root.add_child(lp)
	scroll = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	lp.add_child(scroll)
	list_box = K.vbox(8)
	list_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list_box)
	for t in TABS:
		tabs.append(t[1].new(self, list_box))

	toast_label = K.outlined("", 26)
	toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	toast_label.modulate.a = 0.0
	add_child(toast_label)

	# Кнопка настроек в правом верхнем углу верхней панели
	gear_btn = TextureButton.new()
	gear_btn.texture_normal = K.tex("gear")
	gear_btn.ignore_texture_size = true
	gear_btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	gear_btn.size = Vector2(52, 52)
	gear_btn.modulate = Color(1, 1, 1, 0.85)
	add_child(gear_btn)

	popups = Popups.new()
	popups.audio = audio
	add_child(popups)
	popups.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	popups.lang_toggled.connect(_on_lang_toggled)
	popups.reset_confirmed.connect(_on_reset)
	gear_btn.pressed.connect(popups.show_settings)
	# Кнопка онлайн-топа в левом верхнем углу верхней панели
	leaderboard = LeaderboardPopup.new(popups, online)
	top_btn = TextureButton.new()
	top_btn.texture_normal = K.tex("trophy")
	top_btn.ignore_texture_size = true
	top_btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	top_btn.size = Vector2(52, 52)
	top_btn.modulate = Color(1, 1, 1, 0.9)
	top_btn.pressed.connect(_on_top_pressed)
	add_child(top_btn)
	move_child(popups, -1)
	update_tab_titles()


func _build_top_panel() -> PanelContainer:
	top_panel = PanelContainer.new()
	top_panel.add_theme_stylebox_override("panel", K.sb(K.C_PANEL, 22, 12))
	var tv: VBoxContainer = K.vbox(0)
	top_panel.add_child(tv)
	place_label = K.label("", 20, K.C_BROWN_SOFT, true)
	tv.add_child(place_label)
	zen_label = K.label("0", 54, K.C_BROWN, true)
	tv.add_child(zen_label)
	zps_label = K.label("", 21, K.C_BROWN_SOFT, true)
	tv.add_child(zps_label)
	mandarin_label = K.label("", 19, K.C_MANDARIN, true)
	tv.add_child(mandarin_label)
	# Прогресс до следующей главы
	var pb: VBoxContainer = K.vbox(2)
	tv.add_child(pb)
	chapter_bar = ProgressBar.new()
	chapter_bar.show_percentage = false
	chapter_bar.max_value = 1.0
	chapter_bar.custom_minimum_size = Vector2(0, 10)
	chapter_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chapter_bar.add_theme_stylebox_override("background", K.flat(Color(0.36, 0.23, 0.13, 0.15)))
	chapter_bar.add_theme_stylebox_override("fill", K.flat(K.C_GREEN))
	pb.add_child(chapter_bar)
	chapter_bar_label = K.label("", 15, K.C_BROWN_SOFT, true)
	pb.add_child(chapter_bar_label)
	return top_panel


## Отступы с учётом выреза камеры / закруглений / панели жестов (Android immersive).
func _apply_safe_area() -> void:
	var inset: Array = [0.0, 0.0, 0.0, 0.0]  # left, top, right, bottom (в единицах вьюпорта)
	if OS.has_feature("mobile"):
		var win: Vector2 = Vector2(DisplayServer.window_get_size())
		var safe: Rect2i = DisplayServer.get_display_safe_area()
		if win.x > 0.0 and safe.size.x > 0 and size.x > 0.0:
			var k: float = size.x / win.x  # canvas_items + expand: масштаб одинаковый по осям
			inset = [safe.position.x * k, safe.position.y * k,
				maxf(0.0, win.x - safe.end.x) * k, maxf(0.0, win.y - safe.end.y) * k]
	margin.add_theme_constant_override("margin_left", int(16.0 + inset[0]))
	margin.add_theme_constant_override("margin_top", int(maxf(28.0, inset[1] + 8.0)))
	margin.add_theme_constant_override("margin_right", int(16.0 + inset[2]))
	margin.add_theme_constant_override("margin_bottom", int(16.0 + inset[3]))


func _layout() -> void:
	if stage == null:
		return
	_apply_safe_area()
	stage.layout()
	backdrop.set_stage(stage.get_global_rect())
	var tr: Rect2 = top_panel.get_global_rect()
	gear_btn.position = Vector2(tr.end.x - gear_btn.size.x - 8.0, tr.position.y + 8.0)
	top_btn.position = Vector2(tr.position.x + 8.0, tr.position.y + 8.0)
	toast_label.size = Vector2(size.x - 60, 80)
	# Тост — посередине сцены, ниже облачка с мыслями Капи
	var sr: Rect2 = stage.get_global_rect()
	toast_label.position = Vector2(30, sr.position.y + sr.size.y * 0.42)


# ---------- вкладки ----------

func update_tab_titles() -> void:
	var claimable: int = Game.ach_claimable_count()
	last_claimable = claimable
	for i in tab_buttons.size():
		var b: Button = tab_buttons[i]
		b.text = Game.txt(TABS[i][0])
		var col: Color = K.C_TAB_ON if i == current_tab else K.C_TAB
		if i == TAB_AWARDS and claimable > 0:
			b.text += " (%d)" % claimable
			if i != current_tab:
				col = K.C_ORANGE
		K.style_button(b, col, 18)


## Переключить вкладку (прокрутка в начало).
func set_tab(i: int) -> void:
	var same: bool = i == current_tab
	current_tab = i
	tabs[i].opened()
	if not same:
		update_tab_titles()
	rebuild_tab(false)


## Перестроить открытую вкладку. keep_scroll = true — после покупок и появления
## новых улучшений, чтобы список не прыгал в начало.
func rebuild_tab(keep_scroll: bool) -> void:
	var old_scroll: int = scroll.scroll_vertical
	for c in list_box.get_children():
		# remove_child сразу: иначе до конца кадра в списке живут и старые, и новые строки
		list_box.remove_child(c)
		c.queue_free()
	tabs[current_tab].build()
	scroll.scroll_vertical = 0
	if keep_scroll and old_scroll > 0:
		_restore_scroll(old_scroll)
	_refresh()


func _restore_scroll(v: int) -> void:
	# Размеры пересчитаются только в конце кадра; до этого прокрутка упрётся в старый размер.
	await get_tree().process_frame
	if is_instance_valid(scroll):
		scroll.scroll_vertical = v


# ---------- кадр ----------

func _process(delta: float) -> void:
	idle_time += delta
	if idle_time > IDLE_AFTER and Engine.max_fps != FPS_IDLE:
		Engine.max_fps = FPS_IDLE
	stage.paused = popups.is_open()
	# Тексты обновляем 10 раз в секунду, а не каждый кадр: смена текста Label
	# = новый шейпинг строки, на слабых Android это заметно.
	label_timer -= delta
	if label_timer <= 0.0:
		label_timer = 0.1
		zen_label.text = D.fmt(Game.zen)
		stage.refresh()
	refresh_timer -= delta
	if refresh_timer <= 0.0:
		refresh_timer = 0.15
		_refresh()


func _refresh() -> void:
	var ch: Dictionary = D.CHAPTERS[Game.chapter]
	place_label.text = (Game.txt("chapter") % (Game.chapter + 1)) + " · " + str(ch["place_" + Game.lang])
	zps_label.text = Game.txt("per_sec") % D.fmt(Game.zps())
	mandarin_label.visible = Game.mandarins > 0
	if Game.mandarins > 0:
		mandarin_label.text = Game.txt("mandarins") % [Game.mandarins, Game.mandarin_pct()]
	_refresh_chapter_bar()
	if Game.ach_claimable_count() != last_claimable:
		update_tab_titles()
	tabs[current_tab].refresh()


## Полоска до следующей главы: в логарифмах, т.к. пороги растут в десятки раз.
func _refresh_chapter_bar() -> void:
	var c: int = Game.chapter
	if c + 1 >= D.CHAPTERS.size():
		chapter_bar.value = 1.0
		chapter_bar_label.text = Game.txt("story_end")
		return
	var lo: float = maxf(float(D.CHAPTERS[c]["at"]), 1.0)
	var hi: float = float(D.CHAPTERS[c + 1]["at"])
	var cur: float = maxf(Game.all_total, 1.0)
	var f: float = cur / hi if c == 0 else log(cur / lo) / log(hi / lo)
	f = clampf(f, 0.0, 1.0)
	chapter_bar.value = f
	chapter_bar_label.text = Game.txt("chapter_progress") % [c + 2, int(f * 100.0)]


# ---------- ввод ----------

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_GO_BACK_REQUEST:
			_on_back()
		NOTIFICATION_APPLICATION_RESUMED, NOTIFICATION_APPLICATION_FOCUS_IN:
			_wake()
			_layout()  # вырез/безопасная зона могли поменяться (поворот, складной экран)


## Кнопка/жест «Назад» на Android: окно -> первая вкладка -> выход с сохранением.
func _on_back() -> void:
	if popups.is_open():
		popups.close()
	elif current_tab != 0:
		set_tab(0)
	else:
		Game.save_game()
		get_tree().quit()


func _wake() -> void:
	idle_time = 0.0
	if Engine.max_fps != FPS_ACTIVE:
		Engine.max_fps = FPS_ACTIVE


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventMouseButton or event is InputEventKey:
		_wake()
	if popups.is_open():
		return
	var pos: Vector2 = Vector2.ZERO
	var hit: bool = false
	if event is InputEventScreenTouch and event.pressed:
		last_touch_ms = Time.get_ticks_msec()
		pos = event.position
		hit = true
	elif event is InputEventMouseButton and event.pressed \
			and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT) \
			and Time.get_ticks_msec() - last_touch_ms > TOUCH_MOUSE_GAP_MS:
		# Левая и правая кнопки мыши тапают одинаково. Клик сразу после касания —
		# это эмуляция касания (браузер / emulate_mouse_from_touch): пропускаем,
		# иначе выйдет двойной тап.
		pos = event.position
		hit = true
	if not hit or not stage.capy_rect().has_point(pos):
		return
	if stage.golden_rect().has_point(pos):
		return
	if _tap_allowed():
		_do_tap(pos)


## Скользящее окно 1 с: не больше MAX_TAPS_PER_SEC тапов (мультитач/автокликер).
func _tap_allowed() -> bool:
	var now: int = Time.get_ticks_msec()
	while not tap_stamps.is_empty() and now - tap_stamps[0] > 1000:
		tap_stamps.pop_front()
	if tap_stamps.size() >= MAX_TAPS_PER_SEC:
		return false
	tap_stamps.append(now)
	return true


func _do_tap(global_pos: Vector2) -> void:
	var v: float = Game.tap()
	audio.pop()
	stage.tap_feedback(global_pos, v)


# ---------- события игры ----------

func _on_golden() -> void:
	audio.gold()
	vibrate(40)
	toast(Game.golden_reward())


## Офлайн-доход: и при холодном старте, и при возврате из фона (Game шлёт сигнал).
func _on_offline_earned(_amount: float) -> void:
	var g: float = Game.claim_offline()
	if g >= 1.0:
		popups.show_message(Game.txt("offline_title"), Game.txt("offline_text") % D.fmt(g), stage.tex_capy)


func _on_chapter_unlocked(index: int) -> void:
	_apply_chapter(true)
	_show_chapter_popup(index)
	if current_tab == TAB_STORY:
		rebuild_tab(true)


func _apply_chapter(animated: bool) -> void:
	backdrop.show_chapter(Game.chapter, animated)
	stage.set_chapter(Game.chapter)


func _show_chapter_popup(index: int) -> void:
	var ch: Dictionary = D.CHAPTERS[index]
	popups.show_message((Game.txt("chapter") % (index + 1)) + "\n" + str(ch["place_" + Game.lang]), str(ch["text_" + Game.lang]), stage.tex_capy)


func _on_friend_joined(i: int) -> void:
	var h: Dictionary = D.HELPERS[i]
	popups.show_message(Game.txt("friend_joined") % h[Game.lang], "«" + str(h["line_" + Game.lang]) + "»", stage.friend_tex[h["icon"]])


func _on_achievement_ready(id: String) -> void:
	for a in D.ACHIEVEMENTS:
		if a["id"] == id:
			toast(Game.txt("ach_ready") % str(a[Game.lang]))
			audio.play(audio.snd_buy, 1.4, -6.0)
	update_tab_titles()
	if current_tab == TAB_AWARDS:
		rebuild_tab(true)


func _on_top_pressed() -> void:
	if not popups.is_open():
		leaderboard.show_top()


func _on_lang_toggled() -> void:
	update_tab_titles()
	rebuild_tab(true)


func _on_reset() -> void:
	Game.wipe()
	stage.sync_friends()
	_apply_chapter(false)
	set_tab(0)
	_show_chapter_popup(0)


# ---------- мелочи ----------

## Короткая вибрация. Нужно разрешение VIBRATE в экспорте Android, без него вызов ничего не делает.
func vibrate(ms: int) -> void:
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(ms)


func toast(t: String) -> void:
	toast_label.text = t
	toast_label.modulate.a = 1.0
	# Без kill() старый твин гасил бы новый тост раньше времени
	if _toast_tween and _toast_tween.is_valid():
		_toast_tween.kill()
	_toast_tween = create_tween()
	_toast_tween.tween_interval(1.6)
	_toast_tween.tween_property(toast_label, "modulate:a", 0.0, 0.6)
