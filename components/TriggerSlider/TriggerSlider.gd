# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name TriggerSlider extends VSlider
## A trigger slider to change values


## The uuid, callable, and method name for the trigger
var _trigger_config: Dictionary = {
	"uuid": "",
	"method_name": "",
	"callable": Callable()
}


var _feedback_config: Dictionary = {
	"uuid": "",
	"method_name": "",
	"signal": Signal()
}


## Sets the trigger connected to this slider
func set_trigger(component_uuid: String, method_name: String) -> void:
	if _trigger_config.uuid:
		ComponentDB.remove_request(_trigger_config.uuid, _on_trigger_object_found)
	
	_trigger_config.uuid = component_uuid
	_trigger_config.method_name = method_name
	
	ComponentDB.request_component(component_uuid, _on_trigger_object_found)


## Callback for when ComponentDB finds the object
func _on_trigger_object_found(object: EngineComponent) -> void:
	if object.accessible_methods.has(_trigger_config.method_name):
		_trigger_config.callable = object.accessible_methods[_trigger_config.method_name].set


## Sets the feedback connected to this slider
func set_feedback(component_uuid: String, method_name: String) -> void:
	if _feedback_config.uuid:
		ComponentDB.remove_request(_feedback_config.uuid, _on_feedback_object_found)
	
	_feedback_config.uuid = component_uuid
	_feedback_config.method_name = method_name
	
	ComponentDB.request_component(component_uuid, _on_feedback_object_found)


## Callback for when ComponentDB finds the object
func _on_feedback_object_found(object: EngineComponent) -> void:
	if not _feedback_config.signal.is_null():
		_feedback_config.signal.disconnect(_on_feedback_signal_emitted)
		_feedback_config.signal = Signal()
	
	if object.accessible_methods.has(_feedback_config.method_name):
		set_value_no_signal(object.accessible_methods[_feedback_config.method_name].get.call())
		_feedback_config.signal = object.accessible_methods[_feedback_config.method_name].signal
		_feedback_config.signal.connect(_on_feedback_signal_emitted)


func _on_feedback_signal_emitted(p_value: Variant) -> void:
	set_value_no_signal(p_value as float)


## Called when the value is changed
func _on_value_changed(value: float) -> void:
	if _trigger_config.callable.is_valid():
		_trigger_config.callable.call(value)


## Saves this trigger into a dict
func serialize() -> Dictionary:
	return {
		"min": min_value,
		"max": max_value,
		"trigger": {
			"uuid": _trigger_config.uuid,
			"method_name": _trigger_config.method_name,
		},
		"feedback": {
			"uuid": _feedback_config.uuid,
			"method_name": _feedback_config.method_name,
		}
	}


## Loads this trigger from a dict
func deserialize(serialized_data: Dictionary) -> void:
	min_value = serialized_data.get("min_value", min_value)
	max_value = serialized_data.get("max_value", max_value)
	
	if serialized_data.get("trigger", null) is Dictionary:
		var config: Dictionary = serialized_data.trigger
		if config.get("uuid", "") and config.get("method_name", ""):
			set_trigger(
				config.uuid,
				config.method_name,
			)
	
	if serialized_data.get("feedback", null) is Dictionary:
		var config: Dictionary = serialized_data.feedback
		if config.get("uuid", "") and config.get("method_name", ""):
			set_feedback(
				config.uuid,
				config.method_name,
			)
