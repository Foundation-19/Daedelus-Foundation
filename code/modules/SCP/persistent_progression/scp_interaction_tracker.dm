#define INTERACTION_RISK_NONE 0
#define INTERACTION_RISK_LOW 1
#define INTERACTION_RISK_MEDIUM 2
#define INTERACTION_RISK_HIGH 3
#define INTERACTION_RISK_CRITICAL 4

SUBSYSTEM_DEF(scp_interactions)
	name = "SCP Interactions"
	wait = 600
	priority = FIRE_PRIORITY_INPUT
	var/datum/scp_interaction_manager/manager

/datum/controller/subsystem/scp_interactions/Initialize()
	manager = new /datum/scp_interaction_manager()
	world.log << "SCP Interaction Tracker: Initialized"
	return ..()

/datum/controller/subsystem/scp_interactions/fire()
	if(manager)
		manager.process_interactions()

/datum/scp_interaction_manager
	var/list/player_logs = list()
	var/list/global_interaction_stats = list()
	var/list/first_contacts = list()
	var/list/interaction_milestones = list()
	
	var/list/survival_tracking = list()
	var/survival_xp_per_minute = 1
	
	var/total_interactions_logged = 0
	var/total_first_contacts = 0

/datum/scp_interaction_manager/proc/process_interactions()
	process_survival_tracking()
	check_milestones()

/datum/scp_interaction_manager/proc/log_interaction(mob/living/carbon/human/player, scp_id, interaction_type, data = null)
	if(!player || !player.ckey || !scp_id)
		return FALSE
	
	var/ckey = player.ckey
	
	if(!(ckey in player_logs))
		player_logs[ckey] = new /datum/scp_interaction_log(ckey)
	
	var/datum/scp_interaction_log/log = player_logs[ckey]
	
	var/is_first_contact = FALSE
	if(!(scp_id in log.scps_interacted))
		is_first_contact = TRUE
		log.scps_interacted += scp_id
		total_first_contacts++
		first_contacts[ckey] = (first_contacts[ckey] || 0) + 1
	
	var/datum/interaction_event/event = new(
		scp_id,
		interaction_type,
		data,
		player.loc,
		player.health,
		is_first_contact
	)
	
	log.add_event(event)
	
	if(is_first_contact)
		award_first_contact(player, scp_id)
	
	award_interaction_xp(player, interaction_type, data)
	
	update_global_stats(scp_id, interaction_type)
	
	total_interactions_logged++
	
	return TRUE

/datum/scp_interaction_manager/proc/award_first_contact(mob/living/carbon/human/player, scp_id)
	if(!player || !player.ckey)
		return
	
	var/xp_reward = 100
	
	if(SSpersistent_progression)
		SSpersistent_progression.award_experience(player.ckey, "research_experiment", xp_reward, "scp_first_contact")
	
	to_chat(player, "<span class='boldnotice'>First contact with [scp_id]! +[xp_reward] XP</span>")

/datum/scp_interaction_manager/proc/award_interaction_xp(mob/living/carbon/human/player, interaction_type, data)
	if(!player || !player.ckey)
		return
	
	var/xp_reward = 0
	var/source = "scp_interaction"
	
	switch(interaction_type)
		if(INTERACTION_TYPE_OBSERVATION)
			xp_reward = 5
			source = "scp_observation"
		if(INTERACTION_TYPE_COMBAT)
			if(data && data["damage_dealt"])
				xp_reward = min(50, data["damage_dealt"] / 2)
			else
				xp_reward = 10
			source = "scp_combat"
		if(INTERACTION_TYPE_CONTAINMENT)
			xp_reward = 25
			source = "scp_containment_assist"
		if(INTERACTION_TYPE_RESEARCH)
			xp_reward = 15
			source = "scp_research"
		if(INTERACTION_TYPE_COMMUNICATION)
			xp_reward = 10
			source = "scp_communication"
		if(INTERACTION_TYPE_EXPERIMENT)
			xp_reward = 20
			source = "scp_experiment"
		if(INTERACTION_TYPE_CARE)
			xp_reward = 15
			source = "scp_care"
		if(INTERACTION_TYPE_EXPLORATION)
			xp_reward = 30
			source = "scp_exploration"
		if(INTERACTION_TYPE_SURVIVAL)
			xp_reward = survival_xp_per_minute
			source = "scp_survival"
	
	if(xp_reward > 0 && SSpersistent_progression)
		SSpersistent_progression.award_experience(player.ckey, "research_experiment", xp_reward, source)

/datum/scp_interaction_manager/proc/update_global_stats(scp_id, interaction_type)
	if(!(scp_id in global_interaction_stats))
		global_interaction_stats[scp_id] = list()
	
	var/type_name = get_interaction_type_name(interaction_type)
	global_interaction_stats[scp_id][type_name] = (global_interaction_stats[scp_id][type_name] || 0) + 1

/datum/scp_interaction_manager/proc/start_survival_tracking(mob/living/carbon/human/player, scp_id, risk_level)
	if(!player || !player.ckey)
		return
	
	var/ckey = player.ckey
	var/tracking_id = "[ckey]_[scp_id]"
	
	survival_tracking[tracking_id] = list(
		"ckey" = ckey,
		"scp_id" = scp_id,
		"risk_level" = risk_level,
		"start_time" = world.time,
		"mob_ref" = WEAKREF(player)
	)

/datum/scp_interaction_manager/proc/stop_survival_tracking(mob/living/carbon/human/player, scp_id)
	if(!player || !player.ckey)
		return
	
	var/tracking_id = "[player.ckey]_[scp_id]"
	
	if(tracking_id in survival_tracking)
		var/list/tracking_data = survival_tracking[tracking_id]
		var/survival_time = world.time - tracking_data["start_time"]
		
		log_interaction(player, scp_id, INTERACTION_TYPE_SURVIVAL, list(
			"survival_time" = survival_time,
			"risk_level" = tracking_data["risk_level"]
		))
		
		survival_tracking -= tracking_id

/datum/scp_interaction_manager/proc/process_survival_tracking()
	for(var/tracking_id in survival_tracking)
		var/list/tracking_data = survival_tracking[tracking_id]
		var/datum/weakref/mob_ref = tracking_data["mob_ref"]
		var/mob/living/carbon/human/player = mob_ref?.resolve()
		
		if(!player || player.stat == DEAD)
			survival_tracking -= tracking_id
			continue
		
		var/risk_bonus = tracking_data["risk_level"] * 0.5
		var/xp = (survival_xp_per_minute + risk_bonus) * 0.1
		
		if(SSpersistent_progression)
			SSpersistent_progression.award_experience(player.ckey, "research_experiment", xp, "scp_survival")

/datum/scp_interaction_manager/proc/check_milestones()
	for(var/ckey in player_logs)
		var/datum/scp_interaction_log/log = player_logs[ckey]
		check_player_milestones(log)

/datum/scp_interaction_manager/proc/check_player_milestones(datum/scp_interaction_log/log)
	var/mob/living/carbon/human/player
	for(var/client/C in GLOB.clients)
		if(C.ckey == log.ckey)
			player = C.mob
			break
	
	if(!player)
		return
	
	var/total_contacts = length(log.scps_interacted)
	var/milestone_id = "contacts_[total_contacts]"
	
	if(!(milestone_id in log.milestones_achieved))
		if(total_contacts >= 5)
			award_milestone(player, "SCP Novice", "Interacted with 5 different SCPs", 50)
			log.milestones_achieved += "contacts_5"
		if(total_contacts >= 10)
			award_milestone(player, "SCP Explorer", "Interacted with 10 different SCPs", 100)
			log.milestones_achieved += "contacts_10"
		if(total_contacts >= 20)
			award_milestone(player, "SCP Veteran", "Interacted with 20 different SCPs", 200)
			log.milestones_achieved += "contacts_20"
		if(total_contacts >= 39)
			award_milestone(player, "SCP Master", "Interacted with all SCPs", 500)
			log.milestones_achieved += "contacts_39"

/datum/scp_interaction_manager/proc/award_milestone(mob/player, title, description, xp_reward)
	if(!player)
		return
	
	to_chat(player, "<span class='boldnotice'>Milestone Achieved: [title]</span>")
	to_chat(player, "<span class='notice'>[description] - +[xp_reward] XP</span>")
	
	if(SSpersistent_progression && player.ckey)
		SSpersistent_progression.award_experience(player.ckey, "research_experiment", xp_reward, "scp_milestone")

/datum/scp_interaction_manager/proc/get_player_log(ckey)
	if(!ckey)
		return null
	if(!(ckey in player_logs))
		player_logs[ckey] = new /datum/scp_interaction_log(ckey)
	return player_logs[ckey]

/datum/scp_interaction_manager/proc/get_interaction_count(ckey, scp_id, interaction_type)
	var/datum/scp_interaction_log/log = get_player_log(ckey)
	if(!log)
		return 0
	return log.get_interaction_count(scp_id, interaction_type)

/datum/scp_interaction_manager/proc/get_total_first_contacts(ckey)
	return first_contacts[ckey] || 0

/datum/scp_interaction_log
	var/ckey
	var/list/events = list()
	var/list/scps_interacted = list()
	var/list/interaction_counts = list()
	var/list/milestones_achieved = list()
	var/total_interactions = 0
	var/first_interaction_time
	var/last_interaction_time

/datum/scp_interaction_log/New(c)
	ckey = c
	first_interaction_time = world.time

/datum/scp_interaction_log/proc/add_event(datum/interaction_event/event)
	events += event
	total_interactions++
	last_interaction_time = world.time
	
	var/key = "[event.scp_id]_[event.interaction_type]"
	interaction_counts[key] = (interaction_counts[key] || 0) + 1

/datum/scp_interaction_log/proc/get_interaction_count(scp_id, interaction_type)
	var/key = "[scp_id]_[interaction_type]"
	return interaction_counts[key] || 0

/datum/scp_interaction_log/proc/get_events_for_scp(scp_id)
	var/list/filtered = list()
	for(var/datum/interaction_event/event in events)
		if(event.scp_id == scp_id)
			filtered += event
	return filtered

/datum/scp_interaction_log/proc/get_events_by_type(interaction_type)
	var/list/filtered = list()
	for(var/datum/interaction_event/event in events)
		if(event.interaction_type == interaction_type)
			filtered += event
	return filtered

/datum/scp_interaction_log/proc/get_summary()
	return list(
		"ckey" = ckey,
		"total_interactions" = total_interactions,
		"unique_scps" = length(scps_interacted),
		"first_interaction" = first_interaction_time,
		"last_interaction" = last_interaction_time,
		"milestones" = length(milestones_achieved)
	)

/datum/interaction_event
	var/scp_id
	var/interaction_type
	var/timestamp
	var/turf/location
	var/player_health
	var/data
	var/is_first_contact
	var/risk_level

/datum/interaction_event/New(scp, type, event_data, turf/loc, health, first_contact)
	scp_id = scp
	interaction_type = type
	timestamp = world.time
	data = event_data
	location = loc
	player_health = health
	is_first_contact = first_contact

/datum/interaction_event/proc/get_type_name()
	return get_interaction_type_name(interaction_type)

/proc/get_interaction_type_name(type)
	switch(type)
		if(INTERACTION_TYPE_OBSERVATION)
			return "Observation"
		if(INTERACTION_TYPE_COMBAT)
			return "Combat"
		if(INTERACTION_TYPE_CONTAINMENT)
			return "Containment"
		if(INTERACTION_TYPE_RESEARCH)
			return "Research"
		if(INTERACTION_TYPE_COMMUNICATION)
			return "Communication"
		if(INTERACTION_TYPE_EXPERIMENT)
			return "Experiment"
		if(INTERACTION_TYPE_CARE)
			return "Care"
		if(INTERACTION_TYPE_EXPLORATION)
			return "Exploration"
		if(INTERACTION_TYPE_SURVIVAL)
			return "Survival"
	return "Unknown"

/proc/log_scp_interaction(mob/living/carbon/human/player, scp_id, interaction_type, data = null)
	if(!SSscp_interactions || !SSscp_interactions.manager)
		return FALSE
	return SSscp_interactions.manager.log_interaction(player, scp_id, interaction_type, data)

/proc/start_scp_survival_tracking(mob/living/carbon/human/player, scp_id, risk_level = INTERACTION_RISK_LOW)
	if(!SSscp_interactions || !SSscp_interactions.manager)
		return
	SSscp_interactions.manager.start_survival_tracking(player, scp_id, risk_level)

/proc/stop_scp_survival_tracking(mob/living/carbon/human/player, scp_id)
	if(!SSscp_interactions || !SSscp_interactions.manager)
		return
	SSscp_interactions.manager.stop_survival_tracking(player, scp_id)

/mob/proc/view_scp_interaction_log()
	set name = "View SCP Interaction Log"
	set category = "SCP"
	set desc = "View your SCP interaction history."
	
	if(!SSscp_interactions || !SSscp_interactions.manager)
		to_chat(src, "<span class='warning'>Interaction tracking system not available.</span>")
		return
	
	var/datum/scp_interaction_log/log = SSscp_interactions.manager.get_player_log(ckey)
	
	if(!log || !length(log.events))
		to_chat(src, "<span class='notice'>No SCP interactions recorded yet.</span>")
		return
	
	var/list/summary = log.get_summary()
	
	var/message = "<h2>SCP Interaction Log</h2>"
	message += "<b>Total Interactions:</b> [summary["total_interactions"]]<br>"
	message += "<b>Unique SCPs Contacted:</b> [summary["unique_scps"]]<br>"
	message += "<b>Milestones Achieved:</b> [summary["milestones"]]<br><br>"
	
	message += "<h3>SCPs Contacted:</h3>"
	for(var/scp_id in log.scps_interacted)
		message += "- [scp_id]<br>"
	
	if(length(log.events) > 0)
		message += "<br><h3>Recent Interactions:</h3>"
		var/recent_count = min(10, length(log.events))
		for(var/i in 1 to recent_count)
			var/datum/interaction_event/event = log.events[length(log.events) - i + 1]
			var/time_ago = round((world.time - event.timestamp) / 600, 0.1)
			message += "- [event.scp_id] ([event.get_type_name()]) - [time_ago] min ago<br>"
	
	to_chat(src, "<span class='notice'>[message]</span>")

/mob/proc/view_scp_stats()
	set name = "View SCP Stats"
	set category = "SCP"
	set desc = "View global SCP interaction statistics."
	
	if(!SSscp_interactions || !SSscp_interactions.manager)
		to_chat(src, "<span class='warning'>Interaction tracking system not available.</span>")
		return
	
	var/datum/scp_interaction_manager/manager = SSscp_interactions.manager
	
	var/message = "<h2>Global SCP Statistics</h2>"
	message += "<b>Total Interactions Logged:</b> [manager.total_interactions_logged]<br>"
	message += "<b>Total First Contacts:</b> [manager.total_first_contacts]<br><br>"
	
	message += "<h3>Interactions by SCP:</h3>"
	for(var/scp_id in manager.global_interaction_stats)
		var/list/counts = manager.global_interaction_stats[scp_id]
		var/total = 0
		for(var/type in counts)
			total += counts[type]
		message += "<b>[scp_id]:</b> [total] interactions<br>"
	
	to_chat(src, "<span class='notice'>[message]</span>")
