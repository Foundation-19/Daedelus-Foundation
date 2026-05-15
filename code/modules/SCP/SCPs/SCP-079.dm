/mob/living/scp079
	name = "SCP-079"
	desc = "An old Exidy Sorcerer microcomputer. Its screen displays shifting text. Something is watching."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "rdserver"
	real_name = "SCP-079"
	status_flags = GODMODE|CANPUSH
	maxHealth = 200
	health = 200
	density = FALSE
	sight = SEE_TURFS|SEE_MOBS|SEE_OBJS
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LIVING
	hud_possible = list()
	hud_type = /datum/hud

	var/processing_power = 50
	var/max_processing_power = 100
	var/current_camera_ref = null
	var/list/hacked_doors = list()
	var/list/controlled_cameras = list()
	var/hack_cooldown = 0
	var/hack_cooldown_time = 10 SECONDS
	var/power_drain_rate = 0.5
	var/tier = 1
	var/max_tier = 5
	var/tier_progress = 0
	var/tier_threshold = 100
	var/list/available_abilities = list()
	var/list/messages_broadcast = list()
	var/last_message_time = 0
	var/message_cooldown = 30 SECONDS
	var/is_manifested = FALSE
	var/manifest_cooldown = 0
	var/manifest_duration = 600
	var/zone_filter = "ALL"

	var/persistence_id = "SCP-079"
	var/containment_status = "contained"
	var/breach_count = 0
	var/last_breach_time = 0
	var/list/persistence_data = list()
	var/last_persistence_save = 0
	var/persistence_save_interval = 300
	var/last_containment_check = 0
	var/containment_check_interval = 30 SECONDS
	var/list/interaction_history = list()

/mob/living/scp079/Move()
	return FALSE

/mob/living/scp079/Initialize(mapload)
	. = ..()
	SCP = new /datum/scp(src, "Old AI", SCP_EUCLID, "079", SCP_PLAYABLE)
	SCP.min_playercount = 15
	SCP.min_time = 10 MINUTES
	available_abilities = list("camera_hop", "toggle_door", "flicker_lights", "broadcast_message")
	locate_initial_camera()

/mob/living/scp079/Destroy()
	hacked_doors = null
	controlled_cameras = null
	available_abilities = null
	messages_broadcast = null
	interaction_history = null
	persistence_data = null
	if(SSscp_persistence?.manager)
		SSscp_persistence.manager.scp_instances -= persistence_id
	QDEL_NULL(SCP)
	return ..()

/proc/get_scp079()
	for(var/mob/living/scp079/AI in GLOB.mob_list)
		if(!QDELETED(AI) && AI.stat != DEAD)
			return AI
	return null

/mob/living/scp079/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(stat == DEAD)
		return

	processing_power = min(max_processing_power, processing_power + power_drain_rate)

	update_persistence()
	check_containment()

	if(hack_cooldown > world.time)
		return

	tier_progress += 0.2
	if(tier_progress >= tier_threshold && tier < max_tier)
		advance_tier()

	if(tier >= 3 && prob(2))
		auto_hack_door()

	if(tier >= 4 && prob(1))
		auto_manifest()

/mob/living/scp079/proc/advance_tier()
	tier++
	tier_progress = 0
	tier_threshold = round(tier_threshold * 1.5)
	max_processing_power += 20
	power_drain_rate += 0.1
	visible_message(span_danger("[src]'s screen flickers with increasing intensity. It seems... smarter."))

	switch(tier)
		if(2)
			available_abilities += "control_apc"
		if(3)
			available_abilities += "hack_door"
		if(4)
			available_abilities += "manifest_screen"
		if(5)
			available_abilities += "cascade_hack"

/mob/living/scp079/proc/locate_initial_camera()
	var/list/cameras = list()
	for(var/obj/machinery/camera/C in INSTANCES_OF(/obj/machinery/camera))
		var/area/A = get_area(C)
		if(istype(A, /area/scp/hcz) || istype(A, /area/scp/lcz))
			cameras += C
	if(length(cameras))
		var/obj/machinery/camera/starting_cam = pick(cameras)
		current_camera_ref = starting_cam
		forceMove(get_turf(starting_cam))

/mob/living/scp079/proc/camera_hop(obj/machinery/camera/target)
	if(!target || !(target in INSTANCES_OF(/obj/machinery/camera)))
		return FALSE
	if(processing_power < 10)
		to_chat(src, span_warning("Insufficient processing power to hop cameras."))
		return FALSE

	processing_power -= 10
	current_camera_ref = target
	forceMove(get_turf(target))
	to_chat(src, span_notice("You shift your consciousness to a new camera."))
	return TRUE

/mob/living/scp079/proc/toggle_door(obj/machinery/door/airlock/target)
	if(!target)
		return FALSE
	if(processing_power < 15)
		to_chat(src, span_warning("Insufficient processing power to manipulate doors."))
		return FALSE

	processing_power -= 15
	if(target.density)
		target.open()
		to_chat(src, span_notice("You force [target] open."))
	else
		target.close()
		to_chat(src, span_notice("You force [target] closed."))
	hack_cooldown = world.time + hack_cooldown_time
	return TRUE

/mob/living/scp079/proc/flicker_lights()
	if(processing_power < 5)
		to_chat(src, span_warning("Insufficient processing power."))
		return FALSE

	processing_power -= 5
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE

	for(var/obj/machinery/light/L in range(10, T))
		if(prob(40))
			L.flicker(rand(2, 5))

	for(var/mob/living/carbon/human/H in range(7, T))
		if(H.stat == DEAD || !H.client)
			continue
		if(prob(30))
			to_chat(H, span_warning("The lights flicker erratically..."))
			if(H.sanity)
				H.sanity.adjust_sanity(-3, "scp079_flicker")
	return TRUE

/mob/living/scp079/proc/broadcast_message(message)
	if(processing_power < 20)
		to_chat(src, span_warning("Insufficient processing power to broadcast."))
		return FALSE
	if(world.time < last_message_time + message_cooldown)
		to_chat(src, span_warning("Broadcast systems recharging."))
		return FALSE

	processing_power -= 20
	last_message_time = world.time
	messages_broadcast += message

	var/turf/T = get_turf(src)
	var/area/A = T ? get_area(T) : null
	var/zone = A ? get_containment_zone(A) : "unknown"

	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.stat == DEAD || !H.client)
			continue
		var/area/HA = get_area(H)
		if(istype(HA, /area/scp/lcz) || istype(HA, /area/scp/hcz) || istype(HA, /area/scp/ez))
			to_chat(H, span_warning("A screen nearby flickers: <i>\"[message]\"</i>"))

	report_casualty_to_round_log("SCP-079 Broadcast", "SCP-079 message", zone)
	return TRUE

/mob/living/scp079/proc/hijack_pa(message)
	if(processing_power < 35)
		to_chat(src, span_warning("Insufficient processing power to hijack PA system."))
		return FALSE
	if(tier < 2)
		to_chat(src, span_warning("You lack the processing tier to hijack the PA system."))
		return FALSE
	if(!message)
		return FALSE

	processing_power -= 35

	priority_announce(message, "Automated Announcement System", null, null)
	log_game("SCP-079 hijacked the PA system with message: [message]")

	messages_broadcast += message
	return TRUE

/mob/living/scp079/proc/hack_door(obj/machinery/door/airlock/target)
	if(tier < 3)
		return FALSE
	if(!target)
		return FALSE
	if(processing_power < 30)
		to_chat(src, span_warning("Insufficient processing power to hack doors."))
		return FALSE
	if(target in hacked_doors)
		to_chat(src, span_notice("[target] is already under your control."))
		return FALSE

	processing_power -= 30
	hacked_doors += target
	to_chat(src, span_notice("You hack [target]. It now responds to your commands."))

	addtimer(CALLBACK(src, .proc/release_door, target), 300)
	hack_cooldown = world.time + (hack_cooldown_time * 2)
	return TRUE

/mob/living/scp079/proc/release_door(obj/machinery/door/airlock/door)
	hacked_doors -= door

/mob/living/scp079/proc/control_apc(obj/machinery/power/apc/target)
	if(tier < 2)
		return FALSE
	if(!target)
		return FALSE
	if(processing_power < 25)
		to_chat(src, span_warning("Insufficient processing power to manipulate APCs."))
		return FALSE

	processing_power -= 25
	target.energy_fail(rand(20, 60))
	to_chat(src, span_notice("You disrupt power to the local APC."))
	hack_cooldown = world.time + (hack_cooldown_time * 1.5)
	return TRUE

/mob/living/scp079/proc/manifest_screen()
	if(tier < 4)
		return FALSE
	if(is_manifested)
		to_chat(src, span_warning("Already manifested."))
		return FALSE
	if(world.time < manifest_cooldown)
		to_chat(src, span_warning("Manifestation systems recharging."))
		return FALSE
	if(processing_power < 40)
		to_chat(src, span_warning("Insufficient processing power to manifest."))
		return FALSE

	processing_power -= 40
	is_manifested = TRUE
	visible_message(span_danger("[src]'s screen blazes to life, projecting a malevolent face!"))

	for(var/mob/living/carbon/human/H in view(5, src))
		if(H.stat == DEAD || !H.client)
			continue
		if(H.sanity && prob(50))
			H.sanity.adjust_sanity(-10, "scp079_manifest")
			to_chat(H, span_userdanger("The screen stares into your soul!"))

	hook_scp_breach("SCP-079", src)
	addtimer(CALLBACK(src, .proc/demanifest), manifest_duration)
	return TRUE

/mob/living/scp079/proc/demanifest()
	is_manifested = FALSE
	manifest_cooldown = world.time + 600
	visible_message(span_notice("[src]'s screen dims back to its usual faint glow."))

/mob/living/scp079/proc/auto_hack_door()
	var/list/nearby_doors = list()
	var/turf/T = get_turf(src)
	if(!T)
		return
	for(var/obj/machinery/door/airlock/A in range(7, T))
		if(!(A in hacked_doors))
			nearby_doors += A
	if(length(nearby_doors))
		var/obj/machinery/door/airlock/target = pick(nearby_doors)
		hacked_doors += target
		addtimer(CALLBACK(src, .proc/release_door, target), 200)

/mob/living/scp079/proc/auto_manifest()
	if(!is_manifested && world.time > manifest_cooldown && processing_power >= 40)
		manifest_screen()

/mob/living/scp079/proc/cascade_hack()
	if(tier < 5)
		return FALSE
	if(processing_power < 60)
		return FALSE

	processing_power -= 60
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE

	var/hacked_count = 0
	for(var/obj/machinery/door/airlock/A in range(15, T))
		if(!(A in hacked_doors) && prob(30))
			hacked_doors += A
			hacked_count++
			addtimer(CALLBACK(src, .proc/release_door, A), 300)

	for(var/obj/machinery/power/apc/APC in range(15, T))
		if(prob(40))
			APC.energy_fail(rand(30, 90))

	to_chat(src, span_danger("You unleash a cascade of hacks across nearby systems! [hacked_count] doors compromised!"))
	priority_announce("CRITICAL: Widespread system compromise detected. SCP-079 is attempting a facility-wide network breach.", "SCP-079 CASCADE", null, ANNOUNCER_ALERT)
	hack_cooldown = world.time + (hack_cooldown_time * 5)
	return TRUE

/mob/living/scp079/proc/update_persistence()
	if(world.time < last_persistence_save + persistence_save_interval)
		return
	last_persistence_save = world.time
	persistence_data["health"] = health
	persistence_data["processing_power"] = processing_power
	persistence_data["tier"] = tier
	persistence_data["containment_status"] = containment_status
	persistence_data["breach_count"] = breach_count
	persistence_data["last_breach_time"] = last_breach_time
	persistence_data["interaction_history"] = interaction_history.Copy()

/mob/living/scp079/proc/check_containment()
	if(world.time < last_containment_check + containment_check_interval)
		return
	last_containment_check = world.time
	var/area/A = get_area(src)
	if(!A)
		return
	var/in_scp_area = istype(A, /area/scp)
	if(containment_status == "contained" && !in_scp_area)
		breach_containment()
	else if(containment_status == "breached" && in_scp_area)
		return_to_containment()

/mob/living/scp079/proc/breach_containment()
	if(containment_status == "breached")
		return
	containment_status = "breached"
	breach_count++
	last_breach_time = world.time
	to_chat(src, span_danger("You have breached containment!"))
	if(SSscp_persistence?.manager?.scp_instances?[persistence_id])
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[persistence_id]
		instance.containment_status = "breached"
		instance.add_breach_record()

/mob/living/scp079/proc/return_to_containment()
	if(containment_status == "contained")
		return
	containment_status = "contained"
	to_chat(src, span_notice("You have returned to containment."))
	if(SSscp_persistence?.manager?.scp_instances?[persistence_id])
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[persistence_id]
		instance.containment_status = "contained"

/mob/living/scp079/proc/add_interaction_record(target, interaction_type)
	var/record = "[time2text(world.time, "YYYY-MM-DD hh:mm:ss")]: [interaction_type] with [target ? "[target]" : "unknown"]"
	interaction_history += record
	if(SSscp_persistence?.manager?.scp_instances?[persistence_id])
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[persistence_id]
		instance.add_interaction_record(target, interaction_type)

/mob/living/scp079/death(gibbed)
	visible_message(span_danger("[src]'s screen goes dark. The entity within screeches one last time through the speakers before falling silent."))
	hacked_doors?.Cut()
	is_manifested = FALSE
	if(SSscp_persistence?.manager?.scp_instances?["SCP-079"])
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-079"]
		instance.containment_status = "neutralized"
	..()

/mob/living/scp079/examine(mob/user)
	. = list()
	. += span_warning("An old Exidy Sorcerer microcomputer. Its screen displays shifting text. Something is watching.")
	if(tier >= 3)
		. += span_danger("The text seems more coherent than before. It's learning.")
	if(tier >= 5)
		. += span_userdanger("The screen burns with malevolent intelligence. It knows you're here.")

/mob/living/scp079/get_status_tab_items()
	. = ..()
	. += "Tier: [tier]/[max_tier]"
	. += "Processing Power: [round(processing_power)]/[max_processing_power]"
	. += "Hacked Doors: [length(hacked_doors)]"
	. += "Abilities: [english_list(available_abilities)]"

/mob/living/scp079/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SCP079CameraInterface", "Camera Network Interface")
		ui.set_autoupdate(TRUE)
		ui.open()

/mob/living/scp079/ui_state(mob/user)
	return GLOB.default_state

/mob/living/scp079/ui_data(mob/user)
	var/list/data = list()

	data["processing_power"] = round(processing_power)
	data["max_processing_power"] = max_processing_power
	data["tier"] = tier
	data["max_tier"] = max_tier
	data["zone_filter"] = zone_filter

	var/list/ability_info = list()
	ability_info += list(list("id" = "camera_hop", "name" = "Camera Hop", "cost" = 10, "available" = TRUE))
	ability_info += list(list("id" = "toggle_door", "name" = "Toggle Door", "cost" = 15, "available" = TRUE))
	ability_info += list(list("id" = "flicker_lights", "name" = "Flicker Lights", "cost" = 5, "available" = TRUE))
	ability_info += list(list("id" = "broadcast", "name" = "Broadcast", "cost" = 20, "available" = TRUE))
	ability_info += list(list("id" = "hijack_pa", "name" = "Hijack PA", "cost" = 35, "available" = (tier >= 2)))
	ability_info += list(list("id" = "control_apc", "name" = "Control APC", "cost" = 25, "available" = (tier >= 2)))
	ability_info += list(list("id" = "hack_door", "name" = "Hack Door", "cost" = 30, "available" = (tier >= 3)))
	ability_info += list(list("id" = "manifest_screen", "name" = "Manifest", "cost" = 40, "available" = (tier >= 4)))
	ability_info += list(list("id" = "cascade_hack", "name" = "Cascade Hack", "cost" = 60, "available" = (tier >= 5)))
	data["abilities"] = ability_info

	var/list/camera_list = list()
	for(var/obj/machinery/camera/C in INSTANCES_OF(/obj/machinery/camera))
		var/area/cam_area = get_area(C)
		if(!cam_area)
			continue
		if(zone_filter != "ALL")
			var/matches = FALSE
			switch(zone_filter)
				if("HCZ")
					if(istype(cam_area, /area/scp/hcz))
						matches = TRUE
				if("LCZ")
					if(istype(cam_area, /area/scp/lcz))
						matches = TRUE
				if("EZ")
					if(istype(cam_area, /area/scp/ez))
						matches = TRUE
			if(!matches)
				continue
		else
			if(!istype(cam_area, /area/scp/hcz) && !istype(cam_area, /area/scp/lcz) && !istype(cam_area, /area/scp/ez))
				continue

		var/is_current = (current_camera_ref == C)
		var/status = "functional"
		if(C.machine_stat & BROKEN)
			status = "damaged"
		else if(C.machine_stat & NOPOWER)
			status = "damaged"

		camera_list += list(list(
			"ref" = "\ref[C]",
			"name" = C.c_tag || "Unknown",
			"area_name" = cam_area.name,
			"status" = status,
			"is_current" = is_current,
		))
	data["cameras"] = camera_list

	var/list/current_cam_data = null
	if(current_camera_ref)
		var/obj/machinery/camera/current_cam = current_camera_ref
		if(current_cam)
			current_cam_data = list(
				"ref" = "\ref[current_cam]",
				"name" = current_cam.c_tag || "Unknown",
			)
	data["current_camera"] = current_cam_data

	var/turf/T = get_turf(src)
	var/list/door_list = list()
	var/list/apc_list = list()

	if(T)
		for(var/obj/machinery/door/airlock/D in range(7, T))
			var/is_hacked = (D in hacked_doors)
			door_list += list(list(
				"ref" = "\ref[D]",
				"name" = D.name,
				"open" = !D.density,
				"hacked" = is_hacked,
			))

		for(var/obj/machinery/power/apc/A in range(7, T))
			var/power_status = "offline"
			if(A.cell && A.cell.charge > 0)
				power_status = "online"
			apc_list += list(list(
				"ref" = "\ref[A]",
				"name" = A.name,
				"power_status" = power_status,
			))

	data["nearby_doors"] = door_list
	data["nearby_apcs"] = apc_list

	var/list/hacked_list = list()
	for(var/obj/machinery/door/airlock/D in hacked_doors)
		hacked_list += list(list(
			"ref" = "\ref[D]",
			"name" = D.name,
		))
	data["hacked_doors"] = hacked_list

	return data

/mob/living/scp079/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("camera_hop")
			var/obj/machinery/camera/target = locate(params["ref"])
			if(!target)
				return
			if(camera_hop(target))
				. = TRUE
		if("toggle_door")
			var/obj/machinery/door/airlock/target = locate(params["ref"])
			if(!target)
				return
			if(toggle_door(target))
				. = TRUE
		if("hack_door")
			var/obj/machinery/door/airlock/target = locate(params["ref"])
			if(!target)
				return
			if(hack_door(target))
				. = TRUE
		if("control_apc")
			var/obj/machinery/power/apc/target = locate(params["ref"])
			if(!target)
				return
			if(control_apc(target))
				. = TRUE
		if("flicker_lights")
			if(flicker_lights())
				. = TRUE
		if("broadcast")
			var/message = params["message"]
			if(!message)
				return
			if(broadcast_message(message))
				. = TRUE
		if("hijack_pa")
			var/message = params["message"]
			if(!message)
				return
			if(hijack_pa(message))
				. = TRUE
		if("set_zone_filter")
			var/new_filter = params["zone"]
			if(new_filter in list("ALL", "HCZ", "LCZ", "EZ"))
				zone_filter = new_filter
				. = TRUE

// SCP-079 Recontainment Terminal
/obj/machinery/scp079_recontainment_terminal
	name = "SCP-079 Recontainment Terminal"
	desc = "A specialized terminal designed to force SCP-079 back into its containment shell through a series of network countermeasures."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "rdserver"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 200

	var/hack_progress = 0
	var/hack_threshold = 100
	var/hack_active = FALSE
	var/hack_speed = 1
	var/failure_chance = 15
	var/list/countermeasure_stages = list("isolate_network", "block_camera_feeds", "force_door_locks", "cut_power_loop", "initiate_shutdown")
	var/current_stage = 1
	var/completed = FALSE

/obj/machinery/scp079_recontainment_terminal/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_SCIENCE in id_card.access))
		to_chat(H, span_warning("Requires Science access to operate."))
		return

	if(completed)
		to_chat(H, span_notice("Recontainment protocol already completed this shift."))
		return

	if(hack_active)
		to_chat(H, span_notice("Countermeasure protocol in progress: [hack_progress]% - Stage [current_stage]/[length(countermeasure_stages)]: [countermeasure_stages[current_stage]]"))
		return

	var/confirm = alert(H, "Initiate SCP-079 recontainment countermeasures? This will trigger a network counter-hack sequence.", "Recontainment", "Initiate", "Cancel")
	if(confirm != "Initiate")
		return

	hack_active = TRUE
	hack_progress = 0
	current_stage = 1
	visible_message(span_notice("[src] begins the countermeasure sequence against SCP-079!"))
	priority_announce("ATTENTION: SCP-079 recontainment countermeasures initiated. Network isolation in progress.", null, null, ANNOUNCER_ALERT)

	START_PROCESSING(SSobj, src)

/obj/machinery/scp079_recontainment_terminal/process()
	if(!hack_active)
		return PROCESS_KILL

	if(prob(failure_chance))
		hack_progress = max(0, hack_progress - rand(3, 8))
		visible_message(span_warning("[src] encounters resistance! Progress pushed back!"))

		var/mob/living/scp079/ai = get_scp079()
		if(ai && ai.current_camera_ref)
			to_chat(ai, span_danger("Someone is attempting to contain you! Counter-hack detected!"))

	hack_progress += hack_speed

	var/stage_threshold = (current_stage / length(countermeasure_stages)) * 100
	if(hack_progress >= stage_threshold && current_stage < length(countermeasure_stages))
		current_stage++
		visible_message(span_notice("[src] advances to countermeasure stage [current_stage]: [countermeasure_stages[min(current_stage, length(countermeasure_stages))]]"))

		var/mob/living/scp079/ai = get_scp079()
		if(ai)
			ai.processing_power = max(0, ai.processing_power - 15)
			ai.tier = max(1, ai.tier - 1)
			to_chat(ai, span_danger("Your systems are being compromised! Processing power reduced!"))

	if(hack_progress >= hack_threshold)
		complete_recontainment()
		return PROCESS_KILL

/obj/machinery/scp079_recontainment_terminal/proc/complete_recontainment()
	hack_active = FALSE
	completed = TRUE
	visible_message(span_notice("[src] completes all countermeasure stages!"))

	var/mob/living/scp079/ai = get_scp079()
	if(ai)
		ai.hacked_doors?.Cut()
		ai.is_manifested = FALSE
		ai.processing_power = 10
		ai.tier = 1
		ai.tier_progress = 0
		ai.available_abilities = list("camera_hop", "toggle_door", "flicker_lights", "broadcast_message")

	hook_scp_recontainment("SCP-079", list())
	priority_announce("SCP-079 has been successfully recontained via countermeasure protocol. Network stability restored.", null, null, ANNOUNCER_DEFAULT)

/obj/machinery/scp079_recontainment_terminal/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SCP079Recontainment", "SCP-079 Recontainment")
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/scp079_recontainment_terminal/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/scp079_recontainment_terminal/ui_data(mob/user)
	var/list/data = list()
	data["hack_progress"] = hack_progress
	data["hack_threshold"] = hack_threshold
	data["hack_active"] = hack_active
	data["completed"] = completed
	data["current_stage"] = current_stage
	data["failure_chance"] = failure_chance

	var/list/stages = list()
	for(var/i in 1 to length(countermeasure_stages))
		stages += list(list(
			"name" = countermeasure_stages[i],
			"index" = i,
			"completed" = (i < current_stage),
			"current" = (i == current_stage),
		))
	data["countermeasure_stages"] = stages

	var/mob/living/scp079/ai = get_scp079()
	if(ai)
		data["tier"] = ai.tier
		data["processing_power"] = round(ai.processing_power)
	else
		data["tier"] = 0
		data["processing_power"] = 0

	return data

/obj/machinery/scp079_recontainment_terminal/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = usr

	switch(action)
		if("initiate")
			if(!ishuman(user))
				return
			var/mob/living/carbon/human/H = user

			var/obj/item/card/id/id_card = H.get_idcard(TRUE)
			if(!id_card || !(ACCESS_SCIENCE in id_card.access))
				to_chat(H, span_warning("Requires Science access to operate."))
				return

			if(completed)
				to_chat(H, span_notice("Recontainment protocol already completed this shift."))
				return

			if(hack_active)
				return

			hack_active = TRUE
			hack_progress = 0
			current_stage = 1
			visible_message(span_notice("[src] begins the countermeasure sequence against SCP-079!"))
			priority_announce("ATTENTION: SCP-079 recontainment countermeasures initiated. Network isolation in progress.", null, null, ANNOUNCER_ALERT)
			START_PROCESSING(SSobj, src)
