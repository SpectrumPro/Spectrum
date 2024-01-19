extends Control

var current_file = ""
var home_directory = OS.get_environment("HOME")
var save_folder_path = home_directory + "/Documents/Spectrum/"
var file_name = ""
var save_file = {
		"nodes":{},
		"node_connections":{},
		"widgets":{}
	}

func _ready():
	OS.set_low_processor_usage_mode(true)

func _on_save_pressed():
	save()

func save():
	save_nodes()
	save_widgets()
	save_file.universes = Globals.serialize_universes()
	Globals.nodes.save_file_dialog.popup()

func save_widgets():
	for widget_to_save in get_node("TabContainer/Console/Console Editor").get_children():
		var widget_file_path = widget_to_save.get_meta("widget_file_path")
		if not widget_file_path: continue
		var manifest_file = FileAccess.open(widget_file_path+"manifest.json", FileAccess.READ)
		if not manifest_file:
			Globals.show_popup([{"type":Globals.error.UNABLE_TO_LOAD_MANIFEST,"from":widget_file_path}])
			return
		var manifest = JSON.parse_string(manifest_file.get_as_text())
		save_file.widgets[widget_to_save.name] = {
			"widget_file_path":widget_file_path,
			"uuid":manifest.uuid,
			"name":widget_to_save.name,
			"position_offset":[widget_to_save.position_offset.x,widget_to_save.position_offset.y],
			"size":[widget_to_save.size.x,widget_to_save.size.y],
			"values":{
				
			}
		}

		for key in manifest.values.keys():
			if not widget_to_save.get_node(manifest.values[key].node):
				Globals.show_popup([{"type":Globals.error.NODE_SAVE_MANIFEST_ERROR,"from":widget_file_path}])
				return
			save_file.widgets[widget_to_save.name].values[key] = widget_to_save.get_node(manifest.values[key].node).get(manifest.values[key].content)
	save_file.node_connections = get_node("TabContainer/Node Editor").connected_nodes

func save_nodes():
	for node_to_save in get_node("TabContainer/Node Editor").get_children():
		var node_file_path = node_to_save.get_meta("node_file_path")
		if not node_file_path: continue
		var manifest_file = FileAccess.open(node_file_path+"manifest.json", FileAccess.READ)
		if not manifest_file:
			Globals.show_popup([{"type":Globals.error.UNABLE_TO_LOAD_MANIFEST,"from":node_file_path}])
			return
		var manifest = JSON.parse_string(manifest_file.get_as_text())
		save_file.nodes[node_to_save.name] = {
			"node_file_path":node_file_path,
			"uuid":manifest.uuid,
			"name":node_to_save.name,
			"position_offset":[node_to_save.position_offset.x,node_to_save.position_offset.y],
			"values":{
				
			}
		}
		for key in manifest.values.keys():

			if not node_to_save.get_node(manifest.values[key].node):
				Globals.show_popup([{"type":Globals.error.NODE_SAVE_MANIFEST_ERROR,"from":node_file_path}])
				return
			save_file.nodes[node_to_save.name].values[key] = node_to_save.get_node(manifest.values[key].node).get(manifest.values[key].content)
	save_file.node_connections = get_node("TabContainer/Node Editor").connected_nodes
	
func _on_save_file_dialog_file_selected(path):
	var input_file_name = Globals.nodes.save_file_dialog.current_file

	if not input_file_name:
		input_file_name = "New Save"
	file_name = input_file_name

	save_json_to_file(path, save_file, file_name)
	
func save_json_to_file(save_folder_path, save_file, file_name):
	
	var dir_access = DirAccess.open(home_directory)
	
	var save_file_path = save_folder_path
	
	var file_access = FileAccess.open(save_folder_path, FileAccess.WRITE)
	
	file_access.store_string(JSON.stringify(save_file, "\t"))
	file_access.close()

func _on_load_pressed():
	get_node("Load File Dialog").popup()
	
func load_save(file_path):
	# Check if save file is valid
	var manifest_file = FileAccess.open(file_path, FileAccess.READ)
	if manifest_file == null:
		Globals.show_popup([{"type":Globals.error.UNABLE_TO_LOAD_FILE,"from":file_path}])
		return
		
	var manifest = JSON.parse_string(manifest_file.get_as_text())
	if manifest == null:
		Globals.show_popup([{"type":Globals.error.UNABLE_TO_LOAD_MANIFEST,"from":file_path}])
		return
		
	# Add Nodes
	for node_to_add in manifest.nodes.values():
		var node_manifest_file = FileAccess.open(node_to_add.node_file_path + "manifest.json", FileAccess.READ)
		var node_manifest = JSON.parse_string(node_manifest_file.get_as_text())
		if manifest == null:
			Globals.show_popup([{"type":Globals.error.MISSING_NODES,"from":node_manifest_file}])
			return
		get_node("TabContainer/Node Editor")._add_node(node_to_add.node_file_path, {"position_offset":node_to_add.position_offset, "values":node_to_add.values})
	# Add node connections
	get_node("TabContainer/Node Editor").generate_connected_nodes(manifest.node_connections)
	
	# Add Widgets
	for widget_to_add in manifest.widgets.values():
		var widget_manifest_file = FileAccess.open(widget_to_add.widget_file_path + "manifest.json", FileAccess.READ)
		var widget_manifest = JSON.parse_string(widget_manifest_file.get_as_text())
		if manifest == null:
			Globals.show_popup([{"type":Globals.error.MISSING_NODES,"from":widget_manifest_file}])
			return
		get_node("TabContainer/Console/Console Editor")._add_widget(widget_to_add.widget_file_path, {"position_offset":widget_to_add.get("position_offset"), "values":widget_to_add.get("values"), "size":widget_to_add.get("size")})
	
	#Add Universes
	Globals.deserialize_universes(manifest.universes)
	Globals.nodes.patch_bay.reload_universes()
	
func _on_load_file_dialog_file_selected(path):
	load_save(path)

func _on_edit_mode_toggled(toggled_on):
	Globals.set_value("edit_mode", not toggled_on)
	if toggled_on:
		Globals.nodes.edit_mode_toggle.text = "Play Mode"
	else:
		Globals.nodes.edit_mode_toggle.text = "Edit Mode"
