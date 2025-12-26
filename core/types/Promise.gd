# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name Promise extends RefCounted
## JavaScript-style Promise implementation


## Emitted when the promise is resolved
signal resolved(args: Array)

## Emitted when the promise is rejected
signal rejected(args: Array)


## Callbacks to run when resolved
var _resolved_methods: Array[Callable] = []

## Callbacks to run when rejected
var _rejected_methods: Array[Callable] = []

## Arguments for automatic resolve
var _auto_resolve_args: Array = []

## Arguments for automatic reject
var _auto_reject_args: Array = []

## Whether to auto-resolve new callbacks
var _use_auto_resolve: bool = false

## Whether to auto-reject new callbacks
var _use_auto_reject: bool = false

## The object refernce this promise is for
var _object_refernce: Object = null

## UNIX timestamp this Promise was created at
var _created_at: float = Time.get_unix_time_from_system()


## Resolves the promise and calls all registered `then()` callbacks
func resolve(args: Array = []) -> void:
	for method: Callable in _resolved_methods:
		if not method.get_argument_count():
			method.call()
		else:
			method.callv(args)

	resolved.emit(args)

## Resolves the promise and calls all registered `then()` callbacks. VarArg function
func resolvev(...args) -> void:
	resolve(args)


## Rejects the promise and calls all registered `catch()` callbacks
func reject(args: Array = []) -> void:
	for method: Callable in _rejected_methods:
		if not method.get_argument_count():
			method.call()
		else:
			method.callv(args)

	rejected.emit(args)


## Rejects the promise and calls all registered `catch()` callbacks VarArg function
func rejectv(...args) -> void:
	reject(args)


## Enables auto-resolve for any new `then()` callbacks
func auto_resolve(args: Array = []) -> Promise:
	_use_auto_resolve = true
	_auto_resolve_args = args
	
	return self


## Enables auto-reject for any new `catch()` callbacks
func auto_reject(args: Array = []) -> Promise:
	_use_auto_reject = true
	_auto_reject_args = args
	
	return self


## Registers a callback to be called on resolve
func then(method: Callable) -> Promise:
	_resolved_methods.append(method)

	if _use_auto_resolve:
		method.callv(_auto_resolve_args)

	return self


## Registers a callback to be called on reject
func catch(method: Callable) -> Promise:
	_rejected_methods.append(method)

	if _use_auto_reject:
		method.callv(_auto_reject_args)

	return self


## Clears all registered callbacks and auto-resolve/reject state
func clear() -> void:
	_resolved_methods.clear()
	_rejected_methods.clear()

	_auto_resolve_args.clear()
	_auto_reject_args.clear()

	_use_auto_resolve = false
	_use_auto_reject = false


## Sets the object refernce
func set_object_refernce(p_object_refernce: Object) -> void:
	_object_refernce = p_object_refernce


## Gets the object refernce
func get_object_refernce() -> Object:
	return _object_refernce


## Gets the UNIX timestamp this Promise was created at 
func get_created_time() -> float:
	return _created_at
