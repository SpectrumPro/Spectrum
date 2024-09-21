# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name Programmer extends EngineComponent
## Engine class for programming lights, colors, positions, etc.


## Save Modes
enum SAVE_MODE {
	MODIFIED,		## Only save fixtures that have been changed in the programmer
	ALL,			## Save all values of the fixtures
	ALL_NONE_ZERO	## Save all values of the fixtures, as long as they are not the zero value for that channel
}


## Called when this EngineComponent is ready
func _component_ready() -> void:
	name = "Programmer"
	self_class_name = "Programmer"


## Sets the color of all the fixtures in fixtures, to color
func set_color(fixtures: Array, color: Color) -> void:
	
	Client.send({
		"for": "programmer",
		"call": "set_color",
		"args": [fixtures, color]
	})
