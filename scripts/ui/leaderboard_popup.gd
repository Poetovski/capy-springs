extends RefCounted
## Окно онлайн-топа: список лучших по нажатиям, вход, регистрация и код из почты.
## Рисует содержимое в панели модуля popups; данные берёт у talo_client.

const D = preload("res://scripts/data.gd")
const K = preload("res://scripts/ui/ui_kit.gd")

var popups: Control
var online: Node
var _msg: Label
var _fields: Dictionary = {}


func _init(popups_node: Control, online_node: Node) -> void:
	popups = popups_node
	online = online_node


func _panel(replace: bool) -> VBoxContainer:
	var vb: VBoxContainer = popups.open_panel(replace)
	vb.custom_minimum_size = Vector2(minf(560.0, popups.size.x - 80.0), 0)
	_clear_html_fields()   # поля прошлой формы
	_fields = {}
	return vb


# ---------- топ ----------

func show_top(replace: bool = false) -> void:
	var vb: VBoxContainer = _panel(replace)
	vb.add_child(K.label(Game.txt("top_title"), 30, K.C_BROWN, true))
	if not online.enabled():
		vb.add_child(K.label(Game.txt("top_disabled"), 20, K.C_BROWN_SOFT, true, true))
		vb.add_child(K.button(Game.txt("close"), K.C_GREEN, 24, Vector2(0, 60), popups.close))
		return
	if online.waiting_for_code():
		show_code(true)
		return
	var account: Control
	if online.logged_in():
		account = K.label(Game.txt("top_you") % [online.nickname, D.fmt(float(Game.taps))], 19, K.C_MANDARIN, true, true)
	else:
		account = K.label(Game.txt("top_need_login"), 18, K.C_BROWN_SOFT, true, true)
	vb.add_child(account)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, minf(560.0, popups.size.y * 0.45))
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vb.add_child(scroll)
	var list: VBoxContainer = K.vbox(6)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	list.add_child(K.label(Game.txt("top_loading"), 19, K.C_BROWN_SOFT, true))
	var row: HBoxContainer = K.hbox(10)
	vb.add_child(row)
	if online.logged_in():
		_half(row, K.button(Game.txt("top_logout"), K.C_RED, 19, Vector2(0, 58), _on_logout))
	else:
		_half(row, K.button(Game.txt("top_login"), K.C_BLUE, 20, Vector2(0, 58), show_login.bind(true)))
		_half(row, K.button(Game.txt("top_register"), K.C_ORANGE, 20, Vector2(0, 58), show_register.bind(true)))
	vb.add_child(K.button(Game.txt("close"), K.C_GREEN, 24, Vector2(0, 60), popups.close))
	_fill_top(list)


func _fill_top(list: VBoxContainer) -> void:
	if online.logged_in():
		await online.submit_taps()
	var entries = await online.top(50)
	if not is_instance_valid(list):
		return   # окно закрыли, пока шёл запрос
	for c in list.get_children():
		c.queue_free()
	if entries is Dictionary:
		var key: String = "err_" + str(entries["error"])
		list.add_child(K.label(Game.txt(key if D.STRINGS.has(key) else "err_other"), 18, K.C_RED, true, true))
		return
	if entries.is_empty():
		list.add_child(K.label(Game.txt("top_empty"), 19, K.C_BROWN_SOFT, true))
		return
	for e in entries:
		var p: PanelContainer = PanelContainer.new()
		p.add_theme_stylebox_override("panel", K.sb(Color("ffe2b8") if e["me"] else K.C_ROW, 12, 8))
		var hb: HBoxContainer = K.hbox(10)
		p.add_child(hb)
		# Первые трое — золотой, серебряный и бронзовый номер
		var col: Color = [Color("d9a21b"), Color("8f9aa6"), Color("b0703a")][e["pos"] - 1] if e["pos"] <= 3 else K.C_BROWN_SOFT
		var pl: Label = K.label("%d." % e["pos"], 22 if e["pos"] <= 3 else 20, col)
		pl.custom_minimum_size = Vector2(52, 0)
		hb.add_child(pl)
		var nl: Label = K.label(str(e["name"]), 20, K.C_BROWN)
		nl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nl.clip_text = true
		hb.add_child(nl)
		hb.add_child(K.label(D.fmt(float(e["score"])), 20, K.C_MANDARIN))
		list.add_child(p)


func _half(row: HBoxContainer, b: Button) -> void:
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(b)


# ---------- формы ----------

func _field(vb: VBoxContainer, key: String, hint: String, secret: bool = false) -> void:
	var e: LineEdit = LineEdit.new()
	e.placeholder_text = hint
	e.secret = secret
	e.custom_minimum_size = Vector2(0, 54)
	e.add_theme_font_size_override("font_size", 20)
	e.add_theme_stylebox_override("normal", K.sb(Color.WHITE, 12, 10))
	e.add_theme_stylebox_override("focus", K.sb(Color.WHITE, 12, 10))
	e.add_theme_color_override("font_color", K.C_BROWN)
	e.add_theme_color_override("font_placeholder_color", K.C_BROWN_SOFT)
	if use_html_fields():
		# Браузер на телефоне: Godot сам не открывает экранную клавиатуру. Поверх поля
		# кладём настоящее HTML-поле: палец попадает прямо в него, и клавиатура открывается.
		e.placeholder_text = ""
		e.focus_mode = Control.FOCUS_NONE
		e.mouse_filter = Control.MOUSE_FILTER_IGNORE
		e.set_meta("html_type", "password" if secret else ("email" if key == "email" else "text"))
		e.set_meta("html_hint", hint)
		_ensure_html_timer()
	vb.add_child(e)
	_fields[key] = e


## Веб-версия на сенсорном экране (телефон, планшет). Кроме Godot спрашиваем и сам браузер:
## внутри окошка itch.io Godot не всегда видит сенсор.
static func use_html_fields() -> bool:
	if not OS.has_feature("web"):
		return false
	if DisplayServer.is_touchscreen_available():
		return true
	var js = JavaScriptBridge.eval("(navigator.maxTouchPoints > 0) || ('ontouchstart' in window) || (window.matchMedia && matchMedia('(pointer: coarse)').matches)", true)
	return js == true


const HTML_JS: String = """
window.capyField = function(id, type, ph, x, y, w, h, winW, fs) {
	var c = document.getElementById("canvas") || document.querySelector("canvas");
	var r = c.getBoundingClientRect(); var k = r.width / winW;
	var el = document.getElementById(id);
	if (!el) {
		el = document.createElement("input"); el.id = id; el.className = "capyf"; el.type = type;
		el.placeholder = ph; el.maxLength = 128; el.spellcheck = false;
		el.setAttribute("autocapitalize", "off"); el.setAttribute("autocorrect", "off");
		el.autocomplete = type == "password" ? "new-password" : (type == "email" ? "email" : "off");
		el.style.cssText = "position:fixed;z-index:10;box-sizing:border-box;border:none;outline:none;border-radius:8px;background:#fff;color:#5b3a22;padding:0 12px;margin:0;font-family:Nunito,Arial,sans-serif;";
		el.addEventListener("keydown", function(ev) { ev.stopPropagation(); if (ev.key == "Enter") el.blur(); });
		document.body.appendChild(el);
	}
	el.style.left = (r.left + x * k) + "px"; el.style.top = (r.top + y * k) + "px";
	el.style.width = (w * k) + "px"; el.style.height = (h * k) + "px";
	el.style.fontSize = Math.max(16, fs * k) + "px";
};
window.capyFieldsClear = function() { document.querySelectorAll(".capyf").forEach(function(e) { e.remove(); }); };
"""

var _html_timer: Timer


func _ensure_html_timer() -> void:
	if _html_timer != null and is_instance_valid(_html_timer):
		return
	JavaScriptBridge.eval(HTML_JS, true)
	_html_timer = Timer.new()
	_html_timer.wait_time = 0.1
	_html_timer.timeout.connect(_sync_html_fields)
	popups.add_child(_html_timer)
	_html_timer.start()


## Каждые 0,1 с ставим HTML-поля точно поверх полей окна (окно появляется с анимацией).
## Окно закрыли — поля убираем.
func _sync_html_fields() -> void:
	var alive: bool = false
	var win: float = float(DisplayServer.window_get_size().x)
	for key in _fields:
		var e: LineEdit = _fields[key]
		if not is_instance_valid(e) or not e.is_visible_in_tree() or not e.has_meta("html_type"):
			continue
		alive = true
		var xf: Transform2D = e.get_viewport().get_screen_transform() * e.get_global_transform_with_canvas()
		var sz: Vector2 = e.size * xf.get_scale()
		JavaScriptBridge.eval("capyField(%s,%s,%s,%f,%f,%f,%f,%f,%f)" % [JSON.stringify("capyf_" + key), JSON.stringify(e.get_meta("html_type")),
			JSON.stringify(e.get_meta("html_hint")), xf.origin.x, xf.origin.y, sz.x, sz.y, win, 20.0 * xf.get_scale().x])
	if not alive:
		_clear_html_fields()


func _clear_html_fields() -> void:
	if _html_timer != null and is_instance_valid(_html_timer):
		_html_timer.queue_free()
	_html_timer = null
	if use_html_fields():
		JavaScriptBridge.eval("if (window.capyFieldsClear) capyFieldsClear();", true)


func _form(title: String, replace: bool) -> VBoxContainer:
	var vb: VBoxContainer = _panel(replace)
	vb.add_child(K.label(title, 28, K.C_BROWN, true))
	return vb


func _finish_form(vb: VBoxContainer, action: String, on_submit: Callable) -> void:
	_msg = K.label("", 17, K.C_RED, true, true)
	vb.add_child(_msg)
	var row: HBoxContainer = K.hbox(10)
	vb.add_child(row)
	_half(row, K.button(Game.txt("top_back"), K.C_TAB, 20, Vector2(0, 58), show_top.bind(true)))
	_half(row, K.button(action, K.C_GREEN, 20, Vector2(0, 58), on_submit))


func show_login(replace: bool = true) -> void:
	var vb: VBoxContainer = _form(Game.txt("top_login"), replace)
	_field(vb, "nick", Game.txt("top_nick"))
	_field(vb, "pass", Game.txt("top_password"), true)
	_finish_form(vb, Game.txt("top_login"), _on_login)


func show_register(replace: bool = true) -> void:
	var vb: VBoxContainer = _form(Game.txt("top_register"), replace)
	_field(vb, "nick", Game.txt("top_nick"))
	_field(vb, "email", Game.txt("top_email"))
	_field(vb, "pass", Game.txt("top_password"), true)
	vb.add_child(K.label(Game.txt("top_pass_hint"), 15, K.C_BROWN_SOFT, true, true))
	_finish_form(vb, Game.txt("top_register"), _on_register)


func show_code(replace: bool = true) -> void:
	var vb: VBoxContainer = _form(Game.txt("top_code"), replace)
	vb.add_child(K.label(Game.txt("top_code_sent"), 18, K.C_BROWN_SOFT, true, true))
	_field(vb, "code", Game.txt("top_code"))
	_finish_form(vb, Game.txt("top_send"), _on_code)


func _val(key: String) -> String:
	if not _fields.has(key):
		return ""
	var e: LineEdit = _fields[key]
	if is_instance_valid(e) and e.has_meta("html_type"):
		var v = JavaScriptBridge.eval("(function(){var el=document.getElementById(%s);return el?el.value:\"\";})()" % JSON.stringify("capyf_" + key), true)
		return str(v).strip_edges().left(128) if v != null else ""
	return e.text.strip_edges()


## Ник: 3–20 символов, только буквы, цифры, _ - . (без @: никто случайно не
## покажет в топе свою почту). Пароль: 8–128 символов и не совпадает с ником.
static func valid_form(nick: String, password: String, email: String = "x@y.z") -> bool:
	var re: RegEx = RegEx.create_from_string("^[A-Za-zА-Яа-яЁё0-9_.\\-]{3,20}$")
	var at: int = email.find("@")
	return re.search(nick) != null and password.length() >= 8 and password.length() <= 128 \
		and password.to_lower() != nick.to_lower() \
		and at > 0 and email.find(".", at) > at + 1 and not email.contains(" ")


func _show_error(code: String) -> void:
	if not is_instance_valid(_msg):
		return
	var key: String = "err_" + code
	_msg.text = Game.txt(key) if D.STRINGS.has(key) else Game.txt("err_other")
	if code == "too_many":
		_msg.text = Game.txt("err_too_many") % online.lock_left()


func _after_auth(result: String) -> void:
	if result == "":
		popups.close()
		Game.save_game()
		return
	if result == "code":
		show_code(true)
		return
	_show_error(result)


func _on_login() -> void:
	if online.busy:
		return
	if not valid_form(_val("nick"), _val("pass")):
		_show_error("form")
		return
	_after_auth(await online.login(_val("nick"), _val("pass")))


func _on_register() -> void:
	if online.busy:
		return
	if not valid_form(_val("nick"), _val("pass"), _val("email")):
		_show_error("form")
		return
	_after_auth(await online.register(_val("nick"), _val("email"), _val("pass")))


func _on_code() -> void:
	if online.busy or _val("code").is_empty():
		return
	var r: String = await online.verify(_val("code"))
	if r == "":
		show_top(true)
	else:
		_show_error(r)


func _on_logout() -> void:
	online.logout()
	show_top(true)
