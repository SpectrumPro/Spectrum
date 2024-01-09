extends Window

var fixture_path = Globals.fixture_path
var current_fixture = {}

var options = {
	"channel":0,
	"universe":0,
	"mode":0,
	"quantity":0,
	"offset":0,
}

func _ready():
	var access = DirAccess.open(fixture_path)
	
	for fixture_folder in access.get_directories():
		
		for fixture in access.open(fixture_path+"/"+fixture_folder).get_files():
			
			var manifest_file = FileAccess.open(fixture_path+fixture_folder+"/"+fixture, FileAccess.READ)
			var manifest = JSON.parse_string(manifest_file.get_as_text())
			
			if Globals.fixtures.has(manifest.manufacturerKey):
				Globals.fixtures[manifest.manufacturerKey][manifest.name] = manifest
			else:
				Globals.fixtures[manifest.manufacturerKey] = {manifest.name:manifest}
	
	var tree = Globals.nodes.fixture_tree
	var root = tree.create_item()
	tree.hide_root = true
	
	for manufacturer in Globals.fixtures.keys():
		var manufacturer_item = tree.create_item(root)
		manufacturer_item.set_text(0, manufacturer)
		manufacturer_item.collapsed = true
		
		for fixture in Globals.fixtures[manufacturer].keys():
			var fixture_item = tree.create_item(manufacturer_item)
			fixture_item.set_text(0, Globals.fixtures[manufacturer][fixture].name)
	
	Globals.nodes.fixture_tree.item_selected.connect(self._item_selected)
	Globals.nodes.fixture_modes_option.item_selected.connect(self._mode_item_selected)
	

func reload_menue():
	if not current_fixture:return
	
	Globals.nodes.fixture_channel_list.clear()
	for channel in current_fixture.modes[options.mode].channels:
		if not channel == null:
			Globals.nodes.fixture_channel_list.add_item(channel)
	
	Globals.nodes.fixture_modes_option.clear()
	for mode in current_fixture.modes:
		Globals.nodes.fixture_modes_option.add_item(mode.name)
	Globals.nodes.fixture_modes_option.selected = options.mode
	

func _item_selected():
	var selected = Globals.nodes.fixture_tree.get_selected()
	if not selected.get_parent().get_parent(): return
	
	var manufacturer = selected.get_parent().get_text(0)
	var fixture = selected.get_text(0)
	
	current_fixture = Globals.fixtures[manufacturer][fixture]
	
	options.mode = 0
	reload_menue()

func _mode_item_selected(index):
	options.mode = index
	reload_menue()
	
func reload_universes():
	Globals.nodes.fixture_universe_option.clear()	
	for universe in Globals.universes.values():
		Globals.nodes.fixture_universe_option.add_item(universe.name)

func _on_close_requested():
	self.visible = false

func _show():
	self.popup()
