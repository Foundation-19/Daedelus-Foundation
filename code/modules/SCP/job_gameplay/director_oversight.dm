#ifndef OVERSIGHT_NONE
#define OVERSIGHT_NONE 0
#define OVERSIGHT_PENDING 1
#define OVERSIGHT_ACTIVE 2
#define OVERSIGHT_COMPLETE 3
#define OVERSIGHT_OVERDUE 4
#endif

SUBSYSTEM_DEF(director_oversight)
	name = "Director Oversight"
	wait = 30 SECONDS
	flags = SS_NO_FIRE

	var/list/directive_queue = list()
	var/list/active_directives = list()
	var/list/completed_directives = list()
	var/list/oversight_log = list()
	var/total_directives_issued = 0
	var/total_directives_completed = 0
	var/total_overdue = 0

/datum/controller/subsystem/director_oversight/proc/issue_directive(mob/living/carbon/human/director, department, directive_type, target, description, deadline_minutes)
	if(!director || !department)
		return
	var/directive_id = "dir_[world.time]_[rand(100,999)]"
	var/deadline_time = world.time + (deadline_minutes MINUTES)
	directive_queue += list(list(
		"directive_id" = directive_id,
		"issuer" = director.real_name,
		"issuer_ckey" = director.ckey,
		"department" = department,
		"directive_type" = directive_type,
		"target" = target,
		"description" = description,
		"deadline" = deadline_time,
		"deadline_text" = "[deadline_minutes] min",
		"status" = OVERSIGHT_PENDING,
		"assigned_to" = "",
		"progress" = 0,
		"time_issued" = world.time,
		"time_completed" = 0,
	))
	total_directives_issued++
	if(SSfoundation_comms)
		SSfoundation_comms.create_dispatch(null, department_to_dispatch(department), "[director.real_name] issued directive: [description]. Report to your supervisor.", 1)
	return directive_id

/datum/controller/subsystem/director_oversight/proc/accept_directive(directive_id, mob/living/carbon/human/assignee)
	for(var/list/D in directive_queue)
		if(D["directive_id"] == directive_id)
			D["status"] = OVERSIGHT_ACTIVE
			D["assigned_to"] = assignee.real_name
			active_directives += list(D)
			directive_queue -= list(D)
			to_chat(assignee, span_notice("<b>DIRECTIVE ACCEPTED:</b> [D["description"]]. Deadline: [round((D["deadline"] - world.time) / 600)] minutes remaining."))
			return TRUE
	return FALSE

/datum/controller/subsystem/director_oversight/proc/update_directive_progress(directive_id, progress)
	for(var/list/D in active_directives)
		if(D["directive_id"] == directive_id)
			D["progress"] = min(100, D["progress"] + progress)
			if(D["progress"] >= 100)
				complete_directive(directive_id)
			return TRUE
	return FALSE

/datum/controller/subsystem/director_oversight/proc/complete_directive(directive_id)
	for(var/list/D in active_directives)
		if(D["directive_id"] == directive_id)
			D["status"] = OVERSIGHT_COMPLETE
			D["time_completed"] = world.time
			D["progress"] = 100
			total_directives_completed++
			completed_directives += list(D)
			active_directives -= list(D)
			if(SSscp_research?.manager)
				SSscp_research?.manager?.adjust_research_points(10, "directive_complete:[D["department"]]")
			if(SSbudget_system?.manager)
				SSbudget_system?.manager?.add_transaction(D["department"], "REVENUE", 100, "personnel", "Directive completed: [D["directive_type"]]")
			return TRUE
	return FALSE

/datum/controller/subsystem/director_oversight/proc/check_overdue()
	for(var/list/D in active_directives)
		if(world.time > D["deadline"] && D["status"] == OVERSIGHT_ACTIVE)
			D["status"] = OVERSIGHT_OVERDUE
			total_overdue++

/datum/controller/subsystem/director_oversight/proc/get_department_directives(department)
	var/list/result = list()
	for(var/list/D in directive_queue)
		if(D["department"] == department)
			result += list(D)
	for(var/list/D in active_directives)
		if(D["department"] == department)
			result += list(D)
	return result

/datum/controller/subsystem/director_oversight/proc/department_to_dispatch(department)
	switch(lowertext(department))
		if("science")
			return 1
		if("security")
			return 1
		if("medical")
			return 2
		if("engineering")
			return 3
		if("command","administration")
			return 1
		if("service","logistics")
			return 1
		if("supply")
			return 1
		if("mtf operations","mtf")
			return 4
	return 1

/datum/controller/subsystem/director_oversight/proc/generate_department_review(department)
	var/list/review = list()
	review["department"] = department
	review["pending_directives"] = 0
	review["active_directives"] = 0
	review["completed_directives"] = 0
	review["overdue_directives"] = 0
	for(var/list/D in directive_queue)
		if(lowertext(D["department"]) == lowertext(department))
			review["pending_directives"]++
	for(var/list/D in active_directives)
		if(lowertext(D["department"]) == lowertext(department))
			if(D["status"] == OVERSIGHT_OVERDUE)
				review["overdue_directives"]++
			else
				review["active_directives"]++
	for(var/list/D in completed_directives)
		if(lowertext(D["department"]) == lowertext(department))
			review["completed_directives"]++
	var/budget_key = lowertext(department)
	if(budget_key == "science")
		budget_key = "research"
	if(budget_key == "administration")
		budget_key = "command"
	if(budget_key == "logistics")
		budget_key = "supply"
	if(budget_key == "mtf operations")
		budget_key = "security"
	if(SSscp_research?.manager)
		review["research_points"] = SSscp_research?.manager?.total_research_points
	if(SSbudget_system?.manager)
		var/datum/budget_data/B = SSbudget_system?.manager?.department_budgets[budget_key]
		if(B)
			review["budget_remaining"] = B.remaining_budget
			review["budget_allocated"] = B.allocated_budget
	if(SScontainment_integrity)
		var/total_integrity = 0
		var/zone_count = 0
		for(var/list/Z in SScontainment_integrity.containment_zones)
			total_integrity += Z["integrity"]
			zone_count++
		if(zone_count > 0)
			review["containment_integrity"] = round(total_integrity / zone_count)
	return review

/datum/computer_file/program/scp_director_oversight
	filename = "scp_oversight"
	filedesc = "Director Oversight Console"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Issue department directives, track compliance, review department status."
	size = 3
	tgui_id = "ScpDirectorOversight"
	program_icon = "clipboard-check"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_ADMIN)

/datum/computer_file/program/scp_director_oversight/ui_data(mob/user)
	var/list/data = get_header_data()
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		data["access_denied"] = TRUE
		return data
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ADMIN in id_card.access))
		data["access_denied"] = TRUE
		return data
	data["access_denied"] = FALSE
	if(SSdirector_oversight)
		data["directive_queue"] = SSdirector_oversight.directive_queue
		data["active_directives"] = SSdirector_oversight.active_directives
		var/list/recent = list()
		var/start = max(1, length(SSdirector_oversight.completed_directives) - 15)
		for(var/i = start to length(SSdirector_oversight.completed_directives))
			recent += list(SSdirector_oversight.completed_directives[i])
		data["completed_directives"] = recent
		data["total_directives_issued"] = SSdirector_oversight.total_directives_issued
		data["total_directives_completed"] = SSdirector_oversight.total_directives_completed
		data["total_overdue"] = SSdirector_oversight.total_overdue
		var/list/reviews = list()
		for(var/dept in list("Science", "Security", "Medical", "Engineering", "Logistics", "Administration", "MTF Operations"))
			reviews += list(SSdirector_oversight.generate_department_review(dept))
		data["department_reviews"] = reviews
	return data

/datum/computer_file/program/scp_director_oversight/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ADMIN in id_card.access))
		return
	if(!SSdirector_oversight)
		return
	switch(action)
		if("issue_directive")
			var/deadline = text2num(params["deadline"]) || 10
			SSdirector_oversight.issue_directive(H, params["department"], params["directive_type"], params["target"], params["description"], deadline)
			. = TRUE
		if("accept_directive")
			SSdirector_oversight.accept_directive(params["directive_id"], H)
			. = TRUE
		if("update_progress")
			var/progress = text2num(params["progress"]) || 25
			SSdirector_oversight.update_directive_progress(params["directive_id"], progress)
			. = TRUE
		if("complete_directive")
			SSdirector_oversight.complete_directive(params["directive_id"])
			. = TRUE
