SUBSYSTEM_DEF(security_director)
	name = "Security Director"
	flags = SS_NO_FIRE

	var/list/alert_codes = list()
	var/list/security_directives = list()
	var/list/breach_response_plans = list()
	var/total_directives_issued = 0
	var/total_codes_activated = 0
	var/total_responses_coordinated = 0
	var/average_response_time = 0

/datum/controller/subsystem/security_director/proc/issue_directive(mob/living/carbon/human/director, directive_type, target, description, priority)
	if(!director || !directive_type)
		return
	var/directive_id = "secdir_[world.time]_[rand(100,999)]"
	security_directives += list(list(
		"directive_id" = directive_id,
		"issuer" = director.real_name,
		"issuer_ckey" = director.ckey,
		"directive_type" = directive_type,
		"target" = target || "",
		"description" = description || "",
		"priority" = priority || 0,
		"status" = "active",
		"time_issued" = world.time,
		"time_completed" = 0,
		"responders" = list(),
	))
	total_directives_issued++
	if(SSfoundation_comms)
		SSfoundation_comms.create_dispatch(director, DISPATCH_SECURITY, "Security Directive: [description]. All security personnel acknowledge.", priority || 1)
	if(SSdirector_oversight)
		SSdirector_oversight.issue_directive(director, "Security", directive_type, target, description, 10)
	return directive_id

/datum/controller/subsystem/security_director/proc/acknowledge_directive(directive_id, mob/living/carbon/human/responder)
	for(var/list/D in security_directives)
		if(D["directive_id"] == directive_id && D["status"] == "active")
			D["responders"] += list(list(
				"name" = responder.real_name,
				"ckey" = responder.ckey,
				"time" = world.time,
			))
			to_chat(responder, span_notice("You have acknowledged directive [directive_id]."))
			return TRUE
	return FALSE

/datum/controller/subsystem/security_director/proc/complete_directive(directive_id)
	for(var/list/D in security_directives)
		if(D["directive_id"] == directive_id && D["status"] == "active")
			D["status"] = "completed"
			D["time_completed"] = world.time
			if(SSscp_research?.manager)
				SSscp_research?.manager?.adjust_research_points(5, "security_directive:[directive_id]")
			return TRUE
	return FALSE

/datum/controller/subsystem/security_director/proc/activate_alert_code(code_type, scope, reason, mob/living/carbon/human/activator)
	if(!code_type)
		return
	var/code_id = "code_[world.time]_[rand(10,99)]"
	alert_codes += list(list(
		"code_id" = code_id,
		"code_type" = code_type,
		"scope" = scope || "facility",
		"reason" = reason || "",
		"activated_by" = activator ? activator.real_name : "Automated",
		"time_activated" = world.time,
		"time_deactivated" = 0,
		"status" = "active",
	))
	total_codes_activated++
	var/announcement = ""
	switch(code_type)
		if("lockdown")
			announcement = "SECURITY CODE: LOCKDOWN - [scope] - [reason]. All personnel remain in designated areas. Security teams mobilize."
			if(SSsecurity_level && SSsecurity_level.current_level < SEC_LEVEL_RED)
				set_foundation_security_code(SEC_LEVEL_RED, "Security Code: Lockdown - [reason]")
		if("sweep")
			announcement = "SECURITY CODE: SWEEP - [scope] - [reason]. Security teams begin systematic sweep of designated areas."
		if("perimeter")
			announcement = "SECURITY CODE: PERIMETER - [scope] - [reason]. Security teams secure all entry and exit points."
		if("stand_down")
			announcement = "SECURITY CODE: STAND DOWN - [scope] - [reason]. All security codes deactivated. Resume normal operations."
			for(var/list/C in alert_codes)
				if(C["status"] == "active")
					C["status"] = "deactivated"
					C["time_deactivated"] = world.time
	priority_announce(announcement, "Security Director", null, code_type == "lockdown" ? ANNOUNCER_ALERT : ANNOUNCER_DEFAULT)
	return code_id

/datum/controller/subsystem/security_director/proc/coordinate_breach_response(scp_id, response_type, mob/living/carbon/human/director)
	if(!scp_id)
		return
	var/plan_id = "plan_[world.time]_[rand(100,999)]"
	breach_response_plans += list(list(
		"plan_id" = plan_id,
		"scp_id" = scp_id,
		"response_type" = response_type || "standard",
		"coordinator" = director ? director.real_name : "Automated",
		"time_created" = world.time,
		"status" = "active",
		"teams_dispatched" = list(),
	))
	total_responses_coordinated++
	if(SSfoundation_comms)
		switch(response_type)
			if("standard")
				SSfoundation_comms.create_dispatch(director, DISPATCH_SECURITY, "Breach Response: SCP-[scp_id]. Standard containment protocol. All security personnel respond.", 2)
			if("evacuation")
				SSfoundation_comms.create_dispatch(director, DISPATCH_SECURITY, "Breach Response: SCP-[scp_id]. EVACUATION protocol. All non-essential personnel evacuate containment zones.", 2)
				SSfoundation_comms.create_dispatch(director, DISPATCH_MTF, "Breach Response: SCP-[scp_id]. MTF deployment authorized. Evacuation in effect.", 2)
			if("full_containment")
				SSfoundation_comms.create_dispatch(director, DISPATCH_SECURITY, "Breach Response: SCP-[scp_id]. FULL CONTAINMENT protocol. All security personnel to combat stations.", 2)
				SSfoundation_comms.create_dispatch(director, DISPATCH_MTF, "Breach Response: SCP-[scp_id]. Full containment authorized. All MTF teams deploy immediately.", 2)
	if(SSscp_patrol)
		SSscp_patrol.respond_to_breach(director ? director.ckey : "system", scp_id)
	return plan_id

/datum/controller/subsystem/security_director/proc/get_security_status()
	var/list/status = list()
	status["active_codes"] = 0
	status["active_directives"] = 0
	status["active_plans"] = 0
	status["guards_on_duty"] = 0
	for(var/list/C in alert_codes)
		if(C["status"] == "active")
			status["active_codes"]++
	for(var/list/D in security_directives)
		if(D["status"] == "active")
			status["active_directives"]++
	for(var/list/P in breach_response_plans)
		if(P["status"] == "active")
			status["active_plans"]++
	for(var/mob/living/carbon/human/H in GLOB.mob_list)
		if(H.mind && (H.job in list("LCZ Guard", "HCZ Guard", "EZ Agent", "LCZ Cadet", "HCZ Private", "EZ Probationary Agent", "LCZ Sergeant", "HCZ Sergeant", "EZ Senior Agent", "LCZ Zone Junior Lieutenant", "HCZ Zone Senior Lieutenant", "EZ Zone Supervisor", "Guard Commander", "Security Director")))
			status["guards_on_duty"]++
	return status

/datum/computer_file/program/scp_security_director
	filename = "scp_secdir"
	filedesc = "Security Director Console"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Manage security directives, alert codes, and breach response coordination."
	size = 3
	tgui_id = "ScpSecurityDirector"
	program_icon = "shield-alt"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_ADMIN_LVL3)

/datum/computer_file/program/scp_security_director/ui_data(mob/user)
	var/list/data = get_header_data()
	if(!SSsecurity_director)
		return data
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		data["access_denied"] = TRUE
		return data
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ADMIN_LVL3 in id_card.access))
		data["access_denied"] = TRUE
		return data
	data["access_denied"] = FALSE
	data["directives"] = SSsecurity_director.security_directives
	data["alert_codes"] = SSsecurity_director.alert_codes
	data["response_plans"] = SSsecurity_director.breach_response_plans
	data["total_directives_issued"] = SSsecurity_director.total_directives_issued
	data["total_codes_activated"] = SSsecurity_director.total_codes_activated
	data["total_responses_coordinated"] = SSsecurity_director.total_responses_coordinated
	var/list/sec_status = SSsecurity_director.get_security_status()
	data["active_codes"] = sec_status["active_codes"]
	data["active_directives"] = sec_status["active_directives"]
	data["active_plans"] = sec_status["active_plans"]
	data["guards_on_duty"] = sec_status["guards_on_duty"]
	data["patrol_stats"] = list()
	if(SSscp_patrol)
		data["patrol_stats"] = list(
			"total_patrols" = SSscp_patrol.total_patrols_completed,
			"total_anomalies" = SSscp_patrol.total_anomalies_reported,
			"total_breach_responses" = SSscp_patrol.total_breach_responses,
			"total_contraband" = SSscp_patrol.total_contraband_seized,
			"zone_threats" = list(
				"lcz" = SSscp_patrol.get_zone_threat_level("lcz"),
				"hcz" = SSscp_patrol.get_zone_threat_level("hcz"),
				"ez" = SSscp_patrol.get_zone_threat_level("ez"),
			),
		)
	data["threat_level"] = SSfoundation_comms ? SSfoundation_comms.facility_threat_level : 0
	data["containment_status"] = list()
	if(SScontainment_integrity)
		data["containment_status"] = list(
			"overall" = SScontainment_integrity.overall_integrity,
			"overdue_tasks" = SScontainment_integrity.overdue_tasks,
			"zones" = SScontainment_integrity.containment_zones,
		)
	return data

/datum/computer_file/program/scp_security_director/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!SSsecurity_director)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ADMIN_LVL3 in id_card.access))
		return
	switch(action)
		if("issue_directive")
			SSsecurity_director.issue_directive(H, params["directive_type"], params["target"], params["description"], text2num(params["priority"]) || 0)
			. = TRUE
		if("acknowledge_directive")
			SSsecurity_director.acknowledge_directive(params["directive_id"], H)
			. = TRUE
		if("complete_directive")
			SSsecurity_director.complete_directive(params["directive_id"])
			. = TRUE
		if("activate_code")
			SSsecurity_director.activate_alert_code(params["code_type"], params["scope"] || "facility", params["reason"] || "", H)
			. = TRUE
		if("coordinate_response")
			SSsecurity_director.coordinate_breach_response(params["scp_id"], params["response_type"], H)
			. = TRUE
		if("print_directive")
			var/directive_id = params["directive_id"]
			if(!directive_id)
				return
			var/list/directive
			for(var/list/D in SSsecurity_director.security_directives)
				if(D["directive_id"] == directive_id)
					directive = D
					break
			if(!directive)
				return
			var/obj/item/paper/foundation/incident_report/P = new /obj/item/paper/foundation/incident_report(get_turf(H))
			P.setText({"<h2>SCP FOUNDATION - SECURITY DIRECTIVE</h2><hr>
<b>Directive ID:</b> [directive["directive_id"]]<br>
<b>Date:</b> [time2text(world.time, "MM/DD/YYYY")]<br>
<b>Facility:</b> Site-53<br><hr>
<b>Issued By:</b> [directive["issuer"]]<br>
<b>Directive Type:</b> [directive["directive_type"]]<br>
<b>Target:</b> [directive["target"] || "N/A"]<br>
<b>Priority:</b> [directive["priority"] > 0 ? "HIGH" : "STANDARD"]<br><hr>
<b>Description:</b><br>
[directive["description"]]<br><hr>
<b>Responders:</b><br>
[directive["responders"] ? length(directive["responders"]) : 0] acknowledged<br><hr>
<b>Status:</b> [uppertext(directive["status"])]<br>
<b>Director Signature:</b> [directive["issuer"]] <b>Date:</b> [time2text(directive["time_issued"], "MM/DD/YYYY")]<br>
<br><i>CLASSIFIED - SECURITY CLEARANCE LEVEL 3+ REQUIRED</i><br>"}, FALSE)
			P.name = "Security Directive - [directive["directive_type"]] - [directive["target"] || "General"]"
			H.put_in_hands(P)
			to_chat(H, span_notice("Directive printed."))
			. = TRUE
