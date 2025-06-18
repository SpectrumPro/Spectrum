# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name UIPlaybacks extends UIPanel
## Ui panel for controling scenes, with sliders and extra buttons


## The NewPlaybackRowComponent container for columns
@export var _container: HBoxContainer 

## Object Picker button
@export var _object_picker_button: ObjectPickerButton


## The function group
var _trigger_block: TriggerBlock

## Default number of columns to show
var _default_columns: int = 10

## All UI columns
var _columns: Dictionary[int, PlaybackColumn]

## Signals to connect to the TriggerBlock
var _trigger_block_connections: Dictionary[String, Callable] = {
	"trigger_added": _add_trigger,
	"trigger_removed": _remove_trigger,
	"trigger_name_changed": _rename_trigger,
}


## Load Default Columns
func _ready() -> void:
	set_edit_mode_disabled(true)
	
	for column: int in range(0, _default_columns + 1):
		var new_column: PlaybackColumn = load("res://components/PlaybackColumn/PlaybackColumn.tscn").instantiate()
		
		new_column.set_column(column)
		
		_columns[column] = new_column
		_container.add_child(new_column)


## Sets the trigger block
func set_trigger_block(trigger_block: TriggerBlock) -> void:
	if trigger_block == _trigger_block:
		return
		
	Utils.disconnect_signals(_trigger_block_connections, _trigger_block)
	_trigger_block = trigger_block
	Utils.connect_signals(_trigger_block_connections, _trigger_block)
	
	set_edit_mode_disabled(false)
	
	for playback: PlaybackColumn in _columns.values():
		playback.set_trigger_block(_trigger_block)
		
	var triggers: Dictionary[int, Dictionary] = _trigger_block.get_triggers()
	for row: int in triggers:
		for column: int in triggers[row]:
			_add_trigger(
				triggers[row][column].component,
				triggers[row][column].id,
				triggers[row][column].name,
				row,
				column,
			)


## Called when editmode state is changed
func _edit_mode_toggled(state: bool) -> void:
	if not _trigger_block:
		return
	
	for column: PlaybackColumn in _columns.values():
		column.set_edit_mode(state)


## Called when a trigger is added to the TriggerBlock
func _add_trigger(component: EngineComponent, id: String, p_name: String,  row: int, column: int) -> void:
	if _columns.has(column):
		_columns[column].set_component(component, true)
		_columns[column].set_row_name(row, p_name)


## Called when a trigger is removed from the TriggerBlock
func _remove_trigger(row: int, column: int) -> void:
	if _columns.has(column):
		_columns[column].set_row_name(row, "")


## Called when a trigger is renamed
func _rename_trigger(row: int, column: int, name: String) -> void:
	if _columns.has(column):
		_columns[column].set_row_name(row, "")


## Called when a function group is selected
func _on_object_picker_button_object_selected(object: EngineComponent) -> void:
	set_trigger_block(object)


## Saves this into a dict
func _save() -> Dictionary:
	if _trigger_block: 
		return { "uuid": _trigger_block.uuid }
	else: 
		return {}


## Loads this from a dict
func _load(saved_data: Dictionary) -> void:
	if saved_data.get("uuid") is String:
		_object_picker_button.look_for(saved_data.uuid)
