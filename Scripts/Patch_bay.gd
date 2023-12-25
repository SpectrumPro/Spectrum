extends Control

var universe_edit_mode = false
var current_universe_uuid
var universes = Globals.universes

func _ready():
	Globals.subscribe("edit_mode", self.on_edit_mode_changed)

func delete_request(node):
	var confirmation_dialog = Globals.components.accept_dialog.instantiate()
	confirmation_dialog.dialog_text = "Are you sure you want to delete this? This action can not be undone"
	confirmation_dialog.confirmed.connect((
		func(node):
			universes.erase(node.get_meta("universe_uuid"))
			node.queue_free()
			
			set_controls_enabled(false)
			current_universe_uuid = ""
	).bind(node))
	add_child(confirmation_dialog)
	
	
func edit_request(node):
	universe_edit_mode = true
	current_universe_uuid = node.get_meta("universe_uuid")
	Globals.nodes.universe_name.text = universes[current_universe_uuid].name
	
	set_controls_enabled(true)

func on_edit_mode_changed(edit_mode):
	for function_item in Globals.nodes.universe_list.get_children():
		function_item.dissable_buttons(not edit_mode)
		
	for function_item in Globals.nodes.channel_overrides_list.get_children():
		function_item.dissable_buttons(not edit_mode)
		
func new_universe():
	var universe_uuid = Globals.new_uuid()
	var node_to_add = Globals.components.list_item.instantiate()
	node_to_add.set_item_name("Universe " + str(len(universes.keys())+1))
	node_to_add.control_node = self
	node_to_add.set_meta("universe_uuid", universe_uuid)
	node_to_add.name = universe_uuid
	Globals.nodes.universe_list.add_child(node_to_add)
	
	universes[universe_uuid] = {
		"name":"Universe " + str(len(universes.keys())+1),
		"fixtures:":{},
		"inputs":{},
		"outputs":{},
	}
	
func new_channel_override():
	var node_to_add = Globals.components.list_item.instantiate()
	node_to_add.set_item_name("Channel Override")
	node_to_add.control_node = self
	Globals.nodes.channel_overrides_list.add_child(node_to_add)
	
func new_input():
	var node_to_add = Globals.components.list_item.instantiate()
	node_to_add.set_item_name("Empty Input")
	node_to_add.control_node = self
	Globals.nodes.universe_inputs.add_child(node_to_add)

func new_output():
	var node_to_add = Globals.components.list_item.instantiate()
	node_to_add.set_item_name("Empty Output")
	node_to_add.control_node = self
	Globals.nodes.universe_outputs.add_child(node_to_add)
	universes[current_universe_uuid].outputs[Globals.new_uuid()] = {
		"type":"Empty",
		"name":"Empty Output",
		"settings":{
			
		}
	}
	

func _on_new_universe_pressed():
	new_universe()

func _on_new_channel_overide_pressed():
	new_channel_override()

func _on_new_input_pressed():
	new_input()

func _on_new_output_pressed():
	new_output()

func _on_universe_name_text_changed(new_text):
	universes[current_universe_uuid].name = new_text
	print(Globals.nodes.universe_list.get_children())
	Globals.nodes.universe_list.get_node(current_universe_uuid).set_item_name(new_text)

func set_controls_enabled(enabled):
	for node in Globals.nodes.universe_controls.get_children():
		if node is LineEdit:
			node.editable = enabled
		elif node is BaseButton:
			node.disabled = not enabled
	
	if not enabled:
		Globals.nodes.universe_name.text = ""
