# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

extends Control
## WIP animation editor


signal length_changed(length: float)

@export_node_path("VBoxContainer") var track_controls_container: NodePath
@export_node_path("VBoxContainer") var track_contents_container: NodePath
@export_node_path("AudioStreamPlayer") var audio_stream_player: NodePath

var animation_player: AnimationPlayer
var animation: Animation = Animation.new()

func _ready() -> void:
	if not DirAccess.dir_exists_absolute("user://waveforms/"):
		DirAccess.make_dir_absolute("user://waveforms/")
	
	animation.length = 5 * 60 # 5 mins
	
	animation_player = $AnimationPlayer
	animation_player.get_animation_library("").add_animation("Main", animation)
	
	animation_player.play("Main")
	animation_player.pause()

func set_animation_length(length: float) -> void:
	animation.length = length
	length_changed.emit(animation.length)


func _on_add_audio_track_pressed() -> void:
	
	var track_id = animation.add_track(Animation.TYPE_METHOD)
	
	var track_data = load("res://panels/AnimationEditor/TrackData.tscn").instantiate()
	track_data.track_id = track_id
	get_node(track_contents_container).add_child(track_data)
	
	var track_controls: Control = load("res://panels/AnimationEditor/TrackControls.tscn").instantiate()
	track_controls.track_data_container = track_data
	track_controls.track_id = track_id
	get_node(track_controls_container).add_child(track_controls)
	
	#var file_picker: FileDialog = Globals.components.FilePicker.instantiate()
	#
	#add_child(file_picker)
	#
	#file_picker.file_selected.connect(func (file_path):
		#var file = FileAccess.open(file_path, FileAccess.READ)
		#var stream = AudioStreamMP3.new()
		#stream.data = file.get_buffer(file.get_length())
		#
		#var track_id: int = animation.add_track(Animation.TYPE_AUDIO)
		#var audio_stream_player_path: NodePath = NodePath("AudioStreamPlayer")
		#
		#animation.track_set_path(track_id, "AudioStreamPlayer:stream")
		#animation.audio_track_insert_key(track_id, 0, stream)
		#
		#animation.length = stream.get_length()
		#
		#var track_controls: Control = Globals.components.TrackControls.instantiate()
		#track_controls.track_id = track_id
		#get_node(track_controls_container).add_child(track_controls)
		#
		#var track_data = Globals.components.TrackData.instantiate()
		#track_data.track_id = track_id
		#get_node(track_contents_container).add_child(track_data)
		#
		#Globals.get_waveform(file_path, func (image: Image):
			#track_data.set_image(ImageTexture.create_from_image(image))
		#)
		#
	#)
