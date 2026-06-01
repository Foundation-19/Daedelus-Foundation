// Integration layer between persistent progression achievements and SSachievements
// This allows our progression achievements to also unlock in the main achievement system

/datum/achievement_integration
	var/list/integration_map = list() // Maps our achievement IDs to SSachievements IDs
	var/list/reverse_map = list() // Maps SSachievements IDs to our achievement IDs

/datum/achievement_integration/New()
	initialize_integration_map()

/datum/achievement_integration/proc/initialize_integration_map()
	// Map our progression achievements to existing SSachievements where applicable
	integration_map["first_experience"] = "first_experience_progression"
	integration_map["exp_1000"] = "experience_milestone_1k"
	integration_map["exp_5000"] = "experience_milestone_5k"
	integration_map["exp_10000"] = "experience_milestone_10k"
	integration_map["exp_50000"] = "experience_milestone_50k"
	integration_map["exp_100000"] = "experience_milestone_100k"
	integration_map["rounds_10"] = "rounds_played_10"
	integration_map["rounds_100"] = "rounds_played_100"
	integration_map["survival_master"] = "survival_expert"
	integration_map["security_arrests"] = "security_arrests_50"
	integration_map["medical_saves"] = "medical_saves_50"
	integration_map["engineering_builds"] = "engineering_builds_50"
	integration_map["science_discoveries"] = "science_discoveries_50"
	integration_map["foundation_loyalty"] = "foundation_loyalty_50"
	integration_map["chaos_insurgency"] = "chaos_insurgency_50"
	integration_map["explorer"] = "map_explorer"
	integration_map["pacifist"] = "pacifist_round"
	integration_map["holiday_spirit"] = "holiday_participant"

	// Create reverse mapping
	for(var/our_id in integration_map)
		reverse_map[integration_map[our_id]] = our_id

/datum/achievement_integration/proc/unlock_progression_achievement(ckey, achievement_id)
	// Unlock in our system
	if(SSpersistent_progression.achievement_manager)
		var/datum/achievement/achievement = SSpersistent_progression.achievement_manager.get_achievement(achievement_id)
		if(achievement)
			// Check if this achievement maps to an SSachievements achievement
			var/ss_achievement_id = integration_map[achievement_id]
			if(ss_achievement_id && SSachievements.achievements_enabled)
				// Unlock in SSachievements system
				unlock_ss_achievement(ckey, ss_achievement_id, achievement.achievement_name)

/datum/achievement_integration/proc/unlock_ss_achievement(ckey, achievement_id, achievement_name)
	// Find the corresponding SSachievements achievement
	for(var/achievement_type in SSachievements.achievements)
		var/datum/award/achievement/achievement = SSachievements.achievements[achievement_type]
		if(achievement.database_id == achievement_id)
			// Unlock the achievement
			achievement.unlock(ckey)
			log_game("Achievement Integration: [ckey] unlocked SSachievements achievement: [achievement_name] ([achievement_id])")
			return TRUE
	return FALSE

/datum/achievement_integration/proc/sync_achievements(ckey)
	// Sync achievements between systems
	if(!SSachievements.achievements_enabled)
		return

	var/datum/persistent_player_data/player_data = SSpersistent_progression.get_player_data(ckey)
	if(!player_data)
		return

	// Check our achievements and unlock corresponding SSachievements
	for(var/achievement_id in player_data.achievements)
		var/ss_achievement_id = integration_map[achievement_id]
		if(ss_achievement_id)
			unlock_ss_achievement(ckey, ss_achievement_id, "Progression Achievement")

/datum/achievement_integration/proc/check_ss_achievement_unlock(ckey, achievement_id)
	// Check if an SSachievements achievement should unlock a progression achievement
	var/our_achievement_id = reverse_map[achievement_id]
	if(our_achievement_id)
		var/datum/persistent_player_data/player_data = SSpersistent_progression.get_player_data(ckey)
		if(player_data && !(our_achievement_id in player_data.achievements))
			// Unlock in our system
			player_data.unlock_achievement(our_achievement_id)
			log_game("Achievement Integration: [ckey] unlocked progression achievement: [our_achievement_id] via SSachievements")

// Hook into SSachievements unlock system
/datum/award/achievement/proc/unlock(key)
	if(!SSachievements.achievements_enabled)
		return
	if(!key || !database_id || !name)
		return

	// Check if this should trigger a progression achievement
	if(SSpersistent_progression.achievement_integration)
		SSpersistent_progression.achievement_integration.check_ss_achievement_unlock(key, database_id)

	// Original unlock logic
	var/old_value = load(key)
	if(old_value)
		return

	var/datum/db_query/Q = SSdbcore.NewQuery(
		"INSERT INTO [format_table_name("achievements")] (ckey, achievement_key, value) VALUES (:ckey, :achievement_key, :value)",
		list("ckey" = key, "achievement_key" = database_id, "value" = 1)
	)
	if(!Q.Execute(async = TRUE))
		qdel(Q)
		return
	qdel(Q)

	// Notify the user
	for(var/client/C in GLOB.clients)
		if(C.ckey == key)
			on_unlock(C.mob)
			break

// Create new SSachievements achievements that correspond to our progression system
/datum/award/achievement/progression/first_experience
	name = "First Steps"
	desc = "Gain your first experience point in the persistent progression system"
	database_id = "first_experience_progression"
	icon = "default"

/datum/award/achievement/progression/experience_milestone_1k
	name = "Experience Seeker"
	desc = "Accumulate 1,000 experience points"
	database_id = "experience_milestone_1k"
	icon = "default"

/datum/award/achievement/progression/experience_milestone_5k
	name = "Experience Collector"
	desc = "Accumulate 5,000 experience points"
	database_id = "experience_milestone_5k"
	icon = "default"

/datum/award/achievement/progression/experience_milestone_10k
	name = "Experience Veteran"
	desc = "Accumulate 10,000 experience points"
	database_id = "experience_milestone_10k"
	icon = "default"

/datum/award/achievement/progression/experience_milestone_50k
	name = "Experience Master"
	desc = "Accumulate 50,000 experience points"
	database_id = "experience_milestone_50k"
	icon = "default"

/datum/award/achievement/progression/experience_milestone_100k
	name = "Experience Legend"
	desc = "Accumulate 100,000 experience points"
	database_id = "experience_milestone_100k"
	icon = "default"

/datum/award/achievement/progression/rounds_played_10
	name = "Dedicated Player"
	desc = "Play 10 rounds"
	database_id = "rounds_played_10"
	icon = "default"

/datum/award/achievement/progression/rounds_played_100
	name = "Veteran Player"
	desc = "Play 100 rounds"
	database_id = "rounds_played_100"
	icon = "default"

/datum/award/achievement/progression/survival_expert
	name = "Survival Expert"
	desc = "Maintain an 80% survival rate over 50 rounds"
	database_id = "survival_expert"
	icon = "default"

/datum/award/achievement/progression/security_arrests_50
	name = "Law Enforcer"
	desc = "Make 50 arrests as Security"
	database_id = "security_arrests_50"
	icon = "default"

/datum/award/achievement/progression/medical_saves_50
	name = "Life Saver"
	desc = "Save 50 lives as Medical"
	database_id = "medical_saves_50"
	icon = "default"

/datum/award/achievement/progression/engineering_builds_50
	name = "Master Builder"
	desc = "Complete 50 engineering projects"
	database_id = "engineering_builds_50"
	icon = "default"

/datum/award/achievement/progression/science_discoveries_50
	name = "Research Pioneer"
	desc = "Make 50 scientific discoveries"
	database_id = "science_discoveries_50"
	icon = "default"

/datum/award/achievement/progression/foundation_loyalty_50
	name = "Foundation Loyalist"
	desc = "Serve the Foundation for 50 rounds"
	database_id = "foundation_loyalty_50"
	icon = "default"

/datum/award/achievement/progression/chaos_insurgency_50
	name = "Chaos Operative"
	desc = "Serve the Chaos Insurgency for 50 rounds"
	database_id = "chaos_insurgency_50"
	icon = "default"

/datum/award/achievement/progression/map_explorer
	name = "Map Explorer"
	desc = "Explore 90% of the map in a single round"
	database_id = "map_explorer"
	icon = "default"

/datum/award/achievement/progression/pacifist_round
	name = "Pacifist"
	desc = "Complete a round without dealing any damage"
	database_id = "pacifist_round"
	icon = "default"

/datum/award/achievement/progression/holiday_participant
	name = "Holiday Spirit"
	desc = "Participate in a holiday event"
	database_id = "holiday_participant"
	icon = "default"
