# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name EngineComponent extends RefCounted
## Base class for an engine components, contains functions for storing metadata, and uuid's

signal on_user_meta_changed(key: String, value: Variant, user_meta: Dictionary) ## Emitted when an item is added, edited, or deleted from user_meta, if no value is present it meanes that the key has been deleted
signal on_name_changed(new_name: String) ## Emitted when the name of this object has changed
signal on_delete_requested() ## Emited when this object is about to be deleted

var name: String = "Unnamed EngineComponent": set = set_name ## The name of this object
var user_meta: Dictionary ## Infomation that can be stored by other scripts / clients, this data will get saved to disk and send to all clients
var uuid: String = "" ## Uuid of the current component, do not modify at runtime unless you know what you are doing, things will break


func _init(p_uuid: String = UUID_Util.v4()) -> void:
	uuid = p_uuid
	print("I am: ", uuid)


## Sets user_meta from the given value
func set_user_meta(key: String, value: Variant, no_signal: bool = false):
	
	user_meta[key] = value
	
	if not no_signal:
		on_user_meta_changed.emit(key, value, user_meta)


## Returns the value from user meta at the given key, if the key is not found, default is returned
func get_user_meta(key: String, default = null) -> Variant: 
	
	return user_meta.get(key, default)


## Returns all user meta
func get_all_user_meta() -> Dictionary:
	
	return user_meta


## Delets an item from user meta, returning true if item was found and deleted, and false if not
func delete_user_meta(key: String, no_signal: bool = false) -> bool:
	
	if not no_signal:
		on_user_meta_changed.emit(key, null, user_meta)

	
	return user_meta.erase(key)


## Sets the name of this component
func set_name(new_name) -> void:
	name = new_name
	on_name_changed.emit(name)


## Returns serialized version of this component
func serialize() -> Dictionary:
	
	var serialized_data: Dictionary = {}
	serialized_data = _on_serialize_request()
	
	serialized_data.uuid = uuid
	serialized_data.name = name
	serialized_data.meta = get_all_user_meta()
	
	return serialized_data


## Overide this function to serialize your object
func _on_serialize_request() -> Dictionary:
	return {}


## Always call this function when you want to delete this component. 
## As godot uses reference counting, this object will not truly be deleted untill no other script holds a refernce to it.
func delete() -> void:
	_on_delete_request()
	
	on_delete_requested.emit()
	
	print(uuid, " Has had a delete request send. Currently has:", str(get_reference_count()), " refernces")


## Overide this function to handle delete requests
func _on_delete_request() -> void:
	return


## Loades this object from a serialized version
func load(serialized_data: Dictionary) -> void:
	name = serialized_data.get("name", "Unnamed EngineComponent")
	uuid = serialized_data.get("uuid", UUID_Util.v4())
	user_meta = serialized_data.get("user_meta", {})
	
	if not "uuid" in serialized_data:
		print(name, " No uuid found in serialized_data, making new one: ", uuid)
	
	on_load_request(serialized_data)


## Overide this function to handle load requests
func on_load_request(serialized_data: Dictionary) -> void:
	pass


## Debug function to tell if this component is freed from memory
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		print("\"", self.name, "\" Is being freed, uuid: ", self.uuid)
