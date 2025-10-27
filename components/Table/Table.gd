# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name Table extends UIComponent
## Class to create a spreadsheet like table


## Emitted when the cell selection is changed
signal selection_changed()


## The Tree Node
@onready var _tree: Tree = $Tree


## All columns in the tree
var _columns: Array[Column] 

## RefMap for Row: TreeItem
var _rows: RefMap = RefMap.new()

## The Tree Root
var _root: TreeItem

## All selected TreeItems, and thier selected columns
var _selected_items: Dictionary[TreeItem, Array]

## All TreeItems that have a theme select color tint for a selection
var _active_row_tints: Array[TreeItem]

## Wether or not a selection update and signal emition is queued
var _is_selection_update_queued: bool = false


## Class to repersent a row in the tree
class Row extends Object:
	## The TreeItem
	var _item: TreeItem
	
	## All the Columns in the table
	var _columns: Array[Column] 
	
	## Data for each cell in this row
	var _cells: Dictionary[int, Variant]
	
	## All bound callables for a SettingsModule
	var _module_bound_methods: Dictionary[int, Callable]
	
	## Init
	func _init(p_item: TreeItem, p_columns: Array[Column], p_data: Dictionary[int, Variant]) -> void:
		_item = p_item
		_columns = p_columns
		
		for column: int in p_data:
			set_cell_data(column, p_data[column])
	
	## Sets the data with in a cell
	func set_cell_data(p_column: int, p_value: Variant) -> void:
		if p_column > len(_columns):
			return
		
		if _module_bound_methods.has(p_column):
			(_cells[p_column] as SettingsModule).unsubscribe(_module_bound_methods[p_column])
			_module_bound_methods.erase(p_column)
		
		if p_value is SettingsModule:
			if p_value.get_data_type() != _columns[p_column]._data_type:
				return
			
			_module_bound_methods[p_column] = p_value.subscribe(_set_cell_data_module.bind(p_column))
			
			_cells[p_column] = p_value
			_item.set_text(p_column, p_value.get_value_string())
		
		else:
			_cells[p_column] = Data.data_type_convert(p_value, _columns[p_column]._data_type)
			_item.set_text(p_column, str(_cells[p_column]))
	
	## Gets the data in a cell
	func get_cell_data(p_column: int) -> Variant:
		return _cells.get(p_column, null)
	
	
	## Sets the cell data from a SettingsModule callback
	func _set_cell_data_module(p_data: Variant, p_column: int) -> void:
		if is_instance_valid(_item):
			_item.set_text(p_column, _cells[p_column].get_value_string())
		


## Class to repersent a column in the tree
class Column extends Object:
	## Column number
	var _id: int = 0
	
	## Name of this column
	var _name: String = ""
	
	## DataType for this column
	var _data_type: Data.Type = Data.Type.NULL
	
	## Init
	func _init(p_id: int, p_name: String, p_data_type: Data.Type) -> void:
		_id = p_id
		_name = p_name
		_data_type = p_data_type


## Init
func _init() -> void:
	super._init()
	
	_set_class_name("Table")


## Ready
func _ready() -> void:
	_root = _tree.create_item()


## Adds a new column to the table
func add_column(p_name: String, p_data_type: Data.Type) -> Column:
	var column_id: int = len(_columns)
	var new_column: Column = Column.new(column_id, p_name, p_data_type)
	
	_columns.append(new_column)
	_tree.columns = max(column_id + 1, 1)
	_tree.set_column_title.call_deferred(column_id, p_name)
	
	return new_column


## Adds a new row to the table
func add_row(p_data: Dictionary[int, Variant]) -> Row:
	var new_item: TreeItem = _root.create_child()
	var new_row: Row = Row.new(new_item, _columns, p_data)
	
	_rows.map(new_row, new_item)
	return new_row


## Removes a row from the table
func remove_row(p_row: Row) -> bool:
	var item: TreeItem = _rows.left(p_row)
	
	if not item:
		return false
	
	if item in _selected_items:
		_selected_items.erase(item)
	
	_rows.erase_left(p_row)
	_update_selection()
	
	p_row.free()
	item.free()
	return true


## Clears the whole table
func clear() -> void:
	_rows.clear()
	_selected_items.clear()
	_active_row_tints.clear()
	
	_tree.clear()
	_root = _tree.create_item()


## Returns the first selected row
func get_selected_row() -> Row:
	if _selected_items:
		return _rows.right(_selected_items.keys()[0])
	else:
		return null


## Returns True if there are selected items in the tree
func is_any_selected() -> bool:
	return not _selected_items.is_empty()


## Updates all the row selection, adding a light blue tint to selected rows
func _update_selection() -> void:
	var rows_to_reset: Array[TreeItem] = _active_row_tints.duplicate()
	_active_row_tints.clear()
	
	for item: TreeItem in _selected_items:
		rows_to_reset.erase(item)
		_active_row_tints.append(item)
		
		for column: Column in _columns:
			item.set_custom_bg_color(column._id, ThemeManager.Colors.Selections.SelectedDimmed)
	
	for item: TreeItem in rows_to_reset:
		for column: Column in _columns:
			item.set_custom_bg_color(column._id, Color.TRANSPARENT)
	
	selection_changed.emit()
	_is_selection_update_queued = false


## Called when a cell in the tree is selected
func _on_tree_multi_selected(p_item: TreeItem, p_column: int, p_selected: bool) -> void:
	if p_selected:
		var columns: Array = _selected_items.get_or_add(p_item, [])
		
		if p_column not in columns:
			columns.append(p_column)
	
	else:
		var columns: Array = _selected_items.get(p_item, [])
		columns.erase(p_column)
		
		if not columns:
			_selected_items.erase(p_item)
	
	if not _is_selection_update_queued:
		_update_selection.call_deferred()
		_is_selection_update_queued = true


## Called when nothing is selected in the tree
func _on_tree_nothing_selected() -> void:
	_tree.deselect_all()
	_selected_items.clear()
	_update_selection()


## Called for each GUI input on the tree
func _on_tree_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		var mouse_pos: Vector2 = _tree.get_local_mouse_position()
		var row: Row = _rows.right(_tree.get_item_at_position(mouse_pos))
		
		if not row:
			return
		
		var column: int = _tree.get_column_at_position(mouse_pos)
		var data: Variant = row.get_cell_data(column)
		
		if data is SettingsModule:
			Interface.prompt_settings_module(self, data)
