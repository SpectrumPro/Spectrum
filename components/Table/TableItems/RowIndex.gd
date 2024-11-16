# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name RowIndex extends PanelContainer
## Headder item for table rows


## The text of this RowIndex
var text: String = "" : set = set_text, get = get_text

## The index of this row
var row_index: int = -1

## The row item
var row_item: RowItem = null


## Setter for the text
func set_text(text: String) -> void: $HBoxContainer/Label.text = text

## Getter for the text
func get_text() -> String: return $HBoxContainer/Label.text
