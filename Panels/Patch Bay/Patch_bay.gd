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
	Core.universe_added.connect(self._reload_universes)
	Core.universes_removed.connect(self._reload_universes)


func _new_universe() -> Universe:
	## Creates a new Universe, and calls the reload_universes subscription
	
	var new_universe: Universe = Core.new_universe("Universe " + str( len( Core.universes.keys() ) + 1 ) )
	
	return new_universe


func _reload_universes(_universe) -> void:
	## Reloads the list of Universes in the UI
	
	if not is_instance_valid(_current_universe):
		_current_universe = null
	
	for old_list_item: Control in self.get_node(universe_list).get_children():
		old_list_item.get_parent().remove_child(old_list_item)
		old_list_item.queue_free()
	
	if not _current_universe:
		_set_universe_controls_enabled(false)
	
	for universe: Universe in Core.universes.values():
		_add_universe_list_item(universe)



func _add_universe_list_item(universe: Universe) -> void:
	## Adds a list item to the universe list
	
	var new_list_item: Control = Globals.components.list_item.instantiate()
	
	new_list_item.set_item_name(universe.name)
	new_list_item.control_node = self
	new_list_item.name = universe.uuid
	
	new_list_item.set_meta("object", universe)
	
	if _current_universe and _current_universe.uuid == universe.uuid:
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


func _new_output() -> void:
	## Adds a new ArtNetOutput plugin to the currently selected universe
	
	_current_universe.new_output(ArtNetOutput)


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


func _reload_io(_output=null) -> void:
	## Reloads the Input and Output lists for the currently selected Universe
	
	if not is_instance_valid(_current_io):
		_current_io = null
	
	# Delete the the current output nodes
	for old_list_item: Control in self.get_node(universe_outputs).get_children():
		old_list_item.get_parent().remove_child(old_list_item)
		old_list_item.queue_free()
		
	# If _current_universe is not defined, exit the function now, this will only delete the current IO nodes and leave the list empty
	if not _current_universe or not _current_io:
		_change_io_config(null)
		_set_io_type_option("")
		if not _current_universe:
			return
	
	# Loop through all outputs in _current_universe, and add them to the list
	for output: DataIOPlugin in _current_universe.outputs.values():
		_add_output_list_item(output)


func _add_output_list_item(output: DataIOPlugin) -> void:
	## Adds a list_item component to the output list
	
	var new_list_item: Control = Globals.components.list_item.instantiate()
	new_list_item.set_item_name(output.name)
	new_list_item.control_node = self
	new_list_item.name = output.uuid
	
	new_list_item.set_meta("object", output)
	
	if _current_io and _current_io.uuid == output.uuid:
		new_list_item.set_highlighted(true)
		_set_io_type_option("output")
		self.get_node(universe_io_type).selected = Globals.output_plugins.keys().find(output.name)
		_change_io_config(output)
	else:
		new_list_item.set_highlighted(false)
		
	self.get_node(universe_outputs).add_child(new_list_item)


func _new_channel_override() -> void:
	## WIP function to add a channel override
	
	pass


func edit_request(list_item: Control) -> void:
	## Called when the edit button is pressed on any IO or Universe
	
	if list_item.get_meta("object") is Universe:
		if _current_universe:
			self.get_node(universe_list).get_node(_current_universe.uuid).set_highlighted(false)
		
		_current_universe = list_item.get_meta("object")
		
		_current_universe.output_added.connect(self._reload_io)
		_current_universe.output_removed.connect(self._reload_io)
		
		self.get_node(universe_list).get_node(_current_universe.uuid).set_highlighted(true)
		
		self.get_node(universe_name).text = _current_universe.name
		_set_universe_controls_enabled(true)
		_reload_io()
	
	elif list_item.get_meta("object") is DataIOPlugin:
		if _current_io:
			self.get_node(universe_outputs).get_node(_current_io.uuid).set_highlighted(false)
		_current_io = list_item.get_meta("object")
		self.get_node(universe_outputs).get_node(_current_io.uuid).set_highlighted(true)
		
		_reload_io()


func _set_io_type_option(io_type: String) -> void:
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
				for name in Core.output_plugins:
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
				
				print("about to delete")
				
				_delete_universe(list_item.get_meta("object"))
				
			elif list_item.get_meta("object") is DataIOPlugin:
				_delete_io(list_item.get_meta("object"))
				
			).bind(list_item))
	add_child(confirmation_dialog)


func _delete_universe(universe: Universe) -> void:
	## Deletes a Universe
	
	print("deleting universe")
	
	Core.delete_universe(universe)
	_current_io = null
	_current_universe = null
	
	_set_universe_controls_enabled(false)


func _delete_io(io: DataIOPlugin) -> void:
	## Deletes an IO plugin
	
	var to_delete: DataIOPlugin = io
	_current_universe.remove_output(to_delete)
	if to_delete == _current_io:
		_current_io = null
		


func _on_io_type_item_selected(index:int) -> void:
	## Called when the user selects an IO type from the list dropdown
	
	_current_universe.remove_output(_current_io)
	_current_io = _current_universe.new_output(Core.output_plugins.values()[index].plugin)
	
	_reload_io()


func _on_new_universe_pressed() -> void:
	_new_universe()


func _on_new_channel_overide_pressed() -> void:
	pass


func _on_new_output_pressed() -> void:
	_new_output()


func _on_universe_name_text_changed(new_text) -> void:
	_current_universe.name = new_text
