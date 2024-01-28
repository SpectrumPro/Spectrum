extends GraphElement


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

func delete():
	self.queue_free()
