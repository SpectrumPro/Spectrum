extends Node

var node_path = "res://Nodes/"
var widget_path = "res://Widgets/"
var edit_mode = true

var values = {
	"snapping_distance":20,
	"edit_mode":true
}

var subscriptions = {}

@onready var components = {             
	"close_button":ResourceLoader.load("res://Components/Close_button.tscn"),
	"warning":ResourceLoader.load("res://Components/Warning.tscn"),
	"function_list_item":ResourceLoader.load("res://Components/Function_list_item.tscn")
}
@onready var nodes = {
	"popup_window":get_tree().root.get_node("Main/Popups"),
	"save_file_dialog":get_tree().root.get_node("Main/Save File Dialog"),
	"add_node_popup":get_tree().root.get_node("Main/TabContainer/Node Editor/Add Node Popup"),
	"add_widget_popup":get_tree().root.get_node("Main/TabContainer/Console/Console Editor/Add Widget Popup"),
	"widget_settings_menu":get_tree().root.get_node("Main/TabContainer/Console/Widget Settings Menu"),
	"edit_mode_toggle":get_tree().root.get_node("Main/Menu Buttons/Edit Mode"),
	"scenes_list":get_tree().root.get_node("Main/TabContainer/Functions/VBoxContainer/PanelContainer2/HBoxContainer/Scenes/ScrollContainer/VBoxContainer/Scenes"),
	"effects_list":get_tree().root.get_node("Main/TabContainer/Functions/VBoxContainer/PanelContainer2/HBoxContainer/Effects/ScrollContainer/VBoxContainer/Effects"),
	"cues_list":get_tree().root.get_node("Main/TabContainer/Functions/VBoxContainer/PanelContainer2/HBoxContainer/Cues/ScrollContainer/VBoxContainer/Cues"),
	"functions":get_tree().root.get_node("Main/TabContainer/Functions")
}

@onready var icons = {
	"menue":load("res://Assets/Icons/menu.svg"),
	"center":load("res://Assets/Icons/Center.svg")
	
}

@onready var shaders = {
	"invert":load("res://Assets/Shaders/Invert.tres"),
}

@onready var error = {
	"MANIFEST_MISSING_MANIFEST_VERSION": {
		"title": "Manifest missing version",
		"content": "Manifest is missing required 'manifest_version' field",
		"code":1.1
	},
	"MANIFEST_MISSING_MINIMUM_VERSION": {
		"title": "Manifest missing minimum Spectrum version",
		"content": "Manifest is missing required 'minimum_version' field",
		"code":1.2
	},
	"MANIFEST_MISSING_VERSION": {
		"title": "Manifest missing version",
		"content": "Manifest is missing required 'version' field",
		"code":1.3
	},
	"MANIFEST_MISSING_NODES": {
		"title": "Manifest missing nodes",
		"content": "Manifest is missing required 'nodes' field",
		"code":1.4
	},
	"MANIFEST_MISSING_WIDGET": {
		"title": "Manifest missing widgets",
		"content": "Manifest is missing required 'widgets' field",
		"code":1.4
	},
	"MANIFEST_MISSING_METADATA": {
		"title": "Manifest missing metadata",
		"content": "Manifest is missing required 'metadata' field",
		"code":1.5
	},
	"MANIFEST_MISSING_UUID": {
		"title": "Manifest missing uuid",
		"content": "Manifest is missing required 'uuid' field",
		"code":1.6
	},
	"UNABLE_TO_LOAD_MANIFEST": {
		"title": "An error occurred while attempting to load manifest",
		"content": "An unknown error occurred while attempting to load the manifest, most likely due to a JSON formatting issue.",
		"code":2.1
	},
	"UNABLE_TO_LOAD_SCENE": {
		"title": "An error occurred while attempting to load a scene",
		"content": "An unknown error occurred while attempting to load a scene",
		"code":2.2
	},
	"UNABLE_TO_LOAD_SCRIPT": {
		"title": "An error occurred while attempting to load a script",
		"content": "An unknown error occurred while attempting to load a script",
		"code":2.3
	},
	"NODE_SAVE_MANIFEST_ERROR": {
		"title": "Manifest Error During Node Save",
		"content": "Unable to save a node due to a manifest issue, likely caused by a problem with the 'values' list",
		"code": 2.4
	},
	"MISSING_NODES": {
		"title": "Save File Contains Missing Nodes",
		"content": "Unable to load save file, as it containes nodes that are not installed on this system",
		"code": 2.5
	},
	"UNABLE_TO_LOAD_FILE": {
		"title": "Unable To Load File",
		"content": "Unable to load a file, file may not exist",
		"code": 2.6
	},
	"WIDGET_LOAD_MANIFEST_ERROR": {
		"title": "Manifest Error During Widget Load",
		"content": "Unable to load a widget due to a manifest issue, likely caused by a problem with the 'values' list",
		"code": 2.7
	},
	"UNKNOWN_ERROR": {
		"title": "Unknown Error",
		"content": "An unknown error occurred",
		"code":0.0
	},
}

func show_popup(content = []):
	for i in content:
		var node_to_add = components.warning.instantiate()
		node_to_add.get_node("HBoxContainer/VBoxContainer/Title").text = i.type.title 
		node_to_add.get_node("HBoxContainer/VBoxContainer/Content").text = i.type.content  + ". errcode: " + str(i.type.code) + ((" from: " + i.from) if i.has("from") else "") 
		node_to_add.get_node("HBoxContainer/VBoxContainer/Time").text = Time.get_time_string_from_system()
		nodes.popup_window.get_node("VBoxContainer/PanelContainer/ScrollContainer/Content").add_child(node_to_add)
	
	nodes.popup_window.popup()

func subscribe(value, callback):
	if value in subscriptions:
		subscriptions[value].append(callback)
	else:
		subscriptions[value] = []
		subscriptions[value].append(callback)

func set_value(value_name, value):
	values[value_name] = value
	if subscriptions.get(value_name):
		for node_to_update in subscriptions[value_name]:
			if node_to_update.is_valid():
				node_to_update.call(value)
