# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name UIInterfaceSelector extends UIPopup
## UIInterfaceSelector


## Emitted when an interface and address is selected
signal address_selected(address: IPAddr)


## The Tree for displaying network interfaces
@export var interface_tree: Tree

## The Confirm Button
@export var confirm_button: Button

## Min size of the second tree column
@export var column_min_size: int = 100


## init
func _init() -> void:
	super._init()
	
	_set_class_name("UIInterfaceSelector")
	set_custom_accepted_signal(address_selected)


## Ready
func _ready() -> void:
	interface_tree.set_column_expand(1, false)
	interface_tree.set_column_custom_minimum_width(1, column_min_size)
	
	reload()


## Reloads the interface tree
func reload() -> void:
	var interfaces: Array[Dictionary] = IP.get_local_interfaces()
	
	interface_tree.clear()
	interface_tree.create_item()
	confirm_button.set_disabled(true)
	
	for interface: Dictionary in interfaces:
		_create_interface_item(interface)


## Creates TreeItems for the given interface
func _create_interface_item(p_interface: Dictionary) -> void:
	var interface_item: TreeItem = interface_tree.create_item()
	
	interface_item.set_text(0, p_interface.name)
	interface_item.set_icon(0, preload("res://assets/icons/Ethernet.svg"))
	
	interface_item.set_custom_color(1, Color(0x919191ff))
	interface_item.set_text(1, "Interface")
	
	for address: String in p_interface.addresses:
		_create_address_item(address, interface_item)


## Creates a TreeItem for a given address on an interface
func _create_address_item(p_address: String, p_interface_item: TreeItem) -> void:
	var address_item: TreeItem = p_interface_item.create_child()
	address_item.set_text(0, p_address)
	
	if p_address.contains(":"):
		address_item.set_icon(0, preload("res://assets/icons/IPAddrV6.svg"))
	else:
		address_item.set_icon(0, preload("res://assets/icons/IPAddrV4.svg"))
	
	address_item.set_custom_color(1, Color(0x919191ff))
	address_item.set_text(1, "Address")


## Emits the selected item, if any
func _confirm_selected() -> void:
	var selected: TreeItem = interface_tree.get_selected()
	var address: IPAddr = IPAddr.new()
	
	if not selected:
		return
	
	if selected.get_parent() == interface_tree.get_root():
		address.set_interface(selected.get_text(0))
	else:
		address.set_address(selected.get_text(0))
		address.set_interface(selected.get_parent().get_text(0))
	
	accept(address)


## Called when an item is selected in the InterfaceTree
func _on_interface_tree_item_selected() -> void:
	confirm_button.set_disabled(false)


## Called when nothing is sleected in the InterfaceTree
func _on_interface_tree_nothing_selected() -> void:
	interface_tree.deselect_all()
	confirm_button.set_disabled(true)
