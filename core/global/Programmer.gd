# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name CoreProgrammer extends Node
## Engine class for programming lights, colors, positions, etc.


## Emitted when the programmer is cleared
signal cleared()


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


## Network Config:
var network_config: Dictionary = {
	"callbacks": {
		"on_cleared": _clear,
	}
}


## Clears the programmer
func clear() -> Promise: 
	return Client.send_command("Programmer", "clear")


## Called when the programmer is cleared on the server
func _clear() -> void:
	cleared.emit()


## Function to set the fixture data at the given chanel key
func set_parameter(p_fixtures: Array, p_parameter: String, p_function: String, p_value: float, p_zone: String) -> Promise:
	return Client.send_command("Programmer", "set_parameter", [p_fixtures, p_parameter, p_function, p_value, p_zone])


## Sets a fixture parameter to a random value
func set_parameter_random(p_fixtures: Array, p_parameter: String, p_function: String, p_zone: String, p_mode: RandomMode) -> Promise:
	return Client.send_command("Programmer", "set_parameter_random", [p_fixtures, p_parameter, p_function, p_zone, p_mode])


## Erases a parameter
func erase_parameter(p_fixtures: Array, p_parameter: String, p_zone: String) -> Promise:
	return Client.send_command("Programmer", "erase_parameter", [p_fixtures, p_parameter, p_zone])


## Saves the current state of this programmer to a scene
func save_to_scene(fixtures: Array, mode: SaveMode = SaveMode.MODIFIED) -> Promise:
	return Client.send_command("Programmer", "save_to_scene", [fixtures, mode])
