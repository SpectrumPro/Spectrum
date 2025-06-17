# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name FunctionGroup extends Function
## A group of functions


## Emitted when functions are added
signal functions_added(functions: Array)

## Emitted when functions are removed
signal functions_removed(functions: Array)

## Emitted when a Function's index is changed
signal functions_index_changed(function: Function, index: int)

## Emitted when a trigger is added
signal trigger_added(component: EngineComponent, up_method: String, down_method: String, row: int, column: int)

## Emitted when a trigger is added
signal trigger_removed(row: int, column: int)

## Emitted when a trigger name is changes
signal trigger_name_changed(row: int, column: int, name: String)

## Emitted when a trigger is triggred
signal trigger_up(row: int, column: int)

## Emitted when a trigger is triggred
signal trigger_down(row: int, column: int)


## Refmap for storing functions
var _functions: Array[Function]

## All triggeres stores as { row: { column: {trigger...} } } 
var _triggers: Dictionary[int, Dictionary]


## Init
func _component_ready() -> void:
	_set_name("FunctionGroup")
	_set_self_class("FunctionGroup")
	
	register_callback("on_functions_added", _add_functions)
	register_callback("on_functions_removed", _remove_functions)
	register_callback("on_functions_index_changed", _set_function_index)
	
	register_callback("on_trigger_added", _add_trigger)
	register_callback("on_trigger_removed", _remove_trigger)
	register_callback("on_trigger_name_changed", _rename_trigger)
	register_callback("on_trigger_up", _call_trigger_up)
	register_callback("on_trigger_down", _call_trigger_down)
	
	register_custom_panel("FunctionGroup", "functions", "set_function_group", load("res://components/ComponentSettings/ClassCustomModules/FunctionGroupFunctions.tscn"))


## Adds a trigger at the given row and column
func add_trigger(p_component: EngineComponent, p_up_method: String, p_down_method: String, p_name: String,  p_row: int, p_column: int) -> Promise:
	return rpc("add_trigger", [p_component, p_up_method, p_down_method, p_name, p_row, p_column])


## Removes a trigger
func remove_trigger(p_row: int, p_column: int) -> Promise:
	return rpc("remove_trigger", [p_row, p_column])


## Removes a trigger
func rename_trigger(p_row: int, p_column: int, p_name: String) -> Promise:
	return rpc("rename_trigger", [p_row, p_column, p_name])


## Triggers a trigger
func call_trigger_up(p_row: int, p_column: int, p_value: Variant = null) -> Promise:
	return rpc("call_trigger_up", [p_row, p_column, p_value])


## Triggers a trigger
func call_trigger_down(p_row: int, p_column: int, p_value: Variant = null) -> Promise:
	return rpc("call_trigger_down", [p_row, p_column, p_value])


# Adds a function
func add_function(p_function: Function) -> Promise:
	return rpc("add_function", [p_function])


## Adds mutiple functions at once
func add_functions(p_functions: Array) -> Promise:
	return rpc("add_functions", [p_functions])


## Removes a function
func remove_function(p_function: Function) -> Promise:
	return rpc("remove_function", [p_function])


## Removes mutiple functions at once
func remove_functions(p_functions: Array) -> Promise:
	return rpc("remove_functions", [p_functions])


## Sets the indes of a function
func set_function_index(p_function: Function, p_index: int) -> Promise:
	return rpc("set_function_index", [p_function, p_index])


## Moves a Function up an index
func move_up(p_function: Function) -> Promise:
	return rpc("move_up", [p_function])


## Moves a Function down an index
func move_down(p_function: Function) -> Promise:
	return rpc("move_down", [p_function])


## Gets all the functions
func get_functions() -> Array[Function]:
	return _functions.duplicate()


## Checks if this FunctionGroup has a function
func has_function(p_function: Function) -> bool:
	return _functions.has(p_function)


## Internal: Adds a trigger at the given row and column
func _add_trigger(p_component: EngineComponent, p_up_method: String, p_down_method: String, p_name: String, p_row: int, p_column: int, no_signal: bool = false) -> bool:
	if (p_up_method and not p_component.has_method(p_up_method)) or (p_down_method and not p_component.has_method(p_down_method)):
		return false

	_triggers.get_or_add(p_row, {})[p_column] = {
		"component": p_component,
		"up": p_component.get(p_up_method),
		"down": p_component.get(p_down_method),
		"p_name": p_name
	}
	
	if not no_signal:
		trigger_added.emit(p_component, p_up_method, p_down_method)

	return true


## Internal: Removes a trigger
func _remove_trigger(p_row: int, p_column: int, no_signal: bool = false) -> bool:
	if not _triggers.has(p_row) or not _triggers[p_row].has(p_column):
		return false

	_triggers.get(p_row, {}).erase(p_column)

	if not no_signal:
		trigger_removed.emit(p_row, p_column)

	return true


## Renames a trigger
func _rename_trigger(p_row: int, p_column: int, p_name: String, no_signal: bool = false) -> bool:
	if not _triggers.has(p_row) or not _triggers[p_row].has(p_column):
		return false

	_triggers[p_row][p_column].name = p_name

	if not no_signal:
		trigger_name_changed.emit(p_row, p_column, no_signal)


	return true
## Internal: Triggers a trigger
func _call_trigger_up(p_row: int, p_column: int, p_value: Variant = null) -> void:
	var trigger: Dictionary = _triggers.get(p_row, {}).get(p_column, {})

	if not trigger:
		return

	if p_value == null:
		trigger.up.call()
	else:
		trigger.up.call(p_value)

	trigger_up.emit(p_row, p_column, p_value)


## Internal: Triggers a trigger
func _call_trigger_down(p_row: int, p_column: int, p_value: Variant = null) -> void:
	var trigger: Dictionary = _triggers.get(p_row, {}).get(p_column, {})

	if not trigger:
		return

	if p_value == null:
		trigger.down.call()
	else:
		trigger.down.call(p_value)

	trigger_down.emit(p_row, p_column, p_value)


## Adds a function
func _add_function(p_function: Function, no_signal: bool = false) -> bool:
	if p_function and p_function in _functions and p_function != self:
		return false
	
	p_function.delete_requested.connect(_remove_function.bind(p_function))
	_functions.append(p_function)

	if not no_signal:
		functions_added.emit([p_function])

	return true


## Adds mutiple functions at once
func _add_functions(p_functions: Array) -> void:
	var just_added_functions: Array[Function]

	for function: Variant in p_functions:
		if function is Function:
			if _add_function(function, true):
				just_added_functions.append(function)

	if just_added_functions:
		functions_added.emit(just_added_functions)


## Removes a function
func _remove_function(p_function: Function, no_signal: bool = false) -> bool:
	if p_function not in _functions:
		return false

	_functions.erase(p_function)

	if not no_signal:
		functions_removed.emit([p_function])

	return true


## Removes mutiple functions at once
func _remove_functions(p_functions: Array) -> void:
	var just_removed_functions: Array[Function]

	for function: Variant in p_functions:
		if function is Function:
			if _remove_function(function, true):
				just_removed_functions.append(function)

	if just_removed_functions:
		functions_removed.emit(just_removed_functions)


## Sets the indes of a function
func _set_function_index(p_function: Function, p_index: int) -> bool:
	if p_function not in _functions or p_index > _functions.size():
		return false

	_functions.erase(p_function)
	_functions.insert(p_index, p_function)

	functions_index_changed.emit(p_function, p_index)

	return true


## Overide this function to serialize your object
func _serialize_request() -> Dictionary:
	var function_uuids: Array[String]
	var triggers: Dictionary[int, Dictionary]
	
	for function: Function in _functions:
		function_uuids.append(function.uuid)
	
	for row: int in _triggers:
		triggers[row] = {}
		for column: int in _triggers[row]:
			triggers[row][column] = {
				"component": _triggers[row][column].component.uuid,
				"up": _triggers[row][column].up.get_method() if _triggers[row][column].up else "",
				"down": _triggers[row][column].down.get_method() if _triggers[row][column].down else "",
				"name": _triggers[row][column].name,
			}
	
	return {
		"functions": function_uuids,
		"triggers": triggers
	}


## Overide this function to handle load requests
func _load_request(p_serialized_data: Dictionary) -> void:
	var function_uuids: Array = type_convert(p_serialized_data.get("functions", []), TYPE_ARRAY)
	
	for uuid: Variant in function_uuids:
		if uuid is String:
			ComponentDB.request_component(uuid, func (function: EngineComponent):
				if function is Function:
					_add_function(function)
			)
	
	var triggers: Dictionary = type_convert(p_serialized_data.get("triggers", {}), TYPE_DICTIONARY)
	
	for row: Variant in triggers:
		row = int(row)
		
		for column: Variant in triggers[row]:
			column = int(column)
			ComponentDB.request_component(triggers[row][column].component, func (component: EngineComponent):
				_add_trigger(component, triggers[row][column].up, triggers[row][column].down, triggers[row][column].name, row, column)
			)
