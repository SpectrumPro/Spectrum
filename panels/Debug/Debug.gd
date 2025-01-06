# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name UIDebug extends UIPanel
## UI Panel use for debugging


## Sets the text in the output
func set_output(output: Variant) -> void:
	var result: String = ""
	
	if output is Dictionary:
		result = JSON.stringify(result, "\t")
	else:
		result = str(output)
	
	$VBoxContainer/PanelContainer/HBoxContainer/Output.text = result


## Will reset the engine
func _on_reset_pressed() -> void: Client.send_command("debug", "reset")

## Will quit the engine
func _on_stop_pressed() -> void: Client.send_command("debug", "quit")

## Will crash the server
func _on_crash_pressed() -> void: Client.send_command("debug", "crash")


## Sets the output to the selected component uuid
func _on_get_component_uuid_pressed() -> void:
	Interface.show_object_picker(ObjectPicker.SelectMode.Single, func (objects: Array):
		set_output(objects[0].uuid)
	)


## Dumps the servers networkd objects to a file
func _on_dump_networked_objects_pressed() -> void:
	Client.send_command("debug", "dump_networked_objects").then(func (file_path: String):
		set_output("Networked Objects dumped to (on-server): " + file_path)
	)

## Shows the device id, obtained from OS.get_unique_id()
func _on_get_unique_id_pressed() -> void: set_output(OS.get_unique_id())


## Sets the output to a list containing all the functions
func _on_list_functions_pressed() -> void:
	var output: Dictionary = {}
	
	for function: Function in ComponentDB.get_components_by_classname("Function"):
		output[function.uuid] = str(function) + " | " + function.name 
	
	set_output(output)


func _on_send_message_to_server_pressed() -> void:
	Client.send_command(
		$VBoxContainer/PanelContainer2/ScrollContainer/HBoxContainer/For/HBoxContainer/For.text,
		$VBoxContainer/PanelContainer2/ScrollContainer/HBoxContainer/Call/HBoxContainer/Method.text,
		str_to_var($VBoxContainer/PanelContainer2/ScrollContainer/HBoxContainer/Args/HBoxContainer/Args.text)
	).then(func (result: Variant = null):
		set_output(result)
	)
