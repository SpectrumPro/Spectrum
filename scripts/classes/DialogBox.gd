# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name DialogBox extends Control
## Base class for all dialog boxes


## Emitted when this is confirmed
signal confirmed(value: Variant)

## Emitted when this is rejected
signal rejected()


## The label
@export var _label: Label = null


## Changes the title
func set_title(title: String) -> void:
	_label.text = title
