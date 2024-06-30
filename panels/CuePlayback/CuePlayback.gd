# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends PanelContainer
## UI Panel for controling a CueList


## The settings node used to choose what scenes are to be shown 
@onready var settings_node: Control = $Settings


## The current cue list
var _current_cue_list: CueList

## Stores the uuid of the last CueList that was shown here when save() was called, stored here incase the CueList hasent been added to the engine yet
var _saved_cue_list_uuid: String = ""

## The current selected item
var _current_selected_item: ListItem

## The last selected item
var _last_selected_item: ListItem

## Stores the cue and its related list item in the ui, stored as {cue_number: ListItem}
var _object_refs: Dictionary

## Stores the cue and its related list item in the ui, stored as {ListItem: cue_number}
var _cue_refs: Dictionary

## The last index that this cue list was on
var _old_index: int = 0

## The ItemListView used to display cues
@onready var _cue_list_container: VBoxContainer = $VBoxContainer/List/ScrollContainer/VBoxContainer

## Stores the lables that display status infomation about the scene
@onready var lables: Dictionary = {
	"cue_number": $VBoxContainer/Controls/HBoxContainer/InfoContainer/HBoxContainer/CueNumber,
	"paused": $VBoxContainer/Controls/HBoxContainer/InfoContainer/HBoxContainer/Paused,
	"playing": $VBoxContainer/Controls/HBoxContainer/InfoContainer/HBoxContainer/Playing,
	"stopped": $VBoxContainer/Controls/HBoxContainer/InfoContainer/HBoxContainer/Stopped,
}


func _ready() -> void:
	
	Core.functions_added.connect(func (arg1=null):
		if _saved_cue_list_uuid:
			_find_cue_list()
	)
	
	Core.functions_removed.connect(func (functions: Array):
		for function in functions:
			if function == _current_cue_list:
				set_cue_list(null)
	)
	
	remove_child($Settings)
	reload()


## Reloads the list of cues
func reload(arg1=null, arg2=null, arg3=null, arg4=null):
	for old_item: Control in _cue_list_container.get_children():
		_cue_list_container.remove_child(old_item)
		old_item.queue_free()
	
	
	if _current_cue_list:
		for cue_number: int in _current_cue_list.cues.keys():
			var cue = _current_cue_list.cues[cue_number]
			var new_list_item: ListItem = Interface.components.ListItem.instantiate()
			
			new_list_item.set_item_name(cue.scene.name)
			new_list_item.set_name_changed_signal(cue.scene.name_changed)
			
			_object_refs[cue_number] = new_list_item
			_cue_refs[new_list_item] = cue_number
			
			new_list_item.select_requested.connect(func (arg1=null):
				if _last_selected_item:
					_last_selected_item.set_selected(false)
					
				new_list_item.set_selected(true)
				
				_current_selected_item = new_list_item
				_last_selected_item = new_list_item
			)
			
			_cue_list_container.add_child(new_list_item)
	
	_reload_lables()
	_reload_name()


func set_cue_list(cue_list: CueList = null) -> void:
	if _current_cue_list:
		_current_cue_list.name_changed.disconnect(_reload_name)
		_current_cue_list.cues_added.disconnect(reload)
		_current_cue_list.cues_removed.disconnect(reload)
		_current_cue_list.cue_changed.disconnect(_on_cue_changed)
		_current_cue_list.played.disconnect(_reload_lables)
		_current_cue_list.paused.disconnect(_reload_lables)
		_current_cue_list.stopped.disconnect(_reload_lables)
	
	_current_cue_list = cue_list
	
	if _current_cue_list:
		_current_cue_list.name_changed.connect(_reload_name)
		_current_cue_list.cues_added.connect(reload)
		_current_cue_list.cues_removed.connect(reload)
		_current_cue_list.cue_changed.connect(_on_cue_changed)
		_current_cue_list.played.connect(_reload_lables)
		_current_cue_list.paused.connect(_reload_lables)
		_current_cue_list.stopped.connect(_reload_lables)
	
	reload()


func _find_cue_list():
	if _saved_cue_list_uuid in Core.functions:
		if Core.functions[_saved_cue_list_uuid] is CueList:
			var found_cue_list: CueList = Core.functions[_saved_cue_list_uuid]
			if _current_cue_list == null:
				set_cue_list(found_cue_list)


## Saves the settings to a dictionary
func save() -> Dictionary:
	return {
		"cue_list": _current_cue_list.uuid if _current_cue_list else ""
	}


## Loads settingd from what was returned by save()
func load(saved_data: Dictionary) -> void:
	_saved_cue_list_uuid = saved_data.get("cue_list", "")


## Reloads the status lables
func _reload_lables() -> void:
	lables.cue_number.text = "0"
	lables.playing.hide()
	lables.paused.hide()
	lables.stopped.hide()
	
	if _current_cue_list:
		lables.cue_number.text = str(_current_cue_list.index)
		
		if _current_cue_list.is_playing():
			lables.playing.show()
			
		elif _current_cue_list.index == 0:
			lables.stopped.show()
			
		else:
			lables.paused.show()


func _reload_name(arg1=null):
	if _current_cue_list:
		$VBoxContainer/PanelContainer/Label.text = _current_cue_list.name
	else:
		$VBoxContainer/PanelContainer/Label.text = "Empty List"


## Called when the current cue is changed
func _on_cue_changed(index: int) -> void:
	if _current_cue_list:
		if _old_index:
			_object_refs[_old_index].set_highlighted(false)
		
		if index:
			_object_refs[index].set_highlighted(true)
		_old_index = index
		
		_reload_lables()


func _on_change_cue_list_pressed() -> void:
	Interface.show_object_picker(func (key: Variant, value: Variant):
		if value is CueList:
			set_cue_list(value)
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


func _on_go_pressed() -> void:
	if _current_selected_item:
		_current_cue_list.seek_to(_cue_refs[_current_selected_item])

func _on_next_pressed() -> void:
	if _current_cue_list:
		_current_cue_list.go_next()


func _on_v_box_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		_last_selected_item = null
		if _current_selected_item:
			_current_selected_item.set_selected(false)
