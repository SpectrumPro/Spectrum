extends Control

var current_file = ""
var home_directory = OS.get_environment("HOME")
var save_folder_path = home_directory + "/Documents/Spectrum/"
var file_name = ""
var save_file = {
		"nodes":{},
		"node_connections":{}
	}
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_save_pressed():
	save()

func save():
	
	for node_to_save in get_node("TabContainer/Node Editor").get_children():
		var manifest_file_path = node_to_save.get_meta("manifest_file_path") + "manifest.json"
		var manifest_file = FileAccess.open(manifest_file_path, FileAccess.READ)
		if not manifest_file:
			Globals.show_popup([{"type":Globals.error.UNABLE_TO_LOAD_MANIFEST,"from":manifest_file_path}])
			return
		var manifest = JSON.parse_string(manifest_file.get_as_text())
		save_file.nodes[node_to_save.name] = {
			"manifest_file_path":manifest_file_path,
			"uuid":manifest.uuid,
			"name":node_to_save.name,
			"values":{
				
			}
		}
		for key in manifest.values.keys():
			print(node_to_save)
			print(manifest.values[key])
			if not node_to_save.get_node(manifest.values[key].node):
				Globals.show_popup([{"type":Globals.error.NODE_SAVE_MANIFEST_ERROR,"from":manifest_file_path}])
				return
			save_file.nodes[node_to_save.name].values[key] = node_to_save.get_node(manifest.values[key].node).get(manifest.values[key].content)
	save_file.node_connections = get_node("TabContainer/Node Editor").connected_nodes
	# Get the user's home directory
	Globals.file_name_dialog.popup()
	
	#print(save_file)
	
func _on_file_name_dialog_confirmed():
	var input_file_name = get_node("File Name Dialog/HBoxContainer/LineEdit").text
	if not input_file_name:
		input_file_name = "New Save"
	file_name = input_file_name
	save_json_to_file(save_folder_path, save_file, file_name)
	
func save_json_to_file(save_folder_path, save_file, file_name):
	
	var dir_access = DirAccess.open(home_directory)
	
	if not dir_access.dir_exists(save_folder_path):
		dir_access.make_dir(save_folder_path)
		
	var save_file_path = save_folder_path + file_name + ".spshow"
	print(save_file_path)
	var file_access = FileAccess.open(save_file_path, FileAccess.WRITE)
	
	file_access.store_string(JSON.stringify(save_file, "\t"))
	file_access.close()
