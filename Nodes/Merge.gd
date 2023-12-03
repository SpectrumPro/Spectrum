extends GraphNode

var dmx_0 ={}
var dmx_1 ={}

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
	if typeof(data) != 27: 
		return
	if slot == 0:
		dmx_0 = data
	elif slot == 1:
		dmx_1 = data
	has_new_data = true

func node_process():
	if has_new_data and dmx_0 and dmx_1:
		has_new_data = false
		print(dmx_0)
		print(dmx_1)
		match operation:
			0:
				dmx_data.universe = dmx_0.universe
				dmx_data.dmx_channels = dmx_0.dmx_channels.duplicate()
				dmx_data.dmx_channels.merge(dmx_1.dmx_channels)
				print(dmx_0.universe)
			1:
				dmx_data.universe = dmx_1.universe
				dmx_data.dmx_channels = dmx_1.dmx_channels.duplicate()
				dmx_data.dmx_channels.merge(dmx_0.dmx_channels)
		get_parent().send(self, dmx_data, 0)
		
func close_request():
	get_parent().delete(self)
	queue_free()

func _on_Control_resize_request(new_minsize):
	size = new_minsize


func _on_option_button_item_selected(index):
	operation = index
	has_new_data = true
