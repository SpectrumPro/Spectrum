extends PanelContainer

signal item_selected(key, value)

# Called every frame. 'delta' is the elapsed time since the previous frame.
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
