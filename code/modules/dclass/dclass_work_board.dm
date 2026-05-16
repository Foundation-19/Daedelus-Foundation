// D-Class Work Assignment Board
// TGUI interface for D-Class to view and accept work assignments

/obj/machinery/dclass_work_board
	name = "Work Assignment Board"
	desc = "A digital board displaying available work assignments for D-Class personnel."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "rdserver"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50

/obj/machinery/dclass_work_board/attack_hand(mob/user)
	if(!ishuman(user))
		return
	ui_interact(user)

/obj/machinery/dclass_work_board/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ScpDclassWorkBoard", name)
		ui.open()

/obj/machinery/dclass_work_board/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/dclass_work_board/ui_data(mob/user)
	var/list/data = list()
	data["assignments"] = list()
	if(SSdclass?.manager)
		for(var/work_id in SSdclass.manager.work_assignments)
			var/list/work_data = SSdclass.manager.work_assignments[work_id]
			data["assignments"] += list(list(
				"id" = work_id,
				"name" = work_data["name"],
				"description" = work_data["description"],
				"risk" = work_data["risk"],
				"reward" = work_data["reward"],
				"tools" = work_data["tools"],
				"access" = work_data["access"],
			))
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(H.ckey)
			if(player)
				data["current_assignment"] = player.current_work_assignment
				data["credits"] = player.credits
				data["trust"] = player.trust_points
				data["level"] = player.level
			else
				data["current_assignment"] = null
				data["credits"] = 0
				data["trust"] = 0
				data["level"] = 0
	return data

/obj/machinery/dclass_work_board/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = usr
	if(!ishuman(H))
		return
	if(!SSdclass?.manager)
		return
	var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(H.ckey)
	if(!player)
		return

	switch(action)
		if("accept")
			var/work_id = params["id"]
			if(!work_id || !(work_id in SSdclass.manager.work_assignments))
				return
			if(player.current_work_assignment)
				to_chat(H, span_warning("You already have a work assignment."))
				return
			var/list/work_data = SSdclass.manager.work_assignments[work_id]
			if(player.level < work_data["risk"])
				to_chat(H, span_warning("Your clearance level is too low for this assignment."))
				return
			player.assign_work(work_id)
			to_chat(H, span_notice("Work assignment accepted: [work_data["name"]]. Report to the designated area."))
			. = TRUE
		if("abandon")
			if(!player.current_work_assignment)
				return
			player.current_work_assignment = null
			player.trust_points = max(0, player.trust_points - 5)
			to_chat(H, span_warning("You abandoned your work assignment. Trust rating decreased."))
			. = TRUE
