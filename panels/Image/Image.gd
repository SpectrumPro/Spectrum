# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name UIImage extends UIPanel
## UI panel to display an image


func set_show_settings(state: bool) -> void:
	$FileDialog.visible = state


func _on_file_dialog_confirmed() -> void:
	print($FileDialog.current_path)
	var imported: Resource = ResourceLoader.load($FileDialog.current_path)
	$TextureRect.texture = ImageTexture.create_from_image(Image.load_from_file($FileDialog.current_path))
