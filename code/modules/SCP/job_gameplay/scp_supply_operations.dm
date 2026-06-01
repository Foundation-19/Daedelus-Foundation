#ifndef SCP_REQUISITION_PENDING
#define SCP_REQUISITION_PENDING 0
#define SCP_REQUISITION_APPROVED 1
#define SCP_REQUISITION_SHIPPING 2
#define SCP_REQUISITION_DELIVERED 3
#define SCP_REQUISITION_REJECTED 4
#endif

#ifndef SCP_PRIORITY_ROUTINE
#define SCP_PRIORITY_ROUTINE 1
#define SCP_PRIORITY_URGENT 2
#define SCP_PRIORITY_CRITICAL 3
#endif

#ifndef SCP_ITEM_STANDARD
#define SCP_ITEM_STANDARD "standard"
#define SCP_ITEM_EQUIPMENT "equipment"
#define SCP_ITEM_REAGENT "reagent"
#define SCP_ITEM_ANOMALOUS "anomalous"
#endif

SUBSYSTEM_DEF(scp_supply)
	name = "SCP Supply Operations"
	wait = 20 SECONDS
	flags = SS_NO_FIRE

	var/list/requisition_queue = list()
	var/list/active_shipments = list()
	var/list/delivery_log = list()
	var/list/screening_queue = list()
	var/list/anomalous_materials = list()
	var/list/supply_stats = list()
	var/total_requisitions_processed = 0
	var/total_deliveries_completed = 0
	var/total_screenings = 0
	var/total_contraband_caught = 0
	var/total_anomalous_deliveries = 0

/datum/controller/subsystem/scp_supply/proc/submit_requisition(mob/living/carbon/human/requestor, department, item_type, item_name, quantity, priority, justification)
	if(!istype(requestor))
		return ""
	var/budget_cost = 0
	switch(item_type)
		if(SCP_ITEM_ANOMALOUS)
			budget_cost = 200 + quantity * 50
		if(SCP_ITEM_REAGENT)
			budget_cost = 75 + quantity * 25
		if(SCP_ITEM_EQUIPMENT)
			budget_cost = 100 + quantity * 30
		else
			budget_cost = 25 + quantity * 10
	var/requires_screening = (item_type == SCP_ITEM_ANOMALOUS) ? TRUE : FALSE
	var/requisition_id = "req_[world.time]_[rand(100,999)]"
	var/list/requisition = list(
		"requisition_id" = requisition_id,
		"requestor" = requestor.real_name,
		"requestor_ckey" = requestor.ckey,
		"department" = department,
		"item_type" = item_type,
		"item_name" = item_name,
		"quantity" = quantity,
		"priority" = priority,
		"justification" = justification,
		"budget_cost" = budget_cost,
		"status" = SCP_REQUISITION_PENDING,
		"requires_screening" = requires_screening,
		"time_submitted" = world.time,
		"time_delivered" = 0,
	)
	requisition_queue += list(requisition)
	var/list/stats = get_supply_stats(requestor.ckey)
	stats["total_requisitions"]++
	stats["last_active"] = world.time
	total_requisitions_processed++
	if(priority == SCP_PRIORITY_CRITICAL)
		var/msg = "CRITICAL supply requisition from [requestor.real_name]: [quantity]x [item_name] for [department]. Justification: [justification]"
		SSfoundation_comms.create_dispatch(null, DISPATCH_SECURITY, msg, 2)
	return requisition_id

/datum/controller/subsystem/scp_supply/proc/approve_requisition(requisition_id, mob/living/carbon/human/approver)
	if(!istype(approver))
		return FALSE
	for(var/list/R in requisition_queue)
		if(R["requisition_id"] == requisition_id && R["status"] == SCP_REQUISITION_PENDING)
			R["status"] = SCP_REQUISITION_APPROVED
			if(SSbudget_system?.manager)
				var/desc = "Supply requisition [requisition_id]: [R["quantity"]]x [R["item_name"]]"
				SSbudget_system?.manager?.add_transaction(R["department"], "EXPENSE", R["budget_cost"], "equipment", desc, approver.ckey)
			var/delivery_time = 0
			switch(R["priority"])
				if(SCP_PRIORITY_CRITICAL)
					delivery_time = 30 SECONDS
				if(SCP_PRIORITY_URGENT)
					delivery_time = 60 SECONDS
				else
					delivery_time = 120 SECONDS
			R["delivery_time"] = delivery_time
			R["time_approved"] = world.time
			active_shipments += list(R)
			requisition_queue -= list(R)
			if(R["requires_screening"])
				screening_queue += list(R)
			var/list/stats = get_supply_stats(approver.ckey)
			stats["last_active"] = world.time
			var/mob/living/carbon/human/requestor = locate(R["requestor"]) in GLOB.mob_living_list
			if(requestor)
				to_chat(requestor, span_notice("Your supply requisition [requisition_id] has been approved by [approver.real_name]. Estimated delivery: [round(delivery_time / 10)] seconds."))
			addtimer(CALLBACK(src, PROC_REF(process_shipment), requisition_id), delivery_time)
			return TRUE
	return FALSE

/datum/controller/subsystem/scp_supply/proc/reject_requisition(requisition_id, reason)
	for(var/list/R in requisition_queue)
		if(R["requisition_id"] == requisition_id && R["status"] == SCP_REQUISITION_PENDING)
			R["status"] = SCP_REQUISITION_REJECTED
			requisition_queue -= list(R)
			var/mob/living/carbon/human/requestor = locate(R["requestor"]) in GLOB.mob_living_list
			if(requestor)
				to_chat(requestor, span_warning("Your supply requisition [requisition_id] has been rejected. Reason: [reason]"))
			return TRUE
	return FALSE

/datum/controller/subsystem/scp_supply/proc/process_shipment(requisition_id)
	for(var/list/R in active_shipments)
		if(R["requisition_id"] == requisition_id && R["status"] == SCP_REQUISITION_APPROVED)
			R["status"] = SCP_REQUISITION_SHIPPING
			complete_delivery(requisition_id)
			return TRUE
	return FALSE

/datum/controller/subsystem/scp_supply/proc/complete_delivery(requisition_id)
	for(var/list/R in active_shipments)
		if(R["requisition_id"] == requisition_id && R["status"] == SCP_REQUISITION_SHIPPING)
			if(R["requires_screening"] && (R in screening_queue))
				return FALSE
			R["status"] = SCP_REQUISITION_DELIVERED
			R["time_delivered"] = world.time
			active_shipments -= list(R)
			delivery_log += list(R)
			total_deliveries_completed++
			var/list/stats = get_supply_stats(R["requestor_ckey"])
			stats["total_deliveries"]++
			stats["last_active"] = world.time
			var/mob/living/carbon/human/requestor = locate(R["requestor"]) in GLOB.mob_living_list
			if(requestor)
				to_chat(requestor, span_notice("Your supply requisition [requisition_id] has been delivered."))
			if(R["item_type"] == SCP_ITEM_ANOMALOUS)
				if(SSscp_research?.manager)
					SSscp_research?.manager?.adjust_research_points(25, "anomalous_delivery:[requisition_id]")
			return TRUE
	return FALSE

/datum/controller/subsystem/scp_supply/proc/screen_delivery(requisition_id, mob/living/carbon/human/screener, passed)
	if(!istype(screener))
		return FALSE
	for(var/list/R in screening_queue)
		if(R["requisition_id"] == requisition_id)
			total_screenings++
			var/list/stats = get_supply_stats(screener.ckey)
			stats["total_screenings"]++
			stats["last_active"] = world.time
			if(passed)
				screening_queue -= list(R)
				complete_delivery(requisition_id)
				return TRUE
			else
				screening_queue -= list(R)
				total_contraband_caught++
				stats["total_contraband"]++
				R["status"] = SCP_REQUISITION_REJECTED
				active_shipments -= list(R)
				if(SSraisa)
					var/datum/intel_report/report = new(screener, "contraband_intercept", R["requestor"], R["item_type"], "CONFIDENTIAL", "Contraband detected in supply requisition [requisition_id]: [R["quantity"]]x [R["item_name"]]. Requestor: [R["requestor"]].", "Investigate requestor and seize materials.")
					SSraisa.file_report(report)
				var/mob/living/carbon/human/requestor_mob = locate(R["requestor"]) in GLOB.mob_living_list
				if(requestor_mob)
					to_chat(requestor_mob, span_warning("Your supply requisition [requisition_id] has been flagged as contraband and seized."))
				return FALSE
	return FALSE

/datum/controller/subsystem/scp_supply/proc/log_anomalous_material(item_name, source, containment_class)
	anomalous_materials += list(list(
		"item_name" = item_name,
		"source" = source,
		"containment_class" = containment_class,
		"time_logged" = world.time,
	))
	total_anomalous_deliveries++
	if(containment_class == "keter")
		if(SScontainment_integrity)
			var/msg = "Keter-class anomalous material delivery detected: [item_name] from [source]. Containment protocols advised."
			SSfoundation_comms.create_dispatch(null, DISPATCH_SECURITY, msg, 2)

/datum/controller/subsystem/scp_supply/proc/get_supply_stats(ckey)
	if(!supply_stats[ckey])
		supply_stats[ckey] = list(
			"total_requisitions" = 0,
			"total_deliveries" = 0,
			"total_screenings" = 0,
			"total_contraband" = 0,
			"last_active" = world.time,
		)
	return supply_stats[ckey]

/datum/controller/subsystem/scp_supply/proc/get_department_budget(department)
	if(!SSbudget_system?.manager)
		return 0
	var/datum/budget_data/dept_budget = SSbudget_system?.manager?.department_budgets[department]
	if(!dept_budget)
		return 0
	return dept_budget.remaining_budget

/datum/controller/subsystem/scp_supply/proc/generate_supply_status()
	var/pending_count = 0
	for(var/list/R in requisition_queue)
		if(R["status"] == SCP_REQUISITION_PENDING)
			pending_count++
	var/in_transit_count = length(active_shipments)
	var/delivered_count = 0
	for(var/list/R in delivery_log)
		delivered_count++
	var/list/department_budgets = list()
	var/list/depts = list("command", "security", "science", "medical", "engineering", "logistics", "service")
	for(var/dept in depts)
		department_budgets[dept] = get_department_budget(dept)
	return list(
		"pending_count" = pending_count,
		"in_transit_count" = in_transit_count,
		"delivered_count" = delivered_count,
		"department_budgets" = department_budgets,
		"total_requisitions" = total_requisitions_processed,
		"total_deliveries" = total_deliveries_completed,
		"total_screenings" = total_screenings,
		"total_contraband" = total_contraband_caught,
		"total_anomalous" = total_anomalous_deliveries,
	)

/datum/computer_file/program/scp_supply
	filename = "scp_supply"
	filedesc = "SCP Supply Operations"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Manage supply requisitions, screen anomalous deliveries, track Foundation logistics."
	size = 2
	tgui_id = "ScpSupply"
	program_icon = "truck"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_SECURITY)

/datum/computer_file/program/scp_supply/ui_data(mob/user)
	var/list/data = get_header_data()
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		data["access_denied"] = TRUE
		return data
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_SECURITY in id_card.access))
		data["access_denied"] = TRUE
		return data
	data["access_denied"] = FALSE
	if(!SSscp_supply)
		return data
	data["requisition_queue"] = SSscp_supply.requisition_queue
	data["active_shipments"] = SSscp_supply.active_shipments
	var/list/recent_deliveries = list()
	var/log_len = length(SSscp_supply.delivery_log)
	var/start_idx = max(1, log_len - 19)
	for(var/i in start_idx to log_len)
		recent_deliveries += list(SSscp_supply.delivery_log[i])
	data["delivery_log"] = recent_deliveries
	data["screening_queue"] = SSscp_supply.screening_queue
	data["anomalous_materials"] = SSscp_supply.anomalous_materials
	data["supply_stats"] = SSscp_supply.get_supply_stats(H.ckey)
	data["total_requisitions_processed"] = SSscp_supply.total_requisitions_processed
	data["total_deliveries_completed"] = SSscp_supply.total_deliveries_completed
	data["total_screenings"] = SSscp_supply.total_screenings
	data["total_contraband_caught"] = SSscp_supply.total_contraband_caught
	var/list/dept_budgets = list()
	var/list/depts = list("command", "security", "science", "medical", "engineering", "logistics", "service")
	for(var/dept in depts)
		dept_budgets[dept] = SSscp_supply.get_department_budget(dept)
	data["department_budgets"] = dept_budgets
	var/pending_count = 0
	for(var/list/R in SSscp_supply.requisition_queue)
		if(R["status"] == SCP_REQUISITION_PENDING)
			pending_count++
	data["pending_count"] = pending_count
	return data

/datum/computer_file/program/scp_supply/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_SECURITY in id_card.access))
		return
	if(!SSscp_supply)
		return
	switch(action)
		if("submit_requisition")
			var/department = params["department"] || "service"
			var/item_type = params["item_type"] || SCP_ITEM_STANDARD
			var/item_name = params["item_name"] || ""
			var/quantity = text2num(params["quantity"]) || 1
			var/priority = text2num(params["priority"]) || SCP_PRIORITY_ROUTINE
			var/justification = params["justification"] || ""
			if(!item_name)
				return
			SSscp_supply.submit_requisition(H, department, item_type, item_name, quantity, priority, justification)
			. = TRUE
		if("approve_requisition")
			var/requisition_id = params["requisition_id"]
			if(!requisition_id)
				return
			SSscp_supply.approve_requisition(requisition_id, H)
			. = TRUE
		if("reject_requisition")
			var/requisition_id = params["requisition_id"]
			var/reason = params["reason"] || "No reason provided"
			if(!requisition_id)
				return
			SSscp_supply.reject_requisition(requisition_id, reason)
			. = TRUE
		if("screen_delivery")
			var/requisition_id = params["requisition_id"]
			var/passed = text2num(params["passed"]) ? TRUE : FALSE
			if(!requisition_id)
				return
			SSscp_supply.screen_delivery(requisition_id, H, passed)
			. = TRUE
		if("log_anomalous_material")
			var/item_name = params["item_name"] || ""
			var/source = params["source"] || "Unknown"
			var/containment_class = params["containment_class"] || "safe"
			if(!item_name)
				return
			SSscp_supply.log_anomalous_material(item_name, source, containment_class)
			. = TRUE
