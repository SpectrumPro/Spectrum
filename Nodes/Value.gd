extends GraphNode

var queue = {0:0}

func _ready():
	pass

func node_process():
	if not queue.is_empty():
		get_parent().send(self, queue[0], 0)
		queue = {}

func external_input(value):
	queue[0] = value
	$HBoxContainer/Value.set_value_no_signal(value)

func close_request():
	get_parent().delete(self)
	queue_free()

func _on_value_value_changed(value):
	queue[0] = value

