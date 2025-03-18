# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name NewVirtualFixture extends Control
## New virtual fixture


## Emitted when this virtual fixture is moved
signal move_requested(by: Vector2)

## Emitted when this fixture is clicked
signal clicked()

## Emitted when the mouse left button is released
signal released()


## The position of this virtual fixture not effected by snapping
@onready var _no_snap_pos: Vector2 = position


## Color of this VF when it the fixture is selected
const fixture_selected_color: Color = Color.ROYAL_BLUE

## Color of this VF when self is selected
const self_selected_color: Color = Color.WHITE


## The fixture linked to this virtual fixture
var _fixture: Fixture = null

## Signals to connect to the fixture
var _fixture_signal_connections: Dictionary = {
	"override_changed": _on_override_value_changed,
	"override_erased": _on_override_value_erased,
	"all_override_removed": _on_override_value_erased,
}


## Sets the BG color of this virtual fixture
func render_color(arg1=null):
	pass
	#if is_instance_valid(fixture):
		#var current_values: Dictionary = fixture.get_current_values()
		#var color: Color = current_values.get("set_color", Color.BLACK)
		#
		#var ColorIntensityWhite = current_values.get("ColorIntensityWhite")
		#if ColorIntensityWhite != null: color = _blend_color(color, Color.WHITE, ColorIntensityWhite)
		#
		#var ColorIntensityAmber = current_values.get("ColorIntensityAmber")
		#if ColorIntensityAmber != null: color = _blend_color(color, Color.ORANGE_RED, ColorIntensityAmber)
		#
		#var ColorIntensityUV = current_values.get("ColorIntensityUV")
		#if ColorIntensityUV != null: color = _blend_color(color, Color.BLUE_VIOLET, ColorIntensityUV)
		#
		#
		#if "Dimmer" in fixture.get_channels():
			#var dimmer_value: int = current_values.get("Dimmer", 0)
			#if len(fixture.get_channels()) == 1:
				#color = _blend_color(color, Color.from_string("F6E7D2", Color.ORANGE), dimmer_value)
			#else:
				#color = color.darkened(remap(Fixture.MAX_DMX_VALUE - dimmer_value, 0, Fixture.MAX_DMX_VALUE, 0.0, 1.0))
		#
		#
		#set_color(color)


## Sets the base color
func set_color(color: Color) -> void:
	$Color.modulate = color


## Sets the selection highlight
func set_fixture_selected(state: bool) -> void:
	if state:
		$Highlight.modulate = fixture_selected_color
		$Highlight.show()
	else:
		$Highlight.hide()


## Sets the self highlight
func set_self_selected(state: bool) -> void:
	if state:
		$Highlight.modulate = self_selected_color
		$Highlight.show()
	else:
		$Highlight.hide()


## Custom blend function for colors
func _blend_color(blend_target: Color, base_color: Color, darken_amount: int) -> Color:
	#return Utils.get_htp_color(blend_target, base_color.darkened(remap(Fixture.MAX_DMX_VALUE - darken_amount, 0, Fixture.MAX_DMX_VALUE, 0.0, 1.0)))
	return Color.BLACK


## Sets the fixture linked to this virtual fixture
func set_fixture(control_fixture: Fixture) -> void:
	Utils.disconnect_signals(_fixture_signal_connections, _fixture)
	_fixture = control_fixture
	Utils.connect_signals(_fixture_signal_connections, _fixture)
	
	if _fixture.has_overrides():
		$Override.show()
	
	$UUID.text = control_fixture.uuid


## Gets the fixture linked to this virtual fixture
func get_fixture() -> Fixture:
	return _fixture


## Called when a override value is changed on a fixture
func _on_override_value_changed(parameter: String, function: String, value: Variant, zone: String) -> void: 
	$Override.show()


## Called when an override value is removed from the fixture
func _on_override_value_erased(parameter: String = "", zone: String = "") -> void:
	if not _fixture.has_overrides():
		$Override.hide()


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and event.button_mask == MOUSE_BUTTON_MASK_LEFT:
		move_requested.emit(event.relative) 
	
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			clicked.emit()
			
		elif event.is_released():
			released.emit()
