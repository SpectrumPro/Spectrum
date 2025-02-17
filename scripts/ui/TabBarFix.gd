class_name TabBarFix extends TabBar
## Temp class to fix an issue with TabBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	custom_minimum_size = size + Vector2(1000,1000)
	await get_tree().process_frame
	custom_minimum_size = Vector2.ZERO
