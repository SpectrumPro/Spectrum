# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name UIDataEditor extends UIPanel
## UI panel for editing DataContainers


## Emitted when the DataContainer is changed
signal container_changed(container: DataContainer)

## Emitted when the selection is changed
signal selection_changed(container_item: ContainerItem, selected: bool)

## Emitted when the selection is reset
signal selection_reset()


## The Table
@export var _tree: Tree

## The selection box
@export var _select_box: PanelContainer

## OptionButton for DataViewMode
@export var _data_view_mode_option: OptionButton

## The AddItems button
@export var _add_item_button: Button

## The RemoveItems button
@export var _remove_item_button: Button


## Data View Mode
enum DataViewMode {VALUE, CAN_FADE, START, STOP, FUNCTION}

## Current DataViewMode
var _data_view_mode: DataViewMode = DataViewMode.VALUE

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
var _selected_items: Array[ContainerItem]

## All selected fixtures
var _selected_fixtures: Dictionary[Fixture, Array]

## All selected TreeItems that dont have a corrisponding ContainerItem
var _selected_containerless_items: Dictionary[TreeItem, Array]

## All ContainerItems sorted by TreeItems columns
var _container_items: Dictionary[TreeItem, Dictionary]

## All TreeItems sorted by ContainerItems
var _tree_items: Dictionary[ContainerItem, Dictionary]

## Dragging state
var _is_dragging: bool = false

## Drag start point
var _drag_start_point: Vector2 = Vector2.ZERO

## Color for zero data
var _zero_data_color: Color = Color.TRANSPARENT

## Color for none zero data
var _none_zero_data_color: Color = Color(Color.WHITE, 0.1)

## Color for the fixture items
var _fixture_color: Color = Color(0.09, 0.09, 0.09)

## Signals to connect to the container
var _container_signal_connections: Dictionary[String, Callable] = {
	"items_function_changed": _on_items_function_changed,
	"items_value_changed": _on_items_value_changed,
	"items_can_fade_changed": _on_items_can_fade_changed,
	"items_start_changed": _on_items_start_changed,
	"items_stop_changed": _on_items_stop_changed,
	"items_erased": _on_items_erased,
	"items_stored": _on_items_stored
}


func _ready() -> void:
	for view_mode: String in DataViewMode.keys():
		_data_view_mode_option.add_item(view_mode.capitalize())


## Called when an Function is selected
func set_function(function: Function) -> void:
	_function = function
	
	Utils.disconnect_signals(_container_signal_connections, _container)
	_container = _function.get_data_container()
	Utils.connect_signals(_container_signal_connections, _container)
	
	_columns = {"Fixture": 0, "CID": 1}
	_tree.clear()
	_root = _tree.create_item()
	
	var fixture_data: Dictionary = _container.get_fixtures()
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
	container_changed.emit(_container)


## Sets the data view mode
func set_data_view_mode(data_view_mode: DataViewMode) -> void:
	if not _container or not _function or data_view_mode == _data_view_mode:
		return
	
	_data_view_mode = data_view_mode
	_data_view_mode_option.select(_data_view_mode)
	
	for container_item: ContainerItem in _tree_items:
		_load_item_column_data(_tree_items[container_item].item, container_item,  _tree_items[container_item].column)


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
			fixture_item.set_custom_bg_color(0, _fixture_color)
			fixture_item.set_custom_bg_color(1, _fixture_color)
			
			_fixture_items.map(fixture, fixture_item)
			
			for zone: String in fixture_data[fixture]:
				var zone_item: TreeItem = fixture_item
				
				if zone != "root":
					zone_item = fixture_item.create_child()
					zone_item.set_text(0, zone)
				
				_fixture_zones.get_or_add(fixture, RefMap.new()).map(zone, zone_item)
				
				for parameter: String in fixture_data[fixture][zone]:
					var container_item: ContainerItem = fixture_data[fixture][zone][parameter]
					var column: int = _columns[parameter]
					
					_load_item_column_data(zone_item, container_item, column)
					_container_items.get_or_add(zone_item, {})[column] = container_item
					_tree_items[container_item] = {"item": zone_item, "column": column}


## Loads the data into the TreeItems column
func _load_item_column_data(tree_item: TreeItem, container_item: ContainerItem, column: int) -> void:
	var value: Variant
	
	match _data_view_mode:
		DataViewMode.VALUE:
			tree_item.set_cell_mode(column, TreeItem.CELL_MODE_STRING)
			tree_item.set_editable(column, true)
			
			value = container_item.get_value()
			tree_item.set_text(column, str(value))

		DataViewMode.CAN_FADE:
			tree_item.set_cell_mode(column, TreeItem.CELL_MODE_CHECK)
			tree_item.set_editable(column, false)
			
			value = container_item.get_can_fade()
			tree_item.set_checked(column, value)
			
		DataViewMode.START:
			tree_item.set_cell_mode(column, TreeItem.CELL_MODE_STRING)
			tree_item.set_editable(column, true)
			
			value = container_item.get_start()
			tree_item.set_text(column, str(value))
			
		DataViewMode.STOP:
			tree_item.set_cell_mode(column, TreeItem.CELL_MODE_STRING)
			tree_item.set_editable(column, true)
			
			value = container_item.get_stop()
			tree_item.set_text(column, str(value))
		
		DataViewMode.FUNCTION:
			tree_item.set_cell_mode(column, TreeItem.CELL_MODE_STRING)
			tree_item.set_editable(column, false)
			
			value = container_item.get_function()
			tree_item.set_text(column, value)
	
	tree_item.set_custom_bg_color(column, _none_zero_data_color if value else _zero_data_color)


## Called when items are addded to the DataContainer
func _on_items_stored(items: Array) -> void:
	for container_item: ContainerItem in items:
		if container_item.get_fixture() in _fixture_items.get_left():
			if container_item.get_zone() in _fixture_zones[container_item.get_fixture()].get_left():
				if container_item.get_parameter() in _columns:
					var column: int = _columns[container_item.get_parameter()]
					var item: TreeItem = _fixture_zones[container_item.get_fixture()].left(container_item.get_zone())
					var reselect_item: bool = item in _selected_containerless_items
					
					_add_to_selection(item, column, false)
					_load_item_column_data( item, container_item, column)
					
					_container_items.get_or_add(item, {})[column] = container_item
					_tree_items[container_item] = {"item": item, "column": column}
					
					if reselect_item:
						_add_to_selection(item, column, true)


## Called when items are removed from the DataContainer
func _on_items_erased(items: Array) -> void:
	for container_item: ContainerItem in items:
		var tree_item: TreeItem = _tree_items[container_item].item
		var column: int = _tree_items[container_item].column
		var reselect_item: bool = container_item in _selected_items
		
		tree_item.set_text(column, "")
		tree_item.set_editable(column, false)
		tree_item.set_custom_bg_color(column, _zero_data_color)
		
		_add_to_selection(tree_item, column, false)
		_tree_items.erase(container_item)
		_container_items[tree_item].erase(column)
		
		if reselect_item:
			_add_to_selection(tree_item, column, true)


## Adds an item to the selected items
func _add_to_selection(item: TreeItem, column: int, selected: bool) -> void:
	if column <= 1:
		return
	
	if _container_items[item].has(column):
		var container_item: ContainerItem = _container_items[item][column]
		var fixture: Fixture = container_item.get_fixture()
		
		if selected and not _selected_items.has(container_item):
			_selected_items.append(container_item)
		else:
			_selected_items.erase(container_item)
		
		if selected and not _selected_fixtures.get(fixture, []).has(column):
			_selected_fixtures.get_or_add(fixture, []).append(column)
		else:
			_selected_fixtures.get(fixture, []).erase(column)
			
			if not _selected_fixtures.get(fixture, []):
				_selected_fixtures.erase(fixture)
		
		selection_changed.emit(container_item, selected)
		_remove_item_button.disabled = _selected_items == []
	
	else:
		if selected and not _selected_containerless_items.get(item, []).has(column):
			_selected_containerless_items.get_or_add(item, []).append(column)
		else:
			_selected_containerless_items.get(item, []).erase(column)
			
			if not _selected_containerless_items.get(item, []):
				_selected_containerless_items.erase(item)

		_add_item_button.disabled = _selected_containerless_items == {}


## Selects a whole row
func _select_row(item: TreeItem) -> void:
	for column: int in _columns.values():
		item.select(column)
		_add_to_selection(item, column, true)


## Clears the current selection
func _clear_selection() -> void:
	_tree.deselect_all()
	_selected_items.clear()
	_selected_fixtures.clear()
	_selected_containerless_items.clear()
	
	_remove_item_button.disabled = true
	_add_item_button.disabled = true
	
	selection_reset.emit()


## Called when a functions is changed in the container
func _on_items_function_changed(items: Array, function: String) -> void:
	if not _data_view_mode == DataViewMode.FUNCTION:
		return
	
	for container_item: ContainerItem in items:
		var tree_item: TreeItem = _tree_items[container_item].item
		var column: int = _tree_items[container_item].column
		
		tree_item.set_text(column, function)
		tree_item.set_custom_bg_color(column, _none_zero_data_color if function else _zero_data_color)


## Called when data is changed in the container
func _on_items_value_changed(items: Array, value: float) -> void:
	if not _data_view_mode == DataViewMode.VALUE:
		return
	
	for container_item: ContainerItem in items:
		var tree_item: TreeItem = _tree_items[container_item].item
		var column: int = _tree_items[container_item].column
		
		tree_item.set_text(column, str(value))
		tree_item.set_custom_bg_color(column, _none_zero_data_color if value else _zero_data_color)


## Called when the can_fade state is changed on any item in the container
func _on_items_can_fade_changed(items: Array, can_fade: bool) -> void:
	if not _data_view_mode == DataViewMode.CAN_FADE:
		return
	
	for container_item: ContainerItem in items:
		var tree_item: TreeItem = _tree_items[container_item].item
		var column: int = _tree_items[container_item].column
		
		tree_item.set_checked(column, can_fade)
		tree_item.set_custom_bg_color(column, _none_zero_data_color if can_fade else _zero_data_color)


## Called when the can_fade state is changed on any item in the container
func _on_items_start_changed(items: Array, start: float) -> void:
	if not _data_view_mode == DataViewMode.START:
		return
	
	for container_item: ContainerItem in items:
		var tree_item: TreeItem = _tree_items[container_item].item
		var column: int = _tree_items[container_item].column
		
		tree_item.set_text(column, str(start))
		tree_item.set_custom_bg_color(column, _none_zero_data_color if start else _zero_data_color)


## Called when the can_fade state is changed on any item in the container
func _on_items_stop_changed(items: Array, stop: float) -> void:
	if not _data_view_mode == DataViewMode.STOP:
		return
	
	for container_item: ContainerItem in items:
		var tree_item: TreeItem = _tree_items[container_item].item
		var column: int = _tree_items[container_item].column
		
		tree_item.set_text(column, str(stop))
		tree_item.set_custom_bg_color(column, _none_zero_data_color if stop else _zero_data_color)


## Called when a column title is clicked
func _on_tree_column_title_clicked(column: int, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		if not Input.is_key_pressed(KEY_SHIFT):
			_clear_selection()
		
		for fixture_item: TreeItem in _root.get_children():
			fixture_item.select(column)
			_add_to_selection(fixture_item, column, true)
			
			for zone_item: TreeItem in fixture_item.get_children():
				zone_item.select(column)
				_add_to_selection(zone_item, column, true)
		
		_root.get_child(0).select(column)


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
			match _data_view_mode:
				DataViewMode.CAN_FADE:
					if not _tree.get_selected_column() > 1 or not _selected_items:
						return
					
					var active_item: TreeItem = _tree.get_selected()
					_container.set_can_fade(_selected_items, not active_item.is_checked(_tree.get_selected_column()))
				
				DataViewMode.FUNCTION:
					if not _tree.get_selected_column() > 1 or not _selected_items:
						return
					
					Interface.show_function_list(_selected_fixtures.keys(), _columns.keys()[_tree.get_selected_column()]).then(func (function: String):
						_container.set_function(_selected_items, function)
					)
				_:
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
	
	if from_column <= 1 or to_column <= 1 or not from_item or not to_item:
		return
	
	var from_index: int = from_item.get_index()
	var to_index: int = to_item.get_index()
	var items_to_select: Array[TreeItem]
	
	var index_range: Array = range(to_index, from_index + 1) if from_index > to_index else range(from_index, to_index + 1)
	var column_range: Array = range(to_column, from_column + 1) if from_column > to_column else range(from_column, to_column + 1)
	
	_clear_selection()
	for index: int in index_range:
		var item: TreeItem = _root.get_child(index)
		
		for column: int in column_range:
			item.select(column)
			_add_to_selection(item, column, true)


## Called when an item is edited in the tree
func _on_tree_item_edited() -> void:
	var tree_item: TreeItem = _tree.get_edited()
	
	match _data_view_mode:
		DataViewMode.VALUE:
			_container.set_value(_selected_items, float(tree_item.get_text(_tree.get_edited_column())))
		
		DataViewMode.CAN_FADE:
			pass
		
		DataViewMode.START:
			_container.set_start(_selected_items, float(tree_item.get_text(_tree.get_edited_column())))
		
		DataViewMode.STOP:
			_container.set_stop(_selected_items, float(tree_item.get_text(_tree.get_edited_column())))


## Called when items are selected / deselected in the tree
func _on_tree_multi_selected(item: TreeItem, p_column: int, selected: bool) -> void:
	if p_column >= 2:
		_add_to_selection(item, p_column, selected)


## Called when an item is selected with the mouse
func _on_tree_item_mouse_selected(mouse_position: Vector2, mouse_button_index: int) -> void:
	if _tree.get_selected_column() <= 1:
		_select_row.call_deferred(_tree.get_selected())


## Called when the data view mode is changed
func _on_data_view_mode_item_selected(index: int) -> void:
	set_data_view_mode(index)


## Called when the AddItems button is pressed
func _on_add_item_pressed() -> void:
	var items_to_add: Array[ContainerItem]
	
	for tree_item: TreeItem in _selected_containerless_items:
		for column: int in _selected_containerless_items[tree_item]:
			var container: ContainerItem = ContainerItem.new()
			var fixture: Fixture = _fixture_items.right(tree_item) if tree_item.get_parent() == _root else _fixture_items.right(tree_item.get_parent())
			var zone: String = Fixture.RootZone if tree_item.get_parent() == _root else _fixture_zones[fixture].right(tree_item)
			var parameter: String = _columns.keys()[column]
			var function: String = fixture.get_default_function(zone, parameter)
			
			container.set_fixture(fixture)
			container.set_zone(zone)
			container.set_parameter(parameter)
			container.set_function(function)
			container.set_value(fixture.get_default(zone, parameter, function))
			container.set_can_fade(fixture.function_can_fade(zone, parameter, function))
			
			items_to_add.append(container)
	
	_container.store_items(items_to_add)


## Called when the RemoveItems button is pressed
func _on_remove_item_pressed() -> void:
	_container.erase_items(_selected_items)
