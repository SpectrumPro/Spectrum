# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name VirtualFixture extends GraphElement
## The virtual fixture used by the virtual fixtures panel


## The fixture linked to this virtual fixture
var fixture: Fixture : set = set_fixture


## Allows the user to define how much to blend diffent colors, bigger values will help show what other colors are active on a light, and will have a better vis of the real light
var color_blend_buffer: float = 0.7


func _ready():
	$"Color Box".add_theme_stylebox_override("panel", $"Color Box".get_theme_stylebox("panel").duplicate())


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
		
		
		$"Color Box".get_theme_stylebox("panel").bg_color = color


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
	
	fixture = control_fixture
	fixture.color_changed.connect(render_color)
	fixture.white_intensity_changed.connect(render_color)
	fixture.amber_intensity_changed.connect(render_color)
	fixture.uv_intensity_changed.connect(render_color)
	fixture.dimmer_changed.connect(render_color)
	
	
	render_color()


func serialize():
	return {
		"position_offset":{
			"x":position_offset.x,
			"y":position_offset.y
		}
}

func _on_node_selected():
	$"Color Box".get_theme_stylebox("panel").border_color = Color.WHITE


func _on_node_deselected():
	$"Color Box".get_theme_stylebox("panel").border_color = Color.BLACK


func _on_dragged(from: Vector2, to: Vector2) -> void:
	fixture.user_meta.virtual_fixtures[str(self.name)] = [to.x, to.y]
	fixture.set_user_meta("virtual_fixtures", fixture.user_meta.virtual_fixtures)
