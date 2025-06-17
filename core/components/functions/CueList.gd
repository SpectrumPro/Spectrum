# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name CueList extends Function
## A list of cues


## Emitted when the active cue is changed
signal active_cue_changed(cue: Cue)

## Emitted when a cues crossfade is finished
signal cue_crossfade_finished(cue: Cue)

## Emitted when the global fade state is changed
signal global_fade_state_changed(use_global_fade: bool)

## Emitted when the global pre_wait state is changed
signal global_pre_wait_state_changed(use_global_pre_wait: bool)

## Emitted when the global fade is changed
signal global_fade_changed(global_fade: float)

## Emitted when the global pre_wait is changed
signal global_pre_wait_changed(global_pre_wait: float)

## Emitted when the allow triggered looping state is changed
signal triggered_looping_changed(allow_triggered_looping: bool)

## Emitted when the loop mode is changed
signal loop_mode_changed(loop_mode: LoopMode)

## Emitted when a cue is added to this CueList
signal cues_added(cues: Array)

## Emitted when a cue is removed from this CueList
signal cues_removed(cues: Array)

## Emitted when a cue's position has changed
signal cue_order_changed(cue: Cue, position: int)


## Loop mode, Reset: Reset all track and go to a default state, Track: Track changes while looping the cue list
enum LoopMode {RESET, TRACK}


## All the cues in the list
var _cues: Array[Cue]

## The current active cue
var _active_cue: Cue

## Global fade state
var _use_global_fade: bool = false

## Global pre wait state
var _use_global_pre_wait: bool = false

## Global fade time
var _global_fade: float = 1

## Global pre wait
var _global_pre_wait: float = 1

## Current loop mode for the cue list
var _loop_mode: LoopMode = LoopMode.RESET

## Allow cues with trigger modes to loop back to the start when reaching the end.
var _allow_triggered_looping: bool = false


func _component_ready() -> void:
	_set_name("CueList")
	_set_self_class("CueList")

	register_callback("on_active_cue_changed", _on_active_cue_changed)
	register_callback("on_global_fade_state_changed", _set_global_fade_state)
	register_callback("on_global_pre_wait_state_changed", set_global_pre_wait_state)
	register_callback("on_global_fade_changed", _set_global_fade_speed)
	register_callback("on_global_pre_wait_changed", _set_global_pre_wait_speed)
	register_callback("on_triggered_looping_changed", _set_allow_triggered_looping)
	register_callback("on_loop_mode_changed", _set_loop_mode)
	register_callback("on_cues_added", _add_cues)
	register_callback("on_cues_removed", _remove_cues)
	register_callback("cue_order_changed", _set_cue_position)
	
	register_control_method("Go Previous", go_previous)
	register_control_method("Go Next", go_next)
	register_control_method("Set Global Fade", set_global_fade_speed, get_global_fade_speed, global_fade_changed)
	register_control_method("Set Global Pre-Wait", set_global_pre_wait_speed, get_global_pre_wait_speed, global_pre_wait_changed)
	
	register_setting_bool("allow_triggered_looping", set_allow_triggered_looping, get_allow_triggered_looping, triggered_looping_changed)
	register_setting_bool("use_global_fade", set_global_fade_state, get_global_fade_state, global_fade_state_changed)
	register_setting_bool("use_global_pre_wait", set_global_pre_wait_state, get_global_pre_wait_state, global_pre_wait_state_changed)
	
	register_setting_float("global_fade", set_global_fade_speed, get_global_fade_speed, global_fade_changed, 0, INF)
	register_setting_float("global_pre_wait", set_global_pre_wait_speed, get_global_pre_wait_speed, global_pre_wait_changed, 0, INF)
	
	register_setting_enum("loop_mode", set_loop_mode, get_loop_mode, loop_mode_changed, LoopMode)


## Server: Adds a cue to the list
func add_cue(cue: Cue) -> Promise:
	return rpc("add_cue", [cue])


## Server: Removes a cue from the list
func remove_cue(cue: Cue) -> Promise:
	return rpc("remove_cue", [cue])


## Returns an ordored list of cues
func get_cues() -> Array[Cue]:
	return _cues.duplicate()


## Sets whether triggered cues can loop back to the start
func set_allow_triggered_looping(p_allow_triggered_looping: bool) -> Promise:
	return rpc("set_allow_triggered_looping", [p_allow_triggered_looping])


## Sets the loop mode
func set_loop_mode(p_loop_mode: LoopMode) -> Promise:
	return rpc("set_loop_mode", [p_loop_mode])


## Server: Sets the position of a cue in the list
func set_cue_position(cue: Cue, position: int) -> Promise:
	return rpc("set_cue_position", [cue, position])


## Server: Sets the global fade state
func set_global_fade_state(use_global_fade: bool) -> Promise:
	return rpc("set_global_fade_state", [use_global_fade])


## Server: Sets the global pre wait state
func set_global_pre_wait_state(use_global_pre_wait: bool) -> Promise:
	return rpc("set_global_pre_wait_state", [use_global_pre_wait])


## Server: Sets the global fade speed
func set_global_fade_speed(global_fade_speed: float) -> Promise:
	return rpc("set_global_fade_speed", [global_fade_speed])


## Server: Sets the global pre wait speed
func set_global_pre_wait_speed(global_pre_wait_speed: float) -> Promise:
	return rpc("set_global_pre_wait_speed", [global_pre_wait_speed])


## Gets the current loop mode
func get_loop_mode() -> LoopMode:
	return _loop_mode


## Gets whether triggered cues can loop back to the start
func get_allow_triggered_looping() -> bool:
	return _allow_triggered_looping


## Gets the global fade state
func get_global_fade_state() -> bool:
	return _use_global_fade


## Gets the global pre wait state
func get_global_pre_wait_state() -> bool:
	return _use_global_pre_wait


## Gets the global fade speed
func get_global_fade_speed() -> float:
	return _global_fade


## Gets the global pre wait speed
func get_global_pre_wait_speed() -> float:
	return _global_pre_wait


## Server: Seeks to the next cue in the list
func go_next() -> Promise:
	return rpc("go_next", [])


## Server: Seeks to the previous cue in the list
func go_previous() -> Promise:
	return rpc("go_previous", [])


## Server: Seeks to a cue
func seek_to(cue: Cue) -> Promise:
	return rpc("seek_to", [cue])



## Adds a cue to the list
func _add_cue(p_cue: Cue, p_no_signal: bool = false) -> bool:
	if p_cue in _cues:
		return false
	
	_cues.append(p_cue)
	p_cue.delete_requested.connect(_remove_cue.bind(p_cue))
	ComponentDB.register_component(p_cue)

	if not p_no_signal:
		cues_added.emit([p_cue])
	
	return true


## Adds mutiple cues
func _add_cues(p_cues: Array) -> void:
	var just_added_cues: Array[Cue]

	for cue: Variant in p_cues:
		if cue is Cue and _add_cue(cue, true):
			just_added_cues.append(cue)
	
	if just_added_cues:
		cues_added.emit(just_added_cues)


## Removes a cue from the list
func _remove_cue(p_cue: Cue, p_no_signal: bool = false) -> bool:
	if p_cue not in _cues:
		return false
	 
	_cues.erase(p_cue)
	Client.deregister_component(p_cue)

	if not p_no_signal:
		cues_removed.emit([p_cue])

	return true

## Removes mutiple cues
func _remove_cues(p_cues: Array) -> void:
	var just_removed_cues: Array[Cue]

	for cue: Variant in p_cues:
		if cue is Cue and _remove_cue(cue, true):
			just_removed_cues.append(cue)
	
	if just_removed_cues:
		cues_removed.emit(just_removed_cues)


## Internal: Sets the position of a cue in the list
func _set_cue_position(cue: Cue, position: int) -> void:
	if cue not in _cues:
		return
	
	var old_index: int = _cues.find(cue)
	_cues.insert(position, cue)
	_cues.remove_at(old_index)

	cue_order_changed.emit(cue, position)


## Internal: Sets whether triggered cues can loop back to the start
func _set_allow_triggered_looping(p_allow_triggered_looping: bool) -> void:
	if p_allow_triggered_looping == _allow_triggered_looping:
		return

	_allow_triggered_looping = p_allow_triggered_looping
	triggered_looping_changed.emit(_allow_triggered_looping)


## Internal Sets the loop mode
func _set_loop_mode(p_loop_mode: LoopMode) -> void:
	if _loop_mode == p_loop_mode:
		return

	_loop_mode = p_loop_mode
	loop_mode_changed.emit(_loop_mode)


## Internal: Sets the global fade state
func _set_global_fade_state(use_global_fade: bool) -> void:
	if _use_global_fade == use_global_fade:
		return
	
	_use_global_fade = use_global_fade
	global_fade_state_changed.emit(_use_global_fade)


## Internal: Sets the global pre wait state
func _set_global_pre_wait_state(use_global_pre_wait: bool) -> void:
	if _use_global_pre_wait == use_global_pre_wait:
		return
	
	_use_global_pre_wait = use_global_pre_wait
	global_pre_wait_state_changed.emit(_use_global_pre_wait)


## Internal: Sets the global fade speed
func _set_global_fade_speed(global_fade_speed: float) -> void:
	if _global_fade == global_fade_speed:
		return
	
	_global_fade = global_fade_speed
	global_fade_changed.emit(_global_fade)


## Internal: Sets the global pre wait speed
func _set_global_pre_wait_speed(global_pre_wait_speed: float) -> void:
	if _global_pre_wait == global_pre_wait_speed:
		return
	
	_global_pre_wait = global_pre_wait_speed
	global_pre_wait_changed.emit(_global_pre_wait)


## Internal: Called when the active cue is changed on the server
func _on_active_cue_changed(p_cue: Cue) -> void:
	_active_cue = p_cue
	active_cue_changed.emit(_active_cue)


## Saves this cue list to a Dictionary
func _serialize_request() -> Dictionary:
	return {
		"use_global_fade": _use_global_fade,
		"use_global_pre_wait": _use_global_pre_wait,
		"global_fade": _global_fade,
		"global_pre_wait": _global_pre_wait,
		"allow_triggered_looping": _allow_triggered_looping,
		"loop_mode": _loop_mode,
		"cues": Utils.seralise_component_array(_cues)
	}


## Loads this cue list from a Dictionary
func _load_request(serialized_data: Dictionary) -> void:
	_use_global_fade = type_convert(serialized_data.get("use_global_fade", _use_global_fade), TYPE_BOOL)
	_use_global_pre_wait = type_convert(serialized_data.get("use_global_pre_wait", _use_global_pre_wait), TYPE_BOOL)
	_global_fade = type_convert(serialized_data.get("global_fade", _global_fade), TYPE_FLOAT)
	_global_pre_wait = type_convert(serialized_data.get("global_pre_wait", _global_pre_wait), TYPE_FLOAT)
	_allow_triggered_looping = type_convert(serialized_data.get("allow_triggered_looping", _allow_triggered_looping), TYPE_BOOL)
	_loop_mode = type_convert(serialized_data.get("loop_mode", _loop_mode), TYPE_INT)

	_add_cues(Utils.deseralise_component_array(type_convert(serialized_data.get("cues", []), TYPE_ARRAY)))


## Called when this CueList is to be deleted
func _delete_request() -> void:
	for cue: Cue in _cues.duplicate():
		cue.local_delete()
