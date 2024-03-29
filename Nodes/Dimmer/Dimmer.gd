extends GraphNode

var queue = {}
var dmx_data = {
	"universe":1,
	"dmx_channels":{}
}
var most_recent_data = {}

var dimmer_amount = 0
var operation = 0

func _ready():
	pass

func node_process():
	if not queue.is_empty():
		get_parent().send(self, queue, 0)
		queue = {}

func _process_data():
	dmx_data.dmx_channels = {}
	if operation == 0:
		for i in most_recent_data:
			dmx_data.dmx_channels[i] = clamp(most_recent_data[i] + dimmer_amount, 0, 255)
	elif operation == 1:
		for i in most_recent_data:
			dmx_data.dmx_channels[i] = clamp(most_recent_data[i], 0, dimmer_amount)
	queue = dmx_data

func close_request():
	get_parent().delete(self)
	queue_free()

func receive(data, slot):
	if slot == 0:
		if typeof(data) != 27: 
			return
		most_recent_data = data.dmx_channels
		dmx_data.universe = data.universe
	elif slot == 1:
		if typeof(data) != 2: 
			return
		dimmer_amount = data
		$Row2/Amount.value = data
	_process_data()

func _on_value_value_changed(value):
	dimmer_amount = value
	_process_data()
	

func _on_option_item_selected(index):
	operation = index
	if operation == 0:
		$Row2/Amount.min_value = -255
	elif operation == 1:
		$Row2/Amount.min_value = 0
	_process_data()
