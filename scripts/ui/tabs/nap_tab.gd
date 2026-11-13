extends "res://scripts/ui/tabs/tab_base.gd"
## Вкладка «Сон»: Великий Сон (престиж) и статистика.

var nap_btn: Button
var info: Label
var stats: Label
var confirm: bool = false


func opened() -> void:
	confirm = false


func build() -> void:
	var row: PanelContainer = K.row_panel()
	var vb: VBoxContainer = K.vbox(8)
	row.add_child(vb)
	var hb: HBoxContainer = K.hbox()
	hb.add_child(K.icon(ui.stage.tex_mandarin, 56))
	hb.add_child(K.label(Game.txt("nap_title"), 26))
	vb.add_child(hb)
	vb.add_child(K.label(Game.txt("nap_desc"), 17, K.C_BROWN_SOFT, false, true))
	info = K.label("", 19, K.C_MANDARIN)
	vb.add_child(info)
	nap_btn = K.button("", K.C_ORANGE, 21, Vector2(0, 68), _on_nap)
	nap_btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(nap_btn)
	box.add_child(row)
	stats = K.label("", 18, K.C_BROWN_SOFT)
	box.add_child(stats)


func refresh() -> void:
	info.text = Game.txt("mandarins") % [Game.mandarins, Game.mandarin_pct()]
	if not Game.nap_unlocked():
		nap_btn.text = Game.txt("nap_locked")
		nap_btn.disabled = true
	elif Game.nap_gain() <= 0:
		nap_btn.text = Game.txt("nap_none")
		nap_btn.disabled = true
	else:
		nap_btn.disabled = false
		nap_btn.text = Game.txt("nap_confirm") if confirm else Game.txt("nap_gain") % str(Game.nap_gain())
	stats.text = Game.txt("stats") % [D.fmt(Game.all_total), Game.taps, Game.naps]


func _on_nap() -> void:
	if not confirm:
		confirm = true
		refresh()
		return
	confirm = false
	Game.do_nap()
	ui.audio.gold()
	ui.vibrate(80)
	ui.stage.sync_friends()
	ui.set_tab(0)
	ui.toast(Game.txt("mandarins") % [Game.mandarins, Game.mandarin_pct()])
