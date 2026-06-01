GLOBAL_LIST_EMPTY(zone_lighting_controllers)

/proc/init_zone_lighting_controllers()
	GLOB.zone_lighting_controllers = list()
	GLOB.zone_lighting_controllers["lcz"] = new /datum/zone_lighting_controller/lcz("lcz")
	GLOB.zone_lighting_controllers["hcz"] = new /datum/zone_lighting_controller/hcz("hcz")
	GLOB.zone_lighting_controllers["ez"] = new /datum/zone_lighting_controller/entrance("ez")
	GLOB.zone_lighting_controllers["surface"] = new /datum/zone_lighting_controller("surface")

/proc/get_zone_lighting_controller(zone_id)
	if(!GLOB.zone_lighting_controllers)
		GLOB.zone_lighting_controllers = list()
	if(!GLOB.zone_lighting_controllers[zone_id])
		switch(zone_id)
			if("lcz")
				GLOB.zone_lighting_controllers[zone_id] = new /datum/zone_lighting_controller/lcz(zone_id)
			if("hcz")
				GLOB.zone_lighting_controllers[zone_id] = new /datum/zone_lighting_controller/hcz(zone_id)
			if("ez")
				GLOB.zone_lighting_controllers[zone_id] = new /datum/zone_lighting_controller/entrance(zone_id)
			else
				GLOB.zone_lighting_controllers[zone_id] = new /datum/zone_lighting_controller(zone_id)
	return GLOB.zone_lighting_controllers[zone_id]

/proc/trigger_zone_breach_lighting(zone_id)
	QDEL_NULL(GLOB.zone_lighting_controllers[zone_id])
	GLOB.zone_lighting_controllers[zone_id] = new /datum/zone_lighting_controller/breach(zone_id)
	SEND_GLOBAL_SIGNAL(COMSIG_SCP_BREACH, zone_id)

/proc/restore_zone_lighting(zone_id)
	QDEL_NULL(GLOB.zone_lighting_controllers[zone_id])
	switch(zone_id)
		if("lcz")
			GLOB.zone_lighting_controllers[zone_id] = new /datum/zone_lighting_controller/lcz(zone_id)
		if("hcz")
			GLOB.zone_lighting_controllers[zone_id] = new /datum/zone_lighting_controller/hcz(zone_id)
		if("ez")
			GLOB.zone_lighting_controllers[zone_id] = new /datum/zone_lighting_controller/entrance(zone_id)
		else
			GLOB.zone_lighting_controllers[zone_id] = new /datum/zone_lighting_controller(zone_id)
	var/datum/zone_lighting_controller/controller = GLOB.zone_lighting_controllers[zone_id]
	controller.apply_color_to_lights()
	SEND_GLOBAL_SIGNAL(COMSIG_SCP_RECONTAINED, zone_id)

/proc/conditional_restore_zone_lighting(zone_id, scp_id)
	if(!SSscp_persistence?.manager)
		restore_zone_lighting(zone_id)
		return
	var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances[scp_id]
	if(!instance || instance.containment_status != "breached")
		restore_zone_lighting(zone_id)
