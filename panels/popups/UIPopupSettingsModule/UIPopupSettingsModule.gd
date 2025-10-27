# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name UIPopupSettingsModule extends UIPopup
## UIPopupSettingsModule Displays a SettingsModule


## The title button
@export var title: Button

## The Container to hold the DataInput
@export var module_container: Container


## The current DataInput node
var _current_data_input: DataInput


## Sets the SettingsModule to be shown
func set_module(p_module: SettingsModule) -> void:
	if _current_data_input:
		module_container.remove_child(_current_data_input)
		_current_data_input.queue_free()
	
	var new_data_input: DataInput = UIDB.instance_data_input(p_module.get_data_type())
	
	new_data_input.ready.connect(func ():
		new_data_input.set_module(p_module)
		new_data_input.set_label_text(p_module.get_name())
		new_data_input.set_show_label(true)
	)
	
	if p_module.is_editable():
		title.set_text(str("Edit: ", p_module.get_name()))
	else:
		title.set_text(str("View: ", p_module.get_name()))
	
	new_data_input.value_change_sucess.connect(accept)
	module_container.add_child(new_data_input)
	_current_data_input = new_data_input


## Focuses the input
func focus() -> void:
	if _current_data_input:
		_current_data_input.focus()
