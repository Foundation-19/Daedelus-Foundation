SUBSYSTEM_DEF(persistent_progression)
	name = "Persistent Progression"
	priority = FIRE_PRIORITY_PERSISTENT_PROGRESSION
	init_order = INIT_ORDER_PERSISTENCE_PROGRESSION
	wait = 600

	var/list/player_data = list()
	var/list/classes = list()
	var/list/factions = list()
	var/list/experience_sources = list()
	var/list/active_trackers = list()
	var/save_file_path = "data/persistent_progression/"
	var/round_start_time
	var/datum/achievement_manager/achievement_manager
	var/datum/reward_manager/reward_manager
	var/datum/player_analytics_manager/analytics_manager
	var/datum/achievement_integration/achievement_integration
	var/datum/job_integration/job_integration
	var/datum/faction_integration/faction_integration
	var/datum/persistent_progression_database_adapter/database_adapter
	var/use_database = TRUE

/datum/controller/subsystem/persistent_progression/Initialize()
	log_game("Persistent Progression Subsystem: Initializing...")

	load_all_classes()
	load_all_factions()
	load_all_experience_sources()
	achievement_manager = new /datum/achievement_manager()
	reward_manager = new /datum/reward_manager()
	analytics_manager = new /datum/player_analytics_manager()
	achievement_integration = new /datum/achievement_integration()
	job_integration = new /datum/job_integration()
	initialize_faction_integration()

	if(use_database)
		database_adapter = new /datum/persistent_progression_database_adapter()
		log_game("Persistent Progression: Database adapter initialized")
	else
		log_game("Persistent Progression: Using JSON storage (database disabled)")
	round_start_time = world.time

	SSticker.OnRoundend(CALLBACK(src, PROC_REF(process_round_end)))

	log_game("Persistent Progression Subsystem: Initialized successfully with [length(classes)] classes, [length(factions)] factions, [length(experience_sources)] experience sources")

	return ..()

/datum/controller/subsystem/persistent_progression/proc/initialize_faction_integration()
	if(!faction_integration)
		faction_integration = new /datum/faction_integration()
		GLOB.faction_integration = faction_integration
		log_game("Persistent Progression: Faction integration initialized")

/datum/controller/subsystem/persistent_progression/proc/get_total_experience()
	var/total_exp = 0
	for(var/ckey in player_data)
		var/datum/persistent_player_data/player = player_data[ckey]
		if(player)
			total_exp += player.total_experience
	return total_exp

/datum/controller/subsystem/persistent_progression/proc/get_total_achievements()
	var/total_achievements = 0
	for(var/ckey in player_data)
		var/datum/persistent_player_data/player = player_data[ckey]
		if(player)
			total_achievements += length(player.achievements)
	return total_achievements

/datum/controller/subsystem/persistent_progression/proc/get_scp_progression_count()
	if(SSscp_progression_integration && SSscp_progression_integration.manager)
		return length(SSscp_progression_integration.manager.scp_progression_data)
	return 0

/datum/controller/subsystem/persistent_progression/proc/export_all_data()
	var/list/export_data = list()
	export_data["timestamp"] = world.time
	export_data["total_players"] = length(player_data)
	export_data["total_experience"] = get_total_experience()
	export_data["total_achievements"] = get_total_achievements()
	export_data["scp_progression_count"] = get_scp_progression_count()

	export_data["players"] = list()
	for(var/ckey in player_data)
		var/datum/persistent_player_data/player = player_data[ckey]
		if(player)
			export_data["players"][ckey] = player.export_to_json()

	export_data["classes"] = list()
	for(var/class_id in classes)
		var/datum/persistent_class/class = classes[class_id]
		if(class)
			export_data["classes"][class_id] = class.export_to_json()

	export_data["factions"] = list()
	for(var/faction_id in factions)
		var/datum/persistent_faction/faction = factions[faction_id]
		if(faction)
			export_data["factions"][faction_id] = faction.export_to_json()

	return json_encode(export_data)

/datum/controller/subsystem/persistent_progression/proc/reset_all_data()
	log_game("Persistent Progression: Resetting all data...")

	for(var/ckey in player_data)
		var/datum/persistent_player_data/player = player_data[ckey]
		if(player)
			player.initialize_default_data()

	for(var/ckey in player_data)
		save_player_data(ckey)

	log_game("Persistent Progression: All data reset successfully")

/datum/controller/subsystem/persistent_progression/proc/save_all_data()
	for(var/ckey in player_data)
		save_player_data(ckey)
	log_game("Persistent Progression: All player data saved")

/datum/controller/subsystem/persistent_progression/proc/load_all_data()
	player_data.Cut()
	log_game("Persistent Progression: All player data reloaded on next access")

/datum/controller/subsystem/persistent_progression/proc/load_all_classes()
	log_game("Persistent Progression: Loading classes...")
	classes["security"] = new /datum/persistent_class/security()
	classes["research"] = new /datum/persistent_class/research()
	classes["medical"] = new /datum/persistent_class/medical()
	classes["engineering"] = new /datum/persistent_class/engineering()
	classes["administrative"] = new /datum/persistent_class/administrative()
	classes["containment"] = new /datum/persistent_class/containment()
	log_game("Persistent Progression: Loaded [length(classes)] classes")

/datum/controller/subsystem/persistent_progression/proc/load_all_factions()
	log_game("Persistent Progression: Loading factions...")
	factions["foundation"] = new /datum/persistent_faction/foundation()
	factions["goc"] = new /datum/persistent_faction/goc()
	factions["serpents_hand"] = new /datum/persistent_faction/serpents_hand()
	factions["chaos_insurgency"] = new /datum/persistent_faction/chaos_insurgency()
	factions["mcd"] = new /datum/persistent_faction/mcd()
	factions["uiu"] = new /datum/persistent_faction/uiu()
	log_game("Persistent Progression: Loaded [length(factions)] factions")

/datum/controller/subsystem/persistent_progression/proc/load_all_experience_sources()
	var/list/all_sources = get_all_experience_sources()
	for(var/source_id in all_sources)
		experience_sources[source_id] = all_sources[source_id]
	log_game("Persistent Progression: Loaded [length(experience_sources)] experience sources")

/datum/controller/subsystem/persistent_progression/proc/get_player_data(ckey)
	if(!ckey)
		return null

	if(use_database && database_adapter)
		var/datum/persistent_player_data/db_data = database_adapter.get_player_data(ckey)
		if(db_data)
			player_data[ckey] = db_data
			return db_data

		var/player_name = "Unknown"
		for(var/client/C in GLOB.clients)
			if(C.ckey == ckey)
				player_name = C.prefs ? C.prefs.read_preference(/datum/preference/name/real_name) : "Unknown"
				break
		database_adapter.create_player_data(ckey, player_name)

		db_data = database_adapter.get_player_data(ckey)
		if(db_data)
			player_data[ckey] = db_data
			return db_data

	if(!player_data[ckey])
		player_data[ckey] = load_player_data(ckey)
		if(!player_data[ckey])
			player_data[ckey] = new /datum/persistent_player_data(ckey)

	return player_data[ckey]

/datum/controller/subsystem/persistent_progression/proc/get_class(class_id)
	return classes[class_id]

/datum/controller/subsystem/persistent_progression/proc/get_faction(faction_id) as /datum/persistent_faction
	return factions[faction_id]

/datum/controller/subsystem/persistent_progression/proc/get_experience_source(source_id)
	return experience_sources[source_id]

/datum/controller/subsystem/persistent_progression/proc/save_player_data(ckey)
	var/datum/persistent_player_data/data = player_data[ckey]
	if(!data)
		return

	if(use_database && database_adapter)
		database_adapter.save_player_data(ckey, data)
		return

	var/list/save_data = list(
		"ckey" = ckey,
		"class_data" = data.class_data,
		"rank_data" = data.rank_data,
		"faction_data" = data.faction_data,
		"unlocked_items" = data.unlocked_items,
		"unlocked_titles" = data.unlocked_titles,
		"unlocked_cosmetics" = data.unlocked_cosmetics,
		"achievements" = data.achievements,
		"achievement_progress" = data.achievement_progress,
		"achievement_points" = data.achievement_points,
		"total_achievements_unlocked" = data.total_achievements_unlocked,
		"total_experience" = data.total_experience,
		"rounds_played" = data.rounds_played,
		"rounds_survived" = data.rounds_survived,
		"rounds_died" = data.rounds_died,
		"last_login" = world.time,
		"preferred_class" = data.preferred_class,
		"preferred_faction" = data.preferred_faction,
		"current_class_id" = data.current_class_id,
		"current_faction_id" = data.current_faction_id,
		"current_rank" = data.current_rank,
		"current_rank_name" = data.current_rank_name,
		"experience_sources" = data.experience_sources,
		"performance_metrics" = data.performance_metrics,
		"currency" = data.currency,
		"settings" = data.settings,
		"total_playtime" = data.total_playtime,
		"first_login" = data.first_login,
		"current_streak" = data.current_streak,
		"longest_streak" = data.longest_streak,
		"reputation_score" = data.reputation_score,
		"total_kills" = data.total_kills,
		"total_deaths" = data.total_deaths,
		"total_healing" = data.total_healing,
		"total_damage_dealt" = data.total_damage_dealt,
		"total_objectives" = data.total_objectives,
		"total_scp_interactions" = data.total_scp_interactions,
		"total_containment_breaches" = data.total_containment_breaches,
		"total_recontainments" = data.total_recontainments,
		"total_research_completed" = data.total_research_completed,
		"total_treatments" = data.total_treatments,
		"total_constructions" = data.total_constructions,
		"total_repairs" = data.total_repairs,
		"total_arrests" = data.total_arrests,
		"current_job" = data.current_job,
		"skill_boost_multiplier" = data.skill_boost_multiplier,
		"job_rounds_played" = data.job_rounds_played,
		"job_experience" = data.job_experience,
		"job_achievements" = data.job_achievements,
		"job_performance" = data.job_performance,
		"job_specializations" = data.job_specializations,
		"job_promotions" = data.job_promotions,
		"job_incidents" = data.job_incidents,
		"job_commendations" = data.job_commendations,
		"job_disciplinary_actions" = data.job_disciplinary_actions,
		"job_training_completed" = data.job_training_completed,
		"job_certifications" = data.job_certifications,
		"job_mentoring_sessions" = data.job_mentoring_sessions,
		"job_research_papers" = data.job_research_papers,
		"job_containment_breaches" = data.job_containment_breaches,
		"job_scp_interactions" = data.job_scp_interactions,
		"job_medical_procedures" = data.job_medical_procedures,
		"job_engineering_projects" = data.job_engineering_projects,
		"job_security_operations" = data.job_security_operations,
		"job_supply_management" = data.job_supply_management,
		"job_service_contributions" = data.job_service_contributions,
		"job_dclass_testing" = data.job_dclass_testing,
		"data_version" = data.data_version
	)

	var/json_data = json_encode(save_data)
	rustg_file_write(json_data, "[save_file_path][ckey].json")

/datum/controller/subsystem/persistent_progression/proc/load_player_data(ckey)
	var/file_path = "[save_file_path][ckey].json"
	if(!fexists(file_path))
		return null

	var/json_data = rustg_file_read(file_path)
	if(!json_data)
		return null

	var/list/load_data = json_decode(json_data)
	if(!load_data)
		return null

	var/datum/persistent_player_data/data = new /datum/persistent_player_data(ckey)
	data.class_data = load_data["class_data"] || list()
	data.rank_data = load_data["rank_data"] || list()
	data.faction_data = load_data["faction_data"] || list()
	data.unlocked_items = load_data["unlocked_items"] || list()
	data.unlocked_titles = load_data["unlocked_titles"] || list()
	data.unlocked_cosmetics = load_data["unlocked_cosmetics"] || list()
	data.achievements = load_data["achievements"] || list()
	data.achievement_progress = load_data["achievement_progress"] || list()
	data.achievement_points = load_data["achievement_points"] || 0
	data.total_achievements_unlocked = load_data["total_achievements_unlocked"] || 0
	data.total_experience = load_data["total_experience"] || 0
	data.rounds_played = load_data["rounds_played"] || 0
	data.rounds_survived = load_data["rounds_survived"] || 0
	data.rounds_died = load_data["rounds_died"] || 0
	data.last_login = load_data["last_login"] || world.time
	data.preferred_class = load_data["preferred_class"] || "security"
	data.preferred_faction = load_data["preferred_faction"] || "foundation"
	data.current_class_id = load_data["current_class_id"] || "security"
	data.current_faction_id = load_data["current_faction_id"] || "foundation"
	data.current_rank = load_data["current_rank"] || 0
	data.current_rank_name = load_data["current_rank_name"] || "Recruit"
	data.experience_sources = load_data["experience_sources"] || list()
	data.performance_metrics = load_data["performance_metrics"] || list()
	data.currency = load_data["currency"] || list()
	data.settings = load_data["settings"] || list()
	data.total_playtime = load_data["total_playtime"] || 0
	data.first_login = load_data["first_login"] || world.time
	data.current_streak = load_data["current_streak"] || 0
	data.longest_streak = load_data["longest_streak"] || 0
	data.reputation_score = load_data["reputation_score"] || 0
	data.total_kills = load_data["total_kills"] || 0
	data.total_deaths = load_data["total_deaths"] || 0
	data.total_healing = load_data["total_healing"] || 0
	data.total_damage_dealt = load_data["total_damage_dealt"] || 0
	data.total_objectives = load_data["total_objectives"] || 0
	data.total_scp_interactions = load_data["total_scp_interactions"] || 0
	data.total_containment_breaches = load_data["total_containment_breaches"] || 0
	data.total_recontainments = load_data["total_recontainments"] || 0
	data.total_research_completed = load_data["total_research_completed"] || 0
	data.total_treatments = load_data["total_treatments"] || 0
	data.total_constructions = load_data["total_constructions"] || 0
	data.total_repairs = load_data["total_repairs"] || 0
	data.total_arrests = load_data["total_arrests"] || 0
	data.current_job = load_data["current_job"] || ""
	data.skill_boost_multiplier = load_data["skill_boost_multiplier"] || 1.0
	data.job_rounds_played = load_data["job_rounds_played"] || list()
	data.job_experience = load_data["job_experience"] || list()
	data.job_achievements = load_data["job_achievements"] || list()
	data.job_performance = load_data["job_performance"] || list()
	data.job_specializations = load_data["job_specializations"] || list()
	data.job_promotions = load_data["job_promotions"] || list()
	data.job_incidents = load_data["job_incidents"] || list()
	data.job_commendations = load_data["job_commendations"] || list()
	data.job_disciplinary_actions = load_data["job_disciplinary_actions"] || list()
	data.job_training_completed = load_data["job_training_completed"] || list()
	data.job_certifications = load_data["job_certifications"] || list()
	data.job_mentoring_sessions = load_data["job_mentoring_sessions"] || list()
	data.job_research_papers = load_data["job_research_papers"] || list()
	data.job_containment_breaches = load_data["job_containment_breaches"] || list()
	data.job_scp_interactions = load_data["job_scp_interactions"] || list()
	data.job_medical_procedures = load_data["job_medical_procedures"] || list()
	data.job_engineering_projects = load_data["job_engineering_projects"] || list()
	data.job_security_operations = load_data["job_security_operations"] || list()
	data.job_supply_management = load_data["job_supply_management"] || list()
	data.job_service_contributions = load_data["job_service_contributions"] || list()
	data.job_dclass_testing = load_data["job_dclass_testing"] || list()
	data.data_version = load_data["data_version"] || 1

	return data

/datum/controller/subsystem/persistent_progression/proc/award_experience(ckey, source_id, amount, reason)
	var/datum/persistent_player_data/data = get_player_data(ckey)
	if(!data)
		return 0

	var/datum/experience_source/source = get_experience_source(source_id)
	if(!source)
		return 0

	if(!(data.current_class_id in source.compatible_classes))
		return 0

	var/current_time = world.time
	var/source_count = 0
	for(var/list/source_data in data.experience_sources)
		if(source_data["source"] == source_id)
			source_count++
			if(source.cooldown_time > 0)
				var/time_diff = current_time - source_data["timestamp"]
				if(time_diff < source.cooldown_time)
					return 0

	if(source_count >= source.max_per_round)
		return 0

	var/final_amount = amount > 0 ? amount : source.base_experience
	var/awarded = data.add_experience(final_amount, source_id, reason)

	if(analytics_manager)
		analytics_manager.track_event(ckey, "experience_earned", list("source" = source_id, "amount" = awarded))

	save_player_data(ckey)

	return awarded

/datum/controller/subsystem/persistent_progression/proc/process_round_end()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.mind && H.ckey)
			var/datum/persistent_player_data/data = get_player_data(H.ckey)
			if(data)
				var/survived = (H.stat != DEAD)
				data.end_round(survived)
				award_experience(H.ckey, "round_survival", 200, "Round Completion Bonus")

				if(survived)
					var/faction_key = "[data.current_faction_id]_rounds"
					var/current_faction_rounds = data.get_performance_metric(faction_key)
					data.update_performance_metric(faction_key, current_faction_rounds + 1)

				if(data.current_job)
					data.increment_job_rounds(data.current_job)

				if(use_database && database_adapter)
					database_adapter.end_round(H.ckey, "[GLOB.round_id]", survived, data.total_experience, length(data.achievements))
					if(data.current_job)
						database_adapter.update_job_stats(H.ckey, data.current_job, survived, data.total_experience, length(data.achievements))

				save_player_data(H.ckey)

	if(use_database && database_adapter)
		for(var/ckey in player_data)
			database_adapter.record_metric(ckey, "round_end", world.time)

	if(analytics_manager)
		analytics_manager.track_event(null, "round_end", list("survivors" = 0))

/datum/controller/subsystem/persistent_progression/fire()
	for(var/ckey in active_trackers)
		var/datum/persistent_player_data/data = player_data[ckey]
		if(data)
			data.total_playtime += wait
	return

/datum/controller/subsystem/persistent_progression/proc/add_experience_to_database(ckey, source, amount, reason)
	if(!use_database || !database_adapter)
		return FALSE
	return database_adapter.add_experience(ckey, source, amount, reason)

/datum/controller/subsystem/persistent_progression/proc/unlock_achievement_in_database(ckey, achievement_id, progress = 0)
	if(!use_database || !database_adapter)
		return FALSE
	return database_adapter.unlock_achievement(ckey, achievement_id, progress)

/datum/controller/subsystem/persistent_progression/proc/has_achievement_in_database(ckey, achievement_id)
	if(!use_database || !database_adapter)
		return FALSE
	return database_adapter.has_achievement(ckey, achievement_id)

/datum/controller/subsystem/persistent_progression/proc/unlock_item_in_database(ckey, item_id)
	if(!use_database || !database_adapter)
		return FALSE
	return database_adapter.unlock_item(ckey, item_id)

/datum/controller/subsystem/persistent_progression/proc/unlock_title_in_database(ckey, title_id)
	if(!use_database || !database_adapter)
		return FALSE
	return database_adapter.unlock_title(ckey, title_id)

/datum/controller/subsystem/persistent_progression/proc/start_round_in_database(ckey, round_id, job_title, faction_id)
	if(!use_database || !database_adapter)
		return FALSE
	return database_adapter.start_round(ckey, round_id, job_title, faction_id)

/datum/controller/subsystem/persistent_progression/proc/end_round_in_database(ckey, round_id, survived, experience_gained, achievements_unlocked)
	if(!use_database || !database_adapter)
		return FALSE
	return database_adapter.end_round(ckey, round_id, survived, experience_gained, achievements_unlocked)

/datum/controller/subsystem/persistent_progression/proc/update_job_stats_in_database(ckey, job_title, survived, experience_gained, achievements_unlocked)
	if(!use_database || !database_adapter)
		return FALSE
	return database_adapter.update_job_stats(ckey, job_title, survived, experience_gained, achievements_unlocked)

/datum/controller/subsystem/persistent_progression/proc/record_metric_in_database(ckey, metric_name, metric_value)
	if(!use_database || !database_adapter)
		return FALSE
	return database_adapter.record_metric(ckey, metric_name, metric_value)

/datum/controller/subsystem/persistent_progression/proc/get_global_stats_from_database()
	if(!use_database || !database_adapter)
		return list()
	return database_adapter.get_global_stats()

/datum/controller/subsystem/persistent_progression/proc/get_faction_stats_from_database()
	if(!use_database || !database_adapter)
		return list()
	return database_adapter.get_faction_stats()

/datum/controller/subsystem/persistent_progression/proc/export_player_data_from_database(ckey)
	if(!use_database || !database_adapter)
		return null
	return database_adapter.export_player_data(ckey)

/datum/controller/subsystem/persistent_progression/proc/reset_player_data_in_database(ckey)
	if(!use_database || !database_adapter)
		return FALSE
	return database_adapter.reset_player_data(ckey)

/datum/controller/subsystem/persistent_progression/proc/get_database_status()
	if(!use_database || !database_adapter)
		return list("initialized" = FALSE, "healthy" = FALSE)
	return database_adapter.get_database_status()

/datum/controller/subsystem/persistent_progression/proc/migrate_from_json_to_database(ckey)
	if(!use_database || !database_adapter)
		return FALSE
	var/datum/persistent_player_data/json_data = load_player_data(ckey)
	if(!json_data)
		return FALSE
	return database_adapter.migrate_from_json(ckey, json_data)

/datum/controller/subsystem/persistent_progression/proc/cleanup_old_database_data(days_to_keep = 30)
	if(!use_database || !database_adapter)
		return
	database_adapter.cleanup_old_data(days_to_keep)
