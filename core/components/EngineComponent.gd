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
var self_class_name: String = "EngineComponent" : set = _set_self_class

## Stores all the classes this component inherits from
var class_tree: Array[String] = ["EngineComponent"]

## Network Config:
## high_frequency_signals: Contains all the signals that should be send over the udp stream, instead of the tcp websocket 
var network_config: Dictionary = {
	"callbacks": {
		"on_name_changed": _set_name,
		"on_delete_requested": local_delete,
		"on_user_meta_changed": _set_user_meta,
		"on_user_meta_deleted": _delete_user_meta
	}
}


## List of functions that are allowed to be called by external control scripts.
var accessible_methods: Dictionary = {}


## Settings for this component
var _settings: Dictionary = {
}


func _init(p_uuid: String = UUID_Util.v4(), p_name: String = name) -> void:
	uuid = p_uuid
	name = p_name
	
	register_setting("EngineComponent", "name", set_name, get_name, name_changed, "STRING", 0, "Name")
	_component_ready()
	
	print_verbose("I am: ", name, " | ", uuid)


## Override this function to provide a _ready function for your script
func _component_ready() -> void:
	pass


## Sets the name of this component
func set_name(new_name) -> void: 
	rpc("set_name", [new_name])


## Internal: Sets the name of this component
func _set_name(p_name: String) -> void:
	name = p_name
	name_changed.emit(name)


## Gets the name
func get_name() -> String:
	return name


## Sets the self class name
func _set_self_class(p_self_class_name: String) -> void:
	class_tree.append(p_self_class_name)
	self_class_name = p_self_class_name


## Calls a method on the remote object.
func rpc(p_method_name: String, p_args: Array = []) -> Promise:
	return Client.send_command(uuid, p_method_name, p_args)


## Registers a callback to a server signal
func register_callback(p_signal_name: String, p_callback: Callable) -> void:
	network_config.callbacks[p_signal_name] = p_callback


## Registers a setting
func register_setting(p_classname: String, p_key: String, p_setter: Callable, p_getter: Callable, p_signal: Signal, p_type: String, p_visual_line: int, p_visual_name: String) -> void:
	_settings.get_or_add(p_classname, {})[p_key] = {
			"setter": p_setter,
			"getter": p_getter,
			"signal": p_signal,
			"data_type": p_type,
			"visual_line": p_visual_line,
			"visual_name": p_visual_name
	}


## Registers a custom setting panel
func register_custom_panel(p_classname: String, p_key: String, p_entry_point: String, p_custom_panel: PackedScene) -> void:
	_settings.get_or_add(p_classname, {})[p_key] = {
			"data_type": Utils.TYPE_CUSTOM,
			"entry_point": p_entry_point,
			"custom_panel": p_custom_panel
	}


## Gets the settings for the given class
func get_settings(p_classname: String) -> Dictionary:
	return _settings.get(p_classname, {}).duplicate()


## Adds a method that can be safley callled by client controls
func add_accessible_method(p_name: String, p_types: Array[int], p_set_method: Callable, p_get_method: Callable = Callable(), p_changed_signal: Signal = Signal(), p_arg_description: Array[String] = []) -> void:
	accessible_methods.merge({
		name: {
			"set": p_set_method,
			"get": p_get_method,
			"signal": p_changed_signal,
			"types": p_types,
			"arg_description": p_arg_description
		}
	})


## Sets user_meta from the given value
func set_user_meta(key: String, value: Variant): rpc("set_user_meta", [key, value])

## Internal: Sets user meta
func _set_user_meta(p_key: String, p_value: Variant) -> void:
	user_meta[p_key] = p_value
	user_meta_changed.emit(p_key, p_value)


## Delets an item from user meta, returning true if item was found and deleted, and false if not
func delete_user_meta(key: String) -> void: rpc("delete_user_meta", [key])

## Internal: Deletes user meta
func _delete_user_meta(p_key: String) -> void:
	if user_meta.erase(p_key):
		user_meta_deleted.emit(p_key)


## Returns the value from user meta at the given key, if the key is not found, default is returned
func get_user_meta(key: String, default = null) -> Variant: 
	return user_meta.get(key, default)


## Returns all user meta
func get_all_user_meta() -> Dictionary:
	return user_meta


## Always call this function when you want to delete this component. 
func delete() -> void: rpc("delete")

## Deletes this component localy, with out contacting the server. Usefull when handling server side delete requests
func local_delete() -> void:
	_delete_request()
	
	delete_requested.emit()
	
	print(uuid, " Has had a delete request send. Currently has:", str(get_reference_count()), " refernces")
	ComponentDB.deregister_component(self)

## Overide this function to handle delete requests
func _delete_request() -> void: return


## Returns serialized version of this component
func serialize() -> Dictionary:
	var serialized_data: Dictionary = {}
	serialized_data = _serialize_request()
	
	serialized_data.uuid = uuid
	serialized_data.name = name
	serialized_data.user_meta = get_all_user_meta()
	
	return serialized_data

## Overide this function to serialize your object
func _serialize_request() -> Dictionary: return {}


## Loades this object from a serialized version
func load(p_serialized_data: Dictionary) -> void:
	name = p_serialized_data.get("name", "Unnamed EngineComponent")
	name_changed.emit(name)

	uuid = p_serialized_data.get("uuid", UUID_Util.v4())
	
	user_meta = p_serialized_data.get("user_meta", {})
	user_meta_changed.emit("user_meta", user_meta)
	
	if not "uuid" in p_serialized_data:
		print(name, " No uuid found in serialized_data, making new one: ", uuid)
	
	_load_request(p_serialized_data)

## Overide this function to handle load requests
func _load_request(p_serialized_data: Dictionary) -> void: return


## Debug function to tell if this component is freed from memory
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		print("\"", self.name, "\" Is being freed, uuid: ", self.uuid)
