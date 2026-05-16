#define DOOR_CONTROL_NONE 0
#define DOOR_CONTROL_LOCKED 1
#define DOOR_CONTROL_OPEN 2
#define DOOR_CONTROL_BOLTED 3

/obj/machinery/computer/scp_door_control
	name = "SCP Door Control Console"
	desc = "A secure console for controlling doors and airlocks across SCP containment zones."
	icon = 'icons/obj/computer.dmi'
	icon_state = "security"
	req_access = list(ACCESS_SECURITY)
	density = TRUE
	anchored = TRUE
	circuit = /obj/item/circuitboard/computer/scp_door_control

	var/list/zone_states = list(
		"Light Containment" = DOOR_CONTROL_NONE,
		"Heavy Containment" = DOOR_CONTROL_NONE,
		"Entrance Zone" = DOOR_CONTROL_NONE,
		"D-Class Block" = DOOR_CONTROL_NONE,
		"Surface" = DOOR_CONTROL_NONE,
	)
	var/list/door_log = list()
	var/max_log_entries = 50
	var/list/scp_area_types = list(/area/scp/lcz, /area/scp/hcz, /area/scp/ez, /area/scp/dclass, /area/scp/surface)
	var/list/cached_scp_areas
	var/area_cache_time = 0
	var/area_cache_interval = 30 SECONDS
	var/cached_total_doors = 0
	var/cached_locked_doors = 0
	var/door_cache_time = 0
	var/door_cache_interval = 5 SECONDS

/obj/machinery/computer/scp_door_control/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SCPDoorControl")
		ui.open()

/obj/machinery/computer/scp_door_control/ui_data(mob/user)
	var/list/data = list()
	data["zone_states"] = list()
	for(var/zone in zone_states)
		data["zone_states"] += list(list(
			"name" = zone,
			"state" = zone_states[zone],
			"state_name" = door_state_name(zone_states[zone]),
		))
	data["door_log"] = list()
	var/log_count = 0
	for(var/i = length(door_log); i >= max(1, length(door_log) - 20); i--)
		var/list/entry = door_log[i]
		data["door_log"] += list(entry)
		log_count++
		if(log_count >= 20)
			break
	data["total_doors"] = 0
	data["locked_doors"] = 0
	if(world.time >= door_cache_time + door_cache_interval)
		var/list/all_doors = get_all_controllable_doors()
		cached_total_doors = length(all_doors)
		cached_locked_doors = 0
		for(var/obj/machinery/door/D in all_doors)
			if(D.locked)
				cached_locked_doors++
		door_cache_time = world.time
	data["total_doors"] = cached_total_doors
	data["locked_doors"] = cached_locked_doors
	return data

/obj/machinery/computer/scp_door_control/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("set_zone_state")
			var/zone = params["zone"]
			var/new_state = text2num(params["state"])
			if(zone in zone_states)
				zone_states[zone] = new_state
				apply_zone_state(zone, new_state, usr)
				log_door_action("[usr] set [zone] to [door_state_name(new_state)]")
				return TRUE
		if("emergency_open_all")
			emergency_open_all()
			log_door_action("[usr] triggered EMERGENCY OPEN ALL")
			return TRUE
		if("emergency_lock_all")
			emergency_lock_all()
			log_door_action("[usr] triggered EMERGENCY LOCK ALL")
			return TRUE
		if("cycle_airlock")
			var/area_name = params["zone"]
			cycle_zone_airlocks(area_name)
			log_door_action("[usr] cycled airlocks in [area_name]")
			return TRUE

/obj/machinery/computer/scp_door_control/proc/door_state_name(state)
	switch(state)
		if(DOOR_CONTROL_NONE)
			return "Normal"
		if(DOOR_CONTROL_LOCKED)
			return "Locked"
		if(DOOR_CONTROL_OPEN)
			return "Forced Open"
		if(DOOR_CONTROL_BOLTED)
			return "Bolted"
	return "Unknown"

/obj/machinery/computer/scp_door_control/proc/get_scp_areas()
	if(!cached_scp_areas || world.time >= area_cache_time + area_cache_interval)
		cached_scp_areas = list()
		for(var/area_type in scp_area_types)
			for(var/area/A in world)
				if(istype(A, area_type))
					cached_scp_areas += A
		area_cache_time = world.time
	return cached_scp_areas

/obj/machinery/computer/scp_door_control/proc/get_all_controllable_doors()
	. = list()
	for(var/area/A in get_scp_areas())
		for(var/obj/machinery/door/airlock/D in A.contents)
			. += D

/obj/machinery/computer/scp_door_control/proc/apply_zone_state(zone, state, mob/user)
	var/area/zone_type = zone_to_area_type(zone)
	if(!zone_type)
		return
	for(var/area/A in get_scp_areas())
		if(!istype(A, zone_type))
			continue
		for(var/obj/machinery/door/airlock/D in A.contents)
			switch(state)
				if(DOOR_CONTROL_NONE)
					D.unlock()
				if(DOOR_CONTROL_LOCKED)
					D.lock()
					D.close()
				if(DOOR_CONTROL_OPEN)
					D.unlock()
					D.open()
				if(DOOR_CONTROL_BOLTED)
					D.lock()
					D.close()

/obj/machinery/computer/scp_door_control/proc/zone_to_area_type(zone)
	switch(zone)
		if("Light Containment")
			return /area/scp/lcz
		if("Heavy Containment")
			return /area/scp/hcz
		if("Entrance Zone")
			return /area/scp/ez
		if("D-Class Block")
			return /area/scp/dclass
		if("Surface")
			return /area/scp/surface
	return null

/obj/machinery/computer/scp_door_control/proc/is_door_in_zone(area/door_area, zone)
	return istype(door_area, zone_to_area_type(zone))

/obj/machinery/computer/scp_door_control/proc/emergency_open_all()
	for(var/obj/machinery/door/airlock/A in get_all_controllable_doors())
		A.unlock()
		A.open()

/obj/machinery/computer/scp_door_control/proc/emergency_lock_all()
	for(var/obj/machinery/door/airlock/A in get_all_controllable_doors())
		A.lock()
		A.close()

/obj/machinery/computer/scp_door_control/proc/cycle_zone_airlocks(zone)
	var/area/zone_type = zone_to_area_type(zone)
	if(!zone_type)
		return
	for(var/area/A in get_scp_areas())
		if(!istype(A, zone_type))
			continue
		for(var/obj/machinery/door/airlock/D in A.contents)
			if(D.density)
				D.open()
				addtimer(CALLBACK(D, /obj/machinery/door/proc/close), 50)
			else
				D.close()
				addtimer(CALLBACK(D, /obj/machinery/door/proc/open), 50)

/obj/machinery/computer/scp_door_control/proc/log_door_action(action_text)
	door_log += list(list("text" = action_text, "time" = time2text(world.time, "HH:MM:SS")))
	if(length(door_log) > max_log_entries)
		door_log.Cut(1, 2)

/obj/machinery/computer/scp_door_control/ui_state(mob/user)
	return GLOB.default_state

/obj/item/circuitboard/computer/scp_door_control
	name = "SCP Door Control Console (Computer Board)"
	build_path = /obj/machinery/computer/scp_door_control
