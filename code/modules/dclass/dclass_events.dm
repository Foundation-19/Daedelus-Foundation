// D-Class Dynamic Events System
// Integrates with the random event system to provide SCP-related opportunities

/datum/dclass_event
	var/name = "Generic Event"
	var/description = "A generic event description"
	var/event_type = "neutral" // neutral, opportunity, threat, escape
	var/duration = 300 // 5 minutes default
	var/start_time = 0
	var/active = FALSE
	var/affected_areas = list()
	var/required_scp = null // SCP that must be present for this event
	var/event_effects = list()
	var/escape_bonus = 0 // Bonus to escape attempts during this event
	var/contraband_bonus = 0 // Bonus to finding contraband during this event
	var/security_impact = 0 // Impact on security level (-2 to +2)

// SCP Integration Events
/datum/dclass_event/scp_breach
	name = "SCP Breach"
	description = "An SCP has breached containment! Chaos creates opportunities for escape."
	event_type = "opportunity"
	duration = 600 // 10 minutes
	escape_bonus = 25
	contraband_bonus = 15
	security_impact = -1 // Security is distracted

/datum/dclass_event/scp_breach/start_event()
	. = ..()
	// Find nearby SCPs and create chaos
	for(var/mob/living/scp/S in GLOB.mob_list)
		if(S.stat != DEAD)
			// Make SCPs more aggressive during breach
			S.containment_status = "breached"
			// Notify all D-Class of the opportunity
			for(var/ckey in SSdclass.manager.dclass_players)
				var/datum/dclass_player/player = SSdclass.manager.dclass_players[ckey]
				if(player && player.mob)
					to_chat(player.mob, "<span class='notice'>An SCP has breached! This is your chance to escape!</span>")

/datum/dclass_event/scp_research
	name = "SCP Research Opportunity"
	description = "Researchers are conducting experiments on SCPs. You might be able to steal valuable materials."
	event_type = "opportunity"
	duration = 450 // 7.5 minutes
	contraband_bonus = 20
	escape_bonus = 10

/datum/dclass_event/scp_research/start_event()
	. = ..()
	// Spawn research materials in research areas
	for(var/area/A in GLOB.areas)
		if(findtext(A.name, "research") || findtext(A.name, "lab"))
			affected_areas += A
			// Add research materials to contraband locations
			if(!SSdclass.manager.contraband_locations[A.name])
				SSdclass.manager.contraband_locations[A.name] = list()
			SSdclass.manager.contraband_locations[A.name]["research_notes"] = 40
			SSdclass.manager.contraband_locations[A.name]["chemicals"] = 60
			SSdclass.manager.contraband_locations[A.name]["electronic_components"] = 50

/datum/dclass_event/scp_containment_failure
	name = "Containment System Failure"
	description = "The containment systems are failing! Security is overwhelmed."
	event_type = "opportunity"
	duration = 300 // 5 minutes
	escape_bonus = 30
	security_impact = -2

/datum/dclass_event/scp_containment_failure/start_event()
	. = ..()
	// Disable some security systems temporarily
	for(var/obj/machinery/door/airlock/security/A as anything in INSTANCES_OF(/obj/machinery/door/airlock/security))
		if(prob(30)) // 30% chance to disable each security door
			A.emergency = TRUE
			A.update_icon()

/datum/dclass_event/scp_escape_attempt
	name = "SCP Escape Attempt"
	description = "An SCP is attempting to escape! You could use this as a distraction."
	event_type = "opportunity"
	duration = 240 // 4 minutes
	escape_bonus = 20
	security_impact = -1

/datum/dclass_event/scp_escape_attempt/start_event()
	. = ..()
	// Create a distraction by making an SCP more active
	for(var/mob/living/scp/S in GLOB.mob_list)
		if(S.stat != DEAD && prob(50))
			// Make the SCP more visible and active
			S.containment_status = "active"
			// Notify guards of the SCP activity
			for(var/mob/living/carbon/human/H in GLOB.player_list)
				if(H.job && findtext(H.job, "Guard"))
					to_chat(H, "<span class='warning'>SCP activity detected! Respond immediately!</span>")

// Threat Events
/datum/dclass_event/security_crackdown
	name = "Security Crackdown"
	description = "Security has increased patrols and is conducting thorough searches."
	event_type = "threat"
	duration = 360 // 6 minutes
	escape_bonus = -15
	contraband_bonus = -20
	security_impact = 2

/datum/dclass_event/security_crackdown/start_event()
	. = ..()
	// Increase guard patrol frequency
	for(var/patrol_name in SSdclass.manager.guard_patrols)
		var/list/patrol_data = SSdclass.manager.guard_patrols[patrol_name]
		patrol_data["frequency"] = max(60, patrol_data["frequency"] / 2) // Double patrol frequency

/datum/dclass_event/contraband_raid
	name = "Contraband Raid"
	description = "Security is conducting a massive contraband raid. Hide your items!"
	event_type = "threat"
	duration = 300 // 5 minutes
	escape_bonus = -10
	security_impact = 1

/datum/dclass_event/contraband_raid/start_event()
	. = ..()
	// Force all D-Class to hide contraband or risk detection
	for(var/ckey in SSdclass.manager.dclass_players)
		var/datum/dclass_player/player = SSdclass.manager.dclass_players[ckey]
		if(player && player.mob)
			to_chat(player.mob, "<span class='danger'>Security is conducting a contraband raid! Hide your items immediately!</span>")
			// Increase detection chance for all contraband
			player.increase_suspicion(10)

// Neutral Events
/datum/dclass_event/power_outage
	name = "Power Outage"
	description = "A power outage has affected the facility. Some systems are offline."
	event_type = "neutral"
	duration = 180 // 3 minutes
	escape_bonus = 5
	security_impact = -1

/datum/dclass_event/power_outage/start_event()
	. = ..()
	// Disable some electronic systems
	for(var/obj/machinery/door/airlock/A as anything in INSTANCES_OF(/obj/machinery/door/airlock))
		if(prob(20)) // 20% chance to disable each door
			A.emergency = TRUE
			A.update_icon()

/datum/dclass_event/medical_emergency
	name = "Medical Emergency"
	description = "A medical emergency has occurred. Medical staff are distracted."
	event_type = "neutral"
	duration = 240 // 4 minutes
	contraband_bonus = 10

/datum/dclass_event/medical_emergency/start_event()
	. = ..()
	// Add medical supplies to contraband locations
	for(var/area/A in GLOB.areas)
		if(findtext(A.name, "medical") || findtext(A.name, "clinic"))
			affected_areas += A
			if(!SSdclass.manager.contraband_locations[A.name])
				SSdclass.manager.contraband_locations[A.name] = list()
			SSdclass.manager.contraband_locations[A.name]["medicine"] = 80
			SSdclass.manager.contraband_locations[A.name]["bandages"] = 90

// Event Management System
/datum/dclass_event_manager
	var/list/available_events = list()
	var/list/active_events = list()
	var/last_event_time = 0
	var/event_cooldown = 1200 // 20 minutes between events
	var/max_concurrent_events = 2

/datum/dclass_event_manager/New()
	. = ..()
	initialize_events()

/datum/dclass_event_manager/proc/initialize_events()
	available_events += new /datum/dclass_event/scp_breach()
	available_events += new /datum/dclass_event/scp_research()
	available_events += new /datum/dclass_event/scp_containment_failure()
	available_events += new /datum/dclass_event/scp_escape_attempt()
	available_events += new /datum/dclass_event/security_crackdown()
	available_events += new /datum/dclass_event/contraband_raid()
	available_events += new /datum/dclass_event/power_outage()
	available_events += new /datum/dclass_event/medical_emergency()

/datum/dclass_event_manager/proc/process_events()
	// Check if it's time for a new event
	if(world.time > last_event_time + event_cooldown && length(active_events) < max_concurrent_events)
		trigger_random_event()

	// Process active events
	for(var/datum/dclass_event/event in active_events)
		if(world.time > event.start_time + event.duration)
			end_event(event)

/datum/dclass_event_manager/proc/trigger_random_event()
	var/list/possible_events = list()

	// Check for SCPs in the world to determine available events
	var/has_scps = FALSE
	for(var/mob/living/scp/S in GLOB.mob_list)
		if(S.stat != DEAD)
			has_scps = TRUE
			break

	for(var/datum/dclass_event/event in available_events)
		// Only include SCP events if SCPs are present
		if(findtext(event.name, "SCP") && !has_scps)
			continue

		// Don't repeat the same event type if it's already active
		var/event_already_active = FALSE
		for(var/datum/dclass_event/active_event in active_events)
			if(active_event.name == event.name)
				event_already_active = TRUE
				break

		if(!event_already_active)
			possible_events += event

	if(length(possible_events) > 0)
		var/datum/dclass_event/selected_event = pick(possible_events)
		start_event(selected_event)

/datum/dclass_event_manager/proc/start_event(datum/dclass_event/event)
	event.start_time = world.time
	event.active = TRUE
	active_events += event

	// Apply event effects
	event.start_event()

	// Notify all D-Class players
	for(var/ckey in SSdclass.manager.dclass_players)
		var/datum/dclass_player/player = SSdclass.manager.dclass_players[ckey]
		if(player && player.mob)
			to_chat(player.mob, "<span class='notice'><b>[event.name]:</b> [event.description]</span>")

	// Update security level
	if(event.security_impact != 0)
		var/new_level = SSdclass.manager.get_security_level() + event.security_impact
		SSdclass.manager.set_security_level(max(1, min(4, new_level)))

	last_event_time = world.time

/datum/dclass_event_manager/proc/end_event(datum/dclass_event/event)
	event.active = FALSE
	active_events -= event

	// Revert event effects
	event.end_event()

	// Notify all D-Class players
	for(var/ckey in SSdclass.manager.dclass_players)
		var/datum/dclass_player/player = SSdclass.manager.dclass_players[ckey]
		if(player && player.mob)
			to_chat(player.mob, "<span class='notice'>The [event.name] has ended.</span>")

// Event base procs
/datum/dclass_event/proc/start_event()
	// Override in specific events
	return

/datum/dclass_event/proc/end_event()
	// Override in specific events
	return

// Integration with main D-Class system
/datum/dclass_manager/proc/initialize_events()
	event_manager = new /datum/dclass_event_manager()

/datum/dclass_manager/proc/process_events()
	if(event_manager)
		event_manager.process_events()

// Note: process_dclass() is defined in dclass_system.dm and should include process_events() call

// Enhanced player processing with event bonuses
/datum/dclass_player/proc/process_player_with_events()
	// Update suspicion level
	update_suspicion()

	// Check for detection
	check_detection()

	// Process current work assignment with event bonuses
	if(current_work_assignment)
		process_work_assignment_with_events()

	// Save data periodically
	if(world.time > last_save_time + save_interval)
		save_data()
		last_save_time = world.time

/datum/dclass_player/proc/process_work_assignment_with_events()
	if(!current_work_assignment || !SSdclass || !SSdclass.manager)
		return

	var/list/work_data = SSdclass.manager.work_assignments[current_work_assignment]
	if(!work_data)
		return

	// Check if player is in the correct work area
	if(mob && is_in_work_area())
		// Gain experience for working
		gain_experience(work_data["reward"] / 10, "working")

		// Apply event bonuses to contraband finding
		var/contraband_chance = 5 // Base 5% chance
		if(SSdclass.manager.event_manager)
			for(var/datum/dclass_event/event in SSdclass.manager.event_manager.active_events)
				contraband_chance += event.contraband_bonus

		if(prob(contraband_chance))
			find_contraband_at_work()

// Enhanced escape attempts with event bonuses
/datum/dclass_player/proc/attempt_escape_with_events(escape_type)
	if(!SSdclass || !SSdclass.manager)
		return FALSE

	var/list/escape_data = SSdclass.manager.escape_routes[escape_type]
	if(!escape_data)
		return FALSE

	escape_attempts++

	// Check if player meets requirements
	if(!check_escape_requirements(escape_data["requirements"]))
		if(mob)
			to_chat(mob, "<span class='warning'>You don't have the required items for this escape route.</span>")
		return FALSE

	// Calculate success chance with event bonuses
	var/success_chance = escape_data["success_chance"]
	success_chance += (skills["escape_planning"] - 1) * 10 // Skill bonus
	success_chance -= (SSdclass.manager.get_security_level() - 1) * 10 // Security penalty

	// Apply event bonuses
	if(SSdclass.manager.event_manager)
		for(var/datum/dclass_event/event in SSdclass.manager.event_manager.active_events)
			success_chance += event.escape_bonus

	// Attempt escape
	if(prob(success_chance))
		successful_escape(escape_type)
		return TRUE
	else
		failed_escape(escape_type)
		return FALSE
