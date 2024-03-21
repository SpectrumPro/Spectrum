extends HBoxContainer

func _on_save_pressed() -> void:
	print(Core.save("Debug_show.spsave", OS.get_environment("HOME")))


func _on_load_pressed() -> void:
	var menu: FileDialog = Globals.components.file_load_menu.instantiate()
	
	menu.confirmed.connect(
		func():
			Core.load(menu.current_path)
	)
	
	get_tree().root.add_child(menu)
