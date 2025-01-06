# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name CellItem extends PanelContainer
## Cell item for tables


## The data of this item, can be any data type.
var data: Variant = null : set = set_data

## The method to call when the data changes
var setter: Callable = Callable()

## The callback for the button
var button_callback: Callable = Callable()

## The callback for the dropdown
var dropdown_callback: Callable = Callable()

## All the items in the drop down
var dropdown_items: Array = []

## The signal that will change the data
var changer: Signal = Signal() : set = set_signal


func _ready() -> void:
	$HBox/FloatEdit.get_line_edit().flat = true
	$HBox/IntEdit.get_line_edit().flat = true


## Setter for data
func set_data(data: Variant) -> void:
	_hide_all()
	match typeof(data):
		TYPE_STRING:
			$HBox/StringEdit.show()
			$HBox/StringEdit.text = data
		
		TYPE_INT:
			$HBox/IntEdit.show()
			$HBox/IntEdit.set_value_no_signal(data)
		
		TYPE_FLOAT:
			$HBox/FloatEdit.show()
			$HBox/FloatEdit.set_value_no_signal(data)
		
		TYPE_BOOL:
			$HBox/BoolEdit.show()
			$HBox/BoolEdit.set_pressed_no_signal(data)
		
		TYPE_COLOR:
			$HBox/ColorEdit.show()
			$HBox/ColorEdit.set_pick_color(data)


## Shows a button instead of a data box
func set_button(text: String, callback: Callable) -> void:
	_hide_all()
	button_callback = callback
	
	$HBox/Button.text = text
	$HBox/Button.show()


## Shows a drop down options
func set_dropdown(items: Array, current: int, callback: Callable) -> void:
	_hide_all()
	
	$HBox/OptionButton.clear()
	dropdown_callback = callback
	dropdown_items = items
	
	for item in items:
		$HBox/OptionButton.add_item(str(item))
	
	$HBox/OptionButton.select(current)
	$HBox/OptionButton.show()


## Sets the signal
func set_signal(p_changer: Signal) -> void:
	if not changer.is_null(): changer.disconnect(_on_signal_emitted)
	changer = p_changer
	changer.connect(_on_signal_emitted)


## Called when the changer signal is emitted
func _on_signal_emitted(value: Variant) -> void:
	if $HBox/Button.visible:
		pass
	
	elif $HBox/OptionButton.visible and value is int and value <= len(dropdown_items) - 1:
		$HBox/OptionButton.select(value)
	
	else:
		match typeof(value):
			TYPE_STRING: 
				$HBox/StringEdit.text = value
			TYPE_INT: 
				$HBox/IntEdit.set_value_no_signal(value)
			TYPE_FLOAT: 
				$HBox/FloatEdit.set_value_no_signal(value)
			TYPE_BOOL: 
				$HBox/BoolEdit.set_pressed_no_signal(value)
		

## Hides all the edit nodes
func _hide_all() -> void:
	$HBox/BoolEdit.hide()
	$HBox/FloatEdit.hide()
	$HBox/IntEdit.hide()
	$HBox/StringEdit.hide()
	$HBox/ColorEdit.hide()
	
	$HBox/Button.hide()
	$HBox/OptionButton.hide()


## Callbacks for the inputs
func _on_string_edit_text_submitted(new_text: String) -> void: if setter.is_valid(): setter.call(new_text)
func _on_int_edit_value_changed(value: float) -> void: if setter.is_valid(): setter.call(value)
func _on_float_edit_value_changed(value: float) -> void: if setter.is_valid(): setter.call(value)
func _on_bool_edit_toggled(toggled_on: bool) -> void: if setter.is_valid(): setter.call(toggled_on)

## Button callback
func _on_button_pressed() -> void: if button_callback.is_valid(): button_callback.call()

## Dropdown callback
func _on_option_button_item_selected(index: int) -> void: if dropdown_callback.is_valid(): dropdown_callback.call(index)
