# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name EngineComponent extends Object
## Base class for an engine components, contains functions for storing metadata, and uuid's

signal user_meta_changed(origin: EngineComponent, key: String, value: Variant) ## Emitted when an item is added, edited, or deleted from user_meta, if no value is present it meanes that the key has been deleted
signal name_changed(new_name: String) ## Emitted when the name of this object has changed
signal selected(is_selected: bool)

var uuid: String = "" ## Uuid of the current component
var name: String = "": set = _set_name ## The name of this object, only use when displaying to users, do not use it as a reference 
var user_meta: Dictionary ## Infomation that can be stored by other scripts

var is_selected: bool = false: set = set_selected


func _init() -> void:
	
	if not uuid:
		uuid = UUID_Util.v4()


func set_selected(state: bool) -> void:
	## Sets the selection state of this component
	
	is_selected = state
	selected.emit(state)


func set_user_meta(key: String, value: Variant, no_signal: bool = false):
	## Sets user_meta from the given value
	
	user_meta[key] = value
	
	if not no_signal:
		user_meta_changed.emit(self, key, value)


func get_user_meta(key: String, default = null) -> Variant: 
	## Returns user_meta from the given key, if the key is not found, default is returned
	
	return user_meta.get(key, default)


func delete_user_meta(key: String, no_signal: bool = false) -> bool:
	## Delets an item from user-meta, returning true if item was found and deleted, and false if not
	
	if not no_signal:
		user_meta_changed.emit(self, key)
	
	return user_meta.erase(key)


func _set_name(new_name) -> void:
	name = new_name


func change_name(new_name: String, no_signal: bool = false) -> void:
	## Changes the name of this object
	name = new_name
	
	if not no_signal:
		name_changed.emit(new_name)


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
	
	var serialized_user_meta: Dictionary = {}
	
	for key: String in user_meta:
		if user_meta[key] is Object and "uuid" in user_meta[key]:
			serialized_user_meta[key] = user_meta[key].uuid
		else:
			serialized_user_meta[key] = user_meta[key]
	
	return serialized_user_meta


func delete() -> void:
	pass
