# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name RowItem extends Control
## Stores CellItems in a row


## The corresponding row index
var headder: RowHeadder


## Adds data to the next empty cell
func add_data(data: Variant, setter: Callable, changer: Signal, index: int = -1) -> CellItem:
	var cell_item: CellItem = load("res://components/Table/TableItems/CellItem.tscn").instantiate()
	
	cell_item.set_data(data)
	cell_item.setter = setter
	cell_item.set_signal(changer)
	
	return _add_cell_item(cell_item, index)


## Adds a button to the next empty cell
func add_button(text: String, callback: Callable, index: int = -1) -> CellItem:
	var cell_item: CellItem = load("res://components/Table/TableItems/CellItem.tscn").instantiate()
	
	cell_item.set_button(text, callback)
	
	return _add_cell_item(cell_item, index)


## Adds a drop down to the next empty cell
func add_dropdown(items: Array, current: int, callback: Callable, changer: Signal, index: int = -1) -> CellItem:
	var cell_item: CellItem = load("res://components/Table/TableItems/CellItem.tscn").instantiate()
	
	cell_item.set_dropdown(items, current, callback)
	cell_item.set_signal(changer)
	
	return _add_cell_item(cell_item, index)


## Adds an empty CellItem
func add_blank() -> CellItem:
	var cell_item: CellItem = load("res://components/Table/TableItems/CellItem.tscn").instantiate()
	
	return _add_cell_item(cell_item)


## Shows or hides the selected border
func set_selected(selected: bool) -> void:
	$Selection.visible = selected


## Adds the cell item to the row
func _add_cell_item(cell_item: CellItem, index: int = -1) -> CellItem:
	$HBoxContainer.add_child(cell_item)
	cell_item.i = index
	
	if index != -1:
		var cell: CellItem = $HBoxContainer.get_child(index)
		
		if cell and cell.is_blank:
			$HBoxContainer.remove_child(cell)
			$HBoxContainer.move_child(cell_item, index)
	
	elif $HBoxContainer.get_child_count():
		var i: int = 0
		var cell: CellItem = $HBoxContainer.get_child(i)

		while i < $HBoxContainer.get_child_count() and not cell.is_blank:
			i += 1
			cell = $HBoxContainer.get_child(i)
		
		if cell:
			$HBoxContainer.remove_child(cell)
			$HBoxContainer.move_child(cell_item, cell.get_index())
	
	return cell_item
