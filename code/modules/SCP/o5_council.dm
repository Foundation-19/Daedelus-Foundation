/obj/machinery/o5_council_console
	name = "O5 Council Terminal"
	desc = "A secure terminal for O5 Council voting and decision-making. The highest authority in the Foundation."
	icon = 'icons/obj/machines/nuke.dmi'
	icon_state = "nuclearbomb_base"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 100
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	var/list/active_votes = list()
	var/vote_cooldown = 0
	var/vote_cooldown_time = 5 MINUTES

/obj/machinery/o5_council_console/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ADMIN in id_card.access))
		to_chat(H, span_warning("O5 clearance required."))
		return
	ui_interact(H)

/obj/machinery/o5_council_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "O5Council", name)
		ui.open()

/obj/machinery/o5_council_console/ui_data(mob/user)
	var/list/data = list()
	data["active_votes"] = list()
	for(var/datum/o5_vote/vote in active_votes)
		data["active_votes"] += list(list(
			"id" = vote.id,
			"title" = vote.title,
			"description" = vote.description,
			"yes_votes" = vote.yes_votes,
			"no_votes" = vote.no_votes,
			"required" = vote.required_votes,
			"status" = vote.status,
			"initiator" = vote.initiator,
		))
	return data

/obj/machinery/o5_council_console/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/living/carbon/human/H = usr
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ADMIN in id_card.access))
		return

	switch(action)
		if("call_vote")
			if(world.time < vote_cooldown)
				to_chat(H, span_warning("Vote cooldown active. Wait [DisplayTimeText(vote_cooldown - world.time)]."))
				return
			var/title = params["title"]
			var/desc = params["description"]
			var/vote_type_input = params["vote_type"]
			if(!title)
				return
			var/datum/o5_vote/new_vote = new(title, desc, H.real_name, vote_type_input)
			active_votes += new_vote
			vote_cooldown = world.time + vote_cooldown_time
			priority_announce("O5 COUNCIL VOTE CALLED: [title]. All O5 members report to the Council Chamber.", null, null, 'sound/misc/notice1.ogg')
			log_game("[key_name(H)] called an O5 vote: [title]")
		if("cast_vote")
			var/vote_id = text2num(params["vote_id"])
			var/vote_choice = params["choice"]
			for(var/datum/o5_vote/vote in active_votes)
				if(vote.id == vote_id && vote.status == "active")
					if(H.ckey in vote.voted_ckeys)
						to_chat(H, span_warning("You have already voted on this measure."))
						return
					vote.voted_ckeys += H.ckey
					if(vote_choice == "yes")
						vote.yes_votes++
					else
						vote.no_votes++
					check_vote_completion(vote)
					break
		if("authorize_warhead")
			if(!(ACCESS_ADMIN in id_card.access))
				return
			priority_announce("O5 COUNCIL HAS AUTHORIZED THE ON-SITE WARHEAD. SITE DIRECTOR: CONFIRM DETONATION CODE.", null, null, 'sound/misc/airraid.ogg')
			log_game("[key_name(H)] O5 authorized the on-site warhead via Council vote.")
			for(var/obj/machinery/nuclearbomb/N in INSTANCES_OF(/obj/machinery/nuclearbomb))
				if(istype(N, /obj/machinery/nuclearbomb/foundation))
					var/obj/machinery/nuclearbomb/foundation/FN = N
					FN.foundation_authorized = TRUE

/obj/machinery/o5_council_console/proc/check_vote_completion(datum/o5_vote/vote)
	if(vote.yes_votes >= vote.required_votes)
		vote.status = "passed"
		priority_announce("O5 COUNCIL MEASURE PASSED: [vote.title].", null, null, 'sound/misc/notice1.ogg')
		execute_vote_action(vote)
	else if(vote.no_votes >= vote.required_votes)
		vote.status = "vetoed"
		priority_announce("O5 COUNCIL MEASURE VETOED: [vote.title].", null, null, 'sound/misc/notice1.ogg')

/obj/machinery/o5_council_console/proc/execute_vote_action(datum/o5_vote/vote)
	switch(vote.vote_type)
		if("lockdown")
			for(var/obj/machinery/facility_lockdown_console/L in INSTANCES_OF(/obj/machinery/facility_lockdown_console))
				L.initiate_lockdown(LOCKDOWN_FULL)
		if("mtf_deploy")
			for(var/obj/machinery/mtf_deployment_console/M in INSTANCES_OF(/obj/machinery/mtf_deployment_console))
				if(!M.available_teams || !M.available_teams["mtf_epsilon11"])
					message_admins("O5 MTF deployment failed: No epsilon-11 team data available on [M].")
					continue
				M.deploy_mtf_team("mtf_epsilon11", M.available_teams["mtf_epsilon11"], null)
		if("warhead")
			for(var/obj/machinery/nuclearbomb/N in INSTANCES_OF(/obj/machinery/nuclearbomb))
				if(istype(N, /obj/machinery/nuclearbomb/foundation))
					var/obj/machinery/nuclearbomb/foundation/FN = N
					FN.foundation_authorized = TRUE
		if("evacuation")
			priority_announce("EVACUATION ORDERED BY O5 COUNCIL. ALL NON-ESSENTIAL PERSONNEL PROCEED TO SURFACE EXITS.", null, null, 'sound/misc/airraid.ogg')
		if("general")
			log_game("O5 Council general vote passed: [vote.title]")

/datum/o5_vote
	var/id
	var/title
	var/description
	var/vote_type = "general"
	var/yes_votes = 0
	var/no_votes = 0
	var/required_votes = 3
	var/status = "active"
	var/initiator
	var/list/voted_ckeys = list()

/datum/o5_vote/New(vote_title, vote_desc, vote_initiator, vote_type_input)
	id = world.time
	title = vote_title
	description = vote_desc
	initiator = vote_initiator
	if(vote_type_input)
		vote_type = vote_type_input
