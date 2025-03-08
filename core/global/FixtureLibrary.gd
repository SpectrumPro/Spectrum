# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name CoreFixtureLibrary extends Node
## The main fixture library used to manage fixture manifests


## Emitted when the manifests are found
signal manifests_found()


## All the current found manifests, { "manufacturer": { "name": FixtureManifest } }
var _found_sorted_manifest_info: Dictionary = {}

## All the current found manifests, { "manifest_uuid": FixtureManifest }
var _found_manifest_info: Dictionary = {}

## All loaded fixture manifests, { "manifest_uuid": FixtureManifest }
var _loaded_manifests: Dictionary = {}

## All the current requests for manifests, used when fixtures are loaded before manifest importing
var _manifest_requests: Dictionary

## Loaded state
var _is_loaded: bool = false


## Load the fixture manifests from the folders, buit in manifests will override user manifests
func _ready() -> void:
	Client.connected_to_server.connect(func ():
		Client.send_command("FixtureLibrary", "get_sorted_manifest_info", []).then(func (p_sorted_fixture_manifests: Dictionary):
			_found_sorted_manifest_info = p_sorted_fixture_manifests
			_is_loaded = true
			manifests_found.emit()
		)
	)


## Returnes the sorted manifest info of all manifests found
func get_sorted_manifest_info() -> Dictionary:
	return _found_sorted_manifest_info.duplicate(true)


## Gets a manifest from a manifest uuid, return a promise 
func request_manifest(p_manifest_uuid: String) -> Promise:
	var promise: Promise = Promise.new()
	var manifest: FixtureManifest = _loaded_manifests.get(p_manifest_uuid)

	if manifest:
		promise.auto_resolve([_loaded_manifests[p_manifest_uuid]])
	else:
		if p_manifest_uuid not in _manifest_requests:
			Client.send_command("FixtureLibrary", "get_manifest", [p_manifest_uuid]).then(_on_get_manifest_received)
		
		_manifest_requests.get_or_add(p_manifest_uuid, []).append(promise)

	return promise


			
## Check loaded state
func is_loaded() -> bool: 
	return _is_loaded


## Creates a new fixture from a manifest
func create_fixture(manifest_uuid: String, universe: Universe, config: Dictionary) -> void:
	Client.send_command("FixtureLibrary", "create_fixture", [manifest_uuid, universe, config])


## Called when a manifest is received from the server
func _on_get_manifest_received(p_manifest: FixtureManifest) -> void:
	if p_manifest:
		_loaded_manifests[p_manifest.uuid] = p_manifest
		for promise: Promise in _manifest_requests.get(p_manifest.uuid, []):
			promise.resolve([p_manifest])
		
		_manifest_requests.erase(p_manifest.uuid)
