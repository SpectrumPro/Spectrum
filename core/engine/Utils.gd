# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name Utils extends Object
## Usefull function that would be annoying to write out each time

static func save_json_to_file(file_path: String, file_name: String, json: Dictionary) -> Error:
	
	var file_access: FileAccess = FileAccess.open(file_path+"/"+file_name, FileAccess.WRITE)
	
	if FileAccess.get_open_error():
		return FileAccess.get_open_error()
	
	print(JSON.stringify(json, "\t"))
	file_access.store_string(JSON.stringify(json, "\t"))
	file_access.close()
	
	return file_access.get_error()
	
