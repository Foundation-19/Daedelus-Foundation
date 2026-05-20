// SCP-173 - The Sculpture
// Complete Production-Ready Redesign Implementation

/mob/living/scp/scp173
	ai_enabled = TRUE
	name = "SCP-173"
	desc = "A tall, thin humanoid figure made of concrete and rebar. It appears to be a sculpture."
	icon = 'icons/scp/scp-173.dmi'
	icon_state = "173"
	real_name = "SCP-173"
	persistence_id = "SCP-173"

	// SCP-173 specific variables
	var/state = "idle"

	var/datum/scp173_observation_system/observation_system
	var/datum/scp173_movement_system/movement_system
	var/datum/scp173_containment_system/containment_system
	var/datum/scp173_combat_system/combat_system
	var/datum/scp173_research_system/research_system

	var/successful_movements = 0
	var/victims_killed = 0
	var/containment_breaches = 0

/mob/living/scp/scp173/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "The Sculpture", SCP_EUCLID, "173", SCP_PLAYABLE)
	SCP.min_playercount = 30
	SCP.min_time = 15 MINUTES

	// Initialize core systems
	observation_system = new /datum/scp173_observation_system(src)
	movement_system = new /datum/scp173_movement_system(src)
	containment_system = new /datum/scp173_containment_system(src)
	combat_system = new /datum/scp173_combat_system(src)
	research_system = new /datum/scp173_research_system(src)

	// Grant language and register for SCP persistence
	grant_language(/datum/language/common, TRUE, TRUE)

	// Load persistence data
	load_persistence_data()

/mob/living/scp/scp173/Destroy()
	QDEL_NULL(observation_system)
	QDEL_NULL(movement_system)
	QDEL_NULL(containment_system)
	QDEL_NULL(combat_system)
	QDEL_NULL(research_system)
	return ..()

// Enhanced life cycle integration
/mob/living/scp/scp173/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(.)
		return
	if(observation_system)
		observation_system.process_observation()
	if(movement_system)
		movement_system.process_movement()
	if(containment_system)
		containment_system.process_containment()
	if(combat_system)
		combat_system.process_combat()
	if(research_system)
		research_system.process_research()

	// Update state based on current conditions
	update_state()

// Update SCP-173 state based on current conditions
/mob/living/scp/scp173/proc/update_state()
	if(observation_system && observation_system.is_being_observed)
		state = "contained"
	else if(combat_system && combat_system.attack_cooldown > world.time)
		state = "attacking"
	else if(movement_system && movement_system.movement_cooldown > world.time)
		state = "moving"
	else
		state = "idle"

// Persistence system
/mob/living/scp/scp173/proc/save_persistence_data()
	if(!SCP)
		return

	var/list/data = list(
		"kills_count" = combat_system ? combat_system.kills_count : 0,
		"breach_events" = containment_system ? containment_system.breach_events : 0,
		"is_observed" = observation_system ? observation_system.is_being_observed : FALSE,
		"observation_quality" = observation_system ? observation_system.observation_quality : 0,
		"containment_integrity" = containment_system ? containment_system.containment_integrity : 100,
		"is_contained" = containment_system ? containment_system.is_contained : TRUE
	)

	// Store data for research integration
	if(research_system)
		research_system.research_data = data

/mob/living/scp/scp173/proc/load_persistence_data()
	// Load data from research system if available
	if(research_system && research_system.research_data && length(research_system.research_data) > 0)
		var/list/data = research_system.research_data

		if(containment_system)
			containment_system.containment_integrity = data["containment_integrity"] || 100
			containment_system.is_contained = data["is_contained"] || TRUE
			containment_system.breach_events = data["breach_events"] || 0

		if(combat_system)
			combat_system.kills_count = data["kills_count"] || 0

// Enhanced status display
/mob/living/scp/scp173/proc/get_scp_status()
	var/list/status = list()
	status += "=== SCP-173 Status ==="
	status += "State: [state]"

	if(observation_system)
		status += "Being Observed: [observation_system.is_being_observed ? "Yes" : "No"]"
		status += "Observation Quality: [round(observation_system.observation_quality, 0.1)]"
		status += "Observers: [observation_system.observers ? length(observation_system.observers) : 0]"

	if(containment_system)
		status += "Containment Integrity: [containment_system.containment_integrity]%"
		status += "Is Contained: [containment_system.is_contained ? "Yes" : "No"]"
		status += "Breach Events: [containment_system.breach_events]"

	if(combat_system)
		status += "Kills Count: [combat_system.kills_count]"

	status += "=== Statistics ==="
	status += "Total Kills: [combat_system ? combat_system.kills_count : 0]"
	status += "Total Breach Events: [containment_system ? containment_system.breach_events : 0]"

	return status

/mob/living/scp/scp173/proc/show_status_verb()
	var/list/status = get_scp_status()
	for(var/line in status)
		to_chat(src, "<span class='notice'>[line]</span>")

// Override death to save persistence data
/mob/living/scp/scp173/death(gibbed)
	save_persistence_data()
	. = ..()

// Override logout to save persistence data
/mob/living/scp/scp173/Logout()
	save_persistence_data()
	. = ..()

// Progression Integration Hooks
/mob/living/scp/scp173/proc/on_breach()
	if(containment_system)
		containment_system.breach_events++
	hook_scp_breach("SCP-173", src)

	for(var/mob/living/carbon/human/H in range(10, src))
		if(H != src)
			hook_scp_interaction(H, "SCP-173", INTERACTION_TYPE_OBSERVATION)

/mob/living/scp/scp173/proc/on_recontainment(list/participants)
	hook_scp_recontainment("SCP-173", participants)

/mob/living/scp/scp173/proc/on_kill(mob/living/carbon/human/victim)
	if(victim && victim.ckey)
		hook_player_death_near_scp(victim, "SCP-173")
		hook_scp_combat(victim, "SCP-173", 100, 0)

/mob/living/scp/scp173/proc/on_observation_start(mob/living/carbon/human/observer)
	if(observer && observer.ckey)
		hook_scp_observation(observer, "SCP-173")

/mob/living/scp/scp173/proc/on_observation_end(mob/living/carbon/human/observer)
	if(observer && observer.ckey)
		stop_scp_survival_tracking(observer, "SCP-173")

/mob/living/scp/scp173/process_ai()
	if(stat == DEAD)
		return
	if(containment_status != "breached")
		return
	if(observation_system?.is_being_observed)
		return
	attempt_pry_door()
	ai_target = find_ai_target()
	if(ai_target)
		step_to(src, get_step_towards(src, ai_target))
		if(ai_target in view(1, src))
			if(combat_system)
				combat_system.perform_kill(ai_target)
	else if(prob(40))
		step_rand(src)
