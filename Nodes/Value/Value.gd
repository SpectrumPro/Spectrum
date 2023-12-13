extends GraphNode

@export var has_external_input = true

var queue = {0:0}

func _ready():
	pass

func send():
	if not queue.is_empty():
		get_parent().send(self, queue[0], 0)
		queue = {}

func external_input(value):
	get_node("Row0/Value").value = value
	send()

func close_request():
	get_parent().delete(self)
	queue_free()

func _on_value_value_changed(value):
	queue[0] = value
	send()
