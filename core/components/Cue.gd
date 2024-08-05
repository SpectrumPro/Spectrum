# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name Cue extends EngineComponent
## Data container for CueLists, a Cue doesn't do anything by itself, and needs to be part of a CueList to work


## Emitted when the fade time it changed
signal fade_time_changed(new_fade_time: float)

## Emitted when the pre_wait time is changed
signal pre_wait_time_changed(pre_wait: float)

## Emitted when the cue number is changed
signal number_changed(new_number: float) 


## The index of this cue, do not modify this when it is a part of a cuelist
var number: float = 1.0 : 
	set(value):
		number = value
		number_changed.emit(number)

## Fade in time in seconds
var fade_time: float = 2.0

## Pre-Wait time in seconds, how long to wait before this cue will activate, only works with TRIGGER_MODE.WITH_LAST
var pre_wait: float = 1.0

## Post-Wait time in seconds, how long to wait before the next cue will activate, only works with TRIGGER_MODE.WITH_LAST
var post_wait: float = 1.0


## Enumeration for the trigger modes
enum TRIGGER_MODE { MANUAL, WITH_LAST }
var trigger_mode: TRIGGER_MODE = TRIGGER_MODE.MANUAL

## Tracking flag, indicates if this cue tracks changes
var tracking: bool = true


## Stores the saved fixture data to be animated, stored as {Fixture: [[method_name, value]]}
var stored_data: Dictionary = {} 

## List of Functions that should be triggred during this cue, stored as {Function: [[method_name, [args...]]]}
var function_triggers: Dictionary = {}


func _component_ready() -> void:
	self_class_name = "Cue"


## Stores data inside this cue
func _store_data(fixture: Fixture, method_name: String, value: Variant, default: Variant) -> bool:
	if typeof(value) != typeof(default):
		return false
	
	if not fixture in stored_data.keys():
		stored_data[fixture] = {}
	
	stored_data[fixture][method_name] = {
			"value": value, 
			"default": default
		}

	return true


## Sets the fade time
func set_fade_time(p_fade_time: float) -> void:
	Client.send_command(uuid, "set_fade_time", [p_fade_time])


## Sets the pre_wait time
func set_pre_wait(p_set_pre_wait: float) -> void:
	Client.send_command(uuid, "set_pre_wait", [p_set_pre_wait])


## INTERNAL: called when the fade time is changed on the server
func on_fade_time_changed(p_fade_time: float) -> void:
	fade_time = p_fade_time
	fade_time_changed.emit(fade_time)


## INTERNAL: called when the wait times are changed on the server
func on_pre_wait_time_changed(p_pre_wait) -> void:
	pre_wait = p_pre_wait
	pre_wait_time_changed.emit(pre_wait)


## Returnes a serialized copy of this cue
func _on_serialize_request() -> Dictionary:
	var serialized_stored_data: Dictionary = {}

	for fixture: Fixture in stored_data:
		for method_name: String in stored_data[fixture].keys():

			var stored_item: Dictionary = stored_data[fixture][method_name]

			if not fixture.uuid in serialized_stored_data:
				serialized_stored_data[fixture.uuid] = {}

			serialized_stored_data[fixture.uuid][method_name] = {
				"value": var_to_str(stored_item.value), 
				"default": var_to_str(stored_item.default)
			}


	var serialized_function_triggers: Dictionary = {}

	for function: Function in function_triggers:
		for stored_trigger: Array in function_triggers[function]:
			
			if not function.uuid in serialized_function_triggers:
				serialized_function_triggers[function.uuid] = []

			serialized_function_triggers[function.uuid].append([stored_trigger[0], var_to_str(stored_trigger[1])])

	return {
		"number": number,
		"fade_time": fade_time,
		"pre_wait": pre_wait,
		"post_wait": post_wait,
		"trigger_mode": trigger_mode,
		"tracking": tracking,
		"stored_data": serialized_stored_data,
		"function_triggers": serialized_function_triggers
	}


func _on_load_request(serialized_data: Dictionary) -> void:
	number = serialized_data.get("number", number)
	fade_time = serialized_data.get("fade_time", fade_time)
	pre_wait = serialized_data.get("pre_wait", pre_wait)
	post_wait = serialized_data.get("post_wait", post_wait)
	trigger_mode = serialized_data.get("trigger_mode", trigger_mode)
	tracking = serialized_data.get("tracking", tracking)

	for fixture_uuid: String in serialized_data.get("stored_data", {}).keys():
		if fixture_uuid in Core.fixtures:
			var fixture: Fixture = Core.fixtures[fixture_uuid]

			for method_name: String in serialized_data.stored_data[fixture_uuid]:
				var stored_item: Dictionary = serialized_data.stored_data[fixture_uuid][method_name]

				if fixture.has_method(method_name):
					_store_data(fixture, method_name, str_to_var(stored_item.get("value", "0")),  str_to_var(stored_item.get("default", "null"), ))
