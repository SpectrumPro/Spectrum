# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name Programmer extends EngineComponent
## Engine class for programming lights, colors, positions, etc. This also handles conversion from Godots color system to dmx colors

var save_data: Dictionary = {} ## Current data in the programmer

func set_color(fixtures: Array, color: Color) -> void:
	## Sets the color of all the fixtures in fixtures, to color
	
	for fixture: Fixture in fixtures:
		fixture.set_color(color, "programmer")
		
		if fixture not in save_data:
			save_data[fixture] = {}
		
		save_data[fixture].color = color


func save_to_scene(name: String = "New Scene") -> Scene:
	## Saves the current state of this programmer to a scene
	
	var new_scene: Scene = Scene.new()
	
	print(save_data)
	new_scene.set_save_data(save_data.duplicate(true))
	new_scene.name = name
	
	Core.add_scene("Scene " + str(len(Core.scenes.keys())), new_scene)
	
	return new_scene
