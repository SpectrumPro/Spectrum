# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name UIDebug extends UIPanel
## UI Panel use for debugging


## Message for object input
@export var message_for: LineEdit

## Message object method
@export var message_method: LineEdit

## Message method args
@export var message_args: LineEdit


## Sets the text in the output
func set_output(output: Variant) -> void:
	var result: String = ""
	
	if output is Dictionary:
		result = JSON.stringify(result, "\t")
	else:
		result = str(output)
	
	$VBoxContainer/PanelContainer/HBoxContainer/Output.text = result


## Resets the engine
func _on_reset_pressed() -> void: Client.send_command("debug", "reset")

## Quits the engine
func _on_stop_pressed() -> void: Client.send_command("debug", "quit")

## Crash the server
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


## Shows an objectpicker then a ComponentNamePopup
func _on_change_name_pressed() -> void:
	Interface.show_object_picker(ObjectPicker.SelectMode.Single, func(objects: Array):
		Interface.show_name_prompt(objects[0])
	)


func _on_send_message_to_server_pressed() -> void:
	var args: Variant = str_to_var(message_args.text)
	
	if args is Array:
		Client.send_command(
			message_for.text,
			message_method.text,
			args
		).then(func (result: Variant = null):
			set_output(result)
		)


## Saves this panel into a dictonary
func _save() -> Dictionary:
	return {
		"message": {
			"for": message_for.text,
			"method": message_method.text,
			"args": message_args.text
		}
	}


## Loads this panel from a dictonary
func _load(saved_data: Dictionary) -> void:
	var message: Dictionary = saved_data.get_or_add("message", {})
	
	message_for.text = message.get("for", "")
	message_method.text = message.get("method", "")
	message_args.text = message.get("args", "")
