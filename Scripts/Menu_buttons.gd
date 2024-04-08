extends HBoxContainer

func _on_save_pressed() -> void:
	
	var menu: FileDialog = Globals.components.file_save_menu.instantiate()
	
	menu.confirmed.connect(
		func():
			print(Core.save(menu.current_file, menu.current_dir))
	)
	
	get_tree().root.add_child(menu)
	


func _on_load_pressed() -> void:
	var menu: FileDialog = Globals.components.file_load_menu.instantiate()
	
	menu.confirmed.connect(
		func():
			Core.load(menu.current_path)
	)
	
	get_tree().root.add_child(menu)
