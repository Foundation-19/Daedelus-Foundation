// SCP-610 - The Hideous Without
// A highly contagious dermal infection that transforms organic matter into fleshy biomass
// Classified Keter; spreads via contact, creates hostile flesh creatures and structures

// ============================================================================
// SCP-610 CONTAINMENT BOTTLE
// ============================================================================

/obj/item/reagent_containers/glass/bottle/scp610
	name = "SCP-610"
	desc = "A sealed biocontainment vessel holding a sample of SCP-610. The flesh inside pulses with malign intent."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle4"
	var/containment_breached = FALSE
	var/list/infected_targets = list()
	var/session_start_time = 0
	var/containment_status = "contained"
	var/total_infections = 0
	var/spread_radius = 0

	var/datum/scp610_infection_system/infection_system
	var/datum/scp610_spread_system/spread_system

/obj/item/reagent_containers/glass/bottle/scp610/Initialize()
	. = ..()

	SCP = new /datum/scp(
		src,
		"SCP-610",
		SCP_KETER,
		"610"
	)

	infection_system = new /datum/scp610_infection_system(src)
	spread_system = new /datum/scp610_spread_system(src)
	session_start_time = world.time
	START_PROCESSING(SSobj, src)

/obj/item/reagent_containers/glass/bottle/scp610/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(infection_system)
	QDEL_NULL(spread_system)
	QDEL_NULL(SCP)
	infected_targets.Cut()
	return ..()

/obj/item/reagent_containers/glass/bottle/scp610/process()
	infection_system?.tick_infections()

/obj/item/reagent_containers/glass/bottle/scp610/attack_self(mob/user)
	if(containment_breached)
		to_chat(user, span_warning("The containment vessel is already open!"))
		return

	if(!isliving(user))
		return

	var/mob/living/L = user
	var/obj/item/I = L.get_active_held_item()
	if(I != src)
		return

	containment_breached = TRUE
	visible_message(span_danger("[user] breaks the seal on [src]! A horrible organic stench fills the air."))
	containment_status = "breached"

	var/turf/T = get_turf(src)
	spread_system.begin_spread(T)

	var/obj/structure/scp610_core/core = new(T)
	core.source_bottle = src
	core.activate()
	SSscp610.cores += core

/obj/item/reagent_containers/glass/bottle/scp610/attack(mob/living/target, mob/living/user)
	if(!containment_breached)
		to_chat(user, span_warning("The containment vessel is sealed. You must break the seal first."))
		return ..()

	if(!isliving(target) || target.stat == DEAD)
		return ..()

	infection_system?.attempt_infection(target, 80)
	visible_message(span_danger("[user] splashes the contents of [src] onto [target]!"))
	to_chat(target, span_userdanger("You feel a burning sensation as the flesh touches your skin!"))
	return ..()

/obj/item/reagent_containers/glass/bottle/scp610/examine(mob/user)
	. = ..()
	if(containment_breached)
		. += span_danger("The seal has been broken. The sample is exposed.")
	else
		. += span_notice("The biocontainment seal is intact.")

// ============================================================================
// SCP-610 INFECTION SYSTEM
// ============================================================================

/datum/scp610_infection_system
	var/obj/item/reagent_containers/glass/bottle/scp610/owner
	var/list/infected_mobs = list()
	var/infection_stages = list(
		"stage_1" = 60 SECONDS,
		"stage_2" = 90 SECONDS,
		"stage_3" = 120 SECONDS
	)

/datum/scp610_infection_system/New(obj/item/reagent_containers/glass/bottle/scp610/source)
	owner = source

/datum/scp610_infection_system/Destroy()
	owner = null
	infected_mobs.Cut()
	return ..()

/datum/scp610_infection_system/proc/attempt_infection(mob/living/carbon/human/target, probability = 40)
	if(!istype(target) || target.stat == DEAD)
		return FALSE

	if(target in infected_mobs)
		return FALSE

	if(prob(probability))
		infect_target(target)
		return TRUE

	to_chat(target, span_warning("Your skin tingles where the substance touched, but the sensation fades."))
	return FALSE

/datum/scp610_infection_system/proc/infect_target(mob/living/carbon/human/target)
	if(!target || target.stat == DEAD)
		return

	infected_mobs += target
	owner?.total_infections++

	to_chat(target, span_userdanger("Your skin begins to itch and burn terribly! Something is growing inside you..."))
	target.visible_message(span_warning("[target] scratches at their skin frantically!"))

	target.adjustBruteLoss(5)

	addtimer(CALLBACK(src, PROC_REF(progress_infection), target, "stage_1"), infection_stages["stage_1"])

/datum/scp610_infection_system/proc/progress_infection(mob/living/carbon/human/target, stage)
	if(!target || target.stat == DEAD || !(target in infected_mobs))
		return

	switch(stage)
		if("stage_1")
			to_chat(target, span_userdanger("Your flesh is swelling and shifting! Horrible lumps are forming under your skin!"))
			target.adjustBruteLoss(10)
			target.adjustToxLoss(15)
			target.visible_message(span_danger("[target]'s skin is covered in hideous boils and lumps!"))

			addtimer(CALLBACK(src, PROC_REF(progress_infection), target, "stage_2"), infection_stages["stage_2"])

		if("stage_2")
			to_chat(target, span_userdanger("The flesh is consuming you! Your body is no longer your own!"))
			target.adjustBruteLoss(20)
			target.adjustToxLoss(25)

			var/mob/living/simple_animal/hostile/scp610_half_infested/half = new(get_turf(target))
			half.name = "[target.name] (Half-Infested)"

			target.visible_message(span_danger("[target]'s body is being consumed by pulsating flesh!"))

			addtimer(CALLBACK(src, PROC_REF(progress_infection), target, "stage_3"), infection_stages["stage_3"])

		if("stage_3")
			transform_target(target)

/datum/scp610_infection_system/proc/transform_target(mob/living/carbon/human/target)
	if(!target || target.stat == DEAD)
		if(target in infected_mobs)
			infected_mobs -= target
		return

	var/turf/T = get_turf(target)
	if(!T)
		return

	var/roll = rand(1, 100)
	var/mob/living/simple_animal/hostile/flesh_mob

	if(roll <= 50)
		flesh_mob = new /mob/living/simple_animal/hostile/scp610_fleshman(T)
	else
		flesh_mob = new /mob/living/simple_animal/hostile/scp610_flesh_walker(T)

	if(flesh_mob)
		flesh_mob.name = "[target.name] (Flesh)"
		flesh_mob.desc = "What was once [target.name], now consumed by SCP-610."
		var/obj/structure/scp610_core/core = locate() in range(7, T)
		if(core)
			core.register_flesh_mob(flesh_mob)

	owner?.spread_system?.spread_flesh_turf(T)

	target.visible_message(span_danger("[target] is consumed entirely by the flesh, transforming into a hideous creature!"))
	to_chat(target, span_userdanger("Your mind dissolves into the flesh..."))

	target.ghostize()
	qdel(target)

	infected_mobs -= target

/datum/scp610_infection_system/proc/tick_infections()
	var/list/to_remove = list()
	for(var/mob/living/carbon/human/H in infected_mobs)
		if(H.stat == DEAD)
			to_remove += H
			continue
		if(prob(5))
			H.adjustBruteLoss(2)
			H.adjustToxLoss(2)
	for(var/mob/M in to_remove)
		infected_mobs -= M

// ============================================================================
// SCP-610 SPREAD SYSTEM
// ============================================================================

/datum/scp610_spread_system
	var/obj/item/reagent_containers/glass/bottle/scp610/owner
	var/list/flesh_turfs = list()
	var/list/flesh_structures = list()
	var/spread_active = FALSE
	var/spread_cooldown = 0
	var/spread_cooldown_time = 45 SECONDS
	var/max_spread_radius = 7
	var/current_spread_radius = 0
	var/flesh_node_interval = 3

/datum/scp610_spread_system/New(obj/item/reagent_containers/glass/bottle/scp610/source)
	owner = source

/datum/scp610_spread_system/Destroy()
	owner = null
	flesh_turfs.Cut()
	flesh_structures.Cut()
	return ..()

/datum/scp610_spread_system/proc/begin_spread(turf/T)
	if(!T || spread_active)
		return

	spread_active = TRUE
	flesh_turfs += T

/datum/scp610_spread_system/proc/spread_flesh_turf(turf/T)
	if(!T)
		return

	var/obj/structure/scp610_core/core = locate() in range(7, T)
	if(core)
		core.place_creep(T)

/datum/scp610_spread_system/proc/place_flesh_structure(turf/T, structure_type)
	if(!T)
		return

	var/obj/structure/S = new structure_type(T)
	flesh_structures += S

/datum/scp610_spread_system/proc/get_center_turf()
	if(!owner)
		return null
	var/obj/structure/scp610_core/core = locate() in range(20, owner)
	if(core)
		return get_turf(core)
	if(length(flesh_turfs))
		return get_turf(flesh_turfs[1])
	return null

// ============================================================================
// SCP-610 FLESH MOB - FLESHMAN
// ============================================================================

/mob/living/simple_animal/hostile/scp610_fleshman
	name = "SCP-610 Fleshman"
	desc = "A shambling mass of mutated flesh. It was once human."
	icon = 'icons/scp/newscp610/slasher.dmi'
	icon_state = "slasher"
	icon_living = "slasher"
	icon_dead = "slasher"
	icon_gib = "slasher"

	maxHealth = 150
	health = 150

	melee_damage_lower = 18
	melee_damage_upper = 28
	attack_sound = 'sound/hallucinations/growl1.ogg'

	move_to_delay = 5
	environment_smash = 1
	obj_damage = 25

	faction = list("scp610")
	del_on_death = TRUE

	var/infection_chance = 30
	var/infection_cooldown = 0
	var/infection_cooldown_time = 20 SECONDS

/mob/living/simple_animal/hostile/scp610_fleshman/Initialize()
	. = ..()
	AIStatus = AI_ON
	START_PROCESSING(SSobj, src)

/mob/living/simple_animal/hostile/scp610_fleshman/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/mob/living/simple_animal/hostile/scp610_fleshman/process()
	if(stat == DEAD)
		return

	if(world.time >= infection_cooldown)
		attempt_nearby_infection()
		infection_cooldown = world.time + infection_cooldown_time

/mob/living/simple_animal/hostile/scp610_fleshman/proc/attempt_nearby_infection()
	for(var/mob/living/carbon/human/H in range(1, src))
		if(H.stat == DEAD)
			continue
		if(H.SCP)
			continue
		if(prob(infection_chance))
			visible_message(span_danger("[src] grabs [H] with its fleshy appendages!"))
			scp610_infect(H, 60)
			break

/mob/living/simple_animal/hostile/scp610_fleshman/AttackingTarget()
	. = ..()
	if(. && ishuman(target) && prob(infection_chance))
		var/mob/living/carbon/human/H = target
		scp610_infect(H, 40)

/mob/living/simple_animal/hostile/scp610_fleshman/examine(mob/user)
	. = ..()
	if(iscarbon(user) && get_dist(user, src) <= 2)
		. += span_warning("The flesh on this creature writhes and pulses with unnatural life. Do not touch it.")

// ============================================================================
// SCP-610 FLESH MOB - FLESHWALKER
// ============================================================================

/mob/living/simple_animal/hostile/scp610_flesh_walker
	name = "SCP-610 Fleshwalker"
	desc = "A horrifying abomination of flesh and bone, moving on spiky protrusions with terrifying speed."
	icon = 'icons/scp/newscp610/leaper.dmi'
	icon_state = "leaper"
	icon_living = "leaper"
	icon_dead = "leaper"
	icon_gib = "leaper"

	maxHealth = 100
	health = 100

	melee_damage_lower = 25
	melee_damage_upper = 40
	attack_sound = 'sound/hallucinations/growl2.ogg'

	move_to_delay = 3
	environment_smash = 2
	obj_damage = 35

	faction = list("scp610")
	del_on_death = TRUE

	var/infection_chance = 45
	var/infection_cooldown = 0
	var/infection_cooldown_time = 15 SECONDS

/mob/living/simple_animal/hostile/scp610_flesh_walker/Initialize()
	. = ..()
	AIStatus = AI_ON
	START_PROCESSING(SSobj, src)

/mob/living/simple_animal/hostile/scp610_flesh_walker/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/mob/living/simple_animal/hostile/scp610_flesh_walker/process()
	if(stat == DEAD)
		return

	if(world.time >= infection_cooldown)
		attempt_nearby_infection()
		infection_cooldown = world.time + infection_cooldown_time

/mob/living/simple_animal/hostile/scp610_flesh_walker/proc/attempt_nearby_infection()
	for(var/mob/living/carbon/human/H in range(1, src))
		if(H.stat == DEAD)
			continue
		if(H.SCP)
			continue
		if(prob(infection_chance))
			visible_message(span_danger("[src] impales [H] with a spiky protrusion!"))
			scp610_infect(H, 70)
			break

/mob/living/simple_animal/hostile/scp610_flesh_walker/AttackingTarget()
	. = ..()
	if(. && ishuman(target) && prob(infection_chance))
		var/mob/living/carbon/human/H = target
		scp610_infect(H, 50)

/mob/living/simple_animal/hostile/scp610_flesh_walker/examine(mob/user)
	. = ..()
	if(iscarbon(user) && get_dist(user, src) <= 2)
		. += span_danger("Its spiky legs twitch with predatory anticipation. Getting closer would be fatal.")

// ============================================================================
// SCP-610 FLESH MOB - HALF-INFESTED
// ============================================================================

/mob/living/simple_animal/hostile/scp610_half_infested
	name = "SCP-610 Half-Infested"
	desc = "A human being consumed by SCP-610. Flesh bubbles and writhes across half their body."
	icon = 'icons/scp/newscp610/puker.dmi'
	icon_state = "puker"
	icon_living = "puker"
	icon_dead = "puker"

	maxHealth = 80
	health = 80

	melee_damage_lower = 10
	melee_damage_upper = 18
	attack_sound = 'sound/hallucinations/growl1.ogg'

	move_to_delay = 6
	environment_smash = 0
	obj_damage = 10

	faction = list("scp610")

	var/transform_timer = 120 SECONDS
	var/infection_chance = 20

/mob/living/simple_animal/hostile/scp610_half_infested/Initialize()
	. = ..()
	AIStatus = AI_ON
	START_PROCESSING(SSobj, src)
	addtimer(CALLBACK(src, PROC_REF(complete_transformation)), transform_timer)

/mob/living/simple_animal/hostile/scp610_half_infested/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/mob/living/simple_animal/hostile/scp610_half_infested/process()
	if(stat == DEAD)
		return

	if(prob(3))
		visible_message(span_warning("[src] groans in agony as the flesh continues to consume them..."))

	if(prob(infection_chance))
		for(var/mob/living/carbon/human/H in range(1, src))
			if(H.stat != DEAD && !H.SCP)
				scp610_infect(H, 25)
				break

/mob/living/simple_animal/hostile/scp610_half_infested/proc/complete_transformation()
	if(stat == DEAD)
		return

	var/turf/T = get_turf(src)
	if(!T)
		return

	var/roll = rand(1, 100)
	var/mob/living/simple_animal/hostile/flesh_mob

	if(roll <= 60)
		flesh_mob = new /mob/living/simple_animal/hostile/scp610_fleshman(T)
	else
		flesh_mob = new /mob/living/simple_animal/hostile/scp610_flesh_walker(T)

	if(flesh_mob)
		flesh_mob.name = "[name] (Fully Infested)"
		var/obj/structure/scp610_core/core = locate() in range(7, T)
		if(core)
			core.register_flesh_mob(flesh_mob)

	visible_message(span_danger("[src] is fully consumed by the flesh, transforming into [flesh_mob]!"))
	qdel(src)

/mob/living/simple_animal/hostile/scp610_half_infested/AttackingTarget()
	. = ..()
	if(. && ishuman(target) && prob(infection_chance))
		var/mob/living/carbon/human/H = target
		scp610_infect(H, 30)

// ============================================================================
// SCP-610 INFECTION HELPER PROC
// ============================================================================

/proc/scp610_infect(mob/living/carbon/human/target, probability = 40)
	if(!istype(target) || target.stat == DEAD)
		return FALSE

	if(target.SCP)
		return FALSE

	if(!prob(probability))
		to_chat(target, span_warning("Your skin tingles where the flesh touched you, but the sensation fades."))
		return FALSE

	to_chat(target, span_userdanger("SCP-610 is infecting you! Your skin burns and crawls!"))
	target.visible_message(span_warning("[target] begins scratching at their skin frantically!"))

	var/datum/status_effect/scp610_infection/effect = target.apply_status_effect(/datum/status_effect/scp610_infection)
	if(effect)
		effect.infection_strength = probability
		return TRUE

	return FALSE

// ============================================================================
// SCP-610 INFECTION STATUS EFFECT
// ============================================================================

/datum/status_effect/scp610_infection
	id = "scp610_infection"
	duration = -1
	tick_interval = 10 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/scp610_infection
	var/infection_strength = 40
	var/infection_progress = 0
	var/max_progress = 100
	var/stage = 1

/datum/status_effect/scp610_infection/on_apply()
	. = ..()
	to_chat(owner, span_userdanger("SCP-610 has infected you! Seek medical attention immediately!"))
	if(owner)
		owner.log_message("has been infected with SCP-610", LOG_ATTACK)

/datum/status_effect/scp610_infection/on_remove()
	. = ..()
	if(owner)
		owner.log_message("has been cured of SCP-610 infection", LOG_ATTACK)

/datum/status_effect/scp610_infection/tick()
	if(!owner || owner.stat == DEAD)
		qdel(src)
		return

	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		qdel(src)
		return

	infection_progress += rand(2, 5)

	switch(infection_progress)
		if(0 to 24)
			if(stage < 1)
				stage = 1
			if(prob(10))
				to_chat(H, span_warning("Your skin itches intolerably..."))
				H.adjustBruteLoss(1)

		if(25 to 49)
			if(stage < 2)
				stage = 2
				to_chat(H, span_userdanger("Your flesh is swelling and shifting!"))
				H.visible_message(span_warning("[H]'s skin begins to bubble and distort!"))
			if(prob(15))
				H.adjustBruteLoss(3)
				H.adjustToxLoss(3)

		if(50 to 74)
			if(stage < 3)
				stage = 3
				to_chat(H, span_userdanger("The flesh is taking over your body!"))
				H.visible_message(span_danger("[H] is being consumed by pulsating flesh!"))
			if(prob(20))
				H.adjustBruteLoss(5)
				H.adjustToxLoss(5)
				H.setStaminaLoss(50)

		if(75 to 100)
			if(stage < 4)
				stage = 4
				to_chat(H, span_userdanger("You can feel the flesh consuming your mind!"))
			H.adjustBruteLoss(5)
			H.adjustToxLoss(5)

	if(infection_progress >= max_progress)
		complete_transformation(H)

/datum/status_effect/scp610_infection/proc/complete_transformation(mob/living/carbon/human/H)
	if(!H || H.stat == DEAD)
		qdel(src)
		return

	var/turf/T = get_turf(H)
	if(!T)
		qdel(src)
		return

	var/roll = rand(1, 100)
	var/mob/living/simple_animal/hostile/flesh_mob

	if(roll <= 50)
		flesh_mob = new /mob/living/simple_animal/hostile/scp610_fleshman(T)
	else
		flesh_mob = new /mob/living/simple_animal/hostile/scp610_flesh_walker(T)

	if(flesh_mob)
		flesh_mob.name = "[H.name] (Flesh)"
		flesh_mob.desc = "What was once [H.name], now consumed by SCP-610."

	var/obj/structure/scp610_core/core = locate() in range(7, T)
	if(core)
		core.place_creep(T)
		if(flesh_mob)
			core.register_flesh_mob(flesh_mob)

	H.visible_message(span_danger("[H] is consumed entirely by the flesh, transforming into a hideous creature!"))
	to_chat(H, span_userdanger("Your mind dissolves into the flesh..."))

	H.ghostize()
	qdel(H)
	qdel(src)

/atom/movable/screen/alert/status_effect/scp610_infection
	name = "SCP-610 Infection"
	desc = "Flesh is growing across your body. Seek immediate medical attention."
	icon_state = "button_fleshhate"

// ============================================================================
// SCP-610 FLESH TURFS (legacy — for manual map placement; auto-bridges to new creep system)
// ============================================================================

/turf/open/flesh
	name = "flesh creep"
	desc = "The ground is covered in a thin layer of pulsating flesh. It's warm to the touch."
	icon = 'icons/scp/newscp610/flesh_tile.dmi'
	icon_state = "flesh_tile-0"
	footstep = FOOTSTEP_MEAT
	barefootstep = FOOTSTEP_MEAT
	clawfootstep = FOOTSTEP_MEAT
	heavyfootstep = FOOTSTEP_MEAT

	var/infection_chance = 5
	var/last_infection_check = 0
	var/infection_check_interval = 30 SECONDS

/turf/open/flesh/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/turf/open/flesh/LateInitialize()
	START_PROCESSING(SSobj, src)

/turf/open/flesh/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/turf/open/flesh/process()
	if(world.time < last_infection_check + infection_check_interval)
		return

	last_infection_check = world.time

	for(var/mob/living/carbon/human/H in contents)
		if(H.stat == DEAD || H.SCP)
			continue
		if(prob(infection_chance))
			scp610_infect(H, 10)

/turf/open/flesh/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(!isliving(arrived))
		return

	var/mob/living/L = arrived
	if(iscarbon(L) && !L.SCP && prob(infection_chance * 2))
		scp610_infect(L, 8)

/turf/open/flesh/attackby(obj/item/I, mob/user, params)
	if(I.get_temperature() > 300)
		user.visible_message(span_notice("[user] scorches [src] with [I]!"))
		ScrapeAway()
		return
	return ..()

/turf/open/flesh/node
	name = "flesh node"
	desc = "A thick knot of flesh and sinew. It seems to be the source of the creeping growth."
	icon_state = "flesh_tile-0"
	infection_chance = 15
	slowdown = 1

/turf/open/flesh/node/process()
	. = ..()

	if(world.time < last_infection_check + infection_check_interval)
		return

	for(var/turf/T in RANGE_TURFS(1, src))
		if(T.scp610_corrupted)
			continue
		if(T.density)
			continue
		if(prob(8))
			var/obj/structure/scp610_core/core = locate() in range(7, src)
			if(core)
				core.place_creep(T)

// ============================================================================
// SCP-610 CROSS-SCP INTERACTIONS
// ============================================================================

/mob/living/simple_animal/hostile/scp610_fleshman/proc/check_scp_interactions()
	if(stat == DEAD)
		return

	for(var/mob/living/scp/scp049/doctor in range(7, src))
		if(doctor.stat != DEAD && prob(5))
			hook_scp_cross_interaction("SCP-610", "SCP-049", "049_sense_610_flesh")

/mob/living/simple_animal/hostile/scp610_flesh_walker/proc/check_scp_interactions()
	if(stat == DEAD)
		return

	for(var/mob/living/scp/scp049/doctor in range(7, src))
		if(doctor.stat != DEAD && prob(5))
			hook_scp_cross_interaction("SCP-610", "SCP-049", "049_sense_610_flesh")

/mob/living/simple_animal/hostile/scp610_fleshman/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(stat == DEAD)
		return
	if(prob(2))
		check_scp_interactions()

/mob/living/simple_animal/hostile/scp610_flesh_walker/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(stat == DEAD)
		return
	if(prob(2))
		check_scp_interactions()

// ============================================================================
// SCP-610 ANTAGONIST
// ============================================================================

/datum/antagonist/scp/scp610
	name = "SCP-610"
	roundend_category = "SCP-610"
	job_rank = ROLE_SCP610
	scp_id = "610"

/datum/antagonist/scp/scp610/forge_scp_objectives()
	var/datum/objective/scp_spread_infection/obj = new
	obj.owner = owner
	objectives += obj

/datum/objective/scp_spread_infection
	name = "spread infection"
	explanation_text = "Spread SCP-610 to at least 3 living hosts, creating flesh creatures."

/datum/objective/scp_spread_infection/check_completion()
	var/infected_count = 0
	for(var/mob/living/simple_animal/hostile/scp610_fleshman/F in GLOB.mob_list)
		infected_count++
	for(var/mob/living/simple_animal/hostile/scp610_flesh_walker/W in GLOB.mob_list)
		infected_count++
	for(var/mob/living/simple_animal/hostile/scp610_half_infested/H in GLOB.mob_list)
		infected_count++

	if(infected_count >= 3)
		return TRUE
	return FALSE

// ============================================================================
// SCP-610 RESEARCH INTEGRATION
// ============================================================================

/obj/item/reagent_containers/glass/bottle/scp610/proc/on_research_interaction(mob/user, interaction_type)
	if(!SCP)
		return

	switch(interaction_type)
		if("sample_analysis")
			SCP.award_research(user, "biology", 15)
			to_chat(user, span_notice("You carefully extract a microscopic sample from [src]."))

		if("containment_protocol")
			SCP.award_research(user, "containment", 10)
			to_chat(user, span_notice("You document the containment requirements for SCP-610."))

		if("infection_study")
			if(containment_breached)
				SCP.award_research(user, "biology", 25)
				to_chat(user, span_notice("You study the active infection patterns of SCP-610."))
			else
				to_chat(user, span_warning("You need a breach to study active infection patterns."))

/obj/item/reagent_containers/glass/bottle/scp610/proc/on_containment_breach()
	hook_scp_breach("SCP-610", src)
	containment_status = "breached"

/obj/item/reagent_containers/glass/bottle/scp610/proc/on_recontainment()
	hook_scp_recontainment("SCP-610", list())
	containment_status = "contained"
	containment_breached = FALSE
	spread_system?.spread_active = FALSE
	for(var/obj/structure/scp610_core/core in range(7, src))
		if(core.source_bottle == src)
			qdel(core)
			break

// ============================================================================
// SCP-610 AMNESTIC CURE
// ============================================================================

/obj/item/reagent_containers/glass/bottle/scp610/proc/cure_infected(mob/living/carbon/human/target)
	if(!istype(target))
		return FALSE

	var/datum/status_effect/scp610_infection/infection = target.has_status_effect(/datum/status_effect/scp610_infection)
	if(!infection)
		return FALSE

	if(infection.infection_progress < 50)
		target.remove_status_effect(/datum/status_effect/scp610_infection)
		to_chat(target, span_notice("The burning in your flesh subsides. The infection has been purged!"))
		visible_message(span_notice("[target]'s flesh stops writhing as the treatment takes effect."))
		return TRUE
	else
		to_chat(target, span_warning("The infection has progressed too far for standard treatment!"))
		return FALSE
