# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name Fixture extends EngineComponent
## Engine class to control parameters of fixtures

signal color_changed(color: Color) ## Emitted when the color of this fixture is changed 
signal mode_changed(mode: int) ## Emitted when the mode of the fixture is changed
signal channel_changed(new_channel: int) ## Emitted when the channel of the fixture is changed

signal selected(selected: bool)

## Contains metadata infomation about this fixture
var meta: Dictionary = { 
	"fixture_brand":"",
	"fixture_name":"",
	"display_name":"",
	"file_path":"",
}

var universe: Universe ## The universe this fixture is patched to
var channel: int ## Universe channel of this fixture
var length: int ## Channel length, from start channel, to end channel
var mode: int ## Current mode
var manifest: Dictionary ## Fixture manifest
var channels: Array ## Channels this fixture uses, and what they do
var channel_ranges: Dictionary ## What happenes at each channel, at each value

var is_selected: bool = false

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
		"universe":universe.get_uuid(),
		"channel":channel,
		"mode":mode,
		"meta":meta,
		"user_meta": serialize_meta(),
		"uuid":uuid
	}


func set_color_rgb(r,g,b) -> void:
	## Sets the color of this fixture in 0-255 RBG values
	
	if "ColorIntensityRed" in channels:
		_compiled_dmx_data[int(channels.find("ColorIntensityRed") + channel)] = int(r)
	if "ColorIntensityGreen" in channels:
		_compiled_dmx_data[int(channels.find("ColorIntensityGreen") + channel)] = int(g)
	if "ColorIntensityBlue" in channels:
		_compiled_dmx_data[int(channels.find("ColorIntensityBlue") + channel)] = int(b)
	universe.set_fixture_data(_compiled_dmx_data)
	
	_parameters.color = Color(r, g, b)
	
	color_changed.emit(_parameters.color)


func set_selected(state: bool) -> void:
	is_selected = state
	selected.emit(state)


func delete() -> bool:
	## Called when this fixture is about to be deleted
	
	return true
