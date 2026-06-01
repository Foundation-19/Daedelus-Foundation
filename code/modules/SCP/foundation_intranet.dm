/obj/machinery/computer/foundation_intranet
	name = "Foundation Intranet Terminal"
	desc = "A secure terminal connected to the Foundation's internal network."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 100

	var/current_section = "home"
	var/list/access_logs = list()
	var/clearance_level = 0

/obj/machinery/computer/foundation_intranet/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NtosFoundationIntranet", "FOUNDATION INTRANET")
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/computer/foundation_intranet/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/foundation_intranet/ui_data(mob/user)
	var/list/data = list()
	data["current_section"] = current_section
	data["access_logs"] = access_logs

	var/mob/living/carbon/human/H = user
	if(ishuman(H))
		var/obj/item/card/id/id_card = H.get_idcard(TRUE)
		if(id_card)
			if(ACCESS_ADMIN_LVL5 in id_card.access)
				clearance_level = 5
			else if(ACCESS_ADMIN_LVL4 in id_card.access)
				clearance_level = 4
			else if(ACCESS_ADMIN in id_card.access)
				clearance_level = 3
			else if(ACCESS_SCIENCE in id_card.access)
				clearance_level = 2
			else
				clearance_level = 1

	data["clearance_level"] = clearance_level

	var/list/sections = list()
	sections += list(list("id" = "home", "name" = "Home", "min_clearance" = 1))
	sections += list(list("id" = "scp_database", "name" = "SCP Database", "min_clearance" = 2))
	sections += list(list("id" = "personnel", "name" = "Personnel Records", "min_clearance" = 2))
	sections += list(list("id" = "containment", "name" = "Containment Status", "min_clearance" = 2))
	sections += list(list("id" = "incident_reports", "name" = "Incident Reports", "min_clearance" = 3))
	sections += list(list("id" = "research", "name" = "Research Data", "min_clearance" = 2))
	sections += list(list("id" = "cross_interactions", "name" = "Cross-Anomaly Data", "min_clearance" = 3))
	sections += list(list("id" = "amnestic_log", "name" = "Amnestic Records", "min_clearance" = 3))
	sections += list(list("id" = "classified", "name" = "Classified", "min_clearance" = 5))
	data["sections"] = sections

	var/list/scp_data = list()
	if(clearance_level >= 2)
		var/list/scp_ids = list("SCP-173", "SCP-049", "SCP-096", "SCP-106", "SCP-682", "SCP-079", "SCP-939", "SCP-457", "SCP-035", "SCP-008", "SCP-914", "SCP-999")
		for(var/scp_id in scp_ids)
			var/status = "contained"
			var/obj_class = "Safe"
			if(SSscp_persistence?.manager?.scp_instances?[scp_id])
				var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances[scp_id]
				status = instance.containment_status
				obj_class = instance.containment_class
			scp_data += list(list("id" = scp_id, "status" = status, "class" = obj_class))
	data["scp_data"] = scp_data

	var/list/breach_data = list()
	if(SSscp_persistence?.manager)
		for(var/scp_id in SSscp_persistence?.manager?.scp_instances)
			var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances[scp_id]
			if(instance.containment_status == "breached")
				breach_data += list(list("id" = scp_id, "class" = instance.containment_class, "breach_time" = instance.last_breach))
	data["active_breaches"] = breach_data

	var/list/cross_interaction_data = list()
	if(clearance_level >= 3 && SSscp_cross_interactions?.setup_complete)
		for(var/interaction_id in SSscp_cross_interactions.interactions)
			var/datum/cross_scp_interaction/I = SSscp_cross_interactions.interactions[interaction_id]
			if(!I.discovered)
				continue
			if(I.tier > clearance_level)
				continue
			cross_interaction_data += list(list(
				"name" = I.name,
				"scp1" = I.scp_id_1,
				"scp2" = I.scp_id_2,
				"tier" = I.tier,
				"description" = I.description,
				"triggers" = I.trigger_count,
				"discovered_by" = I.discovered_by || "Foundation Research"
			))
	data["cross_interactions"] = cross_interaction_data

	return data

/obj/machinery/computer/foundation_intranet/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("set_section")
			current_section = params["section"]
			access_logs += "Accessed [current_section] (Clearance: [clearance_level])"
			. = TRUE
		if("submit_report")
			var/report_type = params["type"]
			var/report_text = params["text"]
			if(!report_text)
				return
			access_logs += "Submitted [report_type] report"
			priority_announce("Foundation Intranet: New [report_type] report submitted. Command staff review requested.", "INTRANET NOTIFICATION", null, null)
			. = TRUE
