extends Node


@onready var components = {             
	"close_button":ResourceLoader.load("res://Components/Close_button.tscn"),
	"warning":ResourceLoader.load("res://Components/Warning.tscn")
}
@onready var popup_window = get_tree().root.get_node("Main/Popups")
@onready var file_name_dialog = get_tree().root.get_node("Main/File Name Dialog")


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
	"UNKNOWN_ERROR": {
		"title": "Unknown Error",
		"content": "An unknown error occurred",
		"code":0.0
	},
}

func show_popup(content = []):
	for i in content:
		print(i)
		var node_to_add = components.warning.instantiate()
		node_to_add.get_node("HBoxContainer/VBoxContainer/Title").text = i.type.title 
		node_to_add.get_node("HBoxContainer/VBoxContainer/Content").text = i.type.content  + ". errcode: " + str(i.type.code) + ((" from: " + i.from) if i.has("from") else "") 
		node_to_add.get_node("HBoxContainer/VBoxContainer/Time").text = Time.get_time_string_from_system()
		popup_window.get_node("VBoxContainer/PanelContainer/ScrollContainer/Content").add_child(node_to_add)
	
	popup_window.popup()
