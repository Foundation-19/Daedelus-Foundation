/mob/living/scp/scp457
	name = "SCP-457"
	desc = "A living flame that moves with purpose and spreads with intent."
	icon = 'icons/scp/scp-457.dmi'
	icon_state = "fireguy"
	persistence_id = "SCP-457"


	var/datum/scp457_heat_system/heat_system
	var/datum/scp457_fire_system/fire_system
	var/datum/scp457_containment_system/containment_system
	var/datum/scp457_environmental_system/environmental_system
	var/datum/scp457_research_integration/research_integration

/mob/living/scp/scp457/Initialize()
	. = ..()

	SCP = new /datum/scp(
		src,
		"SCP-457",
		SCP_KETER,
		"457",
		SCP_PLAYABLE
	)

	SCP.min_playercount = 20
	SCP.min_time = 30 MINUTES

	maxHealth = SCP457_MAX_HEALTH
	health = maxHealth


	heat_system = new /datum/scp457_heat_system(src)
	fire_system = new /datum/scp457_fire_system(src)
	containment_system = new /datum/scp457_containment_system(src)
	environmental_system = new /datum/scp457_environmental_system(src)
	research_integration = new /datum/scp457_research_integration(src)

	fovangle = FOV_DEFAULT
	update_fov_angles()
	update_cone_show()


	addtimer(CALLBACK(fire_system, TYPE_PROC_REF(/datum/scp457_fire_system, create_initial_fires)), 1)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_move_absorb_fires))

/mob/living/scp/scp457/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE)
	return

/mob/living/scp/scp457/adjust_fire_stacks(stacks, fire_type)
	return

/mob/living/scp/scp457/set_fire_stacks(stacks, fire_type, remove_wet_stacks = TRUE)
	return

/mob/living/scp/scp457/ignite_mob()
	return

/mob/living/scp/scp457/on_fire_stack(delta_time, times_fired, datum/status_effect/fire_handler/fire_stacks/fire_handler)
	return

/mob/living/scp/scp457/fire_act(exposed_temperature, exposed_volume)
	heat_system?.add_heat(exposed_temperature * 0.01)

/mob/living/scp/scp457/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE)
	if(amount > 0 && !forced)
		amount *= SCP457_BRUTE_MOD
	return ..(amount, updating_health, forced)

/mob/living/scp/scp457/Destroy()
	QDEL_NULL(heat_system)
	QDEL_NULL(fire_system)
	QDEL_NULL(containment_system)
	QDEL_NULL(environmental_system)
	QDEL_NULL(research_integration)
	return ..()

/mob/living/scp/scp457/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(.)
		return

	heat_system?.process()
	fire_system?.process()
	containment_system?.process()
	environmental_system?.process()
	research_integration?.process()
	process_scp457_effects()

	if(prob(15))
		absorb_fires_in_range(0)

/mob/living/scp/scp457/proc/process_scp457_effects()
	update_scp457_appearance()
	process_movement_effects()
	process_target_interaction()
	if(prob(5))
		playsound(src, 'sound/effects/comfyfire.ogg', 20, TRUE, extrarange = 5)

/mob/living/scp/scp457/proc/update_scp457_appearance()
	icon_state = "fireguy"
	var/heat_level = heat_system.get_heat_percentage()

	switch(heat_level)
		if(0 to 25)
			add_atom_colour("#FF6600", FIXED_COLOUR_PRIORITY)
		if(25 to 50)
			add_atom_colour("#FF3300", FIXED_COLOUR_PRIORITY)
		if(50 to 75)
			add_atom_colour("#0066FF", FIXED_COLOUR_PRIORITY)
		if(75 to INFINITY)
			add_atom_colour("#FFFFFF", FIXED_COLOUR_PRIORITY)

/mob/living/scp/scp457/proc/process_movement_effects()
	if(heat_system.current_heat > 25)
		var/turf/current_turf = get_turf(src)
		if(current_turf && !(locate(/obj/effect/scp457_fire) in current_turf))
			fire_system.create_fire_at_turf(current_turf)
			playsound(src, 'sound/items/modsuit/flamethrower.ogg', 25, TRUE)

/mob/living/scp/scp457/proc/process_target_interaction()
	for(var/mob/living/carbon/human/H in range(2, src))
		if(H != src && !H.SCP && H.stat != DEAD && !QDELETED(H))
			if(fovangle && can_see_cone(H))
				attempt_target_consumption(H)

/mob/living/scp/scp457/proc/attempt_target_consumption(mob/living/carbon/human/target)
	if(target.stat == DEAD || QDELETED(target))
		return

	var/damage = heat_system.get_fire_type() == "white" ? 25 : 15

	if(!QDELETED(target) && target.stat != DEAD)
		target.adjustFireLoss(damage)
		target.adjustBruteLoss(damage / 2)

	heat_system.add_heat(5)

	if(target.stat == DEAD)
		to_chat(src, "<span class='notice'>You consume [target] with your flames. Heat: [heat_system.current_heat]/[heat_system.max_heat]</span>")
		playsound(src, 'sound/magic/fireball.ogg', 60, TRUE)

/mob/living/scp/scp457/proc/is_spreading_fires()
	return length(fire_system.active_fires) > 0

/mob/living/scp/scp457/UnarmedAttack(atom/A)
	if(isliving(A))
		var/mob/living/L = A

		if(QDELETED(L))
			return

		var/damage = 20 + (heat_system.current_heat / 10)

		if(!QDELETED(L) && L.stat != DEAD)
			visible_message("<span class='danger'>[src] engulfs [L] in intense flames!</span>")
		playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)

		L.adjustBruteLoss(damage)
		L.adjustFireLoss(damage)

		heat_system.add_heat(3)
		if(L.stat == DEAD && istype(L, /mob/living/carbon/human))
			to_chat(src, "<span class='notice'>Your flames consume [L].</span>")
		return

	return ..()

/mob/living/scp/scp457/proc/create_fire()
	if(fire_system)
		fire_system.create_initial_fires()

/mob/living/scp/scp457/get_status_tab_items()
	. = ..()
	. += "Heat Level: [heat_system.current_heat]/[heat_system.max_heat]"
	. += "Fire Type: [heat_system.get_fire_type()]"
	. += "Active Fires: [length(fire_system.active_fires)]"
	. += "Containment Level: [containment_system.containment_level]"

/mob/living/scp/scp457/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-457, a living flame that spreads and consumes.</span>")
		else
			to_chat(user, "<span class='danger'>A living flame that moves with purpose. The heat radiating from it is intense and unnatural.</span>")

			if(H.sanity)
				H.sanity.add_trauma(TRAUMA_PSYCHOLOGICAL, 5)

/mob/living/scp/scp457/proc/get_persistence_data()
	var/list/data = list()
	data["current_heat"] = heat_system.current_heat
	data["current_containment_level"] = containment_system.containment_level
	return data

/mob/living/scp/scp457/proc/load_persistence_data(list/data)
	if(!data)
		return

/mob/living/scp/scp457/proc/contribute_research_data()
	if(!SSresearch_persistence || !SSresearch_persistence.manager)
		return

	var/project_name = "SCP-457 Behavioral Analysis"
	var/project_description = "Analysis of SCP-457's fire spreading patterns"
	var/research_field = "SCP-457_BEHAVIORAL"
	var/lead_researcher = "System"

	var/datum/research_persistence_project/project = SSresearch_persistence.manager.add_research_project(
		project_name,
		project_description,
		research_field,
		lead_researcher,
		1000,
		1
	)

	if(project)
		project.progress = min(100, length(fire_system.active_fires) + (heat_system.current_heat / 10))

		if(project.progress >= 100)
			project.status = "COMPLETED"

			SSresearch_persistence.manager.add_scientific_discovery(
				"SCP-457 Behavior Patterns",
				"Comprehensive analysis of SCP-457's fire spreading mechanics",
				"SCP_RESEARCH",
				"SCP-457",
				"System",
				3
			)

/mob/living/scp/scp457/proc/on_fire_spread(turf/location)
	if(!location)
		return
	hook_scp_breach("SCP-457", src)
	hook_facility_damage_near_scp("SCP-457", 1)

/mob/living/scp/scp457/proc/on_target_consumption(mob/living/carbon/human/victim)
	if(!victim)
		return
	hook_scp_combat(victim, "SCP-457", 100, 0)
	hook_player_death_near_scp(victim, "SCP-457")

/mob/living/scp/scp457/proc/on_move_absorb_fires()
	SIGNAL_HANDLER
	absorb_fires_in_range(1)

/mob/living/scp/scp457/proc/absorb_fires_in_range(range_val = 1)
	var/absorbed = 0
	var/turf/T = get_turf(src)
	if(!T)
		return

	for(var/obj/effect/hotspot/HS in range(range_val, T))
		var/heat_gain = max(1, HS.temperature ? HS.temperature * 0.005 : 2)
		heat_system?.add_heat(heat_gain)
		qdel(HS)
		absorbed++

	for(var/obj/structure/bonfire/B in range(range_val, T))
		if(B.burning)
			heat_system?.add_heat(8)
			B.extinguish()
			absorbed++

	for(var/mob/living/L in range(range_val, T))
		if(L == src)
			continue
		if(L.on_fire)
			var/stolen = L.fire_stacks
			heat_system?.add_heat(max(1, stolen * 2))
			L.extinguish_mob()
			L.adjust_fire_stacks(-stolen)
			absorbed++

	if(absorbed > 0)
		heat_system?.add_heat(absorbed * 2)
		visible_message(span_danger("[src] absorbs the nearby flames into itself!"))
		playsound(src, 'sound/items/modsuit/flamethrower.ogg', 40, TRUE)


