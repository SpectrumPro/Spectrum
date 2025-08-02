# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name SettingsContainer extends PanelContainer
## Ui Container to store settings


## Emitted when the close button is pressed
signal closed_pressed()


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
