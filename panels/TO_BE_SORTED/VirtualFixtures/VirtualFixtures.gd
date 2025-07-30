# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name UIVirtualFixtures extends UIPanel
## Layout view for showing vixtures


## The fake scroll container, only used for the scroll bars
@onready var dummy_scroll: ScrollContainer = $DummyScroll

## The real scroll container that moves the content
@onready var real_scroll: ScrollContainer = $Table/RealScroll

## The virtual fixture container
@onready var fixture_container: VirtualFixtureContainer = $Table/RealScroll/ScrollSize/FixtureContainer

## Zoom step value for zoom buttons
const zoom_step: Vector2 = Vector2(0.05, 0.05)

## Min zoom size
const min_zoom: float = 0.2

## Max zoom size
const max_zoom: float = 5


func _ready() -> void:
	dummy_scroll.get_h_scroll_bar().value_changed.connect(real_scroll.set_h_scroll)
	dummy_scroll.get_v_scroll_bar().value_changed.connect(real_scroll.set_v_scroll)
	
	real_scroll.get_h_scroll_bar().value_changed.connect(dummy_scroll.get_h_scroll_bar().set_value_no_signal)
	real_scroll.get_v_scroll_bar().value_changed.connect(dummy_scroll.get_v_scroll_bar().set_value_no_signal)
	
	var canvas_size: Vector2 = $Table/RealScroll/ScrollSize.size
	real_scroll.scroll_horizontal = (canvas_size.x / 2) - size.x / 2
	real_scroll.scroll_vertical = (canvas_size.y / 2) - size.y / 2
	
	fixture_container.selected_virtual_fixtures_changed.connect(_on_selected_virtual_fixtures_changed)
	Values.connect_to_selection_value("selected_fixtures", _on_selected_fixtures_changed)
	
	set_edit_mode_disabled(true)


## Zooms in the canvas
func _zoom_in() -> void:
	fixture_container.scale += zoom_step
	#_update_scroll_containers()


## Zooms out the canvas
func _zoom_out() -> void:
	fixture_container.scale -= zoom_step
	#_update_scroll_containers()


## Sets edit mode state
func _edit_mode_toggled(p_edit_mode: bool) -> void:
	fixture_container.set_edit_mode(_edit_mode)
	$TitleBar/HBoxContainer/EditControls/HBoxContainer/Edit.button_pressed = _edit_mode
	$GridAlignSize.hide()
	
	$TitleBar/HBoxContainer/GridControls.visible = _edit_mode
	$TitleBar/HBoxContainer/VSeparator.visible = _edit_mode
	$TitleBar/HBoxContainer/PanelContainer.visible = _edit_mode
	$TitleBar/HBoxContainer/VSeparator2.visible = _edit_mode
	$TitleBar/HBoxContainer/AlignControls.visible = _edit_mode
	$TitleBar/HBoxContainer/VSeparator3.visible = _edit_mode


## Called when the selected virtual fixtures changes
func _on_selected_virtual_fixtures_changed(p_fixtures: Array) -> void:
	var disabled: bool = p_fixtures == []
	$TitleBar/HBoxContainer/PanelContainer/HBoxContainer/RemoveFixtures.disabled = disabled
	$TitleBar/HBoxContainer/AlignControls/HBoxContainer/HorizontalAlign.disabled = disabled
	$TitleBar/HBoxContainer/AlignControls/HBoxContainer/VerticalAlign.disabled = disabled
	$TitleBar/HBoxContainer/AlignControls/HBoxContainer/GridAlign.disabled = disabled
	
	if disabled:
		$GridAlignSize.hide()

## Called when the fixture selection changed
func _on_selected_fixtures_changed(fixtures: Array) -> void:
	$TitleBar/HBoxContainer/PanelContainer/HBoxContainer/Import.disabled = fixtures == []


## Called when when there is a GUI input on the fixture container
func _on_fixture_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
		real_scroll.scroll_horizontal -= event.relative.x
		dummy_scroll.scroll_horizontal = real_scroll.scroll_horizontal
		
		real_scroll.scroll_vertical -= event.relative.y
		dummy_scroll.scroll_vertical = real_scroll.scroll_vertical


## Updates the width and height of the scroll containers with the new canvas size and zoom level
func _update_scroll_containers() -> void:
	real_scroll.get_node("ScrollSize").custom_minimum_size = fixture_container.size * fixture_container.scale
	dummy_scroll.get_node("ScrollSize").custom_minimum_size = fixture_container.size * fixture_container.scale


func _on_grid_align_pressed() -> void:
	$GridAlignSize.show()



## Saves this VirtualFixture layout into a dict
func _save() -> Dictionary:
	if fixture_container.fixture_group:
		return {
			"fixture_group": fixture_container.fixture_group.uuid,
			"scroll_h": real_scroll.scroll_horizontal,
			"scroll_v": real_scroll.scroll_vertical,
			"zoom": fixture_container.scale.x
		}
	else:
		return {}


## Loads this VirtualFixture layout from a dict
func _load(saved_data) -> void:
	if saved_data.get("fixture_group") is String:
		ComponentDB.request_component(saved_data.fixture_group, func (fixture_group: EngineComponent):
			if fixture_group is FixtureGroup:
				fixture_container.set_fixture_group(fixture_group)
		)
	
	real_scroll.scroll_horizontal = type_convert(saved_data.get("scroll_h"), TYPE_INT)
	real_scroll.scroll_vertical = type_convert(saved_data.get("scroll_v"), TYPE_INT)
	
	fixture_container.scale = Vector2(
		type_convert(saved_data.get("zoom"), TYPE_FLOAT),
		type_convert(saved_data.get("zoom"), TYPE_FLOAT)
	)



func _on_table_gui_input(event: InputEvent) -> void:
	print(event)
