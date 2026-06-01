#define O5_AUDIT_PERSONNEL 1
#define O5_AUDIT_CONTAINMENT 2
#define O5_AUDIT_RESEARCH 3
#define O5_AUDIT_BUDGET 4
#define O5_AUDIT_ETHICS 5

#define O5_DIRECTIVE_REVIEW 1
#define O5_DIRECTIVE_OVERRIDE 2
#define O5_DIRECTIVE_INSPECTION 3

SUBSYSTEM_DEF(o5_council)
	name = "O5 Council"
	flags = SS_NO_FIRE

	var/list/council_directives = list()
	var/list/active_audits = list()
	var/list/inspection_reports = list()
	var/total_directives_issued = 0
	var/total_audits_initiated = 0
	var/total_overrides_issued = 0

/datum/controller/subsystem/o5_council/proc/issue_directive(mob/living/carbon/human/representative, directive_type, target, description, classification)
	if(!representative || !directive_type)
		return
	var/directive_id = "O5-[world.time]-[rand(100,999)]"
	council_directives += list(list(
		"directive_id" = directive_id,
		"issuer" = representative.real_name,
		"issuer_ckey" = representative.ckey,
		"directive_type" = directive_type,
		"target" = target || "",
		"description" = description || "",
		"classification" = classification || "CONFIDENTIAL",
		"status" = "active",
		"time_issued" = world.time,
		"time_completed" = 0,
		"acknowledged_by" = list(),
	))
	total_directives_issued++
	priority_announce("O5 Council Directive [directive_id]: [description]. All department heads acknowledge immediately.", "O5 Council", null, ANNOUNCER_ALERT)
	if(SSdirector_oversight)
		SSdirector_oversight.issue_directive(representative, "Command", directive_type, target, description, 15)
	return directive_id

/datum/controller/subsystem/o5_council/proc/acknowledge_directive(directive_id, mob/living/carbon/human/head)
	for(var/list/D in council_directives)
		if(D["directive_id"] == directive_id && D["status"] == "active")
			D["acknowledged_by"] += list(list(
				"name" = head.real_name,
				"job" = head.job,
				"time" = world.time,
			))
			to_chat(head, span_notice("You have acknowledged O5 Directive [directive_id]."))
			return TRUE
	return FALSE

/datum/controller/subsystem/o5_council/proc/rescind_directive(directive_id)
	for(var/list/D in council_directives)
		if(D["directive_id"] == directive_id && D["status"] == "active")
			D["status"] = "rescinded"
			D["time_completed"] = world.time
			priority_announce("O5 Council Directive [directive_id] has been rescinded.", "O5 Council", null, ANNOUNCER_DEFAULT)
			return TRUE
	return FALSE

/datum/controller/subsystem/o5_council/proc/initiate_audit(mob/living/carbon/human/representative, audit_type, target_department, scope, description)
	if(!representative || !audit_type)
		return
	var/audit_id = "AUDIT-[world.time]-[rand(100,999)]"
	active_audits += list(list(
		"audit_id" = audit_id,
		"initiated_by" = representative.real_name,
		"audit_type" = audit_type,
		"target_department" = target_department || "all",
		"scope" = scope || "full",
		"description" = description || "",
		"status" = "active",
		"time_initiated" = world.time,
		"time_completed" = 0,
		"findings" = list(),
	))
	total_audits_initiated++
	priority_announce("O5 Council Audit [audit_id]: [target_department] department - [description]. All personnel cooperate fully.", "O5 Council", null, ANNOUNCER_ALERT)
	return audit_id

/datum/controller/subsystem/o5_council/proc/submit_audit_finding(audit_id, finding_type, description, severity)
	for(var/list/A in active_audits)
		if(A["audit_id"] == audit_id && A["status"] == "active")
			A["findings"] += list(list(
				"finding_type" = finding_type || "observation",
				"description" = description || "",
				"severity" = severity || 1,
				"time" = world.time,
			))
			return TRUE
	return FALSE

/datum/controller/subsystem/o5_council/proc/complete_audit(audit_id)
	for(var/list/A in active_audits)
		if(A["audit_id"] == audit_id && A["status"] == "active")
			A["status"] = "completed"
			A["time_completed"] = world.time
			if(SSscp_research?.manager)
				SSscp_research?.manager?.adjust_research_points(15, "o5_audit:[audit_id]")
			return TRUE
	return FALSE

/datum/controller/subsystem/o5_council/proc/issue_override(override_type, target, reason, mob/living/carbon/human/representative)
	if(!override_type)
		return
	total_overrides_issued++
	switch(override_type)
		if("security_level")
			if(SSsecurity_level && target)
				var/target_level = text2num(target) || SEC_LEVEL_RED
				set_foundation_security_code(target_level, "O5 Override: [reason]")
		if("ethics_veto")
			if(SSethics_committee && target)
				SSethics_committee.deny_test(target)
		if("budget_freeze")
			if(SSbudget_system?.manager && target)
				var/datum/budget_data/B = SSbudget_system.manager.department_budgets[target]
				if(B)
					B.allocated_budget = 0
					priority_announce("O5 Budget Override: [capitalize(target)] department budget FROZEN. Reason: [reason].", "O5 Council", null, ANNOUNCER_ALERT)
		if("budget_unfreeze")
			if(SSbudget_system?.manager && target)
				var/datum/budget_data/B = SSbudget_system.manager.department_budgets[target]
				if(B)
					B.allocated_budget = B.remaining_budget + B.spent_budget
					priority_announce("O5 Budget Override: [capitalize(target)] department budget UNFROZEN.", "O5 Council", null, ANNOUNCER_DEFAULT)
		if("testing_suspension")
			if(SSscp_testing)
				for(var/id in SSscp_testing.test_proposals)
					var/list/P = SSscp_testing.test_proposals[id]
					if(P["status"] != SCP_TEST_REJECTED && P["status"] != SCP_TEST_COMPLETE)
						SSscp_testing.reject_proposal(id, "O5 Council Suspension: [reason]")
				priority_announce("O5 Testing Override: ALL active SCP testing SUSPENDED by O5 Council. Reason: [reason].", "O5 Council", null, ANNOUNCER_ALERT)
		if("containment_review")
			priority_announce("O5 Containment Review: All SCP containment protocols under immediate review. Reason: [reason].", "O5 Council", null, ANNOUNCER_ALERT)
	log_game("O5 Override: [override_type] target=[target] reason=[reason] by [representative ? representative.real_name : "unknown"]")
	return TRUE

/datum/computer_file/program/scp_o5_terminal
	filename = "scp_o5"
	filedesc = "O5 Council Terminal"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Issue O5 Council directives, initiate facility audits, and exercise override authority."
	size = 3
	tgui_id = "ScpO5Terminal"
	program_icon = "crown"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_ADMIN_LVL5)

/datum/computer_file/program/scp_o5_terminal/ui_data(mob/user)
	var/list/data = get_header_data()
	if(!SSo5_council)
		return data
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		data["access_denied"] = TRUE
		return data
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ADMIN_LVL5 in id_card.access))
		data["access_denied"] = TRUE
		return data
	data["access_denied"] = FALSE
	data["directives"] = SSo5_council.council_directives
	data["audits"] = SSo5_council.active_audits
	data["total_directives"] = SSo5_council.total_directives_issued
	data["total_audits"] = SSo5_council.total_audits_initiated
	data["total_overrides"] = SSo5_council.total_overrides_issued
	data["facility_summary"] = list()
	if(SSdirector_oversight)
		data["facility_summary"]["directives_active"] = length(SSdirector_oversight.active_directives)
		data["facility_summary"]["directives_completed"] = SSdirector_oversight.total_directives_completed
		data["facility_summary"]["directives_overdue"] = SSdirector_oversight.total_overdue
	if(SSfoundation_comms)
		data["facility_summary"]["threat_level"] = SSfoundation_comms.facility_threat_level
		data["facility_summary"]["active_dispatches"] = SSfoundation_comms.active_dispatches
	if(SSscp_persistence?.manager)
		data["facility_summary"]["active_breaches"] = SSscp_persistence.manager.active_breaches
		data["facility_summary"]["containment_stability"] = SSscp_persistence.manager.global_containment_stability
	if(SSbudget_system?.manager)
		data["facility_summary"]["total_budget"] = SSbudget_system.manager.total_budget
		data["facility_summary"]["total_spent"] = 0
		for(var/dept_id in SSbudget_system.manager.department_budgets)
			var/datum/budget_data/D = SSbudget_system.manager.department_budgets[dept_id]
			data["facility_summary"]["total_spent"] += D.spent_budget
	if(SSethics_committee)
		var/pending = 0
		for(var/datum/ethics_violation/V in SSethics_committee.violations)
			if(V.status == ETHICS_STATUS_PENDING)
				pending++
		data["facility_summary"]["ethics_pending"] = pending
	return data

/datum/computer_file/program/scp_o5_terminal/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!SSo5_council)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ADMIN_LVL5 in id_card.access))
		return
	switch(action)
		if("issue_directive")
			SSo5_council.issue_directive(H, params["directive_type"], params["target"], params["description"], params["classification"] || "CONFIDENTIAL")
			. = TRUE
		if("acknowledge_directive")
			SSo5_council.acknowledge_directive(params["directive_id"], H)
			. = TRUE
		if("rescind_directive")
			SSo5_council.rescind_directive(params["directive_id"])
			. = TRUE
		if("initiate_audit")
			SSo5_council.initiate_audit(H, text2num(params["audit_type"]) || O5_AUDIT_PERSONNEL, params["target_department"], params["scope"], params["description"])
			. = TRUE
		if("submit_finding")
			SSo5_council.submit_audit_finding(params["audit_id"], params["finding_type"], params["description"], text2num(params["severity"]) || 1)
			. = TRUE
		if("complete_audit")
			SSo5_council.complete_audit(params["audit_id"])
			. = TRUE
		if("issue_override")
			SSo5_council.issue_override(params["override_type"], params["target"], params["reason"] || "O5 Council Authority", H)
			. = TRUE
		if("print_directive")
			var/directive_id = params["directive_id"]
			if(!directive_id)
				return
			var/list/directive
			for(var/list/D in SSo5_council.council_directives)
				if(D["directive_id"] == directive_id)
					directive = D
					break
			if(!directive)
				return
			var/obj/item/paper/P = new /obj/item/paper(get_turf(H))
			P.setText({"<h2>SCP FOUNDATION - O5 COUNCIL DIRECTIVE</h2><hr>
<b>Directive ID:</b> [directive["directive_id"]]<br>
<b>Date:</b> [time2text(world.time, "MM/DD/YYYY")]<br>
<b>Classification:</b> [directive["classification"]]<br><hr>
<b>Issued By:</b> O5 Council Representative [directive["issuer"]]<br>
<b>Directive Type:</b> [directive["directive_type"]]<br>
<b>Target:</b> [directive["target"] || "All Departments"]<br><hr>
<b>Directive:</b><br>
[directive["description"]]<br><hr>
<b>Acknowledged By:</b><br>
[directive["acknowledged_by"] ? length(directive["acknowledged_by"]) : 0] department heads<br><hr>
<b>Status:</b> [uppertext(directive["status"])]<br>
<b>O5 Representative Signature:</b> [directive["issuer"]] <b>Date:</b> [time2text(directive["time_issued"], "MM/DD/YYYY")]<br>
<br><i>CLASSIFIED - O5 EYES ONLY - CLEARANCE LEVEL 5 REQUIRED</i><br>"}, FALSE)
			P.name = "O5 Council Directive - [directive["directive_type"]]"
			H.put_in_hands(P)
			to_chat(H, span_notice("O5 directive printed."))
			. = TRUE
