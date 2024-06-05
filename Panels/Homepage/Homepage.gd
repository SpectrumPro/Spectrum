# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends Control

@export_node_path("Label") var status: NodePath
@export_node_path("LineEdit") var address: NodePath
@export_node_path("LineEdit") var port: NodePath

@export_node_path("VBoxContainer") var main_buttons: NodePath
@export_node_path("VBoxContainer") var connect_buttons: NodePath


func _ready() -> void:
	MainSocketClient.connected_to_server.connect(self._on_web_socket_client_connected_to_server)
	MainSocketClient.connection_closed.connect(self._on_web_socket_client_connection_closed)


func info(msg):
	print(msg)
	self.get_node(status).text = msg


func _on_web_socket_client_connection_closed():
	var ws = MainSocketClient.get_socket()
	info("Connection Failed %s" % [ws.get_close_code(), ws.get_close_reason()])


func _on_web_socket_client_connected_to_server():
	info("Connected")
	get_tree().change_scene_to_file("res://Main.tcsn")


func _on_web_socket_client_message_received(message):
	info("%s" % message)


func _on_connect_pressed() -> void:
	MainSocketClient.connect_to_url("ws://" + self.get_node(address).text + ":" + self.get_node(port).text)
	info("Connecting")


func _on_connect_to_server_pressed() -> void:
	self.get_node(main_buttons).visible = false
	self.get_node(connect_buttons).visible = true


func _on_exit_pressed() -> void:
	get_tree().quit()
