# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name Promise extends RefCounted
## Implementation of the JavaScript Promise


## Emitted when this signal is resolved
signal resolved(args: Array)


## Emitted when this signal is rejected
signal rejected(args: Array)


## Methods to call once this promise is resolved
var _resolved_methods: Array[Callable] = []

## Methods to call once this promise is rejected
var _rejected_methods: Array[Callable] = []

## Args for the auto resolve
var _auto_resolve_args: Array = []

## Auto resolve state
var _use_auto_resolve: bool = false


## Resolve this promise
func resolve(args: Array = []) -> void:
	for method: Callable in _resolved_methods:
		if not method.get_argument_count():
			method.call()
			
		else:
			method.callv(args)
	
	resolved.emit(args)


## Rejects this promise
func reject(args: Array = []) -> void:
	for method: Callable in _rejected_methods:
		if not method.get_argument_count():
			method.call()
			
		else:
			method.callv(args)
	
	rejected.emit(args)


## Automatically resolves this promise when ever a new then() callable is added
func auto_resolve(args: Array = []) -> void:
	_use_auto_resolve = true
	_auto_resolve_args = args


## Adds a method that will be called if this promise is resolved
func then(method: Callable) -> Promise:
	_resolved_methods.append(method)
	
	if _use_auto_resolve:
		method.callv(_auto_resolve_args)
	
	return self


## Adds a method that will be called if this promise is rejected
func catch(method: Callable) -> Promise:
	_rejected_methods.append(method)

	return self


## Removes all callbacks, this does not disconnect signals
func clear() -> void:
	_resolved_methods.clear()
	_rejected_methods.clear()
