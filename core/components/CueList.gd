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


## The current cue number
var current_cue_number: float = -1

## The current active, and previous active cue
var current_cue: Cue = null
var last_cue: Cue = null

## The current mode of this cuelist. When in loop mode the cuelist will not reset fixtures to 0-value when looping back to the start
enum MODE {NORMAL, LOOP}
var mode: int = MODE.NORMAL

## Stores all the cues, theese are stored unordored
var cues: Dictionary = {}

## Stores an ordored list of all the cue indexes
var index_list: Array = []

var _is_playing: bool = false

func _component_ready() -> void:
	self_class_name = "CueList"
	icon = load("res://assets/icons/CueList.svg")
	
	add_accessible_method("play", [TYPE_NIL], play, is_playing, played)
	add_accessible_method("pause", [TYPE_NIL], pause, is_playing, paused)
	add_accessible_method("stop", [TYPE_NIL], stop, get_current_cue_number, cue_changed)
	
	add_accessible_method("go_next", [TYPE_NIL], go_next)
	add_accessible_method("go_previous", [TYPE_NIL], go_previous)
	
	add_accessible_method("seek_to", [TYPE_FLOAT], seek_to, get_current_cue_number, cue_changed, ["Cue Number"])
	
	add_accessible_method("set_mode", [TYPE_INT], set_mode, get_mode, mode_changed, ["Loop Mode, 0: Normal, 1: Loop"])


#region Local Methods

## Plays this CueList, starting at index, or from the current index
func play() -> void: Client.send_command(uuid, "play")
func is_playing() -> bool: return _is_playing

## Pauses the CueList at the current state
func pause() -> void: Client.send_command(uuid, "pause")

## Stopes the CueList, will fade out all running scnes, using fade_out_speed, otherwise will use the fade_out_speed of the current index
func stop() -> void: Client.send_command(uuid, "stop")

## Advances to the next cue in the list
func go_next() -> void: Client.send_command(uuid, "go_next")

## Retuens to the previous cue in the list
func go_previous() -> void: Client.send_command(uuid, "go_previous")

## Skips to the cue provided in index
func seek_to(cue_index: float) -> void: Client.send_command(uuid, "seek_to", [cue_index])
func get_current_cue_number() -> float: return current_cue_number

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
func get_mode() -> MODE: return mode
#endregion



#region Server Methods
## INTERNAL: Called when the number is changed on the server
func on_cue_changed(cue_number: float) -> void:
	current_cue_number = cue_number
	cue_changed.emit(current_cue_number)


## INTERNAL: Called when this cuelist is played on the server
func on_played():
	_is_playing = true
	played.emit()


## INTERNAL: Called when this cuelist is played on the server
func on_paused():
	_is_playing = false
	paused.emit()


## INTERNAL: Called when this cuelist is stopped on the server
func on_stopped():
	_is_playing = false
	current_cue_number = -1
	
	cue_changed.emit(current_cue_number)


## INTERNAL: Called when a cue is added on the server
func on_cues_added(p_cues: Array) -> void:
	for cue in p_cues:
		if cue is Cue:
			_add_cue(cue, cue.number)


## Adds a pre existing cue to this CueList
## Returnes false if the cue already exists in this list, or if the index is already in use
func _add_cue(cue: Cue, number: float = 0, no_signal: bool = false) -> bool:
	cues[number] = cue
	index_list.append(number)
	index_list.sort()
	
	Client.add_networked_object(cue.uuid, cue, cue.delete_requested)
	ComponentDB.register_component(cue)

	
	if not no_signal:
		cues_added.emit([cue])
	
	return true


## INTERNAL: Called when a cue is removed from the server
func on_cues_removed(p_cues: Array) -> void:
	
	var just_removed_cues: Array = []
	
	for cue in p_cues:
		if cue is Cue and cue.number in cues: 
			index_list.erase(cue.number)
			cues.erase(cue.number)
			
			just_removed_cues.append(cue)
	
	if just_removed_cues:
		cues_removed.emit(just_removed_cues)


## INTERNAL: Called when cue numbers are changed on the server
func on_cue_numbers_changed(new_numbers: Dictionary) -> void:
	for new_number: float in new_numbers.keys():
		var cue: Cue = new_numbers[new_number]
		index_list.erase(cue.number)
		cues.erase(cue.number)
		
	for new_number: float in new_numbers.keys():
		var cue: Cue = new_numbers[new_number]
		index_list.append(new_number)
		index_list.sort()

		cues[new_number] = cue
		cue.number = new_number
	
	cue_numbers_changed.emit(new_numbers)


## INTERNAL: Called when the mode is changed on the server
func on_mode_changed(p_mode: MODE) -> void:
	mode = p_mode
	mode_changed.emit(mode)
#endregion



#region Local Methods
func _on_load_request(serialized_data: Dictionary) -> void:
	mode = int(serialized_data.get("mode", MODE.NORMAL))
	
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
		on_cue_changed(index_list[serialized_data.get("index")])
		
	_intensity = serialized_data.get("intensity", 1)
	intensity_changed.emit(_intensity)



func _on_delete_request() -> void:
	for cue: Cue in cues.values():
		cue.on_delete_requested()
#endregion
