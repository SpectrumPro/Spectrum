# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

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
