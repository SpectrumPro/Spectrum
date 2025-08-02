# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name UIUniverses extends UIPanel
## GUI element for managing universes


## The ItemList for showing all universe outputs
@export var _output_list: ItemList = null

## The FixtureTree tree
@export var _fixture_tree: Tree = null

## The RemoveOutput button
@export var _remove_output: Button = null

## The RemoveFixture button
@export var _remove_fixture: Button = null

## The ComponentSettings for DMXOutputs
@export var _output_settings: ComponentSettings = null

## The ComponentSettings for Fixtures 
@export var _fixture_settings: ComponentSettings = null

## The ComponentSettings for self
@export var _self_settings: ComponentSettings = null

## The ObjectPickerButton for this UIUniverses panel
@export var _object_picker_button: ObjectPickerButton = null


## The current selected universe
var _universe: Universe = null

## All signals that need to be connected / disconnected from the universe
var _universe_signal_connections: Dictionary = {
	"outputs_added": _add_outputs,
	"outputs_removed": _remove_outputs,
	"fixtures_added": _add_fixtures,
	"fixtures_removed": _remove_fixtures
}

var _output_signal_connections: Dictionary = {
	"name_changed": _on_output_name_changed
}

var _fixture_signal_connections: Dictionary = {
	"name_changed": _on_fixture_name_changed,
	"channel_changed": _on_fixture_channel_changed
}

## RefMap for DMXOutput:ItemList_idx
var _output_map: RefMap = RefMap.new()

## RefMap for Fixture:ItemList_idx
var _fixture_map: RefMap = RefMap.new()

## All the fixture channels
var _fixture_channels: Dictionary

## Old fixture channels
var _old_fixture_channels: Dictionary


## Init
func _init() -> void:
	super._init()
	_set_class_name("UIUniverses")


## Ready
func _ready() -> void:
	_fixture_tree.set_column_title(0, "Fixture")
	_fixture_tree.set_column_title(1, "Channel")
	_fixture_tree.set_column_expand(1, false)


## Sets the current universe
func set_universe(universe: Universe) -> void:
	_output_map.clear()
	_fixture_map.clear()
	_output_list.clear()
	_fixture_tree.clear()
	_fixture_tree.create_item() 
	_fixture_channels.clear()
	
	_output_settings.set_component(null)
	_fixture_settings.set_component(null)
	_self_settings.set_component(universe)
	
	Utils.disconnect_signals(_universe_signal_connections, _universe)
	_universe = universe
	Utils.connect_signals(_universe_signal_connections, _universe)
	
	_add_outputs(_universe.get_outputs().values())
	_add_fixtures(_universe.get_fixtures().values())


## Called when fixtures are added to the universe
func _add_fixtures(fixtures: Array) -> void:
	for fixture: DMXFixture in fixtures:
		var item: TreeItem = _fixture_tree.create_item(null, fixture.get_channel())
		_fixture_map.map(fixture, item)
		item.set_text(0, fixture.name)
		item.set_text(1, str(fixture.get_channel()))
		
		_fixture_channels.get_or_add(fixture.get_channel(), []).append(fixture)
		_old_fixture_channels[fixture] = fixture.get_channel()
		Utils.connect_signals_with_bind(_fixture_signal_connections, fixture)
		
	_sort_fixtures()


## Called when fixtures are removed from the universe
func _remove_fixtures(fixtures: Array) -> void:
	for fixture: DMXFixture in fixtures:
		_fixture_map.left(fixture).free()
		_fixture_map.erase_left(fixture)
		Utils.disconnect_signals_with_bind(_fixture_signal_connections, fixture)
		
		_fixture_channels[fixture.get_channel()].erase(fixture)
		
		if not _fixture_channels[fixture.get_channel()]:
			_fixture_channels.erase(fixture.get_channel())
		
		if fixture == _fixture_settings.get_component():
			_fixture_settings.set_component(null)


## Called when outputs are added to the universe
func _add_outputs(outputs: Array) -> void:
	for output: DMXOutput in outputs:
		_output_map.map(output, _output_list.add_item(output.name, Interface.get_class_icon(output.self_class_name)))
		Utils.connect_signals_with_bind(_output_signal_connections, output)


## Called when outputs are removed from the universe
func _remove_outputs(outputs: Array) -> void:
	for output: DMXOutput in outputs:
		_output_list.remove_item(_output_map.left(output))
		_output_map.erase_left(output)
		Utils.disconnect_signals_with_bind(_output_signal_connections, output)
		
		if output == _output_settings.get_component():
			_output_settings.set_component(null)


## Called when an output is renamed
func _on_output_name_changed(new_name: String, output: DMXOutput) -> void:
	_output_list.set_item_text(_output_map.left(output), new_name)


## Called when a fixture is renamed
func _on_fixture_name_changed(new_name: String, fixture: DMXFixture) -> void:
	(_fixture_map.left(fixture) as TreeItem).set_text(0, new_name)


## Called when a fixture channel is changed
func _on_fixture_channel_changed(channel: int, fixture: DMXFixture) -> void:
	_fixture_channels[_old_fixture_channels[fixture]].erase(fixture)
	
	if not _fixture_channels[_old_fixture_channels[fixture]]:
		_fixture_channels.erase(_old_fixture_channels[fixture])
	
	_fixture_channels.get_or_add(channel, []).append(fixture)
	_old_fixture_channels[fixture] = channel
	
	(_fixture_map.left(fixture) as TreeItem).set_text(1, str(channel))
	_sort_fixtures()


## Sorts all fixtures by channel
func _sort_fixtures() -> void:
	var previous: TreeItem = _fixture_tree.get_root().get_child(0)
	var channels: Array = _fixture_channels.keys()
	channels.sort()
	channels.reverse()
	
	for channel: int in channels:
		for fixture: DMXFixture in _fixture_channels[channel]:
			(_fixture_map.left(fixture) as TreeItem).move_before(previous)
			previous = _fixture_map.left(fixture)


## Called when the NewOutput button is pressed
func _on_new_output_pressed() -> void:
	Interface.show_create_component(CreateComponent.Mode.Class, "DMXOutput").then(func (classname: String):
		_universe.create_output(classname)
	)


## Called when the NewFixture button is pressed
func _on_new_fixture_pressed() -> void:
	(Interface.create_panel_popup("AddFixture", self) as UIAddFixture).universe_options.set_object(_universe)


## Called when the RemoveOutput button is pressed
func _on_remove_output_pressed() -> void:
	Interface.show_delete_confirmation("", self).then(func ():
		for idx: int in _output_list.get_selected_items():
			_output_map.right(idx).delete()
	)


## Called when the RemoveFixture button is pressed
func _on_remove_fixture_pressed() -> void:
	Interface.show_delete_confirmation("", self).then(func ():
		_fixture_map.right(_fixture_tree.get_selected()).delete()
	)


## Called when an item is selected in the OutputList
func _on_outputs_list_multi_selected(index: int, selected: bool) -> void:
	_remove_output.disabled = not _output_list.is_anything_selected()
	
	if len(_output_list.get_selected_items()) == 1:
		_output_settings.set_component(_output_map.right(index))
	else:
		_output_settings.set_component(null)


## Called when an item is selected in the FixtureTree
func _on_fixture_tree_item_selected() -> void:
	_remove_fixture.disabled = false
	_fixture_settings.set_component(_fixture_map.right(_fixture_tree.get_selected()))


## Called when nothing is clicked in the OutputList
func _on_outputs_list_empty_clicked(at_position: Vector2, mouse_button_index: int) -> void:
	_remove_output.disabled = true
	_output_list.deselect_all()
	_output_settings.set_component(null)


## Called when nothing is selected in the FixtureTree
func _on_fixture_tree_nothing_selected() -> void:
	_remove_fixture.disabled = true
	_fixture_tree.deselect_all()
	_fixture_settings.set_component(null)


## Saves this UIUniverses panel to a dictonary
func _save() -> Dictionary: 
	if _universe:
		return {
			"uuid": _universe.uuid
		}
		
	else:
		return {}


## Loads this UIUniverses from a dictonary
func _load(saved_data: Dictionary) -> void: 
	if saved_data.get("uuid") is String:
		_object_picker_button.look_for(saved_data.uuid)
