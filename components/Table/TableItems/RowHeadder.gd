# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name RowHeadder extends PanelContainer
## Headder item for table rows


## Emitted when this row item is clicked
signal clicked()


## The text of this RowHeadder
var text: String = "" : set = set_text, get = get_text

## The index of this row
var index: int = -1

## The row item
var row_item: RowItem = null


## Name setter callable
var _name_setter: Callable = Callable()

## Name signal
var _name_signal: Signal = Signal()


## Setter for the text
func set_text(text: String) -> void: 
	$HBoxContainer/Label.text = text
	$HBoxContainer/NameButton.text = text


## Getter for the text
func get_text() -> String: 
	return $HBoxContainer/Label.text


## Sets the setter method and signal for the name
func set_name_method(setter: Callable, changer: Signal) -> void:
	if not _name_signal.is_null(): _name_signal.disconnect(_on_name_changed)
	
	_name_setter = setter
	_name_signal = changer
	_name_signal.connect(_on_name_changed)
	
	$HBoxContainer/Label.editable = true


## Shows or hides the handle
func show_handle(state: bool) -> void:
	$HBoxContainer/Handle.visible = state


## Shows or hides the selected border, also changes the selection state on the row item
func set_selected(selected: bool) -> void:
	$Selection.visible = selected
	if row_item:
		row_item.set_selected(selected)


## Called when the name changed signal is emitted
func _on_name_changed(new_name: String) -> void: 
	set_text(new_name)


## Called when the name LineEdit is changed
func _on_label_text_submitted(new_text: String) -> void: 
	if _name_setter.is_valid(): 
		_name_setter.call(new_text)
		$HBoxContainer/Label.hide()
		$HBoxContainer/NameButton.show()
		$HBoxContainer/NameButton.text = new_text


func _on_name_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.is_double_click():
			$HBoxContainer/NameButton.hide()
			$HBoxContainer/Label.show()
			$HBoxContainer/Label.grab_focus()
			$HBoxContainer/Label.select_all()
		else:
			clicked.emit()


func _on_label_focus_exited() -> void:
	$HBoxContainer/Label.hide()
	$HBoxContainer/NameButton.show()
