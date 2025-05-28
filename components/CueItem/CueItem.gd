# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name CueItem extends PanelContainer
## A item to represent a cue


## Emitted when this CueItem clicked
signal clicked()


## The status bar
@onready var _status_bar: ProgressBar = $VBoxContainer/ProgressBar


## The cue
var _cue: Cue = null

## The cue list
var _cue_list: CueList

## Is this cue enabled, and has its status bar visible
var _is_enabled: bool = false

## The current animating tween
var _current_tween: Tween = null

## All the lables
@onready var _labels: Dictionary = {
	"Name": $VBoxContainer/HBoxContainer/VBoxContainer2/Name,
	"CueNumber": $VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/PanelContainer2/HBoxContainer/CueNumber,
	"FadeTime": $VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/PanelContainer3/HBoxContainer/FadeTime,
	"PreWait": $VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/PanelContainer4/HBoxContainer/PreWait,
}


func _ready() -> void:
	Programmer.store_mode_changed.connect(_on_store_mode_changed)

## Sets the cue represented by this CueItem
func set_cue(cue: Cue, cue_list: CueList) -> void:
	if _cue_list: _cue_list.active_cue_changed.disconnect(_on_cue_number_changed)
	if _cue:
		_cue.name_changed.disconnect(set_cue_name)
		_cue.number_changed.disconnect(set_number)
		_cue.fade_time_changed.disconnect(set_fade_time)
		_cue.pre_wait_time_changed.disconnect(set_pre_wait)
		_cue.trigger_mode_changed.disconnect(set_trigger_mode)
	
	_cue = cue
	_cue_list = cue_list
	
	if _cue and _cue_list:
		_cue_list.active_cue_changed.connect(_on_cue_number_changed)
		
		_cue.name_changed.connect(set_cue_name)
		_cue.number_changed.connect(set_number)
		_cue.fade_time_changed.connect(set_fade_time)
		_cue.pre_wait_time_changed.connect(set_pre_wait)
		_cue.trigger_mode_changed.connect(set_trigger_mode)
		
		set_cue_name(_cue.name)
		set_number(_cue.number)
		set_fade_time(_cue.get_fade_time())
		set_pre_wait(_cue.get_pre_wait())
		set_trigger_mode(_cue.get_trigger_mode())


## Shows or hides the status bar
func set_status_bar(state: bool, time: float) -> void:
	if _current_tween: _current_tween.kill()
	var tween: Tween = get_tree().create_tween()
	
	tween.tween_method(_status_bar.set_value_no_signal, _status_bar.value, 1 if state else 0, time)
	_current_tween = tween
	
	if state:
		_is_enabled = true
	else:
		tween.finished.connect(func (): _is_enabled = false)


## Called when the CueList cue number changes
func _on_cue_number_changed(cue_number: float) -> void:
	if cue_number == _cue.number:
		set_status_bar(true, _cue.get_fade_time())
	
	elif _is_enabled: 
		var fade_time: float = 0
		if _cue_list.get_cue(cue_number):
			fade_time = _cue_list.get_cue(cue_number).get_fade_time()
		else:
			fade_time = _cue.get_fade_time()
		
		set_status_bar(false, fade_time)


## Functions for changing all the labels
func set_cue_name(p_name: String) -> void: _labels.Name.text = p_name
func set_number(number: float) -> void: _labels.CueNumber.text = str(number)
func set_fade_time(fade_time: float) -> void: _labels.FadeTime.text = str(fade_time)
func set_pre_wait(pre_wait: float) -> void: _labels.PreWait.text = str(pre_wait)


## Sets the trigger mode
func set_trigger_mode(trigger_mode: int) -> void:
	$VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/PanelContainer/VBoxContainer/Manual.hide()
	$VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/PanelContainer/VBoxContainer/AfterLast.hide()
	$VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/PanelContainer/VBoxContainer/WithLast.hide()
	
	match trigger_mode:
		Cue.TRIGGER_MODE.MANUAL: $VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/PanelContainer/VBoxContainer/Manual.show()
		Cue.TRIGGER_MODE.AFTER_LAST: $VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/PanelContainer/VBoxContainer/AfterLast.show()
		Cue.TRIGGER_MODE.WITH_LAST: $VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/PanelContainer/VBoxContainer/WithLast.show()


## Called when store mode is changed
func _on_store_mode_changed(store_mode: bool, class_hint: String) -> void:
	$StoreMode.visible = store_mode


## Called when an input event is decected in the panel
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		
		if event.double_click: 
			if _cue_list and _cue:
				_cue_list.seek_to(_cue)
			
		else:
			clicked.emit()
			
			if Programmer.get_store_mode():
				Programmer.resolve_store_mode(_cue)
