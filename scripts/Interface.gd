# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends Node
## Main script for the spectrum interface


## Emitted when kiosk_mode is changed
signal kiosk_mode_changed(in_kiosk_mode: bool)


## Stores all the components found in the folder, stored as {"folder_name": PackedScene}
var components: Dictionary = {
	"ChannelSlider": preload("res://components/ChannelSlider/ChannelSlider.tscn"),
	"ColorSlider": preload("res://components/ColorSlider/ColorSlider.tscn"),
	"ConfirmationBox": preload("res://components/ConfirmationBox/ConfirmationBox.tscn"),
	"CueTriggerModeOption": preload("res://components/CueTriggerModeOption/CueTriggerModeOption.tscn"),
	"DeskItemContainer": preload("res://components/DeskItemContainer/DeskItemContainer.tscn"),
	"ItemListView": preload("res://components/ItemListView/ItemListView.tscn"),
	"Knob": preload("res://components/Knob/Knob.tscn"),
	"ListItem": preload("res://components/ListItem/ListItem.tscn"),
	"ObjectPicker": preload("res://components/ObjectPicker/ObjectPicker.tscn"),
	"PanelContainer": preload("res://components/PanelContainer/PanelContainer.tscn"),
	"PanelSettingsContainer": preload("res://components/PanelSettingContainer/PanelSettingsContainer.tscn"),
	"PlaybackRow": preload("res://components/PlaybackRow/PlaybackRow.tscn"),
	"PopupWindow": preload("res://components/PopupWindow/PopupWindow.tscn"),
	"TimerPicker": preload("res://components/TimePicker/TimePicker.tscn"),
	"TriggerButton": preload("res://components/TriggerButton/TriggerButton.tscn"),
	"VirtualFixture": preload("res://components/VirtualFixture/VirtualFixture.tscn"),
	"Warning": preload("res://components/Warning/Warning.tscn")
}


## Stores all the panels found in the folder, stored as {"folder_name": PackedScene}
var panels: Dictionary = {
	"AddFixture": preload("res://panels/AddFixture/AddFixture.tscn"),
	"AnimationEditor": preload("res://panels/AnimationEditor/AnimationEditor.tscn"),
	"ColorPalette": preload("res://panels/ColorPalette/ColorPalette.tscn"),
	"ColorBlock": preload("res://panels/ColorBlock/ColorBlock.tscn"),
	"ColorPicker": preload("res://panels/ColorPicker/ColorPicker.tscn"),
	"CuePlayback": preload("res://panels/CuePlayback/CuePlayback.tscn"),
	"Clock": preload('res://panels/Clock/Clock.tscn'),
	"Debug": preload("res://panels/Debug/Debug.tscn"),
	"Desk": preload("res://panels/Desk/Desk.tscn"),
	"Fixtures": preload("res://panels/Fixtures/Fixtures.tscn"),
	"Functions": preload("res://panels/Functions/Functions.tscn"),
	"IOControls": preload("res://panels/IOControls/IOControls.tscn"),
	"Settings": preload("res://panels/Settings/Settings.tscn"),
	"PlaybackButtons": preload("res://panels/PlaybackButtons/PlaybackButtons.tscn"),
	"Playbacks": preload("res://panels/Playbacks/Playbacks.tscn"),
	"Programmer": preload("res://panels/Programmer/Programmer.tscn"),
	"SaveLoad": preload("res://panels/SaveLoad/SaveLoad.tscn"),
	"Universes": preload("res://panels/Universes/Universes.tscn"),
	"VirtualFixtures": preload("res://panels/VirtualFixtures/VirtualFixtures.tscn")
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
var _object_picker: Control

## The object pickers window
var _object_picker_window: Window

## The currently connected callable connected to the object picker
var _object_picker_selected_signal_connection: Callable

## The currently connected deselected callable connected to the object picker
var _object_picker_deselected_signal_connection: Callable


func _ready() -> void:
	OS.set_low_processor_usage_mode(true)
	1
	if not DirAccess.dir_exists_absolute(ui_library_location):
		print("The folder \"ui_library_location\" does not exist, creating one now, errcode: ", DirAccess.make_dir_absolute(ui_library_location))
	
	Core.fixtures_removed.connect(func (fixtures: Array): 
		Values.remove_from_selection_value("selected_fixtures", fixtures)
	)
	
	Core.resetting.connect(_on_engine_resetting)
	_load()
	
	var cli_args: PackedStringArray = OS.get_cmdline_args()
	
	kiosk_mode = "--kiosk" in cli_args
	if kiosk_mode:
		kiosk_mode_changed.emit(kiosk_mode)
		
		var passcode_index: int = cli_args.find("--relay-server") + 1
		
		if passcode_index < cli_args.size() and cli_args[passcode_index].is_valid_ip_address():
			print((cli_args[passcode_index] as String).split() as Array[int])


func _on_engine_resetting() -> void:
	get_tree().change_scene_to_file("res://Main.tscn")
	
	# For some reason we need to wait 2 frames for SceneTree.change_scene_to_file to finish and load the new nodes
	await get_tree().process_frame
	await get_tree().process_frame
	
	_load()


func _load() -> void:
	_set_up_object_picker()
	_try_auto_load.call_deferred()


func _try_auto_load() -> void:
	if FileAccess.file_exists(ui_library_location + "/main"):
		var file: String = FileAccess.open(ui_library_location + "/main", FileAccess.READ).get_as_text()
		
		var saved_data = JSON.parse_string(file)
		if saved_data:
			self.load(saved_data)


## loads all the objects into the object picker
func _set_up_object_picker() -> void:
	if not get_tree().root.has_node("Main"):
		return
	_object_picker_window = get_tree().root.get_node("Main").get_node("ObjectPickerWindow")
	_object_picker = get_tree().root.get_node("Main").get_node("ObjectPickerWindow/ObjectPicker")
	_object_picker.load_objects(panels, "Panels")
	
	Core.universes_added.connect(func (arg1=null): _object_picker.load_objects(Core.universes, "Universes", "name"))
	Core.universes_removed.connect(func (arg1=null): _object_picker.load_objects(Core.universes, "Universes", "name"))
	Core.universe_name_changed.connect(func (arg1=null, arg2=null): _object_picker.load_objects(Core.universes, "Universes", "name"))
	
	Core.fixtures_added.connect(func (arg1=null): _object_picker.load_objects(Core.fixtures, "Fixtures", "name"))
	Core.fixtures_removed.connect(func (arg1=null): _object_picker.load_objects(Core.fixtures, "Fixtures", "name"))
	Core.universe_name_changed.connect(func (arg1=null, arg2=null): _object_picker.load_objects(Core.fixtures, "Fixtures", "name"))
	
	Core.functions_added.connect(func (arg1=null): _object_picker.load_objects(Core.functions, "Functions", "name"))
	Core.functions_removed.connect(func (arg1=null): _object_picker.load_objects(Core.functions, "Functions", "name"))
	Core.function_name_changed.connect(func (arg1=null, arg2=null): _object_picker.load_objects(Core.functions, "Functions", "name"))
	
	_object_picker.closed.connect(hide_object_picker)



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



func show_object_picker(callback: Callable, filter: Array[String] = [], allow_multi_select: bool = false, deselect_callback: Callable = Callable(), selection: Array = []) -> void:
	_object_picker.set_filter(filter)
	_object_picker.set_multi_select(allow_multi_select)
	_object_picker.set_selected(selection)
	
	_object_picker_window.show()
	
	_object_picker_selected_signal_connection = func (key: Variant, value: Variant):
		callback.call(key, value)
		
		if not allow_multi_select:
			_object_picker_window.hide()
	
	_object_picker_deselected_signal_connection = func (key: Variant, value: Variant):
		deselect_callback.call(key, value)
	
	_object_picker.item_selected.connect(_object_picker_selected_signal_connection, CONNECT_PERSIST if allow_multi_select else CONNECT_ONE_SHOT)
	
	if deselect_callback.is_valid():
		_object_picker.item_deselected.connect(_object_picker_deselected_signal_connection, CONNECT_PERSIST if allow_multi_select else CONNECT_ONE_SHOT)
		

## Hides the object picker
func hide_object_picker() -> void:
	_object_picker_window.hide()
	if _object_picker_selected_signal_connection.is_valid() and _object_picker.item_selected.is_connected(_object_picker_selected_signal_connection):
		_object_picker.item_selected.disconnect(_object_picker_selected_signal_connection)
		
	if _object_picker_deselected_signal_connection.is_valid() and _object_picker.item_deselected.is_connected(_object_picker_deselected_signal_connection):
		_object_picker.item_deselected.disconnect(_object_picker_deselected_signal_connection)


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
