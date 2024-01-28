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
	"uuid":"",
	"mode":""
}

var channels = {}
var channel_ranges = {}
var compiled_dmx_data = {}
var virtual_fixtures = []
var parameters = {}

func serialize():
	var serialized_virtual_fixtures = []
	for fixture in virtual_fixtures:
		serialized_virtual_fixtures.append(fixture.serialize())
		
	return {
			"display_name":config.display_name,
			"fixture_brand":config.fixture_brand,
			"fixture_name":config.fixture_name,
			"mode":config.mode,
			"virtual_fixtures":serialized_virtual_fixtures
	}

func from(universe, manifest, channel, mode, name, uuid, virtual_fixtures):
	print("Making new fixture from manifest")
	channel_ranges = manifest.get("channels", {})
	channels = manifest.modes.values()[mode].channels
	config.universe = universe
	config.channel = channel
	config.length = len(manifest.modes.values()[mode].channels)
	config.fixture_brand = manifest.info.brand
	config.fixture_name = manifest.info.name
	config.name = name
	config.uuid = uuid
	config.mode = mode
	
	if virtual_fixtures:
		for fixture in virtual_fixtures:
			Globals.nodes.virtual_fixtures.from(fixture, self)
	
	return self

func set_color_rgb(r,g,b):
	if "ColorIntensityRed" in channels:
		compiled_dmx_data[channels.find("ColorIntensityRed")+config.channel] = int(remap(r, 0.0, 1.0, 0.0, 255.0))
	if "ColorIntensityGreen" in channels:
		compiled_dmx_data[channels.find("ColorIntensityGreen")+config.channel] = int(remap(g, 0.0, 1.0, 0.0, 255.0))
	if "ColorIntensityBlue" in channels:
		compiled_dmx_data[channels.find("ColorIntensityBlue")+config.channel] = int(remap(b, 0.0, 1.0, 0.0, 255.0))
	#print(compiled_dmx_data)
	config.universe.set_fixture_data(compiled_dmx_data)
	
	parameters.color = Color(r, g, b)
	
	update_virtual_fixtures()
	
func update_virtual_fixtures():
	if not virtual_fixtures:return
	
	for fixture in virtual_fixtures:
		fixture.set_color_rgb(parameters.color)
	
func add_virtual_fixture(node):
	virtual_fixtures.append(node)
