# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends PanelContainer
## UI Panel for controling a CueList


## The settings node used to choose what scenes are to be shown 
@onready var settings_node: Control = $Settings

## The current cue list
var _current_cue_list: CueList

## The ItemListView used to display cues
@onready var _cue_list_view: ItemListView = $VBoxContainer/List/ItemListView


func _ready() -> void:
	remove_child($Settings)
	reload()


## Reloads the list of cues
func reload(arg1=null, arg2=null, arg3=null, arg4=null):
	_cue_list_view.remove_all()
	
	if _current_cue_list:
		for cue: Dictionary in _current_cue_list.cues.values():
			_cue_list_view.add_items([cue.scene])


func set_cue_list(cue_list: CueList = null) -> void:
	if _current_cue_list:
		_current_cue_list.cues_added.disconnect(reload)
		_current_cue_list.cues_removed.disconnect(reload)
		_current_cue_list.cue_changed.disconnect(_on_cue_changed)
		
		$VBoxContainer/PanelContainer/Label.text = "Empty List"
	
	_current_cue_list = cue_list
	
	if _current_cue_list:
		_current_cue_list.cues_added.connect(reload)
		_current_cue_list.cues_removed.connect(reload)
		_current_cue_list.cue_changed.connect(_on_cue_changed)
		
		$VBoxContainer/PanelContainer/Label.text = _current_cue_list.name


## Called when the current cue is changed
func _on_cue_changed(index: int) -> void:
	if _current_cue_list:
		_cue_list_view.set_highlighted([_current_cue_list.cues[index].scene])


func _on_change_cue_list_pressed() -> void:
	Interface.show_object_picker(func (key: Variant, value: Variant):
		if value is CueList:
			set_cue_list(value)
			reload()
	, ["Functions"])


func _on_play_pressed() -> void:
	if _current_cue_list:
		_current_cue_list.play()


func _on_pause_pressed() -> void:
	if _current_cue_list:
		_current_cue_list.pause()


func _on_stop_pressed() -> void:
	if _current_cue_list:
		_current_cue_list.stop()


func _on_previous_pressed() -> void:
	if _current_cue_list:
		_current_cue_list.go_previous()


func _on_next_pressed() -> void:
	if _current_cue_list:
		_current_cue_list.go_next()
