# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends Control
## Handles UI elements for setting up and tweaking universes.
## Including inputs, outputs, and channel overrides.

@export var universe_list: NodePath
@export var universe_inputs: NodePath
@export var universe_outputs: NodePath
@export var channel_overrides_list: NodePath
@export var universe_name: NodePath
@export var universe_controls: NodePath
@export var universe_io_controls: NodePath
@export var universe_io_type: NodePath

var _current_universe: Universe
var _current_io: DataIOPlugin

func _ready() -> void:
	Globals.subscribe("reload_universes", self._reload_universes)
	Globals.subscribe("patch_bay_reload_io", self._reload_io)


func _new_universe() -> Universe:
	## Creates a new Universe, and calls the reload_universes subscription
	
	var new_universe: Universe = Globals.new_universe()
	new_universe.set_universe_name("Universe " + str(len(Globals.universes.keys())))
	
	Globals.call_subscription("reload_universes")
	return new_universe


func _reload_universes() -> void:
	## Reloads the list of Universes in the UI
	
	if not is_instance_valid(_current_universe):
		_current_universe = null
	
	for old_list_item: Control in self.get_node(universe_list).get_children():
		old_list_item.get_parent().remove_child(old_list_item)
		old_list_item.queue_free()
	
	if not _current_universe:
		_set_universe_controls_enabled(false)
	
	for universe: Universe in Globals.universes.values():
		_add_universe_list_item(universe)
	
	Globals.call_subscription("patch_bay_reload_io")


func _add_universe_list_item(universe: Universe) -> void:
	## Adds a list item to the universe list
	
	var new_list_item: Control = Globals.components.list_item.instantiate()
	new_list_item.set_item_name(universe.get_universe_name())
	new_list_item.control_node = self
	new_list_item.name = universe.get_uuid()
	
	new_list_item.set_meta("object", universe)
	
	if _current_universe and _current_universe.get_uuid() == universe.get_uuid():
		new_list_item.set_highlighted(true)
	else:
		new_list_item.set_highlighted(false)
		
	self.get_node(universe_list).add_child(new_list_item)


func _set_universe_controls_enabled(enabled:bool) -> void:
	## Enables or dissables the universe control bar
	
	for input_node: Control in self.get_node(universe_controls).get_children():
		if input_node is LineEdit:
			input_node.editable = enabled
		elif input_node is BaseButton:
			input_node.disabled = not enabled
			
	if not enabled:
		self.get_node(universe_name).text = ""


func _new_input() -> void:
	## WIP Function for adding a Universe input
	
	pass


func _new_output() -> void:
	## Adds a new output plugin to the currently selected universe, and calls reload_io()
	
	_current_universe.new_output()
	Globals.call_subscription("patch_bay_reload_io")


func _change_io_config(io: DataIOPlugin = null) -> void:
	## Updates the IO config list, used to set configs for each IO plugin
	
	# Delete old nodes
	for old_config_node: Control in self.get_node(universe_io_controls).get_children():
		old_config_node.get_parent().remove_child(old_config_node)
		old_config_node.queue_free()
	
	# If IO is not defined, exit the function now, this will only delete the current config and leave the config list empty
	if not io: 
		return
	
	# Loop through all exposed values, and instance a new input node to allow the user to adust the value
	for value_to_expose: Dictionary in io.exposed_values:
		_expose_value(value_to_expose)


func _expose_value(value_to_expose: Dictionary) -> void:
	## Exposes a value to the IO config list, so parameters of the current IO can be edited by the user
	
	var value_node_to_add: Control = value_to_expose.type.new()
	value_node_to_add.get(value_to_expose.signal).connect(value_to_expose.function)
	
	# If the exposed value has any parameters, (variables that need to be set). Set them, if they are a function, call the function, and use the result as the value
	for parameter: String in value_to_expose.parameters:
		if value_to_expose.parameters[parameter] is Callable:
			value_node_to_add.set(parameter, value_to_expose.parameters[parameter].call())
		else:
			value_node_to_add.set(parameter, value_to_expose.parameters[parameter])
	
	var container: HBoxContainer = HBoxContainer.new()
	var lable: Label = Label.new()
	
	lable.text = value_to_expose.name
	
	container.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	lable.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	value_node_to_add.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	
	container.add_child(lable)
	container.add_child(value_node_to_add)
	self.get_node(universe_io_controls).add_child(container)


func _reload_io() -> void:
	## Reloads the Input and Output lists for the currently selected Universe
	
	if not is_instance_valid(_current_io):
		_current_io = null
	
	# Delete the the current output nodes
	for old_list_item: Control in self.get_node(universe_outputs).get_children():
		old_list_item.get_parent().remove_child(old_list_item)
		old_list_item.queue_free()
		
	# If _current_universe is not defined, exit the function now, this will only delete the current IO nodes and leave the list empty
	if not _current_universe or not _current_io:
		_change_io_config()
		_set_io_type_option("")
		if not _current_universe:
			return
	
	# Loop through all outputs in _current_universe, and add them to the list
	for output: DataIOPlugin in _current_universe.get_all_outputs().values():
		_add_output_list_item(output)


func _add_output_list_item(output: DataIOPlugin) -> void:
	## Adds a list_item component to the output list
	
	var new_list_item: Control = Globals.components.list_item.instantiate()
	new_list_item.set_item_name(output.get_name())
	new_list_item.control_node = self
	new_list_item.name = output.get_uuid()
	
	new_list_item.set_meta("object", output)
	
	if _current_io and _current_io.get_uuid() == output.get_uuid():
		new_list_item.set_highlighted(true)
		_set_io_type_option("output")
		self.get_node(universe_io_type).selected = Globals.output_plugins.keys().find(output.get_name())
		_change_io_config(output)
	else:
		new_list_item.set_highlighted(false)
		
	self.get_node(universe_outputs).add_child(new_list_item)


func _new_channel_override() -> void:
	## WIP function to add a channel override
	
	pass


func edit_request(list_item:Control) -> void:
	## Called when the edit button is pressed on any IO or Universe
	
	if list_item.get_meta("object") is Universe:
		if _current_universe:
			self.get_node(universe_list).get_node(_current_universe.get_uuid()).set_highlighted(false)
		
		_current_universe = list_item.get_meta("object")
		self.get_node(universe_list).get_node(_current_universe.get_uuid()).set_highlighted(true)
		
		self.get_node(universe_name).text = _current_universe.get_universe_name()
		_set_universe_controls_enabled(true)
		Globals.call_subscription("patch_bay_reload_io")
	
	elif list_item.get_meta("object") is DataIOPlugin:
		match list_item.get_meta("object").get_type():
			"input":
				pass
			
			"output":
				if _current_io:
					self.get_node(universe_outputs).get_node(_current_io.get_uuid()).set_highlighted(false)
				_current_io = list_item.get_meta("object")
				self.get_node(universe_outputs).get_node(_current_io.get_uuid()).set_highlighted(true)
				
		Globals.call_subscription("patch_bay_reload_io")


func _set_io_type_option(io_type:String) -> void:
	## Updates the list of IO types
	
	self.get_node(universe_io_type).clear()
	
	# If io_type is defined, iterate through the list of loaded IO plugins, and add them to the list
	# Otherwise dissable the list dropdown
	if io_type:
		self.get_node(universe_io_type).disabled = false
		match io_type:
			"input":
				pass
			"output":
				for name in Globals.output_plugins:
					self.get_node(universe_io_type).add_item(name)
	else:
		self.get_node(universe_io_type).disabled = true


func delete_request(list_item:Control) -> void:
	## Called when the delete button is pressed on any Universe or IO
	
	var confirmation_dialog: AcceptDialog = Globals.components.accept_dialog.instantiate()
	confirmation_dialog.dialog_text = "Are you sure you want to delete this? This action can not be undone"
	
	confirmation_dialog.confirmed.connect((
		func(list_item: Control):
			if list_item.get_meta("object") is Universe:
				_delete_universe(list_item.get_meta("object"))
				
			elif list_item.get_meta("object") is DataIOPlugin:
				_delete_io(list_item.get_meta("object"))
				
			).bind(list_item))
	add_child(confirmation_dialog)


func _delete_universe(universe: Universe) -> void:
	## Deletes a Universe
	
	Globals.delete_universe(universe)
	_current_io = null
	_current_universe = null
	
	_reload_universes()
	_set_universe_controls_enabled(false)


func _delete_io(io: DataIOPlugin) -> void:
	## Deletes an IO plugin
	
	var to_delete: DataIOPlugin = io
	match to_delete.get_type():
		"input":
			_current_universe.remove_input(to_delete)
		"output":
			_current_universe.remove_output(to_delete)
	if to_delete == _current_io:
		_current_io = null
		
	Globals.call_subscription("patch_bay_reload_io")


func _on_io_type_item_selected(index:int) -> void:
	## Called when the user selects an IO type from the list dropdown
	
	if _current_io:
		match _current_io.get_type():
			"input":
				_current_io = _current_universe.change_input_type(_current_io.get_uuid(), Globals.input_plugins.values()[index])
			"output":
				_current_io = _current_universe.change_output_type(_current_io.get_uuid(), Globals.output_plugins.values()[index])
	Globals.call_subscription("patch_bay_reload_io")


func _on_new_universe_pressed() -> void:
	_new_universe()


func _on_new_channel_overide_pressed() -> void:
	pass


func _on_new_input_pressed() -> void:
	pass


func _on_new_output_pressed() -> void:
	_new_output()


func _on_universe_name_text_changed(new_text) -> void:
	_current_universe.set_universe_name(new_text)
	_reload_universes()
