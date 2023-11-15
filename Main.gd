extends Control

var initial_position = Vector2(40,40)
var node_index = 0
@onready var nodeList = $Control/NodeList                                                                                 
var built_in_nodes = {
	'DMX Value':"DMX_value",
	'Art-Net Output':"ART_NET_output",
}
var connected_nodes = {}
# Called when the node enters the scene tree for the first time.

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func send(node, data, slot):
	print(data)
	get_node(NodePath(connected_nodes[node][slot])).receive(data, slot)

func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
	self.get_parent().get_node("Node Editor").connect_node(from, from_slot, to, to_slot)
	print(from)
	connected_nodes[get_node(str(from))] = {from_slot:to}

func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	self.get_parent().get_node("Node Editor").disconnect_node(from, from_slot, to, to_slot)
	print(from)
	connected_nodes[get_node(str(from))].erase(from_slot)

func _on_RunProgram_pressed():
	var G = self
	var connection_list = G.get_connection_list()
	print(G.get_connection_list())
	var result = 0
	for i in range(0, connection_list.size()):
		var value = G.get_node(NodePath(connection_list[i].from)).get_node('SpinBox').value
		var value_2 = G.get_node(NodePath(connection_list[i].to)).get_node('SpinBox').value
		result += value
		if i+1 == connection_list.size():
			result += value_2
	print(result)


func _on_item_list_item_clicked(index, _at_position, _mouse_button_index):
	print("res://Nodes/" + built_in_nodes[nodeList.get_item_text(index)] + ".tscn")
	var node_to_add = load("res://Nodes/" + built_in_nodes[nodeList.get_item_text(index)] + ".tscn").instantiate()
	node_to_add.position_offset += initial_position + (node_index * Vector2(20,20))
	set_editable_instance(node_to_add, true)
	node_to_add.name = node_to_add.name + str(node_index)
	self.add_child(node_to_add)
	node_index += 1
