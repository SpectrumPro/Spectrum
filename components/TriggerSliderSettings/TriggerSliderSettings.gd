# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name TriggerSliderSettings extends PanelContainer
## Settings panel for the TriggerSAlider


## The ComponentMethodPicker used here
@onready var method_picker: ComponentMethodPicker = $ComponentMethodPicker


func _ready() -> void:
	remove_child(method_picker)
	Interface.add_custom_popup(method_picker)
	method_picker.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_WIDTH)
