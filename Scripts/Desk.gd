extends Control

var dmx_data = {}
var universe = 1

var current_universe

var current_command = {}
var control_mode = "channels"

var active_fixtures = []

var command_tree = {
	"SET":{
		"_":self.command_set
	},
	"_":self.set_error
}

# Called when the node enters the scene tree for the first time.
func _ready():
	load_dmx_faders()
	Globals.subscribe("reload_universes", self.reload_universes)
	Globals.subscribe("active_fixtures", self.active_fixtures_changed)

func load_dmx_faders():
	for i in range(1, 513):
		var node_to_add = Globals.components.channel_slider.instantiate()
		node_to_add.set_channel_name("#" + str(i))
		node_to_add.callback = self.slider_changed
		node_to_add.id = i
		node_to_add.name = str(i)
		Globals.nodes.desk_channel_container.add_child(node_to_add)

func reload_universes():
	Globals.nodes.desk_universe_option.clear()
	for universe in Globals.universes:
		Globals.nodes.desk_universe_option.add_item(Globals.universes[universe].get_universe_name())
	if len(Globals.universes) == 0:
		current_universe = null
	Globals.nodes.desk_universe_option.item_selected.emit(0)
	
func slider_changed(value, channel):
	if current_universe:
		if value == 0:
			dmx_data.erase(channel)
		else:
			dmx_data[channel] = value
		current_universe.set_desk_data(dmx_data)

func reload_values(universe):
	var new_desk_data = universe.get_desk_data()
	for i in range(1, 513):
		Globals.nodes.desk_channel_container.get_node(str(i)).set_value(new_desk_data.get(i, 0))
	dmx_data = new_desk_data
	
func _on_desk_universe_option_item_selected(index):
	if len(Globals.universes) == 0:return
	current_universe = Globals.universes[Globals.universes.keys()[index]]
	reload_values(current_universe)

func active_fixtures_changed(fixtures):
	active_fixtures = fixtures


 # ------------------ Control Panel Function --------------------


func update_command_input():
	var output = ""
	for i in current_command.values():
		output += str(i) + " "
	
	Globals.nodes.command_input.text = output

func on_keypad_button_pressed(number):
	var index = len(current_command)
	if index == 0:
		current_command[index] = "SET"
		current_command[index+1] = number
	elif typeof(current_command[index-1]) == TYPE_INT:
		current_command[index-1] = int(str(current_command[index-1]) + str(number))
	else:
		current_command[index] = number
	update_command_input()

func _on_0_pressed(): on_keypad_button_pressed(0)
func _on_1_pressed(): on_keypad_button_pressed(1)
func _on_2_pressed(): on_keypad_button_pressed(2)
func _on_3_pressed(): on_keypad_button_pressed(3)
func _on_4_pressed(): on_keypad_button_pressed(4)
func _on_5_pressed(): on_keypad_button_pressed(5)
func _on_6_pressed(): on_keypad_button_pressed(6)
func _on_7_pressed(): on_keypad_button_pressed(7)
func _on_8_pressed(): on_keypad_button_pressed(8)
func _on_9_pressed(): on_keypad_button_pressed(9)


func _on_execute_pressed():
	if not current_command:return
	var command_tree_branch = command_tree
	var index = 0
	
	for command in current_command.values():
		if command in command_tree_branch:
			command_tree_branch = command_tree_branch[command]
		else:
			var args = current_command.values()
			for i in range(index):
				args.remove_at(0)
				
			command_tree_branch["_"].call(args)
			
			current_command = {}
			update_command_input()
			
			return
		index +=1
		
func _on_decimal_pressed():
	pass # Replace with function body.


func on_action_pressed(type):
	current_command[len(current_command)] = type
	update_command_input()

func _on_at_pressed(): on_action_pressed("AT")
func _on_full_pressed():on_action_pressed("FULL")
func _on_zero_pressed(): on_action_pressed("ZERO")
func _on_thru_pressed(): on_action_pressed("THRU")
func _on_by_pressed(): on_action_pressed("BY")

func _on_delete_pressed():
	current_command.erase(len(current_command) - 1)
	update_command_input()


func _on_color_picker_color_changed(color):
	for fixture in active_fixtures:
		fixture.set_color_rgb(color.r,color.g,color.b)


#----------------------- Command Functions --------------------------


func command_set(args):
	if len(args) < 3:return
	var channels = []
	var value = 0
	var step = 1
	
	var index = 0
	
	if current_universe:
		
		if args[1] == "THRU":
			channels = range(args[0], args[2]+1)
			value = args[4]
			if args[3] == "BY":
				step = args[4]
				value = args[6]
		else:
			channels = [args[0]]
			value = args[2]
		
		value = int(str(value).replace("FULL", "255").replace("ZERO", "0"))
		
		for channel in channels:
			if index % step == 0:
				dmx_data[channel] = value
			index +=1
		current_universe.set_desk_data(dmx_data)
		reload_values(current_universe)

func set_error(args):
	Globals.nodes.command_input.text = "ERROR IN LAST COMMAND"


