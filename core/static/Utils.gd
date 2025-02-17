# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name Utils extends Object
## Usefull function that would be annoying to write out each time


## Contains all the bound signal connections from connect_signals_with_bind()
##	{
##		Object: {
##			Signal: {
##				"CallableName + Callable.get_object_id()": Callable
##			}
##		}
##	}
static var _signal_connections: Dictionary


## Custom Types:
const TYPE_STRING := "STRING"
const TYPE_IP := "IP"
const TYPE_BOOL := "BOOL"
const TYPE_INT := "INT"
const TYPE_NULL := "NULL"
const TYPE_CUSTOM := "CUSTOM"


## Saves a JSON valid dictonary to a file, creates the file and folder if it does not exist
static func save_json_to_file(file_path: String, file_name: String, json: Dictionary) -> Error:
	
	if not DirAccess.dir_exists_absolute(file_path):
		print("The folder \"" + file_path + "\" does not exist, creating one now, errcode: ", DirAccess.make_dir_absolute(file_path))

	var file_access: FileAccess = FileAccess.open(file_path+"/"+file_name, FileAccess.WRITE)
	
	if FileAccess.get_open_error():
		return FileAccess.get_open_error()
	
	file_access.store_string(JSON.stringify(json, "\t"))
	file_access.close()
	
	return file_access.get_error()


## Replaces any object in the given data with uuid refernces. Checks sub arrays and dictionarys
static func objects_to_uuids(data: Variant) -> Variant:
	match typeof(data):
		TYPE_OBJECT:
			return {
					"_object_ref": str(data.get("uuid")),
					#"_serialized_object": data.serialize(),
					"_class_name": data.get("self_class_name")
				}
		
		TYPE_DICTIONARY:
			var new_dict = {}
			for key in data.keys():
				new_dict[key] = objects_to_uuids(data[key])
			return new_dict
		
		TYPE_ARRAY:
			var new_array = []
			for item in data:
				new_array.append(objects_to_uuids(item))
			return new_array
		
		TYPE_COLOR:
			return var_to_str(data)
	
	return data


## Checks for uuid refernces left by objects_to_uuids(). If one is found the corrisponding object will be created or found via ComponentDB
static func uuids_to_objects(data: Variant, networked_objects: Dictionary):
	match typeof(data):
		TYPE_DICTIONARY:
			if "_object_ref" in data.keys():
				if data._object_ref in networked_objects.keys():
					return networked_objects[data._object_ref].get("object", null)
					
				elif "_class_name" in data.keys():
					if ClassList.has_class(data["_class_name"]):
						var initialized_object = ClassList.get_class_script(data["_class_name"]).new(data._object_ref)
						
						if initialized_object.has_method("load") and "_serialized_object" in data.keys():
							initialized_object.load(data._serialized_object)
							
						return initialized_object
				else:
					return null
				
			else:
				var new_dict = {}
				for key in data.keys():
					new_dict[key] = uuids_to_objects(data[key], networked_objects)
				return new_dict
		
		TYPE_ARRAY:
			var new_array = []
			for item in data:
				new_array.append(uuids_to_objects(item, networked_objects))
			return new_array
		
		TYPE_STRING:
			if data.contains("Color("):
				return str_to_var(data)
	
	return data


## Calculates the HTP value of two colors
static func get_htp_color(color_1: Color, color_2: Color) -> Color:
	# Calculate the intensity of each channel for color1
	var intensity_1_r = color_1.r
	var intensity_1_g = color_1.g
	var intensity_1_b = color_1.b

	# Calculate the intensity of each channel for color2
	var intensity_2_r = color_2.r
	var intensity_2_g = color_2.g
	var intensity_2_b = color_2.b

	# Compare the intensities for each channel and return the color with the higher intensity for each channel
	var result_color = Color()
	result_color.r = intensity_1_r if intensity_1_r > intensity_2_r else intensity_2_r
	result_color.g = intensity_1_g if intensity_1_g > intensity_2_g else intensity_2_g
	result_color.b = intensity_1_b if intensity_1_b > intensity_2_b else intensity_2_b
	
	return result_color


## Gets the most common variant in an array
static func get_most_common_value(arr: Array) -> Variant:
	var count_dict := {}
	
	# Count the occurrences of each value
	for value in arr:
		if value in count_dict:
			count_dict[value] += 1
		else:
			count_dict[value] = 1
	
	# Find the most common value
	var most_common_value = null
	var max_count = 0
	
	for key in count_dict:
		if count_dict[key] > max_count:
			max_count = count_dict[key]
			most_common_value = key
	
	return most_common_value


## Sums all items in an array
static func sum_array(array: Array) -> Variant:
	var sum: Variant = 0
	
	for element: Variant in array:
		sum += element
	
	return sum


## Connects all the callables to the signals in the dictionary. Stored as {"SignalName": Callable}
static func connect_signals(signals: Dictionary, object: Object) -> void:
	if is_instance_valid(object):
		for signal_name: String in signals:
			if object.has_signal(signal_name) and not (object.get(signal_name) as Signal).is_connected(signals[signal_name]):
				(object.get(signal_name) as Signal).connect(signals[signal_name])


## Disconnects all the callables from the signals in the dictionary. Stored as {"SignalName": Callable}
static func disconnect_signals(signals: Dictionary, object: Object) -> void:
	if is_instance_valid(object):
		for signal_name: String in signals:
			if object.has_signal(signal_name) and (object.get(signal_name) as Signal).is_connected(signals[signal_name]):
				(object.get(signal_name) as Signal).disconnect(signals[signal_name])


## Connects all the callables to the signals in the dictionary. Also binds the object to the callable. Stored as {"SignalName": Callable}
static func connect_signals_with_bind(signals: Dictionary, object: Object) -> void:
	_signal_connections.get_or_add(object, {})
	
	for signal_name: String in signals:
		if object.has_signal(signal_name):
			var _signal: Signal = object.get(signal_name)
			var connections: Dictionary = _signal_connections[object].get_or_add(_signal, {})
			var bound_callable: Callable = signals[signal_name].bind(object)
			var callable_name: String = bound_callable.get_method() + str(bound_callable.get_object_id())
			
			_signal.connect(bound_callable)
			connections[callable_name] = bound_callable


## Disconnects all the bound callables from the signals in the dictionary. Stored as {"SignalName": Callable}
static func disconnect_signals_with_bind(signals: Dictionary, object: Object) -> void:
	if not _signal_connections.has(object):
		return
	
	for signal_name: String in signals:
		if object.has_signal(signal_name):
			var _signal: Signal = object.get(signal_name)
			var connections: Dictionary = _signal_connections[object].get_or_add(_signal, {})
			var orignal_callable: Callable = signals[signal_name]
			var callable_name: String = orignal_callable.get_method() + str(orignal_callable.get_object_id())
			var bound_callable: Callable = connections[callable_name]
			
			_signal.disconnect(bound_callable)
			connections.erase(callable_name)
