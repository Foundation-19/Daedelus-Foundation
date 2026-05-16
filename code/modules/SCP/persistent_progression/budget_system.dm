// Budget Management System
// Integrates with all departments and existing game systems for comprehensive financial management

SUBSYSTEM_DEF(budget_system)
	name = "Budget System"
	wait = 300 // 5 minutes
	priority = FIRE_PRIORITY_INPUT

	var/datum/budget_manager/manager

/datum/budget_manager
	var/list/department_budgets = list() // department_id -> budget_data
	var/list/transaction_history = list() // transaction_id -> transaction_data
	var/list/budget_requests = list() // request_id -> request_data
	var/list/expense_categories = list() // category -> expense_data
	var/list/revenue_sources = list() // source -> revenue_data

	// Global budget metrics
	var/total_budget = 10000000 // 10 million starting budget
	var/current_balance = 10000000
	var/monthly_expenses = 0
	var/monthly_revenue = 0
	var/budget_cycle = 1 // Current budget cycle/quarter
	var/last_budget_reset = 0

	// Budget alerts and notifications
	var/list/budget_alerts = list() // alert_id -> alert_data
	var/list/budget_history = list() // timestamp -> historical_data
	var/alert_threshold_warning = 0.75 // 75% budget utilization
	var/alert_threshold_critical = 0.90 // 90% budget utilization
	var/alert_threshold_overspent = 1.0 // 100% budget utilization

	// Department budget allocations
	var/security_budget = 2000000
	var/medical_budget = 1500000
	var/research_budget = 2500000
	var/engineering_budget = 1200000
	var/supply_budget = 800000
	var/service_budget = 500000
	var/command_budget = 1000000

/datum/budget_data
	var/department_id
	var/department_name
	var/allocated_budget = 0
	var/spent_budget = 0
	var/remaining_budget = 0
	var/budget_efficiency = 100
	var/priority_level = 1 // 1-5, higher = more important
	var/list/expense_breakdown = list()
	var/list/revenue_breakdown = list()
	var/budget_status = "NORMAL" // NORMAL, WARNING, CRITICAL, OVERSPENT
	var/last_updated

/datum/budget_data/New(var/department_id, var/department_name, var/allocated_budget)
		src.department_id = department_id
		src.department_name = department_name
		src.allocated_budget = allocated_budget
		src.remaining_budget = allocated_budget
		src.last_updated = world.time

/datum/transaction_data
	var/transaction_id
	var/department_id
	var/transaction_type // EXPENSE, REVENUE, TRANSFER, REQUEST
	var/amount
	var/category
	var/description
	var/approved_by
	var/timestamp
	var/status = "PENDING" // PENDING, APPROVED, DENIED, CANCELLED
	var/related_system // Which game system this affects

/datum/transaction_data/New(var/transaction_id, var/department_id, var/transaction_type, var/amount, var/category, var/description)
		src.transaction_id = transaction_id
		src.department_id = department_id
		src.transaction_type = transaction_type
		src.amount = amount
		src.category = category
		src.description = description
		src.timestamp = world.time

/datum/budget_request_data
	var/request_id
	var/department_id
	var/requested_amount
	var/requested_category
	var/justification
	var/requested_by
	var/priority = 1 // 1-5
	var/timestamp
	var/status = "PENDING" // PENDING, APPROVED, DENIED
	var/approved_by
	var/approval_notes = ""

/datum/budget_request_data/New(var/request_id, var/department_id, var/requested_amount, var/requested_category, var/justification)
		src.request_id = request_id
		src.department_id = department_id
		src.requested_amount = requested_amount
		src.requested_category = requested_category
		src.justification = justification
		src.timestamp = world.time

// Budget Manager Methods
/datum/budget_manager/proc/process_budget()
	// Update budget statistics
	update_budget_statistics()

	// Process pending requests
	process_budget_requests()

	// Update department budgets
	update_department_budgets()

		// Generate budget reports
	generate_budget_reports()

	// Generate budget alerts
	generate_budget_alerts()

	// Record historical data (every hour)
	if(world.time % 3600 == 0)
		record_historical_data()

	// Save data periodically
	if(world.time % 6000 == 0) // Every 10 minutes
		save_budget_data()

/datum/budget_manager/proc/initialize_department_budgets()
	// Initialize all department budgets
	department_budgets["security"] = new /datum/budget_data("security", "Security Department", security_budget)
	department_budgets["medical"] = new /datum/budget_data("medical", "Medical Department", medical_budget)
	department_budgets["research"] = new /datum/budget_data("research", "Research Department", research_budget)
	department_budgets["engineering"] = new /datum/budget_data("engineering", "Engineering Department", engineering_budget)
	department_budgets["supply"] = new /datum/budget_data("supply", "Supply Department", supply_budget)
	department_budgets["service"] = new /datum/budget_data("service", "Service Department", service_budget)
	department_budgets["command"] = new /datum/budget_data("command", "Command Department", command_budget)

	// Initialize expense categories
	initialize_expense_categories()

	// Initialize revenue sources
	initialize_revenue_sources()

/datum/budget_manager/proc/initialize_expense_categories()
	expense_categories = list(
		"personnel" = list("name" = "Personnel Costs", "description" = "Salaries, benefits, training"),
		"equipment" = list("name" = "Equipment & Supplies", "description" = "Tools, machinery, consumables"),
		"maintenance" = list("name" = "Maintenance & Repairs", "description" = "System repairs, facility upkeep"),
		"research" = list("name" = "Research & Development", "description" = "Research projects, experiments"),
		"security" = list("name" = "Security Measures", "description" = "Security equipment, protocols"),
		"medical" = list("name" = "Medical Supplies", "description" = "Medications, medical equipment"),
		"utilities" = list("name" = "Utilities & Power", "description" = "Power, water, life support"),
		"containment" = list("name" = "Containment Systems", "description" = "SCP containment, safety systems"),
		"transportation" = list("name" = "Transportation", "description" = "Vehicle maintenance, fuel"),
		"miscellaneous" = list("name" = "Miscellaneous", "description" = "Other expenses")
	)

/datum/budget_manager/proc/initialize_revenue_sources()
	revenue_sources = list(
		"government_funding" = list("name" = "Government Funding", "description" = "Primary funding source"),
		"research_grants" = list("name" = "Research Grants", "description" = "External research funding"),
		"containment_fees" = list("name" = "Containment Fees", "description" = "Fees for SCP containment"),
		"consulting" = list("name" = "Consulting Services", "description" = "External consulting work"),
		"technology_sales" = list("name" = "Technology Sales", "description" = "Sales of developed technology"),
		"training_programs" = list("name" = "Training Programs", "description" = "External training services"),
		"emergency_response" = list("name" = "Emergency Response", "description" = "Emergency response fees"),
		"other" = list("name" = "Other Revenue", "description" = "Other income sources")
	)

/datum/budget_manager/proc/add_transaction(var/department_id, var/transaction_type, var/amount, var/category, var/description, var/approved_by = null)
	var/transaction_id = "TXN_[time2text(world.time, "YYYYMMDD_HHMMSS")]_[department_id]"
	var/datum/transaction_data/transaction = new /datum/transaction_data(transaction_id, department_id, transaction_type, amount, category, description)
	transaction.approved_by = approved_by
	transaction.status = "APPROVED"

	transaction_history[transaction_id] = transaction

	// Update department budget
	var/datum/budget_data/dept_budget = department_budgets[department_id]
	if(dept_budget)
		if(transaction_type == "EXPENSE")
			dept_budget.spent_budget += amount
			dept_budget.remaining_budget -= amount
			current_balance -= amount
			monthly_expenses += amount
		else if(transaction_type == "REVENUE")
			dept_budget.revenue_breakdown[category] = (dept_budget.revenue_breakdown[category] || 0) + amount
			current_balance += amount
			monthly_revenue += amount

		dept_budget.last_updated = world.time
		update_department_status(dept_budget)

	// Update expense categories
	if(transaction_type == "EXPENSE")
		expense_categories[category]["total"] = (expense_categories[category]["total"] || 0) + amount

	return transaction

/datum/budget_manager/proc/request_budget_increase(var/department_id, var/requested_amount, var/category, var/justification, var/requested_by)
	var/request_id = "REQ_[time2text(world.time, "YYYYMMDD_HHMMSS")]_[department_id]"
	var/datum/budget_request_data/request = new /datum/budget_request_data(request_id, department_id, requested_amount, category, justification)
	request.requested_by = requested_by

	budget_requests[request_id] = request

	// Log the request
	world.log << "Budget: Budget increase request [request_id] from [department_id] for [requested_amount] credits"

	return request

// Transfer budget between departments
/datum/budget_manager/proc/transfer_budget(var/from_department, var/to_department, var/amount, var/reason, var/transferred_by)
	if(!from_department || !to_department || amount <= 0)
		return FALSE

	var/datum/budget_data/from_dept = department_budgets[from_department]
	var/datum/budget_data/to_dept = department_budgets[to_department]

	if(!from_dept || !to_dept)
		return FALSE

	if(from_dept.remaining_budget < amount)
		return FALSE

	// Deduct from source department
	from_dept.spent_budget += amount
	from_dept.remaining_budget = from_dept.allocated_budget - from_dept.spent_budget

	// Add to destination department
	to_dept.allocated_budget += amount
	to_dept.remaining_budget = to_dept.allocated_budget - to_dept.spent_budget

	// Update department statuses
	update_department_status(from_dept)
	update_department_status(to_dept)

	// Create transaction records
	var/transfer_id = "TRANSFER_[world.time]"
	var/datum/transaction_data/outgoing = new /datum/transaction_data(transfer_id, from_department, "EXPENSE", amount, "budget_transfer", "Budget transfer to [to_department]: [reason]", transferred_by)
	var/datum/transaction_data/incoming = new /datum/transaction_data(transfer_id, to_department, "REVENUE", amount, "budget_transfer", "Budget transfer from [from_department]: [reason]", transferred_by)

	transaction_history[transfer_id] = outgoing
	transaction_history["[transfer_id]_IN"] = incoming

	// Update global metrics
	update_budget_statistics()

	world.log << "Budget: Transfer of [amount] credits from [from_department] to [to_department] by [transferred_by]"
	return TRUE

// Generate budget alerts
/datum/budget_manager/proc/generate_budget_alerts()
	var/alert_id = "ALERT_[world.time]"
	var/list/alerts = list()

	// Check overall budget utilization
	var/utilization_ratio = (total_budget - current_balance) / total_budget
	if(utilization_ratio >= alert_threshold_overspent)
		alerts += list(list(
			"type" = "CRITICAL",
			"department" = "GLOBAL",
			"message" = "Overall budget utilization is OVERSPENT ([round(utilization_ratio * 100)]%)",
			"timestamp" = world.time,
			"severity" = 5
		))
	else if(utilization_ratio >= alert_threshold_critical)
		alerts += list(list(
			"type" = "CRITICAL",
			"department" = "GLOBAL",
			"message" = "Overall budget utilization is CRITICAL ([round(utilization_ratio * 100)]%)",
			"timestamp" = world.time,
			"severity" = 4
		))
	else if(utilization_ratio >= alert_threshold_warning)
		alerts += list(list(
			"type" = "WARNING",
			"department" = "GLOBAL",
			"message" = "Overall budget utilization is HIGH ([round(utilization_ratio * 100)]%)",
			"timestamp" = world.time,
			"severity" = 3
		))

	// Check individual departments
	for(var/dept_id in department_budgets)
		var/datum/budget_data/dept = department_budgets[dept_id]
		var/dept_utilization = dept.spent_budget / dept.allocated_budget

		if(dept_utilization >= alert_threshold_overspent)
			alerts += list(list(
				"type" = "CRITICAL",
				"department" = dept_id,
				"message" = "[dept.department_name] is OVERSPENT ([round(dept_utilization * 100)]%)",
				"timestamp" = world.time,
				"severity" = 5
			))
		else if(dept_utilization >= alert_threshold_critical)
			alerts += list(list(
				"type" = "CRITICAL",
				"department" = dept_id,
				"message" = "[dept.department_name] is CRITICAL ([round(dept_utilization * 100)]%)",
				"timestamp" = world.time,
				"severity" = 4
			))
		else if(dept_utilization >= alert_threshold_warning)
			alerts += list(list(
				"type" = "WARNING",
				"department" = dept_id,
				"message" = "[dept.department_name] is HIGH ([round(dept_utilization * 100)]%)",
				"timestamp" = world.time,
				"severity" = 3
			))

	// Store alerts
	if(length(alerts) > 0)
		budget_alerts[alert_id] = alerts
		world.log << "Budget: Generated [length(alerts)] budget alerts"

	return alerts

// Record historical budget data
/datum/budget_manager/proc/record_historical_data()
	var/timestamp = world.time
	var/list/historical_data = list(
		"timestamp" = timestamp,
		"total_budget" = total_budget,
		"current_balance" = current_balance,
		"monthly_expenses" = monthly_expenses,
		"monthly_revenue" = monthly_revenue,
		"budget_cycle" = budget_cycle,
		"departments" = list()
	)

	// Record department data
	for(var/dept_id in department_budgets)
		var/datum/budget_data/dept = department_budgets[dept_id]
		historical_data["departments"][dept_id] = list(
			"allocated" = dept.allocated_budget,
			"spent" = dept.spent_budget,
			"remaining" = dept.remaining_budget,
			"efficiency" = dept.budget_efficiency,
			"status" = dept.budget_status
		)

	// Store historical data (keep last 30 days)
	budget_history[timestamp] = historical_data

	// Clean old historical data (older than 30 days)
	var/oldest_allowed = world.time - (30 * 24 * 60 * 60 * 10) // 30 days in deciseconds
	for(var/old_timestamp in budget_history)
		if(old_timestamp < oldest_allowed)
			budget_history -= old_timestamp

	world.log << "Budget: Recorded historical data for timestamp [timestamp]"

// Get budget trends analysis
/datum/budget_manager/proc/get_budget_trends()
	var/list/trends = list()

	if(length(budget_history) < 2)
		return trends

	// Calculate spending trends
	var/list/timestamps = sortTim(budget_history, GLOBAL_PROC_REF(cmp_numeric_asc))
	var/oldest_data = budget_history[timestamps[1]]
	var/newest_data = budget_history[timestamps[length(timestamps)]]

	var/time_span = newest_data["timestamp"] - oldest_data["timestamp"]
	var/spending_change = (newest_data["total_budget"] - newest_data["current_balance"]) - (oldest_data["total_budget"] - oldest_data["current_balance"])

	trends["spending_rate"] = spending_change / (time_span / (24 * 60 * 60 * 10)) // credits per day
	trends["projected_monthly"] = trends["spending_rate"] * 30
	if(trends["spending_rate"] > 0)
		trends["budget_life_expectancy"] = newest_data["current_balance"] / trends["spending_rate"]
	else
		trends["budget_life_expectancy"] = 999

	// Department trends
	trends["department_trends"] = list()
	for(var/dept_id in department_budgets)
		if(oldest_data["departments"][dept_id] && newest_data["departments"][dept_id])
			var/old_dept = oldest_data["departments"][dept_id]
			var/new_dept = newest_data["departments"][dept_id]
			var/dept_spending_change = new_dept["spent"] - old_dept["spent"]
			var/dept_spending_rate = dept_spending_change / (time_span / (24 * 60 * 60 * 10))

			trends["department_trends"][dept_id] = list(
				"spending_rate" = dept_spending_rate,
				"projected_monthly" = dept_spending_rate * 30,
				"efficiency_change" = new_dept["efficiency"] - old_dept["efficiency"]
			)

	return trends

/datum/budget_manager/proc/approve_budget_request(var/request_id, var/approved_by, var/approval_notes = "")
	var/datum/budget_request_data/request = budget_requests[request_id]
	if(!request || request.status != "PENDING")
		return FALSE

	request.status = "APPROVED"
	request.approved_by = approved_by
	request.approval_notes = approval_notes

	// Transfer budget to department
	var/datum/budget_data/dept_budget = department_budgets[request.department_id]
	if(dept_budget)
		dept_budget.allocated_budget += request.requested_amount
		dept_budget.remaining_budget += request.requested_amount
		total_budget += request.requested_amount
		current_balance += request.requested_amount

		// Create transaction record
		add_transaction(request.department_id, "REVENUE", request.requested_amount, "budget_increase", "Budget increase approved: [request.justification]", approved_by)

		update_department_status(dept_budget)

	world.log << "Budget: Budget request [request_id] approved by [approved_by]"
	return TRUE

/datum/budget_manager/proc/deny_budget_request(var/request_id, var/denied_by, var/denial_notes = "")
	var/datum/budget_request_data/request = budget_requests[request_id]
	if(!request || request.status != "PENDING")
		return FALSE

	request.status = "DENIED"
	request.approved_by = denied_by
	request.approval_notes = denial_notes

	world.log << "Budget: Budget request [request_id] denied by [denied_by]"
	return TRUE

/datum/budget_manager/proc/update_department_status(var/datum/budget_data/dept_budget)
	if(!dept_budget)
		return

	var/spending_ratio = dept_budget.spent_budget / dept_budget.allocated_budget

	if(spending_ratio >= 1.0)
		dept_budget.budget_status = "OVERSPENT"
	else if(spending_ratio >= 0.9)
		dept_budget.budget_status = "CRITICAL"
	else if(spending_ratio >= 0.75)
		dept_budget.budget_status = "WARNING"
	else
		dept_budget.budget_status = "NORMAL"

	// Calculate efficiency (remaining budget vs time elapsed)
	var/time_elapsed = world.time - last_budget_reset
	var/expected_spending = (dept_budget.allocated_budget * time_elapsed) / (30 * 24 * 60 * 60 * 10) // 30 days in deciseconds
	var/actual_spending = dept_budget.spent_budget

	if(expected_spending > 0 && actual_spending > 0)
		dept_budget.budget_efficiency = max(0, min(100, (expected_spending / actual_spending) * 100))
	else if(expected_spending > 0 && actual_spending == 0)
		// If expected spending but no actual spending, efficiency is 100% (under budget)
		dept_budget.budget_efficiency = 100
	else
		// If no expected spending, efficiency is 100%
		dept_budget.budget_efficiency = 100

/datum/budget_manager/proc/update_budget_statistics()
	// Calculate total spent across all departments
	var/total_spent = 0
	for(var/dept_id in department_budgets)
		var/datum/budget_data/dept = department_budgets[dept_id]
		total_spent += dept.spent_budget

	// Update global metrics
	current_balance = total_budget - total_spent

	// Update department statuses
	for(var/dept_id in department_budgets)
		update_department_status(department_budgets[dept_id])

/datum/budget_manager/proc/process_budget_requests()
	// Auto-approve low-priority requests if budget allows
	for(var/request_id in budget_requests)
		var/datum/budget_request_data/request = budget_requests[request_id]
		if(request.status == "PENDING" && request.priority <= 2)
			if(current_balance >= request.requested_amount)
				approve_budget_request(request_id, "SYSTEM", "Auto-approved low-priority request")

/datum/budget_manager/proc/update_department_budgets()
	// Update all department budgets
	for(var/dept_id in department_budgets)
		var/datum/budget_data/dept = department_budgets[dept_id]
		dept.remaining_budget = dept.allocated_budget - dept.spent_budget
		update_department_status(dept)

/datum/budget_manager/proc/generate_budget_reports()
	// Generate comprehensive budget reports
	var/list/report = list()
	report["total_budget"] = total_budget
	report["current_balance"] = current_balance
	report["monthly_expenses"] = monthly_expenses
	report["monthly_revenue"] = monthly_revenue
	report["budget_cycle"] = budget_cycle

	report["departments"] = list()
	for(var/dept_id in department_budgets)
		var/datum/budget_data/dept = department_budgets[dept_id]
		report["departments"][dept_id] = list(
			"name" = dept.department_name,
			"allocated" = dept.allocated_budget,
			"spent" = dept.spent_budget,
			"remaining" = dept.remaining_budget,
			"efficiency" = dept.budget_efficiency,
			"status" = dept.budget_status
		)

	return report

// Integration with existing systems
/datum/budget_manager/proc/process_security_expense(var/expense_type, var/amount, var/description)
	// Process security-related expenses
	var/category = "security"
	if(expense_type == "personnel")
		category = "personnel"
	else if(expense_type == "equipment")
		category = "equipment"
	else if(expense_type == "maintenance")
		category = "maintenance"

	return add_transaction("security", "EXPENSE", amount, category, description, "SYSTEM")

/datum/budget_manager/proc/process_medical_expense(var/expense_type, var/amount, var/description)
	// Process medical-related expenses
	var/category = "medical"
	if(expense_type == "personnel")
		category = "personnel"
	else if(expense_type == "equipment")
		category = "equipment"

	return add_transaction("medical", "EXPENSE", amount, category, description, "SYSTEM")

/datum/budget_manager/proc/process_research_expense(var/expense_type, var/amount, var/description)
	// Process research-related expenses
	var/category = "research"
	if(expense_type == "equipment")
		category = "equipment"
	else if(expense_type == "personnel")
		category = "personnel"

	return add_transaction("research", "EXPENSE", amount, category, description, "SYSTEM")

/datum/budget_manager/proc/process_engineering_expense(var/expense_type, var/amount, var/description)
	// Process engineering-related expenses
	var/category = "maintenance"
	if(expense_type == "equipment")
		category = "equipment"
	else if(expense_type == "personnel")
		category = "personnel"

	return add_transaction("engineering", "EXPENSE", amount, category, description, "SYSTEM")

/datum/budget_manager/proc/process_supply_expense(var/expense_type, var/amount, var/description)
	// Process supply-related expenses
	var/category = "equipment"
	if(expense_type == "personnel")
		category = "personnel"

	return add_transaction("supply", "EXPENSE", amount, category, description, "SYSTEM")

// Save and load budget data
/datum/budget_manager/proc/save_budget_data()
	var/list/data = list()

	// Save department budgets
	data["department_budgets"] = list()
	for(var/dept_id in department_budgets)
		var/datum/budget_data/dept = department_budgets[dept_id]
		data["department_budgets"][dept_id] = list(
			"department_name" = dept.department_name,
			"allocated_budget" = dept.allocated_budget,
			"spent_budget" = dept.spent_budget,
			"remaining_budget" = dept.remaining_budget,
			"budget_efficiency" = dept.budget_efficiency,
			"priority_level" = dept.priority_level,
			"expense_breakdown" = dept.expense_breakdown,
			"revenue_breakdown" = dept.revenue_breakdown,
			"budget_status" = dept.budget_status,
			"last_updated" = dept.last_updated
		)

	// Save transactions
	data["transactions"] = list()
	for(var/txn_id in transaction_history)
		var/datum/transaction_data/txn = transaction_history[txn_id]
		data["transactions"][txn_id] = list(
			"department_id" = txn.department_id,
			"transaction_type" = txn.transaction_type,
			"amount" = txn.amount,
			"category" = txn.category,
			"description" = txn.description,
			"approved_by" = txn.approved_by,
			"timestamp" = txn.timestamp,
			"status" = txn.status,
			"related_system" = txn.related_system
		)

	// Save budget requests
	data["budget_requests"] = list()
	for(var/req_id in budget_requests)
		var/datum/budget_request_data/req = budget_requests[req_id]
		data["budget_requests"][req_id] = list(
			"department_id" = req.department_id,
			"requested_amount" = req.requested_amount,
			"requested_category" = req.requested_category,
			"justification" = req.justification,
			"requested_by" = req.requested_by,
			"priority" = req.priority,
			"timestamp" = req.timestamp,
			"status" = req.status,
			"approved_by" = req.approved_by,
			"approval_notes" = req.approval_notes
		)

	// Save global metrics
	data["global_metrics"] = list(
		"total_budget" = total_budget,
		"current_balance" = current_balance,
		"monthly_expenses" = monthly_expenses,
		"monthly_revenue" = monthly_revenue,
		"budget_cycle" = budget_cycle,
		"last_budget_reset" = last_budget_reset,
		"alert_threshold_warning" = alert_threshold_warning,
		"alert_threshold_critical" = alert_threshold_critical,
		"alert_threshold_overspent" = alert_threshold_overspent
	)

	// Save budget alerts
	data["budget_alerts"] = budget_alerts

	// Save budget history
	data["budget_history"] = budget_history

	// Write to JSON file
	var/json_data = json_encode(data)
	var/savefile/S = new /savefile("data/budget_system.json")
	S["data"] << json_data

/datum/budget_manager/proc/load_budget_data()
	var/savefile/S = new /savefile("data/budget_system.json")
	if(!S["data"])
		return

	var/json_data
	S["data"] >> json_data

	var/list/data = json_decode(json_data)
	if(!data)
		return

	// Load department budgets
	if(data["department_budgets"])
		for(var/dept_id in data["department_budgets"])
			var/list/dept_data = data["department_budgets"][dept_id]
			var/datum/budget_data/dept = new /datum/budget_data(dept_id, dept_data["department_name"], dept_data["allocated_budget"])
			dept.spent_budget = dept_data["spent_budget"]
			dept.remaining_budget = dept_data["remaining_budget"]
			dept.budget_efficiency = dept_data["budget_efficiency"]
			dept.priority_level = dept_data["priority_level"]
			dept.expense_breakdown = dept_data["expense_breakdown"]
			dept.revenue_breakdown = dept_data["revenue_breakdown"]
			dept.budget_status = dept_data["budget_status"]
			dept.last_updated = dept_data["last_updated"]
			department_budgets[dept_id] = dept

	// Load transactions
	if(data["transactions"])
		for(var/txn_id in data["transactions"])
			var/list/txn_data = data["transactions"][txn_id]
			var/datum/transaction_data/txn = new /datum/transaction_data(txn_id, txn_data["department_id"], txn_data["transaction_type"], txn_data["amount"], txn_data["category"], txn_data["description"])
			txn.approved_by = txn_data["approved_by"]
			txn.timestamp = txn_data["timestamp"]
			txn.status = txn_data["status"]
			txn.related_system = txn_data["related_system"]
			transaction_history[txn_id] = txn

	// Load budget requests
	if(data["budget_requests"])
		for(var/req_id in data["budget_requests"])
			var/list/req_data = data["budget_requests"][req_id]
			var/datum/budget_request_data/req = new /datum/budget_request_data(req_id, req_data["department_id"], req_data["requested_amount"], req_data["requested_category"], req_data["justification"])
			req.requested_by = req_data["requested_by"]
			req.priority = req_data["priority"]
			req.timestamp = req_data["timestamp"]
			req.status = req_data["status"]
			req.approved_by = req_data["approved_by"]
			req.approval_notes = req_data["approval_notes"]
			budget_requests[req_id] = req

	// Load global metrics
	if(data["global_metrics"])
		var/list/metrics = data["global_metrics"]
		total_budget = metrics["total_budget"]
		current_balance = metrics["current_balance"]
		monthly_expenses = metrics["monthly_expenses"]
		monthly_revenue = metrics["monthly_revenue"]
		budget_cycle = metrics["budget_cycle"]
		last_budget_reset = metrics["last_budget_reset"]
		alert_threshold_warning = metrics["alert_threshold_warning"] || 0.75
		alert_threshold_critical = metrics["alert_threshold_critical"] || 0.90
		alert_threshold_overspent = metrics["alert_threshold_overspent"] || 1.0

	// Load budget alerts
	if(data["budget_alerts"])
		budget_alerts = data["budget_alerts"]

	// Load budget history
	if(data["budget_history"])
		budget_history = data["budget_history"]

// Subsystem initialization
/datum/controller/subsystem/budget_system/Initialize()
	world.log << "Budget system initializing..."
	manager = new /datum/budget_manager()
	manager.initialize_department_budgets()
	manager.load_budget_data()
	world.log << "Budget system initialized with [length(manager.department_budgets)] departments"
	return ..()

/datum/controller/subsystem/budget_system/fire()
	if(manager)
		manager.process_budget()

// Global instance
GLOBAL_DATUM_INIT(budget_manager, /datum/budget_manager, new)

// Integration Hooks for Existing Game Systems
// These functions can be called from other systems to automatically track expenses

// Cargo/Supply System Integration
/proc/track_cargo_expense(var/amount, var/description, var/department_id = "supply")
	if(SSbudget_system && SSbudget_system.manager)
		return SSbudget_system.manager.add_transaction(department_id, "EXPENSE", amount, "equipment", description, "SYSTEM")
	return null

/proc/track_cargo_revenue(var/amount, var/description, var/revenue_type = "government_funding")
	if(SSbudget_system && SSbudget_system.manager)
		return SSbudget_system.manager.add_transaction("supply", "REVENUE", amount, revenue_type, description, "SYSTEM")
	return null

/proc/track_supply_order(var/datum/supply_order/order)
	if(SSbudget_system && SSbudget_system.manager && order)
		var/amount = order.pack.get_cost()
		var/department_id = "supply"

		// Determine which department is paying
		if(order.paying_account)
			// Find which department this account belongs to
			for(var/dept_id in SSbudget_system.manager.department_budgets)
				// This is a simplified check - in a real implementation you'd have account-to-department mapping
				if(order.paying_account.account_balance >= amount)
					department_id = dept_id
					break

		var/description = "Supply order #[order.id]: [order.pack.name] - [order.reason ? order.reason : "No reason provided"]"
		return SSbudget_system.manager.add_transaction(department_id, "EXPENSE", amount, "equipment", description, order.orderer_ckey || "SYSTEM")
	return null

/proc/track_cargo_export(var/amount, var/description)
	if(SSbudget_system && SSbudget_system.manager)
		return SSbudget_system.manager.add_transaction("supply", "REVENUE", amount, "technology_sales", description, "SYSTEM")
	return null

// Security System Integration
/proc/track_security_expense(var/expense_type, var/amount, var/description)
	if(SSbudget_system && SSbudget_system.manager)
		return SSbudget_system.manager.process_security_expense(expense_type, amount, description)
	return null

// Medical System Integration
/proc/track_medical_expense(var/expense_type, var/amount, var/description)
	if(SSbudget_system && SSbudget_system.manager)
		return SSbudget_system.manager.process_medical_expense(expense_type, amount, description)
	return null

// Research System Integration
/proc/track_research_expense(var/expense_type, var/amount, var/description)
	if(SSbudget_system && SSbudget_system.manager)
		return SSbudget_system.manager.process_research_expense(expense_type, amount, description)
	return null

// Engineering System Integration
/proc/track_engineering_expense(var/expense_type, var/amount, var/description)
	if(SSbudget_system && SSbudget_system.manager)
		return SSbudget_system.manager.process_engineering_expense(expense_type, amount, description)
	return null

// Supply System Integration
/proc/track_supply_expense(var/expense_type, var/amount, var/description)
	if(SSbudget_system && SSbudget_system.manager)
		return SSbudget_system.manager.process_supply_expense(expense_type, amount, description)
	return null

// General Expense Tracking
/proc/track_department_expense(var/department_id, var/expense_type, var/amount, var/description)
	if(SSbudget_system && SSbudget_system.manager)
		var/category = "miscellaneous"
		switch(expense_type)
			if("personnel")
				category = "personnel"
			if("equipment")
				category = "equipment"
			if("maintenance")
				category = "maintenance"
			if("research")
				category = "research"
			if("security")
				category = "security"
			if("medical")
				category = "medical"
			if("utilities")
				category = "utilities"
			if("containment")
				category = "containment"
			if("transportation")
				category = "transportation"

		return SSbudget_system.manager.add_transaction(department_id, "EXPENSE", amount, category, description, "SYSTEM")
	return null

// Revenue Tracking
/proc/track_department_revenue(var/department_id, var/revenue_type, var/amount, var/description)
	if(SSbudget_system && SSbudget_system.manager)
		return SSbudget_system.manager.add_transaction(department_id, "REVENUE", amount, revenue_type, description, "SYSTEM")
	return null

// Budget Request Helper
/proc/request_department_budget(var/department_id, var/amount, var/category, var/justification, var/requested_by, var/priority = 1)
	if(SSbudget_system && SSbudget_system.manager)
		var/datum/budget_request_data/request = SSbudget_system.manager.request_budget_increase(department_id, amount, category, justification, requested_by)
		if(request)
			request.priority = priority
		return request
	return null
