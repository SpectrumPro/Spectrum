# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name CueListTable extends UIPanel
## A table for editing cuelists


## The main table node
@export var table: Table

## The name button
@export var object_picker_button: ObjectPickerButton

## The IntensityButton
@export var _intensity_button: IntensityButton

## List of buttons to disable on cue deselect
@export var _disable_on_deselect: Array[Button]


## The cuelist 
var _cue_list: CueList = null

## Stores all cues and there respective RowHeadder
var _cues: Dictionary = {}

## All the parmiters that can be changed
var _data_keys: Array = [
	"Number",
	"Fade Time",
	"Pre Wait",
	"Follow Mode",
	"Fixtures",
	#"Triggers"
]


var _cue_list_connections: Dictionary = {
	"cues_added": _on_cue_list_cues_added,
	"cues_removed": _on_cue_list_cues_removed,
}

var _cue_connections: Dictionary = {
	"number_changed": _on_cue_number_changed
}


func _ready() -> void:
	set_edit_mode_disabled(true)
	_create_columns()

	$CreateConfirmationBox.confirmed.connect(_on_add_cue_confirmed)
	
	table.row_selected.connect(func (r): enable_button_array(_disable_on_deselect))
	table.nothing_selected.connect(func (): disable_button_array(_disable_on_deselect))


## Sets the cue list
func set_cue_list(cue_list: CueList) -> void:
	Utils.disconnect_signals(_cue_list_connections, _cue_list)
	_cue_list = cue_list
	Utils.connect_signals(_cue_list_connections, _cue_list)
	
	_intensity_button.set_function(_cue_list)
	_reload_table()


## Reloads all the items in the table
func _reload_table() -> void:
	table.clear_cells()
	table.clear_rows()
	
	if _cue_list:
		for cue_number: float in _cue_list.get_index_list():
			_add_cue_row(_cue_list.get_cue(cue_number))


## Creats the colums
func _create_columns() -> void:
	for title: String in _data_keys:
		table.create_column(title)


## Adds a row for a cue
func _add_cue_row(cue: Cue) -> void:
	var row_headder: RowHeadder = table.create_row(cue.name)
	table.move_row(row_headder.index, _cue_list.get_cue_index(cue))
	
	var l: int = len(cue.get_fixture_data())
	
	var _data_values: Dictionary = {
		"Number": 		{ "value": cue.get_number(), "setter": _cue_list.set_cue_number.bind(cue), "signal": cue.number_changed},
		"Fade Time": 	{ "value": cue.get_fade_time(), "setter": cue.set_fade_time, "signal": cue.fade_time_changed },
		"Pre Wait": 	{ "value": cue.get_pre_wait(), "setter": cue.set_pre_wait, "signal": cue.pre_wait_time_changed },
		"Follow Mode": 	{ "list": ["Manual", "After Last", "With Last"], "value": cue.get_trigger_mode(), "setter": func (value): cue.set_trigger_mode(value), "signal": cue.trigger_mode_changed },
		"Fixtures": 	{ "button_text": str(l) + " Fixture" + ("s" if l != 1 else ""), "button_callback": Callable()},
		#"Triggers": 	{ "button_text": str(len(cue.function_triggers)) + " Triggers", "button_callback": Callable()}
	}
	
	for data: Dictionary in _data_values.values():
		if "button_text" in data:
			table.add_button(row_headder.index, data.button_text, data.button_callback)
		elif "list" in data:
			table.add_dropdown(row_headder.index, data.list, data.value, data.setter, data.signal)
		elif "value" in data:
			table.add_data(row_headder.index, data.value, data.setter, data.signal)
	
	Utils.connect_signals_with_bind(_cue_connections, cue)
	
	_cues[cue] = row_headder
	row_headder.set_name_method(cue.set_name, cue.name_changed)


## Called when cues are added to the cue list
func _on_cue_list_cues_added(cues: Array) -> void:
	for cue_number: float in _cue_list.get_index_list():
		var cue: Cue = _cue_list.get_cue(cue_number)
		if cue in cues:
			_add_cue_row(cue)


## Called when cues are removes from the CueList
func _on_cue_list_cues_removed(cues: Array) -> void:
	for cue: Cue in cues:
		table.remove_row(_cues[cue].index)


## Called when a cue number changes
func _on_cue_number_changed(new_number: float, cue: Cue) -> void:
	table.move_row(_cues[cue].index, _cue_list.get_cue_index(cue))


## Called when the confirm button is pressed in the add cue menu
func _on_add_cue_confirmed() -> void:
	var save_mode: Programmer.SaveMode
	
	match $CreateConfirmationBox.button_group.get_pressed_button().name:
		"ModifiedChannels": 	save_mode = Programmer.SaveMode.MODIFIED
		"AllChannels": 			save_mode = Programmer.SaveMode.ALL
		"AllNoneZero":			save_mode = Programmer.SaveMode.ALL_NONE_ZERO
	
	Client.send_command("programmer", "save_to_new_cue", [
		Values.get_selection_value("selected_fixtures"),
		_cue_list,
		save_mode
	])


## Saves this into a dict
func _save() -> Dictionary:
	if _cue_list: return { "uuid": _cue_list.uuid }
	else: return {}


## Loads this from a dict
func _load(saved_data: Dictionary) -> void:
	if "uuid" in saved_data:
		object_picker_button.look_for(saved_data.uuid)


## Called when the CueName button is pressed
func _on_cue_name_pressed() -> void:
	Interface.show_object_picker(
		ObjectPicker.SelectMode.Single, 
		func (objects: Array): 
			if objects[0] is CueList: set_cue_list(objects[0]), 
		"CueList"
	)


## Gets the cue from the current selected RowIndex
func _get_cue_number() -> float:
	var index_list: Array = _cue_list.get_index_list()
	if table.get_selected_row() and table.get_selected_row().index <= len(index_list):
		return index_list[table.get_selected_row().index]
	else:
		return -1


func _on_go_pressed() -> void:
	_cue_list.seek_to(_get_cue_number())

func _on_previous_pressed() -> void: if _cue_list: _cue_list.go_previous()
func _on_next_pressed() -> void: if _cue_list: _cue_list.go_next()
func _on_play_pause_pressed() -> void: if _cue_list: _cue_list.pause() if _cue_list.is_playing() else _cue_list.play()
func _on_stop_pressed() -> void: if _cue_list: _cue_list.stop()


func _on_delete_pressed() -> void:
	var cue_number: float = _get_cue_number()
	if cue_number != -1:
		Interface.show_delete_confirmation("Confirm Deletion of Cue: " + str(cue_number)).confirmed.connect(func ():
			_cue_list.get_cue(cue_number).delete()
		)


func _on_add_pressed() -> void:
	$CreateConfirmationBox.show()
