// SCP Progression Integration System
// Comprehensive integration between SCP entities and the persistent progression system

SUBSYSTEM_DEF(scp_progression_integration)
	name = "SCP Progression Integration"
	wait = 300 // 5 seconds
	priority = FIRE_PRIORITY_PERSISTENT_PROGRESSION
	init_order = INIT_ORDER_PERSISTENCE_PROGRESSION
	var/datum/scp_progression_manager/manager

/datum/controller/subsystem/scp_progression_integration/Initialize()
	manager = new /datum/scp_progression_manager()
	world.log << "SCP Progression Integration Subsystem: Initialized"
	return ..()

/datum/controller/subsystem/scp_progression_integration/fire()
	if(manager)
		manager.process_scp_progression()

// SCP Progression Manager
/datum/scp_progression_manager
	var/list/scp_progression_data = list() // scp_id -> progression_data
	var/list/scp_achievements = list() // achievement_id -> achievement_data
	var/list/scp_performance_metrics = list() // scp_id -> metrics
	var/list/scp_research_projects = list() // project_id -> research_data
	var/list/scp_containment_events = list() // event_id -> event_data
	var/list/scp_interaction_logs = list() // interaction_id -> interaction_data

	// Global SCP progression metrics
	var/total_scp_rounds_played = 0
	var/total_scp_achievements_unlocked = 0
	var/average_scp_performance = 0.0
	var/total_scp_research_points = 0
	var/scp_containment_breaches = 0
	var/scp_research_breakthroughs = 0

/datum/scp_progression_manager/proc/process_scp_progression()
	// Process all SCP entities in the world
	process_scp_entities()

	// Update SCP performance metrics
	update_scp_performance_metrics()

	// Save data periodically
	if(world.time % 6000 == 0) // Every 10 minutes
		save_scp_progression_data()

/datum/scp_progression_manager/proc/process_scp_entities()
	for(var/mob/living/carbon/human/H in GLOB.mob_list)
		if(QDELETED(H))
			continue
		if(H.SCP && H.ckey)
			process_scp_entity(H)

/datum/scp_progression_manager/proc/process_scp_entity(mob/living/scp/scp)
	if(!scp || !scp.SCP || !scp.ckey)
		return

	var/scp_id = scp.SCP.designation
	var/ckey = scp.ckey

	// Get or create progression data
	var/datum/scp_progression_data/prog_data = get_scp_progression_data(scp_id, ckey)
	if(!prog_data)
		prog_data = new /datum/scp_progression_data(scp_id, ckey)

	// Update progression data from SCP entity
	prog_data.update_from_scp(scp)

	// Award experience based on SCP activities
	award_scp_experience(scp, prog_data)

	// Check for achievement unlocks
	check_scp_achievements(scp, prog_data)

/datum/scp_progression_manager/proc/get_scp_progression_data(scp_id, ckey)
	var/key = "[scp_id]_[ckey]"
	if(!(key in scp_progression_data))
		scp_progression_data[key] = new /datum/scp_progression_data(scp_id, ckey)
	return scp_progression_data[key]

/datum/scp_progression_manager/proc/award_scp_experience(mob/living/scp/scp, datum/scp_progression_data/prog_data)
	if(!scp || !prog_data)
		return

	var/experience_awarded = 0

	// Award experience based on SCP-specific activities
	switch(scp.SCP.designation)
		if("049")
			experience_awarded += award_scp049_experience(scp, prog_data)
		if("096")
			experience_awarded += award_scp096_experience(scp, prog_data)
		if("173")
			experience_awarded += award_scp173_experience(scp, prog_data)
		if("457")
			experience_awarded += award_scp457_experience(scp, prog_data)
		if("939")
			experience_awarded += award_scp939_experience(scp, prog_data)
		if("2020")
			experience_awarded += award_scp2020_experience(scp, prog_data)

	// Award experience to player through persistent progression system
	if(experience_awarded > 0 && SSpersistent_progression)
		SSpersistent_progression.award_experience(scp.ckey, "scp_[scp.SCP.designation]", experience_awarded, "SCP Activity")

/datum/scp_progression_manager/proc/award_scp049_experience(mob/living/scp/scp, datum/scp_progression_data/prog_data)
	var/experience = 0

	// Award for cures performed
	if(prog_data.metrics["cures_performed"] > prog_data.last_metrics["cures_performed"])
		var/cures_delta = prog_data.metrics["cures_performed"] - prog_data.last_metrics["cures_performed"]
		experience += cures_delta * 50

	// Award for containment breaches
	if(prog_data.metrics["containment_breaches"] > prog_data.last_metrics["containment_breaches"])
		var/breaches_delta = prog_data.metrics["containment_breaches"] - prog_data.last_metrics["containment_breaches"]
		experience += breaches_delta * 100

	return experience

/datum/scp_progression_manager/proc/award_scp096_experience(mob/living/scp/scp, datum/scp_progression_data/prog_data)
	var/experience = 0

	// Award for rage activations
	if(prog_data.metrics["rage_activations"] > prog_data.last_metrics["rage_activations"])
		var/rage_delta = prog_data.metrics["rage_activations"] - prog_data.last_metrics["rage_activations"]
		experience += rage_delta * 75

	// Award for victims hunted
	if(prog_data.metrics["victims_hunted"] > prog_data.last_metrics["victims_hunted"])
		var/victims_delta = prog_data.metrics["victims_hunted"] - prog_data.last_metrics["victims_hunted"]
		experience += victims_delta * 100

	return experience

/datum/scp_progression_manager/proc/award_scp173_experience(mob/living/scp/scp, datum/scp_progression_data/prog_data)
	var/experience = 0

	// Award for successful movements
	if(prog_data.metrics["successful_movements"] > prog_data.last_metrics["successful_movements"])
		var/movements_delta = prog_data.metrics["successful_movements"] - prog_data.last_metrics["successful_movements"]
		experience += movements_delta * 10

	// Award for victims killed
	if(prog_data.metrics["victims_killed"] > prog_data.last_metrics["victims_killed"])
		var/kills_delta = prog_data.metrics["victims_killed"] - prog_data.last_metrics["victims_killed"]
		experience += kills_delta * 125

	return experience

/datum/scp_progression_manager/proc/award_scp457_experience(mob/living/scp/scp, datum/scp_progression_data/prog_data)
	var/experience = 0

	// Award for fires created
	if(prog_data.metrics["fires_created"] > prog_data.last_metrics["fires_created"])
		var/fires_delta = prog_data.metrics["fires_created"] - prog_data.last_metrics["fires_created"]
		experience += fires_delta * 15

	// Award for victims consumed
	if(prog_data.metrics["victims_consumed"] > prog_data.last_metrics["victims_consumed"])
		var/consumed_delta = prog_data.metrics["victims_consumed"] - prog_data.last_metrics["victims_consumed"]
		experience += consumed_delta * 100

	return experience

/datum/scp_progression_manager/proc/award_scp939_experience(mob/living/scp/scp, datum/scp_progression_data/prog_data)
	var/experience = 0

	// Award for voices learned
	if(prog_data.metrics["voices_learned"] > prog_data.last_metrics["voices_learned"])
		var/voices_delta = prog_data.metrics["voices_learned"] - prog_data.last_metrics["voices_learned"]
		experience += voices_delta * 25

	// Award for victims hunted
	if(prog_data.metrics["victims_hunted"] > prog_data.last_metrics["victims_hunted"])
		var/victims_delta = prog_data.metrics["victims_hunted"] - prog_data.last_metrics["victims_hunted"]
		experience += victims_delta * 75

	return experience

/datum/scp_progression_manager/proc/award_scp2020_experience(mob/living/scp/scp, datum/scp_progression_data/prog_data)
	var/experience = 0

	// Award for teleportations
	if(prog_data.metrics["teleportations"] > prog_data.last_metrics["teleportations"])
		var/teleport_delta = prog_data.metrics["teleportations"] - prog_data.last_metrics["teleportations"]
		experience += teleport_delta * 20

	// Award for stealth actions
	if(prog_data.metrics["stealth_actions"] > prog_data.last_metrics["stealth_actions"])
		var/stealth_delta = prog_data.metrics["stealth_actions"] - prog_data.last_metrics["stealth_actions"]
		experience += stealth_delta * 15

	return experience

/datum/scp_progression_manager/proc/check_scp_achievements(mob/living/scp/scp, datum/scp_progression_data/prog_data)
	if(!scp || !prog_data || !SSpersistent_progression)
		return

	var/scp_id = scp.SCP.designation
	var/ckey = scp.ckey

	// Use ckey for additional functionality like player-specific progression tracking
	if(ckey)
		// Log the SCP playtime for future implementation
		world.log << "SCP Progression: Player [ckey] played as SCP [scp_id]"

	// Check SCP-specific achievements
	switch(scp_id)
		if("049")
			check_scp049_achievements(scp, prog_data)
		if("096")
			check_scp096_achievements(scp, prog_data)
		if("173")
			check_scp173_achievements(scp, prog_data)
		if("457")
			check_scp457_achievements(scp, prog_data)
		if("939")
			check_scp939_achievements(scp, prog_data)
		if("2020")
			check_scp2020_achievements(scp, prog_data)

/datum/scp_progression_manager/proc/check_scp049_achievements(mob/living/scp/scp, datum/scp_progression_data/prog_data)
	var/ckey = scp.ckey

	// First Cure
	if(prog_data.metrics["cures_performed"] >= 1 && !("scp049_first_cure" in prog_data.achievements))
		unlock_scp_achievement(ckey, "scp049_first_cure", "First Cure", "Perform your first cure as SCP-049", prog_data)

	// Master Healer
	if(prog_data.metrics["cures_performed"] >= 10 && !("scp049_master_healer" in prog_data.achievements))
		unlock_scp_achievement(ckey, "scp049_master_healer", "Master Healer", "Perform 10 cures as SCP-049", prog_data)

/datum/scp_progression_manager/proc/check_scp096_achievements(mob/living/scp/scp, datum/scp_progression_data/prog_data)
	var/ckey = scp.ckey

	// First Rage
	if(prog_data.metrics["rage_activations"] >= 1 && !("scp096_first_rage" in prog_data.achievements))
		unlock_scp_achievement(ckey, "scp096_first_rage", "First Rage", "Activate your first rage as SCP-096", prog_data)

	// Efficient Hunter
	if(prog_data.metrics["victims_hunted"] >= 15 && !("scp096_efficient_hunter" in prog_data.achievements))
		unlock_scp_achievement(ckey, "scp096_efficient_hunter", "Efficient Hunter", "Hunt 15 victims as SCP-096", prog_data)

/datum/scp_progression_manager/proc/check_scp173_achievements(mob/living/scp/scp, datum/scp_progression_data/prog_data)
	var/ckey = scp.ckey

	// First Movement
	if(prog_data.metrics["successful_movements"] >= 1 && !("scp173_first_movement" in prog_data.achievements))
		unlock_scp_achievement(ckey, "scp173_first_movement", "First Movement", "Make your first successful movement as SCP-173", prog_data)

	// Silent Killer
	if(prog_data.metrics["victims_killed"] >= 20 && !("scp173_silent_killer" in prog_data.achievements))
		unlock_scp_achievement(ckey, "scp173_silent_killer", "Silent Killer", "Kill 20 victims as SCP-173", prog_data)

/datum/scp_progression_manager/proc/check_scp457_achievements(mob/living/scp/scp, datum/scp_progression_data/prog_data)
	var/ckey = scp.ckey

	// First Fire
	if(prog_data.metrics["fires_created"] >= 1 && !("scp457_first_fire" in prog_data.achievements))
		unlock_scp_achievement(ckey, "scp457_first_fire", "First Fire", "Create your first fire as SCP-457", prog_data)

	// Consuming Flame
	if(prog_data.metrics["victims_consumed"] >= 10 && !("scp457_consuming_flame" in prog_data.achievements))
		unlock_scp_achievement(ckey, "scp457_consuming_flame", "Consuming Flame", "Consume 10 victims as SCP-457", prog_data)

/datum/scp_progression_manager/proc/check_scp939_achievements(mob/living/scp/scp, datum/scp_progression_data/prog_data)
	var/ckey = scp.ckey

	// First Voice
	if(prog_data.metrics["voices_learned"] >= 1 && !("scp939_first_voice" in prog_data.achievements))
		unlock_scp_achievement(ckey, "scp939_first_voice", "First Voice", "Learn your first voice as SCP-939", prog_data)

	// Voice Master
	if(prog_data.metrics["voices_learned"] >= 20 && !("scp939_voice_master" in prog_data.achievements))
		unlock_scp_achievement(ckey, "scp939_voice_master", "Voice Master", "Learn 20 voices as SCP-939", prog_data)

/datum/scp_progression_manager/proc/check_scp2020_achievements(mob/living/scp/scp, datum/scp_progression_data/prog_data)
	var/ckey = scp.ckey

	// First Teleport
	if(prog_data.metrics["teleportations"] >= 1 && !("scp2020_first_teleport" in prog_data.achievements))
		unlock_scp_achievement(ckey, "scp2020_first_teleport", "First Teleport", "Perform your first teleport as SCP-2020", prog_data)

	// Stealth Operative
	if(prog_data.metrics["stealth_actions"] >= 30 && !("scp2020_stealth_operative" in prog_data.achievements))
		unlock_scp_achievement(ckey, "scp2020_stealth_operative", "Stealth Operative", "Perform 30 stealth actions as SCP-2020", prog_data)

/datum/scp_progression_manager/proc/unlock_scp_achievement(ckey, achievement_id, achievement_name, achievement_desc, datum/scp_progression_data/prog_data)
	if(!ckey || !achievement_id || !SSpersistent_progression)
		return

	var/already_unlocked = FALSE

	// Unlock in persistent progression system
	var/datum/persistent_player_data/player_data = SSpersistent_progression.get_player_data(ckey)
	if(player_data && !(achievement_id in player_data.achievements))
		player_data.unlock_achievement(achievement_id)

		// Notify player
		for(var/client/C in GLOB.clients)
			if(C.ckey == ckey)
				to_chat(C, "<span class='achievement'>Achievement Unlocked: [achievement_name] - [achievement_desc]</span>")
				break

		// Log achievement
		world.log << "SCP Achievement: [ckey] unlocked [achievement_name] ([achievement_id])"
	else
		already_unlocked = TRUE

	// Track in SCP progression data too so check doesn't re-fire
	if(prog_data && !(achievement_id in prog_data.achievements))
		prog_data.achievements += achievement_id

	if(already_unlocked)
		return

/datum/scp_progression_manager/proc/update_scp_performance_metrics()
	// Update global performance metrics
	var/total_score = 0
	var/total_rounds = 0

	for(var/scp_id in scp_performance_metrics)
		for(var/ckey in scp_performance_metrics[scp_id])
			var/list/player_metrics = scp_performance_metrics[scp_id][ckey]
			total_score += player_metrics["current_score"] || 0
			total_rounds += player_metrics["rounds_played"] || 0

	if(total_rounds > 0)
		average_scp_performance = total_score / total_rounds

/datum/scp_progression_manager/proc/save_scp_progression_data()
	var/filename = "data/scp_progression_data.json"
	var/list/data = list(
		"scp_progression_data" = scp_progression_data,
		"scp_performance_metrics" = scp_performance_metrics,
		"total_scp_rounds_played" = total_scp_rounds_played,
		"total_scp_achievements_unlocked" = total_scp_achievements_unlocked,
		"average_scp_performance" = average_scp_performance,
		"timestamp" = world.time
	)

	rustg_file_write(json_encode(data), filename)

// SCP Progression Data Datum
/datum/scp_progression_data
	var/scp_id
	var/ckey
	var/list/metrics = list()
	var/list/last_metrics = list()
	var/list/achievements = list()
	var/rounds_played = 0
	var/total_experience = 0
	var/last_update = 0

/datum/scp_progression_data/New(scp_id, ckey)
	src.scp_id = scp_id
	src.ckey = ckey
	initialize_metrics()

/datum/scp_progression_data/proc/initialize_metrics()
	// Initialize all SCP metrics to 0
	metrics["victims_hunted"] = 0
	metrics["containment_breaches"] = 0
	metrics["research_progress"] = 0
	metrics["voices_learned"] = 0
	metrics["fires_created"] = 0
	metrics["teleportations"] = 0
	metrics["stealth_actions"] = 0
	metrics["cures_performed"] = 0
	metrics["rage_activations"] = 0
	metrics["successful_movements"] = 0
	metrics["victims_killed"] = 0
	metrics["damage_dealt"] = 0
	metrics["victims_consumed"] = 0
	metrics["pack_coordination"] = 0
	metrics["psychological_manipulations"] = 0
	metrics["victims_eliminated"] = 0

	// Copy to last_metrics
	last_metrics = metrics.Copy()

/datum/scp_progression_data/proc/update_from_scp(mob/living/scp/scp)
	if(!scp || !scp.SCP)
		return

	// Update last_metrics before updating current metrics
	last_metrics = metrics.Copy()

	// Update metrics based on SCP type
	switch(scp.SCP.designation)
		if("049")
			update_scp049_metrics(scp)
		if("096")
			update_scp096_metrics(scp)
		if("173")
			update_scp173_metrics(scp)
		if("457")
			update_scp457_metrics(scp)
		if("939")
			update_scp939_metrics(scp)
		if("2020")
			update_scp2020_metrics(scp)

	last_update = world.time

/datum/scp_progression_data/proc/update_scp049_metrics(mob/living/scp/scp)
	// Update SCP-049 specific metrics
	if(istype(scp, /mob/living/scp/scp049))
		var/mob/living/scp/scp049/scp049 = scp
		metrics["cures_performed"] = scp049.cures_successful
		metrics["containment_breaches"] = scp049.containment_breaches
		metrics["research_progress"] = scp049.research_progress

/datum/scp_progression_data/proc/update_scp096_metrics(mob/living/scp/scp)
	// Update SCP-096 specific metrics
	if(istype(scp, /mob/living/scp/scp096))
		var/mob/living/scp/scp096/scp096 = scp
		metrics["rage_activations"] = scp096.rage_activations
		metrics["victims_hunted"] = scp096.victims_hunted
		metrics["containment_breaches"] = scp096.containment_escapes

/datum/scp_progression_data/proc/update_scp173_metrics(mob/living/scp/scp)
	// Update SCP-173 specific metrics
	if(istype(scp, /mob/living/scp/scp173))
		var/mob/living/scp/scp173/scp173 = scp
		metrics["successful_movements"] = scp173.successful_movements
		metrics["victims_killed"] = scp173.victims_killed
		metrics["containment_breaches"] = scp173.containment_breaches

/datum/scp_progression_data/proc/update_scp457_metrics(mob/living/scp/scp)
	if(istype(scp, /mob/living/scp/scp457))
		var/mob/living/scp/scp457/scp457 = scp
		metrics["current_heat"] = scp457.heat_system.current_heat
		metrics["active_fires"] = length(scp457.fire_system.active_fires)

/datum/scp_progression_data/proc/update_scp939_metrics(mob/living/scp/scp)
	// Update SCP-939 specific metrics
	if(istype(scp, /mob/living/scp/scp939))
		var/mob/living/scp/scp939/scp939 = scp
		if(scp939.voice_system)
			metrics["voices_learned"] = length(scp939.voice_system.learned_voices)


/datum/scp_progression_data/proc/update_scp2020_metrics(mob/living/scp/scp)
	// Update SCP-2020 specific metrics
	if(istype(scp, /mob/living/scp/scp2020))
		var/mob/living/scp/scp2020/scp2020 = scp
		metrics["cliche_count"] = scp2020.cliche_count
		metrics["plot_developments"] = scp2020.plot_developments
		metrics["conversations_held"] = scp2020.conversations_held
