extends PanelContainer

var _last_call_time: int = 0

func _on_color_picker_color_changed(color: Color) -> void:
	var current_time = Time.get_ticks_msec() / 1000.0  # Convert milliseconds to seconds
	
	if current_time - _last_call_time >= Core.call_interval:
		Core.programmer.set_color(Values.get_selection_value("selected_fixtures", []), color)
		
		_last_call_time = current_time
