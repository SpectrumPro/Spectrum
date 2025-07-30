# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name TriggerButton extends Button
## Ui button to trigger an action on click


## Emitted when the name is changed
signal name_changed(new_name: String)

## Emitted when the background color is changed
signal bg_color_changed(bg_color: Color)

## Emitted when the border color is changed
signal border_color_changed(border_color: Color)

## Emitted when the border width is changed
signal border_width_changed(border_width: int)

## Emitted whem an InputEvent shortcut is added
signal shortcut_added(event: InputEvent)


## Button Mode
enum Mode {Normal, Toggle}
var button_mode: Mode = Mode.Normal : set = set_button_mode


## Stored here so the indicator can be resized
var _percentage: float = 0

## The style box used for themeing this button
var _style_box: StyleBoxFlat = null

## If this is a dummy button
var _is_dummy: bool = false


## Config for the button up action
var _button_up_trigger: MethodTrigger = MethodTrigger.new()

## Config for the button down action1
var _button_down_trigger: MethodTrigger = MethodTrigger.new()


func _ready() -> void:
	_style_box = $Style.get_theme_stylebox("panel").duplicate()
	$Style.add_theme_stylebox_override("panel", _style_box)
	
	shortcut = Shortcut.new()


## Sets the text of this button, 
## use this instead of buttons built in set_text method, as this label supports text wrapping
func set_label_text(label_text: String) -> void:
	$Label.text = label_text
	name_changed.emit(label_text)


## Gets the label text
func get_label_text() -> String:
	return $Label.text


## Sets and gets the background color
func set_bg_color(bg_color: Color) -> void: 
	_style_box.bg_color = bg_color
	bg_color_changed.emit(bg_color)

func get_bg_color() -> Color: return _style_box.bg_color


## Sets and gets the border color
func set_border_color(border_color: Color) -> void: 
	_style_box.border_color = border_color
	border_color_changed.emit(border_color)

func get_border_color() -> Color: return _style_box.border_color


## Sets and gets the border width
func set_border_width(border_width: int) -> void:
	_style_box.border_width_left = border_width
	_style_box.border_width_right = border_width
	_style_box.border_width_top = border_width
	_style_box.border_width_bottom = border_width
	border_width_changed.emit(border_width)

func get_border_width() -> int: return _style_box.border_width_bottom


## Sets the button mode
func set_button_mode(p_button_mode: Mode) -> void:
	button_mode = p_button_mode
	toggle_mode = p_button_mode == Mode.Toggle
	
	if toggle_mode:
		if button_up.is_connected(_on_button_up): button_up.disconnect(_on_button_up)
		if button_down.is_connected(_on_button_down): button_down.disconnect(_on_button_down)
		if not toggled.is_connected(_on_button_toggled): toggled.connect(_on_button_toggled)
		
	
	else:
		if not button_up.is_connected(_on_button_up): button_up.connect(_on_button_up)
		if not button_down.is_connected(_on_button_down): button_down.connect(_on_button_down)
		if toggled.is_connected(_on_button_toggled): toggled.disconnect(_on_button_toggled)


## Sets the action for button up
func set_button_up(method_trigger: MethodTrigger) -> void: 
	_button_up_trigger.deseralize(method_trigger.seralize())

## Removes the button up binding
func remove_button_up() -> void: _button_up_trigger = MethodTrigger.new()

## Returns the button up config
func get_button_up() -> MethodTrigger: return _button_up_trigger


## Sets the action for button down
func set_button_down(method_trigger: MethodTrigger) -> void: 
	_button_down_trigger.deseralize(method_trigger.seralize())

## Removes the button down binding
func remove_button_down() -> void: _button_down_trigger = MethodTrigger.new()

## Returns the button down config
func get_button_down() -> MethodTrigger: return _button_down_trigger


## Sets the indicator value of this button
func set_value(percentage: float) -> void:
	_percentage = percentage
	$Value.set_deferred("size", Vector2(remap(percentage, 0, 1, 0, size.x), size.y))


## Makes this trigger button a dummy of another, will auto copy over visual elements, but not triggers
func make_dummy_of(master_trigger: TriggerButton) -> void:
	set_label_text(master_trigger.get_label_text())
	set_bg_color(master_trigger.get_bg_color())
	set_border_color(master_trigger.get_border_color())
	set_border_width(master_trigger.get_border_width())
	
	master_trigger.name_changed.connect(set_label_text)
	master_trigger.bg_color_changed.connect(set_bg_color)
	master_trigger.border_color_changed.connect(set_border_color)
	master_trigger.border_width_changed.connect(set_border_width)
	master_trigger.shortcut_added.connect(add_shortcut)


## Adds an input event as a shortcut
func add_shortcut(event: InputEvent) -> void:
	shortcut.events = [event]
	shortcut_added.emit(event)


## Used to update the position of the value background when we are resized
func _on_resized() -> void: set_value(_percentage)


## Called when this button is pushed down
func _on_button_down() -> void:
	if is_instance_valid(_button_down_trigger):
		_button_down_trigger.call_method()


## Called when this button is let go
func _on_button_up() -> void:
	if is_instance_valid(_button_up_trigger):
		_button_up_trigger.call_method()


## Called when the button is pressed
func _on_pressed() -> void:
	_on_button_down()
	await get_tree().create_timer(0.01).timeout
	_on_button_up()


## Called when this button is toggled in toggle mode, will call the corresponding _on_button_* method
func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_on_button_down()
	else:
		_on_button_up()


## Saves the config of this TriggerButton into a dict
func serialize() -> Dictionary:
	return {
		"button_mode": button_mode,
		"button_down": _button_down_trigger.seralize() if _button_down_trigger else {},
		"button_up": _button_up_trigger.seralize() if _button_up_trigger else {},
		"label": $Label.text,
		"bg_color": var_to_str(get_bg_color()),
		"border_color": var_to_str(get_border_color()),
		"border_width": get_border_width(),
		"visible": visible,
		"shortcut": var_to_str(shortcut)
	}


## Loads the saved state
func deserialize(serialized_data: Dictionary) -> void:
	set_button_mode(serialized_data.get("button_mode", Mode.Normal))
	
	if serialized_data.get("button_down", null) is Dictionary: 
		var config: Dictionary = serialized_data.button_down
		_button_down_trigger = MethodTrigger.new().deseralize(config)
	
	if serialized_data.get("button_up", null) is Dictionary: 
		var config: Dictionary = serialized_data.button_up
		_button_up_trigger = MethodTrigger.new().deseralize(config)

	
	var bg = str_to_var(serialized_data.get("bg_color", ""))
	if bg is Color: set_bg_color(bg)
	
	var border = str_to_var(serialized_data.get("border_color", ""))
	if border is Color: set_border_color(border)
	
	set_border_width(serialized_data.get("border_width", get_border_width()))
	
	set_label_text(serialized_data.get("label", ""))
	visible = serialized_data.get("visible", true)
	
	shortcut = str_to_var(serialized_data.get("shortcut", ""))
