# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name UIDataEditor extends UIPanel
## UI panel for editing DataContainers


## The Table
@export var _tree: Tree

## The selection box
@export var _select_box: PanelContainer


## The selected Function
var _function: Function

## The _component's selected DataContainer
var _container: DataContainer

## Stores all the columns and the ids
var _columns: Dictionary[String, int]

## The root tree item
var _root: TreeItem

## Refmap for Fixture:TreeItem
var _fixture_items: RefMap = RefMap.new()

## Dictionary for RefMap Zone:TreeItem
var _fixture_zones: Dictionary[Fixture, RefMap]

## All selected tree items and columns
var _selected_items: Dictionary[TreeItem, Array]

## Dragging state
var _is_dragging: bool = false

## Drag start point
var _drag_start_point: Vector2 = Vector2.ZERO

## Color for zero data
var _zero_data_color: Color = Color.TRANSPARENT

## Color for none zero data
var _none_zero_data_color: Color = Color(Color.WHITE, 0.1)

## Signals to connect to the container
var _container_signal_connections: Dictionary[String, Callable] = {
	"data_value_changed": _on_data_value_changed
}


## Called when an Function is selected
func set_function(function: Function) -> void:
	_function = function
	
	Utils.disconnect_signals(_container_signal_connections, _container)
	_container = _function.get_data_container()
	Utils.connect_signals(_container_signal_connections, _container)
	
	_columns = {"Fixture": 0, "CID": 1}
	_tree.clear()
	_root = _tree.create_item()
	
	var fixture_data: Dictionary = _container.get_fixture_data()
	var fixture_cids: Dictionary[int, Array]
	var parameters: Array[String]
	
	for fixture: Fixture in fixture_data:
		fixture_cids.get_or_add(fixture.cid(), []).append(fixture)
		
		for zone: String in fixture_data[fixture]:
			
			for parameter: String in fixture_data[fixture][zone]:
				if parameter not in parameters:
					parameters.append(parameter)
					_columns[parameter] = parameters.find(parameter) + 2 
	
	_load_data(fixture_cids, parameters, fixture_data)
	
	for column: String in _columns:
		_tree.set_column_title.call_deferred(_columns[column], column)
		_tree.set_column_expand.call_deferred(_columns[column], true)
	
	_tree.set_column_expand.call_deferred(1, false)


## Loads all the data from the container
func _load_data(fixture_cids: Dictionary, parameters: Array, fixture_data: Dictionary):
	var cids: Array = fixture_cids.keys()
	cids.sort()
	parameters.sort()
	_tree.columns = len(parameters) + 2
	
	for cid: int in cids:
		for fixture: Fixture in fixture_cids[cid]:
			var fixture_item: TreeItem = _root.create_child()
			fixture_item.set_text(0, fixture.get_name())
			fixture_item.set_text(1, str(cid))
			
			_fixture_items.map(fixture, fixture_item)
			
			for zone: String in fixture_data[fixture]:
				var zone_item: TreeItem = fixture_item
				
				if zone != "root":
					zone_item = fixture_item.create_child()
					zone_item.set_text(0, zone)
				
				_fixture_zones.get_or_add(fixture, RefMap.new()).map(zone, zone_item)
				
				for parameter: String in fixture_data[fixture][zone]:
					var value: float = fixture_data[fixture][zone][parameter].value
					zone_item.set_text(_columns[parameter], str(value))
					zone_item.set_editable(_columns[parameter], true)
					
					zone_item.set_custom_bg_color(_columns[parameter], _none_zero_data_color if value else _zero_data_color)


## Adds an item to the selected items
func _add_to_selection(item: TreeItem, column: int, selected: bool) -> void:
	var columns: Array = _selected_items.get_or_add(item, [])
	
	if selected:
		if column not in columns:
			columns.append(column)
	else:
		if column in columns:
			columns.erase(column)
		
		if not columns:
			_selected_items.erase(item)


## Called when data is changed in the container
func _on_data_value_changed(fixture: Fixture, parameter: String, zone: String, value: float) -> void:
	var item: TreeItem = _fixture_zones[fixture].left(zone)
	item.set_text(_columns[parameter], str(value))
	item.set_custom_bg_color(_columns[parameter], _none_zero_data_color if value else _zero_data_color)


## Called when a column title is clicked
func _on_tree_column_title_clicked(column: int, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		if not Input.is_key_pressed(KEY_SHIFT):
			_tree.deselect_all()
			_selected_items.clear()
		
		for fixture_item: TreeItem in _root.get_children():
			fixture_item.select(column)
			_selected_items[fixture_item] = [column]
			
			for zone_item: TreeItem in fixture_item.get_children():
				zone_item.select(column)
				_selected_items[fixture_item] = [column]


## GUI input on tree
func _on_tree_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_is_dragging = true
				_drag_start_point = _tree.get_local_mouse_position()
				
				_select_box.size = Vector2.ZERO
				_select_box.position = _drag_start_point
				_select_box.show()
				
			else:
				_is_dragging = false
				_select_box.hide()

		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_tree.edit_selected()


	if event is InputEventMouseMotion and _is_dragging:
		_handle_drag_selection(event)


## Called during drag selection
func _handle_drag_selection(event: InputEventMouseMotion) -> void:
	var start_point: Vector2 = _drag_start_point
	var end_point: Vector2 = event.position
	
	_select_box.position = Vector2(
		min(start_point.x, end_point.x),
		min(start_point.y, end_point.y)
	)
	
	_select_box.size = Vector2(
		abs(end_point.x - start_point.x),
		abs(end_point.y - start_point.y)
	)
	
	var from_column: int = _tree.get_column_at_position(start_point)
	var from_item: TreeItem = _tree.get_item_at_position(start_point)
	var to_column: int = _tree.get_column_at_position(end_point)
	var to_item: TreeItem = _tree.get_item_at_position(end_point)
	
	if from_column <= 2 or to_column <= 2 or not from_item or not to_item:
		return
	
	var from_index: int = from_item.get_index()
	var to_index: int = to_item.get_index()
	var items_to_select: Array[TreeItem]
	
	var index_range: Array = range(to_index, from_index + 1) if from_index > to_index else range(from_index, to_index + 1)
	var column_range: Array = range(to_column, from_column + 1) if from_column > to_column else range(from_column, to_column + 1)
	
	_selected_items.clear()
	_tree.deselect_all()
	for index: int in index_range:
		var item: TreeItem = _root.get_child(index)
		
		for column: int in column_range:
			item.select(column)
			_add_to_selection(item, column, true)


## Called when an item is edited in the tree
func _on_tree_item_edited() -> void:
	var new_value: float = float(_tree.get_edited().get_text(_tree.get_edited_column()))
	
	for selected_item: TreeItem in _selected_items:
		var parent: TreeItem = selected_item.get_parent()
		
		for column: int in _selected_items[selected_item]:

			if parent == _root:
				_container.set_value(
					_fixture_items.right(selected_item),
					_columns.keys()[column],
					"root",
					new_value
				)
			else:
				_container.set_value(
					_fixture_items.right(parent),
					_columns.keys()[column],
					_fixture_zones[_fixture_items.right(parent)].right(selected_item),
					new_value
				)


## Called when items are selected / deselected in the tree
func _on_tree_multi_selected(item: TreeItem, column: int, selected: bool) -> void:
	if not column >= 2:
		return
	
	_add_to_selection(item, column, selected)
