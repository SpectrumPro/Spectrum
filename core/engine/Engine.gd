# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name CoreEngine extends Node
## The client side engine that powers Spectrum

signal universe_name_changed(universe: Universe, new_name: String) ## Emitted when any of the universes in this engine have there name changed
signal universes_added(universe: Array[Universe])
signal universes_removed(universe_uuids: Array[String])
signal universe_selection_changed(selected_universes: Array[Universe])

var universes: Dictionary = {}


func _ready() -> void:
	Client.add_networked_object("engine", self)


func new_universe() -> void:
	
	var request: Dictionary = {
		"for":"engine",
		"call":"new_universe",
		"args":[
			"New Universe " + str(len(universes) + 1)
		]
	}
	
	Client.send(request)


func on_universes_added(p_universes: Array, all_uuids: Array) -> void:
	
	var new_universes: Array[Universe]
	new_universes.assign(p_universes)
	print(new_universes)
	
	for universe: Universe in new_universes:
		universes[universe.uuid] = universe
	
	universes_added.emit(universes)


func remove_universes(universes_to_remove):
	Client.send({
		"for":"engine",
		"call":"remove_universes",
		"args":[universes_to_remove]
	})

func on_universes_removed(universe_uuids: Array) -> void:
	print(universe_uuids)
