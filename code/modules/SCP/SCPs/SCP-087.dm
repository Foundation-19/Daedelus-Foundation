// SCP-087 - The Stairwell
// An endless stairwell that induces psychological horror and contains a mysterious entity
// AUTOMATED STRUCTURE - NO PLAYER CONTROL

/obj/structure/scp087
	name = "SCP-087"
	desc = "A seemingly endless stairwell that descends into darkness. The air feels heavy with dread."
	icon = 'icons/scp/scpstructures(32x32).dmi'
	icon_state = "stairs"
	density = FALSE
	anchored = TRUE

	// Modular systems
	var/datum/scp087_descent_system/descent_system
	var/datum/scp087_horror_system/horror_system
	var/datum/scp087_entity_system/entity_system
	var/datum/scp087_environmental_system/environmental_system
	var/datum/scp087_research_system/research_system

	// Basic tracking variables
	var/total_encounters = 0
	var/people_affected = 0
	var/activation_events = 0

/obj/structure/scp087/Initialize()
	. = ..()

	// Initialize modular systems
	descent_system = new /datum/scp087_descent_system(src)
	horror_system = new /datum/scp087_horror_system(src)
	entity_system = new /datum/scp087_entity_system(src)
	environmental_system = new /datum/scp087_environmental_system(src)
	research_system = new /datum/scp087_research_system(src)

	// Initialize SCP datum
	SCP = new /datum/scp(src, "The Stairwell", SCP_EUCLID, "087")

	// Register with SCP persistence system
	// Start processing
	RegisterSignal(src, COMSIG_ATOM_ENTERED, PROC_REF(on_crossed))
	START_PROCESSING(SSobj, src)

/obj/structure/scp087/Destroy()
	QDEL_NULL(descent_system)
	QDEL_NULL(horror_system)
	QDEL_NULL(entity_system)
	QDEL_NULL(environmental_system)
	QDEL_NULL(research_system)
	STOP_PROCESSING(SSobj, src)
	return ..()

// Core automated processing
/obj/structure/scp087/process()
	. = ..()

	// Process all modular systems
	if(descent_system)
		descent_system.process_descent()
	if(horror_system)
		horror_system.process_horror()
	if(entity_system)
		entity_system.process_entity()
	if(environmental_system)
		environmental_system.process_environment()
	if(research_system)
		research_system.process_research()

	// Update tracking data
	update_tracking_data()

	// Automatic escalation based on prolonged exposure
	check_escalation_conditions()

/obj/structure/scp087/proc/update_tracking_data()
	// Count current nearby people
	var/current_people = 0
	for(var/mob/living/carbon/human/H in range(6, src))
		if(H.stat != DEAD)
			current_people++

	if(current_people > 0)
		activation_events++

/obj/structure/scp087/proc/check_escalation_conditions()
	// Check if conditions warrant escalation of effects
	var/list/nearby_people = list()
	for(var/mob/living/carbon/human/H in range(6, src))
		if(H.stat != DEAD)
			nearby_people += H

	// Escalate if multiple people have been present for a while
	if(length(nearby_people) > 2 && activation_events > 100)
		escalate_all_systems()

	// Special escalation if someone stays too long
	if(length(nearby_people) > 0 && activation_events > 200)
		trigger_deep_horror_event(nearby_people)

/obj/structure/scp087/proc/escalate_all_systems()
	if(descent_system)
		descent_system.increase_descent_intensity()
	if(horror_system)
		horror_system.intensify_horror()
	if(entity_system && entity_system.entity_cooldown <= world.time)
		entity_system.create_entity_encounter(range(6, src))
	if(environmental_system)
		environmental_system.increase_darkness()

	for(var/mob/living/carbon/human/H in range(8, src))
		if(H.stat != DEAD)
			to_chat(H, span_danger("The stairwell's malevolent presence intensifies dramatically!"))

	activation_events = 50

/obj/structure/scp087/proc/trigger_deep_horror_event(list/targets)
	// Major event that affects all nearby people
	total_encounters++
	people_affected += length(targets)

	for(var/mob/living/carbon/human/H in targets)
		to_chat(H, span_danger("You feel yourself being pulled into the infinite darkness of the stairwell..."))
		H.adjustBruteLoss(10)
		if(H.stamina)
			H.stamina.adjust(-30)

	// Reset activation counter to prevent spam
	activation_events = 0

// Interaction handling - automatic responses to player actions
/obj/structure/scp087/attack_hand(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return

	// Automatic response to interaction
	if(user.stat != DEAD)
		to_chat(user, span_danger("As you touch the stairwell, you feel an overwhelming urge to descend..."))

		// Trigger systems based on interaction
		if(descent_system)
			descent_system.progress_descent()
		if(horror_system)
			horror_system.increase_psychological_horror()

/obj/structure/scp087/proc/on_crossed(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if(H.stat != DEAD)
			to_chat(H, span_danger("As you step onto the stairwell, the darkness below seems to beckon..."))

			// Trigger multiple systems
			if(descent_system)
				descent_system.progress_descent()
			if(entity_system)
				entity_system.manifest_entity_presence()
			if(environmental_system)
				environmental_system.increase_darkness()

// Status display for admin/research purposes
/obj/structure/scp087/proc/get_status()
	var/list/status = list()
	status += "=== SCP-087 Status ==="

	if(descent_system)
		status += "Descent Level: [descent_system.descent_level]/[descent_system.max_descent_level]"
		status += "Descent Intensity: [descent_system.descent_intensity]/[descent_system.max_descent_intensity]"
		status += "Descents Performed: [descent_system.descents_performed]"

	if(horror_system)
		status += "Psychological Horror: [horror_system.psychological_horror]/[horror_system.max_psychological_horror]"
		status += "Horror Intensity: [horror_system.horror_intensity]/[horror_system.max_horror_intensity]"
		status += "Horror Events: [horror_system.horror_events]"

	if(entity_system)
		status += "Entity Encounters: [entity_system.entity_encounters]/[entity_system.max_entity_encounters]"
		status += "Entity Presence: [entity_system.entity_presence]/[entity_system.max_entity_presence]"
		status += "Entity Events: [entity_system.entity_events]"

	if(environmental_system)
		status += "Darkness Level: [environmental_system.darkness_level]/[environmental_system.max_darkness_level]"
		status += "Darkness Events: [environmental_system.darkness_events]"

	status += "=== Statistics ==="
	status += "Total Encounters: [total_encounters]"
	status += "People Affected: [people_affected]"
	status += "Activation Events: [activation_events]"

	return status

// Admin verb for status checking
/obj/structure/scp087/proc/show_status_verb()
	if(!check_rights(R_ADMIN))
		return

	var/list/status = get_status()
	for(var/line in status)
		to_chat(usr, span_notice("[line]"))

// Persistence system
/obj/structure/scp087/proc/save_persistence_data()
	if(!SCP)
		return

	var/list/data = list(
		"total_encounters" = total_encounters,
		"people_affected" = people_affected,
		"activation_events" = activation_events,
		"descent_level" = descent_system ? descent_system.descent_level : 0,
		"descent_intensity" = descent_system ? descent_system.descent_intensity : 0,
		"psychological_horror" = horror_system ? horror_system.psychological_horror : 0,
		"horror_intensity" = horror_system ? horror_system.horror_intensity : 0,
		"entity_encounters" = entity_system ? entity_system.entity_encounters : 0,
		"entity_presence" = entity_system ? entity_system.entity_presence : 0,
		"darkness_level" = environmental_system ? environmental_system.darkness_level : 1,
		"descents_performed" = descent_system ? descent_system.descents_performed : 0,
		"horror_events" = horror_system ? horror_system.horror_events : 0,
		"entity_events" = entity_system ? entity_system.entity_events : 0,
		"darkness_events" = environmental_system ? environmental_system.darkness_events : 0
	)

	// Store data for research integration
	if(research_system)
		research_system.research_data = data

/obj/structure/scp087/proc/load_persistence_data()
	// Load data from research system if available
	if(research_system && research_system.research_data && length(research_system.research_data) > 0)
		var/list/data = research_system.research_data
		total_encounters = data["total_encounters"] || 0
		people_affected = data["people_affected"] || 0
		activation_events = data["activation_events"] || 0

		if(descent_system)
			descent_system.descent_level = data["descent_level"] || 0
			descent_system.descent_intensity = data["descent_intensity"] || 0
			descent_system.descents_performed = data["descents_performed"] || 0

		if(horror_system)
			horror_system.psychological_horror = data["psychological_horror"] || 0
			horror_system.horror_intensity = data["horror_intensity"] || 0
			horror_system.horror_events = data["horror_events"] || 0

		if(entity_system)
			entity_system.entity_encounters = data["entity_encounters"] || 0
			entity_system.entity_presence = data["entity_presence"] || 0
			entity_system.entity_events = data["entity_events"] || 0

		if(environmental_system)
			environmental_system.darkness_level = data["darkness_level"] || 1
			environmental_system.darkness_events = data["darkness_events"] || 0

/obj/structure/scp087/proc/on_descent(mob/living/carbon/human/descender)
	if(!descender)
		return
	var/depth = descent_system ? descent_system.descent_level : 0
	hook_scp_interaction(descender, "SCP-087", INTERACTION_TYPE_EXPLORATION)
	hook_scp_exploration(descender, "SCP-087", depth)

/obj/structure/scp087/proc/on_horror_event(mob/living/carbon/human/victim)
	if(!victim)
		return
	hook_scp_combat(victim, "SCP-087", 0, 10)

/obj/structure/scp087/proc/on_entity_encounter(mob/living/carbon/human/witness)
	if(!witness)
		return
	hook_scp_interaction(witness, "SCP-087", INTERACTION_TYPE_OBSERVATION)
