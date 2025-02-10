# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name FixtureGroupItem extends EngineComponent
## A data container for Fixture Groups, this does not do anyting by its self.


## Emited when the fixture changes
signal fixture_changed(fixture: Fixture)

## Emitted when the position changes
signal position_changed(position: Vector3)


## The fixture asigned to this group item
var _fixture: Fixture = null

## The position of this fixture in this group item
var _position: Vector3 = Vector3.ZERO


func _component_ready() -> void:
	_set_self_class("FixtureGroupItem")
	
	register_callback("on_fixture_changed", _set_fixture)
	register_callback("on_position_changed", _set_position)


## Sets the fixture
func set_fixture(p_fixture: Fixture) -> void: rpc("set_fixture", [p_fixture])

## Internal: Sets the fixture
func _set_fixture(p_fixture: Fixture) -> void:
	if p_fixture == _fixture: return
	
	_fixture = p_fixture
	fixture_changed.emit(_fixture)

## Gets the fixture
func get_fixture() -> Fixture: return _fixture


## Sets the fixtures position
func set_position(p_position: Vector3) -> void: rpc("set_position", [p_position])

## Internal: Sets the fixtures position
func _set_position(p_position: Vector3) -> void:
	if _position == p_position: return
	
	_position = p_position
	position_changed.emit(_position)

## Gets the position
func get_position() -> Vector3: return _position


## Saves this component into a dict
func _serialize_request() -> Dictionary:
	return {
		"fixture": _fixture.uuid,
		"position": var_to_str(_position)
	}


## Loads this component from a dict
func _load_request(serialized_data: Dictionary) -> void:
	if serialized_data.get("fixture") is String and ComponentDB.get_component(serialized_data.fixture) is Fixture:
		_set_fixture(ComponentDB.get_component(serialized_data.fixture))
	
	var position: Variant = serialized_data.get("position", null)
	if position is String and str_to_var(position) is Vector3:
		_set_position(str_to_var(position))
