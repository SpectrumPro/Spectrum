extends Control

var fixture_path = Globals.fixture_path
var current_fixture = {}

var options = {
	"channel":1,
	"mode":0,
	"quantity":1,
	"offset":0,
	"name":""
}
	#"add_fixture_window":get_tree().root.get_node("Main/Add Fixture"),
	#"add_fixture_menu":get_tree().root.get_node("Main/Add Fixture/Add Fixture/"),
	#"fixture_tree":get_tree().root.get_node("Main/Add Fixture/Add Fixture/MarginContainer/HSplitContainer/Fixture Tree"),
	#"fixture_channel_list":get_tree().root.get_node("Main/Add Fixture/Add Fixture/MarginContainer/HSplitContainer/PanelContainer/VBoxContainer/Channel List"),
	#"fixture_modes_option":get_tree().root.get_node("Main/Add Fixture/Add Fixture/MarginContainer/HSplitContainer/PanelContainer/VBoxContainer/HBoxContainer4/Modes"),
	#"fixture_universe_option":get_tree().root.get_node("Main/Add Fixture/Add Fixture/MarginContainer/HSplitContainer/PanelContainer/VBoxContainer/HBoxContainer3/Fixture Universe Option"),
	#"add_fixture_button":get_tree().root.get_node("Main/Add Fixture/Add Fixture/MarginContainer/HSplitContainer/PanelContainer/VBoxContainer/HBoxContainer2/Add Fixture Button"),
	#
	
@export var fixture_tree: NodePath
@export var fixture_channel_list: NodePath
@export var fixture_modes_option: NodePath
@export var fixture_universe_option: NodePath
@export var add_fixture_button: NodePath

func _ready():
	var access = DirAccess.open(fixture_path)
	
	for fixture_folder in access.get_directories():
		
		for fixture in access.open(fixture_path+"/"+fixture_folder).get_files():
			
			var manifest_file = FileAccess.open(fixture_path+fixture_folder+"/"+fixture, FileAccess.READ)
			var manifest = JSON.parse_string(manifest_file.get_as_text())
			
			manifest.info.file_path = fixture_path+fixture_folder+"/"+fixture
			
			if Globals.fixtures.has(manifest.info.brand):
				Globals.fixtures[manifest.info.brand][manifest.info.name] = manifest
			else:
				Globals.fixtures[manifest.info.brand] = {manifest.info.name:manifest}
	
	var tree = get_node(fixture_tree)
	var root = tree.create_item()
	tree.hide_root = true
	
	for manufacturer in Globals.fixtures.keys():
		var manufacturer_item = tree.create_item(root)
		manufacturer_item.set_text(0, manufacturer)
		manufacturer_item.collapsed = true
		
		for fixture in Globals.fixtures[manufacturer].keys():
			var fixture_item = tree.create_item(manufacturer_item)
			fixture_item.set_text(0, Globals.fixtures[manufacturer][fixture].info.name)
	
	get_node(fixture_tree).item_selected.connect(self._item_selected)
	get_node(fixture_modes_option).item_selected.connect(self._mode_item_selected)
	
	Globals.subscribe("reload_universes", self.reload_universes)
	reload_universes()

func reload_menue():
	if not current_fixture:return
	
	get_node(fixture_channel_list).clear()

	for channel in current_fixture.modes.values()[options.mode].channels:
		get_node(fixture_channel_list).add_item(str(channel))
	
	get_node(fixture_modes_option).clear()
	for mode in current_fixture.modes:
		get_node(fixture_modes_option).add_item(mode)
	get_node(fixture_modes_option).selected = options.mode
	

func _item_selected():
	var selected = get_node(fixture_tree).get_selected()
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
	get_node(fixture_universe_option).clear()
	for universe in Globals.universes.values():
		get_node(fixture_universe_option).add_item(universe.get_universe_name())

func _on_add_fixture_button_pressed():
	if get_node(fixture_universe_option).selected < 0: return
	Globals.universes.values()[get_node(fixture_universe_option).selected].new_fixture(current_fixture, options)


func _on_quantity_value_changed(value):
	options.quantity = value


func _on_offset_value_changed(value):
	options.offset = value


func _on_channel_value_changed(value):
	options.channel = value
