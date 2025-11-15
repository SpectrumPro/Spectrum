# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name CoreProgrammer extends Node
## Engine class for programming lights, colors, positions, etc.


## Emitted when the programmer is cleared
signal cleared()

## Emitted when the store mode state is changed
signal store_mode_changed(store_mode_state: bool, class_hint: String)


## Save Modes
enum SaveMode {
	MODIFIED,		## Only save fixtures that have been changed in the programmer
	ALL,			## Save all values of the fixtures
	ALL_NONE_ZERO	## Save all values of the fixtures, as long as they are not the zero value for that channel
}

## Random parameter modes
enum RandomMode {
	All,			## Sets all fixture's parameter to the same random value
	Individual		## Uses a differnt random value for each fixture
}

## Mix Mode 
enum MixMode {
	Additive,		## Uses Additive Mixing
	Subtractive		## Uses Subtractive Mixing
}


## Network Config:
var network_config: Dictionary = {
	"callbacks": {
		"on_cleared": _clear,
	}
}


## Current store mode state
var _store_mode_state: bool = false

## Callback for store mode
var _store_mode_callback: Callable


## Clears the programmer
func clear() -> Promise: 
	return Network.send_command("Programmer", "clear")


## Called when the programmer is cleared on the server
func _clear() -> void:
	cleared.emit()


## Function to set the fixture data at the given chanel key
func set_parameter(p_fixtures: Array, p_parameter: String, p_function: String, p_value: float, p_zone: String) -> Promise:
	return Network.send_command("Programmer", "set_parameter", [p_fixtures, p_parameter, p_function, p_value, p_zone])


## Sets a fixture parameter to a random value
func set_parameter_random(p_fixtures: Array, p_parameter: String, p_function: String, p_zone: String, p_mode: RandomMode) -> Promise:
	return Network.send_command("Programmer", "set_parameter_random", [p_fixtures, p_parameter, p_function, p_zone, p_mode])


## Erases a parameter
func erase_parameter(p_fixtures: Array, p_parameter: String, p_zone: String) -> Promise:
	return Network.send_command("Programmer", "erase_parameter", [p_fixtures, p_parameter, p_zone])


## Saves the current state of this programmer to a scene
func save_to_new_scene(fixtures: Array, mode: SaveMode = SaveMode.MODIFIED) -> Promise:
	return Network.send_command("Programmer", "save_to_new_scene", [fixtures, mode])


## Shortcut to set the color of fixtures
func shortcut_set_color(p_fixtures: Array, p_color: Color, p_mode: MixMode) -> Promise:
	return Network.send_command("Programmer", "shortcut_set_color", [p_fixtures, p_color, p_mode])


## Enters store mode
func enter_store_mode(callback: Callable = _store_callback, class_hint: String = "EngineComponent") -> void:
	_store_mode_state = true
	_store_mode_callback = callback
	store_mode_changed.emit(_store_mode_state, class_hint)


## Exits store mode
func exit_store_mode() -> void:
	if not _store_mode_state:
		return
	
	_store_mode_state = false
	_store_mode_callback = Callable()
	store_mode_changed.emit(_store_mode_state, "")


## Gets the store mode state
func get_store_mode() -> bool:
	return _store_mode_state


## Resolves the store mode by handing back a component to store to
func resolve_store_mode(with: EngineComponent) -> void:
	exit_store_mode()
	
	var fixtures: Array = Values.get_selection_value("selected_fixtures")
	Network.send_command("Programmer", "store_into", [with, fixtures])


## Resolves the store mode by handing back a classname for a new component
func resolve_store_mode_with_new(classname: String) -> Promise:
	exit_store_mode()
	
	var fixtures: Array = Values.get_selection_value("selected_fixtures")
	var promise: Promise = Network.send_command("Programmer", "store_into_new", [classname, fixtures])
	
	promise.then(_store_callback)
	return promise


## Store callback
func _store_callback(component: EngineComponent) -> void:
	Interface.show_name_prompt(component)
