# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name SettingsManager extends RefCounted
## SettingsManager


## All entrys in this SettingsManager
var _entrys: Dictionary[String, SettingsModule]

## The owner Object
var _owner: Object = null

## The object deletion signal
var _delete_signal: Signal

## The owner object's class inheritance
var _inheritance_list: Array[String]

## All methods that can be called over the network
var _networked_methods: Dictionary[String, Callable]

## Methods to be called when the given callback is recieved
var _networked_callbacks: Dictionary[String, Callable]

## All signals that should be emitted accross the network
var _networked_signals: Dictionary[String, Signal]


## Registers a settings
func register_setting(p_id: String, p_data_type: Data.Type, p_setter: Callable, p_getter: Callable, p_signals: Array[Signal]) -> SettingsModule:
	if not p_id:
		return null
	
	var module: SettingsModule = SettingsModule.new(p_id, p_id.capitalize(), p_data_type, SettingsModule.Type.SETTING, p_setter, p_getter, p_signals)
	_entrys[p_id] = module
	
	return module


## Registers a controlable parameter
func register_control(p_id: String, p_data_type: Data.Type, p_setter: Callable, p_getter: Callable, p_signals: Array[Signal]) -> SettingsModule:
	if not p_id:
		return null
	
	var module: SettingsModule = SettingsModule.new(p_id, p_id.capitalize(), p_data_type, SettingsModule.Type.CONTROL, p_setter, p_getter, p_signals)
	_entrys[p_id] = module
	
	return module


## Registers a controlable parameter
func register_status(p_id: String, p_data_type: Data.Type, p_getter: Callable, p_signals: Array[Signal], p_enum_dict: Dictionary = {}) -> SettingsModule:
	if not p_id or not p_data_type or not p_getter:
		return null
	
	var module: SettingsModule = SettingsModule.new(p_id, p_id.capitalize(), p_data_type, SettingsModule.Type.STATUS, Callable(), p_getter, p_signals)
	module.set_enum_dict(p_enum_dict)
	_entrys[p_id] = module
	
	return module


## Registers a networked method, auto sets the method name from the Callable
func register_networked_methods_auto(p_methods: Array[Callable]) -> void:
	for method: Callable in p_methods:
		_networked_methods[method.get_method()] = method


## Registers a networked method
func register_networked_methods(p_methods: Dictionary[String, Callable]) -> void:
	_networked_methods.merge(p_methods, true)


## Registers a networked callbacks, auto sets the method name from the Callable
func register_networked_callbacks_auto(p_callbacks: Array[Callable]) -> void:
	for method: Callable in p_callbacks:
		_networked_callbacks[method.get_method()] = method


## Registers a networked method
func register_networked_callbacks(p_callbacks: Dictionary[String, Callable]) -> void:
	_networked_callbacks.merge(p_callbacks, true)


## Registers a networked method, auto sets the method name from the Callable
func register_networked_signals_auto(p_signals: Array[Signal]) -> void:
	for p_signal: Signal in p_signals:
		_networked_signals[p_signal.get_name()] = p_signal


## Registers a networked method
func register_networked_signal(p_signals: Dictionary[String, Signal]) -> void:
	_networked_methods.merge(p_signals, true)


## Gets an entry
func get_entry(p_id: String) -> SettingsModule:
	return _entrys.get(p_id, null)


## Gets all the SettingsModules
func get_modules() -> Dictionary[String, SettingsModule]:
	return _entrys.duplicate()


## Gets the owner of this SettingsManager
func get_owner() -> Object:
	return _owner


## Gets the delete signal
func get_delete_signal() -> Signal:
	return _delete_signal


## Gets the inheritance list
func get_inheritance_list() -> Array[String]:
	return _inheritance_list.duplicate()


## Gets the first item in the inheritance list
func get_inheritance_root() -> String:
	return _inheritance_list[0]


## Gets a networked method by name
func get_networked_method(p_method_name: String) -> Callable:
	return _networked_methods.get(p_method_name, Callable())


## Gets a networked method by name
func get_networked_callback(p_callback_name: String) -> Callable:
	return _networked_callbacks.get(p_callback_name, Callable())


## Gets a networked signals by name
func get_networked_signal(p_signal_name: String) -> Signal:
	return _networked_signals.get(p_signal_name, Signal())


## Gets all networked methods
func get_networked_methods() -> Dictionary[String, Callable]:
	return _networked_methods.duplicate()


## Gets all networked callbacks
func get_networked_callbacks() -> Dictionary[String, Callable]:
	return _networked_callbacks.duplicate()


## Gets all networked signals
func get_networked_signals() -> Dictionary[String, Signal]:
	return _networked_signals.duplicate()


## Sets the owner
func set_owner(p_owner: Object) -> void:
	_owner = p_owner


## Sets the delete signal
func set_delete_signal(p_delete_signal: Signal) -> void:
	_delete_signal = p_delete_signal


## Sets the Array inheritance_list uses, allowing it to be updated afterwards
func set_inheritance_array(p_inheritance_array: Array[String]) -> void:
	_inheritance_list = p_inheritance_array
