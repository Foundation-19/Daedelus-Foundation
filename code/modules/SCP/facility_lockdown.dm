// Facility Lockdown Mode
// Unified cascade lockdown that closes blast doors, disables elevators, and jams communications

/obj/machinery/facility_lockdown_console
	name = "Facility Lockdown Console"
	desc = "A secure console for initiating facility-wide lockdown protocols."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 150

	var/lockdown_state = LOCKDOWN_NONE
	var/lockdown_reason = ""
	var/lockdown_start_time = 0
	var/auto_lift_time = 0
	var/comms_jammed = FALSE
	var/elevators_disabled = FALSE
	var/blast_doors_closed = FALSE
	var/list/jammed_radios = list()
	var/saved_security_level = 0
	var/cached_airlock_iteration_lockdown = 0
	var/cached_airlock_iteration_unlock = 0
	var/cached_elevator_iteration_lock = 0
	var/cached_elevator_iteration_unlock = 0
	var/airlock_cache_cooldown = 30 SECONDS

/obj/machinery/facility_lockdown_console/Initialize(mapload)
	. = ..()
	SET_TRACKING(__TYPE__)

/obj/machinery/facility_lockdown_console/Destroy()
	UNSET_TRACKING(__TYPE__)
	return ..()

/obj/machinery/facility_lockdown_console/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ADMIN in id_card.access))
		to_chat(H, span_warning("Requires Command access to operate lockdown systems."))
		return

	if(lockdown_state != LOCKDOWN_NONE)
		show_lockdown_status(H)
		return

	var/list/options = list("Partial Lockdown", "Full Lockdown", "Cancel")
	var/choice = alert(H, "Select lockdown protocol:", "Facility Lockdown", options[1], options[2], options[3])
	if(choice == "Cancel")
		return

	var/reason = input(H, "Enter reason for lockdown:", "Lockdown Reason") as text|null
	if(!reason)
		reason = "Unspecified security concern"

	initiate_lockdown(choice == "Full Lockdown" ? LOCKDOWN_FULL : LOCKDOWN_PARTIAL, reason, H)

/obj/machinery/facility_lockdown_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FacilityLockdown", "SCP FOUNDATION — FACILITY LOCKDOWN CONTROL")
		ui.open()

/obj/machinery/facility_lockdown_console/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/facility_lockdown_console/ui_data(mob/user)
	var/list/data = list()
	data["lockdown_state"] = lockdown_state
	data["lockdown_reason"] = lockdown_reason
	data["lockdown_start_time"] = lockdown_start_time
	data["comms_jammed"] = comms_jammed
	data["elevators_disabled"] = elevators_disabled
	data["blast_doors_closed"] = blast_doors_closed
	data["lockdown_duration"] = lockdown_start_time ? (world.time - lockdown_start_time) : 0
	return data

/obj/machinery/facility_lockdown_console/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/user = ui.user
	if(.)
		return

	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ADMIN in id_card.access))
		to_chat(H, span_warning("Requires Command access to operate lockdown systems."))
		return

	switch(action)
		if("lockdown")
			var/level = text2num(params["level"])
			if(!level)
				return
			var/reason = params["reason"]
			if(!reason)
				reason = "Unspecified security concern"
			initiate_lockdown(level, reason, H)
			. = TRUE
		if("lift_lockdown")
			lift_lockdown(H)
			. = TRUE

/obj/machinery/facility_lockdown_console/proc/show_lockdown_status(mob/user)
	var/duration = lockdown_start_time ? DisplayTimeText(world.time - lockdown_start_time) : "N/A"
	to_chat(user, span_notice("Lockdown Status: [lockdown_state == LOCKDOWN_FULL ? "FULL" : "PARTIAL"]"))
	to_chat(user, span_notice("Reason: [lockdown_reason]"))
	to_chat(user, span_notice("Duration: [duration]"))
	to_chat(user, span_notice("Blast Doors: [blast_doors_closed ? "CLOSED" : "OPEN"]"))
	to_chat(user, span_notice("Elevators: [elevators_disabled ? "DISABLED" : "OPERATIONAL"]"))
	to_chat(user, span_notice("Communications: [comms_jammed ? "JAMMED" : "NORMAL"]"))

	var/lift = alert(user, "Lift lockdown?", "Facility Lockdown", "Lift Lockdown", "Keep Active")
	if(lift == "Lift Lockdown")
		lift_lockdown(user)

/obj/machinery/facility_lockdown_console/proc/initiate_lockdown(level, reason, mob/initiator)
	lockdown_state = level
	lockdown_reason = reason
	lockdown_start_time = world.time

	log_game("Facility lockdown initiated by [initiator ? key_name(initiator) : "automated system"]: [level == LOCKDOWN_FULL ? "FULL" : "PARTIAL"] - [reason]")

	if(level >= LOCKDOWN_PARTIAL)
		close_blast_doors()
		lockdown_dclass_areas()

	if(level >= LOCKDOWN_FULL)
		disable_elevators()
		jam_communications()

	if(auto_lift_time > 0)
		addtimer(CALLBACK(src, /obj/machinery/facility_lockdown_console/proc/lift_lockdown, null), auto_lift_time)

	priority_announce(
		"ATTENTION: [level == LOCKDOWN_FULL ? "FULL" : "PARTIAL"] FACILITY LOCKDOWN INITIATED. Reason: [reason]. [level == LOCKDOWN_FULL ? "All personnel remain at current posts. Blast doors sealed. Elevators disabled." : "D-Class areas secured. Blast doors closing."]",
		"FACILITY LOCKDOWN",
		null,
		ANNOUNCER_ALERT
	)

	report_lockdown_to_round_log(reason, 0)

	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence?.manager?.global_scp_management_mode = "lockdown"

/obj/machinery/facility_lockdown_console/proc/lift_lockdown(mob/user)
	lockdown_state = LOCKDOWN_NONE
	lockdown_reason = ""

	open_blast_doors()
	enable_elevators()
	unjam_communications()
	unlock_dclass_areas()

	priority_announce("Facility lockdown has been lifted. All systems returning to normal operation.", "LOCKDOWN LIFTED", null, ANNOUNCER_DEFAULT)

	report_lockdown_to_round_log("Lockdown lifted", world.time - lockdown_start_time)

	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence?.manager?.global_scp_management_mode = "standard"

/obj/machinery/facility_lockdown_console/proc/close_blast_doors()
	blast_doors_closed = TRUE
	for(var/obj/machinery/door/poddoor/shutters/P in INSTANCES_OF(/obj/machinery/door/poddoor/shutters))
		var/area/A = get_area(P)
		if(istype(A, /area/scp/lcz) || istype(A, /area/scp/hcz) || istype(A, /area/scp/ez))
			P.close()

	for(var/obj/machinery/door/poddoor/P in INSTANCES_OF(/obj/machinery/door/poddoor))
		var/area/A = get_area(P)
		if(istype(A, /area/scp/lcz/checkpoint) || istype(A, /area/scp/hcz/checkpoint) || istype(A, /area/scp/ez/checkpoint))
			P.close()

/obj/machinery/facility_lockdown_console/proc/open_blast_doors()
	blast_doors_closed = FALSE
	for(var/obj/machinery/door/poddoor/shutters/P in INSTANCES_OF(/obj/machinery/door/poddoor/shutters))
		var/area/A = get_area(P)
		if(istype(A, /area/scp/lcz) || istype(A, /area/scp/hcz) || istype(A, /area/scp/ez))
			P.open()

	for(var/obj/machinery/door/poddoor/P in INSTANCES_OF(/obj/machinery/door/poddoor))
		var/area/A = get_area(P)
		if(istype(A, /area/scp/lcz/checkpoint) || istype(A, /area/scp/hcz/checkpoint) || istype(A, /area/scp/ez/checkpoint))
			P.open()

/obj/machinery/facility_lockdown_console/proc/lockdown_dclass_areas()
	if(SSdclass && SSdclass.manager)
		saved_security_level = SSdclass?.manager?.current_security_level
		SSdclass?.manager?.current_security_level = 4
	if(world.time < cached_airlock_iteration_lockdown)
		return
	cached_airlock_iteration_lockdown = world.time + airlock_cache_cooldown
	for(var/obj/machinery/door/airlock/A in INSTANCES_OF(/obj/machinery/door/airlock))
		var/area/area = get_area(A)
		if(istype(area, /area/scp/dclass))
			A.lock()

/obj/machinery/facility_lockdown_console/proc/unlock_dclass_areas()
	if(SSdclass && SSdclass.manager)
		SSdclass?.manager?.current_security_level = saved_security_level ? saved_security_level : 1
	if(world.time < cached_airlock_iteration_unlock)
		return
	cached_airlock_iteration_unlock = world.time + airlock_cache_cooldown
	for(var/obj/machinery/door/airlock/A in INSTANCES_OF(/obj/machinery/door/airlock))
		var/area/area = get_area(A)
		if(istype(area, /area/scp/dclass))
			A.unlock()

/obj/machinery/facility_lockdown_console/proc/disable_elevators()
	elevators_disabled = TRUE
	if(world.time < cached_elevator_iteration_lock)
		return
	cached_elevator_iteration_lock = world.time + airlock_cache_cooldown
	for(var/obj/machinery/door/airlock/A in INSTANCES_OF(/obj/machinery/door/airlock))
		var/area/area = get_area(A)
		if(istype(area, /area/scp/surface) || istype(area, /area/scp/ez))
			if(findtext(lowertext(A.name), "elevator") || findtext(lowertext(A.name), "lift"))
				A.lock()

/obj/machinery/facility_lockdown_console/proc/enable_elevators()
	elevators_disabled = FALSE
	if(world.time < cached_elevator_iteration_unlock)
		return
	cached_elevator_iteration_unlock = world.time + airlock_cache_cooldown
	for(var/obj/machinery/door/airlock/A in INSTANCES_OF(/obj/machinery/door/airlock))
		var/area/area = get_area(A)
		if(istype(area, /area/scp/surface) || istype(area, /area/scp/ez))
			if(findtext(lowertext(A.name), "elevator") || findtext(lowertext(A.name), "lift"))
				A.unlock()

/obj/machinery/facility_lockdown_console/proc/jam_communications()
	comms_jammed = TRUE
	jammed_radios = list()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(istype(A, /area/scp/lcz) || istype(A, /area/scp/hcz))
			var/obj/item/radio/R = H.ears
			if(istype(R) && R.is_on())
				R.set_on(FALSE)
				jammed_radios += R
			to_chat(H, span_warning("Your radio crackles and goes silent. Communications are being jammed."))

/obj/machinery/facility_lockdown_console/proc/unjam_communications()
	comms_jammed = FALSE
	for(var/obj/item/radio/R in jammed_radios)
		if(!QDELETED(R))
			R.set_on(TRUE)
	jammed_radios = list()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(istype(A, /area/scp/lcz) || istype(A, /area/scp/hcz))
			to_chat(H, span_notice("Your radio crackles back to life. Communications restored."))
/proc/trigger_facility_lockdown(reason = "Cascade event detected")
	var/list/consoles = list()
	for(var/obj/machinery/facility_lockdown_console/C in INSTANCES_OF(/obj/machinery/facility_lockdown_console))
		if(C.lockdown_state == LOCKDOWN_NONE)
			consoles += C

	if(length(consoles))
		var/obj/machinery/facility_lockdown_console/C = pick(consoles)
		C.initiate_lockdown(LOCKDOWN_FULL, reason, null)
