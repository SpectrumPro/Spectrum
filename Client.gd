# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends Node
## Client side network control

var _networked_objects: Dictionary = {} ## Contains a list of networked objects, stores their functions and data types of there args
var _callbacks: Dictionary = {} ## Contains a list of callbacks, stored as callback id:callable

var _networked_objects_delete_callbacks: Dictionary = {}

func _ready() -> void:
	MainSocketClient.connected_to_server.connect(func(): print("connected"))
	MainSocketClient.message_received.connect(self._on_message_receved)
	MainSocketClient.connect_to_url("ws://127.0.0.1:3824")


## Send a message to the server, all data passed is automatically converted to strings, and serialised
func send(data: Dictionary, callback: Callable = Callable()) -> void:
	if callback.is_valid():
		var callback_id = UUID_Util.v4()
		_callbacks[callback_id] = callback
		data.callback_id = callback_id
		
	MainSocketClient.send(var_to_str(Utils.objects_to_uuids(data)))


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
	print("Removing Networked Object: ", object_name)
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
			
			# Loop through all the args passed from the server, and check the type of them against the function in the networked object
			if "args" in command:
				for index in len(command.args):
					# Check if the server has passed too many args to the client, if so stop now to avoid a crash
					if index >= len(method.args.values()):
						print("Total arguments provided by server: ", len(command.args), " Is more then: ", command.signal, " Is expecting, at: ", len(method.args))
						return
					
					# Check if the type of the arg passed by the sever matches the arg expected by the function, if not stop now to avoid a crash, ignore if the expected type is null, as this could also be Variant
					if not typeof(command.args[index]) == method.args.values()[index] and not method.args.values()[index] == 0:
						print("Type of data: ", command.args[index],  " does not match type: ", type_string(method.args.values()[index]), " required by: ", method.callable)
						return
			
			# If all check above pass, call the function and pass the arguments
			print("Calling Methord: ", networked_object.object.get(command.signal))
			(networked_object.object.get(command.signal) as Callable).callv(command.get("args", []))
	
	# Check if it has "callback_id"
	if "callback_id" in message:
		
		# Check if the callback_id in regestered in _callbacks
		if message.get("callback_id", "") in _callbacks:
			var command: Dictionary = Utils.uuids_to_objects(message, _networked_objects)
			print("Calling Methord: ", _callbacks[command.callback_id])
			if command.get("response"):
				_callbacks[command.callback_id].call(command.response)
			else:
				_callbacks[command.callback_id].call()
			
			_callbacks.erase(command.callback_id)
