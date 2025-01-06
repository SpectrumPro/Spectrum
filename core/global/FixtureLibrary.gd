# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name CoreFixtureLibrary extends Node
## The main fixture library used to manage fixture manifests


## Emitted when the manifests are loaded
signal manifests_loaded()


## All the current fixture manifests
var fixture_manifests: Dictionary = {}


## Loaded state
var _is_loaded: bool = false


## Load the fixture definitions from the folders, buit in manifests will override user manifests
func _ready() -> void:
	Client.connected_to_server.connect(func ():
		Client.send_command("FixtureLibrary", "get_loaded_fixture_manifests", []).then(func (p_fixture_manifests):
			fixture_manifests = p_fixture_manifests
			manifests_loaded.emit()
			_is_loaded = true
		)
	)


## Returnes all currently loaded fixture manifests
func get_loaded_fixture_manifests() -> Dictionary:
	return fixture_manifests.duplicate(true)


## Check loaded state
func is_loaded() -> bool: return _is_loaded
