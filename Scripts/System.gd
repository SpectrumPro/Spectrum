extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# WIP
func _on_save_pressed():

	print(get_parent().get_node("TabContainer/Node Editor").connected_nodes)
	print(get_parent().get_node("TabContainer/Node Editor").get_children())


