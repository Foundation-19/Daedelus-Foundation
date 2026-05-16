// SCP Component Networking and Communication System
// Advanced inter-component communication and networking capabilities

// Component Communication Interface
/datum/scp_component_communicator
	var/name = "Component Communicator"
	var/list/subscribed_components = list()
	var/list/message_queue = list()
	var/list/broadcast_channels = list()
	var/max_queue_size = 100
	var/processing_enabled = TRUE

/datum/scp_component_communicator/New()
	. = ..()
	// Initialize default communication channels
	broadcast_channels["global"] = list()
	broadcast_channels["scp_specific"] = list()
	broadcast_channels["skill_system"] = list()
	broadcast_channels["containment"] = list()
	broadcast_channels["emergency"] = list()

/datum/scp_component_communicator/proc/subscribe_component(datum/scp_advanced_component/component, channel = "global")
	if(!component || !channel)
		return FALSE

	if(!(channel in broadcast_channels))
		broadcast_channels[channel] = list()

	if(!(component in broadcast_channels[channel]))
		broadcast_channels[channel] += component
		subscribed_components += component
		return TRUE

	return FALSE

/datum/scp_component_communicator/proc/unsubscribe_component(datum/scp_advanced_component/component, channel = "global")
	if(!component || !channel)
		return FALSE

	if(channel in broadcast_channels)
		broadcast_channels[channel] -= component
		subscribed_components -= component
		return TRUE

	return FALSE

/datum/scp_component_communicator/proc/send_message(datum/scp_advanced_component/sender, datum/scp_advanced_component/receiver, message_data, priority = COMPONENT_PRIORITY_NORMAL)
	if(!sender || !receiver || !message_data)
		return FALSE

	var/message = list(
		"sender" = sender,
		"receiver" = receiver,
		"data" = message_data,
		"priority" = priority,
		"timestamp" = world.time,
		"id" = generate_message_id()
	)

	// Add to message queue based on priority
	if(priority >= COMPONENT_PRIORITY_HIGH)
		message_queue.Insert(1, message) // High priority messages go to front
	else
		message_queue += message

	// Enforce queue size limit
	if(length(message_queue) > max_queue_size)
		message_queue.Cut(max_queue_size + 1)

	return TRUE

/datum/scp_component_communicator/proc/broadcast_message(datum/scp_advanced_component/sender, message_data, channel = "global", priority = COMPONENT_PRIORITY_NORMAL)
	if(!sender || !message_data || !channel)
		return FALSE

	if(!(channel in broadcast_channels))
		return FALSE

	var/message = list(
		"sender" = sender,
		"data" = message_data,
		"priority" = priority,
		"timestamp" = world.time,
		"channel" = channel,
		"id" = generate_message_id()
	)

	// Send to all subscribers of the channel
	for(var/datum/scp_advanced_component/component in broadcast_channels[channel])
		if(component != sender && component.component_state == COMPONENT_STATE_ACTIVE)
			component.receive_broadcast(message)

	return TRUE

/datum/scp_component_communicator/proc/process_message_queue()
	if(!processing_enabled || !length(message_queue))
		return

	var/messages_processed = 0
	var/max_process_per_tick = 5

	while(length(message_queue) && messages_processed < max_process_per_tick)
		var/list/message = message_queue[1]
		message_queue.Cut(1, 2)

		var/datum/scp_advanced_component/receiver = message["receiver"]
		if(receiver && receiver.component_state == COMPONENT_STATE_ACTIVE)
			receiver.receive_message(message)

		messages_processed++

/datum/scp_component_communicator/proc/generate_message_id()
	return "MSG_[world.time]_[rand(1000, 9999)]"

// Enhanced Component Base with Communication
/datum/scp_advanced_component
	var/datum/scp_component_communicator/communicator = null
	var/list/subscribed_channels = list()

/datum/scp_advanced_component/proc/initialize_communication()
	if(!manager || !manager.communicator)
		return FALSE

	communicator = manager.communicator

	// Subscribe to relevant channels
	communicator.subscribe_component(src, "global")
	subscribed_channels += "global"

	// Subscribe to component category specific channel
	if(component_category)
		communicator.subscribe_component(src, component_category)
		subscribed_channels += component_category

	return TRUE

/datum/scp_advanced_component/proc/send_message_to_component(datum/scp_advanced_component/target, message_data, priority = COMPONENT_PRIORITY_NORMAL)
	if(!communicator || !target)
		return FALSE

	return communicator.send_message(src, target, message_data, priority)

/datum/scp_advanced_component/proc/broadcast_to_channel(message_data, channel = "global", priority = COMPONENT_PRIORITY_NORMAL)
	if(!communicator)
		return FALSE

	return communicator.broadcast_message(src, message_data, channel, priority)

/datum/scp_advanced_component/proc/receive_message(list/message)
	// Override in specific components to handle direct messages
	var/message_type = message["data"]["type"]

	switch(message_type)
		if("skill_coordination")
			handle_skill_coordination(message)
		if("status_request")
			handle_status_request(message)
		if("emergency_alert")
			handle_emergency_alert(message)
		if("component_sync")
			handle_component_sync(message)

/datum/scp_advanced_component/proc/receive_broadcast(list/message)
	// Override in specific components to handle broadcast messages
	var/channel = message["channel"]
	var/message_data = message["data"]

	switch(channel)
		if("emergency")
			handle_emergency_broadcast(message_data)
		if("skill_system")
			handle_skill_broadcast(message_data)
		if("containment")
			handle_containment_broadcast(message_data)

/datum/scp_advanced_component/proc/handle_skill_coordination(list/message)
	// Handle skill coordination between components
	return

/datum/scp_advanced_component/proc/handle_status_request(list/message)
	// Respond to status requests from other components
	var/status_data = list(
		"component_id" = component_id,
		"state" = component_state,
		"health" = "operational"
	)

	send_message_to_component(message["sender"], list("type" = "status_response", "data" = status_data))

/datum/scp_advanced_component/proc/handle_emergency_alert(list/message)
	// Handle emergency alerts from other components
	component_priority = COMPONENT_PRIORITY_HIGH
	trigger_event("emergency_mode", message["data"])

/datum/scp_advanced_component/proc/handle_component_sync(list/message)
	// Handle component synchronization requests
	return

/datum/scp_advanced_component/proc/handle_emergency_broadcast(message_data)
	// Handle emergency broadcasts
	trigger_event("emergency_broadcast", message_data)

/datum/scp_advanced_component/proc/handle_skill_broadcast(message_data)
	// Handle skill system broadcasts
	return

/datum/scp_advanced_component/proc/handle_containment_broadcast(message_data)
	// Handle containment system broadcasts
	return

// Enhanced Component Manager with Communication
/datum/component_manager_advanced
	var/datum/scp_component_communicator/communicator = null

/datum/component_manager_advanced/New(mob/target)
	. = ..()
	communicator = new /datum/scp_component_communicator()

/datum/component_manager_advanced/proc/process_communication()
	if(communicator)
		communicator.process_message_queue()

// Component Synchronization System
/datum/scp_component_synchronizer
	var/name = "Component Synchronizer"
	var/list/synchronized_components = list()
	var/sync_interval = 30 SECONDS
	var/last_sync_time = 0
	var/auto_sync_enabled = TRUE

/datum/scp_component_synchronizer/proc/add_component(datum/scp_advanced_component/component)
	if(!component)
		return FALSE

	if(!(component in synchronized_components))
		synchronized_components += component
		return TRUE

	return FALSE

/datum/scp_component_synchronizer/proc/remove_component(datum/scp_advanced_component/component)
	synchronized_components -= component

/datum/scp_component_synchronizer/proc/sync_all_components()
	if(world.time < last_sync_time + sync_interval)
		return

	last_sync_time = world.time

	for(var/datum/scp_advanced_component/component in synchronized_components)
		if(component.component_state == COMPONENT_STATE_ACTIVE)
			sync_component(component)

/datum/scp_component_synchronizer/proc/sync_component(datum/scp_advanced_component/component)
	var/sync_data = list(
		"component_id" = component.component_id,
		"state" = component.component_state,
		"timestamp" = world.time,
		"version" = component.version
	)

	component.broadcast_to_channel(list("type" = "component_sync", "data" = sync_data), "global")

// Inter-SCP Communication Network
/datum/scp_network_hub
	var/name = "SCP Network Hub"
	var/list/connected_scps = list()
	var/list/network_logs = list()
	var/max_log_entries = 1000
	var/network_enabled = TRUE

/datum/scp_network_hub/proc/register_scp(mob/scp_mob)
	if(!scp_mob || !scp_mob.SCP)
		return FALSE

	if(!(scp_mob in connected_scps))
		connected_scps += scp_mob
		log_network_event("SCP_CONNECTED", "[scp_mob.SCP.designation] connected to network")
		return TRUE

	return FALSE

/datum/scp_network_hub/proc/unregister_scp(mob/scp_mob)
	if(scp_mob in connected_scps)
		connected_scps -= scp_mob
		log_network_event("SCP_DISCONNECTED", "[scp_mob.SCP.designation] disconnected from network")

/datum/scp_network_hub/proc/broadcast_to_network(mob/sender, message_data, scp_class_filter = null)
	if(!network_enabled || !sender)
		return FALSE

	for(var/mob/scp_mob in connected_scps)
		if(scp_mob == sender)
			continue

		if(scp_class_filter && scp_mob.SCP.classification != scp_class_filter)
			continue

		if(scp_mob.SCP && scp_mob.SCP.uses_advanced_components)
			var/datum/component_manager_advanced/manager = scp_mob.SCP.advanced_components
			if(manager && manager.communicator)
				manager.communicator.broadcast_message(null, message_data, "scp_network")

/datum/scp_network_hub/proc/log_network_event(event_type, description)
	var/log_entry = list(
		"timestamp" = world.time,
		"type" = event_type,
		"description" = description
	)

	network_logs += list(log_entry)

	// Maintain log size
	if(length(network_logs) > max_log_entries)
		network_logs.Cut(1, length(network_logs) - max_log_entries + 1)

// Global SCP Network Hub Instance
var/global/datum/scp_network_hub/GLOB_SCP_NETWORK = new /datum/scp_network_hub()
