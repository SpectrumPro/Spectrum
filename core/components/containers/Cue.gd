# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name Cue extends DataContainer
## Data container for CueLists, a Cue doesn't do anything by itself, and needs to be part of a CueList to work


## Emitted when the fade time it changed
signal fade_time_changed(new_fade_time: float)

## Emitted when the pre_wait time is changed
signal pre_wait_time_changed(pre_wait: float)

## Emitted when the cue number is changed
signal number_changed(new_number: float) 

## Emitted when the trigger mode it changed
signal trigger_mode_changed(trigger_mode: TRIGGER_MODE)

## Emitted when the timecode enabled state changes
signal timecode_enabled_state_changed(timecode_enabled: bool)

## Emitted when the timecode triggers change
signal timecode_trigger_changed(timecode_trigger: int)


## The index of this cue, do not modify this when it is a part of a cuelist
var number: float = 1.0 : 
	set(value):
		number = value
		number_changed.emit(number)

## Fade in time in seconds
var _fade_time: float = 2.0

## Pre-Wait time in seconds, how long to wait before this cue will activate, only works with TRIGGER_MODE.WITH_LAST / AFTER_LAST
var _pre_wait: float = 1.0

## Enumeration for the trigger modes
enum TRIGGER_MODE { MANUAL, AFTER_LAST, WITH_LAST }
var _trigger_mode: TRIGGER_MODE = TRIGGER_MODE.MANUAL

## Tracking flag, indicates if this cue tracks changes
var _tracking: bool = true

## Stores all the timecode frame counters that will trigger this cue
var _timecode_trigger: int = 0

## Enables timecode triggers on this cue
var _timecode_enabled: bool = false

## List of Functions that should be triggred during this cue, stored as {Function: [[method_name, [args...]]]}
var _function_triggers: Dictionary = {}


func _component_ready() -> void:
	_set_self_class("Cue")
	
	add_accessible_method("fade_time", [TYPE_FLOAT], set_fade_time, get_fade_time, fade_time_changed, ["Seconds"])
	add_accessible_method("pre_wait", [TYPE_FLOAT], set_pre_wait, get_pre_wait, pre_wait_time_changed, ["Seconds"])
	
	register_callback("on_fade_time_changed", _set_fade_time)
	register_callback("on_pre_wait_time_changed", _set_pre_wait)
	register_callback("on_trigger_mode_changed", _set_trigger_mode)
	register_callback("on_timecode_enabled_state_changed", _set_timecode_enabled)
	register_callback("on_timecode_trigger_changed", _set_timecode_trigger)


## Gets the cue number
func get_number() -> float: 
	return number


## Sets the fade time
func set_fade_time(p_fade_time: float) -> void: rpc("set_fade_time", [p_fade_time])

## Internal: Sets the fade time
func _set_fade_time(p_fade_time: float) -> void:
	_fade_time = p_fade_time
	fade_time_changed.emit(_fade_time)

## Gets the fade time
func get_fade_time() -> float: return _fade_time


## Sets the pre wait time
func set_pre_wait(p_set_pre_wait: float) -> void: rpc("set_pre_wait", [p_set_pre_wait])

## Internal: Sets the pre wait time
func _set_pre_wait(p_pre_wait: float) -> void:
	_pre_wait = p_pre_wait
	pre_wait_time_changed.emit(_pre_wait)

## Gets the pre wait time
func get_pre_wait() -> float: return _pre_wait


## Sets the trigger mode time
func set_trigger_mode(p_trigger_mode: TRIGGER_MODE) -> void: rpc("set_trigger_mode", [p_trigger_mode])

## Internal: Sets the trigger mode
func _set_trigger_mode(p_trigger_mode: TRIGGER_MODE) -> void:
	_trigger_mode = p_trigger_mode
	trigger_mode_changed.emit(_trigger_mode)

## Gets the trigger mode
func get_trigger_mode() -> TRIGGER_MODE: return _trigger_mode


## Enables or disables timecode triggers
func set_timecode_enabled(p_timecode_enabled: bool) -> void: rpc("set_timecode_enabled", [p_timecode_enabled])

## Internal: Enables or disables the timecode trigger
func _set_timecode_enabled(p_timecode_enabled: bool) -> void:
	p_timecode_enabled = p_timecode_enabled
	timecode_enabled_state_changed.emit(_timecode_enabled)

## Gets the timecode enabled state
func get_timecode_enabled() -> bool: return _timecode_enabled

## Adds a timecode trigger
func set_timecode_trigger(p_frame: int) -> void: rpc("set_timecode_trigger", [p_frame])

## Internal: Sets the timecode trigger
func _set_timecode_trigger(p_frame: int) -> void:
	_timecode_trigger = p_frame
	timecode_trigger_changed.emit(_timecode_trigger)

## Gets the timecode trigger
func get_timecode_trigger() -> int: return _timecode_trigger


## Sets the timecode trigger to the current frame as of calling this method
func set_timecode_now() -> void: 
	rpc("set_timecode_now")


func _load_request(serialized_data: Dictionary) -> void:
	number = serialized_data.get("number", number)
	_fade_time = serialized_data.get("fade_time", _fade_time)
	_pre_wait = serialized_data.get("pre_wait", _pre_wait)
	_trigger_mode = serialized_data.get("trigger_mode", _trigger_mode)
	_tracking = serialized_data.get("tracking", _tracking)
	
	_timecode_enabled = serialized_data.get("timecode_enabled", _timecode_enabled)
	_timecode_trigger = serialized_data.get("timecode_trigger", _timecode_trigger)
	
	_load(serialized_data.get("stored_data", {}))
