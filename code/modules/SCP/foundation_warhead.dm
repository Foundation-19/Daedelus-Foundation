/obj/machinery/nuclearbomb/foundation
	name = "Foundation On-Site Warhead"
	desc = "A thermobaric on-site warhead controlled by the O5 Council. Last resort for catastrophic containment failure."
	icon_state = "nuclearbomb_base"
	anchored = TRUE
	proper_bomb = FALSE
	var/foundation_authorized = FALSE
	var/foundation_auth_code
	var/foundation_timer_seconds = 60
	var/foundation_minimum = 30
	var/foundation_maximum = 180

/obj/machinery/nuclearbomb/foundation/Initialize(mapload)
	. = ..()
	foundation_auth_code = "[rand(1000, 9999)]"

/obj/machinery/nuclearbomb/foundation/attack_hand(mob/user)
	if(!ishuman(user))
		return
	ui_interact(user)

/obj/machinery/nuclearbomb/foundation/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FoundationWarhead", name)
		ui.open()

/obj/machinery/nuclearbomb/foundation/ui_data(mob/user)
	var/list/data = list()
	data["armed"] = timing
	data["authorized"] = foundation_authorized
	data["detonating"] = exploding
	data["timer_set"] = foundation_timer_seconds
	data["minimum_timer"] = foundation_minimum
	data["maximum_timer"] = foundation_maximum
	if(detonation_timer)
		data["time_remaining"] = max(0, (detonation_timer - world.time) / 10)
	else
		data["time_remaining"] = 0
	return data

/obj/machinery/nuclearbomb/foundation/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/living/carbon/human/H = ui.user
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)

	switch(action)
		if("authorize")
			if(!id_card)
				to_chat(H, span_warning("ID card required."))
				return
			if(!(ACCESS_ADMIN in id_card.access))
				to_chat(H, span_warning("O5 authorization required."))
				return
			foundation_authorized = !foundation_authorized
			if(foundation_authorized)
				priority_announce("ON-SITE WARHEAD AUTHORIZATION DETECTED. AWAITING CONFIRMATION CODE.", null, null, 'sound/misc/notice1.ogg')
				log_game("[key_name(H)] authorized the Foundation on-site warhead.")
				message_admins("[ADMIN_LOOKUPFLW(H)] authorized the Foundation on-site warhead.")
			else
				priority_announce("On-site warhead authorization revoked.", null, null, 'sound/misc/notice1.ogg')
				if(timing)
					timer_set = 90
					timing = FALSE
					safety = TRUE
					detonation_timer = null
					update_appearance()
					STOP_PROCESSING(SSobj, src)
		if("confirm_code")
			if(!foundation_authorized)
				return
			var/code_input = params["code"]
			if(code_input == foundation_auth_code)
				timer_set = foundation_timer_seconds
				safety = FALSE
				yes_code = TRUE
				timing = TRUE
				detonation_timer = world.time + (timer_set * 10)
				priority_announce("ON-SITE WARHEAD ARMED. DETONATION IN [timer_set] SECONDS. ALL PERSONNEL EVACUATE IMMEDIATELY.", null, null, 'sound/misc/airraid.ogg')
				log_game("[key_name(H)] confirmed the Foundation on-site warhead. Detonation in [timer_set] seconds.")
				message_admins("[ADMIN_LOOKUPFLW(H)] confirmed the Foundation on-site warhead!")
				update_appearance()
				START_PROCESSING(SSobj, src)
			else
				to_chat(H, span_warning("Invalid confirmation code."))
		if("cancel")
			if(!foundation_authorized)
				return
			if(!id_card || !(ACCESS_ADMIN in id_card.access))
				return
			timing = FALSE
			safety = TRUE
			detonation_timer = null
			foundation_authorized = FALSE
			update_appearance()
			STOP_PROCESSING(SSobj, src)
			priority_announce("On-site warhead detonation cancelled.", null, null, 'sound/misc/notice1.ogg')
			log_game("[key_name(H)] cancelled the Foundation on-site warhead.")
		if("set_timer")
			if(!foundation_authorized || timing)
				return
			var/new_time = text2num(params["time"])
			new_time = clamp(new_time, foundation_minimum, foundation_maximum)
			foundation_timer_seconds = new_time

/obj/machinery/nuclearbomb/foundation/process()
	if(!timing)
		STOP_PROCESSING(SSobj, src)
		return

	if(detonation_timer && world.time >= detonation_timer)
		foundation_detonate()
		return

	if(detonation_timer)
		var/time_left = (detonation_timer - world.time) / 10
		if(time_left <= 30)
			icon_state = "nuclearbomb1"
		else if(time_left <= 60)
			icon_state = "nuclearbomb2"
		else
			icon_state = "nuclearbomb3"

/obj/machinery/nuclearbomb/foundation/proc/foundation_detonate()
	log_game("Foundation on-site warhead detonated!")
	message_admins("Foundation on-site warhead has detonated!")

	for(var/mob/M in GLOB.player_list)
		if(M.client)
			shake_camera(M, 50, 5)

	for(var/mob/living/L in GLOB.alive_mob_list)
		var/turf/T = get_turf(L)
		if(!T || !is_station_level(T.z))
			continue
		L.gib()

	SSticker.set_force_ending(TRUE)

/obj/machinery/nuclearbomb/foundation/update_icon_state()
	. = ..()
	if(timing)
		if(detonation_timer)
			var/time_left = (detonation_timer - world.time) / 10
			if(time_left <= 30)
				icon_state = "nuclearbomb1"
			else if(time_left <= 60)
				icon_state = "nuclearbomb2"
			else
				icon_state = "nuclearbomb3"
		else
			icon_state = "nuclearbomb3"
	else
		icon_state = "nuclearbomb_base"
