/datum/scp457_heat_system
	var/mob/living/scp/scp457/owner
	var/current_heat = SCP457_INITIAL_HEAT
	var/max_heat = SCP457_MAX_HEAT
	var/heat_generation_rate = SCP457_HEAT_GENERATION_RATE
	var/heat_decay_rate = SCP457_HEAT_DECAY_RATE
	var/last_heat_update = 0
	var/heat_update_interval = 30 SECONDS
	var/heat_gain_multiplier = 1.0
	var/heat_decay_multiplier = 1.0
	var/containment_heat_penalty = 0

/datum/scp457_heat_system/New(mob/living/scp/scp457/new_owner)
	. = ..()
	owner = new_owner

/datum/scp457_heat_system/Destroy()
	owner = null
	return ..()

/datum/scp457_heat_system/process()
	if(world.time >= last_heat_update + heat_update_interval)
		update_heat()
		last_heat_update = world.time

/datum/scp457_heat_system/proc/update_heat()
	if(!owner.is_spreading_fires())
		current_heat = min(max_heat, current_heat + (heat_generation_rate * heat_gain_multiplier))

	current_heat = max(0, current_heat - (heat_decay_rate * heat_decay_multiplier))

	if(containment_heat_penalty > 0)
		current_heat = max(0, current_heat - containment_heat_penalty)
		containment_heat_penalty = max(0, containment_heat_penalty - 1)

/datum/scp457_heat_system/proc/add_heat(amount)
	current_heat = min(max_heat, current_heat + amount)

/datum/scp457_heat_system/proc/consume_heat(amount)
	current_heat = max(0, current_heat - amount)

/datum/scp457_heat_system/proc/get_heat_percentage()
	return (current_heat / max_heat) * 100

/datum/scp457_heat_system/proc/get_fire_type()
	if(current_heat <= SCP457_HEAT_THRESHOLD_BASIC)
		return "basic"
	else if(current_heat <= SCP457_HEAT_THRESHOLD_INTENSE)
		return "intense"
	else if(current_heat <= SCP457_HEAT_THRESHOLD_BLUE)
		return "blue"
	else
		return "white"

/datum/scp457_heat_system/proc/apply_containment_penalty(penalty)
	containment_heat_penalty += penalty

/datum/scp457_fire_system
	var/mob/living/scp/scp457/owner
	var/list/active_fires = list()
	var/spread_cooldown = 0
	var/spread_interval = 10 SECONDS
	var/current_fire_type = "basic"
	var/spread_range = 1
	var/max_spread_range = 5
	var/fire_creation_cooldown = 0
	var/fire_creation_interval = 5 SECONDS

/datum/scp457_fire_system/New(mob/living/scp/scp457/new_owner)
	. = ..()
	owner = new_owner
	current_fire_type = "basic"

/datum/scp457_fire_system/Destroy()
	cleanup_fires()
	active_fires = null
	owner = null
	return ..()

/datum/scp457_fire_system/process()
	if(world.time >= spread_cooldown + spread_interval)
		process_fire_spreading()
		spread_cooldown = world.time

	if(world.time >= fire_creation_cooldown + fire_creation_interval)
		create_initial_fires()
		fire_creation_cooldown = world.time

/datum/scp457_fire_system/proc/process_fire_spreading()
	var/current_heat = owner.heat_system.current_heat
	var/fire_type = owner.heat_system.get_fire_type()

	current_fire_type = fire_type

	var/spread_chance = (current_heat / 100) * 0.3

	for(var/obj/effect/scp457_fire/fire in active_fires)
		if(!fire || fire.loc == null)
			active_fires -= fire
			continue

		if(prob(spread_chance * 100))
			attempt_fire_spread(fire)

/datum/scp457_fire_system/proc/attempt_fire_spread(obj/effect/scp457_fire/source_fire)
	var/list/adjacent_turfs = list()

	for(var/turf/T in range(1, source_fire))
		if(can_spread_to_turf(T))
			adjacent_turfs += T

	if(length(adjacent_turfs))
		var/turf/spread_turf = pick(adjacent_turfs)
		create_fire_at_turf(spread_turf)

		owner.heat_system.consume_heat(2)

/datum/scp457_fire_system/proc/can_spread_to_turf(turf/T)
	if(!T || T.density)
		return FALSE

	if(locate(/obj/effect/scp457_fire) in T)
		return FALSE

	if(istype(T, /turf/closed))
		return FALSE

	return TRUE

/datum/scp457_fire_system/proc/create_fire_at_turf(turf/T)
	if(!can_spread_to_turf(T))
		return

	var/obj/effect/scp457_fire/new_fire = new /obj/effect/scp457_fire(T)
	new_fire.fire_type = current_fire_type
	new_fire.owner = owner
	new_fire.setup_fire_properties()

	active_fires += new_fire

	track_scp457_fire_creation(owner, current_fire_type, T)

	apply_fire_damage(T)

/datum/scp457_fire_system/proc/apply_fire_damage(turf/fire_turf)
	var/damage = get_fire_damage()

	for(var/mob/living/L in range(1, fire_turf))
		if(L != owner && !L.SCP && !QDELETED(L))
			if(!QDELETED(L) && L.stat != DEAD)
				L.adjustFireLoss(damage)
				L.adjustBruteLoss(damage / 2)

/datum/scp457_fire_system/proc/get_fire_damage()
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

/datum/scp457_fire_system/proc/create_initial_fires()
	if(length(active_fires) < 3)
		var/list/adjacent_turfs = list()
		for(var/turf/T in range(1, owner))
			if(can_spread_to_turf(T))
				adjacent_turfs += T

		if(length(adjacent_turfs))
			var/turf/chosen_turf = pick(adjacent_turfs)
			create_fire_at_turf(chosen_turf)

/datum/scp457_fire_system/proc/cleanup_fires()
	for(var/obj/effect/scp457_fire/fire in active_fires)
		if(fire)
			qdel(fire)
	active_fires.Cut()

/datum/scp457_containment_system
	var/mob/living/scp/scp457/owner
	var/containment_level = 0
	var/max_containment_level = SCP457_MAX_CONTAINMENT_LEVEL
	var/response_cooldown = 0
	var/response_interval = 30 SECONDS
	var/active_personnel = list()
	var/containment_equipment = list()
	var/last_containment_check = 0
	var/containment_check_interval = 15 SECONDS
	var/fire_thresholds = list(3, 8, 15, 25)
	var/containment_successes = 0
	var/containment_failures = 0

/datum/scp457_containment_system/New(mob/living/scp/scp457/new_owner)
	. = ..()
	owner = new_owner

/datum/scp457_containment_system/Destroy()
	owner = null
	return ..()

/datum/scp457_containment_system/process()
	if(world.time >= last_containment_check + containment_check_interval)
		check_containment_response()
		last_containment_check = world.time

/datum/scp457_containment_system/proc/check_containment_response()
	var/active_fires = length(owner.fire_system.active_fires)
	var/fire_type = owner.heat_system.get_fire_type()
	var/new_containment_level = 0

	for(var/i = 1; i <= length(fire_thresholds); i++)
		if(active_fires >= fire_thresholds[i])
			new_containment_level = i

	if(fire_type == "blue" && new_containment_level < 3)
		new_containment_level = 3
	if(fire_type == "white" && new_containment_level < 4)
		new_containment_level = 4

	if(new_containment_level != containment_level)
		update_containment_level(new_containment_level)

/datum/scp457_containment_system/proc/update_containment_level(new_level)
	var/old_level = containment_level
	containment_level = new_level

	apply_containment_effects(new_level)

	if(new_level > old_level)
		to_chat(owner, "<span class='warning'>Containment level increased to [new_level]!</span>")
		containment_failures++
	else if(new_level < old_level)
		to_chat(owner, "<span class='notice'>Containment level decreased to [new_level].</span>")
		containment_successes++
		if(new_level == 0)
			hook_scp_recontainment("SCP-457", list("method" = "fire_suppression", "fires_remaining" = length(owner.fire_system.active_fires)))

/datum/scp457_containment_system/proc/apply_containment_effects(level)
	switch(level)
		if(1)
			owner.heat_system.containment_heat_penalty = 1
			spawn_containment_personnel(2)
		if(2)
			owner.heat_system.containment_heat_penalty = 2
			spawn_containment_personnel(5)
			spawn_containment_equipment("extinguishers")
		if(3)
			owner.heat_system.containment_heat_penalty = 3
			spawn_containment_personnel(8)
			spawn_containment_equipment("barriers")
			trigger_evacuation()
		if(4)
			owner.heat_system.containment_heat_penalty = 5
			spawn_containment_personnel(12)
			spawn_containment_equipment("specialized")
			trigger_breach_protocol()

/datum/scp457_containment_system/proc/spawn_containment_personnel(count)
	active_personnel = list()
	for(var/i = 1; i <= count; i++)
		active_personnel += "personnel_[i]"

/datum/scp457_containment_system/proc/spawn_containment_equipment(type)
	containment_equipment[type] = TRUE

/datum/scp457_containment_system/proc/trigger_evacuation()
	log_game("SCP-457 triggered evacuation protocol")

/datum/scp457_containment_system/proc/trigger_breach_protocol()
	log_game("SCP-457 triggered breach protocol")

/datum/scp457_environmental_system
	var/mob/living/scp/scp457/owner
	var/list/controlled_room_types = list()
	var/list/room_effects = list()
	var/environmental_hazards = list()
	var/strategic_positions = list()
	var/last_environment_check = 0
	var/environment_check_interval = 20 SECONDS

/datum/scp457_environmental_system/New(mob/living/scp/scp457/new_owner)
	. = ..()
	owner = new_owner
	setup_room_effects()

/datum/scp457_environmental_system/Destroy()
	controlled_room_types = null
	room_effects = null
	environmental_hazards = null
	strategic_positions = null
	owner = null
	return ..()

/datum/scp457_environmental_system/process()
	if(world.time >= last_environment_check + environment_check_interval)
		check_environmental_control()
		last_environment_check = world.time

/datum/scp457_environmental_system/proc/setup_room_effects()
	room_effects = list(
		"laboratory" = list("flammability" = 1.5, "containment" = 0.8, "hazard" = "chemicals"),
		"security" = list("flammability" = 0.75, "containment" = 1.2, "hazard" = "equipment"),
		"maintenance" = list("flammability" = 1.2, "containment" = 0.6, "hazard" = "machinery"),
		"command" = list("flammability" = 1.0, "containment" = 1.5, "hazard" = "critical"),
		"medical" = list("flammability" = 0.8, "containment" = 1.3, "hazard" = "oxygen"),
		"standard" = list("flammability" = 1.0, "containment" = 1.0, "hazard" = "none")
	)

/datum/scp457_environmental_system/proc/check_environmental_control()
	var/list/controlled_areas = list()

	for(var/obj/effect/scp457_fire/fire in owner.fire_system.active_fires)
		var/area/fire_area = get_area(fire)
		if(fire_area)
			controlled_areas[fire_area.type] = TRUE

	controlled_room_types = controlled_areas

/datum/scp457_environmental_system/proc/get_room_effect(area/room_area)
	var/room_type = "standard"

	if(istype(room_area, /area/station/science))
		room_type = "laboratory"
	else if(istype(room_area, /area/station/security))
		room_type = "security"
	else if(istype(room_area, /area/station/maintenance))
		room_type = "maintenance"
	else if(istype(room_area, /area/station/command))
		room_type = "command"
	else if(istype(room_area, /area/station/medical))
		room_type = "medical"

	return room_effects[room_type] || room_effects["standard"]

/datum/scp457_research_integration
	var/mob/living/scp/scp457/owner
	var/list/research_projects = list()
	var/list/research_data = list()
	var/research_update_cooldown = 0
	var/research_update_interval = 120 SECONDS
	var/last_research_update = 0

/datum/scp457_research_integration/New(mob/living/scp/scp457/new_owner)
	. = ..()
	owner = new_owner
	setup_research_projects()

/datum/scp457_research_integration/Destroy()
	research_data = null
	owner = null
	return ..()

/datum/scp457_research_integration/process()
	if(world.time >= last_research_update + research_update_interval)
		update_research_data()
		last_research_update = world.time

/datum/scp457_research_integration/proc/setup_research_projects()
	research_projects = list(
		"behavioral" = list(
			"name" = "SCP-457 Fire Spread Patterns",
			"description" = "Study the patterns and mechanics of SCP-457's fire spreading behavior",
			"requirements" = list("observation_time" = 600, "fire_count" = 10),
			"benefits" = list("containment_efficiency" = 0.2)
		),
		"containment" = list(
			"name" = "SCP-457 Suppression Methods",
			"description" = "Develop effective methods for containing and suppressing SCP-457 fires",
			"requirements" = list("containment_successes" = 5, "suppression_attempts" = 10),
			"benefits" = list("fire_resistance" = 0.3)
		)
	)

/datum/scp457_research_integration/proc/update_research_data()
	research_data["active_fires"] = length(owner.fire_system.active_fires)
	research_data["heat_level"] = owner.heat_system.current_heat
	research_data["containment_level"] = owner.containment_system.containment_level
	research_data["environmental_control"] = length(owner.environmental_system.controlled_room_types)

	if(SSresearch_persistence && SSresearch_persistence.manager)
		add_research_contribution()

/datum/scp457_research_integration/proc/add_research_contribution()
	log_game("SCP-457 research data: [json_encode(research_data)]")

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
