extends PanelContainer

@export var close_settings: Button

func _on_close_settings_pressed() -> void:
	print(close_settings.get_signal_connection_list("pressed"))
