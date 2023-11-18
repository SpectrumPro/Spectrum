extends GraphNode


var udp_peer = PacketPeerUDP.new()
var target_ip = "172.0.0.1"
var target_port = 6454

var formatted_dmx_data = []
var packet_id = 0
var debug_index = 1

func _ready():
	connect_to_host()

func connect_to_host():
	udp_peer.close()
	udp_peer.connect_to_host(target_ip, target_port)

func _on_Control_close_request():
	get_parent().delete(self)
	queue_free()

func node_process():
	pass

func receive(data, _slot):
	formatted_dmx_data = []
	for channel in range(1, 513):
		formatted_dmx_data.append(data.dmx_channels.get(channel, 0))
	send_artnet_packet(data.universe-1)
	print(formatted_dmx_data)

func _on_Control_resize_request(new_minsize):
	size = new_minsize

func send_artnet_packet(universe):
	# Construct Art-Net packet
	var packet = PackedByteArray()

	# Art-Net ID ('Art-Net')
	packet.append_array([65, 114, 116, 45, 78, 101, 116, 0])

	# OpCode: ArtDMX (0x5000)
	packet.append_array([0, 80])

	# Protocol Version: 14 (0x000e)
	packet.append_array([0, 14])

	# ArtDMX packet
	# Sequence Number
	packet.append(0)

	# Physical Port (Set to 0 if not needed)
	packet.append(0)

	# Universe (16-bit)
	packet.append(universe)
	packet.append(0)

	# Length (16-bit)
#	packet.append_array([512 % 256, int(512 / 255)])
	packet.append(02)
	packet.append(00)
	
	# DMX Channels
	for value in formatted_dmx_data:
		packet.append(value)

	# Send the packet
#	udp_peer.set_dest_address(ip, port)

	udp_peer.put_packet(packet)
	


func _on_url_text_submitted(new_text):
	target_ip = new_text
	connect_to_host()

func _on_port_text_submitted(new_text):
	target_port = int(new_text)
	connect_to_host()
