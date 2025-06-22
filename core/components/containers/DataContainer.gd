# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name DataContainer extends EngineComponent
## DataContainer stores fixture data


## Emitted when ContainerItems are stored
signal items_stored(items: Array)

## Emitted when ContainerItems are erased
signal items_erased(items: Array)

## Emitted when the function is changed in mutiple ContainerItems
signal items_function_changed(items: Array, function: String)

## Emitted when the value is changed in mutiple ContainerItems
signal items_value_changed(items: Array, value: float)

## Emitted when the can_fade state is changed in mutiple ContainerItems
signal items_can_fade_changed(items: Array, can_fade: bool)

## Emitted when the start point is changed in mutiple ContainerItems
signal items_start_changed(items: Array, start: float)

## Emitted when the stop point is changed in mutiple ContainerItems
signal items_stop_changed(items: Array, stop: float)


## All ContainerItems
var _items: Array[ContainerItem]

## All fixtures stored as { Fixture: { zone: { parameter: ContainerItem } } }
var _fixture: Dictionary[Fixture, Dictionary]


## Constructor
func _init(p_uuid: String = UUID_Util.v4(), p_name: String = name) -> void:
	_set_name("DataContainer")
	_set_self_class("DataContainer")
	
	register_callback("on_items_stored", _store_items)
	register_callback("on_items_erased", _erase_items)
	register_callback("on_items_function_changed", _set_function)
	register_callback("on_items_value_changed", _set_value)
	register_callback("on_items_can_fade_changed", _set_can_fade)
	register_callback("on_items_start_changed", _set_start)
	register_callback("on_items_stop_changed", _set_stop)
	
	super._init(p_uuid, p_name)


## Gets all the ContainerItems
func get_items() -> Array[ContainerItem]:
	return _items.duplicate()


## Gets all the fixture data
func get_fixtures() -> Dictionary[Fixture, Dictionary]:
	return _fixture.duplicate(true)


## Gets a list of all fixtures in this DataContainer
func get_stored_fixtures() -> Array:
	return _fixture.keys()


## Stores data into this DataContainer
func store_data(p_fixture: Fixture, p_zone: String, p_parameter: String, p_function: String, p_value: float, p_can_fade: bool = true, p_start: float = 0.0, p_stop: float = 1.0) -> Promise:
	return rpc("store_data", [p_fixture, p_zone, p_parameter, p_function, p_value, p_can_fade, p_start, p_stop])


## Erases data
func erase_data(p_fixture: Fixture, p_zone: String, p_parameter: String) -> Promise:
	return rpc("erase_data", [p_fixture, p_zone, p_parameter])
	

## Stores a ContainerItem
func store_item(p_item: ContainerItem) -> Promise:
	return rpc("store_item", [p_item])


## Stores mutiple items at once
func store_items(p_items: Array) -> Promise:
	return rpc("store_items", [p_items])


## Erases an item
func erase_item(p_item: ContainerItem) -> Promise:
	return rpc("erase_item", [p_item])


## Erases mutiple items at once
func erase_items(p_items: Array) -> Promise:
	return rpc("erase_items", [p_items])


## Sets the function of mutiple items
func set_function(p_items: Array, p_function: String) -> Promise:
	return rpc("set_function", [p_items, p_function])


## Sets the value of mutiple items
func set_value(p_items: Array, p_value: float) -> Promise:
	return rpc("set_value", [p_items, p_value])


## Sets the value of mutiple items
func set_can_fade(p_items: Array, p_can_fade: bool) ->Promise:
	return rpc("set_can_fade", [p_items, p_can_fade])


## Sets the value of mutiple items
func set_start(p_items: Array, p_start: float) -> Promise:
	return rpc("set_start", [p_items, p_start])


## Sets the value of mutiple items
func set_stop(p_items: Array, p_stop: float) -> Promise:
	return rpc("set_stop", [p_items, p_stop])


## Internal: Stores a ContainerItem
func _store_item(p_item: ContainerItem, no_signal: bool = false) -> bool:
	if not p_item or p_item in _items or not p_item.is_valid():
		return false
	
	_items.append(p_item)
	_fixture.get_or_add(p_item.get_fixture(), {}).get_or_add(p_item.get_zone(), {})[p_item.get_parameter()] = p_item

	#ComponentDB.register_component(p_item)
	p_item.delete_requested.connect(_erase_item.bind(p_item))

	if not no_signal:
		items_stored.emit([p_item])
	
	return true


## Internal: Stores mutiple items at once
func _store_items(p_items: Array) -> void:
	var just_added_items: Array[ContainerItem]

	for item: Variant in p_items:
		if item is ContainerItem:
			if _store_item(item, true):
				just_added_items.append(item)
	
	if just_added_items:
		items_stored.emit(just_added_items)


## Internal: Erases an item
func _erase_item(p_item: ContainerItem, no_signal: bool = false) -> bool:
	if not p_item or p_item not in _items:
		return false
	
	_items.erase(p_item)
	_fixture[p_item.get_fixture()][p_item.get_zone()].erase(p_item.get_parameter())

	if not no_signal:
		items_erased.emit([p_item])
	
	return true


## Internal: Erases mutiple items at once
func _erase_items(p_items: Array) -> void:
	var just_erased_items: Array[ContainerItem]

	for item: Variant in p_items:
		if item is ContainerItem:
			if _erase_item(item, true):
				just_erased_items.append(item)
	
	if just_erased_items:
		items_erased.emit(just_erased_items)


## Internal: Sets the function of mutiple items
func _set_function(p_items: Array, p_function: String) -> void:
	var changed_items: Array[ContainerItem]

	for item: Variant in p_items:
		if item is ContainerItem:
			if item.set_function(p_function):
				changed_items.append(item)
	
	if changed_items:
		items_function_changed.emit(changed_items, p_function)


## Internal: Sets the value of mutiple items
func _set_value(p_items: Array, p_value: float) -> void:
	var changed_items: Array[ContainerItem]

	for item: Variant in p_items:
		if item is ContainerItem:
			if item.set_value(p_value):
				changed_items.append(item)
	
	if changed_items:
		items_value_changed.emit(changed_items, p_value)


## Internal: Sets the value of mutiple items
func _set_can_fade(p_items: Array, p_can_fade: bool) -> void:
	var changed_items: Array[ContainerItem]

	for item: Variant in p_items:
		if item is ContainerItem:
			if item.set_can_fade(p_can_fade):
				changed_items.append(item)
	
	if changed_items:
		items_can_fade_changed.emit(changed_items, p_can_fade)


## Internal: Sets the value of mutiple items
func _set_start(p_items: Array, p_start: float) -> void:
	var changed_items: Array[ContainerItem]

	for item: Variant in p_items:
		if item is ContainerItem:
			if item.set_start(p_start):
				changed_items.append(item)
	
	if changed_items:
		items_start_changed.emit(changed_items, p_start)


## Internal: Sets the value of mutiple items
func _set_stop(p_items: Array, p_stop: float) -> void:
	var changed_items: Array[ContainerItem]

	for item: Variant in p_items:
		if item is ContainerItem:
			if item.set_stop(p_stop):
				changed_items.append(item)
	
	if changed_items:
		items_stop_changed.emit(changed_items, p_stop)


## Serializes this DataContainer and returnes it in a dictionary
func _serialize() -> Dictionary:
	return {
		"items": Utils.seralise_component_array(_items)
	}


## Called when this DataContainer is to be loaded from serialized data
func _load(serialized_data: Dictionary) -> void:
	_store_items(Utils.deseralise_component_array(type_convert(serialized_data.get("items", []), TYPE_ARRAY)))


## Handles delete requests
func _delete() -> void:
	for item: ContainerItem in _items:
		item.local_delete()


## Serializes this Datacontainer and returnes it in a dictionary
func _serialize_request() -> Dictionary: 
	return _serialize()


## Loads this DataContainer from a dictonary
func _load_request(serialized_data) -> void: 
	_load(serialized_data)


## Handles delete requests
func _delete_request() -> void:
	_delete()
