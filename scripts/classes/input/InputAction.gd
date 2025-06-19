# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name InputAction extends ClientComponent
## Combines inputs and control things


## Emitted when an InputTrigger is added
signal input_trigger_added(input_trigger: InputTrigger)

## Emitted when an InputTrigger is removed
signal input_trigger_removed(input_trigger: InputTrigger)

## Emitted when an ActionTrigger is added
signal action_trigger_added(action_trigger: ActionTrigger)

## Emitted when an ActionTrigger is removed
signal action_trigger_removed(action_trigger: ActionTrigger)


## All InputTriggers in this InputAction
var _input_triggers: Array[InputTrigger]

## All ActionTriggers in this InputAction
var _action_triggers: Array[ActionTrigger]


## Ready
func _component_ready() -> void:
	_set_class_name("InputAction")


## Activates this InputAction
func activate() -> void:
	print("Activated")


## Deactivates this InputAction
func deactivate() -> void:
	print("deactivated")


## Creates a new InputTrigger
func create_input_trigger(classname: String) -> InputTrigger:
	var input_trigger: InputTrigger = InputServer.get_input_trigger(classname)
	
	if not input_trigger:
		return null
	
	add_input_trigger(input_trigger)
	return input_trigger


## Adds a InputTrigger
func add_input_trigger(p_input_trigger: InputTrigger, no_signal: bool = false) -> bool:
	if _input_triggers.has(p_input_trigger):
		return false
	
	_input_triggers.append(p_input_trigger)
	
	match p_input_trigger.get_class_name():
		"InputTriggerKey":
			InputMap.action_add_event(uuid(), p_input_trigger.get_input_event())
	
	if not no_signal:
		input_trigger_added.emit(p_input_trigger)
	
	return true


## Removes an InputTrigger
func remove_input_trigger(p_input_trigger: InputTrigger, no_signal: bool = false) -> bool:
	if not _input_triggers.has(p_input_trigger):
		return false
	
	_input_triggers.erase(p_input_trigger)
	
	match p_input_trigger.get_class_name():
		"InputTriggerKey":
			InputMap.action_erase_event(uuid(), p_input_trigger.get_input_event())
	
	if not no_signal:
		input_trigger_removed.emit(p_input_trigger)
	
	return true


## Creates a new ActionTrigger
func create_action_trigger(classname: String) -> ActionTrigger:
	var action_trigger: ActionTrigger = InputServer.get_action_trigger(classname)
	
	if not action_trigger:
		return null
	
	add_action_trigger(action_trigger)
	return action_trigger


## Adds a ActionTrigger
func add_action_trigger(p_action_trigger: ActionTrigger, no_signal: bool = false) -> bool:
	if _action_triggers.has(p_action_trigger):
		return false
	
	_action_triggers.append(p_action_trigger)
	
	if not no_signal:
		action_trigger_added.emit(p_action_trigger)
	
	return true


## Removes an ActionTrigger
func remove_action_trigger(p_action_trigger: ActionTrigger, no_signal: bool = false) -> bool:
	if not _action_triggers.has(p_action_trigger):
		return false
	
	_action_triggers.erase(p_action_trigger)
	
	if not no_signal:
		action_trigger_removed.emit(p_action_trigger)
	
	return true


## Gets all the InputTriggers
func get_input_triggers() -> Array[InputTrigger]:
	return _input_triggers.duplicate()


## Gets all the ActionTrigger
func get_action_triggers() -> Array[ActionTrigger]:
	return _action_triggers.duplicate()


## Override this to provide a save function to your ClientComponent
func _save() -> Dictionary:
	var saved_input_triggers: Array[Dictionary]
	var saved_action_triggers: Array[Dictionary]
	
	for input_trigger: InputTrigger in _input_triggers:
		saved_input_triggers.append(input_trigger.save())
	
	for action_trigger: ActionTrigger in _action_triggers:
		saved_action_triggers.append(action_trigger.save())
	
	return {
		"input_triggers": saved_input_triggers,
		"action_triggers": saved_action_triggers
	}


## Override this to provide a load function to your ClientComponent
func _load(saved_data: Dictionary) -> void:
	var saved_input_triggers: Array = type_convert(saved_data.get("input_triggers"), TYPE_ARRAY)
	var saved_action_triggers: Array = type_convert(saved_data.get("action_triggers"), TYPE_ARRAY)
	
	for saved_input: Variant in saved_input_triggers:
		if saved_input is Dictionary and saved_input.get("class") is String:
			var input_trigger: InputTrigger = InputServer.get_input_trigger(saved_input.class)
			input_trigger.load(saved_input)
			
			add_input_trigger(input_trigger)
	
	for saved_action: Variant in saved_action_triggers:
		if saved_action is Dictionary and saved_action.get("class") is String:
			var action_trigger: ActionTrigger = InputServer.get_action_trigger(saved_action.class)
			action_trigger.load(saved_action)
			
			add_action_trigger(action_trigger)
