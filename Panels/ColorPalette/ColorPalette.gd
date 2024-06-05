# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends PanelContainer

var color_list: Array[Color]
var number_of_colors: int = 40

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	add_color_button(Color.WHITE)
	add_color_button(Color.BLACK)
	
	for i in range(number_of_colors):
		var hue = float(i) / number_of_colors
		var color = Color.from_hsv(hue, 1.0, 1.0)
		color_list.append(color)
		add_color_button(color)
	
	print(color_list)


func add_color_button(color: Color) -> void:
	var new_color_button: Button = load("res://Panels/ColorPalette/ColorButton.tscn").instantiate()
	
	new_color_button.color = color
	new_color_button.button_down.connect(func ():
		print("Setting Color: ", color)
		Core.programmer.set_color(Values.get_selection_value("selected_fixtures", []), color)
	)
	
	$ScrollContainer/GridContainer.add_child(new_color_button)


func _on_grid_container_resized() -> void:
	$ScrollContainer/GridContainer.columns = clamp(int(self.size.x / 85), 1, INF)

