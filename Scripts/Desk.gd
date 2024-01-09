extends Control

var dmx_data = []
var universe = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	dmx_data.resize(512)
	dmx_data.fill(0)
	
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

func slider_changed(value, channel):
	dmx_data[channel-1] = value
	Globals.set_desk_data(universe, dmx_data)


func _on_desk_universe_option_item_selected(index):
	universe = index
