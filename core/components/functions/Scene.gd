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
var _enabled: bool = false 

## Fade in time in seconds, defaults to 2 seconds
var _fade_in_speed: float = 2

## Fade out time in seconds, defaults to 2 seconds
var _fade_out_speed: float = 2


## Called when this EngineComponent is ready
func _component_ready() -> void:
	_set_self_class("Scene")
	
	add_accessible_method("enabled", [TYPE_BOOL], set_enabled, is_enabled, state_changed, ["Set Enable State"])
	add_accessible_method("enabled_with_fade", [TYPE_BOOL, TYPE_FLOAT], set_enabled, is_enabled, state_changed, ["Set Enable State", "Fade Speed"])
	
	add_accessible_method("fade_in", [TYPE_FLOAT], set_fade_in_speed, get_fade_in_speed, fade_in_speed_changed, ["In Seconds"])
	add_accessible_method("fade_out", [TYPE_FLOAT], set_fade_out_speed, get_fade_out_speed, fade_out_speed_changed, ["In Seconds"])
	
	add_accessible_method("flash_hold", [TYPE_FLOAT], flash_hold, Callable(), Signal(), ["Fade In Speed"])
	add_accessible_method("flash_release", [TYPE_FLOAT], flash_release, Callable(), Signal(), ["Fade Out Speed"])
	add_accessible_method("flash", [TYPE_FLOAT, TYPE_FLOAT, TYPE_FLOAT], flash, Callable(), Signal(), ["Fade In Speed", "Fade Out Speed", "Hold Time"])
	
	register_setting("Scene", "fade_in", set_fade_in_speed, get_fade_in_speed, fade_in_speed_changed, Utils.TYPE_FLOAT, 0, "Fade In Time", 0, INF)
	register_setting("Scene", "fade_out", set_fade_out_speed, get_fade_out_speed, fade_out_speed_changed, Utils.TYPE_FLOAT, 1, "Fade Out Time", 0, INF)
	
	register_callback("on_state_changed", _set_enabled)
	register_callback("on_fade_in_speed_changed", _set_fade_in_speed)
	register_callback("on_fade_out_speed_changed", _set_fade_out_speed)


#region Local Method
## Enabled or dissables this scene
func set_enabled(p_enabled: bool, p_fade_speed: float = -1) -> void: rpc("set_enabled", [p_enabled, p_fade_speed])
func is_enabled() -> bool: return _enabled


## Sets the fade in speed in seconds
func set_fade_in_speed(p_fade_in: float) -> void: rpc("set_fade_in_speed", [p_fade_in])
func get_fade_in_speed() -> float: return _fade_in_speed


## Sets the fade out speed in seconds
func set_fade_out_speed(p_fade_out: float) -> void: rpc("set_fade_out_speed", [p_fade_out])
func get_fade_out_speed() -> float: return _fade_out_speed


## Flash hold and release functions
func flash_hold(p_fade_time: float = _fade_in_speed) -> void: rpc("flash_hold", [p_fade_time])
func flash_release(p_fade_time: float = _fade_out_speed) -> void: rpc("flash_release", [p_fade_time])

func flash(p_fade_in: float = _fade_in_speed, p_fade_out: float = _fade_out_speed, p_hold: float = 0.2) -> void: rpc("flash", [p_fade_in, p_fade_out, p_hold])
#endregion


#region Server Callbacks
## Called when the fade in time is changed on the server
func _set_fade_in_speed(p_fade_in_speed: float) -> void:
	_fade_in_speed = p_fade_in_speed
	fade_in_speed_changed.emit(_fade_in_speed)


## Called whem the fade out time is changed on the server
func _set_fade_out_speed(p_fade_out_speed: float) -> void:
	_fade_out_speed = p_fade_out_speed
	fade_out_speed_changed.emit(_fade_out_speed)


## Called when the state is changed on the server
func _set_enabled(p_state: bool) -> void:
	state_changed.emit(p_state)
	_enabled = p_state
#endregion


#region Internal Methods
## Serializes this scene and returnes it in a dictionary
func _serialize_request() -> Dictionary:
	return {
		"fade_in_speed": _fade_in_speed,
		"fade_out_speed": _fade_out_speed,
		"save_data": _data_container.serialize()
	}


func _load_request(serialized_data: Dictionary) -> void:
	_fade_in_speed = serialized_data.get("fade_in_speed", _fade_in_speed)
	_fade_out_speed = serialized_data.get("fade_out_speed", _fade_out_speed)
	
	fade_in_speed_changed.emit(_fade_in_speed)
	fade_out_speed_changed.emit(_fade_out_speed)
	
	Client.remove_networked_object(_data_container.uuid)
	_data_container.load(serialized_data.get("save_data", {}))
	Client.add_networked_object(_data_container.uuid, _data_container)
	
	_enabled = serialized_data.get("enabled", false)
	if _enabled:
		state_changed.emit(_enabled)
	
	_intensity = serialized_data.get("intensity", 0)
	if _intensity:
		intensity_changed.emit(_intensity)
#endregion
