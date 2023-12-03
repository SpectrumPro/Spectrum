extends GraphEdit

var initial_position = Vector2(40,40)
var node_index = 0
@onready var node_list = get_parent().get_parent().get_node("Node Editor List/NodeList")                                                                             
@onready var connection_option_button = get_parent().get_node("Console/MarginContainer/VBoxContainer/connection/OptionButton")
@onready var console_editor = get_parent().get_node("Console/Console Editor")
var built_in_nodes = {
	'DMX Value':"DMX_value",
	'Art-Net Output':"ART_NET_output",
	'Merge':"Merge",
	'Value':"Value",
	'DMX Table': "DMX_table",
	'Dimmer': "Dimmer"
}

var connected_nodes = {}
var selected_nodes = []

var outbound_queue = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	for node in built_in_nodes:
		node_list.add_item(node)
	var add_node_button = Button.new()
	add_node_button.text = "Add Node"
	add_node_button.pressed.connect(get_parent().get_parent().get_node("Node Editor List").add_node_button_clicked)
	self.get_menu_hbox().add_child(add_node_button)
	
	var delete_node_button = Button.new()
	delete_node_button.text = "Delete Node"
	delete_node_button.pressed.connect(self.request_delete)
	self.get_menu_hbox().add_child(delete_node_button)
 
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("process_loop"):
		print(connected_nodes)
	if not outbound_queue.is_empty():
		for i in outbound_queue:
			if connected_nodes.has(i):
				for slot in connected_nodes[i]:
					get_node(NodePath(slot[1])).receive(outbound_queue[i][slot[0]], slot[2])
		outbound_queue = {}
	for N in self.get_children():
			N.node_process()
		
func send(node, data, slot):
	if node.name in outbound_queue:
		outbound_queue[node.name][slot] = data
	else:
		outbound_queue[node.name] = {slot:data}

#	for node_to_send in connected_nodes:
#		get_node(NodePath(list[i]["to"])).receive(data, list[i]["to_port"])
			
#			print(self.get_parent().get_node("Node Editor").get_connection_list())
#	if connected_nodes.has(node):
#		get_node(NodePath(connected_nodes[node][slot])).receive(data, slot)

func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
	self.connect_node(from, from_slot, to, to_slot)
	if from in connected_nodes:
		connected_nodes[from].append([from_slot, to, to_slot])
	else:
		connected_nodes[from] = [[from_slot, to, to_slot]]
	print(connected_nodes)

func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	self.disconnect_node(from, from_slot, to, to_slot)
	connected_nodes[from].erase([from_slot, to, to_slot])
	if len(connected_nodes[from]) == 0:
		connected_nodes.erase(from)
	print(connected_nodes)
	
func request_delete(node=null):
	if node == null:
		for i in selected_nodes:
			i.close_request()
			print(i)
		selected_nodes = []
	
func delete(node):
	connected_nodes.erase(node.name)
	print(connected_nodes)
	for i in connected_nodes:
		print(i)
		for x in connected_nodes[i]:
			print(x)
			if node.name in x:
				print("found node to delete")
				print(x)
				connected_nodes[i].erase(x)
		if len(connected_nodes[i]) == 0:
			connected_nodes.erase(i)
	connection_option_button.clear()
	var opt_button_list = []
	for i in self.get_children():
		opt_button_list.append(str(i.name))
		connection_option_button.add_item(i.name)
	console_editor.set_connection_button_list(opt_button_list)	
	console_editor.remove_connection(node)

func _add_node(node):
	var node_to_add = load("res://Nodes/" + node + ".tscn").instantiate()
	
	node_to_add.position_offset = (get_viewport().get_mouse_position() + self.scroll_offset) / self.zoom
	node_to_add.name = node_to_add.name + str(node_index)
	node_to_add.title = node_to_add.title + " #" + str(node_index)
	var close_button = Globals.components.close_button.instantiate()
	close_button.pressed.connect(node_to_add.close_request)
	node_to_add.get_titlebar_hbox().add_child(close_button)
	self.add_child(node_to_add)
	node_index += 1
	
	connection_option_button.clear()
	var opt_button_list = []
	for i in self.get_children():
		if i.get_meta_list().has("external_input"):
			opt_button_list.append(str(i.name))
			connection_option_button.add_item(i.name)
	console_editor.set_connection_button_list(opt_button_list)
	
func _on_item_list_item_clicked(index, _at_position, _mouse_button_index):
	print("res://Nodes/" + built_in_nodes[node_list.get_item_text(index)] + ".tscn")
	_add_node(built_in_nodes[node_list.get_item_text(index)])

func _on_node_selected(node):
	selected_nodes.append(node)

func _on_node_deselected(node):
	selected_nodes.erase(node)
