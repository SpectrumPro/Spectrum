# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name System extends Object
## Engine class for the save load system

var save_file: Dictionary = {}

func save(engine: CoreEngine, file_name: String, file_path: String) -> Error:
	## Saves the current state of the given engine to a file
	
	save_file.universes = engine.serialize_universes()
	return Utils.save_json_to_file(file_path, file_name, save_file)

#extends Object
#
#var current_file = ""
#var home_directory = OS.get_environment("HOME")
#var save_folder_path = home_directory + "/Documents/Spectrum/"
#var file_name = ""
#var save_file = {
		#"nodes":{},
		#"node_connections":{},
		#"widgets":{}
	#}
#
#func _ready():
	#OS.set_low_processor_usage_mode(true)
#
#func _on_save_pressed():
	#save()
#
#func save():
	#save_nodes()
	#save_widgets()
	#save_file.universes = Globals.serialize_universes()
	#Globals.nodes.save_file_dialog.popup()
#
#
#func _on_save_file_dialog_file_selected(path):
	#var input_file_name = Globals.nodes.save_file_dialog.current_file
#
	#if not input_file_name:
		#input_file_name = "New Save"
	#file_name = input_file_name
#
	#save_json_to_file(path, save_file, file_name)
	#
#func save_json_to_file(folder_path, save_data, _file_name):
	#
	#var file_access = FileAccess.open(folder_path, FileAccess.WRITE)
	#
	#file_access.store_string(JSON.stringify(save_data, "\t"))
	#file_access.close()
#
#func _on_load_pressed():
	#get_node("Load File Dialog").popup()
	#
#func load_save(file_path):
	## Check if save file is valid
	#var manifest_file = FileAccess.open(file_path, FileAccess.READ)
	#if manifest_file == null:
		#Globals.show_popup([{"type":Globals.error.UNABLE_TO_LOAD_FILE,"from":file_path}])
		#return
	#var manifest = JSON.parse_string(manifest_file.get_as_text())
	#if manifest == null:
		#Globals.show_popup([{"type":Globals.error.UNABLE_TO_LOAD_MANIFEST,"from":file_path}])
		#return
		#
	## Add Nodes
	#for node_to_add in manifest.nodes.values():
		#var node_manifest_file = FileAccess.open(node_to_add.node_file_path + "manifest.json", FileAccess.READ)
		#if manifest == null:
			#Globals.show_popup([{"type":Globals.error.MISSING_NODES,"from":node_manifest_file}])
			#return
		#Globals.nodes.node_editor._add_node(node_to_add.node_file_path, {"position_offset":node_to_add.position_offset, "values":node_to_add.values})
	## Add node connections
	#Globals.nodes.node_editor.generate_connected_nodes(manifest.node_connections)
	#
	## Add Widgets
	#for widget_to_add in manifest.widgets.values():
		#var widget_manifest_file = FileAccess.open(widget_to_add.widget_file_path + "manifest.json", FileAccess.READ)
		#if manifest == null:
			#Globals.show_popup([{"type":Globals.error.MISSING_NODES,"from":widget_manifest_file}])
			#return
		#Globals.nodes.console_editor._add_widget(widget_to_add.widget_file_path, {"position_offset":widget_to_add.get("position_offset"), "values":widget_to_add.get("values"), "size":widget_to_add.get("size")})
	#
	##Add Universes
	#Globals.deserialize_universes(manifest.universes)
	#Globals.call_subscription("reload_universes")
	#Globals.call_subscription("reload_fixtures")
	#
#func _on_load_file_dialog_file_selected(path):
	#load_save(path)
