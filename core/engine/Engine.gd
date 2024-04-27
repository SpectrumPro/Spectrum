# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name CoreEngine extends Node
## The client side engine that powers Spectrum

signal universe_name_changed(universe: Universe, new_name: String) ## Emitted when any of the universes in this engine have there name changed
signal universes_added(universe: Array[Universe])
signal universes_removed(universes: Array[Universe])
signal universe_selection_changed(selected_universes: Array[Universe])

var universes: Dictionary = {}

func _ready() -> void:
	Client.add_networked_object("engine", self)


func new_universe() -> void:
	
	var request: Dictionary = {
		"for":"engine",
		"call":"add_universe",
		"args":[
			"New Universe " + str(len(universes) + 1)
		]
	}
	
	Client.send(request)


func on_universes_added(p_universes: Array, all_uuids: Array) -> void:
	
	for universe in p_universes:
		if universe is Universe:
			print(universe.name)
			universes[universe.uuid] = universe
	
	universes_added.emit(universes)


func remove_universes(universes_to_remove):
	Client.send({
		"for":"engine",
		"call":"remove_universes",
		"args":[universes_to_remove]
	})


func on_universes_removed(universes_to_remove: Array) -> void:
	var just_removed_universes: Array = []
	
	for universe: Universe in universes_to_remove:
		# Check if this universe is part of this engine
		if universe in universes.values():
			universes.erase(universe.uuid)
			universes_removed.emit([universe])
			
		else:
			print("Universe: ", universe.uuid, " is not part of this engine")
			
	universes_removed.emit(just_removed_universes)
