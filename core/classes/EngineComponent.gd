# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name EngineComponent extends RefCounted
## Base class for an engine components, contains functions for storing metadata, and uuid's


## Emitted when an item is added or edited from user_meta
signal user_meta_changed(key: String, value: Variant)

## Emitted when an item is deleted from user_meta
signal user_meta_deleted(key: String)

## Emitted when the name of this object has changed
signal name_changed(new_name: String)

## Emited when this object is about to be deleted
signal delete_requested()


## The name of this object
var name: String = "Unnamed EngineComponent"

## Infomation that can be stored by other scripts / clients, this data will get saved to disk and send to all clients
var user_meta: Dictionary

## Uuid of the current component, do not modify at runtime unless you know what you are doing, things will break
var uuid: String = ""

## The class_name of this component this should always be set by the object that extends EngineComponent
var self_class_name: String = "EngineComponent" : set = set_self_class

## Stores all the classes this component inherits from
var class_tree: Array[String] = ["EngineComponent"]

## The local icon for this component, used when displaying in th ui
var icon: Texture2D = load("res://assets/icons/Component.svg")

## List of functions that are allowed to be called by external control scripts.
var accessible_methods: Dictionary = {}


func _init(p_uuid: String = UUID_Util.v4(), p_name: String = name) -> void:
	uuid = p_uuid
	name = p_name
	_component_ready()
	
	print_verbose("I am: ", name, " | ", uuid)


## Override this function to provide a _ready function for your script
func _component_ready() -> void:
	pass


## Calls a method on the remote object.
func rpc(method_name: String, args: Array = []) -> void:
	Client.send_command(uuid, method_name, args)


## Sets user_meta from the given value
func set_user_meta(key: String, value: Variant): rpc("set_user_meta", [key, value])

## Delets an item from user meta, returning true if item was found and deleted, and false if not
func delete_user_meta(key: String) -> void: rpc("delete_user_meta", [key])

## Sets the name of this component
func set_name(new_name) -> void: rpc("set_name", [new_name])

## Always call this function when you want to delete this component. 
## As godot uses reference counting, this object will not truly be deleted untill no other script holds a refernce to it.
func delete() -> void: rpc("delete")


## Returns the value from user meta at the given key, if the key is not found, default is returned
func get_user_meta(key: String, default = null) -> Variant: 
	return user_meta.get(key, default)


## Returns all user meta
func get_all_user_meta() -> Dictionary:
	return user_meta


## Sets the self class name
func set_self_class(p_self_class_name: String) -> void:
	class_tree.append(p_self_class_name)
	self_class_name = p_self_class_name


## Adds a method that can be safley callled by client controls
func add_accessible_method(name: String, types: Array[int], set_method: Callable, get_method: Callable = Callable(), changed_signal: Signal = Signal(), arg_description: Array[String] = []) -> void:
	accessible_methods.merge({
		name: {
			"set": set_method,
			"get": get_method,
			"signal": changed_signal,
			"types": types,
			"arg_description": arg_description
		}
	})


## INTERNAL: Called when user meta is changed on the server
func on_user_meta_changed(key: String, value) -> void:
	user_meta[key] = value
	user_meta_changed.emit(key, value, user_meta)


func on_user_meta_deleted(key: String) -> void:
	if user_meta.erase(key):
		user_meta_deleted.emit(key)


## INTERNAL: called when this component is renamed on the server
func on_name_changed(new_name) -> void:
	name = new_name
	name_changed.emit(new_name)


## Returns serialized version of this component
func serialize() -> Dictionary:
	
	var serialized_data: Dictionary = {}
	serialized_data = _on_serialize_request()
	
	serialized_data.uuid = uuid
	serialized_data.name = name
	serialized_data.user_meta = get_all_user_meta()
	
	return serialized_data


## Overide this function to serialize your object
func _on_serialize_request() -> Dictionary:
	return {}


## INTERNAL: called when this object has been requested to be deleted from the server
func on_delete_requested() -> void:
	_on_delete_request()
	
	delete_requested.emit()
	
	print(uuid, " Has had a delete request send. Currently has:", str(get_reference_count()), " refernces")
	ComponentDB.deregister_component(self)


## Overide this function to handle delete requests
func _on_delete_request() -> void:
	return


## Loades this object from a serialized version
func load(serialized_data: Dictionary) -> void:
	name = serialized_data.get("name", "Unnamed EngineComponent")
	name_changed.emit(name)

	uuid = serialized_data.get("uuid", UUID_Util.v4())
	
	user_meta = serialized_data.get("user_meta", {})
	user_meta_changed.emit("user_meta", user_meta)
	
	if not "uuid" in serialized_data:
		print(name, " No uuid found in serialized_data, making new one: ", uuid)
	
	_on_load_request(serialized_data)


## Overide this function to handle load requests
func _on_load_request(serialized_data: Dictionary) -> void:
	pass


## Debug function to tell if this component is freed from memory
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		print("\"", self.name, "\" Is being freed, uuid: ", self.uuid)
