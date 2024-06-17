# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends Button
## Button for displaying a color, used in the color palette 


## The color of this button
var color: Color = Color.BLACK : set = set_color


func _ready() -> void:
	$Panel.add_theme_stylebox_override("panel", $Panel.get_theme_stylebox("panel").duplicate())


## Sets the color of this button
func set_color(p_color: Color) -> void:
	color = p_color
	$Panel.get_theme_stylebox("panel").bg_color = color
