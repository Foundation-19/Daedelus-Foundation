/datum/scp_achievement
	var/id
	var/name
	var/desc
	var/category
	var/tier = 1
	var/unlocked = FALSE
	var/progress = 0
	var/goal = 1
	var/unlock_time

SUBSYSTEM_DEF(scp_achievements)
	name = "SCP Achievements"
	wait = 600
	flags = SS_NO_FIRE
	var/list/achievements = list()
	var/list/player_achievements = list()

/datum/controller/subsystem/scp_achievements/Initialize()
	initialize_achievements()
	load_achievements()
	return ..()

/datum/controller/subsystem/scp_achievements/proc/initialize_achievements()
	var/list/definitions = list(
		list("id" = "first_recontainment", "name" = "First Containment", "desc" = "Successfully recontain an SCP", "category" = "containment", "tier" = 1, "goal" = 1),
		list("id" = "recontainment_master", "name" = "Containment Master", "desc" = "Recontain 5 SCPs in one shift", "category" = "containment", "tier" = 2, "goal" = 5),
		list("id" = "femur_breaker", "name" = "Necessary Sacrifice", "desc" = "Use the femur breaker on SCP-106", "category" = "containment", "tier" = 1, "goal" = 1),
		list("id" = "rapid_response", "name" = "Rapid Response", "desc" = "Recontain an SCP within 5 minutes of breach", "category" = "containment", "tier" = 2, "goal" = 1),
		list("id" = "perfect_record", "name" = "Perfect Record", "desc" = "Complete a shift with zero containment breaches", "category" = "containment", "tier" = 3, "goal" = 1),
		list("id" = "first_experiment", "name" = "First Experiment", "desc" = "Complete your first SCP experiment", "category" = "research", "tier" = 1, "goal" = 1),
		list("id" = "experiment_enthusiast", "name" = "Research Enthusiast", "desc" = "Complete 10 experiments", "category" = "research", "tier" = 2, "goal" = 10),
		list("id" = "dangerous_research", "name" = "Dangerous Research", "desc" = "Complete an experiment with risk level CRITICAL", "category" = "research", "tier" = 1, "goal" = 1),
		list("id" = "tech_pioneer", "name" = "Tech Pioneer", "desc" = "Unlock a tier 3 research node", "category" = "research", "tier" = 1, "goal" = 1),
		list("id" = "nobel_prize", "name" = "Nobel Prize", "desc" = "Unlock a tier 5 research node", "category" = "research", "tier" = 3, "goal" = 1),
		list("id" = "scp_encounter", "name" = "Close Encounter", "desc" = "Survive being within 3 tiles of an active SCP", "category" = "survival", "tier" = 1, "goal" = 1),
		list("id" = "escape_artist", "name" = "Escape Artist", "desc" = "Successfully escape the facility as D-Class", "category" = "survival", "tier" = 1, "goal" = 1),
		list("id" = "pocket_survivor", "name" = "Pocket Survivor", "desc" = "Escape from SCP-106's pocket dimension", "category" = "survival", "tier" = 1, "goal" = 1),
		list("id" = "096_survivor", "name" = "Don't Look Back", "desc" = "Survive an SCP-096 encounter without dying", "category" = "survival", "tier" = 1, "goal" = 1),
		list("id" = "one_day_more", "name" = "One Day More", "desc" = "Survive an entire shift as D-Class without dying", "category" = "survival", "tier" = 3, "goal" = 1),
		list("id" = "first_breach", "name" = "First Breach", "desc" = "Breach containment as an SCP for the first time", "category" = "scp_play", "tier" = 1, "goal" = 1),
		list("id" = "scp049_curer", "name" = "The Cure", "desc" = "Cure 3 targets as SCP-049", "category" = "scp_play", "tier" = 1, "goal" = 3),
		list("id" = "scp079_network", "name" = "Network Overlord", "desc" = "Reach tier 5 as SCP-079", "category" = "scp_play", "tier" = 1, "goal" = 1),
		list("id" = "scp682_adapted", "name" = "Adaptive Horror", "desc" = "Survive 15 minutes after breach as SCP-682", "category" = "scp_play", "tier" = 1, "goal" = 1),
		list("id" = "scp173_moved", "name" = "When Nobody's Looking", "desc" = "Move 100 tiles as SCP-173", "category" = "scp_play", "tier" = 2, "goal" = 100),
		list("id" = "dclass_crafter", "name" = "Improviser", "desc" = "Craft 5 items as D-Class", "category" = "dclass", "tier" = 1, "goal" = 5),
		list("id" = "dclass_scientist", "name" = "Amateur Scientist", "desc" = "Complete 3 experiments as D-Class", "category" = "dclass", "tier" = 1, "goal" = 3),
		list("id" = "dclass_explorer", "name" = "Explorer", "desc" = "Visit 5 different SCP containment cells", "category" = "dclass", "tier" = 1, "goal" = 5),
		list("id" = "dclass_rioter", "name" = "Uprising", "desc" = "Participate in a D-Class riot", "category" = "dclass", "tier" = 1, "goal" = 1),
		list("id" = "dclass_legend", "name" = "Legend", "desc" = "Escape, complete 5 experiments, and survive the shift as D-Class", "category" = "dclass", "tier" = 3, "goal" = 1)
	)

	for(var/list/def in definitions)
		var/datum/scp_achievement/A = new()
		A.id = def["id"]
		A.name = def["name"]
		A.desc = def["desc"]
		A.category = def["category"]
		A.tier = def["tier"]
		A.goal = def["goal"]
		achievements[A.id] = A

/datum/controller/subsystem/scp_achievements/proc/unlock_achievement(ckey, achievement_id)
	if(!ckey || !achievement_id)
		return

	var/datum/scp_achievement/A = achievements[achievement_id]
	if(!A)
		return

	if(!player_achievements[ckey])
		player_achievements[ckey] = list()

	if(achievement_id in player_achievements[ckey])
		return

	player_achievements[ckey] += achievement_id
	A.unlocked = TRUE
	A.unlock_time = world.time

	var/tier_name = "Bronze"
	if(A.tier == 2)
		tier_name = "Silver"
	if(A.tier == 3)
		tier_name = "Gold"

	for(var/mob/M in GLOB.player_list)
		if(QDELETED(M))
			continue
		if(M.ckey == ckey)
			to_chat(M, span_notice("<b>Achievement Unlocked: [A.name]</b> ([tier_name]) - [A.desc]"))

	save_achievements()

/datum/controller/subsystem/scp_achievements/proc/increment_progress(ckey, achievement_id, amount)
	if(!ckey || !achievement_id)
		return

	var/datum/scp_achievement/A = achievements[achievement_id]
	if(!A)
		return

	if(achievement_id in player_achievements[ckey])
		return

	A.progress += (amount || 1)

	if(A.progress >= A.goal)
		unlock_achievement(ckey, achievement_id)

/datum/controller/subsystem/scp_achievements/proc/check_achievement(ckey, achievement_id)
	if(!ckey || !achievement_id)
		return FALSE

	if(!player_achievements[ckey])
		return FALSE

	return (achievement_id in player_achievements[ckey])

/datum/controller/subsystem/scp_achievements/proc/get_player_achievements(ckey)
	var/list/result = list()

	if(!ckey || !player_achievements[ckey])
		return result

	for(var/achievement_id in achievements)
		var/datum/scp_achievement/A = achievements[achievement_id]
		result += list(list(
			"id" = A.id,
			"name" = A.name,
			"desc" = A.desc,
			"category" = A.category,
			"tier" = A.tier,
			"unlocked" = (achievement_id in player_achievements[ckey]),
			"progress" = A.progress,
			"goal" = A.goal,
			"unlock_time" = A.unlock_time
		))

	return result

/datum/controller/subsystem/scp_achievements/proc/save_achievements()
	var/list/save_data = list()

	for(var/ckey in player_achievements)
		save_data[ckey] = player_achievements[ckey]

	var/json_text = json_encode(save_data)
	if(fexists("data/scp_achievements.json"))
		fdel("data/scp_achievements.json")
	text2file(json_text, "data/scp_achievements.json")

/datum/controller/subsystem/scp_achievements/proc/load_achievements()
	if(!fexists("data/scp_achievements.json"))
		return

	var/json_text = file2text("data/scp_achievements.json")
	if(!json_text)
		return

	var/list/loaded = json_decode(json_text)
	if(!loaded)
		return

	for(var/ckey in loaded)
		player_achievements[ckey] = loaded[ckey]
		for(var/achievement_id in loaded[ckey])
			var/datum/scp_achievement/A = achievements[achievement_id]
			if(A)
				A.unlocked = TRUE

/obj/machinery/computer/scp_achievement_console
	name = "SCP achievement console"
	desc = "A console displaying personal SCP achievements and milestones."
	icon = 'icons/obj/modular_console.dmi'
	icon_state = "console"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 150

/obj/machinery/computer/scp_achievement_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SCPAchievementConsole", "SCP Achievements")
		ui.open()

/obj/machinery/computer/scp_achievement_console/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/scp_achievement_console/ui_data(mob/user)
	var/list/data = list()
	var/ckey = user.ckey

	if(!SSscp_achievements)
		data["achievements"] = list()
		return data

	var/list/achievement_list = list()
	var/list/all_achievements = SSscp_achievements.get_player_achievements(ckey)

	for(var/list/A in all_achievements)
		achievement_list += list(list(
			"id" = A["id"],
			"name" = A["name"],
			"desc" = A["desc"],
			"category" = A["category"],
			"tier" = A["tier"],
			"unlocked" = A["unlocked"],
			"progress" = A["progress"],
			"goal" = A["goal"],
			"unlock_time" = A["unlock_time"]
		))

	data["achievements"] = achievement_list
	data["ckey"] = ckey
	data["is_admin"] = check_rights(R_ADMIN, FALSE, user)

	return data

/obj/machinery/computer/scp_achievement_console/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("view_other")
			if(!check_rights(R_ADMIN, FALSE, ui.user))
				return
			var/target_ckey = params["ckey"]
			if(!target_ckey)
				return
			var/list/other_achievements = SSscp_achievements.get_player_achievements(target_ckey)
			for(var/list/A in other_achievements)
				to_chat(ui.user, span_notice("[A["name"]] - [A["unlocked"] ? "UNLOCKED" : "[A["progress"]]/[A["goal"]]"] ([A["category"]])"))
