# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name CuePlayback extends PanelContainer
## Ui panel for playing back cuelists

## The VBoxContainer that hold all the cues
@onready var _cue_container: VBoxContainer = $VBoxContainer/PanelContainer/ScrollContainer/VBoxContainer


## The cue list
var _cue_list: CueList = null

## Contains all the CueItems, keyed by the cue uuid
var _cues: Dictionary = {}

## The uuid of the cuelist used when this panel was saved
var _previous_uuid: String = ""


## Sets the cuelist to control
func set_cue_list(cue_list: CueList) -> void:
	if _previous_uuid: ComponentDB.remove_request(_previous_uuid, _on_cue_list_object_found)
	if _cue_list: _cue_list.cues_added.disconnect(_reload_cues)
	
	_cue_list = cue_list
	_cue_list.cues_added.connect(_reload_cues)
	
	_reload_cues()
	$VBoxContainer/PanelContainer2/HBoxContainer/CueName.text = cue_list.name


## Reloads the list of cues
func _reload_cues(arg1=null) -> void:
	for old_cue_item: CueItem in _cue_container.get_children():
		_cue_container.remove_child(old_cue_item)
		old_cue_item.queue_free()
	
	if _cue_list:
		for index: float in _cue_list.index_list:
			var cue: Cue = _cue_list.cues[index]
			var new_cue_item: CueItem = Interface.components.CueItem.instantiate()
			
			_cues[cue.uuid] = new_cue_item
			new_cue_item.set_cue(cue, _cue_list)
			_cue_container.add_child(new_cue_item)


## Called when the cue name button is pressed
func _on_cue_name_pressed() -> void:
	Interface.show_object_picker(ObjectPicker.SelectMode.Single, func (items: Array[EngineComponent]) -> void:
		set_cue_list(items[0])
	, ["CueList"])


## Called when ComponentDB finds the cuelist
func _on_cue_list_object_found(object: EngineComponent) -> void: if object is CueList: set_cue_list(object)


## Saves this into a dict
func save() -> Dictionary:
	if _cue_list: return { "uuid": _cue_list.uuid }
	else: return {}


## Loads this from a dict
func load(saved_data: Dictionary) -> void:
	if "uuid" in saved_data:
		_previous_uuid = saved_data.uuid
		ComponentDB.request_component(saved_data.uuid, _on_cue_list_object_found)
