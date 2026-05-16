// SCP-106 - The Old Man
// A predatory entity that corrodes matter, phases through solid surfaces, and drags victims into a pocket dimension.
// Thematic accuracy: slow, patient, relentless. Leaves corrosion trails. Fire and bright light are weaknesses.
// Abilities have substantial cooldowns and energy costs to prevent spam.

/mob/living/scp/scp106
	name = "SCP-106"
	desc = "An elderly humanoid figure composed of a dark, viscous substance. Where it walks, reality rots."
	icon = 'icons/scp/scp-106.dmi'
	icon_state = "scp106"
	real_name = "SCP-106"
	persistence_id = "SCP-106"

	var/datum/scp106_phasing_system/phasing_system
	var/datum/scp106_pocket_dimension_system/pocket_dimension_system
	var/datum/scp106_corrosion_system/corrosion_system
	var/datum/scp106_hunting_system/hunting_system
	var/datum/scp106_containment_system/containment_system
	var/datum/scp106_research_integration/research_integration

	var/corrosion_active = TRUE
	var/last_corrosion_tick = 0
	var/corrosion_tick_interval = 3 SECONDS
	var/in_pocket_dimension = FALSE
	var/pocket_dimension_turf = null

/mob/living/scp/scp106/Initialize()
	. = ..()

	phasing_system = new /datum/scp106_phasing_system(src)
	pocket_dimension_system = new /datum/scp106_pocket_dimension_system(src)
	corrosion_system = new /datum/scp106_corrosion_system(src)
	hunting_system = new /datum/scp106_hunting_system(src)
	containment_system = new /datum/scp106_containment_system(src)
	research_integration = new /datum/scp106_research_integration(src)

	SCP = new /datum/scp(
		src,
		"SCP-106",
		SCP_KETER,
		"106",
		SCP_PLAYABLE
	)

	SCP.min_playercount = 20
	SCP.min_time = 30 MINUTES

	maxHealth = SCP106_MAX_HEALTH
	health = maxHealth

	fovangle = 90
	update_fov_angles()
	update_cone_show()

/mob/living/scp/scp106/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(.)
		return
	if(stat == DEAD)
		return

	if(in_pocket_dimension)
		process_pocket_dimension_healing()
		return

	phasing_system?.process_phasing()
	pocket_dimension_system?.process_dimensions()
	corrosion_system?.process_corrosion()
	hunting_system?.process_hunting()
	containment_system?.process_containment()
	research_integration?.process_research()

	process_passive_corrosion()
	process_weakness_damage()

	if(prob(5))
		playsound(src, 'sound/scp/106/breathing.ogg', 25, TRUE, extrarange = 5)

/mob/living/scp/scp106/Destroy()
	QDEL_NULL(phasing_system)
	QDEL_NULL(pocket_dimension_system)
	QDEL_NULL(corrosion_system)
	QDEL_NULL(hunting_system)
	QDEL_NULL(containment_system)
	QDEL_NULL(research_integration)
	return ..()

/mob/living/scp/scp106/examine(mob/user)
	. = ..()
	. += span_warning("A foul black substance drips from its form. The air around it tastes of rust and decay.")

/mob/living/scp/scp106/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	if(in_pocket_dimension)
		return FALSE
	. = ..()
	if(. && corrosion_active && !QDELETED(src))
		leave_corrosion_pool(get_turf(src))

/mob/living/scp/scp106/UnarmedAttack(atom/A)
	if(in_pocket_dimension)
		return
	if(ismob(A))
		corrosive_touch(A)
		return
	if(istype(A, /obj/structure) || istype(A, /obj/machinery/door))
		corrode_structure(A)
		return
	if(istype(A, /turf/closed/wall/scp_containment))
		corrode_containment_wall(A)
		return
	..()

/mob/living/scp/scp106/proc/process_passive_corrosion()
	if(!corrosion_active)
		return
	if(world.time < last_corrosion_tick + corrosion_tick_interval)
		return
	last_corrosion_tick = world.time

	var/turf/T = get_turf(src)
	if(T)
		leave_corrosion_pool(T)
		if(prob(30))
			playsound(src, pick('sound/scp/106/decay1.ogg', 'sound/scp/106/decay2.ogg', 'sound/scp/106/decay3.ogg'), 30, TRUE, extrarange = 3)
		for(var/obj/item/I in T)
			if(prob(15))
				I.take_damage(5)

/mob/living/scp/scp106/proc/process_weakness_damage()
	var/turf/T = get_turf(src)
	if(!T)
		return

	var/light_amount = T.get_lumcount()
	if(light_amount > 0.6)
		adjustBruteLoss(2)

	if(on_fire)
		adjustFireLoss(5)

/mob/living/scp/scp106/proc/process_pocket_dimension_healing()
	adjustBruteLoss(-5)
	adjustFireLoss(-5)
	if(health >= maxHealth)
		health = maxHealth

/mob/living/scp/scp106/proc/leave_corrosion_pool(turf/T)
	if(!T || T.density)
		return
	var/obj/effect/scp106_residue/existing = locate(/obj/effect/scp106_residue) in T
	if(existing)
		existing.linger_time = world.time + 45 SECONDS
		return
	new /obj/effect/scp106_residue(T)

/mob/living/scp/scp106/proc/corrosive_touch(mob/living/target)
	if(!istype(target) || target == src)
		return
	if(corrosion_system?.corrosion_cooldown > 0)
		to_chat(src, span_warning("Your corrosive touch is still recharging."))
		return

	corrosion_system.corrosion_cooldown = 10 SECONDS
	corrosion_system.last_corrosion = world.time

	target.adjustBruteLoss(25)
	target.adjustToxLoss(15)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.sanity)
			H.sanity.adjust_sanity(-20, "scp106_touch")
	target.visible_message(span_danger("[src] places a rotting hand on [target]! Flesh blackens and peels!"), \
		span_userdanger("A freezing, corrosive hand touches you. Your skin bubbles and sloughs off!"))
	playsound(target, 'sound/scp/106/decay1.ogg', 50, TRUE)

	on_corrosion_use(target)

/mob/living/scp/scp106/proc/corrode_structure(atom/target)
	if(corrosion_system?.corrosion_cooldown > 0)
		to_chat(src, span_warning("Your corrosive touch is still recharging."))
		return

	corrosion_system.corrosion_cooldown = 8 SECONDS
	corrosion_system.last_corrosion = world.time

	if(istype(target, /obj/machinery/door))
		var/obj/machinery/door/D = target
		D.visible_message(span_danger("[src] presses against [D] — the metal corrodes and crumbles!"))
		playsound(D, 'sound/scp/106/wall_decay.ogg', 60, TRUE)
		addtimer(CALLBACK(D, /obj/machinery/door/proc/open, TRUE), 2 SECONDS)
	else if(istype(target, /obj/structure))
		var/obj/structure/S = target
		S.visible_message(span_danger("[src] touches [S] — it decays before your eyes!"))
		playsound(S, 'sound/scp/106/decay2.ogg', 50, TRUE)
		S.take_damage(80)

/mob/living/scp/scp106/proc/corrode_containment_wall(turf/closed/wall/scp_containment/target)
	if(corrosion_system?.corrosion_cooldown > 0)
		to_chat(src, span_warning("Your corrosive touch is still recharging."))
		return
	corrosion_system.corrosion_cooldown = 15 SECONDS
	corrosion_system.last_corrosion = world.time
	try_scp_corrode_wall(src, target, corrosion_system.corrosion_potency)

/mob/living/scp/scp106/proc/enter_pocket_dimension()
	if(in_pocket_dimension)
		return FALSE
	if(!pocket_dimension_system)
		return FALSE

	var/dimension_id = pocket_dimension_system.create_pocket_dimension()
	if(!dimension_id)
		to_chat(src, span_warning("You cannot create a pocket dimension right now."))
		return FALSE

	in_pocket_dimension = TRUE
	pocket_dimension_turf = get_turf(src)
	visible_message(span_danger("[src] sinks into the floor, vanishing from sight!"), \
		span_notice("You sink into your pocket dimension. The darkness embraces you."))
	playsound(src, 'sound/scp/106/decay3.ogg', 50, TRUE)

	var/area/pocket = locate(/area/scp/pocket_dimension) in world
	if(pocket)
		var/list/turfs = list()
		for(var/turf/open/T in pocket)
			turfs += T
		if(length(turfs))
			forceMove(pick(turfs))
	else
		var/turf/target = pocket_dimension_turf
		forceMove(target)
		in_pocket_dimension = FALSE

	return TRUE

/mob/living/scp/scp106/proc/exit_pocket_dimension()
	if(!in_pocket_dimension)
		return FALSE

	in_pocket_dimension = FALSE

	var/turf/exit_loc = pocket_dimension_turf
	if(!exit_loc || exit_loc.density)
		exit_loc = find_nearby_open_turf()

	if(exit_loc)
		forceMove(exit_loc)
		visible_message(span_danger("[src] rises from the floor, black ooze dripping from its form!"), \
			span_notice("You emerge from your pocket dimension."))
		playsound(src, 'sound/scp/106/decay3.ogg', 60, TRUE)
		leave_corrosion_pool(exit_loc)
		return TRUE

	in_pocket_dimension = TRUE
	return FALSE

/mob/living/scp/scp106/proc/find_nearby_open_turf()
	for(var/turf/open/T in range(5, pocket_dimension_turf || src))
		if(!T.density)
			return T
	return null

/mob/living/scp/scp106/proc/drag_victim(mob/living/carbon/human/victim)
	if(!victim || victim.stat == DEAD)
		return
	if(get_dist(src, victim) > 1)
		to_chat(src, span_warning("They are too far away to grab."))
		return
	if(in_pocket_dimension)
		return

	victim.visible_message(span_danger("[src] drags [victim] downward into the floor!"), \
		span_userdanger("[src] pulls you into the floor! Darkness swallows you whole!"))
	playsound(victim, 'sound/scp/106/decay1.ogg', 60, TRUE)
	playsound(src, 'sound/scp/106/laugh.ogg', 40, TRUE)

	on_pocket_capture(victim)

	var/turf/target_turf = get_turf(victim)
	if(target_turf)
		leave_corrosion_pool(target_turf)

	if(victim.sanity)
		victim.sanity.adjust_sanity(-30, "scp106_pocket_drag")
	victim.adjustBruteLoss(15)

	if(pocket_dimension_system && length(pocket_dimension_system.active_dimensions))
		var/dim_id = null
		for(var/key in pocket_dimension_system.active_dimensions)
			dim_id = key
			break
		pocket_dimension_system.drag_victim_to_dimension(victim, dim_id)

/mob/living/scp/scp106/proc/on_breach()
	hook_scp_breach("SCP-106", src)

/mob/living/scp/scp106/proc/on_pocket_capture(mob/living/carbon/human/victim)
	if(victim && victim.ckey)
		hook_scp_interaction(victim, "SCP-106", INTERACTION_TYPE_CONTAINMENT, list("captured" = TRUE))

/mob/living/scp/scp106/proc/on_pocket_escape(mob/living/carbon/human/escapee)
	if(escapee && escapee.ckey)
		hook_scp_interaction(escapee, "SCP-106", INTERACTION_TYPE_SURVIVAL, list("escaped" = TRUE))

/mob/living/scp/scp106/proc/on_corrosion_use(mob/living/target)
	if(target && ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.ckey)
			hook_scp_combat(H, "SCP-106", 25, 0)

/mob/living/scp/scp106/proc/toggle_corrosion(on)
	corrosion_active = on

/mob/living/scp/scp106/get_status_tab_items()
	var/list/status_items = ..()
	if(phasing_system)
		status_items += "Dimensional Energy: [phasing_system.dimensional_energy]/[phasing_system.max_dimensional_energy]"
	if(corrosion_system)
		var/cd_remaining = max(0, corrosion_system.corrosion_cooldown - world.time + corrosion_system.last_corrosion)
		status_items += "Corrosion Cooldown: [cd_remaining > 0 ? "[round(cd_remaining/10, 0.1)]s" : "Ready"]"
	status_items += "Pocket Dimension: [in_pocket_dimension ? "INSIDE" : "Outside"]"
	return status_items

/obj/effect/scp106_residue
	name = "dark residue"
	desc = "A pool of thick, black substance. It seems to eat away at whatever it touches."
	icon = 'icons/effects/effects.dmi'
	icon_state = "greenglow"
	color = "#1a0a0a"
	layer = ABOVE_OPEN_TURF_LAYER
	anchored = TRUE
	var/linger_time = 0
	var/damage_amount = 3
	var/last_damage_tick = 0
	var/damage_interval = 2 SECONDS

/obj/effect/scp106_residue/Initialize(mapload)
	. = ..()
	linger_time = world.time + 45 SECONDS
	START_PROCESSING(SSobj, src)

/obj/effect/scp106_residue/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/scp106_residue/process()
	if(world.time >= linger_time)
		qdel(src)
		return
	if(world.time < last_damage_tick + damage_interval)
		return
	last_damage_tick = world.time
	for(var/mob/living/carbon/human/H in get_turf(src))
		if(H.stat == DEAD || H.SCP)
			continue
		H.adjustBruteLoss(damage_amount)
		H.adjustToxLoss(damage_amount * 0.5)
		if(H.sanity)
			H.sanity.adjust_sanity(-2, "scp106_residue")
		if(prob(10))
			to_chat(H, span_warning("The black ooze burns your feet!"))
