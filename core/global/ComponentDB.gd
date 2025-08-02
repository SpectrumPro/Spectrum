# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name EngineComponentDB extends Node
## Stores all the current components in the engine


## Emitted when a component is added to this engine
signal component_added(component: EngineComponent)

## Emitted when a component is deleted from this engine
signal component_removed(component: EngineComponent)


## Stores all the components in this DB
var components: Dictionary = {}

## Stores all components by there class name
var components_by_classname: Dictionary = {}


## Stores all the class callback signals
var _class_callbacks: Dictionary = {}

## Stores all the components that were just added or removed for a given class name. Allowing to emit the class callback all at once
var _just_changed_components: Dictionary = {}

## Is true when _emit_class_callbacks is to be called at the end of this frame
var _emit_class_callbacks_queued: bool = false

## Stores all the requests for components
var _component_requests: Dictionary = {}


func _ready() -> void:
	Core.resetting.connect(func () -> void:
		_just_changed_components = {}
		_class_callbacks = {}
		_emit_class_callbacks_queued = false
		_component_requests = {}
	)


## Adds a component to the DB, returns false if it already exists
func register_component(component: EngineComponent) -> bool:
	if component.uuid in components:
		return false
	
	components[component.uuid] = component
	
	for classname in component.class_tree:
		if not classname in components_by_classname:
			components_by_classname[classname] = []
		components_by_classname[classname].append(component)
	
	if component.uuid in _component_requests:
		for callback in _component_requests[component.uuid]:
			if callback.is_valid(): 
				callback.call(component)
		_component_requests.erase(component.uuid)
	
	_check_class_callbacks(component)
	component.delete_requested.connect(deregister_component.bind(component), CONNECT_ONE_SHOT)
	
	Client.add_networked_object(component.uuid, component, component.delete_requested)
	component_added.emit(component)
	return true


## Removes a component to the DB, returns false if it never existed
func deregister_component(component: EngineComponent) -> bool:
	if not component.uuid in components:
		return false
	
	for classname in component.class_tree:
		components_by_classname[classname].erase(component)
	
	_check_class_callbacks(component, true)
	
	Client.remove_networked_object(component.uuid)
	components.erase(component.uuid)
	
	component_removed.emit(component)
	return true


## Gets all the loaded components by classname
func get_components_by_classname(classname: String) -> Array:
	return components_by_classname.get(classname, []).duplicate()


## Gets a component by a uuid
func get_component(uuid: String) -> EngineComponent:
	return components.get(uuid)


## Use this method if you need to call a function once a component is added to the engine. This will only be called once
func request_component(uuid: String, callback: Callable) -> void:
	if not uuid:
		return
	
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


## Adds a request to callback when a component is added that matches the classname, this will be called every time 
func request_class_callback(classname: String, callback: Callable) -> void:
	if not _class_callbacks.has(classname): 
		_class_callbacks[classname] = []
	
	_class_callbacks[classname].append(callback)


## Removes a request for a class callback
func remove_class_callback(classname: String, callback: Callable) -> void:
	if _class_callbacks.has(classname):
		_class_callbacks[classname].erase(callback)


## Checks if there are any class callbacks for this component
func _check_class_callbacks(component: EngineComponent, remove: bool = false) -> void:
	for classname: String in component.class_tree:
		if classname in _class_callbacks:
			if not _just_changed_components.has(classname): 
				_just_changed_components[classname] = {
					"added": [],
					"removed": []
				}
			
			if remove:
				_just_changed_components[classname].removed.append(component)
			else:
				_just_changed_components[classname].added.append(component)
			
			if not _emit_class_callbacks_queued:
				_emit_class_callbacks.call_deferred()
			_emit_class_callbacks_queued = true


## Emitts all the class callbacks, this function should be called using call_defered() allowing to emit all components at once, instead of one by one
func _emit_class_callbacks() -> void:
	if _just_changed_components:
		for classname: String in _just_changed_components:
			for callback: Callable in _class_callbacks[classname]:
				callback.callv(_just_changed_components[classname].values())
	
	_just_changed_components = {}
	_emit_class_callbacks_queued = false
