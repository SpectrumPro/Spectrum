# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name ObjectPickerButton extends Button
## Button for the object picker


## Emitted when the object is changed
signal object_selected(object: EngineComponent)

## Emitted when mutiple objects are selected when using multi select mode
signal multi_selected(objects: Array[EngineComponent])


## The Select mode
@export_enum("Single:0", "Multi:1") var select_mode: int = ObjectPicker.SelectMode.Single

## Object picker filter
@export var filter: Array[String] = []


## The current object
var _object: EngineComponent = null

## The orignal user defined text of this button
var _orignal_text: String


func _ready() -> void:
	_orignal_text = text


## Sets the select object
func set_object(object: EngineComponent) -> void:
	_object = object
	
	if _object:
		text = _object.name
		remove_theme_color_override("icon_normal_color")
		remove_theme_color_override("icon_focus_color")
		remove_theme_color_override("icon_hover_color")
		remove_theme_color_override("icon_hover_pressed_color")
		remove_theme_color_override("icon_pressed_color")
	else:
		text = _orignal_text
		add_theme_color_override("icon_normal_color", Color.hex(0x7a7a7a))
		add_theme_color_override("icon_focus_color", Color.hex(0x7a7a7a))
		add_theme_color_override("icon_hover_color", Color.hex(0x7a7a7a))
		add_theme_color_override("icon_hover_pressed_color", Color.hex(0x7a7a7a))
		add_theme_color_override("icon_pressed_color", Color.hex(0x7a7a7a))
		
	object_selected.emit(_object)


## Returns the object
func get_object() -> EngineComponent:
	return _object


## Called when the button is pressed
func _on_pressed() -> void:
	Interface.show_object_picker(select_mode, func (objects: Array[EngineComponent]):
		if objects:
			set_object(objects[0])
			
	, filter)
