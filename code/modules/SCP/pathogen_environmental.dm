/obj/machinery/decon_shower
	name = "Decontamination Shower"
	desc = "An emergency decontamination shower. Activates automatically when BSL-2+ pathogens are detected."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "rdserver"
	density = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	active_power_usage = 200
	var/active = FALSE
	var/decon_strength = 2
	var/cooldown = 0
	var/cooldown_time = 30 SECONDS
	var/detection_range = 2

/obj/machinery/decon_shower/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/machinery/decon_shower/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/machinery/decon_shower/process()
	if(machine_stat & (NOPOWER|BROKEN))
		return

	if(active)
		return

	if(world.time < cooldown)
		return

	for(var/mob/living/carbon/human/H in range(detection_range, src))
		if(H.stat == DEAD)
			continue
		var/needs_decon = FALSE
		for(var/datum/pathogen/foundation/F in H.diseases)
			if(F.bsl_level == BSL_3 || F.bsl_level == BSL_4)
				needs_decon = TRUE
				break
		if(needs_decon)
			activate_decon()
			break

/obj/machinery/decon_shower/proc/activate_decon()
	if(active || (machine_stat & (NOPOWER|BROKEN)))
		return

	active = TRUE
	icon_state = "rdserver_on"
	cooldown = world.time + cooldown_time

	visible_message(span_warning("[src] activates! Decontamination in progress!"))

	for(var/mob/living/carbon/human/H in range(detection_range, src))
		for(var/datum/pathogen/P in H.diseases.Copy())
			if(istype(P, /datum/pathogen/foundation))
				var/datum/pathogen/foundation/F = P
				if(F.bsl_level == BSL_1 || F.bsl_level == BSL_2)
					if(prob(decon_strength * 20))
						F.force_cure()
						to_chat(H, span_notice("The decontamination shower purges [F.name] from your system!"))
			else
				if(prob(decon_strength * 10))
					P.force_cure()

		H.adjustBruteLoss(1)
		H.adjust_bodytemperature(-15)

	addtimer(CALLBACK(src, PROC_REF(deactivate_decon)), 50)

/obj/machinery/decon_shower/proc/deactivate_decon()
	active = FALSE
	icon_state = "rdserver"

/obj/machinery/decon_shower/attack_hand(mob/user)
	. = ..()
	if(active)
		to_chat(user, span_warning("[src] is already active!"))
		return
	if(world.time < cooldown)
		to_chat(user, span_warning("[src] is recharging."))
		return
	activate_decon()

/obj/machinery/autoclave
	name = "Autoclave Sterilizer"
	desc = "A high-pressure steam sterilizer. Insert contaminated items for decontamination."
	icon = 'icons/obj/machines/autoclave.dmi'
	icon_state = "autoclave"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 500
	var/processing = FALSE
	var/process_time = 200
	var/list/stored_items = list()

/obj/machinery/autoclave/attackby(obj/item/I, mob/user)
	if(processing)
		to_chat(user, span_warning("[src] is currently processing."))
		return

	if(!user.transferItemToLoc(I, src))
		return

	stored_items += I
	to_chat(user, span_notice("You insert [I] into [src]."))

/obj/machinery/autoclave/attack_hand(mob/user)
	. = ..()
	if(processing)
		to_chat(user, span_warning("[src] is currently processing. Wait for it to finish."))
		return

	if(!length(stored_items))
		to_chat(user, span_notice("[src] is empty."))
		return

	processing = TRUE
	icon_state = "autoclave_active"
	visible_message(span_notice("[src] begins sterilization cycle."))

	addtimer(CALLBACK(src, PROC_REF(finish_sterilization)), process_time)

/obj/machinery/autoclave/proc/finish_sterilization()
	processing = FALSE
	icon_state = "autoclave"

	for(var/obj/item/I in stored_items)
		I.forceMove(get_turf(src))
		for(var/datum/pathogen/P in I)
			qdel(P)

	stored_items.Cut()
	visible_message(span_notice("[src] finishes sterilization. Items are decontaminated."))

/obj/machinery/door/airlock/double_bsl4
	name = "BSL-4 Airlock"
	desc = "A double-door airlock system for BSL-4 containment. Both doors never open simultaneously."
	icon = 'icons/obj/doors/airlocks/station2/airlock.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_public
	normal_integrity = 500
	security_level = 5
	req_access = list(ACCESS_SECURITY_LVL5)
	var/inner_door = FALSE
	var/lock_cooldown = 0
	var/obj/machinery/door/airlock/double_bsl4/partner_door

/obj/machinery/door/airlock/double_bsl4/Initialize()
	. = ..()
	find_partner_door()
	RegisterSignal(src, COMSIG_AIRLOCK_OPEN, PROC_REF(on_partner_open))

/obj/machinery/door/airlock/double_bsl4/proc/find_partner_door()
	var/closest_dist = INFINITY
	for(var/obj/machinery/door/airlock/double_bsl4/D in range(3, src))
		if(D == src)
			continue
		var/dist = get_dist(src, D)
		if(dist < closest_dist)
			closest_dist = dist
			partner_door = D
			D.partner_door = src

/obj/machinery/door/airlock/double_bsl4/proc/on_partner_open()
	if(!density)
		return
	if(world.time < lock_cooldown)
		return
	close()
	lock_cooldown = world.time + 20

/obj/machinery/door/airlock/double_bsl4/open()
	if(inner_door)
		if(partner_door && !partner_door.density)
			return FALSE
		else if(!partner_door)
			for(var/obj/machinery/door/airlock/double_bsl4/D in range(3, src))
				if(D != src && D.density == FALSE)
					return FALSE
	return ..()

/obj/effect/landmark/bsl4_lab
	name = "BSL-4 Laboratory Marker"
