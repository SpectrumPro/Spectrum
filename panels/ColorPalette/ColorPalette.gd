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


## The ButtonGroup added to all the buttons
var _button_groop: ButtonGroup = null

## Stores a refernce to all the buttons, by there color
var _button_refs: Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reload()
	
	settings_node.get_node("VBoxContainer/HBoxContainer/NumberOfColors").set_value_no_signal(number_of_colors)
	settings_node.get_node("VBoxContainer/HBoxContainer2/ShowWhite").set_pressed_no_signal(show_white)
	settings_node.get_node("VBoxContainer/HBoxContainer2/ShowBlack").set_pressed_no_signal(show_black)
	
	Values.connect_to_selection_value("selected_fixtures", _change_selected_color_from_fixtures)
	
	remove_child($Settings)


## Reloads the list of colors
func reload() -> void:
	for old_button: Button in $ScrollContainer/GridContainer.get_children():
		$ScrollContainer/GridContainer.remove_child(old_button)
		old_button.queue_free()
	
	_button_groop = ButtonGroup.new()
	
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


## Saves the settings to a dictionary
func save() -> Dictionary:
	return {
		"show_black": show_black,
		"show_white": show_white,
		"number_of_colors": number_of_colors
	}


## Loads settings from what was returned by save()
func load(saved_data: Dictionary) -> void:
	show_black = saved_data.get("show_black", show_black)
	show_white = saved_data.get("show_white", show_white)
	
	number_of_colors = saved_data.get("number_of_colors", number_of_colors)


## Adds a color button to the list
func _add_color_button(color: Color) -> void:
	var new_color_button: Button = load("res://panels/ColorPalette/ColorButton.tscn").instantiate()
	
	new_color_button.color = color
	new_color_button.button_down.connect(func ():
		Core.programmer.set_color(Values.get_selection_value("selected_fixtures", []), color)
	)
	
	new_color_button.button_group = _button_groop
	
	## Because the color is converted to r,g,b.8 on the server, we need to refernce it here so it can be found	
	_button_refs[[color.r8, color.g8, color.b8]] = new_color_button
	
	$ScrollContainer/GridContainer.add_child(new_color_button)


func _change_selected_color_from_fixtures(fixtures: Array) -> void:
	print("Selection Changed")
	if fixtures:
		var fixture: Fixture = fixtures[0]
		
		var override_color: Variant = fixture.get_override_value_from_channel_key("set_color")
		
		if override_color != null:
			## Because the color is converted to r,g,b.8 on the server, we need to refernce it here so it can be found
			var color8: Array = [override_color.r8, override_color.g8, override_color.b8]
			
			if color8 in _button_refs.keys():
				(_button_refs[color8] as Button).button_pressed = true
	else:
		var pressed_button: BaseButton = _button_groop.get_pressed_button()
		
		if pressed_button:
			pressed_button.button_pressed = false
		


func _on_grid_container_resized() -> void:
	$ScrollContainer/GridContainer.columns = clamp(int(self.size.x / 85), 1, INF)



func _on_number_of_colors_value_changed(value: float) -> void:
	set_number_of_colors(int(value))
