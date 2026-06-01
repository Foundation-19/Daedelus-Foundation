/datum/department_budget
	var/department = ""
	var/allocated = 0
	var/spent = 0
	var/remaining = 0
	var/pending_requests = 0
	var/approved_this_round = 0
	var/denied_this_round = 0

/datum/department_budget/proc/spend(amount, purpose)
	if(amount > remaining)
		return FALSE
	spent += amount
	remaining = allocated - spent
	return TRUE

/datum/department_budget/proc/allocate(amount)
	allocated += amount
	remaining = allocated - spent

/datum/budget_request
	var/request_id = ""
	var/department = ""
	var/requester_name = ""
	var/requester_job = ""
	var/amount = 0
	var/purpose = ""
	var/justification = ""
	var/time_filed = 0
	var/status = "pending"
	var/reviewer = ""
	var/review_notes = ""

/datum/budget_request/New(dept, requester, amt, purpose, justification)
	request_id = "BUD-[world.time]-[rand(10,99)]"
	time_filed = world.time
	department = dept
	if(istype(requester, /mob/living/carbon/human))
		var/mob/living/carbon/human/R = requester
		requester_name = R.real_name
		requester_job = R.job
	amount = amt
	purpose = purpose
	justification = justification

/datum/budget_request/proc/approve(reviewer_name, notes)
	status = "approved"
	reviewer = reviewer_name
	review_notes = notes

/datum/budget_request/proc/deny(reviewer_name, notes)
	status = "denied"
	reviewer = reviewer_name
	review_notes = notes

SUBSYSTEM_DEF(foundation_budget)
	name = "Foundation Budget"
	wait = 30 SECONDS
	priority = FIRE_PRIORITY_DEFAULT
	var/list/datum/department_budget/department_budgets = list()
	var/list/datum/budget_request/requests = list()
	var/total_budget = 50000
	var/total_spent = 0
	var/budget_round = 0

/datum/controller/subsystem/foundation_budget/Initialize(start_timeofday)
	. = ..()
	setup_departments()

/datum/controller/subsystem/foundation_budget/proc/setup_departments()
	var/list/depts = list("command", "security", "science", "medical", "engineering", "logistics", "service")
	var/list/shares = list(20, 20, 25, 15, 10, 5, 5)
	for(var/i in 1 to length(depts))
		var/datum/department_budget/B = new()
		B.department = depts[i]
		B.allocated = round(total_budget * shares[i] / 100)
		B.remaining = B.allocated
		department_budgets[B.department] = B

/datum/controller/subsystem/foundation_budget/proc/file_request(datum/budget_request/R)
	requests += R
	var/datum/department_budget/B = department_budgets[R.department]
	if(B)
		B.pending_requests++
	return R.request_id

/datum/controller/subsystem/foundation_budget/proc/approve_request(request_id, reviewer_name, notes)
	for(var/datum/budget_request/R in requests)
		if(R.request_id == request_id && R.status == "pending")
			var/datum/department_budget/B = department_budgets[R.department]
			if(!B)
				return FALSE
			if(!B.spend(R.amount, R.purpose))
				return FALSE
			R.approve(reviewer_name, notes)
			B.approved_this_round++
			B.pending_requests--
			total_spent += R.amount
			return TRUE
	return FALSE

/datum/controller/subsystem/foundation_budget/proc/deny_request(request_id, reviewer_name, notes)
	for(var/datum/budget_request/R in requests)
		if(R.request_id == request_id && R.status == "pending")
			R.deny(reviewer_name, notes)
			var/datum/department_budget/B = department_budgets[R.department]
			if(B)
				B.denied_this_round++
				B.pending_requests--
			return TRUE
	return FALSE

/datum/controller/subsystem/foundation_budget/proc/reallocate(from_dept, to_dept, amount)
	var/datum/department_budget/from_budget = department_budgets[from_dept]
	var/datum/department_budget/to_budget = department_budgets[to_dept]
	if(!from_budget || !to_budget)
		return FALSE
	if(from_budget.remaining < amount)
		return FALSE
	from_budget.allocated -= amount
	from_budget.remaining = from_budget.allocated - from_budget.spent
	to_budget.allocate(amount)
	return TRUE

