# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name UIPlaybacks extends UIPanel
## Ui panel for controling scenes, with sliders and extra buttons


## The NewPlaybackRowComponent container for columns
@export var _container: HBoxContainer 


## Default number of columns to show
var _default_columns: int = 10

## All UI columns
var _columns: Dictionary[int, PlaybackColumn]

## The function group
var _function_group: FunctionGroup


## Load Default Columns
func _ready() -> void:
	for column: int in range(0, _default_columns + 1):
		var new_column: PlaybackColumn = load("res://components/PlaybackColumn/PlaybackColumn.tscn").instantiate()
		_columns[column] = new_column
		_container.add_child(new_column)


## Called when a function group is selected
func _on_object_picker_button_object_selected(object: EngineComponent) -> void:
	_function_group = object
	
	for playback: PlaybackColumn in _columns.values():
		playback.set_function_group(_function_group)


## Called when editmode state is changed
func _edit_mode_toggled(state: bool) -> void:
	if not _function_group:
		return
	
	for column: PlaybackColumn in _columns.values():
		column.set_edit_mode(state)


## Saves this UIPlaybacks to a dict
func _save() -> Dictionary:
	return {}


## Loads this UIPlaybacks
func _load(serialized_data: Dictionary) -> void:
	pass
