// SCP-008 - The Zombie Plague
// Complete Redesign Implementation

/obj/item/reagent_containers/glass/bottle/scp008
	name = "SCP-008"
	desc = "A sealed container containing a highly contagious zombie plague. Extremely dangerous."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle"
	var/containment_breached = FALSE
	var/infection_strength = 50
	var/list/infected_targets = list()
	var/list/zombified_targets = list()

	// Core system datums
	var/datum/scp008_infection_system/infection_system
	var/datum/scp008_horde_system/horde_system
	var/datum/scp008_evolution_system/evolution_system
	var/datum/scp008_containment_system/containment_system
	var/datum/scp008_environmental_system/environmental_system
	var/datum/scp008_research_integration/research_integration

	// Persistence tracking
	var/total_infections_caused = 0
	var/total_host_deaths = 0
	var/total_evolution_stages = 0
	var/total_containment_encounters = 0
	var/total_environmental_control = 0
	var/session_start_time = 0
	var/containment_status = "contained"

/obj/item/reagent_containers/glass/bottle/scp008/Initialize()
	. = ..()

	// Initialize SCP datum
	SCP = new /datum/scp(
		src,
		"SCP-008",
		SCP_KETER,
		"008"
	)

	// Initialize core systems
	infection_system = new /datum/scp008_infection_system(src)
	horde_system = new /datum/scp008_horde_system(src)
	evolution_system = new /datum/scp008_evolution_system(src)
	containment_system = new /datum/scp008_containment_system(src)
	environmental_system = new /datum/scp008_environmental_system(src)
	research_integration = new /datum/scp008_research_integration(src)

	// Set session start time
	session_start_time = world.time

	// Start processing
	START_PROCESSING(SSobj, src)

/obj/item/reagent_containers/glass/bottle/scp008/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(infection_system)
	QDEL_NULL(horde_system)
	QDEL_NULL(evolution_system)
	QDEL_NULL(containment_system)
	QDEL_NULL(environmental_system)
	QDEL_NULL(research_integration)
	QDEL_NULL(SCP)
	infected_targets.Cut()
	zombified_targets.Cut()
	return ..()

/obj/item/reagent_containers/glass/bottle/scp008/process()
	// Update all systems
	infection_system?.process()
	horde_system?.process()
	evolution_system?.process()
	containment_system?.process()
	environmental_system?.process()
	research_integration?.process()

	// Process SCP-008 specific effects
	process_scp008_effects()

/obj/item/reagent_containers/glass/bottle/scp008/proc/process_scp008_effects()
	// Update appearance based on infection strength
	update_scp008_appearance()

	// Process infection spread
	process_infection_spread()

/obj/item/reagent_containers/glass/bottle/scp008/proc/update_scp008_appearance()
	var/infection_type = infection_system.get_infection_type()

	switch(infection_type)
		if("airborne")
			icon_state = "bottle"
		if("contact")
			icon_state = "bottle"
		if("fluid")
			icon_state = "bottle"
		if("aerosol")
			icon_state = "bottle"

/obj/item/reagent_containers/glass/bottle/scp008/proc/process_infection_spread()
	// Only spread if containment is breached
	if(!containment_breached)
		return

	var/infection_type = infection_system.get_infection_type()
	var/spread_range = get_spread_range(infection_type)

	// Clean up stale entries in infected/zombified targets
	for(var/key in infected_targets)
		var/mob/living/carbon/human/H = infected_targets[key]
		if(QDELETED(H))
			infected_targets -= key
	for(var/key in zombified_targets)
		var/mob/living/carbon/human/H = zombified_targets[key]
		if(QDELETED(H))
			zombified_targets -= key

	// Check for nearby targets to infect
	for(var/mob/living/carbon/human/H in range(spread_range, src))
		if(H != src && !H.SCP && H.stat != DEAD)
			var/key = REF(H)
			if(!infected_targets[key] && !zombified_targets[key])
				attempt_infection(H, infection_type)

/obj/item/reagent_containers/glass/bottle/scp008/proc/get_spread_range(infection_type)
	switch(infection_type)
		if("airborne")
			return 3
		if("contact")
			return 1
		if("fluid")
			return 2
		if("aerosol")
			return 5
		else
			return 2

/obj/item/reagent_containers/glass/bottle/scp008/proc/attempt_infection(mob/living/carbon/human/target, infection_type)
	if(!target || target.stat == DEAD)
		return

	// Calculate infection chance based on type and strength
	var/infection_chance = get_infection_chance(infection_type)

	if(prob(infection_chance))
		infect_target(target, infection_type)

/obj/item/reagent_containers/glass/bottle/scp008/proc/get_infection_chance(infection_type)
	var/base_chance = infection_system.current_strength / 10

	switch(infection_type)
		if("airborne")
			return base_chance * 0.8
		if("contact")
			return base_chance * 1.2
		if("fluid")
			return base_chance * 1.5
		if("aerosol")
			return base_chance * 2.0
		else
			return base_chance

/obj/item/reagent_containers/glass/bottle/scp008/proc/infect_target(mob/living/carbon/human/target, infection_type)
	if(!target || target.stat == DEAD)
		return

	var/key = REF(target)
	if(infected_targets[key] || zombified_targets[key])
		return

	infected_targets[key] = target
	total_infections_caused++
	containment_breached = TRUE
	containment_status = "breached"
	if(!SSscp_persistence || !SSscp_persistence.manager || SSscp_persistence.manager.scp_instances["SCP-008"]?.containment_status != "breached")
		hook_scp_breach("SCP-008", src)

	visible_message("<span class='danger'>[target] has been infected with SCP-008!</span>")
	to_chat(target, "<span class='danger'>You have been infected with SCP-008! You feel your body beginning to decay...</span>")

	// Apply infection effects
	var/damage = get_infection_damage(infection_type)
	target.adjustBruteLoss(damage)
	target.adjustToxLoss(damage)

	// Add to evolution progress
	evolution_system.add_infection_caused()

	// Start infection timer
	addtimer(CALLBACK(src, PROC_REF(zombify_target), target), get_infection_duration(infection_type))

	// Update persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-008"]
		if(instance)
			instance.add_interaction_record(target, "infection")

/obj/item/reagent_containers/glass/bottle/scp008/proc/get_infection_damage(infection_type)
	var/base_damage = infection_system.current_strength / 10

	switch(infection_type)
		if("airborne")
			return base_damage * 0.8
		if("contact")
			return base_damage * 1.0
		if("fluid")
			return base_damage * 1.3
		if("aerosol")
			return base_damage * 1.8
		else
			return base_damage

/obj/item/reagent_containers/glass/bottle/scp008/proc/get_infection_duration(infection_type)
	switch(infection_type)
		if("airborne")
			return 300 // 30 seconds
		if("contact")
			return 180 // 18 seconds
		if("fluid")
			return 240 // 24 seconds
		if("aerosol")
			return 120 // 12 seconds
		else
			return 300

/obj/item/reagent_containers/glass/bottle/scp008/proc/zombify_target(mob/living/carbon/human/target)
	if(!target || target.stat == DEAD)
		return

	var/key = REF(target)
	infected_targets -= key
	zombified_targets[key] = target
	total_host_deaths++

	visible_message("<span class='danger'>[target] has been completely zombified by SCP-008!</span>")
	to_chat(target, "<span class='danger'>You have been completely transformed into a zombie! You are now part of the SCP-008 horde.</span>")

	// Create zombie mob
	var/mob/living/simple_animal/hostile/scp008_zombie/zombie = new /mob/living/simple_animal/hostile/scp008_zombie(target.loc)

	// Add to horde system
	horde_system.horde_members += zombie

	// Transfer target's appearance to zombie
	zombie.name = "[target.name] (Zombie)"
	zombie.desc = "A zombie created by SCP-008. It was once [target.name]."

	// Add to evolution progress
	evolution_system.add_host_death()

	// Remove original target
	target.ghostize()
	qdel(target)

/obj/item/reagent_containers/glass/bottle/scp008/proc/is_spreading_infection()
	return length(infected_targets) > 0 || length(zombified_targets) > 0

/obj/item/reagent_containers/glass/bottle/scp008/proc/add_evolution_record(stage)
	total_evolution_stages = max(total_evolution_stages, stage)

/obj/item/reagent_containers/glass/bottle/scp008/proc/add_containment_record()
	total_containment_encounters++

/obj/item/reagent_containers/glass/bottle/scp008/proc/add_environmental_record()
	total_environmental_control++

// Reagent interaction - when SCP-008 is used as a reagent
/obj/item/reagent_containers/glass/bottle/scp008/proc/on_reagent_use(mob/living/carbon/human/user)
	if(!user || user.stat == DEAD)
		return

	// Breach containment when used
	containment_breached = TRUE

	// Infect the user
	var/infection_type = infection_system.get_infection_type()
	infect_target(user, infection_type)

	visible_message("<span class='danger'>[user] has been exposed to SCP-008!</span>")

	// Update persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-008"]
		if(instance)
			instance.add_interaction_record(user, "reagent_exposure")

// Status display
/obj/item/reagent_containers/glass/bottle/scp008/proc/get_status_tab_items()
	var/list/status = list()
	status += "Infection Strength: [infection_system.current_strength]/[infection_system.max_strength]"
	status += "Infection Type: [infection_system.get_infection_type()]"
	status += "Infected Targets: [length(infected_targets)]"
	status += "Zombified Targets: [length(zombified_targets)]"
	status += "Horde Size: [length(horde_system.horde_members)]"
	status += "Evolution Stage: [evolution_system.current_stage]/[evolution_system.max_stage]"
	status += "Containment Level: [containment_system.containment_level]"
	status += "Total Infections: [total_infections_caused]"
	status += "Environmental Control: [length(environmental_system.controlled_room_types)]"
	return status

// Examine behavior
/obj/item/reagent_containers/glass/bottle/scp008/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-008, a zombie plague. Current evolution stage: [evolution_system.current_stage]</span>")
		else
			to_chat(user, "<span class='danger'>A sealed container containing a highly contagious zombie plague. The contents seem to writhe and move unnaturally.</span>")

			// Apply fear effect to non-SCP humans
			if(H.sanity)
				H.sanity.add_trauma(TRAUMA_PSYCHOLOGICAL, 8)

// Persistence integration
/obj/item/reagent_containers/glass/bottle/scp008/proc/get_persistence_data()
	var/list/data = list()
	data["total_infections_caused"] = total_infections_caused
	data["total_host_deaths"] = total_host_deaths
	data["total_evolution_stages"] = total_evolution_stages
	data["total_containment_encounters"] = total_containment_encounters
	data["total_environmental_control"] = total_environmental_control
	data["session_duration"] = world.time - session_start_time
	data["current_infection_strength"] = infection_system.current_strength
	data["current_evolution_stage"] = evolution_system.current_stage
	data["current_containment_level"] = containment_system.containment_level
	return data

/obj/item/reagent_containers/glass/bottle/scp008/proc/load_persistence_data(list/data)
	if(!data)
		return

	total_infections_caused = data["total_infections_caused"] || 0
	total_host_deaths = data["total_host_deaths"] || 0
	total_evolution_stages = data["total_evolution_stages"] || 0
	total_containment_encounters = data["total_containment_encounters"] || 0
	total_environmental_control = data["total_environmental_control"] || 0

// Research integration
/obj/item/reagent_containers/glass/bottle/scp008/proc/contribute_research_data()
	if(!SSresearch_persistence || !SSresearch_persistence.manager)
		return

	// Create research project if it doesn't exist
	var/project_name = "SCP-008 Outbreak Analysis"
	var/project_description = "Analysis of SCP-008's infection spreading and horde formation patterns"
	var/research_field = "SCP-008_OUTBREAK"
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
		// Update project with current data
		project.progress = min(100, (total_infections_caused * 2) + (total_host_deaths * 3) + (total_evolution_stages * 10))

		// Mark as completed if enough data
		if(project.progress >= 100)
			project.status = "COMPLETED"

			// Add scientific discovery
			SSresearch_persistence.manager.add_scientific_discovery(
				"SCP-008 Outbreak Patterns",
				"Comprehensive analysis of SCP-008's infection spreading and horde formation mechanics",
				"SCP_RESEARCH",
				"SCP-008",
				"System",
				3 // High significance
			)

// Legacy compatibility
/obj/item/reagent_containers/glass/bottle/scp008/proc/spread_infection()
	// Legacy infection spread handled by new systems
	process_infection_spread()

// ============================================================================
// SCP-008 ZOMBIE MOB
// ============================================================================

/mob/living/simple_animal/hostile/scp008_zombie
	name = "SCP-008 Zombie"
	desc = "A zombie created by SCP-008. It moves slowly but relentlessly."
	icon = 'icons/mob/human.dmi'
	icon_state = "zombie"
	icon_living = "zombie"
	icon_dead = "zombie_dead"
	icon_gib = "zombie_gib"

	maxHealth = 100
	health = 100

	melee_damage_lower = 20
	melee_damage_upper = 30
	attack_sound = 'sound/hallucinations/growl1.ogg'

	environment_smash = 1
	obj_damage = 20

	del_on_death = TRUE

	var/infection_strength = 25
	var/can_infect = TRUE
	var/infection_cooldown = 0
	var/infection_cooldown_time = 30 SECONDS

/mob/living/simple_animal/hostile/scp008_zombie/Initialize()
	. = ..()

	// Set up zombie AI
	AIStatus = AI_ON

	// Start processing
	START_PROCESSING(SSobj, src)

/mob/living/simple_animal/hostile/scp008_zombie/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/mob/living/simple_animal/hostile/scp008_zombie/process()
	if(can_infect && world.time >= infection_cooldown + infection_cooldown_time)
		process_infection_spread()
		infection_cooldown = world.time

/mob/living/simple_animal/hostile/scp008_zombie/proc/process_infection_spread()
	// Check for nearby humans to infect
	for(var/mob/living/carbon/human/H in range(2, src))
		if(H.stat != DEAD && !H.SCP)
			if(prob(infection_strength))
				attempt_infection(H)

/mob/living/simple_animal/hostile/scp008_zombie/proc/attempt_infection(mob/living/carbon/human/target)
	if(!target || target.stat == DEAD)
		return

	// Apply infection damage
	target.adjustBruteLoss(infection_strength)
	target.adjustToxLoss(infection_strength)

	// Notify target
	to_chat(target, "<span class='danger'>You have been infected by a zombie!</span>")

	// Start infection timer
	addtimer(CALLBACK(src, PROC_REF(zombify_target), target), 300)

/mob/living/simple_animal/hostile/scp008_zombie/proc/zombify_target(mob/living/carbon/human/target)
	if(!target || target.stat == DEAD)
		return

	visible_message("<span class='danger'>[target] has been zombified!</span>")
	to_chat(target, "<span class='danger'>You have been completely transformed into a zombie!</span>")

	// Create new zombie
	var/mob/living/simple_animal/hostile/scp008_zombie/new_zombie = new /mob/living/simple_animal/hostile/scp008_zombie(target.loc)
	new_zombie.name = "[target.name] (Zombie)"
	new_zombie.desc = "A zombie created by SCP-008. It was once [target.name]."

	// Remove original target
	target.ghostize()
	qdel(target)

// ============================================================================
// END OF SCP-008 REDESIGN
// ============================================================================

/obj/item/reagent_containers/glass/bottle/scp008/proc/on_containment_breach()
	hook_scp_breach("SCP-008", src)

