#define NETWORK_NODE_OFFLINE 0
#define NETWORK_NODE_ONLINE 1
#define NETWORK_NODE_DEGRADED 2
#define NETWORK_NODE_COMPROMISED 3

/datum/network_node
	var/node_id = ""
	var/node_name = ""
	var/area_name = ""
	var/status = NETWORK_NODE_ONLINE
	var/integrity = 100
	var/power_draw = 50
	var/last_maintenance = 0
	var/scp079_influence = 0
	var/list/connected_nodes = list()

/datum/network_node/New(name, area)
	node_id = "NODE-[world.time]-[rand(10,99)]"
	node_name = name
	area_name = area

/datum/network_node/proc/degrade(amount)
	integrity = max(0, integrity - amount)
	if(integrity <= 0)
		status = NETWORK_NODE_OFFLINE
	else if(integrity < 50)
		status = NETWORK_NODE_DEGRADED
	else if(scp079_influence > 50)
		status = NETWORK_NODE_COMPROMISED

/datum/network_node/proc/repair(amount)
	integrity = min(100, integrity + amount)
	last_maintenance = world.time
	scp079_influence = max(0, scp079_influence - amount * 0.5)
	if(integrity >= 50)
		if(scp079_influence <= 50)
			status = NETWORK_NODE_ONLINE
		else
			status = NETWORK_NODE_COMPROMISED

/datum/network_node/proc/get_status_text()
	switch(status)
		if(NETWORK_NODE_OFFLINE)
			return "Offline"
		if(NETWORK_NODE_ONLINE)
			return "Online"
		if(NETWORK_NODE_DEGRADED)
			return "Degraded"
		if(NETWORK_NODE_COMPROMISED)
			return "Compromised"

/datum/network_node/proc/apply_scp079_influence(amount)
	scp079_influence = min(100, scp079_influence + amount)
	if(scp079_influence > 50)
		status = NETWORK_NODE_COMPROMISED

/datum/server_rack
	var/rack_id = ""
	var/rack_name = ""
	var/area_name = ""
	var/temperature = 20
	var/optimal_temperature = 20
	var/cpu_usage = 0
	var/memory_usage = 0
	var/storage_usage = 0
	var/maintenance_required = FALSE
	var/last_maintenance = 0
	var/firewall_strength = 100
	var/list/running_services = list()

/datum/server_rack/New(name, area)
	rack_id = "RACK-[world.time]-[rand(10,99)]"
	rack_name = name
	area_name = area
	var/list/default_services = list(
		"Database Query Service",
		"Authentication Service",
		"File Storage Service",
		"Network Routing Service",
	)
	running_services = default_services.Copy()
	cpu_usage = rand(20, 45)
	memory_usage = rand(30, 60)
	storage_usage = rand(15, 40)

/datum/server_rack/proc/tick()
	temperature += rand(-1, 2)
	if(temperature > 35)
		maintenance_required = TRUE
		firewall_strength = max(0, firewall_strength - 1)
	if(world.time > last_maintenance + 20 MINUTES)
		maintenance_required = TRUE
		firewall_strength = max(0, firewall_strength - 0.5)
	cpu_usage = clamp(cpu_usage + rand(-3, 5), 5, 100)
	memory_usage = clamp(memory_usage + rand(-2, 4), 10, 100)
	storage_usage = clamp(storage_usage + rand(0, 1), 0, 95)
	if(maintenance_required)
		cpu_usage = min(100, cpu_usage + 5)
		memory_usage = min(100, memory_usage + 3)
	if(cpu_usage > 90 || memory_usage > 90)
		firewall_strength = max(0, firewall_strength - 2)
	if(prob(5) && !maintenance_required)
		running_services += "Backup Service [world.time]"
	if(length(running_services) > 8)
		running_services.Cut(1, 2)

/datum/server_rack/proc/maintain()
	temperature = optimal_temperature
	last_maintenance = world.time
	maintenance_required = FALSE
	firewall_strength = min(100, firewall_strength + 20)
	cpu_usage = max(15, cpu_usage - 20)
	memory_usage = max(20, memory_usage - 15)
	storage_usage = max(10, storage_usage - 5)

/datum/server_rack/proc/reboot_firewall()
	firewall_strength = 100
	cpu_usage = min(100, cpu_usage + 30)

/datum/server_rack/proc/block_scp079()
	if(firewall_strength < 30)
		return FALSE
	firewall_strength = max(0, firewall_strength - 25)
	return TRUE

SUBSYSTEM_DEF(it_network)
	name = "IT Network"
	wait = 10 SECONDS
	priority = FIRE_PRIORITY_DEFAULT
	var/list/datum/network_node/nodes = list()
	var/list/datum/server_rack/server_racks = list()
	var/overall_integrity = 100
	var/scp079_network_presence = 0
	var/last_network_scan = 0

/datum/controller/subsystem/it_network/Initialize(start_timeofday)
	. = ..()
	setup_network()

/datum/controller/subsystem/it_network/proc/setup_network()
	var/list/areas = list(
		"Command Server Room",
		"Research Server Room",
		"Security Network Hub",
		"Medical Data Center",
		"Engineering Network Node",
		"LCZ Network Access",
		"HCZ Network Access",
		"Surface Communications",
	)
	for(var/name in areas)
		var/datum/network_node/N = new(name, name)
		nodes += N
	for(var/i in 1 to length(nodes))
		var/datum/network_node/N = nodes[i]
		var/prev_idx = ((i - 2 + length(nodes)) % length(nodes)) + 1
		var/next_idx = (i % length(nodes)) + 1
		N.connected_nodes += nodes[prev_idx]
		N.connected_nodes += nodes[next_idx]
		if(i <= 4)
			var/cross_idx = rand(1, length(nodes))
			if(cross_idx != i && !(nodes[cross_idx] in N.connected_nodes))
				N.connected_nodes += nodes[cross_idx]
	var/list/racks = list(
		"Primary Server Rack" = "Command Server Room",
		"Research Database Rack" = "Research Server Room",
		"Security Records Rack" = "Security Network Hub",
		"Medical Database Rack" = "Medical Data Center",
	)
	for(var/name in racks)
		var/datum/server_rack/R = new(name, racks[name])
		server_racks += R

/datum/controller/subsystem/it_network/fire()
	var/total_integrity = 0
	for(var/datum/network_node/N in nodes)
		if(world.time > N.last_maintenance + 15 MINUTES && N.integrity > 0)
			N.degrade(1)
		total_integrity += N.integrity
		if(scp079_network_presence > 30 && prob(scp079_network_presence / 10))
			N.apply_scp079_influence(5)
	for(var/datum/server_rack/R in server_racks)
		R.tick()
	overall_integrity = length(nodes) ? round(total_integrity / length(nodes)) : 0
	if(scp079_network_presence > 0)
		scp079_network_presence = max(0, scp079_network_presence - 0.2)

/datum/controller/subsystem/it_network/proc/repair_node(node_id, amount)
	for(var/datum/network_node/N in nodes)
		if(N.node_id == node_id)
			N.repair(amount)
			recalculate_integrity()
			return TRUE
	return FALSE

/datum/controller/subsystem/it_network/proc/maintain_rack(rack_id)
	for(var/datum/server_rack/R in server_racks)
		if(R.rack_id == rack_id)
			R.maintain()
			return TRUE
	return FALSE

/datum/controller/subsystem/it_network/proc/reboot_firewall(rack_id)
	for(var/datum/server_rack/R in server_racks)
		if(R.rack_id == rack_id)
			R.reboot_firewall()
			return TRUE
	return FALSE

/datum/controller/subsystem/it_network/proc/counter_scp079()
	scp079_network_presence = max(0, scp079_network_presence - 30)
	for(var/datum/server_rack/R in server_racks)
		if(R.block_scp079())
			continue
	for(var/datum/network_node/N in nodes)
		N.scp079_influence = max(0, N.scp079_influence - 20)
		if(N.scp079_influence <= 50 && N.integrity >= 50)
			N.status = NETWORK_NODE_ONLINE
	recalculate_integrity()

/datum/controller/subsystem/it_network/proc/recalculate_integrity()
	var/total = 0
	for(var/datum/network_node/N in nodes)
		total += N.integrity
	overall_integrity = length(nodes) ? round(total / length(nodes)) : 0

/datum/controller/subsystem/it_network/proc/run_network_scan()
	last_network_scan = world.time
	var/list/results = list()
	for(var/datum/network_node/N in nodes)
		results += list(list(
			"name" = N.node_name,
			"status" = N.get_status_text(),
			"integrity" = N.integrity,
			"scp079" = N.scp079_influence,
		))
	return results


