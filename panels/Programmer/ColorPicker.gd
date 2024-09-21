# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

extends ColorPicker
## The color picker wheel in the programmer

func _on_control_resized() -> void:
	size = Vector2(get_parent().size.x, get_parent().size.y)

