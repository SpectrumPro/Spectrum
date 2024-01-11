extends Control

var current_universe_uuid
var current_io_uuid
var current_io_type

var input_options = [
	"Empty",
	
]
var output_options = [
	"Empty",
	"Art-Net"
]
var universes = Globals.universes

func _ready():
	Globals.subscribe("edit_mode", self.on_edit_mode_changed)

func delete_request(node):
	var confirmation_dialog = Globals.components.accept_dialog.instantiate()
	confirmation_dialog.dialog_text = "Are you sure you want to delete this? This action can not be undone"
	match node.get_meta("type"):
		"universe":
			confirmation_dialog.confirmed.connect((
			func(node):
				Globals.delete_universe(node.get_meta("universe_uuid"))
				
				current_universe_uuid = ""
				reload_universes()
				reload_io()
				
				set_universe_controls_enabled(false)
			).bind(node))
			add_child(confirmation_dialog)
		"output":
			confirmation_dialog.confirmed.connect((
			func(node):
				universes[current_universe_uuid].outputs.erase(node.get_meta("output_uuid"))
				current_io_uuid = ""
				current_io_type = ""
				reload_io()
				
			).bind(node))
			add_child(confirmation_dialog)

func edit_request(node):
	match node.get_meta("type"):
		"universe":
			current_universe_uuid = node.get_meta("universe_uuid")
			Globals.nodes.universe_name.text = universes[current_universe_uuid].name
			
			set_universe_controls_enabled(true)
			reload_io()
		"output":
			current_io_uuid = node.get_meta("output_uuid")
			current_io_type = "output"
			set_io_controls_enabled(true, universes[current_universe_uuid].outputs[current_io_uuid].type)
			reload_io()

func on_edit_mode_changed(edit_mode):
	for function_item in Globals.nodes.universe_list.get_children():
		function_item.dissable_buttons(not edit_mode)
		
	for function_item in Globals.nodes.channel_overrides_list.get_children():
		function_item.dissable_buttons(not edit_mode)

func new_universe():
	Globals.new_universe().set_name("Universe " + str(len(universes.keys())+1))
	#universes[Globals.new_uuid()] = {
		#"name":"Universe " + str(len(universes.keys())+1),
		#"fixtures:":{},
		#"inputs":{},
		#"outputs":{},
	#}
	reload_universes()

func reload_universes():
	
	for node in Globals.nodes.universe_list.get_children():
		node.queue_free()
	for uuid in universes:
		var universe = universes[uuid]
		var node_to_add = Globals.components.list_item.instantiate()
		node_to_add.set_item_name(universe.get_name())
		node_to_add.control_node = self
		node_to_add.set_meta("universe_uuid", uuid)
		node_to_add.set_meta("type", "universe")
		node_to_add.name = uuid
		node_to_add.set_highlighted(false)
		
		if current_universe_uuid == uuid:
			node_to_add.set_highlighted(true)
		
		Globals.nodes.universe_list.add_child(node_to_add)
	
	Globals.nodes.add_fixture_menu.reload_universes()
	Globals.nodes.desk.reload_universes()
	
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
	var output_uuid = Globals.new_uuid()
	
	universes[current_universe_uuid].outputs[output_uuid] = {
		"type":"Empty",
		"name":"Empty Output",
		"settings":{
			
		}
	}
	reload_io()

func reload_io():
	if not current_universe_uuid:return
	for node in Globals.nodes.universe_outputs.get_children():
		node.queue_free()
	for uuid in universes[current_universe_uuid].outputs:
		var output = universes[current_universe_uuid].outputs[uuid]
		var node_to_add = Globals.components.list_item.instantiate()
		node_to_add.set_item_name(output.name)
		node_to_add.control_node = self
		node_to_add.set_meta("output_uuid", uuid)
		node_to_add.set_meta("type", "output")
		node_to_add.name = uuid
		node_to_add.set_highlighted(false)
		
		if current_io_uuid == uuid:
			if output.type:
				Globals.nodes.universe_io_type.selected = output_options.find(output.type)
			node_to_add.set_highlighted(true)
			if output.type != "Empty":
				for node in Globals.nodes.universe_io_controls.get_children():
					if node.name == output.type:
						node.visible = true
					else:
						node.visible = false
			
		Globals.nodes.universe_outputs.add_child(node_to_add)

		
func set_universe_controls_enabled(enabled):
	for node in Globals.nodes.universe_controls.get_children():
		if node is LineEdit:
			node.editable = enabled
		elif node is BaseButton:
			node.disabled = not enabled
	
	if not enabled:
		Globals.nodes.universe_name.text = ""

func set_io_controls_enabled(enabled, type):
	if enabled and type != "Empty":
		Globals.nodes.universe_io_controls.get_node(type).visible = true
	else:
		for node in Globals.nodes.universe_io_controls.get_children():
			node.visible = false



# Button Callbacks

func _on_io_type_item_selected(index):
	if current_io_uuid:
		if current_io_type == "input":
			universes[current_universe_uuid].inputs[current_io_uuid].type = input_options[index]
			set_io_controls_enabled(true, input_options[index])
			
		elif current_io_type == "output":
			universes[current_universe_uuid].outputs[current_io_uuid].type = output_options[index]
			set_io_controls_enabled(true, output_options[index])
			match output_options[index]:
				"Art-Net":
					universes[current_universe_uuid].outputs[current_io_uuid].settings = {
						"ip":"172.0.0.1",
						"port":6454,
						"universe":0
					}
				"Empty":
					universes[current_universe_uuid].outputs[current_io_uuid].settings = {}
		reload_io()

func _on_art_net_port_text_submitted(new_text):
	universes[current_universe_uuid].outputs[current_io_uuid].settings.ip = new_text
	
func _on_art_net_port_value_changed(value):
	universes[current_universe_uuid].outputs[current_io_uuid].settings.port = value
	
func _on_art_net_universe_value_changed(value):
	universes[current_universe_uuid].outputs[current_io_uuid].settings.universe = value

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
	reload_universes()
