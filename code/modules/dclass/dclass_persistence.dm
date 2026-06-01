// D-Class Enhanced Persistence System
// Tracks detailed player statistics, achievements, and integrates with SCP persistence

/datum/dclass_persistence_data
	var/ckey
	var/name
	var/round_count = 0
	var/total_playtime = 0
	var/total_escape_attempts = 0
	var/total_successful_escapes = 0
	var/total_contraband_found = 0
	var/total_work_completed = 0
	var/total_alliances_formed = 0
	var/total_players_betrayed = 0
	var/highest_level_achieved = 1
	var/longest_survival_time = 0
	var/most_valuable_contraband = ""
	var/favorite_escape_route = ""
	var/achievements = list()
	var/statistics = list()
	var/last_round_data = list()
	var/persistence_version = 1

// Achievement System
/datum/dclass_achievement
	var/id
	var/name
	var/description
	var/icon_state = "achievement"
	var/unlocked = FALSE
	var/unlock_time = 0
	var/requirements = list()

// Define achievements
/datum/dclass_achievement/first_escape
	id = "first_escape"
	name = "First Taste of Freedom"
	description = "Successfully escape for the first time"
	requirements = list("successful_escapes" = 1)

/datum/dclass_achievement/contraband_collector
	id = "contraband_collector"
	name = "Contraband Collector"
	description = "Find 50 pieces of contraband"
	requirements = list("total_contraband_found" = 50)

/datum/dclass_achievement/escape_artist
	id = "escape_artist"
	name = "Escape Artist"
	description = "Successfully escape 10 times"
	requirements = list("successful_escapes" = 10)

/datum/dclass_achievement/social_butterfly
	id = "social_butterfly"
	name = "Social Butterfly"
	description = "Form 20 alliances with other D-Class"
	requirements = list("total_alliances_formed" = 20)

/datum/dclass_achievement/betrayer
	id = "betrayer"
	name = "The Betrayer"
	description = "Betray 10 other D-Class players"
	requirements = list("total_players_betrayed" = 10)

/datum/dclass_achievement/survivor
	id = "survivor"
	name = "Survivor"
	description = "Survive for 30 minutes in a single round"
	requirements = list("longest_survival_time" = 1800)

/datum/dclass_achievement/master_escape
	id = "master_escape"
	name = "Master Escape Artist"
	description = "Reach level 5 and escape successfully"
	requirements = list("highest_level_achieved" = 5, "successful_escapes" = 1)

/datum/dclass_achievement/scp_exploiter
	id = "scp_exploiter"
	name = "SCP Exploiter"
	description = "Successfully escape during an SCP breach event"
	requirements = list("escape_during_scp_event" = 1)

/datum/dclass_achievement/stealth_master
	id = "stealth_master"
	name = "Stealth Master"
	description = "Complete a round without being detected by guards"
	requirements = list("stealth_round" = 1)

/datum/dclass_achievement/contraband_king
	id = "contraband_king"
	name = "Contraband King"
	description = "Find 100 pieces of contraband"
	requirements = list("total_contraband_found" = 100)

// Enhanced Persistence Manager
/datum/dclass_persistence_manager
	var/list/datum/dclass_persistence_data/persistent_data = list()
	var/list/achievements = list()
	var/persistence_file = "data/dclass_persistence.json"
	var/backup_file = "data/dclass_persistence_backup.json"
	var/auto_save_interval = 600 // 10 minutes
	var/last_save_time = 0

/datum/dclass_persistence_manager/New()
	. = ..()
	initialize_achievements()
	load_persistence_data()

/datum/dclass_persistence_manager/proc/initialize_achievements()
	achievements["first_escape"] = new /datum/dclass_achievement/first_escape()
	achievements["contraband_collector"] = new /datum/dclass_achievement/contraband_collector()
	achievements["escape_artist"] = new /datum/dclass_achievement/escape_artist()
	achievements["social_butterfly"] = new /datum/dclass_achievement/social_butterfly()
	achievements["betrayer"] = new /datum/dclass_achievement/betrayer()
	achievements["survivor"] = new /datum/dclass_achievement/survivor()
	achievements["master_escape"] = new /datum/dclass_achievement/master_escape()
	achievements["scp_exploiter"] = new /datum/dclass_achievement/scp_exploiter()
	achievements["stealth_master"] = new /datum/dclass_achievement/stealth_master()
	achievements["contraband_king"] = new /datum/dclass_achievement/contraband_king()

/datum/dclass_persistence_manager/proc/get_persistence_data(ckey)
	if(!(ckey in persistent_data))
		persistent_data[ckey] = new /datum/dclass_persistence_data()
		persistent_data[ckey].ckey = ckey
	return persistent_data[ckey]

/datum/dclass_persistence_manager/proc/update_player_statistics(datum/dclass_player/player, stat_name, value)
	if(!player || !player.ckey)
		return

	var/datum/dclass_persistence_data/data = get_persistence_data(player.ckey)

	// Update basic statistics
	switch(stat_name)
		if("escape_attempts")
			data.total_escape_attempts += value
		if("successful_escapes")
			data.total_successful_escapes += value
		if("contraband_found")
			data.total_contraband_found += value
		if("work_completed")
			data.total_work_completed += value
		if("alliances_formed")
			data.total_alliances_formed += value
		if("players_betrayed")
			data.total_players_betrayed += value
		if("level_achieved")
			if(value > data.highest_level_achieved)
				data.highest_level_achieved = value
		if("survival_time")
			if(value > data.longest_survival_time)
				data.longest_survival_time = value
		if("valuable_contraband")
			data.most_valuable_contraband = value
		if("escape_route")
			data.favorite_escape_route = value

	// Update detailed statistics
	if(!(stat_name in data.statistics))
		data.statistics[stat_name] = 0
	data.statistics[stat_name] += value

	// Check for achievement unlocks
	check_achievements(data)

/datum/dclass_persistence_manager/proc/check_achievements(datum/dclass_persistence_data/data)
	for(var/achievement_id in achievements)
		if(achievement_id in data.achievements)
			continue

		var/datum/dclass_achievement/achievement = achievements[achievement_id]

		var/can_unlock = TRUE
		for(var/requirement in achievement.requirements)
			var/required_value = achievement.requirements[requirement]
			var/current_value = 0

			// Get current value based on requirement type
			switch(requirement)
				if("successful_escapes")
					current_value = data.total_successful_escapes
				if("total_contraband_found")
					current_value = data.total_contraband_found
				if("total_alliances_formed")
					current_value = data.total_alliances_formed
				if("total_players_betrayed")
					current_value = data.total_players_betrayed
				if("highest_level_achieved")
					current_value = data.highest_level_achieved
				if("longest_survival_time")
					current_value = data.longest_survival_time
				else
					// Check detailed statistics
					current_value = data.statistics[requirement] || 0

			if(current_value < required_value)
				can_unlock = FALSE
				break

		if(can_unlock)
			unlock_achievement(data, achievement)

/datum/dclass_persistence_manager/proc/unlock_achievement(datum/dclass_persistence_data/data, datum/dclass_achievement/achievement)
	data.achievements[achievement.id] = list(
		"name" = achievement.name,
		"description" = achievement.description,
		"unlock_time" = world.time
	)

	// Notify player if they're online
	for(var/client/C in GLOB.clients)
		if(C.ckey == data.ckey)
			to_chat(C, "<span class='notice'><b>Achievement Unlocked: [achievement.name]</b><br>[achievement.description]</span>")
			break

/datum/dclass_persistence_manager/proc/save_round_data(datum/dclass_player/player)
	if(!player || !player.ckey)
		return

	var/datum/dclass_persistence_data/data = get_persistence_data(player.ckey)

	// Save current round statistics
	data.last_round_data = list(
		"round_start_time" = player.round_start_time,
		"escape_attempts" = player.escape_attempts,
		"successful_escapes" = player.successful_escapes,
		"contraband_found" = length(player.contraband),
		"work_assignments" = player.current_work_assignment,
		"alliances_formed" = length(player.allies),
		"players_betrayed" = length(player.reported_players),
		"final_level" = player.level,
		"final_experience" = player.experience,
		"survival_time" = world.time - player.round_start_time,
		"stealth_round" = player.stealth_round_completed,
		"escape_during_scp_event" = player.escaped_during_scp_event
	)

	// Update persistent statistics
	update_player_statistics(player, "escape_attempts", player.escape_attempts)
	update_player_statistics(player, "successful_escapes", player.successful_escapes)
	update_player_statistics(player, "contraband_found", length(player.contraband))
	update_player_statistics(player, "work_completed", 1)
	update_player_statistics(player, "alliances_formed", length(player.allies))
	update_player_statistics(player, "players_betrayed", length(player.reported_players))
	update_player_statistics(player, "level_achieved", player.level)
	update_player_statistics(player, "survival_time", world.time - player.round_start_time)

	data.round_count++

	// Save to database
	save_player_to_database(data)

/datum/dclass_persistence_manager/proc/save_player_to_database(datum/dclass_persistence_data/data)
	if(!SSdbcore.Connect())
		return

	// Save basic player data
	var/datum/db_query/query_save_player = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("dclass_players")]
		(ckey, name, round_count, total_playtime, total_escape_attempts, total_successful_escapes,
		total_contraband_found, total_work_completed, total_alliances_formed, total_players_betrayed,
		highest_level_achieved, longest_survival_time, most_valuable_contraband, favorite_escape_route,
		achievements, statistics, last_round_data, persistence_version, last_updated)
		VALUES (:ckey, :name, :round_count, :total_playtime, :total_escape_attempts, :total_successful_escapes,
		:total_contraband_found, :total_work_completed, :total_alliances_formed, :total_players_betrayed,
		:highest_level_achieved, :longest_survival_time, :most_valuable_contraband, :favorite_escape_route,
		:achievements, :statistics, :last_round_data, :persistence_version, NOW())
		ON DUPLICATE KEY UPDATE
		name = VALUES(name), round_count = VALUES(round_count), total_playtime = VALUES(total_playtime),
		total_escape_attempts = VALUES(total_escape_attempts), total_successful_escapes = VALUES(total_successful_escapes),
		total_contraband_found = VALUES(total_contraband_found), total_work_completed = VALUES(total_work_completed),
		total_alliances_formed = VALUES(total_alliances_formed), total_players_betrayed = VALUES(total_players_betrayed),
		highest_level_achieved = VALUES(highest_level_achieved), longest_survival_time = VALUES(longest_survival_time),
		most_valuable_contraband = VALUES(most_valuable_contraband), favorite_escape_route = VALUES(favorite_escape_route),
		achievements = VALUES(achievements), statistics = VALUES(statistics), last_round_data = VALUES(last_round_data),
		persistence_version = VALUES(persistence_version), last_updated = NOW()
	"}, list(
		"ckey" = data.ckey,
		"name" = data.name,
		"round_count" = data.round_count,
		"total_playtime" = data.total_playtime,
		"total_escape_attempts" = data.total_escape_attempts,
		"total_successful_escapes" = data.total_successful_escapes,
		"total_contraband_found" = data.total_contraband_found,
		"total_work_completed" = data.total_work_completed,
		"total_alliances_formed" = data.total_alliances_formed,
		"total_players_betrayed" = data.total_players_betrayed,
		"highest_level_achieved" = data.highest_level_achieved,
		"longest_survival_time" = data.longest_survival_time,
		"most_valuable_contraband" = data.most_valuable_contraband,
		"favorite_escape_route" = data.favorite_escape_route,
		"achievements" = json_encode(data.achievements),
		"statistics" = json_encode(data.statistics),
		"last_round_data" = json_encode(data.last_round_data),
		"persistence_version" = data.persistence_version
	))

	if(!query_save_player.warn_execute())
		qdel(query_save_player)
		return

	qdel(query_save_player)

	// Save individual achievements to database
	save_achievements_to_database(data)

/datum/dclass_persistence_manager/proc/save_achievements_to_database(datum/dclass_persistence_data/data)
	if(!SSdbcore.Connect())
		return

	var/list/achievement_rows = list()
	for(var/achievement_id in data.achievements)
		var/list/achievement_data = data.achievements[achievement_id]
		achievement_rows += list(list(
			"ckey" = data.ckey,
			"achievement_id" = achievement_id,
			"achievement_name" = achievement_data["name"],
			"achievement_description" = achievement_data["description"],
			"unlock_time" = achievement_data["unlock_time"],
			"unlocked_at" = SQLtime(achievement_data["unlock_time"])
		))

	if(length(achievement_rows) > 0)
		SSdbcore.MassInsert(format_table_name("dclass_achievements"), achievement_rows, duplicate_key = TRUE)

/datum/dclass_persistence_manager/proc/load_player_from_database(ckey)
	if(!SSdbcore.Connect())
		return null

	var/datum/db_query/query_load_player = SSdbcore.NewQuery(
		"SELECT * FROM [format_table_name("dclass_players")] WHERE ckey = :ckey",
		list("ckey" = ckey)
	)

	if(!query_load_player.warn_execute())
		qdel(query_load_player)
		return null

	var/datum/dclass_persistence_data/data = null
	if(query_load_player.NextRow())
		data = new /datum/dclass_persistence_data()
		data.ckey = ckey
		data.name = query_load_player.item[2] || "Unknown"
		data.round_count = text2num(query_load_player.item[3]) || 0
		data.total_playtime = text2num(query_load_player.item[4]) || 0
		data.total_escape_attempts = text2num(query_load_player.item[5]) || 0
		data.total_successful_escapes = text2num(query_load_player.item[6]) || 0
		data.total_contraband_found = text2num(query_load_player.item[7]) || 0
		data.total_work_completed = text2num(query_load_player.item[8]) || 0
		data.total_alliances_formed = text2num(query_load_player.item[9]) || 0
		data.total_players_betrayed = text2num(query_load_player.item[10]) || 0
		data.highest_level_achieved = text2num(query_load_player.item[11]) || 1
		data.longest_survival_time = text2num(query_load_player.item[12]) || 0
		data.most_valuable_contraband = query_load_player.item[13] || ""
		data.favorite_escape_route = query_load_player.item[14] || ""

		// Parse JSON fields
		try
			data.achievements = json_decode(query_load_player.item[15]) || list()
			data.statistics = json_decode(query_load_player.item[16]) || list()
			data.last_round_data = json_decode(query_load_player.item[17]) || list()
		catch(var/exception)
			// Log the exception details for debugging
			log_world("DClass Persistence: Exception during data loading: [exception]")
			// Note: Exception object properties may not be available in all contexts

			// Set default values on error
			data.achievements = list()
			data.statistics = list()
			data.last_round_data = list()

		data.persistence_version = text2num(query_load_player.item[18]) || 1

	qdel(query_load_player)
	return data

/datum/dclass_persistence_manager/proc/save_persistence_data()
	// Save to both file and database
	save_persistence_to_file()
	save_persistence_to_database()

/datum/dclass_persistence_manager/proc/save_persistence_to_file()
	var/list/save_data = list()

	for(var/ckey in persistent_data)
		var/datum/dclass_persistence_data/data = persistent_data[ckey]
		save_data[ckey] = list(
			"name" = data.name,
			"round_count" = data.round_count,
			"total_playtime" = data.total_playtime,
			"total_escape_attempts" = data.total_escape_attempts,
			"total_successful_escapes" = data.total_successful_escapes,
			"total_contraband_found" = data.total_contraband_found,
			"total_work_completed" = data.total_work_completed,
			"total_alliances_formed" = data.total_alliances_formed,
			"total_players_betrayed" = data.total_players_betrayed,
			"highest_level_achieved" = data.highest_level_achieved,
			"longest_survival_time" = data.longest_survival_time,
			"most_valuable_contraband" = data.most_valuable_contraband,
			"favorite_escape_route" = data.favorite_escape_route,
			"achievements" = data.achievements,
			"statistics" = data.statistics,
			"last_round_data" = data.last_round_data,
			"persistence_version" = data.persistence_version
		)

	// Create backup first
	if(fexists(persistence_file))
		fcopy(persistence_file, backup_file)

	// Save new data
	fdel(persistence_file)
	text2file(json_encode(save_data), persistence_file)
	last_save_time = world.time

/datum/dclass_persistence_manager/proc/save_persistence_to_database()
	if(!SSdbcore.Connect())
		return

	// Save all players to database
	for(var/ckey in persistent_data)
		var/datum/dclass_persistence_data/data = persistent_data[ckey]
		save_player_to_database(data)

/datum/dclass_persistence_manager/proc/load_persistence_data()
	// Try to load from database first, fall back to file
	load_persistence_from_database()

	// If database loading failed or was incomplete, load from file
	if(length(persistent_data) == 0)
		load_persistence_from_file()

/datum/dclass_persistence_manager/proc/load_persistence_from_database()
	if(!SSdbcore.Connect())
		return

	// Load all players from database
	var/datum/db_query/query_load_all = SSdbcore.NewQuery(
		"SELECT ckey FROM [format_table_name("dclass_players")]"
	)

	if(!query_load_all.warn_execute())
		qdel(query_load_all)
		return

	while(query_load_all.NextRow())
		var/ckey = query_load_all.item[1]
		var/datum/dclass_persistence_data/data = load_player_from_database(ckey)
		if(data)
			persistent_data[ckey] = data

	qdel(query_load_all)

	// Restore achievement states per-player from persistent data
	// (unlock state is tracked in pdata.achievements, not on the global template)

/datum/dclass_persistence_manager/proc/load_persistence_from_file()
	if(!fexists(persistence_file))
		return

	var/json_data = file2text(persistence_file)
	var/list/loaded_data = json_decode(json_data)
	if(!loaded_data)
		return

	for(var/ckey in loaded_data)
		var/list/player_data = loaded_data[ckey]
		var/datum/dclass_persistence_data/data = new /datum/dclass_persistence_data()

		data.ckey = ckey
		data.name = player_data["name"] || "Unknown"
		data.round_count = player_data["round_count"] || 0
		data.total_playtime = player_data["total_playtime"] || 0
		data.total_escape_attempts = player_data["total_escape_attempts"] || 0
		data.total_successful_escapes = player_data["total_successful_escapes"] || 0
		data.total_contraband_found = player_data["total_contraband_found"] || 0
		data.total_work_completed = player_data["total_work_completed"] || 0
		data.total_alliances_formed = player_data["total_alliances_formed"] || 0
		data.total_players_betrayed = player_data["total_players_betrayed"] || 0
		data.highest_level_achieved = player_data["highest_level_achieved"] || 1
		data.longest_survival_time = player_data["longest_survival_time"] || 0
		data.most_valuable_contraband = player_data["most_valuable_contraband"] || ""
		data.favorite_escape_route = player_data["favorite_escape_route"] || ""
		data.achievements = player_data["achievements"] || list()
		data.statistics = player_data["statistics"] || list()
		data.last_round_data = player_data["last_round_data"] || list()
		data.persistence_version = player_data["persistence_version"] || 1

		persistent_data[ckey] = data

		// Achievement unlock state is tracked per-player in data.achievements

/datum/dclass_persistence_manager/proc/get_player_leaderboard()
	var/list/leaderboard = list()

	for(var/ckey in persistent_data)
		var/datum/dclass_persistence_data/data = persistent_data[ckey]
		leaderboard += list(list(
			"ckey" = ckey,
			"name" = data.name,
			"successful_escapes" = data.total_successful_escapes,
			"highest_level" = data.highest_level_achieved,
			"contraband_found" = data.total_contraband_found,
			"achievements" = length(data.achievements)
		))

	// Sort by successful escapes (descending) - manual sorting
	for(var/i = 1; i <= length(leaderboard); i++)
		for(var/j = i + 1; j <= length(leaderboard); j++)
			if(leaderboard[i]["successful_escapes"] < leaderboard[j]["successful_escapes"])
				var/list/temp = leaderboard[i]
				leaderboard[i] = leaderboard[j]
				leaderboard[j] = temp
	return leaderboard

// Integration with SCP Persistence
/datum/dclass_persistence_manager/proc/integrate_with_scp_persistence(datum/dclass_player/player)
	if(!player || !player.ckey || !SSscp_persistence || !SSscp_persistence.manager)
		return

	// Get SCP persistence data for this player
	var/datum/player_performance/scp_performance = SSscp_persistence.manager.get_player_performance(player.ckey)
	if(!scp_performance)
		return

	var/datum/dclass_persistence_data/data = get_persistence_data(player.ckey)

	// Integrate SCP performance data
	data.statistics["scp_rounds_played"] = scp_performance.rounds_played || 0
	data.statistics["scp_achievements"] = length(scp_performance.achievements)
	data.statistics["scp_violations"] = length(scp_performance.violations)
	data.statistics["scp_access_level"] = scp_performance.access_level

	// Check for SCP-related achievements
	if(scp_performance.access_level >= 3)
		update_player_statistics(player, "scp_access_level", scp_performance.access_level)

/datum/dclass_player/proc/process_player_with_persistence()
	// Regular processing
	process_player()

	// Update round statistics
	if(mob)
		current_round_stats["current_time"] = world.time
		current_round_stats["survival_time"] = world.time - round_start_time

	// Check for stealth round completion
	if(is_hiding && !stealth_round_completed)
		current_round_stats["stealth_time"] += 6 // 6 seconds per process cycle
		if(current_round_stats["stealth_time"] >= 1800) // 30 minutes
			stealth_round_completed = TRUE

	// Auto-save persistence data
	if(SSdclass && SSdclass.manager && SSdclass.manager.persistence_manager)
		if(world.time > SSdclass.manager.persistence_manager.last_save_time + SSdclass.manager.persistence_manager.auto_save_interval)
			SSdclass.manager.persistence_manager.save_persistence_data()

/datum/dclass_player/proc/save_data_with_persistence()
	// Save regular data
	save_data()

	// Save to enhanced persistence system
	if(SSdclass && SSdclass.manager && SSdclass.manager.persistence_manager)
		SSdclass.manager.persistence_manager.save_round_data(src)
		SSdclass.manager.persistence_manager.integrate_with_scp_persistence(src)

// Note: process_dclass() is defined in dclass_system.dm and includes persistence features
