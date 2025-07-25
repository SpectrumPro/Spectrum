# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name UIPanelSettingsShortcuts extends Control
## Settings for UI Panels


## Tree displaying panel buttons
@export var _button_tree: Tree

## Tree showing assigned InputActions
@export var _action_tree: Tree

## Button to add a InputAction
@export var _add_action_button: Button

## Button to remove an InputAction
@export var _remove_action_button: Button


## Currently active UIPanel
var _panel: UIPanel

## Map of Button -> TreeItem
var _button_items: RefMap = RefMap.new()

## RefMap for InputAction:TreeItem
var _actions: RefMap = RefMap.new()

## Currently selected button
var _selected_button: Button


## Assigns the UIPanel to edit
func set_panel(panel: UIPanel) -> void:
	_button_tree.clear()
	_button_tree.create_item()
	
	_button_items.clear()
	_selected_button = null
	
	_add_action_button.set_disabled(true)
	_remove_action_button.set_disabled(true)
	
	_panel = panel
	_load_buttons()


## Sets the current button
func set_buton(button: Button) -> void:
	if not _button_items.has_left(button):
		return
	
	var button_item: TreeItem = _button_items.left(button)
	button_item.select(0)
	_button_tree.scroll_to_item(button_item)
	
	_selected_button = button
	_add_action_button.set_disabled(false)
	
	_action_tree.clear()
	_action_tree.create_item()
	for action: InputAction in _panel.get_button_actions(_selected_button):
		var tree_item: TreeItem = _action_tree.create_item()
		tree_item.set_text(0, action.get_name())
		
		_actions.map(action, tree_item)


## Loads and displays all buttons from the UIPanel
func _load_buttons() -> void:
	for button in _panel.get_buttons():
		var item: TreeItem = _button_tree.create_item()
		
		item.set_text(0, button.get_name())
		_button_items.map(button, item)


## Called when an item is selected in the button tree
func _on_button_list_item_selected() -> void:
	set_buton(_button_items.right(_button_tree.get_selected()))


## Called when the AddAction button is pressed
func _on_add_action_pressed() -> void:
	Interface.show_input_action_list().then(func (action: InputAction) -> void:
		if _panel and _selected_button:
			if _panel.asign_button_action(_selected_button, action):
				var tree_item: TreeItem = _action_tree.create_item()
				
				tree_item.set_text(0, action.get_name())
				_actions.map(action, tree_item)
	)


## Called when the remove action button is pressed
func _on_remove_action_pressed() -> void:
	var tree_item: TreeItem = _action_tree.get_selected()
	
	_panel.remove_button_action(_selected_button, _actions.right(tree_item))
	_actions.erase_right(tree_item)
	
	tree_item.free()
	_remove_action_button.set_disabled(true)


## Called when an item is selected in the ActionTree
func _on_action_tree_item_selected() -> void:
	_remove_action_button.set_disabled(false)
