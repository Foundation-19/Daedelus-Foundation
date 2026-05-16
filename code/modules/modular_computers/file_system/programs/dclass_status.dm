/datum/computer_file/program/dclass_status
	filename = "dclass"
	filedesc = "D-Class Monitor"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Personal status monitor for D-Class personnel."
	size = 2
	tgui_id = "NtosDclassMonitor"
	program_icon = "id-card"
	usage_flags = PROGRAM_TABLET
	available_on_ntnet = FALSE

/datum/computer_file/program/dclass_status/ui_data(mob/user)
	var/list/data = get_header_data()

	if(!user.ckey || !SSdclass || !SSdclass.manager)
		data["access_denied"] = TRUE
		data["denied_reason"] = "D-Class system not available."
		return data

	if(!(user.ckey in SSdclass.manager.dclass_players))
		data["access_denied"] = TRUE
		data["denied_reason"] = "Access denied. D-Class personnel only."
		return data

	var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(user.ckey)
	if(!player)
		data["access_denied"] = TRUE
		data["denied_reason"] = "D-Class data not found."
		return data

	data["access_denied"] = FALSE

	data["level"] = player.level
	data["experience"] = player.experience
	data["required_experience"] = player.calculate_required_experience(player.level)
	data["trust_level"] = player.trust_level
	data["trust_name"] = player.get_trust_name(player.trust_level)
	data["trust_points"] = player.trust_points
	data["credits"] = player.credits
	data["credits_lifetime"] = player.credits_lifetime
	data["strikes"] = player.strikes
	data["warnings"] = player.warnings
	data["reputation"] = player.reputation
	data["suspicion"] = player.suspicion_level
	data["dclass_number"] = player.dclass_number
	data["informant"] = player.informant
	data["informant_reports"] = player.informant_reports

	data["current_time_slot"] = SSdclass.manager.current_time_slot
	data["security_level"] = SSdclass.manager.get_security_level()

	if(player.current_work_assignment)
		var/list/work_data = SSdclass.manager.work_assignments[player.current_work_assignment]
		if(work_data)
			data["current_work"] = list(
				"id" = player.current_work_assignment,
				"name" = work_data["name"],
				"description" = work_data["description"],
				"risk" = work_data["risk"],
				"reward" = work_data["reward"]
			)
		else
			data["current_work"] = null
	else
		data["current_work"] = null

	var/list/contraband_items = list()
	for(var/item in player.contraband)
		contraband_items += list(list(
			"name" = item,
			"count" = player.contraband[item],
			"hidden" = FALSE
		))
	data["contraband"] = contraband_items

	var/list/hidden_items = list()
	for(var/item in player.hidden_items)
		hidden_items += list(list(
			"name" = item,
			"count" = player.hidden_items[item],
			"hidden" = TRUE
		))
	data["hidden_items"] = hidden_items

	var/list/crafted_items = list()
	for(var/item in player.crafted_items)
		crafted_items += list(list(
			"name" = item
		))
	data["crafted_items"] = crafted_items

	var/list/skills_data = list()
	for(var/skill in player.skills)
		skills_data += list(list(
			"name" = skill,
			"level" = player.skills[skill]
		))
	data["skills"] = skills_data

	data["career_stats"] = null
	data["achievements"] = list()

	if(SSdclass.manager.persistence_manager)
		var/datum/dclass_persistence_data/pdata = SSdclass.manager.persistence_manager.get_persistence_data(user.ckey)
		if(pdata)
			data["career_stats"] = list(
				"rounds_played" = pdata.round_count,
				"total_escape_attempts" = pdata.total_escape_attempts,
				"successful_escapes" = pdata.total_successful_escapes,
				"contraband_found" = pdata.total_contraband_found,
				"work_completed" = pdata.total_work_completed,
				"alliances_formed" = pdata.total_alliances_formed,
				"players_betrayed" = pdata.total_players_betrayed,
				"highest_level" = pdata.highest_level_achieved,
				"longest_survival" = pdata.longest_survival_time / 600
			)

			var/list/achievement_list = list()
			for(var/achievement_id in SSdclass.manager.persistence_manager.achievements)
				var/datum/dclass_achievement/achievement = SSdclass.manager.persistence_manager.achievements[achievement_id]
				var/unlocked = (achievement_id in pdata.achievements)
				achievement_list += list(list(
					"id" = achievement_id,
					"name" = achievement.name,
					"description" = achievement.description,
					"unlocked" = unlocked
				))
			data["achievements"] = achievement_list

	var/list/active_events = list()
	if(SSdclass.manager.event_manager && length(SSdclass.manager.event_manager.active_events) > 0)
		for(var/datum/dclass_event/event in SSdclass.manager.event_manager.active_events)
			var/time_remaining = (event.start_time + event.duration - world.time) / 10
			active_events += list(list(
				"name" = event.name,
				"description" = event.description,
				"event_type" = event.event_type,
				"time_remaining" = time_remaining,
				"escape_bonus" = event.escape_bonus,
				"contraband_bonus" = event.contraband_bonus,
				"security_impact" = event.security_impact
			))
	data["active_events"] = active_events

	data["next_event_prediction"] = null
	if(SSdclass.manager.event_manager)
		var/time_since_last = (world.time - SSdclass.manager.event_manager.last_event_time) / 10
		var/time_until_next = (SSdclass.manager.event_manager.event_cooldown - time_since_last) / 10
		data["next_event_prediction"] = max(0, time_until_next)

	return data

/datum/computer_file/program/dclass_status/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user

	if(!user.ckey || !SSdclass || !SSdclass.manager)
		return

	if(!(user.ckey in SSdclass.manager.dclass_players))
		return

	var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(user.ckey)
	if(!player)
		return

	switch(action)
		if("PRG_drop_item")
			var/item_name = params["item"]
			if(!item_name || !(item_name in player.contraband))
				return
			player.remove_contraband(item_name, 1)
			return TRUE
		if("PRG_hide_item")
			var/item_name = params["item"]
			if(!item_name || !(item_name in player.contraband))
				return
			player.hidden_items[item_name] = 1
			player.remove_contraband(item_name, 1)
			return TRUE

/obj/item/computer_hardware/hard_drive/role/dclass
	name = "D-Class data disk"
	desc = "A data disk for D-Class personnel."
	icon_state = "datadisk5"

/obj/item/computer_hardware/hard_drive/role/dclass/Initialize(mapload)
	. = ..()
	var/datum/computer_file/program/dclass_status/prog = new(src)
	prog.usage_flags = PROGRAM_ALL
	prog.required_access = list()
	prog.transfer_access = list()
	store_file(prog)
