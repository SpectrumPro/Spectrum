# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name Scene extends Function
## Engine class for creating and recalling saved data


## Emitted when the fade in time has changed
signal fade_in_speed_changed(fade_in_speed: float)

## Emitted when the fade out time has changed
signal fade_out_speed_changed(fade_out_speed: float)


## Fade in time in seconds, defaults to 2 seconds
var _fade_in_speed: float = 2

## Fade out time in seconds, defaults to 2 seconds
var _fade_out_speed: float = 2


## Called when this EngineComponent is ready
func _component_ready() -> void:
	_set_self_class("Scene")
	
	#register_control_method("fade_in_speed", set_fade_in_speed, get_fade_in_speed, fade_in_speed_changed, [TYPE_FLOAT])
	#register_control_method("fade_out_speed", set_fade_out_speed, get_fade_out_speed, fade_out_speed_changed, [TYPE_FLOAT])
	##
	#register_setting("Scene", "fade_in", set_fade_in_speed, get_fade_in_speed, fade_in_speed_changed, Utils.TYPE_FLOAT, 0, "Fade In Time", 0, INF)
	#register_setting("Scene", "fade_out", set_fade_out_speed, get_fade_out_speed, fade_out_speed_changed, Utils.TYPE_FLOAT, 1, "Fade Out Time", 0, INF)
	#
	register_callback("on_fade_in_speed_changed", _set_fade_in_speed)
	register_callback("on_fade_out_speed_changed", _set_fade_out_speed)


## Sets the fade in speed in seconds
func set_fade_in_speed(p_fade_in: float) -> void: 
	rpc("set_fade_in_speed", [p_fade_in])


## Gets the current fade speed
func get_fade_in_speed() -> float: 
	return _fade_in_speed


## Sets the fade out speed in seconds
func set_fade_out_speed(p_fade_out: float) -> void: 
	rpc("set_fade_out_speed", [p_fade_out])


## Gets the fade out speed
func get_fade_out_speed() -> float: 
	return _fade_out_speed


## Called when the fade in time is changed on the server
func _set_fade_in_speed(p_fade_in_speed: float) -> void:
	_fade_in_speed = p_fade_in_speed
	fade_in_speed_changed.emit(_fade_in_speed)


## Called whem the fade out time is changed on the server
func _set_fade_out_speed(p_fade_out_speed: float) -> void:
	_fade_out_speed = p_fade_out_speed
	fade_out_speed_changed.emit(_fade_out_speed)


## Serializes this scene and returnes it in a dictionary
func _serialize_request() -> Dictionary:
	return {
		"fade_in_speed": _fade_in_speed,
		"fade_out_speed": _fade_out_speed,
		"save_data": _data_container.serialize()
	}


func _load_request(serialized_data: Dictionary) -> void:
	_fade_in_speed = type_convert(serialized_data.get("fade_in_speed", _fade_in_speed), TYPE_FLOAT)
	_fade_out_speed = type_convert(serialized_data.get("fade_out_speed", _fade_out_speed), TYPE_FLOAT)
	
	Network.remove_networked_object(_data_container.uuid())
	_data_container.load(serialized_data.get("save_data", {}))
	Network.add_networked_object(_data_container.uuid(), _data_container.settings())
