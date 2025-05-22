# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name TriggerButtonSettings extends PanelContainer
## Settings panel for the TriggerButton


## The ComponentMethodPicker used here
@onready var method_picker: ComponentMethodPicker = $ComponentMethodPicker

## The AddShortcutButton button
@export var _external_input_button: AddShortcutButton


## The trigger button used
var trigger_button: TriggerButton = null : set = set_trigger_button

## Mode
enum Mode {Down, Up, Feedback}
var mode: Mode = Mode.Down


func _ready() -> void:
	remove_child(method_picker)
	Interface.add_custom_popup(method_picker)
	method_picker.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_WIDTH)


func set_trigger_button(p_trigger_button: TriggerButton) -> void:
	trigger_button = p_trigger_button
	
	_update_button_down_name()
	_update_button_up_name()
	
	$VBoxContainer/PanelContainer/HBoxContainer/ItemName.text = trigger_button.get_label_text()
	$VBoxContainer/ScrollContainer/PanelContainer/VBoxContainer/ColorAndDisplay/VBoxContainer/BGColor/BGColorPicker.color = trigger_button.get_bg_color()
	$VBoxContainer/ScrollContainer/PanelContainer/VBoxContainer/ColorAndDisplay/VBoxContainer/Border/BorderColorPicker.color = trigger_button.get_border_color()
	$VBoxContainer/ScrollContainer/PanelContainer/VBoxContainer/ColorAndDisplay/VBoxContainer/HBoxContainer/BorderWidth.set_value_no_signal(trigger_button.get_border_width())
	
	_external_input_button.set_button(trigger_button)


## Updates the name on the button down button
func _update_button_down_name() -> void:
	var button_down_name: String = trigger_button.get_button_down().get_method_name() if trigger_button.get_button_down() else ""
	var button_down_component_uuid: String = trigger_button.get_button_down().get_uuid() if trigger_button.get_button_down() else ""
	
	if button_down_name == "": 
		button_down_name = "Choose"
	else:
		if button_down_component_uuid in ComponentDB.components: 
			button_down_name = ComponentDB.components[button_down_component_uuid].name + "." + button_down_name.capitalize()
		else: 
			button_down_name = "UnknownComponent." + button_down_name.capitalize()
	
	$VBoxContainer/ScrollContainer/PanelContainer/VBoxContainer/ButtonDown/VBoxContainer/ChooseButtonDownMethod.text = button_down_name


## Updates the name on the button up name
func _update_button_up_name() -> void:
	var button_up_name: String = trigger_button.get_button_up().get_method_name() if trigger_button.get_button_up() else ""
	var button_up_component_uuid: String = trigger_button.get_button_up().get_uuid() if trigger_button.get_button_up() else ""
	
	if button_up_name == "": 
		button_up_name = "Choose"
	else:
		if button_up_component_uuid in ComponentDB.components: 
			button_up_name = ComponentDB.components[button_up_component_uuid].name + "." + button_up_name.capitalize()
		else: 
			button_up_name = "UnknownComponent." + button_up_name.capitalize()
	
	$VBoxContainer/ScrollContainer/PanelContainer/VBoxContainer/ButtonUp/VBoxContainer/ChooseButtonUpMethod.text = button_up_name


func _on_item_name_text_changed(new_text: String) -> void:
	if trigger_button:
		trigger_button.set_label_text(new_text)


func _on_option_button_item_selected(index: int) -> void:
	if trigger_button:
		trigger_button.set_button_mode(index as TriggerButton.Mode)


func _on_choose_button_down_method_pressed() -> void:
	if trigger_button:
		mode = Mode.Down
		method_picker.set_method_config(trigger_button.get_button_down())
		method_picker.show()


func _on_choose_button_up_method_pressed() -> void:
	if trigger_button:
		mode = Mode.Up
		method_picker.set_method_config(trigger_button.get_button_up())
		method_picker.show()


func _on_choose_feedback_method_pressed() -> void:
	if trigger_button:
		mode = Mode.Feedback
		method_picker.show()


func _on_bg_color_picker_color_changed(color: Color) -> void: if trigger_button: trigger_button.set_bg_color(color)

func _on_border_color_picker_color_changed(color: Color) -> void: if trigger_button: trigger_button.set_border_color(color)

func _on_border_width_value_changed(value: float) -> void: if trigger_button: trigger_button.set_border_width(int(value))


func _on_component_method_picker_cancled() -> void: method_picker.hide()

## Called when the user clicks the remove binding button in the method picker
func _on_component_method_picker_remove_requested() -> void:
	method_picker.hide()
	match mode:
		Mode.Down: 
			trigger_button.remove_button_down()
			_update_button_down_name()
		Mode.Up:
			trigger_button.remove_button_up()
			_update_button_up_name()
		Mode.Feedback: 
			pass


## Called when the user picks a method 
func _on_component_method_picker_method_confired(method_trigger: MethodTrigger) -> void:
	method_picker.hide()
	match mode:
		Mode.Down:
			trigger_button.set_button_down(method_trigger)
			_update_button_down_name()
		Mode.Up:
			trigger_button.set_button_up(method_trigger)
			_update_button_up_name()
		Mode.Feedback:
			pass

## Called when a shortcut is added
func _on_add_shortcut_button_shortcut_changed(input_event: InputEvent) -> void:
	if trigger_button:
		trigger_button.add_shortcut(input_event)
