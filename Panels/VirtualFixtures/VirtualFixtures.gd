# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends GraphEdit
## UI panel for displaying virtual fixtures

## Stores all virtual fixtures, sotred as uuid:virtual_fixture
var virtual_fixtures: Dictionary = {}

## The initial position of new virtual fixtures
var position_offset: Vector2 = Vector2(100, 100)

## The increment position of new virtual fixtures, added to position_offset for each new virtual fixture
var position_offset_increment: Vector2 = Vector2(100, 100)


## HORIZONTAL and VERTICAL size flags, used when calling align()
const ORIENTATION_HORIZONTAL: int = 1
const ORIENTATION_VERTICAL: int = 0


## The "Add Selected Fixtures" button, stored here so it can be dissabled when nothing is selected
var _add_fixture_button: Button

## The currently selected virtual fixtures, this is differnt from Values.selected_fixtures as there may be more than one virtual fixture linked to a single fixture, this array contains the list of selected virtual fixture nodes
var _selected_virtual_fixtures: Array

## Used to ensure that new colors are not send too quickley, as it is not needed and will only flood network trafic
var _last_call_time: float = 0.0

## Add extra buttons to GraphEdit menu, and subscribe to global variables
func _ready() -> void:
	_add_fixture_button = _add_menu_hbox_button("Add Selected Fixtures", self._add_virtual_fixtures, "Add the selected fixtures to the view", false)
	_add_menu_hbox_button("Delete", self._request_delete, "Delete the selected virtual fixtures, this does NOT delete the underlying fixture")
	_add_menu_hbox_button(ResourceLoader.load("res://Assets/Icons/Horizontal_distribute.svg"), self._align.bind(ORIENTATION_HORIZONTAL), "Align the selected fixtures horizontally" )
	_add_menu_hbox_button(ResourceLoader.load("res://Assets/Icons/Vertical_distribute.svg"), self._align.bind(ORIENTATION_VERTICAL), "Align the selected fixtures verticality" )
	
	#Values.connect_to_selection_value("selected_fixtures", self._active_fixtures_changed)
	Core.fixtures_added.connect(self.load_fixtures)
	
	load_fixtures(Core.fixtures.values())

## Function to add a button to the Graph Edits menu HBox, with callbacks, tool tips, and shortcuts
func _add_menu_hbox_button(content:Variant, method: Callable, tooltip: String = "", disabled: bool = false) -> Button:
	var button: Button = Button.new()
	
	if content is Texture2D:
		button.icon = content
	else:
		button.text = content as String
	
	button.pressed.connect(method)
	button.tooltip_text = tooltip
	button.disabled = disabled
	
	self.get_menu_hbox().add_child(button)
	return button


## Callback for the Add Selected Fixtures button
func _add_virtual_fixtures() -> void:
	for fixture: Fixture in Values.get_selection_value("selected_fixtures", []):
		add_virtual_fixture(fixture)


## Add the fixtures defined in p_fixtures, as virtual fixtures
func add_virtual_fixture(fixture: Fixture, uuid: String = UUID_Util.v4(), position_offset: Vector2 = Vector2(), no_meta: bool = false, select: bool = true) -> void:
	var new_virtual_fixture: Control = Interface.components.VirtualFixture.instantiate()
	
	new_virtual_fixture.name = uuid # Give the virtual fixture a uuid so it can be stored later, and found
	new_virtual_fixture.set_fixture(fixture)
	new_virtual_fixture.selected = select
	
	
	if position_offset:
		new_virtual_fixture.position_offset = position_offset
	else:
		new_virtual_fixture.position_offset += position_offset
		position_offset += position_offset_increment
	
	if not no_meta:
		var virtual_fixture_list: Dictionary = fixture.get_user_meta("virtual_fixtures", {})
		virtual_fixture_list[uuid] = [new_virtual_fixture.position_offset.x, new_virtual_fixture.position_offset.y]
		fixture.set_user_meta("virtual_fixtures", virtual_fixture_list)
	
	_selected_virtual_fixtures.append(new_virtual_fixture)
	virtual_fixtures[uuid] = new_virtual_fixture
	self.add_child(new_virtual_fixture)


## Deletes virtual fixtures from the current view
func _request_delete() -> void:
	var to_remove: Array = _selected_virtual_fixtures.duplicate() ## Duplicate the array, to avoid issues when itterating over it while deleting
	
	for virtual_fixture: Control in to_remove:
		var virtual_fixture_list: Dictionary = virtual_fixture.fixture.get_user_meta("virtual_fixtures", {})
		virtual_fixture_list.erase(str(virtual_fixture.name))
		virtual_fixture.fixture.set_user_meta("virtual_fixtures", virtual_fixture_list)
		
		virtual_fixture.queue_free()
		_selected_virtual_fixtures.erase(virtual_fixture)
		virtual_fixtures.erase(str(virtual_fixture.name))


### Function to update highlighting on virtual fixtures, when their corresponding fixture is selected
#func _active_fixtures_changed(p_fixtures: Array) -> void:
	#_add_fixture_button.disabled = true if p_fixtures == [] else false
	#
	#for virtual_fixture: Control in get_children():
		#virtual_fixture.set_highlighted(false)
		##virtual_fixture.selected = false
	#
	#for fixture: Fixture in p_fixtures:
		#for uuid in fixture.get_user_meta("virtual_fixtures", {}).keys():
			#virtual_fixtures[uuid].set_highlighted(true)
			##virtual_fixtures[uuid].selected = true


## Called when a fixture is added to this engine, will check if it has any virtual fixtures, if so they will be added
func load_fixtures(p_fixtures: Array) -> void:
	for fixture: Fixture in p_fixtures:
		for uuid: String in fixture.get_user_meta("virtual_fixtures", {}).keys():
			if not uuid in virtual_fixtures.keys():
				var pos_array: Array = fixture.get_user_meta("virtual_fixtures", {})[uuid]
				add_virtual_fixture(fixture, uuid, Vector2(pos_array[0], pos_array[1]), true, false)


## Function to align the currently selected fixtures horizontally
func _align(orientation: int) -> void:
	
	if not _selected_virtual_fixtures:
		return
		
	var base_position: Vector2 = _selected_virtual_fixtures[0].position_offset
	
	for virtual_fixture: Control in _selected_virtual_fixtures:
		virtual_fixture.position_offset = base_position
		
		virtual_fixture.fixture.user_meta.virtual_fixtures[str(virtual_fixture.name)] = base_position
		virtual_fixture.fixture.set_user_meta("virtual_fixtures", virtual_fixture.fixture.user_meta.virtual_fixtures)
		#virtual_fixture.fixture.user_meta.virtual_fixtures[virtual_fixture.virtual_fixture_index] = base_position
		
		if orientation:
			base_position.x += 100
		else:
			base_position.y += 100


## Called when a virtual_fixture node is selected
func _on_virtual_fixture_selected(node) -> void:
	if node not in _selected_virtual_fixtures:
		_selected_virtual_fixtures.append(node)
	
	Values.add_to_selection_value("selected_fixtures", [node.fixture])


## Called when a virtual_fixture node is deselected
func _on_virtual_fixture_deselected(node) -> void:
	_selected_virtual_fixtures.erase(node)
	
	Values.remove_from_selection_value("selected_fixtures", [node.fixture])


func _on_save_pressed() -> void:
	Core.programmer.save_to_scene()
