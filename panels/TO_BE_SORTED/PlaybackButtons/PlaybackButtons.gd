# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name PlaybackButtons extends Control
## Ui panel for triggering scenes, only with a single button


## The settings node used to choose what scenes are to be shown 
@onready var settings_node: Control = $Settings

## The list of scenes that are shown here, after updating it, call reload()
var scenes: Array = []

## Whether or not to show all scenes that get added to this engine
@export var show_all: bool = false : set = set_show_all


## Stores a list of the user selected scenes befour show_all was enabled, so they can be restored after
var _old_scenes: Array = []

## The ListItemView node in the setting page
var _settings_list: ItemListView

## Stores the uuids of the scenes that where shown here when save() was called, stored here incase the scene hasent been added to the engine yet
var _saved_scene_uuids: Array = []


func _ready() -> void:
	
	_settings_list = $Settings/VBoxContainer/ItemListView as ItemListView
	_settings_list.remove_all()
	
	reload()
	
	Core.functions_added.connect(func (new_scenes: Array):
		if show_all:
			scenes.append_array(new_scenes)
			reload()
		
		if _find_saved_scenes():
			reload()
	)
	
	Core.functions_removed.connect(func (scenes_to_remove: Array):
		var should_reload: bool = false
		
		for scene: Function in scenes_to_remove:
			if scene is Scene and scene in scenes:
				scenes.erase(scene)
				should_reload = true
		
		if should_reload:
			reload()
	)
	
	Core.function_name_changed.connect(func (function: Function, new_name: String):
		if function is Scene and function in scenes:
			reload()
	)
	
	remove_child($Settings)


func set_show_all(p_show_all: bool) -> void:
	show_all = p_show_all
	
	if show_all:
		_old_scenes = scenes.duplicate()
		scenes = Core.functions.values()
	else:
		scenes = _old_scenes.duplicate()
	
	if is_node_ready():
		reload()



## Reloads the buttons in the ui
func reload(arg1=null, arg2=null) -> void:
	
	for old_button: Button in $ScrollContainer/GridContainer.get_children():
		$ScrollContainer/GridContainer.remove_child(old_button)
		old_button.queue_free()
	
	_settings_list.remove_all()
	
	_find_saved_scenes()
	
	for scene: Function in scenes.duplicate():
		if scene is Scene:
			
			_settings_list.add_items([scene])
			
			var button_to_add: Button = Interface.components.TriggerButton.instantiate()
		
			button_to_add.set_label_text(scene.name)
			
			button_to_add.toggled.connect(
				func(state):
					scene.set_enabled(state)
			)
			
			scene.state_changed.connect(button_to_add.set_pressed_no_signal)
			scene.intensity_changed.connect(button_to_add.set_value)
			
			button_to_add.set_pressed_no_signal(scene.enabled)
			
			$ScrollContainer/GridContainer.add_child(button_to_add)


## Trys to find any scenes that were just added, from the ones that were saved when save() was called
func _find_saved_scenes() -> Array:
	var found_scenes: Array
	
	for saved_scene_uuid in _saved_scene_uuids.duplicate():
		if saved_scene_uuid in Core.functions:
			if Core.functions[saved_scene_uuid] is Scene:
				var found_scene: Scene = Core.functions[saved_scene_uuid] 
				if not found_scene in scenes:
					scenes.append(found_scene)
					found_scenes.append(found_scene)
	
	return found_scenes


## Returnes the settings of this panel
func save() -> Dictionary:
	var scene_uuids: Array[String] = []
	
	if not show_all:
		for scene in scenes:
			scene_uuids.append(scene.uuid)
	
	return {
		"scenes": scene_uuids,
		"show_all": show_all
	}


## Loads the settings saved using save()
func load(saved_data: Dictionary) -> void:
	show_all = saved_data.get("show_all", false)
	
	_saved_scene_uuids = saved_data.get("scenes", [])
	
	reload()


func _on_item_list_view_edit_requested(items: Array) -> void:
	#Interface.show_object_picker(_on_object_picker_item_selected, ["Functions"], true, _on_object_picker_item_deselected, scenes)
	pass


func _on_object_picker_item_selected(key, value) -> void:
	scenes.append(value)
	reload()


func _on_object_picker_item_deselected(key, value) -> void:
	scenes.erase(value)
	reload()


func _on_grid_container_resized() -> void:
	$ScrollContainer/GridContainer.columns = clamp(int(self.size.x / 90), 1, INF)
