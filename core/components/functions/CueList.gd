# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name CueList extends Function
## Stores a list of Cues, that are enabled and disabled in order one after another


## Emitted when the current cue is changed
signal cue_changed(cue_number: float)

## Emitted when this CueList starts playing
signal played(index: float)

## Emitted when this CueList is paused
signal paused(index: float)

## Emitted when a cue is moved in this list
signal cue_moved(scene: Scene, to: float)

## Emitted when a cue is added to this CueList
signal cues_added(cues: Array)

## Emitted when a cue is removed form this CueList
signal cues_removed(cues: Array)

## Emitted when cue numbers are changed, stored as {Cue:new_number, ...}
signal cue_numbers_changed(new_numbers: Dictionary)

## Emitted when the mode is changed
signal mode_changed(mode: MODE)


## The current cue
var _current_cue: Cue = null

## The current mode of this cuelist. When in loop mode the cuelist will not reset fixtures to 0-value when looping back to the start
enum MODE {NORMAL, LOOP}
var _mode: int = MODE.NORMAL

## Stores all the cues, theese are stored unordored
var _cues: Dictionary = {}

## Stores an ordored list of all the cue indexes
var _index_list: Array = []

## Is this cue autoplaying
var _autoplay: bool = false


func _component_ready() -> void:
	_set_self_class("CueList")
	
	add_accessible_method("play", [TYPE_NIL], play, is_playing, played)
	add_accessible_method("pause", [TYPE_NIL], pause, is_playing, paused)
	add_accessible_method("stop", [TYPE_NIL], stop, get_current_cue_number, cue_changed)
	
	add_accessible_method("go_next", [TYPE_NIL], go_next)
	add_accessible_method("go_previous", [TYPE_NIL], go_previous)
	
	add_accessible_method("seek_to", [TYPE_FLOAT], seek_to, get_current_cue_number, cue_changed, ["Cue Number"])
	
	add_accessible_method("set_mode", [TYPE_INT], set_mode, get_mode, mode_changed, ["Loop Mode, 0: Normal, 1: Loop"])
	add_accessible_method("global_fade_time", [TYPE_FLOAT], set_global_fade_time, Callable(), Signal(), ["Fade Time"])
	add_accessible_method("global_pre_wait", [TYPE_FLOAT], set_global_pre_wait, Callable(), Signal(), ["Fade Time"])
	
	register_callback("on_cue_changed", _seek_to)
	register_callback("on_played", _play)
	register_callback("on_paused", _pause)
	register_callback("on_stopped", _stop)
	register_callback("on_cues_added", _add_cues)
	register_callback("on_cues_removed", _remove_cues)
	register_callback("on_cue_numbers_changed", _change_cue_numbers)
	register_callback("on_mode_changed", _change_mode)



## Plays this CueList, starting at index, or from the current index
func play() -> void: Client.send_command(uuid, "play")
func is_playing() -> bool: return _autoplay

## Stopes the CueList, will fade out all running scnes, using fade_out_speed, otherwise will use the fade_out_speed of the current index
func stop() -> void: Client.send_command(uuid, "stop")

## Advances to the next cue in the list
func go_next() -> void: Client.send_command(uuid, "go_next")

## Retuens to the previous cue in the list
func go_previous() -> void: Client.send_command(uuid, "go_previous")

## Skips to the cue provided in index
func seek_to(cue_index: float) -> void: Client.send_command(uuid, "seek_to", [cue_index])
func get_current_cue_number() -> float: return _current_cue.number if _current_cue else -1
func get_current_cue() -> Cue: return _current_cue

## Moves the cue at cue_number up. By swappign the number with the next cue in the list
func move_cue_up(cue_number: float) -> void: Client.send_command(uuid, "move_cue_up", [cue_number])

## Moves the cue at cue_number down. By swappign the number with the previous cue in the list
func move_cue_down(cue_number: float) -> void: Client.send_command(uuid, "move_cue_down", [cue_number])

## Changes the number of a cue
func set_cue_number(new_number: float, cue: Cue) -> void: Client.send_command(uuid, "set_cue_number", [new_number, cue])

## Duplicates a cue
func duplicate_cue(cue_number: float) -> void: Client.send_command(uuid, "duplicate_cue", [cue_number])

## Changes the current mode
func set_mode(p_mode: MODE) -> void: Client.send_command(uuid, "set_mode", [p_mode])
func get_mode() -> MODE: return _mode

## Sets the fade time for all cues
func set_global_fade_time(fade_time: float) -> void: Client.send_command(uuid, "set_global_fade_time", [fade_time])

## Sets the pre wait time for all cues
func set_global_pre_wait(pre_wait: float) -> void: Client.send_command(uuid, "set_global_pre_wait", [pre_wait])


## Gets the index list
func get_index_list() -> Array: 
	return _index_list


## Returns the index of a cue
func get_cue_index(p_cue: Cue) -> int:
	return _index_list.find(p_cue.number)


## Gets a cue from a cue number
func get_cue(p_cue_number: float) -> Cue:
	return _cues.get(p_cue_number)


## Internal: Seeks to a cue
func _seek_to(p_cue_number: float) -> void:
	if p_cue_number in _cues:
		_current_cue = _cues[p_cue_number]
	else:
		_current_cue = null
	
	cue_changed.emit(p_cue_number)


## Internal: Plays this cuelist 
func _play():
	_autoplay = true
	played.emit()


## Internal: Pauses this cuelist
func _pause():
	_autoplay = false
	paused.emit()


## Internal: Stops this cuelist
func _stop():
	_autoplay = false
	_current_cue = null
	cue_changed.emit(-1)


## Internal: Adds cues to this cuelist
func _add_cues(p_cues: Array) -> void:
	for cue in p_cues:
		if cue is Cue:
			_add_cue(cue, cue.number)


## Adds a pre existing cue to this CueList
## Returnes false if the cue already exists in this list, or if the index is already in use
func _add_cue(cue: Cue, number: float = 0, no_signal: bool = false) -> bool:
	_cues[number] = cue
	_index_list.append(number)
	_index_list.sort()
	
	ComponentDB.register_component(cue)
	
	if not no_signal:
		cues_added.emit([cue])
	
	return true


## Internal: Removes cues from this cuelist
func _remove_cues(p_cues: Array) -> void:
	var just_removed_cues: Array[Cue] = []
	
	for cue in p_cues:
		if cue is Cue and cue.number in _cues: 
			_index_list.erase(cue.number)
			_cues.erase(cue.number)
			
			just_removed_cues.append(cue)
	
	if just_removed_cues:
		cues_removed.emit(just_removed_cues)


## INTERNAL: Called when cue numbers are changed on the server
func _change_cue_numbers(new_numbers: Dictionary) -> void:
	for new_number: float in new_numbers.keys():
		var cue: Cue = new_numbers[new_number]
		_index_list.erase(cue.number)
		_cues.erase(cue.number)
		
	for new_number: float in new_numbers.keys():
		var cue: Cue = new_numbers[new_number]
		_index_list.append(new_number)
		_index_list.sort()

		_cues[new_number] = cue
		cue.number = new_number
	
	cue_numbers_changed.emit(new_numbers)


## Internal: Changes the mode
func _change_mode(p_mode: MODE) -> void:
	_mode = p_mode
	mode_changed.emit(_mode)


## Loads this CueList from a dictionary
func _load_request(serialized_data: Dictionary) -> void:
	_mode = int(serialized_data.get("mode", MODE.NORMAL))
	
	var just_added_cues: Array = []
	
	for cue_index: String in serialized_data.get("cues").keys():
		var new_cue: Cue = Cue.new(serialized_data.cues[cue_index].uuid, serialized_data.cues[cue_index].name)
		new_cue.load(serialized_data.cues[cue_index])
		
		if _add_cue(new_cue, float(cue_index), true):
			just_added_cues.append(new_cue)
	
	if just_added_cues:
		cues_added.emit(just_added_cues)
	
	var index: Variant = serialized_data.get("index")
	if index is int and index != -1:
		_seek_to(_index_list[serialized_data.get("index")])
		
	_intensity = serialized_data.get("intensity", 1)
	intensity_changed.emit(_intensity)


## Called when this CueList is to be deleted
func _delete_request() -> void:
	for cue: Cue in _cues.values():
		cue.local_delete()
