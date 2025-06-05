# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name UIDataEditor extends UIPanel
## UI panel for editing DataContainers


## The Table
@export var _tree: Tree


## The selected Function
var _function: Function

## The _component's selected DataContainer
var _container: DataContainer

## Stores all the columns and the ids
var _columns: Dictionary[String, int]

## The root tree item
var _root: TreeItem


## Create the root tree item
func _ready() -> void:
	ComponentDB.request_component("10447be2-70aa-4600-ada3-418df4168e6c", set_function)


## Called when an Function is selected
func set_function(function: Function) -> void:
	_function = function
	_container = _function.get_data_container()
	_columns = {"Parameter: ": 0}
	_tree.clear()
	_root = _tree.create_item()
	
	var fixture_data: Dictionary = _container.get_fixture_data()
	for fixture: Fixture in fixture_data:
		var fixture_item: TreeItem = _root.create_child()
		fixture_item.set_text(0, fixture.get_name())
		
		for zone: String in fixture_data[fixture]:
			var zone_item: TreeItem = fixture_item
			
			if zone != "root":
				zone_item = fixture_item.create_child()
				zone_item.set_text(0, zone)
			
			for parameter: String in fixture_data[fixture][zone]:
				if parameter not in _columns:
					_tree.columns = _columns.values().max() + 1
					_columns[parameter] = _tree.columns
				
				zone_item.set_text(_columns[parameter], str(fixture_data[fixture][zone][parameter].value))
				zone_item.set_custom_bg_color(_columns[parameter], Color(Color.WHITE, 0.1))
	
	for column: String in _columns:
		_tree.set_column_title(_columns[column], column)
		_tree.set_column_expand(_columns[column], false)
	#
	#_tree.columns = _tree.columns + 1
	#_tree.set_column_expand(_tree.columns, true)

	
		
