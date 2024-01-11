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

@onready var components = {             
	"close_button":ResourceLoader.load("res://Components/Close_button.tscn"),
	"warning":ResourceLoader.load("res://Components/Warning.tscn"),
	"list_item":ResourceLoader.load("res://Components/List_item.tscn"),
	"accept_dialog":ResourceLoader.load("res://Components/Accept_dialog.tscn"),
	"channel_slider":ResourceLoader.load("res://Components/Channel_slider.tscn")
}

@onready var nodes = {
	# General Nodes
	"popup_window":get_tree().root.get_node("Main/Popups"),
	"save_file_dialog":get_tree().root.get_node("Main/Save File Dialog"),
	"add_node_popup":get_tree().root.get_node("Main/TabContainer/Node Editor/Add Node Popup"),
	"add_widget_popup":get_tree().root.get_node("Main/TabContainer/Console/Console Editor/Add Widget Popup"),
	"widget_settings_menu":get_tree().root.get_node("Main/TabContainer/Console/Widget Settings Menu"),
	"edit_mode_toggle":get_tree().root.get_node("Main/Menu Buttons/Edit Mode"),
	
	# Functions Tab
	"functions":get_tree().root.get_node("Main/TabContainer/Functions"),
	"scenes_list":get_tree().root.get_node("Main/TabContainer/Functions/VBoxContainer/PanelContainer2/HBoxContainer/Scenes/ScrollContainer/VBoxContainer/Scenes"),
	"effects_list":get_tree().root.get_node("Main/TabContainer/Functions/VBoxContainer/PanelContainer2/HBoxContainer/Effects/ScrollContainer/VBoxContainer/Effects"),
	"cues_list":get_tree().root.get_node("Main/TabContainer/Functions/VBoxContainer/PanelContainer2/HBoxContainer/Cues/ScrollContainer/VBoxContainer/Cues"),
	
	# Patch Bay Tab
	"patch_bay":get_tree().root.get_node("Main/TabContainer/Patch Bay"),
	"universe_list":get_tree().root.get_node("Main/TabContainer/Patch Bay/VBoxContainer/HSplitContainer/PanelContainer/ScrollContainer/Universes"),
	"universe_inputs":get_tree().root.get_node("Main/TabContainer/Patch Bay/VBoxContainer/HSplitContainer/PanelContainer2/VSplitContainer/PanelContainer/VBoxContainer/GridContainer/PanelContainer/Universe Inputs"),
	"universe_outputs":get_tree().root.get_node("Main/TabContainer/Patch Bay/VBoxContainer/HSplitContainer/PanelContainer2/VSplitContainer/PanelContainer/VBoxContainer/GridContainer/PanelContainer3/ScrollContainer/Universe Outputs"),
	"channel_overrides_list":get_tree().root.get_node("Main/TabContainer/Patch Bay/VBoxContainer/HSplitContainer/PanelContainer2/VSplitContainer/PanelContainer2/ScrollContainer/Channel Overrides"),
	"universe_controls_cover":get_tree().root.get_node("Main/TabContainer/Patch Bay/VBoxContainer/HSplitContainer/PanelContainer2/Cover"),
	"universe_name":get_tree().root.get_node("Main/TabContainer/Patch Bay/VBoxContainer/HSplitContainer/PanelContainer2/VSplitContainer/PanelContainer/VBoxContainer/PanelContainer/Universe Controls/Universe Name"),
	"universe_controls":get_tree().root.get_node("Main/TabContainer/Patch Bay/VBoxContainer/HSplitContainer/PanelContainer2/VSplitContainer/PanelContainer/VBoxContainer/PanelContainer/Universe Controls"),
	"universe_io_controls":get_tree().root.get_node("Main/TabContainer/Patch Bay/VBoxContainer/HSplitContainer/PanelContainer2/VSplitContainer/PanelContainer/VBoxContainer/GridContainer/PanelContainer2/VBoxContainer/IO Controls"),
	"universe_io_type":get_tree().root.get_node("Main/TabContainer/Patch Bay/VBoxContainer/HSplitContainer/PanelContainer2/VSplitContainer/PanelContainer/VBoxContainer/GridContainer/PanelContainer2/VBoxContainer/IO Type"),
	
	# Fixtures Tab
	"fixtures":get_tree().root.get_node("Main/TabContainer/Fixtures"),
	"virtual_fixture_list":get_tree().root.get_node("Main/TabContainer/Fixtures/VBoxContainer/VSplitContainer/HSplitContainer/PanelContainer/ScrollContainer/Virtual Fixtures"),
	"physical_fixture_list":get_tree().root.get_node("Main/TabContainer/Fixtures/VBoxContainer/VSplitContainer/HSplitContainer/PanelContainer2/ScrollContainer/Physical Fixtures"),
	"fixture_groups_list":get_tree().root.get_node("Main/TabContainer/Fixtures/VBoxContainer/VSplitContainer/PanelContainer2/ScrollContainer/Fixture Groups"),
	
	# Add Fixture Menue
	"add_fixture_menu":get_tree().root.get_node("Main/Add Fixture"),
	"fixture_tree":get_tree().root.get_node("Main/Add Fixture/TabContainer/MarginContainer/HSplitContainer/Fixture Tree"),
	"fixture_channel_list":get_tree().root.get_node("Main/Add Fixture/TabContainer/MarginContainer/HSplitContainer/PanelContainer/VBoxContainer/Channel List"),
	"fixture_modes_option":get_tree().root.get_node("Main/Add Fixture/TabContainer/MarginContainer/HSplitContainer/PanelContainer/VBoxContainer/HBoxContainer4/Modes"),
	"fixture_universe_option":get_tree().root.get_node("Main/Add Fixture/TabContainer/MarginContainer/HSplitContainer/PanelContainer/VBoxContainer/HBoxContainer3/Fixture Universe Option"),
	"add_fixture_button":get_tree().root.get_node("Main/Add Fixture/TabContainer/MarginContainer/HSplitContainer/PanelContainer/VBoxContainer/HBoxContainer2/Add Fixture Button"),
	
	# Desk
	"desk":get_tree().root.get_node("Main/TabContainer/Desk"),
	"desk_channel_container":get_tree().root.get_node("Main/TabContainer/Desk/VSplitContainer/PanelContainer/VBoxContainer/PanelContainer2/ScrollContainer/Channel Container"),
	"desk_universe_option":get_tree().root.get_node("Main/TabContainer/Desk/VSplitContainer/PanelContainer/VBoxContainer/PanelContainer/HBoxContainer/Desk Universe Option"),
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

func new_uuid():
	return uuid_util.v4()

func set_desk_data(universe, data):
	art_net_sender.send_artnet_packet(0, data)

func reload_universe_io_connections(io={}):
	if io:
		print(io)
	else:
		print(universes)

func _ready():
	art_net_sender.target_ip = "192.168.1.53"
	art_net_sender.connect_to_host()
	var dmx = []
	dmx.resize(512)
	dmx.fill(255)
	art_net_sender.send_packet(0, dmx)

func new_universe():
	var new_universe = Universe.new()
	universes[new_universe.get_uuid()] = new_universe
	return new_universe

func delete_universe(universe):
	if typeof(universe) == 4: # String
		universes.erase(universe)
	elif typeof(universe) == 27:
		universes.erase(universe.get_uuid())
	
