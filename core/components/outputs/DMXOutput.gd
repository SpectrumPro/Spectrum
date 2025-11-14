# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name DMXOutput extends EngineComponent
## Base class for all DMX outputs


## Emited when this output connects or disconnects, added note for reason
signal connection_state_changed(state: bool, note: String)

## Emitted when the auto start state is changed
signal auto_start_changed(auto_start)


## Autostart state
var _auto_start: bool = true

## Current connection state
var _connection_state: bool = false

## The last note given for connection status
var _previous_note: String = ""


func _init(p_uuid: String = UUID_Util.v4(), p_name: String = _name) -> void:
	_set_self_class("DMXOutput")
	
	#register_custom_panel("DMXOutput", "connection_status", "set_output", load("res://components/ComponentSettings/ClassCustomModules/DMXOutputStatusDisplay.tscn"))
	#register_setting("DMXOutput", "start", start, Callable(), Signal(), Utils.TYPE_NULL, 0, "Start")
	#register_setting("DMXOutput", "stop", stop, Callable(), Signal(), Utils.TYPE_NULL, 0, "Stop")
	#register_setting("DMXOutput", "auto_start", set_auto_start, get_auto_start, auto_start_changed, Utils.TYPE_BOOL, 1, "Auto Start")
	
	register_callback("on_connection_state_changed", _on_connection_state_changed)
	register_callback("on_auto_start_changed", _set_auto_start)
	
	super._init()


## Sets the auto start state
func set_auto_start(p_auto_start: bool) -> Promise: return rpc("set_auto_start", [p_auto_start])

## Internal: Sets the auto start state
func _set_auto_start(p_auto_start: bool) -> void:
	_auto_start = p_auto_start
	auto_start_changed.emit(p_auto_start)

## Gets the auto start state
func get_auto_start() -> bool:
	return _auto_start


## Gets the previous note
func get_previous_note() -> String:
	return _previous_note


## Gets the current connection state
func get_connection_state()-> bool:
	return _connection_state


## Starts this plugin
func start() -> Promise: 
	return rpc("start")


## Stops this plugin
func stop() -> Promise: 
	return rpc("stop")


## Server: Called when the connection state changes on the server
func _on_connection_state_changed(p_state: bool, p_note: String) -> void:
	_connection_state = p_state
	connection_state_changed.emit(p_state, p_note)
