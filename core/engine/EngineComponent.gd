# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name EngineComponent extends Object
## Base class for an engine components, contains functions for storing metadata, and uuid's

var uuid: String = "" ## Uuid of the current component
var user_meta: Dictionary ## Infomation that can be stored by other scripts

func _init() -> void:
	uuid = UUID_Util.v4()


func set_user_meta(key: String, value: Variant):
	## Sets user_meta from the given value
	
	user_meta[key] = value


func get_user_meta(key: String, default=null) -> Variant: 
	## Returns user_meta from the given key, if the key is not found, default is returned
	
	return user_meta.get(key, default)


func delete_user_meta(key: String) -> bool:
	## Delets an item from user-meta, returning true if item was found and deleted, and false if not
	
	return user_meta.erase(key)


func serialize() -> Dictionary:
	## When this object gets serialize all user metadata that is an Object, will be checked for a uuid propity.
	## If one is present it will be used as the serialized version of that object. If none is present, it will be ignored. 
	## Other user_meta that is not an object will be directly added to the serialized data.
	
	return {
		"uuid":uuid,
		"user_meta":serialize_meta()
	}


func serialize_meta() -> Dictionary:
	## Returnes serialized user_meta
	
	var serialized_user_meta: Dictionary
	
	for key: String in user_meta:
		if user_meta[key] is Object and "uuid" in user_meta[key]:
			serialized_user_meta[key] = user_meta[key].uuid
		else:
				serialized_user_meta[key] = user_meta[key]
	
	return serialized_user_meta
