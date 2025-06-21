# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

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
var _function_group_signal_connections: Dictionary[String, Callable] = {
	"functions_added": _add_functions,
	"functions_removed": _remove_functions,
	"functions_index_changed": _set_function_index
}


## Sets the FunctionGroup
func set_function_group(function_group: FunctionGroup) -> void:
	Utils.disconnect_signals(_function_group_signal_connections, _function_group)
	_function_group = function_group
	Utils.connect_signals(_function_group_signal_connections, _function_group)
	
	_add_functions(_function_group.get_functions())


## Adds functions to the list
func _add_functions(functions: Array) -> void:
	for function: Function in functions:
		if function in _function_tree_items.get_left():
			return
		
		var item: TreeItem = _root.create_child()
		item.set_text(0, function.get_name())
		
		_function_tree_items.map(function, item)


## Removes functions from the list
func _remove_functions(functions: Array) -> void:
	for function: Function in functions:
		if function not in _function_tree_items.get_left():
			return
		
		_function_tree_items.left(function).free()
		_function_tree_items.erase_left(function)
		
		if function in _selected_functions:
			_selected_functions.erase(function)


## Sets the index of a function
func _set_function_index(function: Function, index: int) -> void:
	var tree_item: TreeItem = _function_tree_items.left(function)
	
	if index == 0:
		tree_item.move_before(_root.get_child(0))
	else:
		var before: TreeItem = _root.get_child(index)
		print(before.get_text(0))
		tree_item.move_after(before)


## Called when the Add Button is pressed
func _on_add_pressed() -> void:
	Interface.show_object_picker(ObjectPicker.SelectMode.Multi, func (functions: Array):
		_function_group.add_functions(functions)
	, "Function")


## Called when the Remove Button is pressed
func _on_remove_pressed() -> void:
	_function_group.remove_functions(_selected_functions)


## Called when items are selected on the Tree
func _on_tree_multi_selected(item: TreeItem, column: int, selected: bool) -> void:
	var function: Function = _function_tree_items.right(item)
	
	if selected and function not in _selected_functions:
		_selected_functions.append(function)
	elif not selected and function in _selected_functions:
		_selected_functions.erase(function)
	
	var state: bool = _selected_functions == []
	_remove_button.disabled = state
	_move_up_button.disabled = state
	_move_down_button.disabled = state


## Called when the Down button is pressed
func _on_move_up_pressed() -> void:
	for function: Function in _selected_functions:
		_function_group.move_up(function)


## Called when the Up button is pressed
func _on_move_down_pressed() -> void:
	for function: Function in _selected_functions:
		_function_group.move_down(function)
