# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends Node3D
## WIP 3D Vis

# Called when the node enters the scene tree for the first time.
func _ready():
	for n in self.get_children():
		n.light_energy = 0.01
#		n.light_energy = 1
