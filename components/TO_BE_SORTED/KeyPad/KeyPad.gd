# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name KeyPadComponent extends PanelContainer
## A kaypad that will call a function once the correct code is entred


## Emitted when the correct code is entred
signal code_accepted()

## Emitted when a code is entred incorrectly
signal code_rejected()

## Emitted when a code is entred
signal code_entred(code: Array[int])

## Emitted when the close button is pressed
signal closed_requested


## The correct passcode, stored as an array if intergers
var passcode: Array[int] = [0, 0, 0, 0] : set = set_passcode

## The current code being entred
var current_code: Array[int] = []


@onready var _chips_panel: PanelContainer = $VBoxContainer2/ChipsPanel


func _ready() -> void:
	_reload_chips()


func set_passcode(p_passcode: Array[int]) -> void:
	if p_passcode == passcode:
		return
	
	passcode = p_passcode
	_reload_chips()


func set_label_text(label_text: String) -> void:
	$VBoxContainer2/Label.text = label_text


func _reload_chips() -> void:
	var old_h_box: HBoxContainer = _chips_panel.get_node_or_null("HBox")
	
	if old_h_box:
		_chips_panel.remove_child(old_h_box)
		old_h_box.queue_free()
	
	var new_h_box: HBoxContainer = HBoxContainer.new()
	new_h_box.name = "HBox"
	
	for i in range(0, len(passcode)):
		var new_panel: PanelContainer = PanelContainer.new()
		
		new_panel.name = str(i)
		new_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER + Control.SIZE_EXPAND
		
		new_panel.add_theme_stylebox_override("panel", _chips_panel.get_theme_stylebox("panel").duplicate(true))
		
		new_h_box.add_child(new_panel)
	
	_chips_panel.add_child(new_h_box)


func _on_button_pressed(number: int) -> void:
	current_code.append(number)
	
	if len(current_code) == len(passcode):
		code_entred.emit(current_code)
	
	if current_code == passcode:
		code_accepted.emit()
		current_code = []
	
	elif len(current_code) == len(passcode):
		code_rejected.emit()
		current_code = []

	_update_chips()
	


func _update_chips() -> void:
	for i in range(0, len(passcode)):
		var chip: PanelContainer = _chips_panel.get_node("HBox").get_node_or_null(str(i))
		
		if chip:
			var style_box: StyleBoxFlat = chip.get_theme_stylebox("panel")
			style_box.bg_color = Color.WHITE if i in range(0, len(current_code)) else Color.from_string("10101031", Color.GRAY)
			chip.add_theme_stylebox_override("panel", style_box)


func _on_backspace_pressed() -> void:
	current_code.pop_back()
	_update_chips()


func _on_close_pressed() -> void:
	current_code = []
	_update_chips()
	
	closed_requested.emit()
