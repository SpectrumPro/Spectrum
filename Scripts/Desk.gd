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
		Globals.nodes.desk_channel_container.add_child(node_to_add)

func reload_universes():
	Globals.nodes.desk_universe_option.clear()
	for universe in Globals.universes:
		Globals.nodes.desk_universe_option.add_item(Globals.universes[universe].name)
		
	Globals.nodes.desk_universe_option.select(0)
	
func slider_changed(value, channel):
	dmx_data[channel] = value
	current_universe.set_desk_data(dmx_data)
	#Globals.set_desk_data(universe, dmx_data)


func _on_desk_universe_option_item_selected(index):
	print()
	current_universe = Globals.universes[Globals.universes.keys()[index]]
