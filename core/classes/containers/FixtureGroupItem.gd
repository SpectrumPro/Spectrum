# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name FixtureGroupItem extends EngineComponent
## A data container for Fixture Groups, this does not do anyting by its self.


## Emited when the fixture changes
signal fixture_changed(fixture: Fixture)


## Emitted when the position changes
signal position_changed(position: Vector3)


## The fixture asigned to this group item
var fixture: Fixture = null

## The position of this fixture in this group item
var position: Vector3 = Vector3.ZERO


func _component_ready() -> void:
	set_self_class("FixtureGroupItem")


## Sets the fixture
func set_fixture(p_fixture: Fixture) -> void: rpc("set_fixture", [p_fixture])

## Internal: Sets the fixture
func _set_fixture(p_fixture: Fixture) -> void:
	if p_fixture == fixture: return
	
	fixture = p_fixture
	fixture_changed.emit(fixture)


## Sets the fixtures position
func set_position(p_position: Vector3) -> void: rpc("set_position", [p_position])

## Internal: Sets the fixtures position
func _set_position(p_position: Vector3) -> void:
	if position == p_position: return
	
	position = p_position
	position_changed.emit(position)


## Server: Called when the fixture changes
func on_fixture_changed(p_fixture: Fixture) -> void: _set_fixture(p_fixture)

## Server: Called when the position changes
func on_position_changed(p_position: Vector3) -> void: _set_position(p_position)


## Saves this component into a dict
func _on_serialize_request() -> Dictionary:
	return {
		"fixture": fixture.uuid,
		"position": var_to_str(position)
	}


## Loads this component from a dict
func _on_load_request(serialized_data: Dictionary) -> void:
	if serialized_data.get("fixture") is String and ComponentDB.get_component(serialized_data.fixture) is Fixture:
		_set_fixture(ComponentDB.get_component(serialized_data.fixture))
	
	var position: Variant = serialized_data.get("position", null)
	if position is String and str_to_var(position) is Vector3:
		_set_position(str_to_var(position))
