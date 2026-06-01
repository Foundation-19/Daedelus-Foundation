// SCP Event Tracking System
// Automatically tracks SCP activities and integrates them with the progression system

// Global event tracking hooks
/proc/track_scp_event(mob/living/scp/scp, event_type, event_data = list())
	if(!scp || !scp.SCP || !scp.ckey)
		return

	if(SSscp_progression_integration && SSscp_progression_integration.manager)
		SSscp_progression_integration.manager.track_scp_event(scp, event_type, event_data)

// SCP-049 Event Tracking
/proc/track_scp049_cure(mob/living/scp/scp, mob/living/target, success = TRUE)
	if(!scp || !istype(scp, /mob/living/scp/scp049))
		return

	var/target_name = "unknown"
	if(target)
		target_name = target.name

	var/location_name = "unknown"
	var/area/A = get_area(scp)
	if(A)
		location_name = A.name

	var/list/event_data = list(
		"target" = target_name,
		"success" = success,
		"location" = location_name
	)

	track_scp_event(scp, "cure_performed", event_data)

	// Update progression tracking
	if(istype(scp, /mob/living/scp/scp049))
		var/mob/living/scp/scp049/scp049 = scp
		scp049.cures_successful++

/proc/track_scp049_containment_breach(mob/living/scp/scp, breach_type = "door")
	if(!scp || !istype(scp, /mob/living/scp/scp049))
		return

	var/location_name = "unknown"
	var/area/A = get_area(scp)
	if(A)
		location_name = A.name

	var/list/event_data = list(
		"breach_type" = breach_type,
		"location" = location_name
	)

	track_scp_event(scp, "containment_breach", event_data)

	// Update progression tracking
	if(istype(scp, /mob/living/scp/scp049))
		var/mob/living/scp/scp049/scp049 = scp
		scp049.containment_breaches++

/proc/track_scp049_research(mob/living/scp/scp, research_type, progress = 0)
	if(!scp || !istype(scp, /mob/living/scp/scp049))
		return

	var/location_name = "unknown"
	var/area/A = get_area(scp)
	if(A)
		location_name = A.name

	var/list/event_data = list(
		"research_type" = research_type,
		"progress" = progress,
		"location" = location_name
	)

	track_scp_event(scp, "research_progress", event_data)

	// Update progression tracking
	if(istype(scp, /mob/living/scp/scp049))
		var/mob/living/scp/scp049/scp049 = scp
		scp049.research_progress += progress

// SCP-096 Event Tracking
/proc/track_scp096_rage_activation(mob/living/scp/scp, trigger_type = "face_seen")
	if(!scp || !istype(scp, /mob/living/scp/scp096))
		return

	var/location_name = "unknown"
	var/area/A = get_area(scp)
	if(A)
		location_name = A.name

	var/list/event_data = list(
		"trigger_type" = trigger_type,
		"location" = location_name
	)

	track_scp_event(scp, "rage_activation", event_data)

	// Update progression tracking
	if(istype(scp, /mob/living/scp/scp096))
		var/mob/living/scp/scp096/scp096 = scp
		scp096.rage_activations++

/proc/track_scp096_victim_hunt(mob/living/scp/scp, mob/living/victim, outcome = "hunted")
	if(!scp || !istype(scp, /mob/living/scp/scp096))
		return

	var/victim_name = "unknown"
	if(victim)
		victim_name = victim.name

	var/location_name = "unknown"
	var/area/A = get_area(scp)
	if(A)
		location_name = A.name

	var/list/event_data = list(
		"victim" = victim_name,
		"outcome" = outcome,
		"location" = location_name
	)

	track_scp_event(scp, "victim_hunt", event_data)

	// Update progression tracking
	if(istype(scp, /mob/living/scp/scp096))
		var/mob/living/scp/scp096/scp096 = scp
		scp096.victims_hunted++

/proc/track_scp096_containment_escape(mob/living/scp/scp, escape_method = "breach")
	if(!scp || !istype(scp, /mob/living/scp/scp096))
		return

	var/location_name = "unknown"
	var/area/A = get_area(scp)
	if(A)
		location_name = A.name

	var/list/event_data = list(
		"escape_method" = escape_method,
		"location" = location_name
	)

	track_scp_event(scp, "containment_escape", event_data)

	// Update progression tracking
	if(istype(scp, /mob/living/scp/scp096))
		var/mob/living/scp/scp096/scp096 = scp
		scp096.containment_escapes++

// SCP-173 Event Tracking
/proc/track_scp173_movement(mob/living/scp/scp, movement_type = "successful")
	if(!scp || !istype(scp, /mob/living/scp/scp173))
		return

	var/location_name = "unknown"
	var/area/A = get_area(scp)
	if(A)
		location_name = A.name

	var/list/event_data = list(
		"movement_type" = movement_type,
		"location" = location_name
	)

	track_scp_event(scp, "movement", event_data)

	// Update progression tracking
	if(istype(scp, /mob/living/scp/scp173))
		var/mob/living/scp/scp173/scp173 = scp
		scp173.successful_movements++

/proc/track_scp173_victim_kill(mob/living/scp/scp, mob/living/victim, kill_method = "snap")
	if(!scp || !istype(scp, /mob/living/scp/scp173))
		return

	var/victim_name = "unknown"
	if(victim)
		victim_name = victim.name

	var/location_name = "unknown"
	var/area/A = get_area(scp)
	if(A)
		location_name = A.name

	var/list/event_data = list(
		"victim" = victim_name,
		"kill_method" = kill_method,
		"location" = location_name
	)

	track_scp_event(scp, "victim_kill", event_data)

	// Update progression tracking
	if(istype(scp, /mob/living/scp/scp173))
		var/mob/living/scp/scp173/scp173 = scp
		scp173.victims_killed++

/proc/track_scp173_containment_breach(mob/living/scp/scp, breach_type = "movement")
	if(!scp || !istype(scp, /mob/living/scp/scp173))
		return

	var/location_name = "unknown"
	var/area/A = get_area(scp)
	if(A)
		location_name = A.name

	var/list/event_data = list(
		"breach_type" = breach_type,
		"location" = location_name
	)

	track_scp_event(scp, "containment_breach", event_data)

	// Update progression tracking
	if(istype(scp, /mob/living/scp/scp173))
		var/mob/living/scp/scp173/scp173 = scp
		scp173.containment_breaches++

// SCP-457 Event Tracking
/proc/track_scp457_fire_creation(mob/living/scp/scp, fire_type = "basic", location = null)
	if(!scp || !istype(scp, /mob/living/scp/scp457))
		return

	var/location_name = "unknown"
	if(location)
		location_name = location
	else
		var/area/A = get_area(scp)
		if(A)
			location_name = A.name

	var/list/event_data = list(
		"fire_type" = fire_type,
		"location" = location_name
	)

	track_scp_event(scp, "fire_creation", event_data)

/proc/track_scp457_damage_dealt(mob/living/scp/scp, mob/living/target, damage_amount = 0, damage_type = "fire")
	if(!scp || !istype(scp, /mob/living/scp/scp457))
		return

	var/target_name = "unknown"
	if(target)
		target_name = target.name

	var/location_name = "unknown"
	var/area/A = get_area(scp)
	if(A)
		location_name = A.name

	var/list/event_data = list(
		"target" = target_name,
		"damage_amount" = damage_amount,
		"damage_type" = damage_type,
		"location" = location_name
	)

	track_scp_event(scp, "damage_dealt", event_data)

/proc/track_scp457_victim_consumption(mob/living/scp/scp, mob/living/victim)
	if(!scp || !istype(scp, /mob/living/scp/scp457))
		return

	var/victim_name = "unknown"
	if(victim)
		victim_name = victim.name

	var/location_name = "unknown"
	var/area/A = get_area(scp)
	if(A)
		location_name = A.name

	var/list/event_data = list(
		"victim" = victim_name,
		"location" = location_name
	)

	track_scp_event(scp, "victim_consumption", event_data)

// SCP-939 Event Tracking
/proc/track_scp939_voice_learning(mob/living/scp/scp, mob/living/speaker, voice_quality = "good")
	if(!scp || !istype(scp, /mob/living/scp/scp939))
		return

	var/speaker_name = "unknown"
	if(speaker)
		speaker_name = speaker.name

	var/location_name = "unknown"
	var/area/A = get_area(scp)
	if(A)
		location_name = A.name

	var/list/event_data = list(
		"speaker" = speaker_name,
		"voice_quality" = voice_quality,
		"location" = location_name
	)

	track_scp_event(scp, "voice_learning", event_data)

/proc/track_scp939_victim_hunt(mob/living/scp/scp, mob/living/victim, hunt_method = "voice_mimicry")
	if(!scp || !istype(scp, /mob/living/scp/scp939))
		return

	var/victim_name = "unknown"
	if(victim)
		victim_name = victim.name

	var/location_name = "unknown"
	var/area/A = get_area(scp)
	if(A)
		location_name = A.name

	var/list/event_data = list(
		"victim" = victim_name,
		"hunt_method" = hunt_method,
		"location" = location_name
	)

	track_scp_event(scp, "victim_hunt", event_data)

/proc/track_scp939_psychological_manipulation(mob/living/scp/scp, mob/living/target, manipulation_type = "voice_confusion")
	if(!scp || !istype(scp, /mob/living/scp/scp939))
		return

	var/target_name = "unknown"
	if(target)
		target_name = target.name

	var/location_name = "unknown"
	var/area/A = get_area(scp)
	if(A)
		location_name = A.name

	var/list/event_data = list(
		"target" = target_name,
		"manipulation_type" = manipulation_type,
		"location" = location_name
	)

	track_scp_event(scp, "psychological_manipulation", event_data)



// SCP-2020 Event Tracking
/proc/track_scp2020_teleportation(mob/living/scp/scp, turf/destination, teleport_type = "player_controlled")
	if(!scp || !istype(scp, /mob/living/scp/scp2020))
		return

	var/destination_name = "unknown"
	if(destination)
		destination_name = destination.name

	var/location_name = "unknown"
	var/area/A = get_area(scp)
	if(A)
		location_name = A.name

	var/list/event_data = list(
		"destination" = destination_name,
		"teleport_type" = teleport_type,
		"location" = location_name
	)

	track_scp_event(scp, "teleportation", event_data)

	// Update progression tracking (SCP-2020 is harmless — no teleportation tracking)
/proc/track_scp2020_stealth_action(mob/living/scp/scp, action_type = "phasing", success = TRUE)
	if(!scp || !istype(scp, /mob/living/scp/scp2020))
		return

	var/location_name = "unknown"
	var/area/A = get_area(scp)
	if(A)
		location_name = A.name

	var/list/event_data = list(
		"action_type" = action_type,
		"success" = success,
		"location" = location_name
	)

	track_scp_event(scp, "stealth_action", event_data)

	// SCP-2020 is harmless — no stealth_action tracking

/proc/track_scp2020_victim_elimination(mob/living/scp/scp, mob/living/victim, elimination_method = "stealth")
	if(!scp || !istype(scp, /mob/living/scp/scp2020))
		return

	var/victim_name = "unknown"
	if(victim)
		victim_name = victim.name

	var/location_name = "unknown"
	var/area/A = get_area(scp)
	if(A)
		location_name = A.name

	var/list/event_data = list(
		"victim" = victim_name,
		"elimination_method" = elimination_method,
		"location" = location_name
	)

	track_scp_event(scp, "victim_elimination", event_data)

	// SCP-2020 is harmless — no victims_eliminated tracking

// Event tracking manager extension
/datum/scp_progression_manager/proc/track_scp_event(mob/living/scp/scp, event_type, list/event_data)
	if(!scp || !scp.SCP || !scp.ckey)
		return

	var/scp_id = scp.SCP.designation
	var/ckey = scp.ckey

	// Log the event
	var/log_entry = "[world.time] - [ckey] ([scp_id]) - [event_type]: [json_encode(event_data)]"
	log_game("SCP Event: [log_entry]")

	// Store event in interaction logs
	var/event_id = "[scp_id]_[ckey]_[world.time]"
	scp_interaction_logs[event_id] = list(
		"scp_id" = scp_id,
		"ckey" = ckey,
		"event_type" = event_type,
		"event_data" = event_data,
		"timestamp" = world.time
	)

	// Award experience based on event type
	var/experience_award = get_experience_for_event(event_type, event_data)
	if(experience_award > 0 && SSpersistent_progression)
		SSpersistent_progression.award_experience(ckey, "scp_[scp_id]_[event_type]", experience_award, "SCP Event: [event_type]")

/datum/scp_progression_manager/proc/get_experience_for_event(event_type, list/event_data)
	var/experience = 0

	switch(event_type)
		if("cure_performed")
			experience = event_data["success"] ? 50 : 10
		if("containment_breach")
			experience = 100
		if("research_progress")
			experience = event_data["progress"] * 0.5
		if("rage_activation")
			experience = 75
		if("victim_hunt")
			experience = 100
		if("containment_escape")
			experience = 150
		if("movement")
			experience = 10
		if("victim_kill")
			experience = 125
		if("fire_creation")
			experience = 15
		if("damage_dealt")
			experience = event_data["damage_amount"] * 0.1
		if("victim_consumption")
			experience = 100
		if("voice_learning")
			experience = 25
		if("psychological_manipulation")
			experience = 30
		if("teleportation")
			experience = 20
		if("stealth_action")
			experience = event_data["success"] ? 15 : 5
		if("victim_elimination")
			experience = 100

	return experience
