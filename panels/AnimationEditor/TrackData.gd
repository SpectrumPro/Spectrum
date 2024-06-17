# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends Control
## WIP animation system

var track_id: int

func add_track_item():
	$Container.add_child(Interface.components.SceneTrackItem.instantiate())
