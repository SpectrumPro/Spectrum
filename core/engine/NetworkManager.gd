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


## Ready
func _ready() -> void:
	for handler_name: String in _available_handlers:
		var new_handler: NetworkHandler = _available_handlers[handler_name].new()
		
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
