# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name UIAddFixture extends UIPanel
## UI panel for adding fixtures


## List of manufacturers
@export var manufacturers_list: ItemList

## List of fixtures
@export var fixture_list: ItemList

## Fixture infomation view
@export var fixture_infomation: ScrollContainer

## SelectAFixture label warning
@export var select_a_fixture: Label

## Name label for the fixture infomation
@export var fixture_info_name: Label

## Manufacturer label for the fixture infomation
@export var fixture_info_manufacturer: Label

## List of of modes for the fixture infomation
@export var fixture_info_modes: ItemList

## The ObjectPickerButton
@export var universe_options: ObjectPickerButton

## DMX channel
@export var channel_input: SpinBox

## Input for the quanti of fixtures to add
@export var quantity_input: SpinBox

## Input for the channel gap
@export var offset_input: SpinBox

## Fixture name input
@export var name_input: LineEdit

## Checkbox for incrementing the name
@export var increment_name: CheckBox


## All current displayed fixtures
var loaded_manifests: Dictionary = {}

## Current selected manufacturer
var _current_manufacturer: String

## Current selected fixture
var _current_fixture: String

## Current selected mode
var _mode: String = ""


func _ready() -> void:
	set_edit_mode_disabled(true)
	
	FixtureLibrary.manifests_found.connect(_reload_fixtures)
	if FixtureLibrary.is_loaded():
		_reload_fixtures()


## Reloads all the fixtures
func _reload_fixtures() -> void:
	manufacturers_list.clear()
	fixture_list.clear()
	
	loaded_manifests = FixtureLibrary.get_sorted_manifest_info()
	
	for manufacturer: String in loaded_manifests:
		manufacturers_list.add_item(manufacturer)
	
	manufacturers_list.sort_items_by_text()


## Changes the fixtures list to show all fixtures from the given manufacturer
func _switch_to_manufacturer(manufacturer: String) -> void:
	fixture_list.clear()
	
	for fixture: String in loaded_manifests[manufacturer]:
		fixture_list.add_item(fixture)
	
	fixture_list.sort_items_by_text()
	
	_switch_to_fixture(manufacturer, "")
	_current_manufacturer = manufacturer


## Changes the fixture infomation to show the given fixture
func _switch_to_fixture(manufacturer: String, fixture: String) -> void:
	if manufacturer:
		_current_fixture = fixture
		if fixture:
			fixture_infomation.show()
			select_a_fixture.hide()
			
			fixture_info_name.text = fixture
			fixture_info_manufacturer.text = manufacturer
			name_input.text = fixture
			
			fixture_info_modes.clear()
			for mode: String in (loaded_manifests[manufacturer][fixture] as FixtureManifest).get_modes():
				fixture_info_modes.add_item(mode)
			
			fixture_info_modes.select(0)
			_on_modes_item_selected(0)
			fixture_info_modes.sort_items_by_text()
			
			
		else:
			fixture_infomation.hide()
			select_a_fixture.show()


## Called when an item in the manufacturers list is clicked
func _on_manufacturers_item_selected(index: int) -> void:
	_switch_to_manufacturer(manufacturers_list.get_item_text(index))


## Called when an item in the fixtures list is clicked
func _on_fixtures_item_selected(index: int) -> void:
	_switch_to_fixture(_current_manufacturer, fixture_list.get_item_text(index))


## Called when a mode is selected
func _on_modes_item_selected(index: int) -> void:
	_mode = fixture_info_modes.get_item_text(index)


func _on_create_pressed() -> void:
	var universe: Universe = universe_options.get_object()
	var manifest_uuid: String = loaded_manifests[_current_manufacturer][_current_fixture].uuid
	var config: Dictionary = {
		"channel": channel_input.value,
		"quantity": quantity_input.value,
		"offset": offset_input.value,
		"mode": _mode,
		"name": name_input.text,
		"increment_name": increment_name.button_pressed
	}
	FixtureLibrary.create_fixture(manifest_uuid, universe, config)
