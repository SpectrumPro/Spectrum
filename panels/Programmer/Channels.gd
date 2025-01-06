# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

extends VBoxContainer
## Channel overrides for universes

#signal clear_all_presses
#
#var _current_universe: Universe = null
#
#var _show_channels: bool = false
#
#@onready var universe_container: ScrollContainer = $UniverseContainer/ScrollContainer
#
#func _ready() -> void:
	#Core.universes_added.connect(_reload_universes)
	#
	#Core.universes_removed.connect(func (universe: Universe): 
		#if universe == _current_universe: 
			#$UniverseContainer.get_node(_current_universe.uuid).queue_free()
			#
			#if Core.universes:
				#_reload_sliders(Core.universes[-1])
			#else:
				#_current_universe = null
		#
		#_reload_universes()
	#)
	#
	#Core.universe_name_changed.connect(_reload_universes)
	#
	#_reload_universes()
#
#
#func _reload_sliders(new_universe: Universe) -> void:
	#if not _show_channels:
		#return
	#
	#if _current_universe:
		#universe_container.get_node(_current_universe.uuid).hide()
		#
	#
	#if universe_container.has_node(new_universe.uuid):
		#universe_container.get_node(new_universe.uuid).show()
		#
	#else:
		#var container: HBoxContainer = HBoxContainer.new()
		#container.set_v_size_flags(SIZE_EXPAND_FILL)
		#container.name = new_universe.uuid
	#
		#for channel: int in range(1, 513):
			#var channel_slider: ChannelSlider = Interface.components.ChannelSlider.instantiate()
			#
			#channel_slider.set_label_text(str(channel))
			#channel_slider.args_befour = [channel]
			#channel_slider.object_id = new_universe.uuid
			#channel_slider.show_randomise_button = false
			#
			#channel_slider.method = "set_dmx_override"
			#channel_slider.reset_method = "remove_dmx_override"
			#
			#clear_all_presses.connect(channel_slider.reset_no_message)
			#
			#container.add_child(channel_slider)
		#
		#universe_container.add_child(container)
		#
	#_current_universe = new_universe
	#pass
#
#
#
#func _reload_universes(arg1 = null, arg2 = null) -> void:
	#$PanelContainer2/HBoxContainer2/OptionButton.clear()
	#
	#for universe: Universe in Core.universes.values():
		#$PanelContainer2/HBoxContainer2/OptionButton.add_item(universe.name)
	#
	#if not _current_universe and Core.universes:
		#_reload_sliders(Core.universes.values()[$PanelContainer2/HBoxContainer2/OptionButton.selected])
#
#func _on_option_button_item_selected(index: int) -> void:
	#_reload_sliders(Core.universes.values()[index])
#
#
#func _on_clear_all_pressed() -> void:
	#clear_all_presses.emit()
	#Client.send({
		#"for": _current_universe.uuid,
		#"call": "remove_all_dmx_overrides",
	#})
#
#
#func _on_left_pressed() -> void:
	#var scroll_container: ScrollContainer = $UniverseContainer/ScrollContainer
	#scroll_container.scroll_horizontal = scroll_container.scroll_horizontal - 500
#
#
#
#func _on_right_pressed() -> void:
	#var scroll_container: ScrollContainer = $UniverseContainer/ScrollContainer
	#scroll_container.scroll_horizontal = scroll_container.scroll_horizontal + 500
#
#
#func _on_enable_pressed() -> void:
	#_show_channels = true
