/mob/living/scp/scp457
	ai_enabled = TRUE
	name = "SCP-457"
	desc = "A living flame that moves with purpose and spreads with intent."
	icon = 'icons/scp/scp-457.dmi'
	icon_state = "fireguy"
	persistence_id = "SCP-457"

	var/current_heat = SCP457_INITIAL_HEAT
	var/max_heat = SCP457_MAX_HEAT
	var/heat_generation_rate = SCP457_HEAT_GENERATION_RATE
	var/heat_decay_rate = SCP457_HEAT_DECAY_RATE
	var/heat_gain_multiplier = 1.0
	var/heat_decay_multiplier = 1.0
	var/containment_heat_penalty = 0
	var/last_heat_update = 0

	var/list/active_fires = list()
	var/spread_cooldown = 0
	var/current_fire_type = "basic"
	var/spread_range = 1
	var/max_spread_range = 5
	var/fire_creation_cooldown = 0

	var/containment_successes = 0
	var/containment_failures = 0
	var/list/fire_thresholds = list(3, 8, 15, 25)

	var/list/controlled_room_types = list()
	var/list/room_effects = list()
	var/last_environment_check = 0

	var/last_research_update = 0

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

	fovangle = FOV_DEFAULT
	update_fov_angles()
	update_cone_show()

	SetupRoomEffects()

	addtimer(CALLBACK(src, PROC_REF(CreateInitialFires)), 1)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_move_absorb_fires))

	add_verb(src, list(
		/mob/living/scp/scp457/proc/verb_hurl_fireball,
	))

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
	AddHeat(exposed_temperature * 0.01)

/mob/living/scp/scp457/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE)
	if(amount > 0 && !forced)
		amount *= SCP457_BRUTE_MOD
	return ..(amount, updating_health, forced)

/mob/living/scp/scp457/Destroy()
	CleanupFires()
	active_fires = null
	room_effects = null
	controlled_room_types = null
	return ..()

/mob/living/scp/scp457/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(.)
		return

	ProcessHeat()
	ProcessFireSpreading()
	ProcessContainment()
	ProcessEnvironmental()
	ProcessResearch()
	process_scp457_effects()

	if(prob(15))
		absorb_fires_in_range(0)

/mob/living/scp/scp457/proc/process_scp457_effects()
	update_scp457_appearance()
	process_movement_effects()
	process_target_interaction()
	if(prob(5))
		playsound(src, 'sound/effects/comfyfire.ogg', 20, TRUE, extrarange = 5)

/mob/living/scp/scp457/proc/ProcessHeat()
	if(world.time >= last_heat_update + 30 SECONDS)
		UpdateHeat()
		last_heat_update = world.time

/mob/living/scp/scp457/proc/UpdateHeat()
	if(!is_spreading_fires())
		current_heat = min(max_heat, current_heat + (heat_generation_rate * heat_gain_multiplier))

	current_heat = max(0, current_heat - (heat_decay_rate * heat_decay_multiplier))

	if(containment_heat_penalty > 0)
		current_heat = max(0, current_heat - containment_heat_penalty)
		containment_heat_penalty = max(0, containment_heat_penalty - 1)

/mob/living/scp/scp457/proc/AddHeat(amount)
	current_heat = min(max_heat, current_heat + amount)

/mob/living/scp/scp457/proc/ConsumeHeat(amount)
	current_heat = max(0, current_heat - amount)

/mob/living/scp/scp457/proc/GetHeatPercentage()
	return (current_heat / max_heat) * 100

/mob/living/scp/scp457/proc/GetFireType()
	if(current_heat <= SCP457_HEAT_THRESHOLD_BASIC)
		return "basic"
	else if(current_heat <= SCP457_HEAT_THRESHOLD_INTENSE)
		return "intense"
	else if(current_heat <= SCP457_HEAT_THRESHOLD_BLUE)
		return "blue"
	else
		return "white"

/mob/living/scp/scp457/proc/ProcessFireSpreading()
	if(world.time >= spread_cooldown + 10 SECONDS)
		ProcessFireSpread()
		spread_cooldown = world.time

	if(world.time >= fire_creation_cooldown + 5 SECONDS)
		CreateInitialFires()
		fire_creation_cooldown = world.time

/mob/living/scp/scp457/proc/ProcessFireSpread()
	var/fire_type = GetFireType()
	current_fire_type = fire_type
	var/spread_chance = (current_heat / 100) * 0.3

	for(var/obj/effect/scp457_fire/fire in active_fires)
		if(!fire || fire.loc == null)
			active_fires -= fire
			continue

		if(prob(spread_chance * 100))
			AttemptFireSpread(fire)

/mob/living/scp/scp457/proc/AttemptFireSpread(obj/effect/scp457_fire/source_fire)
	var/list/adjacent_turfs = list()

	for(var/turf/T in range(1, source_fire))
		if(CanSpreadToTurf(T))
			adjacent_turfs += T

	if(length(adjacent_turfs))
		var/turf/spread_turf = pick(adjacent_turfs)
		CreateFireAtTurf(spread_turf)
		ConsumeHeat(2)

/mob/living/scp/scp457/proc/CanSpreadToTurf(turf/T)
	if(!T || T.density)
		return FALSE
	if(locate(/obj/effect/scp457_fire) in T)
		return FALSE
	if(istype(T, /turf/closed))
		return FALSE
	return TRUE

/mob/living/scp/scp457/proc/CreateFireAtTurf(turf/T)
	if(!CanSpreadToTurf(T))
		return

	var/obj/effect/scp457_fire/new_fire = new /obj/effect/scp457_fire(T)
	new_fire.fire_type = current_fire_type
	new_fire.owner = src
	new_fire.setup_fire_properties()

	active_fires += new_fire

	track_scp457_fire_creation(src, current_fire_type, T)

	ApplyFireDamage(T)

/mob/living/scp/scp457/proc/ApplyFireDamage(turf/fire_turf)
	var/damage = GetFireDamage()

	for(var/mob/living/L in range(1, fire_turf))
		if(L != src && !L.SCP && !QDELETED(L))
			if(!QDELETED(L) && L.stat != DEAD)
				L.adjustFireLoss(damage)
				L.adjustBruteLoss(damage / 2)

/mob/living/scp/scp457/proc/GetFireDamage()
	switch(current_fire_type)
		if("basic")
			return 5
		if("intense")
			return 15
		if("blue")
			return 30
		if("white")
			return 50
		else
			return 5

/mob/living/scp/scp457/proc/CreateInitialFires()
	if(length(active_fires) < 3)
		var/list/adjacent_turfs = list()
		for(var/turf/T in range(1, src))
			if(CanSpreadToTurf(T))
				adjacent_turfs += T

		if(length(adjacent_turfs))
			var/turf/chosen_turf = pick(adjacent_turfs)
			CreateFireAtTurf(chosen_turf)

/mob/living/scp/scp457/proc/CleanupFires()
	for(var/obj/effect/scp457_fire/fire in active_fires)
		if(fire)
			qdel(fire)
	active_fires.Cut()

/mob/living/scp/scp457/proc/ProcessContainment()
	if(world.time >= last_containment_check + 15 SECONDS)
		last_containment_check = world.time
		CheckContainmentResponse()

/mob/living/scp/scp457/proc/CheckContainmentResponse()
	var/active_fire_count = length(active_fires)
	var/fire_type = GetFireType()
	var/new_containment_level = 0

	for(var/i = 1; i <= length(fire_thresholds); i++)
		if(active_fire_count >= fire_thresholds[i])
			new_containment_level = i

	if(fire_type == "blue" && new_containment_level < 3)
		new_containment_level = 3
	if(fire_type == "white" && new_containment_level < 4)
		new_containment_level = 4

	if(new_containment_level != containment_level)
		UpdateContainmentLevel(new_containment_level)

/mob/living/scp/scp457/proc/UpdateContainmentLevel(new_level)
	var/old_level = containment_level
	containment_level = new_level

	ApplyContainmentEffects(new_level)

	if(new_level > old_level)
		to_chat(src, span_warning("Containment level increased to [new_level]!"))
		containment_failures++
	else if(new_level < old_level)
		to_chat(src, span_notice("Containment level decreased to [new_level]."))
		containment_successes++
		if(new_level == 0)
			hook_scp_recontainment("SCP-457", list("method" = "fire_suppression", "fires_remaining" = length(active_fires)))

/mob/living/scp/scp457/proc/ApplyContainmentEffects(level)
	switch(level)
		if(1)
			containment_heat_penalty = 1
		if(2)
			containment_heat_penalty = 2
		if(3)
			containment_heat_penalty = 3
			log_game("SCP-457 triggered evacuation protocol")
		if(4)
			containment_heat_penalty = 5
			log_game("SCP-457 triggered breach protocol")

/mob/living/scp/scp457/proc/ProcessEnvironmental()
	if(world.time >= last_environment_check + 20 SECONDS)
		CheckEnvironmentalControl()
		last_environment_check = world.time

/mob/living/scp/scp457/proc/SetupRoomEffects()
	room_effects = list(
		"laboratory" = list("flammability" = 1.5, "containment" = 0.8, "hazard" = "chemicals"),
		"security" = list("flammability" = 0.75, "containment" = 1.2, "hazard" = "equipment"),
		"maintenance" = list("flammability" = 1.2, "containment" = 0.6, "hazard" = "machinery"),
		"command" = list("flammability" = 1.0, "containment" = 1.5, "hazard" = "critical"),
		"medical" = list("flammability" = 0.8, "containment" = 1.3, "hazard" = "oxygen"),
		"standard" = list("flammability" = 1.0, "containment" = 1.0, "hazard" = "none")
	)

/mob/living/scp/scp457/proc/CheckEnvironmentalControl()
	var/list/controlled_areas = list()

	for(var/obj/effect/scp457_fire/fire in active_fires)
		var/area/fire_area = get_area(fire)
		if(fire_area)
			controlled_areas[fire_area.type] = TRUE

	controlled_room_types = controlled_areas

/mob/living/scp/scp457/proc/ProcessResearch()
	if(world.time >= last_research_update + 120 SECONDS)
		last_research_update = world.time
		if(!SSresearch_persistence || !SSresearch_persistence.manager)
			return
		log_game("SCP-457 research data: fires=[length(active_fires)] heat=[current_heat] containment=[containment_level] rooms=[length(controlled_room_types)]")

/mob/living/scp/scp457/proc/update_scp457_appearance()
	icon_state = "fireguy"
	var/heat_level = GetHeatPercentage()

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
	if(current_heat > 25)
		var/turf/current_turf = get_turf(src)
		if(current_turf && !(locate(/obj/effect/scp457_fire) in current_turf))
			CreateFireAtTurf(current_turf)
			playsound(src, 'sound/items/modsuit/flamethrower.ogg', 25, TRUE)

/mob/living/scp/scp457/proc/process_target_interaction()
	for(var/mob/living/carbon/human/H in range(2, src))
		if(H != src && !H.SCP && H.stat != DEAD && !QDELETED(H))
			if(fovangle && can_see_cone(H))
				attempt_target_consumption(H)

/mob/living/scp/scp457/proc/attempt_target_consumption(mob/living/carbon/human/target)
	if(target.stat == DEAD || QDELETED(target))
		return

	var/damage = GetFireType() == "white" ? 25 : 15

	if(!QDELETED(target) && target.stat != DEAD)
		target.adjustFireLoss(damage)
		target.adjustBruteLoss(damage / 2)

	AddHeat(5)

	if(target.stat == DEAD)
		to_chat(src, span_notice("You consume [target] with your flames. Heat: [current_heat]/[max_heat]"))
		playsound(src, 'sound/magic/fireball.ogg', 60, TRUE)

/mob/living/scp/scp457/proc/is_spreading_fires()
	return length(active_fires) > 0

/mob/living/scp/scp457/UnarmedAttack(atom/A)
	if(isliving(A))
		var/mob/living/L = A

		if(QDELETED(L))
			return

		var/damage = 20 + (current_heat / 10)

		if(!QDELETED(L) && L.stat != DEAD)
			visible_message(span_danger("[src] engulfs [L] in intense flames!"))
		playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)

		L.adjustBruteLoss(damage)
		L.adjustFireLoss(damage)

		AddHeat(3)
		if(L.stat == DEAD && istype(L, /mob/living/carbon/human))
			to_chat(src, span_notice("Your flames consume [L]."))
		return

	if(isobj(A) && !istype(A, /obj/effect))
		ConsumeFlammable(A)
		return

	return ..()

/mob/living/scp/scp457/proc/ConsumeFlammable(atom/target)
	if(!target || istype(target, /obj/effect/scp457_fire))
		return FALSE

	var/fuel_value = GetFuelValue(target)
	if(fuel_value <= 0)
		to_chat(src, span_warning("[target] has nothing worth consuming."))
		return FALSE

	var/obj/item/I = target
	var/consume_time = 2 SECONDS
	if(istype(I) && I.w_class >= 3)
		consume_time = 3 SECONDS

	visible_message(span_danger("[src] reaches toward [target], flames licking hungrily!"))
	to_chat(src, span_notice("You begin consuming [target]..."))

	if(do_after(src, consume_time, target))
		if(QDELETED(target))
			return FALSE

		var/consumed_name = target.name
		AddHeat(fuel_value)
		heal_fuel(fuel_value)
		qdel(target)

		visible_message(span_danger("[src] devours [consumed_name] in a burst of intensified flame!"))
		to_chat(src, span_notice("You consume [consumed_name]. Heat: [current_heat]/[max_heat]"))
		playsound(src, 'sound/items/modsuit/flamethrower.ogg', 40, TRUE)
		return TRUE

	return FALSE

/mob/living/scp/scp457/proc/GetFuelValue(atom/target)
	if(!target)
		return 0

	var/fuel = 0

	if(istype(target, /obj/item/paper) || istype(target, /obj/item/book) || istype(target, /obj/item/photo))
		fuel = 3
	else if(istype(target, /obj/item/clothing))
		fuel = 5
	else if(istype(target, /obj/item/stack/sheet/mineral/wood) || istype(target, /obj/structure/table/wood) || istype(target, /obj/structure/bed))
		fuel = 12
	else if(istype(target, /obj/item/stack/sheet/cloth) || istype(target, /obj/item/stack/medical))
		fuel = 8
	else if(istype(target, /obj/item/stack/sheet/plastic))
		fuel = 10
	else if(istype(target, /obj/item/food))
		fuel = 4
	else if(istype(target, /obj/item/candle))
		fuel = 7
	else if(istype(target, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/RC = target
		if(RC.reagents?.has_reagent(/datum/reagent/fuel))
			fuel = 20
		else if(RC.reagents?.has_reagent(/datum/reagent/clf3))
			fuel = 35
		else if(RC.reagents?.has_reagent(/datum/reagent/phosphorus))
			fuel = 15
		else if(RC.reagents?.total_volume > 0)
			fuel = 2
		else
			fuel = 1
	else if(istype(target, /obj/item/tank/internals/plasma))
		fuel = 30
	else if(istype(target, /obj/structure/closet/crate) || istype(target, /obj/structure/closet))
		fuel = 8
	else if(istype(target, /obj/structure/rack) || istype(target, /obj/structure/bed))
		fuel = 6
	else if(istype(target, /obj/structure/chair))
		fuel = 5
	else if(istype(target, /obj/machinery/light))
		fuel = 3
	else if(istype(target, /obj/item))
		var/obj/item/I = target
		if(I.resistance_flags & FLAMMABLE)
			fuel = max(4, I.w_class * 2)
		else
			fuel = 1
	else if(istype(target, /obj/structure))
		fuel = 4

	return fuel

/mob/living/scp/scp457/proc/heal_fuel(amount)
	var/heal = amount * 1.5
	adjustBruteLoss(-heal, forced = TRUE)

/mob/living/scp/scp457/process_ai()
	if(stat == DEAD)
		return
	if(containment_status != "breached")
		return
	if(world.time < last_ai_tick + ai_tick_interval)
		return
	last_ai_tick = world.time

	if(current_heat < 10)
		ai_seek_heat()
		return

	var/mob/living/carbon/human/prey = ai_find_burn_target()
	if(prey)
		ai_burn_prey(prey)
	else
		ai_spread_and_wander()

	if(current_heat > SCP457_HEAT_THRESHOLD_INTENSE && prob(15))
		ai_hurl_fireball()

/mob/living/scp/scp457/proc/ai_seek_heat()
	var/best_dist = INFINITY
	var/turf/best_turf = null
	for(var/obj/structure/bonfire/B in range(15, src))
		if(!B.burning)
			continue
		var/d = get_dist(src, B)
		if(d < best_dist)
			best_dist = d
			best_turf = get_turf(B)
	for(var/obj/machinery/atmospherics/components/unary/cryo_cell/C in range(15, src))
		var/d = get_dist(src, C)
		if(d < best_dist && C.on)
			best_dist = d
			best_turf = get_turf(C)
	if(best_turf)
		step_to(src, best_turf)
	else
		step_rand(src)

/mob/living/scp/scp457/proc/ai_find_burn_target()
	var/mob/living/carbon/human/best = null
	var/best_score = -INFINITY
	for(var/mob/living/carbon/human/H in view(10, src))
		if(H == src || H.stat == DEAD || QDELETED(H))
			continue
		var/score = 100 - get_dist(src, H) * 8
		if(H.on_fire)
			score += 30
		if(H.health < H.maxHealth * 0.5)
			score += 15
		if(score > best_score)
			best_score = score
			best = H
	return best

/mob/living/scp/scp457/proc/ai_burn_prey(mob/living/carbon/human/prey)
	if(get_dist(src, prey) <= 1)
		UnarmedAttack(prey)
		if(!locate(/obj/effect/scp457_fire) in get_turf(prey))
			CreateFireAtTurf(get_turf(prey))
		return

	step_to(src, prey)

	if(current_heat > 25)
		var/turf/my_turf = get_turf(src)
		if(my_turf && !(locate(/obj/effect/scp457_fire) in my_turf))
			CreateFireAtTurf(my_turf)

/mob/living/scp/scp457/proc/ai_spread_and_wander()
	if(current_heat < 40)
		var/obj/item/best_fuel = null
		var/best_fuel_value = 5
		for(var/obj/item/I in range(3, src))
			var/val = GetFuelValue(I)
			if(val > best_fuel_value)
				best_fuel_value = val
				best_fuel = I
		if(best_fuel)
			if(get_dist(src, best_fuel) <= 1)
				ConsumeFlammable(best_fuel)
			else
				step_to(src, best_fuel)
			return

	if(prob(30))
		var/list/adjacent = list()
		for(var/turf/T in range(2, src))
			if(CanSpreadToTurf(T))
				adjacent += T
		if(length(adjacent))
			CreateFireAtTurf(pick(adjacent))

	if(prob(20))
		var/obj/structure/S = locate() in range(3, src)
		if(S)
			S.fire_act(1000, 100)
			AddHeat(2)

	if(ai_home_turf && get_dist(src, ai_home_turf) > ai_wander_range * 2)
		var/turf/step_towards_home = get_step_towards(src, ai_home_turf)
		if(step_towards_home && !step_towards_home.density)
			Move(step_towards_home)
		else
			step_rand(src)
	else
		step_rand(src)

/mob/living/scp/scp457/proc/ai_hurl_fireball()
	var/list/targets = list()
	for(var/mob/living/L in view(7, src))
		if(L != src && L.stat != DEAD && !QDELETED(L))
			targets += L
	if(!length(targets))
		return
	var/mob/living/target = pick(targets)
	target.adjustFireLoss(35)
	target.visible_message(span_danger("A fireball from [src] strikes [target]!"), span_userdanger("A fireball hits you!"))
	AddHeat(10)
	playsound(src, 'sound/effects/explosion1.ogg', 60, TRUE)
	on_fire_spread(get_turf(target))

/mob/living/scp/scp457/get_status_tab_items()
	. = ..()
	. += "Heat Level: [current_heat]/[max_heat]"
	. += "Fire Type: [GetFireType()]"
	. += "Active Fires: [length(active_fires)]"
	. += "Containment Level: [containment_level]"

/mob/living/scp/scp457/proc/verb_hurl_fireball()
	set name = "Hurl Fireball"
	set category = "SCP-457"
	var/list/targets = list()
	for(var/mob/living/L in view(7, src))
		if(L != src && L.stat != DEAD)
			targets += L
	if(!length(targets))
		to_chat(src, span_warning("No targets in range!"))
		return
	var/mob/living/target = input(src, "Choose a target:", "Fireball") as null|anything in targets
	if(!target || QDELETED(target))
		return
	target.adjustFireLoss(35)
	target.visible_message(span_danger("A fireball from [src] strikes [target]!"), span_userdanger("A fireball hits you!"))
	AddHeat(10)
	playsound(src, 'sound/effects/explosion1.ogg', 60, TRUE)
	on_fire_spread(get_turf(target))

/mob/living/scp/scp457/verb/verb_consume_fuel()
	set name = "Consume Fuel"
	set category = "SCP-457"
	set desc = "Consume a nearby flammable object to increase your heat."
	var/list/fuel_targets = list()
	for(var/obj/item/I in range(1, src))
		if(GetFuelValue(I) > 0)
			fuel_targets += I
	for(var/obj/structure/S in range(1, src))
		if(GetFuelValue(S) > 0)
			fuel_targets += S
	if(!length(fuel_targets))
		to_chat(src, span_warning("No flammable objects nearby!"))
		return
	var/atom/chosen = input(src, "Choose an object to consume:", "Consume Fuel") as null|anything in fuel_targets
	if(!chosen || QDELETED(chosen))
		return
	ConsumeFlammable(chosen)

/mob/living/scp/scp457/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, span_warning("This is SCP-457, a living flame that spreads and consumes."))
		else
			to_chat(user, span_danger("A living flame that moves with purpose. The heat radiating from it is intense and unnatural."))
			if(H.sanity)
				H.sanity.add_trauma(TRAUMA_PSYCHOLOGICAL, 5)

/mob/living/scp/scp457/proc/get_persistence_data()
	var/list/data = list()
	data["current_heat"] = current_heat
	data["current_containment_level"] = containment_level
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

	var/datum/research_persistence_project/project = SSresearch_persistence?.manager?.add_research_project(
		project_name,
		project_description,
		research_field,
		lead_researcher,
		1000,
		1
	)

	if(project)
		project.progress = min(100, length(active_fires) + (current_heat / 10))

		if(project.progress >= 100)
			project.status = "COMPLETED"

			SSresearch_persistence?.manager?.add_scientific_discovery(
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
		AddHeat(heat_gain)
		qdel(HS)
		absorbed++

	for(var/obj/structure/bonfire/B in range(range_val, T))
		if(B.burning)
			AddHeat(8)
			B.extinguish()
			absorbed++

	for(var/mob/living/L in range(range_val, T))
		if(L == src)
			continue
		if(L.on_fire)
			var/stolen = L.fire_stacks
			AddHeat(max(1, stolen * 2))
			L.extinguish_mob()
			L.adjust_fire_stacks(-stolen)
			absorbed++

	if(absorbed > 0)
		AddHeat(absorbed * 2)
		visible_message(span_danger("[src] absorbs the nearby flames into itself!"))
		playsound(src, 'sound/items/modsuit/flamethrower.ogg', 40, TRUE)

	if(current_heat < 60)
		for(var/obj/item/I in range(range_val, T))
			if(QDELETED(I))
				continue
			var/fuel = GetFuelValue(I)
			if(fuel >= 3 && fuel <= 12)
				AddHeat(fuel * 0.5)
				heal_fuel(fuel * 0.5)
				qdel(I)
				absorbed++
		if(absorbed > 0)
			visible_message(span_danger("[src]'s flames consume nearby flammable debris!"))

/obj/effect/scp457_fire
	name = "Living Flame"
	desc = "A flame created by SCP-457"
	icon = 'icons/effects/fire.dmi'
	icon_state = "1"
	layer = 3
	anchored = TRUE
	var/fire_type = "basic"
	var/mob/living/scp/scp457/owner
	var/fire_duration = 60 SECONDS
	var/creation_time = 0
	var/damage_tick = 0
	var/damage_interval = 1 SECONDS

/obj/effect/scp457_fire/Initialize()
	. = ..()
	creation_time = world.time
	START_PROCESSING(SSobj, src)
	setup_fire_properties()

/obj/effect/scp457_fire/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/scp457_fire/process()
	if(world.time >= damage_tick + damage_interval)
		apply_damage()
		damage_tick = world.time

	if(world.time >= creation_time + fire_duration)
		qdel(src)

/obj/effect/scp457_fire/proc/setup_fire_properties()
	switch(fire_type)
		if("basic")
			icon_state = "1"
			fire_duration = 60 SECONDS
		if("intense")
			icon_state = "2"
			fire_duration = 120 SECONDS
		if("blue")
			icon_state = "3"
			fire_duration = 180 SECONDS
		if("white")
			icon_state = "3"
			fire_duration = 300 SECONDS

/obj/effect/scp457_fire/proc/apply_damage()
	var/damage = get_damage_amount()

	for(var/mob/living/L in range(1, src))
		if(L != owner && !L.SCP && !QDELETED(L))
			if(!QDELETED(L) && L.stat != DEAD)
				L.adjustFireLoss(damage)
				L.adjustBruteLoss(damage / 2)

/obj/effect/scp457_fire/proc/get_damage_amount()
	switch(fire_type)
		if("basic")
			return 5
		if("intense")
			return 15
		if("blue")
			return 30
		if("white")
			return 50
		else
			return 5
