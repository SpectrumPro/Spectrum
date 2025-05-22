# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name UICuePlayback extends UIPanel
## Ui panel for playing back cuelists


## The VBoxContainer that hold all the cues
@onready var _cue_container: VBoxContainer = $VBoxContainer/PanelContainer/ScrollContainer/VBoxContainer

## The object picker button
@export var _object_picker_button: ObjectPickerButton

## The IntensityButton
@export var _intensity_button: IntensityButton


## The cue list
var _cue_list: CueList = null

## Contains all the CueItems, keyed by the cue uuid
var _cues: Dictionary = {}

## The uuid of the cuelist used when this panel was saved
var _previous_uuid: String = ""

var _signal_connections: Dictionary = {
	"cues_added": _reload_cues,
	"cues_removed": _reload_cues,
	"delete_request": set_cue_list.bind(null)
}

## Sets the cuelist to control
func set_cue_list(cue_list: CueList) -> void:
	Utils.disconnect_signals(_signal_connections, _cue_list)
	_cue_list = cue_list
	Utils.connect_signals(_signal_connections, _cue_list)
	
	_reload_cues()
	_intensity_button.set_function(cue_list)


## Reloads the list of cues
func _reload_cues(arg1=null) -> void:
	for old_cue_item: CueItem in _cue_container.get_children():
		_cue_container.remove_child(old_cue_item)
		old_cue_item.set_cue(null, null)
		old_cue_item.queue_free()
	
	if _cue_list:
		for index: float in _cue_list.get_index_list():
			var cue: Cue = _cue_list.get_cue(index)
			var new_cue_item: CueItem = Interface.components.CueItem.instantiate()
			
			_cues[cue.uuid] = new_cue_item
			_cue_container.add_child(new_cue_item)
			new_cue_item.set_cue(cue, _cue_list)


#region Ui Callbacks

func _on_previous_pressed() -> void: if _cue_list: _cue_list.go_previous()
func _on_next_pressed() -> void: if _cue_list: _cue_list.go_next()
func _on_play_pause_pressed() -> void: if _cue_list: _cue_list.pause() if _cue_list.is_playing() else _cue_list.play()
func _on_stop_pressed() -> void: if _cue_list: _cue_list.stop()

#endregion


## Saves this into a dict
func _save() -> Dictionary:
	if _cue_list: return { "uuid": _cue_list.uuid }
	else: return {}


## Loads this from a dict
func _load(saved_data: Dictionary) -> void:
	if saved_data.get("uuid") is String:
		_object_picker_button.look_for(saved_data.uuid)
