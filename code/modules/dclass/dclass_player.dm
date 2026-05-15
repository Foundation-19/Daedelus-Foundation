// D-Class Player Datum
// Handles individual D-Class player data and progression

#ifndef DCLASS_TRUST_HOSTILE
#define DCLASS_TRUST_HOSTILE 0
#define DCLASS_TRUST_SUSPICIOUS 1
#define DCLASS_TRUST_NEUTRAL 2
#define DCLASS_TRUST_COOPERATIVE 3
#define DCLASS_TRUST_TRUSTED 4

#define DCLASS_STATUS_GENERAL 0
#define DCLASS_STATUS_TEST_SUBJECT 1
#define DCLASS_STATUS_MEDICAL_SUBJECT 2
#define DCLASS_STATUS_CONTAINMENT_ASSIST 3
#endif

#define DCLASS_FACTION_NONE 0
#define DCLASS_FACTION_REBELS 1
#define DCLASS_FACTION_COLLABORATORS 2
#define DCLASS_FACTION_SURVIVORS 3

/datum/dclass_player
	var/ckey
	var/name
	var/dclass_number
	var/mob/living/carbon/human/mob

	// Progression
	var/level = 1
	var/experience = 0
	var/reputation = 0
	var/trust_level = DCLASS_TRUST_NEUTRAL
	var/trust_points = 50
	var/status = DCLASS_STATUS_GENERAL

	// Economy
	var/credits = 100
	var/credits_lifetime = 0

	// Sentence & Behavior
	var/sentence_remaining = -1
	var/strikes = 0
	var/warnings = 0
	var/good_behavior_points = 0
	var/bad_behavior_points = 0

	// Testing
	var/tests_completed = 0
	var/tests_successful = 0
	var/tests_failed = 0
	var/research_contributions = 0

	// Escape
	var/escape_attempts = 0
	var/successful_escapes = 0

	// Informant
	var/informant = FALSE
	var/informant_reports = 0

	// Current Status
	var/current_work_assignment = null
	var/current_cell = null
	var/current_location = null
	var/suspicion_level = 0
	var/last_seen_time = 0
	var/is_hiding = FALSE
	var/can_volunteer = FALSE

	// Inventory & Contraband
	var/list/contraband = list()
	var/list/hidden_items = list()
	var/list/crafted_items = list()
	var/list/escape_plans = list()

	// Social & Alliances
	var/list/allies = list()
	var/list/enemies = list()
	var/list/trade_history = list()
	var/list/reported_players = list()
	var/faction = DCLASS_FACTION_NONE

	// Skills & Routes
	var/list/skills = list()
	var/list/known_routes = list()
	var/list/guard_patterns = list()

	// Achievements & Records
	var/list/achievements = list()
	var/list/incidents = list()
	var/list/commendations = list()

	// Persistence
	var/last_save_time = 0
	var/save_interval = 300
	var/data_file_path = ""

/datum/dclass_player/New(var/player_ckey)
	ckey = player_ckey
	data_file_path = "data/dclass/[ckey].json"
	generate_dclass_number()
	initialize_skills()
	load_data()

/datum/dclass_player/proc/generate_dclass_number()
	dclass_number = "D-[rand(1000, 9999)]"

/datum/dclass_player/proc/initialize_skills()
	skills["escape_planning"] = 1

/datum/dclass_player/proc/process_player()
	// Update suspicion level
	update_suspicion()

	// Check for detection
	check_detection()

	// Process current work assignment
	if(current_work_assignment)
		process_work_assignment()

	// Save data periodically
	if(world.time > last_save_time + save_interval)
		save_data()
		last_save_time = world.time

// Experience and Leveling
/datum/dclass_player/proc/gain_experience(amount, reason = "Unknown")
	experience += amount

	// Check for level up
	var/required_exp = calculate_required_experience(level)
	if(experience >= required_exp && level < 5)
		level_up()

	// Notify player
	if(mob)
		to_chat(mob, "<span class='notice'>You gained [amount] experience for [reason]. Total: [experience]/[required_exp]</span>")

/datum/dclass_player/proc/calculate_required_experience(current_level)
	switch(current_level)
		if(1) return 100
		if(2) return 300
		if(3) return 600
		if(4) return 1000
		if(5) return 999999 // Max level
		else return 100

/datum/dclass_player/proc/level_up()
	level++
	experience = 0

	// Notify player
	if(mob)
		to_chat(mob, "<span class='notice'>Congratulations! You are now Level [level] D-Class!</span>")
		to_chat(mob, "<span class='notice'>New abilities and opportunities are now available.</span>")

// Work Assignment System
/datum/dclass_player/proc/assign_work(work_id)
	if(!SSdclass || !SSdclass.manager)
		return

	var/list/work_data = SSdclass.manager.work_assignments[work_id]
	if(!work_data)
		return

	current_work_assignment = work_id

	if(mob)
		to_chat(mob, "<span class='notice'>You have been assigned to [work_data["name"]]: [work_data["description"]]</span>")
		to_chat(mob, "<span class='notice'>Risk Level: [work_data["risk"]], Reward: [work_data["reward"]] XP</span>")

/datum/dclass_player/proc/process_work_assignment()
	if(!current_work_assignment || !SSdclass || !SSdclass.manager)
		return

	var/list/work_data = SSdclass.manager.work_assignments[current_work_assignment]
	if(!work_data)
		return

	// Check if player is in the correct work area
	if(mob && is_in_work_area())
		// Gain experience for working
		gain_experience(work_data["reward"] / 10, "working") // Divide by 10 for continuous gain

		// Chance to find contraband
		if(prob(5)) // 5% chance per process cycle
			find_contraband_at_work()

/datum/dclass_player/proc/is_in_work_area()
	if(!mob || !current_work_assignment)
		return FALSE

	var/area/A = get_area(mob)
	if(!A)
		return FALSE

	// Also check area type hierarchy
	var/work_area_found = FALSE
	switch(current_work_assignment)
		if("kitchen")
			work_area_found = (findtext(A.name, "kitchen") || findtext(A.name, "cafeteria") || istype(A, /area/station/service/hydroponics))
		if("maintenance")
			work_area_found = (findtext(A.name, "maintenance") || findtext(A.name, "engineering") || istype(A, /area/station/engineering))
		if("laundry")
			work_area_found = (findtext(A.name, "laundry") || findtext(A.name, "cleaning") || findtext(A.name, "custodial"))
		if("medical")
			work_area_found = (findtext(A.name, "medical") || findtext(A.name, "clinic") || findtext(A.name, "medbay") || istype(A, /area/station/medical))
		if("science")
			work_area_found = (findtext(A.name, "research") || findtext(A.name, "laboratory") || findtext(A.name, "science") || istype(A, /area/station/science) || istype(A, /area/scp/lcz/testing_lab) || istype(A, /area/scp/lcz/observation))

	return work_area_found

/datum/dclass_player/proc/find_contraband_at_work()
	if(!current_work_assignment || !SSdclass || !SSdclass.manager)
		return

	var/list/contraband_data = SSdclass.manager.contraband_locations[current_work_assignment]
	if(!contraband_data)
		return

	// Find a random contraband item
	for(var/item in contraband_data)
		if(prob(contraband_data[item]))
			add_contraband(item)
			if(mob)
				to_chat(mob, "<span class='notice'>You found [item] while working!</span>")
			break

// Contraband System
/datum/dclass_player/proc/add_contraband(item)
	if(!(item in contraband))
		contraband[item] = 0
	contraband[item]++

	// Increase suspicion slightly
	increase_suspicion(5)

/datum/dclass_player/proc/remove_contraband(item, amount = 1)
	if(!(item in contraband))
		return FALSE

	contraband[item] -= amount
	if(contraband[item] <= 0)
		contraband -= item

	return TRUE

/datum/dclass_player/proc/has_contraband(item)
	return (item in contraband) && contraband[item] > 0

/datum/dclass_player/proc/get_contraband_count(item)
	return contraband[item] || 0

// Suspicion and Detection
/datum/dclass_player/proc/increase_suspicion(amount)
	suspicion_level = min(100, suspicion_level + amount)

	// Check for security level increase
	if(suspicion_level >= 80 && SSdclass && SSdclass.manager)
		SSdclass.manager.set_security_level(SSdclass.manager.get_security_level() + 1)

/datum/dclass_player/proc/decrease_suspicion(amount)
	suspicion_level = max(0, suspicion_level - amount)

/datum/dclass_player/proc/update_suspicion()
	// Natural suspicion decay
	if(suspicion_level > 0)
		decrease_suspicion(1) // Decay 1 point per process cycle

	// Update last seen time
	if(mob)
		last_seen_time = world.time

/datum/dclass_player/proc/check_detection()
	if(!mob)
		return

	// Check if player is being observed by guards
	var/list/nearby_guards = list()
	var/list/guard_jobs = list("Security Officer", "MTF Commander", "MTF Operative", "MTF Medic", "MTF Heavy", "Warden", "Head of Security")
	for(var/mob/living/carbon/human/H in view(7, mob))
		if(H.job && (H.job in guard_jobs))
			nearby_guards += H

	// If guards are nearby and player has contraband, risk detection
	if(length(nearby_guards) > 0 && length(contraband) > 0)
		var/detection_chance = suspicion_level / 10 // 0-10% based on suspicion
		if(prob(detection_chance))
			detect_contraband(pick(nearby_guards))

/datum/dclass_player/proc/detect_contraband(mob/living/carbon/human/guard)
	// Guard discovers contraband
	increase_suspicion(20)

	if(mob)
		to_chat(mob, "<span class='danger'>A guard has discovered your contraband!</span>")

	if(guard)
		to_chat(guard, "<span class='warning'>You found contraband on [mob?.name || "D-Class"]!</span>")

	// Remove some contraband
	var/items_to_remove = min(2, length(contraband))
	for(var/i = 1 to items_to_remove)
		if(length(contraband) > 0)
			var/random_item = pick(contraband)
			remove_contraband(random_item, 1)

// Escape System
/datum/dclass_player/proc/attempt_escape(escape_type)
	if(!SSdclass || !SSdclass.manager)
		return FALSE

	var/list/escape_data = SSdclass.manager.escape_routes[escape_type]
	if(!escape_data)
		return FALSE

	escape_attempts++

	if(!check_escape_requirements(escape_data["requirements"]))
		if(mob)
			to_chat(mob, "<span class='warning'>You don't have the required items for this escape route.</span>")
		return FALSE

	for(var/obj/structure/dclass_escape_point/EP as anything in INSTANCES_OF(/obj/structure/dclass_escape_point))
		if(EP.route_id == escape_type && EP.route && EP.discovered)
			return EP.route.attempt_escape(mob)

	var/success_chance = escape_data["success_chance"]
	success_chance += (skills["escape_planning"] - 1) * 10
	success_chance -= (SSdclass.manager.get_security_level() - 1) * 10

	if(prob(success_chance))
		successful_escape(escape_type)
		return TRUE
	else
		failed_escape(escape_type)
		return FALSE

/datum/dclass_player/proc/check_escape_requirements(list/requirements)
	for(var/requirement in requirements)
		if(!has_contraband(requirement))
			return FALSE
	return TRUE

/datum/dclass_player/proc/successful_escape(escape_type)
	successful_escapes++
	gain_experience(200, "successful escape")

	if(mob)
		to_chat(mob, "<span class='notice'>Congratulations! You have successfully escaped using the [escape_type] route!</span>")
		to_chat(mob, "<span class='notice'>You are now free!</span>")

/datum/dclass_player/proc/failed_escape(escape_type)
	increase_suspicion(30)

	if(mob)
		to_chat(mob, "<span class='danger'>Your escape attempt failed! Security has been increased.</span>")

// Notification System
/datum/dclass_player/proc/notify_spawn()
	if(mob)
		to_chat(mob, "<span class='notice'>Welcome to D-Class containment. Your goal is to escape!</span>")
		to_chat(mob, "<span class='notice'>Current Level: [level], Experience: [experience]</span>")

/datum/dclass_player/proc/notify_cell_inspection()
	if(mob)
		to_chat(mob, "<span class='warning'>Cell inspection in progress. Hide any contraband!</span>")

/datum/dclass_player/proc/notify_cafeteria_open()
	if(mob)
		to_chat(mob, "<span class='notice'>Cafeteria is now open for meal time.</span>")

/datum/dclass_player/proc/notify_work_assignment()
	if(mob)
		to_chat(mob, "<span class='notice'>Work assignments are being distributed.</span>")

/datum/dclass_player/proc/notify_recreation_open()
	if(mob)
		to_chat(mob, "<span class='notice'>Recreation areas are now open.</span>")

/datum/dclass_player/proc/notify_showers_open()
	if(mob)
		to_chat(mob, "<span class='notice'>Shower areas are now open.</span>")

/datum/dclass_player/proc/notify_lockdown()
	if(mob)
		to_chat(mob, "<span class='danger'>Lockdown procedures initiated. Security level increased.</span>")

/datum/dclass_player/proc/notify_lights_out()
	if(mob)
		to_chat(mob, "<span class='notice'>Lights out. High-risk escape attempts may be attempted.</span>")

/datum/dclass_player/proc/notify_security_level_change(new_level)
	if(mob)
		to_chat(mob, "<span class='warning'>Security level changed to [new_level]. Escape attempts are now more difficult.</span>")

// Trust System
/datum/dclass_player/proc/adjust_trust(amount, reason)
	var/old_trust = trust_level
	trust_points = clamp(trust_points + amount, 0, 100)
	var/new_trust = get_trust_from_points(trust_points)
	if(new_trust != old_trust)
		trust_level = new_trust
		if(mob)
			to_chat(mob, span_notice("Your trust level is now [get_trust_name(trust_level)]."))
	return trust_level

/datum/dclass_player/proc/get_trust_from_points(points)
	switch(points)
		if(0 to 19)
			return DCLASS_TRUST_HOSTILE
		if(20 to 39)
			return DCLASS_TRUST_SUSPICIOUS
		if(40 to 59)
			return DCLASS_TRUST_NEUTRAL
		if(60 to 79)
			return DCLASS_TRUST_COOPERATIVE
		if(80 to 100)
			return DCLASS_TRUST_TRUSTED

/datum/dclass_player/proc/get_trust_name(level)
	switch(level)
		if(DCLASS_TRUST_HOSTILE)
			return "Hostile"
		if(DCLASS_TRUST_SUSPICIOUS)
			return "Suspicious"
		if(DCLASS_TRUST_NEUTRAL)
			return "Neutral"
		if(DCLASS_TRUST_COOPERATIVE)
			return "Cooperative"
		if(DCLASS_TRUST_TRUSTED)
			return "Trusted"

// Credits System
/datum/dclass_player/proc/adjust_credits(amount, reason)
	if(amount < 0 && credits + amount < 0)
		return FALSE
	credits += amount
	if(amount > 0)
		credits_lifetime += amount
	return TRUE

// Incident & Commendation System
/datum/dclass_player/proc/add_incident(incident_type, description, severity = "minor")
	var/list/incident = list(
		"type" = incident_type,
		"description" = description,
		"severity" = severity,
		"timestamp" = world.time
	)
	incidents += list(incident)
	switch(severity)
		if("minor")
			adjust_trust(-5, "Minor incident: [incident_type]")
			warnings++
		if("major")
			adjust_trust(-15, "Major incident: [incident_type]")
			strikes++
		if("severe")
			adjust_trust(-30, "Severe incident: [incident_type]")
			strikes += 2
			bad_behavior_points += 50
	return TRUE

/datum/dclass_player/proc/add_commendation(commendation_type, description, reward_credits = 0)
	var/list/commendation = list(
		"type" = commendation_type,
		"description" = description,
		"reward" = reward_credits,
		"timestamp" = world.time
	)
	commendations += list(commendation)
	if(reward_credits > 0)
		adjust_credits(reward_credits, "Commendation reward: [commendation_type]")
	adjust_trust(10, "Commendation: [commendation_type]")
	good_behavior_points += 10
	return TRUE

// Test Recording
/datum/dclass_player/proc/record_test(scp_id, test_type, outcome, danger_level)
	tests_completed++
	switch(outcome)
		if("success", "partial_success")
			tests_successful++
			var/reward = calculate_test_reward(danger_level)
			adjust_credits(reward, "Successful test: [scp_id]")
			adjust_trust(5, "Test cooperation")
			research_contributions++
		if("failure")
			tests_failed++
			adjust_trust(2, "Test participation")
		if("refused")
			adjust_trust(-5, "Test refusal")
			add_incident("test_refusal", "Refused to participate in test with [scp_id]", "minor")

/datum/dclass_player/proc/calculate_test_reward(danger_level)
	var/base_reward = 50
	switch(danger_level)
		if(1 to 2)
			base_reward = 75
		if(3 to 4)
			base_reward = 150
		if(5 to INFINITY)
			base_reward = 300
	return base_reward + (trust_level * 10)

// Informant System
/datum/dclass_player/proc/become_informant()
	if(informant)
		return FALSE
	informant = TRUE
	adjust_trust(20, "Became informant")
	adjust_credits(500, "Informant signup bonus")
	return TRUE

/datum/dclass_player/proc/report_escape_plan(plan_name, participants_count)
	if(!informant)
		return FALSE
	informant_reports++
	var/reward = 200 + (participants_count * 50)
	adjust_credits(reward, "Reported escape plan")
	adjust_trust(10, "Reported escape plan")
	return TRUE

// Sentence Management
/datum/dclass_player/proc/reduce_sentence(days = 1)
	if(sentence_remaining == -1)
		return FALSE
	sentence_remaining = max(0, sentence_remaining - days)
	if(sentence_remaining <= 0 && mob)
		to_chat(mob, span_green("Your sentence has been served. You are now eligible for release."))
	return TRUE

// Data Persistence
/datum/dclass_player/proc/save_data()
	var/list/data = list(
		"level" = level,
		"experience" = experience,
		"reputation" = reputation,
		"trust_level" = trust_level,
		"trust_points" = trust_points,
		"status" = status,
		"credits" = credits,
		"credits_lifetime" = credits_lifetime,
		"strikes" = strikes,
		"warnings" = warnings,
		"good_behavior_points" = good_behavior_points,
		"bad_behavior_points" = bad_behavior_points,
		"tests_completed" = tests_completed,
		"tests_successful" = tests_successful,
		"tests_failed" = tests_failed,
		"research_contributions" = research_contributions,
		"escape_attempts" = escape_attempts,
		"successful_escapes" = successful_escapes,
		"suspicion_level" = suspicion_level,
		"contraband" = contraband,
		"skills" = skills,
		"allies" = allies,
		"enemies" = enemies,
		"achievements" = achievements,
		"incidents" = incidents,
		"commendations" = commendations,
		"informant" = informant,
		"informant_reports" = informant_reports,
		"dclass_number" = dclass_number,
		"sentence_remaining" = sentence_remaining
	)

	var/filename = data_file_path
	var/temp_filename = "[filename].tmp"
	text2file(json_encode(data), temp_filename)
	if(fexists(filename))
		fdel(filename)
	fcopy(temp_filename, filename)
	if(fexists(temp_filename))
		fdel(temp_filename)

/datum/dclass_player/proc/load_data()
	if(!fexists(data_file_path))
		return

	var/json_data = file2text(data_file_path)
	var/list/data = json_decode(json_data)
	if(!data)
		return

	level = data["level"] || 1
	experience = data["experience"] || 0
	reputation = data["reputation"] || 0
	trust_level = data["trust_level"] || DCLASS_TRUST_NEUTRAL
	trust_points = data["trust_points"] || 50
	status = data["status"] || DCLASS_STATUS_GENERAL
	credits = data["credits"] || 100
	credits_lifetime = data["credits_lifetime"] || 0
	strikes = data["strikes"] || 0
	warnings = data["warnings"] || 0
	good_behavior_points = data["good_behavior_points"] || 0
	bad_behavior_points = data["bad_behavior_points"] || 0
	tests_completed = data["tests_completed"] || 0
	tests_successful = data["tests_successful"] || 0
	tests_failed = data["tests_failed"] || 0
	research_contributions = data["research_contributions"] || 0
	escape_attempts = data["escape_attempts"] || 0
	successful_escapes = data["successful_escapes"] || 0
	suspicion_level = (data["suspicion_level"] != null) ? data["suspicion_level"] : 0
	contraband = data["contraband"] || list()
	skills = data["skills"] || skills
	allies = data["allies"] || list()
	enemies = data["enemies"] || list()
	achievements = data["achievements"] || list()
	incidents = data["incidents"] || list()
	commendations = data["commendations"] || list()
	informant = data["informant"] || FALSE
	informant_reports = data["informant_reports"] || 0
	dclass_number = data["dclass_number"] || dclass_number
	sentence_remaining = data["sentence_remaining"] || -1

// Utility Functions
/datum/dclass_player/proc/get_status_info()
	var/info = "<h3>D-Class Status Report</h3>"
	info += "<b>Number:</b> [dclass_number]<br>"
	info += "<b>Name:</b> [name]<br>"
	info += "<b>Level:</b> [level]/5<br>"
	info += "<b>Experience:</b> [experience]/[calculate_required_experience(level)]<br>"
	info += "<b>Trust:</b> [get_trust_name(trust_level)] ([trust_points]%)<br>"
	info += "<b>Credits:</b> [credits] (Lifetime: [credits_lifetime])<br>"
	info += "<b>Reputation:</b> [reputation]<br>"
	info += "<b>Suspicion:</b> [suspicion_level]/100<br>"
	info += "<b>Tests Completed:</b> [tests_completed] ([tests_successful] successful)<br>"
	info += "<b>Escape Attempts:</b> [escape_attempts]<br>"
	info += "<b>Successful Escapes:</b> [successful_escapes]<br>"

	if(current_work_assignment)
		info += "<b>Current Work:</b> [current_work_assignment]<br>"

	if(strikes > 0 || warnings > 0)
		info += "<b>Strikes:</b> [strikes]/3 | <b>Warnings:</b> [warnings]<br>"

	if(informant)
		info += "<b>Informant:</b> Yes ([informant_reports] reports)<br>"

	info += "<b>Contraband:</b> [length(contraband)] items<br>"
	info += "<b>Skills:</b> [length(skills)] skills<br>"
	info += "<b>Achievements:</b> [length(achievements)]<br>"

	return info

