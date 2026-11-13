extends "res://scripts/ui/tabs/tab_base.gd"
## Вкладка «Награды»: достижения, каждое даёт +2% ко всему дзену навсегда.

var rows: Array = []
var header: Label


func build() -> void:
	rows = []
	header = K.label("", 19, K.C_MANDARIN, true, true)
	box.add_child(header)
	# Сначала готовые к получению, потом в процессе, в конце уже полученные
	# (по проходам, а не sort_custom: тот не сохраняет порядок внутри группы)
	var order: Array = []
	for bucket in 3:
		for a in D.ACHIEVEMENTS:
			if _bucket(a) == bucket:
				order.append(a)
	for a in order:
		var row: PanelContainer = K.row_panel()
		var hb: HBoxContainer = K.hbox()
		row.add_child(hb)
		var ic: TextureRect = K.icon(ui.stage.tex_mandarin, 52)
		hb.add_child(ic)
		var vb: VBoxContainer = K.vbox(2, true)
		hb.add_child(vb)
		vb.add_child(K.label(str(a[Game.lang]), 20))
		var dl: Label = K.label("", 16, K.C_BROWN_SOFT, false, true)
		vb.add_child(dl)
		var b: Button = K.button("", K.C_ORANGE, 19, Vector2(140, 60), _on_claim.bind(str(a["id"])))
		hb.add_child(b)
		box.add_child(row)
		rows.append({"a": a, "desc": dl, "btn": b, "icon": ic})


func _bucket(a: Dictionary) -> int:
	if Game.ach_claimed.has(a["id"]):
		return 2
	return 0 if Game.ach_done(a) else 1


func refresh() -> void:
	var n: int = Game.ach_claimed.size()
	header.text = Game.txt("ach_header") % [n, D.ACHIEVEMENTS.size(), int(round(n * D.ACH_BONUS * 100.0))] \
		+ "\n" + Game.txt("ach_reward")
	for r in rows:
		var a: Dictionary = r["a"]
		var claimed: bool = Game.ach_claimed.has(a["id"])
		var done: bool = Game.ach_done(a)
		var goal: float = float(a["goal"])
		(r["desc"] as Label).text = "%s\n%s / %s" % [a["d_" + Game.lang], D.fmt(minf(Game.ach_value(a), goal)), D.fmt(goal)]
		var b: Button = r["btn"]
		b.text = Game.txt("ach_done") if claimed else Game.txt("ach_claim")
		b.disabled = claimed or not done
		(r["icon"] as TextureRect).modulate = Color.WHITE if (claimed or done) else Color(0.3, 0.3, 0.3, 0.45)


func _on_claim(id: String) -> void:
	if Game.claim_achievement(id):
		ui.audio.gold(1.1)
		ui.vibrate(40)
		ui.toast("+2%!")
		ui.update_tab_titles()
		ui.rebuild_tab(true)
