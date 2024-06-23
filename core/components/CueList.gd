# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name CueList extends Function
## Stores a list of Scenes, that are enabled and disabled in order one after another

#
## Emitted when the current cue is changed
signal cue_changed(index: int)

## Emitted when this CueList starts playing
signal played(index: int)

## Emitted when this CueList is paused
signal paused(index: int)

## Emitted when a cue is moved in this list
signal cue_moved(scene: Scene, to: int)

## Emitted when a cue is added to this CueList
signal cues_added(cues: Array)

## Emitted when a cue is removed form this CueList
signal cues_removed(cues: Array)

## Emitted when a cue's fade in time, out, or hold time is changed
signal cue_timings_changed(index: int, fade_in_time: float, fade_out_time: float, hold_time: float)


## Stores all the Scenes that make up this cue list, stored as: {"index": {"scenes": [Scene, ...], "hold_time": float}}
var cues: Dictionary = {}

## The index of the current cue, do not change this at runtime, instead use seek_to()
var index: int = 0

## Called when this EngineComponent is ready
func _component_ready() -> void:
	name = "CueList"
	self_class_name = "CueList"


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
func stop(fade_out_speed: float = -1) -> void:
	Client.send({
		"for": uuid,
		"call": "stop",
		"args": [fade_out_speed]
	})

#
## Advances to the next cue in the list, can be used with out needing to run play(), will use fade speeds of the cue if none are provided
func go_next(fade_in_speed: float = -1, fade_out_speed: float = -1) -> void:
	Client.send({
		"for": uuid,
		"call": "go_next",
		"args": [fade_in_speed, fade_out_speed]
	})


## Retuens to the previous cue in the list, can be used with out needing to run play(), will use fade speeds of the cue if none are provided
func go_previous(fade_in_speed: float = -1, fade_out_speed: float = -1) -> void:
	Client.send({
		"for": uuid,
		"call": "go_previous",
		"args": [fade_in_speed, fade_out_speed]
	})


## INTERNAL: Called when the index is changed on the server
func on_cue_changed(p_index) -> void:
	index = p_index
	cue_changed.emit(index)


func on_load_request(serialized_data: Dictionary) -> void:
	var just_added_cues: Array = []
	
	# Loop through all the cues in the serialized data
	for index in serialized_data.get("cues", {}):
		var serialized_cue: Dictionary = serialized_data.cues[index]
		
		var hold_time: float = serialized_cue.get("hold_time", 1)
		var scene_uuid: String = serialized_cue.get("scene", "")
		
		if scene_uuid in Core.functions.keys() and Core.functions[scene_uuid] is Scene:
			
			var fade_in_speed: float = serialized_cue.get("fade_in_speed", 1)
			var fade_out_speed: float = serialized_cue.get("fade_out_speed", 1)
			
			cues[int(index)] = {
				"scene": Core.functions[scene_uuid],
				"hold_time": hold_time,
				"fade_in_speed": fade_in_speed,
				"fade_out_speed": fade_out_speed
			}
			
			just_added_cues.append(cues[int(index)])
	
	if just_added_cues:
		cues_added.emit(just_added_cues)
