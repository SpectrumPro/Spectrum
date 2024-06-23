# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends PanelContainer
## UI Panel use for debugging


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
	})


func _on_grid_container_resized() -> void:
	$VBoxContainer/PanelContainer/GridContainer.columns = clamp(int(self.size.x / 85), 1, INF)
