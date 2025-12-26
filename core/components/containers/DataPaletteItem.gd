# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name DataPaletteItem extends DataContainer
## Data container for DataPalette items


## Position of this palette item
var position: Vector2i = Vector2i.ZERO


## Serializes this scene and returnes it in a dictionary
func serialize() -> Dictionary:
	return super.serialize().merged({
		"position": var_to_str(position)
	})


## Called when this scene is to be loaded from serialized data
func deserialize(p_serialized_data: Dictionary) -> void:
	super.deserialize(p_serialized_data)
	
	position = type_convert(str_to_var(p_serialized_data.get("position")), TYPE_VECTOR2)
