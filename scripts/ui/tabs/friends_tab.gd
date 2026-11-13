extends "res://scripts/ui/tabs/tab_base.gd"
## Вкладка «Друзья»: покупка друзей x1 / x10 / MAX с лимитом мест в источнике.

const MODES: Array = ["x1", "x10", "MAX"]

var buy_mode: int = 0
var rows: Array = []
var mode_btn: Button


func build() -> void:
	rows = []
	mode_btn = K.button("", K.C_BLUE, 20, Vector2(0, 48), _toggle_mode)
	box.add_child(mode_btn)
	for i in D.HELPERS.size():
		var row: PanelContainer = K.row_panel()
		var hb: HBoxContainer = K.hbox()
		row.add_child(hb)
		var ic: TextureRect = K.icon(ui.stage.friend_tex[D.HELPERS[i]["icon"]], 76)
		hb.add_child(ic)
		var vb: VBoxContainer = K.vbox(2, true)
		hb.add_child(vb)
		var nl: Label = K.label("", 23)
		vb.add_child(nl)
		var il: Label = K.label("", 17, K.C_BROWN_SOFT, false, true)
		vb.add_child(il)
		var b: Button = K.button("", K.C_GREEN, 22, Vector2(150, 72), _on_buy.bind(i))
		hb.add_child(b)
		box.add_child(row)
		rows.append({"row": row, "icon": ic, "name": nl, "info": il, "btn": b})


## Сколько друзей купит нажатие в текущем режиме (с учётом мест в источнике).
func buy_count(i: int) -> int:
	var room: int = Game.helper_room(i)
	match buy_mode:
		1:
			return clampi(10, 1, maxi(1, room))
		2:
			return maxi(1, Game.helper_max_affordable(i))
	return 1


func refresh() -> void:
	var lang: String = Game.lang
	mode_btn.text = Game.txt("buy_mode") % MODES[buy_mode]
	var shown_locked: bool = false
	var cap: int = Game.helper_cap()
	for i in rows.size():
		var r: Dictionary = rows[i]
		var h: Dictionary = D.HELPERS[i]
		var row: PanelContainer = r["row"]
		var btn: Button = r["btn"]
		var ic: TextureRect = r["icon"]
		var nl: Label = r["name"]
		var il: Label = r["info"]
		if not Game.helper_revealed(i):
			# Показываем только первого закрытого друга, остальные спрятаны
			row.visible = not shown_locked
			if shown_locked:
				continue
			shown_locked = true
			ic.modulate = Color(0, 0, 0, 0.55)
			nl.text = Game.txt("locked")
			var req: int = int(h.get("chapter_req", 0))
			il.text = Game.txt("locked_hint_book3" if req >= D.BOOK3_FIRST_CHAPTER else ("locked_hint_book2" if h.has("chapter_req") else "locked_hint"))
			btn.text = D.fmt(Game.helper_cost(i, 1))
			btn.disabled = true
			continue
		row.visible = true
		ic.modulate = Color.WHITE
		nl.text = str(h[lang])
		var own: int = int(Game.owned[i])
		var each: float = Game.helper_zps_each(i) * Game.prestige_mult()
		if Game.helper_room(i) <= 0:
			il.text = Game.txt("owned_cap") % [own, cap, D.fmt(each * own)] + "\n" + Game.txt("cap_hint")
			btn.text = Game.txt("cap_full")
			btn.disabled = true
			continue
		var n: int = buy_count(i)
		var cost: float = Game.helper_cost(i, n)
		il.text = (Game.txt("owned_cap") % [own, cap, D.fmt(each * own)]) if own > 0 else (Game.txt("each") % D.fmt(each))
		btn.text = D.fmt(cost) + ("" if n == 1 else "\nx%d" % n)
		btn.disabled = Game.zen < cost


func _toggle_mode() -> void:
	buy_mode = (buy_mode + 1) % MODES.size()
	refresh()


func _on_buy(i: int) -> void:
	if Game.buy_helper(i, buy_count(i)):
		ui.audio.buy()
		if not ui.stage.chill_sprites.has(i):
			ui.stage.sync_friends()
		refresh()
