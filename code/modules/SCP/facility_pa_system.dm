// Facility-wide PA/Intercom System
// Unified SCP-themed public address system with zone-specific pages and command announcements

/obj/machinery/facility_pa
	name = "Facility PA System"
	desc = "A facility-wide public address system for broadcasting messages to specific zones or the entire facility."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50

	var/announcement_cooldown = 0
	var/announcement_cooldown_time = 30 SECONDS
	var/last_announcement = ""
	var/announcement_count = 0

/obj/machinery/facility_pa/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card)
		to_chat(H, "<span class='warning'>ID card required.</span>")
		return

	var/has_access = (ACCESS_ADMIN in id_card.access) || (ACCESS_SECURITY in id_card.access)
	if(!has_access)
		to_chat(H, "<span class='warning'>Requires Command or Security access to use the PA system.</span>")
		return

	if(world.time < announcement_cooldown)
		to_chat(H, "<span class='warning'>PA system recharging. Available in [DisplayTimeText(announcement_cooldown - world.time)].</span>")
		return

	var/list/zone_options = list(
		"Facility-Wide" = null,
		"Light Containment Zone" = /area/scp/lcz,
		"Heavy Containment Zone" = /area/scp/hcz,
		"Entrance Zone" = /area/scp/ez,
		"D-Class Block" = /area/scp/dclass,
		"Surface" = /area/scp/surface,
	)

	var/zone_choice = input(H, "Select broadcast zone:", "Facility PA") as null|anything in zone_options
	if(!zone_choice)
		return

	var/message = input(H, "Enter PA announcement:", "Facility PA") as text|null
	if(!message)
		return

	var/target_area_type = zone_options[zone_choice]
	broadcast_pa_message(message, H, zone_choice, target_area_type)

/obj/machinery/facility_pa/proc/broadcast_pa_message(message, mob/sender, zone_name, area_type)
	announcement_cooldown = world.time + announcement_cooldown_time
	last_announcement = message
	announcement_count++

	var/header = "FACILITY PA - [zone_name]"
	var/formatted = "<h2 class='alert'>[html_encode(header)]</h2><br><span style='font-size:120%'>[span_alert("[html_encode(message)]")]</span>"

	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.stat == DEAD || !H.client)
			continue

		if(area_type)
			var/area/A = get_area(H)
			if(!istype(A, area_type))
				continue

		to_chat(H, formatted)

	log_say("[key_name(sender)] made a PA announcement to [zone_name]: [message]")

// Pre-recorded emergency announcements
/obj/machinery/facility_pa/proc/broadcast_emergency(emergency_type)
	switch(emergency_type)
		if("containment_breach")
			broadcast_pa_message("CONTAINMENT BREACH DETECTED. ALL SECURITY PERSONNEL RESPOND IMMEDIATELY. RESEARCH PERSONNEL SHELTER IN PLACE.", null, "Facility-Wide", null)
		if("biohazard")
			broadcast_pa_message("BIOLOGICAL HAZARD DETECTED IN CONTAINMENT WING. DON PROTECTIVE EQUIPMENT. PROCEED TO QUARANTINE IF EXPOSED.", null, "Facility-Wide", null)
		if("power_failure")
			broadcast_pa_message("POWER GRID INSTABILITY DETECTED. BACKUP GENERATORS ENGAGING. ALL PERSONNEL SECURE WORKSTATIONS.", null, "Facility-Wide", null)
		if("dclass_incident")
			broadcast_pa_message("D-CLASS DISTURBANCE IN PROGRESS. SECURITY RESPOND TO D-CLASS BLOCK. ALL OTHER PERSONNEL AVOID THE AREA.", null, "Facility-Wide", null)
		if("evacuation")
			broadcast_pa_message("EVACUATION ORDER. ALL NON-ESSENTIAL PERSONNEL PROCEED TO NEAREST EXIT. MTF PERSONNEL MAINTAIN POSTS.", null, "Facility-Wide", null)

// Zone-specific intercom
/obj/item/radio/intercom/scp_facility
	name = "facility intercom"
	desc = "A facility intercom tuned to SCP Foundation channels."
	icon = 'icons/obj/radio.dmi'
	icon_state = "intercom"
	freqlock = TRUE

/obj/item/radio/intercom/scp_facility/Initialize(mapload, ndir, building)
	. = ..()
	set_frequency(FREQ_SCP_COMMAND)

/obj/item/scp_radio_jammer
	name = "anomalous signal jammer"
	desc = "A device that disrupts SCP Foundation radio frequencies within a certain range."
	icon = 'icons/obj/device.dmi'
	icon_state = "shield0"
	var/active = FALSE
	var/jam_range = 7
	var/battery = 100
	var/drain_rate = 1
	var/list/jammed_frequencies = list(FREQ_SCP_COMMAND, FREQ_SCP_SECURITY, FREQ_SCP_SCIENCE, FREQ_SCP_MEDICAL, FREQ_SCP_CONTAINMENT, FREQ_SCP_MTF)

/obj/item/scp_radio_jammer/attack_self(mob/user)
	active = !active
	if(active)
		to_chat(user, "<span class='notice'>Radio jammer activated. Foundation frequencies within [jam_range] meters will be disrupted.</span>")
		LAZYADD(GLOB.active_scp_jammers, src)
		START_PROCESSING(SSobj, src)
	else
		to_chat(user, "<span class='notice'>Radio jammer deactivated.</span>")
		LAZYREMOVE(GLOB.active_scp_jammers, src)
		STOP_PROCESSING(SSobj, src)

/obj/item/scp_radio_jammer/process()
	if(!active || battery <= 0)
		active = FALSE
		LAZYREMOVE(GLOB.active_scp_jammers, src)
		STOP_PROCESSING(SSobj, src)
		return

	battery -= drain_rate

/obj/item/scp_radio_jammer/proc/is_frequency_jammed(freq, turf/location)
	if(!active || battery <= 0)
		return FALSE
	if(!(freq in jammed_frequencies))
		return FALSE
	var/turf/T = get_turf(src)
	if(!T || !location)
		return FALSE
	return get_dist(T, location) <= jam_range
