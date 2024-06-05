extends Control

var track_id: int

func add_track_item():
	$Container.add_child(Interface.components.SceneTrackItem.instantiate())
