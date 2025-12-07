# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name FunctionGroupFunctions extends PanelContainer
## Custom status display for FunctionGroup


## Tree for displaying function
@export var _tree: Tree

## The Remove Button
@export var _remove_button: Button

## The MoveUp Button
@export var _move_up_button: Button

## The MoveDown Button
@export var _move_down_button: Button

## Root TreeItem
@onready var _root: TreeItem = _tree.create_item()


## The current FunctionGroup
var _function_group: FunctionGroup

## Stores all TreeItems with there Function
var _function_tree_items: RefMap = RefMap.new()

## All current selected function
var _selected_functions: Array[Function]

## Signals to connect to the FunctionGroup
var _signal_group: SignalGroup = SignalGroup.new([], {
	"functions_added": _add_functions,
	"functions_removed": _remove_functions,
	"functions_index_changed": _set_function_index
})


## Sets the FunctionGroup
func set_function_group(function_group: FunctionGroup) -> void:
	_signal_group.disconnect_object(_function_group)
	_function_group = function_group
	_signal_group.connect_object(_function_group)
	
	_add_functions(_function_group.get_functions())


## Adds functions to the list
func _add_functions(p_functions: Array[Function]) -> void:
	for function: Function in p_functions:
		if function in _function_tree_items.get_left():
			return
		
		var item: TreeItem = _root.create_child()
		item.set_text(0, function.get_name())
		
		_function_tree_items.map(function, item)


## Removes functions from the list
func _remove_functions(p_functions: Array[Function]) -> void:
	for function: Function in p_functions:
		if function not in _function_tree_items.get_left():
			return
		
		_function_tree_items.left(function).free()
		_function_tree_items.erase_left(function)
		
		if function in _selected_functions:
			_selected_functions.erase(function)


## Sets the index of a function
func _set_function_index(p_function: Function, p_index: int) -> void:
	var tree_item: TreeItem = _function_tree_items.left(p_function)
	
	if p_index == 0:
		tree_item.move_before(_root.get_child(0))
	else:
		var before: TreeItem = _root.get_child(p_index)
		tree_item.move_after(before)


## Called when the Add Button is pressed
func _on_add_pressed() -> void:
	Interface.prompt_object_picker(self, EngineComponent, "Function").then(func (p_function: Function):
		_function_group.add_function(p_function)
	)


## Called when the Remove Button is pressed
func _on_remove_pressed() -> void:
	_function_group.remove_functions(_selected_functions)


## Called when items are selected on the Tree
func _on_tree_multi_selected(p_item: TreeItem, p_column: int, p_selected: bool) -> void:
	var function: Function = _function_tree_items.right(p_item)
	
	if p_selected and function not in _selected_functions:
		_selected_functions.append(function)
	elif not p_selected and function in _selected_functions:
		_selected_functions.erase(function)
	
	var state: bool = _selected_functions == []
	_remove_button.set_disabled(state)
	_move_up_button.set_disabled(state)
	_move_down_button.set_disabled(state)


## Called when the Down button is pressed
func _on_move_up_pressed() -> void:
	for function: Function in _selected_functions:
		_function_group.move_up(function)


## Called when the Up button is pressed
func _on_move_down_pressed() -> void:
	for function: Function in _selected_functions:
		_function_group.move_down(function)
