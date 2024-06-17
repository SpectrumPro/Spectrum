# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name Function extends EngineComponent
## Base class for all functions, scenes, cuelists ect


## Emitted when the fade speed has changed
signal fade_time_changed(fade_in_speed: float, fade_out_speed: float)


## Fade in time in seconds, defaults to 2 seconds
var fade_in_speed: float = 2


## Fade out time in seconds, defaults to 2 seconds
var fade_out_speed: float = 2


## Sets the fade in speed in seconds
func set_fade_in_speed(speed: float) -> void:
	Client.send({
		"for": uuid,
		"call": "set_fade_in_speed",
		"args": [speed]
	})


## Sets the fade out speed in seconds
func set_fade_out_speed(speed: float) -> void:
	Client.send({
		"for": uuid,
		"call": "set_fade_out_speed",
		"args": [speed]
	})


## INTERNAL: Called when the fade speed is changed on the server
func on_fade_time_changed(p_fade_in_speed: float, p_fade_out_speed: float):
	fade_in_speed = p_fade_in_speed
	fade_out_speed = p_fade_out_speed
	
	fade_time_changed.emit(fade_in_speed, fade_out_speed)
