# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name Table extends PanelContainer
## A table for displaying and editing data


## Emitted when the add row button is pressed
signal add_row_button_pressed()


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

## Stores all the rows
var _rows: Dictionary = {}


func _ready() -> void:
	table_scroll_container.get_h_scroll_bar().value_changed.connect(_on_h_scrolled)
	table_scroll_container.get_v_scroll_bar().value_changed.connect(_on_v_scrolled)
	
	row_index_scroll_container.get_v_scroll_bar().value_changed.connect(_on_v_side_scrolled)
	column_index_scroll_container.get_h_scroll_bar().value_changed.connect(_on_h_side_scrolled)


## Gets the corner node, so you can add custem lables or buttons
func get_corner_node() -> PanelContainer: return $VBoxContainer/HBoxContainer/Corner

## Shows or hides the add row button
func set_show_add_button(show: bool) -> void: add_row_button.visible = show


## Clears this table, removing all items, row, and columns
func clear() -> void:
	clear_columns()
	clear_rows()
	clear_cells()


## Removes all the columns
func clear_columns() -> void:
	for column_item: ColumnIndex in column_item_container.get_children():
		column_item_container.remove_child(column_item)
		column_item.queue_free()


## Removes all the rows
func clear_rows() -> void:
	for row_item: Node in row_item_container.get_children():
		if row_item is RowIndex:
			row_item_container.remove_child(row_item)
			row_item.queue_free()
	_rows = {}


## Removes all the cell items
func clear_cells() -> void:
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
	
	return new_column


## Created mutiple columns at once
func create_columns(columns: Array[String]) -> Array[ColumnIndex]:
	if not columns: return []
	var new_columns: Array[ColumnIndex]
	
	for column_name: String in columns:
		new_columns.append(create_column(column_name))
	
	return new_columns


## Adds a new row to this table
func create_row(row_name: String) -> RowIndex:
	var new_row: RowIndex = load("res://components/Table/TableItems/RowIndex.tscn").instantiate()
	var new_row_item: RowItem = load("res://components/Table/TableItems/RowItem.tscn").instantiate()
	
	row_item_container.add_child(new_row)
	cell_item_container.add_child(new_row_item)
	add_row_button.move_to_front()
	
	new_row.set_text(row_name)
	new_row.row_index = new_row.get_index()
	new_row.row_item = new_row_item
	
	_rows[new_row.row_index] = new_row_item
	return new_row


## Created mutiple rows at once
func create_rows(rows: Array[String]) -> Array[RowIndex]:
	var new_rows: Array[RowIndex]
	
	for row_name: String in rows:
		new_rows.append(create_row(row_name))
	
	return new_rows


## Adds a cellitem with data in it
func add_data(row_index: int, data: Variant, setter: Callable, changer: Signal) -> CellItem:
	if not row_index in _rows: return null
	
	return (_rows[row_index] as RowItem).add_data(data, setter, changer)


## Adds a button
func add_button(row_index: int, text: String, callback: Callable) -> CellItem:
	if not row_index in _rows: return null
	
	return (_rows[row_index] as RowItem).add_button(text, callback)


## Adds a dropdown
func add_dropdown(row_index: int, items: Array, current: int ,callback: Callable, changer: Signal) -> CellItem:
	if not row_index in _rows: return null
	
	return (_rows[row_index] as RowItem).add_dropdown(items, current, callback, changer)


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
