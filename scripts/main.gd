extends Control
## Весь интерфейс игры собирается кодом: так его проще менять.

const D = preload("res://scripts/data.gd")

const C_BROWN: Color = Color("5b3a22")
const C_BROWN_SOFT: Color = Color(0.36, 0.23, 0.13, 0.75)
const C_ORANGE: Color = Color("ff9f43")
const C_GREEN: Color = Color("5fb36a")
const C_BLUE: Color = Color("5aa9e6")
const C_PANEL: Color = Color(1.0, 0.97, 0.9, 0.93)
const C_ROW: Color = Color(1.0, 0.93, 0.8, 1.0)
const C_TAB: Color = Color("c58b5a")
const C_TAB_ON: Color = Color("8a5530")

var tex_capy: Texture2D
var tex_mandarin: Texture2D
var tex_dot: Texture2D
var tex_paw: Texture2D
var friend_tex: Dictionary = {}

var bg: TextureRect
var zen_label: Label
var zps_label: Label
var place_label: Label
var mandarin_label: Label
var buff_label: Label
var capy_area: Control
var capy_holder: Control
var capy_sprite: TextureRect
var capy_mandarin: TextureRect
var golden_btn: TextureButton
var tab_buttons: Array = []
var list_box: VBoxContainer
var scroll: ScrollContainer
var toast_label: Label
var snow: CPUParticles2D
var steam: CPUParticles2D
var popup_layer: Control = null

var current_tab: int = 0
var buy_mode: int = 0
var helper_rows: Array = []
var upgrade_rows: Array = []
var upgrade_sig: String = ""
var nap_btn: Button
var stats_label: Label
var mandarin_info: Label
var buy_mode_btn: Button
var refresh_timer: float = 0.0
var golden_timer: float = 60.0
var golden_life: float = 0.0
var popup_queue: Array = []
var sfx: Array = []
var sfx_i: int = 0
var snd_pop: AudioStream
var snd_buy: AudioStream
var snd_gold: AudioStream
var time_acc: float = 0.0
var confirm_nap: bool = false
var confirm_reset: bool = false
var float_count: int = 0

const MAX_TAPS_PER_SEC: int = 20      # защита от автокликеров / 10 пальцев
const FPS_ACTIVE: int = 60            # 90/120 Гц экраны иначе жгут батарею
const FPS_IDLE: int = 30
const IDLE_AFTER: float = 20.0        # с без касаний -> снижаем FPS
const POPUP_GUARD: float = 0.5        # с: «Дальше» не нажимается случайным тапом

var margin: MarginContainer
var tap_tween: Tween
var toast_tween: Tween
var label_timer: float = 0.0
var last_buff_text: String = ""
var idle_time: float = 0.0
var tap_stamps: Array[int] = []
var sb_cache: Dictionary = {}

const THOUGHT_MIN: float = 25.0       # с между мыслями Капи
const THOUGHT_MAX: float = 45.0
var thought_panel: PanelContainer
var thought_label: Label
var thought_tween: Tween
var thought_timer: float = 12.0
const TOUCH_MOUSE_GAP_MS: int = 500   # клик мыши сразу после касания = эмуляция
var last_touch_ms: int = -100000

const TAB_KEYS: Array = ["tab_friends", "tab_upgrades", "tab_story", "tab_awards", "tab_more"]
const TAB_STORY: int = 2
const TAB_AWARDS: int = 3
const TAB_NAP: int = 4
const MUSIC_PATH: String = "res://assets/music/cozy_loop.wav"
const MUSIC_BASE_DB: float = -4.0
const TAP_FACE_TIME: float = 0.35     # с: сколько Капи «радуется» после тапа

var tex_capy_tap: Texture2D
var tex_gear: Texture2D
var music_player: AudioStreamPlayer
var top_panel: PanelContainer
var gear_btn: TextureButton
var chapter_bar: ProgressBar
var chapter_bar_label: Label
var tap_face_timer: float = 0.0
var ach_rows: Array = []
var ach_header: Label
var last_claimable: int = -1
## Друзья, которые «чилят» рядом с Капи: [i] -> TextureRect (или null)
var chill_back: Control
var chill_front: Control
var chill_sprites: Dictionary = {}
var chill_base: Dictionary = {}
## Места для друзей вокруг Капи: x — от центра Капи в ширинах Капи,
## y — от линии воды (низ Капи) в высотах Капи, back — за Капи.
## Все сидят в общем источнике рядами по бокам от Капи (морду никто не закрывает).
## back = true: выглядывает из-за Капи.
const CHILL_SLOTS: Array = [
	[-0.62, 0.02, false], [0.62, 0.02, false], [-0.82, -0.12, false], [0.82, -0.12, false],
	[-0.62, -0.26, false], [0.62, -0.26, false], [-0.82, -0.40, false], [0.82, -0.40, false],
	[-0.37, -0.44, true], [0.37, -0.44, true], [-0.62, -0.54, false], [0.62, -0.54, false],
	[-0.82, 0.14, false], [0.82, 0.14, false], [-0.82, -0.66, false], [0.82, -0.66, false],
	[-0.42, 0.14, false], [0.42, 0.14, false],
]
var pool_rect: TextureRect
var tex_ripple: Texture2D


func _ready() -> void:
	tex_capy = _tex("capybara")
	tex_capy_tap = _tex("capybara_tap")
	if tex_capy_tap == null:
		tex_capy_tap = tex_capy
	tex_gear = _tex("gear")
	tex_ripple = _tex("ripple")
	tex_mandarin = _tex("mandarin")
	tex_dot = _tex("dot")
	tex_paw = _tex("paw")
	for h in D.HELPERS:
		# Нет картинки (новый друг, спрайт ещё не добавлен) — показываем лапку
		var ft: Texture2D = _tex("friends/" + str(h["icon"]))
		friend_tex[h["icon"]] = ft if ft != null else tex_paw
	snd_pop = load("res://assets/pop.wav")
	snd_buy = load("res://assets/buy.wav")
	snd_gold = load("res://assets/gold.wav")
	for i in 6:
		var p: AudioStreamPlayer = AudioStreamPlayer.new()
		add_child(p)
		sfx.append(p)
	_setup_music()

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

	# Android: «Назад» обрабатываем сами (закрыть окно / вкладка / выход с сохранением)
	get_tree().quit_on_go_back = false
	Engine.max_fps = FPS_ACTIVE

	_build_ui()
	Game.chapter_unlocked.connect(_on_chapter_unlocked)
	Game.friend_joined.connect(_on_friend_joined)
	Game.offline_earned.connect(_on_offline_earned)
	Game.achievement_ready.connect(_on_achievement_ready)
	golden_timer = Game.golden_interval()
	_sync_chill_friends()
	_apply_chapter_visuals()
	_set_tab(0)

	if Game.all_total <= 0.0:
		_show_chapter_popup(0)
	if Game.pending_offline >= 1.0:
		_on_offline_earned(Game.pending_offline)
	resized.connect(_layout)
	_layout()


## Офлайн-доход: и при холодном старте, и при возврате из фона (Game шлёт сигнал).
func _on_offline_earned(_amount: float) -> void:
	var g: float = Game.claim_offline()
	if g >= 1.0:
		_show_popup(Game.txt("offline_title"), Game.txt("offline_text") % D.fmt(g), tex_capy)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_GO_BACK_REQUEST:
			_on_back()
		NOTIFICATION_APPLICATION_RESUMED, NOTIFICATION_APPLICATION_FOCUS_IN:
			_wake()
			_layout()  # вырез/безопасная зона могли поменяться (поворот, складной экран)


## Кнопка/жест «Назад» на Android: окно -> первая вкладка -> выход с сохранением.
func _on_back() -> void:
	if popup_layer != null:
		_close_popup()
	elif current_tab != 0:
		_set_tab(0)
	else:
		Game.save_game()
		get_tree().quit()


func _wake() -> void:
	idle_time = 0.0
	if Engine.max_fps != FPS_ACTIVE:
		Engine.max_fps = FPS_ACTIVE


## Фоновая музыка: бесшовная петля, громкость из настроек.
func _setup_music() -> void:
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	if not ResourceLoader.exists(MUSIC_PATH):
		return
	var s: AudioStream = load(MUSIC_PATH)
	if s is AudioStreamWAV:
		var w: AudioStreamWAV = s
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_begin = 0
		w.loop_end = int(w.get_length() * w.mix_rate)
	music_player.stream = s
	_apply_volumes()
	music_player.play()


func _apply_volumes() -> void:
	if music_player == null:
		return
	var v: float = Game.music_vol
	music_player.volume_db = MUSIC_BASE_DB + linear_to_db(maxf(v, 0.0001))
	music_player.stream_paused = v <= 0.001


## Картинка из assets: если рядом лежит .png с тем же именем, берётся он, иначе .svg
func _tex(file: String) -> Texture2D:
	for ext in [".png", ".webp", ".jpg"]:
		var path: String = "res://assets/" + file + ext
		if ResourceLoader.exists(path):
			return load(path)
	var svg: String = "res://assets/" + file + ".svg"
	if ResourceLoader.exists(svg):
		return load(svg)
	return null


# ---------- построение интерфейса ----------

## Стили кэшируются: раньше каждая перестройка вкладки создавала десятки StyleBoxFlat.
## Стили нигде не меняются после создания, поэтому их можно делить между узлами.
func _sb(color: Color, radius: int = 18, pad: int = 12) -> StyleBoxFlat:
	var key: String = "%s|%d|%d" % [color.to_html(), radius, pad]
	if sb_cache.has(key):
		return sb_cache[key]
	var s: StyleBoxFlat = StyleBoxFlat.new()
	sb_cache[key] = s
	s.bg_color = color
	s.set_corner_radius_all(radius)
	s.set_content_margin_all(pad)
	s.shadow_color = Color(0, 0, 0, 0.12)
	s.shadow_size = 4
	s.shadow_offset = Vector2(0, 2)
	return s


func _style_button(b: Button, color: Color, font_size: int = 22) -> void:
	b.add_theme_stylebox_override("normal", _sb(color, 16, 10))
	b.add_theme_stylebox_override("hover", _sb(color.lightened(0.08), 16, 10))
	b.add_theme_stylebox_override("pressed", _sb(color.darkened(0.15), 16, 10))
	b.add_theme_stylebox_override("disabled", _sb(Color(0.78, 0.73, 0.67), 16, 10))
	if not sb_cache.has("empty"):
		sb_cache["empty"] = StyleBoxEmpty.new()
	b.add_theme_stylebox_override("focus", sb_cache["empty"])
	for k in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		b.add_theme_color_override(k, Color.WHITE)
	b.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0.85))
	b.add_theme_font_size_override("font_size", font_size)
	b.mouse_filter = Control.MOUSE_FILTER_PASS
	b.focus_mode = Control.FOCUS_NONE


func _label(text: String, fs: int, color: Color = C_BROWN, center: bool = false) -> Label:
	var l: Label = Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", color)
	if center:
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _icon(tex: Texture2D, px: int) -> TextureRect:
	var t: TextureRect = TextureRect.new()
	t.texture = tex
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.custom_minimum_size = Vector2(px, px)
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t


func _build_ui() -> void:
	bg = TextureRect.new()
	bg.texture = _tex("bg")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	snow = CPUParticles2D.new()
	snow.texture = tex_dot
	snow.amount = 70
	snow.lifetime = 14.0
	snow.preprocess = 14.0
	snow.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	snow.emission_rect_extents = Vector2(420, 10)
	snow.direction = Vector2(0.2, 1)
	snow.spread = 20.0
	snow.gravity = Vector2(0, 8)
	snow.initial_velocity_min = 40.0
	snow.initial_velocity_max = 80.0
	snow.scale_amount_min = 0.12
	snow.scale_amount_max = 0.3
	snow.color = Color(1, 1, 1, 0.85)
	add_child(snow)

	margin = MarginContainer.new()
	add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["margin_left", "margin_right"]:
		margin.add_theme_constant_override(side, 16)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_bottom", 16)

	var root: VBoxContainer = VBoxContainer.new()
	root.add_theme_constant_override("separation", 10)
	margin.add_child(root)

	# Верхняя панель
	var top: PanelContainer = PanelContainer.new()
	top.add_theme_stylebox_override("panel", _sb(C_PANEL, 22, 12))
	root.add_child(top)
	top_panel = top
	var tv: VBoxContainer = VBoxContainer.new()
	tv.add_theme_constant_override("separation", 0)
	top.add_child(tv)
	place_label = _label("", 20, C_BROWN_SOFT, true)
	tv.add_child(place_label)
	zen_label = _label("0", 54, C_BROWN, true)
	tv.add_child(zen_label)
	zps_label = _label("", 21, C_BROWN_SOFT, true)
	tv.add_child(zps_label)
	mandarin_label = _label("", 19, Color("d9772b"), true)
	tv.add_child(mandarin_label)
	# Прогресс до следующей главы
	var pb_box: VBoxContainer = VBoxContainer.new()
	pb_box.add_theme_constant_override("separation", 2)
	tv.add_child(pb_box)
	chapter_bar = ProgressBar.new()
	chapter_bar.show_percentage = false
	chapter_bar.min_value = 0.0
	chapter_bar.max_value = 1.0
	chapter_bar.custom_minimum_size = Vector2(0, 10)
	chapter_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bar_bg: StyleBoxFlat = _sb(Color(0.36, 0.23, 0.13, 0.15), 6, 0).duplicate()
	bar_bg.shadow_size = 0
	var bar_fill: StyleBoxFlat = _sb(C_GREEN, 6, 0).duplicate()
	bar_fill.shadow_size = 0
	chapter_bar.add_theme_stylebox_override("background", bar_bg)
	chapter_bar.add_theme_stylebox_override("fill", bar_fill)
	pb_box.add_child(chapter_bar)
	chapter_bar_label = _label("", 15, C_BROWN_SOFT, true)
	pb_box.add_child(chapter_bar_label)

	# Зона с капибарой
	capy_area = Control.new()
	capy_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	capy_area.size_flags_stretch_ratio = 1.0
	capy_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(capy_area)
	capy_area.resized.connect(_layout)

	# Общий горячий источник (появляется, когда приходит первый друг)
	pool_rect = TextureRect.new()
	pool_rect.texture = _tex("pool")
	pool_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pool_rect.stretch_mode = TextureRect.STRETCH_SCALE
	pool_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pool_rect.visible = false
	capy_area.add_child(pool_rect)

	steam = CPUParticles2D.new()
	steam.texture = tex_dot
	steam.amount = 18
	steam.lifetime = 3.5
	steam.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	steam.emission_rect_extents = Vector2(160, 6)
	steam.direction = Vector2(0, -1)
	steam.spread = 12.0
	steam.gravity = Vector2(0, -10)
	steam.initial_velocity_min = 20.0
	steam.initial_velocity_max = 40.0
	steam.scale_amount_min = 0.4
	steam.scale_amount_max = 0.9
	var grad: Gradient = Gradient.new()
	grad.set_color(0, Color(1, 1, 1, 0.45))
	grad.set_color(1, Color(1, 1, 1, 0.0))
	steam.color_ramp = grad
	capy_area.add_child(steam)

	# Друзья за Капи / перед Капи
	chill_back = Control.new()
	chill_back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capy_area.add_child(chill_back)

	capy_holder = Control.new()
	capy_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capy_area.add_child(capy_holder)
	capy_sprite = TextureRect.new()
	capy_sprite.texture = tex_capy
	capy_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	capy_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	capy_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capy_holder.add_child(capy_sprite)
	capy_sprite.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	capy_mandarin = _icon(tex_mandarin, 10)
	capy_sprite.add_child(capy_mandarin)

	chill_front = Control.new()
	chill_front.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capy_area.add_child(chill_front)

	buff_label = _label("", 22, Color.WHITE, true)
	buff_label.add_theme_constant_override("outline_size", 8)
	buff_label.add_theme_color_override("font_outline_color", Color(0.55, 0.3, 0.05))
	capy_area.add_child(buff_label)

	# Облачко с мыслями Капи
	thought_panel = PanelContainer.new()
	thought_panel.add_theme_stylebox_override("panel", _sb(Color(1.0, 1.0, 1.0, 0.92), 20, 10))
	thought_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	thought_panel.modulate.a = 0.0
	thought_label = _label("", 18, C_BROWN, true)
	thought_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	thought_panel.add_child(thought_label)
	capy_area.add_child(thought_panel)

	golden_btn = TextureButton.new()
	golden_btn.texture_normal = tex_mandarin
	golden_btn.ignore_texture_size = true
	golden_btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	golden_btn.custom_minimum_size = Vector2(110, 110)
	golden_btn.size = Vector2(110, 110)
	golden_btn.pivot_offset = Vector2(55, 55)
	golden_btn.visible = false
	golden_btn.pressed.connect(_on_golden)
	capy_area.add_child(golden_btn)

	# Вкладки
	var tabs: HBoxContainer = HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 8)
	root.add_child(tabs)
	tabs.add_theme_constant_override("separation", 6)
	for i in TAB_KEYS.size():
		var b: Button = Button.new()
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size = Vector2(0, 58)
		b.clip_text = true
		_style_button(b, C_TAB, 18)
		b.pressed.connect(_set_tab.bind(i))
		tabs.add_child(b)
		tab_buttons.append(b)

	# Список
	var lp: PanelContainer = PanelContainer.new()
	lp.add_theme_stylebox_override("panel", _sb(C_PANEL, 22, 10))
	lp.size_flags_vertical = Control.SIZE_EXPAND_FILL
	lp.size_flags_stretch_ratio = 1.2
	root.add_child(lp)
	scroll = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	lp.add_child(scroll)
	list_box = VBoxContainer.new()
	list_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_box.add_theme_constant_override("separation", 8)
	scroll.add_child(list_box)

	toast_label = _label("", 26, Color.WHITE, true)
	toast_label.add_theme_constant_override("outline_size", 10)
	toast_label.add_theme_color_override("font_outline_color", Color(0.55, 0.3, 0.05))
	toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	toast_label.modulate.a = 0.0
	add_child(toast_label)

	# Кнопка настроек в правом верхнем углу верхней панели
	gear_btn = TextureButton.new()
	gear_btn.texture_normal = tex_gear
	gear_btn.ignore_texture_size = true
	gear_btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	gear_btn.size = Vector2(52, 52)
	gear_btn.modulate = Color(1, 1, 1, 0.85)
	gear_btn.pressed.connect(_show_settings)
	add_child(gear_btn)
	_update_tab_titles()


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
	if capy_area == null:
		return
	_apply_safe_area()
	var a: Vector2 = capy_area.size
	# Капи чуть меньше, чем раньше: по бокам должны помещаться друзья
	var w: float = minf(a.x * 0.56, a.y * 0.8 * 420.0 / 360.0)
	var h: float = w * 360.0 / 420.0
	capy_holder.size = Vector2(w, h)
	capy_holder.position = Vector2((a.x - w) * 0.5, (a.y - h) * 0.5 + 14.0)
	capy_holder.pivot_offset = Vector2(w * 0.5, h)
	capy_sprite.pivot_offset = Vector2(w * 0.5, h)
	# Мандарин на макушке: верх головы в спрайте — (210, 70) из 420x360
	var ms: float = w * 0.2
	capy_mandarin.size = Vector2(ms, ms)
	capy_mandarin.position = Vector2(w * 0.5 - ms * 0.5, h * (70.0 / 360.0) - ms * 0.82)
	steam.position = Vector2(a.x * 0.5, capy_holder.position.y + h * 0.85)
	_layout_chill(w, h)
	if gear_btn and top_panel:
		var tr: Rect2 = top_panel.get_global_rect()
		gear_btn.position = Vector2(tr.end.x - gear_btn.size.x - 8.0, tr.position.y + 8.0)
	buff_label.position = Vector2(0, 0)
	buff_label.size = Vector2(a.x, 30)
	thought_panel.size = Vector2(minf(a.x - 40.0, 460.0), 0)
	thought_panel.position = Vector2((a.x - thought_panel.size.x) * 0.5, maxf(34.0, capy_holder.position.y - 30.0))
	snow.position = Vector2(size.x * 0.5, -20)
	snow.emission_rect_extents = Vector2(size.x * 0.6, 10)
	toast_label.size = Vector2(size.x - 60, 80)
	toast_label.position = Vector2(30, size.y * 0.28)


func _update_tab_titles() -> void:
	var claimable: int = Game.ach_claimable_count()
	last_claimable = claimable
	for i in tab_buttons.size():
		var b: Button = tab_buttons[i]
		b.text = Game.txt(TAB_KEYS[i])
		if i == TAB_AWARDS and claimable > 0:
			b.text += " (%d)" % claimable
		var col: Color = C_TAB_ON if i == current_tab else C_TAB
		if i == TAB_AWARDS and claimable > 0 and i != current_tab:
			col = C_ORANGE
		_style_button(b, col, 18)


# ---------- друзья рядом с Капи ----------

## Создать спрайты для друзей, которые есть в этом забеге (owned > 0).
func _sync_chill_friends() -> void:
	if chill_back == null:
		return
	for i in D.HELPERS.size():
		var has: bool = int(Game.owned[i]) > 0
		if has and not chill_sprites.has(i):
			var slot: Array = CHILL_SLOTS[i % CHILL_SLOTS.size()]
			# Юнит = голова друга (покачивается) + вода перед ним (стоит на месте)
			var unit: Control = Control.new()
			unit.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var head: TextureRect = _icon(friend_tex[D.HELPERS[i]["icon"]], 10)
			unit.add_child(head)
			var water: TextureRect = _icon(tex_ripple, 10)
			water.stretch_mode = TextureRect.STRETCH_SCALE
			unit.add_child(water)
			unit.set_meta("head", head)
			unit.set_meta("water", water)
			(chill_back if slot[2] else chill_front).add_child(unit)
			chill_sprites[i] = unit
			head.scale = Vector2(0.1, 0.1)
			create_tween().tween_property(head, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		elif not has and chill_sprites.has(i):
			chill_sprites[i].queue_free()
			chill_sprites.erase(i)
			chill_base.erase(i)
	if pool_rect:
		pool_rect.visible = not chill_sprites.is_empty()
	_layout()


func _layout_chill(w: float, h: float) -> void:
	var cx: float = capy_holder.position.x + w * 0.5
	var base_y: float = capy_holder.position.y + h * (312.0 / 360.0)   # линия воды у Капи
	if pool_rect:
		pool_rect.position = Vector2(-4.0, base_y - h * 0.98)
		pool_rect.size = Vector2(capy_area.size.x + 8.0, h * 1.18)
	var fs: float = w * 0.19
	for i in chill_sprites:
		var slot: Array = CHILL_SLOTS[int(i) % CHILL_SLOTS.size()]
		var unit: Control = chill_sprites[i]
		var s: float = fs * (0.85 if slot[2] else 1.0)
		var head: TextureRect = unit.get_meta("head")
		var water: TextureRect = unit.get_meta("water")
		unit.size = Vector2(s, s)
		var pos: Vector2 = Vector2(cx + float(slot[0]) * w - s * 0.5, base_y + float(slot[1]) * h - s)
		pos.x = clampf(pos.x, 0.0, capy_area.size.x - s)   # не вылезать за края
		unit.position = pos
		head.size = Vector2(s, s)
		head.pivot_offset = Vector2(s * 0.5, s)
		# Вода закрывает нижнюю четверть головы и чуть шире неё
		water.size = Vector2(s * 1.3, s * 0.42)
		water.position = Vector2(-s * 0.15, s * 0.66)
		chill_base[i] = pos.y
	# Кто ниже на экране — тот ближе: рисуем поверх
	for c in [chill_front, chill_back]:
		var kids: Array = c.get_children()
		kids.sort_custom(func(p, q): return p.position.y < q.position.y)
		for k in kids.size():
			c.move_child(kids[k], k)


## Друзья покачиваются в воде, каждый в своём ритме; вода стоит на месте.
func _animate_chill() -> void:
	for i in chill_sprites:
		var unit: Control = chill_sprites[i]
		var head: TextureRect = unit.get_meta("head")
		head.position.y = 2.5 * sin(time_acc * 1.7 + float(i) * 1.3)
		head.rotation = 0.05 * sin(time_acc * 1.1 + float(i))


## Переключение вкладки (прокрутка в начало).
func _set_tab(i: int) -> void:
	var same: bool = i == current_tab
	current_tab = i
	confirm_nap = false
	confirm_reset = false
	if not same:
		_update_tab_titles()
	_rebuild_tab(false)


## Перестройка текущей вкладки. keep_scroll = true — для покупок и появления
## новых улучшений: раньше каждый такой случай (каждые 0.15 с при росте дзена)
## сбрасывал прокрутку списка улучшений в начало.
func _rebuild_tab(keep_scroll: bool) -> void:
	var i: int = current_tab
	var old_scroll: int = scroll.scroll_vertical
	for c in list_box.get_children():
		# remove_child сразу: иначе до конца кадра в VBox живут и старые, и новые строки
		list_box.remove_child(c)
		c.queue_free()
	helper_rows = []
	upgrade_rows = []
	upgrade_sig = ""
	nap_btn = null
	stats_label = null
	buy_mode_btn = null
	ach_rows = []
	ach_header = null
	match i:
		0: _build_helpers()
		1: _build_upgrades()
		TAB_STORY: _build_story()
		TAB_AWARDS: _build_awards()
		TAB_NAP: _build_nap()
	scroll.scroll_vertical = 0
	if keep_scroll and old_scroll > 0:
		_restore_scroll(old_scroll)
	_refresh()


func _restore_scroll(v: int) -> void:
	# Контейнеры пересчитают размеры только в конце кадра; до этого
	# ScrollContainer обрежет значение по старому (пустому) max_value.
	await get_tree().process_frame
	if is_instance_valid(scroll):
		scroll.scroll_vertical = v


func _row_panel() -> PanelContainer:
	var p: PanelContainer = PanelContainer.new()
	p.add_theme_stylebox_override("panel", _sb(C_ROW, 16, 10))
	p.mouse_filter = Control.MOUSE_FILTER_PASS
	return p


func _build_helpers() -> void:
	buy_mode_btn = Button.new()
	buy_mode_btn.custom_minimum_size = Vector2(0, 48)
	_style_button(buy_mode_btn, C_BLUE, 20)
	buy_mode_btn.pressed.connect(_toggle_buy_mode)
	list_box.add_child(buy_mode_btn)
	for i in D.HELPERS.size():
		var h: Dictionary = D.HELPERS[i]
		var row: PanelContainer = _row_panel()
		var hb: HBoxContainer = HBoxContainer.new()
		hb.add_theme_constant_override("separation", 12)
		row.add_child(hb)
		var ic: TextureRect = _icon(friend_tex[h["icon"]], 76)
		hb.add_child(ic)
		var vb: VBoxContainer = VBoxContainer.new()
		vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vb.alignment = BoxContainer.ALIGNMENT_CENTER
		hb.add_child(vb)
		var nl: Label = _label("", 23)
		vb.add_child(nl)
		var il: Label = _label("", 17, C_BROWN_SOFT)
		il.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vb.add_child(il)
		var b: Button = Button.new()
		b.custom_minimum_size = Vector2(150, 72)
		_style_button(b, C_GREEN, 22)
		b.pressed.connect(_on_buy_helper.bind(i))
		hb.add_child(b)
		list_box.add_child(row)
		helper_rows.append({"row": row, "icon": ic, "name": nl, "info": il, "btn": b})


func _build_upgrades() -> void:
	var list: Array = Game.visible_upgrades()
	upgrade_sig = _sig(list)
	if list.is_empty():
		var l: Label = _label(Game.txt("no_upgrades"), 20, C_BROWN_SOFT, true)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		list_box.add_child(l)
		return
	for u in list:
		var row: PanelContainer = _row_panel()
		var hb: HBoxContainer = HBoxContainer.new()
		hb.add_theme_constant_override("separation", 12)
		row.add_child(hb)
		var tex: Texture2D = tex_paw
		if friend_tex.has(u["icon"]):
			tex = friend_tex[u["icon"]]
		elif u["icon"] == "capy":
			tex = tex_capy
		elif u["icon"] == "mandarin":
			tex = tex_mandarin
		hb.add_child(_icon(tex, 64))
		var vb: VBoxContainer = VBoxContainer.new()
		vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vb.alignment = BoxContainer.ALIGNMENT_CENTER
		hb.add_child(vb)
		var nl: Label = _label(Game.upgrade_name(u), 20)
		nl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vb.add_child(nl)
		var dl: Label = _label(Game.upgrade_desc(u), 16, C_BROWN_SOFT)
		dl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vb.add_child(dl)
		var b: Button = Button.new()
		b.custom_minimum_size = Vector2(140, 64)
		b.text = D.fmt(float(u["cost"]))
		_style_button(b, C_ORANGE, 21)
		b.pressed.connect(_on_buy_upgrade.bind(u))
		hb.add_child(b)
		list_box.add_child(row)
		upgrade_rows.append({"u": u, "btn": b})


func _sig(list: Array) -> String:
	var s: String = ""
	for u in list:
		s += str(u["id"]) + ","
	return s


func _build_story() -> void:
	var lang: String = Game.lang
	var next_text: String = Game.txt("story_end")
	if Game.chapter + 1 < D.CHAPTERS.size():
		next_text = Game.txt("next_chapter") % D.fmt(float(D.CHAPTERS[Game.chapter + 1]["at"]))
	var nl: Label = _label(next_text, 18, C_BROWN_SOFT, true)
	nl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	list_box.add_child(nl)
	var c: int = Game.chapter
	while c >= 0:
		var ch: Dictionary = D.CHAPTERS[c]
		# Заголовок книги: перед последней (верхней в списке) главой каждой книги
		if c == Game.chapter or c == D.BOOK2_FIRST_CHAPTER - 1:
			var book_key: String = "book2_title" if c >= D.BOOK2_FIRST_CHAPTER else "book1_title"
			list_box.add_child(_label(Game.txt(book_key), 24, C_BROWN, true))
		var row: PanelContainer = _row_panel()
		var vb: VBoxContainer = VBoxContainer.new()
		row.add_child(vb)
		vb.add_child(_label((Game.txt("chapter") % (c + 1)) + " · " + str(ch["place_" + lang]), 22))
		var tl: Label = _label(str(ch["text_" + lang]), 18, C_BROWN_SOFT)
		tl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vb.add_child(tl)
		list_box.add_child(row)
		c -= 1
	for i in D.HELPERS.size():
		if Game.friends_met.has(str(i)):
			var h: Dictionary = D.HELPERS[i]
			var row2: PanelContainer = _row_panel()
			var hb: HBoxContainer = HBoxContainer.new()
			hb.add_theme_constant_override("separation", 12)
			row2.add_child(hb)
			hb.add_child(_icon(friend_tex[h["icon"]], 56))
			var text: String = "%s: «%s»" % [h[lang], h["line_" + lang]]
			# Реплики дружбы открываются при 10 / 25 / 50 штуках
			var own: int = int(Game.owned[i])
			var lines: Array = D.FRIEND_LINES.get(h["icon"], [])
			var next_at: int = 0
			for fl in lines:
				if own >= int(fl["at"]):
					text += "\n«%s»" % fl[lang]
				elif next_at == 0:
					next_at = int(fl["at"])
			if next_at > 0:
				text += "\n" + Game.txt("friend_line_locked") % next_at
			var ll: Label = _label(text, 17, C_BROWN_SOFT)
			ll.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			ll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			hb.add_child(ll)
			list_box.add_child(row2)


func _build_nap() -> void:
	var row: PanelContainer = _row_panel()
	var vb: VBoxContainer = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 8)
	row.add_child(vb)
	var hb: HBoxContainer = HBoxContainer.new()
	hb.add_child(_icon(tex_mandarin, 56))
	hb.add_child(_label(Game.txt("nap_title"), 26))
	vb.add_child(hb)
	var dl: Label = _label(Game.txt("nap_desc"), 17, C_BROWN_SOFT)
	dl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(dl)
	mandarin_info = _label("", 19, Color("d9772b"))
	vb.add_child(mandarin_info)
	nap_btn = Button.new()
	nap_btn.custom_minimum_size = Vector2(0, 68)
	nap_btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_style_button(nap_btn, C_ORANGE, 21)
	nap_btn.pressed.connect(_on_nap)
	vb.add_child(nap_btn)
	list_box.add_child(row)

	stats_label = _label("", 18, C_BROWN_SOFT)
	list_box.add_child(stats_label)


# ---------- награды (достижения) ----------

func _build_awards() -> void:
	ach_header = _label("", 19, Color("d9772b"), true)
	ach_header.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	list_box.add_child(ach_header)
	# Сначала готовые к получению, потом в процессе, в конце уже полученные
	var order: Array = []
	for pass_i in 3:
		for a in D.ACHIEVEMENTS:
			var claimed: bool = Game.ach_claimed.has(a["id"])
			var done: bool = Game.ach_done(a)
			var bucket: int = 2 if claimed else (0 if done else 1)
			if bucket == pass_i:
				order.append(a)
	for a in order:
		var row: PanelContainer = _row_panel()
		var hb: HBoxContainer = HBoxContainer.new()
		hb.add_theme_constant_override("separation", 12)
		row.add_child(hb)
		var ic: TextureRect = _icon(tex_mandarin, 52)
		hb.add_child(ic)
		var vb: VBoxContainer = VBoxContainer.new()
		vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vb.alignment = BoxContainer.ALIGNMENT_CENTER
		hb.add_child(vb)
		vb.add_child(_label(str(a[Game.lang]), 20))
		var dl: Label = _label("", 16, C_BROWN_SOFT)
		dl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vb.add_child(dl)
		var b: Button = Button.new()
		b.custom_minimum_size = Vector2(140, 60)
		_style_button(b, C_ORANGE, 19)
		b.pressed.connect(_on_claim.bind(str(a["id"])))
		hb.add_child(b)
		list_box.add_child(row)
		ach_rows.append({"a": a, "desc": dl, "btn": b, "icon": ic})


func _refresh_awards() -> void:
	if ach_header:
		var n: int = Game.ach_claimed.size()
		ach_header.text = Game.txt("ach_header") % [n, D.ACHIEVEMENTS.size(), int(round(n * D.ACH_BONUS * 100.0))] \
			+ "\n" + Game.txt("ach_reward")
	for r in ach_rows:
		var a: Dictionary = r["a"]
		var claimed: bool = Game.ach_claimed.has(a["id"])
		var done: bool = Game.ach_done(a)
		var goal: float = float(a["goal"])
		var cur: float = minf(Game.ach_value(a), goal)
		(r["desc"] as Label).text = "%s\n%s / %s" % [a["d_" + Game.lang], D.fmt(cur), D.fmt(goal)]
		var b: Button = r["btn"]
		b.text = Game.txt("ach_done") if claimed else Game.txt("ach_claim")
		b.disabled = claimed or not done
		(r["icon"] as TextureRect).modulate = Color.WHITE if (claimed or done) else Color(0.3, 0.3, 0.3, 0.45)


func _on_claim(id: String) -> void:
	if Game.claim_achievement(id):
		_play(snd_gold, 1.1)
		_vibrate(40)
		_toast("+2%!")
		_update_tab_titles()
		_rebuild_tab(true)


func _on_achievement_ready(id: String) -> void:
	for a in D.ACHIEVEMENTS:
		if a["id"] == id:
			_toast(Game.txt("ach_ready") % str(a[Game.lang]))
			_play(snd_buy, 1.4, -6.0)
	_update_tab_titles()
	if current_tab == TAB_AWARDS:
		_rebuild_tab(true)


# ---------- настройки ----------

func _show_settings() -> void:
	if popup_layer != null:
		return
	confirm_reset = false
	popup_layer = ColorRect.new()
	(popup_layer as ColorRect).color = Color(0.1, 0.05, 0.0, 0.5)
	popup_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(popup_layer)
	popup_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var cc: CenterContainer = CenterContainer.new()
	popup_layer.add_child(cc)
	cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var p: PanelContainer = PanelContainer.new()
	p.add_theme_stylebox_override("panel", _sb(Color(1.0, 0.97, 0.9), 26, 24))
	cc.add_child(p)
	var vb: VBoxContainer = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 14)
	vb.custom_minimum_size = Vector2(minf(520.0, size.x - 100.0), 0)
	p.add_child(vb)
	vb.add_child(_label(Game.txt("settings"), 30, C_BROWN, true))
	vb.add_child(_volume_row(Game.txt("music"), Game.music_vol, _on_music_vol))
	vb.add_child(_volume_row(Game.txt("sounds"), Game.sfx_vol, _on_sfx_vol))
	var lb: Button = Button.new()
	lb.text = Game.txt("lang")
	lb.custom_minimum_size = Vector2(0, 58)
	_style_button(lb, C_BLUE, 20)
	lb.pressed.connect(_toggle_lang)
	vb.add_child(lb)
	var rb: Button = Button.new()
	rb.text = Game.txt("reset")
	rb.custom_minimum_size = Vector2(0, 50)
	_style_button(rb, Color("c76b6b"), 18)
	rb.pressed.connect(_on_reset.bind(rb))
	vb.add_child(rb)
	var cb: Button = Button.new()
	cb.text = Game.txt("close")
	cb.custom_minimum_size = Vector2(0, 64)
	_style_button(cb, C_GREEN, 24)
	cb.mouse_filter = Control.MOUSE_FILTER_STOP
	cb.pressed.connect(_close_settings)
	vb.add_child(cb)


func _volume_row(title: String, value: float, cb: Callable) -> Control:
	var hb: HBoxContainer = HBoxContainer.new()
	hb.add_theme_constant_override("separation", 14)
	var l: Label = _label(title, 21)
	l.custom_minimum_size = Vector2(110, 0)
	hb.add_child(l)
	var s: HSlider = HSlider.new()
	s.min_value = 0.0
	s.max_value = 1.0
	s.step = 0.05
	s.value = value
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	s.custom_minimum_size = Vector2(0, 44)
	s.focus_mode = Control.FOCUS_NONE
	var grab: StyleBoxFlat = _sb(C_ORANGE, 6, 0).duplicate()
	grab.shadow_size = 0
	var track: StyleBoxFlat = _sb(Color(0.36, 0.23, 0.13, 0.2), 6, 0).duplicate()
	track.shadow_size = 0
	track.content_margin_top = 5
	track.content_margin_bottom = 5
	s.add_theme_stylebox_override("slider", track)
	s.add_theme_stylebox_override("grabber_area", grab)
	s.add_theme_stylebox_override("grabber_area_highlight", grab)
	s.value_changed.connect(cb)
	hb.add_child(s)
	return hb


func _on_music_vol(v: float) -> void:
	Game.music_vol = v
	_apply_volumes()


func _on_sfx_vol(v: float) -> void:
	Game.sfx_vol = v
	_play(snd_pop, 1.0, -6.0)


func _close_settings() -> void:
	Game.save_game()
	_close_popup()


# ---------- обновление ----------

func _process(delta: float) -> void:
	time_acc += delta
	capy_sprite.scale = Vector2(1.0 + 0.01 * sin(time_acc * 2.0), 1.0 + 0.02 * sin(time_acc * 2.0 + 0.6))
	_animate_chill()
	if tap_face_timer > 0.0:
		tap_face_timer -= delta
		if tap_face_timer <= 0.0:
			capy_sprite.texture = tex_capy

	idle_time += delta
	if idle_time > IDLE_AFTER and Engine.max_fps != FPS_IDLE:
		Engine.max_fps = FPS_IDLE

	# Тексты обновляем 10 раз в секунду, а не каждый кадр: смена текста Label
	# = новый шейпинг строки (TextServer), на слабых Android это заметно.
	label_timer -= delta
	if label_timer <= 0.0:
		label_timer = 0.1
		zen_label.text = D.fmt(Game.zen)
		var b: String = ""
		if Game.frenzy_time > 0.0:
			b += Game.txt("buff_frenzy") % int(ceil(Game.frenzy_time)) + "   "
		if Game.tap_frenzy_time > 0.0:
			b += Game.txt("buff_tap") % int(ceil(Game.tap_frenzy_time))
		if b != last_buff_text:
			last_buff_text = b
			buff_label.text = b

	refresh_timer -= delta
	if refresh_timer <= 0.0:
		refresh_timer = 0.15
		_refresh()

	if golden_btn.visible:
		golden_life -= delta
		golden_btn.rotation = 0.15 * sin(time_acc * 4.0)
		if golden_life <= 0.0:
			golden_btn.visible = false
			golden_timer = Game.golden_interval()
		elif golden_life < 3.0:
			golden_btn.modulate.a = 0.5 + 0.5 * absf(sin(time_acc * 8.0))
	else:
		golden_timer -= delta
		if golden_timer <= 0.0 and popup_layer == null:
			_spawn_golden()

	thought_timer -= delta
	if thought_timer <= 0.0:
		thought_timer = randf_range(THOUGHT_MIN, THOUGHT_MAX)
		if popup_layer == null:
			_show_thought()


## Случайная мысль Капи над головой (мысли второй книги — только с нужной главы).
func _show_thought() -> void:
	var pool: Array = D.CAPY_THOUGHTS.duplicate()
	for t in D.CAPY_THOUGHTS_BOOK2:
		if Game.chapter >= int(t["ch"]):
			pool.append(t)
	if pool.is_empty():
		return
	thought_label.text = str(pool[randi() % pool.size()][Game.lang])
	if thought_tween and thought_tween.is_valid():
		thought_tween.kill()
	thought_tween = create_tween()
	thought_tween.tween_property(thought_panel, "modulate:a", 1.0, 0.4)
	thought_tween.tween_interval(5.0)
	thought_tween.tween_property(thought_panel, "modulate:a", 0.0, 0.6)


func _refresh() -> void:
	var lang: String = Game.lang
	var ch: Dictionary = D.CHAPTERS[Game.chapter]
	place_label.text = (Game.txt("chapter") % (Game.chapter + 1)) + " · " + str(ch["place_" + lang])
	zps_label.text = Game.txt("per_sec") % D.fmt(Game.zps())
	if Game.mandarins > 0:
		mandarin_label.text = Game.txt("mandarins") % [Game.mandarins, Game.mandarins * 5]
		mandarin_label.visible = true
	else:
		mandarin_label.visible = false
	capy_mandarin.visible = Game.mandarins > 0
	_refresh_chapter_bar()
	if Game.ach_claimable_count() != last_claimable:
		_update_tab_titles()

	match current_tab:
		0: _refresh_helpers()
		1: _refresh_upgrades()
		TAB_AWARDS: _refresh_awards()
		TAB_NAP: _refresh_nap()


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
	var f: float = 0.0
	if c == 0:
		f = cur / hi
	else:
		f = log(cur / lo) / log(hi / lo)
	f = clampf(f, 0.0, 1.0)
	chapter_bar.value = f
	chapter_bar_label.text = Game.txt("chapter_progress") % [c + 2, int(f * 100.0)]


func _buy_count(i: int) -> int:
	match buy_mode:
		1:
			return 10
		2:
			return maxi(1, Game.helper_max_affordable(i))
	return 1


func _refresh_helpers() -> void:
	var lang: String = Game.lang
	if buy_mode_btn:
		var modes: Array = ["x1", "x10", "MAX"]
		buy_mode_btn.text = Game.txt("buy_mode") % modes[buy_mode]
	var shown_locked: bool = false
	for i in helper_rows.size():
		var r: Dictionary = helper_rows[i]
		var h: Dictionary = D.HELPERS[i]
		var revealed: bool = Game.helper_revealed(i)
		var row: PanelContainer = r["row"]
		var btn: Button = r["btn"]
		var ic: TextureRect = r["icon"]
		var nl: Label = r["name"]
		var il: Label = r["info"]
		if not revealed:
			if shown_locked:
				row.visible = false
				continue
			shown_locked = true
			row.visible = true
			ic.modulate = Color(0, 0, 0, 0.55)
			nl.text = Game.txt("locked")
			il.text = Game.txt("locked_hint_book2" if h.has("chapter_req") else "locked_hint")
			btn.text = D.fmt(Game.helper_cost(i, 1))
			btn.disabled = true
			continue
		row.visible = true
		ic.modulate = Color.WHITE
		var n: int = _buy_count(i)
		var cost: float = Game.helper_cost(i, n)
		nl.text = str(h[lang])
		var own: int = int(Game.owned[i])
		var each: float = Game.helper_zps_each(i) * Game.prestige_mult()
		if own > 0:
			il.text = Game.txt("owned") % [own, D.fmt(each * own)]
		else:
			il.text = Game.txt("each") % D.fmt(each)
		btn.text = D.fmt(cost) + ("" if n == 1 else "\nx%d" % n)
		btn.disabled = Game.zen < cost


func _refresh_upgrades() -> void:
	var list: Array = Game.visible_upgrades()
	if _sig(list) != upgrade_sig:
		_rebuild_tab(true)
		return
	for r in upgrade_rows:
		var b: Button = r["btn"]
		b.disabled = Game.zen < float(r["u"]["cost"])


func _refresh_nap() -> void:
	if nap_btn == null:
		return
	mandarin_info.text = Game.txt("mandarins") % [Game.mandarins, Game.mandarins * 5]
	if not Game.nap_unlocked():
		nap_btn.text = Game.txt("nap_locked")
		nap_btn.disabled = true
	elif Game.nap_gain() <= 0:
		nap_btn.text = Game.txt("nap_none")
		nap_btn.disabled = true
	else:
		nap_btn.disabled = false
		nap_btn.text = Game.txt("nap_confirm") if confirm_nap else Game.txt("nap_gain") % str(Game.nap_gain())
	stats_label.text = Game.txt("stats") % [D.fmt(Game.all_total), Game.taps, Game.naps]


# ---------- действия ----------

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventMouseButton or event is InputEventKey:
		_wake()
	if popup_layer != null:
		return
	var pos: Vector2 = Vector2.ZERO
	var hit: bool = false
	if event is InputEventScreenTouch and event.pressed:
		last_touch_ms = Time.get_ticks_msec()
		pos = event.position
		hit = true
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT \
			and Time.get_ticks_msec() - last_touch_ms > TOUCH_MOUSE_GAP_MS:
		# Касание порождает ещё и клик мыши (emulate_mouse_from_touch или сам браузер).
		# Такой клик приходит сразу после касания — его пропускаем, чтобы не было
		# двойного тапа. Проверка по device не годится: в веб-версии она отсекала
		# и настоящую мышь.
		pos = event.position
		hit = true
	if not hit:
		return
	if not _tap_allowed():
		return
	if golden_btn.visible and golden_btn.get_global_rect().has_point(pos):
		return
	var r: Rect2 = capy_holder.get_global_rect().grow(-capy_holder.size.x * 0.05)
	if r.has_point(pos):
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
	# Один твин на Капи: раньше каждый тап создавал новый, и при быстрых
	# нажатиях десятки твинов одновременно дёргали один и тот же scale.
	if tap_tween and tap_tween.is_valid():
		tap_tween.kill()
	tap_tween = create_tween()
	tap_tween.tween_property(capy_holder, "scale", Vector2(1.06, 0.9), 0.05)
	tap_tween.tween_property(capy_holder, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_play(snd_pop, randf_range(0.9, 1.2), -6.0)
	# Капи радуется: открывает глаза на мгновение
	capy_sprite.texture = tex_capy_tap
	tap_face_timer = TAP_FACE_TIME
	if float_count < 40:
		_float_text("+" + D.fmt(v), global_pos - capy_area.global_position)


func _float_text(t: String, local_pos: Vector2) -> void:
	float_count += 1
	var l: Label = _label(t, 34, Color.WHITE, true)
	l.add_theme_constant_override("outline_size", 8)
	l.add_theme_color_override("font_outline_color", C_BROWN)
	l.size = Vector2(240, 44)
	l.position = local_pos - Vector2(120 + randf_range(-20, 20), 40)
	capy_area.add_child(l)
	var tw: Tween = create_tween().set_parallel(true)
	tw.tween_property(l, "position:y", l.position.y - 150.0, 0.9).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(l, "modulate:a", 0.0, 0.9).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(_float_done.bind(l))


func _float_done(l: Label) -> void:
	l.queue_free()
	float_count -= 1


func _play(stream: AudioStream, pitch: float = 1.0, db: float = 0.0) -> void:
	if stream == null or Game.sfx_vol <= 0.001:
		return
	var p: AudioStreamPlayer = sfx[sfx_i]
	sfx_i = (sfx_i + 1) % sfx.size()
	p.stream = stream
	p.pitch_scale = pitch
	p.volume_db = db + linear_to_db(Game.sfx_vol)
	p.play()


func _toggle_buy_mode() -> void:
	buy_mode = (buy_mode + 1) % 3
	_refresh()


func _on_buy_helper(i: int) -> void:
	if Game.buy_helper(i, _buy_count(i)):
		_play(snd_buy, randf_range(0.95, 1.05), -4.0)
		if not chill_sprites.has(i):
			_sync_chill_friends()
		_refresh()


func _on_buy_upgrade(u: Dictionary) -> void:
	if Game.buy_upgrade(u):
		_play(snd_buy, 1.2, -4.0)
		_rebuild_tab(true)


func _on_nap() -> void:
	if not confirm_nap:
		confirm_nap = true
		_refresh()
		return
	confirm_nap = false
	Game.do_nap()
	_play(snd_gold)
	_vibrate(80)
	_sync_chill_friends()
	_set_tab(0)
	_toast(Game.txt("mandarins") % [Game.mandarins, Game.mandarins * 5])


func _on_reset(b: Button) -> void:
	if not confirm_reset:
		confirm_reset = true
		b.text = Game.txt("reset_confirm")
		return
	Game.wipe()
	_close_popup()
	_sync_chill_friends()
	_apply_chapter_visuals()
	_set_tab(0)
	_show_chapter_popup(0)


func _toggle_lang() -> void:
	Game.lang = "en" if Game.lang == "ru" else "ru"
	Game.save_game()
	_update_tab_titles()
	_rebuild_tab(true)
	# Окно настроек открыто — пересобрать его на новом языке
	if popup_layer != null:
		_close_popup()
		_show_settings()


func _spawn_golden() -> void:
	var a: Vector2 = capy_area.size
	golden_btn.position = Vector2(randf_range(10.0, maxf(20.0, a.x - 130.0)), randf_range(30.0, maxf(40.0, a.y - 130.0)))
	golden_btn.modulate.a = 1.0
	golden_btn.visible = true
	golden_btn.scale = Vector2(0.2, 0.2)
	create_tween().tween_property(golden_btn, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	golden_life = 13.0


func _on_golden() -> void:
	golden_btn.visible = false
	golden_timer = Game.golden_interval()
	_play(snd_gold)
	_vibrate(40)
	_toast(Game.golden_reward())


## Короткая вибрация. Нужно разрешение VIBRATE в экспорте Android
## (permissions/vibrate=true), без него вызов ничего не делает.
func _vibrate(ms: int) -> void:
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(ms)


func _toast(t: String) -> void:
	toast_label.text = t
	toast_label.modulate.a = 1.0
	# Без kill() старый твин гасил новый тост раньше времени.
	if toast_tween and toast_tween.is_valid():
		toast_tween.kill()
	toast_tween = create_tween()
	toast_tween.tween_interval(1.6)
	toast_tween.tween_property(toast_label, "modulate:a", 0.0, 0.6)


# ---------- сюжет и всплывающие окна ----------

func _apply_chapter_visuals() -> void:
	var ch: Dictionary = D.CHAPTERS[Game.chapter]
	var tw: Tween = create_tween()
	tw.tween_property(bg, "modulate", ch["tint"], 1.5)
	snow.emitting = Game.chapter < 2
	steam.emitting = Game.chapter >= 1


func _on_chapter_unlocked(index: int) -> void:
	_apply_chapter_visuals()
	_show_chapter_popup(index)
	if current_tab == TAB_STORY:
		_rebuild_tab(true)


func _show_chapter_popup(index: int) -> void:
	var ch: Dictionary = D.CHAPTERS[index]
	var lang: String = Game.lang
	_show_popup((Game.txt("chapter") % (index + 1)) + "\n" + str(ch["place_" + lang]), str(ch["text_" + lang]), tex_capy)


func _on_friend_joined(i: int) -> void:
	var h: Dictionary = D.HELPERS[i]
	var lang: String = Game.lang
	_show_popup(Game.txt("friend_joined") % h[lang], "«" + str(h["line_" + lang]) + "»", friend_tex[h["icon"]])


func _show_popup(title: String, body: String, icon: Texture2D) -> void:
	if popup_layer != null:
		popup_queue.append([title, body, icon])
		return
	popup_layer = ColorRect.new()
	(popup_layer as ColorRect).color = Color(0.1, 0.05, 0.0, 0.5)
	popup_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(popup_layer)
	popup_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var cc: CenterContainer = CenterContainer.new()
	popup_layer.add_child(cc)
	cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var p: PanelContainer = PanelContainer.new()
	p.add_theme_stylebox_override("panel", _sb(Color(1.0, 0.97, 0.9), 26, 24))
	cc.add_child(p)
	var vb: VBoxContainer = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 14)
	p.add_child(vb)
	if icon:
		var ic: TextureRect = _icon(icon, 150)
		vb.add_child(ic)
	vb.add_child(_label(title, 30, C_BROWN, true))
	var bl: Label = _label(body, 21, C_BROWN_SOFT, true)
	bl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bl.custom_minimum_size = Vector2(minf(560.0, size.x - 110.0), 0)
	vb.add_child(bl)
	var b: Button = Button.new()
	b.text = Game.txt("continue")
	b.custom_minimum_size = Vector2(0, 64)
	_style_button(b, C_GREEN, 24)
	b.mouse_filter = Control.MOUSE_FILTER_STOP
	b.pressed.connect(_close_popup)
	vb.add_child(b)
	# Окно появляется под пальцем, который как раз тапает Капи: первые
	# POPUP_GUARD секунд кнопка неактивна, иначе сюжет пролистывается не глядя.
	b.disabled = true
	var guard: Tween = b.create_tween()  # твин привязан к кнопке и умрёт вместе с ней
	guard.tween_interval(POPUP_GUARD)
	guard.tween_callback(b.set.bind("disabled", false))
	p.scale = Vector2(0.85, 0.85)
	p.modulate.a = 0.0
	var tw: Tween = create_tween().set_parallel(true)
	tw.tween_property(p, "modulate:a", 1.0, 0.2)
	tw.tween_property(p, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	p.resized.connect(func(): p.pivot_offset = p.size * 0.5)


func _close_popup() -> void:
	if popup_layer:
		popup_layer.queue_free()
		popup_layer = null
	if not popup_queue.is_empty():
		var q: Array = popup_queue.pop_front()
		_show_popup(q[0], q[1], q[2])
