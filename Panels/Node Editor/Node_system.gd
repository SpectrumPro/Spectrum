extends GraphEdit

var initial_position = Vector2(40,40)
var node_index = 0
#@onready var connection_option_button = get_parent().get_node("Console/MarginContainer/VBoxContainer/connection/OptionButton")
#@onready var console_editor = get_parent().get_node("Console/Console Editor")
var built_in_nodes = {

}
var node_path = Globals.node_path

var connected_nodes = {}
var selected_nodes = []

var outbound_queue = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	_add_menu_hbox_button("Add Node", Globals.nodes.add_node_popup.add_node_button_clicked)
	_add_menu_hbox_button("Delete Node", self.request_delete)
	
	var access = DirAccess.open(node_path)
	for node_folder in access.get_directories():
		var manifest_file_path = node_path + node_folder + "/manifest.json"
		if access.file_exists(manifest_file_path):
			var manifest_file = FileAccess.open(manifest_file_path, FileAccess.READ)
			var manifest = JSON.parse_string(manifest_file.get_as_text())
			if manifest == null:
				Globals.show_popup([{"type":Globals.error.UNABLE_TO_LOAD_MANIFEST,"from":manifest_file_path}])
				return
			var verify_result = verify_manifest(manifest, manifest_file_path)
			if verify_result == []:
				Globals.nodes.add_node_popup.add_item(manifest.metadata.name)
				built_in_nodes[manifest.uuid] = node_path + node_folder + "/"
			else:
				Globals.show_popup(verify_result)
 
func _add_menu_hbox_button(text, method):
	var button = Button.new()
	button.text = text
	button.pressed.connect(method)
	self.get_menu_hbox().add_child(button)

func verify_manifest(manifest,from):
	var return_mgs = []

	if not manifest.has("manifest_version"):
		return_mgs.append({"type":Globals.error.MANIFEST_MISSING_MANIFEST_VERSION,"from":from})
	if not manifest.has("minimum_version"):
		return_mgs.append({"type":Globals.error.MANIFEST_MISSING_MINIMUM_VERSION,"from":from})
	if not manifest.has("version"):
		return_mgs.append({"type":Globals.error.MANIFEST_MISSING_VERSION,"from":from})
	if not manifest.has("node"):
		return_mgs.append({"type":Globals.error.MANIFEST_MISSING_NODES,"from":from})
	if not manifest.has("uuid"):
		return_mgs.append({"type":Globals.error.MANIFEST_MISSING_UUID,"from":from})
		
	if not manifest.get("metadata",false).get("name",false):
		return_mgs.append({"type":Globals.error.MANIFEST_MISSING_METADATA,"from":from})
	
	return return_mgs

func _process(_delta):
	if not outbound_queue.is_empty():
		for i in outbound_queue:
			if connected_nodes.has(i):
				for slot in connected_nodes[i]:
					get_node(NodePath(slot[1])).receive(outbound_queue[i][slot[0]], slot[2])
		outbound_queue = {}


func send(node, data, slot):
	if node.name in outbound_queue:
		outbound_queue[node.name][slot] = data
	else:
		outbound_queue[node.name] = {slot:data}


func GraphEdit_connection_request(from, from_slot, to, to_slot):
	self.connect_node(from, from_slot, to, to_slot)
	if from in connected_nodes:
		connected_nodes[from].append([from_slot, to, to_slot])
	else:
		connected_nodes[from] = [[from_slot, to, to_slot]]



func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	self.disconnect_node(from, from_slot, to, to_slot)
	connected_nodes[from].erase([from_slot, to, to_slot])
	
	if len(connected_nodes[from]) == 0:
		connected_nodes.erase(from)


func request_delete(node=null):
	if node == null:
		for i in selected_nodes:
			i.close_request()
			
		selected_nodes = []


func delete(node):
	connected_nodes.erase(node.name)

	for i in connected_nodes:
		for x in connected_nodes[i]:
			if node.name in x:
				connected_nodes[i].erase(x)
				
		if len(connected_nodes[i]) == 0:
			connected_nodes.erase(i)
		


func _add_node(node_file_path, overrides = {"name":"", "title":"", "position_offset":[]}):
	var manifest_file = FileAccess.open(node_file_path + "manifest.json", FileAccess.READ)
	var manifest = JSON.parse_string(manifest_file.get_as_text())
	if manifest == null:
		Globals.show_popup([{"type":Globals.error.MISSING_NODES,"from":node_file_path}])
		return
	
	
	if load(node_file_path + manifest.node.scene) == null:
		Globals.show_popup([{"type":Globals.error.UNABLE_TO_LOAD_SCENE,"from":node_file_path}])
		return false
	
	var node_to_add = load(node_file_path + manifest.node.scene).instantiate()
	
	if node_to_add.get_script() == null:
		var sciprt_to_add = load(node_file_path + manifest.node.script)
		if sciprt_to_add == null:
			Globals.show_popup([{"type":Globals.error.UNABLE_TO_LOAD_SCRIPT,"from":node_file_path}])
			return
		node_to_add.set_script(sciprt_to_add)
	
	node_to_add.position_offset = (get_viewport().get_mouse_position() + self.scroll_offset) / self.zoom
	node_to_add.name = node_to_add.name + str(node_index)
	node_to_add.title = node_to_add.title + " #" + str(node_index)
	node_to_add.set_meta("node_file_path", node_file_path)
	
	if overrides["position_offset"]:
		node_to_add.position_offset = Vector2i(overrides.position_offset[0],overrides.position_offset[1])
	
	if overrides.get("values"):
		for key in overrides.values.keys():
			node_to_add.get_node(manifest.values[key].node).set(manifest.values[key].content, overrides.values[key])
	
	var close_button = Globals.components.close_button.instantiate()
	close_button.pressed.connect(node_to_add.close_request)
	node_to_add.get_titlebar_hbox().add_child(close_button)
	
	self.add_child(node_to_add)
	node_index += 1
	
	_regenerate_option_button_list()

func _on_item_list_item_clicked(index, _at_position, _mouse_button_index):
	_add_node(built_in_nodes.values()[index])


func _on_node_selected(node):
	selected_nodes.append(node)


func _on_node_deselected(node):
	selected_nodes.erase(node)


func _regenerate_option_button_list():
	#connection_option_button.clear()
	#var opt_button_list = []
	#for i in self.get_children():
		#if i.get("has_external_input"):
			#opt_button_list.append(str(i.name))
			#connection_option_button.add_item(i.name)
	#console_editor.set_connection_button_list(opt_button_list)
	pass

func generate_connected_nodes(node_connections):
	for key in node_connections.keys():
		for i in node_connections[key]:
			GraphEdit_connection_request(key, i[0], i[1], i[2])
