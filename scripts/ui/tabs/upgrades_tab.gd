extends "res://scripts/ui/tabs/tab_base.gd"
## Вкладка «Улучшения»: список доступных улучшений, дешёвые сверху.

var rows: Array = []
var sig: String = ""


func build() -> void:
	rows = []
	var list: Array = Game.visible_upgrades()
	sig = signature(list)
	if list.is_empty():
		box.add_child(K.label(Game.txt("no_upgrades"), 20, K.C_BROWN_SOFT, true, true))
		return
	for u in list:
		var row: PanelContainer = K.row_panel()
		var hb: HBoxContainer = K.hbox()
		row.add_child(hb)
		hb.add_child(K.icon(_icon_for(u), 64))
		var vb: VBoxContainer = K.vbox(2, true)
		hb.add_child(vb)
		vb.add_child(K.label(Game.upgrade_name(u), 20, K.C_BROWN, false, true))
		vb.add_child(K.label(Game.upgrade_desc(u), 16, K.C_BROWN_SOFT, false, true))
		var b: Button = K.button(D.fmt(float(u["cost"])), K.C_ORANGE, 21, Vector2(140, 64), _on_buy.bind(u))
		hb.add_child(b)
		box.add_child(row)
		rows.append({"u": u, "btn": b})


func _icon_for(u: Dictionary) -> Texture2D:
	var st = ui.stage
	if st.friend_tex.has(u["icon"]):
		return st.friend_tex[u["icon"]]
	match str(u["icon"]):
		"capy":
			return st.tex_capy
		"mandarin":
			return st.tex_mandarin
	return K.tex("paw")


static func signature(list: Array) -> String:
	var s: String = ""
	for u in list:
		s += str(u["id"]) + ","
	return s


func refresh() -> void:
	# Появились новые улучшения — перестроить список, сохранив прокрутку
	if signature(Game.visible_upgrades()) != sig:
		ui.rebuild_tab(true)
		return
	for r in rows:
		(r["btn"] as Button).disabled = Game.zen < float(r["u"]["cost"])


func _on_buy(u: Dictionary) -> void:
	if Game.buy_upgrade(u):
		ui.audio.buy(1.2)
		ui.rebuild_tab(true)
