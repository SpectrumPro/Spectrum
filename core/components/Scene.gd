# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name Scene extends EngineComponent
## Engine class for creating and recalling saved data

signal state_changed(is_enabled: bool) ## Emmitted when this scene is enabled or dissabled

var fade_in_speed: int = 100 ## Fade in speed in ms
var fade_out_speed: int = 100 ## Fade out speed in ms

var enabled: bool = false: set = set_enabled ## The current state of this scene

var save_data: Dictionary = {}

func set_enabled(is_enabled: bool) -> void:
	enabled = is_enabled
	
	print(enabled)
	
	if is_enabled:
		for fixture: Fixture in save_data.keys():
			fixture.set_color(save_data[fixture].color)
	
