
extends Node

var connection
var value = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func close_request():
	queue_free()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func external_input(new_value):
	value = remap(new_value, 0, 127, $VSlider.min_value, $VSlider.max_value)
	$VSlider.value = value

func set_connection(node):
	print(node)
	connection = node

func get_connection():
	return connection

func _on_value_slider_changed(value):
	if connection:
		connection.external_input(value)


func _on_resize_request(new_minsize):
	self.size = Vector2i(new_minsize)
	print(self.size)
