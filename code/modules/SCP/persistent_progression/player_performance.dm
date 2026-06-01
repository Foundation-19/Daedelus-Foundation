// Player Performance Tracking System
/datum/player_performance
	var/ckey
	var/name
	var/list/job_performance = list()
	var/list/scp_performance = list()
	var/list/performance_history = list()
	var/total_playtime = 0
	var/rounds_played = 0
	var/rounds_as_scp = 0
	var/rounds_as_staff = 0
	var/overall_rating = 0.0
	var/last_updated = 0
	var/list/achievements = list()
	var/list/violations = list()
	var/access_level = 0
	// Aggregated SCP skill progression snapshots by scp_id
	var/list/scp_skill_summaries = list() // scp_id -> list(levels, top_skills)

/datum/player_performance/New(var/player_ckey)
	ckey = player_ckey
	load_performance_data()

/datum/player_performance/proc/load_performance_data()
	var/filename = "data/player_performance/[ckey].json"
	if(fexists(filename))
		var/json_data = file2text(filename)
		var/list/data = json_decode(json_data)
		if(data)
			job_performance = data["job_performance"] || list()
			scp_performance = data["scp_performance"] || list()
			performance_history = data["performance_history"] || list()
			total_playtime = data["total_playtime"] || 0
			rounds_played = data["rounds_played"] || 0
			rounds_as_scp = data["rounds_as_scp"] || 0
			rounds_as_staff = data["rounds_as_staff"] || 0
			overall_rating = data["overall_rating"] || 0.0
			last_updated = data["last_updated"] || 0
			achievements = data["achievements"] || list()
			violations = data["violations"] || list()
			access_level = data["access_level"] || 0
			scp_skill_summaries = data["scp_skill_summaries"] || list()

/datum/player_performance/proc/save_performance_data()
	var/list/data = list(
		"job_performance" = job_performance,
		"scp_performance" = scp_performance,
		"performance_history" = performance_history,
		"total_playtime" = total_playtime,
		"rounds_played" = rounds_played,
		"rounds_as_scp" = rounds_as_scp,
		"rounds_as_staff" = rounds_as_staff,
		"overall_rating" = overall_rating,
		"last_updated" = last_updated,
		"achievements" = achievements,
		"violations" = violations,
		"access_level" = access_level
		,"scp_skill_summaries" = scp_skill_summaries
	)
	var/filename = "data/player_performance/[ckey].json"
	fdel(filename)
	text2file(json_encode(data), filename)

/datum/player_performance/proc/record_job_performance(var/job_title, var/performance_score, var/round_data)
	if(!job_title || !performance_score)
		return
	if(!(job_title in job_performance))
		job_performance[job_title] = list()
	var/list/job_data = job_performance[job_title]
	job_data["current_score"] = performance_score
	job_data["rounds_played"] = (job_data["rounds_played"] || 0) + 1
	job_data["total_score"] = (job_data["total_score"] || 0) + performance_score
	job_data["average_score"] = job_data["total_score"] / job_data["rounds_played"]
	job_data["last_round"] = round_data
	var/list/history_entry = list(
		"timestamp" = 0,
		"job_title" = job_title,
		"performance_score" = performance_score,
		"round_data" = round_data
	)
	performance_history += history_entry
	update_overall_rating()
	save_performance_data()

/datum/player_performance/proc/record_scp_performance(var/scp_id, var/performance_score, var/round_data)
	if(!scp_id || !performance_score)
		return
	if(!(scp_id in scp_performance))
		scp_performance[scp_id] = list()
	var/list/scp_data = scp_performance[scp_id]
	scp_data["current_score"] = performance_score
	scp_data["rounds_played"] = (scp_data["rounds_played"] || 0) + 1
	scp_data["total_score"] = (scp_data["total_score"] || 0) + performance_score
	scp_data["average_score"] = scp_data["total_score"] / scp_data["rounds_played"]
	scp_data["last_round"] = round_data
	var/list/history_entry = list(
		"timestamp" = 0,
		"scp_id" = scp_id,
		"performance_score" = performance_score,
		"round_data" = round_data
	)
	performance_history += history_entry
	update_overall_rating()
	// Update skill snapshot placeholder (can be fed by round-end aggregation)
	if(!(scp_id in scp_skill_summaries))
		scp_skill_summaries[scp_id] = list("levels" = list(), "top_skills" = list())
	save_performance_data()

/datum/player_performance/proc/update_overall_rating()
	var/total_score = 0
	var/total_rounds = 0
	for(var/job_title in job_performance)
		var/list/job_data = job_performance[job_title]
		total_score += (job_data["average_score"] || 0) * (job_data["rounds_played"] || 0)
		total_rounds += job_data["rounds_played"] || 0
	for(var/scp_id in scp_performance)
		var/list/scp_data = scp_performance[scp_id]
		total_score += (scp_data["average_score"] || 0) * (scp_data["rounds_played"] || 0)
		total_rounds += scp_data["rounds_played"] || 0
	if(total_rounds > 0)
		overall_rating = total_score / total_rounds
	else
		overall_rating = 0.0
	update_access_level()

/datum/player_performance/proc/update_access_level()
	var/new_access_level = 0
	if(overall_rating >= 90 && rounds_played >= 25)
		new_access_level = 5
	else if(overall_rating >= 85 && rounds_played >= 20)
		new_access_level = 4
	else if(overall_rating >= 75 && rounds_played >= 15)
		new_access_level = 3
	else if(overall_rating >= 65 && rounds_played >= 10)
		new_access_level = 2
	else if(overall_rating >= 50 && rounds_played >= 5)
		new_access_level = 1
	else
		new_access_level = 0
	for(var/violation in violations)
		var/list/viol_data = violation
		if(viol_data["active"] && viol_data["severity"] == "major")
			new_access_level = new_access_level - 1
			if(new_access_level < 0)
				new_access_level = 0
	access_level = new_access_level

/datum/player_performance/proc/add_achievement(var/achievement_id, var/achievement_name, var/description)
	var/list/achievement = list(
		"id" = achievement_id,
		"name" = achievement_name,
		"description" = description,
		"timestamp" = 0
	)
	achievements += achievement
	save_performance_data()

/datum/player_performance/proc/add_violation(var/violation_type, var/description, var/severity = "minor")
	var/list/violation = list(
		"type" = violation_type,
		"description" = description,
		"severity" = severity,
		"timestamp" = 0,
		"active" = 1
	)
	violations += violation
	update_access_level()
	save_performance_data()

/datum/player_performance/proc/get_available_scps()
	var/list/available_scps = list()
	if(access_level == 5)
		available_scps = list(ROLE_SCP173, ROLE_SCP096, ROLE_SCP008, ROLE_SCP035, ROLE_SCP049, ROLE_SCP2427_3, ROLE_SARKIC_CULT, ROLE_CHAOS_INSURGENCY, ROLE_SERPENTS_HAND)
	else if(access_level == 4)
		available_scps = list(ROLE_SCP173, ROLE_SCP096, ROLE_SCP008, ROLE_SCP035, ROLE_SCP049, ROLE_SCP2427_3, ROLE_SARKIC_CULT, ROLE_CHAOS_INSURGENCY, ROLE_SERPENTS_HAND)
	else if(access_level == 3)
		available_scps = list(ROLE_SCP173, ROLE_SCP096, ROLE_SCP008, ROLE_SCP035, ROLE_SCP049)
	else if(access_level == 2)
		available_scps = list(ROLE_SCP173, ROLE_SCP096, ROLE_SCP008)
	else if(access_level == 1)
		available_scps = list(ROLE_SCP173, ROLE_SCP096)
	else if(access_level == 0)
		available_scps = list()
	return available_scps

// Called by round-end processing to register SCP skill stats into performance
/datum/player_performance/proc/register_scp_skill_snapshot(var/scp_id, var/list/skill_levels)
	if(!scp_id || !islist(skill_levels))
		return
	var/list/snapshot = list()
	for(var/skill in skill_levels)
		snapshot[skill] = skill_levels[skill]
	if(!(scp_id in scp_skill_summaries))
		scp_skill_summaries[scp_id] = list("levels" = list(), "top_skills" = list())
	var/list/summary = scp_skill_summaries[scp_id]
	// Keep last 5 snapshots
	var/list/levels_history = summary["levels"] || list()
	levels_history += list(snapshot)
	while(length(levels_history) > 5)
		levels_history.Cut(1,2)
	summary["levels"] = levels_history

	// Compute top 3 skills (manual selection)
	var/list/top = list()
	var/list/temp = snapshot.Copy()
	for(var/i=1, i<=3, i++)
		var/best_key = null
		var/best_level = -1
		for(var/k in temp)
			if(temp[k] > best_level)
				best_level = temp[k]
				best_key = k
		if(!isnull(best_key))
			top += list(list("name"=best_key, "level"=best_level))
			temp -= best_key
	summary["top_skills"] = top
	scp_skill_summaries[scp_id] = summary
	save_performance_data()
