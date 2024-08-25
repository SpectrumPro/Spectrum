# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name SettingsPanel extends PanelContainer

## UI panel for client settings


## Ui items
@onready var status_label: Label = $VBoxContainer/Status
@onready var ip_input: LineEdit = $VBoxContainer/IpAddr
@onready var key_pad: KeyPadComponent = $KeyPad


func _ready() -> void:
	MainSocketClient.connected_to_server.connect(_on_connected_to_server)
	MainSocketClient.connection_closed.connect(_on_connection_closed)
	
	Interface.kiosk_mode_changed.connect(_on_kiosk_mode_changed)
	
	ip_input.editable = MainSocketClient.last_state == WebSocketPeer.STATE_CLOSED
	_reload_ui()



func _on_connected_to_server() -> void:
	ip_input.editable = false
	_reload_ui()


func _on_connection_closed() -> void:
	ip_input.editable = true
	_reload_ui()


func _on_kiosk_mode_changed(kiosk_mode: bool) -> void:
	$VBoxContainer/KioskMode.text = "Exit Kiosk Mode" if kiosk_mode else "Enter Kiosk Mode"
	
	$VBoxContainer/HBoxContainer/Connect.disabled = kiosk_mode
	$VBoxContainer/HBoxContainer/Disconnect.disabled = kiosk_mode
	$VBoxContainer/IpAddr.editable = not kiosk_mode


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


func _on_kiosk_mode_pressed() -> void:
	key_pad.show()
	$VBoxContainer.hide()
	
	if Interface.kiosk_mode:
		key_pad.set_label_text("Kiosk Passcode")
		key_pad.set_passcode(Interface.kiosk_password)
		key_pad.code_accepted.connect(_on_key_pad_code_accepted, CONNECT_ONE_SHOT)
	
	else:
		key_pad.set_label_text("Kiosk Passcode")
		key_pad.set_passcode(Interface.kiosk_password)
		key_pad.code_entred.connect(_on_key_pad_code_entred, CONNECT_ONE_SHOT)


func _on_key_pad_code_accepted() -> void:
	if Interface.kiosk_mode:
		Interface.kiosk_mode = false
		
		key_pad.hide()
		$VBoxContainer.show()


func _on_key_pad_code_entred(code: Array[int]) -> void:
	Interface.kiosk_password = code
	Interface.kiosk_mode = true
	
	key_pad.hide()
	$VBoxContainer.show()


func _on_key_pad_closed_requested() -> void:
	key_pad.code_entred.disconnect(_on_key_pad_code_entred)
	key_pad.code_accepted.disconnect(_on_key_pad_code_accepted)
	key_pad.hide()
	$VBoxContainer.show()
