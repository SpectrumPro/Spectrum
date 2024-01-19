extends GraphNode

var channel_number = 1
var value = 0

var dmx_data = {
	"universe":1,
	"dmx_channels":{}
}

var queue = {}
var grid_container
var template_row
var row_index = 1

func _ready():
	grid_container = $VBoxContainer/ScrollContainer/GridContainer
	template_row = load("res://Nodes/DMX_table_row_template.tscn")
	add_row()
	
func node_process():
	if not queue.is_empty():
		get_parent().send(self, dmx_data, 0)
		queue = {}

func _set_dmx_data():
	dmx_data.dmx_channels = {}
	for i in grid_container.get_children():
		dmx_data.dmx_channels[int(i.get_node("Channel").value)] = int(i.get_node("Value").value)
	print(dmx_data)
	queue = dmx_data

func receive(_data, _slot):
	pass

func add_row():
	var new_row = template_row.instantiate()
	new_row.name = str(row_index)
	new_row.get_node("Channel").value = row_index
	new_row.get_node("Channel").value_changed.connect(_on_value_changed)
	new_row.get_node("Value").value_changed.connect(_on_value_changed)
	grid_container.add_child(new_row)
	row_index += 1
	_set_dmx_data()

func _on_value_changed(_value):
	_set_dmx_data()
	
func close_request():
	get_parent().delete(self)
	queue_free()

func _on_add_pressed():
	add_row()

func _on_resize_request(new_minsize):
	size = new_minsize

func _on_universe_value_changed(new_value):
	dmx_data.universe = int(new_value)
	_set_dmx_data()
