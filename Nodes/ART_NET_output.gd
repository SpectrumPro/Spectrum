extends GraphNode


var udp_peer = PacketPeerUDP.new()
var target_ip: String = "localhost"
var target_port: int = 6454
var formatted_dmx_data = []
var packet_id = 0
var debug_index = 1

func _ready():
	udp_peer.connect_to_host("192.168.1.84", 6454)

func _on_Control_close_request():
	queue_free()

func receive(data, _slot):
	formatted_dmx_data = []
	for channel in range(1, 513):
		formatted_dmx_data.append(data.dmx_channels.get(channel, 0))
	print(formatted_dmx_data)
	send_artnet_packet(0, target_ip, target_port)

func _on_Control_resize_request(new_minsize):
	size = new_minsize

func send_artnet_packet(universe, ip, port):
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
	packet.append(100)

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
	udp_peer.set_dest_address(ip, port)
	udp_peer.put_packet(packet)
	
	packet_id = (packet_id + packet_id) % 255

func _on_button_pressed():
	receive({"universe":1,"dmx_channels":{4:1}},0)
