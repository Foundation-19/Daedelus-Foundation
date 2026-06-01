/datum/net_signal
	var/list/data
	var/command
	var/source
	var/priority
	var/target_address
	var/transmit_type

	New(list/data, command, source, priority, transmit_type)
		src.data = data
		src.command = command
		src.source = source
		src.priority = priority
		src.transmit_type = transmit_type
