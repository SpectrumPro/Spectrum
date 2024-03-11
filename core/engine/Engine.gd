# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name CoreEngine extends Node
## The core engine that powers Spectrum

var current_file_name: String = ""
var current_file_path: String = ""

var _system: System = System.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	OS.set_low_processor_usage_mode(true)

func save(file_name: String = current_file_name, file_path: String = current_file_name) -> Error:
	return _system.save(self, file_name, file_path)
