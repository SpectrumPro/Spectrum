# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name CueListTable extends Control
## A table for editing cuelists


## The main table node
@onready var table: Table = $Table

## The cuelist 
var _cue_list: CueList = null

## The uuid of the cuelist used when this panel was saved
var _previous_uuid: String = ""

## The name button
var _name_button: Button


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
	_create_columns()
	_add_name_button()
	
	table.add_row_button_pressed.connect(func (): $CreateConfirmationBox.show())
	$CreateConfirmationBox.confirmed.connect(_on_add_cue_confirmed)


## Sets the cue list
func set_cue_list(cue_list: CueList) -> void:
	if _previous_uuid: ComponentDB.remove_request.call_deferred(_previous_uuid, _on_cue_list_object_found)
	
	if _cue_list: 
		_cue_list.cues_added.disconnect(_on_cue_list_cues_added)
		_cue_list.name_changed.disconnect(_on_cue_list_on_name_changed)
	
	_cue_list = cue_list
	table.set_show_add_button(is_instance_valid(_cue_list))
	
	if _cue_list:
		_cue_list.cues_added.connect(_on_cue_list_cues_added)
		_cue_list.name_changed.connect(_on_cue_list_on_name_changed)
	
	_name_button.text = cue_list.name
	_reload_table()


## Reloads all the items in the table
func _reload_table() -> void:
	table.clear_cells()
	table.clear_rows()
	
	if _cue_list:
		for cue_number: float in _cue_list.index_list:
			_add_cue_row(_cue_list.cues[cue_number])


func _add_name_button() -> void:
	var new_button: Button = Button.new()
	_name_button = new_button
	
	new_button.flat = true
	new_button.text = "Empty Table"
	new_button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	
	new_button.pressed.connect(func (): 
		Interface.show_object_picker(
			ObjectPicker.SelectMode.Single, 
			func (objects: Array): 
				if objects[0] is CueList: set_cue_list(objects[0]), 
			["CueList"]
		)
	)
	
	new_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_button.icon = load("res://assets/icons/CueList.svg")
	
	table.get_corner_node().add_child(new_button)


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
		"Follow Mode": 	{ "list": ["Manual", "After Last", "With Last"], "value": cue.get_trigger_mode(), "setter": func (value): cue.set_trigger_mode(value), "signal": cue.trigger_mode_changed },
		"Fixtures": 	{ "button_text": str(len(cue.stored_data)) + " Fixtures", "button_callback": Callable()},
		"Triggers": 	{ "button_text": str(len(cue.function_triggers)) + " Triggers", "button_callback": Callable()}
	}
	
	for data: Dictionary in _data_values.values():
		if "button_text" in data:
			table.add_button(row_item.row_index, data.button_text, data.button_callback)
		elif "list" in data:
			table.add_dropdown(row_item.row_index, data.list, data.value, data.setter, data.signal)
		elif "value" in data:
			table.add_data(row_item.row_index, data.value, data.setter, data.signal)
		
	row_item.set_name_method(cue.set_name, cue.name_changed)


## Called when cues are added to the cue list
func _on_cue_list_cues_added(cues: Array) -> void:
	for cue_number: float in _cue_list.index_list:
		var cue: Cue = _cue_list.cues[cue_number]
		if cue in cues:
			_add_cue_row(cue)


## Called when the name of the cuelist changes
func _on_cue_list_on_name_changed(new_name: String) -> void:
	_name_button.text = new_name


## Called when the confirm button is pressed in the add cue menu
func _on_add_cue_confirmed() -> void:
	var save_mode: Programmer.SAVE_MODE
	
	match $CreateConfirmationBox.button_group.get_pressed_button().name:
		"ModifiedChannels": 	save_mode = Programmer.SAVE_MODE.MODIFIED
		"AllChannels": 			save_mode = Programmer.SAVE_MODE.ALL
		"AllNoneZero":			save_mode = Programmer.SAVE_MODE.ALL_NONE_ZERO
	
	Client.send_command("programmer", "save_to_new_cue", [
		Values.get_selection_value("selected_fixtures"),
		_cue_list,
		save_mode
	])


## Called when ComponentDB finds the cuelist
func _on_cue_list_object_found(object: EngineComponent) -> void: if object is CueList: set_cue_list(object)


## Saves this into a dict
func save() -> Dictionary:
	if _cue_list: return { "uuid": _cue_list.uuid }
	else: return {}


## Loads this from a dict
func load(saved_data: Dictionary) -> void:
	if "uuid" in saved_data:
		_previous_uuid = saved_data.uuid
		ComponentDB.request_component(saved_data.uuid, _on_cue_list_object_found)
