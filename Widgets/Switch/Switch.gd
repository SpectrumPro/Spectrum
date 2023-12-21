
extends Node

var connection
var value = 0

func close_request():
	queue_free()

func _on_resized():
	var new_minsize = self.size
	var snap_size = Globals.values.snapping_distance
	self.size = Vector2(round(new_minsize.x / snap_size) * snap_size, round(new_minsize.y / snap_size) * snap_size)

func _on_switch_toggled(toggled_on):
	if toggled_on:
		get_node("Toggle Button/Container/False").visible = false
		get_node("Toggle Button/Container/True").visible = true
	else:
		get_node("Toggle Button/Container/False").visible = true
		get_node("Toggle Button/Container/True").visible = false

