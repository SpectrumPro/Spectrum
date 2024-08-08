# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name VirtualFixture extends GraphElement
## The virtual fixture used by the virtual fixtures panel


## The fixture linked to this virtual fixture
var fixture: Fixture : set = set_fixture

## Whether this virtual fixture is highlighted
var is_highlight = false : set = set_highlighted

var _color_override = false


func _ready():
	$"Color Box".add_theme_stylebox_override("panel", $"Color Box".get_theme_stylebox("panel").duplicate())


## Sets the BG color of this virtual fixture
func set_color(color):
	$"Color Box".get_theme_stylebox("panel").bg_color = color


## Sets the fixture linked to this virtual fixture
func set_fixture(control_fixture: Fixture) -> void:
	## Sets the fixture this virtual fixture is atached to
	
	if is_instance_valid(fixture):
		fixture.color_changed.disconnect(self.set_color)
		fixture.delete_request.disconnect(self.delete)
	
	fixture = control_fixture
	fixture.color_changed.connect(self.set_color)
	
	set_color(fixture.current_values.set_color)


func serialize():
	return {
		"position_offset":{
			"x":position_offset.x,
			"y":position_offset.y
		}
}


## Sets whether this virtual fixture is highlighted
func set_highlighted(highlight):
	is_highlight = highlight
	if not _color_override:
		if highlight:
			$"Color Box".get_theme_stylebox("panel").border_color = Color.DIM_GRAY
		else:
			$"Color Box".get_theme_stylebox("panel").border_color = Color.BLACK


func _on_node_selected():
	_color_override = true
	$"Color Box".get_theme_stylebox("panel").border_color = Color.WHITE


func _on_node_deselected():
	_color_override = false
	if is_highlight:set_highlighted(true)
	else:$"Color Box".get_theme_stylebox("panel").border_color = Color.BLACK


func _on_dragged(from: Vector2, to: Vector2) -> void:
	fixture.user_meta.virtual_fixtures[str(self.name)] = [to.x, to.y]
	fixture.set_user_meta("virtual_fixtures", fixture.user_meta.virtual_fixtures)
