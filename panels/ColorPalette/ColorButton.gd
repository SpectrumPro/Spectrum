# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name ColorButton extends Button
## Button for displaying a color, or a texture. Used in the color palette 


## The color of this button
var color: Color = Color.BLACK : set = set_color


func _ready() -> void:
	$Panel.add_theme_stylebox_override("panel", $Panel.get_theme_stylebox("panel").duplicate())


## Sets the color of this button
func set_color(p_color: Color) -> void:
	color = p_color
	$Panel.get_theme_stylebox("panel").bg_color = color


## Sets a custem texture for this button
func set_texture(texture: Texture2D) -> void:
	if texture:
		$Panel.hide()
		$TextureRect.show()
		
		$TextureRect.texture = texture
	
	else:
		$Panel.show()
		$TextureRect.hide()
		
		$TextureRect.texture = null
