# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name ClientComponent extends RefCounted
## Client Component base class for Names


## Emitted when the name is changed
signal name_changed(new_name: String)


## UUID of this component
var _uuid: String = UUID_Util.v4()

## The name of this ClientComponent
var _name: String = "Un-named Object"

## Class tree
var _class_tree: Array[String] = ["ClientComponent"]

## Current class name
var _self_class_name: String = "ClientComponent"

## Settings for this component
var _settings: Dictionary = {}


## Init
func _init() -> void:
	register_setting_string("name", set_name, get_name, name_changed)
	_component_ready()


## Override this for a ready function
func _component_ready() -> void:
	pass


## Gets the name
func get_name() -> String:
	return _name


## Gets the classname
func get_class_name() -> String:
	return _self_class_name


## Sets the name of this component
func set_name(p_name: String, no_signal: bool = false) -> bool:
	if p_name == _name:
		return false
	
	_name = p_name
	
	if not no_signal:
		name_changed.emit(_name)
	
	return true


## Gets the uuid
func uuid() -> String:
	return _uuid


## Gets the class tree
func get_class_tree() -> Array[String]:
	return _class_tree.duplicate()


## Gets the settings for the given class
func get_settings(p_classname: String) -> Dictionary:
	return _settings.get(p_classname, {}).duplicate()


## Registers a setting
func register_setting(p_classname: String, p_key: String, p_setter: Callable, p_getter: Callable, p_signal: Signal, p_type: Data.Type, p_visual_line: int, p_visual_name: String, p_min: Variant = null, p_max: Variant = null, p_enum: Dictionary = {}) -> void:
	_settings.get_or_add(p_classname, {})[p_key] = {
			"setter": p_setter,
			"getter": p_getter,
			"signal": p_signal,
			"data_type": p_type,
			"visual_line": p_visual_line,
			"visual_name": p_visual_name,
			"min": p_min,
			"max": p_max,
			"enum": p_enum
	}


## Shorthand for register_setting() for a string value
func register_setting_string(p_key: String, p_setter: Callable, p_getter: Callable, p_signal: Signal) -> void:
	register_setting(_self_class_name, p_key, p_setter, p_getter, p_signal, Data.Type.STRING, -1, p_key.capitalize())


## Shorthand for register_setting() for a float value
func register_setting_bool(p_key: String, p_setter: Callable, p_getter: Callable, p_signal: Signal) -> void:
	register_setting(_self_class_name, p_key, p_setter, p_getter, p_signal, Data.Type.BOOL, -1, p_key.capitalize(), null, null)


## Shorthand for register_setting() for a int value
func register_setting_int(p_key: String, p_setter: Callable, p_getter: Callable, p_signal: Signal, p_min: int, p_max: int) -> void:
	register_setting(_self_class_name, p_key, p_setter, p_getter, p_signal, Data.Type.INT, -1, p_key.capitalize(), p_min, p_max)


## Shorthand for register_setting() for a float value
func register_setting_float(p_key: String, p_setter: Callable, p_getter: Callable, p_signal: Signal, p_min: float, p_max: float) -> void:
	register_setting(_self_class_name, p_key, p_setter, p_getter, p_signal, Data.Type.FLOAT, -1, p_key.capitalize(), p_min, p_max)


## Shorthand for register_setting() for a float value
func register_setting_enum(p_key: String, p_setter: Callable, p_getter: Callable, p_signal: Signal, p_enum: Dictionary) -> void:
	register_setting(_self_class_name, p_key, p_setter, p_getter, p_signal, Data.Type.ENUM, -1, p_key.capitalize(), null, null, p_enum)


## Registers a custom setting panel
func register_custom_panel(p_classname: String, p_key: String, p_entry_point: String, p_custom_panel: PackedScene) -> void:
	_settings.get_or_add(p_classname, {})[p_key] = {
			"data_type": Data.Type.CUSTOMPANEL,
			"entry_point": p_entry_point,
			"custom_panel": p_custom_panel
	}


## Sets the classname of this component
func _set_class_name(p_class_name: String) -> void:
	_self_class_name = p_class_name
	_class_tree.append(p_class_name)


## Saves this ClientComponent into a Dictionary
func save() -> Dictionary:
	return {
		"uuid": _uuid,
		"name": _name,
		"class": _self_class_name,
	}.merged(_save())


## Loads this ClientComponent from a dictionary
func load(saved_data: Dictionary) -> void:
	_uuid = type_convert(saved_data.get("uuid", _uuid), TYPE_STRING)
	_name = type_convert(saved_data.get("name", _name), TYPE_STRING)
	
	_load(saved_data)


## Override this to provide a save function to your ClientComponent
func _save() -> Dictionary:
	return {}


## Override this to provide a load function to your ClientComponent
func _load(saved_data: Dictionary) -> void:
	pass
