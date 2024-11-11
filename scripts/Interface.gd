# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

extends Node
## Main script for the spectrum interface


## Emitted when kiosk_mode is changed
signal kiosk_mode_changed(in_kiosk_mode: bool)


## Stores all the components found in the folder, stored as {"folder_name": PackedScene}
var components: Dictionary = {
	"ChannelSlider": load("res://components/ChannelSlider/ChannelSlider.tscn"),
	"ColorSlider": load("res://components/ColorSlider/ColorSlider.tscn"),
	"ConfirmationBox": load("res://components/ConfirmationBox/ConfirmationBox.tscn"),
	"CueTriggerModeOption": load("res://components/CueTriggerModeOption/CueTriggerModeOption.tscn"),
	"DeskItemContainer": load("res://components/DeskItemContainer/DeskItemContainer.tscn"),
	"ItemListView": load("res://components/ItemListView/ItemListView.tscn"),
	"Knob": load("res://components/Knob/Knob.tscn"),
	"ListItem": load("res://components/ListItem/ListItem.tscn"),
	"ObjectPicker": load("res://components/ObjectPicker/ObjectPicker.tscn"),
	"PanelContainer": load("res://components/PanelContainer/PanelContainer.tscn"),
	"SettingsContainer": load("res://components/SettingsContainer/SettingsContainer.tscn"),
	"PlaybackRow": load("res://components/PlaybackRow/PlaybackRow.tscn"),
	"PopupWindow": load("res://components/PopupWindow/PopupWindow.tscn"),
	"TimerPicker": load("res://components/TimePicker/TimePicker.tscn"),
	"TriggerButton": load("res://components/TriggerButton/TriggerButton.tscn"),
	"VirtualFixture": load("res://components/VirtualFixture/VirtualFixture.tscn"),
	"Warning": load("res://components/Warning/Warning.tscn")
}


## Stores all the panels found in the folder, stored as {"folder_name": PackedScene}
var panels: Dictionary = {
	"AddFixture": load("res://panels/AddFixture/AddFixture.tscn"),
	"AnimationEditor": load("res://panels/AnimationEditor/AnimationEditor.tscn"),
	"ColorPalette": load("res://panels/ColorPalette/ColorPalette.tscn"),
	"ColorBlock": load("res://panels/ColorBlock/ColorBlock.tscn"),
	"ColorPicker": load("res://panels/ColorPicker/ColorPicker.tscn"),
	"CuePlayback": load("res://panels/CuePlayback/CuePlayback.tscn"),
	"Clock": load('res://panels/Clock/Clock.tscn'),
	"Debug": load("res://panels/Debug/Debug.tscn"),
	"Desk": load("res://panels/Desk/Desk.tscn"),
	"Fixtures": load("res://panels/Fixtures/Fixtures.tscn"),
	"Functions": load("res://panels/Functions/Functions.tscn"),
	"IOControls": load("res://panels/IOControls/IOControls.tscn"),
	"Settings": load("res://panels/Settings/Settings.tscn"),
	"PlaybackButtons": load("res://panels/PlaybackButtons/PlaybackButtons.tscn"),
	"Playbacks": load("res://panels/Playbacks/Playbacks.tscn"),
	"Programmer": load("res://panels/Programmer/Programmer.tscn"),
	"SaveLoad": load("res://panels/SaveLoad/SaveLoad.tscn"),
	"Universes": load("res://panels/Universes/Universes.tscn"),
	"VirtualFixtures": load("res://panels/VirtualFixtures/VirtualFixtures.tscn")
}


var panel_icons: Dictionary = {
	"CuePlayback": load("res://assets/panel_icons/CuePlayback.png"),
	"ColorPalette": load("res://assets/panel_icons/ColorPalette.png"),
	"Playbacks": load("res://assets/panel_icons/Playbacks.png"),
	"Programmer": load("res://assets/panel_icons/Programmer.png"),
	"Clock": load("res://assets/panel_icons/Clock.png"),
	"ColorBlock": load("res://assets/panel_icons/ColorBlock.png"),
	"VirtualFixtures": load("res://assets/panel_icons/VirtualFixtures.png"),
	"AnimationEditor": load("res://assets/panel_icons/AnimationEditor.png"),
	"AddFixture": load("res://assets/panel_icons/AddFixture.png"),
	"ColorPicker": load("res://assets/panel_icons/ColorPicker.png"),
	"Debug": load("res://assets/panel_icons/Debug.png"),
	"Fixtures": load("res://assets/panel_icons/Fixtures.png"),
	"Functions": load("res://assets/panel_icons/Functions.png"),
	"IOControls": load("res://assets/panel_icons/IOControls.png"),
	"PlaybackButtons": load("res://assets/panel_icons/PlaybackButtons.png"),
	"SaveLoad": load("res://assets/panel_icons/SaveLoad.png"),
	"Settings": load("res://assets/panel_icons/Settings.png"),
	"Universes": load("res://assets/panel_icons/Universes.png"),
	"Desk": load("res://assets/panel_icons/Desk.png"),
}


## Stores the corresponding panel to access settings for each EngineComponent
var component_settings_panels: Dictionary = {
	"CueList": {"panel": load("res://panels/CuePlayback/CuePlayback.tscn"), "method": "set_cue_list"}
}

## Folder path in which all the components are stored
const components_folder: String = "res://components/"

## Folder path in which all the panels are sotred
const panels_folder: String = "res://panels/"


var home_path := OS.get_environment("USERPROFILE") if OS.has_feature("windows") else OS.get_environment("HOME")
## The location for storing all the save show files
var ui_library_location: String = "user://UILibrary"


## Kiosk mode state, will disable all edit actions in the ui, only allowing showing none-destructive controls to the user
var kiosk_mode: bool = false: set = set_kiosk_mode

## A 4 digit pin used to disable kiosk mode
var kiosk_password: Array[int] = [0, 0, 0, 0]


## The main object picker
var _object_picker: ObjectPicker

## The object pickers window
var _object_picker_base: Control

## The currently connected callable connected to the object picker
var _object_picker_selected_signal_connection: Callable

## All the added root nodes
var _added_root_nodes: Array[Node] = []


func _ready() -> void:
	OS.set_low_processor_usage_mode(true)
	
	if not DirAccess.dir_exists_absolute(ui_library_location):
		print("The folder \"ui_library_location\" does not exist, creating one now, errcode: ", DirAccess.make_dir_absolute(ui_library_location))
	
	Core.fixtures_removed.connect(func (fixtures: Array): 
		Values.remove_from_selection_value("selected_fixtures", fixtures)
	)
	
	Core.resetting.connect(_on_engine_resetting)
	_load()
	
	_set_up_object_picker()
	
	var cli_args: PackedStringArray = OS.get_cmdline_args()
	
	kiosk_mode = "--kiosk" in cli_args
	if kiosk_mode:
		kiosk_mode_changed.emit(kiosk_mode)
		
		var passcode_index: int = cli_args.find("--relay-server") + 1
		
		if passcode_index < cli_args.size() and cli_args[passcode_index].is_valid_ip_address():
			print((cli_args[passcode_index] as String).split() as Array[int])


func _on_engine_resetting() -> void:
	for node: Node in _added_root_nodes:
		remove_child(node)
		node.queue_free()
	_added_root_nodes = []
	
	get_tree().change_scene_to_file("res://Main.tscn")
	_set_up_object_picker()
	
	# For some reason we need to wait 2 frames for SceneTree.change_scene_to_file to finish and load the new nodes
	await get_tree().process_frame
	await get_tree().process_frame
	
	_load()


func _load() -> void:
	_try_auto_load.call_deferred()


func _set_up_object_picker() -> void:
	_object_picker_base = load("res://ObjectPickerDefault.tscn").instantiate()
	_object_picker = _object_picker_base.get_node("ObjectPicker")
	add_root_child(_object_picker_base)
	


func _try_auto_load() -> void:
	if FileAccess.file_exists(ui_library_location + "/main"):
		var file: String = FileAccess.open(ui_library_location + "/main", FileAccess.READ).get_as_text()
		
		var saved_data = JSON.parse_string(file)
		if saved_data:
			self.load(saved_data)


func set_kiosk_mode(p_kiosk_mode: bool) -> void:
	if p_kiosk_mode == kiosk_mode:
		return
	
	kiosk_mode = p_kiosk_mode
	kiosk_mode_changed.emit(kiosk_mode)


## Returnes all the packed scenes in the given folder, a pack scene must be in a folder, with the same name as the folder it is in
func get_packed_scenes_from_folder(folder: String) -> Dictionary:
	var packed_scenes: Dictionary = {}
	var scenes_folder: DirAccess = DirAccess.open(folder)
	
	if scenes_folder:
		_load_matching_scenes_in_folder(folder, packed_scenes)
		
		scenes_folder.list_dir_begin()
		var folder_name: String = scenes_folder.get_next()
		
		while folder_name != "":
			if scenes_folder.current_is_dir() and folder_name != "." and folder_name != "..":
				var subfolder_path: String = folder + "/" + folder_name
				_load_matching_scenes_in_folder(subfolder_path, packed_scenes, folder_name)
				
			folder_name = scenes_folder.get_next()
		
		scenes_folder.list_dir_end()
	
	return packed_scenes


## Finds the packed scene file, and checks if its name matches its parent folder
func _load_matching_scenes_in_folder(current_folder: String, packed_scenes: Dictionary, folder_name: String = "") -> void:
	var dir_access: DirAccess = DirAccess.open(current_folder)
	
	if dir_access:
		dir_access.list_dir_begin()
		var file_name: String = dir_access.get_next()
		
		while file_name != "":
			if file_name.ends_with(".tscn") or file_name.ends_with(".scn"):
				var base_file_name = file_name.get_basename()
				if folder_name == "" or base_file_name == folder_name:
					var file_path: String = current_folder + "/" + file_name
					var scene_resource = ResourceLoader.load(file_path)
					var key_name = base_file_name if folder_name == "" else folder_name
					packed_scenes[key_name] = scene_resource
			
			file_name = dir_access.get_next()
		
		dir_access.list_dir_end()


func show_object_picker(select_mode: ObjectPicker.SelectMode, callback: Callable, filter: Array[String] = []) -> void:
	_object_picker.filter_allow_list = filter
	_object_picker.set_user_filtering(filter == [])
	_object_picker.set_select_mode(select_mode)
	
	if _object_picker_selected_signal_connection.is_valid():
		_object_picker.selection_confirmed.disconnect(_object_picker_selected_signal_connection)
	
	_object_picker_selected_signal_connection = callback
	_object_picker.selection_confirmed.connect(func (selection) -> void:
		_object_picker_base.hide()
		callback.call(selection)
	, CONNECT_ONE_SHOT)
	
	_object_picker.selection_canceled.connect(func () -> void:
		_object_picker.selection_confirmed.disconnect(_object_picker_selected_signal_connection)
		_object_picker_selected_signal_connection = Callable()
		_object_picker_base.hide()
	, CONNECT_ONE_SHOT)
	
	_object_picker_base.move_to_front()
	_object_picker_base.show()


## Adds a node as a child to the root. Allowing to create popups
func add_root_child(node: Node) -> void:
	_added_root_nodes.append(node)
	get_tree().root.add_child.call_deferred(node)



func save() -> Dictionary:
	return {
		"main_window": get_tree().root.get_node("Main").save()
	}


## Saves the current ui layout to a file
func save_to_file():
	Utils.save_json_to_file(ui_library_location, "main", save())


func load(saved_data: Dictionary) -> void:
	if saved_data.has("main_window") and get_tree().root.has_node("Main"):
		get_tree().root.get_node("Main").load(saved_data.main_window)
