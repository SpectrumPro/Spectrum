# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends Node

@onready var _root_node : Control = get_tree().root.get_node("Main")

var components: Dictionary = {}
var panels: Dictionary = {}

@onready var icons := {
	"menue":load("res://Assets/Icons/menu.svg"),
	"center":load("res://Assets/Icons/Center.svg")
	
}

@onready var shaders := {
	"invert":load("res://Assets/Shaders/Invert.tres"),
}


var components_folder: String = "res://Components/"
var panels_folder: String = "res://Panels/"


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
	print(panels)


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





func open_panel_in_window(panel_name:String) -> void:
	#if panel_name in panels:
		#var new_window_node : Window = components.window.instantiate()
		#new_window_node.add_child(panels[panel_name].instantiate())
		#_root_node.add_child(new_window_node)
		#return new_window_node
	#else: 
		#return false
	pass
