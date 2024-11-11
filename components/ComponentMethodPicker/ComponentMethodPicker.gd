# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name ComponentMethodPicker extends PanelContainer
## Allow for choosing method on object to call by buttons sliders


## Emitted when the user confirms the method
signal method_confired(method: Callable)

## Emitted when the user presses the cancel button 
signal cancled()


## The ItemList used for listing methods
@onready var _method_list: ItemList = $VBoxContainer/PanelContainer2/HSplitContainer/VBoxContainer/MethodList

## The component used
var component: EngineComponent = null

## The current method
var _current_method: Dictionary = {}

## The HBox container for parameter controls
var _parameters_v_box: VBoxContainer = null


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
	
	_parameters_v_box = VBoxContainer.new()
	
	if _current_method:
		for index: int in len(_current_method.types):
			var data_type: int = _current_method.types[index]
			
			if len(_current_method.arg_description) - 1 < index:
				break
			
			match data_type:
				TYPE_INT:
					_parameters_v_box.add_child(_create_int_control(index, _current_method.arg_description[index]))
				TYPE_FLOAT:
					_parameters_v_box.add_child(_create_float_control(index, _current_method.arg_description[index]))
				TYPE_BOOL:
					_parameters_v_box.add_child(_create_bool_control(index, _current_method.arg_description[index]))
				_:
					_parameters_v_box.add_child(_create_unsuported(data_type, _current_method.arg_description[index]))
	
	$VBoxContainer/PanelContainer2/HSplitContainer/VBoxContainer2/PanelContainer3/VBoxContainer.add_child(_parameters_v_box)


func _remove_old_parameter_list() -> void:
	if is_instance_valid(_parameters_v_box):
		_parameters_v_box.queue_free()


func _create_int_control(arg_index: int, arg_description: String) -> Control:
	var spin_box: SpinBox = SpinBox.new()
	spin_box.prefix = "int: "
	
	return _get_base_control(arg_description, spin_box)


func _create_float_control(arg_index: int, arg_description: String) -> Control:
	var spin_box: SpinBox = SpinBox.new()
	spin_box.step = 0.001
	spin_box.prefix = "float: "
	
	return _get_base_control(arg_description, spin_box)


func _create_bool_control(arg_index: int, arg_description: String) -> Control:
	var check_button: CheckButton = CheckButton.new()
	check_button.text = "True / False"
	
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
	component = objects[0]
	$VBoxContainer/PanelContainer/HBoxContainer/PanelContainer/HBoxContainer/CurrentObject.text = component.name
	
	_update_method_list()


func _on_method_list_item_selected(index: int) -> void:
	if component:
		_current_method = component.accessible_methods.values()[index]
		_update_parameter_controls()


func _on_confirm_pressed() -> void:
	#method_confired.emit()
	pass


func _on_cancel_pressed() -> void:
	cancled.emit()
