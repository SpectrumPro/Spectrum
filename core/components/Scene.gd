# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name Scene extends Function
## Engine class for creating and recalling saved data

signal state_changed(is_enabled: bool) ## Emmitted when this scene is enabled or dissabled
signal percentage_step_changed(percentage: float) ## Emitted when the step is changed, emits the current progress percentage of this scene

var enabled: bool = false ## The current state of this scene
var percentage_step: float = 0 ## The percentage step of this scene
var save_data: Dictionary = {} ## Saved data for this scene


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


## INTERNAL: Called when the percentage step is changed on the server
func on_percentage_step_changed(percentage: float) -> void:
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
	
	enabled = serialized_data.get("enabled", false)
	if enabled:
		state_changed.emit(enabled)
	
	percentage_step = serialized_data.get("percentage_step", 0)
	if percentage_step:
		percentage_step_changed.emit(percentage_step)
