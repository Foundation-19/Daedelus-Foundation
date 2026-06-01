// SCP-008 Core Systems
// Complete Redesign Implementation

// ============================================================================
// INFECTION MANAGEMENT SYSTEM
// ============================================================================

/datum/scp008_infection_system
	var/obj/item/reagent_containers/glass/bottle/scp008/owner
	var/current_strength = 50
	var/max_strength = 100
	var/infection_growth_rate = 1
	var/infection_decay_rate = 1
	var/last_infection_update = 0
	var/infection_update_interval = 30 SECONDS
	var/infection_gain_multiplier = 1.0
	var/infection_decay_multiplier = 1.0
	var/containment_infection_penalty = 0

/datum/scp008_infection_system/New(obj/item/reagent_containers/glass/bottle/scp008/new_owner)
	. = ..()
	owner = new_owner
	START_PROCESSING(SSobj, src)

/datum/scp008_infection_system/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/scp008_infection_system/process()
	if(world.time >= last_infection_update + infection_update_interval)
		update_infection()
		last_infection_update = world.time

/datum/scp008_infection_system/proc/update_infection()
	// Natural infection growth
	if(!owner.is_spreading_infection())
		current_strength = min(max_strength, current_strength + (infection_growth_rate * infection_gain_multiplier))

	// Natural infection decay
	current_strength = max(0, current_strength - (infection_decay_rate * infection_decay_multiplier))

	// Containment penalty
	if(containment_infection_penalty > 0)
		current_strength = max(0, current_strength - containment_infection_penalty)
		containment_infection_penalty = max(0, containment_infection_penalty - 1)

/datum/scp008_infection_system/proc/add_infection(amount)
	current_strength = min(max_strength, current_strength + amount)

/datum/scp008_infection_system/proc/consume_infection(amount)
	current_strength = max(0, current_strength - amount)

/datum/scp008_infection_system/proc/get_infection_percentage()
	return (current_strength / max_strength) * 100

/datum/scp008_infection_system/proc/get_infection_type()
	if(current_strength <= 25)
		return "airborne"
	else if(current_strength <= 50)
		return "contact"
	else if(current_strength <= 75)
		return "fluid"
	else
		return "aerosol"

/datum/scp008_infection_system/proc/apply_containment_penalty(penalty)
	containment_infection_penalty += penalty

// ============================================================================
// HORDE COORDINATION SYSTEM
// ============================================================================

/datum/scp008_horde_system
	var/obj/item/reagent_containers/glass/bottle/scp008/owner
	var/list/horde_members = list()
	var/horde_coordination = 0
	var/max_horde_coordination = 100
	var/horde_hierarchy_rank = 1
	var/max_horde_hierarchy = 5
	var/territory_radius = 10
	var/max_territory_radius = 20
	var/horde_formation_cooldown = 0
	var/horde_formation_interval = 15 SECONDS
	var/total_horde_members = 0
	var/horde_members_this_session = 0

/datum/scp008_horde_system/New(obj/item/reagent_containers/glass/bottle/scp008/new_owner)
	. = ..()
	owner = new_owner
	START_PROCESSING(SSobj, src)

/datum/scp008_horde_system/Destroy()
	cleanup_horde()
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/scp008_horde_system/process()
	if(world.time >= horde_formation_cooldown + horde_formation_interval)
		process_horde_formation()
		horde_formation_cooldown = world.time

/datum/scp008_horde_system/proc/process_horde_formation()
	var/current_infection = owner.infection_system.current_strength
	var/infection_type = owner.infection_system.get_infection_type()

	// Apply infection type-specific behavior
	switch(infection_type)
		if("aggressive")
			// Aggressive infection increases horde coordination
			horde_coordination = min(max_horde_coordination, horde_coordination + 2)
		if("stealth")
			// Stealth infection reduces detection range
			territory_radius = max(5, territory_radius - 1)
		if("resilient")
			// Resilient infection increases horde member health
			for(var/mob/living/simple_animal/hostile/scp008_zombie/zombie in horde_members)
				if(zombie && zombie.health < zombie.maxHealth)
					zombie.adjustHealth(-5) // Heal 5 damage

	// Calculate horde formation chance based on infection strength
	var/formation_chance = (current_infection / 100) * 0.2

	// Process each horde member
	for(var/mob/living/simple_animal/hostile/scp008_zombie/zombie in horde_members)
		if(!zombie || zombie.loc == null)
			horde_members -= zombie
			continue

		// Attempt to form horde bonds
		if(prob(formation_chance * 100))
			attempt_horde_coordination(zombie)

/datum/scp008_horde_system/proc/attempt_horde_coordination(mob/living/simple_animal/hostile/scp008_zombie/zombie)
	// Find nearby zombies for coordination
	var/list/nearby_zombies = list()

	for(var/mob/living/simple_animal/hostile/scp008_zombie/other_zombie in range(territory_radius, zombie))
		if(other_zombie != zombie && !(other_zombie in horde_members))
			nearby_zombies += other_zombie

	if(length(nearby_zombies))
		var/mob/living/simple_animal/hostile/scp008_zombie/coordinated_zombie = pick(nearby_zombies)
		form_horde_bond(zombie, coordinated_zombie)

		// Consume infection for coordination
		owner.infection_system.consume_infection(2)

/datum/scp008_horde_system/proc/form_horde_bond(mob/living/simple_animal/hostile/scp008_zombie/zombie1, mob/living/simple_animal/hostile/scp008_zombie/zombie2)
	if(!zombie1 || !zombie2)
		return

	// Add to horde
	if(!(zombie1 in horde_members))
		horde_members += zombie1
		total_horde_members++
		horde_members_this_session++

	if(!(zombie2 in horde_members))
		horde_members += zombie2
		total_horde_members++
		horde_members_this_session++

	// Increase coordination
	horde_coordination = min(max_horde_coordination, horde_coordination + 5)

	// Apply coordination benefits
	apply_coordination_benefits(zombie1, zombie2)

/datum/scp008_horde_system/proc/apply_coordination_benefits(mob/living/simple_animal/hostile/scp008_zombie/zombie1, mob/living/simple_animal/hostile/scp008_zombie/zombie2)
	// Share target information
	if(zombie1.target && !zombie2.target)
		zombie2.target = zombie1.target

	if(zombie2.target && !zombie1.target)
		zombie1.target = zombie2.target

	// Increase damage
	zombie1.melee_damage_lower = min(50, zombie1.melee_damage_lower + 5)
	zombie1.melee_damage_upper = min(60, zombie1.melee_damage_upper + 5)
	zombie2.melee_damage_lower = min(50, zombie2.melee_damage_lower + 5)
	zombie2.melee_damage_upper = min(60, zombie2.melee_damage_upper + 5)

/datum/scp008_horde_system/proc/cleanup_horde()
	for(var/mob/living/simple_animal/hostile/scp008_zombie/zombie in horde_members)
		if(zombie)
			// Reset zombie stats
			zombie.melee_damage_lower = 20
			zombie.melee_damage_upper = 30
	horde_members.Cut()

/datum/scp008_horde_system/proc/update_territory_radius()
	territory_radius = min(max_territory_radius, 10 + (owner.evolution_system.current_stage - 1) * 2)

// ============================================================================
// EVOLUTION SYSTEM
// ============================================================================

/datum/scp008_evolution_system
	var/obj/item/reagent_containers/glass/bottle/scp008/owner
	var/current_stage = 1
	var/max_stage = 5
	var/evolution_progress = 0
	var/evolution_requirements = list()
	var/infections_caused = 0
	var/host_deaths = 0
	var/containment_survivals = 0
	var/last_evolution_check = 0
	var/evolution_check_interval = 60 SECONDS

/datum/scp008_evolution_system/New(obj/item/reagent_containers/glass/bottle/scp008/new_owner)
	. = ..()
	owner = new_owner
	START_PROCESSING(SSobj, src)
	setup_evolution_requirements()

/datum/scp008_evolution_system/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/scp008_evolution_system/process()
	if(world.time >= last_evolution_check + evolution_check_interval)
		check_evolution_progress()
		last_evolution_check = world.time

/datum/scp008_evolution_system/proc/setup_evolution_requirements()
	evolution_requirements = list(
		"stage_2" = list("infections" = 3, "infection_strength" = 50, "host_deaths" = 1),
		"stage_3" = list("infections" = 8, "infection_strength" = 75, "host_deaths" = 3, "containment" = 2),
		"stage_4" = list("infections" = 15, "infection_strength" = 90, "host_deaths" = 8, "containment" = 5),
		"stage_5" = list("infections" = 25, "infection_strength" = 100, "host_deaths" = 15, "containment" = 10)
	)

/datum/scp008_evolution_system/proc/check_evolution_progress()
	if(current_stage >= max_stage)
		return

	var/next_stage = current_stage + 1
	var/requirements = evolution_requirements["stage_[next_stage]"]

	if(!requirements)
		return

	var/can_evolve = TRUE

	// Check infection requirement
	if(infections_caused < requirements["infections"])
		can_evolve = FALSE

	// Check infection strength requirement
	if(owner.infection_system.current_strength < requirements["infection_strength"])
		can_evolve = FALSE

	// Check host death requirement
	if(host_deaths < requirements["host_deaths"])
		can_evolve = FALSE

	// Check containment survival requirement
	if(containment_survivals < requirements["containment"])
		can_evolve = FALSE

	if(can_evolve)
		evolve_to_stage(next_stage)

/datum/scp008_evolution_system/proc/evolve_to_stage(new_stage)
	if(new_stage <= current_stage || new_stage > max_stage)
		return

	current_stage = new_stage
	evolution_progress = 0

	// Apply evolution benefits
	apply_evolution_benefits(new_stage)

	// Update horde system
	owner.horde_system.update_territory_radius()

	// Notify owner
	to_chat(owner, span_notice("SCP-008 has evolved to stage [new_stage]!"))

	// Add to persistence
	owner.add_evolution_record(new_stage)

/datum/scp008_evolution_system/proc/apply_evolution_benefits(stage)
	switch(stage)
		if(2)
			// Advanced Infection benefits
			owner.infection_system.infection_gain_multiplier = 1.2
			owner.infection_system.infection_decay_multiplier = 0.8
		if(3)
			// Master Infection benefits
			owner.infection_system.infection_gain_multiplier = 1.5
			owner.infection_system.infection_decay_multiplier = 0.6
		if(4)
			// Perfect Infection benefits
			owner.infection_system.infection_gain_multiplier = 2.0
			owner.infection_system.infection_decay_multiplier = 0.4
		if(5)
			// Plague Master benefits
			owner.infection_system.infection_gain_multiplier = 2.5
			owner.infection_system.infection_decay_multiplier = 0.2

/datum/scp008_evolution_system/proc/add_infection_caused()
	infections_caused++
	evolution_progress += 10

/datum/scp008_evolution_system/proc/add_host_death()
	host_deaths++
	evolution_progress += 15

/datum/scp008_evolution_system/proc/add_containment_survival()
	containment_survivals++
	evolution_progress += 20

// ============================================================================
// CONTAINMENT SYSTEM
// ============================================================================

/datum/scp008_containment_system
	var/obj/item/reagent_containers/glass/bottle/scp008/owner
	var/containment_level = 0
	var/max_containment_level = 4
	var/response_cooldown = 0
	var/response_interval = 30 SECONDS
	var/active_personnel = list()
	var/containment_equipment = list()
	var/last_containment_check = 0
	var/containment_check_interval = 15 SECONDS
	var/infection_thresholds = list(3, 8, 15, 25)
	var/containment_successes = 0
	var/containment_failures = 0

/datum/scp008_containment_system/New(obj/item/reagent_containers/glass/bottle/scp008/new_owner)
	. = ..()
	owner = new_owner
	START_PROCESSING(SSobj, src)

/datum/scp008_containment_system/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/scp008_containment_system/process()
	if(world.time >= last_containment_check + containment_check_interval)
		check_containment_response()
		last_containment_check = world.time

/datum/scp008_containment_system/proc/check_containment_response()
	var/active_infections = owner.infection_system.current_strength
	var/infection_type = owner.infection_system.get_infection_type()
	var/horde_size = length(owner.horde_system.horde_members)
	var/new_containment_level = 0

	// Determine containment level based on infections and horde size
	for(var/i = 1; i <= length(infection_thresholds); i++)
		if(active_infections >= infection_thresholds[i])
			new_containment_level = i

	// Adjust for infection type
	if(infection_type == "fluid" && new_containment_level < 3)
		new_containment_level = 3
	if(infection_type == "aerosol" && new_containment_level < 4)
		new_containment_level = 4

	// Adjust for horde size
	if(horde_size >= 5 && new_containment_level < 3)
		new_containment_level = 3
	if(horde_size >= 10 && new_containment_level < 4)
		new_containment_level = 4

	// Update containment level
	if(new_containment_level != containment_level)
		update_containment_level(new_containment_level)

/datum/scp008_containment_system/proc/update_containment_level(new_level)
	var/old_level = containment_level
	containment_level = new_level

	// Apply containment effects
	apply_containment_effects(new_level)

	// Notify owner
	if(new_level > old_level)
		to_chat(owner, span_warning("Containment level increased to [new_level]!"))
		containment_failures++
		owner.evolution_system.add_containment_survival()
	else if(new_level < old_level)
		to_chat(owner, span_notice("Containment level decreased to [new_level]."))
		containment_successes++

/datum/scp008_containment_system/proc/apply_containment_effects(level)
	switch(level)
		if(1)
			// Basic response
			owner.infection_system.containment_infection_penalty = 1
			spawn_containment_personnel(2)
		if(2)
			// Enhanced response
			owner.infection_system.containment_infection_penalty = 2
			spawn_containment_personnel(5)
			spawn_containment_equipment("quarantine")
		if(3)
			// Emergency response
			owner.infection_system.containment_infection_penalty = 3
			spawn_containment_personnel(8)
			spawn_containment_equipment("decontamination")
			trigger_evacuation()
		if(4)
			// Breach protocol
			owner.infection_system.containment_infection_penalty = 5
			spawn_containment_personnel(12)
			spawn_containment_equipment("specialized")
			trigger_breach_protocol()

/datum/scp008_containment_system/proc/spawn_containment_personnel(count)
	// This would integrate with your personnel system
	// For now, just track the count
	active_personnel = list()
	for(var/i = 1; i <= count; i++)
		active_personnel += "personnel_[i]"

/datum/scp008_containment_system/proc/spawn_containment_equipment(type)
	// This would integrate with your equipment system
	// For now, just track the equipment
	containment_equipment[type] = TRUE

/datum/scp008_containment_system/proc/trigger_evacuation()
	// This would integrate with your facility systems
	// For now, just log the event
	log_game("SCP-008 triggered evacuation protocol")

/datum/scp008_containment_system/proc/trigger_breach_protocol()
	// This would integrate with your breach system
	// For now, just log the event
	log_game("SCP-008 triggered breach protocol")

// ============================================================================
// ENVIRONMENTAL SYSTEM
// ============================================================================

/datum/scp008_environmental_system
	var/obj/item/reagent_containers/glass/bottle/scp008/owner
	var/list/controlled_room_types = list()
	var/list/room_effects = list()
	var/environmental_hazards = list()
	var/strategic_positions = list()
	var/last_environment_check = 0
	var/environment_check_interval = 20 SECONDS

/datum/scp008_environmental_system/New(obj/item/reagent_containers/glass/bottle/scp008/new_owner)
	. = ..()
	owner = new_owner
	START_PROCESSING(SSobj, src)
	setup_room_effects()

/datum/scp008_environmental_system/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/scp008_environmental_system/process()
	if(world.time >= last_environment_check + environment_check_interval)
		check_environmental_control()
		last_environment_check = world.time

/datum/scp008_environmental_system/proc/setup_room_effects()
	room_effects = list(
		"medical" = list("infection_rate" = 1.5, "containment" = 0.8, "hazard" = "patients"),
		"security" = list("infection_rate" = 0.75, "containment" = 1.2, "hazard" = "personnel"),
		"maintenance" = list("infection_rate" = 1.2, "containment" = 0.6, "hazard" = "equipment"),
		"command" = list("infection_rate" = 1.0, "containment" = 1.5, "hazard" = "critical"),
		"laboratory" = list("infection_rate" = 1.3, "containment" = 0.9, "hazard" = "research"),
		"standard" = list("infection_rate" = 1.0, "containment" = 1.0, "hazard" = "none")
	)

/datum/scp008_environmental_system/proc/check_environmental_control()
	var/list/controlled_areas = list()

	// Check which areas SCP-008 has infections in
	for(var/mob/living/simple_animal/hostile/scp008_zombie/zombie in owner.horde_system.horde_members)
		var/area/zombie_area = get_area(zombie)
		if(zombie_area)
			controlled_areas[zombie_area.type] = TRUE

	// Update controlled room types
	controlled_room_types = controlled_areas

	// Check for new environmental control
	if(length(controlled_areas) > length(environmental_hazards))
		// Add environmental control tracking
		environmental_hazards = controlled_areas.Copy()

/datum/scp008_environmental_system/proc/get_room_effect(area/room_area)
	var/room_type = "standard"

	// Determine room type based on area
	if(istype(room_area, /area/station/medical))
		room_type = "medical"
	else if(istype(room_area, /area/station/security))
		room_type = "security"
	else if(istype(room_area, /area/station/maintenance))
		room_type = "maintenance"
	else if(istype(room_area, /area/station/command))
		room_type = "command"
	else if(istype(room_area, /area/station/science))
		room_type = "laboratory"

	return room_effects[room_type] || room_effects["standard"]

// ============================================================================
// RESEARCH INTEGRATION
// ============================================================================

/datum/scp008_research_integration
	var/obj/item/reagent_containers/glass/bottle/scp008/owner
	var/list/research_projects = list()
	var/list/research_data = list()
	var/research_update_cooldown = 0
	var/research_update_interval = 120 SECONDS
	var/last_research_update = 0

/datum/scp008_research_integration/New(obj/item/reagent_containers/glass/bottle/scp008/new_owner)
	. = ..()
	owner = new_owner
	// Don't start processing - already handled by SCP-008's process() method
	setup_research_projects()

/datum/scp008_research_integration/Destroy()
	// No longer processing separately
	return ..()

/datum/scp008_research_integration/process()
	if(world.time >= last_research_update + research_update_interval)
		update_research_data()
		last_research_update = world.time

/datum/scp008_research_integration/proc/setup_research_projects()
	research_projects = list(
		"outbreak" = list(
			"name" = "SCP-008 Infection Patterns",
			"description" = "Study the patterns and mechanics of SCP-008's infection spreading behavior",
			"requirements" = list("observation_time" = 600, "infection_count" = 10),
			"benefits" = list("containment_efficiency" = 0.2)
		),
		"containment" = list(
			"name" = "SCP-008 Decontamination Methods",
			"description" = "Develop effective methods for containing and decontaminating SCP-008 infections",
			"requirements" = list("containment_successes" = 5, "decontamination_attempts" = 10),
			"benefits" = list("infection_resistance" = 0.3)
		),
		"horde" = list(
			"name" = "SCP-008 Horde Behavior Study",
			"description" = "Analyze the horde formation and coordination patterns of SCP-008",
			"requirements" = list("horde_observations" = 10, "coordination_events" = 5),
			"benefits" = list("horde_prediction" = 0.4)
		)
	)

/datum/scp008_research_integration/proc/update_research_data()
	// Update research data based on current state
	research_data["active_infections"] = owner.infection_system.current_strength
	research_data["infection_type"] = owner.infection_system.get_infection_type()
	research_data["evolution_stage"] = owner.evolution_system.current_stage
	research_data["containment_level"] = owner.containment_system.containment_level
	research_data["horde_size"] = length(owner.horde_system.horde_members)
	research_data["environmental_control"] = length(owner.environmental_system.controlled_room_types)

	// Add to research persistence if available
	if(SSresearch_persistence && SSresearch_persistence.manager)
		add_research_contribution()

/datum/scp008_research_integration/proc/add_research_contribution()
	// This would integrate with your research persistence system
	// For now, just log the research data
	log_game("SCP-008 research data: [json_encode(research_data)]")

// ============================================================================
// END OF SCP-008 CORE SYSTEMS
// ============================================================================
