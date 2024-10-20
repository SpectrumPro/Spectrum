# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name Scene extends Function
## Engine class for creating and recalling saved data


## Emitted when the fade in time has changed
signal fade_in_speed_changed(fade_in_speed: float)

## Emitted when the fade out time has changed
signal fade_out_speed_changed(fade_out_speed: float)

## Emmitted when this scene is enabled or dissabled
signal state_changed(is_enabled: bool)


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
	
	add_accessible_method("enabled", set_enabled, is_enabled, state_changed)
	
	add_accessible_method("fade_in", set_fade_in_speed, get_fade_in_speed, fade_in_speed_changed)
	add_accessible_method("fade_out", set_fade_out_speed, get_fade_out_speed, fade_out_speed_changed)
	
	add_accessible_method("flash_hold", flash_hold)
	add_accessible_method("flash_release", flash_release)
	add_accessible_method("flash", flash)


#region Local Method
## Enabled or dissables this scene
func set_enabled(is_enabled: bool, fade_speed: float = -1) -> void: Client.send_command(uuid, "set_enabled", [is_enabled, fade_speed])
func is_enabled() -> bool: return enabled


## Sets the fade in speed in seconds
func set_fade_in_speed(speed: float) -> void: Client.send_command(uuid, "set_fade_in_speed", [speed])
func get_fade_in_speed() -> float: return fade_in_speed


## Sets the fade out speed in seconds
func set_fade_out_speed(speed: float) -> void: Client.send_command(uuid, "set_fade_out_speed", [speed])
func get_fade_out_speed() -> float: return fade_out_speed


## Flash hold and release functions
func flash_hold(fade_time: float = fade_in_speed) -> void: Client.send_command(uuid, "flash_hold", [fade_time])
func flash_release(fade_time: float = fade_out_speed) -> void: Client.send_command(uuid, "flash_release", [fade_time])

func flash(fade_in: float = fade_in_speed, fade_out: float = fade_out_speed, hold: float = 0.2) -> void: Client.send_command(uuid, "flash", [fade_in, fade_out, hold])
#endregion


#region Server Callbacks
## Called when the fade in time is changed on the server
func on_fade_in_speed_changed(p_fade_in_speed: float) -> void:
	fade_in_speed = p_fade_in_speed
	fade_in_speed_changed.emit(fade_in_speed)


## Called whem the fade out time is changed on the server
func on_fade_out_speed_changed(p_fade_out_speed: float) -> void:
	fade_out_speed = p_fade_out_speed
	fade_out_speed_changed.emit(fade_out_speed)


## INTERNAL: Called when the state is changed on the server
func on_state_changed(state: bool) -> void:
	state_changed.emit(state)
	enabled = state
#endregion


#region Internal Methods
func _on_serialize_request() -> Dictionary:
	## Serializes this scene and returnes it in a dictionary
	return {
		"fade_in_speed": fade_in_speed,
		"fade_out_speed": fade_out_speed,
	}


func _on_load_request(serialized_data: Dictionary) -> void:
	fade_in_speed = serialized_data.get("fade_in_speed", fade_in_speed)
	fade_out_speed = serialized_data.get("fade_out_speed", fade_out_speed)
	
	fade_in_speed_changed.emit(fade_in_speed)
	fade_out_speed_changed.emit(fade_out_speed)
	
	enabled = serialized_data.get("enabled", false)
	if enabled:
		state_changed.emit(enabled)
	
	_intensity = serialized_data.get("intensity", 0)
	if _intensity:
		intensity_changed.emit(_intensity)
#endregion
