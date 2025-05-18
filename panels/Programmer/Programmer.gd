# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name UIProgrammer extends UIPanel
## Programmer to adust the settings and paramiters of Fixtures


## DimmerTabButton Button
@export var _dimmer_tab_button: Button

## ColorTabButton Button
@export var _color_tab_button: Button

## GoboTabButton Button
@export var _gobo_tab_button: Button

## PositionTabButton Button
@export var _position_tab_button: Button

## BeamTabButton Button
@export var _beam_tab_button: Button

## FocusTabButton Button
@export var _focus_tab_button: Button

## ShapersTabButton Button
@export var _shapers_tab_button: Button

## ControlTabButton Button
@export var _control_tab_button: Button

## The HBoxContainer for ParameterControllers
@export var _parameter_container: HBoxContainer

## The ButtonGroup for all the tab buttons
@export var button_group: ButtonGroup

## The SaveToScene Button
@export var save_to_scene: Button

## Zone select button
@export var zone_select: OptionButton


## All sorted tab buttons
@onready var _tab_buttons: Dictionary[String, Button] = {
	"Dimmer": _dimmer_tab_button,
	"Color": _color_tab_button,
	"Gobo": _gobo_tab_button,
	"Position": _position_tab_button,
	"Beam": _beam_tab_button,
	"Focus": _focus_tab_button,
	"Shapers": _shapers_tab_button,
	"Control": _control_tab_button
}

## The RefMap for tab buttons
@onready var _button_map: RefMap = RefMap.from(_tab_buttons)

## The current tab
var _current_tab: String = "Dimmer"

## All the currently selected fixtures
var _fixtures: Array[Fixture]

## The current selected fixture zone
var _current_zone: String = ""

## All the zones in the current selected fixtures
var _selected_fixture_zones: Array[String] = []

## RandomMode for random values
var _random_mode: Programmer.RandomMode = Programmer.RandomMode.All

## All the current ParameterControllers
var _parameter_controllers: Dictionary[String, Dictionary] = {} 

## All the current ParameterControllers sorted by categorie
var _controller_categories: Dictionary[String, Array] = {}

## All current override values sorted by catigory
var _current_values: Dictionary[String, Dictionary] = {}

## All the visible ParameterControllers
var _visible_parameter_controllers: Array[ParameterController] = []

## Override color of this ParameterController
var _tab_button_override_color: Color = Color(1, 0.518, 0)


func _ready() -> void:
	Values.connect_to_selection_value("selected_fixtures", _on_selected_fixtures_changed)
	button_group.pressed.connect(_on_tab_button_pressed)
	
	Programmer.cleared.connect(_clear_override_bg)


## Updates the tabs of categorys displayed to the user
func _update_categorys(new_fixtures: Array) -> void:
	var controlers_to_hide: Array[ParameterController] = _visible_parameter_controllers.duplicate()
	var tabs_to_disable: Array[String] = _tab_buttons.keys()
	var new_visible_controllers: Array[ParameterController] = []
	var zone_select_index: int = 1
	var zone_to_select: int = 0
	
	_current_values.clear()
	zone_select.clear()
	_selected_fixture_zones = []
	
	zone_select.add_item("All", 0)
	zone_select.add_separator()
	zone_select.select(0)
	
	for fixture: Fixture in new_fixtures:
		var zones: Array[String] = fixture.get_zones()
		
		if _current_zone not in zones:
			_current_zone = ""
		
		Utils.sort_text_and_numbers(zones)
		Utils.array_move_to_start(zones, "root")
		
		for zone: String in zones:
			if zone not in _selected_fixture_zones:
				zone_select.add_item(zone, zone_select_index)
				_selected_fixture_zones.append(zone)
			
			if zone == _current_zone:
				zone_to_select = zone_select_index
			
			zone_select_index += 1
		
			var categories: Dictionary = fixture.get_parameter_categories(zone)
			var current_values: Dictionary = fixture.get_all_override_values()
			
			for parameter: String in categories:
				var controller: ParameterController 
				if _parameter_controllers.get_or_add(zone, {}).has(parameter):
					controller = _parameter_controllers[zone][parameter]
					
					if fixture not in _fixtures:
						for function: String in fixture.get_parameter_functions(zone, parameter):
							if not controller.has_function(function):
								controller.add_function(function)
					
					tabs_to_disable.erase(controller.category)
					_button_map.left(controller.category).disabled = false
					
					if controller.category == _current_tab:
						controller.show()
					
					if controller not in new_visible_controllers:
						new_visible_controllers.append(controller)
					
					controlers_to_hide.erase(controller)
				
				else:
					controller = load("res://panels/Programmer/ParameterController/ParameterController.tscn").instantiate()
					var category = categories[parameter]
					
					if category not in _tab_buttons.keys():
						category = "Control"
					
					controller.set_parameter(parameter)
					controller.set_zone(zone)
					controller.category = category
					
					for function: String in fixture.get_parameter_functions(zone, parameter):
						controller.add_function(function)
					
					_parameter_controllers.get_or_add(zone, {})[parameter] = controller
					_controller_categories.get_or_add(category, []).append(controller)
					new_visible_controllers.append(controller)
					
					tabs_to_disable.erase(category)
					_button_map.left(category).disabled = false
					
					if category != _current_tab:
						controller.hide()
					
					_parameter_container.add_child(controller)
					controller.value_changed.connect(_on_controller_value_changed.bind(controller))
					controller.random_pressed.connect(_on_controller_random_pressed.bind(controller))
					controller.erase_pressed.connect(_on_controller_erase_pressed.bind(controller))
				
				var current: Dictionary = current_values.get(zone, {}).get(parameter, {})
				if current:
					controller.set_value(current.value)
					controller.set_function(current.function)
					controller.set_override_bg(true)
					_set_tab_button_override(_tab_buttons[controller.category], true)
					
					_current_values.get_or_add(controller.category, {})[parameter] = {
						"value": current.value,
						"function": current.function
					}
	
	for controller: ParameterController in controlers_to_hide:
		controller.clear()
		controller.hide()
	
	for tab_name: String in tabs_to_disable:
		_button_map.left(tab_name).disabled = true
		_set_tab_button_override(_button_map.left(tab_name), false)
	
	_visible_parameter_controllers = new_visible_controllers
	_fixtures.assign(new_fixtures)
	
	if zone_to_select == 0:
		_current_zone = ""
	
	zone_select.select(zone_to_select)
	_update_zone_filter()


## Shows or hides ParameterControllers based on the current zone filter
func _update_zone_filter() -> void:
	for controller: ParameterController in _visible_parameter_controllers:
		if controller.category != _current_tab:
			continue
		
		if controller.get_zone() == _current_zone or _current_zone == "":
			controller.show()
		
		elif controller.get_zone() != _current_zone:
			controller.hide()


## Clears the override BG on all of the ParameterControllers and tab buttons
func _clear_override_bg() -> void:
	for zone: String in _parameter_controllers.keys():
		for controller: ParameterController in _parameter_controllers[zone].values():
			controller.set_override_bg(false)
	
	for tab_button: Button in _tab_buttons.values():
		_set_tab_button_override(tab_button, false)


## Sets the override state on the given tab button
func _set_tab_button_override(tab_button: Button, state: bool) -> void:
	tab_button.begin_bulk_theme_override()
	if state:
		tab_button.add_theme_color_override("font_outline_color", _tab_button_override_color)
		tab_button.add_theme_color_override("font_color", _tab_button_override_color)
		tab_button.add_theme_color_override("font_focus_color", _tab_button_override_color)
		tab_button.add_theme_color_override("font_pressed_color", _tab_button_override_color)
	else:
		tab_button.remove_theme_color_override("font_outline_color")
		tab_button.remove_theme_color_override("font_color")
		tab_button.remove_theme_color_override("font_focus_color")
		tab_button.remove_theme_color_override("font_pressed_color")
	tab_button.end_bulk_theme_override()


## Called when the fixture selection changes
func _on_selected_fixtures_changed(fixtures: Array) -> void:
	if visible and fixtures != _fixtures:
		_update_categorys(fixtures)
		
		save_to_scene.disabled = fixtures == []


## Called when any one of the tab buttons is pressed
func _on_tab_button_pressed(button: Button) -> void:
	if _button_map.right(button) == _current_tab:
		return
	
	for controller: ParameterController in _controller_categories.get(_current_tab, []):
		controller.hide()
		#_visible_parameter_controllers.erase(controller)
	
	_current_tab = _button_map.right(button)
	
	for controller: ParameterController in _controller_categories.get(_current_tab, []):
		if controller in _visible_parameter_controllers:
			controller.show()
	
	_update_zone_filter()


## Called when a value is changed in a controller
func _on_controller_value_changed(zone: String, parameter: String, function: String, value: float, controller: ParameterController) -> void:
	Programmer.set_parameter(_fixtures, parameter, function, value, zone)
	_current_values.get_or_add(controller.category, {})[parameter] = {"value": value, "function": function}
	controller.set_override_bg(true)
	_set_tab_button_override(_button_map.left(controller.category), true)


## Called when the random button is pressed on any of the controllers
func _on_controller_random_pressed(zone: String, parameter: String, function: String, controller: ParameterController) -> void:
	Programmer.set_parameter_random(_fixtures, parameter, function, zone, _random_mode)
	_current_values.get_or_add(controller.category, {})[parameter] = {"value": 0, "function": function}
	controller.set_override_bg(true)
	_set_tab_button_override(_button_map.left(controller.category), true)


## Called when the erase button is pressed on any of the controllers
func _on_controller_erase_pressed(zone: String, parameter: String, controller: ParameterController) -> void:
	Programmer.erase_parameter(_fixtures, parameter, zone)
	controller.set_override_bg(false)
	
	if _current_values.get_or_add(controller.category, {}).erase(parameter) and not _current_values[controller.category]:
		_set_tab_button_override(_button_map.left(controller.category), false)


## Called when the Clear button is pressed
func _on_erace_pressed() -> void:
	Programmer.clear()


## Called when the RandomMode option is changed
func _on_random_mode_item_selected(index: int) -> void:
	_random_mode = index


## Called when the ZoneSelect option is changed
func _on_zone_select_item_selected(index: int) -> void:
	_current_zone = zone_select.get_item_text(index)
	if _current_zone == "All":
		_current_zone = ""
	
	_update_zone_filter()


## Called when the SaveToScene button is pressed
func _on_save_to_scene_pressed() -> void:
	Programmer.save_to_new_scene(_fixtures).then(func (scene: Scene):
		Interface.show_name_prompt(scene)
	)
