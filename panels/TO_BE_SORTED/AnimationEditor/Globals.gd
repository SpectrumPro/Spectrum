# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

extends Node
## WIP animation system


const WIDTH: int = 7000 
const HEIGHT: int = 3000

const FFMPEG_PATH: String = "/usr/local/bin/ffmpeg"

var components: Dictionary = {}

func _ready() -> void:
	var dir: DirAccess = DirAccess.open("res://components/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.file_exists(file_name):
				print("Found file: " + file_name)
				components[file_name.replace(".tscn", "")] = ResourceLoader.load("res://components/"+file_name)
			file_name = dir.get_next()


func get_waveform(file_path: String, callback: Callable) -> void:
	var thread = Thread.new()
	thread.start(_run_get_waveform.bind(file_path, callback))

func _run_get_waveform(file_path: String, callback: Callable) -> void:
	var md5 = FileAccess.get_md5(file_path)
	var image_path: String = OS.get_user_data_dir() + "/waveforms/" + md5 + ".png"
	
	if FileAccess.file_exists(image_path):
		print("Loading Waveform From File")
		callback.call_deferred(Image.load_from_file(image_path))
	else:
		print("Genarating New Waveform")
		callback.call_deferred(_get_waveform(file_path, image_path))

func _get_waveform(file_path: String, image_path: String) -> Image:
	var output = []
	OS.execute(FFMPEG_PATH, [
		"-i", file_path, 
		"-filter_complex", "compand=gain=-6,showwavespic=s="+str(WIDTH)+"x"+str(HEIGHT)+":colors=white", 
		"-frames:v", "1", 
		image_path, 
		"-y"
	], output)
	print(output)
	var image: Image = Image.new()
	image.load(image_path)
	
	return image
