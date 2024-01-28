extends Control

var current_universe_uuid
var current_io_uuid
var current_io_type
var current_io

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
				universes[current_universe_uuid].remove_output(node.get_meta("output_uuid"))
				current_io_uuid = ""
				current_io_type = ""
				current_io = ""
				
				Globals.nodes.universe_io_type.disabled = true
				
				reload_io()
				
			).bind(node))
			add_child(confirmation_dialog)

func edit_request(node):
	match node.get_meta("type"):
		"universe":
			current_universe_uuid = node.get_meta("universe_uuid")
			Globals.nodes.universe_name.text = universes[current_universe_uuid].get_name()
			
			set_universe_controls_enabled(true)
			reload_io()
		"output":
			current_io_uuid = node.get_meta("output_uuid")
			current_io_type = "output"
			current_io = universes[current_universe_uuid].get_output(current_io_uuid)
			
			Globals.nodes.universe_io_type.disabled = false
			
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
		node_to_add.set_item_name(universe._get_name())
		node_to_add.control_node = self
		node_to_add.set_meta("universe_uuid", uuid)
		node_to_add.set_meta("type", "universe")
		node_to_add.name = uuid
		node_to_add.set_highlighted(false)
		
		if current_universe_uuid == uuid:
			node_to_add.set_highlighted(true)
		
		Globals.nodes.universe_list.add_child(node_to_add)
	
	Globals.call_subscription("reload_universes_callback")
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
	universes[current_universe_uuid].new_output("Empty")
	#var output_uuid = Globals.new_uuid()
	#
	#universes[current_universe_uuid].outputs[output_uuid] = {
		#"type":"Empty",
		#"name":"Empty Output",
		#"settings":{
			#
		#}
	#}
	reload_io()

func reload_io():
	if not current_universe_uuid:return
	
	for node in Globals.nodes.universe_outputs.get_children():
		node.queue_free()
	
	for node in Globals.nodes.universe_io_controls.get_children():
		node.queue_free()
	
	for uuid in universes[current_universe_uuid].get_all_outputs().keys():
		var output = universes[current_universe_uuid].get_output(uuid)
		var node_to_add = Globals.components.list_item.instantiate()
		node_to_add.set_item_name(output._get_name())
		node_to_add.control_node = self
		node_to_add.set_meta("output_uuid", uuid)
		node_to_add.set_meta("type", "output")
		node_to_add.name = uuid
		node_to_add.set_highlighted(false)
		
		if current_io_uuid == uuid:
			if output.get_type():
				Globals.nodes.universe_io_type.selected = output_options.find(output.get_type())
			
			for value in output.exposed_values:
				var value_node_to_add = value.type.new()
				value_node_to_add.get(value.signal).connect(output.get(value.function))
				
				for config in value.configs:
					if value.configs[config] is Callable:
						value_node_to_add.set(config, value.configs[config].call())
					else:
						value_node_to_add.set(config, value.configs[config])
				
				var container = HBoxContainer.new()
				var lable = Label.new()
				lable.text = value.name
				lable.set_h_size_flags(Control.SIZE_EXPAND_FILL)
				value_node_to_add.set_h_size_flags(Control.SIZE_EXPAND_FILL)
				container.set_h_size_flags(Control.SIZE_EXPAND_FILL)
				container.add_child(lable)
				container.add_child(value_node_to_add)
				Globals.nodes.universe_io_controls.add_child(container)
			#if output.get_type() != "Empty":
				#for node in Globals.nodes.universe_io_controls.get_children():
					#if node.name == output.get_type():
						#node.visible = true
					#else:
						#node.visible = false
			node_to_add.set_highlighted(true)
			
		Globals.nodes.universe_outputs.add_child(node_to_add)

func set_universe_controls_enabled(enabled):
	for node in Globals.nodes.universe_controls.get_children():
		if node is LineEdit:
			node.editable = enabled
		elif node is BaseButton:
			node.disabled = not enabled
	
	if not enabled:
		Globals.nodes.universe_name.text = ""

# Button Callbacks

func _on_io_type_item_selected(index):
	if current_io_uuid:
		if current_io_type == "input":
			universes[current_universe_uuid].inputs[current_io_uuid].type = input_options[index]
			
		elif current_io_type == "output":
			current_io = universes[current_universe_uuid].change_output_type(current_io_uuid, output_options[index])
		reload_io()

func _on_art_net_ip_text_submitted(new_text):
	current_io.art_net.ip = new_text
	current_io.connect_to_host()
	
func _on_art_net_port_value_changed(value):
	current_io.art_net.port = value
	current_io.connect_to_host()
	
func _on_art_net_universe_value_changed(value):
	current_io.art_net.universe = int(value)

func _on_new_universe_pressed():
	new_universe()

func _on_new_channel_overide_pressed():
	#new_channel_override()
	pass
	
func _on_new_input_pressed():
	#new_input()
	pass

func _on_new_output_pressed():
	new_output()

func _on_universe_name_text_changed(new_text):
	universes[current_universe_uuid]._set_name(new_text)
	reload_universes()
