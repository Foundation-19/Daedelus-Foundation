/obj/machinery/computer/personnel_management_console
	name = "Personnel Management Console"
	desc = "A secure console for managing Foundation personnel assignments and transfers."
	icon_screen = "comm"
	icon_keyboard = "tech_key"
	req_access = list(ACCESS_ADMIN)
	circuit = /obj/item/circuitboard/computer/personnel_management
	light_color = LIGHT_COLOR_BLOOD_MAGIC

/obj/machinery/computer/personnel_management_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PersonnelManagement", "PERSONNEL MANAGEMENT")
		ui.open()

/obj/machinery/computer/personnel_management_console/ui_data(mob/user)
	var/list/data = list()
	var/list/personnel = list()
	for(var/mob/living/carbon/human/H in GLOB.mob_living_list)
		if(QDELETED(H) || H.stat == DEAD)
			continue
		personnel += list(list(
			"name" = H.name,
			"job" = H.job || "Unknown",
			"area" = get_area_name(H, TRUE),
			"health" = round(H.health / H.maxHealth * 100),
			"ref" = REF(H),
		))
	data["personnel"] = personnel
	return data

/obj/machinery/computer/personnel_management_console/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("transfer")
			var/mob/living/carbon/human/H = locate(params["ref"]) in GLOB.mob_living_list
			if(!istype(H) || H.stat == DEAD)
				return
			var/new_dept = params["department"]
			if(!new_dept)
				return
			to_chat(H, span_notice("You have been reassigned to [new_dept] by command staff."))
			. = TRUE

/obj/item/circuitboard/computer/personnel_management
	name = "Personnel Management Console (Circuit Board)"
	build_path = /obj/machinery/computer/personnel_management_console

/obj/machinery/computer/disciplinary_console
	name = "Disciplinary Action Console"
	desc = "A console for issuing formal disciplinary actions against Foundation personnel."
	icon_screen = "comm"
	icon_keyboard = "tech_key"
	req_access = list(ACCESS_ADMIN)
	circuit = /obj/item/circuitboard/computer/disciplinary
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	var/list/actions = list()

/obj/machinery/computer/disciplinary_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DisciplinaryConsole", "DISCIPLINARY ACTION")
		ui.open()

/obj/machinery/computer/disciplinary_console/ui_data(mob/user)
	var/list/data = list()
	data["actions"] = actions
	var/list/personnel = list()
	for(var/mob/living/carbon/human/H in GLOB.mob_living_list)
		if(QDELETED(H) || H.stat == DEAD)
			continue
		personnel += list(list("name" = H.name, "job" = H.job || "Unknown", "ref" = REF(H)))
	data["personnel"] = personnel
	return data

/obj/machinery/computer/disciplinary_console/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("issue_action")
			var/target_name = params["target"]
			var/action_type = params["action_type"]
			var/reason = params["reason"]
			if(!target_name || !action_type)
				return
			actions += list(list("target" = target_name, "type" = action_type, "reason" = reason, "time" = gameTimestamp("hh:mm"), "resolved" = FALSE))
			for(var/mob/living/carbon/human/H in GLOB.mob_living_list)
				if(H.name == target_name)
					to_chat(H, span_warning("DISCIPLINARY NOTICE: [action_type] - [reason]"))
					break
			if(GLOB.scp_admin_log)
				GLOB.scp_admin_log.log_event("DISCIPLINARY", action_type, usr?.ckey, target_name, reason, "MEDIUM")
			. = TRUE
		if("resolve")
			var/idx = text2num(params["index"])
			if(idx && idx <= length(actions))
				actions[idx]["resolved"] = TRUE
				. = TRUE

/obj/item/circuitboard/computer/disciplinary
	name = "Disciplinary Action Console (Circuit Board)"
	build_path = /obj/machinery/computer/disciplinary_console

/obj/machinery/computer/containment_protocol_console
	name = "Containment Protocol Console"
	desc = "A console for editing and managing SCP containment and recontainment procedures."
	icon_screen = "comm"
	icon_keyboard = "tech_key"
	req_access = list(ACCESS_SCIENCE)
	circuit = /obj/item/circuitboard/computer/containment_protocol
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	var/list/protocols = list()

/obj/machinery/computer/containment_protocol_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ContainmentProtocol", "CONTAINMENT PROTOCOLS")
		ui.open()

/obj/machinery/computer/containment_protocol_console/ui_static_data(mob/user)
	var/list/data = list()
	var/list/scp_list = list()
	for(var/mob/living/scp/S in GLOB.mob_living_list)
		scp_list += list(list(
			"name" = S.name,
			"scp_id" = S.name,
			"breached" = S.containment_status == "breached",
			"containment" = jointext(S.containment_requirements, "\n") || "Standard containment protocols apply.",
			"recontainment" = "Standard recontainment protocols apply.",
			"ref" = REF(S),
		))
	data["scps"] = scp_list
	return data

/obj/machinery/computer/containment_protocol_console/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("update_procedures")
			var/mob/living/scp/S = locate(params["ref"]) in GLOB.mob_living_list
			if(!istype(S))
				return
			var/procedure_type = params["type"]
			var/new_text = params["text"]
			if(procedure_type == "containment")
				S.containment_requirements = splittext(new_text, "\n")
			if(GLOB.scp_admin_log)
				GLOB.scp_admin_log.log_event("PROTOCOL", procedure_type, usr?.ckey, S.name, "Updated procedures", "LOW")
			. = TRUE

/obj/item/circuitboard/computer/containment_protocol
	name = "Containment Protocol Console (Circuit Board)"
	build_path = /obj/machinery/computer/containment_protocol_console

/obj/machinery/computer/emergency_broadcast_console
	name = "Emergency Broadcast Console"
	desc = "A secure console for issuing facility-wide emergency broadcasts and alert codes."
	icon_screen = "comm"
	icon_keyboard = "tech_key"
	req_access = list(ACCESS_ADMIN)
	circuit = /obj/item/circuitboard/computer/emergency_broadcast
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	var/last_broadcast = 0
	var/broadcast_cooldown = 60 SECONDS

/obj/machinery/computer/emergency_broadcast_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "EmergencyBroadcast", "EMERGENCY BROADCAST")
		ui.open()

/obj/machinery/computer/emergency_broadcast_console/ui_data(mob/user)
	var/list/data = list()
	data["cooldown_active"] = (last_broadcast + broadcast_cooldown) > world.time
	data["cooldown_remaining"] = max(0, (last_broadcast + broadcast_cooldown) - world.time)
	data["preset_codes"] = list(
		list("code" = "CODE BLACK", "desc" = "Multiple containment breaches"),
		list("code" = "CODE BIOHAZARD", "desc" = "Biological containment failure"),
		list("code" = "CI INCURSION", "desc" = "Chaos Insurgency attack"),
		list("code" = "EVACUATION", "desc" = "Facility evacuation ordered"),
		list("code" = "MEDICAL EMERGENCY", "desc" = "Mass casualty event"),
		list("code" = "POWER FAILURE", "desc" = "Critical power grid failure"),
	)
	return data

/obj/machinery/computer/emergency_broadcast_console/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("broadcast_preset")
			if(world.time < last_broadcast + broadcast_cooldown)
				return
			var/code = params["code"]
			var/message = params["message"] || "All personnel respond immediately."
			priority_announce("[code]: [message]", "EMERGENCY", null, ANNOUNCER_ALERT)
			last_broadcast = world.time
			if(GLOB.scp_admin_log)
				GLOB.scp_admin_log.log_event("BROADCAST", code, usr?.ckey, null, message, "HIGH")
			. = TRUE
		if("broadcast_custom")
			if(world.time < last_broadcast + broadcast_cooldown)
				return
			var/code = params["code"]
			var/message = params["message"]
			if(!code || !message)
				return
			priority_announce("[code]: [message]", "EMERGENCY", null, ANNOUNCER_ALERT)
			last_broadcast = world.time
			if(GLOB.scp_admin_log)
				GLOB.scp_admin_log.log_event("BROADCAST", code, usr?.ckey, null, message, "HIGH")
			. = TRUE

/obj/item/circuitboard/computer/emergency_broadcast
	name = "Emergency Broadcast Console (Circuit Board)"
	build_path = /obj/machinery/computer/emergency_broadcast_console

/obj/machinery/computer/clearance_review_console
	name = "Clearance Review Console"
	desc = "A console for submitting and reviewing personnel clearance level requests."
	icon_screen = "comm"
	icon_keyboard = "tech_key"
	req_access = list(ACCESS_ADMIN)
	circuit = /obj/item/circuitboard/computer/clearance_review
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	var/list/requests = list()

/obj/machinery/computer/clearance_review_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ClearanceReview", "CLEARANCE REVIEW")
		ui.open()

/obj/machinery/computer/clearance_review_console/ui_data(mob/user)
	var/list/data = list()
	data["requests"] = requests
	return data

/obj/machinery/computer/clearance_review_console/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("submit_request")
			var/requestor = params["name"]
			var/current = params["current_level"]
			var/requested = params["requested_level"]
			var/reason = params["reason"]
			requests += list(list("requestor" = requestor, "current" = current, "requested" = requested, "reason" = reason, "status" = "pending", "time" = gameTimestamp("hh:mm")))
			. = TRUE
		if("approve")
			var/idx = text2num(params["index"])
			if(idx && idx <= length(requests))
				requests[idx]["status"] = "approved"
				. = TRUE
		if("deny")
			var/idx = text2num(params["index"])
			if(idx && idx <= length(requests))
				requests[idx]["status"] = "denied"
				. = TRUE

/obj/item/circuitboard/computer/clearance_review
	name = "Clearance Review Console (Circuit Board)"
	build_path = /obj/machinery/computer/clearance_review_console

/obj/machinery/computer/facility_inspection_console
	name = "Facility Inspection Console"
	desc = "A console for conducting departmental facility inspections."
	icon_screen = "comm"
	icon_keyboard = "tech_key"
	req_access = list(ACCESS_ADMIN)
	circuit = /obj/item/circuitboard/computer/facility_inspection
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	var/list/inspections = list()

/obj/machinery/computer/facility_inspection_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FacilityInspection", "FACILITY INSPECTION")
		ui.open()

/obj/machinery/computer/facility_inspection_console/ui_data(mob/user)
	var/list/data = list()
	data["inspections"] = inspections
	return data

/obj/machinery/computer/facility_inspection_console/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("conduct_inspection")
			var/department = params["department"]
			var/rating = text2num(params["rating"]) || 50
			var/findings = params["findings"] || "No findings recorded."
			inspections += list(list("department" = department, "rating" = rating, "findings" = findings, "inspector" = usr?.name, "time" = gameTimestamp("hh:mm")))
			if(GLOB.scp_admin_log)
				GLOB.scp_admin_log.log_event("INSPECTION", department, usr?.ckey, null, "Rating: [rating]%", "LOW")
			. = TRUE

/obj/item/circuitboard/computer/facility_inspection
	name = "Facility Inspection Console (Circuit Board)"
	build_path = /obj/machinery/computer/facility_inspection_console

/obj/machinery/computer/department_requisition_console
	name = "Department Requisition Console"
	desc = "A console for submitting and approving interdepartmental supply requests."
	icon_screen = "comm"
	icon_keyboard = "tech_key"
	circuit = /obj/item/circuitboard/computer/department_requisition
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	var/list/requisitions = list()

/obj/machinery/computer/department_requisition_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DepartmentRequisition", "DEPARTMENT REQUISITION")
		ui.open()

/obj/machinery/computer/department_requisition_console/ui_data(mob/user)
	var/list/data = list()
	data["requisitions"] = requisitions
	return data

/obj/machinery/computer/department_requisition_console/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("submit_requisition")
			var/department = params["department"]
			var/item = params["item"]
			var/quantity = text2num(params["quantity"]) || 1
			var/priority = params["priority"] || "normal"
			var/reason = params["reason"] || ""
			requisitions += list(list("department" = department, "item" = item, "quantity" = quantity, "priority" = priority, "reason" = reason, "status" = "pending", "requestor" = usr?.name, "time" = gameTimestamp("hh:mm")))
			. = TRUE
		if("approve")
			var/idx = text2num(params["index"])
			if(idx && idx <= length(requisitions))
				requisitions[idx]["status"] = "approved"
				. = TRUE
		if("deny")
			var/idx = text2num(params["index"])
			if(idx && idx <= length(requisitions))
				requisitions[idx]["status"] = "denied"
				. = TRUE
		if("fulfill")
			var/idx = text2num(params["index"])
			if(idx && idx <= length(requisitions))
				requisitions[idx]["status"] = "fulfilled"
				. = TRUE

/obj/item/circuitboard/computer/department_requisition
	name = "Department Requisition Console (Circuit Board)"
	build_path = /obj/machinery/computer/department_requisition_console

/obj/machinery/computer/interdepartmental_memo_console
	name = "Interdepartmental Memo Console"
	desc = "A console for sending formal interdepartmental memos across the facility."
	icon_screen = "comm"
	icon_keyboard = "tech_key"
	circuit = /obj/item/circuitboard/computer/interdepartmental_memo
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	var/list/memos = list()

/obj/machinery/computer/interdepartmental_memo_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "InterdepartmentalMemo", "INTERDEPARTMENTAL MEMOS")
		ui.open()

/obj/machinery/computer/interdepartmental_memo_console/ui_data(mob/user)
	var/list/data = list()
	data["memos"] = memos
	return data

/obj/machinery/computer/interdepartmental_memo_console/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("send_memo")
			var/from_dept = params["from"]
			var/to_dept = params["to"]
			var/subject = params["subject"]
			var/body = params["body"]
			var/priority = params["priority"] || "normal"
			if(!subject || !body)
				return
			memos += list(list("from" = from_dept, "to" = to_dept, "subject" = subject, "body" = body, "priority" = priority, "time" = gameTimestamp("hh:mm"), "author" = usr?.name))
			if(GLOB.scp_admin_log)
				GLOB.scp_admin_log.log_event("MEMO", priority, usr?.ckey, to_dept, subject, "LOW")
			. = TRUE

/obj/item/circuitboard/computer/interdepartmental_memo
	name = "Interdepartmental Memo Console (Circuit Board)"
	build_path = /obj/machinery/computer/interdepartmental_memo_console
