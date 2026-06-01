// Skill Progression TGUI Interface
// Backend for the skill progression TGUI system

/datum/skill_progression_ui
	var/mob/living/carbon/human/user
	var/datum/mind/user_mind

/datum/skill_progression_ui/New(mob/living/carbon/human/target_user)
	user = target_user
	user_mind = user.mind

/datum/skill_progression_ui/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	if(!user.client)
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SkillProgression", "Skill Progression")
		ui.open()

/datum/skill_progression_ui/ui_state(mob/user)
	return GLOB.always_state

/datum/skill_progression_ui/ui_data(mob/user)
	var/list/data = list()

	if(!user_mind || !user_mind.persistent_data)
		data["has_data"] = FALSE
		return data

	var/datum/persistent_player_data/player_data = user_mind.persistent_data
	var/datum/persistent_class/current_class = user_mind.get_current_class()
	var/datum/persistent_faction/current_faction = user_mind.get_current_faction()
	var/list/rank_info = user_mind.get_rank_progress()

	// Basic player info
	data["has_data"] = TRUE
	data["player_name"] = user.name
	data["player_key"] = user.key
	data["current_class"] = current_class ? current_class.class_name : "Unknown"
	data["current_faction"] = current_faction ? current_faction.faction_name : "Unknown"
	data["current_rank"] = rank_info["rank_name"]
	data["current_rank_level"] = rank_info["current_rank"]
	data["total_experience"] = player_data.total_experience
	data["rounds_played"] = player_data.rounds_played
	data["progress_to_next"] = rank_info["progress"]
	data["exp_needed"] = rank_info["exp_needed"]

	// Skill summary
	data["skill_summary"] = player_data.get_skill_summary()

	// Skill milestones
	data["skill_milestones"] = user_mind.get_skill_milestones()

	// Performance metrics
	data["performance_metrics"] = player_data.performance_metrics

	// Skill boosts
	data["skill_boosts"] = get_skill_boosts_for_class(player_data.current_class_id)

	return data

/datum/skill_progression_ui/proc/get_skill_boosts_for_class(class_id)
	var/list/boosts = list()

	if(SSskill_integration && SSskill_integration.manager)
		var/list/class_boosts = SSskill_integration.manager.progression_skill_boosts[class_id]
		if(class_boosts)
			for(var/skill_type in class_boosts)
				var/boost_multiplier = class_boosts[skill_type]
				boosts[skill_type] = boost_multiplier

	return boosts

/datum/skill_progression_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("refresh_data")
			// Force refresh of skill data
			if(user_mind && SSskill_integration && SSskill_integration.manager)
				SSskill_integration.manager.process_player_skill_integration(user_mind)
			return TRUE

		if("claim_milestone")
			var/skill_type = text2path(params["skill_type"])
			var/milestone_level = text2num(params["milestone_level"])
			claim_skill_milestone(skill_type, milestone_level)
			return TRUE

		if("show_skill_details")
			var/skill_type = text2path(params["skill_type"])
			show_skill_details(skill_type)
			return TRUE

	return FALSE

/datum/skill_progression_ui/proc/claim_skill_milestone(skill_type, milestone_level)
	if(!user_mind || !user_mind.persistent_data)
		return

	var/datum/persistent_player_data/player_data = user_mind.persistent_data

	// Update player data with milestone information
	if(player_data)
		if(!player_data.achievements)
			player_data.achievements = list()
		player_data.achievements["skill_milestone_[skill_type]_[milestone_level]"] = world.time
	var/current_level = user_mind.get_skill_level(skill_type)

	if(current_level < milestone_level)
		to_chat(user, span_warning("You haven't reached this milestone yet!"))
		return

	// Check if already claimed
	var/list/milestones = user_mind.get_skill_milestones()
	if(milestones[skill_type] && (milestone_level in milestones[skill_type]))
		to_chat(user, span_warning("You've already claimed this milestone!"))
		return

	// Award milestone rewards
	var/list/rewards = SSskill_integration.manager.skill_progression_rewards[milestone_level]
	if(rewards)
		SSskill_integration.manager.award_skill_milestone_rewards(user_mind, skill_type, milestone_level, rewards)

	// Update milestone tracking
	var/ckey = user_mind.key
	if(ckey)
		var/list/integration_data = SSskill_integration.manager.get_integration_data(ckey)
		if(!(skill_type in integration_data["skill_milestones"]))
			integration_data["skill_milestones"][skill_type] = list()
		integration_data["skill_milestones"][skill_type] += milestone_level

	to_chat(user, span_notice("Milestone claimed! Check your progression for rewards."))

/datum/skill_progression_ui/proc/show_skill_details(skill_type)
	// Open detailed skill information
	var/datum/skill/skill_ref = GetSkillRef(skill_type)
	if(!skill_ref)
		return

	var/current_level = user_mind.get_skill_level(skill_type)
	var/current_exp = user_mind.get_skill_exp(skill_type)
	var/next_level_exp = SKILL_EXP_LIST[current_level + 1] || 2500
	var/progress = current_exp / next_level_exp * 100

	var/message = "[span_info("Skill Details: [get_skill_name(skill_type)]")]\n"
	message += "[span_notice("Current Level: [SSskills.level_names[current_level]] ([current_level])")]\n"
	message += "[span_notice("Experience: [current_exp]/[next_level_exp] ([round(progress, 0.1)]%)")]\n"
	message += "[span_notice("Description: [get_skill_name(skill_type)]")]\n"

	// Show progression class info
	var/progression_class = user_mind.get_skill_progression_class(skill_type)
	var/boost_multiplier = user_mind.get_skill_progression_boost(skill_type)
	message += "[span_notice("Progression Class: [progression_class]")]\n"
	if(boost_multiplier > 1.0)
		message += "[span_green("Experience Boost: +[round((boost_multiplier - 1) * 100, 0)]%")]\n"

	to_chat(user, examine_block(message))

// Player verbs for accessing skill progression
/mob/living/proc/show_skill_progression()
	set name = "Show Skill Progression"
	set category = "IC"
	set desc = "View your skill progression and how it relates to your persistent progression"

	if(!mind)
		to_chat(src, span_warning("You don't have a mind!"))
		return

	var/datum/skill_progression_ui/ui = new /datum/skill_progression_ui(src)
	ui.ui_interact(src)

/mob/living/proc/check_skill_milestones()
	set name = "Check Skill Milestones"
	set category = "IC"
	set desc = "Check your skill milestones and claim rewards"

	if(!mind)
		to_chat(src, span_warning("You don't have a mind!"))
		return

	if(!SSskill_integration || !SSskill_integration.manager)
		to_chat(src, span_warning("Skill integration system not available!"))
		return

	// Process skill milestones
	SSskill_integration.manager.process_player_skill_integration(mind)

	// Show milestone summary
	var/list/milestones = mind.get_skill_milestones()
	var/message = "[span_info("Skill Milestones:")]\n"

	if(length(milestones) == 0)
		message += "[span_notice("No milestones achieved yet. Keep practicing your skills!")]\n"
	else
		for(var/skill_type in milestones)
			var/list/achieved_levels = milestones[skill_type]
			var/skill_name = get_skill_name(skill_type)
			var/levels_text = ""
			for(var/i = 1; i <= length(achieved_levels); i++)
				levels_text += "[achieved_levels[i]]"
				if(i < length(achieved_levels))
					levels_text += ", "
			message += "[span_green("[skill_name]: [levels_text]")]\n"

	to_chat(src, examine_block(message))

// Admin verbs for skill progression management
/client/proc/manage_skill_progression()
	set name = "Manage Skill Progression"
	set category = "Admin.Player"
	set desc = "Manage player skill progression and integration"

	if(!check_rights(R_ADMIN))
		return

	var/list/options = list(
		"View All Players" = "view_all",
		"Sync Skill Data" = "sync_data",
		"Reset Player Data" = "reset_data",
		"Force Milestone Check" = "force_milestone"
	)

	var/choice = input("Choose an action:", "Skill Progression Management") as null|anything in options
	if(!choice)
		return

	switch(choice)
		if("view_all")
			view_all_skill_progression()
		if("sync_data")
			sync_skill_progression_data()
		if("reset_data")
			reset_player_skill_data()
		if("force_milestone")
			force_milestone_check()

/client/proc/view_all_skill_progression()
	var/message = "[span_info("Skill Progression Overview:")]\n"

	for(var/client/C in GLOB.clients)
		if(C.mob && C.mob.mind && C.mob.mind.persistent_data)
			var/datum/persistent_player_data/player_data = C.mob.mind.persistent_data
			var/list/skill_summary = player_data.get_skill_summary()
			var/total_levels = 0
			var/highest_level = 0

			for(var/skill_type in skill_summary)
				var/list/skill_data = skill_summary[skill_type]
				total_levels += skill_data["level"]
				highest_level = max(highest_level, skill_data["level"])

			message += "[span_notice("[C.key]: Class [player_data.current_class_id], Rank [player_data.current_rank], Total Skill Levels [total_levels], Highest [highest_level]")]\n"

	to_chat(src, examine_block(message))

/client/proc/sync_skill_progression_data()
	if(!SSskill_integration || !SSskill_integration.manager)
		to_chat(src, span_warning("Skill integration system not available!"))
		return

	SSskill_integration.manager.sync_skill_progression_data()
	to_chat(src, span_notice("Skill progression data synchronized."))

/client/proc/reset_player_skill_data()
	var/target_key = input("Enter player key to reset:", "Reset Skill Data") as text|null
	if(!target_key)
		return

	if(SSskill_integration && SSskill_integration.manager)
		SSskill_integration.manager.integration_cache -= target_key
		to_chat(src, span_notice("Skill integration data reset for [target_key]."))

/client/proc/force_milestone_check()
	if(!SSskill_integration || !SSskill_integration.manager)
		to_chat(src, span_warning("Skill integration system not available!"))
		return

	for(var/client/C in GLOB.clients)
		if(C.mob && C.mob.mind)
			SSskill_integration.manager.process_player_skill_integration(C.mob.mind)

	to_chat(src, span_notice("Forced milestone check for all players."))


