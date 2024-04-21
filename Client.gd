# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends Node
## Client side network control


var _networked_objects: Dictionary = {}


func _ready() -> void:
	MainSocketClient.connected_to_server.connect(func(): print("connected"))
	MainSocketClient.message_received.connect(self._on_message_receved)
	MainSocketClient.connect_to_url("ws://127.0.0.1:3824")


func send(data: Dictionary) -> void:
	MainSocketClient.send(var_to_str(Utils.objects_to_uuids(data)))


func add_networked_object(object_name: String, object: Object) -> void:
	var new_networked_config: Dictionary = {
		"object": object,
		"functions": {},
	}

	var method_list: Array = object.get_script().get_script_method_list()

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
	
	print(_networked_objects)

func remove_networked_object(name: String) -> void:
	_networked_objects.erase(name)


func _on_message_receved(message: Variant) -> void:
	
	message = str_to_var(message)
	if not message is Dictionary:
		return
	
	var command: Dictionary = Utils.uuids_to_objects(message, _networked_objects)
	
	if "signal" in command and command.get("for") in _networked_objects:
		var networked_object: Dictionary = _networked_objects[message.for]
		
		if networked_object.object.has_method(command.signal):
			
			var method: Dictionary = networked_object.functions[command.signal]
			
			if "args" in command:
				for index in len(command.args):
					if not typeof(command.args[index]) == method.args.values()[index]:
						print("Type of data: ", command.args[index],  " does not match type: ", type_string(method.args.values()[index]), " required by: ", method.callable)
						return
			
			(networked_object.object.get(command.signal) as Callable).callv(command.get("args", []))

