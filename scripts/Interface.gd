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
const components_folder: String = "res://components/"

## Folder path in which all the panels are sotred
const panels_folder: String = "res://panels/"


## The main object picker
var _object_picker: Control

## The object pickers window
var _object_picker_window: Window

## The currently connected callable connected to the object picker
var _object_picker_selected_signal_connection: Callable

## The currently connected deselected callable connected to the object picker
var _object_picker_deselected_signal_connection: Callable


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
	
	_set_up_object_picker()

## Loads all the objects into the object picker
func _set_up_object_picker() -> void:
	_object_picker_window = get_tree().root.get_node("Main").get_node("ObjectPickerWindow")
	_object_picker = get_tree().root.get_node("Main").get_node("ObjectPickerWindow/ObjectPicker")
	_object_picker.load_objects(panels, "Panels")
	
	Core.universes_added.connect(func (arg1=null): _object_picker.load_objects(Core.universes, "Universes", "name"))
	Core.universes_removed.connect(func (arg1=null): _object_picker.load_objects(Core.universes, "Universes", "name"))
	Core.universe_name_changed.connect(func (arg1=null, arg2=null): _object_picker.load_objects(Core.universes, "Universes", "name"))
	
	Core.fixtures_added.connect(func (arg1=null): _object_picker.load_objects(Core.fixtures, "Fixtures", "name"))
	Core.fixtures_added.connect(func (arg1=null): _object_picker.load_objects(Core.fixtures, "Fixtures", "name"))
	Core.universe_name_changed.connect(func (arg1=null, arg2=null): _object_picker.load_objects(Core.fixtures, "Fixtures", "name"))
	
	Core.scenes_added.connect(func (arg1=null): _object_picker.load_objects(Core.scenes, "Scenes", "name"))
	Core.scenes_removed.connect(func (arg1=null): _object_picker.load_objects(Core.scenes, "Scenes", "name"))
	Core.scene_name_changed.connect(func (arg1=null, arg2=null): _object_picker.load_objects(Core.scenes, "Scenes", "name"))
	
	_object_picker.closed.connect(hide_object_picker)



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


func show_object_picker(callback: Callable, filter: Array[String] = [], allow_multi_select: bool = false, deselect_callback: Callable = Callable(), selection: Array = []) -> void:
	_object_picker.set_filter(filter)
	_object_picker.set_multi_select(allow_multi_select)
	_object_picker.set_selected(selection)
	
	_object_picker_window.show()
	
	_object_picker_selected_signal_connection = func (key: Variant, value: Variant):
		callback.call(key, value)
		
		if not allow_multi_select:
			_object_picker_window.hide()
	
	_object_picker_deselected_signal_connection = func (key: Variant, value: Variant):
		deselect_callback.call(key, value)
	
	_object_picker.item_selected.connect(_object_picker_selected_signal_connection, CONNECT_PERSIST if allow_multi_select else CONNECT_ONE_SHOT)
	
	if deselect_callback.is_valid():
		_object_picker.item_deselected.connect(_object_picker_deselected_signal_connection, CONNECT_PERSIST if allow_multi_select else CONNECT_ONE_SHOT)
		

## Hides the object picker
func hide_object_picker() -> void:
	_object_picker_window.hide()
	if _object_picker_selected_signal_connection.is_valid() and _object_picker.item_selected.is_connected(_object_picker_selected_signal_connection):
		_object_picker.item_selected.disconnect(_object_picker_selected_signal_connection)
		
	if _object_picker_deselected_signal_connection.is_valid() and _object_picker.item_deselected.is_connected(_object_picker_deselected_signal_connection):
		_object_picker.item_deselected.disconnect(_object_picker_deselected_signal_connection)
