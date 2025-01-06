# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name DataPaletteComponent extends PanelContainer
## A Data palette


## Emitted when an item is clicked
signal item_clicked(who: PaletteItemComponent)


## Number of rows
var rows: int = 0 : set = set_rows

## Number of columns
var columns: int = 0 : set = set_columns


## The GridContainer containing all the items
@export var _grid_container: GridContainer

## All the items in this Palette, sorted by visual order
var _items: Array[PaletteItemComponent]


func _ready() -> void:
	_update_container_size()


## Adds a new item to this palette
func add_item(text: String) -> PaletteItemComponent:
	var new_item: PaletteItemComponent = PaletteItemComponent.new()
	new_item.set_label_text(text)
	
	return new_item


## Sets the number of rows
func set_rows(p_rows: int) -> void:
	rows = p_rows
	_update_container_size()


## Sets the number of columns
func set_columns(p_columns: int) -> void:
	columns = p_columns
	_update_container_size()


## Removes all items from this palette
func _clear() -> void:
	for item: PaletteItemComponent in _items:
		_grid_container.remove_child(item)
	
	_items.clear()


## Updates the quantity of nodes and number of columns on the Scroll Container to match the given size
func _update_container_size() -> void:
	var total: int = rows * columns
	var current: int = len(_items)
	
	if total == current:
		print("No change needed")
		return
	
	elif total < current:
		var needed: int = current - total
		print("Items needed is less then total current, adding: ", needed)
		
		for i in range(needed + 1):
			var new_item: PaletteItemComponent = PaletteItemComponent.new()
			new_item.set_item_disabled(true)
			
			
			
		pass
	
	elif total > current:
		var to_remove: Array[PaletteItemComponent] = _items.slice(total - 1)
		print("Items needed exceeds total current items, removing: ", len(to_remove))
		
		for item: PaletteItemComponent in to_remove:
			_grid_container.remove_child(item)
			_items.erase(item)
