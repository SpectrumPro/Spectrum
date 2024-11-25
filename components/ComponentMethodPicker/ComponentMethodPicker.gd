# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name ComponentMethodPicker extends PanelContainer
## Allow for choosing method on object to call by buttons sliders


## Emitted when the user confirms the method
signal method_confired(method_trigger: MethodTrigger)

## Emitted when the user presses the cancel button 
signal cancled()

## Emitted when the remove binding button is pressed
signal remove_requested()


## The ItemList used for listing methods
@onready var _method_list: ItemList = $VBoxContainer/PanelContainer2/HSplitContainer/VBoxContainer/MethodList

## The component used
var component: EngineComponent = null : set = set_component

## The current method
var _current_method: Dictionary = {}

## The HBox container for parameter controls
var _parameters_v_box: VBoxContainer = null

## The method trigger to be returned
var _method_trigger: MethodTrigger = MethodTrigger.new()

## Contains the args that will be auto loaded when loading a pre-existing config
var _saved_args: Array = []


## Sets the method config
func set_method_config(method_trigger: MethodTrigger) -> void:
	if method_trigger.get_uuid() in ComponentDB.components:
		_method_trigger = MethodTrigger.new().deseralize(method_trigger.seralize())
		_saved_args = _method_trigger.args
		set_component(ComponentDB.components[_method_trigger.get_uuid()])
		
		var index: int = component.accessible_methods.keys().find(_method_trigger.get_method_name())
		_method_list.select(index)
		_on_method_list_item_selected(index)
		
	

## Sets the component
func set_component(p_component: EngineComponent) -> void:
	component = p_component
	_update_method_list()
	
	if component:
		$VBoxContainer/PanelContainer/HBoxContainer/PanelContainer/HBoxContainer/CurrentObject.text = component.name
		$VBoxContainer/PanelContainer2/HSplitContainer/VBoxContainer2/PanelContainer3/VBoxContainer/SelectAnObject.hide()
		_method_trigger.set_uuid(component.uuid)
	else:
		$VBoxContainer/PanelContainer2/HSplitContainer/VBoxContainer2/PanelContainer3/VBoxContainer/SelectAnObject.show()
	

## Updates the list of methods
func _update_method_list() -> void:
	_method_list.clear()
	
	for method_name: String in component.accessible_methods.keys():
		var accessible_method: Dictionary = component.accessible_methods[method_name]
		
		_method_list.add_item(method_name.capitalize())
	
	_update_parameter_controls()


## Updates the Parameter controls for the current method
func _update_parameter_controls() -> void:
	if _current_method:
		if _current_method.types[0] == TYPE_NIL:
			$VBoxContainer/PanelContainer2/HSplitContainer/VBoxContainer2/PanelContainer3/VBoxContainer/HasNoArgs.show()
			$VBoxContainer/PanelContainer2/HSplitContainer/VBoxContainer2/PanelContainer3/VBoxContainer/SelectToEdit.hide()
			_remove_old_parameter_list()
			_method_trigger.args = []
			
		else:
			$VBoxContainer/PanelContainer2/HSplitContainer/VBoxContainer2/PanelContainer3/VBoxContainer/HasNoArgs.hide()
			$VBoxContainer/PanelContainer2/HSplitContainer/VBoxContainer2/PanelContainer3/VBoxContainer/SelectToEdit.hide()
			_reload_parameter_list()
			
	else:
		$VBoxContainer/PanelContainer2/HSplitContainer/VBoxContainer2/PanelContainer3/VBoxContainer/HasNoArgs.hide()
		$VBoxContainer/PanelContainer2/HSplitContainer/VBoxContainer2/PanelContainer3/VBoxContainer/SelectToEdit.show()


## Reloads the list of parameter controls
func _reload_parameter_list() -> void:
	_remove_old_parameter_list()
	
	_method_trigger.args = []
	_parameters_v_box = VBoxContainer.new()
	
	if _current_method and len(_current_method.types):
		_method_trigger.args.resize(len(_current_method.types))
		_method_trigger.args.fill(null)
		
		for index: int in len(_current_method.types):
			var data_type: int = _current_method.types[index]
			var value: Variant = null
			
			if len(_current_method.arg_description) - 1 < index:
				break
			
			if len(_saved_args) - 1 >= index:
				if typeof(_saved_args[index]) == _current_method.types[index]:
					value = _saved_args[index]
			
			match data_type:
				TYPE_INT:
					if value == null: value = 0
					_parameters_v_box.add_child(_create_int_control(index, _current_method.arg_description[index], value))
				TYPE_FLOAT:
					if value == null: value = 0
					_parameters_v_box.add_child(_create_float_control(index, _current_method.arg_description[index], value))
				TYPE_BOOL:
					if value == null: value = false
					_parameters_v_box.add_child(_create_bool_control(index, _current_method.arg_description[index], value))
				_:
					_parameters_v_box.add_child(_create_unsuported(data_type, _current_method.arg_description[index]))
			
			_method_trigger.args[index] = value
			
	
	$VBoxContainer/PanelContainer2/HSplitContainer/VBoxContainer2/PanelContainer3/VBoxContainer.add_child(_parameters_v_box)


func _remove_old_parameter_list() -> void:
	if is_instance_valid(_parameters_v_box):
		_parameters_v_box.queue_free()


func _create_int_control(arg_index: int, arg_description: String, value: int = 0) -> Control:
	var spin_box: SpinBox = SpinBox.new()
	spin_box.prefix = "int: "
	
	spin_box.set_value_no_signal(value)
	spin_box.value_changed.connect(func (new_value: int): _method_trigger.args[arg_index] = new_value)
	
	return _get_base_control(arg_description, spin_box)


func _create_float_control(arg_index: int, arg_description: String, value: float = 0) -> Control:
	var spin_box: SpinBox = SpinBox.new()
	spin_box.step = 0.001
	spin_box.prefix = "float: "
	
	spin_box.set_value_no_signal(value)
	spin_box.value_changed.connect(func (new_value: float): _method_trigger.args[arg_index] = new_value)
	
	return _get_base_control(arg_description, spin_box)


func _create_bool_control(arg_index: int, arg_description: String, value: bool = false) -> Control:
	var check_button: CheckButton = CheckButton.new()
	check_button.text = "True / False"
	
	check_button.set_pressed_no_signal(value)
	check_button.toggled.connect(func (toggled_on: bool): _method_trigger.args[arg_index] = toggled_on)
	
	return _get_base_control(arg_description, check_button)


func _create_unsuported(data_type: int, arg_description: String) -> Control:
	var label: Label = Label.new()
	label.text = "Type: " + type_string(data_type)
	
	return _get_base_control("(Unsupported): " + arg_description, label)


func _get_base_control(arg_description: String, controls: Control) -> Control:
	var base: Control = load("res://components/ComponentMethodPicker/ParameterControls/Base.tscn").instantiate()
	base.get_node("HBox/Label").text = arg_description
	
	if not controls.custom_minimum_size:
		controls.custom_minimum_size = Vector2(200, 0)
	
	base.get_node("HBox/InputContainer").add_child(controls)
	return base


## Called when the change object button is pressed
func _on_change_object_pressed() -> void:
	Interface.show_object_picker(ObjectPicker.SelectMode.Single, _on_object_picker_object_selected)


## Called when an object is choosen
func _on_object_picker_object_selected(objects: Array[EngineComponent]) -> void:
	set_component(objects[0])


## Called when a method is selected in the method list
func _on_method_list_item_selected(index: int) -> void:
	if component:
		_current_method = component.accessible_methods.values()[index]
		_method_trigger.set_method_name(component.accessible_methods.keys()[index])
		_update_parameter_controls()
		
		$VBoxContainer/PanelContainer/HBoxContainer/Confirm.disabled = false


## Called when the confirm button is pressed
func _on_confirm_pressed() -> void: method_confired.emit(_method_trigger)

## Called when the cansel button is pressed
func _on_cancel_pressed() -> void: cancled.emit()

## Called wen the remove binding button is pressed
func _on_remove_binding_pressed() -> void: remove_requested.emit()
