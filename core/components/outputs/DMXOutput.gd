# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name DMXOutput extends EngineComponent
## Base class for all DMX outputs


## Emited when this output connects or disconnects, added note for reason
signal connection_state_changed(state: bool, note: String)


func _init(p_uuid: String = UUID_Util.v4(), p_name: String = name) -> void:
	_set_self_class("DMXOutput")
	register_callback("on_connection_state_changed", _on_connection_state_changed)

	super._init()

## Starts this plugin
func start() -> Promise: return rpc("start")

## Internal: Starts this plugin
func _start() -> void:
	
	connection_state_changed.emit(true, "Empty Output")
	# As this is the base class, this script does not connect to anything.
	print(name, " Started!")


## Stops this plugin
func stop() -> Promise: return rpc("stop")

## Internal: Stops this plugin
func _stop() -> void:

	connection_state_changed.emit(false, "Empty Output")
	# As this is the base class, this script does not connect to anything.
	print(name, " Stoped")


## Server: Called when the connection state changes on the server
func _on_connection_state_changed(p_state: bool, p_note: String) -> void:
	connection_state_changed.emit(p_state, p_note)
