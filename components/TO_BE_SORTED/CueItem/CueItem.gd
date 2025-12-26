# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name CueItem extends PanelContainer
## A item to represent a cue


## Emitted when this CueItem clicked
signal clicked()


## The status bar
@export var _status_bar: ProgressBar

## The Label node for the cue's name
@export var _name_label: Label

## The Label node for the cue's QID
@export var _qid_label: Label

## The Label node for the cue's fade time
@export var _fade_time_label: Label

## The Label node for the cue's pre wait time
@export var _pre_wait_label: Label

## Icon for Cue.TriggerMode.MANUAL
@export var _trigger_mode_manual: TextureRect

## Icon for Cue.TriggerMode.AFTER_LAST
@export var _trigger_mode_after_last: TextureRect

## Icon for Cue.TriggerMode.WITH_LAST
@export var _trigger_mode_with_last: TextureRect


## The cue
var _cue: Cue = null

## The cue list
var _cue_list: CueList

## Is this cue enabled, and has its status bar visible
var _is_enabled: bool = false

## The current animating tween
var _current_tween: Tween = null

## Signals to connect to the Cue
var _cue_signals: Dictionary[String, Callable] = {
	"name_changed": set_cue_name,
	"qid_changed": set_qid,
	"fade_time_changed": set_fade_time,
	"pre_wait_time_changed": set_pre_wait,
	"trigger_mode_changed": set_trigger_mode
}

## Signals to connect to the CueList
var _cue_list_signals: Dictionary[String, Callable] = {
	"active_cue_changed": _on_active_cue_changed,
	"transport_state_changed": _on_transport_state_changed,
	"active_state_changed": _on_active_state_changed
}


## Connect store mode 
func _ready() -> void:
	Programmer.store_mode_changed.connect(_on_store_mode_changed)


## Sets the cue represented by this CueItem
func set_cue(cue: Cue, cue_list: CueList) -> void:
	Utils.disconnect_signals(_cue_signals, _cue)
	Utils.disconnect_signals(_cue_list_signals, _cue_list)
	
	_cue = cue
	_cue_list = cue_list
	
	Utils.connect_signals(_cue_signals, _cue)
	Utils.connect_signals(_cue_list_signals, _cue_list)
	
	if _cue and _cue_list:
		set_cue_name(_cue.get_name())
		set_qid(_cue.get_qid())
		set_fade_time(_cue.get_fade_time())
		set_pre_wait(_cue.get_pre_wait())
		set_trigger_mode(_cue.get_trigger_mode())


## Shows or hides the status bar
func set_status_bar(state: bool, time: float) -> void:
	if _current_tween: 
		_current_tween.kill()
	
	if not is_inside_tree():
		return
	
	var tween: Tween = get_tree().create_tween()
	
	tween.tween_method(_status_bar.set_value_no_signal, _status_bar.value, 1 if state else 0, time)
	_current_tween = tween
	
	if state:
		_is_enabled = true
	else:
		tween.finished.connect(func (): _is_enabled = false)


## Functions for changing all the labels
func set_cue_name(p_name: String) -> void: 
	_name_label.text = p_name


## Sets the QID label
func set_qid(qid: String) -> void: 
	_qid_label.text = qid


## Sets the fade time label
func set_fade_time(fade_time: float) -> void: 
	_fade_time_label.text = str(fade_time)


## Sets the pre wait label
func set_pre_wait(pre_wait: float) -> void: 
	_pre_wait_label.text = str(pre_wait)


## Sets the trigger mode
func set_trigger_mode(trigger_mode: Cue.TriggerMode) -> void:
	_trigger_mode_manual.hide()
	_trigger_mode_after_last.hide()
	_trigger_mode_with_last.hide()
	
	match trigger_mode:
		Cue.TriggerMode.MANUAL: 
			_trigger_mode_manual.show()
		
		Cue.TriggerMode.AFTER_LAST: 
			_trigger_mode_after_last.show()
		
		Cue.TriggerMode.WITH_LAST: 
			_trigger_mode_with_last.show()


## Called when the CueList cue number changes
func _on_active_cue_changed(cue: Cue) -> void:
	if cue == _cue:
		set_status_bar(true, _cue_list.get_global_fade_speed() if _cue_list.get_global_fade_state() else _cue.get_fade_time())
		$Selected.show()
	
	elif _is_enabled: 
		var fade_time: float = 0
		fade_time = _cue_list.get_global_fade_speed() if _cue_list.get_global_fade_state() else cue.get_fade_time()
		
		set_status_bar(false, fade_time)
		$Selected.hide()


## Called when the CueList's transport state is changed
func _on_transport_state_changed(transport_state: Function.TransportState) -> void:
	if transport_state and _current_tween and _current_tween.is_valid():
		_current_tween.play()
	
	elif _current_tween and _current_tween.is_valid():
		_current_tween.pause()


## Called when the CueList's active state is changed
func _on_active_state_changed(active_state: Function.ActiveState) -> void:
	if not active_state:
		if _current_tween:
			_current_tween.kill()
		
		_is_enabled = false
		_status_bar.set_value_no_signal(0)
		$Selected.hide()


## Called when store mode is changed
func _on_store_mode_changed(store_mode: bool, class_hint: String) -> void:
	$StoreMode.visible = store_mode


## Called when an input event is decected in the panel
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		event = event as InputEventMouseButton
		
		if event.double_click: 
			if _cue_list and _cue:
				_cue_list.seek_to(_cue)
			
		else:
			clicked.emit()
			
			if Programmer.get_store_mode():
				Programmer.resolve_store_mode(_cue)
