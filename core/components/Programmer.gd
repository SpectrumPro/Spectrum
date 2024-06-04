# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name Programmer extends EngineComponent
## Engine class for programming lights, colors, positions, etc. This also handles conversion from Godots color system to dmx colors

var save_data: Dictionary = {} ## Current data in the programmer

func set_color(fixtures: Array, color: Color) -> void:
	## Sets the color of all the fixtures in fixtures, to color
	
	Client.send({
		"for": "programmer",
		"call": "set_color",
		"args": [fixtures, color]
	})


func save_to_scene(name: String = "New Scene") -> void:
	## Saves the current state of this programmer to a scene
	
	Client.send({
		"for": "programmer",
		"call": "save_to_scene",
		"args": [name]
	})
