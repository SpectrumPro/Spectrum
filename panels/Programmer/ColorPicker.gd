# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends ColorPicker
## The color picker wheel in the programmer

func _on_control_resized() -> void:
	size = Vector2(get_parent().size.x, get_parent().size.y)

