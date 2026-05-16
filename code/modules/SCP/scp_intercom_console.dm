/obj/machinery/computer/scp_intercom_console
	name = "SCP Intercom Console"
	desc = "A secure console for broadcasting messages across the facility's intercom and PA system."
	icon = 'icons/obj/computer.dmi'
	icon_state = "comm"
	req_access = list(ACCESS_SECURITY)
	density = TRUE
	anchored = TRUE
	circuit = /obj/item/circuitboard/computer/scp_intercom_console

	var/selected_zone = "Facility-Wide"
	var/broadcast_cooldown = 0
	var/list/broadcast_history = list()
	var/max_history = 30

/obj/machinery/computer/scp_intercom_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SCPIntercomConsole")
		ui.open()

/obj/machinery/computer/scp_intercom_console/ui_data(mob/user)
	var/list/data = list()
	data["selected_zone"] = selected_zone
	data["cooldown_remaining"] = max(0, broadcast_cooldown - world.time)
	data["zones"] = list("Facility-Wide", "Light Containment", "Heavy Containment", "Entrance Zone", "D-Class Block", "Surface")
	data["emergency_types"] = list(
		list("id" = "breach", "name" = "Containment Breach"),
		list("id" = "biohazard", "name" = "Biohazard"),
		list("id" = "power", "name" = "Power Failure"),
		list("id" = "dclass", "name" = "D-Class Incident"),
		list("id" = "evacuation", "name" = "Evacuation"),
	)
	data["history"] = list()
	var/hist_count = 0
	for(var/i = length(broadcast_history); i >= max(1, length(broadcast_history) - 15); i--)
		data["history"] += list(broadcast_history[i])
		hist_count++
		if(hist_count >= 15)
			break
	return data

/obj/machinery/computer/scp_intercom_console/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("set_zone")
			selected_zone = params["zone"]
			return TRUE
		if("broadcast")
			if(world.time < broadcast_cooldown)
				return
			var/message = params["message"]
			if(!message)
				return
			broadcast_message(message, selected_zone, usr)
			broadcast_cooldown = world.time + 300
			return TRUE
		if("emergency")
			if(world.time < broadcast_cooldown)
				return
			var/emergency_type = params["type"]
			broadcast_emergency(emergency_type, selected_zone, usr)
			broadcast_cooldown = world.time + 600
			return TRUE

/obj/machinery/computer/scp_intercom_console/proc/broadcast_message(message, zone, mob/user)
	var/broadcast_text = "<span class='boldannounce'>[zone] Announcement:</span> [html_encode(message)]"
	var/list/target_area_types = get_zone_area_types(zone)

	for(var/mob/M in GLOB.mob_list)
		if(QDELETED(M))
			continue
		if(!M.client)
			continue
		var/area/mob_area = get_area(M)
		if(zone == "Facility-Wide")
			to_chat(M, broadcast_text)
		else if(mob_area)
			var/matches_zone = FALSE
			for(var/T in target_area_types)
				if(istype(mob_area, T))
					matches_zone = TRUE
					break
			if(matches_zone)
				to_chat(M, broadcast_text)

	log_broadcast("[user] broadcast to [zone]: [message]")

/obj/machinery/computer/scp_intercom_console/proc/broadcast_emergency(emergency_type, zone, mob/user)
	var/emergency_text
	switch(emergency_type)
		if("breach")
			emergency_text = "CONTAINMENT BREACH DETECTED. ALL PERSONNEL PROCEED TO NEAREST SAFE ZONE. SECURITY RESPONSE TEAMS DEPLOY."
		if("biohazard")
			emergency_text = "BIOHAZARD ALERT. HAZMAT PROTOCOLS IN EFFECT. ALL PERSONNEL DON PROTECTIVE GEAR."
		if("power")
			emergency_text = "POWER FAILURE DETECTED. EMERGENCY POWER ACTIVE. ENGINEERING RESPOND IMMEDIATELY."
		if("dclass")
			emergency_text = "D-CLASS INCIDENT IN PROGRESS. SECURITY PERSONNEL RESPOND. ALL D-CLASS RETURN TO DESIGNATED AREAS."
		if("evacuation")
			emergency_text = "EVACUATION ORDER. ALL NON-ESSENTIAL PERSONNEL PROCEED TO SURFACE EXIT IMMEDIATELY."

	if(!emergency_text)
		return

	var/broadcast_text = "<span class='userdanger'>[zone] EMERGENCY: [emergency_text]</span>"
	var/list/target_area_types = get_zone_area_types(zone)

	for(var/mob/M in GLOB.mob_list)
		if(QDELETED(M))
			continue
		if(!M.client)
			continue
		var/area/mob_area = get_area(M)
		if(zone == "Facility-Wide")
			to_chat(M, broadcast_text)
		else if(mob_area)
			var/matches_zone = FALSE
			for(var/T in target_area_types)
				if(istype(mob_area, T))
					matches_zone = TRUE
					break
			if(matches_zone)
				to_chat(M, broadcast_text)

	log_broadcast("[user] triggered [emergency_type] emergency in [zone]")

/obj/machinery/computer/scp_intercom_console/proc/get_zone_area_types(zone)
	. = list()
	switch(zone)
		if("Light Containment")
			. += /area/scp/lcz
		if("Heavy Containment")
			. += /area/scp/hcz
		if("Entrance Zone")
			. += /area/scp/ez
		if("D-Class Block")
			. += /area/scp/dclass
		if("Surface")
			. += /area/scp/surface
		if("Facility-Wide")
			. += /area/scp

/obj/machinery/computer/scp_intercom_console/proc/log_broadcast(text)
	broadcast_history += list(list("text" = text, "time" = time2text(world.time, "HH:MM:SS")))
	if(length(broadcast_history) > max_history)
		broadcast_history.Cut(1, 2)

/obj/machinery/computer/scp_intercom_console/ui_state(mob/user)
	return GLOB.default_state

/obj/item/circuitboard/computer/scp_intercom_console
	name = "SCP Intercom Console (Computer Board)"
	build_path = /obj/machinery/computer/scp_intercom_console
