# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name ComponentSettings extends PanelContainer
## ComponentSettings


## SettingsModuleContainer VBox
@export var _settings_module_container: VBoxContainer

## The current component
var _component: EngineComponent = null


## Sets the component
func set_component(component: EngineComponent) -> void:
	for old_module: ClassSettingsModule in _settings_module_container.get_children():
		old_module.queue_free()
		_settings_module_container.remove_child(old_module)
	
	_component = component
	if not is_instance_valid(component):
		return
	
	for classname: String in component.class_tree:
		var new_module: ClassSettingsModule = load("res://components/ComponentSettings/ClassSettingsModule/ClassSettingsModule.tscn").instantiate()
		new_module.set_title(classname)
		
		var settings: Array = component.get_settings(classname).values()
		if settings:
			for setting: Dictionary in settings:
				match setting.data_type:
					Data.Type.CUSTOMPANEL:
						var panel: Control = setting.custom_panel.instantiate()
						
						if panel.has_method(setting.entry_point):
							panel.ready.connect(panel.get(setting.entry_point).call.bind(component), CONNECT_ONE_SHOT)
						
						new_module.show_custom(panel)
					
					_:
						new_module.show_setting(setting.setter, setting.getter, setting.signal, setting.data_type, setting.visual_line, setting.visual_name, setting.min, setting.max, setting.enum)
		else:
			new_module.set_disable(true)
		
		_settings_module_container.add_child(new_module)


## Gets the component
func get_component() -> EngineComponent:
	return _component
