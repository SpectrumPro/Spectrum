# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends PanelContainer
## Ui panel for color presets, applyed directly to the programmer

## The number of colors to show
@export var number_of_colors: int = 20 : set = set_number_of_colors

## Whether or not to show the white color button
@export var show_white: bool = true : set = set_show_white

## Whether or not to show the black color button
@export var show_black: bool = true : set = set_show_black

## The settings node used to choose how many colors to show
@onready var settings_node: Control = $Settings


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reload()
	
	settings_node.get_node("VBoxContainer/HBoxContainer/NumberOfColors").set_value_no_signal(number_of_colors)
	settings_node.get_node("VBoxContainer/HBoxContainer2/ShowWhite").set_pressed_no_signal(show_white)
	settings_node.get_node("VBoxContainer/HBoxContainer2/ShowBlack").set_pressed_no_signal(show_black)
	
	remove_child($Settings)


## Reloads the list of colors
func reload() -> void:
	for old_button: Button in $ScrollContainer/GridContainer.get_children():
		$ScrollContainer/GridContainer.remove_child(old_button)
		old_button.queue_free()
	
	if show_white: 
		_add_color_button(Color.WHITE)
	
	if show_black: 
		_add_color_button(Color.BLACK)
	
	for i in range(number_of_colors):
		var hue = float(i) / number_of_colors
		var color = Color.from_hsv(hue, 1.0, 1.0)
		_add_color_button(color)


## Sets the number of colors to display
func set_number_of_colors(number: int) -> void:
	number_of_colors = number
	reload()


## Whether or not to show the white color button
func set_show_white(p_show_white: bool) -> void:
	show_white = p_show_white
	reload()


## Whether or not to show the black color button
func set_show_black(p_show_black: bool) -> void:
	show_black = p_show_black
	reload()


## Adds a color button to the list
func _add_color_button(color: Color) -> void:
	var new_color_button: Button = load("res://Panels/ColorPalette/ColorButton.tscn").instantiate()
	
	new_color_button.color = color
	new_color_button.button_down.connect(func ():
		print("Setting Color: ", color)
		Core.programmer.set_color(Values.get_selection_value("selected_fixtures", []), color)
	)
	
	$ScrollContainer/GridContainer.add_child(new_color_button)


func _on_grid_container_resized() -> void:
	$ScrollContainer/GridContainer.columns = clamp(int(self.size.x / 85), 1, INF)



func _on_number_of_colors_value_changed(value: float) -> void:
	set_number_of_colors(int(value))
