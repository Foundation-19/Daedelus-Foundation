/datum/component/network_connected
	var/datum/net_bus/network_bus
	var/connected = FALSE
	var/receive_packet_proc
	var/address
	var/list/tags

	Initialize(network_bus, connected, receive_packet_proc, address, list/tags)
		src.network_bus = network_bus
		src.connected = connected
		src.receive_packet_proc = receive_packet_proc
		src.address = address
		src.tags = tags ? tags.Copy() : list()

/datum/component/network_connected/proc/register_with_bus(datum/net_bus/bus)
	if(connected)
		return
	bus.register_device(parent, address, tags)
	network_bus = bus
	connected = TRUE

/datum/component/network_connected/proc/unregister_from_bus()
	if(!connected)
		return
	network_bus.unregister_device(parent)
	connected = FALSE
