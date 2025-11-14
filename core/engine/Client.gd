# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name CoreClient extends Node
## Client side network control


@warning_ignore_start("unused_signal")
@warning_ignore_start("unused_private_class_variable")

## Emitted when we connect to the server
signal connected_to_server()

## Emitted when the connection closes
signal connection_closed()


## Default server ip address
var ip_address: String = "127.0.0.1"

## Default server port
var websocket_port: int = 3824

## Default server udp port
var udp_port: int = 3823

## Contains a list of networked objects, stores their functions and data types of there args
var _networked_objects: Dictionary = {}

## Contains a list of callbacks, stored as callback id:callable
var _callbacks: Dictionary = {}

## All the objects that have been networked
var _networked_objects_delete_callbacks: Dictionary = {}

## Is this server expecting a disconnect
var _is_expecting_disconnect: bool = false


func _ready() -> void:
	pass


## Starts the server on the given port, 
func connect_to_server(p_ip: String = ip_address, p_websocket_port: int = websocket_port, p_udp_port: int = udp_port):
	pass


## Disconnects from the server
func disconnect_from_server() -> void:
	pass


## Checks if this client is expecting a disconnect from the server
func is_expecting_disconnect() -> bool:
	return false


## Checks if this client is connected to a server
func is_connected_to_server() -> bool:
	return false


## Send a message to the server, all data passed is automatically converted to strings, and serialised
func send(data: Dictionary) -> void:
	pass


## Sends a command to the server
func send_command(object_id: String, method: String, args: Array = []) -> Promise:
	return Promise.new().auto_reject()


## Registers a component as a network object
func register_component(p_component: EngineComponent) -> void:
	pass


## Deregisters a component as a network object
func deregister_component(p_component) -> void:
	pass


## Add a network object
func add_networked_object(object_name: String, object: Object, delete_signal: Signal = Signal()) -> void:
	pass


## Remove a network object
func remove_networked_object(object_name: String) -> void:
	pass


## Called when a message is receved from the server 
func _on_message_receved(message: Variant) -> void:
	pass


## Called when high frequency UDP message is recieved
func _on_udp_message_receved(message: Variant) -> void:
	pass


## Function to call a method, checks all method types befour calling
func _call_method(networked_object: Dictionary, method_name: String, method_dict: Dictionary, args: Array = []):
	pass
