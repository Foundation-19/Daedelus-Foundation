/obj/item/poster/escape_map
	name = "Escape Route Map"
	desc = "A worn poster showing facility layout with some routes circled in red."
	icon = 'icons/obj/contraband.dmi'
	icon_state = "rolled_poster"

/obj/item/poster/escape_map/attack_hand(mob/user)
	if(!ishuman(user))
		return
	ui_interact(user)

/obj/item/poster/escape_map/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DclassEscapeMap", "Escape Routes")
		ui.open()

/obj/item/poster/escape_map/ui_data(mob/user)
	var/list/data = list()
	var/list/routes = list()
	if(SSdclass && SSdclass.manager)
		for(var/route_id in SSdclass.manager.escape_routes)
			var/list/route = SSdclass.manager.escape_routes[route_id]
			var/list/req_data = list()
			if(route["requirements"])
				for(var/req in route["requirements"])
					req_data += list(list(
						"name" = req,
						"met" = FALSE,
					))
			routes += list(list(
				"id" = route_id,
				"name" = route["name"] || "Unknown Route",
				"description" = route["description"] || "No details available.",
				"difficulty" = route["difficulty"] || 0,
				"success_chance" = route["success_chance"] || 0,
				"time_required" = route["time_required"] || 0,
				"requirements" = req_data,
			))
	data["routes"] = routes
	return data

/obj/item/poster/escape_map/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(action == "attempt")
		var/route_id = params["route_id"]
		if(!route_id)
			return
		var/mob/living/carbon/human/H = usr
		if(!istype(H) || !H.ckey)
			return
		if(!SSdclass || !SSdclass.manager)
			return
		var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(H.ckey)
		if(!player)
			return
		player.attempt_escape(route_id)
		. = TRUE

/obj/structure/dclass_bunk
	name = "D-Class Bunk"
	desc = "A narrow bunk bed. A good place to observe the cell block unnoticed."
	density = FALSE
	anchored = TRUE
	icon = 'icons/obj/structures.dmi'
	icon_state = "bed"

/obj/structure/dclass_bunk/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(!SSdclass || !SSdclass.manager || !H.ckey)
		return
	var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(H.ckey)
	if(!player)
		to_chat(H, span_notice("You sit on the bunk."))
		return
	var/area/current_area = get_area(H)
	var/guard_count = 0
	var/dclass_count = 0
	for(var/mob/living/carbon/human/M in view(7, H))
		if(M == H)
			continue
		if(M.job && findtext(M.job, "Guard"))
			guard_count++
		var/datum/dclass_player/other = SSdclass.manager.get_dclass_player(M.ckey)
		if(other)
			dclass_count++
	var/security_level = SSdclass.manager.get_security_level()
	var/time_slot = SSdclass.manager.current_time_slot || "Day"
	to_chat(H, span_notice("You observe your surroundings from the bunk..."))
	to_chat(H, span_notice("<b>Area:</b> [current_area ? current_area.name : "Unknown"]"))
	to_chat(H, span_notice("<b>Guards nearby:</b> [guard_count]"))
	to_chat(H, span_notice("<b>D-Class nearby:</b> [dclass_count]"))
	to_chat(H, span_notice("<b>Security Level:</b> [security_level]"))
	to_chat(H, span_notice("<b>Time Slot:</b> [time_slot]"))
	to_chat(H, span_notice("<b>Credits:</b> [player.credits], <b>Trust:</b> [player.trust_points]%"))
	player.gain_experience(2, "observation")

/obj/structure/dclass_watercooler
	name = "Water Cooler"
	desc = "A water cooler. A common gathering spot for quiet conversation."
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/structures.dmi'
	icon_state = "watercooler"

/obj/structure/dclass_watercooler/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(!SSdclass || !SSdclass.manager || !H.ckey)
		to_chat(H, span_notice("You drink some water. Refreshing."))
		return
	var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(H.ckey)
	if(!player)
		to_chat(H, span_notice("You drink some water. Refreshing."))
		return
	ui_interact(user)

/obj/structure/dclass_watercooler/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DclassSocial", "Social - Water Cooler")
		ui.open()

/obj/structure/dclass_watercooler/ui_data(mob/user)
	var/list/data = list()
	var/list/nearby = list()
	var/mob/living/carbon/human/H = user
	if(!SSdclass || !SSdclass.manager || !H.ckey)
		data["nearby_players"] = nearby
		return data
	var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(H.ckey)
	if(!player)
		data["nearby_players"] = nearby
		return data
	var/list/my_items = list()
	for(var/obj/item/dclass_contraband/C in H.contents)
		my_items += list(list("name" = C.name, "ref" = "\ref[C]"))
	data["my_trade_items"] = my_items
	for(var/mob/living/carbon/human/M in view(3, H))
		if(M == H || !M.ckey)
			continue
		var/datum/dclass_player/other = SSdclass.manager.get_dclass_player(M.ckey)
		if(!other)
			continue
		var/relationship = "Neutral"
		if(M.real_name in player.allies)
			relationship = "Ally"
		else if(M.real_name in player.enemies)
			relationship = "Enemy"
		var/list/their_items = list()
		for(var/obj/item/dclass_contraband/C in M.contents)
			their_items += list(list("name" = C.name, "ref" = "\ref[C]"))
		nearby += list(list(
			"name" = M.real_name,
			"player_id" = M.ckey,
			"level" = other.level,
			"relationship" = relationship,
			"trade_items" = their_items,
		))
	data["nearby_players"] = nearby
	return data

/obj/structure/dclass_watercooler/ui_act(action, params)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = usr
	if(!istype(H) || !H.ckey)
		return
	if(!SSdclass || !SSdclass.manager)
		return
	var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(H.ckey)
	if(!player)
		return
	var/target_name = params["name"]
	var/target_ckey = params["player_id"]
	switch(action)
		if("ally")
			if(!target_name && !target_ckey)
				return
			if(!target_name && target_ckey)
				var/datum/dclass_player/p = SSdclass.manager.dclass_players[target_ckey]
				if(p?.mob)
					target_name = p.mob.real_name
			if(!(target_name in player.allies))
				player.allies |= target_name
				to_chat(H, span_notice("You form an alliance with [target_name]."))
				player.gain_experience(1, "social")
			. = TRUE
		if("trade")
			var/offer_ref = params["offer_ref"]
			var/request_ref = params["request_ref"]
			if(!target_ckey)
				return
			var/datum/dclass_player/target_player = SSdclass.manager.dclass_players[target_ckey]
			if(!target_player || !target_player.mob)
				to_chat(H, span_warning("Can't find that person."))
				return TRUE
			var/mob/living/carbon/human/target_mob = target_player.mob
			if(get_dist(H, target_mob) > 3)
				to_chat(H, span_warning("Too far away to trade."))
				return TRUE
			var/obj/item/dclass_contraband/offer_item = locate(offer_ref)
			var/obj/item/dclass_contraband/request_item = locate(request_ref)
			if(!offer_item || !istype(offer_item) || !(offer_item in H.contents))
				to_chat(H, span_warning("Invalid offer item."))
				return TRUE
			if(!request_item || !istype(request_item) || !(request_item in target_mob.contents))
				to_chat(H, span_warning("Invalid request item."))
				return TRUE
			to_chat(H, span_notice("You offer [offer_item.name] for [request_item.name]. Waiting for [target_mob.real_name]..."))
			to_chat(target_mob, span_notice("<b>TRADE REQUEST:</b> [H.real_name] offers [offer_item.name] for your [request_item.name]. Use 'Accept Trade' or 'Decline Trade' verb."))
			target_mob.trade_pending = list("offer_name" = offer_item.name, "offer_item" = offer_item, "request_name" = request_item.name, "request_item" = request_item, "from" = H)
			return TRUE
		if("report")
			if(!target_name)
				return
			if(!(target_name in player.reported_players))
				player.reported_players |= target_name
				to_chat(H, span_notice("You quietly report [target_name] to the guards."))
				player.gain_experience(2, "social")
			. = TRUE

/obj/machinery/dclass_faction_terminal
	name = "D-Class Faction Terminal"
	desc = "A terminal for managing your faction affiliation and reporting information to staff."
	icon = 'icons/obj/computer.dmi'
	icon_state = "dterm"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50

/obj/machinery/dclass_faction_terminal/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(!SSdclass || !SSdclass.manager || !H.ckey)
		to_chat(H, span_notice("The terminal displays: ACCESS DENIED."))
		return
	var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(H.ckey)
	if(!player)
		to_chat(H, span_notice("The terminal displays: NO D-CLASS RECORD FOUND."))
		return
	ui_interact(user)

/obj/machinery/dclass_faction_terminal/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DclassFactionTerminal", "FACTION TERMINAL")
		ui.open()

/obj/machinery/dclass_faction_terminal/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/dclass_faction_terminal/ui_data(mob/user)
	var/list/data = list()
	var/mob/living/carbon/human/H = user
	if(!SSdclass || !SSdclass.manager || !H.ckey)
		return data
	var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(H.ckey)
	if(!player)
		return data

	data["faction"] = player.faction
	data["faction_name"] = "None"
	data["faction_desc"] = ""
	data["faction_perks"] = list()
	data["informant"] = player.informant
	data["informant_reports"] = player.informant_reports
	data["trust_level"] = player.trust_level

	if(SSdclass.manager.faction_manager)
		var/datum/dclass_faction_manager/FM = SSdclass.manager.faction_manager
		var/list/faction_data = list()
		for(var/fkey in FM.factions)
			var/datum/dclass_faction/F = FM.factions[fkey]
			faction_data += list(list(
				"key" = fkey,
				"name" = F.name,
				"description" = F.description,
				"member_count" = length(F.members),
				"perks" = F.perks,
				"is_member" = (player.ckey in F.members),
			))
		data["factions"] = faction_data

		if(player.faction != DCLASS_FACTION_NONE)
			var/datum/dclass_faction/current
			switch(player.faction)
				if(DCLASS_FACTION_REBELS)
					current = FM.factions["rebels"]
				if(DCLASS_FACTION_COLLABORATORS)
					current = FM.factions["collaborators"]
				if(DCLASS_FACTION_SURVIVORS)
					current = FM.factions["survivors"]
			if(current)
				data["faction_name"] = current.name
				data["faction_desc"] = current.description
				data["faction_perks"] = current.perks

	return data

/obj/machinery/dclass_faction_terminal/ui_act(action, params)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = usr
	if(!istype(H) || !H.ckey)
		return
	if(!SSdclass || !SSdclass.manager)
		return
	var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(H.ckey)
	if(!player)
		return

	switch(action)
		if("join_faction")
			if(player.faction != DCLASS_FACTION_NONE)
				to_chat(H, span_warning("You are already in a faction. Leave your current faction first."))
				return
			var/faction_key = params["faction"]
			if(!SSdclass.manager.faction_manager)
				return
			var/datum/dclass_faction_manager/FM = SSdclass.manager.faction_manager
			var/datum/dclass_faction/F = FM.factions[faction_key]
			if(!F)
				return
			F.add_member(player)
			switch(faction_key)
				if("rebels")
					player.faction = DCLASS_FACTION_REBELS
				if("collaborators")
					player.faction = DCLASS_FACTION_COLLABORATORS
				if("survivors")
					player.faction = DCLASS_FACTION_SURVIVORS
			player.gain_experience(10, "joined_faction")
			. = TRUE
		if("leave_faction")
			if(player.faction == DCLASS_FACTION_NONE)
				return
			if(!SSdclass.manager.faction_manager)
				return
			var/datum/dclass_faction_manager/FM = SSdclass.manager.faction_manager
			var/faction_key
			switch(player.faction)
				if(DCLASS_FACTION_REBELS)
					faction_key = "rebels"
				if(DCLASS_FACTION_COLLABORATORS)
					faction_key = "collaborators"
				if(DCLASS_FACTION_SURVIVORS)
					faction_key = "survivors"
			if(faction_key)
				var/datum/dclass_faction/F = FM.factions[faction_key]
				if(F)
					F.remove_member(player)
			player.faction = DCLASS_FACTION_NONE
			player.adjust_trust(-5, "left_faction")
			to_chat(H, span_notice("You have left your faction. Your trust has decreased slightly."))
			. = TRUE
		if("become_informant")
			if(player.informant)
				to_chat(H, span_warning("You are already an informant."))
				return
			if(player.trust_level < DCLASS_TRUST_NEUTRAL)
				to_chat(H, span_warning("Your trust level is too low to become an informant."))
				return
			player.become_informant()
			to_chat(H, span_notice("You have signed up as an informant. Report escape plans and suspicious activity to earn rewards."))
			. = TRUE
		if("report_plan")
			if(!player.informant)
				to_chat(H, span_warning("You must be an informant to file reports."))
				return
			var/plan_desc = params["plan"] || "suspicious activity"
			var/count = text2num(params["participants"]) || 1
			player.report_escape_plan(plan_desc, count)
			to_chat(H, span_notice("Report filed. Reward credited to your account."))
			. = TRUE
		if("volunteer_for_testing")
			if(!SSscp_gameplay)
				to_chat(H, span_warning("No testing protocols are currently active."))
				return
			player.adjust_trust(5, "volunteered_for_testing")
			player.adjust_credits(50, "volunteer_bonus")
			player.gain_experience(5, "volunteered")
			for(var/mob/living/carbon/human/G in GLOB.player_list)
				if(G.stat == DEAD)
					continue
				if(G.job && (findtext(G.job, "Guard") || findtext(G.job, "Security")))
					to_chat(G, span_notice("<b>D-CLASS VOLUNTEER:</b> [H.real_name] has volunteered for SCP testing. Escort available at your convenience."))
			for(var/task_id in SSscp_gameplay.escort_tasks)
				var/datum/escort_task/task = SSscp_gameplay.escort_tasks[task_id]
				if(task.status == "pending" && task.researcher)
					to_chat(task.researcher, span_notice("<b>SUBJECT AVAILABLE:</b> [H.real_name] has volunteered for testing."))
					break
			to_chat(H, span_notice("You have volunteered for SCP testing. Bonus credits and trust awarded. A guard will escort you when ready."))
			. = TRUE

/mob/living/carbon/human/var/list/trade_pending = null

/mob/living/carbon/human/proc/accept_trade()
	set name = "Accept Trade"
	set category = "D-Class"
	set hidden = TRUE
	if(!trade_pending)
		to_chat(usr, span_warning("No pending trade offer."))
		return
	var/mob/living/carbon/human/requester = trade_pending["from"]
	if(!requester || requester.stat == DEAD || get_dist(src, requester) > 5)
		to_chat(usr, span_warning("Trade partner unavailable."))
		trade_pending = null
		return
	var/obj/item/offered = trade_pending["offer_item"]
	var/obj/item/requested = trade_pending["request_item"]
	if(!offered || !requested)
		to_chat(usr, span_warning("Trade items no longer available."))
		trade_pending = null
		return
	if(!(offered in requester.contents) || !(requested in src.contents))
		to_chat(usr, span_warning("Trade items no longer held."))
		trade_pending = null
		return
	requester.transferItemToLoc(offered, src)
	transferItemToLoc(requested, requester)
	to_chat(usr, span_notice("Trade complete! You received [offered.name] for [requested.name]."))
	to_chat(requester, span_notice("Trade complete! You received [requested.name] for [offered.name]."))
	var/datum/dclass_player/my_player = SSdclass?.manager?.dclass_players[ckey]
	var/datum/dclass_player/their_player = SSdclass?.manager?.dclass_players[requester.ckey]
	if(my_player)
		my_player.gain_experience(3, "trade")
	if(their_player)
		their_player.gain_experience(3, "trade")
	trade_pending = null

/mob/living/carbon/human/proc/decline_trade()
	set name = "Decline Trade"
	set category = "D-Class"
	set hidden = TRUE
	if(!trade_pending)
		to_chat(usr, span_warning("No pending trade offer."))
		return
	var/mob/living/carbon/human/requester = trade_pending["from"]
	if(requester)
		to_chat(requester, span_warning("[src.real_name] declined your trade offer."))
	trade_pending = null
