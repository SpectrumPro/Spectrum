extends Node
class_name Fixture

var config = {
	"universe":null,
	"channel":1,
	"length":1,
	"fixture_brand":"",
	"fixture_name":"",
	"display_name":"",
	"file_path":"",
	"uuid":""
}

var channels = {}
var channel_ranges = {}

var channel_configuration = {}

var compiled_dmx_data = {}

var overrides = {}


func from(universe, manifest, channel, mode, name, uuid):
	channel_ranges = manifest.get("channels", {})
	channels = manifest.modes.values()[mode].channels
	config.universe = universe
	config.channel = channel
	config.length = len(manifest.modes.values()[mode].channels)
	config.fixture_brand = manifest.info.brand
	config.fixture_name = manifest.info.name
	config.name = name
	config.file_path = manifest.info.get("file_path", "")
	config.uuid = uuid
	
	return self

#func determine_color_model(fixture_channels):
	#var color_model = []
#
	#for channel_name in fixture_channels.keys():
		#var channel_info = fixture_channels[channel_name]
		#var capability_type = channel_info.get("capabilities", {}).get("type", "").to_lower()
#
		#if capability_type == "colorintensity":
			#var color = channel_info.get("capabilities", {}).get("color", "").to_lower()
			#color_model.append(color)
#
	#if "cyan" in color_model and "magenta" in color_model and "yellow" in color_model:
		#return "CYM"
	#elif "red" in color_model and "green" in color_model and "blue" in color_model:
		#return "RGB"
	## Add more conditions for other color models if needed
#
	#return "Unknown"


func set_color_rgb(r,g,b):
	if "ColorIntensityRed" in channels:
		compiled_dmx_data[channels.find("ColorIntensityRed")+config.channel] = int(remap(r, 0.0, 1.0, 0.0, 255.0))
	if "ColorIntensityGreen" in channels:
		compiled_dmx_data[channels.find("ColorIntensityGreen")+config.channel] = int(remap(g, 0.0, 1.0, 0.0, 255.0))
	if "ColorIntensityBlue" in channels:
		compiled_dmx_data[channels.find("ColorIntensityBlue")+config.channel] = int(remap(b, 0.0, 1.0, 0.0, 255.0))
	#print(compiled_dmx_data)
	config.universe.set_fixture_data(compiled_dmx_data)
