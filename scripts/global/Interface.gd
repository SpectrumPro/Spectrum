# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name ClientInterface extends Node
## Main script for the spectrum interface


## Stores all the components found in the folder, stored as {"folder_name": PackedScene}
var components: Dictionary = {
	"ChannelSlider": load("res://components/ChannelSlider/ChannelSlider.tscn"),
	"ColorSlider": load("res://components/ColorSlider/ColorSlider.tscn"),
	"ConfirmationBox": load("res://components/ConfirmationBox/ConfirmationBox.tscn"),
	"CreateComponent": load("res://components/CreateComponent/CreateComponent.tscn"),
	"ComponentNamePopup": load("res://components/ComponentNamePopup/ComponentNamePopup.tscn"),
	"NameDialogBox": load("res://components/NameDialogBox/NameDialogBox.tscn"),
	"DialogBoxContainer": load("res://components/DialogBoxContainer/DialogBoxContainer.tscn"),
	"CueItem": load("res://components/CueItem/CueItem.tscn"),
	"CueTriggerModeOption": load("res://components/CueTriggerModeOption/CueTriggerModeOption.tscn"),
	"DeskItemContainer": load("res://components/DeskItemContainer/DeskItemContainer.tscn"),
	"ItemListView": load("res://components/ItemListView/ItemListView.tscn"),
	"Knob": load("res://components/Knob/Knob.tscn"),
	"ListItem": load("res://components/ListItem/ListItem.tscn"),
	"ObjectPicker": load("res://components/ObjectPicker/ObjectPicker.tscn"),
	"PanelContainer": load("res://components/PanelContainer/PanelContainer.tscn"),
	"PanelPicker": load("res://components/PanelPicker/PanelPicker.tscn"),
	"SettingsContainer": load("res://components/SettingsContainer/SettingsContainer.tscn"),
	"PlaybackRow": load("res://components/PlaybackRow/PlaybackRow.tscn"),
	"PopupWindow": load("res://components/PopupWindow/PopupWindow.tscn"),
	"TimerPicker": load("res://components/TimePicker/TimePicker.tscn"),
	"TriggerButton": load("res://components/TriggerButton/TriggerButton.tscn"),
	"Warning": load("res://components/Warning/Warning.tscn"),
}


## Stores all the panels found in the folder, stored as {"folder_name": PackedScene}
var panels: Dictionary = {
	"AddFixture": load("res://panels/AddFixture/AddFixture.tscn"),
	"AnimationEditor": load("res://panels/AnimationEditor/AnimationEditor.tscn"),
	"ColorPalette": load("res://panels/ColorPalette/ColorPalette.tscn"),
	"ColorBlock": load("res://panels/ColorBlock/ColorBlock.tscn"),
	"ColorPicker": load("res://panels/ColorPicker/ColorPicker.tscn"),
	"NewCuePlayback": load("res://panels/NewCuePlayback/NewCuePlayback.tscn"),
	"CuePlayback": load("res://panels/CuePlayback/CuePlayback.tscn"),
	"CueListTable": load("res://panels/CueListTable/CueListTable.tscn"),
	"DataContainerTable": load("res://panels/DataContainerTable/DataContainerTable.tscn"),
	"Clock": load('res://panels/Clock/Clock.tscn'),
	"Debug": load("res://panels/Debug/Debug.tscn"),
	"Desk": load("res://panels/Desk/Desk.tscn"),
	"Fixtures": load("res://panels/Fixtures/Fixtures.tscn"),
	"Functions": load("res://panels/Functions/Functions.tscn"),
	"IOControls": load("res://panels/IOControls/IOControls.tscn"),
	"Image": load("res://panels/Image/Image.tscn"),
	"Settings": load("res://panels/Settings/Settings.tscn"),
	"PlaybackButtons": load("res://panels/PlaybackButtons/PlaybackButtons.tscn"),
	"Playbacks": load("res://panels/Playbacks/Playbacks.tscn"),
	"Pad": load("res://panels/Pad/Pad.tscn"),
	"NewProgrammer": load("res://panels/NewProgrammer/NewProgrammer.tscn"),
	"Programmer": load("res://panels/Programmer/Programmer.tscn"),
	"SaveLoad": load("res://panels/SaveLoad/SaveLoad.tscn"),
	"Universes": load("res://panels/Universes/Universes.tscn"),
	"VirtualFixtures": load("res://panels/VirtualFixtures/VirtualFixtures.tscn")
}


## Panels sorted into categories
var sorted_panels: Dictionary = {
	"Playbacks": ["NewCuePlayback", "CuePlayback", "PlaybackButtons", "Playbacks", "Pad"],
	"Editors": ["AnimationEditor", "ColorPalette", "ColorPicker", "Fixtures", "Functions", "Universes", "AddFixture", "CueListTable", "DataContainerTable"],
	"Utilities": ["Debug", "SaveLoad", "Settings", "IOControls", "Desk", "Programmer", "NewProgrammer"],
	"Visualization": ["VirtualFixtures"],
	"Widgets": ["Clock", "ColorBlock", "Image"],
}


## Stores all panel icons
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


## Stores the default icons for all the classes
var icon_class_list: Dictionary = {
	"EngineComponent": load("res://assets/icons/Component.svg"),
	"Universe": load("res://assets/icons/Universe.svg"),
	"DMXFixture": load("res://assets/icons/DMXFixture.svg"),
	"Fixture": load("res://assets/icons/Fixture.svg"),
	"FixtureGroup": load("res://assets/icons/FixtureGroup.svg"),
	"Programmer": load("res://assets/icons/Programmer.svg"),
	"Cue": load("res://assets/icons/Cue.svg"),
	"Scene": load("res://assets/icons/Scene.svg"),
	"CueList": load("res://assets/icons/CueList.svg"),
	"DataPalette": load("res://assets/icons/Palette.svg"),
	"DMXOutput": load("res://assets/icons/DMXOutput.svg"),
	"ArtNetOutput": load("res://assets/icons/ArtNet.svg"),
	"Function": load("res://assets/icons/Function.svg"),
}


## Home Path
var home_path := OS.get_environment("USERPROFILE") if OS.has_feature("windows") else OS.get_environment("HOME")

## The location for storing all the save show files
var ui_library_location: String = "user://UILibrary"


## The main object picker
var _object_picker: ObjectPicker

## The currently connected callable connected to the object picker
var _object_picker_selected_signal_connection: Callable

## The main panel picker
var _panel_picker: PanelPicker

## The panel pickers promise callback
var _panel_picker_promise: Promise = Promise.new()

## The CreateComponent popup
var _create_component_popup: CreateComponent

## The CreateComponent popup promise callback
var _create_component_promise: Promise = Promise.new()

## The NamePickerComponent popup
var _name_popup: NamePickerComponent

## The container that stores all dialog boxes
var _dialog_box_container: DialogBoxContainer

## The container for cusoem popups
var _custom_popup_container: Control


func _ready() -> void:
	OS.set_low_processor_usage_mode(true)
	
	if not DirAccess.dir_exists_absolute(ui_library_location):
		print("The folder \"ui_library_location\" does not exist, creating one now, errcode: ", DirAccess.make_dir_absolute(ui_library_location))
	
	ComponentDB.request_class_callback("Fixture", func (added: Array, removed: Array):
		Values.remove_from_selection_value("selected_fixtures", removed)
	)
	
	Core.resetting.connect(_on_engine_resetting)
	
	_try_auto_load.call_deferred()
	_set_up_custom_popups()
	_set_up_custom_pickers()


## Called for all notifications
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		show_confirmation_dialog("Are you sure you want to close the app? Unsaved UI changes will lost.").confirmed.connect(func():
			get_tree().quit()
		)


## Sets-up all the custom picker components
func _set_up_custom_pickers():
	_set_up_object_picker()
	_set_up_panel_picker()
	_set_up_create_component()
	_set_up_name_popup()
	_set_up_dialog_box_container()


## Called when the engine is resetting, Will reload the whole ui layout
func _on_engine_resetting() -> void:
	for popup: Control in _custom_popup_container.get_children():
		_custom_popup_container.remove_child(popup)
		popup.queue_free()
	
	_set_up_custom_pickers()
	get_tree().change_scene_to_file("res://Main.tscn")
	
	# For some reason we need to wait 2 frames for SceneTree.change_scene_to_file to finish and load the new nodes
	await get_tree().process_frame
	await get_tree().process_frame
	
	_custom_popup_container.move_to_front()
	_try_auto_load()

## Sets up the custom popup container
func _set_up_custom_popups() -> void:
	_custom_popup_container = Control.new()
	
	_custom_popup_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	_custom_popup_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	get_tree().root.add_child.call_deferred(_custom_popup_container)


## Sets up the object picker
func _set_up_object_picker() -> void:
	_object_picker = load("res://components/ObjectPicker/ObjectPicker.tscn").instantiate()
	
	_object_picker.set_anchors_preset(Control.PRESET_CENTER)
	_object_picker.custom_minimum_size = Vector2(820, 430)
	
	_object_picker.selection_canceled.connect(func () -> void:
		_object_picker.selection_confirmed.disconnect(_object_picker_selected_signal_connection)
		_object_picker_selected_signal_connection = Callable()
		hide_custom_popup(_object_picker)
	)
	
	add_custom_popup(_object_picker)


## Sets up the panel picker
func _set_up_panel_picker() -> void:
	_panel_picker = components.PanelPicker.instantiate()
	
	_panel_picker.set_anchors_preset(Control.PRESET_CENTER)
	_panel_picker.custom_minimum_size = Vector2(820, 630)
	
	_panel_picker.panel_chosen.connect(func (panel: PackedScene):
		_panel_picker_promise.resolve([panel])
		hide_custom_popup(_panel_picker)
	)
	_panel_picker.cancel_pressed.connect(hide_custom_popup.bind(_panel_picker))
	
	add_custom_popup(_panel_picker)


## Sets up the component creator
func _set_up_create_component() -> void:
	_create_component_popup = components.CreateComponent.instantiate()
	
	_create_component_popup.set_anchors_preset(Control.PRESET_CENTER)
	_create_component_popup.custom_minimum_size = Vector2(820, 630)
	
	_create_component_popup.component_created.connect(func (component: EngineComponent):
		_create_component_promise.resolve([component])
		hide_custom_popup(_create_component_popup)
	)
	_create_component_popup.class_confirmed.connect(func (classname: String):
		_create_component_promise.resolve([classname])
		hide_custom_popup(_create_component_popup)
	)
	_create_component_popup.canceled.connect(hide_custom_popup.bind(_create_component_popup))
	
	add_custom_popup(_create_component_popup)


## Sets up the component name popup
func _set_up_name_popup() -> void:
	_name_popup = components.ComponentNamePopup.instantiate()
	_name_popup.set_anchors_preset(Control.PRESET_CENTER)
	
	_name_popup.component_renamed.connect(func (arg): hide_custom_popup(_name_popup))
	_name_popup.canceled.connect(hide_custom_popup.bind(_name_popup))
	
	add_custom_popup(_name_popup)


## Sets up the dialog box container
func _set_up_dialog_box_container() -> void:
	_dialog_box_container = components.DialogBoxContainer.instantiate()
	add_custom_popup(_dialog_box_container)


## Try auto load the ui
func _try_auto_load() -> void:
	if FileAccess.file_exists(ui_library_location + "/main"):
		var file: String = FileAccess.open(ui_library_location + "/main", FileAccess.READ).get_as_text()
		
		var saved_data = JSON.parse_string(file)
		if saved_data:
			self.load(saved_data)


## Shows the object picker
func show_object_picker(select_mode: ObjectPicker.SelectMode, callback: Callable, filter: Array[String] = []) -> void:
	_object_picker.filter_allow_list = filter
	_object_picker.set_user_filtering(filter == [])
	_object_picker.set_select_mode(select_mode)
	
	if _object_picker_selected_signal_connection.is_valid():
		_object_picker.selection_confirmed.disconnect(_object_picker_selected_signal_connection)
	
	_object_picker_selected_signal_connection = func (selection) -> void:
		hide_custom_popup(_object_picker)
		callback.call(selection)
	
	_object_picker.selection_confirmed.connect(_object_picker_selected_signal_connection, CONNECT_ONE_SHOT)
	
	show_custom_popup(_object_picker)


## Shows the create component popup
func show_create_component(mode: CreateComponent.Mode, class_filter: String) -> Promise:
	_create_component_promise.clear()
	
	_create_component_popup.deselect_all()
	_create_component_popup.set_mode(mode)
	_create_component_popup.set_class_filter(class_filter)
	
	show_custom_popup(_create_component_popup)
	return _create_component_promise


## Shows the ComponentNamePopup
func show_name_prompt(for_component: EngineComponent) -> void:
	_name_popup.set_component(for_component)
	show_custom_popup(_name_popup)


## Shows the panel picker
func show_panel_picker() -> Promise:
	_panel_picker_promise.clear()
	show_custom_popup(_panel_picker)
	return _panel_picker_promise


## Shows a regular confirmation dialog
func show_confirmation_dialog(title: String) -> ConfirmationBox:
	return _dialog_box_container.add_confirmation_dialog(title)


## Shows a regular confirmation dialog
func show_info_dialog(title: String) -> ConfirmationBox:
	return _dialog_box_container.add_info_dialog(title)


## Shows a delete confirmation dialog
func show_delete_confirmation(title: String = "") -> ConfirmationBox:
	return _dialog_box_container.add_delete_confirmation(title)


## Shows a rename dialog
func show_name_dialog(title: String = "", default_text: String = "") -> NameDialogBox:
	return _dialog_box_container.add_name_dialog_box(title, default_text)


## Adds a node as a child to the root. Allowing to create popups
func add_custom_popup(popup: Control) -> void:
	if is_instance_valid(popup):
		if popup.get_parent_control():
			popup.get_parent_control().remove_child(popup)
		
		if popup is UIPanel:
			popup.close_request.connect(hide_custom_popup.bind(popup))
			popup.set_display_mode(UIPanel.DisplayMode.Popup)
		
		popup.hide()
		_custom_popup_container.add_child.call_deferred(popup)


## Removes a custom popup
func remove_custom_popup(popup: Control) -> void:
	if popup in _custom_popup_container.get_children():
		_custom_popup_container.remove_child(popup)


## Shows a custom popup
func show_custom_popup(popup: Control) -> void:
	popup.move_to_front()
	_dialog_box_container.move_to_front()
	popup.show()


## Hides a custom popup
func hide_custom_popup(popup: Control) -> void:
	popup.hide()


## Gets a class icon
func get_class_icon(classname: String) -> Texture2D:
	var icon: Texture2D = icon_class_list.get(classname, null)
	
	if not icon and ClassList.is_class_custom(classname):
		icon = icon_class_list.get(ClassList.get_custon_classes()[classname][-2])
	
	return icon
 

## Saves the current ui layout to a file
func save_to_file():
	Utils.save_json_to_file(ui_library_location, "main", save())


## Saves this ui to a dictionary
func save() -> Dictionary:
	return {
		"main_window": get_tree().root.get_node("Main").save()
	}


## Loads this ui from a dictionary
func load(saved_data: Dictionary) -> void:
	if saved_data.has("main_window") and get_tree().root.has_node("Main"):
		get_tree().root.get_node("Main").load(saved_data.main_window)
