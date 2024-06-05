extends Button

var color: Color = Color.BLACK : set = set_color

func _ready() -> void:
	$Panel.add_theme_stylebox_override("panel", $Panel.get_theme_stylebox("panel").duplicate())

func set_color(p_color: Color) -> void:
	color = p_color
	$Panel.get_theme_stylebox("panel").bg_color = color
