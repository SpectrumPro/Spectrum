# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends PanelContainer

## UI Panel for controlling a CueList

## The settings node used to choose what scenes are to be shown 
@onready var settings_node: Control = $Settings

## The current cue list
var current_cue_list: CueList

## Stores the UUID of the last CueList that was shown here when save() was called
## Stored here in case the CueList hasn't been added to the engine yet
var saved_cue_list_uuid: String = ""

## The current selected item
var current_selected_item: ListItem : set = _set_current_selected_item

## The last selected item
var last_selected_item: ListItem

## Stores the cue and its related list item in the UI
## Stored as {cue_number: ListItem}
var object_refs: Dictionary

## Stores the cue and its related list item in the UI
## Stored as {ListItem: cue_number}
var cue_refs: Dictionary

## The last index that this cue list was on
var old_index: float = 0


## Edit mode
var _edit_mode: bool = false

## Current selected Cue object
var _current_selected_cue: Cue = null

## Used to create the global cue controls
var _pre_wait: float = 0
var _fade_time: float = 0


## The ItemListView used to display cues
@onready var cue_list_container: VBoxContainer = $VBoxContainer/List/VBoxContainer/ScrollContainer/VBoxContainer

@onready var glboal_cue: ListItem = $VBoxContainer/List/VBoxContainer/GlobalCue

@onready var edit_controls: PanelContainer = $VBoxContainer/PanelContainer/HBoxContainer/EditControls

## Stores the labels that display status information about the scene
@onready var labels: Dictionary = {
	"cue_number": $VBoxContainer/Controls/HBoxContainer/InfoContainer/HBoxContainer/CueNumber,
	"cue_label": $VBoxContainer/Controls/HBoxContainer/InfoContainer/HBoxContainer/CueLabel,
	"separator": $VBoxContainer/Controls/HBoxContainer/InfoContainer/HBoxContainer/VSeparator,
	"paused": $VBoxContainer/Controls/HBoxContainer/InfoContainer/HBoxContainer/Paused,
	"playing": $VBoxContainer/Controls/HBoxContainer/InfoContainer/HBoxContainer/Playing,
	"stopped": $VBoxContainer/Controls/HBoxContainer/InfoContainer/HBoxContainer/Stopped,
}


func _ready() -> void:
	Core.functions_added.connect(_on_functions_added)
	Core.functions_removed.connect(_on_functions_removed)
	Values.connect_to_selection_value("selected_fixtures", _on_selected_fixtures_changed)
	
	glboal_cue.set_item_name("Global")
	glboal_cue.add_chip(self, "_fade_time", _set_global_fade_time)
	glboal_cue.add_chip(self, "_pre_wait", _set_global_pre_wait)
	
	remove_child(settings_node)
	settings_node.show()
	reload()


func _set_global_pre_wait(pre_wait: float) -> void:
	if current_cue_list:
		_pre_wait = pre_wait
		for cue: Cue in current_cue_list.cues.values():
			cue.set_pre_wait(pre_wait)


func _set_global_fade_time(fade_time: float) -> void:
	if current_cue_list:
		_fade_time = fade_time
		for cue: Cue in current_cue_list.cues.values():
			cue.set_fade_time(fade_time)


func _set_current_selected_item(p_current_selected_item) -> void:
	current_selected_item = p_current_selected_item
	_current_selected_cue = current_cue_list.cues[cue_refs[current_selected_item]] if current_selected_item else null
	
	var state: bool = current_selected_item == null
	
	$VBoxContainer/PanelContainer/HBoxContainer/EditControls/HBoxContainer/Delete.disabled = state
	$VBoxContainer/PanelContainer/HBoxContainer/EditControls/HBoxContainer/MoveUp.disabled = state
	$VBoxContainer/PanelContainer/HBoxContainer/EditControls/HBoxContainer/MoveDown.disabled = state
	$VBoxContainer/Controls/HBoxContainer/Go.disabled = state


func _on_functions_added(arg1=null) -> void:
	if saved_cue_list_uuid:
		_find_cue_list()


func _on_functions_removed(functions: Array) -> void:
	for function in functions:
		if function == current_cue_list:
			set_cue_list(null)


func _on_selected_fixtures_changed(selected_fixtures: Array) -> void:
	$VBoxContainer/PanelContainer/HBoxContainer/Store.disabled = selected_fixtures == []
	$StoreConfirmationBox/VBoxContainer2/HBoxContainer4/NumOfFixtures.text = str(len(selected_fixtures))


## Reloads the list of cues
func reload() -> void:
	for old_item: Control in cue_list_container.get_children():
		cue_list_container.remove_child(old_item)
		old_item.queue_free()
	
	
	var old_selected_cue: Cue = _current_selected_cue
	
	_clear_selections()
	_reset_refs()

	if current_cue_list:
		for cue_number: float in current_cue_list.index_list:
			var cue: Cue = current_cue_list.cues[cue_number]
			var new_list_item: ListItem = Interface.components.ListItem.instantiate()

			new_list_item.set_item_name(cue.name)
			new_list_item.set_name_changed_signal(cue.name_changed)
			new_list_item.set_id_tag(str(cue_number))
			
			if _edit_mode:
				new_list_item.set_name_method(cue.set_name)
				new_list_item.add_chip(cue, "fade_time", cue.set_fade_time)
				new_list_item.add_chip(cue, "pre_wait", cue.set_pre_wait)
			
			_store_refs(cue_number, new_list_item)
			
			if cue == old_selected_cue:
				new_list_item.set_selected(true)
				last_selected_item = new_list_item
				current_selected_item = new_list_item
			

			new_list_item.select_requested.connect(func(arg1=null):
				_on_select_requested(new_list_item, cue_number))

			cue_list_container.add_child(new_list_item)
		
		glboal_cue.visible = _edit_mode
		
	_reload_labels()
	_reload_name()


func _clear_selections() -> void:
	current_selected_item = null
	last_selected_item = null


func _reset_refs() -> void:
	object_refs = {}
	cue_refs = {}
	old_index = 0


func _store_refs(cue_number: float, new_list_item: ListItem) -> void:
	object_refs[cue_number] = new_list_item
	cue_refs[new_list_item] = cue_number


func _on_select_requested(new_list_item: ListItem, cue_number: float) -> void:
	if last_selected_item:
		last_selected_item.set_selected(false)

	new_list_item.set_selected(true)

	current_selected_item = new_list_item
	last_selected_item = new_list_item

	if Input.is_key_pressed(KEY_CTRL):
		current_cue_list.seek_to(cue_refs[current_selected_item])

	$StoreConfirmationBox/VBoxContainer2/HBoxContainer4/CueNumber.text = str(cue_number)


func set_cue_list(cue_list: CueList = null) -> void:
	if current_cue_list:
		_disconnect_signals()

	current_cue_list = cue_list

	if current_cue_list:
		_connect_signals()

	reload()


func _disconnect_signals() -> void:
	current_cue_list.name_changed.disconnect(_reload_name)
	current_cue_list.cues_added.disconnect(_reload_from_signal)
	current_cue_list.cues_removed.disconnect(_reload_from_signal)
	current_cue_list.cue_numbers_changed.disconnect(_reload_from_signal)
	current_cue_list.cue_changed.disconnect(_on_cue_changed)
	current_cue_list.played.disconnect(_reload_labels)
	current_cue_list.paused.disconnect(_reload_labels)


func _connect_signals() -> void:
	current_cue_list.name_changed.connect(_reload_name)
	current_cue_list.cues_added.connect(_reload_from_signal)
	current_cue_list.cues_removed.connect(_reload_from_signal)
	current_cue_list.cue_numbers_changed.connect(_reload_from_signal)	
	current_cue_list.cue_changed.connect(_on_cue_changed)
	current_cue_list.played.connect(_reload_labels)
	current_cue_list.paused.connect(_reload_labels)


func _reload_from_signal(arg1=null) -> void:
	reload()


func _find_cue_list() -> void:
	if saved_cue_list_uuid in Core.functions:
		var found_cue_list: CueList = Core.functions[saved_cue_list_uuid]
		if current_cue_list == null:
			set_cue_list(found_cue_list)


## Saves the settings to a dictionary
func save() -> Dictionary:
	return {
		"cue_list": current_cue_list.uuid if current_cue_list else ""
	}


## Loads settings from what was returned by save()
func load(saved_data: Dictionary) -> void:
	saved_cue_list_uuid = saved_data.get("cue_list", "")


## Reloads the status labels
func _reload_labels() -> void:
	labels.cue_number.text = "0"
	labels.cue_number.hide()
	labels.cue_label.hide()
	labels.separator.hide()
	labels.playing.hide()
	labels.paused.hide()
	labels.stopped.hide()

	if current_cue_list:
		labels.cue_number.text = str(current_cue_list.current_cue_number)

		if current_cue_list.is_playing():
			labels.playing.show()

		if current_cue_list.current_cue_number == -1:
			labels.cue_number.hide()
			labels.cue_label.hide()
			labels.stopped.show()
		else:
			labels.paused.show()
			labels.cue_number.show()
			labels.cue_label.show()
			labels.separator.show()


func _reload_name(arg1=null) -> void:
	if current_cue_list:
		$VBoxContainer/PanelContainer/HBoxContainer/Label.text = current_cue_list.name
	else:
		$VBoxContainer/PanelContainer/HBoxContainer/Label.text = "Empty List"


## Called when the current cue is changed
func _on_cue_changed(index: float) -> void:
	if current_cue_list:
		if old_index:
			object_refs[old_index].set_highlighted(false)

		if index in object_refs:
			object_refs[index].set_highlighted(true)
			old_index = index

		_reload_labels()


func _on_change_cue_list_pressed() -> void:
	Interface.show_object_picker(func(key: Variant, value: Variant):
		if value is CueList:
			set_cue_list(value)
	, ["Functions"])


func _on_play_pressed() -> void:
	if current_cue_list:
		current_cue_list.play()


func _on_pause_pressed() -> void:
	if current_cue_list:
		current_cue_list.pause()


func _on_stop_pressed() -> void:
	if current_cue_list:
		current_cue_list.stop()


func _on_previous_pressed() -> void:
	if current_cue_list:
		current_cue_list.go_previous()


func _on_go_pressed() -> void:
	if current_selected_item:
		current_cue_list.seek_to(cue_refs[current_selected_item])


func _on_next_pressed() -> void:
	if current_cue_list:
		current_cue_list.go_next()


func _on_v_box_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		last_selected_item = null
		
		if current_selected_item:
			current_selected_item.set_selected(false)
		
		current_selected_item = null

		$StoreConfirmationBox/VBoxContainer2/HBoxContainer4/CueNumber.text = "null"


## Edit Controls
func _on_store_pressed() -> void:
	if current_cue_list:
		$StoreConfirmationBox.show()


func _on_cancel_pressed() -> void:
	$StoreConfirmationBox.hide()


func _get_save_mode() -> int:
	return $StoreConfirmationBox/VBoxContainer2/PanelContainer/SaveMode.current_tab


func _on_new_cue_pressed() -> void:
	if current_cue_list:
		Client.send({
			"for": "programmer",
			"call": "save_to_new_cue",
			"args": [Values.get_selection_value("selected_fixtures", []), current_cue_list, _get_save_mode()]
		})


func _on_edit_mode_toggled(toggled_on: bool) -> void:
	_edit_mode = toggled_on
	reload()
	edit_controls.visible = toggled_on


func _on_delete_pressed() -> void:
	if current_selected_item:
		current_cue_list.cues[cue_refs[current_selected_item]].delete()


func _on_move_up_pressed() -> void:
	current_cue_list.move_cue_up(cue_refs[current_selected_item])


func _on_move_down_pressed() -> void:
	current_cue_list.move_cue_down(cue_refs[current_selected_item])
