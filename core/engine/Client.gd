# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name CoreClient extends Node
## Client side network control


## Emitted when we connect to the server
signal connected_to_server()

## Emitted when the connection closes
signal connection_closed()


## Default server ip address
var ip_address: String = "127.0.0.1"

## Default server port
var websocket_port: int = 3824

## Default server udp port
var udp_port: int = 3823

## Contains a list of networked objects, stores their functions and data types of there args
var _networked_objects: Dictionary = {}

## Contains a list of callbacks, stored as callback id:callable
var _callbacks: Dictionary = {}

## All the objects that have been networked
var _networked_objects_delete_callbacks: Dictionary = {}

## Is this server expecting a disconnect
var _is_expecting_disconnect: bool = false


func _ready() -> void:
	MainSocketClient.message_received.connect(self._on_message_receved)
	MainUDPSocketClient.packet_recieved.connect(self._on_udp_message_receved)
	
	MainSocketClient.connected_to_server.connect(func (): 
		connected_to_server.emit()
		_is_expecting_disconnect = false
	)
	
	MainSocketClient.connection_closed.connect(func (): 
		connection_closed.emit()
		(func (): _is_expecting_disconnect = true).call_deferred()
	)


## Starts the server on the given port, 
func connect_to_server(p_ip: String = ip_address, p_websocket_port: int = websocket_port, p_udp_port: int = udp_port):
	print("Connecting to websocket server")

	var err = MainSocketClient.connect_to_url("ws://" + p_ip + ":" + str(p_websocket_port))
	if err != OK:
		print("Error connecting to websocket server | errorcode: ", error_string(err))
		return
	
	print("Websocket connected to: ws://", p_ip, ":", p_websocket_port)

	print()

	print("Connecting to UDP server")

	err = MainUDPSocketClient.connect_to_host(p_ip, p_udp_port)
	if err != OK:
		print("Error connecting to UDP server | errorcode: ", error_string(err))
		return
	
	print("UDP client connected to: ", p_ip, ":", p_udp_port)
	
	print()


## Disconnects from the server
func disconnect_from_server() -> void:
	
	print("Removing all networked objects")
	for object_name: String in _networked_objects.keys():
		remove_networked_object(object_name)
	
	_callbacks = {}
	
	print("Disconnecting WebSocket peer")
	MainSocketClient.close()
	
	print("Disconnecting UDP peer")
	MainUDPSocketClient.close()


## Checks if this client is expecting a disconnect from the server
func is_expecting_disconnect() -> bool:
	return _is_expecting_disconnect


## Checks if this client is connected to a server
func is_connected_to_server() -> bool:
	return MainSocketClient.last_state == WebSocketPeer.STATE_OPEN


## Send a message to the server, all data passed is automatically converted to strings, and serialised
func send(data: Dictionary) -> void:
	MainSocketClient.send(var_to_str(Utils.objects_to_uuids(data)))


## Sends a command to the server
func send_command(object_id: String, method: String, args: Array = []) -> Promise:
	var data: Dictionary = {
		"for": object_id,
		"call": method,
		"args": args
	}

	var promise: Promise = Promise.new()
	var callback_id = UUID_Util.v4()

	_callbacks[callback_id] = promise
	data.callback_id = callback_id

	Client.send(data)
	return promise


## Add a network object
func add_networked_object(object_name: String, object: Object, delete_signal: Signal = Signal()) -> void:
	
	if object_name in _networked_objects.keys():
		return
	
	var new_networked_config: Dictionary = {
		"object": object,
		"functions": {},
	}
	
	var method_list: Array = object.get_script().get_script_method_list()
	
	if not delete_signal.is_null():
		delete_signal.connect(func ():
			remove_networked_object(object_name)
		, CONNECT_ONE_SHOT)
	
	# Loop through each function on the object that is being added, and create a dictionary containing the avaibal function, and their args
	for index: int in range(len(method_list)):
		
		# If the method name starts with an "_", discard it, as this meanes its an internal method that should not be called by the client
		if method_list[index].name.begins_with("_"):
			continue 
	
		var method: Dictionary = {
			"callable":object.get(method_list[index].name),
			"args":{}
		}
		
		# Loop through all the args in this method, and note down there name and type
		for arg: Dictionary in method_list[index].args:
			method.args[arg.name] = arg.type
		
		new_networked_config.functions[method_list[index].name] = method
	
	_networked_objects[object_name] = new_networked_config 


## Remove a network object
func remove_networked_object(object_name: String) -> void:
	print("Removing Networked Object: ", object_name)
	#if _networked_objects_delete_callbacks.has(object_name):
		#(_networked_objects_delete_callbacks[object_name].signal as Signal).disconnect(_networked_objects_delete_callbacks[object_name].callable)
		#_networked_objects_delete_callbacks.erase(object_name)
		
	_networked_objects.erase(object_name)


## Called when a message is receved from the server 
func _on_message_receved(message: Variant) -> void:
	# Check to make sure the message passed is a Dictionary
	message = str_to_var(message)
	if not message is Dictionary:
		return

	var command: Dictionary = Utils.uuids_to_objects(message, _networked_objects)
	
	# Convert all seralized objects to objects refs
	
	# If command has the "signal" value, check if its a valid function in the network object specifyed in the command.for value
	if "signal" in message and message.get("for") in _networked_objects:
		var networked_object: Dictionary = _networked_objects[message.for]
		var network_config: Dictionary = networked_object.object.get("network_config")
		
		# Check if the function still exists, in case it is no longer valid
		if network_config.get("callbacks", {}).has(message.signal):
			var method: Callable = network_config.callbacks[message.signal]
			method.callv(command.get("args", []))
		else:
			print("You broke it!")
	
	
	# Check if it has "callback_id"
	if "callback_id" in message:
		
		# Check if the callback_id in regestered in _callbacks
		if message.callback_id in _callbacks:
			print_verbose("Calling Method Callback: ", _callbacks[command.callback_id])
			
			if command.has("response"):
				_callbacks[command.callback_id].resolve([command.response])
			
			else:
				_callbacks[command.callback_id].resolve([])
			
			_callbacks.erase(command.callback_id)


## Called when high frequency UDP message is recieved
func _on_udp_message_receved(message: Variant) -> void:
	if not message is Dictionary:
		return
	
	for object_array: Variant in message.keys():
		if object_array is Array and len(object_array) == 2:
			var networked_object: Dictionary = _networked_objects.get(object_array[0], {})
			var network_config: Dictionary = networked_object.object.get("network_config")
			
			# Check if the function still exists, in case it is no longer valid
			if network_config.get("callbacks", {}).has(object_array[1]):
				var method: Callable = network_config.callbacks[object_array[1]]
				method.callv(message[object_array])
			else:
				print("You broke it!")


## Function to call a method, checks all method types befour calling
func _call_method(networked_object: Dictionary, method_name: String, method_dict: Dictionary, args: Array = []):
	# Loop through all the args passed from the server, and check the type of them against the function in the networked object
	for index in len(args):
		# Check if the server has passed too many args to the client, if so stop now to avoid a crash
		if index >= len(method_dict.args.values()):
			print("Total arguments provided by server: ", len(args), " Is more then: ", method_name, " Is expecting, at: ", len(method_dict.args))
			return
		
		# Check if the type of the arg passed by the sever matches the arg expected by the function, if not stop now to avoid a crash, ignore if the expected type is null, as this could also be Variant
		if not typeof(args[index]) == method_dict.args.values()[index] and not method_dict.args.values()[index] == 0:
			print("Type of data: ", args[index],  " does not match type: ", type_string(method_dict.args.values()[index]), " required by: ", method_dict.callable, " Got: ", typeof(type_string(args[index])))
			return
	
	# If all check above pass, call the function and pass the arguments
	print_verbose("Calling Method: ", networked_object.object.get(method_name))
	(networked_object.object.get(method_name) as Callable).callv(args)
