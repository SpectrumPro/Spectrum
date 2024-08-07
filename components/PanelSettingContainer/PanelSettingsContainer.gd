# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends PanelContainer
## Ui Container to store settings from panels


## Sets the node in the settings panel
func set_node(node: Control) -> void:
	remove_node()
	
	node.name = "Settings"
	node.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	
	$VBoxContainer.add_child(node)


## Removes the node in this container
func remove_node() -> void:
	if $VBoxContainer.get_node_or_null("Settings"):
		$VBoxContainer.remove_child($VBoxContainer/Settings)


func _on_close_pressed() -> void:
	remove_node()
	hide()
