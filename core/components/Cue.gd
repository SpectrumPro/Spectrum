# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name Cue extends Function
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
var fade_time: float = 2.0

## Pre-Wait time in seconds, how long to wait before this cue will activate, only works with TRIGGER_MODE.WITH_LAST / AFTER_LAST
var pre_wait: float = 1.0

## Post-Wait time in seconds, how long to wait before the next cue will activate, only works with TRIGGER_MODE.WITH_LAST
var post_wait: float = 1.0


## Enumeration for the trigger modes
enum TRIGGER_MODE { MANUAL, AFTER_LAST, WITH_LAST }
var trigger_mode: TRIGGER_MODE = TRIGGER_MODE.MANUAL

## Tracking flag, indicates if this cue tracks changes
var tracking: bool = true

## Stores all the timecode frame counters that will trigger this cue
var timecode_trigger: int = 0

## Enables timecode triggers on this cue
var timecode_enabled: bool = false

## Stores the saved fixture data to be animated, stored as {Fixture: [[method_name, value]]}
var stored_data: Dictionary = {} 

## List of Functions that should be triggred during this cue, stored as {Function: [[method_name, [args...]]]}
var function_triggers: Dictionary = {}


func _component_ready() -> void:
	self_class_name = "Cue"
	icon = load("res://assets/icons/Cue.svg")
	
	add_accessible_method("fade_time", [TYPE_FLOAT], set_fade_time, get_fade_time, fade_time_changed, ["Seconds"])
	add_accessible_method("pre_wait", [TYPE_FLOAT], set_pre_wait, get_pre_wait, pre_wait_time_changed, ["Seconds"])


## Stores data inside this cue
func _store_data(fixture: Fixture, method_name: String, value: Variant) -> bool:
	if not fixture in stored_data.keys():
		stored_data[fixture] = {}
	
	stored_data[fixture][method_name] = {
			"value": value, 
		}
	
	return true


#region Local Methods

## Sets the fade time
func set_fade_time(p_fade_time: float) -> void: Client.send_command(uuid, "set_fade_time", [p_fade_time])
func get_fade_time() -> float: return fade_time

## Sets the pre_wait time
func set_pre_wait(p_set_pre_wait: float) -> void: Client.send_command(uuid, "set_pre_wait", [p_set_pre_wait])
func get_pre_wait() -> float: return pre_wait

## Sets the trigger mode time
func set_trigger_mode(p_trigger_mode: TRIGGER_MODE) -> void: Client.send_command(uuid, "set_trigger_mode", [p_trigger_mode])
func get_trigger_mode() -> TRIGGER_MODE: return trigger_mode

## Enables or disables timecode triggers
func set_timecode_enabled(p_timecode_enabled: bool) -> void: Client.send_command(uuid, "set_timecode_enabled", [p_timecode_enabled])
func get_timecode_enabled() -> bool: return timecode_enabled

## Adds a timecode trigger
func set_timecode_trigger(frame: int) -> void: Client.send_command(uuid, "set_timecode_trigger", [frame])
func get_timecode_trigger() -> int: return timecode_trigger

## Sets the timecode trigger to the current frame as of calling this method
func set_timecode_now() -> void: Client.send_command(uuid, "set_timecode_now")

## Getter for number
func get_number() -> float: return number
#endregion


#region Server Methods

## INTERNAL: called when the fade time is changed on the server
func on_fade_time_changed(p_fade_time: float) -> void:
	fade_time = p_fade_time
	fade_time_changed.emit(fade_time)


## INTERNAL: called when the wait times are changed on the server
func on_pre_wait_time_changed(p_pre_wait) -> void:
	pre_wait = p_pre_wait
	pre_wait_time_changed.emit(pre_wait)


## INTERNAL: called when the trigger mode is changed on the server
func on_trigger_mode_changed(p_trigger_mode: TRIGGER_MODE) -> void:
	trigger_mode = p_trigger_mode
	trigger_mode_changed.emit(trigger_mode)


## INTERNAL: Called when the timecode enabled state is changed on the server
func on_timecode_enabled_state_changed(p_timecode_enabled: bool) -> void:
	timecode_enabled = p_timecode_enabled
	timecode_enabled_state_changed.emit(timecode_enabled)


## INTERNAL: Called when the timecode triggers change on the server
func on_timecode_trigger_changed(p_timecode_trigger: int) -> void:
	timecode_trigger = p_timecode_trigger
	
	timecode_trigger_changed.emit(timecode_trigger)


func on_data_stored(fixture: Fixture, channel_key: String, value: Variant) -> void:
	_store_data_static(fixture, channel_key, value, stored_data)
#endregion


#region Internal Methods

func on_data_eraced(fixture: Fixture, channel_key: String) -> void:
	_erace_data_static(fixture, channel_key, stored_data)


func _on_load_request(serialized_data: Dictionary) -> void:
	number = serialized_data.get("number", number)
	fade_time = serialized_data.get("fade_time", fade_time)
	pre_wait = serialized_data.get("pre_wait", pre_wait)
	post_wait = serialized_data.get("post_wait", post_wait)
	trigger_mode = serialized_data.get("trigger_mode", trigger_mode)
	tracking = serialized_data.get("tracking", tracking)
	
	timecode_enabled = serialized_data.get("timecode_enabled", timecode_enabled)
	timecode_trigger = serialized_data.get("timecode_trigger", timecode_trigger)
	
	_load_stored_data(serialized_data.get("stored_data", {}), stored_data)
#endregion
