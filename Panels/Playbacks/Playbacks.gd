# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends Control
## Ui panel for controling scenes


## The settings node used to choose what scenes are to be shown 
@onready var settings_node: Control = $Settings

## The list of scenes that are shown here, after updating it, call reload()
var scenes: Array = []

## Whether or not to show all scenes that get added to this engine
@export var show_all: bool = false : set = set_show_all


## Stores a list of the user selected scenes befour show_all was enabled, so they can be restored after
var _old_scenes: Array = []


func _ready() -> void:
	Core.scenes_added.connect(func (new_scenes: Array):
		if show_all:
			scenes.append_array(new_scenes)
			reload()
	)
	
	Core.scenes_removed.connect(func (scenes_to_remove: Array):
		var should_reload: bool = false
		
		for scene: Scene in scenes_to_remove:
			if scene in scenes:
				scenes.erase(scene)
				should_reload = true
		
		if should_reload:
			reload()
	)
	
	Core.scene_name_changed.connect(func (scene: Scene, new_name: String):
		if scene in scenes:
			reload()
	)
	
	reload()
	remove_child($Settings)


func set_show_all(p_show_all: bool) -> void:
	show_all = p_show_all
	
	if show_all:
		_old_scenes = scenes.duplicate()
		scenes = Core.scenes.values()
	else:
		scenes = _old_scenes.duplicate()
	reload()


## Reload the list of scenes
func reload(arg1=null, arg2=null) -> void:
	for old_playback: Control in $Container.get_children():
		$Container.remove_child(old_playback)
		old_playback.queue_free()
	print(scenes)
	
	for scene: Scene in scenes:
		var new_node = Interface.components.PlaybackRow.instantiate()
		
		
		$Container.add_child(new_node)
		
		# Button 1 will toggle the scene
		new_node.button1.toggle_mode = true
		new_node.button1.toggled.connect(scene.set_enabled)
		new_node.button1.set_label_text(scene.name)
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
		new_node.slider.value_changed.connect(scene.set_step_percentage)
		new_node.slider.set_value_no_signal(scene.percentage_step)
		scene.percentage_step_changed.connect(new_node.slider.set_value_no_signal)
	


func _on_item_list_view_edit_requested(items: Array) -> void:
	Interface.show_object_picker(_on_object_picker_item_selected, ["Scenes"], true, _on_object_picker_item_deselected)


func _on_object_picker_item_selected(key, value) -> void:
	scenes.append(value)
	reload()


func _on_object_picker_item_deselected(key, value) -> void:
	scenes.erase(value)
	reload()
