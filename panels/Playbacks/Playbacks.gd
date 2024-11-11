# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

extends Control
## Ui panel for controling scenes, with sliders and extra buttons


## The settings node used to choose what scenes are to be shown 
@onready var settings_node: Control = $Settings

@onready var _add_row_button: Button = $Settings/VBoxContainer/HSplitContainer/PanelContainer/ScrollContainer/HBoxContainer/AddRow
@onready var _dummy_container: HBoxContainer = $Settings/VBoxContainer/HSplitContainer/PanelContainer/ScrollContainer/HBoxContainer
@onready var _scroll_container: ScrollContainer = $Settings/VBoxContainer/HSplitContainer/PanelContainer/ScrollContainer


func _ready() -> void:
	remove_child($Settings)


func _auto_setup_for(playback_row: PlaybackRowComponent) -> void:
	Interface.show_object_picker(ObjectPicker.SelectMode.Single, func(objects: Array[EngineComponent]) -> void:
		playback_row.load_auto_config(objects[0])
	)


func _on_add_row_pressed() -> void:
	var new_row: PlaybackRowComponent = Interface.components.PlaybackRow.instantiate()
	$Container.add_child(new_row)
	
	var dummy_row: PlaybackRowComponent = new_row.create_dummy_row()
	var dummy_row_container: PlaybackRowDummyContainer = load("res://components/PlaybackRow/PlaybackRowDummyContainer.tscn").instantiate()
	
	dummy_row_container.set_playback_row(dummy_row)
	
	dummy_row_container.delete_pressed.connect(func () -> void:
		new_row.queue_free()
		dummy_row_container.queue_free()
	)
	
	dummy_row_container.auto_pressed.connect(func () -> void:
		_auto_setup_for(new_row)
	)
	
	_dummy_container.add_child(dummy_row_container)
	_add_row_button.move_to_front()
	
	await get_tree().process_frame
	
	_scroll_container.ensure_control_visible.call_deferred(_add_row_button)
