# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name SettingsManagerView extends UIComponent
## SettingsManagerView


## The VBox for all SettingsManagerModuleView
@onready var _view_container: VBoxContainer = $VBoxContainer

## The current SettingsManager
var _manager: SettingsManager

## Stores each ModuleView by its class
var _views_by_class: Dictionary[String, SettingsManagerModuleView]


## Init
func _init() -> void:
	_set_class_name("SettingsManagerView")


## Resets this SettingsManagerView
func reset() -> void:
	for view: SettingsManagerModuleView in _views_by_class.values():
		_view_container.remove_child(view)
		view.queue_free()
	
	_manager = null
	_views_by_class.clear()


## Sets the SettingsManager
func set_manager(p_manager: SettingsManager) -> void:
	reset()
	_manager = p_manager
	
	for classname: String in _manager.get_inheritance_list():
		var view: SettingsManagerModuleView = preload("res://components/SettingsManagerView/ModuleView/SettingsManagerModuleView.tscn").instantiate()
		
		view.set_title(classname)
		view.set_disabled(true)
		
		_views_by_class[classname] = view
		_view_container.add_child(view)
	
	for module: SettingsModule in _manager.get_modules().values():
		var view: SettingsManagerModuleView
		
		if module.get_visual_category() in _views_by_class:
			view = _views_by_class[module.get_visual_category()]
		else:
			view = _views_by_class[_manager.get_inheritance_root()]
		
		view.set_disabled(false)
		view.show_module(module)


## Sets the SettingsManager
func get_manager() -> SettingsManager:
	return _manager
