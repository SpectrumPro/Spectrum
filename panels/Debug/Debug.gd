# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends PanelContainer
## UI Panel use for debugging


## Sets the text in the output
func set_output(output: String) -> void:
	$VBoxContainer/PanelContainer/HBoxContainer/Output.text = output
	print(output)


## Will quit the engine
func _on_stop_pressed() -> void:
		Client.send({
		"for": "debug",
		"call": "quit"
	})


## Will crash the server
func _on_crash_pressed() -> void:
	Client.send({
		"for": "debug",
		"call": "crash"
	})


## Dumps the servers networkd objects to a file
func _on_dump_networked_objects_pressed() -> void:
	Client.send({
		"for": "debug",
		"call": "dump_networked_objects"
	}, func (file_path: String):
		set_output("Networked Objects dumped to (on-server): " + file_path)
	)


## Shows the device id, obtained from OS.get_unique_id()
func _on_get_unique_id_pressed() -> void:
	set_output(OS.get_unique_id())


func _on_grid_container_resized() -> void:
	$VBoxContainer/PanelContainer/HBoxContainer/GridContainer.columns = clamp(int(self.size.x / 85), 1, INF)


