extends GraphNode

var channel_number = 1
var value = 0

var dmx_data = {
	"universe":2,
	"dmx_channels":{}
}

var queue = {}
func node_process():
	if not queue.is_empty():
		get_parent().send(self, dmx_data, 0)
		queue = {}
		
func set_dmx_data():
	dmx_data.dmx_channels = {channel_number:value}
	queue[0] = dmx_data
	
func receive(data, slot):
	if slot == 0:
		channel_number = int(data)
		get_node("HBoxContainer/ChanelNumber").set_value_no_signal(data)
	if slot == 1:
		value = int(data)
		get_node("HBoxContainer3/Value").set_value_no_signal(data)
	set_dmx_data()

func _on_chanel_number_value_changed(new_value):
	channel_number = int(new_value)
	set_dmx_data()

func _on_value_value_changed(new_value):
	value = int(new_value)
	set_dmx_data()

func _on_Control_close_request():
	get_parent().delete(self)
	queue_free()
