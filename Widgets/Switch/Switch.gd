extends Node

var connection
var value = 0

func _ready():
	self.resized.connect(_on_resized)
	$Switch.toggled.connect(_on_switch_toggled)
	Globals.subscribe("edit_mode", self.toggle_edit_mode)
func close_request():
	queue_free()

func _on_resized():
	var new_minsize = self.size
	var snap_size = Globals.values.snapping_distance
	self.size = Vector2(round(new_minsize.x / snap_size) * snap_size, round(new_minsize.y / snap_size) * snap_size)

func _on_switch_toggled(toggled_on):
	if toggled_on:
		get_node("Switch/Container/False").visible = false
		get_node("Switch/Container/True").visible = true
	else:
		get_node("Switch/Container/False").visible = true
		get_node("Switch/Container/True").visible = false

func toggle_edit_mode(edit_mode):
	if edit_mode:
		get_node("Switch").disabled = true
		get_node("Switch").mouse_filter = 1
	else:
		get_node("Switch").disabled = false
		get_node("Switch").mouse_filter = 0
