# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name Fixture extends EngineComponent
## Engine class to control parameters of fixtures

signal color_changed(color: Color) ## Emitted when the color of this fixture is changed 
signal mode_changed(mode: int) ## Emitted when the mode of the fixture is changed
signal channel_changed(new_channel: int) ## Emitted when the channel of the fixture is changed

## Contains metadata infomation about this fixture
var meta: Dictionary = { 
	"fixture_brand":"",
	"fixture_name":"",
	"display_name":"",
}

var universe: Universe ## The universe this fixture is patched to
var channel: int ## Universe channel of this fixture
var length: int ## Channel length, from start channel, to end channel
var mode: int ## Current mode
var manifest: Dictionary ## Fixture manifest
var channels: Array ## Channels this fixture uses, and what they do
var channel_ranges: Dictionary ## What happenes at each channel, at each value


## Contains all the parameters inputted by other function in spectrum, ie scenes, programmer, ect. 
## Each input it added to this dict with a id for each item, allowing for HTP and LTP calculations
var current_input_data: Dictionary = {} 

var _compiled_dmx_data: Dictionary
var _parameters: Dictionary


func _init(i: Dictionary = {}) -> void:
	## Init function to create a new fixture, from a set of prexisting infomation. If no infomation is passed a blank fixture is returne
	
	if not i:
		return
	
	universe = i.universe as Universe
	channel = i.channel as int
	mode = i.mode as int
	length = len(i.manifest.modes.values()[mode].channels)
	manifest = i.manifest as Dictionary
	channel_ranges = i.manifest.get("channels", {})
	channels = i.manifest.modes.values()[mode].channels
	
	meta.fixture_brand = i.manifest.info.brand
	meta.fixture_name = i.manifest.info.name
	
	self.name_changed.connect(
		func(new_name: String):
			universe.fixture_name_changed.emit(self, new_name)
	)
	
	super._init()

func serialize() -> Dictionary:
	## Returnes serialized infomation about this fixture
	print(uuid)
	return {
		"universe":universe.uuid,
		"channel":channel,
		"mode":mode,
		"meta":meta,
		"user_meta": serialize_meta(),
	}


func recompile_data() -> void:
	## Compiles dmx data from this fixture
	
	var highest_valued_data: Dictionary = {}
	
	for input_data_id in current_input_data:
		for input_data in current_input_data[input_data_id]:
			match input_data:
				"color":
					highest_valued_data["color"] = Utils.get_htp_color(highest_valued_data.get("color", Color()), current_input_data[input_data_id][input_data])
		
	universe.set_data(_compiled_dmx_data)
	_set_color(highest_valued_data.get("color", Color.BLACK))


func _set_color(color: Color) -> void:
	if "ColorIntensityRed" in channels:
		_compiled_dmx_data[int(channels.find("ColorIntensityRed") + channel)] = color.r8
	if "ColorIntensityGreen" in channels:
		_compiled_dmx_data[int(channels.find("ColorIntensityGreen") + channel)] = color.g8
	if "ColorIntensityBlue" in channels:
		_compiled_dmx_data[int(channels.find("ColorIntensityBlue") + channel)] = color.b8
	
	_parameters.color = color
	color_changed.emit(_parameters.color)


func set_color(color: Color, id: String = "overide") -> void:
	## Sets the color of this fixture
	
	if color == Color.BLACK:
		_remove_current_input_data(id, "color")
	else:
		_add_current_input_data(id, "color", color)
	
	recompile_data()


func _add_current_input_data(id: String, key: String, value: Variant) -> void:
	if id not in current_input_data:
		current_input_data[id] = {}
	current_input_data[id][key] = value


func _remove_current_input_data(id: String, key: String) -> void:
	current_input_data.get("id", {}).erase(key)
	if not current_input_data.get("id", false):
		current_input_data.erase(id) 
