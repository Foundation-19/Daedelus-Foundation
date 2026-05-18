/obj/machinery/facility_pa
	name = "Facility PA System"
	desc = "A public address system for facility-wide or zone-specific announcements."
	icon = 'icons/obj/radio.dmi'
	icon_state = "intercom"
	density = FALSE
	anchored = TRUE
	circuit = /obj/item/circuitboard/facility_pa
	var/selected_zone = "all"
	var/announcement_cooldown = 0
	var/announcement_cooldown_duration = 200
	var/list/zone_options = list(
		"all" = "All Zones",
		"lcz" = "Light Containment",
		"hcz" = "Heavy Containment",
		"ez" = "Entrance Zone",
		"surface" = "Surface",
		"dclass" = "D-Class Block",
		"medical" = "Medical",
		"engineering" = "Engineering",
		"security" = "Security",
	)
	var/last_announcement = ""
	var/list/announcement_log = list()

/obj/machinery/facility_pa/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FacilityPA", "Facility PA System")
		ui.open()

/obj/machinery/facility_pa/ui_data(mob/user)
	var/list/data = list()
	data["selected_zone"] = selected_zone
	data["cooldown"] = announcement_cooldown
	data["cooldown_max"] = announcement_cooldown_duration
	data["last_announcement"] = last_announcement
	data["can_announce"] = announcement_cooldown <= 0
	data["is_command"] = FALSE

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/datum/job/J = SSjob.GetJob(H.job)
		if(J)
			var/list/departments = list("Command", "Security", "Foundation Command")
			for(var/dept in departments)
				if(findtext(J.title, dept) || J.title in list("Site Director", "Head of Personnel", "Chief Medical Officer", "Research Director", "Chief Engineer", "Head of Security"))
					data["is_command"] = TRUE
					break

	data["zones"] = list()
	for(var/zone_key in zone_options)
		data["zones"] += list(list(
			"key" = zone_key,
			"name" = zone_options[zone_key],
			"selected" = zone_key == selected_zone,
		))

	data["announcement_log"] = announcement_log

	return data

/obj/machinery/facility_pa/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = usr

	switch(action)
		if("select_zone")
			var/zone = params["zone"]
			if(zone in zone_options)
				selected_zone = zone
			. = TRUE

		if("make_announcement")
			if(announcement_cooldown > 0)
				return

			var/message = params["message"]
			if(!message || length(message) < 2 || length(message) > 300)
				return

			make_announcement(user, message)
			. = TRUE

/obj/machinery/facility_pa/proc/make_announcement(mob/user, message)
	announcement_cooldown = announcement_cooldown_duration
	last_announcement = message

	var/zone_name = zone_options[selected_zone] || "All Zones"
	var/sender_name = "Unknown"
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		sender_name = H.job ? "[H.job] [H.real_name]" : H.real_name

	var/announcement_text = "[zone_name] Announcement from [sender_name]: [message]"

	announcement_log += list(list(
		"sender" = sender_name,
		"zone" = zone_name,
		"message" = message,
		"time" = gameTimestamp("hh:mm"),
	))

	if(selected_zone == "all")
		priority_announce(announcement_text, "Facility PA", null, ANNOUNCER_ALERT)
	else
		for(var/mob/living/carbon/human/H in GLOB.mob_living_list)
			if(H.stat == DEAD || !H.client)
				continue
			var/area/A = get_area(H)
			if(!A)
				continue
			if(check_zone_match(A, selected_zone))
				to_chat(H, "<span class='notice'><b>[zone_name] PA:</b> [message]</span>")

	playsound(src, 'sound/misc/announce.ogg', 40, TRUE)

/obj/machinery/facility_pa/proc/check_zone_match(area/A, zone)
	if(!A)
		return FALSE
	switch(zone)
		if("lcz")
			return istype(A, /area/scp/lcz)
		if("hcz")
			return istype(A, /area/scp/hcz)
		if("ez")
			return istype(A, /area/scp/ez)
		if("surface")
			return istype(A, /area/scp/surface)
		if("dclass")
			return istype(A, /area/scp/dclass)
		if("medical")
			return istype(A, /area/medical)
		if("engineering")
			return istype(A, /area/engineering)
		if("security")
			return istype(A, /area/security)
	return FALSE

/obj/machinery/facility_pa/process()
	if(announcement_cooldown > 0)
		announcement_cooldown -= 20

/obj/item/circuitboard/facility_pa
	name = "Facility PA (Circuit Board)"
	build_path = /obj/machinery/facility_pa
