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
		nearby += list(list(
			"name" = M.real_name,
			"level" = other.level,
			"relationship" = relationship,
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
	switch(action)
		if("ally")
			if(!target_name)
				return
			if(!(target_name in player.allies))
				player.allies |= target_name
				to_chat(H, span_notice("You form an alliance with [target_name]."))
				player.gain_experience(1, "social")
			. = TRUE
		if("trade")
			to_chat(H, span_notice("Trading is not yet available."))
			. = TRUE
		if("report")
			if(!target_name)
				return
			if(!(target_name in player.reported_players))
				player.reported_players |= target_name
				to_chat(H, span_notice("You quietly report [target_name] to the guards."))
				player.gain_experience(2, "social")
			. = TRUE
