# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name UIInputActionList extends UIPanel
## Picker for Imput Actions


## Emitted when a InputAction is chosen
signal action_chosen(action: InputAction)


## ItemList for function
@export var _action_list: Tree

## The Confirm button
@export var _confirm_button: Button


## RefMap for InputAction: TreeItem
var _input_actions: RefMap = RefMap.new()


## Connect signals
func _ready() -> void:
	_action_list.create_item()
	
	InputServer.input_action_added.connect(_add_input_action)
	InputServer.input_action_removed.connect(_remove_input_action)
	
	for action: InputAction in InputServer.get_input_actions():
		_add_input_action(action)


## Adds an InputAction to the list
func _add_input_action(p_action: InputAction) -> void:
	var tree_item: TreeItem = _action_list.create_item()
	
	p_action.name_changed.connect(func (new_name: String):
		tree_item.set_text(0, new_name)
	)
	
	tree_item.set_text(0, p_action.get_name())
	_input_actions.map(p_action, tree_item)
	
	tree_item.select(0)
	_confirm_button.set_disabled(false)


## Removes an InputAction to the list
func _remove_input_action(p_action: InputAction) -> void:
	_input_actions.left(p_action).free()
	_input_actions.erase_left(p_action)
	
	if not _input_actions.get_left():
		_confirm_button.set_disabled(true)


## Called when the Confirm Button is pressed
func _on_confirm_pressed() -> void:
	action_chosen.emit(_input_actions.right(_action_list.get_selected()))
