/datum/persistent_player_data
	var/ckey
	var/list/class_data = list()
	var/list/rank_data = list()
	var/list/faction_data = list()
	var/list/unlocked_items = list()
	var/list/unlocked_titles = list()
	var/list/unlocked_cosmetics = list()
	var/list/achievements = list()
	var/total_experience = 0
	var/rounds_played = 0
	var/rounds_survived = 0
	var/rounds_died = 0
	var/last_login = 0
	var/preferred_class = "security"
	var/preferred_faction = "foundation"
	var/current_class_id = "security"
	var/current_faction_id = "foundation"
	var/current_rank = 0
	var/current_rank_name = "Recruit"
	var/list/experience_sources = list()
	var/list/performance_metrics = list()
	var/list/achievement_progress = list()
	var/achievement_points = 0
	var/total_achievements_unlocked = 0
	var/round_start_time = 0
	var/round_end_time = 0
	var/current_round_survived = FALSE
	var/current_round_damage_dealt = 0
	var/current_round_damage_taken = 0
	var/current_round_healing_done = 0
	var/current_round_objectives_completed = 0
	var/current_round_team_contributions = 0
	var/current_round_map_exploration = 0
	var/current_round_pacifist = TRUE
	var/list/event_history = list()
	var/list/currency = list()
	var/list/settings = list()
	var/total_playtime = 0
	var/first_login = 0
	var/list/daily_login_streak = list()
	var/current_streak = 0
	var/longest_streak = 0
	var/list/friends_list = list()
	var/list/blocked_list = list()
	var/list/notes = list()
	var/reputation_score = 0
	var/total_kills = 0
	var/current_job = ""
	var/list/job_rounds_played = list()
	var/list/job_experience = list()
	var/list/job_achievements = list()
	var/list/job_performance = list()
	var/list/job_specializations = list()
	var/list/job_promotions = list()
	var/list/job_incidents = list()
	var/list/job_commendations = list()
	var/list/job_disciplinary_actions = list()
	var/list/job_training_completed = list()
	var/list/job_certifications = list()
	var/list/job_mentoring_sessions = list()
	var/list/job_research_papers = list()
	var/list/job_containment_breaches = list()
	var/list/job_scp_interactions = list()
	var/list/job_medical_procedures = list()
	var/list/job_engineering_projects = list()
	var/list/job_security_operations = list()
	var/list/job_supply_management = list()
	var/list/job_service_contributions = list()
	var/list/job_dclass_testing = list()
	var/skill_boost_multiplier = 1.0
	var/total_deaths = 0
	var/total_healing = 0
	var/total_damage_dealt = 0
	var/total_objectives = 0
	var/total_scp_interactions = 0
	var/total_containment_breaches = 0
	var/total_research_completed = 0
	var/total_treatments = 0
	var/total_constructions = 0
	var/total_repairs = 0
	var/total_arrests = 0
	var/list/sessions = list()
	var/list/notifications = list()
	var/data_version = 1
	var/last_backup = 0
	var/dirty = FALSE

/datum/persistent_player_data/New(player_ckey)
	ckey = player_ckey
	initialize_default_data()

/datum/persistent_player_data/proc/initialize_default_data()
	current_class_id = preferred_class
	current_faction_id = preferred_faction
	current_rank = 0
	current_rank_name = "Recruit"
	total_experience = 0
	rounds_played = 0
	rounds_survived = 0
	rounds_died = 0
	last_login = world.time
	unlocked_items = list()
	unlocked_titles = list()
	achievements = list()
	experience_sources = list()
	performance_metrics = list()

/datum/persistent_player_data/proc/update_rank()
	var/datum/persistent_class/class = SSpersistent_progression.get_class(current_class_id)
	if(!class)
		return FALSE

	// Check if already at max rank
	if(current_rank >= class.max_rank)
		return FALSE

	// var/old_rank = current_rank
	var/rank_requirements = class.get_rank_requirement(current_rank + 1)

	if(rank_requirements && total_experience >= rank_requirements)
		current_rank++
		current_rank_name = class.get_rank_name(current_rank)
		return TRUE

	return FALSE

/datum/persistent_player_data/proc/add_experience(amount, source_id, reason)
	if(amount <= 0)
		return 0

	var/datum/experience_source/source = SSpersistent_progression.get_experience_source(source_id)
	if(!source)
		return 0

	// Apply multipliers
	var/final_amount = amount
	var/datum/persistent_class/class = SSpersistent_progression.get_class(current_class_id)
	var/datum/persistent_faction/faction = SSpersistent_progression.get_faction(current_faction_id)

	if(class)
		final_amount *= class.experience_multiplier
	if(faction)
		final_amount *= faction.experience_multiplier
	if(source.class_multiplier && class)
		final_amount *= source.class_multiplier
	if(source.rank_multiplier)
		final_amount *= (1 + (current_rank * source.rank_multiplier))

	final_amount = round(final_amount)

	// Add to total experience
	total_experience += final_amount

	// Record this experience source
	var/list/source_data = list(
		"source" = source_id,
		"amount" = final_amount,
		"reason" = reason,
		"timestamp" = world.time
	)
	experience_sources += source_data

	// Check for rank up
	update_rank()

	return final_amount

/datum/persistent_player_data/proc/get_progress_to_next_rank()
	var/datum/persistent_class/class = SSpersistent_progression.get_class(current_class_id)
	if(!class || current_rank >= class.max_rank)
		return 100

	var/current_rank_exp = class.get_rank_requirement(current_rank)
	var/next_rank_exp = class.get_rank_requirement(current_rank + 1)

	if(!next_rank_exp)
		return 100

	var/exp_in_current_rank = total_experience - current_rank_exp
	var/exp_needed_for_next = next_rank_exp - current_rank_exp

	if(exp_needed_for_next <= 0)
		return 100

	return round((exp_in_current_rank / exp_needed_for_next) * 100)

/datum/persistent_player_data/proc/get_experience_needed_for_next_rank()
	var/datum/persistent_class/class = SSpersistent_progression.get_class(current_class_id)
	if(!class || current_rank >= class.max_rank)
		return 0

	var/next_rank_exp = class.get_rank_requirement(current_rank + 1)

	if(!next_rank_exp)
		return 0

	var/exp_needed = next_rank_exp - total_experience
	return exp_needed > 0 ? exp_needed : 0

/datum/persistent_player_data/proc/unlock_item(item_id)
	if(item_id in unlocked_items)
		return FALSE

	unlocked_items += item_id
	return TRUE

/datum/persistent_player_data/proc/unlock_title(title_id)
	if(title_id in unlocked_titles)
		return FALSE

	unlocked_titles += title_id
	return TRUE

/datum/persistent_player_data/proc/add_achievement(achievement_id)
	if(achievement_id in achievements)
		return FALSE

	achievements += achievement_id
	return TRUE

/datum/persistent_player_data/proc/update_performance_metric(metric_type, value)
	performance_metrics[metric_type] = value

/datum/persistent_player_data/proc/get_performance_metric(metric_type)
	return performance_metrics[metric_type] || 0

/datum/persistent_player_data/proc/reset_progress()
	initialize_default_data()
	return TRUE

/datum/persistent_player_data/proc/export_to_json()
	var/list/data = list()
	data["ckey"] = ckey
	data["total_experience"] = total_experience
	data["rounds_played"] = rounds_played
	data["rounds_survived"] = rounds_survived
	data["rounds_died"] = rounds_died
	data["current_class_id"] = current_class_id
	data["current_faction_id"] = current_faction_id
	data["current_rank"] = current_rank
	data["current_rank_name"] = current_rank_name
	data["unlocked_items"] = unlocked_items
	data["unlocked_titles"] = unlocked_titles
	data["achievements"] = achievements
	data["achievement_progress"] = achievement_progress
	data["achievement_points"] = achievement_points
	data["total_achievements_unlocked"] = total_achievements_unlocked
	data["experience_sources"] = experience_sources
	data["performance_metrics"] = performance_metrics
	return json_encode(data)

// Achievement tracking methods
/datum/persistent_player_data/proc/check_achievements()
	if(!SSpersistent_progression.achievement_manager)
		return

	check_milestone_achievements()
	check_class_achievements()
	check_faction_achievements()
	check_hidden_achievements()
	check_job_performance_achievements()
	check_scp_achievements()
	check_combat_achievements()
	check_research_achievements()
	check_medical_achievements()
	check_engineering_achievements()
	check_social_achievements()

/datum/persistent_player_data/proc/check_milestone_achievements()

	// First experience
	if(total_experience >= 1 && !("first_experience" in achievements))
		unlock_achievement("first_experience")

	// Experience milestones
	if(total_experience >= 1000 && !("exp_1000" in achievements))
		unlock_achievement("exp_1000")
	if(total_experience >= 10000 && !("exp_10000" in achievements))
		unlock_achievement("exp_10000")
	if(total_experience >= 100000 && !("exp_100000" in achievements))
		unlock_achievement("exp_100000")

	// Round milestones
	if(rounds_played >= 10 && !("rounds_10" in achievements))
		unlock_achievement("rounds_10")
	if(rounds_played >= 100 && !("rounds_100" in achievements))
		unlock_achievement("rounds_100")

	// Survival master
	var/survival_rate = rounds_played > 0 ? (rounds_survived / rounds_played) * 100 : 0
	if(rounds_played >= 50 && survival_rate >= 90 && !("survival_master" in achievements))
		unlock_achievement("survival_master")

/datum/persistent_player_data/proc/check_class_achievements()
	var/list/class_ids = list("security", "research", "medical", "engineering", "containment")
	for(var/class_id in class_ids)
		var/class_rank = 0
		if(class_data[class_id])
			class_rank = class_data[class_id]["rank"] || current_rank
		if(class_id == current_class_id)
			class_rank = current_rank
		if(class_rank >= 1 && !("class_[class_id]_novice" in achievements))
			unlock_achievement("class_[class_id]_novice")
		if(class_rank >= 5 && !("class_[class_id]_expert" in achievements))
			unlock_achievement("class_[class_id]_expert")
		if(class_rank >= 10 && !("class_[class_id]_master" in achievements))
			unlock_achievement("class_[class_id]_master")

/datum/persistent_player_data/proc/check_faction_achievements()
	var/list/faction_rounds = list(
		"foundation" = get_performance_metric("foundation_rounds"),
		"goc" = get_performance_metric("goc_rounds"),
		"serpents_hand" = get_performance_metric("serpents_hand_rounds"),
		"chaos_insurgency" = get_performance_metric("chaos_rounds"),
		"mcd" = get_performance_metric("mcd_rounds"),
		"uiu" = get_performance_metric("uiu_rounds")
	)

	if(faction_rounds["foundation"] >= 50 && !("foundation_loyalty" in achievements))
		unlock_achievement("foundation_loyalty")
	if(faction_rounds["foundation"] >= 100 && !("foundation_dedication" in achievements))
		unlock_achievement("foundation_dedication")
	if(faction_rounds["goc"] >= 50 && !("goc_loyalty" in achievements))
		unlock_achievement("goc_loyalty")
	if(faction_rounds["serpents_hand"] >= 50 && !("serpents_hand_loyalty" in achievements))
		unlock_achievement("serpents_hand_loyalty")
	if(faction_rounds["chaos_insurgency"] >= 50 && !("chaos_insurgency_loyalty" in achievements))
		unlock_achievement("chaos_insurgency_loyalty")
	if(faction_rounds["mcd"] >= 50 && !("mcd_loyalty" in achievements))
		unlock_achievement("mcd_loyalty")
	if(faction_rounds["uiu"] >= 50 && !("uiu_loyalty" in achievements))
		unlock_achievement("uiu_loyalty")

/datum/persistent_player_data/proc/check_hidden_achievements()
	if(current_round_map_exploration >= 90 && !("explorer" in achievements))
		unlock_achievement("explorer")

	if(current_round_pacifist && current_round_survived && !("pacifist_run" in achievements))
		unlock_achievement("pacifist_run")

	if(total_containment_breaches >= 1 && !("hidden_containment_breach" in achievements))
		unlock_achievement("hidden_containment_breach")

	if(total_deaths >= 1 && total_scp_interactions >= 10 && !("hidden_sacrifice" in achievements))
		unlock_achievement("hidden_sacrifice")

/datum/persistent_player_data/proc/check_job_performance_achievements()
	if(total_arrests >= 10 && !("job_security_arrests_10" in achievements))
		unlock_achievement("job_security_arrests_10")
	if(total_arrests >= 50 && !("job_security_arrests_50" in achievements))
		unlock_achievement("job_security_arrests_50")
	if(total_arrests >= 100 && !("job_security_arrests_100" in achievements))
		unlock_achievement("job_security_arrests_100")

	if(total_treatments >= 50 && !("job_medical_saves_10" in achievements))
		unlock_achievement("job_medical_saves_10")
	if(total_treatments >= 200 && !("job_medical_saves_50" in achievements))
		unlock_achievement("job_medical_saves_50")
	if(total_treatments >= 500 && !("job_medical_saves_100" in achievements))
		unlock_achievement("job_medical_saves_100")

	var/total_papers = 0
	for(var/job in job_research_papers)
		total_papers += length(job_research_papers[job])
	if(total_papers >= 5 && !("job_research_papers_5" in achievements))
		unlock_achievement("job_research_papers_5")
	if(total_papers >= 25 && !("job_research_papers_25" in achievements))
		unlock_achievement("job_research_papers_25")
	if(total_papers >= 50 && !("job_research_papers_50" in achievements))
		unlock_achievement("job_research_papers_50")

	if(total_constructions >= 50 && !("job_engineering_builds_50" in achievements))
		unlock_achievement("job_engineering_builds_50")
	if(total_constructions >= 200 && !("job_engineering_builds_200" in achievements))
		unlock_achievement("job_engineering_builds_200")
	if(total_constructions >= 500 && !("job_engineering_builds_500" in achievements))
		unlock_achievement("job_engineering_builds_500")

/datum/persistent_player_data/proc/check_scp_achievements()
	if(total_scp_interactions >= 10 && !("scp_interactions_10" in achievements))
		unlock_achievement("scp_interactions_10")
	if(total_scp_interactions >= 50 && !("scp_interactions_50" in achievements))
		unlock_achievement("scp_interactions_50")
	if(total_scp_interactions >= 100 && !("scp_interactions_100" in achievements))
		unlock_achievement("scp_interactions_100")

	if(total_containment_breaches >= 10 && !("scp_containment_10" in achievements))
		unlock_achievement("scp_containment_10")
	if(total_containment_breaches >= 50 && !("scp_containment_50" in achievements))
		unlock_achievement("scp_containment_50")
	if(total_containment_breaches >= 100 && !("scp_containment_100" in achievements))
		unlock_achievement("scp_containment_100")

	if(total_research_completed >= 25 && !("scp_research_25" in achievements))
		unlock_achievement("scp_research_25")
	if(total_research_completed >= 100 && !("scp_research_100" in achievements))
		unlock_achievement("scp_research_100")

	var/unique_scp_contacts = get_performance_metric("unique_scp_contacts")
	if(unique_scp_contacts >= 5 && !("scp_first_contact_5" in achievements))
		unlock_achievement("scp_first_contact_5")
	if(unique_scp_contacts >= 15 && !("scp_first_contact_15" in achievements))
		unlock_achievement("scp_first_contact_15")
	if(unique_scp_contacts >= 30 && !("scp_first_contact_30" in achievements))
		unlock_achievement("scp_first_contact_30")

/datum/persistent_player_data/proc/check_combat_achievements()
	if(total_kills >= 10 && !("combat_kills_10" in achievements))
		unlock_achievement("combat_kills_10")
	if(total_kills >= 50 && !("combat_kills_50" in achievements))
		unlock_achievement("combat_kills_50")
	if(total_kills >= 100 && !("combat_kills_100" in achievements))
		unlock_achievement("combat_kills_100")

	if(total_damage_dealt >= 10000 && !("combat_damage_taken_10000" in achievements))
		unlock_achievement("combat_damage_taken_10000")
	if(total_damage_dealt >= 50000 && !("combat_damage_taken_50000" in achievements))
		unlock_achievement("combat_damage_taken_50000")
	if(total_damage_dealt >= 100000 && !("combat_damage_taken_100000" in achievements))
		unlock_achievement("combat_damage_taken_100000")

	if(current_round_pacifist && current_round_survived && !("combat_perfect_round" in achievements))
		unlock_achievement("combat_perfect_round")

/datum/persistent_player_data/proc/check_research_achievements()
	if(total_research_completed >= 5 && !("research_discoveries_5" in achievements))
		unlock_achievement("research_discoveries_5")
	if(total_research_completed >= 25 && !("research_discoveries_25" in achievements))
		unlock_achievement("research_discoveries_25")
	if(total_research_completed >= 50 && !("research_discoveries_50" in achievements))
		unlock_achievement("research_discoveries_50")

	var/total_projects = 0
	for(var/job in job_research_papers)
		total_projects += length(job_research_papers[job])
	if(total_projects >= 10 && !("research_projects_10" in achievements))
		unlock_achievement("research_projects_10")
	if(total_projects >= 50 && !("research_projects_50" in achievements))
		unlock_achievement("research_projects_50")

/datum/persistent_player_data/proc/check_medical_achievements()
	if(total_treatments >= 50 && !("medical_treatments_50" in achievements))
		unlock_achievement("medical_treatments_50")
	if(total_treatments >= 200 && !("medical_treatments_200" in achievements))
		unlock_achievement("medical_treatments_200")
	if(total_treatments >= 500 && !("medical_treatments_500" in achievements))
		unlock_achievement("medical_treatments_500")

	var/total_surgeries = 0
	for(var/job in job_medical_procedures)
		for(var/list/proc_data in job_medical_procedures[job])
			if(proc_data["procedure_type"] == "surgery")
				total_surgeries++
	if(total_surgeries >= 10 && !("medical_surgeries_10" in achievements))
		unlock_achievement("medical_surgeries_10")
	if(total_surgeries >= 50 && !("medical_surgeries_50" in achievements))
		unlock_achievement("medical_surgeries_50")

/datum/persistent_player_data/proc/check_engineering_achievements()
	if(total_repairs >= 50 && !("engineering_repairs_50" in achievements))
		unlock_achievement("engineering_repairs_50")
	if(total_repairs >= 200 && !("engineering_repairs_200" in achievements))
		unlock_achievement("engineering_repairs_200")
	if(total_repairs >= 500 && !("engineering_repairs_500" in achievements))
		unlock_achievement("engineering_repairs_500")

	if(total_constructions >= 100 && !("engineering_construction_100" in achievements))
		unlock_achievement("engineering_construction_100")
	if(total_constructions >= 500 && !("engineering_construction_500" in achievements))
		unlock_achievement("engineering_construction_500")

/datum/persistent_player_data/proc/check_social_achievements()
	var/total_commendations = 0
	for(var/job in job_commendations)
		total_commendations += length(job_commendations[job])
	if(total_commendations >= 10 && !("social_commendations_10" in achievements))
		unlock_achievement("social_commendations_10")

	var/total_mentoring = 0
	for(var/job in job_mentoring_sessions)
		total_mentoring += length(job_mentoring_sessions[job])
	if(total_mentoring >= 10 && !("social_mentoring_10" in achievements))
		unlock_achievement("social_mentoring_10")
	if(total_mentoring >= 50 && !("social_mentoring_50" in achievements))
		unlock_achievement("social_mentoring_50")

	if(rounds_played >= 10 && !("social_team_rounds_10" in achievements))
		unlock_achievement("social_team_rounds_10")
	if(rounds_played >= 50 && !("social_team_rounds_50" in achievements))
		unlock_achievement("social_team_rounds_50")
	if(rounds_played >= 100 && !("social_team_rounds_100" in achievements))
		unlock_achievement("social_team_rounds_100")

/datum/persistent_player_data/proc/unlock_achievement(achievement_id)
	if(!SSpersistent_progression.achievement_manager)
		return FALSE

	var/datum/achievement/achievement = SSpersistent_progression.achievement_manager.get_achievement(achievement_id)
	if(!achievement)
		return FALSE

	if(achievement_id in achievements)
		return FALSE

	achievements += achievement_id
	achievement_points += achievement.achievement_points
	total_achievements_unlocked++

	// Add rewards
	for(var/reward in achievement.achievement_rewards)
		process_achievement_reward(reward)

	// Integrate with SSachievements system
	if(SSpersistent_progression.achievement_integration)
		SSpersistent_progression.achievement_integration.unlock_progression_achievement(ckey, achievement_id)

	return TRUE

/datum/persistent_player_data/proc/process_achievement_reward(reward)
	if(reward["type"] == "item")
		unlock_item(reward["id"])
	else if(reward["type"] == "title")
		unlock_title(reward["id"])
	else if(reward["type"] == "experience")
		add_experience(reward["amount"], "achievement", "Achievement Reward")

/datum/persistent_player_data/proc/update_achievement_progress(achievement_id, progress)
	if(!achievement_progress[achievement_id])
		achievement_progress[achievement_id] = 0

	achievement_progress[achievement_id] += progress

	// Check if achievement should be unlocked
	var/datum/achievement/achievement = SSpersistent_progression.achievement_manager.get_achievement(achievement_id)
	if(achievement && achievement_progress[achievement_id] >= achievement.achievement_max_progress)
		unlock_achievement(achievement_id)

/datum/persistent_player_data/proc/start_round()
	round_start_time = world.time
	current_round_survived = FALSE
	current_round_damage_dealt = 0
	current_round_damage_taken = 0
	current_round_healing_done = 0
	current_round_objectives_completed = 0
	current_round_team_contributions = 0
	current_round_map_exploration = 0
	current_round_pacifist = TRUE

/datum/persistent_player_data/proc/end_round(survived = FALSE)
	round_end_time = world.time
	current_round_survived = survived
	rounds_played++

	if(survived)
		rounds_survived++
	else
		rounds_died++

	// Update performance metrics
	update_performance_metric("total_rounds_played", rounds_played)
	update_performance_metric("total_rounds_survived", rounds_survived)
	update_performance_metric("total_rounds_died", rounds_died)
	update_performance_metric("survival_rate", rounds_played > 0 ? (rounds_survived / rounds_played) * 100 : 0)

	// Check achievements
	check_achievements()

// Job-specific methods for Foundation-19 integration

/datum/persistent_player_data/proc/set_current_job(job_title)
	current_job = job_title
	if(!job_rounds_played[job_title])
		job_rounds_played[job_title] = 0
	if(!job_experience[job_title])
		job_experience[job_title] = 0
	if(!job_achievements[job_title])
		job_achievements[job_title] = list()
	if(!job_performance[job_title])
		job_performance[job_title] = list()

/datum/persistent_player_data/proc/add_job_experience(job_title, amount, source = "general")
	if(!job_experience[job_title])
		job_experience[job_title] = 0

	job_experience[job_title] += amount

	// Also add to general experience
	add_experience(amount, "job_[job_title]", "Job Performance: [source]")

	// Check for job-specific achievements
	check_job_achievements(job_title)

	return amount

/datum/persistent_player_data/proc/get_job_experience(job_title)
	return job_experience[job_title] || 0

/datum/persistent_player_data/proc/get_job_rounds_played(job_title)
	return job_rounds_played[job_title] || 0

/datum/persistent_player_data/proc/increment_job_rounds(job_title)
	if(!job_rounds_played[job_title])
		job_rounds_played[job_title] = 0
	job_rounds_played[job_title]++

/datum/persistent_player_data/proc/add_job_achievement(job_title, achievement_id)
	if(!job_achievements[job_title])
		job_achievements[job_title] = list()

	if(!(achievement_id in job_achievements[job_title]))
		job_achievements[job_title] += achievement_id
		return TRUE
	return FALSE

/datum/persistent_player_data/proc/update_job_performance(job_title, metric, value)
	if(!job_performance[job_title])
		job_performance[job_title] = list()

	job_performance[job_title][metric] = value

/datum/persistent_player_data/proc/get_job_performance(job_title, metric)
	if(!job_performance[job_title])
		return 0
	return job_performance[job_title][metric] || 0

/datum/persistent_player_data/proc/add_job_specialization(job_title, specialization)
	if(!job_specializations[job_title])
		job_specializations[job_title] = list()

	if(!(specialization in job_specializations[job_title]))
		job_specializations[job_title] += specialization
		return TRUE
	return FALSE

/datum/persistent_player_data/proc/record_job_promotion(job_title, old_rank, new_rank)
	if(!job_promotions[job_title])
		job_promotions[job_title] = list()

	var/list/promotion_data = list(
		"old_rank" = old_rank,
		"new_rank" = new_rank,
		"timestamp" = world.time
	)
	job_promotions[job_title] += promotion_data

/datum/persistent_player_data/proc/record_job_incident(job_title, incident_type, description, severity = "minor")
	if(!job_incidents[job_title])
		job_incidents[job_title] = list()

	var/list/incident_data = list(
		"type" = incident_type,
		"description" = description,
		"severity" = severity,
		"timestamp" = world.time
	)
	job_incidents[job_title] += incident_data

/datum/persistent_player_data/proc/record_job_commendation(job_title, reason, awarded_by)
	if(!job_commendations[job_title])
		job_commendations[job_title] = list()

	var/list/commendation_data = list(
		"reason" = reason,
		"awarded_by" = awarded_by,
		"timestamp" = world.time
	)
	job_commendations[job_title] += commendation_data

/datum/persistent_player_data/proc/record_job_disciplinary_action(job_title, action_type, reason, issued_by)
	if(!job_disciplinary_actions[job_title])
		job_disciplinary_actions[job_title] = list()

	var/list/disciplinary_data = list(
		"action_type" = action_type,
		"reason" = reason,
		"issued_by" = issued_by,
		"timestamp" = world.time
	)
	job_disciplinary_actions[job_title] += disciplinary_data

/datum/persistent_player_data/proc/complete_job_training(job_title, training_type)
	if(!job_training_completed[job_title])
		job_training_completed[job_title] = list()

	if(!(training_type in job_training_completed[job_title]))
		job_training_completed[job_title] += training_type
		add_job_experience(job_title, 50, "Training Completion")
		return TRUE
	return FALSE

/datum/persistent_player_data/proc/earn_job_certification(job_title, certification_type)
	if(!job_certifications[job_title])
		job_certifications[job_title] = list()

	if(!(certification_type in job_certifications[job_title]))
		job_certifications[job_title] += certification_type
		add_job_experience(job_title, 100, "Certification Earned")
		return TRUE
	return FALSE

/datum/persistent_player_data/proc/conduct_job_mentoring(job_title, mentee, topic)
	if(!job_mentoring_sessions[job_title])
		job_mentoring_sessions[job_title] = list()

	var/list/mentoring_data = list(
		"mentee" = mentee,
		"topic" = topic,
		"timestamp" = world.time
	)
	job_mentoring_sessions[job_title] += mentoring_data
	add_job_experience(job_title, 25, "Mentoring Session")

/datum/persistent_player_data/proc/publish_job_research_paper(job_title, paper_title, co_authors = list())
	if(!job_research_papers[job_title])
		job_research_papers[job_title] = list()

	var/list/paper_data = list(
		"title" = paper_title,
		"co_authors" = co_authors,
		"timestamp" = world.time
	)
	job_research_papers[job_title] += paper_data
	add_job_experience(job_title, 200, "Research Paper Published")

/datum/persistent_player_data/proc/respond_to_containment_breach(job_title, scp_id, response_type, outcome)
	if(!job_containment_breaches[job_title])
		job_containment_breaches[job_title] = list()

	var/list/breach_data = list(
		"scp_id" = scp_id,
		"response_type" = response_type,
		"outcome" = outcome,
		"timestamp" = world.time
	)
	job_containment_breaches[job_title] += breach_data

	var/exp_reward = 0
	switch(outcome)
		if("successful")
			exp_reward = 150
		if("partial")
			exp_reward = 75
		if("failed")
			exp_reward = 25

	add_job_experience(job_title, exp_reward, "Containment Breach Response")

/datum/persistent_player_data/proc/interact_with_scp(job_title, scp_id, interaction_type, outcome)
	if(!job_scp_interactions[job_title])
		job_scp_interactions[job_title] = list()

	var/list/interaction_data = list(
		"scp_id" = scp_id,
		"interaction_type" = interaction_type,
		"outcome" = outcome,
		"timestamp" = world.time
	)
	job_scp_interactions[job_title] += interaction_data

	var/exp_reward = 0
	switch(interaction_type)
		if("research")
			exp_reward = 50
		if("containment")
			exp_reward = 75
		if("testing")
			exp_reward = 100
		if("emergency")
			exp_reward = 125

	add_job_experience(job_title, exp_reward, "SCP Interaction")

/datum/persistent_player_data/proc/perform_medical_procedure(job_title, procedure_type, patient, outcome)
	if(!job_medical_procedures[job_title])
		job_medical_procedures[job_title] = list()

	var/list/procedure_data = list(
		"procedure_type" = procedure_type,
		"patient" = patient,
		"outcome" = outcome,
		"timestamp" = world.time
	)
	job_medical_procedures[job_title] += procedure_data

	var/exp_reward = 0
	switch(procedure_type)
		if("surgery")
			exp_reward = 100
		if("diagnosis")
			exp_reward = 50
		if("treatment")
			exp_reward = 75
		if("emergency")
			exp_reward = 125

	add_job_experience(job_title, exp_reward, "Medical Procedure")

/datum/persistent_player_data/proc/complete_engineering_project(job_title, project_type, complexity, outcome)
	if(!job_engineering_projects[job_title])
		job_engineering_projects[job_title] = list()

	var/list/project_data = list(
		"project_type" = project_type,
		"complexity" = complexity,
		"outcome" = outcome,
		"timestamp" = world.time
	)
	job_engineering_projects[job_title] += project_data

	var/exp_reward = 0
	switch(complexity)
		if("simple")
			exp_reward = 50
		if("moderate")
			exp_reward = 100
		if("complex")
			exp_reward = 150
		if("critical")
			exp_reward = 200

	add_job_experience(job_title, exp_reward, "Engineering Project")

/datum/persistent_player_data/proc/conduct_security_operation(job_title, operation_type, target, outcome)
	if(!job_security_operations[job_title])
		job_security_operations[job_title] = list()

	var/list/operation_data = list(
		"operation_type" = operation_type,
		"target" = target,
		"outcome" = outcome,
		"timestamp" = world.time
	)
	job_security_operations[job_title] += operation_data

	var/exp_reward = 0
	switch(operation_type)
		if("patrol")
			exp_reward = 25
		if("investigation")
			exp_reward = 50
		if("arrest")
			exp_reward = 75
		if("containment")
			exp_reward = 100
		if("mtf_operation")
			exp_reward = 150

	add_job_experience(job_title, exp_reward, "Security Operation")

/datum/persistent_player_data/proc/manage_supply_operation(job_title, operation_type, items_managed, efficiency)
	if(!job_supply_management[job_title])
		job_supply_management[job_title] = list()

	var/list/operation_data = list(
		"operation_type" = operation_type,
		"items_managed" = items_managed,
		"efficiency" = efficiency,
		"timestamp" = world.time
	)
	job_supply_management[job_title] += operation_data

	var/exp_reward = items_managed * (efficiency / 100)
	add_job_experience(job_title, exp_reward, "Supply Management")

/datum/persistent_player_data/proc/contribute_service(job_title, service_type, beneficiaries, quality)
	if(!job_service_contributions[job_title])
		job_service_contributions[job_title] = list()

	var/list/contribution_data = list(
		"service_type" = service_type,
		"beneficiaries" = beneficiaries,
		"quality" = quality,
		"timestamp" = world.time
	)
	job_service_contributions[job_title] += contribution_data

	var/exp_reward = beneficiaries * (quality / 100)
	add_job_experience(job_title, exp_reward, "Service Contribution")

/datum/persistent_player_data/proc/participate_dclass_testing(job_title, test_type, scp_id, outcome)
	if(!job_dclass_testing[job_title])
		job_dclass_testing[job_title] = list()

	var/list/testing_data = list(
		"test_type" = test_type,
		"scp_id" = scp_id,
		"outcome" = outcome,
		"timestamp" = world.time
	)
	job_dclass_testing[job_title] += testing_data

	var/exp_reward = 0
	switch(test_type)
		if("routine")
			exp_reward = 25
		if("research")
			exp_reward = 50
		if("containment")
			exp_reward = 75
		if("emergency")
			exp_reward = 100

	add_job_experience(job_title, exp_reward, "D-Class Testing")

/datum/persistent_player_data/proc/check_job_achievements(job_title)
	// Job-specific achievement checks
	var/job_exp = get_job_experience(job_title)
	var/job_rounds = get_job_rounds_played(job_title)

	// Experience milestones
	if(job_exp >= 1000 && !("job_[job_title]_veteran" in achievements))
		unlock_achievement("job_[job_title]_veteran")
	if(job_exp >= 5000 && !("job_[job_title]_expert" in achievements))
		unlock_achievement("job_[job_title]_expert")
	if(job_exp >= 10000 && !("job_[job_title]_master" in achievements))
		unlock_achievement("job_[job_title]_master")

	// Round milestones
	if(job_rounds >= 10 && !("job_[job_title]_dedicated" in achievements))
		unlock_achievement("job_[job_title]_dedicated")
	if(job_rounds >= 50 && !("job_[job_title]_loyal" in achievements))
		unlock_achievement("job_[job_title]_loyal")
	if(job_rounds >= 100 && !("job_[job_title]_legendary" in achievements))
		unlock_achievement("job_[job_title]_legendary")

/datum/persistent_player_data/proc/get_job_statistics(job_title)
	var/list/stats = list()
	stats["experience"] = get_job_experience(job_title)
	stats["rounds_played"] = get_job_rounds_played(job_title)
	stats["achievements"] = length(job_achievements[job_title] || list())
	stats["specializations"] = length(job_specializations[job_title] || list())
	stats["certifications"] = length(job_certifications[job_title] || list())
	stats["promotions"] = length(job_promotions[job_title] || list())
	stats["commendations"] = length(job_commendations[job_title] || list())
	stats["incidents"] = length(job_incidents[job_title] || list())
	stats["disciplinary_actions"] = length(job_disciplinary_actions[job_title] || list())
	return stats

// Skill summary proc for skill progression system
/datum/persistent_player_data/proc/get_skill_summary()
	var/list/summary = list()

	// Get skill data from the mind if available
	var/datum/mind/player_mind = null
	for(var/client/C in GLOB.clients)
		if(C.ckey == ckey)
			player_mind = C.mob?.mind
			break

	if(player_mind)
		var/list/known_skills = player_mind.known_skills
		var/total_skills = 0
		var/highest_skill = "None"
		var/highest_level = 0
		var/list/skill_distribution = list()

		for(var/skill_type in known_skills)
			var/skill_level = known_skills[skill_type][SKILL_LVL]
			if(skill_level > 0)
				total_skills++
				if(skill_level > highest_level)
					highest_level = skill_level
					highest_skill = get_skill_name(skill_type)

				// Add to distribution
				if(!skill_distribution["[skill_level]"])
					skill_distribution["[skill_level]"] = 0
				skill_distribution["[skill_level]"]++

		summary["total_skills"] = total_skills
		summary["highest_skill"] = highest_skill
		summary["highest_level"] = highest_level
		summary["skill_distribution"] = skill_distribution
	else
		// Fallback data
		summary["total_skills"] = 0
		summary["highest_skill"] = "None"
		summary["highest_level"] = 0
		summary["skill_distribution"] = list()

	return summary
