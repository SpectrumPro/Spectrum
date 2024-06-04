extends PanelContainer

signal value_changed(value: int)

@onready var value: int = $VBoxContainer/PanelContainer/VSlider.value: 
	get:
		return $VBoxContainer/PanelContainer/TextureRect.value

var bottom_color: Color = Color.BLACK: set = set_botton_color
var top_color: Color = Color.WHITE: set = set_top_color

func set_botton_color(color: Color) -> void:
	print(color)
	bottom_color = color
	$VBoxContainer/PanelContainer/TextureRect.texture.gradient.set_color(0, color)

func set_top_color(color: Color) -> void:
	print(color)
	top_color = color
	$VBoxContainer/PanelContainer/TextureRect.texture.gradient.set_color(1, color)


func _on_v_slider_value_changed(value: float) -> void:
	value_changed.emit(value)
