extends GraphNode

var dmx_0 = {0:0}
var dmx_1 = {0:0}

var has_new_data = false

var dmx_data = {
	"universe":1,
	"dmx_channels":{}
}
var operation = 0

func _ready():
	print(dmx_data)
	pass

func receive(data, slot):
	has_new_data = true
	if slot == 0:
		dmx_0 = data.dmx_channels
	elif slot == 1:
		dmx_1 = data.dmx_channels

func node_process():
	if has_new_data:
		has_new_data = false
		match operation:
			0:
				dmx_data.dmx_channels = dmx_0.duplicate()
				dmx_data.dmx_channels.merge(dmx_1)
			1:
				dmx_data.dmx_channels = dmx_1.duplicate()
				dmx_data.dmx_channels.merge(dmx_0)
		print(dmx_data)
		get_parent().send(self, dmx_data, 0)
func _on_Control_close_request():
	get_parent().delete(self)
	queue_free()

func _on_Control_resize_request(new_minsize):
	size = new_minsize


func _on_option_button_item_selected(index):
	operation = index
	has_new_data = true
