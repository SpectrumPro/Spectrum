extends Control

var dmx_data = {}
var universe = 1

var current_universe

# Called when the node enters the scene tree for the first time.
func _ready():
	
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
		Globals.nodes.desk_universe_option.add_item(Globals.universes[universe]._get_name())
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
	print(new_desk_data)
	for i in range(1, 513):
		Globals.nodes.desk_channel_container.get_node(str(i)).set_value(new_desk_data.get(i, 0))
	dmx_data = new_desk_data
	
func _on_desk_universe_option_item_selected(index):
	current_universe = Globals.universes[Globals.universes.keys()[index]]
	reload_values(current_universe)
