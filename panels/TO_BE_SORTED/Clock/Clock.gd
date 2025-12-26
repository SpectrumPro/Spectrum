# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name UIClock extends UIPanel
## A clock


func _ready() -> void:
	$Control/Label.label_settings = $Control/Label.label_settings.duplicate()
	_set_font_size()


func _process(delta: float) -> void:
	$Control/Label.text = Time.get_time_string_from_system()


func _set_font_size() -> void:
	$Control/Label.label_settings.font_size = (size.x * 0.13)
