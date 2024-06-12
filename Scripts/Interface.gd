# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends Node
## Main script for spectrum interface


## Emitted when edit_mode is changed
signal edit_mode_changed(edit_mode: bool)


## Stores all the components found in the folder, stored as there folder name
var components: Dictionary = {}

## Stores all the panel found in the folder, stored as there folder name
var panels: Dictionary = {}

## Global edit mode
var edit_mode: bool = false : set = set_edit_mode

## Folder path in which all the components are stored
const components_folder: String = "res://Components/"

## Folder path in which all the panels are sotred
const panels_folder: String = "res://Panels/"


## The main object picker
var _object_picker: Control

## The currently connected callable connected to the object picker
var _object_picker_signal_connection: Callable


func _ready() -> void:
	OS.set_low_processor_usage_mode(true)
	
	Core.universes_removed.connect(func (universes: Array):
		Values.remove_from_selection_value("selected_universes", universes)
	)
	Core.fixtures_removed.connect(func (fixtures: Array): 
		Values.remove_from_selection_value("selected_fixtures", fixtures)
	)
	
	components = get_packed_scenes_from_folder(components_folder)
	panels = get_packed_scenes_from_folder(panels_folder)
	
	_object_picker = get_tree().root.get_node("Main").get_node("ObjectPicker")
	_object_picker.load_objects(panels, "Panels")
	

## Returnes all the packed scenes in the given folder, a pack scene must be in a folder, with the same name as the folder it is in
func get_packed_scenes_from_folder(folder: String) -> Dictionary:
	var packed_scenes: Dictionary = {}
	var scenes_folder: DirAccess = DirAccess.open(folder)
	
	if scenes_folder:
		_load_matching_scenes_in_folder(folder, packed_scenes)
		
		scenes_folder.list_dir_begin()
		var folder_name: String = scenes_folder.get_next()
		
		while folder_name != "":
			if scenes_folder.current_is_dir() and folder_name != "." and folder_name != "..":
				var subfolder_path: String = folder + "/" + folder_name
				_load_matching_scenes_in_folder(subfolder_path, packed_scenes, folder_name)
				
			folder_name = scenes_folder.get_next()
		
		scenes_folder.list_dir_end()
	
	return packed_scenes


## Finds the packed scene file, and checks if its name matches its parent folder
func _load_matching_scenes_in_folder(current_folder: String, packed_scenes: Dictionary, folder_name: String = "") -> void:
	var dir_access: DirAccess = DirAccess.open(current_folder)
	
	if dir_access:
		dir_access.list_dir_begin()
		var file_name: String = dir_access.get_next()
		
		while file_name != "":
			if file_name.ends_with(".tscn") or file_name.ends_with(".scn"):
				var base_file_name = file_name.get_basename()
				if folder_name == "" or base_file_name == folder_name:
					var file_path: String = current_folder + "/" + file_name
					var scene_resource = ResourceLoader.load(file_path)
					var key_name = base_file_name if folder_name == "" else folder_name
					packed_scenes[key_name] = scene_resource
			
			file_name = dir_access.get_next()
		
		dir_access.list_dir_end()


## Sets the state of edit mode
func set_edit_mode(p_edit_mode: bool) -> void:
	edit_mode = p_edit_mode
	edit_mode_changed.emit(edit_mode)


func show_object_picker(callback: Callable, filter: Array[String] = []) -> void:
	_object_picker.set_filter(filter)
	_object_picker.show()
	
	_object_picker_signal_connection = func (key: Variant, value: Variant):
		callback.call(key, value)
		_object_picker.hide()
	
	_object_picker.item_selected.connect(_object_picker_signal_connection, CONNECT_ONE_SHOT)
	
	_object_picker.closed.connect(func ():
		if _object_picker.item_selected.is_connected(_object_picker_signal_connection):
			_object_picker.item_selected.disconnect(_object_picker_signal_connection)
	, CONNECT_ONE_SHOT)
