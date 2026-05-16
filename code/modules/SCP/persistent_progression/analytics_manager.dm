// Player Analytics Manager System
// Tracks player statistics, behavior patterns, and performance metrics

/datum/player_analytics_manager
	var/name = "Player Analytics Manager"
	var/list/global_statistics = list()
	var/list/player_metrics_cache = list()
	var/cache_duration = 300
	var/last_cache_update = 0
	var/list/tracked_events = list()
	var/list/leaderboards = list()
	var/leaderboard_update_interval = 600
	var/last_leaderboard_update = 0

/datum/player_analytics_manager/New()
	initialize_tracked_events()
	initialize_global_statistics()
	initialize_leaderboards()

/datum/player_analytics_manager/proc/initialize_tracked_events()
	tracked_events = list(
		"round_completion" = TRUE,
		"round_end" = TRUE,
		"player_death" = TRUE,
		"player_kill" = TRUE,
		"scp_interaction" = TRUE,
		"scp_breach" = TRUE,
		"scp_recontainment" = TRUE,
		"containment_breach" = TRUE,
		"research_discovery" = TRUE,
		"medical_treatment" = TRUE,
		"engineering_build" = TRUE,
		"security_arrest" = TRUE,
		"experience_earned" = TRUE,
		"experience_gain" = TRUE,
		"achievement_unlock" = TRUE,
		"item_unlock" = TRUE,
		"title_unlock" = TRUE,
		"faction_change" = TRUE,
		"class_change" = TRUE,
		"job_change" = TRUE
	)

/datum/player_analytics_manager/proc/initialize_global_statistics()
	global_statistics = list(
		"total_rounds_played" = 0,
		"total_player_deaths" = 0,
		"total_player_kills" = 0,
		"total_scp_interactions" = 0,
		"total_containment_breaches" = 0,
		"total_research_discoveries" = 0,
		"total_medical_treatments" = 0,
		"total_engineering_builds" = 0,
		"total_security_arrests" = 0,
		"total_experience_earned" = 0,
		"total_achievements_unlocked" = 0,
		"total_items_unlocked" = 0,
		"total_titles_unlocked" = 0,
		"average_round_duration" = 0,
		"average_players_per_round" = 0,
		"most_played_class" = "",
		"most_played_faction" = "",
		"most_played_job" = "",
		"active_players_today" = 0,
		"active_players_this_week" = 0,
		"active_players_this_month" = 0
	)

/datum/player_analytics_manager/proc/initialize_leaderboards()
	leaderboards = list(
		"experience" = list(),
		"rounds_played" = list(),
		"achievements" = list(),
		"kills" = list(),
		"deaths" = list(),
		"kd_ratio" = list(),
		"survival_rate" = list(),
		"research_discoveries" = list(),
		"medical_treatments" = list(),
		"engineering_builds" = list(),
		"security_arrests" = list(),
		"scp_interactions" = list()
	)

/datum/player_analytics_manager/proc/track_event(ckey, event_type, event_data)
	if(!tracked_events[event_type])
		return FALSE

	record_player_event(ckey, event_type, event_data)
	update_global_statistics(event_type, event_data)
	check_event_milestones(ckey, event_type, event_data)

	return TRUE

/datum/player_analytics_manager/proc/record_player_event(ckey, event_type, event_data)
	var/datum/persistent_player_data/player_data = SSpersistent_progression.get_player_data(ckey)
	if(!player_data)
		return

	if(!player_data.event_history)
		player_data.event_history = list()

	var/list/event_record = list(
		"type" = event_type,
		"data" = event_data,
		"timestamp" = world.time,
		"round_id" = GLOB.round_id
	)

	player_data.event_history += list(event_record)

	if(length(player_data.event_history) > 1000)
		player_data.event_history.Cut(1, 501)

/datum/player_analytics_manager/proc/update_global_statistics(event_type, event_data)
	switch(event_type)
		if("round_completion")
			global_statistics["total_rounds_played"]++
		if("player_death")
			global_statistics["total_player_deaths"]++
		if("player_kill")
			global_statistics["total_player_kills"]++
		if("scp_interaction")
			global_statistics["total_scp_interactions"]++
		if("containment_breach")
			global_statistics["total_containment_breaches"]++
		if("research_discovery")
			global_statistics["total_research_discoveries"]++
		if("medical_treatment")
			global_statistics["total_medical_treatments"]++
		if("engineering_build")
			global_statistics["total_engineering_builds"]++
		if("security_arrest")
			global_statistics["total_security_arrests"]++
		if("experience_gain")
			global_statistics["total_experience_earned"] += event_data["amount"] || 0
		if("achievement_unlock")
			global_statistics["total_achievements_unlocked"]++
		if("item_unlock")
			global_statistics["total_items_unlocked"]++
		if("title_unlock")
			global_statistics["total_titles_unlocked"]++

/datum/player_analytics_manager/proc/check_event_milestones(ckey, event_type, event_data)
	var/datum/persistent_player_data/player_data = SSpersistent_progression.get_player_data(ckey)
	if(!player_data)
		return

	var/milestone_type = "[event_type]_count"
	var/current_count = player_data.performance_metrics[milestone_type] || 0
	current_count++
	player_data.performance_metrics[milestone_type] = current_count

	if(current_count == 10)
		notify_milestone(ckey, event_type, current_count)
	else if(current_count == 50)
		notify_milestone(ckey, event_type, current_count)
	else if(current_count == 100)
		notify_milestone(ckey, event_type, current_count)
	else if(current_count == 500)
		notify_milestone(ckey, event_type, current_count)
	else if(current_count == 1000)
		notify_milestone(ckey, event_type, current_count)

/datum/player_analytics_manager/proc/notify_milestone(ckey, event_type, count)
	for(var/client/C in GLOB.clients)
		if(C.ckey == ckey)
			to_chat(C, "<span class='boldnotice'>MILESTONE: You have recorded [count] [event_type] events!</span>")
			break

/datum/player_analytics_manager/proc/get_player_statistics(ckey)
	var/datum/persistent_player_data/player_data = SSpersistent_progression.get_player_data(ckey)
	if(!player_data)
		return list()

	var/list/stats = list()

	stats["basic"] = list(
		"total_experience" = player_data.total_experience,
		"rounds_played" = player_data.rounds_played,
		"rounds_survived" = player_data.rounds_survived,
		"rounds_died" = player_data.rounds_died,
		"survival_rate" = player_data.rounds_played > 0 ? round((player_data.rounds_survived / player_data.rounds_played) * 100, 0.1) : 0,
		"current_rank" = player_data.current_rank,
		"current_rank_name" = player_data.current_rank_name,
		"current_class" = player_data.current_class_id,
		"current_faction" = player_data.current_faction_id,
		"achievements_unlocked" = length(player_data.achievements),
		"items_unlocked" = length(player_data.unlocked_items),
		"titles_unlocked" = length(player_data.unlocked_titles),
		"achievement_points" = player_data.achievement_points
	)

	stats["performance"] = player_data.performance_metrics

	stats["class_data"] = player_data.class_data
	stats["faction_data"] = player_data.faction_data
	stats["job_data"] = list(
		"experience" = player_data.job_experience,
		"rounds_played" = player_data.job_rounds_played,
		"achievements" = player_data.job_achievements,
		"performance" = player_data.job_performance,
		"specializations" = player_data.job_specializations
	)

	return stats

/datum/player_analytics_manager/proc/get_player_comparison(ckey1, ckey2)
	var/list/stats1 = get_player_statistics(ckey1)
	var/list/stats2 = get_player_statistics(ckey2)

	if(!length(stats1) || !length(stats2))
		return list()

	var/list/comparison = list()
	comparison["player1"] = ckey1
	comparison["player2"] = ckey2

	comparison["experience_diff"] = stats1["basic"]["total_experience"] - stats2["basic"]["total_experience"]
	comparison["rounds_diff"] = stats1["basic"]["rounds_played"] - stats2["basic"]["rounds_played"]
	comparison["survival_diff"] = stats1["basic"]["survival_rate"] - stats2["basic"]["survival_rate"]
	comparison["achievements_diff"] = stats1["basic"]["achievements_unlocked"] - stats2["basic"]["achievements_unlocked"]

	return comparison

/datum/player_analytics_manager/proc/update_leaderboards()
	if(world.time < last_leaderboard_update + leaderboard_update_interval)
		return

	last_leaderboard_update = world.time

	for(var/leaderboard_type in leaderboards)
		leaderboards[leaderboard_type] = calculate_leaderboard(leaderboard_type)

/datum/player_analytics_manager/proc/calculate_leaderboard(leaderboard_type)
	var/list/rankings = list()

	for(var/ckey in SSpersistent_progression.player_data)
		var/datum/persistent_player_data/player_data = SSpersistent_progression.player_data[ckey]
		if(!player_data)
			continue

		var/value = 0

		switch(leaderboard_type)
			if("experience")
				value = player_data.total_experience
			if("rounds_played")
				value = player_data.rounds_played
			if("achievements")
				value = length(player_data.achievements)
			if("kills")
				value = player_data.performance_metrics["player_kills"] || 0
			if("deaths")
				value = player_data.performance_metrics["player_deaths"] || 0
			if("kd_ratio")
				var/kills = player_data.performance_metrics["player_kills"] || 0
				var/deaths = player_data.performance_metrics["player_deaths"] || 1
				value = deaths > 0 ? kills / deaths : kills
			if("survival_rate")
				value = player_data.rounds_played > 0 ? (player_data.rounds_survived / player_data.rounds_played) * 100 : 0
			if("research_discoveries")
				value = player_data.performance_metrics["research_discoveries"] || 0
			if("medical_treatments")
				value = player_data.performance_metrics["medical_treatments"] || 0
			if("engineering_builds")
				value = player_data.performance_metrics["engineering_builds"] || 0
			if("security_arrests")
				value = player_data.performance_metrics["security_arrests"] || 0
			if("scp_interactions")
				value = player_data.performance_metrics["scp_interactions"] || 0

		rankings[ckey] = value

	var/list/sorted_rankings = list()
	for(var/ckey in rankings)
		sorted_rankings += list(list("ckey" = ckey, "value" = rankings[ckey]))

	sorted_rankings = sort_list_by_value(sorted_rankings, "value", TRUE)

	return sorted_rankings

/datum/player_analytics_manager/proc/sort_list_by_value(list/input_list, key, descending = FALSE)
	var/list/sorted = input_list.Copy()

	for(var/i = 1 to length(sorted) - 1)
		for(var/j = i + 1 to length(sorted))
			var/list/item_i = sorted[i]
			var/list/item_j = sorted[j]

			if(descending)
				if(item_i[key] < item_j[key])
					sorted.Swap(i, j)
			else
				if(item_i[key] > item_j[key])
					sorted.Swap(i, j)

	return sorted

/datum/player_analytics_manager/proc/get_leaderboard(leaderboard_type, limit = 10)
	update_leaderboards()

	var/list/board = leaderboards[leaderboard_type]
	if(!board)
		return list()

	if(length(board) > limit)
		return board.Copy(1, limit + 1)

	return board

/datum/player_analytics_manager/proc/get_player_leaderboard_rank(ckey, leaderboard_type)
	var/list/board = leaderboards[leaderboard_type]
	if(!board)
		return -1

	for(var/i = 1 to length(board))
		var/list/entry = board[i]
		if(entry["ckey"] == ckey)
			return i

	return -1

/datum/player_analytics_manager/proc/get_global_statistics()
	return global_statistics

/datum/player_analytics_manager/proc/get_activity_report(days = 7)
	var/list/report = list()
	report["period"] = "[days] days"
	report["total_players"] = length(SSpersistent_progression.player_data)
	report["active_players"] = 0
	report["new_players"] = 0
	report["returning_players"] = 0

	var/cutoff_time = world.time - (days * 86400)

	for(var/ckey in SSpersistent_progression.player_data)
		var/datum/persistent_player_data/player_data = SSpersistent_progression.player_data[ckey]
		if(!player_data)
			continue

		if(player_data.last_login >= cutoff_time)
			report["active_players"]++

		if(player_data.rounds_played <= 5)
			report["new_players"]++
		else if(player_data.last_login < cutoff_time + 86400)
			report["returning_players"]++

	return report

/datum/player_analytics_manager/proc/get_trend_analysis(ckey, metric_type, days = 7)
	var/datum/persistent_player_data/player_data = SSpersistent_progression.get_player_data(ckey)
	if(!player_data || !player_data.event_history)
		return list()

	var/list/trends = list()
	var/cutoff_time = world.time - (days * 86400)

	for(var/list/event in player_data.event_history)
		if(event["timestamp"] < cutoff_time)
			continue

		if(event["type"] == metric_type)
			trends += list(event)

	return trends

/datum/player_analytics_manager/proc/export_analytics()
	var/list/data = list()
	data["global_statistics"] = global_statistics
	data["leaderboards"] = leaderboards
	data["tracked_events"] = tracked_events
	data["export_timestamp"] = world.time

	return json_encode(data)

/datum/player_analytics_manager/proc/generate_player_report(ckey)
	var/list/report = list()
	report["ckey"] = ckey
	report["generated_at"] = world.time
	report["statistics"] = get_player_statistics(ckey)
	report["leaderboard_ranks"] = list()

	for(var/leaderboard_type in leaderboards)
		var/rank = get_player_leaderboard_rank(ckey, leaderboard_type)
		if(rank > 0)
			report["leaderboard_ranks"][leaderboard_type] = rank

	return report
