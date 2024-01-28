extends Node

const uuid_util = preload('res://Scripts/Classes/Uuid.gd')
const ArtNet = preload('res://Scripts/Classes/Art_net.gd')
const Universe = preload('res://Scripts/Classes/Universe.gd')
var art_net_sender = ArtNet.new()

var node_path = "res://Nodes/"
var widget_path = "res://Widgets/"
var fixture_path = "res://Fixtures/"
var edit_mode = true

var values = {
	"snapping_distance":20,
	"edit_mode":true
}

var subscriptions = {}

var universes = {}
var fixtures = {}
var active_fixtures = {}

@onready var components = {             
	"close_button":ResourceLoader.load("res://Components/Close_button.tscn"),
	"warning":ResourceLoader.load("res://Components/Warning.tscn"),
	"list_item":ResourceLoader.load("res://Components/List_item.tscn"),
	"accept_dialog":ResourceLoader.load("res://Components/Accept_dialog.tscn"),
	"channel_slider":ResourceLoader.load("res://Components/Channel_slider.tscn"),
	"virtual_fixture":ResourceLoader.load("res://Components/Virtual_fixture.tscn")
}

@onready var nodes = {
	# General Nodes
	"popup_window":get_tree().root.get_node("Main/Popups"),
	"save_file_dialog":get_tree().root.get_node("Main/Save File Dialog"),
	"add_node_popup":get_tree().root.get_node("Main/TabContainer/Node Editor/Node Editor/Add Node Popup"),
	"add_widget_popup":get_tree().root.get_node("Main/TabContainer/Console/Console/Console Editor/Add Widget Popup"),
	"widget_settings_menu":get_tree().root.get_node("Main/TabContainer/Console/Console/Widget Settings Menu"),
	"edit_mode_toggle":get_tree().root.get_node("Main/Menu Buttons/Edit Mode"),
	
	#Node Editor
	"node_editor":get_tree().root.get_node("Main/TabContainer/Node Editor/Node Editor"),
	
	#Console
	"console_editor":get_tree().root.get_node("Main/TabContainer/Console/Console/Console Editor"),
	
	
	# Functions Tab
	"functions":get_tree().root.get_node("Main/TabContainer/Functions/Functions"),
	"scenes_list":get_tree().root.get_node("Main/TabContainer/Functions/Functions/VBoxContainer/PanelContainer2/HBoxContainer/Scenes/ScrollContainer/VBoxContainer/Scenes"),
	"effects_list":get_tree().root.get_node("Main/TabContainer/Functions/Functions/VBoxContainer/PanelContainer2/HBoxContainer/Effects/ScrollContainer/VBoxContainer/Effects"),
	"cues_list":get_tree().root.get_node("Main/TabContainer/Functions/Functions/VBoxContainer/PanelContainer2/HBoxContainer/Cues/ScrollContainer/VBoxContainer/Cues"),
	
	# Patch Bay Tab
	"patch_bay":get_tree().root.get_node("Main/TabContainer/Patch Bay/Patch Bay/"),
	"universe_list":get_tree().root.get_node("Main/TabContainer/Patch Bay/Patch Bay/VBoxContainer/HSplitContainer/PanelContainer/ScrollContainer/Universes"),
	"universe_inputs":get_tree().root.get_node("Main/TabContainer/Patch Bay/Patch Bay/VBoxContainer/HSplitContainer/PanelContainer2/VSplitContainer/PanelContainer/VBoxContainer/GridContainer/PanelContainer/Universe Inputs"),
	"universe_outputs":get_tree().root.get_node("Main/TabContainer/Patch Bay/Patch Bay/VBoxContainer/HSplitContainer/PanelContainer2/VSplitContainer/PanelContainer/VBoxContainer/GridContainer/PanelContainer3/ScrollContainer/Universe Outputs"),
	"channel_overrides_list":get_tree().root.get_node("Main/TabContainer/Patch Bay/Patch Bay/VBoxContainer/HSplitContainer/PanelContainer2/VSplitContainer/PanelContainer2/ScrollContainer/Channel Overrides"),
	"universe_name":get_tree().root.get_node("Main/TabContainer/Patch Bay/Patch Bay/VBoxContainer/HSplitContainer/PanelContainer2/VSplitContainer/PanelContainer/VBoxContainer/PanelContainer/Universe Controls/Universe Name"),
	"universe_controls":get_tree().root.get_node("Main/TabContainer/Patch Bay/Patch Bay/VBoxContainer/HSplitContainer/PanelContainer2/VSplitContainer/PanelContainer/VBoxContainer/PanelContainer/Universe Controls"),
	"universe_io_controls":get_tree().root.get_node("Main/TabContainer/Patch Bay/Patch Bay/VBoxContainer/HSplitContainer/PanelContainer2/VSplitContainer/PanelContainer/VBoxContainer/GridContainer/PanelContainer2/VBoxContainer/IO Controls"),
	"universe_io_type":get_tree().root.get_node("Main/TabContainer/Patch Bay/Patch Bay/VBoxContainer/HSplitContainer/PanelContainer2/VSplitContainer/PanelContainer/VBoxContainer/GridContainer/PanelContainer2/VBoxContainer/IO Type"),
	
	# Fixtures Tab
	"fixtures":get_tree().root.get_node("Main/TabContainer/Fixtures/Fixtures/"),
	"physical_fixture_list":get_tree().root.get_node("Main/TabContainer/Fixtures/Fixtures/VBoxContainer/VSplitContainer/PanelContainer3/ScrollContainer/Physical Fixtures"),
	"fixture_groups_list":get_tree().root.get_node("Main/TabContainer/Fixtures/Fixtures/VBoxContainer/VSplitContainer/PanelContainer2/ScrollContainer/Fixture Groups"),
	
	# Add Fixture Menu
	"add_fixture_window":get_tree().root.get_node("Main/Add Fixture"),
	"add_fixture_menu":get_tree().root.get_node("Main/Add Fixture/Add Fixture/"),
	"fixture_tree":get_tree().root.get_node("Main/Add Fixture/Add Fixture/MarginContainer/HSplitContainer/Fixture Tree"),
	"fixture_channel_list":get_tree().root.get_node("Main/Add Fixture/Add Fixture/MarginContainer/HSplitContainer/PanelContainer/VBoxContainer/Channel List"),
	"fixture_modes_option":get_tree().root.get_node("Main/Add Fixture/Add Fixture/MarginContainer/HSplitContainer/PanelContainer/VBoxContainer/HBoxContainer4/Modes"),
	"fixture_universe_option":get_tree().root.get_node("Main/Add Fixture/Add Fixture/MarginContainer/HSplitContainer/PanelContainer/VBoxContainer/HBoxContainer3/Fixture Universe Option"),
	"add_fixture_button":get_tree().root.get_node("Main/Add Fixture/Add Fixture/MarginContainer/HSplitContainer/PanelContainer/VBoxContainer/HBoxContainer2/Add Fixture Button"),
	
	# Desk
	"desk":get_tree().root.get_node("Main/TabContainer/Desk/Desk"),
	"desk_channel_container":get_tree().root.get_node("Main/TabContainer/Desk/Desk/VSplitContainer/PanelContainer/VBoxContainer/PanelContainer2/ScrollContainer/Channel Container"),
	"desk_universe_option":get_tree().root.get_node("Main/TabContainer/Desk/Desk/VSplitContainer/PanelContainer/VBoxContainer/PanelContainer/HBoxContainer/Desk Universe Option"),
	"command_input":get_tree().root.get_node("Main/TabContainer/Desk/Desk/VSplitContainer/PanelContainer/VBoxContainer/PanelContainer/HBoxContainer/Command Input"),
	
	#Virtual Fixtures
	"virtual_fixtures":get_tree().root.get_node("Main/TabContainer/Virtual Fixtures/Virtual Fixtures"),
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

#func _process(_delta):
	#if Input.is_action_just_pressed("process_loop"):
		#for universe in universes.values():
			#print(universe.serialize())

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

func get_value(value_name):
	return values.get(value_name, null)

func call_subscription(value_name):
	if subscriptions.get(value_name):
		for node_to_update in subscriptions[value_name]:
			if node_to_update.is_valid():
				node_to_update.call()


func new_uuid():
	return uuid_util.v4()
	
func reload_universe_io_connections(io={}):
	if io:
		print(io)
	else:
		print(universes)

func _ready():
	pass

func new_universe():
	var universe_to_add = Universe.new()
	universes[universe_to_add.get_uuid()] = universe_to_add
	return universe_to_add

func delete_universe(universe):
	if typeof(universe) == 4: # String
		universes[universe].queue_free()
		universes.erase(universe)
	elif typeof(universe) == 27: 
		universes[universe.get_uuid()].queue_free()
		universes.erase(universe.get_uuid())
	print(universes.keys())

func serialize_universes():
	var serialized_universes = {}
	for universe_uuid in universes:
		serialized_universes[universe_uuid] = universes[universe_uuid].serialize()
	return serialized_universes

func deserialize_universes(new_universes):
	for universe_uuid in new_universes:
		var universe_to_add = Universe.new()
		universe_to_add.from(new_universes[universe_uuid])
		universes[universe_uuid] = universe_to_add
