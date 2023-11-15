extends GraphNode

var channel_number = 1
var value = 1

var dmx_data = {
	"universe":1,
	"dmx_channels":{}
}


func _on_Control_close_request():
	queue_free()

func _on_Control_resize_request(new_minsize):
	size = new_minsize

func receive(data, slot):
	print(self.title + "received: ")
	print(data)
	print(slot)

func _on_chanel_number_value_changed(new_value):
	channel_number = int(new_value)
	dmx_data.dmx_channels = {channel_number:value}
	get_parent().send(self, dmx_data, 0)


func _on_value_value_changed(new_value):
	value = int(new_value)
	dmx_data.dmx_channels = {channel_number:value}
	get_parent().send(self, dmx_data, 0)
