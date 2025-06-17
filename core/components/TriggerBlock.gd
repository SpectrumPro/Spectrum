# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name TriggerBlock extends EngineComponent
## Block of triggers


## Emitted when a trigger is added
signal trigger_added(component: EngineComponent, up_method: String, down_method: String, name: String, id: String, row: int, column: int)

## Emitted when a trigger is added
signal trigger_removed(row: int, column: int)

## Emitted when a trigger name is changes
signal trigger_name_changed(row: int, column: int, name: String)

## Emitted when a trigger is triggred
signal trigger_up(row: int, column: int)

## Emitted when a trigger is triggred
signal trigger_down(row: int, column: int)


## All triggeres stores as { row: { column: {trigger...} } }
var _triggers: Dictionary[int, Dictionary]


## Ready
func _component_ready() -> void:
	_set_name("TriggerBlock")
	_set_self_class("TriggerBlock")
	
	register_callback("on_trigger_added", _add_trigger)
	register_callback("on_trigger_removed", _remove_trigger)
	register_callback("on_trigger_name_changed", _rename_trigger)
	register_callback("on_trigger_up", _call_trigger_up)
	register_callback("on_trigger_down", _call_trigger_down)


## Adds a trigger at the given row and column
func add_trigger(p_component: EngineComponent, p_up_method: String, p_down_method: String, p_name: String, p_id: String, p_row: int, p_column: int) -> Promise:
	return rpc("add_trigger", [p_component, p_up_method, p_down_method, p_name, p_id, p_row, p_column])


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


## Gets all the triggers
func get_triggers() -> Dictionary[int, Dictionary]:
	return _triggers.duplicate()


## Internal: Adds a trigger at the given row and column
func _add_trigger(p_component: EngineComponent, p_up_method: String, p_down_method: String, p_name: String, p_id: String, p_row: int, p_column: int, no_signal: bool = false) -> bool:
	if (p_up_method and not p_component.has_method(p_up_method)) or (p_down_method and not p_component.has_method(p_down_method)):
		return false
	
	_triggers.get_or_add(p_row, {})[p_column] = {
		"component": p_component,
		"up": p_component.get(p_up_method) if p_component.has_method(p_up_method) else Callable(),
		"down": p_component.get(p_down_method) if p_component.has_method(p_down_method) else Callable(),
		"name": p_name,
		"id": p_id
	}
	
	if not no_signal:
		trigger_added.emit(p_component, p_up_method, p_down_method, p_name, p_id, p_row, p_column)
	
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
	
	trigger_up.emit(p_row, p_column, p_value)


## Internal: Triggers a trigger
func _call_trigger_down(p_row: int, p_column: int, p_value: Variant = null) -> void:
	var trigger: Dictionary = _triggers.get(p_row, {}).get(p_column, {})
	
	if not trigger:
		return
	
	trigger_down.emit(p_row, p_column, p_value)


## Overide this function to serialize your object
func _serialize_request() -> Dictionary:
	var triggers: Dictionary[int, Dictionary]

	for row: int in _triggers:
		triggers[row] = {}
		for column: int in _triggers[row]:
			triggers[row][column] = {
				"component": _triggers[row][column].component.uuid,
				"up": _triggers[row][column].up.get_method() if _triggers[row][column].up else "",
				"down": _triggers[row][column].down.get_method() if _triggers[row][column].down else "",
				"name": _triggers[row][column].name,
				"id": _triggers[row][column].id
			}

	return {
		"triggers": triggers
	}


## Overide this function to handle load requests
func _load_request(p_serialized_data: Dictionary) -> void:
	var triggers: Dictionary = type_convert(p_serialized_data.get("triggers", {}), TYPE_DICTIONARY)

	for row_key: int in triggers.keys():
		var row_dict: Dictionary = type_convert(triggers.get(row_key, {}), TYPE_DICTIONARY)

		for column_key: int in row_dict.keys():
			var trigger_data: Dictionary = type_convert(row_dict.get(column_key, {}), TYPE_DICTIONARY)

			var component_id: Variant = trigger_data.get("component", null)
			var up: String = type_convert(trigger_data.get("up", false), TYPE_STRING)
			var down: String = type_convert(trigger_data.get("down", false), TYPE_STRING)
			var name: String = type_convert(trigger_data.get("name", ""), TYPE_STRING)
			var id: String = type_convert(trigger_data.get("id", ""), TYPE_STRING)

			if component_id == null:
				continue

			ComponentDB.request_component(component_id, func(component: EngineComponent) -> void:
				_add_trigger(component, up, down, name, id, row_key, column_key, true)
			)
