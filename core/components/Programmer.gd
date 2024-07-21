# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name Programmer extends EngineComponent
## Engine class for programming lights, colors, positions, etc.


enum SAVE_MODE {ALL, MODIFIED}

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


## Sets the white intensity of all the fixtures pass in [pram fixtures] 
func set_white_intensity(fixtures: Array, value: int) -> void:
	Client.send({
		"for": "programmer",
		"call": "set_white_intensity",
		"args": [fixtures, value]
	})


## Saves the current state of this programmer to a scene
func save_to_scene(name: String = "New Scene") -> void:
	
	Client.send({
		"for": "programmer",
		"call": "save_to_scene",
		"args": [name]
	})
