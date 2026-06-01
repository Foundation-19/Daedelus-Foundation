/datum/coordination_task
	var/task_id = ""
	var/task_type = ""
	var/department = ""
	var/issuer_name = ""
	var/issuer_job = ""
	var/description = ""
	var/priority = 0
	var/time_issued = 0
	var/status = "pending"
	var/assignee_name = ""
	var/completion_notes = ""

/datum/coordination_task/New(issuer, dept, ttype, desc, prio)
	task_id = "COORD-[world.time]-[rand(10,99)]"
	time_issued = world.time
	if(ismob(issuer))
		var/mob/M = issuer
		issuer_name = M.real_name
		issuer_job = M.job
	department = dept
	task_type = ttype
	description = desc
	priority = prio

/datum/coordination_task/proc/assign(mob/M)
	assignee_name = M.real_name
	status = "assigned"

/datum/coordination_task/proc/complete(notes)
	status = "completed"
	completion_notes = notes

SUBSYSTEM_DEF(department_coordination)
	name = "Department Coordination"
	flags = SS_NO_FIRE
	var/list/datum/coordination_task/tasks = list()
	var/list/interdepartmental_memos = list()
	var/total_tasks = 0
	var/completed_tasks = 0

/datum/controller/subsystem/department_coordination/proc/issue_task(datum/coordination_task/T)
	tasks += T
	total_tasks++
	return T.task_id

/datum/controller/subsystem/department_coordination/proc/assign_task(task_id, mob/M)
	for(var/datum/coordination_task/T in tasks)
		if(T.task_id == task_id && T.status == "pending")
			T.assign(M)
			to_chat(M, span_notice("You have been assigned coordination task: [T.description]"))
			return TRUE
	return FALSE

/datum/controller/subsystem/department_coordination/proc/complete_task(task_id, notes)
	for(var/datum/coordination_task/T in tasks)
		if(T.task_id == task_id && T.status == "assigned")
			T.complete(notes)
			completed_tasks++
			if(SSfoundation_budget)
				var/datum/department_budget/B = SSfoundation_budget?.department_budgets[T.department]
				if(B)
					B.allocate(25)
					SSfoundation_budget.total_budget += 25
			if(SSscp_research?.manager)
				SSscp_research?.manager?.adjust_research_points(3, "coordination_task:[T.task_id]")
			return TRUE
	return FALSE

/datum/controller/subsystem/department_coordination/proc/send_memo(from_dept, to_dept, subject, body, sender)
	var/list/memo = list(
		"from" = from_dept,
		"to" = to_dept,
		"subject" = subject,
		"body" = body,
		"sender" = sender,
		"time" = world.time,
	)
	interdepartmental_memos += list(memo)
	priority_announce("Interdepartmental memo from [from_dept] to [to_dept]: [subject]", "Department Memo", null, ANNOUNCER_DEFAULT)
	return TRUE


