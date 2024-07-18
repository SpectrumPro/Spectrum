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


func _on_list_functions_pressed() -> void:
	var output: Dictionary = {}
	
	for function_uuid: String in Core.functions:
		output[function_uuid] = Core.functions[function_uuid].name + " | " + str(Core.functions[function_uuid])
		
	set_output(JSON.stringify(output, "\t"))


func _on_send_message_to_server_pressed() -> void:
	Client.send({
		"for": $VBoxContainer/PanelContainer2/ScrollContainer/HBoxContainer/For/HBoxContainer/For.text,
		"call": $VBoxContainer/PanelContainer2/ScrollContainer/HBoxContainer/Call/HBoxContainer/Method.text,
		"args": str_to_var($VBoxContainer/PanelContainer2/ScrollContainer/HBoxContainer/Args/HBoxContainer/Args.text)
	}, func (result=null):
		if result is Dictionary:
			set_output(JSON.stringify(result, "\t"))
		else:
			set_output(str(result))
	)
