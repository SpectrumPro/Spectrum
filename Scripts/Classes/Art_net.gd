extends Node
class_name ArtNet

var _udp_peer = PacketPeerUDP.new()

var art_net = {
	"ip":"172.0.0.1",
	"port":6454,
	"universe":0,
	"name":"Art-Net Output", 
	"type":"Art-Net"
}

func connect_to_host():
	_udp_peer.close()
	print(_udp_peer.connect_to_host(art_net.ip, art_net.port))

func _get_name():
	return art_net.name

func _set_name(name):
	art_net.name = name

func get_type():
	return art_net.type


func send_packet(dmx_data):
	print(dmx_data)
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
	packet.append(art_net.universe % 256)  # Lower 8 bits
	packet.append(art_net.universe / 256)  # Upper 8 bits

	# Length (16-bit)
#	packet.append_array([512 % 256, int(512 / 255)])
	packet.append(02)
	packet.append(00)
	
	# DMX Channels
	for channel in range(1, 513):
		packet.append(dmx_data.get(channel, 0))
		print(dmx_data.get(channel, 0))

	# Send the packet
#	_udp_peer.set_dest_address(ip, port)
	_udp_peer.put_packet(packet)
	
