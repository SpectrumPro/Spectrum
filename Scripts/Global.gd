extends Node


var node_path := "res://Nodes/"
var widget_path := "res://Widgets/"
var fixture_path := "res://Fixtures/"
var io_plugin_path := "res://IO Plugins/"
var edit_mode := true

var values := {
	"snapping_distance":20,
	"edit_mode":true,
	"active_fixtures":[]
}

var subscriptions := {}

var universes := {}
var fixtures := {}
var active_fixtures := {}

var configFile : ConfigFile

var input_plugins : Dictionary
var output_plugins : Dictionary

@onready var _root_node : Control = get_tree().root.get_node("Main")

@onready var components := {             
	"close_button":ResourceLoader.load("res://Components/Close Button/Close_button.tscn"),
	"warning":ResourceLoader.load("res://Components/Warning/Warning.tscn"),
	"list_item":ResourceLoader.load("res://Components/List Item/List_item.tscn"),
	"accept_dialog":ResourceLoader.load("res://Components/Accept Dialog/Accept_dialog.tscn"),
	"channel_slider":ResourceLoader.load("res://Components/Channel Slider/Channel_slider.tscn"),
	"virtual_fixture":ResourceLoader.load("res://Components/Virtual Fixture/Virtual_fixture.tscn"),
	"window":ResourceLoader.load("res://Components/Window/Window.tscn"),
	"trigger_button":ResourceLoader.load("res://Components/Trigger Button/TriggerButton.tscn"),
	"file_load_menu": ResourceLoader.load("res://Components/File Load Menu/FileLoadMenu.tscn"),
	"file_save_menu": ResourceLoader.load("res://Components/File Save Menu/FileSaveMenu.tscn")
}

@onready var panels : Dictionary = {             
	"3d":ResourceLoader.load("res://Panels/3D/3d.tscn"),
	"add_fixture":ResourceLoader.load("res://Panels/Add Fixture/Add_fixture.tscn"),
	"console":ResourceLoader.load("res://Panels/Console/Console.tscn"),
	"desk":ResourceLoader.load("res://Panels/Desk/Desk.tscn"),
	"fixtures":ResourceLoader.load("res://Panels/Fixtures/Fixtures.tscn"),
	"node_editor":ResourceLoader.load("res://Panels/Node Editor/Node_editor.tscn"),
	"settings":ResourceLoader.load("res://Panels/Settings/Settings.tscn"),
	"virtual_fixtures":ResourceLoader.load("res://Panels/Virtual Fixtures/Virtual_fixtures.tscn"),
	"window_control":ResourceLoader.load("res://Panels/Window Control/Window_control.tscn"),
}

@onready var icons := {
	"menue":load("res://Assets/Icons/menu.svg"),
	"center":load("res://Assets/Icons/Center.svg")
	
}

@onready var shaders := {
	"invert":load("res://Assets/Shaders/Invert.tres"),
}

@onready var error := {
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

func _ready() -> void:
	OS.set_low_processor_usage_mode(true)
	#load_fixtures()
	
#func load_io_plugins() -> void:
	#var output_plugin_folder : DirAccess = DirAccess.open(io_plugin_path + "Output Plugins")
	#for plugin in output_plugin_folder.get_files():
		#var uninitialized_plugin = ResourceLoader.load(io_plugin_path + "Output Plugins" + "/" + plugin)
		#var initialized_plugin = uninitialized_plugin.new()
		#var plugin_name: String = initialized_plugin.get_name()
		#
		#if plugin_name in output_plugins.keys():
			#plugin_name = plugin_name +  " " + new_uuid()
		#
		#output_plugins[plugin_name] = uninitialized_plugin 
		#initialized_plugin.free()
#
#func load_fixtures() -> void:
	#var access = DirAccess.open(fixture_path)
	#
	#for fixture_folder in access.get_directories():
		#
		#for fixture in access.open(fixture_path+"/"+fixture_folder).get_files():
			#
			#var manifest_file = FileAccess.open(fixture_path+fixture_folder+"/"+fixture, FileAccess.READ)
			#var manifest = JSON.parse_string(manifest_file.get_as_text())
			#
			#manifest.info.file_path = fixture_path+fixture_folder+"/"+fixture
			#
			#if fixtures.has(manifest.info.brand):
				#fixtures[manifest.info.brand][manifest.info.name] = manifest
			#else:
				#fixtures[manifest.info.brand] = {manifest.info.name:manifest}
#
#func show_popup(content: Array[Dictionary] = []) -> void:
	#for i in content:
		#var node_to_add = components.warning.instantiate()
		#node_to_add.get_node("HBoxContainer/VBoxContainer/Title").text = i.type.title 
		#node_to_add.get_node("HBoxContainer/VBoxContainer/Content").text = i.type.content  + ". errcode: " + str(i.type.code) + ((" from: " + i.from) if i.has("from") else "") 
		#node_to_add.get_node("HBoxContainer/VBoxContainer/Time").text = Time.get_time_string_from_system()
		#nodes.popup_window.get_node("VBoxContainer/PanelContainer/ScrollContainer/Content").add_child(node_to_add)
	#
	#nodes.popup_window.popup()

func subscribe(value_name:String, callback:Callable) -> void:
	if value_name in subscriptions:
		subscriptions[value_name].append(callback)
	else:
		subscriptions[value_name] = []
		subscriptions[value_name].append(callback)

func set_value(value_name:String, value:Variant) -> void:
	values[value_name] = value
	if subscriptions.get(value_name):
		for function_to_call in subscriptions[value_name]:
			if function_to_call.is_valid():
				function_to_call.call(value)

func get_value(value_name:String) -> Variant:
	return values.get(value_name, null)

func call_subscription(value_name:String) -> void:
	if subscriptions.get(value_name):
		for node_to_update in subscriptions[value_name]:
			if node_to_update.is_valid():
				node_to_update.call()

#func new_uuid() -> String:
	#return UUID_Util.v4()
#
#func select_fixture(fixture_to_add:Fixture) -> Array:
	#
	#var active_fixtures = get_value("active_fixtures")
	#if fixture_to_add not in active_fixtures:
		#active_fixtures.append(fixture_to_add)
#
		#set_value("active_fixtures", active_fixtures)
#
	#return active_fixtures
	#
#func deselect_fixture(fixture_to_remove:Fixture) -> Array:
	#var active_fixtures = get_value("active_fixtures")
	#active_fixtures.erase(fixture_to_remove)
	#
	#set_value("active_fixtures", active_fixtures)
	#return active_fixtures
	#
#func new_universe() -> Universe:
	#var new_universe = Universe.new()
	#universes[new_universe.get_uuid()] = new_universe
	#return new_universe
#
#func delete_universe(universe:Universe) -> void: 
	#universe.delete()
	#universes.erase(universe.get_uuid())
	#universe.free()
	#
	#call_subscription("reload_universes")
	#call_subscription("reload_fixtures")
#
#func serialize_universes() -> Dictionary:
	#var serialized_universes = {}
	#for universe_uuid in universes:
		#serialized_universes[universe_uuid] = universes[universe_uuid].serialize()
	#return serialized_universes
#
#func deserialize_universes(new_universes:Dictionary):
	#for universe_uuid in new_universes:
		#var universe_to_add = Universe.new()
		#universe_to_add.from(new_universes[universe_uuid])
		#universes[universe_uuid] = universe_to_add

func open_panel_in_window(panel_name:String) -> Variant:
	if panel_name in panels:
		var new_window_node : Window = components.window.instantiate()
		new_window_node.add_child(panels[panel_name].instantiate())
		_root_node.add_child(new_window_node)
		return new_window_node
	else: 
		return false
