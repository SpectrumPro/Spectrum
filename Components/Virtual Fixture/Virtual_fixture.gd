extends GraphElement

var fixture: Fixture
var color_override = false
var is_highlight = false
var virtual_fixture_index: int = 0

func _ready():
	$"Color Box".add_theme_stylebox_override("panel", $"Color Box".get_theme_stylebox("panel").duplicate())

func set_color(color):
	$"Color Box".get_theme_stylebox("panel").bg_color = color

func set_fixture(control_fixture: Fixture) -> void:
	## Sets the fixture this virtual fixture is atached to
	
	if is_instance_valid(fixture):
		fixture.color_changed.disconnect(self.set_color)
		fixture.delete_request.disconnect(self.delete)
	
	fixture = control_fixture
	fixture.color_changed.connect(self.set_color)
	fixture.delete_requested.connect(self.delete)

func serialize():
	return {
		"position_offset":{
			"x":position_offset.x,
			"y":position_offset.y
		}
}

func set_highlighted(highlight):
	is_highlight = highlight
	if not color_override:
		if highlight:
			$"Color Box".get_theme_stylebox("panel").border_color = Color.DIM_GRAY
		else:
			$"Color Box".get_theme_stylebox("panel").border_color = Color.BLACK

func delete(_fixture = null):
	self.get_parent()._selected_virtual_fixtures.erase(self)
	self.queue_free()


func _on_node_selected():
	color_override = true
	$"Color Box".get_theme_stylebox("panel").border_color = Color.WHITE

func _on_node_deselected():
	color_override = false
	if is_highlight:set_highlighted(true)
	else:$"Color Box".get_theme_stylebox("panel").border_color = Color.BLACK


func _on_dragged(from: Vector2, to: Vector2) -> void:
	fixture.user_meta.virtual_fixtures[str(self.name)] = to
	fixture.set_user_meta("virtual_fixtures", fixture.user_meta.virtual_fixtures)
