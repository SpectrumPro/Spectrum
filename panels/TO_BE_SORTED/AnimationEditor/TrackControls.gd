# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

extends Control
## WIP animation system

var track_id: int

var track_data_container: Control

func _on_add_track_item_pressed() -> void:
	track_data_container.add_track_item()
