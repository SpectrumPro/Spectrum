# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name CoreProgrammer extends Node
## Engine class for programming lights, colors, positions, etc.


## Save Modes
enum SAVE_MODE {
	MODIFIED,		## Only save fixtures that have been changed in the programmer
	ALL,			## Save all values of the fixtures
	ALL_NONE_ZERO	## Save all values of the fixtures, as long as they are not the zero value for that channel
}


## Clears the programmer
func clear() -> void: 
	Client.send_command("Programmer", "clear")


## Function to set the fixture data at the given chanel key
func set_parameter(p_fixtures: Array, p_parameter: String, p_value: float, p_zone: String) -> void:
	Client.send_command("Programmer", "set_parameter", [p_fixtures, p_parameter, p_value, p_zone])
