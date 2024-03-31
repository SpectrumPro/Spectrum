# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends Control
## UI panel for adding and editing fixtures

@export var fixture_tree: NodePath
@export var fixture_channel_list: NodePath
@export var fixture_modes_option: NodePath
@export var fixture_universe_option: NodePath
@export var add_fixture_button: NodePath
@export var error_lable: NodePath

var fixture_path: String = Globals.fixture_path
var current_fixture: Dictionary = {}

var options: Dictionary = {
	"channel":1,
	"mode":1,
	"quantity":1,
	"offset":0,
	"name":""
}


func _ready() -> void:
	Core.universe_added.connect(self._reload_universes)
	Core.universes_removed.connect(self._reload_universes)
	_reload_universes()
	_reload_fixture_tree()


func _reload_fixture_tree() -> void:
	## Reload the fixture tree, where the parent elements are the brand, and child elements being the fixtures
	
	self.get_node(fixture_tree).clear()
	
	var tree: Tree = self.get_node(fixture_tree)
	var root: TreeItem = tree.create_item()
	tree.hide_root = true
	
	for manufacturer: String in Core.fixtures_definitions.keys():
		var manufacturer_item: TreeItem = tree.create_item(root)
		manufacturer_item.set_text(0, manufacturer)
		manufacturer_item.collapsed = true
		
		for fixture: String in Core.fixtures_definitions[manufacturer].keys():
			var fixture_item: TreeItem = tree.create_item(manufacturer_item)
			fixture_item.set_text(0, Core.fixtures_definitions[manufacturer][fixture].info.name)


func _reload_menu() -> void:
	## Reloads the channel list and mode option button ui elements
	
	self.get_node(fixture_channel_list).clear()
	self.get_node(fixture_modes_option).clear()
	
	if not current_fixture:
		return
		
	for mode: String in current_fixture.modes:
		self.get_node(fixture_modes_option).add_item(mode)
	
	self.get_node(fixture_modes_option).selected = options.mode
	
	for channel: String in current_fixture.modes.values()[options.mode].channels:
		self.get_node(fixture_channel_list).add_item(channel)


func _reload_universes(_universe=null) -> void:
	## Reload the list of universes
	
	self.get_node(fixture_universe_option).clear()
	
	for universe: Universe in Core.universes.values():
		self.get_node(fixture_universe_option).add_item(universe.name)


func _on_fixture_tree_item_selected() -> void:
	## Called when an item from the fixure tree is selected
	
	var selected: TreeItem = self.get_node(fixture_tree).get_selected()
	
	# Ignore if the selected TreeItem is is a Brand not a fixture
	if not selected.get_parent().get_parent(): return
	
	var manufacturer: String = selected.get_parent().get_text(0)
	var fixture: String = selected.get_text(0)
	
	current_fixture = Core.fixtures_definitions[manufacturer][fixture]
	
	options.mode = 0
	_reload_menu()


func _on_modes_item_selected(index: int) -> void:
	options.mode = index + 1
	_reload_menu()


func _on_add_fixture_button_pressed() -> void:
	if self.get_node(fixture_universe_option).selected < 0:
		return
		
	Core.universes.values()[self.get_node(fixture_universe_option).selected].new_fixture(
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
