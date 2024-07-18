# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name CueList extends Function
## Stores a list of Scenes, that are enabled and disabled in order one after another

#
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

## Emitted when a cue's fade in time, out, or hold time is changed
signal cue_timings_changed(index: float, fade_in_time: float, fade_out_time: float, hold_time: float)


## The current cue number
var current_cue_number: int = -1

## The current active, and previous active cue
var current_cue: Cue = null
var last_cue: Cue = null

## Stores all the cues, theese are stored unordored
var cues: Dictionary = {}

## Stores an ordored list of all the cue indexes
var index_list: Array = []

var _is_playing: bool = false

func _component_ready() -> void:
	name = "CueList"
	self_class_name = "CueList"


## Adds a pre existing cue to this CueList
## Returnes false if the cue already exists in this list, or if the index is already in use
func _add_cue(cue: Cue, index: float = 0) -> bool:

	if index <= 0:
		index = (index_list[-1] + 1) if index_list else 1

	if cue in cues.values() or index in index_list:
		return false

	cues[index] = cue
	index_list.append(index)
	index_list.sort()
	
	return true


## Plays this CueList, starting at index, or from the current index if one is not provided
func play(start_index: int = -1) -> void:
	Client.send({
		"for": uuid,
		"call": "play",
		"args": [start_index]
	})


## Pauses the CueList at the current state
func pause() -> void:
	Client.send({
		"for": uuid,
		"call": "pause",
	})


## Stopes the CueList, will fade out all running scnes, using fade_out_speed, otherwise will use the fade_out_speed of the current index
func stop() -> void:
	Client.send({
		"for": uuid,
		"call": "stop",
		"args": []
	})


## Returns the play state of this CueList
func is_playing() -> bool:
	return _is_playing


## Advances to the next cue in the list
func go_next() -> void:
	Client.send({
		"for": uuid,
		"call": "go_next",
		"args": []
	})


## Retuens to the previous cue in the list
func go_previous() -> void:
	Client.send({
		"for": uuid,
		"call": "go_previous",
		"args": []
	})


## Skips to the cue provided in index
func seek_to(cue_index: float) -> void:
	Client.send({
		"for": uuid,
		"call": "seek_to",
		"args": [cue_index]
	})


## INTERNAL: Called when the index is changed on the server
func on_cue_changed(cue_number: float) -> void:
	current_cue_number = cue_number
	print(current_cue_number)
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


func _on_load_request(serialized_data: Dictionary) -> void:
	var just_added_cues: Array = []
	
	for cue_index: float in serialized_data.get("cues").keys():
		var new_cue: Cue = Cue.new()
		new_cue.load(serialized_data.cues[cue_index])
		
		if _add_cue(new_cue, cue_index):
			just_added_cues.append(new_cue)
	
	if just_added_cues:
		cues_added.emit(just_added_cues)
			
	
