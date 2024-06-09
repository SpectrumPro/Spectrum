# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends PanelContainer
## A view to select items


## Emitted when an item is selected
signal item_selected(key, value)


## Load objects from a dictnary, where the key is the name, and the value being the object to be selected
func load_objects(objects: Dictionary, tab_name: String) -> void:
	var grid_node: GridContainer = load("res://Components/ObjectPicker/Grid.tscn").instantiate()
	
	for object_key: String in objects:
		var new_node: Button = load("res://Components/ObjectPicker/Button.tscn").instantiate()
		
		new_node.pressed.connect(func ():
			item_selected.emit(object_key, objects[object_key])
		)
		
		new_node.get_node("Label").text = object_key.capitalize()
		
		grid_node.add_child(new_node)
	
	grid_node.name = tab_name
	$ObjectPicker.add_child(grid_node)



func _on_close_pressed() -> void:
	hide()
