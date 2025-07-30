# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name ColumnIndex extends PanelContainer
## Headder item for table columns


## The text of this ColumnIndex
var text: String = "" : set = set_text, get = get_text


## The index of this column
var column_index: int = -1


## Setter for the text
func set_text(text: String) -> void: $HBoxContainer/Label.text = text

## Getter for the text
func get_text() -> String: return $HBoxContainer/Label.text
