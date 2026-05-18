/obj/item/paper/death_certificate
	name = "Death Certificate"
	desc = "An official Foundation death certificate."
	icon_state = "paper"

/obj/item/paper/death_certificate/proc/generate_certificate(mob/living/carbon/human/H, cause, time_of_death)
	if(!H)
		return

	var/cert_text = {"
		<center><b>SCP FOUNDATION — DEATH CERTIFICATE</b></center>
		<hr>
		<b>Decedent:</b> [H.real_name]<br>
		<b>Position:</b> [H.job || "Unknown"]<br>
		<b>Blood Type:</b> [H.dna?.blood_type || "Unknown"]<br>
		<b>Time of Death:</b> [time_of_death || gameTimestamp("hh:mm")]<br>
		<b>Location:</b> [get_area_name(H, TRUE) || "Unknown"]<br>
		<b>Cause of Death:</b> [cause || "Pending Autopsy"]<br>
		<br>
		<b>Circumstances:</b> [cause == "Pending Autopsy" ? "Autopsy required." : "See attached report."]<br>
		<br>
		<b>Coroner:</b> ________________<br>
		<b>Witness:</b> ________________<br>
		<b>Date:</b> [time2text(world.realtime, "YYYY-MM-DD")]<br>
		<hr>
		<center><i>This document is classified under Foundation Protocol 4000-Alpha.<br>Unauthorized distribution is grounds for immediate termination.</i></center>
	"}

	info = cert_text
	name = "Death Certificate — [H.real_name]"

/obj/structure/bodybag_rack
	name = "body bag rack"
	desc = "A rack for storing body bags."
	icon = 'icons/obj/storage.dmi'
	icon_state = "safe"
	anchored = TRUE
	density = FALSE
	var/max_bags = 5
	var/list/stored_bags = list()

/obj/structure/bodybag_rack/examine(mob/user)
	. = ..()
	. += "It contains [length(stored_bags)]/[max_bags] body bags."

/obj/structure/bodybag_rack/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/bodybag))
		if(length(stored_bags) >= max_bags)
			to_chat(user, span_warning("The rack is full!"))
			return
		stored_bags += I
		I.forceMove(src)
		to_chat(user, span_notice("You place [I] on the rack."))
		return
	if(I.tool_behaviour == TOOL_WRENCH)
		to_chat(user, span_notice("You [anchored ? "unsecure" : "secure"] [src]."))
		anchored = !anchored
		I.play_tool_sound(src)
		return
	return ..()

/obj/structure/bodybag_rack/attack_hand(mob/user)
	if(!length(stored_bags))
		to_chat(user, span_warning("The rack is empty!"))
		return

	var/obj/item/bodybag/B = stored_bags[length(stored_bags)]
	stored_bags -= B
	B.forceMove(get_turf(user))
	user.put_in_hands(B)
	to_chat(user, span_notice("You take [B] from the rack."))

/obj/machinery/computer/morgue_console
	name = "Morgue Management Console"
	desc = "A console for managing morgue records and issuing death certificates."
	icon_screen = "medcomp"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/computer/morgue_console

/obj/machinery/computer/morgue_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MorgueConsole", "Morgue Management")
		ui.open()

/obj/machinery/computer/morgue_console/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/morgue_console/ui_data(mob/user)
	var/list/data = list()
	var/list/bodies = list()

	for(var/mob/living/carbon/human/H in GLOB.mob_living_list)
		if(H.stat != DEAD)
			continue
		if(!is_station_level(H.z))
			continue
		bodies += list(list(
			"name" = H.real_name,
			"job" = H.job || "Unknown",
			"location" = get_area_name(H, TRUE) || "Unknown",
			"ref" = REF(H),
			"time_of_death" = gameTimestamp("hh:mm"),
			"has_certificate" = FALSE
		))

	data["bodies"] = bodies
	return data

/obj/machinery/computer/morgue_console/ui_act(action, params)
	. = ..()
	if(.)
		return

	if(action == "issue_certificate")
		var/mob/living/carbon/human/H = locate(params["ref"]) in GLOB.mob_living_list
		if(!H || H.stat != DEAD)
			return

		var/cause = params["cause"] || "Pending Autopsy"
		var/obj/item/paper/death_certificate/cert = new(get_turf(src))
		cert.generate_certificate(H, cause)
		visible_message(span_notice("[src] prints a death certificate for [H.real_name]."))
		playsound(loc, 'sound/machines/printer.ogg', 50, TRUE)

		if(GLOB.scp_admin_log)
			GLOB.scp_admin_log.log_event("death_cert", "N/A", usr?.ckey || "N/A", H.real_name, "Death certificate issued: [cause]", 2)

		return TRUE

/obj/item/circuitboard/computer/morgue_console
	name = "Morgue Management Console (Computer Board)"
	build_path = /obj/machinery/computer/morgue_console
