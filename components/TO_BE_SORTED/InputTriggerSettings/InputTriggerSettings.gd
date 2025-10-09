# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name InputActionSettingsComponent extends PanelContainer
## Settings for InputAction


## The ClientComponentSettings for InputActions
@export var _input_action_settings: Control

## The ClientComponentSettings for InputTriggers
@export var _input_trigger_settings: Control

## The ClientComponentSettings for ActionTriggers
@export var _action_trigger_settings: Control

## ItemList for InputTriggers
@export var _input_triggers_tree: Tree

## ItemList for ActionTriggers
@export var _action_triggers_tree: Tree

## OptionButton for creating a new InputTrigger
@export var _new_input_trigger_button: OptionButton

## OptionButton for creating a new ActionButton
@export var _new_action_trigger_button: OptionButton

## The RemoveInputTrigger button
@export var _remove_input_trigger_button: Button

## The RemoveActionTrigger button
@export var _remove_action_trigger_button: Button

## Tab button for settings
@export var _tab_button_settings: Button

## Tab button for InputTriggers
@export var _tab_button_inputs: Button

## Tab button for ActionTriggers
@export var _tab_button_actions: Button


## The current input trigger
var _input_action: InputAction

## RefMap for InputTrigger:TreeItem
var _input_triggers: RefMap = RefMap.new()

## RefMap for ActionTrigger:TreeItem
var _action_triggers: RefMap = RefMap.new()

## Signal to connect
var _input_action_signals: Dictionary[String, Callable] = {
	"input_trigger_added": _add_input_trigger,
	"input_trigger_removed": _remove_input_trigger,
	"action_trigger_added": _add_action_trigger,
	"action_trigger_removed": _remove_action_trigger,
}


## Ready
func _ready() -> void:
	for classname: String in InputServer.get_input_trigger_types():
		_new_input_trigger_button.add_item(classname)
	
	for classname: String in InputServer.get_action_trigger_types():
		_new_action_trigger_button.add_item(classname)
	
	_new_input_trigger_button.select(0)
	_new_action_trigger_button.select(0)


## Sets the input action
func set_input_action(p_input_action: InputAction) -> void:
	if p_input_action == _input_action:
		return
	
	Utils.disconnect_signals(_input_action_signals, _input_action)
	_input_action = p_input_action
	
	_input_triggers_tree.clear()
	_action_triggers_tree.clear()
	
	_input_triggers_tree.create_item()
	_action_triggers_tree.create_item()
	
	_input_trigger_settings.set_component(null)
	_action_trigger_settings.set_component(null)
	
	_remove_input_trigger_button.set_disabled(true)
	_remove_action_trigger_button.set_disabled(true)
	
	if not _input_action:
		_tab_button_settings.set_pressed(true)
		
		_tab_button_settings.set_disabled(true)
		_tab_button_inputs.set_disabled(true)
		_tab_button_actions.set_disabled(true)
		
		_input_action_settings.set_component(null)
		return
	
	_tab_button_settings.set_disabled(false)
	_tab_button_inputs.set_disabled(false)
	_tab_button_actions.set_disabled(false)
	
	Utils.connect_signals(_input_action_signals, _input_action)
	_input_action_settings.set_component(_input_action)

	for input_trigger: InputTrigger in _input_action.get_input_triggers():
		_add_input_trigger(input_trigger)
	
	for action_trigger: ActionTrigger in _input_action.get_action_triggers():
		_add_action_trigger(action_trigger)


## Adds an input trigger
func _add_input_trigger(p_input_trigger: InputTrigger) -> void:
	var tree_item: TreeItem = _input_triggers_tree.create_item()
	tree_item.set_text(0, p_input_trigger.get_name())
	
	p_input_trigger.name_changed.connect(func (new_name: String):
		tree_item.set_text(0, new_name)
	)
	
	_input_triggers.map(p_input_trigger, tree_item)


## Removes an input trigger
func _remove_input_trigger(p_input_trigger: InputTrigger) -> void:
	_input_trigger_settings.set_component(null)
	_input_triggers.left(p_input_trigger).free()


## Adds an input trigger
func _add_action_trigger(p_action_trigger: ActionTrigger) -> void:
	var tree_item: TreeItem = _action_triggers_tree.create_item()
	tree_item.set_text(0, p_action_trigger.get_name())
	
	p_action_trigger.name_changed.connect(func (new_name: String):
		tree_item.set_text(0, new_name)
	)
	
	_action_triggers.map(p_action_trigger, tree_item)


## Removes an input trigger
func _remove_action_trigger(p_action_trigger: ActionTrigger) -> void:
	_action_trigger_settings.set_component(null)
	_action_triggers.left(p_action_trigger).free()


## Called when a class is selected in the NewInputTriggerButton
func _on_new_input_trigger_item_selected(index: int) -> void:
	_input_action.create_input_trigger(InputServer.get_input_trigger_types()[index - 1])
	_new_input_trigger_button.select(0)


## Called when a class is selected in the NewActionTrigger
func _on_new_action_trigger_item_selected(index: int) -> void:
	_input_action.create_action_trigger(InputServer.get_action_trigger_types()[index - 1])
	_new_action_trigger_button.select(0)


## Called when an item is selected in the input trigger tree
func _on_input_trigger_list_item_selected() -> void:
	_input_trigger_settings.set_component(_input_triggers.right(_input_triggers_tree.get_selected()))
	_remove_input_trigger_button.set_disabled(false)


## Called when an item is selected in the action trigger tree
func _on_action_triggers_item_selected() -> void:
	_action_trigger_settings.set_component(_action_triggers.right(_action_triggers_tree.get_selected()))
	_remove_action_trigger_button.set_disabled(false)


## Called when the DeleteInputTrigger button is pressed
func _on_delete_input_trigger_pressed() -> void:
	_input_action.remove_input_trigger(_input_triggers.right(_input_triggers_tree.get_selected()))


## Called when the DeleteActionTrigger button is pressed
func _on_delete_action_trigger_pressed() -> void:
	_input_action.remove_action_trigger(_action_triggers.right(_action_triggers_tree.get_selected()))
