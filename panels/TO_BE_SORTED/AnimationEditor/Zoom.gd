# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

extends Control
## WIP animation system

@export var controller: NodePath

func _on_h_slider_value_changed(value: float) -> void:
	print(value)
	if value > 0:
		$Padding.custom_minimum_size.x = 0
		$Track.custom_minimum_size.x = value
	elif value < 0:
		$Padding.custom_minimum_size.x = abs(value)
		$Track.custom_minimum_size.x = 0
