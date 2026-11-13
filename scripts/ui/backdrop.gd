extends Control
## Окружение за Капи: небо, горы, холмы, деревья и погода. У каждой главы своё место;
## при смене главы новое место плавно проявляется поверх старого.

const K = preload("res://scripts/ui/ui_kit.gd")

## Места по индексу главы (их столько же, сколько глав).
## sky: [верх, низ]; mtn/hill: цвет гор и холмов; snow: снежные шапки на горах;
## orb: "sun" / "moon" / ""; stars: звёзды; clouds: сколько облаков;
## props: [картинка из assets/env, x (доля ширины), высота (доля высоты сцены), зеркально];
## weather: snow / petals / leaves / fireflies / sparkles / "".
const PLACES: Array = [
	# --- Книга 1: Вечный Холод ---
	{"sky": ["#9fb8d6", "#dfe9f5"], "mtn": "#b7c6dc", "snow": true, "hill": "#eef4fb", "orb": "", "stars": false, "clouds": 2,
		"props": [["pine_snow", 0.06, 0.62, false], ["pine_snow", 0.17, 0.44, true], ["pine_snow", 0.93, 0.58, true], ["rocks", 0.84, 0.16, false]], "weather": "snow"},
	{"sky": ["#a9c6e6", "#e8f0f8"], "mtn": "#b9cade", "snow": true, "hill": "#e9f2f4", "orb": "sun", "stars": false, "clouds": 2,
		"props": [["pine_snow", 0.06, 0.6, false], ["reeds", 0.18, 0.24, false], ["pine_snow", 0.94, 0.56, true], ["reeds", 0.83, 0.22, true]], "weather": "snow_light"},
	{"sky": ["#a8d8e8", "#e6f5ec"], "mtn": "#a9c9bd", "snow": true, "hill": "#bfe3a8", "orb": "sun", "stars": false, "clouds": 2,
		"props": [["bamboo", 0.05, 0.72, false], ["bamboo", 0.17, 0.56, true], ["bamboo", 0.95, 0.7, true], ["bamboo", 0.84, 0.5, false]], "weather": "leaves_green"},
	{"sky": ["#8fd0f0", "#e4f6f7"], "mtn": "#9fc4c9", "snow": false, "hill": "#a9dc8e", "orb": "sun", "stars": false, "clouds": 3,
		"props": [["tree_summer", 0.07, 0.56, false], ["flowers", 0.2, 0.14, false], ["reeds", 0.86, 0.24, true], ["tree_summer", 0.95, 0.5, true]], "weather": "petals_white"},
	{"sky": ["#b9b5e0", "#f2e9f2"], "mtn": "#a6a8c8", "snow": true, "hill": "#c9d8c4", "orb": "sun", "stars": false, "clouds": 3,
		"props": [["pine", 0.05, 0.64, false], ["lantern", 0.17, 0.34, false], ["rocks", 0.2, 0.14, true], ["pine", 0.95, 0.6, true], ["lantern", 0.83, 0.34, false]], "weather": "snow_light"},
	{"sky": ["#f2c4dc", "#fbeef3"], "mtn": "#d9bcd6", "snow": false, "hill": "#e7d3ea", "orb": "", "stars": false, "clouds": 5,
		"props": [["tree_sakura", 0.07, 0.56, false], ["flowers", 0.19, 0.14, true], ["tree_sakura", 0.94, 0.52, true]], "weather": "petals"},
	{"sky": ["#b8c6f2", "#eef0fc"], "mtn": "#c2c8e8", "snow": true, "hill": "#dde3f5", "orb": "moon", "stars": false, "clouds": 5,
		"props": [["pine_snow", 0.06, 0.56, false], ["pine_snow", 0.94, 0.52, true]], "weather": "sparkles"},
	{"sky": ["#2c3a6e", "#6f7fb8"], "mtn": "#4a5690", "snow": true, "hill": "#5f6fa6", "orb": "moon", "stars": true, "clouds": 1,
		"props": [["pine", 0.06, 0.58, false], ["lantern", 0.18, 0.34, false], ["lantern", 0.82, 0.34, true], ["pine", 0.94, 0.54, true]], "weather": "fireflies"},
	# --- Книга 2: Спящая Весна ---
	{"sky": ["#b3c8e4", "#eef3f8"], "mtn": "#aab9cf", "snow": true, "hill": "#d4e2da", "orb": "sun", "stars": false, "clouds": 2,
		"props": [["tree_bare", 0.07, 0.52, false], ["rocks", 0.2, 0.14, false], ["pine_snow", 0.94, 0.56, true]], "weather": "snow_light"},
	{"sky": ["#9ccbe8", "#e9f5f6"], "mtn": "#a6bfd4", "snow": true, "hill": "#c4e2d2", "orb": "sun", "stars": false, "clouds": 2,
		"props": [["pine_snow", 0.06, 0.58, false], ["reeds", 0.18, 0.22, false], ["flowers", 0.82, 0.14, true], ["tree_summer", 0.95, 0.5, true]], "weather": "snow_light"},
	{"sky": ["#f5d9b8", "#fbf0e6"], "mtn": "#d6c3b0", "snow": false, "hill": "#cfdcab", "orb": "sun", "stars": false, "clouds": 3,
		"props": [["tree_sakura", 0.07, 0.54, false], ["pine_snow", 0.19, 0.4, true], ["tree_maple", 0.94, 0.52, true]], "weather": "leaves_up"},
	{"sky": ["#9a8fcf", "#e8d6ea"], "mtn": "#a897c8", "snow": false, "hill": "#b9c9a6", "orb": "moon", "stars": true, "clouds": 2,
		"props": [["flowers", 0.1, 0.16, false], ["tree_summer", 0.05, 0.46, false], ["flowers", 0.88, 0.16, true]], "weather": "fireflies"},
	{"sky": ["#f4c79a", "#fbe9d5"], "mtn": "#c9a98a", "snow": false, "hill": "#b5b27d", "orb": "sun", "stars": false, "clouds": 2,
		"props": [["reeds", 0.08, 0.26, false], ["rocks", 0.2, 0.15, false], ["reeds", 0.9, 0.26, true], ["rocks", 0.8, 0.13, true]], "weather": ""},
	{"sky": ["#b9e3c8", "#f2f8e8"], "mtn": "#a7cdb5", "snow": false, "hill": "#a6d891", "orb": "sun", "stars": false, "clouds": 3,
		"props": [["tree_sakura", 0.06, 0.56, false], ["tree_summer", 0.19, 0.42, true], ["tree_sakura", 0.94, 0.54, true], ["flowers", 0.82, 0.14, false]], "weather": "petals"},
	{"sky": ["#1f2756", "#4b4f8e"], "mtn": "#353d78", "snow": false, "hill": "#45508c", "orb": "moon", "stars": true, "clouds": 0,
		"props": [["tree_bare", 0.07, 0.5, false], ["lantern", 0.2, 0.32, false], ["tree_bare", 0.93, 0.48, true]], "weather": "fireflies_many"},
	{"sky": ["#ffd6e6", "#fff6ee"], "mtn": "#e6c7d6", "snow": false, "hill": "#bfe6a0", "orb": "sun", "stars": false, "clouds": 3,
		"props": [["tree_sakura", 0.06, 0.6, false], ["flowers", 0.2, 0.15, false], ["tree_sakura", 0.95, 0.56, true], ["flowers", 0.81, 0.15, true]], "weather": "petals_many"},
	# --- Книга 3: Лето и Осень ---
	{"sky": ["#6fc6f2", "#e2f7fb"], "mtn": "#8cc0cf", "snow": false, "hill": "#9ed47e", "orb": "sun_big", "stars": false, "clouds": 2,
		"props": [["sunflower", 0.08, 0.4, false], ["sunflower", 0.17, 0.32, true], ["tree_summer", 0.94, 0.54, true]], "weather": "sparkles"},
	{"sky": ["#86d2ec", "#eef9f2"], "mtn": "#93c3c1", "snow": false, "hill": "#8fcf86", "orb": "sun_big", "stars": false, "clouds": 2,
		"props": [["tree_willow", 0.07, 0.56, false], ["reeds", 0.2, 0.24, false], ["reeds", 0.85, 0.24, true], ["tree_willow", 0.95, 0.52, true]], "weather": "fireflies"},
	{"sky": ["#9fdcf0", "#f0faf6"], "mtn": "#a2cbc6", "snow": false, "hill": "#9ad493", "orb": "sun", "stars": false, "clouds": 3,
		"props": [["tree_willow", 0.06, 0.6, false], ["flowers", 0.2, 0.13, false], ["rocks", 0.84, 0.14, true], ["tree_willow", 0.95, 0.54, true]], "weather": ""},
	{"sky": ["#a9d9ef", "#fbf3d6"], "mtn": "#b9c7b0", "snow": false, "hill": "#d5d77f", "orb": "sun_big", "stars": false, "clouds": 2,
		"props": [["sunflower", 0.07, 0.42, false], ["sunflower", 0.16, 0.34, false], ["sunflower", 0.85, 0.36, true], ["sunflower", 0.94, 0.42, true]], "weather": "sparkles"},
	{"sky": ["#f6a77f", "#ffe1b8"], "mtn": "#c98f86", "snow": false, "hill": "#b6b97a", "orb": "sun_low", "stars": false, "clouds": 3,
		"props": [["tree_summer", 0.06, 0.52, false], ["rocks", 0.2, 0.14, false], ["reeds", 0.86, 0.24, true]], "weather": ""},
	{"sky": ["#d98f6a", "#f7d3b0"], "mtn": "#b77e6a", "snow": false, "hill": "#c99a5f", "orb": "", "stars": false, "clouds": 2,
		"props": [["tree_maple", 0.07, 0.58, false], ["tree_maple", 0.19, 0.42, true], ["tree_maple", 0.94, 0.56, true]], "weather": "leaves"},
	{"sky": ["#f2b77e", "#fde8cc"], "mtn": "#cfa483", "snow": false, "hill": "#b9b46e", "orb": "sun_low", "stars": false, "clouds": 2,
		"props": [["tree_mandarin", 0.07, 0.56, false], ["lantern", 0.2, 0.34, false], ["tree_mandarin", 0.94, 0.54, true], ["lantern", 0.81, 0.34, true]], "weather": "leaves"},
	{"sky": ["#5a4f9a", "#f0b9a8"], "mtn": "#7d6aa6", "snow": true, "hill": "#9cba8c", "orb": "moon", "stars": true, "clouds": 2,
		"props": [["tree_sakura", 0.06, 0.54, false], ["sunflower", 0.18, 0.34, false], ["tree_maple", 0.94, 0.54, true], ["pine_snow", 0.82, 0.4, true]], "weather": "mix"},
]

## Деревья выше, чем в таблице: нижнюю часть всё равно закрывает бассейн.
const PROP_SCALE: float = 1.3

var stage: Rect2 = Rect2(0, 300, 720, 400)   # где на экране сцена с Капи (задаёт main)
var place: int = -1
var layer: Control = null
var _t: float = 0.0
var _star_pts: Array = []
var _textures: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 7
	for i in 46:
		_star_pts.append(Vector3(rng.randf(), rng.randf() * 0.55, rng.randf_range(1.0, 2.6)))
	resized.connect(_rebuild_now)


func place_for(chapter: int) -> int:
	return clampi(chapter, 0, PLACES.size() - 1)


## Показать место главы. animated = false — мгновенно (старт игры, сброс).
func show_chapter(chapter: int, animated: bool) -> void:
	var p: int = place_for(chapter)
	if p == place and layer != null:
		return
	place = p
	var old: Control = layer
	layer = _build(PLACES[p])
	add_child(layer)
	if old == null or not animated:
		if old:
			old.queue_free()
		return
	layer.modulate.a = 0.0
	var tw: Tween = create_tween()
	tw.tween_property(layer, "modulate:a", 1.0, 1.6)
	tw.tween_callback(old.queue_free)


## Сцена с Капи переехала (поворот, другой экран): пересобрать без анимации.
func set_stage(r: Rect2) -> void:
	if r.is_equal_approx(stage):
		return
	stage = r
	_rebuild_now()


func _rebuild_now() -> void:
	if place < 0:
		return
	var p: int = place
	place = -1
	if layer:
		layer.queue_free()
		layer = null
	show_chapter(p, false)


func _process(delta: float) -> void:
	_t += delta
	if layer == null:
		return
	# Облака медленно плывут, звёзды мерцают
	for c in (layer.get_meta("clouds") if layer.has_meta("clouds") else []):
		var cl: TextureRect = c
		cl.position.x += delta * float(cl.get_meta("speed"))
		if cl.position.x > size.x + 20.0:
			cl.position.x = -cl.size.x - 20.0
	if layer.has_meta("stars"):
		(layer.get_meta("stars") as Control).modulate.a = 0.75 + 0.25 * sin(_t * 1.3)


# ---------- сборка места ----------

func _tex(name: String) -> Texture2D:
	if not _textures.has(name):
		_textures[name] = K.tex("env/" + name)
	return _textures[name]


func _rect(tex: Texture2D, stretch: int = TextureRect.STRETCH_SCALE) -> TextureRect:
	var t: TextureRect = TextureRect.new()
	t.texture = tex
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = stretch
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t


func _build(p: Dictionary) -> Control:
	var root: Control = Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.size = size
	var W: float = maxf(size.x, 1.0)
	var H: float = maxf(size.y, 1.0)
	var sh: float = maxf(stage.size.y, 200.0)
	var horizon: float = stage.position.y + sh * 0.32

	# Небо: вертикальный градиент на весь экран
	var g: Gradient = _grad([0.0, clampf(horizon / H, 0.2, 1.0)], [Color(p["sky"][0]), Color(p["sky"][1])])
	var gt: GradientTexture2D = GradientTexture2D.new()
	gt.gradient = g
	gt.width = 4
	gt.height = 256
	gt.fill_from = Vector2(0, 0)
	gt.fill_to = Vector2(0, 1)
	var sky: TextureRect = _rect(gt)
	sky.size = Vector2(W, H)
	root.add_child(sky)

	if p["stars"]:
		var st: Control = Control.new()
		st.mouse_filter = Control.MOUSE_FILTER_IGNORE
		st.size = Vector2(W, horizon)
		st.draw.connect(_draw_stars.bind(st))
		root.add_child(st)
		root.set_meta("stars", st)

	var orb: String = p["orb"]
	if orb != "":
		var big: bool = orb == "sun_big"
		var o: TextureRect = _rect(_tex("moon" if orb == "moon" else "sun"), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
		var os: float = sh * (0.36 if big else 0.26)
		o.size = Vector2(os, os)
		# Над бассейном, но ниже верхней панели; закатное солнце — у самого горизонта
		var oy: float = horizon - sh * 0.02 if orb == "sun_low" else stage.position.y + os * 0.32
		o.position = Vector2(W * 0.78 - os * 0.5, oy - os * 0.5)
		root.add_child(o)

	var clouds: Array = []
	for i in int(p["clouds"]):
		var c: TextureRect = _rect(_tex("cloud"), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
		var cw: float = sh * randf_range(0.32, 0.5)
		c.size = Vector2(cw, cw * 100.0 / 240.0)
		c.position = Vector2(randf_range(-cw * 0.3, W), stage.position.y - sh * 0.1 + randf_range(0.0, sh * 0.3))
		c.modulate = Color(1, 1, 1, 0.8)
		c.set_meta("speed", randf_range(4.0, 10.0))
		root.add_child(c)
		clouds.append(c)
	root.set_meta("clouds", clouds)

	# Горы и холмы (серые картинки, цвет через modulate)
	var mtn_h: float = sh * 0.5
	var mtn: TextureRect = _rect(_tex("mountains"))
	mtn.size = Vector2(W, mtn_h)
	mtn.position = Vector2(0, horizon - mtn_h + sh * 0.08)
	mtn.modulate = Color(p["mtn"])
	root.add_child(mtn)
	if p["snow"]:
		var caps: TextureRect = _rect(_tex("snowcaps"))
		caps.size = mtn.size
		caps.position = mtn.position
		root.add_child(caps)
	var hill: TextureRect = _rect(_tex("hills"))
	hill.position = Vector2(0, horizon - sh * 0.06)
	hill.size = Vector2(W, maxf(H - hill.position.y, sh))
	hill.modulate = Color(p["hill"])
	root.add_child(hill)

	# Деревья и прочее стоят на холмах по краям сцены
	var ground: float = horizon + sh * 0.3
	for pr in p["props"]:
		var t: Texture2D = _tex(pr[0])
		if t == null:
			continue
		var ph: float = sh * float(pr[2]) * PROP_SCALE
		var pw: float = ph * float(t.get_width()) / maxf(1.0, float(t.get_height()))
		var r: TextureRect = _rect(t, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
		r.size = Vector2(pw, ph)
		r.position = Vector2(W * float(pr[1]) - pw * 0.5, ground - ph)
		r.flip_h = bool(pr[3])
		root.add_child(r)

	var w: String = p["weather"]
	if w != "":
		root.add_child(_weather(w, W, sh))
	return root


func _draw_stars(c: Control) -> void:
	for s in _star_pts:
		var v: Vector3 = s
		c.draw_circle(Vector2(v.x * c.size.x, v.y * c.size.y / 0.55), v.z, Color(1, 1, 0.9, 0.85))


# ---------- погода ----------

func _weather(kind: String, W: float, sh: float) -> CPUParticles2D:
	var p: CPUParticles2D = CPUParticles2D.new()
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.position = Vector2(W * 0.5, stage.position.y - sh * 0.6)
	p.emission_rect_extents = Vector2(W * 0.6, 10)
	p.direction = Vector2(0.2, 1)
	p.spread = 20.0
	p.gravity = Vector2(0, 8)
	match kind:
		"snow", "snow_light":
			p.texture = K.tex("dot")
			p.amount = 70 if kind == "snow" else 30
			p.lifetime = 14.0
			p.initial_velocity_min = 40.0
			p.initial_velocity_max = 80.0
			p.scale_amount_min = 0.12
			p.scale_amount_max = 0.3
			p.color = Color(1, 1, 1, 0.85)
		"petals", "petals_many", "petals_white":
			p.texture = _tex("petal")
			p.amount = 60 if kind == "petals_many" else 28
			p.lifetime = 16.0
			p.initial_velocity_min = 25.0
			p.initial_velocity_max = 55.0
			p.angular_velocity_min = -90.0
			p.angular_velocity_max = 90.0
			p.angle_min = 0.0
			p.angle_max = 360.0
			p.scale_amount_min = 0.5
			p.scale_amount_max = 0.9
			p.color = Color("ffe3ec") if kind == "petals_white" else Color("ffb3c9")
		"leaves", "leaves_green", "leaves_up", "mix":
			p.texture = _tex("leaf")
			p.amount = 26
			p.lifetime = 16.0
			p.initial_velocity_min = 25.0
			p.initial_velocity_max = 50.0
			p.angular_velocity_min = -120.0
			p.angular_velocity_max = 120.0
			p.angle_max = 360.0
			p.scale_amount_min = 0.5
			p.scale_amount_max = 0.85
			var pair: Array = [Color("f5a742"), Color("d9552a")]
			if kind == "leaves_green":
				pair = [Color("9fd77c"), Color("6aa64e")]
			elif kind == "mix":
				pair = [Color("ffb3c9"), Color("f08a3c")]
			p.color_initial_ramp = _grad([0.0, 1.0], pair)
			if kind == "leaves_up":
				# Пёстрый лес: листья падают... вверх
				p.position = Vector2(W * 0.5, stage.end.y + sh * 0.2)
				p.direction = Vector2(0.15, -1)
				p.gravity = Vector2(0, -8)
		"fireflies", "fireflies_many":
			p.texture = _tex("glow")
			p.amount = 40 if kind == "fireflies_many" else 18
			p.lifetime = 6.0
			p.position = stage.get_center() - Vector2(0, sh * 0.15)
			p.emission_rect_extents = Vector2(W * 0.5, sh * 0.45)
			p.direction = Vector2(0, -1)
			p.spread = 180.0
			p.gravity = Vector2.ZERO
			p.initial_velocity_min = 4.0
			p.initial_velocity_max = 14.0
			p.scale_amount_min = 0.35
			p.scale_amount_max = 0.7
			p.color_ramp = _grad([0.0, 0.3, 0.7, 1.0], [Color(1.0, 0.95, 0.5, 0.0), Color(1.0, 0.95, 0.5, 1.0), Color(0.85, 1.0, 0.5, 1.0), Color(0.85, 1.0, 0.5, 0.0)])
		"sparkles":
			p.texture = _tex("glow")
			p.amount = 16
			p.lifetime = 4.0
			p.position = stage.get_center() - Vector2(0, sh * 0.25)
			p.emission_rect_extents = Vector2(W * 0.5, sh * 0.35)
			p.direction = Vector2(0, -1)
			p.spread = 30.0
			p.gravity = Vector2(0, -6)
			p.initial_velocity_min = 5.0
			p.initial_velocity_max = 12.0
			p.scale_amount_min = 0.2
			p.scale_amount_max = 0.45
			p.color_ramp = _grad([0.0, 0.5, 1.0], [Color(1, 1, 1, 0.0), Color(1, 1, 1, 0.9), Color(1, 1, 1, 0.0)])
	p.preprocess = p.lifetime
	return p


func _grad(offsets: Array, colors: Array) -> Gradient:
	var g: Gradient = Gradient.new()
	g.offsets = PackedFloat32Array(offsets)
	g.colors = PackedColorArray(colors)
	return g
