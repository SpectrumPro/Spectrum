# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name Scene extends EngineComponent
## Engine class for creating and recalling saved data

signal state_changed(is_enabled: bool) ## Emmitted when this scene is enabled or dissabled
signal percentage_step_changed(percentage: float) ## Emitted when the step is changed, emits the current progress percentage of this scene

var fade_in_speed: float = 2 ## Fade in speed in seconds
var fade_out_speed: float = 2 ## Fade out speed in seconds

var enabled: bool = false ## The current state of this scene
var save_data: Dictionary = {} ## Saved data for this scene


## Enabled or dissables this scene
func set_enabled(is_enabled: bool, time: float = -1) -> void:
	Client.send({
		"for": self.uuid,
		"call": "set_enabled",
		"args": [is_enabled, time]
	})


func set_fade_in_speed(p_fade_in_speed: float) -> void:
	Client.send({
		"for": self.uuid,
		"call": "set_fade_in_speed",
		"args": [p_fade_in_speed]
	})


func set_fade_out_speed(p_fade_out_speed: float) -> void:
	Client.send({
		"for": self.uuid,
		"call": "set_fade_out_speed",
		"args": [p_fade_out_speed]
	})


## INTERNAL: Called when the fade speed is changed on the server
func on_fade_speed_changed(fade_in: float, fade_out: float) -> void:
	fade_in_speed = fade_in
	fade_out_speed = fade_out


## INTERNAL: Called when the state is changed on the server
func on_state_changed(state: bool) -> void:
	state_changed.emit(state)
	enabled = state
	print("State Chaged")


func set_step_percentage(percentage: float) -> void:
	Client.send({
		"for": self.uuid,
		"call": "set_step_percentage",
		"args": [percentage]
	})


## INTERNAL: Called when the percentage step is changed on the server
func on_percentage_step_changed(percentage: float) -> void:
	print(percentage)
	percentage_step_changed.emit(percentage)


func flash_hold(fade_time: float = fade_in_speed) -> void:
	Client.send({
		"for": self.uuid,
		"call": "flash_hold",
		"args": [fade_time]
	})


func flash_release(fade_time: float = fade_out_speed) -> void:
	Client.send({
		"for": self.uuid,
		"call": "flash_release",
		"args": [fade_time]
	})


func _on_serialize_request() -> Dictionary:
	## Serializes this scene and returnes it in a dictionary
	return {
		"fade_in_speed": fade_in_speed,
		"fade_out_speed": fade_out_speed,
	}


func on_load_request(serialized_data: Dictionary) -> void:
	fade_in_speed = serialized_data.get("fade_in_speed", fade_in_speed)
	fade_out_speed = serialized_data.get("fade_out_speed", fade_out_speed)
