# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name Utils extends Object
## Usefull function that would be annoying to write out each time


static func save_json_to_file(file_path: String, file_name: String, json: Dictionary) -> Error:
	
	if not DirAccess.dir_exists_absolute(file_path):
		print("The folder \"" + file_path + "\" does not exist, creating one now, errcode: ", DirAccess.make_dir_absolute(file_path))

	var file_access: FileAccess = FileAccess.open(file_path+"/"+file_name, FileAccess.WRITE)
	
	print(file_path+"/"+file_name)

	if FileAccess.get_open_error():
		return FileAccess.get_open_error()
		
	
	print(JSON.stringify(json, "\t"))
	file_access.store_string(JSON.stringify(json, "\t"))
	file_access.close()
	
	return file_access.get_error()


static func objects_to_uuids(data):
	## Checks if there are any Objects in the data passed, also checks inside of arrays and dictionarys. If any are found, they are replaced with there uuid, if no uuid if found, it will be null instead 
	match typeof(data):
		TYPE_OBJECT:
			return {
					"_object_ref": str(data.get("uuid")),
					#"_serialized_object": data.serialize(),
					"_class_name": data.get("class_name")
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
	
	return data




static func uuids_to_objects(data: Variant, networked_objects: Dictionary, callback: Callable = Callable()):
	## Checks if there are any uuids in the data passed, also checks inside of arrays and dictionarys. 
	## If any are found, they are replaced with there object refenrce, if no object refernce is found, it will seralised from the file passed
	## If a callback is provided it will be called with the uuid and object.
	match typeof(data):
		TYPE_DICTIONARY:
			if "_object_ref" in data.keys():
				if data._object_ref in networked_objects.keys():
					return networked_objects[data._object_ref].get("object", null)
					
				elif "_class_name" in data.keys():
					if data["_class_name"] in ClassList.global_class_table:
						var initialized_object = ClassList.global_class_table[data["_class_name"]].new(data._object_ref)
						
						if initialized_object.has_method("load") and "_serialized_object" in data.keys():
							initialized_object.load.call_deferred(data._serialized_object)
						
						return initialized_object
				else:
					return null
				
			else:
				var new_dict = {}
				for key in data.keys():
					new_dict[key] = uuids_to_objects(data[key], networked_objects, callback)
				return new_dict
		TYPE_ARRAY:
			var new_array = []
			for item in data:
				new_array.append(uuids_to_objects(item, networked_objects, callback))
			return new_array
	
	return data



static func serialize_variant(variant: Variant) -> Variant:
	
	return var_to_str(variant)


static func deserialize_variant(variant: Variant) -> Variant:
	return str_to_var(variant)
	#match typeof(variant):
		#TYPE_STRING:
			#match variant[0]:
				#"#":
					#print(variant.right(8))
					#return Color.from_string(variant.right(8), Color.BLACK)
	#
	#return ERR_INVALID_DATA


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

