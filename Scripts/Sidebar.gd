extends Control


var is_open = false

@export var contence = Control

func _on_side_bar_open_pressed() -> void:
	if is_open:
		contence.visible = false
	else:
		contence.visible = true
	is_open = not is_open
