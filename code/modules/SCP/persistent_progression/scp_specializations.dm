#define SPEC_TRACK_RESEARCH "research"
#define SPEC_TRACK_CONTAINMENT "containment"
#define SPEC_TRACK_FIELD "field"
#define SPEC_TRACK_MEDICAL "medical"

#define SPEC_TIER_TRAINEE "trainee"
#define SPEC_TIER_JUNIOR "junior"
#define SPEC_TIER_AGENT "agent"
#define SPEC_TIER_SENIOR "senior"
#define SPEC_TIER_SPECIALIST "specialist"

SUBSYSTEM_DEF(scp_specializations)
	name = "SCP Specializations"
	wait = 600
	priority = FIRE_PRIORITY_INPUT
	var/datum/specialization_manager/manager

/datum/controller/subsystem/scp_specializations/Initialize()
	manager = new /datum/specialization_manager()
	manager.initialize_specializations()
	log_game("SCP Specialization System: Initialized")
	return ..()

/datum/controller/subsystem/scp_specializations/fire()
	if(manager)
		manager.process_specializations()

/datum/specialization_manager
	var/list/player_specializations = list()
	var/list/specialization_tracks = list()
	var/list/track_requirements = list()
	var/list/unlockable_bonuses = list()
	
	var/global_xp_multiplier = 1.0

/datum/specialization_manager/proc/initialize_specializations()
	initialize_tracks()
	initialize_requirements()
	initialize_bonuses()

/datum/specialization_manager/proc/initialize_tracks()
	specialization_tracks[SPEC_TRACK_RESEARCH] = new /datum/specialization_track(
		SPEC_TRACK_RESEARCH,
		"Research",
		"Scientific study and experimentation with SCPs",
		list("Scientist", "Research Director", "Senior Researcher", "Research Assistant")
	)
	
	specialization_tracks[SPEC_TRACK_CONTAINMENT] = new /datum/specialization_track(
		SPEC_TRACK_CONTAINMENT,
		"Containment",
		"Breach response and SCP containment procedures",
		list("Security Officer", "Containment Specialist", "Mobile Task Force")
	)
	
	specialization_tracks[SPEC_TRACK_FIELD] = new /datum/specialization_track(
		SPEC_TRACK_FIELD,
		"Field Operations",
		"SCP interaction, survival, and reconnaissance",
		list("Field Agent", "Mobile Task Force", "Security Officer")
	)
	
	specialization_tracks[SPEC_TRACK_MEDICAL] = new /datum/specialization_track(
		SPEC_TRACK_MEDICAL,
		"Medical",
		"SCP-related medical treatment and research",
		list("Medical Doctor", "Chief Medical Officer", "Researcher")
	)

/datum/specialization_manager/proc/initialize_requirements()
	track_requirements[SPEC_TIER_JUNIOR] = new /datum/tier_requirement(
		SPEC_TIER_JUNIOR, 1000, list()
	)
	track_requirements[SPEC_TIER_AGENT] = new /datum/tier_requirement(
		SPEC_TIER_AGENT, 5000, list(
			"interactions" = 10
		)
	)
	track_requirements[SPEC_TIER_SENIOR] = new /datum/tier_requirement(
		SPEC_TIER_SENIOR, 15000, list(
			"interactions" = 25,
			"experiments" = 5
		)
	)
	track_requirements[SPEC_TIER_SPECIALIST] = new /datum/tier_requirement(
		SPEC_TIER_SPECIALIST, 35000, list(
			"interactions" = 50,
			"experiments" = 15,
			"ratings_s" = 3
		)
	)

/datum/specialization_manager/proc/initialize_bonuses()
	unlockable_bonuses["research_xp_boost"] = list(
		"track" = SPEC_TRACK_RESEARCH,
		"tier" = SPEC_TIER_AGENT,
		"bonus" = 0.25,
		"type" = "xp_multiplier"
	)
	unlockable_bonuses["containment_rating_boost"] = list(
		"track" = SPEC_TRACK_CONTAINMENT,
		"tier" = SPEC_TIER_SENIOR,
		"bonus" = 0.20,
		"type" = "rating_modifier"
	)
	unlockable_bonuses["survival_detection"] = list(
		"track" = SPEC_TRACK_FIELD,
		"tier" = SPEC_TIER_AGENT,
		"bonus" = 1,
		"type" = "detection_range"
	)
	unlockable_bonuses["medical_scp_access"] = list(
		"track" = SPEC_TRACK_MEDICAL,
		"tier" = SPEC_TIER_SENIOR,
		"bonus" = 1,
		"type" = "access_level"
	)

/datum/specialization_manager/proc/process_specializations()
	for(var/ckey in player_specializations)
		var/datum/player_specialization/ps = player_specializations[ckey]
		check_tier_advancement(ckey, ps)

/datum/specialization_manager/proc/get_player_specialization(ckey)
	if(!ckey)
		return null
	if(!(ckey in player_specializations))
		player_specializations[ckey] = new /datum/player_specialization(ckey)
	return player_specializations[ckey]

/datum/specialization_manager/proc/add_specialization_xp(ckey, track_type, amount)
	var/datum/player_specialization/ps = get_player_specialization(ckey)
	if(!ps)
		return FALSE
	
	ps.add_xp(track_type, amount)
	check_tier_advancement(ckey, ps)
	
	return TRUE

/datum/specialization_manager/proc/check_tier_advancement(ckey, datum/player_specialization/ps)
	if(!ps)
		return
	
	for(var/track_type in ps.track_xp)
		var/current_tier = ps.track_tiers[track_type]
		var/xp = ps.track_xp[track_type]
		
		for(var/tier in list(SPEC_TIER_SPECIALIST, SPEC_TIER_SENIOR, SPEC_TIER_AGENT, SPEC_TIER_JUNIOR))
			if(current_tier >= tier)
				continue
			
			var/datum/tier_requirement/req = track_requirements[tier]
			if(!req)
				continue
			
			if(xp >= req.xp_required && check_requirement_conditions(ckey, track_type, req))
				advance_tier(ckey, ps, track_type, tier)

/datum/specialization_manager/proc/check_requirement_conditions(ckey, track_type, datum/tier_requirement/req)
	if(!req.conditions || !length(req.conditions))
		return TRUE
	
	var/datum/scp_interaction_log/log = SSscp_interactions?.manager?.get_player_log(ckey)
	var/datum/player_containment_stats/cstats = SScontainment_evaluation?.manager?.get_player_stats(ckey)
	var/datum/researcher_data/rdata = SSscp_research?.manager?.get_researcher_profile(ckey)
	
	if("interactions" in req.conditions)
		if(!log || length(log.scps_interacted) < req.conditions["interactions"])
			return FALSE
	
	if("experiments" in req.conditions)
		if(!rdata || rdata.completed_projects < req.conditions["experiments"])
			return FALSE
	
	if("ratings_s" in req.conditions)
		if(!cstats || cstats.rating_s_count < req.conditions["ratings_s"])
			return FALSE
	
	return TRUE

/datum/specialization_manager/proc/advance_tier(ckey, datum/player_specialization/ps, track_type, new_tier)
	var/old_tier = ps.track_tiers[track_type]
	ps.track_tiers[track_type] = new_tier
	
	var/track_name = get_track_name(track_type)
	var/tier_name = get_tier_name(new_tier)
	
	notify_tier_advancement(ckey, track_name, tier_name)
	
	apply_tier_bonuses(ckey, track_type, new_tier, old_tier)

/datum/specialization_manager/proc/notify_tier_advancement(ckey, track_name, tier_name)
	for(var/client/C in GLOB.clients)
		if(C.ckey == ckey)
			to_chat(C, span_boldnotice("SPECIALIZATION ADVANCEMENT!"))
			to_chat(C, span_notice("You have advanced to [tier_name] in [track_name]!"))
			break

/datum/specialization_manager/proc/apply_tier_bonuses(ckey, track_type, tier, old_tier)
	for(var/bonus_id in unlockable_bonuses)
		var/list/bonus_data = unlockable_bonuses[bonus_id]
		if(bonus_data["track"] == track_type && bonus_data["tier"] <= tier && bonus_data["tier"] > old_tier)
			apply_bonus(ckey, bonus_data)

/datum/specialization_manager/proc/apply_bonus(ckey, list/bonus_data)
	var/datum/player_specialization/ps = get_player_specialization(ckey)
	if(!ps)
		return
	
	switch(bonus_data["type"])
		if("xp_multiplier")
			ps.xp_multipliers[bonus_data["track"]] = 1.0 + bonus_data["bonus"]
		if("rating_modifier")
			ps.rating_modifier += bonus_data["bonus"]
		if("detection_range")
			ps.detection_range += bonus_data["bonus"]
		if("access_level")
			ps.access_bonuses += bonus_data["bonus"]

/datum/specialization_manager/proc/get_xp_multiplier(ckey, track_type)
	var/datum/player_specialization/ps = get_player_specialization(ckey)
	if(!ps)
		return 1.0
	return ps.xp_multipliers[track_type] || 1.0

/datum/specialization_manager/proc/get_tier(ckey, track_type)
	var/datum/player_specialization/ps = get_player_specialization(ckey)
	if(!ps)
		return SPEC_TIER_TRAINEE
	return ps.track_tiers[track_type] || SPEC_TIER_TRAINEE

/datum/specialization_manager/proc/get_track_name(track_type)
	switch(track_type)
		if(SPEC_TRACK_RESEARCH)
			return "Research"
		if(SPEC_TRACK_CONTAINMENT)
			return "Containment"
		if(SPEC_TRACK_FIELD)
			return "Field Operations"
		if(SPEC_TRACK_MEDICAL)
			return "Medical"
	return "Unknown"

/datum/specialization_manager/proc/get_tier_name(tier)
	switch(tier)
		if(SPEC_TIER_TRAINEE)
			return "Trainee"
		if(SPEC_TIER_JUNIOR)
			return "Junior"
		if(SPEC_TIER_AGENT)
			return "Agent"
		if(SPEC_TIER_SENIOR)
			return "Senior"
		if(SPEC_TIER_SPECIALIST)
			return "Specialist"
	return "Unknown"

/datum/specialization_manager/proc/get_full_title(ckey, track_type)
	var/tier = get_tier(ckey, track_type)
	var/track_name = get_track_name(track_type)
	var/tier_name = get_tier_name(tier)
	return "[tier_name] [track_name] Specialist"

/datum/specialization_track
	var/track_type
	var/name
	var/description
	var/list/eligible_jobs
	var/list/tier_names = list(
		"trainee" = "Trainee",
		"junior" = "Junior",
		"agent" = "Agent",
		"senior" = "Senior",
		"specialist" = "Specialist"
	)

/datum/specialization_track/New(type, n, desc, jobs)
	track_type = type
	name = n
	description = desc
	eligible_jobs = jobs

/datum/tier_requirement
	var/tier
	var/xp_required
	var/list/conditions

/datum/tier_requirement/New(t, xp, conds)
	tier = t
	xp_required = xp
	conditions = conds

/datum/player_specialization
	var/ckey
	var/list/track_xp = list(
		"research" = 0,
		"containment" = 0,
		"field" = 0,
		"medical" = 0
	)
	var/list/track_tiers = list(
		"research" = 1,
		"containment" = 1,
		"field" = 1,
		"medical" = 1
	)
	var/list/xp_multipliers = list(
		"research" = 1.0,
		"containment" = 1.0,
		"field" = 1.0,
		"medical" = 1.0
	)
	var/rating_modifier = 0
	var/detection_range = 0
	var/access_bonuses = 0
	var/primary_track = null

/datum/player_specialization/New(c)
	ckey = c

/datum/player_specialization/proc/add_xp(track_type, amount)
	if(!(track_type in track_xp))
		return
	
	var/multiplier = xp_multipliers[track_type] || 1.0
	track_xp[track_type] += round(amount * multiplier)
	
	if(!primary_track || track_xp[track_type] > track_xp[primary_track])
		primary_track = track_type

/datum/player_specialization/proc/get_summary()
	return list(
		"ckey" = ckey,
		"tracks" = list(
			"research" = list(
				"xp" = track_xp[SPEC_TRACK_RESEARCH],
				"tier" = track_tiers[SPEC_TRACK_RESEARCH]
			),
			"containment" = list(
				"xp" = track_xp[SPEC_TRACK_CONTAINMENT],
				"tier" = track_tiers[SPEC_TRACK_CONTAINMENT]
			),
			"field" = list(
				"xp" = track_xp[SPEC_TRACK_FIELD],
				"tier" = track_tiers[SPEC_TRACK_FIELD]
			),
			"medical" = list(
				"xp" = track_xp[SPEC_TRACK_MEDICAL],
				"tier" = track_tiers[SPEC_TRACK_MEDICAL]
			)
		),
		"primary_track" = primary_track,
		"bonuses" = list(
			"rating_modifier" = rating_modifier,
			"detection_range" = detection_range
		)
	)

/mob/proc/view_specializations()
	set name = "View Specializations"
	set category = "Progression"
	set desc = "View your specialization progress."
	
	if(!SSscp_specializations || !SSscp_specializations.manager)
		to_chat(src, span_warning("Specialization system not available."))
		return
	
	var/datum/specialization_manager/manager = SSscp_specializations.manager
	var/datum/player_specialization/ps = manager.get_player_specialization(ckey)
	
	if(!ps)
		to_chat(src, span_warning("Could not retrieve specialization data."))
		return
	
	var/list/summary = ps.get_summary()
	
	var/message = "<h2>Specialization Progress</h2>"
	
	if(ps.primary_track)
		message += "<b>Primary Focus:</b> [manager.get_track_name(ps.primary_track)]<br>"
		message += "<b>Title:</b> [manager.get_full_title(ckey, ps.primary_track)]<br><br>"
	
	message += "<h3>Track Progress</h3>"
	
	for(var/track_type in list(SPEC_TRACK_RESEARCH, SPEC_TRACK_CONTAINMENT, SPEC_TRACK_FIELD, SPEC_TRACK_MEDICAL))
		var/track_name = manager.get_track_name(track_type)
		var/tier = summary["tracks"][lowertext(track_name)]["tier"]
		var/tier_name = manager.get_tier_name(tier)
		var/xp = summary["tracks"][lowertext(track_name)]["xp"]
		
		var/next_tier = tier + 1
		var/next_xp = 0
		if(next_tier <= SPEC_TIER_SPECIALIST)
			var/datum/tier_requirement/req = manager.track_requirements[next_tier]
			next_xp = req?.xp_required || 0
		
		message += "<b>[track_name]:</b> [tier_name] ([xp] XP)"
		if(next_xp > 0 && xp < next_xp)
			message += " - Next tier: [next_xp] XP"
		message += "<br>"
	
	if(summary["bonuses"]["rating_modifier"] > 0)
		message += "<br><b>Bonuses Active:</b><br>"
		message += "- Rating Modifier: +[round(summary["bonuses"]["rating_modifier"] * 100)]%<br>"
		message += "- Detection Range: +[summary["bonuses"]["detection_range"]]<br>"
	
	to_chat(src, span_notice("[message]"))

/proc/award_specialization_xp(ckey, track_type, amount)
	if(!SSscp_specializations || !SSscp_specializations.manager)
		return FALSE
	return SSscp_specializations.manager.add_specialization_xp(ckey, track_type, amount)

/proc/get_player_spec_tier(ckey, track_type)
	if(!SSscp_specializations || !SSscp_specializations.manager)
		return SPEC_TIER_TRAINEE
	return SSscp_specializations.manager.get_tier(ckey, track_type)

/proc/get_player_spec_multiplier(ckey, track_type)
	if(!SSscp_specializations || !SSscp_specializations.manager)
		return 1.0
	return SSscp_specializations.manager.get_xp_multiplier(ckey, track_type)
