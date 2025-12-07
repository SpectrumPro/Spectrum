# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name UIManifestPicker extends UIPopup
## Find and selects objects


## The Tree to show all manifests
@export var manifest_tree: Tree

## The Tree to show all fixtures
@export var fixture_tree: Tree

## The Tree to show all modes
@export var mode_tree: Tree

## The LineEdit for the search bar
@export var search_bar: LineEdit

## Min size of the second tree column
@export var column_min_size: int = 150


## Contains all manifest info from FixtureLibaray
var _manifest_info: Dictionary[String, Dictionary] = {}

## RefMap for FixtureManifest: Tree
var _manifest_items: RefMap = RefMap.new()

## The current selected FixtureManifest
var _selected_manifest: FixtureManifest

## The current active tree
var _active_tree: Tree


## Ready
func _ready() -> void:
	manifest_tree.set_column_expand(1, false)
	manifest_tree.set_column_custom_minimum_width(1, column_min_size)
	
	fixture_tree.set_column_expand(1, false)
	fixture_tree.set_column_custom_minimum_width(1, column_min_size)
	
	FixtureLibrary.manifests_found.connect(_load_manifests)
	_load_manifests()


## Searched for the given text
func search_for(p_search_text: String) -> void:
	if _active_tree == manifest_tree and p_search_text:
		manifest_tree.hide()
		fixture_tree.show()
		_active_tree = fixture_tree
	
	elif _active_tree == fixture_tree and not p_search_text:
		fixture_tree.hide()
		manifest_tree.show()
		_active_tree = fixture_tree
	
	var search_tree: Tree 
	var items_to_display: Array
	
	match _active_tree:
		fixture_tree:
			search_tree = fixture_tree
			
			for manifest: FixtureManifest in _manifest_items.get_left():
				items_to_display.append({
					"similarity": manifest.name().similarity(p_search_text) if p_search_text else 0.0,
					"tree_item": _manifest_items.left(manifest),
					"show": true
				})
		
		mode_tree:
			pass
	
	items_to_display.sort_custom(func (p_a: Dictionary, p_b: Dictionary) -> bool:
		if p_search_text and len(p_search_text) < 3:
			return (p_a.item_name as String).to_lower().begins_with(p_search_text[0])
		elif p_search_text:
			return p_a.similarity > p_b.similarity
		else:
			return (p_a.item_name as String).naturalnocasecmp_to(p_b.item_name)
	)
	items_to_display.reverse()

	for item: Dictionary in items_to_display:
		item.tree_item.move_before(search_tree.get_root().get_child(0))
		item.tree_item.set_visible(item.show)


## Loads all manifests
func _load_manifests() -> void:
	manifest_tree.clear()
	fixture_tree.clear()
	mode_tree.clear()
	search_bar.clear()
	
	manifest_tree.create_item()
	fixture_tree.create_item()
	mode_tree.create_item()
	
	_manifest_items.clear()
	_manifest_info = FixtureLibrary.get_sorted_manifest_info()
	
	for manufacturer: String in _manifest_info:
		var manufacturer_item: TreeItem = manifest_tree.create_item()
		
		manufacturer_item.set_text(0, manufacturer)
		manufacturer_item.set_icon(0, preload("res://assets/icons/Factory.svg"))
		
		manufacturer_item.set_custom_color(1, Color(0x919191ff))
		manufacturer_item.set_text(1, "Manufacturer")
		
		for fixture: String in _manifest_info[manufacturer]:
			var manifest_tree_fixture_item: TreeItem = manufacturer_item.create_child()
			
			manifest_tree_fixture_item.set_text(0, fixture)
			manifest_tree_fixture_item.set_icon(0, preload("res://assets/icons/Fixture.svg"))
			
			manifest_tree_fixture_item.set_custom_color(1, Color(0x919191ff))
			manifest_tree_fixture_item.set_text(1, "FixtureManifest")
			
			var fixture_tree_fixture_item: TreeItem = fixture_tree.create_item()
			
			fixture_tree_fixture_item.set_text(0, fixture)
			fixture_tree_fixture_item.set_icon(0, preload("res://assets/icons/Fixture.svg"))
			
			fixture_tree_fixture_item.set_custom_color(1, Color(0x919191ff))
			fixture_tree_fixture_item.set_text(1, manufacturer)
			
			_manifest_items.map(_manifest_info[manufacturer][fixture], fixture_tree_fixture_item)


## Called for all GUI inputs on the search bar
func _on_line_edit_gui_input(p_event: InputEvent) -> void:
	if p_event.is_action_released("ui_down"):
		_active_tree.select_next()
	
	if p_event.is_action_pressed("ui_up"):
		_active_tree.select_prev()
