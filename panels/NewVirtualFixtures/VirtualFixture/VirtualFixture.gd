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


## The fixture linked to this virtual fixture
var fixture: Fixture : set = set_fixture

const fixture_selected_color: Color = Color.ROYAL_BLUE
const self_selected_color: Color = Color.WHITE


## The position of this virtual fixture not effected by snapping
@onready var _no_snap_pos: Vector2 = position


## Sets the BG color of this virtual fixture
func render_color(arg1=null):
	if is_instance_valid(fixture):
		var color: Color = fixture.current_values.get("set_color", Color.BLACK)
		
		var ColorIntensityWhite = fixture.current_values.get("ColorIntensityWhite")
		if ColorIntensityWhite != null: color = _blend_color(color, Color.WHITE, ColorIntensityWhite)
		
		var ColorIntensityAmber = fixture.current_values.get("ColorIntensityAmber")
		if ColorIntensityAmber != null: color = _blend_color(color, Color.ORANGE_RED, ColorIntensityAmber)
		
		var ColorIntensityUV = fixture.current_values.get("ColorIntensityUV")
		if ColorIntensityUV != null: color = _blend_color(color, Color.BLUE_VIOLET, ColorIntensityUV)
		
		
		if "Dimmer" in fixture.channels:
			var dimmer_value: int = fixture.current_values.get("Dimmer", 0)
			if len(fixture.channels) == 1:
				color = _blend_color(color, Color.from_string("F6E7D2", Color.ORANGE), dimmer_value)
			else:
				color = color.darkened(remap(Fixture.MAX_DMX_VALUE - dimmer_value, 0, Fixture.MAX_DMX_VALUE, 0.0, 1.0))
		
		
		set_color(color)


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
	return Utils.get_htp_color(blend_target, base_color.darkened(remap(Fixture.MAX_DMX_VALUE - darken_amount, 0, Fixture.MAX_DMX_VALUE, 0.0, 1.0)))


## Sets the fixture linked to this virtual fixture
func set_fixture(control_fixture: Fixture) -> void:
	## Sets the fixture this virtual fixture is atached to
	
	if is_instance_valid(fixture):
		fixture.color_changed.disconnect(render_color)
		fixture.white_intensity_changed.disconnect(render_color)
		fixture.amber_intensity_changed.disconnect(render_color)
		fixture.uv_intensity_changed.disconnect(render_color)
		fixture.dimmer_changed.disconnect(render_color)
		fixture.delete_request.disconnect(self.delete)
		fixture.override_value_changed.disconnect(_on_override_value_changed)
		fixture.override_value_removed.disconnect(_on_override_value_removed)
	
	fixture = control_fixture
	
	if is_instance_valid(fixture):
		fixture.color_changed.connect(render_color)
		fixture.white_intensity_changed.connect(render_color)
		fixture.amber_intensity_changed.connect(render_color)
		fixture.uv_intensity_changed.connect(render_color)
		fixture.dimmer_changed.connect(render_color)
		fixture.override_value_changed.connect(_on_override_value_changed)
		fixture.override_value_removed.connect(_on_override_value_removed)
	
		render_color()
		if fixture.get_all_ovrride_values():
			pass


## Called when a override value is changed on a fixture
func _on_override_value_changed(arg1=null, arg2=null) -> void: 
	pass


## Called when an override value is removed from the fixture
func _on_override_value_removed(arg1=null) -> void:
	if not fixture.get_all_ovrride_values():
		pass


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and event.button_mask == MOUSE_BUTTON_MASK_LEFT:
		move_requested.emit(event.relative) 
	
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			clicked.emit()
			
		elif event.is_released():
			released.emit()
