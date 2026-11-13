extends Control
## Всплывающие окна поверх игры: сюжет, новые друзья, офлайн-доход и настройки.
## Окна идут по очереди: пока одно открыто, следующие ждут.

signal lang_toggled
signal reset_confirmed

const K = preload("res://scripts/ui/ui_kit.gd")
const GUARD_TIME: float = 0.5   # с: «Дальше» не нажимается случайным тапом по Капи

var audio: Node                 # для звука ползунка громкости
var layer: Control = null       # текущее окно (null — ничего не открыто)
var _queue: Array = []
var _confirm_reset: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func is_open() -> bool:
	return layer != null


## Окно с картинкой, заголовком, текстом и кнопкой «Дальше».
func show_message(title: String, body: String, icon: Texture2D) -> void:
	if layer != null:
		_queue.append([title, body, icon])
		return
	var vb: VBoxContainer = _open()
	if icon:
		vb.add_child(K.icon(icon, 150))
	vb.add_child(K.label(title, 30, K.C_BROWN, true))
	var bl: Label = K.label(body, 21, K.C_BROWN_SOFT, true, true)
	bl.custom_minimum_size = Vector2(minf(560.0, size.x - 110.0), 0)
	vb.add_child(bl)
	var b: Button = K.button(Game.txt("continue"), K.C_GREEN, 24, Vector2(0, 64), close)
	b.mouse_filter = Control.MOUSE_FILTER_STOP
	vb.add_child(b)
	# Окно появляется под пальцем, который как раз тапает Капи: первые
	# GUARD_TIME секунд кнопка неактивна, иначе сюжет пролистывается не глядя.
	b.disabled = true
	var guard: Tween = b.create_tween()   # твин умрёт вместе с кнопкой
	guard.tween_interval(GUARD_TIME)
	guard.tween_callback(b.set.bind("disabled", false))


func show_settings() -> void:
	if layer != null:
		return
	_confirm_reset = false
	var vb: VBoxContainer = _open()
	vb.custom_minimum_size = Vector2(minf(520.0, size.x - 100.0), 0)
	vb.add_child(K.label(Game.txt("settings"), 30, K.C_BROWN, true))
	vb.add_child(_volume_row(Game.txt("music"), Game.music_vol, _on_music_vol))
	vb.add_child(_volume_row(Game.txt("sounds"), Game.sfx_vol, _on_sfx_vol))
	vb.add_child(K.button(Game.txt("lang"), K.C_BLUE, 20, Vector2(0, 58), _on_lang))
	var rb: Button = K.button(Game.txt("reset"), K.C_RED, 18, Vector2(0, 50), func(): pass)
	rb.pressed.connect(_on_reset.bind(rb))
	vb.add_child(rb)
	var cb: Button = K.button(Game.txt("close"), K.C_GREEN, 24, Vector2(0, 64), close_settings)
	cb.mouse_filter = Control.MOUSE_FILTER_STOP
	vb.add_child(cb)


func close_settings() -> void:
	Game.save_game()
	close()


## Закрыть текущее окно и показать следующее из очереди.
func close() -> void:
	if layer:
		layer.queue_free()
		layer = null
	if not _queue.is_empty():
		var q: Array = _queue.pop_front()
		show_message(q[0], q[1], q[2])


## Затемнение + панель по центру с появлением; возвращает контейнер для содержимого.
func _open() -> VBoxContainer:
	var dim: ColorRect = ColorRect.new()
	dim.color = K.C_DIM
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer = dim
	var cc: CenterContainer = CenterContainer.new()
	dim.add_child(cc)
	cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var p: PanelContainer = PanelContainer.new()
	p.add_theme_stylebox_override("panel", K.sb(K.C_POPUP, 26, 24))
	cc.add_child(p)
	var vb: VBoxContainer = K.vbox(14)
	p.add_child(vb)
	p.scale = Vector2(0.85, 0.85)
	p.modulate.a = 0.0
	var tw: Tween = create_tween().set_parallel(true)
	tw.tween_property(p, "modulate:a", 1.0, 0.2)
	tw.tween_property(p, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	p.resized.connect(func(): p.pivot_offset = p.size * 0.5)
	return vb


func _volume_row(title: String, value: float, cb: Callable) -> Control:
	var hb: HBoxContainer = K.hbox(14)
	var l: Label = K.label(title, 21)
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
	var track: StyleBoxFlat = K.flat(Color(0.36, 0.23, 0.13, 0.2)).duplicate()
	track.content_margin_top = 5
	track.content_margin_bottom = 5
	var grab: StyleBoxFlat = K.flat(K.C_ORANGE)
	s.add_theme_stylebox_override("slider", track)
	s.add_theme_stylebox_override("grabber_area", grab)
	s.add_theme_stylebox_override("grabber_area_highlight", grab)
	s.value_changed.connect(cb)
	hb.add_child(s)
	return hb


func _on_music_vol(v: float) -> void:
	Game.music_vol = v
	if audio:
		audio.apply_volumes()


func _on_sfx_vol(v: float) -> void:
	Game.sfx_vol = v
	if audio:
		audio.play(audio.snd_pop, 1.0, -6.0)


func _on_lang() -> void:
	Game.lang = "en" if Game.lang == "ru" else "ru"
	Game.save_game()
	# Пересобрать окно настроек на новом языке
	close()
	show_settings()
	lang_toggled.emit()


func _on_reset(b: Button) -> void:
	if not _confirm_reset:
		_confirm_reset = true
		b.text = Game.txt("reset_confirm")
		return
	close()
	reset_confirmed.emit()
