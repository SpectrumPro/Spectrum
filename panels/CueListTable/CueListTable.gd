# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name CueListTable extends Control
## A table for editing cuelists


## The main table node
@onready var table: Table = $Table

## The cuelist 
var _cue_list: CueList = null


## All the parmiters that can be changed
var _data_keys: Array = [
	"Number",
	"Fade Time",
	"Pre Wait",
	"Follow Mode",
	"Fixtures",
	"Triggers"
]


func _ready() -> void:
	ComponentDB.request_component("57f68170-fb4f-4cfc-9077-e05043176964", _on_cue_list_found)
	_create_columns()


## Sets the cue list
func set_cue_list(cue_list: CueList) -> void:
	if _cue_list:
		_cue_list.cues_added.disconnect(_on_cue_list_cues_added)
	
	_cue_list = cue_list
	
	if _cue_list:
		_cue_list.cues_added.connect(_on_cue_list_cues_added)
	
	_reload_table()


## Reloads all the items in the table
func _reload_table() -> void:
	table.clear_cells()
	table.clear_rows()
	
	if _cue_list:
		for cue_number: float in _cue_list.index_list:
			_add_cue_row(_cue_list.cues[cue_number])


## Creats the colums
func _create_columns() -> void:
	for title: String in _data_keys:
		table.create_column(title)


## Adds a row for a cue
func _add_cue_row(cue: Cue) -> void:
	var row_item: RowIndex = table.create_row(cue.name)
	var _data_values: Dictionary = {
		"Number": 		{ "value": cue.get_number(), "setter": _cue_list.set_cue_number.bind(cue), "signal": cue.number_changed},
		"Fade Time": 	{ "value": cue.get_fade_time(), "setter": cue.set_fade_time, "signal": cue.fade_time_changed },
		"Pre Wait": 	{ "value": cue.get_pre_wait(), "setter": cue.set_pre_wait, "signal": cue.pre_wait_time_changed },
		"Follow Mode": 	{ "value": cue.get_trigger_mode(), "setter": cue.get_trigger_mode, "signal": cue.trigger_mode_changed },
		#"Fixtures": { "getter": "get_number", "setter": "set_cue_number", "signal": "number_changed" },
		#"Triggers": { "getter": "get_number", "setter": "set_cue_number", "signal": "number_changed" }
	}
	
	for data: Dictionary in _data_values.values():
		table.add_data(row_item.row_index, data.value, data.setter, data.signal)


## Called when cues are added to the cue list
func _on_cue_list_cues_added(cues: Array) -> void:
	for cue_number: float in _cue_list.index_list:
		var cue: Cue = _cue_list.cues[cue_number]
		if cue in cues:
			_add_cue_row(cue)



## Called when ComponentDB finds the cue list
func _on_cue_list_found(cue_list: EngineComponent) -> void:
	if cue_list is CueList:
		set_cue_list(cue_list)
