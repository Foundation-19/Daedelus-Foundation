// SCP-1981 - RONALD REAGAN CUT UP WHILE TALKING
// A video recording that causes reality distortion and temporal effects

/obj/item/scp1981
	name = "SCP-1981"
	desc = "A video recording that appears to show Ronald Reagan being cut up while talking."
	icon = 'icons/scp/scpstructures(32x32).dmi'
	icon_state = "scp1981"
	w_class = WEIGHT_CLASS_SMALL

	// Modular systems
	var/datum/scp1981_video_system/video_system
	var/datum/scp1981_reality_system/reality_system
	var/datum/scp1981_temporal_system/temporal_system
	var/datum/scp1981_synthesis_system/synthesis_system
	var/datum/scp1981_research_system/research_system

	// Basic tracking variables
	var/total_viewers = 0
	var/people_affected = 0
	var/activation_events = 0

/obj/item/scp1981/Initialize()
	. = ..()

	// Initialize modular systems
	video_system = new /datum/scp1981_video_system(src)
	reality_system = new /datum/scp1981_reality_system(src)
	temporal_system = new /datum/scp1981_temporal_system(src)
	synthesis_system = new /datum/scp1981_synthesis_system(src)
	research_system = new /datum/scp1981_research_system(src)

	// Initialize SCP datum
	SCP = new /datum/scp(src, "RONALD REAGAN CUT UP WHILE TALKING", SCP_EUCLID, "1981")

	// Register with SCP persistence system
	// Start processing
	START_PROCESSING(SSobj, src)

/obj/item/scp1981/Destroy()
	QDEL_NULL(video_system)
	QDEL_NULL(reality_system)
	QDEL_NULL(temporal_system)
	QDEL_NULL(synthesis_system)
	QDEL_NULL(research_system)
	STOP_PROCESSING(SSobj, src)
	return ..()

// Core automated processing
/obj/item/scp1981/process(delta_time)
	if(!istype(loc, /turf))
		return

	if(video_system)
		video_system.process_video()
	if(reality_system)
		reality_system.process_reality()
	if(temporal_system)
		temporal_system.process_temporal()
	if(synthesis_system)
		synthesis_system.process_synthesis()
	if(research_system)
		research_system.process_research()

	update_tracking_data()

	check_escalation_conditions()

/obj/item/scp1981/proc/update_tracking_data()
	// Count current nearby viewers
	var/current_viewers = 0
	for(var/mob/living/carbon/human/H in range(6, src))
		if(H.stat != DEAD)
			current_viewers++

	if(current_viewers > 0)
		activation_events++
		total_viewers += current_viewers

/obj/item/scp1981/proc/check_escalation_conditions()
	// Check if conditions warrant escalation of effects
	var/list/nearby_viewers = list()
	for(var/mob/living/carbon/human/H in range(6, src))
		if(H.stat != DEAD)
			nearby_viewers += H

	// Escalate if multiple people have been viewing for a while
	if(length(nearby_viewers) > 2 && activation_events > 100)
		escalate_all_systems()

	// Special escalation if someone stays too long
	if(length(nearby_viewers) > 0 && activation_events > 200)
		trigger_ultimate_video_event(nearby_viewers)

/obj/item/scp1981/proc/escalate_all_systems()
	if(video_system)
		video_system.increase_video_manipulation()
	if(reality_system)
		reality_system.increase_reality_distortion()
	if(temporal_system)
		temporal_system.increase_temporal_effects()

	for(var/mob/living/carbon/human/H in range(8, src))
		if(H.stat != DEAD)
			to_chat(H, "<span class='danger'>The video recording's effects intensify dramatically!</span>")

	activation_events = 50

/obj/item/scp1981/proc/trigger_ultimate_video_event(list/targets)
	// Major event that affects all nearby people
	people_affected += length(targets)

	for(var/mob/living/carbon/human/H in targets)
		to_chat(H, "<span class='danger'>You experience SCP-1981's ultimate video manipulation!</span>")
		H.adjustBruteLoss(25)
		if(H.stamina)
			H.stamina.adjust(-30)
		hook_scp_interaction(H, "SCP-1981", "ultimate_video_event")

	// Reset activation counter to prevent spam
	activation_events = 0

// Interaction handling - automatic responses to player actions
/obj/item/scp1981/attack_hand(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return

	// Automatic response to interaction
	if(user.stat != DEAD)
		to_chat(user, "<span class='danger'>As you touch the video recording, you see disturbing imagery...</span>")

		hook_scp_interaction(user, "SCP-1981", "video_viewing")

		// Trigger systems based on interaction
		if(video_system)
			video_system.increase_video_manipulation()
		if(reality_system)
			reality_system.increase_reality_distortion()

// Examine override
/obj/item/scp1981/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-1981, a video recording that causes reality distortion.</span>")
		else
			to_chat(user, "<span class='danger'>A disturbing video recording that seems to distort reality.</span>")

// Status display for admin/research purposes
/obj/item/scp1981/proc/get_status()
	var/list/status = list()
	status += "=== SCP-1981 Status ==="

	if(video_system)
		status += "Video Manipulation: [video_system.video_manipulation]/[video_system.max_video_manipulation]"
		status += "Video Evolution: [video_system.video_evolution]/[video_system.max_video_evolution]"
		status += "Video Events: [video_system.video_events]"

	if(reality_system)
		status += "Reality Distortion: [reality_system.reality_distortion]/[reality_system.max_reality_distortion]"
		status += "Distortion Potency: [reality_system.distortion_potency]/[reality_system.max_distortion_potency]"
		status += "Reality Events: [reality_system.reality_events]"

	if(temporal_system)
		status += "Temporal Effects: [temporal_system.temporal_effects]/[temporal_system.max_temporal_effects]"
		status += "Temporal Mastery: [temporal_system.temporal_mastery]/[temporal_system.max_temporal_mastery]"
		status += "Temporal Events: [temporal_system.temporal_events]"

	if(synthesis_system)
		status += "Synthesis Events: [synthesis_system.synthesis_events]"

	status += "=== Statistics ==="
	status += "Total Viewers: [total_viewers]"
	status += "People Affected: [people_affected]"
	status += "Activation Events: [activation_events]"

	return status

// Admin verb for status checking
/obj/item/scp1981/proc/show_status_verb()
	if(!check_rights(R_ADMIN))
		return

	var/list/status = get_status()
	for(var/line in status)
		to_chat(src, "<span class='notice'>[line]</span>")

// Persistence system
/obj/item/scp1981/proc/save_persistence_data()
	if(!SCP)
		return

	var/list/data = list(
		"total_viewers" = total_viewers,
		"people_affected" = people_affected,
		"activation_events" = activation_events,
		"video_manipulation" = video_system ? video_system.video_manipulation : 0,
		"video_evolution" = video_system ? video_system.video_evolution : 1,
		"reality_distortion" = reality_system ? reality_system.reality_distortion : 0,
		"distortion_potency" = reality_system ? reality_system.distortion_potency : 1,
		"temporal_effects" = temporal_system ? temporal_system.temporal_effects : 0,
		"temporal_mastery" = temporal_system ? temporal_system.temporal_mastery : 0,
		"video_events" = video_system ? video_system.video_events : 0,
		"reality_events" = reality_system ? reality_system.reality_events : 0,
		"temporal_events" = temporal_system ? temporal_system.temporal_events : 0,
		"synthesis_events" = synthesis_system ? synthesis_system.synthesis_events : 0
	)

	// Store data for research integration
	if(research_system)
		research_system.research_data = data

/obj/item/scp1981/proc/load_persistence_data()
	// Load data from research system if available
	if(research_system && research_system.research_data && length(research_system.research_data) > 0)
		var/list/data = research_system.research_data
		total_viewers = data["total_viewers"] || 0
		people_affected = data["people_affected"] || 0
		activation_events = data["activation_events"] || 0

		if(video_system)
			video_system.video_manipulation = data["video_manipulation"] || 0
			video_system.video_evolution = data["video_evolution"] || 1
			video_system.video_events = data["video_events"] || 0

		if(reality_system)
			reality_system.reality_distortion = data["reality_distortion"] || 0
			reality_system.distortion_potency = data["distortion_potency"] || 1
			reality_system.reality_events = data["reality_events"] || 0

		if(temporal_system)
			temporal_system.temporal_effects = data["temporal_effects"] || 0
			temporal_system.temporal_mastery = data["temporal_mastery"] || 0
			temporal_system.temporal_events = data["temporal_events"] || 0

		if(synthesis_system)
			synthesis_system.synthesis_events = data["synthesis_events"] || 0

