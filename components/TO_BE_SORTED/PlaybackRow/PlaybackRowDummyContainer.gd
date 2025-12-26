# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name PlaybackRowDummyContainer extends VBoxContainer
## Container for a playback row used in the playback's panel settings


## Emitted when the corrisponing button is pressed
signal delete_pressed()
signal auto_pressed()
signal move_left_pressed()
signal move_right_pressed()


## Sets the playback row
func set_playback_row(row: PlaybackRowComponent) -> void:
	add_child(row)
	move_child(row, 1)


func _on_delete_pressed() -> void: delete_pressed.emit()
func _on_auto_pressed() -> void: auto_pressed.emit()
func _on_left_pressed() -> void: move_left_pressed.emit()
func _on_right_pressed() -> void: move_right_pressed.emit()
