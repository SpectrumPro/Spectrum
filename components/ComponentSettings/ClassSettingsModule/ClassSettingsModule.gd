# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name ClassSettingsModule extends PanelContainer
## Class settings module


## Title label
@export var _title: Label

## ExpandHide button
@export var _expand_hide_button: Button

## SettingsContainer VBox
@export var _settings_container: VBoxContainer

## CustomContainer VBox
@export var _custom_container: VBoxContainer


## Contains all the lines of settings
var _lines: Dictionary = {}


## Disables this settings module
func set_disable(state: bool) -> void:
	_on_expand_hide_toggled(state)
	_expand_hide_button.disabled = state


## Sets the title
func set_title(title: String) -> void:
	_title.text = title


## Shows a custom panel
func show_custom(panel: Control) -> void:
	_custom_container.add_child(panel)


## Shows a setting
func show_setting(setter: Callable, getter: Callable, p_signal: Signal, p_type: String, p_line_number: int, p_name: String, p_min: Variant = null, p_max: Variant = null, p_enum: Dictionary = {}) -> void:
	if p_line_number == -1:
		p_line_number = 0
		
		while p_line_number in _lines:
			p_line_number += 1
		
		var new_line: HBoxContainer = HBoxContainer.new()
		_lines[p_line_number] = new_line
		_settings_container.add_child(new_line)
	
	elif not _lines.has(p_line_number):
		var new_line: HBoxContainer = HBoxContainer.new()
		_lines[p_line_number] = new_line
		
		_settings_container.add_child(new_line)
		_settings_container.move_child(new_line, p_line_number + 1)
	
	var line: HBoxContainer = _lines[p_line_number]
	var control: Control = null
	
	match p_type:
		Utils.TYPE_STRING, Utils.TYPE_IP:
			var line_edit: LineEdit = LineEdit.new()
			line_edit.text = getter.call()
			
			line_edit.text_submitted.connect(setter)
			p_signal.connect(line_edit.set_text)
			control = line_edit
			
		Utils.TYPE_BOOL:
			var check_button: CheckButton = CheckButton.new()
			check_button.set_pressed_no_signal(getter.call())
			check_button.text = "TRUE" if check_button.button_pressed else "FALSE"
			
			check_button.toggled.connect(setter)
			p_signal.connect((func (state: bool, button: CheckButton):
				button.set_pressed_no_signal(state)
				button.text = "TRUE" if state else "FALSE"
			).bind(check_button))
			control = check_button
		
		Utils.TYPE_INT:
			var spin_box: SpinBox = SpinBox.new()
			spin_box.min_value = p_min if p_min != null else -(1 << 32)
			spin_box.max_value = p_max if p_max != null else 1 << 32
			spin_box.set_value_no_signal(getter.call())
			
			spin_box.value_changed.connect(setter)
			p_signal.connect(spin_box.set_value_no_signal)
			control = spin_box
		
		Utils.TYPE_FLOAT:
			var spin_box: SpinBox = SpinBox.new()
			spin_box.min_value = p_min if p_min != null else -(1 << 32)
			spin_box.max_value = p_max if p_max != null else 1 << 32
			spin_box.step = 0.001
			spin_box.set_value_no_signal(getter.call())
			
			spin_box.value_changed.connect(setter)
			p_signal.connect(spin_box.set_value_no_signal)
			control = spin_box
		
		Utils.TYPE_ENUM:
			var option_button: OptionButton = OptionButton.new()
			
			for item_name: String in p_enum:
				option_button.add_item(item_name.capitalize())
			
			option_button.select(getter.call())
			option_button.item_selected.connect(setter)
			p_signal.connect(option_button.select)
			control = option_button
		
		Utils.TYPE_CID:
			var spin_box: SpinBox = SpinBox.new()
			spin_box.min_value = -1
			spin_box.max_value = INF
			spin_box.prefix = getter.get_object().self_class_name + ": "
			spin_box.select_all_on_focus = true
			spin_box.set_value_no_signal(getter.call())
			
			spin_box.value_changed.connect(setter)
			p_signal.connect(spin_box.set_value_no_signal)
			control = spin_box
		
		Utils.TYPE_NULL:
			if getter.is_null():
				var button: Button = Button.new()
				button.text = p_name
				
				button.pressed.connect(setter)
				control = button
	
	if not getter.is_null():
		var hbox: HBoxContainer = HBoxContainer.new()
		var label: Label = Label.new()
		
		label.text = p_name
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		hbox.add_child(label)
		hbox.add_child(control)
		line.add_child(hbox)
	
	else:
		control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.add_child(control)


## Called when the ExpandHide button is toggled
func _on_expand_hide_toggled(toggled_on: bool) -> void:
	_settings_container.visible = not toggled_on
	_expand_hide_button.icon = preload("res://assets/icons/UnfoldMore.svg") if toggled_on else preload("res://assets/icons/UnfoldLess.svg") 
