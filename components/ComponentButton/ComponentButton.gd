# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name ComponentButton extends Button
## Button to select an EngineComponent


## Emitted when the object is changed
signal object_selected(object: EngineComponent)


## Classname filter to search for
@export var class_filter: Script

## Enables this button to follow global store mode
@export var enable_resolve_mode: bool = false

## Button enabled state
@export var enabled: bool = false

## Nodes group
@export_group("nodes")

## The control to act as the status label
@export var underline: Control


## The current object
var _component: EngineComponent = null

## The orignal user defined text of this button
var _orignal_text: String

## UUID of the EngineComponent to look for
var _look_for_component: String

## Signal connections for the EngineComponent
var _signal_group: SignalGroup = SignalGroup.new([
	_on_name_changed
])


## ready
func _ready() -> void:
	_orignal_text = get_text()
	set_enabled(enabled)


## Sets the select object
func set_component(o_component: EngineComponent) -> void:
	_signal_group.disconnect_object(_component)
	
	if not is_instance_valid(o_component):
		_component = null
		underline.set_modulate(ThemeManager.Colors.Statuses.Standby)
		return
	
	_component = o_component
	_signal_group.connect_object(_component)
	
	set_text(_component.name())
	underline.set_modulate(ThemeManager.Colors.Statuses.Normal)
	
	object_selected.emit(_component)


## Returns the object
func get_component() -> EngineComponent:
	return _component


## Looks for an object, or waits untill is added
func look_for(p_uuid: String) -> void:
	if _look_for_component:
		ComponentDB.remove_request(_look_for_component, _on_component_found)
	
	underline.set_modulate(ThemeManager.Colors.Statuses.Caution)
	_look_for_component = p_uuid
	ComponentDB.request_component(_look_for_component, _on_component_found)


## Sets the enabled state
func set_enabled(p_enabled) -> void:
	enabled = p_enabled
	
	if enabled and _component:
		underline.set_modulate(ThemeManager.Colors.Statuses.Normal)
	elif enabled and not _component:
		underline.set_modulate(ThemeManager.Colors.Statuses.Standby)
	elif enabled and not _component and _look_for_component:
		underline.set_modulate(ThemeManager.Colors.Statuses.Caution)
	elif not enabled:
		underline.set_modulate(ThemeManager.Colors.Statuses.Off)


## Called if ComponentDB find the component
func _on_component_found(p_component: EngineComponent) -> void:
	if ClassList.does_class_inherit(p_component.classname(), class_filter.get_global_name()):
		set_component(p_component)


## Called when the components name is changed
func _on_name_changed(new_name: String) -> void:
	text = new_name


## Called when the button is pressed
func _on_pressed() -> void:
	if not enabled:
		return
	
	Interface.prompt_object_picker(self, EngineComponent, class_filter.get_global_name()).then(func (p_component: EngineComponent):
		set_component(p_component)
	)
