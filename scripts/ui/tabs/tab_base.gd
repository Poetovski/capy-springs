extends RefCounted
## Основа вкладки нижнего списка. Вкладка строит строки в box (build) и
## обновляет цифры на них (refresh, ~7 раз в секунду, пока вкладка открыта).

const D = preload("res://scripts/data.gd")
const K = preload("res://scripts/ui/ui_kit.gd")

var ui: Control              # main.gd: звук, сцена с Капи, тосты, перестройка вкладки
var box: VBoxContainer


func _init(main_ui: Control, list_box: VBoxContainer) -> void:
	ui = main_ui
	box = list_box


## Строки списка создаются заново при каждом открытии вкладки.
func build() -> void:
	pass


func refresh() -> void:
	pass


## Вкладку открыли (а не просто перестроили после покупки).
func opened() -> void:
	pass
