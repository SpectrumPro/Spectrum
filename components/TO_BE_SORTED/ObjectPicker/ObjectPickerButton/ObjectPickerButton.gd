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
@export var filter: String = "EngineComponent"

## Enables this button to follow global store mode
@export var enable_store_mode: bool = false


## The current object
var _object: EngineComponent = null

## The orignal user defined text of this button
var _orignal_text: String

## UUID of the EngineComponent to look for
var _look_for_component: String


func _ready() -> void:
	_orignal_text = text
	
	if enable_store_mode:
		Programmer.store_mode_changed.connect(_store_mode_changed)


## Sets the select object
func set_object(object: EngineComponent) -> void:
	if _object:
		_object.name_changed.disconnect(_on_component_name_changed)
	
	_object = object
	
	if _object:
		text = _object.name
		_object.name_changed.connect(_on_component_name_changed)
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


## Looks for an object, or waits untill is added
func look_for(uuid: String) -> void:
	if _look_for_component:
		ComponentDB.remove_request(_look_for_component, _on_component_found)
		
	_look_for_component = uuid
	ComponentDB.request_component(_look_for_component, _on_component_found)


## Called if ComponentDB find the component
func _on_component_found(object: EngineComponent) -> void:
	if object.class_tree.has(filter):
		set_object(object)


## Called when the components name is changed
func _on_component_name_changed(new_name: String) -> void:
	text = new_name


## Called when the programmer store mode changes
func _store_mode_changed(state: bool, type_hint: String) -> void:
	$StoreMode.visible = state


## Called when the button is pressed
func _on_pressed() -> void:
	if $StoreMode.visible:
		if _object:
			Programmer.resolve_store_mode(_object)
		else:
			Programmer.resolve_store_mode_with_new(filter).then(set_object)
		
	else:
		_show_object_picker()


## Shows the object picker to change the object
func _show_object_picker() -> void:
	Interface.show_object_picker(select_mode, func (objects: Array[EngineComponent]):
		if objects:
			set_object(objects[0])
			
	, filter)
