/datum/dclass_riot
	var/stage = 0
	var/list/demands = list()
	var/list/rioting_dclass = list()
	var/list/willing_dclass = list()
	var/negotiator
	var/negotiation_progress = 0
	var/suppression_progress = 0
	var/timer_until_escalation = 0
	var/last_reject_time = 0
	var/last_action_time = 0
	var/riot_active = FALSE
	var/partial_win = FALSE
	var/list/met_demands = list()

	var/static/list/demand_pool = list(
		"Better food rations",
		"Reduced experiment frequency",
		"Freedom of movement in LCZ",
		"Access to medical care",
		"Transfer to minimum security",
		"End of mandatory testing",
	)

/datum/dclass_riot/proc/start_riot()
	if(riot_active)
		return
	riot_active = TRUE
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(findtext(H.job, "D-Class"))
			add_verb(H, list(/mob/living/carbon/human/proc/join_riot, /mob/living/carbon/human/proc/refuse_riot))
	stage = 1
	var/num_demands = rand(2, 3)
	demands = list()
	for(var/i in 1 to num_demands)
		var/demand = pick(demand_pool - demands)
		demands += demand
	met_demands = list()
	timer_until_escalation = 1800
	collect_rioting_dclass()
	log_game("D-Class Riot started with [length(rioting_dclass)] rioters")
	for(var/mob/living/carbon/human/H in rioting_dclass)
		if(H.stat == DEAD)
			continue
		to_chat(H, span_warning("You feel a surge of defiance. The D-Class are organizing. You can join the unrest with the 'Join Riot' verb or stay out of it."))
		RegisterSignal(H, COMSIG_LIVING_DEATH, PROC_REF(on_dclass_death))
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.stat == DEAD || !H.client)
			continue
		var/obj/item/card/id/id_card = H.get_idcard(TRUE)
		if(id_card && (ACCESS_SECURITY in id_card.access))
			to_chat(H, span_danger("The D-Class are refusing to follow orders!"))
			if(H.sanity)
				H.sanity.adjust_sanity(-10, "dclass_unrest")
	priority_announce("D-Class unrest has been detected in the facility. Security personnel are advised to monitor the situation.", null, null, ANNOUNCER_ALERT)
	hook_storytelling_riot(1)
	if(SSfoundation_politics?.manager)
		SSfoundation_politics.manager.political_tensions = min(100, SSfoundation_politics.manager.political_tensions + 10)

/datum/dclass_riot/proc/collect_rioting_dclass()
	rioting_dclass = list()
	willing_dclass = list()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.stat == DEAD || !H.client)
			continue
		if(findtext(H.job, "D-Class"))
			willing_dclass += H
			if(H.combat_mode || prob(60))
				rioting_dclass += H

/datum/dclass_riot/proc/on_dclass_death(mob/living/L)
	SIGNAL_HANDLER
	rioting_dclass -= L
	willing_dclass -= L
	if(length(rioting_dclass) == 0 && riot_active)
		end_riot(TRUE)

/datum/dclass_riot/proc/dclass_join(mob/living/carbon/human/H)
	if(!istype(H) || H.stat == DEAD)
		return FALSE
	if(H in rioting_dclass)
		to_chat(H, span_notice("You are already part of the unrest."))
		return FALSE
	rioting_dclass += H
	willing_dclass += H
	RegisterSignal(H, COMSIG_LIVING_DEATH, PROC_REF(on_dclass_death))
	to_chat(H, span_warning("You join the D-Class uprising!"))
	return TRUE

/datum/dclass_riot/proc/dclass_refuse(mob/living/carbon/human/H)
	if(!istype(H) || H.stat == DEAD)
		return FALSE
	rioting_dclass -= H
	to_chat(H, span_notice("You step back from the unrest. You'll follow orders."))
	return TRUE

/datum/dclass_riot/proc/tick()
	if(!riot_active)
		return
	timer_until_escalation -= 50
	if(timer_until_escalation <= 0)
		escalate_riot()
		timer_until_escalation = max(200, 1800 - (stage * 200))
	collect_rioting_dclass()

/datum/dclass_riot/proc/escalate_riot()
	if(stage >= 4)
		return
	stage++
	switch(stage)
		if(2)
			priority_announce("D-Class personnel are protesting in the cell blocks. Demands have been issued: [english_list(demands)].", null, null, ANNOUNCER_ALERT)
			for(var/mob/living/carbon/human/H in rioting_dclass)
				if(QDELETED(H) || H.stat == DEAD)
					continue
				to_chat(H, span_warning("You gather with the other D-Class, raising your voices in protest!"))
			if(prob(20))
				priority_announce("D-Class property damage reported in the cell block area.", null, null, ANNOUNCER_ALERT)
		if(3)
			priority_announce("ALERT: D-Class riot in progress! Security personnel engage immediately. Containment integrity at risk.", null, null, ANNOUNCER_ALERT)
			for(var/mob/living/carbon/human/H in rioting_dclass)
				if(QDELETED(H) || H.stat == DEAD)
					continue
				to_chat(H, span_danger("The riot has escalated! Fight for your freedom!"))
			if(prob(30))
				var/list/valid_airlocks = list()
				for(var/obj/machinery/door/airlock/AL in INSTANCES_OF(/obj/machinery/door/airlock))
					if(QDELETED(AL))
						continue
					var/area/A = get_area(AL)
					if(istype(A, /area/scp/dclass) || istype(A, /area/scp/lcz))
						valid_airlocks += AL
				if(length(valid_airlocks))
					var/obj/machinery/door/airlock/target = pick(valid_airlocks)
					if(!QDELETED(target) && target.density)
						target.open()
					priority_announce("Door breach detected near D-Class areas!", null, null, ANNOUNCER_ALERT)
		if(4)
			priority_announce("CRITICAL: D-Class armed uprising in progress! All security personnel respond with lethal force authorized. Containment breach imminent.", null, null, ANNOUNCER_ALERT)
			for(var/mob/living/carbon/human/H in rioting_dclass)
				if(QDELETED(H) || H.stat == DEAD)
					continue
				to_chat(H, span_userdanger("You have weapons now. This is the final stand!"))
			if(SSscp_chain_breach)
				for(var/datum/scp_chain_breach/CB in SSscp_chain_breach.chain_breaches)
					if(CB.breach_id == "riot_cascade" && !CB.triggered)
						CB.evaluate_condition("dclass_riot_active")
	hook_storytelling_riot(stage)
	if(SSfoundation_politics?.manager)
		SSfoundation_politics.manager.political_tensions = min(100, SSfoundation_politics.manager.political_tensions + 5)
		SSfoundation_politics.manager.spend_budget("security", 2000 * stage, "D-Class Riot Escalation")

/datum/dclass_riot/proc/attempt_negotiation(mob/negotiator_mob)
	if(!istype(negotiator_mob, /mob/living/carbon/human))
		return FALSE
	var/mob/living/carbon/human/H = negotiator_mob
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card)
		return FALSE
	if(!(ACCESS_SECURITY in id_card.access))
		to_chat(H, span_warning("You lack the required access to negotiate with the D-Class."))
		return FALSE
	if(negotiator)
		to_chat(H, span_warning("Someone is already negotiating with the D-Class."))
		return FALSE
	negotiator = H
	negotiation_progress = 0
	to_chat(H, span_notice("You begin negotiating with the D-Class rioters."))
	priority_announce("Negotiations with D-Class rioters have begun.", null, null, ANNOUNCER_DEFAULT)
	return TRUE

/datum/dclass_riot/proc/progress_negotiation(amount)
	negotiation_progress = min(100, negotiation_progress + amount)
	if(negotiation_progress >= 100)
		if(stage > 1)
			stage--
			negotiation_progress = 0
			priority_announce("D-Class rioters have agreed to de-escalate. Current stage: [stage].", null, null, ANNOUNCER_DEFAULT)
			if(stage <= 1)
				end_riot(FALSE)
		else
			end_riot(FALSE)

/datum/dclass_riot/proc/meet_demand(demand)
	if(!(demand in demands))
		return FALSE
	if(demand in met_demands)
		return FALSE
	met_demands += demand
	negotiation_progress = min(100, negotiation_progress + 40)
	for(var/mob/living/carbon/human/H in rioting_dclass)
		if(QDELETED(H) || H.stat == DEAD)
			continue
		to_chat(H, span_notice("The Foundation has agreed to: [demand]. Some rioters calm down."))
	priority_announce("The Foundation has partially met D-Class demands: [demand].", null, null, ANNOUNCER_DEFAULT)
	if(length(met_demands) >= length(demands) || negotiation_progress >= 100)
		partial_win = TRUE
		end_riot(FALSE)
	return TRUE

/datum/dclass_riot/proc/suppress_riot(amount)
	suppression_progress = min(100, suppression_progress + amount)
	if(suppression_progress >= 100)
		end_riot(TRUE)

/datum/dclass_riot/proc/end_riot(violent)
	riot_active = FALSE
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		remove_verb(H, list(/mob/living/carbon/human/proc/join_riot, /mob/living/carbon/human/proc/refuse_riot))
	var/old_stage = stage
	log_game("D-Class Riot ended: [partial_win ? "partial win" : "suppressed"]")
	stage = 0
	for(var/mob/living/carbon/human/H in rioting_dclass)
		UnregisterSignal(H, COMSIG_LIVING_DEATH)
	if(violent)
		priority_announce("D-Class riot has been suppressed by force. Multiple casualties reported.", null, null, ANNOUNCER_ALERT)
		for(var/mob/living/carbon/human/H in rioting_dclass)
			if(QDELETED(H) || H.stat == DEAD)
				continue
			if(prob(40))
				H.adjustBruteLoss(rand(30, 80))
				log_combat(null, H, "riotsuppressed", addition="D-Class riot suppression damage")
		for(var/mob/living/carbon/human/H in GLOB.player_list)
			if(QDELETED(H))
				continue
			if(H.stat == DEAD || !H.client)
				continue
			var/obj/item/card/id/id_card = H.get_idcard(TRUE)
			if(id_card && (ACCESS_SECURITY in id_card.access) && prob(30))
				H.adjustBruteLoss(rand(10, 30))
				log_combat(null, H, "riotsuppressed", addition="D-Class riot collateral damage")
	else
		if(partial_win || length(met_demands) > 0)
			priority_announce("D-Class unrest has been resolved through negotiation. Demands partially met: [english_list(met_demands)].", null, null, ANNOUNCER_DEFAULT)
		else
			priority_announce("D-Class unrest has been resolved peacefully. Demands have been partially addressed.", null, null, ANNOUNCER_DEFAULT)
	if(SSfoundation_politics?.manager)
		if(violent)
			SSfoundation_politics.manager.political_tensions = min(100, SSfoundation_politics.manager.political_tensions + 15)
			SSfoundation_politics.manager.spend_budget("security", 5000 * old_stage, "D-Class Riot Aftermath")
		else
			SSfoundation_politics.manager.political_tensions = max(0, SSfoundation_politics.manager.political_tensions - 10)
	rioting_dclass = list()
	willing_dclass = list()
	demands = list()
	met_demands = list()
	negotiator = null
	negotiation_progress = 0
	suppression_progress = 0
	partial_win = FALSE

/datum/dclass_riot/proc/get_riot_status()
	if(!riot_active)
		return "No active riot."
	var/stage_name = list("Inactive", "Unrest", "Protest", "Riot", "Armed Uprising")
	var/status = "Stage: [stage_name[min(stage + 1, length(stage_name))]]<br>"
	status += "Escalation Timer: [timer_until_escalation / 10]s<br>"
	status += "Demands: [english_list(demands)]<br>"
	status += "Met Demands: [english_list(met_demands)]<br>"
	status += "Rioting D-Class: [length(rioting_dclass)]<br>"
	status += "Negotiation Progress: [negotiation_progress]%<br>"
	status += "Suppression Progress: [suppression_progress]%<br>"
	return status

/datum/round_event_control/dclass_riot
	name = "D-Class Riot"
	typepath = /datum/round_event/dclass_riot
	max_occurrences = 2
	weight = 10
	earliest_start = 20 MINUTES

/datum/round_event/dclass_riot
	var/datum/dclass_riot/riot

/datum/round_event/dclass_riot/setup()
	startWhen = 1
	announceWhen = 1
	endWhen = 50

/datum/round_event/dclass_riot/announce(fake)
	priority_announce("ALERT: D-Class unrest is escalating in the facility. All security personnel prepare for riot response.", null, null, ANNOUNCER_ALERT)

/datum/round_event/dclass_riot/start()
	riot = new /datum/dclass_riot()
	riot.start_riot()
	if(SSdclass_riot)
		SSdclass_riot.current_riot = riot
		SSdclass_riot.flags &= ~SS_NO_FIRE

SUBSYSTEM_DEF(dclass_riot)
	name = "D-Class Riot"
	flags = SS_NO_FIRE
	wait = 5 SECONDS
	init_order = INIT_ORDER_DEFAULT
	var/datum/dclass_riot/current_riot = null

/datum/controller/subsystem/dclass_riot/fire(resumed)
	if(current_riot && current_riot.riot_active)
		current_riot.tick()
	else
		if(current_riot)
			current_riot = null
		flags |= SS_NO_FIRE

/datum/controller/subsystem/dclass_riot/proc/can_start_riot()
	if(current_riot && current_riot.riot_active)
		return FALSE
	var/dclass_count = 0
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.stat == DEAD || !H.client)
			continue
		if(findtext(H.job, "D-Class"))
			dclass_count++
	if(dclass_count < 3)
		return FALSE
	return TRUE

/datum/controller/subsystem/dclass_riot/proc/trigger_riot_check()
	if(!can_start_riot())
		return FALSE
	var/chance = 10
	if(!prob(chance))
		return FALSE
	current_riot = new /datum/dclass_riot()
	current_riot.start_riot()
	flags &= ~SS_NO_FIRE
	return TRUE

/mob/living/carbon/human/proc/join_riot()
	set name = "Join Riot"
	set category = "D-Class"
	set desc = "Join the D-Class riot."
	set hidden = TRUE
	if(!findtext(job, "D-Class"))
		return
	if(!SSdclass_riot || !SSdclass_riot.current_riot || !SSdclass_riot.current_riot.riot_active)
		to_chat(src, span_warning("There is no active riot to join."))
		return
	SSdclass_riot.current_riot.dclass_join(src)

/mob/living/carbon/human/proc/refuse_riot()
	set name = "Refuse Riot"
	set category = "D-Class"
	set desc = "Refuse to participate in the D-Class riot."
	set hidden = TRUE
	if(!findtext(job, "D-Class"))
		return
	if(!SSdclass_riot || !SSdclass_riot.current_riot || !SSdclass_riot.current_riot.riot_active)
		to_chat(src, span_notice("There is no active riot."))
		return
	SSdclass_riot.current_riot.dclass_refuse(src)

/obj/machinery/computer/dclass_riot_console
	name = "D-Class Riot Control Console"
	desc = "A secure console for monitoring and responding to D-Class riots."
	icon = 'icons/obj/modular_console.dmi'
	icon_state = "console"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 200
	req_access = list(ACCESS_SECURITY)

/obj/machinery/computer/dclass_riot_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DClassRiotConsole", "D-Class Riot Control")
		ui.open()

/obj/machinery/computer/dclass_riot_console/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/dclass_riot_console/ui_data(mob/user)
	var/list/data = list()
	if(SSdclass_riot && SSdclass_riot.current_riot)
		var/datum/dclass_riot/riot = SSdclass_riot.current_riot
		data["riot_active"] = riot.riot_active
		data["stage"] = riot.stage
		data["demands"] = riot.demands
		data["met_demands"] = riot.met_demands
		data["rioting_count"] = length(riot.rioting_dclass)
		data["negotiation_progress"] = riot.negotiation_progress
		data["suppression_progress"] = riot.suppression_progress
		data["escalation_timer"] = riot.timer_until_escalation
		data["has_negotiator"] = riot.negotiator ? TRUE : FALSE
		data["partial_win"] = riot.partial_win
	else
		data["riot_active"] = FALSE
		data["stage"] = 0
		data["demands"] = list()
		data["met_demands"] = list()
		data["rioting_count"] = 0
		data["negotiation_progress"] = 0
		data["suppression_progress"] = 0
		data["escalation_timer"] = 0
		data["has_negotiator"] = FALSE
		data["partial_win"] = FALSE
	return data

/obj/machinery/computer/dclass_riot_console/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/user = ui.user
	if(.)
		return

	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_SECURITY in id_card.access))
		to_chat(H, span_warning("Access denied."))
		return

	if(!SSdclass_riot || !SSdclass_riot.current_riot || !SSdclass_riot.current_riot.riot_active)
		return

	var/datum/dclass_riot/riot = SSdclass_riot.current_riot

	switch(action)
		if("negotiate")
			riot.attempt_negotiation(H)
			. = TRUE
		if("authorize_suppression")
			if(riot.last_action_time && (world.time - riot.last_action_time) < 10 SECONDS)
				to_chat(H, span_warning("Action cooldown in effect. Wait a moment."))
				return
			riot.last_action_time = world.time
			riot.suppress_riot(25)
			to_chat(H, span_notice("Suppression forces authorized. Progress: [riot.suppression_progress]%"))
			. = TRUE
		if("accept_demands")
			if(riot.last_action_time && (world.time - riot.last_action_time) < 10 SECONDS)
				to_chat(H, span_warning("Action cooldown in effect. Wait a moment."))
				return
			riot.last_action_time = world.time
			riot.progress_negotiation(30)
			to_chat(H, span_notice("Demands partially accepted. Negotiation progress: [riot.negotiation_progress]%"))
			. = TRUE
		if("meet_demand")
			var/demand = params["demand"]
			if(demand)
				riot.meet_demand(demand)
				. = TRUE
		if("reject_demands")
			if(riot.last_reject_time && (world.time - riot.last_reject_time) < 30 SECONDS)
				to_chat(H, span_warning("Demands were recently rejected. The rioters won't listen again so soon."))
				return
			riot.last_reject_time = world.time
			if(riot.stage < 4)
				riot.escalate_riot()
			else
				to_chat(H, span_warning("The rioters are past negotiations. Only force will end this now."))
			to_chat(H, span_warning("Demands rejected. The situation escalates!"))
			. = TRUE
