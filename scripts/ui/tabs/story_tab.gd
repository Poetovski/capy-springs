extends "res://scripts/ui/tabs/tab_base.gd"
## Вкладка «История»: прочитанные главы (новые сверху) и реплики друзей.

## Первая глава каждой книги и ключ её заголовка.
const BOOKS: Array = [[0, "book1_title"], [D.BOOK2_FIRST_CHAPTER, "book2_title"], [D.BOOK3_FIRST_CHAPTER, "book3_title"]]


func build() -> void:
	var lang: String = Game.lang
	var next_text: String = Game.txt("story_end")
	if Game.chapter + 1 < D.CHAPTERS.size():
		next_text = Game.txt("next_chapter") % D.fmt(float(D.CHAPTERS[Game.chapter + 1]["at"]))
	box.add_child(K.label(next_text, 18, K.C_BROWN_SOFT, true, true))
	for c in range(Game.chapter, -1, -1):
		var ch: Dictionary = D.CHAPTERS[c]
		# Заголовок книги — над её последней прочитанной главой (верхней в списке)
		var b: int = book_of(c)
		if c == Game.chapter or (b + 1 < BOOKS.size() and c == int(BOOKS[b + 1][0]) - 1):
			box.add_child(K.label(Game.txt(BOOKS[b][1]), 24, K.C_BROWN, true))
		var row: PanelContainer = K.row_panel()
		var vb: VBoxContainer = K.vbox()
		row.add_child(vb)
		vb.add_child(K.label((Game.txt("chapter") % (c + 1)) + " · " + str(ch["place_" + lang]), 22, K.C_BROWN, false, true))
		vb.add_child(K.label(str(ch["text_" + lang]), 18, K.C_BROWN_SOFT, false, true))
		box.add_child(row)
	for i in D.HELPERS.size():
		if Game.friends_met.has(str(i)):
			box.add_child(_friend_row(i))


static func book_of(chapter: int) -> int:
	var b: int = 0
	for k in BOOKS.size():
		if chapter >= int(BOOKS[k][0]):
			b = k
	return b


func _friend_row(i: int) -> PanelContainer:
	var lang: String = Game.lang
	var h: Dictionary = D.HELPERS[i]
	var row: PanelContainer = K.row_panel()
	var hb: HBoxContainer = K.hbox()
	row.add_child(hb)
	hb.add_child(K.icon(ui.stage.friend_tex[h["icon"]], 56))
	var text: String = "%s: «%s»" % [h[lang], h["line_" + lang]]
	# Реплики дружбы открываются при 10 / 25 / 50 штуках
	var own: int = int(Game.owned[i])
	var next_at: int = 0
	for fl in D.FRIEND_LINES.get(h["icon"], []):
		if own >= int(fl["at"]):
			text += "\n«%s»" % fl[lang]
		elif next_at == 0:
			next_at = int(fl["at"])
	if next_at > 0:
		text += "\n" + Game.txt("friend_line_locked") % next_at
	var ll: Label = K.label(text, 17, K.C_BROWN_SOFT, false, true)
	ll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(ll)
	return row
