extends RefCounted
## Общие цвета, стили и маленькие фабрики интерфейса. Всё статическое:
## любой модуль UI пишет K.label(...), K.style_button(...) и т.д.

const C_BROWN: Color = Color("5b3a22")
const C_BROWN_SOFT: Color = Color(0.36, 0.23, 0.13, 0.75)
const C_ORANGE: Color = Color("ff9f43")
const C_MANDARIN: Color = Color("d9772b")
const C_GREEN: Color = Color("5fb36a")
const C_BLUE: Color = Color("5aa9e6")
const C_RED: Color = Color("c76b6b")
const C_PANEL: Color = Color(1.0, 0.97, 0.9, 0.93)
const C_POPUP: Color = Color(1.0, 0.97, 0.9)
const C_ROW: Color = Color(1.0, 0.93, 0.8, 1.0)
const C_TAB: Color = Color("c58b5a")
const C_TAB_ON: Color = Color("8a5530")
const C_DIM: Color = Color(0.1, 0.05, 0.0, 0.5)

## Стили кэшируются: они не меняются после создания, поэтому их можно делить между узлами.
static var _cache: Dictionary = {}


static func sb(color: Color, radius: int = 18, pad: int = 12) -> StyleBoxFlat:
	var key: String = "%s|%d|%d" % [color.to_html(), radius, pad]
	if _cache.has(key):
		return _cache[key]
	var s: StyleBoxFlat = StyleBoxFlat.new()
	_cache[key] = s
	s.bg_color = color
	s.set_corner_radius_all(radius)
	s.set_content_margin_all(pad)
	s.shadow_color = Color(0, 0, 0, 0.12)
	s.shadow_size = 4
	s.shadow_offset = Vector2(0, 2)
	return s


## Плоский стиль без тени (полоски прогресса, ползунки).
static func flat(color: Color, radius: int = 6) -> StyleBoxFlat:
	var s: StyleBoxFlat = sb(color, radius, 0).duplicate()
	s.shadow_size = 0
	return s


static func style_button(b: Button, color: Color, font_size: int = 22) -> void:
	b.add_theme_stylebox_override("normal", sb(color, 16, 10))
	b.add_theme_stylebox_override("hover", sb(color.lightened(0.08), 16, 10))
	b.add_theme_stylebox_override("pressed", sb(color.darkened(0.15), 16, 10))
	b.add_theme_stylebox_override("disabled", sb(Color(0.78, 0.73, 0.67), 16, 10))
	if not _cache.has("empty"):
		_cache["empty"] = StyleBoxEmpty.new()
	b.add_theme_stylebox_override("focus", _cache["empty"])
	for k in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		b.add_theme_color_override(k, Color.WHITE)
	b.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0.85))
	b.add_theme_font_size_override("font_size", font_size)
	b.mouse_filter = Control.MOUSE_FILTER_PASS
	b.focus_mode = Control.FOCUS_NONE


static func button(text: String, color: Color, font_size: int, min_size: Vector2, on_press: Callable) -> Button:
	var b: Button = Button.new()
	b.text = text
	b.custom_minimum_size = min_size
	style_button(b, color, font_size)
	b.pressed.connect(on_press)
	return b


static func label(text: String, fs: int, color: Color = C_BROWN, center: bool = false, wrap: bool = false) -> Label:
	var l: Label = Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", color)
	if center:
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


## Белый текст с коричневой обводкой (всплывающие числа, тосты, баффы).
static func outlined(text: String, fs: int, outline: Color = Color(0.55, 0.3, 0.05)) -> Label:
	var l: Label = label(text, fs, Color.WHITE, true)
	l.add_theme_constant_override("outline_size", 8 if fs < 26 else 10)
	l.add_theme_color_override("font_outline_color", outline)
	return l


static func icon(tex: Texture2D, px: int) -> TextureRect:
	var t: TextureRect = TextureRect.new()
	t.texture = tex
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.custom_minimum_size = Vector2(px, px)
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t


static func row_panel() -> PanelContainer:
	var p: PanelContainer = PanelContainer.new()
	p.add_theme_stylebox_override("panel", sb(C_ROW, 16, 10))
	p.mouse_filter = Control.MOUSE_FILTER_PASS
	return p


static func hbox(sep: int = 12) -> HBoxContainer:
	var hb: HBoxContainer = HBoxContainer.new()
	hb.add_theme_constant_override("separation", sep)
	return hb


static func vbox(sep: int = 4, centered: bool = false) -> VBoxContainer:
	var vb: VBoxContainer = VBoxContainer.new()
	vb.add_theme_constant_override("separation", sep)
	if centered:
		vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vb.alignment = BoxContainer.ALIGNMENT_CENTER
	return vb


## Картинка из assets: сначала .png/.webp/.jpg с тем же именем, потом .svg.
static func tex(file: String) -> Texture2D:
	for ext in [".png", ".webp", ".jpg", ".svg"]:
		var path: String = "res://assets/" + file + ext
		if ResourceLoader.exists(path):
			return load(path)
	return null
