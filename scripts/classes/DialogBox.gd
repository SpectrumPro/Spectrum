# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name DialogBox extends Control
## Base class for all dialog boxes


## Emitted when this is confirmed
signal confirmed(value: Variant)

## Emitted when this is rejected
signal rejected()


## The label
@export var _label: Label = null

## The Promise callback
var _promise: Promise = Promise.new()


func _ready() -> void:
	_promise.then(func (value: Variant=null): if value: confirmed.emit(value) else: confirmed.emit())
	_promise.catch(func (): rejected.emit())


## Changes the title
func set_title(title: String) -> void:
	_label.text = title


## Adds a method that will be called if this promise is resolved
func then(method: Callable) -> DialogBox:
	_promise.then(method)

	return self


## Adds a method that will be called if this promise is rejected
func catch(method: Callable) -> DialogBox:
	_promise.catch(method)

	return self
