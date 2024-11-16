# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name RowItem extends Control
## Stores CellItems in a row


func add_data(data: Variant, setter: Callable, changer: Signal) -> CellItem:
	var cell_item: CellItem = load("res://components/Table/TableItems/CellItem.tscn").instantiate()
	
	cell_item.set_data(data)
	cell_item.setter = setter
	cell_item.set_signal(changer)
	
	$HBoxContainer.add_child(cell_item)
	$HBoxContainer.add_child($HBoxContainer/Seprator.duplicate())
	return cell_item
