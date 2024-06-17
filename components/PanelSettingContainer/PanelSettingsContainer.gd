# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends Window
## Ui Container to store settings from panels


## Emitted when the Change Type button is pressed
signal type_change_pressed

## Emitted when the Delete button is pressed
signal delete_pressed


## Sets the node in the settings panel
func set_node(node: Control) -> void:
	remove_node()
	
	node.name = "Settings"
	node.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	
	$PanelContainer/VBoxContainer.add_child(node)


## Removes the node in this container
func remove_node() -> void:
	if $PanelContainer/VBoxContainer.get_node_or_null("Settings"):
		$PanelContainer/VBoxContainer.remove_child($PanelContainer/VBoxContainer/Settings)


func _on_close_requested() -> void:
	remove_node()
	hide()
	get_tree().root.grab_focus()


func _on_change_type_pressed() -> void:
	type_change_pressed.emit()


func _on_delete_pressed() -> void:
	delete_pressed.emit()
