# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name DataPalette extends Function
## A Palette of fixture preset data



### Emitted when palette items are added
#signal on_palettes_added(palettes: Array[DataPaletteItem])
#
### Emitted when paletts are removed
#signal on_palettes_removed(palettes: Array[DataPaletteItem])
#
### Emitted when the position of any palette is changed. The new position of the palette item can be access by using the DataPaletteItem.position value
#signal on_palette_positions_changed(new_positions: Array[DataPaletteItem])
#
### Emitted when the operation changes
#signal on_operation_mode_changed(mode: OperationMode)
#
#
#
### Operation modes for this palette. 
###  Programmer: Set fixture data using the programmer, allowing this palette to be used as a preset pool
###  Standalone: Set fixture data directley from this function, allowing this palette to be used during live opration
#enum OperationMode {Programmer, Standalone}
#
### The current operation mode of this palette
#var _mode: OperationMode = OperationMode.Programmer
#
### The Matrix2D used to store palettes in two-dimensional space
#var _position_matrix: Matrix2D = Matrix2D.new()
#
### The current active palette item
#var _current_palette: DataPaletteItem = null
#
#
### Creates a new palette item with the givven name and position, returns false if the position is taken
#func create_palette(p_name: String, p_position: Vector2i) -> void: rpc("create_palette", [p_name, p_position])
#
#
### Adds a pre-existing palette item to this palette, returning false if the position is taken
#func add_palette(p_palette: DataPaletteItem, no_signal: bool = false) -> void: rpc("add_palette")
#
### Adds a pre-existing palette item to this palette, returning false if the position is taken
#func _add_palette(p_palette: DataPaletteItem, no_signal: bool = false) -> bool:
	#if _position_matrix.get_xy(p_palette.position):
		#return false
#
	#_position_matrix.set_xy(p_palette, p_palette.position)
#
	#if not no_signal:
		#on_palettes_added.emit([p_palette])
#
	#return true
#
#
### Adds mutiple palettes at once
#func add_palettes(p_palettes: Array) -> void:
	#var just_added_palettes: Array[DataPaletteItem]
#
	#for palette: Variant in p_palettes:
		#if palette is DataPaletteItem:
			#if _add_palette(palette, true):
				#just_added_palettes.append(palette)
	#
	#if just_added_palettes:
		#on_palettes_added.emit(just_added_palettes)
#
#
### Moves a palette item to the givven position, returning false if the position is taken
#func move_palette(p_palette: DataPaletteItem, p_position: Vector2i) -> bool:
	#if _position_matrix.get_xy(p_position):
		#return false
#
	#_position_matrix.erase_xy(p_palette.position)
	#_position_matrix.set_xy(p_palette, p_position)
#
	#p_palette.position = p_position
	#on_palette_positions_changed.emit([p_palette])
#
	#return true
#
#
### Removes a palette item from this palette, returning false if the palette item is not in this palette
#func remove_palette(p_palette: DataPaletteItem, no_signal: bool = false) -> bool:
	#if _position_matrix.get_xy(p_palette.position):
		#return false
#
	#_position_matrix.erase_xy(p_palette.position) == null
#
	#if not no_signal:
		#on_palettes_removed.emit([p_palette])
	#
	#return true
#
#
### Removes mutiple palettes at once
#func remove_palettes(p_palettes: Array) -> void:
	#var just_removed_palettes: Array[DataPaletteItem]
#
	#for palette: Variant in p_palettes:
		#if palette is DataPaletteItem:
			#if remove_palette(palette, true):
				#just_removed_palettes.append(palette)
	#
	#if just_removed_palettes:
		#on_palettes_removed.emit(just_removed_palettes)
#
#
### Gets the current mode
#func get_mode() -> OperationMode: 
	#return _mode
#
#
### Sets the operation mode of this palette
#func set_mode(p_mode: OperationMode) -> void:
	#if p_mode == _mode:
		#return
	#
	#_mode = p_mode
	#on_operation_mode_changed.emit(_mode)
#
#
### Saves this DataPalette into a dictionary
#func _on_serialize_request() -> Dictionary:
	#var serialized_palettes: Array = []
#
	#for palette: DataPaletteItem in _position_matrix.all().values():
		#serialized_palettes.append(palette.serialize())
#
	#return {
		#"mode": _mode,
		#"palettes": serialized_palettes
	#}
#
#
### Loads this DataPalette from a dictionary
#func _on_load_request(serialized_data) -> void:
	#_mode = serialized_data.get("mode", OperationMode.Programmer)
#
	#var just_added_palettes: Array[DataPaletteItem] = []
#
	#for serialize_palette: Dictionary in serialized_data.get("palettes", {}):
		#var new_palette: DataPaletteItem = DataPaletteItem.new()
		#new_palette.load(serialize_palette)
#
		#if _add_palette(new_palette, true):
			#just_added_palettes.append(new_palette)
	#
	#if just_added_palettes:
		#on_palettes_added.emit(just_added_palettes)
