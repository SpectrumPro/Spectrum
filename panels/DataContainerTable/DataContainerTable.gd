# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name DataContainerTable extends UIPanel
## A table for editing cuelists


## The main table node
@export var table: Table = null

## The name button
@export var _name_button: Button = null

## List of buttons to disable on cue deselect
@export var _disable_on_deselect: Array[Button]


## The cuelist 
var _container: DataContainer = null

## The uuid of the cuelist used when this panel was saved
var _previous_uuid: String = ""

## All the parmiters that can be changed
var _data_keys: Array = [
	"Dimmer",
	"set_color",
	"ColorIntensityWhite",
	"ColorIntensityAmber",
	"ColorIntensityUV",
]

var _container_connections: Dictionary = {}


func _ready() -> void:
	set_edit_mode_disabled(true)
	_create_columns()
	
	table.row_selected.connect(func (r): enable_button_array(_disable_on_deselect))
	table.nothing_selected.connect(func (): disable_button_array(_disable_on_deselect))


## Sets the cue list
func set_container(container: DataContainer) -> void:
	if _previous_uuid: ComponentDB.remove_request.call_deferred(_previous_uuid, _on_container_object_found)
	
	Utils.disconnect_signals(_container_connections, _container)
	_container = container
	Utils.connect_signals(_container_connections, _container)
	
	_name_button.text = container.name
	_reload_table()


## Reloads all the items in the table
func _reload_table() -> void:
	table.clear_cells()
	table.clear_rows()
	
	if _container:
		var fixture_data: Dictionary = _container.get_fixture_data()
		for fixture: Fixture in fixture_data:
			_add_fixture_row(fixture, fixture_data[fixture])


## Creats the colums
func _create_columns() -> void:
	for title: String in _data_keys:
		table.create_column(title.replace("ColorIntensity", "").capitalize())


## Adds a row for a cue
func _add_fixture_row(fixture: Fixture, data: Dictionary) -> void:
	var row_headder: RowHeadder = table.create_row(fixture.name)
	
	
	#var _data_values: Array = [
		#{ "value": data, "setter": _container.set_cue_number.bind(cue), "signal": cue.number_changed},
		##{ "value": cue.get_fade_time(), "setter": cue.set_fade_time, "signal": cue.fade_time_changed },
		##{ "value": cue.get_pre_wait(), "setter": cue.set_pre_wait, "signal": cue.pre_wait_time_changed },
		##{ "list": ["Manual", "After Last", "With Last"], "value": cue.get_trigger_mode(), "setter": func (value): cue.set_trigger_mode(value), "signal": cue.trigger_mode_changed },
		##{ "button_text": str(l) + " Fixture" + ("s" if l != 1 else ""), "button_callback": Callable()},
	#]
	#
	#for data: Dictionary in .values():
		#if "button_text" in data:
			#table.add_button(row_headder.index, data.button_text, data.button_callback)
		#elif "list" in data:
			#table.add_dropdown(row_headder.index, data.list, data.value, data.setter, data.signal)
		#elif "value" in data:
			#table.add_data(row_headder.index, data.value, data.setter, data.signal)
	
	for parameter_key: String in _data_keys:
		if data.has(parameter_key):
			table.add_data(row_headder.index, data[parameter_key].value, Callable(), Signal())
		else:
			table.add_data(row_headder.index, null, Callable(), Signal())
	
	


## Called when ComponentDB finds the Container
func _on_container_object_found(object: EngineComponent) -> void: if object is DataContainer: set_container(object)


## Saves this into a dict
func _save() -> Dictionary:
	if _container: 
		return { "uuid": _container.uuid }
	else: return {}


## Loads this from a dict
func _load(saved_data: Dictionary) -> void:
	if "uuid" in saved_data:
		_previous_uuid = saved_data.uuid
		ComponentDB.request_component(saved_data.uuid, _on_container_object_found)


func _on_container_name_pressed() -> void:
	Interface.show_object_picker(
		ObjectPicker.SelectMode.Single, 
		func (objects: Array): 
			if objects[0] is DataContainer: set_container(objects[0]), 
		
	)
