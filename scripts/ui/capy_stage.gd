extends Control
## Сцена в центре экрана: Капи в горячем источнике, друзья вокруг неё, пар,
## облачко с мыслями, всплывающие числа и золотой мандарин.

signal golden_pressed

const D = preload("res://scripts/data.gd")
const K = preload("res://scripts/ui/ui_kit.gd")

const TAP_FACE_TIME: float = 0.35      # с: сколько Капи «радуется» после тапа
const THOUGHT_MIN: float = 18.0        # с между мыслями Капи
const THOUGHT_MAX: float = 34.0
const THOUGHT_HISTORY: int = 20        # столько последних мыслей не повторяем
const GOLDEN_LIFE: float = 13.0
const MAX_FLOATS: int = 40

## Места для друзей: x — от центра Капи в ширинах Капи, y — от линии воды
## (низ Капи) в высотах Капи, back = true — выглядывает из-за Капи.
## Индекс места = индекс друга, новые места дописывать в конец.
const CHILL_SLOTS: Array = [
	[-0.62, 0.02, false], [0.62, 0.02, false], [-0.82, -0.12, false], [0.82, -0.12, false],
	[-0.62, -0.26, false], [0.62, -0.26, false], [-0.82, -0.40, false], [0.82, -0.40, false],
	[-0.37, -0.44, true], [0.37, -0.44, true], [-0.62, -0.54, false], [0.62, -0.54, false],
	[-0.82, 0.14, false], [0.82, 0.14, false], [-0.82, -0.66, false], [0.82, -0.66, false],
	[-0.42, 0.14, false], [0.42, 0.14, false],
	# Книга третья
	[-0.21, 0.17, false], [0.21, 0.17, false], [-0.62, 0.17, false], [0.62, 0.17, false],
	[-0.44, -0.66, true], [0.44, -0.66, true],
]

var tex_capy: Texture2D
var tex_capy_tap: Texture2D
var tex_mandarin: Texture2D
var tex_ripple: Texture2D
var friend_tex: Dictionary = {}

var pool_rect: TextureRect
var steam: CPUParticles2D
var chill_back: Control
var chill_front: Control
var capy_holder: Control
var capy_sprite: TextureRect
var capy_mandarin: TextureRect
var buff_label: Label
var thought_panel: PanelContainer
var thought_label: Label
var golden_btn: TextureButton

## Друзья, которые «чилят» рядом с Капи: индекс друга -> Control (голова + вода)
var chill_sprites: Dictionary = {}
var paused: bool = false               # true, пока открыто окно: ни мыслей, ни мандаринов
var thought_timer: float = 10.0
var golden_timer: float = 60.0
var golden_life: float = 0.0
var tap_face_timer: float = 0.0
var float_count: int = 0
var _t: float = 0.0
var _tap_tween: Tween
var _thought_tween: Tween
var _last_buff: String = ""
var _recent_thoughts: Array = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	tex_capy = K.tex("capybara")
	tex_capy_tap = K.tex("capybara_tap")
	if tex_capy_tap == null:
		tex_capy_tap = tex_capy
	tex_mandarin = K.tex("mandarin")
	tex_ripple = K.tex("ripple")
	var paw: Texture2D = K.tex("paw")
	for h in D.HELPERS:
		# Нет картинки (спрайт ещё не добавлен) — показываем лапку
		var ft: Texture2D = K.tex("friends/" + str(h["icon"]))
		friend_tex[h["icon"]] = ft if ft != null else paw
	_build()
	golden_timer = Game.golden_interval()
	resized.connect(layout)


func _build() -> void:
	# Общий горячий источник (появляется вместе с первым другом)
	pool_rect = TextureRect.new()
	pool_rect.texture = K.tex("pool")
	pool_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pool_rect.stretch_mode = TextureRect.STRETCH_SCALE
	pool_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pool_rect.visible = false
	add_child(pool_rect)

	steam = CPUParticles2D.new()
	steam.texture = K.tex("dot")
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
	grad.offsets = PackedFloat32Array([0.0, 1.0])
	grad.colors = PackedColorArray([Color(1, 1, 1, 0.45), Color(1, 1, 1, 0.0)])
	steam.color_ramp = grad
	add_child(steam)

	chill_back = _layer()
	capy_holder = _layer()
	capy_sprite = TextureRect.new()
	capy_sprite.texture = tex_capy
	capy_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	capy_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	capy_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capy_holder.add_child(capy_sprite)
	capy_sprite.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	capy_mandarin = K.icon(tex_mandarin, 10)
	capy_sprite.add_child(capy_mandarin)
	chill_front = _layer()

	buff_label = K.outlined("", 22)
	add_child(buff_label)

	thought_panel = PanelContainer.new()
	thought_panel.add_theme_stylebox_override("panel", K.sb(Color(1.0, 1.0, 1.0, 0.94), 20, 10))
	thought_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	thought_panel.modulate.a = 0.0
	thought_label = K.label("", 18, K.C_BROWN, true, true)
	thought_panel.add_child(thought_label)
	add_child(thought_panel)

	golden_btn = TextureButton.new()
	golden_btn.texture_normal = tex_mandarin
	golden_btn.ignore_texture_size = true
	golden_btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	golden_btn.custom_minimum_size = Vector2(110, 110)
	golden_btn.size = Vector2(110, 110)
	golden_btn.pivot_offset = Vector2(55, 55)
	golden_btn.visible = false
	golden_btn.pressed.connect(_on_golden)
	add_child(golden_btn)


func _layer() -> Control:
	var c: Control = Control.new()
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(c)
	return c


# ---------- раскладка ----------

func layout() -> void:
	var a: Vector2 = size
	# Капи не шире 56% сцены: по бокам должны помещаться друзья
	var w: float = minf(a.x * 0.56, a.y * 0.7 * 420.0 / 360.0)
	var h: float = w * 360.0 / 420.0
	capy_holder.size = Vector2(w, h)
	# Капи ближе к низу сцены: сверху видно небо и окружение главы
	capy_holder.position = Vector2((a.x - w) * 0.5, a.y - h * 1.12)
	capy_holder.pivot_offset = Vector2(w * 0.5, h)
	capy_sprite.pivot_offset = Vector2(w * 0.5, h)
	# Мандарин на макушке: верх головы в спрайте — (210, 70) из 420x360
	var ms: float = w * 0.2
	capy_mandarin.size = Vector2(ms, ms)
	capy_mandarin.position = Vector2(w * 0.5 - ms * 0.5, h * (70.0 / 360.0) - ms * 0.82)
	steam.position = Vector2(a.x * 0.5, capy_holder.position.y + h * 0.85)
	_layout_chill(w, h)
	buff_label.position = Vector2.ZERO
	buff_label.size = Vector2(a.x, 30)
	thought_panel.size = Vector2(minf(a.x - 40.0, 460.0), 0)
	thought_panel.position = Vector2((a.x - thought_panel.size.x) * 0.5, maxf(34.0, capy_holder.position.y - 64.0))


func capy_rect() -> Rect2:
	return capy_holder.get_global_rect().grow(-capy_holder.size.x * 0.05)


func golden_rect() -> Rect2:
	return golden_btn.get_global_rect() if golden_btn.visible else Rect2()


# ---------- друзья рядом с Капи ----------

## Создать или убрать спрайты друзей по тому, кто есть в этом забеге (owned > 0).
func sync_friends() -> void:
	for i in D.HELPERS.size():
		var has: bool = int(Game.owned[i]) > 0
		if has and not chill_sprites.has(i):
			var slot: Array = CHILL_SLOTS[i % CHILL_SLOTS.size()]
			# Юнит = голова друга (покачивается) + вода перед ним (стоит на месте)
			var unit: Control = Control.new()
			unit.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var head: TextureRect = K.icon(friend_tex[D.HELPERS[i]["icon"]], 10)
			unit.add_child(head)
			var water: TextureRect = K.icon(tex_ripple, 10)
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
	pool_rect.visible = not chill_sprites.is_empty()
	layout()


func _layout_chill(w: float, h: float) -> void:
	var cx: float = capy_holder.position.x + w * 0.5
	var base_y: float = capy_holder.position.y + h * (312.0 / 360.0)   # линия воды у Капи
	pool_rect.position = Vector2(-4.0, base_y - h * 0.98)
	pool_rect.size = Vector2(size.x + 8.0, h * 1.27)
	# Новые спрайты (голова + плечи + лапки) крупнее старых круглых голов
	var fs: float = w * 0.23
	for i in chill_sprites:
		var slot: Array = CHILL_SLOTS[int(i) % CHILL_SLOTS.size()]
		var unit: Control = chill_sprites[i]
		var s: float = fs * (0.85 if slot[2] else 1.0)
		var head: TextureRect = unit.get_meta("head")
		var water: TextureRect = unit.get_meta("water")
		unit.size = Vector2(s, s)
		var pos: Vector2 = Vector2(cx + float(slot[0]) * w - s * 0.5, base_y + float(slot[1]) * h - s)
		pos.x = clampf(pos.x, 0.0, size.x - s)   # не вылезать за края
		unit.position = pos
		head.size = Vector2(s, s)
		head.pivot_offset = Vector2(s * 0.5, s)
		# Вода закрывает нижнюю четверть головы и чуть шире неё
		water.size = Vector2(s * 1.3, s * 0.42)
		water.position = Vector2(-s * 0.15, s * 0.66)
	# Кто ниже на экране — тот ближе: рисуем поверх
	for c in [chill_front, chill_back]:
		var kids: Array = c.get_children()
		kids.sort_custom(func(p, q): return p.position.y < q.position.y)
		for k in kids.size():
			c.move_child(kids[k], k)


# ---------- кадр ----------

func _process(delta: float) -> void:
	_t += delta
	capy_sprite.scale = Vector2(1.0 + 0.01 * sin(_t * 2.0), 1.0 + 0.02 * sin(_t * 2.0 + 0.6))
	# Друзья покачиваются в воде, каждый в своём ритме; вода стоит на месте
	for i in chill_sprites:
		var head: TextureRect = chill_sprites[i].get_meta("head")
		head.position.y = 2.5 * sin(_t * 1.7 + float(i) * 1.3)
		head.rotation = 0.05 * sin(_t * 1.1 + float(i))
	if tap_face_timer > 0.0:
		tap_face_timer -= delta
		if tap_face_timer <= 0.0:
			capy_sprite.texture = tex_capy
	_process_golden(delta)
	thought_timer -= delta
	if thought_timer <= 0.0:
		thought_timer = randf_range(THOUGHT_MIN, THOUGHT_MAX)
		if not paused:
			show_thought()


## Подписи, которые зависят от состояния игры (вызывается ~10 раз в секунду).
func refresh() -> void:
	capy_mandarin.visible = Game.mandarins > 0
	var b: String = ""
	if Game.frenzy_time > 0.0:
		b += Game.txt("buff_frenzy") % int(ceil(Game.frenzy_time)) + "   "
	if Game.tap_frenzy_time > 0.0:
		b += Game.txt("buff_tap") % int(ceil(Game.tap_frenzy_time))
	if b != _last_buff:
		_last_buff = b
		buff_label.text = b


func set_chapter(chapter: int) -> void:
	steam.emitting = chapter >= 1


# ---------- тап ----------

func tap_feedback(global_pos: Vector2, value: float) -> void:
	# Один твин на Капи: при быстрых нажатиях десятки твинов дёргали бы один scale
	if _tap_tween and _tap_tween.is_valid():
		_tap_tween.kill()
	_tap_tween = create_tween()
	_tap_tween.tween_property(capy_holder, "scale", Vector2(1.06, 0.9), 0.05)
	_tap_tween.tween_property(capy_holder, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# Капи радуется: открывает глаза на мгновение
	capy_sprite.texture = tex_capy_tap
	tap_face_timer = TAP_FACE_TIME
	if float_count < MAX_FLOATS:
		_float_text("+" + D.fmt(value), global_pos - global_position)


func _float_text(t: String, local_pos: Vector2) -> void:
	float_count += 1
	var l: Label = K.outlined(t, 34, K.C_BROWN)
	l.size = Vector2(240, 44)
	l.position = local_pos - Vector2(120 + randf_range(-20, 20), 40)
	add_child(l)
	var tw: Tween = create_tween().set_parallel(true)
	tw.tween_property(l, "position:y", l.position.y - 150.0, 0.9).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(l, "modulate:a", 0.0, 0.9).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(_float_done.bind(l))


func _float_done(l: Label) -> void:
	l.queue_free()
	float_count -= 1


# ---------- мысли Капи ----------

## Все мысли, которые подходят сейчас: общие, по главе и про друзей в источнике.
func thought_pool() -> Array:
	var pool: Array = D.CAPY_THOUGHTS.duplicate()
	pool.append_array(D.CAPY_THOUGHTS_MEME)
	for t in D.CAPY_THOUGHTS_BOOK2:
		if Game.chapter >= int(t["ch"]):
			pool.append(t)
	for t in D.CAPY_THOUGHTS_FRIENDS:
		var idx: int = _helper_index(str(t["f"]))
		if idx >= 0 and int(Game.owned[idx]) > 0:
			pool.append(t)
	return pool


func _helper_index(icon: String) -> int:
	for i in D.HELPERS.size():
		if D.HELPERS[i]["icon"] == icon:
			return i
	return -1


## Случайная мысль над головой Капи. Недавние не повторяются; облачко живёт
## тем дольше, чем длиннее фраза (раньше 5 с — длинные не успевали прочитать).
func show_thought() -> void:
	var pool: Array = thought_pool()
	var fresh: Array = pool.filter(func(t): return not _recent_thoughts.has(t["en"]))
	if fresh.is_empty():
		_recent_thoughts.clear()
		fresh = pool
	if fresh.is_empty():
		return
	var t: Dictionary = fresh[randi() % fresh.size()]
	_recent_thoughts.append(t["en"])
	if _recent_thoughts.size() > THOUGHT_HISTORY:
		_recent_thoughts.pop_front()
	var text: String = str(t[Game.lang])
	thought_label.text = text
	if _thought_tween and _thought_tween.is_valid():
		_thought_tween.kill()
	_thought_tween = create_tween()
	_thought_tween.tween_property(thought_panel, "modulate:a", 1.0, 0.4)
	_thought_tween.tween_interval(thought_duration(text))
	_thought_tween.tween_property(thought_panel, "modulate:a", 0.0, 0.8)


static func thought_duration(text: String) -> float:
	return clampf(5.0 + float(text.length()) / 12.0, 8.0, 14.0)


# ---------- золотой мандарин ----------

func _process_golden(delta: float) -> void:
	if golden_btn.visible:
		golden_life -= delta
		golden_btn.rotation = 0.15 * sin(_t * 4.0)
		if golden_life <= 0.0:
			golden_btn.visible = false
			golden_timer = Game.golden_interval()
		elif golden_life < 3.0:
			golden_btn.modulate.a = 0.5 + 0.5 * absf(sin(_t * 8.0))
	else:
		golden_timer -= delta
		if golden_timer <= 0.0 and not paused:
			spawn_golden()


func spawn_golden() -> void:
	golden_btn.position = Vector2(randf_range(10.0, maxf(20.0, size.x - 130.0)), randf_range(30.0, maxf(40.0, size.y - 130.0)))
	golden_btn.modulate.a = 1.0
	golden_btn.visible = true
	golden_btn.scale = Vector2(0.2, 0.2)
	create_tween().tween_property(golden_btn, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	golden_life = GOLDEN_LIFE


func _on_golden() -> void:
	golden_btn.visible = false
	golden_timer = Game.golden_interval()
	golden_pressed.emit()
