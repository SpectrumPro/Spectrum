# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name NetworkManager extends Node
## Controls the Spectrum Network System


## All available NetworkHandlers that can be loaded
var _available_handlers: Dictionary[String, Script] = {
	"Constellation": Constellation
}

## All NetworkHandlers currently loaded in the engine
var _active_handlers: Dictionary[String, NetworkHandler]

## Dict containg all NetworkItems sorted by classname
var _registered_items: Dictionary[String, Array]

## The SettingsManager for NetworkManager
var settings_manager: SettingsManager = SettingsManager.new()


## Init
func _init() -> void:
	settings_manager.set_owner(self)
	settings_manager.set_inheritance_array(["NetworkManager"])
	settings_manager.register_control("StartAll", Data.Type.NULL, start_all, Callable(), [])
	settings_manager.register_control("StopAll", Data.Type.NULL, stop_all, Callable(), [])


## Ready
func _ready() -> void:
	for handler_name: String in _available_handlers:
		var new_handler: NetworkHandler = _available_handlers[handler_name].new()
		
		new_handler.node_found.connect(_register_item)
		new_handler.session_created.connect(_register_item)
		
		_register_item(new_handler)
		add_child(new_handler)
		
		_active_handlers[handler_name] = new_handler


## Starts all the NetworkHandlers
func start_all() -> void:
	for handler: NetworkHandler in _active_handlers.values():
		handler.start_node()


## Stop all the NetworkHandlers
func stop_all() -> void:
	for handler: NetworkHandler in _active_handlers.values():
		handler.stop_node()


## Gets an active handler by its class name
func get_active_handler_by_name(p_classname: String) -> NetworkHandler:
	return _active_handlers.get(p_classname, null)


## Returns all active NetworkHandlers
func get_all_active_handlers() -> Dictionary[String, NetworkHandler]:
	return _active_handlers.duplicate()


## Gets all the NetworkItems by classname
func get_items_by_classname(p_classname: String) -> Array:
	return _registered_items.get(p_classname, [])


## Register an item
func _register_item(p_item: NetworkItem) -> void:
	for classname: String in NetworkClassList.get_class_inheritance_tree(p_item.get_script().get_global_name()):
		_registered_items.get_or_add(classname, []).append(p_item)
	
	p_item.request_delete.connect(_deregister_item)


## Deregister an item
func _deregister_item(p_item: NetworkItem) -> void:
	for classname: String in NetworkClassList.get_class_inheritance_tree(p_item.get_script().get_global_name()):
		_registered_items.get(classname, []).erase(p_item)
