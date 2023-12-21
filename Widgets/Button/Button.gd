extends Node

func _ready():
	Globals.subscribe("edit_mode", self.toggle_edit_mode)

func close_request():
	queue_free()

func _on_resized():
	var new_minsize = self.size
	var snap_size = Globals.values.snapping_distance
	self.size = Vector2(round(new_minsize.x / snap_size) * snap_size, round(new_minsize.y / snap_size) * snap_size)

func toggle_edit_mode(edit_mode):
	
	print(edit_mode)
	if edit_mode:
		get_node("Button").disabled = true
		get_node("Button").mouse_filter = 1
	else:
		get_node("Button").disabled = false
		get_node("Button").mouse_filter = 0
