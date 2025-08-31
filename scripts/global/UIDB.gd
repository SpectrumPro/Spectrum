# Copyright (c) 2025 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name ClientUIDB extends Node
## Contains a list of all the UIPanel classes


## File path for all UIPanels
const UI_PANEL_LOCATION: String = "res://panels/"

## File path for all UIPanels
const UI_POPUP_LOCATION: String = "res://panels/popups/"


## All UIPanels
var _panels: Dictionary[String, PackedScene] = {
	"UIDesk": load(_p("UIDesk")),
	"UIFunctions": load(_p("UIFunctions")),
	"UIPlaybacks": load(_p("UIPlaybacks")),
	"UIUniverses": load(_p("UIUniverses")),
	"UISettings": load(_p("UISettings")),
	"UISaveLoad": load(_p("UISaveLoad")),
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


## Returns the PackedScene for a panel
func get_panel_scene(p_panel_class: String) -> PackedScene:
	return _panels.get(p_panel_class, null)


## Creates a new instance of a panel
func instance_panel(p_panel_class: String) -> UIPanel:
	if not has_panel(p_panel_class):
		return null
	
	return _panels[p_panel_class].instantiate()


## Checks if a panel exists
func has_panel(p_panel_class: String) -> bool:
	return _panels.has(p_panel_class)


## Gets all the panel categories
func get_panel_categories() -> Array:
	return _panels_by_category.keys()


## Gets all the panels in the given category
func get_panels_in_category(p_category: String) -> Array:
	return _panels_by_category.get(p_category, [])
