# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name Table extends PanelContainer
## A table for displaying and editing data


## Emitted when the add row button is pressed
signal add_row_button_pressed()

## Emitted when a row is selected
signal row_selected(row: RowHeadder)

## Emitted when a column is selected
signal column_selected(colum: ColumnIndex)

## Emitted when nothing is selected
signal nothing_selected()


## The Scroll Containers
@onready var table_scroll_container: ScrollContainer = $VBoxContainer/HBoxContainer2/PanelContainer2/ScrollContainer
@onready var row_index_scroll_container: ScrollContainer = $VBoxContainer/HBoxContainer2/PanelContainer/ScrollContainer
@onready var column_index_scroll_container: ScrollContainer = $VBoxContainer/HBoxContainer/PanelContainer2/ScrollContainer

## Row and Column item containers
@onready var column_item_container: HBoxContainer = $VBoxContainer/HBoxContainer/PanelContainer2/ScrollContainer/HBoxContainer
@onready var row_item_container: VBoxContainer = $VBoxContainer/HBoxContainer2/PanelContainer/ScrollContainer/VBoxContainer
@onready var cell_item_container: VBoxContainer = $VBoxContainer/HBoxContainer2/PanelContainer2/ScrollContainer/VBoxContainer

## The add button
@onready var add_row_button: Button = $VBoxContainer/HBoxContainer2/PanelContainer/ScrollContainer/VBoxContainer/AddButton


## Stores all the row items. {{index: RowItem}
var _row_items: Dictionary[int, RowItem] = {}

## Current selected row
var _selected_row: RowHeadder

## Current selected column
var _selected_column: ColumnIndex


func _ready() -> void:
	table_scroll_container.get_h_scroll_bar().value_changed.connect(_on_h_scrolled)
	table_scroll_container.get_v_scroll_bar().value_changed.connect(_on_v_scrolled)
	
	row_index_scroll_container.get_v_scroll_bar().value_changed.connect(_on_v_side_scrolled)
	column_index_scroll_container.get_h_scroll_bar().value_changed.connect(_on_h_side_scrolled)


## Gets the corner node, so you can add custem lables or buttons
func get_corner_node() -> PanelContainer: 
	return $VBoxContainer/HBoxContainer/Corner

## Shows or hides the add row button
func set_show_add_button(show: bool) -> void: 
	add_row_button.visible = show


## Clears this table, removing all items, row, and columns
func clear() -> void:
	clear_columns()
	clear_rows()
	clear_cells()


## Removes all the columns
func clear_columns() -> void:
	_selected_column = null
	for column_item: ColumnIndex in column_item_container.get_children():
		column_item_container.remove_child(column_item)
		column_item.queue_free()


## Removes all the rows
func clear_rows() -> void:
	_selected_row = null
	for row_item: Node in row_item_container.get_children():
		if row_item is RowHeadder:
			row_item_container.remove_child(row_item)
			row_item.queue_free()
	_row_items = {}


## Removes all the cell items
func clear_cells() -> void:
	_selected_column = null
	_selected_row = null
	for node: Control in cell_item_container.get_children():
		cell_item_container.remove_child(node)
		node.queue_free()


## Adds a new column to this table
func create_column(column_name: String) -> ColumnIndex:
	var new_column: ColumnIndex = load("res://components/Table/TableItems/ColumnIndex.tscn").instantiate()
	new_column.set_text(column_name)
	
	column_item_container.add_child(new_column)
	new_column.column_index = new_column.get_index()
	
	(func ():
		cell_item_container.custom_minimum_size.x = new_column.position.x + new_column.size.x
	).call_deferred()
	
	for row: RowItem in _row_items.values():
		row.add_blank()
	
	return new_column


## Created mutiple columns at once
func create_columns(columns: Array[String]) -> Array[ColumnIndex]:
	if not columns: return []
	var new_columns: Array[ColumnIndex]
	
	for column_name: String in columns:
		new_columns.append(create_column(column_name))
	
	return new_columns


## Adds a new row to this table
func create_row(row_name: String) -> RowHeadder:
	var new_row: RowHeadder = load("res://components/Table/TableItems/RowHeadder.tscn").instantiate()
	var new_row_item: RowItem = load("res://components/Table/TableItems/RowItem.tscn").instantiate()
	
	row_item_container.add_child(new_row)
	cell_item_container.add_child(new_row_item)
	add_row_button.move_to_front()
	
	new_row.set_text(row_name)
	new_row.index = new_row.get_index()
	
	new_row.row_item = new_row_item
	new_row_item.headder = new_row
	
	new_row.clicked.connect(func ():
		set_row_selected(new_row.index)
	)
	
	for column: ColumnIndex in column_item_container.get_children():
		new_row_item.add_blank()
	
	_row_items[new_row.index] = new_row_item
	return new_row


## Created mutiple rows at once
func create_rows(rows: Array[String]) -> Array[RowHeadder]:
	var new_rows: Array[RowHeadder]
	
	for row_name: String in rows:
		new_rows.append(create_row(row_name))
	
	return new_rows


## Removes a row
func remove_row(row_index: int) -> void:
	if not row_index in _row_items: return
	
	if _selected_row and _selected_row.index == row_index:
		deselect_all()
	
	var row_header: RowHeadder = _row_items[row_index].headder
	row_item_container.remove_child(row_header)
	cell_item_container.remove_child(row_header.row_item)
	
	_row_items.erase(row_index)


## Moves a row, by changing the child order
func move_row(row_index: int, to: int) -> void:
	if not row_index in _row_items: return
	
	var row_header: RowHeadder = _row_items[row_index].headder
	row_item_container.move_child(row_header, to)
	cell_item_container.move_child(row_header.row_item, to)


## Adds a cellitem with data in it
func add_data(row_index: int, data: Variant, setter: Callable, changer: Signal, index: int = -1) -> CellItem:
	if not row_index in _row_items: return null
	
	return (_row_items[row_index] as RowItem).add_data(data, setter, changer, index)


## Adds a button
func add_button(row_index: int, text: String, callback: Callable, index: int = -1) -> CellItem:
	if not row_index in _row_items: return null
	
	return (_row_items[row_index] as RowItem).add_button(text, callback, index)


## Adds a dropdown
func add_dropdown(row_index: int, items: Array, current: int ,callback: Callable, changer: Signal, index: int = -1) -> CellItem:
	if not row_index in _row_items: return null
	
	return (_row_items[row_index] as RowItem).add_dropdown(items, current, callback, changer, index)


## Selectes nothing
func deselect_all() -> void:
	if _selected_row:
		_selected_row.set_selected(false)
		_selected_row = null
	
	nothing_selected.emit()


## Sets a row selected
func set_row_selected(index: int) -> void:
	if _row_items.has(index):
		if _selected_row:
			_selected_row.set_selected(false)
		
		_selected_row = _row_items[index].headder
		_selected_row.set_selected(true)
		
		row_selected.emit(_selected_row)


## Returns the selected row or null
func get_selected_row() -> RowHeadder:
	return _selected_row


## Updates the min Y size of the rows, fixing issues with scrolling
func _update_row_min_size() -> void:
	row_item_container.custom_minimum_size.y = 0
	
	var row_container_y: int = row_item_container.size.y
	
	cell_item_container.custom_minimum_size.y = row_container_y - 20 


## Called when the table_scroll_container is scrolled horizontally
func _on_h_scrolled(value: float) -> void:column_index_scroll_container.scroll_horizontal = int(value)

## Called when the table_scroll_container is scrolled vertically 
func _on_v_scrolled(value: float) -> void: row_index_scroll_container.scroll_vertical = int(value)

## Called when the side bar scroll container is scrolled 
func _on_v_side_scrolled(value: float) -> void: table_scroll_container.scroll_vertical = value

## Called when the top bar scroll container is scrolled 
func _on_h_side_scrolled(value: float) -> void: table_scroll_container.scroll_horizontal = value

## Called when the add row button is pressed
func _on_add_button_pressed() -> void: add_row_button_pressed.emit()


func _on_v_box_container_minimum_size_changed() -> void:
	_update_row_min_size()


func _on_h_box_container_2_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_mask == MOUSE_BUTTON_MASK_LEFT and event.is_pressed():
		deselect_all()
