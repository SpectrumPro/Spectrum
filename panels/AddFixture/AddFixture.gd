# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name UIAddFixture extends UIPanel
## UI panel for adding fixtures

@export var fixture_tree: NodePath
@export var fixture_channel_list: NodePath
@export var fixture_modes_option: NodePath
@export var fixture_universe_option: NodePath
@export var add_fixture_button: NodePath
@export var error_lable: NodePath

## Fixture manifest for the currently selected fixture
var current_fixture: Dictionary = {} 

## Contains a list of all fixture manifests that are made avaibal to the user
var loaded_fixtures: Dictionary = {}

## Contains the current options for the new fixture
var options: Dictionary = {
	"channel":1,
	"mode":1,
	"quantity":1,
	"offset":0,
	"name":""
}


func _ready() -> void:
	ComponentDB.request_class_callback("Universe", _reload_universes)
	_reload_universes()
	
	FixtureLibrary.manifests_loaded.connect(self._reload_fixture_tree)
	if FixtureLibrary.is_loaded():
		_reload_fixture_tree()



## Reload the fixture tree, where the parent elements are the brand, and child elements being the fixtures
func _reload_fixture_tree() -> void:
	
	self.get_node(fixture_tree).clear()
	
	var tree: Tree = self.get_node(fixture_tree)
	var root: TreeItem = tree.create_item()
	tree.hide_root = true
	
	for manufacturer: String in FixtureLibrary.fixture_manifests.keys():
		var manufacturer_item: TreeItem = tree.create_item(root)
		manufacturer_item.set_text(0, manufacturer)
		manufacturer_item.collapsed = true
		
		loaded_fixtures[manufacturer] = {}
		
		for fixture: String in FixtureLibrary.fixture_manifests[manufacturer].keys():
			var fixture_item: TreeItem = tree.create_item(manufacturer_item)
			fixture_item.set_text(0, FixtureLibrary.fixture_manifests[manufacturer][fixture].info.name)
			
			loaded_fixtures[manufacturer][FixtureLibrary.fixture_manifests[manufacturer][fixture].info.name] = FixtureLibrary.fixture_manifests[manufacturer][fixture]


## Reloads the channel list and mode option button ui elements
func _reload_menu() -> void:
	
	print(self.get_node(fixture_modes_option).selected)
	
	self.get_node(fixture_channel_list).clear()
	self.get_node(fixture_modes_option).clear()
	
	if not current_fixture:
		return
		
	for mode: Dictionary in current_fixture.modes:
		self.get_node(fixture_modes_option).add_item(mode.name)
	
	self.get_node(fixture_modes_option).selected = options.mode
	
	for channel_key: String in current_fixture.modes[options.mode].channels:
		self.get_node(fixture_channel_list).add_item(channel_key.capitalize())


## Reload the list of universes
func _reload_universes(arg1=null, arg2=null) -> void:
	
	self.get_node(fixture_universe_option).clear()
	
	for universe: Universe in ComponentDB.get_components_by_classname("Universe"):
		self.get_node(fixture_universe_option).add_item(universe.name)


## Called when an item from the fixure tree is selected
func _on_fixture_tree_item_selected() -> void:
	
	var selected: TreeItem = self.get_node(fixture_tree).get_selected()
	
	# Ignore if the selected TreeItem is is a Brand not a fixture
	if not selected.get_parent().get_parent(): return
	
	var manufacturer: String = selected.get_parent().get_text(0)
	var fixture: String = selected.get_text(0)
	
	current_fixture = loaded_fixtures[manufacturer][fixture]
	
	options.mode = 0
	_reload_menu()


func _on_modes_item_selected(index: int) -> void:
	options.mode = index
	_reload_menu()


func _on_add_fixture_button_pressed() -> void:
	if self.get_node(fixture_universe_option).selected < 0:
		return
		
	ComponentDB.get_components_by_classname("Universe")[self.get_node(fixture_universe_option).selected].add_fixtures_from_manifest(
		current_fixture, 
		options.mode, 
		options.channel, 
		options.quantity, 
		options.offset
	)


func _on_quantity_value_changed(value: int) -> void:
	options.quantity = value


func _on_offset_value_changed(value: int) -> void:
	options.offset = value


func _on_channel_value_changed(value: int) -> void:
	options.channel = value
