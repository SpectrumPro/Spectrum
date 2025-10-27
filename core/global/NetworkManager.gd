# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name NetworkManager extends Node
## Controls the Spectrum Network System


## Emitted when a command is recieved
signal command_recieved(p_from: NetworkNode, p_type: Variant.Type, p_command: Variant)


## Enum for MessageType
enum MessageType {
	NONE		= 0, ## Unknown message
	COMMAND		= 1, ## Command message
	SIGNAL		= 2, ## Signal message
	RESPONCE	= 3, ## Command responce messgae1
}


## All available NetworkHandlers that can be loaded
var _available_handlers: Dictionary[String, Script] = {
	"Constellation": Constellation
}

## All NetworkHandlers currently loaded in the engine
var _active_handlers: Dictionary[String, NetworkHandler]

## Dict containg all NetworkItems sorted by classname
var _registered_items: Dictionary[String, Array]

## Contains all network objects, RefMap for "id": SettingsManager
var _registered_network_objects: RefMap = RefMap.new()

## Stores all lamba functions that are connected to an objects signals for each SettingsManager
var _networked_objects_signal_connections: Dictionary[SettingsManager, Dictionary]

## Contains all Promises awaiting a responce from the network
var _awaiting_responces: Dictionary[String, Promise]

## The SettingsManager for NetworkManager
var settings_manager: SettingsManager = SettingsManager.new()


## Init
func _init() -> void:
	settings_manager.set_owner(self)
	settings_manager.set_inheritance_array(["NetworkManager"])
	settings_manager.register_control("StartAll", Data.Type.NULL, start_all, Callable(), [])
	settings_manager.register_control("StopAll", Data.Type.NULL, stop_all, Callable(), [])


## Ready
func _ready() -> void:
	for handler_name: String in _available_handlers:
		var new_handler: NetworkHandler = _available_handlers[handler_name].new()
		
		new_handler.node_found.connect(_register_item)
		new_handler.session_created.connect(_register_item)
		new_handler.command_recieved.connect(_on_command_recieved)
		
		_register_item(new_handler)
		add_child(new_handler)
		
		_active_handlers[handler_name] = new_handler


## Starts all the NetworkHandlers
func start_all() -> void:
	for handler: NetworkHandler in _active_handlers.values():
		handler.start_node()


## Stop all the NetworkHandlers
func stop_all() -> void:
	for handler: NetworkHandler in _active_handlers.values():
		handler.stop_node()


## Sends a message to the session, using p_node_filter as the NodeFilter
func send_message(p_command: Variant, p_node_filter: NetworkSession.NodeFilter = NetworkSession.NodeFilter.AUTO) -> Error:
	return _active_handlers["Constellation"].send_command(p_command, p_node_filter)


## Sends a MessageType.COMMAND to the network
func send_command(p_for: String, p_call: String, p_args: Array, p_node_filter: NetworkSession.NodeFilter = NetworkSession.NodeFilter.AUTO) -> Promise:
	var msg_id: String = UUID_Util.v4()
	var promise: Promise = Promise.new()
	var message: Dictionary = {
		"type": MessageType.COMMAND,
		"msg_id": msg_id,
		"for": p_for,
		"call": p_call,
		"args": var_to_str(Utils.objects_to_uuids(p_args))
	}
	
	if send_message(message, p_node_filter):
		return promise.auto_reject()
	
	_awaiting_responces[msg_id] = promise
	return promise


## Sends a MessageType.SIGNAL
func send_signal(p_from: String, p_signal: String, p_args: Array = [], p_node_filter: NetworkSession.NodeFilter = NetworkSession.NodeFilter.AUTO) -> Error:
	return send_message({
		"type": MessageType.SIGNAL,
		"for": p_from,
		"call": p_signal,
		"args": p_args, 
	})


## Sends a MessageType.RESPONCE
func send_responce(p_id: String, p_args: Array = [], p_node_filter: NetworkSession.NodeFilter = NetworkSession.NodeFilter.AUTO) -> Error:
	return send_message({
		"type": MessageType.RESPONCE,
		"msg_id": p_id,
		"args": p_args, 
	})


## Rgegisters a network object
func register_network_object(p_id: String, p_settings_manager: SettingsManager) -> void:
	if _registered_network_objects.has_left(p_id) or not is_instance_valid(p_settings_manager):
		return;
	
	for p_signal_name: String in p_settings_manager.get_networked_signals():
		var p_signal: Signal = p_settings_manager.get_networked_signal(p_signal_name)
		var method: Callable = func (...args) -> void: send_signal(p_id, p_signal_name, args)
		p_signal.connect(method)
		
		_networked_objects_signal_connections.get_or_add(p_settings_manager)[p_signal] = method
	
	p_settings_manager.get_delete_signal().connect(deregister_network_object.bind(p_settings_manager), CONNECT_ONE_SHOT)
	_registered_network_objects.map(p_id, p_settings_manager)


## Deregister a network object
func deregister_network_object(p_settings_manager: SettingsManager) -> void:
	if not _registered_network_objects.has_right(p_settings_manager):
		return
	
	for p_signal: Signal in _networked_objects_signal_connections.get(p_settings_manager):
		p_signal.disconnect(_networked_objects_signal_connections[p_settings_manager][p_signal])
	
	_registered_network_objects.erase_right(p_settings_manager)


## Gets an active handler by its class name
func get_active_handler_by_name(p_classname: String) -> NetworkHandler:
	return _active_handlers.get(p_classname, null)


## Returns all active NetworkHandlers
func get_all_active_handlers() -> Dictionary[String, NetworkHandler]:
	return _active_handlers.duplicate()


## Gets all the NetworkItems by classname
func get_items_by_classname(p_classname: String) -> Array:
	return _registered_items.get(p_classname, [])


## Register an item
func _register_item(p_item: NetworkItem) -> void:
	for classname: String in NetworkClassList.get_class_inheritance_tree(p_item.get_script().get_global_name()):
		_registered_items.get_or_add(classname, []).append(p_item)
	
	p_item.request_delete.connect(_deregister_item.bind(p_item))


## Deregister an item
func _deregister_item(p_item: NetworkItem) -> void:
	for classname: String in NetworkClassList.get_class_inheritance_tree(p_item.get_script().get_global_name()):
		_registered_items.get(classname, []).erase(p_item)


## Emitted when a command is recieved
func _on_command_recieved(p_from: NetworkNode, p_type: Variant.Type, p_command: Variant, ) -> void:
	if p_command is Dictionary:
		var object_id: String = type_convert(p_command.get("for", ""), TYPE_STRING)
		var for_method: String = type_convert(p_command.get("call", ""), TYPE_STRING)
		var args: Array = str_to_var(type_convert(p_command.get("args", "[]"), TYPE_STRING))
		var msg_id: String = type_convert(p_command.get("msg_id", ""), TYPE_STRING)
		
		match p_command.get("type", 0):
			MessageType.COMMAND:
				if _registered_network_objects.has_left(object_id):
					var result: Variant = (_registered_network_objects.left(object_id) as SettingsManager).get_networked_method(for_method).callv(args)
					send_responce(msg_id, [result])
				
			MessageType.SIGNAL:
				if _registered_network_objects.has_left(object_id):
					(_registered_network_objects.left(object_id) as SettingsManager).get_networked_callback(for_method).callv(args)
				
			MessageType.RESPONCE:
				if _awaiting_responces.has(msg_id):
					_awaiting_responces[msg_id].resolve(args)
					_awaiting_responces.erase(msg_id)
	
	print("Got command: ", p_command, " from: ", p_from.get_node_name())
	command_recieved.emit(p_from, p_type, p_command)
