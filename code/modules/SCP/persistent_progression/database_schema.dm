// JSON-Based Database Schema for Persistent Progression System
// This file defines a database-like system using JSON files for storing progression data

// Database table definitions (JSON file names)
#define TABLE_PLAYERS "players.json"
#define TABLE_EXPERIENCE "experience.json"
#define TABLE_ACHIEVEMENTS "achievements.json"
#define TABLE_ITEMS "items.json"
#define TABLE_TITLES "titles.json"
#define TABLE_ROUNDS "rounds.json"
#define TABLE_JOB_STATS "job_stats.json"
#define TABLE_ANALYTICS "analytics.json"

// JSON-based database system
/datum/persistent_progression_database
	var/db_path = "data/persistent_progression_db/"
	var/initialized = FALSE
	var/list/cache = list()

/datum/persistent_progression_database/New()
	initialize_database()

/datum/persistent_progression_database/proc/initialize_database()
	if(initialized)
		return

	// Create database directory
	rustg_file_write("", "[db_path].gitkeep")

	// Initialize cache
	cache = list()

	// Create tables (JSON files)
	create_players_table()
	create_experience_table()
	create_achievements_table()
	create_items_table()
	create_titles_table()
	create_rounds_table()
	create_job_stats_table()
	create_analytics_table()

	initialized = TRUE
	log_game("Persistent Progression Database: Initialized successfully")

// Create players table
/datum/persistent_progression_database/proc/create_players_table()
	var/file_path = "[db_path][TABLE_PLAYERS]"
	if(!fexists(file_path))
		rustg_file_write("{}", file_path)

// Create experience table
/datum/persistent_progression_database/proc/create_experience_table()
	var/file_path = "[db_path][TABLE_EXPERIENCE]"
	if(!fexists(file_path))
		rustg_file_write("{}", file_path)

// Create achievements table
/datum/persistent_progression_database/proc/create_achievements_table()
	var/file_path = "[db_path][TABLE_ACHIEVEMENTS]"
	if(!fexists(file_path))
		rustg_file_write("{}", file_path)

// Create items table
/datum/persistent_progression_database/proc/create_items_table()
	var/file_path = "[db_path][TABLE_ITEMS]"
	if(!fexists(file_path))
		rustg_file_write("{}", file_path)

// Create titles table
/datum/persistent_progression_database/proc/create_titles_table()
	var/file_path = "[db_path][TABLE_TITLES]"
	if(!fexists(file_path))
		rustg_file_write("{}", file_path)

// Create rounds table
/datum/persistent_progression_database/proc/create_rounds_table()
	var/file_path = "[db_path][TABLE_ROUNDS]"
	if(!fexists(file_path))
		rustg_file_write("{}", file_path)

// Create job stats table
/datum/persistent_progression_database/proc/create_job_stats_table()
	var/file_path = "[db_path][TABLE_JOB_STATS]"
	if(!fexists(file_path))
		rustg_file_write("{}", file_path)

// Create analytics table
/datum/persistent_progression_database/proc/create_analytics_table()
	var/file_path = "[db_path][TABLE_ANALYTICS]"
	if(!fexists(file_path))
		rustg_file_write("{}", file_path)

// Helper functions for JSON operations
/datum/persistent_progression_database/proc/read_json_file(file_path)
	if(!fexists(file_path))
		return list()

	var/json_data = rustg_file_read(file_path)
	if(!json_data)
		return list()

	var/list/data = json_decode(json_data)
	return data || list()

/datum/persistent_progression_database/proc/write_json_file(file_path, data)
	var/json_data = json_encode(data)
	return rustg_file_write(json_data, file_path)

// Player data operations
/datum/persistent_progression_database/proc/get_player_data(ckey)
	if(!ckey)
		return null

	var/file_path = "[db_path][TABLE_PLAYERS]"
	var/list/players = read_json_file(file_path)

	if(players[ckey])
		return players[ckey]
	return null

/datum/persistent_progression_database/proc/create_player_data(ckey, player_name)
	if(!ckey)
		return FALSE

	var/file_path = "[db_path][TABLE_PLAYERS]"
	var/list/players = read_json_file(file_path)

	if(players[ckey])
		return TRUE // Already exists

	players[ckey] = list(
		"ckey" = ckey,
		"player_name" = player_name,
		"current_class_id" = "security",
		"current_faction_id" = "foundation",
		"current_rank" = 0,
		"current_rank_name" = "Recruit",
		"preferred_class" = "security",
		"preferred_faction" = "foundation",
		"total_experience" = 0,
		"rounds_played" = 0,
		"rounds_survived" = 0,
		"rounds_died" = 0,
		"total_kills" = 0,
		"total_deaths" = 0,
		"total_healing" = 0,
		"total_damage_dealt" = 0,
		"total_objectives" = 0,
		"total_scp_interactions" = 0,
		"total_containment_breaches" = 0,
		"total_recontainments" = 0,
		"total_research_completed" = 0,
		"total_treatments" = 0,
		"total_constructions" = 0,
		"total_repairs" = 0,
		"total_arrests" = 0,
		"reputation_score" = 0,
		"total_playtime" = 0,
		"current_streak" = 0,
		"longest_streak" = 0,
		"current_job" = "",
		"skill_boost_multiplier" = 1.0,
		"achievement_points" = 0,
		"total_achievements_unlocked" = 0,
		"data_version" = 1,
		"last_login" = world.time,
		"created_at" = world.time,
		"updated_at" = world.time
	)

	return write_json_file(file_path, players)

/datum/persistent_progression_database/proc/update_player_data(ckey, data)
	if(!ckey || !data)
		return FALSE

	var/file_path = "[db_path][TABLE_PLAYERS]"
	var/list/players = read_json_file(file_path)

	if(!players[ckey])
		return FALSE

	var/list/safe_keys = list("current_class_id", "current_faction_id", "current_rank", "current_rank_name", "total_experience", "rounds_played", "rounds_survived", "rounds_died", "preferred_class", "preferred_faction", "total_kills", "total_deaths", "total_healing", "total_damage_dealt", "total_objectives", "total_scp_interactions", "total_containment_breaches", "total_recontainments", "total_research_completed", "total_treatments", "total_constructions", "total_repairs", "total_arrests", "reputation_score", "total_playtime", "current_streak", "longest_streak", "current_job", "skill_boost_multiplier", "achievement_points", "total_achievements_unlocked", "data_version")
	for(var/key in safe_keys)
		if(!isnull(data[key]))
			players[ckey][key] = data[key]

	var/list/list_keys = list("class_data", "rank_data", "faction_data", "unlocked_items", "unlocked_titles", "unlocked_cosmetics", "achievements", "achievement_progress", "experience_sources", "performance_metrics", "currency", "settings", "job_rounds_played", "job_experience", "job_achievements", "job_performance", "job_specializations", "job_promotions", "job_incidents", "job_commendations", "job_disciplinary_actions", "job_training_completed", "job_certifications", "job_mentoring_sessions", "job_research_papers", "job_containment_breaches", "job_scp_interactions", "job_medical_procedures", "job_engineering_projects", "job_security_operations", "job_supply_management", "job_service_contributions", "job_dclass_testing")
	for(var/key in list_keys)
		if(!isnull(data[key]))
			players[ckey][key] = data[key]

	players[ckey]["last_login"] = world.time
	players[ckey]["updated_at"] = world.time

	return write_json_file(file_path, players)

// Experience operations
/datum/persistent_progression_database/proc/add_experience(ckey, source, amount, reason)
	if(!ckey || !source || amount <= 0)
		return FALSE

	var/file_path = "[db_path][TABLE_EXPERIENCE]"
	var/list/experience = read_json_file(file_path)

	if(!experience[ckey])
		experience[ckey] = list()

	var/list/exp_entry = list(
		"source" = source,
		"amount" = amount,
		"reason" = reason,
		"timestamp" = world.time
	)

	experience[ckey] += list(exp_entry)

	// Keep only last 100 entries
	var/list/exp_entries2 = experience[ckey]
	if(length(exp_entries2) > 100)
		experience[ckey] = exp_entries2.Copy(length(exp_entries2) - 99, length(exp_entries2))

	var/success = write_json_file(file_path, experience)

	if(success)
		// Update total experience in players table
		var/player_file = "[db_path][TABLE_PLAYERS]"
		var/list/players = read_json_file(player_file)
		if(players[ckey])
			players[ckey]["total_experience"] += amount
			players[ckey]["updated_at"] = world.time
			write_json_file(player_file, players)

	return success

/datum/persistent_progression_database/proc/get_recent_experience(ckey, limit = 10)
	if(!ckey)
		return list()

	var/file_path = "[db_path][TABLE_EXPERIENCE]"
	var/list/experience = read_json_file(file_path)

	if(!experience[ckey])
		return list()

	var/list/exp_entries2 = experience[ckey]
	var/list/recent = exp_entries2.Copy()
	// Sort by timestamp (newest first)
	recent = sort_list(recent, /proc/cmp_experience_timestamp)

	var/list/recent_copy = recent.Copy()
	return recent_copy.Copy(1, min(limit + 1, length(recent_copy) + 1))

// Achievement operations
/datum/persistent_progression_database/proc/unlock_achievement(ckey, achievement_id, progress = 0)
	if(!ckey || !achievement_id)
		return FALSE

	var/file_path = "[db_path][TABLE_ACHIEVEMENTS]"
	var/list/achievements = read_json_file(file_path)

	if(!achievements[ckey])
		achievements[ckey] = list()

	achievements[ckey][achievement_id] = list(
		"unlocked_at" = world.time,
		"progress" = progress
	)

	return write_json_file(file_path, achievements)

/datum/persistent_progression_database/proc/get_achievements(ckey)
	if(!ckey)
		return list()

	var/file_path = "[db_path][TABLE_ACHIEVEMENTS]"
	var/list/achievements = read_json_file(file_path)

	if(!achievements[ckey])
		return list()

	var/list/result = list()
	for(var/achievement_id in achievements[ckey])
		var/list/achievement = achievements[ckey][achievement_id]
		result += list(list(
			"achievement_id" = achievement_id,
			"unlocked_at" = achievement["unlocked_at"],
			"progress" = achievement["progress"]
		))

	return result

/datum/persistent_progression_database/proc/has_achievement(ckey, achievement_id)
	if(!ckey || !achievement_id)
		return FALSE

	var/file_path = "[db_path][TABLE_ACHIEVEMENTS]"
	var/list/achievements = read_json_file(file_path)

	return achievements[ckey] && achievements[ckey][achievement_id]

// Item operations
/datum/persistent_progression_database/proc/unlock_item(ckey, item_id)
	if(!ckey || !item_id)
		return FALSE

	var/file_path = "[db_path][TABLE_ITEMS]"
	var/list/items = read_json_file(file_path)

	if(!items[ckey])
		items[ckey] = list()

	if(!items[ckey][item_id])
		items[ckey][item_id] = list("unlocked_at" = world.time)

	return write_json_file(file_path, items)

/datum/persistent_progression_database/proc/get_unlocked_items(ckey)
	if(!ckey)
		return list()

	var/file_path = "[db_path][TABLE_ITEMS]"
	var/list/items = read_json_file(file_path)

	if(!items[ckey])
		return list()

	var/list/result = list()
	for(var/item_id in items[ckey])
		result += list(list(
			"item_id" = item_id,
			"unlocked_at" = items[ckey][item_id]["unlocked_at"]
		))

	return result

// Title operations
/datum/persistent_progression_database/proc/unlock_title(ckey, title_id)
	if(!ckey || !title_id)
		return FALSE

	var/file_path = "[db_path][TABLE_TITLES]"
	var/list/titles = read_json_file(file_path)

	if(!titles[ckey])
		titles[ckey] = list()

	if(!titles[ckey][title_id])
		titles[ckey][title_id] = list("unlocked_at" = world.time)

	return write_json_file(file_path, titles)

/datum/persistent_progression_database/proc/get_unlocked_titles(ckey)
	if(!ckey)
		return list()

	var/file_path = "[db_path][TABLE_TITLES]"
	var/list/titles = read_json_file(file_path)

	if(!titles[ckey])
		return list()

	var/list/result = list()
	for(var/title_id in titles[ckey])
		result += list(list(
			"title_id" = title_id,
			"unlocked_at" = titles[ckey][title_id]["unlocked_at"]
		))

	return result

// Round operations
/datum/persistent_progression_database/proc/start_round(ckey, round_id, job_title, faction_id)
	if(!ckey || !round_id)
		return FALSE

	var/file_path = "[db_path][TABLE_ROUNDS]"
	var/list/rounds = read_json_file(file_path)

	if(!rounds[ckey])
		rounds[ckey] = list()

	rounds[ckey][round_id] = list(
		"job_title" = job_title,
		"faction_id" = faction_id,
		"started_at" = world.time,
		"ended_at" = null,
		"survived" = FALSE,
		"experience_gained" = 0,
		"achievements_unlocked" = 0
	)

	return write_json_file(file_path, rounds)

/datum/persistent_progression_database/proc/end_round(ckey, round_id, survived, experience_gained, achievements_unlocked)
	if(!ckey || !round_id)
		return FALSE

	var/file_path = "[db_path][TABLE_ROUNDS]"
	var/list/rounds = read_json_file(file_path)

	if(!rounds[ckey] || !rounds[ckey][round_id])
		return FALSE

	rounds[ckey][round_id]["ended_at"] = world.time
	rounds[ckey][round_id]["survived"] = survived
	rounds[ckey][round_id]["experience_gained"] = experience_gained
	rounds[ckey][round_id]["achievements_unlocked"] = achievements_unlocked

	return write_json_file(file_path, rounds)

// Job stats operations
/datum/persistent_progression_database/proc/update_job_stats(ckey, job_title, survived, experience_gained, achievements_unlocked)
	if(!ckey || !job_title)
		return FALSE

	var/file_path = "[db_path][TABLE_JOB_STATS]"
	var/list/job_stats = read_json_file(file_path)

	if(!job_stats[ckey])
		job_stats[ckey] = list()

	if(!job_stats[ckey][job_title])
		job_stats[ckey][job_title] = list(
			"rounds_played" = 0,
			"rounds_survived" = 0,
			"total_experience" = 0,
			"achievements_unlocked" = 0,
			"last_played" = world.time
		)

	job_stats[ckey][job_title]["rounds_played"]++
	if(survived)
		job_stats[ckey][job_title]["rounds_survived"]++
	job_stats[ckey][job_title]["total_experience"] += experience_gained
	job_stats[ckey][job_title]["achievements_unlocked"] += achievements_unlocked
	job_stats[ckey][job_title]["last_played"] = world.time

	return write_json_file(file_path, job_stats)

/datum/persistent_progression_database/proc/get_job_stats(ckey)
	if(!ckey)
		return list()

	var/file_path = "[db_path][TABLE_JOB_STATS]"
	var/list/job_stats = read_json_file(file_path)

	if(!job_stats[ckey])
		return list()

	var/list/result = list()
	for(var/job_title in job_stats[ckey])
		var/list/stats = job_stats[ckey][job_title]
		result += list(list(
			"job_title" = job_title,
			"rounds_played" = stats["rounds_played"],
			"rounds_survived" = stats["rounds_survived"],
			"total_experience" = stats["total_experience"],
			"achievements_unlocked" = stats["achievements_unlocked"],
			"last_played" = stats["last_played"]
		))

	return result

// Analytics operations
/datum/persistent_progression_database/proc/record_metric(ckey, metric_name, metric_value)
	if(!ckey || !metric_name)
		return FALSE

	var/file_path = "[db_path][TABLE_ANALYTICS]"
	var/list/analytics = read_json_file(file_path)

	if(!analytics[ckey])
		analytics[ckey] = list()

	if(!analytics[ckey][metric_name])
		analytics[ckey][metric_name] = list()

	analytics[ckey][metric_name] += list(list(
		"metric_value" = metric_value,
		"recorded_at" = world.time
	))

	// Keep only last 100 entries per metric
	var/list/metric_entries = analytics[ckey][metric_name]
	if(length(metric_entries) > 100)
		analytics[ckey][metric_name] = metric_entries.Copy(length(metric_entries) - 99, length(metric_entries))

	return write_json_file(file_path, analytics)

/datum/persistent_progression_database/proc/get_analytics(ckey, metric_name, limit = 100)
	if(!ckey || !metric_name)
		return list()

	var/file_path = "[db_path][TABLE_ANALYTICS]"
	var/list/analytics = read_json_file(file_path)

	if(!analytics[ckey] || !analytics[ckey][metric_name])
		return list()

	var/list/metric_source = analytics[ckey][metric_name]
	var/list/metric_data = metric_source.Copy()
	// Sort by timestamp (newest first)
	metric_data = sort_list(metric_data, /proc/cmp_analytics_timestamp)

	var/list/metric_copy = metric_data.Copy()
	return metric_copy.Copy(1, min(limit + 1, length(metric_copy) + 1))

// Global statistics
/datum/persistent_progression_database/proc/get_global_stats()
	var/file_path = "[db_path][TABLE_PLAYERS]"
	var/list/players = read_json_file(file_path)

	var/total_players = length(players)
	var/total_experience = 0
	var/total_rounds = 0

	for(var/ckey in players)
		var/list/player = players[ckey]
		total_experience += player["total_experience"] || 0
		total_rounds += player["rounds_played"] || 0

	var/avg_experience = total_players > 0 ? total_experience / total_players : 0
	var/avg_rounds = total_players > 0 ? total_rounds / total_players : 0

	return list(
		"total_players" = total_players,
		"total_experience" = total_experience,
		"total_rounds" = total_rounds,
		"avg_experience" = avg_experience,
		"avg_rounds" = avg_rounds
	)

// Faction statistics
/datum/persistent_progression_database/proc/get_faction_stats()
	var/file_path = "[db_path][TABLE_PLAYERS]"
	var/list/players = read_json_file(file_path)

	var/list/faction_stats = list()

	for(var/ckey in players)
		var/list/player = players[ckey]
		var/faction_id = player["current_faction_id"] || "foundation"

		if(!faction_stats[faction_id])
			faction_stats[faction_id] = list(
				"faction_id" = faction_id,
				"member_count" = 0,
				"total_experience" = 0,
				"avg_experience" = 0
			)

		faction_stats[faction_id]["member_count"]++
		faction_stats[faction_id]["total_experience"] += player["total_experience"] || 0

	// Calculate averages
	for(var/faction_id in faction_stats)
		var/list/stats = faction_stats[faction_id]
		stats["avg_experience"] = stats["member_count"] > 0 ? stats["total_experience"] / stats["member_count"] : 0

	// Convert to list format
	var/list/result = list()
	for(var/faction_id in faction_stats)
		result += list(faction_stats[faction_id])

	return result

// Cleanup old data
/datum/persistent_progression_database/proc/cleanup_old_data(days_to_keep = 30)
	var/cutoff_time = world.time - (days_to_keep * 24 * 60 * 60 * 10) // Convert days to ticks

	// Clean experience data
	var/file_path = "[db_path][TABLE_EXPERIENCE]"
	var/list/experience = read_json_file(file_path)
	for(var/ckey in experience)
		if(experience[ckey])
			var/list/new_entries = list()
			for(var/list/entry in experience[ckey])
				if(entry["timestamp"] > cutoff_time)
					new_entries += list(entry)
			experience[ckey] = new_entries
	write_json_file(file_path, experience)

	// Clean analytics data
	file_path = "[db_path][TABLE_ANALYTICS]"
	var/list/analytics = read_json_file(file_path)
	for(var/ckey in analytics)
		if(analytics[ckey])
			for(var/metric_name in analytics[ckey])
				if(analytics[ckey][metric_name])
					var/list/new_entries = list()
					for(var/list/entry in analytics[ckey][metric_name])
						if(entry["recorded_at"] > cutoff_time)
							new_entries += list(entry)
					analytics[ckey][metric_name] = new_entries
	write_json_file(file_path, analytics)

	log_game("Persistent Progression Database: Cleaned up data older than [days_to_keep] days")

// Export player data
/datum/persistent_progression_database/proc/export_player_data(ckey)
	if(!ckey)
		return null

	var/list/data = list()

	// Get player data
	data["player"] = get_player_data(ckey)

	// Get recent experience
	data["recent_experience"] = get_recent_experience(ckey, 50)

	// Get achievements
	data["achievements"] = get_achievements(ckey)

	// Get items
	data["items"] = get_unlocked_items(ckey)

	// Get titles
	data["titles"] = get_unlocked_titles(ckey)

	// Get job stats
	data["job_stats"] = get_job_stats(ckey)

	// Get analytics
	data["analytics"] = get_analytics(ckey, "performance", 100)

	return data

// Reset player data
/datum/persistent_progression_database/proc/reset_player_data(ckey)
	if(!ckey)
		return FALSE

	// Reset player data
	var/file_path = "[db_path][TABLE_PLAYERS]"
	var/list/players = read_json_file(file_path)
	if(players[ckey])
		players[ckey]["current_class_id"] = "security"
		players[ckey]["current_faction_id"] = "foundation"
		players[ckey]["current_rank"] = 0
		players[ckey]["current_rank_name"] = "Recruit"
		players[ckey]["total_experience"] = 0
		players[ckey]["rounds_played"] = 0
		players[ckey]["rounds_survived"] = 0
		players[ckey]["rounds_died"] = 0
		players[ckey]["updated_at"] = world.time
		write_json_file(file_path, players)

	// Clear other data
	var/tables = list(TABLE_EXPERIENCE, TABLE_ACHIEVEMENTS, TABLE_ITEMS, TABLE_TITLES, TABLE_ROUNDS, TABLE_JOB_STATS, TABLE_ANALYTICS)
	for(var/table in tables)
		file_path = "[db_path][table]"
		var/list/table_data = read_json_file(file_path)
		table_data[ckey] = null
		write_json_file(file_path, table_data)

	return TRUE

// Helper comparison functions
/proc/cmp_experience_timestamp(list/a, list/b)
	return b["timestamp"] - a["timestamp"]

/proc/cmp_analytics_timestamp(list/a, list/b)
	return b["recorded_at"] - a["recorded_at"]
