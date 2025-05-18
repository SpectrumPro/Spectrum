# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name UIDataEditor extends UIPanel
## UI panel for editing DataContainers


## The Table
@export var _table: Table


## The selected Function
var _function: Function

## The _component's selected DataContainer
var _container: DataContainer

## The RefMap for Fixture:RowHeadder
var _fixture_row_headders: RefMap = RefMap.new()

## The RefMap for "Parameter":ColumnIndex
var _parameter_column_indexes: RefMap = RefMap.new()


## Called when an Function is selected
func _on_object_picker_button_object_selected(function: Function) -> void:
	if function is not Scene:
		return
	
	_function = function
	_container = function.get_data_container()
	
	var fixture_data: Dictionary = _container.get_fixture_data()
	for fixture: Fixture in fixture_data:
		var row: RowHeadder = _table.create_row(fixture.name)
		_fixture_row_headders.map(fixture, row)
		
		for zone: String in fixture_data[fixture]:
			for parameter: String in fixture_data[fixture][zone]:
				var data: Dictionary = fixture_data[fixture][zone][parameter]
				var key: String = zone + "." + parameter
				var column: ColumnIndex
				
				if _parameter_column_indexes.has_left(key):
					column = _parameter_column_indexes.left(key)
				else:
					column = _table.create_column(key)
					_parameter_column_indexes.map(key, column)
				
				_table.add_data(row.index, data.value, Callable(), Signal(), column.column_index)
