# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name UIPanelSettingsShortcuts extends Control
## Settings for UI Panels


## Tree displaying panel buttons
@export var _button_tree: Tree

## List showing assigned shortcuts
@export var _shortcut_list: ItemList

## Button to add a new shortcut
@export var _new_shortcut_button: Button

## Button to delete selected shortcuts
@export var _delete_shortcut_button: Button


## Currently active UIPanel
var _panel: UIPanel

## Map of button name -> Button
var _buttons: RefMap = RefMap.new()

## Map of Button -> TreeItem
var _button_items: RefMap = RefMap.new()

## Currently selected button
var _selected_button: Button

## Whether we're listening for input
var _is_listning: bool = false

## Last input event received
var _previous_event: InputEvent


## Called when the node enters the scene tree
func _ready() -> void:
	_button_tree.columns = 2
	_button_tree.set_column_title(0, "Button")
	_button_tree.set_column_title(1, "Shortcuts")
	_button_tree.set_column_expand(1, false)

	_reset()
	set_process_input(false)


## Assigns the UIPanel to edit
func set_panel(panel: UIPanel) -> void:
	_reset()
	_panel = panel
	_load_buttons()


## Sets the input listening state
func _set_listning(listning: bool) -> void:
	set_process_input(listning)
	_is_listning = listning

	if listning:
		_new_shortcut_button.text = "Press a Button"
		_new_shortcut_button.set_pressed_no_signal(true)
	else:
		_new_shortcut_button.text = "New"
		_new_shortcut_button.set_pressed_no_signal(false)

		if _previous_event:
			if not _selected_button.shortcut:
				_selected_button.shortcut = Shortcut.new()

			_selected_button.shortcut.events.append(_previous_event)
			_shortcut_list.add_item(_previous_event.as_text())
			_button_items.left(_selected_button).set_text(1, str(len(_selected_button.shortcut.events)))

			_previous_event = null


## Handles user input when listening
func _input(event: InputEvent) -> void:
	if InputServer.is_event_allowed(event) and event.is_pressed():
		if event is InputEventKey:
			if event.keycode == KEY_ESCAPE:
				_previous_event = null
				_set_listning(false)
			if not InputServer.is_key_allowed(event.keycode):
				return

		_new_shortcut_button.text = event.as_text()
		_previous_event = event


## Loads and displays all buttons from the UIPanel
func _load_buttons() -> void:
	var sorted_buttons: Array[String] = []

	for button: Button in _panel.buttons:
		sorted_buttons.append(button.name)
		_buttons.map(button.name, button)

	sorted_buttons.sort()

	for name in sorted_buttons:
		var button: Button = _buttons.left(name)
		var item: TreeItem = _button_tree.create_item()
		item.set_text(0, name)
		item.set_text(1, str(len(button.shortcut.events)) if button.shortcut else "0")
		_button_items.map(button, item)


## Sets which button is currently selected
func _set_selected_button(button: Button) -> void:
	if button == _selected_button:
		return

	_shortcut_list.clear()
	_selected_button = button

	if button.shortcut:
		for event in button.shortcut.events:
			_shortcut_list.add_item(event.as_text())


## Resets the internal state and clears the UI
func _reset() -> void:
	_buttons.clear()
	_button_items.clear()
	_selected_button = null
	_set_listning(false)

	_button_tree.clear()
	_button_tree.create_item()

	_new_shortcut_button.disabled = true
	_delete_shortcut_button.disabled = true


## Called when a button is selected from the tree
func _on_button_list_item_selected() -> void:
	var item: TreeItem = _button_tree.get_selected()
	if item:
		var button_name := item.get_text(0)
		_set_selected_button(_buttons.left(button_name))

	_new_shortcut_button.disabled = false
	_delete_shortcut_button.disabled = true


## Called when New Shortcut is toggled
func _on_new_shortcut_toggled(toggled_on: bool) -> void:
	_set_listning(toggled_on)


## Called when Delete Shortcut is pressed
func _on_delete_shortcut_pressed() -> void:
	if not _selected_button or not _shortcut_list.is_anything_selected():
		return

	var selected_items := _shortcut_list.get_selected_items()
	selected_items.sort()
	selected_items.reverse()

	for id in selected_items:
		_selected_button.shortcut.events.remove_at(id)
		_shortcut_list.remove_item(id)
	
	_button_items.left(_selected_button).set_text(1, str(len(_selected_button.shortcut.events)))


## Called when items are multi-selected in the list
func _on_shortcut_list_multi_selected(index: int, selected: bool) -> void:
	_delete_shortcut_button.disabled = not _shortcut_list.is_anything_selected()
