# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

extends Node
## Client side network control

## Contains a list of networked objects, stores their functions and data types of there args
var _networked_objects: Dictionary = {}

## Contains a list of callbacks, stored as callback id:callable
var _callbacks: Dictionary = {}

## All the objects that have been networked
var _networked_objects_delete_callbacks: Dictionary = {}

func _ready() -> void:
	MainSocketClient.message_received.connect(self._on_message_receved)
	MainUDPSocketClient.packet_recieved.connect(self._on_udp_message_receved)


## Starts the server on the given port, 
func connect_to_server(ip: String, websocket_port: int, udp_port: int):
	print("Connecting to websocket server")

	var err = MainSocketClient.connect_to_url("ws://" + ip + ":" + str(websocket_port))
	if err != OK:
		print("Error connecting to websocket server | errorcode: ", error_string(err))
		return
	
	print("Websocket connected to: ws://", ip, ":", websocket_port)

	print()

	print("Connecting to UDP server")

	err = MainUDPSocketClient.connect_to_host(ip, udp_port)
	if err != OK:
		print("Error connecting to UDP server | errorcode: ", error_string(err))
		return
	
	print("UDP client connected to: ", ip, ":", udp_port)
	
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



## Send a message to the server, all data passed is automatically converted to strings, and serialised
func send(data: Dictionary, callback: Callable = Callable()) -> void:
	if callback.is_valid():
		var callback_id = UUID_Util.v4()
		_callbacks[callback_id] = callback
		data.callback_id = callback_id
	
	MainSocketClient.send(var_to_str(Utils.objects_to_uuids(data)))


## Sends a command to the server
func send_command(object_id: String, method: String, args: Array = []) -> void:
	Client.send({
		"for": object_id,
		"call": method,
		"args": args
	})


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
		_networked_objects_delete_callbacks[object_name] = {
			"callable":remove_networked_object.bind(object_name),
			"signal":delete_signal
			}
		 
		delete_signal.connect(_networked_objects_delete_callbacks[object_name].callable)
	
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
	print_verbose("Removing Networked Object: ", object_name)
	if _networked_objects_delete_callbacks.has(object_name):
		(_networked_objects_delete_callbacks[object_name].signal as Signal).disconnect(_networked_objects_delete_callbacks[object_name].callable)
		_networked_objects_delete_callbacks.erase(object_name)
		
	_networked_objects.erase(object_name)


## Called when a message is receved from the server 
func _on_message_receved(message: Variant) -> void:
	# Check to make sure the message passed is a Dictionary
	message = str_to_var(message)
	if not message is Dictionary:
		return
	
	# Convert all seralized objects to objects refs
	
	# If command has the "signal" value, check if its a valid function in the network object specifyed in the command.for value
	if "signal" in message and message.get("for") in _networked_objects:
		var networked_object: Dictionary = _networked_objects[message.for]
		
		# Check if the function still exists, in case it is no longer valid
		if networked_object.object.has_method(message.signal):
			var command: Dictionary = Utils.uuids_to_objects(message, _networked_objects)
			var method: Dictionary = networked_object.functions[command.signal]
			
			_call_method(networked_object, command.signal, method, command.get("args", []))
	
	# Check if it has "callback_id"
	if "callback_id" in message:
		
		# Check if the callback_id in regestered in _callbacks
		if message.get("callback_id", "") in _callbacks:
			var command: Dictionary = Utils.uuids_to_objects(message, _networked_objects)
			print_verbose("Calling Methord: ", _callbacks[command.callback_id])
			if not command.get("response") == null:
				_callbacks[command.callback_id].call(command.response)
			else:
				_callbacks[command.callback_id].call()
			
			_callbacks.erase(command.callback_id)


func _on_udp_message_receved(message: Variant) -> void:
	if not message is Dictionary:
		return
	
	for object_array: Variant in message.keys():
		if object_array is Array and len(object_array) == 2:
			var networked_object: Dictionary = _networked_objects.get(object_array[0], {})
			
			if networked_object and object_array[1] in networked_object.functions:
				_call_method(networked_object, object_array[1], networked_object.functions[object_array[1]], message[object_array])
			


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
