# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends Control
## Common script to handle a menu opening when a button is pressed, ie a sidebar, dropdown, ect

@export var contence: Control

var is_open: bool = false:
	set(new_value):
		contence.visible = new_value
		is_open = new_value

func _on_button_pressed() -> void:
	#if is_open:
		#contence.visible = false
	#else:
		#contence.visible = true
	is_open = not is_open
