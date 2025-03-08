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

## ShapersTabButton Button
@export var _shapers_tab_button: Button

## ControlTabButton Button
@export var _control_tab_button: Button


## All sorted tab buttons
var tab_buttons: Dictionary = {
	"Dimmer": _dimmer_tab_button,
	"Color": _color_tab_button,
	"Gobo": _gobo_tab_button,
	"Position": _position_tab_button,
	"Beam": _beam_tab_button,
	"Shapers": _shapers_tab_button,
	"Control": _control_tab_button
}


## All the currently selected fixtures
var _fixtures: Array[Fixture]

## The current selected fixture zone
var _zone: String = "root"


func _ready() -> void:
	Values.connect_to_selection_value("selected_fixtures", _on_selected_fixtures_changed)


## Updates the tabs of categorys displayed to the user
func _update_categorys(new_fixtures: Array) -> void:
	#_tab_container.clear()
	#_current_categorys.clear()
	#_current_parameter_controls.clear()
	print("Updating PArams")
	#for fixture: Fixture in new_fixtures:
		#var categories: Dictionary = fixture.get_parameter_categories(_zone)
		#
		#for parameter: String in categories:
			#if fixture in _fixtures:
				#continue
			#
			#var category: String = categories[parameter]
			#
			#if category not in _current_categorys:
				#_current_categorys[category] = HBoxContainer.new()
				#_current_parameter_controls[category] = {}
				#_tab_container.add_tab(category, _current_categorys[category])
			#
			#if parameter not in _current_parameter_controls[category]:
				#print("Creating New Param: ", parameter)
				#var controller: ParameterController = load("res://panels/Programmer/ParameterController/ParameterController.tscn").instantiate()
				#controller.set_parameter(parameter)
				#
				#for function: String in fixture.get_parameter_functions(_zone, parameter):
					#controller.add_function(function)
				#
				#
				#_current_categorys[category].add_child(controller)
				#_current_parameter_controls[category][parameter] = controller
			#
				#controller.value_changed.connect(_on_controller_value_changed)
	#
	#_fixtures.assign(new_fixtures)


## Called when the fixture selection changes
func _on_selected_fixtures_changed(fixtures: Array) -> void:
	if visible:
		_update_categorys(fixtures)


## Called when a value is changed in a controller
func _on_controller_value_changed(parameter: String, value: float):
	Programmer.set_parameter(_fixtures, parameter, value, _zone)
