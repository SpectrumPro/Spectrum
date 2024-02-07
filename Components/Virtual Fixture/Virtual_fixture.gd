extends GraphElement

var control_node
var color_override = false
var is_highlight = false
# Called when the node enters the scene tree for the first time.
func _ready():
	$"Color Box".add_theme_stylebox_override("panel", $"Color Box".get_theme_stylebox("panel").duplicate())

func set_color_rgb(color):
	$"Color Box".get_theme_stylebox("panel").bg_color = color

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

func delete():
	self.queue_free()


func _on_node_selected():
	color_override = true
	$"Color Box".get_theme_stylebox("panel").border_color = Color.WHITE

func _on_node_deselected():
	color_override = false
	if is_highlight:set_highlighted(true)
	else:$"Color Box".get_theme_stylebox("panel").border_color = Color.BLACK
