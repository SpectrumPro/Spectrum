# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name PaletteItemComponent extends Button
## A palett item


## The color icon panel
@export var _color_icon: Panel = null

## The label
@export var _label: Label = null


## The color icon stylebox
var _color_icon_style_box: StyleBox = null


func _ready() -> void:
	_color_icon.add_theme_stylebox_override("panel", _color_icon.get_theme_stylebox("panel").duplicate(true))


## Sets the color icons color
func set_color(p_color: Color) -> void: _color_icon_style_box.bg_color = p_color
func get_color() -> Color: return _color_icon_style_box.bg_color


## Sets the visibility state on the color icon
func set_show_color(p_show_color: bool) -> void:
	_color_icon.visible = p_show_color


## Sets the disabled state of this item
func set_item_disabled(p_disabled: bool) -> void:
	disabled = p_disabled
	$Overlay.visible = disabled


## Sets the label text
func set_label_text(p_label_text: String) -> void: _label.text = p_label_text
func get_label_text() -> String: return _label.text
