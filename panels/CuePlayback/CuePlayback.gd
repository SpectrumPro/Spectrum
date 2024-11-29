# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

extends PanelContainer
## UI Panel for controlling a CueList


## Emitted when a cue is selected
signal cue_selected(cue: Cue)


## The settings node used to choose what scenes are to be shown 
@onready var settings_node: Control = $Settings

## Toggles showing the title bar
@export var show_title_bar: bool = true : set = set_show_title_bar

## Toggles showing the list
@export var show_list: bool = true : set = set_show_list

## Toggles showing the controls
@export var show_controls: bool = true : set = set_show_controls


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

## The fade in and hold time inputs for the global cue
var _global_cue_fade_time: TimerPicker = null
var _global_cue_pre_wait_time: TimerPicker = null

## Number of cues to leave visible when autoscrolling
var _scroll_extra: int = 3


## Colors for cues that have been highlighted
var _cue_highlight_color: Color = Color.ROYAL_BLUE
var _cue_default_color: Color = Color.WHITE
var _cue_active_color: Color = Color.DIM_GRAY


## The ItemListView used to display cues
@onready var cue_list_container: VBoxContainer = $VBoxContainer/List/VBoxContainer/ScrollContainer/VBoxContainer

@onready var scroll_container: ScrollContainer = $VBoxContainer/List/VBoxContainer/ScrollContainer

@onready var global_cue: ListItem = $VBoxContainer/List/VBoxContainer/GlobalCue

@onready var edit_controls: PanelContainer = $VBoxContainer/PanelContainer/HBoxContainer/EditControls

@onready var new_update_button: Button = $VBoxContainer/PanelContainer/HBoxContainer/NewUpdateButton

@onready var settings_name_label: Label = $Settings/VBoxContainer/PanelContainer2/HBoxContainer/PanelContainer/HBoxContainer/CurrentCueList

## Stores the labels that display status information about the scene
@onready var labels: Dictionary = {
	"cue_number": $VBoxContainer/Controls/HBoxContainer/InfoContainer/HBoxContainer/CueNumber,
	"cue_label": $VBoxContainer/Controls/HBoxContainer/InfoContainer/HBoxContainer/CueLabel,
 }

var _label_background_stylebox: StyleBoxFlat = null

## All the shortcut buttons in the settings panel
@onready var shortcut_buttons: Dictionary = {
	"PreviousShortcutButton": $Settings/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/PanelContainer2/VBoxContainer/HBoxContainer/PreviousShortcutButton,
	"GoShortcutButton": $Settings/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/PanelContainer3/VBoxContainer/HBoxContainer/GoShortcutButton,
	"NextShortcutButton": $Settings/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/PanelContainer4/VBoxContainer/HBoxContainer2/NextShortcutButton,
	"PlayShortcutButton": $Settings/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer2/PanelContainer5/VBoxContainer/HBoxContainer/PlayShortcutButton,
	"PauseShortcutButton": $Settings/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer2/PanelContainer6/VBoxContainer/HBoxContainer2/PauseShortcutButton,
	"ToggleShortcutButton": $Settings/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer2/PanelContainer7/VBoxContainer/HBoxContainer2/ToggleShortcutButton,
	"StopShortcutButton": $Settings/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer2/PanelContainer8/VBoxContainer/HBoxContainer2/StopShortcutButton,
}

@onready var visibility_buttons: Dictionary = {
	"Previous": $Settings/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/PanelContainer2/VBoxContainer/HBoxContainer/Visible,
	"Go": $Settings/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/PanelContainer3/VBoxContainer/HBoxContainer/Visible,
	"Next": $Settings/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/PanelContainer4/VBoxContainer/HBoxContainer2/Visible,
	"Play": $Settings/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer2/PanelContainer5/VBoxContainer/HBoxContainer/Visible,
	"Pause": $Settings/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer2/PanelContainer6/VBoxContainer/HBoxContainer2/Visible,
	"Toggle": $Settings/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer2/PanelContainer7/VBoxContainer/HBoxContainer2/Visible,
	"Stop": $Settings/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer2/PanelContainer8/VBoxContainer/HBoxContainer2/Visible,
	"show_title_bar": $Settings/VBoxContainer/PanelContainer2/HBoxContainer/PanelContainer2/HBoxContainer/ShowTitleBar,
	"show_list": $Settings/VBoxContainer/PanelContainer2/HBoxContainer/PanelContainer2/HBoxContainer/ShowList,
	"show_controls": $Settings/VBoxContainer/PanelContainer2/HBoxContainer/PanelContainer2/HBoxContainer/ShowControls,

}

@onready var control_buttons: Dictionary = {
	"Previous": $VBoxContainer/Controls/HBoxContainer/Previous,
	"Go": $VBoxContainer/Controls/HBoxContainer/Go,
	"Next": $VBoxContainer/Controls/HBoxContainer/Next,
	"Play": $VBoxContainer/Controls/HBoxContainer/Play,
	"Pause": $VBoxContainer/Controls/HBoxContainer/Pause,
	"Toggle": $VBoxContainer/Controls/HBoxContainer/Toggle,
	"Stop": $VBoxContainer/Controls/HBoxContainer/Stop,
}

var store_function_button_group: ButtonGroup = null
@onready var store_function_buttons: Dictionary = {
	"merge": $StoreConfirmationBox/VBoxContainer2/StoreModes/Merge,
	"erace": $StoreConfirmationBox/VBoxContainer2/StoreModes/Erace,
	"new_cue": $StoreConfirmationBox/VBoxContainer2/StoreModes/NewCue,
}

var save_mode_button_group: ButtonGroup = null
@onready var save_mode_buttons: Dictionary = {
	"modified_channels": $StoreConfirmationBox/VBoxContainer2/SaveModes/ModifiedChannels,
	"all_channels": $StoreConfirmationBox/VBoxContainer2/SaveModes/AllChannels,
	"all_none_zero": $StoreConfirmationBox/VBoxContainer2/SaveModes/AllNoneZero,
}


## Called when a cue has its data changed, will then go and call the _highlight_cues_with_stored_fixtures method with the selected fixtures
var _reload_highlights_signal_callback: Callable = func (arg1=null, arg2=null, arg3=null) -> void:
	_highlight_cues_with_stored_fixtures(Values.get_selection_value("selected_fixtures", []))


func _ready() -> void:
	ComponentDB.request_class_callback("Function", func (added, removed):
		if added: _on_functions_added(added)
		if removed: _on_functions_removed(removed)
	)
	Values.connect_to_selection_value("selected_fixtures", _on_selected_fixtures_changed)
	
	global_cue.set_item_name("Global")
	
	_global_cue_fade_time = Interface.components.TimerPicker.instantiate()
	_global_cue_fade_time.value = _fade_time
	_global_cue_fade_time.value_changed.connect(_set_global_fade_time)
	
	_global_cue_pre_wait_time = Interface.components.TimerPicker.instantiate()
	_global_cue_pre_wait_time.value = _pre_wait
	_global_cue_pre_wait_time.set_icon(load("res://assets/icons/PreWait.svg"))
	_global_cue_pre_wait_time.value_changed.connect(_set_global_pre_wait)
	
	global_cue.add_chip_node(_global_cue_fade_time)
	global_cue.add_chip_node(_global_cue_pre_wait_time)
	
	global_cue.select_requested.connect(_clear_selections)
	
	
	store_function_button_group = _add_to_button_group(store_function_buttons.values())
	store_function_button_group.pressed.connect(_on_store_function_changed)
	
	save_mode_button_group = _add_to_button_group(save_mode_buttons.values())
	save_mode_button_group.pressed.connect(_on_save_mode_changed)
	
	(store_function_buttons.merge as Button).button_pressed = true
	(save_mode_buttons.modified_channels as Button).button_pressed = true
	
	shortcut_buttons.PreviousShortcutButton.set_button(control_buttons.Previous)
	shortcut_buttons.GoShortcutButton.set_button(control_buttons.Go)
	shortcut_buttons.NextShortcutButton.set_button(control_buttons.Next)
	shortcut_buttons.PlayShortcutButton.set_button(control_buttons.Play)
	shortcut_buttons.PauseShortcutButton.set_button(control_buttons.Pause)
	shortcut_buttons.StopShortcutButton.set_button(control_buttons.Stop)
	shortcut_buttons.ToggleShortcutButton.set_button(control_buttons.Toggle)
	
	
	var mode_button_groop: ButtonGroup = ButtonGroup.new()
	$VBoxContainer/PanelContainer/HBoxContainer/EditControls/HBoxContainer/NormalMode.button_group = mode_button_groop
	$VBoxContainer/PanelContainer/HBoxContainer/EditControls/HBoxContainer/LoopMode.button_group = mode_button_groop
	
	
	_label_background_stylebox = $VBoxContainer/Controls/HBoxContainer/InfoContainer.get_theme_stylebox("panel").duplicate()
	$VBoxContainer/Controls/HBoxContainer/InfoContainer.add_theme_stylebox_override("panel", _label_background_stylebox)
	
	remove_child(settings_node)
	settings_node.show()
	reload()


func set_edit_mode(edit_mode: bool) -> void:
	_edit_mode = edit_mode
	reload()
	edit_controls.visible = edit_mode


func set_show_title_bar(p_show_title_bar: bool) -> void:
	show_title_bar = p_show_title_bar
	$VBoxContainer/PanelContainer.visible = show_title_bar


func set_show_list(p_show_list: bool) -> void:
	show_list = p_show_list
	$VBoxContainer/List.visible = show_list


func set_show_controls(p_show_controls: bool) -> void:
	show_controls = p_show_controls
	$VBoxContainer/Controls.visible = show_controls


## Adds all the passed buttons to a new ButtonGroup
func _add_to_button_group(buttons: Array) -> ButtonGroup:
	var new_group: ButtonGroup = ButtonGroup.new()
	
	for button: BaseButton in buttons:
		button.toggle_mode = true
		button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		button.button_group = new_group
	
	return new_group


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
	$VBoxContainer/PanelContainer/HBoxContainer/EditControls/HBoxContainer/Duplicate.disabled = state
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
	
	var num_of_fixtures: int = len(selected_fixtures)
	$StoreConfirmationBox/VBoxContainer2/ActionText/NumOfFixtures.text = str(num_of_fixtures)
	
	if num_of_fixtures:
		$NewUpdateConfirmationBox/VBoxContainer2/ActionText/NumOfFixtures.text = str(num_of_fixtures)
	else:
		$NewUpdateConfirmationBox/VBoxContainer2/ActionText/NumOfFixtures.text = "All"
	
	if _edit_mode:
		_highlight_cues_with_stored_fixtures(selected_fixtures)


## Reloads the list of cues
func reload() -> void:
	for old_item: Control in cue_list_container.get_children():
		cue_list_container.remove_child(old_item)
		old_item.queue_free()
	
	
	var old_selected_cue: Cue = _current_selected_cue
	
	_clear_selections()
	_reset_refs()

	if current_cue_list:
		var fade_times: Array = [0]
		var pre_wait_times: Array = [0]
		
		for cue_number: float in current_cue_list.index_list:
			var cue: Cue = current_cue_list.cues[cue_number]
			var new_list_item: ListItem = Interface.components.ListItem.instantiate()

			new_list_item.set_item_name(cue.name)
			new_list_item.set_name_changed_signal(cue.name_changed)
			new_list_item.set_id_tag(str(cue_number))
			
			fade_times.append(cue.fade_time)
			pre_wait_times.append(cue.pre_wait)
			
			if _edit_mode:
				new_list_item.set_name_method(cue.set_name)
				new_list_item.set_id_method(current_cue_list.set_cue_number.bind(cue))
				
				var trigger_mode_option: CueTriggerModeOption = Interface.components.CueTriggerModeOption.instantiate()
				trigger_mode_option.set_cue(cue)
				
				var fade_time_picker: TimerPicker = Interface.components.TimerPicker.instantiate()
				fade_time_picker.value = cue.fade_time
				
				fade_time_picker.value_changed.connect(cue.set_fade_time)
				cue.fade_time_changed.connect(fade_time_picker.set_value_no_signal)
				
				var pre_wait_time_picker: TimerPicker = Interface.components.TimerPicker.instantiate()
				pre_wait_time_picker.value = cue.pre_wait
				
				pre_wait_time_picker.set_icon(load("res://assets/icons/PreWait.svg"))
				pre_wait_time_picker.value_changed.connect(cue.set_pre_wait)
				cue.pre_wait_time_changed.connect(pre_wait_time_picker.set_value_no_signal)
				
				new_list_item.add_chip_node(trigger_mode_option)
				new_list_item.add_chip_node(fade_time_picker)
				new_list_item.add_chip_node(pre_wait_time_picker)
			
			_store_refs(cue_number, new_list_item)
			
			if cue == old_selected_cue:
				new_list_item.set_selected(true)
				last_selected_item = new_list_item
				current_selected_item = new_list_item
			
			if cue_number == current_cue_list.current_cue_number:
				_handle_cue_change(cue_number)
			
			if not cue.data_stored.is_connected(_reload_highlights_signal_callback): cue.data_stored.connect(_reload_highlights_signal_callback)
			if not cue.data_eraced.is_connected(_reload_highlights_signal_callback): cue.data_eraced.connect(_reload_highlights_signal_callback)
			
			new_list_item.select_requested.connect(func(arg1=null):
				_on_select_requested(new_list_item, cue_number))
			
			new_list_item.double_clicked.connect(func(): 
				current_cue_list.seek_to(cue_number)
			)

			cue_list_container.add_child(new_list_item)
		
		_global_cue_fade_time.set_value_no_signal(Utils.get_most_common_value(fade_times))
		_global_cue_pre_wait_time.set_value_no_signal(Utils.get_most_common_value(pre_wait_times))
		global_cue.visible = _edit_mode
		
	_reload_labels()
	_reload_name()
	new_update_button.visible = not _edit_mode
	$VBoxContainer/PanelContainer/HBoxContainer/Store.visible = _edit_mode
	
	if _edit_mode:
		_highlight_cues_with_stored_fixtures(Values.get_selection_value("selected_fixtures", []))


func _clear_selections(arg1=null) -> void:
	last_selected_item = null
	
	if current_selected_item:
		current_selected_item.set_selected(false)
	
	current_selected_item = null
	
	$StoreConfirmationBox/VBoxContainer2/ActionText/CueNumber.text = "null"
	new_update_button.text = "New Cue" if current_cue_list else "New Cue List"
	
	cue_selected.emit(null)


func _reset_refs() -> void:
	object_refs = {}
	cue_refs = {}
	old_index = 0


func _store_refs(cue_number: float, new_list_item: ListItem) -> void:
	object_refs[cue_number] = new_list_item
	cue_refs[new_list_item] = cue_number


func _highlight_cues_with_stored_fixtures(fixtures: Array) -> void:
	for cue_number: float in object_refs.keys():
		var list_item: ListItem = object_refs[cue_number]
		var cue: Cue = current_cue_list.cues[cue_number]
		
		var new_color: Color = _cue_active_color if cue.number == current_cue_list.current_cue_number else _cue_default_color
		
		for fixture: Fixture in fixtures:
			if fixture in cue.stored_data.keys():
				new_color = _cue_highlight_color
				break
		
		list_item.selected_color = new_color
		list_item.color = new_color


func _on_select_requested(new_list_item: ListItem, cue_number: float) -> void:
	if last_selected_item:
		last_selected_item.set_selected(false)
	
	new_list_item.set_selected(true)
	
	current_selected_item = new_list_item
	last_selected_item = new_list_item
	
	if Input.is_key_pressed(KEY_CTRL):
		current_cue_list.seek_to(cue_refs[current_selected_item])
	
	$StoreConfirmationBox/VBoxContainer2/ActionText/CueNumber.text = str(cue_number)
	new_update_button.text = "Update"
	
	cue_selected.emit(_current_selected_cue)


func set_cue_list(cue_list: CueList = null) -> void:
	if not is_node_ready():
		return
	
	if current_cue_list:
		_disconnect_signals()
	
	current_cue_list = cue_list
	
	if current_cue_list:
		_connect_signals()
		_on_mode_changed(current_cue_list.mode)
		new_update_button.text = "New Cue"
	
	reload()


func _disconnect_signals() -> void:
	current_cue_list.name_changed.disconnect(_reload_name)
	current_cue_list.cues_added.disconnect(_on_cues_added)
	current_cue_list.cues_removed.disconnect(_reload_from_signal)
	current_cue_list.cue_numbers_changed.disconnect(_reload_from_signal)
	current_cue_list.cue_changed.disconnect(_handle_cue_change)
	current_cue_list.played.disconnect(_reload_labels)
	current_cue_list.paused.disconnect(_reload_labels)
	current_cue_list.mode_changed.disconnect(_on_mode_changed)


func _connect_signals() -> void:
	current_cue_list.name_changed.connect(_reload_name)
	current_cue_list.cues_added.connect(_on_cues_added)
	current_cue_list.cues_removed.connect(_reload_from_signal)
	current_cue_list.cue_numbers_changed.connect(_reload_from_signal)
	current_cue_list.cue_changed.connect(_handle_cue_change)
	current_cue_list.played.connect(_reload_labels)
	current_cue_list.paused.connect(_reload_labels)
	current_cue_list.mode_changed.connect(_on_mode_changed)


func _on_cues_added(cues: Array) -> void:
	reload()
	await get_tree().process_frame
	_ensure_cue_visible(cues[0].number)


func _reload_from_signal(arg1=null) -> void:
	reload()


func _on_mode_changed(mode: CueList.MODE) -> void:
	match mode:
		0:
			$VBoxContainer/PanelContainer/HBoxContainer/EditControls/HBoxContainer/NormalMode.button_pressed = true
		1:
			$VBoxContainer/PanelContainer/HBoxContainer/EditControls/HBoxContainer/LoopMode.button_pressed = true


func _find_cue_list() -> void:
	if saved_cue_list_uuid in ComponentDB.get_components_by_classname("Function"):
		var found_cue_list: CueList = ComponentDB.components[saved_cue_list_uuid]
		if current_cue_list == null:
			set_cue_list(found_cue_list)


## Saves the settings to a dictionary
func save() -> Dictionary:
	
	var seralized_shortcuts: Dictionary = {}
	
	for shortcut_button_name: String in shortcut_buttons.keys():
		seralized_shortcuts[shortcut_button_name] = shortcut_buttons[shortcut_button_name].save()
	
	var control_visibility: Dictionary = {}
	
	for button_name: String in control_buttons.keys():
		control_visibility[button_name] = control_buttons[button_name].visible
	
	return {
		"cue_list": current_cue_list.uuid if current_cue_list else "",
		"seralized_shortcuts": seralized_shortcuts,
		"control_visibility": control_visibility,
		"show_title_bar": show_title_bar,
		"show_list": show_list,
		"show_controls": show_controls
	}


## Loads settings from what was returned by save()
func load(saved_data: Dictionary) -> void:
	saved_cue_list_uuid = saved_data.get("cue_list", "")
	
	var seralized_shortcuts: Variant = saved_data.get("seralized_shortcuts", null)
	
	if seralized_shortcuts is Dictionary:
		for shortcut_button_name: String in seralized_shortcuts.keys():
			if shortcut_button_name in shortcut_buttons and seralized_shortcuts[shortcut_button_name] is Dictionary:
				shortcut_buttons[shortcut_button_name].load(seralized_shortcuts[shortcut_button_name])
	
	for button_name: String in saved_data.get("control_visibility", {}).keys():
		if button_name in control_buttons:
			control_buttons[button_name].visible = saved_data.control_visibility[button_name]
			visibility_buttons[button_name].set_pressed_no_signal(not saved_data.control_visibility[button_name])
			
	
	show_title_bar = saved_data.get("show_title_bar", show_title_bar)
	show_list = saved_data.get("show_list", show_list)
	show_controls = saved_data.get("show_controls", show_controls)
	
	visibility_buttons.show_title_bar.button_pressed = show_title_bar
	visibility_buttons.show_list.button_pressed = show_list
	visibility_buttons.show_controls.button_pressed = show_controls


## Reloads the status labels
func _reload_labels() -> void:
	labels.cue_number.text = "0"
	labels.cue_number.hide()
	labels.cue_label.hide()
	
	_label_background_stylebox.bg_color = Color.DARK_RED

	if current_cue_list:
		var new_text: String = str(current_cue_list.current_cue_number)
		if current_cue_list.current_cue_number <= 9:
			new_text = "0" + new_text
		
		if current_cue_list.current_cue_number != int(current_cue_list.current_cue_number):
			new_text = new_text.trim_prefix("0")
		
		labels.cue_number.text = new_text
		
		if current_cue_list.current_cue_number == -1:
			labels.cue_number.hide()
			labels.cue_label.hide()
			_label_background_stylebox.bg_color = Color.DARK_RED

		else:
			if current_cue_list.is_playing():
				_label_background_stylebox.bg_color = Color.DARK_GREEN
			else:
				_label_background_stylebox.bg_color = Color.DARK_ORANGE
			
			labels.cue_number.show()
			labels.cue_label.show()


func _reload_name(arg1=null) -> void:
	var new_name: String = current_cue_list.name if current_cue_list else "Empty List"
	$VBoxContainer/PanelContainer/HBoxContainer/CueListName.text = new_name
	settings_name_label.text = new_name


## Called when the current cue is changed
func _handle_cue_change(number: float) -> void:
	if current_cue_list:
		if old_index:
			object_refs[old_index].set_highlighted(false)

		if number in object_refs:
			object_refs[number].set_highlighted(true)
			old_index = number
		
		_ensure_cue_visible(number)
		_reload_labels()


func _ensure_cue_visible(number: float) -> void:
	if not number in object_refs:
		return
	
	var index: int = object_refs.values().find(object_refs[number]) if number != -1 else 0
	var scroll_extra_index: int = clampi(index + _scroll_extra, 0, len(object_refs) - 1)
	
	if index < _scroll_extra:
		scroll_extra_index = index
	
	scroll_container.ensure_control_visible(object_refs.values()[scroll_extra_index])


func _on_change_cue_list_pressed() -> void:
	Interface.show_object_picker(ObjectPicker.SelectMode.Single, _object_picker_callback, ["CueList"])


func _object_picker_callback(object_array: Array[EngineComponent]) -> void:
	if object_array[0] is CueList:
		set_cue_list(object_array[0])


func _on_play_pressed() -> void:
	if current_cue_list:
		current_cue_list.play()


func _on_pause_pressed() -> void:
	if current_cue_list:
		current_cue_list.pause()

func _on_toggle_pressed() -> void:
	if current_cue_list:
		match current_cue_list.is_playing():
			true:
				current_cue_list.stop()
			false:
				current_cue_list.play()


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
		_clear_selections()

#region Store Controls

## Called when the store button in the menue bar is clicked
func _on_store_pressed() -> void:
	if current_cue_list:
		$StoreConfirmationBox.show()

## Called when the cancel button is pressed in the store menu
func _on_cancel_pressed() -> void:
	$StoreConfirmationBox.hide()


## Called when the store button is pressed in the store menu
func _on_store_confirmation_pressed() -> void:
	if current_cue_list:
		var args_needs_cue_number: bool = false
		var save_mode: int = 0
		var store_function: String = ""
		var args: Array = []
		var current_cue_number: float = cue_refs[current_selected_item] if current_selected_item else -1
		
		match save_mode_button_group.get_pressed_button():
			save_mode_buttons.modified_channels:
				save_mode = Programmer.SAVE_MODE.MODIFIED
			
			save_mode_buttons.all_channels:
				save_mode = Programmer.SAVE_MODE.ALL
			
			save_mode_buttons.all_none_zero:
				save_mode = Programmer.SAVE_MODE.ALL_NONE_ZERO
		
		
		match store_function_button_group.get_pressed_button():
			store_function_buttons.merge:
				store_function = "merge_into_cue"
				args_needs_cue_number = true
				
			store_function_buttons.erace:
				store_function = "erace_from_cue"
				args_needs_cue_number = true
				
			store_function_buttons.new_cue:
				store_function = "save_to_new_cue"
		
		args = [
			Values.get_selection_value("selected_fixtures", []), 
			current_cue_list
		]
		
		if args_needs_cue_number:
			args += [current_cue_number]
		
		args += [
			save_mode
		]
		
		Client.send_command("programmer", store_function, args)


## Called when a store function button is pressed
func _on_store_function_changed(button: Button) -> void:
	pass


## Called when a save mode button is pressed
func _on_save_mode_changed(button: Button) -> void:
	pass


## Called when the New / Update button is pressed
func _on_new_update_button_pressed() -> void:
	if not current_cue_list:
		Core.create_component("CueList", "", func (new_cue_list: Function):
			if new_cue_list is CueList:
				set_cue_list(new_cue_list)
		)
	
	else:
		$NewUpdateConfirmationBox.show()


## Called when the cancel button is pressed in the New / Update menu
func _on_new_update_cancel_pressed() -> void:
	$NewUpdateConfirmationBox.hide()


## Called when the store button is pressed in the New / Update menu
func _on_new_update_confirmation_pressed() -> void:
	var fixtures: Array = Values.get_selection_value("selected_fixtures")
	
	if not fixtures:
		fixtures = Core.fixtures.values()
		
	if _current_selected_cue:
		Client.send_command("programmer", "merge_into_cue", [fixtures, current_cue_list, _current_selected_cue.number, Programmer.SAVE_MODE.ALL])
	else:
		Client.send_command("programmer", "save_to_new_cue", [fixtures, current_cue_list, Programmer.SAVE_MODE.ALL])


#region Cue Edit Controls

## Edit Controls
func _on_edit_mode_toggled(toggled_on: bool) -> void:
	set_edit_mode(toggled_on)


func _on_delete_pressed() -> void:
	if current_selected_item:
		current_cue_list.cues[cue_refs[current_selected_item]].delete()


func _on_move_up_pressed() -> void:
	current_cue_list.move_cue_up(cue_refs[current_selected_item])


func _on_move_down_pressed() -> void:
	current_cue_list.move_cue_down(cue_refs[current_selected_item])


func _on_duplicate_pressed() -> void:
	current_cue_list.duplicate_cue(cue_refs[current_selected_item])


func _on_normal_mode_pressed() -> void:
	current_cue_list.set_mode(CueList.MODE.NORMAL)


func _on_loop_mode_pressed() -> void:
	current_cue_list.set_mode(CueList.MODE.LOOP)


func _on_time_code_toggled(toggled_on: bool) -> void:
	$VBoxContainer/Triggers.visible = toggled_on


#endregion


func _on_visible_toggled(toggled_on: bool, button_index: int) -> void:
	control_buttons.values()[button_index].visible = not toggled_on


func _on_status_visible_toggled(toggled_on: bool) -> void:
	$VBoxContainer/Controls/HBoxContainer/InfoContainer.visible = not toggled_on
