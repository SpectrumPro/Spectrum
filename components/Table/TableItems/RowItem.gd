# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name RowItem extends Control
## Stores CellItems in a row


## The corresponding row index
var headder: RowHeadder


## Adds data to the next empty cell
func add_data(data: Variant, setter: Callable, changer: Signal) -> CellItem:
	var cell_item: CellItem = load("res://components/Table/TableItems/CellItem.tscn").instantiate()
	
	cell_item.set_data(data)
	cell_item.setter = setter
	cell_item.set_signal(changer)
	return _add_cell_item(cell_item)


## Adds a button to the next empty cell
func add_button(text: String, callback: Callable) -> CellItem:
	var cell_item: CellItem = load("res://components/Table/TableItems/CellItem.tscn").instantiate()
	
	cell_item.set_button(text, callback)
	return _add_cell_item(cell_item)


## Adds a drop down to the next empty cell
func add_dropdown(items: Array, current: int, callback: Callable, changer: Signal) -> CellItem:
	var cell_item: CellItem = load("res://components/Table/TableItems/CellItem.tscn").instantiate()
	
	cell_item.set_dropdown(items, current, callback)
	cell_item.set_signal(changer)
	
	return _add_cell_item(cell_item)


## Shows or hides the selected border
func set_selected(selected: bool) -> void:
	$Selection.visible = selected


## Adds the cell item to the row
func _add_cell_item(cell_item: CellItem) -> CellItem:
	$HBoxContainer.add_child(cell_item)
	$HBoxContainer.add_child($HBoxContainer/Seprator.duplicate())
	return cell_item
