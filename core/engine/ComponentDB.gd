# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name EngineComponentDB extends Node
## Stores all the current somponents in the engine


## Emitted when a component is added to this engine
signal component_added(component: EngineComponent)

## Emitted when a component is deleted from this engine
signal component_removed(component: EngineComponent)


## Stores all the components in this DB
var components: Dictionary = {}

## Stores all components by there class name
var components_by_classname: Dictionary = {}


## Stores all the requests for components
var _component_requests: Dictionary = {}


func _ready() -> void:
	Core.resetting.connect(func () -> void:
		components = {}
		components_by_classname = {}
	)


## Adds a component to the DB, returns false if it already exists
func register_component(component: EngineComponent) -> bool:
	if component.uuid in components:
		return false
	
	components[component.uuid] = component
	
	if not component.self_class_name in components_by_classname:
		components_by_classname[component.self_class_name] = []
	components_by_classname[component.self_class_name].append(component)
	
	if component.uuid in _component_requests:
		for callback: Callable in _component_requests[component.uuid]:
			callback.call(component)
		
		_component_requests.erase(component.uuid)
	
	component_added.emit(component)
	return true


## Removes a component to the DB, returns false if it never existed
func deregister_component(component: EngineComponent) -> bool:
	if not component.uuid in components:
		return false
		
	components.erase(component.uuid)
	components_by_classname[component.self_class_name].erase(component)
	
	component_removed.emit(component)
	return true


## Gets all the loaded components by classname
func get_components_by_classname(classname: String) -> Array:
	return components_by_classname.get(classname, [])


## Use this method if you need to call a function once a component is added to the engine
func request_component(uuid: String, callback: Callable) -> void:
	if uuid in components:
		callback.call(components[uuid])
		
	else:
		if not uuid in _component_requests:
			_component_requests[uuid] = []
		
		_component_requests[uuid].append(callback)


## Removes a request
func remove_request(uuid: String, callback: Callable) -> void:
	if uuid in _component_requests and callback in _component_requests[uuid]:
		_component_requests[uuid].erase(callback)
		
		if not _component_requests[uuid]:
			_component_requests.erase(uuid)
