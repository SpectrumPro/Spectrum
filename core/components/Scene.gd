# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name Scene extends Function
## Engine class for creating and recalling saved data


## Emitted when the fade speed has changed
signal fade_time_changed(fade_in_speed: float, fade_out_speed: float)

## Emmitted when this scene is enabled or dissabled
signal state_changed(is_enabled: bool)

## Emitted when the step is changed, emits the current progress percentage of this scene
signal percentage_step_changed(percentage: float)


## The current state of this scene
var enabled: bool = false 

## The percentage step of this scene
var percentage_step: float = 0

## Saved data for this scene
var save_data: Dictionary = {} 

## Fade in time in seconds, defaults to 2 seconds
var fade_in_speed: float = 2

## Fade out time in seconds, defaults to 2 seconds
var fade_out_speed: float = 2


## Called when this EngineComponent is ready
func _component_ready() -> void:
	name = "Scene"
	self_class_name = "Scene"


## Enabled or dissables this scene
func set_enabled(is_enabled: bool, time: float = -1) -> void:
	Client.send({
		"for": self.uuid,
		"call": "set_enabled",
		"args": [is_enabled, time]
	})


## INTERNAL: Called when the state is changed on the server
func on_state_changed(state: bool) -> void:
	state_changed.emit(state)
	enabled = state


func set_step_percentage(percentage: float) -> void:
	Client.send({
		"for": self.uuid,
		"call": "set_step_percentage",
		"args": [percentage]
	})


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



## INTERNAL: Called when the percentage step is changed on the server
func on_percentage_step_changed(percentage: float) -> void:
	percentage_step_changed.emit(percentage)


## INTERNAL: Called when the fade speed is changed on the server
func on_fade_time_changed(p_fade_in_speed: float, p_fade_out_speed: float):
	fade_in_speed = p_fade_in_speed
	fade_out_speed = p_fade_out_speed
	
	fade_time_changed.emit(fade_in_speed, fade_out_speed)


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


func _on_load_request(serialized_data: Dictionary) -> void:
	fade_in_speed = serialized_data.get("fade_in_speed", fade_in_speed)
	fade_out_speed = serialized_data.get("fade_out_speed", fade_out_speed)
	
	enabled = serialized_data.get("enabled", false)
	if enabled:
		state_changed.emit(enabled)
	
	percentage_step = serialized_data.get("percentage_step", 0)
	if percentage_step:
		percentage_step_changed.emit(percentage_step)
