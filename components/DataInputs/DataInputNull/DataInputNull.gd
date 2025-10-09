# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name DataInputNull extends DataInput
## DataInput for Data.Type.NULL


## Ready
func _ready() -> void:
	_data_type = Data.Type.NULL
	_label = $HBox/Label
	_outline = $Outline


## Sets the label to show the unsupported DataType
func set_unsupported_type(p_data_type: Data.Type) -> void:
	set_show_label(true)
	set_label_text(str("Unsupported DataType: ", Data.Type.keys()[p_data_type]))
	_label.modulate = Color(1, 1, 1, 0.5)
