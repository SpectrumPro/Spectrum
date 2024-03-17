extends DataIOPlugin
class_name ArtNetOutput

var meta = {
	"name": "Art Net Output"
}

var _udp_peer = PacketPeerUDP.new()

var exposed_values = [
	{
		"name":"Ip Address",
		"type":LineEdit,
		"signal":"text_submitted",
		"function":self.set_ip_addr,
		"parameters":{
			"placeholder_text":"172.0.0.1",
			"text":self.get_ip_addr
		}
	},
	{
		"name":"Port",
		"type":SpinBox,
		"signal":"value_changed",
		"function":self.set_port,
		"parameters": {
			"max_value":65535,
			"value":self.get_port
		}
	}, 
	{
		"name":"Art-Net Universe",
		"type":SpinBox,
		"signal":"value_changed",
		"function":self.set_universe,
		"parameters":{
			"max_value":9223370000000000000,
			"rounded":"true",
			"value":self.get_universe
		}
	}
]

var config = {
	"ip":"172.0.0.1",
	"port":6454,
	"universe":0,
}

func _init():
	self.set_type("output")
	self.name = meta.name
	super._init()

func connect_to_host():
	_udp_peer.close()
	_udp_peer.connect_to_host(config.ip, config.port)

func set_ip_addr(new_ip_address):
	config.ip = new_ip_address
	connect_to_host()

func set_port(new_port):
	config.port = new_port
	connect_to_host()

func set_universe(new_universe):
	config.universe = new_universe
	connect_to_host()
	
func get_ip_addr():
	return config.ip

func get_port():
	return config.port

func get_universe():
	return config.universe

func serialize():
	return config

func from(serialized_data):
	config = serialized_data

func _disconnect():
	_udp_peer.close()

func delete():
	_disconnect()

func send_packet(dmx_data) -> void:
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
	packet.append(int(config.universe) % 256)  # Lower 8 bits
	packet.append(int(config.universe) / 256)  # Upper 8 bits

	# Length (16-bit)
#	packet.append_array([512 % 256, int(512 / 255)])
	packet.append(02)
	packet.append(00)
	
	# DMX Channels
	for channel in range(1, 513):
		packet.append(dmx_data.get(channel, 0))

	# Send the packet
#	_udp_peer.set_dest_address(ip, port)
	_udp_peer.put_packet(packet)
	
