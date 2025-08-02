# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

extends PanelContainer
## The color sliders used in the programmer, support setting the bg gradient color to indicate to the user what color you will get when you move the slider


## Emitted when the underlaying slider is chanegd
signal value_changed(value: int)


## The current value of the underlaying slider
@onready var value: int = $VBoxContainer/PanelContainer/VSlider.value: 
	get:
		return $VBoxContainer/PanelContainer/TextureRect.value

## The color at the bottom of the BG graident
var bottom_color: Color = Color.BLACK: set = set_botton_color

## The color at the bottom of the BG graident
var top_color: Color = Color.WHITE: set = set_top_color


## Sets the color at the bottom of the BG graident
func set_botton_color(color: Color) -> void:
	bottom_color = color
	$VBoxContainer/PanelContainer/TextureRect.texture.gradient.set_color(0, color)


## Sets the color at the bottom of the BG graident
func set_top_color(color: Color) -> void:
	top_color = color
	$VBoxContainer/PanelContainer/TextureRect.texture.gradient.set_color(1, color)


func _on_v_slider_value_changed(value: float) -> void:
	value_changed.emit(value)
