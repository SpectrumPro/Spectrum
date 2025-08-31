# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name NetworkManager extends Node
## Controls the Spectrum Network System



## All available NetworkHandlers that can be loaded
var _available_handlers: Array[Script] = [
	Constellation
]

## All NetworkHandlers currently loaded in the engine
var _active_handlers: Array[NetworkHandler] = []


## Ready
func _ready() -> void:
	for available_handler: Script in _available_handlers:
		var new_handler: NetworkHandler = available_handler.new()
		
		add_child(new_handler)
		_active_handlers.append(new_handler)


## Starts all the NetworkHandlers
func start_all() -> void:
	for handler: NetworkHandler in _active_handlers:
		handler.start_node()


## Stop all the NetworkHandlers
func stop_all() -> void:
	for handler: NetworkHandler in _active_handlers:
		handler.stop_node()
