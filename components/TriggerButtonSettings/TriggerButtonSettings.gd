# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name TriggerButtonSettings extends PanelContainer
## Settings panel for the TriggerButton


## The ComponentMethodPicker used here
@onready var method_picker: ComponentMethodPicker = $ComponentMethodPicker


func _ready() -> void:
	remove_child(method_picker)
	Interface.add_root_child(method_picker)
	method_picker.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_WIDTH)


func _on_choose_button_down_method_pressed() -> void:
	method_picker.show()


func _on_choose_button_up_method_pressed() -> void:
	method_picker.show()


func _on_choose_feedback_method_pressed() -> void:
	method_picker.show()


func _on_component_method_picker_cancled() -> void:
	method_picker.hide()
