# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

extends Control
## WIP animation system

var track_id: int

func add_track_item():
	$Container.add_child(Interface.components.SceneTrackItem.instantiate())
