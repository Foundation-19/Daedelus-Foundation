/datum/scp_progression_ui
	var/mob/living/carbon/human/user

/datum/scp_progression_ui/New(mob/living/carbon/human/target_user)
	user = target_user

/datum/scp_progression_ui/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SCPProgression", "SCP Progression", 1200, 800)
		ui.open()

/datum/scp_progression_ui/ui_state(mob/user)
	return GLOB.always_state

/datum/scp_progression_ui/ui_data(mob/user)
	var/list/data = list()

	if(!SSscp_progression_integration || !SSscp_progression_integration.manager)
		data["has_data"] = FALSE
		return data

	var/datum/scp_progression_manager/manager = SSscp_progression_integration.manager
	data["has_data"] = TRUE
	data["player_name"] = user.name
	data["player_key"] = user.key
	data["current_scp"] = user.SCP ? user.SCP.designation : "None"

	var/list/progression_data = list()
	var/list/available_scps = list()

	var/static/list/scp_ids = list("049", "096", "173", "457", "939", "2020")

	for(var/scp_id in scp_ids)
		var/datum/scp_progression_data/prog_data = manager.get_scp_progression_data(scp_id, user.ckey)
		if(prog_data)
			progression_data[scp_id] = list(
				"rounds_played" = prog_data.rounds_played,
				"total_experience" = prog_data.total_experience,
				"achievements" = prog_data.achievements,
				"metrics" = prog_data.metrics,
				"last_update" = prog_data.last_update,
			)

		available_scps += list(list(
			"scp_id" = scp_id,
			"scp_name" = "SCP-[scp_id]",
		))

	data["scp_progression_data"] = progression_data
	data["available_scps"] = available_scps

	var/list/achievements = list()
	var/static/list/achievement_definitions = list(
		"scp049_first_cure" = list("name" = "First Cure", "description" = "Perform your first cure as SCP-049"),
		"scp049_master_healer" = list("name" = "Master Healer", "description" = "Perform 10 cures as SCP-049"),
		"scp096_first_rage" = list("name" = "First Rage", "description" = "Activate your first rage as SCP-096"),
		"scp096_efficient_hunter" = list("name" = "Efficient Hunter", "description" = "Hunt 15 victims as SCP-096"),
		"scp173_first_movement" = list("name" = "First Movement", "description" = "Make your first successful movement as SCP-173"),
		"scp173_silent_killer" = list("name" = "Silent Killer", "description" = "Kill 20 victims as SCP-173"),
		"scp457_first_fire" = list("name" = "First Fire", "description" = "Create your first fire as SCP-457"),
		"scp457_consuming_flame" = list("name" = "Consuming Flame", "description" = "Consume 10 victims as SCP-457"),
		"scp939_first_voice" = list("name" = "First Voice", "description" = "Learn your first voice as SCP-939"),
		"scp939_voice_master" = list("name" = "Voice Master", "description" = "Learn 20 voices as SCP-939"),
		"scp2020_first_teleport" = list("name" = "First Teleport", "description" = "Perform your first teleport as SCP-2020"),
		"scp2020_stealth_operative" = list("name" = "Stealth Operative", "description" = "Perform 30 stealth actions as SCP-2020"),
	)

	for(var/achievement_id in achievement_definitions)
		var/list/ach_def = achievement_definitions[achievement_id]
		var/unlocked = FALSE
		for(var/scp_id in scp_ids)
			var/datum/scp_progression_data/prog_data = manager.get_scp_progression_data(scp_id, user.ckey)
			if(prog_data && (achievement_id in prog_data.achievements))
				unlocked = TRUE
				break
		achievements += list(list(
			"name" = ach_def["name"],
			"description" = ach_def["description"],
			"unlocked" = unlocked,
		))

	data["achievements"] = achievements

	var/list/recent_events = list()
	if(length(manager.scp_interaction_logs) > 0)
		var/count = 0
		for(var/i = length(manager.scp_interaction_logs); i > 0 && count < 10; i--)
			var/list/log_entry = manager.scp_interaction_logs[i]
			if(log_entry)
				recent_events += list(log_entry)
				count++
	data["recent_events"] = recent_events

	data["global_scp_stats"] = list(
		"total_scp_rounds_played" = manager.total_scp_rounds_played,
		"total_scp_achievements_unlocked" = manager.total_scp_achievements_unlocked,
		"average_scp_performance" = manager.average_scp_performance,
		"total_scp_research_points" = manager.total_scp_research_points,
		"scp_containment_breaches" = manager.scp_containment_breaches,
		"scp_research_breakthroughs" = manager.scp_research_breakthroughs,
	)

	return data

/datum/scp_progression_ui/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("export_scp_data")
			var/data_json = json_encode(list("ckey" = user.ckey, "scp_data" = "export"))
			user << browse(data_json, "window=scp_progression_data;size=600x400;can_close=1;can_resize=1")
			to_chat(user, span_notice("SCP progression data exported."))
			. = TRUE

		if("refresh_scp_data")
			to_chat(user, span_notice("SCP progression data refreshed."))
			. = TRUE

		if("save_scp_data")
			if(SSscp_progression_integration && SSscp_progression_integration.manager)
				SSscp_progression_integration.manager.save_scp_progression_data()
				to_chat(user, span_notice("SCP progression data saved."))
			. = TRUE

		if("load_scp_data")
			to_chat(user, span_notice("SCP progression data reloaded."))
			. = TRUE
