GLOBAL_DATUM_INIT(foundation_network, /datum/net_bus_controller, new)

/datum/net_bus_controller
	var/list/buses = list()

/datum/net_bus_controller/proc/get_bus(channel_id)
	if(!buses[channel_id])
		buses[channel_id] = new /datum/net_bus(channel_id)
	return buses[channel_id]

/datum/net_bus_controller/proc/remove_bus(channel_id)
	var/datum/net_bus/bus = buses[channel_id]
	if(bus)
		qdel(bus)
		buses -= channel_id

/datum/net_bus
	var/channel_id
	var/list/devices_by_address = list()
	var/list/devices_by_tag = list()
	var/list/all_hearing = list()
	var/list/firewalls = list()
	var/active = TRUE

	New(id)
		channel_id = id

	Destroy()
		deactivate()
		return ..()

/datum/net_bus/proc/deactivate()
	active = FALSE
	for(var/atom/movable/device as anything in all_hearing)
		var/datum/component/network_connected/comp = device.GetComponent(/datum/component/network_connected)
		if(comp)
			comp.network_bus = null
			comp.connected = FALSE
	devices_by_address.Cut()
	devices_by_tag.Cut()
	all_hearing.Cut()
	firewalls.Cut()

/datum/net_bus/proc/register_device(atom/movable/device, address, list/tags)
	devices_by_address[address] = device
	all_hearing |= device
	if(tags)
		for(var/tag in tags)
			LAZYADD(devices_by_tag[tag], device)

/datum/net_bus/proc/unregister_device(atom/movable/device)
	var/addr = null
	for(var/a in devices_by_address)
		if(devices_by_address[a] == device)
			addr = a
			break
	if(addr)
		devices_by_address -= addr
	all_hearing -= device
	for(var/tag in devices_by_tag)
		devices_by_tag[tag] -= device
		if(!length(devices_by_tag[tag]))
			devices_by_tag -= tag

/datum/net_bus/proc/post_packet(datum/net_signal/signal)
	if(!active)
		return FALSE
	for(var/datum/net_firewall/fw as anything in firewalls)
		if(!fw.check_packet(signal))
			return FALSE
	if(signal.target_address)
		var/atom/movable/target = devices_by_address[signal.target_address]
		if(target)
			deliver_signal(target, signal)
	else
		broadcast_packet(signal)
	return TRUE

/datum/net_bus/proc/broadcast_packet(datum/net_signal/signal)
	for(var/atom/movable/device as anything in all_hearing)
		deliver_signal(device, signal)

/datum/net_bus/proc/deliver_signal(atom/movable/device, datum/net_signal/signal)
	var/datum/component/network_connected/comp = device.GetComponent(/datum/component/network_connected)
	if(!comp || !comp.connected || !comp.receive_packet_proc)
		return
	call(device, comp.receive_packet_proc)(signal)

/datum/net_bus/proc/add_firewall(datum/net_firewall/firewall)
	firewalls |= firewall

/datum/net_bus/proc/remove_firewall(datum/net_firewall/firewall)
	firewalls -= firewall

/datum/net_bus/proc/get_devices_with_tag(tag)
	return devices_by_tag[tag]
