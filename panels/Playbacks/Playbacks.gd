# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name UIPlaybacks extends UIPanel
## Ui panel for controling scenes, with sliders and extra buttons


@export var _add_row_button: Button = null
@export var _dummy_container: HBoxContainer = null
@export var _scroll_container: ScrollContainer = null


## TriggerButton and TriggerSlider settings panels
@export var _trigger_button_settings: TriggerButtonSettings = null
@export var _trigger_slider_settings: TriggerSliderSettings = null


@export var auto_add_new_scenes: bool = false


## Auto setups a Playback row
func _auto_setup_for(playback_row: PlaybackRowComponent) -> void:
	Interface.show_object_picker(ObjectPicker.SelectMode.Single, func(objects: Array[EngineComponent]) -> void:
		playback_row.load_auto_config(objects[0])
	)


## Opens the side bar for the selected item based on its type, or closes it if there is not match
func _open_side_bar_for(item: Control) -> void:
	_trigger_button_settings.hide()
	_trigger_slider_settings.hide()
	
	if item is TriggerButton: 
		_trigger_button_settings.show()
		_trigger_button_settings.set_trigger_button(item)
	
	if item is TriggerSlider: _trigger_slider_settings.show()


## Called when the add row button is pressed
func _on_add_row_pressed() -> void:
	var new_row: PlaybackRowComponent = Interface.components.PlaybackRow.instantiate()
	_add_row(new_row)


## Adds a new row
func _add_row(new_row: PlaybackRowComponent) -> void:
	new_row.dummy_row_item_selected.connect(_open_side_bar_for)
	$Container.add_child(new_row)
	
	var dummy_row: PlaybackRowComponent = new_row.create_dummy_row()
	var dummy_row_container: PlaybackRowDummyContainer = load("res://components/PlaybackRow/PlaybackRowDummyContainer.tscn").instantiate()
	
	dummy_row_container.set_playback_row(dummy_row)
	
	dummy_row_container.delete_pressed.connect(func () -> void:
		new_row.queue_free()
		dummy_row_container.queue_free()
	)
	
	dummy_row_container.auto_pressed.connect(func (): _auto_setup_for(new_row))
	
	dummy_row_container.move_right_pressed.connect(func () -> void:
		_dummy_container.move_child(dummy_row_container, dummy_row_container.get_index() + 1)
		$Container.move_child(new_row, new_row.get_index() + 1)
		_scroll_container.ensure_control_visible.call_deferred(dummy_row_container)
		_add_row_button.move_to_front()
	)
	
	dummy_row_container.move_left_pressed.connect(func () -> void:
		_dummy_container.move_child(dummy_row_container, dummy_row_container.get_index() - 1)
		$Container.move_child(new_row, new_row.get_index() - 1)
		_scroll_container.ensure_control_visible.call_deferred(dummy_row_container)
		
	)
	
	_dummy_container.add_child(dummy_row_container)
	_add_row_button.move_to_front()
	
	await get_tree().process_frame
	
	_scroll_container.ensure_control_visible.call_deferred(_add_row_button)


## Saves the playbacks to a dict
func save() -> Dictionary:
	var serialized_data: Dictionary = {
		"rows": []
	}
	
	for playback_row: PlaybackRowComponent in $Container.get_children():
		serialized_data.rows.append(playback_row.serialize())
	
	return serialized_data


func load(serialized_data: Dictionary) -> void:
	for serialized_row: Dictionary in serialized_data.get("rows", []):
		var new_row: PlaybackRowComponent = Interface.components.PlaybackRow.instantiate()
		_add_row(new_row)
		new_row.deserialize(serialized_row)
