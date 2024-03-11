extends HBoxContainer

func _on_save_pressed() -> void:
	print(OS.get_environment("HOME"))
	print(Core.save("Debug_show.spsave", OS.get_environment("HOME")))
