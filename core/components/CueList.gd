# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name CueList extends Function
## Stores a list of Scenes, that are enabled and disabled in order one after another

#
### Emitted when the current cue is changed
#signal on_cue_changed(index: int)
#
### Emitted when this CueList starts playing
#signal on_played(index: int)
#
### Emitted when this CueList is paused
#signal on_paused(index: int)
#
### Emitted when a cue is moved in this list
#signal on_cue_moved(scene: Scene, to: int)
#
### Emitted when a cue is added to this CueList
#signal on_cues_added(cues: Array)
#
### Emitted when a cue is removed form this CueList
#signal on_cues_removed(cues: Array)
#
### Emitted when a cue's fade in time is changed
#signal on_cue_fade_in_changed(index: int, fade_in_time: float)
#
### Emitted when a cue's fade out time is changed
#signal on_cue_fade_out_changed(index: int, fade_out_time: float)
#
### Emitted when a cue's hold time is changed
#signal on_cue_hold_changed(index: int, hold_time: float)
#
#
### Stores all the Scenes that make up this cue list, stored as: {"index": {"scenes": [Scene, ...], "hold_time": float}}
#var cues: Dictionary = {}
#
### Stores the fade in and fade out time for each scene in a dictionary, stored as {Scene: {fade_in_time:float, ...}}
#var timings: Dictionary = {}
#
### The index of the current cue, do not change this at runtime, instead use seek_to()
#var index: int = 0
#
### Used to store the on_delete_requested signal connection for each scene in this CueList, stored here to they can be dissconnected to remove refernces once a scene is deleted
#var _scene_signal_connections: Dictionary = {}
#
### Stores the scenes that are currently fading in or out, this is used when pausing and playing the CueList
#var _active_scenes: Array = []
#var _is_playing: bool = false
#
#
## Called when this EngineComponent is ready
func _component_ready() -> void:
	name = "CueList"
	self_class_name = "CueList"

#
### Plays this CueList, starting at index, or from the current index if one is not provided
#func play(start_index: int = -1) -> void:
	#if not _is_playing and len(cues):
		#_is_playing = true
#
		#index = start_index if not start_index == -1 else index
#
		#for scene: Scene in _active_scenes:
			#scene.play()
		#
		#while _is_playing:
			#go_next()
			#await Core.get_tree().create_timer(cues[index].hold_time).timeout
			#if index == len(cues):
				#index = 0
#
#
### Pauses the CueList at the current state
#func pause() -> void:
	#_is_playing = false
	#
	#for scene: Scene in _active_scenes:
		#scene.pause()
#
#
### Stopes the CueList, will fade out all running scnes, using fade_out_speed, otherwise will use the fade_out_speed of the current index
#func stop(fade_out_speed: float = -1) -> void:
	#_active_scenes = _active_scenes.filter(func (scene: Scene):
		#scene.set_enabled(false, fade_out_speed if not fade_out_speed == -1 else timings[scene].fade_out_speed)
		#return false
	#)
#
#
### Advances to the next cue in the list, can be used with out needing to run play(), will use fade speeds of the cue if none are provided
#func go_next(fade_in_speed: float = -1, fade_out_speed: float = -1) -> void:
	#seek_to(index + 1, fade_in_speed, fade_out_speed)
#
#
### Retuens to the previous cue in the list, can be used with out needing to run play(), will use fade speeds of the cue if none are provided
#func go_previous(fade_in_speed: float = -1, fade_out_speed: float = -1) -> void:
	#seek_to(index - 1, fade_in_speed, fade_out_speed)
#
#
### Skips to the cue provided in index, can be used with out needing to run play(), will use fade speeds of the cue if none are provided
#func seek_to(p_index: int, fade_in_speed: float = -1, fade_out_speed: float = -1) -> void:
	#index = p_index
#
	#_active_scenes = _active_scenes.filter(func (scene: Scene):
		#scene.set_enabled(false, fade_out_speed if not fade_out_speed == -1 else timings[scene].fade_out_speed)
		#return false
	#)
#
	#for scene: Scene in cues[index].scenes:
		#scene.set_enabled(true, fade_in_speed if not fade_in_speed == -1 else timings[scene].fade_in_speed)
		#_active_scenes.append(scene)
		#
#
#
### Adds a scene to this CueList, will use the scenes fade times if none are provided. If no index is provided, the scene will be appened at the end of the list. Do not add cues while this CueList is playing, things may break
#func add_cue(scene: Scene, at_index: int = -1 , fade_in_speed: float = -1, fade_out_speed: float = -1, no_signal: bool = false) -> void:
	#
	#if at_index not in range(1, len(cues.keys()) + 1):
		#at_index = len(cues.keys()) + 1
#
	#if not cues.get(at_index, 0):
		#cues[at_index] = {
			#"scenes": [],
			#"hold_time": 1.0
		#}
#
	#timings[scene] = {
		#"fade_in_speed": fade_in_speed,
		#"fade_out_speed": fade_out_speed
	#}
	#
	#cues[at_index].scenes.append(scene)
#
#
#func _connect_scene_signals(scene: Scene) -> void:
	#pass
#
#func _disconnect_scene_signals(scene: Scene) -> void:
	#pass
#
### Moves the cue at index, to to_index. Do not move cues while this CueList is playing, things may break
#func move_cue(scene: Scene, to_index: int) -> void:
	#pass
#
#
### Removes a cue at index. Do not remove cues while this CueList is playing, things may break
#func remove_cue(scene: Scene) -> void:
	#pass
#
#
### Sets the fade in time for the cue at index
#func set_fade_in_time(scene: Scene, fade_in_time: float) -> void:
	#pass
#
#
### Sets the fade out time for the cue at index
#func set_fade_out_time(scene: Scene, fade_out_time: float) -> void:
	#pass
#
#
### Sets the hold time for the cue at index
#func set_hold_time(at_index: int, hold_time: float) -> void:
	#if cues.has(at_index):
	  #cues[at_index].hold_time = hold_time
#
#
#func _on_serialize_request(mode: int) -> Dictionary:
	#var serialized_cues: Dictionary = {}
	#var serialized_timings: Dictionary = {}
#
	#for index in cues:
		#serialized_cues[index] = {
			#"hold_time": cues[index].hold_time,
			#"scenes": cues[index].scenes.map(func (scene: Scene):
				#return scene.uuid
				#)
		#}
		#
	#for scene: Scene in timings:
		#serialized_timings[scene.uuid] = timings[scene]
#
	#return {
		#"cues": serialized_cues,
		#"timings": serialized_timings
	#}
#
#
#func _on_load_request(serialized_data: Dictionary) -> void:
#
	#var just_added_cues: Dictionary = {}
#
	#for index in serialized_data.get("cues", {}):
		#var serialized_cue: Dictionary = serialized_data.cues[index]
#
		#var hold_time: float = serialized_cue.get("hold_time", 1)
#
		#for scene_uuid in serialized_cue.get("scenes", []):
			#if scene_uuid in Core.scenes.keys():
#
				#var fade_in_speed: float = 1
				#var fade_out_speed: float = 1
#
				#var serialized_timings: Dictionary = serialized_data.get("timings", {})
				#if serialized_timings.has(scene_uuid):
					#fade_in_speed = serialized_timings[scene_uuid].get("fade_in_speed")
					#fade_out_speed = serialized_timings[scene_uuid].get("fade_out_speed")
				#
				#add_cue(Core.scenes[scene_uuid], int(index), fade_in_speed, fade_out_speed, true)
		#
		#set_hold_time(int(index), hold_time)
#
#
	#if just_added_cues:
		#on_cues_added.emit(just_added_cues)
#
#
#func _on_delete_request() -> void:
	#stop(0)
