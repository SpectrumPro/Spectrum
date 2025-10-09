# Copyright (c) 2025 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name ClientUIDB extends Node
## Contains a list of all the UIPanel classes


## File path for all UIPanels
const UI_PANEL_LOCATION: String = "res://panels/"

## File path for all UIPanels
const UI_POPUP_LOCATION: String = "res://panels/popups/"

## File path for all UIPanels
const DATA_INPUT_LOCATION: String = "res://components/DataInputs/"


## All UIPanels
var _panels: Dictionary[String, PackedScene] = {
	"UIDesk":			load(_p("UIDesk")),
	"UIFunctions":		load(_p("UIFunctions")),
	"UIPlaybacks":		load(_p("UIPlaybacks")),
	"UIUniverses":		load(_p("UIUniverses")),
	"UISettings":		load(_p("UISettings")),
	"UISaveLoad":		load(_p("UISaveLoad")),
}


## All UIPopups
var _popups: Dictionary[String, PackedScene] = {
	"UIPopupDialog": 	load(_u("UIPopupDialog"))
}


## All DataInputs by DataType
var _data_inputs: Dictionary[Data.Type, PackedScene] = {
	Data.Type.NULL:		load(_d("DataInputNull")),
	Data.Type.STRING:	load(_d("DataInputString")),
	Data.Type.BOOL:		load(_d("DataInputBool")),
	Data.Type.INT:		load(_d("DataInputInt")),
	Data.Type.FLOAT:	load(_d("DataInputFloat")),
	Data.Type.NAME:		load(_d("DataInputString")),
}

## All UIPanels sorted by category
var _panels_by_category: Dictionary[String, Array] = {
	"Panels": [
		"UIDesk",
		"UIFunctions",
		"UIPlaybacks",
		"UIUniverses",
		"UISettings",
		"UISaveLoad",
	],
}


## Returns the file path of a UIPanel
func _p(p_panel_class: String) -> String:
	return str(UI_PANEL_LOCATION, p_panel_class, "/", p_panel_class, ".tscn")


## Returns the file path of a UIPopup
func _u(p_popup_class: String) -> String:
	return str(UI_POPUP_LOCATION, p_popup_class, "/", p_popup_class, ".tscn")


## Returns the file path of a DataInput
func _d(p_data_input_class: String) -> String:
	return str(DATA_INPUT_LOCATION, p_data_input_class, "/", p_data_input_class, ".tscn")


## Returns the PackedScene for a UIPanel
func get_panel_scene(p_panel_class: String) -> PackedScene:
	return _panels.get(p_panel_class, null)


## Returns the PackedScene for a UIPopup
func get_popup_scene(p_popup_class: String) -> PackedScene:
	return _popups.get(p_popup_class, null)


## Returns the PackedScene for a DataInput
func get_data_input_scene(p_data_type: Data.Type) -> PackedScene:
	return _data_inputs.get(p_data_type, null)


## Creates a new instance of a panel
func instance_panel(p_panel_class: Variant) -> UIPanel:
	if p_panel_class is Script:
		p_panel_class = String((p_panel_class as Script).get_global_name())
	
	if p_panel_class is not String or not has_panel(p_panel_class):
		return null
	
	return _panels[p_panel_class].instantiate()


## Creates a new instance of a panel
func instance_popup(p_popup_class: Variant) -> UIPopup:
	if p_popup_class is Script:
		p_popup_class = String((p_popup_class as Script).get_global_name())
	
	if p_popup_class is not String or not has_popup(p_popup_class):
		return null
	
	return _popups[p_popup_class].instantiate()


## Creates a new instance of a panel
func instance_data_input(p_data_type: Data.Type) -> DataInput:
	if not has_data_input(p_data_type):
		var null_type: DataInputNull = _data_inputs[Data.Type.NULL].instantiate()
		
		null_type.ready.connect(func ():
			null_type.set_unsupported_type(p_data_type)
		)
		
		return null_type
	
	return _data_inputs[p_data_type].instantiate()


## Checks if a UIPanel exists
func has_panel(p_panel_class: String) -> bool:
	return _panels.has(p_panel_class)


## Checks if a UIPopup exists
func has_popup(p_popup_class: String) -> bool:
	return _popups.has(p_popup_class)


## Checks if a DataInput exists
func has_data_input(p_data_type: Data.Type) -> bool:
	return _data_inputs.has(p_data_type)


## Gets all the panel categories
func get_panel_categories() -> Array:
	return _panels_by_category.keys()


## Gets all the panels in the given category
func get_panels_in_category(p_category: String) -> Array:
	return _panels_by_category.get(p_category, [])
