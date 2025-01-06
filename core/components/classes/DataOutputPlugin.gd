# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name DataOutputPlugin extends EngineComponent
## Base class for all output plugins

signal connection_state_changed(state: bool, note: String) ## Emited when this output connects or disconnects, added note for reason

var plugin_name: String = "Empty Output": set=set_plugin_name ## Name of this plugin
var plugin_description: String = "A base class for all data output plugins" ## Plugin description
var plugin_authors: Array = ["Liam Sherwin"] ## List of all the authors that created this plugin
var plugin_link: String = "https://github.com/SpectrumPro/spectrum-server" ## Link to this plugins website, or documentation

var dmx_data: Dictionary = {} ## Dictionary containing the dmx data for this output, stored as channel:value


## Checks if a child class has the "init" function, if so it calls it.
func _init(p_uuid: String = UUID_Util.v4()) -> void:

	super._init(p_uuid)
	self.name = plugin_name


## Starts this plugin
func start() -> void:
	
	connection_state_changed.emit(true, "Empty Output")
	# As this is the base class, this script does not connect to anything.
	print(plugin_name, " Started!")


## Stops this plugin
func stop() -> void:

	connection_state_changed.emit(false, "Empty Output")
	# As this is the base class, this script does not connect to anything.
	print(plugin_name, " Stoped")


## Outputs [mebmer DataOutputPlugin.dmx_data]
func output() -> void:

	# As this is the base class, this script does not really output anything, so we are just printing the dmx data
	print(dmx_data)


func set_plugin_name(new_name):
	plugin_name = new_name

	self.name = new_name
