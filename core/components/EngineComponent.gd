# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name EngineComponent extends RefCounted
## Base class for an engine components, contains functions for storing metadata, and uuid's


## Emitted when an item is added or edited from user_meta
signal user_meta_changed(key: String, value: Variant)

## Emitted when an item is deleted from user_meta
signal user_meta_deleted(key: String)

## Emitted when the name of this object has changed
signal name_changed(new_name: String)

## Emitted when the CID is changed
signal cid_changed(cid: int)

## Emited when this object is about to be deleted
signal delete_requested()


## The name of this object
var _name: String = "Unnamed EngineComponent"

## Infomation that can be stored by other scripts / clients, this data will get saved to disk and send to all clients
var _user_meta: Dictionary

## Uuid of the current component, do not modify at runtime unless you know what you are doing, things will break
var _uuid: String = ""

## The class_name of this component this should always be set by the object that extends EngineComponent
var _self_class_name: String = "EngineComponent" : set = _set_self_class

## Stores all the classes this component inherits from
var _class_tree: Array[String] = ["EngineComponent"]

## ComponentID
var _cid: int = -1

## The SettingsManager
var _settings_manager: SettingsManager = SettingsManager.new()


## Init
func _init(p_uuid: String = UUID_Util.v4(), p_name: String = _name) -> void:
	_uuid = p_uuid
	_name = p_name
	
	_settings_manager.set_owner(self)
	_settings_manager.set_inheritance_array(_class_tree)
	_settings_manager.set_delete_signal(delete_requested)
	
	_settings_manager.register_setting("name", Data.Type.STRING, set_name, get_name, [name_changed])
	
	#_settings_manager.register_setting("CID", Data.Type.CID, CIDManager.set_component_id.bind(self), cid, [cid_changed])\
	#.display("EngineComponent", 1)
	
	_settings_manager.register_networked_callbacks({
		"on_name_changed": _set_name,
		"on_delete_requested": local_delete,
		"on_user_meta_changed": _set_user_meta,
		"on_user_meta_deleted": _delete_user_meta
	})
	
	print("I am: ", _name, " | ", _uuid)


## Shorthand for get_cid()
func cid() -> int:
	return get_cid()


## shorthand for get_uuid()
func uuid() -> String:
	return get_uuid()


## Shorthand for get_name()
func name() -> String:
	return get_name()


## Shorthand for get_self_classname()
func classname() -> String:
	return get_self_classname()


## Shorthand for get_settings_manager()
func settings() -> SettingsManager:
	return get_settings_manager()


## Calls a method on the remote object.
func rpc(p_method_name: String, p_args: Array = []) -> Promise:
	return Network.send_command(_uuid, p_method_name, p_args)


## Sets the name of this component
func set_name(new_name) -> void: 
	rpc("set_name", [new_name])


## Sets user_meta from the given value
func set_user_meta(key: String, value: Variant): 
	rpc("set_user_meta", [key, value])


## Delets an item from user meta, returning true if item was found and deleted, and false if not
func delete_user_meta(key: String) -> void: 
	rpc("delete_user_meta", [key])


## Returns the value from user meta at the given key, if the key is not found, default is returned
func get_user_meta(key: String, default = null) -> Variant: 
	return _user_meta.get(key, default)


## Returns all user meta
func get_all_user_meta() -> Dictionary:
	return _user_meta


## Gets the CID
func get_cid() -> int:
	return _cid


## Gets the uuid
func get_uuid() -> String:
	return _uuid


## Gets the name
func get_name() -> String:
	return _name


## Gets the classname of this EngineComponent
func get_self_classname() -> String:
	return _self_class_name


## Gets the settings manager
func get_settings_manager() -> SettingsManager:
	return _settings_manager


## Gets the class tree
func get_class_tree() -> Array[String]:
	return _class_tree.duplicate()


## Always call this function when you want to delete this component. 
func delete() -> void: 
	rpc("delete")


## Deletes this component localy, with out contacting the server. Usefull when handling server side delete requests
func local_delete() -> void:
	_delete_request()
	
	delete_requested.emit()
	print(_uuid, " Has had a delete request send. Currently has:", str(get_reference_count()), " refernces")


## Returns serialized version of this component
func serialize() -> Dictionary:
	var serialized_data: Dictionary = {}
	serialized_data = _serialize_request()
	
	serialized_data.uuid = _uuid
	serialized_data.name = _name
	serialized_data.user_meta = get_all_user_meta()
	
	return serialized_data


## Loades this object from a serialized version
func load(p_serialized_data: Dictionary) -> void:
	_name = p_serialized_data.get("name", "Unnamed EngineComponent")
	name_changed.emit(_name)

	_uuid = p_serialized_data.get("uuid", UUID_Util.v4())
	
	_user_meta = p_serialized_data.get("user_meta", {})
	user_meta_changed.emit("user_meta", _user_meta)
	
	var cid: int = type_convert(p_serialized_data.get("cid", -1), TYPE_INT)
	if CIDManager.set_component_id_local(cid, self, true):
		_cid = cid
	
	if not "uuid" in p_serialized_data:
		print(_name, " No uuid found in serialized_data, making new one: ", _uuid)
	
	_load_request(p_serialized_data)


#region DeleteMe
## Gets a control method by name
func get_control_methods() -> Dictionary[String, Dictionary]:
	return {}


## Gets a control method by name
func get_control_method(p_control_name: String) -> Dictionary:
	return {}


## Registers a callback to a server signal
func register_callback(p_signal_name: String, p_callback: Callable) -> void:
	pass


## Registers a setting
func register_setting(p_classname: String, p_key: String, p_setter: Callable, p_getter: Callable, p_signal: Signal, p_type: Data.Type, p_visual_line: int, p_visual_name: String, p_min: Variant = null, p_max: Variant = null, p_enum: Dictionary = {}) -> void:
	pass


## Shorthand for register_setting() for a string value
func register_setting_string(p_key: String, p_setter: Callable, p_getter: Callable, p_signal: Signal) -> void:
	pass


## Shorthand for register_setting() for a float value
func register_setting_bool(p_key: String, p_setter: Callable, p_getter: Callable, p_signal: Signal) -> void:
	pass


## Shorthand for register_setting() for a float value
func register_setting_float(p_key: String, p_setter: Callable, p_getter: Callable, p_signal: Signal, p_min: float, p_max: float) -> void:
	pass


## Shorthand for register_setting() for a float value
func register_setting_enum(p_key: String, p_setter: Callable, p_getter: Callable, p_signal: Signal, p_enum: Dictionary) -> void:
	pass


## Registers a custom setting panel
func register_custom_panel(p_classname: String, p_key: String, p_entry_point: String, p_custom_panel: PackedScene) -> void:
	pass


## Gets the settings for the given class
func get_settings(p_classname: String) -> Dictionary:
	return {}


## Registers a method that can be called by external control systems
func register_control_method(p_name: String, p_down_method: Callable, p_up_method: Callable = Callable(), p_signal: Signal = Signal(), p_args: Array[int] = []) -> void:
	pass
#endregion


## Internal: Sets the name of this component
func _set_name(p_name: String) -> void:
	_name = p_name
	name_changed.emit(_name)


## Sets the self class name
func _set_self_class(p_self_class_name: String) -> void:
	_class_tree.append(p_self_class_name)
	_self_class_name = p_self_class_name


## Internal: Sets user meta
func _set_user_meta(p_key: String, p_value: Variant) -> void:
	_user_meta[p_key] = p_value
	user_meta_changed.emit(p_key, p_value)


## Internal: Deletes user meta
func _delete_user_meta(p_key: String) -> void:
	if _user_meta.erase(p_key):
		user_meta_deleted.emit(p_key)


## Overide this function to handle delete requests
func _delete_request() -> void: 
	return


## Overide this function to serialize your object
func _serialize_request() -> Dictionary: 
	return {}


## Overide this function to handle load requests
func _load_request(p_serialized_data: Dictionary) -> void: 
	return


## Debug function to tell if this component is freed from memory
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		print("\"", self._name, "\" Is being freed, uuid: ", self._uuid)
