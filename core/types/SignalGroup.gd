# Copyright (c) 2025 Liam Sherwin, All rights reserved.

class_name SignalGroup extends Object
## Utility class to bulk connect and disconnect signals from an object.
## Supports automatic and manually defined connections, with optional binding.


## Automatically discovered signal handler methods (e.g., `on_event`)
var _auto_detect: Array[Callable]

## Manually specified signal-to-callable mappings
var _manual_defs: Dictionary[String, Callable]

## Callables to never bind
var _no_bind: Array[Callable]

## Method name prefix used for auto-detect (default: "on_")
var _callable_prefix: String = "_on_"

## Tracks all bound signal connections for disconnection
## Format:
## {
##     Object: {
##         Signal: {
##             "methodname + object_id": Callable (bound)
##         }
##     }
## }
var _signal_connections: Dictionary = {}


## Constructor
func _init(p_auto_detect: Array[Callable] = [], p_manual_defs: Dictionary[String, Callable] = {}) -> void:
	_auto_detect = p_auto_detect
	_manual_defs = p_manual_defs


## Sets the callable prefix, Only run this once after init
func set_prefix(p_prefix: String) -> SignalGroup:
	_callable_prefix = p_prefix
	
	return self


## Gets the callable prefix
func get_prefix() -> String:
	return _callable_prefix


## Sets the callables to never bind
func no_bind(p_callables: Array[Callable]) -> SignalGroup:
	for callable: Callable in p_callables:
		if callable not in _auto_detect:
			_auto_detect.append(callable)
		
		_no_bind.append(callable)
	
	return self


## Connects all signals on the target object
## If `p_use_bind` is true, the object is bound to each callable
func connect_object(p_object: Object, p_use_bind: bool = false) -> void:
	set_signals_connected(p_object, true, p_use_bind)


## Disconnects all signals from the target object
func disconnect_object(p_object: Object, p_use_bind: bool = false) -> void:
	set_signals_connected(p_object, false, p_use_bind)


## Internal method to (dis)connect all signals based on current mode
func set_signals_connected(p_object: Object, p_connect: bool, p_use_bind: bool = false) -> void:
	if not is_instance_valid(p_object):
		return

	# Handle auto-detected callables
	for callable: Callable in _auto_detect:
		var signal_name: String = callable.get_method().replace(_callable_prefix, "")
		
		if p_object.has_signal(signal_name):
			var p_signal: Signal = p_object.get(signal_name)
			
			if p_use_bind and callable not in _no_bind:
				_set_bound_signal_connected(p_object, p_signal, callable, p_connect)
			else:
				_set_signal_connected(p_signal, callable, p_connect)

	# Handle manually defined callables
	for signal_name: String in _manual_defs:
		var callable: Callable = _manual_defs[signal_name]
		
		if p_object.has_signal(signal_name):
			var p_signal: Signal = p_object.get(signal_name)
			
			if p_use_bind and callable not in _no_bind:
				_set_bound_signal_connected(p_object, p_signal, callable, p_connect)
			else:
				_set_signal_connected(p_signal, callable, p_connect)


## Connects or disconnects an unbound callable to/from a signal
func _set_signal_connected(p_signal: Signal, p_callable: Callable, p_connect: bool) -> void:
	if p_connect:
		p_signal.connect(p_callable)
	else:
		p_signal.disconnect(p_callable)


## Connects or disconnects a bound callable (object-bound context)
## Handles internal tracking and cleanup of stored connections
func _set_bound_signal_connected(p_object: Object, p_signal: Signal, p_callable: Callable, p_connect: bool) -> void:
	var object_conns: Dictionary = _signal_connections.get_or_add(p_object, {})
	var signal_conns: Dictionary = object_conns.get_or_add(p_signal, {})
	var callable_key: String = _make_bound_key(p_callable)
	
	if p_connect:
		var bound_callable: Callable = p_callable.bind(p_object)
		p_signal.connect(bound_callable)
		signal_conns[callable_key] = bound_callable
	else:
		if signal_conns.has(callable_key):
			var bound_callable: Callable = signal_conns[callable_key]
			p_signal.disconnect(bound_callable)
			signal_conns.erase(callable_key)
			
			# Cleanup empty dictionaries
			if signal_conns.is_empty():
				object_conns.erase(p_signal)
			if object_conns.is_empty():
				_signal_connections.erase(p_object)


## Generates a unique key for a bound callable
func _make_bound_key(callable: Callable) -> String:
	return callable.get_method() + str(callable.get_object_id())
