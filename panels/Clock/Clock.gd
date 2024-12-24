# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name UIClock extends UIPanel
## A clock


func _ready() -> void:
	_set_font_size()


func _process(delta: float) -> void:
	$Control/Label.text = Time.get_time_string_from_system()


func _on_resized() -> void:
	_set_font_size()


func _set_font_size() -> void:
	$Control/Label.label_settings.font_size = (size.x * 0.13)
