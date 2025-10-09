# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name SettingsManager extends RefCounted
## SettingsManager


## All entrys in this SettingsManager
var _entrys: Dictionary[String, SettingsModule]

## The owner Object
var _owner: Object = null

## The owner object's class inheritance
var _inheritance_list: Array[String]


## Registers a settings
func register_setting(p_id: String, p_data_type: Data.Type, p_setter: Callable, p_getter: Callable, p_signals: Array[Signal]) -> SettingsModule:
	if not p_id or not p_data_type or not p_getter:
		return null
	
	var module: SettingsModule = SettingsModule.new(p_id, p_id.capitalize(), p_data_type, SettingsModule.TypeFlags.SETTING, p_setter, p_getter, p_signals)
	_entrys[p_id] = module
	
	return module


## Registers a controlable parameter
func register_control(p_id: String, p_data_type: Data.Type, p_setter: Callable, p_getter: Callable, p_signals: Array[Signal]) -> SettingsModule:
	if not p_id or not p_data_type or not p_getter:
		return null
	
	var module: SettingsModule = SettingsModule.new(p_id, p_id.capitalize(), p_data_type, SettingsModule.TypeFlags.CONTROL, p_setter, p_getter, p_signals)
	_entrys[p_id] = module
	
	return module


## Registers a controlable parameter
func register_status(p_id: String, p_data_type: Data.Type, p_getter: Callable, p_signals: Array[Signal], p_enum_dict: Dictionary = {}) -> SettingsModule:
	if not p_id or not p_data_type or not p_getter:
		return null
	
	var module: SettingsModule = SettingsModule.new(p_id, p_id.capitalize(), p_data_type, SettingsModule.TypeFlags.STATUS, Callable(), p_getter, p_signals)
	module.set_enum_dict(p_enum_dict)
	_entrys[p_id] = module
	
	return module


## Gets an entry
func get_entry(p_id: String) -> SettingsModule:
	return _entrys.get(p_id, null)


## Gets all the SettingsModules
func get_modules() -> Dictionary[String, SettingsModule]:
	return _entrys.duplicate()


## Gets the owner of this SettingsManager
func get_owner() -> Object:
	return _owner


## Gets the inheritance list
func get_inheritance_list() -> Array[String]:
	return _inheritance_list.duplicate()


## Gets the first item in the inheritance list
func get_inheritance_root() -> String:
	return _inheritance_list[0]


## Sets the owner
func set_owner(p_owner: Object) -> void:
	_owner = p_owner


## Sets the Array inheritance_list uses, allowing it to be updated afterwards
func set_inheritance_array(p_inheritance_array: Array[String]) -> void:
	_inheritance_list = p_inheritance_array
