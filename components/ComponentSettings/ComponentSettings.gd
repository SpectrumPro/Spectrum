# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name ComponentSettings extends PanelContainer
## ComponentSettings


## SettingsModuleContainer VBox
@export var _settings_module_container: VBoxContainer


## Sets the component
func set_component(component: EngineComponent) -> void:
	for old_module: ClassSettingsModule in _settings_module_container.get_children():
		old_module.queue_free()
		_settings_module_container.remove_child(old_module)
	
	if not is_instance_valid(component):
		return
	
	for classname: String in component.class_tree:
		var new_module: ClassSettingsModule = load("res://components/ComponentSettings/ClassSettingsModule/ClassSettingsModule.tscn").instantiate()
		new_module.set_title(classname)
		
		for setting: Dictionary in component.get_settings(classname).values():
			if setting.data_type == Utils.TYPE_CUSTOM:
				var panel: Control = setting.custom_panel.instantiate()
				
				if panel.has_method(setting.entry_point):
					panel.get(setting.entry_point).call(component)
				
				new_module.show_custom(panel)
			else:
				new_module.show_setting(setting.setter, setting.getter, setting.signal, setting.data_type, setting.visual_line, setting.visual_name)
		
		_settings_module_container.add_child(new_module)
