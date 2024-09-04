# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends Control
## Ui panel for controling scenes, with sliders and extra buttons


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
	
	Core.functions_added.connect(func (new_functions: Array):
		var should_reload: bool = false
		
		if show_all:
			for function: Function in new_functions:
				if function is Scene:
					scenes.append(function)
					should_reload = true
			
			if should_reload:
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


## Reload the list of scenes
func reload(arg1=null, arg2=null) -> void:
	for old_playback: Control in $Container.get_children():
		$Container.remove_child(old_playback)
		old_playback.queue_free()
	
	_settings_list.remove_all()
	
	_find_saved_scenes()
	
	for scene: Function in scenes.duplicate():
		if scene is Scene:
			_add_playback_row(scene)
			
		else:
			scenes.erase(scene)

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

## Adds a playback row
func _add_playback_row(scene: Scene) -> void:
	_settings_list.add_items([scene], [], "", "name_changed")
	
	var new_node: PlaybackRowComponent = Interface.components.PlaybackRow.instantiate()
	
	$Container.add_child(new_node)
	
	# Button 1 will toggle the scene
	new_node.button1.toggle_mode = true
	new_node.button1.toggled.connect(scene.set_enabled)
	
	new_node.button1.set_label_text(scene.name)
	scene.name_changed.connect(new_node.button1.set_label_text)
	
	new_node.button1.set_pressed_no_signal(scene.enabled)
	new_node.button1.set_value(scene.percentage_step)
	scene.percentage_step_changed.connect(new_node.button1.set_value)
	scene.state_changed.connect(new_node.button1.set_pressed_no_signal)

	
	# Button 2 will always enable the scene
	new_node.button2.set_label_text("Enable")
	new_node.button2.pressed.connect(scene.set_enabled.bind(true))
	
	
	# Button 3 will flash the scene
	new_node.button3.set_label_text("Flash On")
	new_node.button3.button_down.connect(scene.flash_hold.bind(0))
	new_node.button3.button_up.connect(scene.flash_release.bind())
	
	# Button 4 doesn't do anything, thus it is hidden
	new_node.button4.hide()
	
	# Button 5 will always disable the scene
	new_node.button5.set_label_text("Disable")
	new_node.button5.pressed.connect(scene.set_enabled.bind(false))
	
	
	# The slider sets the state of the scene
	new_node.slider.value_changed.connect(func (value: int) -> void:
		scene.set_step_percentage(remap(value, 0, 255, 0.0, 1.0))
	)
	new_node.set_slider_value(scene.percentage_step)
	scene.percentage_step_changed.connect(new_node.set_slider_value)


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
	Interface.show_object_picker(_on_object_picker_item_selected, ["Functions"], true, _on_object_picker_item_deselected, scenes)


func _on_object_picker_item_selected(key, value) -> void:
	scenes.append(value)
	reload()


func _on_object_picker_item_deselected(key, value) -> void:
	scenes.erase(value)
	reload()
