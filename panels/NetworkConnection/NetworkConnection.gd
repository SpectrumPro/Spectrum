# Copyright (c) 2024 Liam Sherwin
# All rights reserved.
class_name NetworkConnectionPanel extends PanelContainer
## UI panel for connecting to server


## Ui items
@onready var status_label: Label = $VBoxContainer/Status
@onready var ip_input: LineEdit = $VBoxContainer/IpAddr


func _ready() -> void:
	MainSocketClient.connected_to_server.connect(_on_connected_to_server)
	MainSocketClient.connection_closed.connect(_on_connection_closed)

	ip_input.editable = MainSocketClient.last_state == WebSocketPeer.STATE_CLOSED
	_reload_ui()



func _on_connected_to_server() -> void:
	ip_input.editable = false
	_reload_ui()


func _on_connection_closed() -> void:
	ip_input.editable = true
	_reload_ui()


## Reloads the status label from the current connection state
func _reload_ui() -> void:
	var status: String = ""
	
	match MainSocketClient.last_state:
		WebSocketPeer.STATE_CONNECTING:
			status = "Connecting..."
		WebSocketPeer.STATE_OPEN:
			status = "Connected"
		WebSocketPeer.STATE_CLOSING:
			status = "Disconnecting..."
		WebSocketPeer.STATE_CLOSED:
			status = "Disconnected"
	
	status_label.text = status
	
	ip_input.text = Core.server_ip_address


func _on_connect_pressed() -> void:
	Core.connect_to_server(ip_input.text)


func _on_disconnect_pressed() -> void:
	Core.disconnect_from_server()
