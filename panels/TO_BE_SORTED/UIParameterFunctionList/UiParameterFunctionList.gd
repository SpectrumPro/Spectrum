# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name UiParameterFunctionList extends UIPanel
## Picker for Parameter Functions


## Emitted when a functions is chosen
signal function_chosen(function: String)


## ItemList for function
@export var _function_list: ItemList


## Sets the fixtures to show thier functions
func set_fixtures(fixtures: Array, parameter: String) -> void:
	var functions: Array[String] = []
	_function_list.clear()
	
	for fixture: Fixture in fixtures:
		for function: String in fixture.get_parameter_functions("root", parameter):
			if function not in functions:
				functions.append(function)
				_function_list.add_item(function)
	
	_function_list.select(0)


## Called when the Confirm Button is pressed
func _on_confirm_pressed() -> void:
	function_chosen.emit(_function_list.get_item_text(_function_list.get_selected_items()[0]))
