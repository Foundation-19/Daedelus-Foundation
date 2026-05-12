
#define DISCIPLINE_WARNING "Written Warning"
#define DISCIPLINE_SUSPENSION "Suspension"
#define DISCIPLINE_DEMOTION "Demotion"
#define DISCIPLINE_TERMINATION "Termination"
#define DISCIPLINE_AMNESTIC "Amnestic Treatment"

#define REQUISITION_PENDING "Pending"
#define REQUISITION_APPROVED "Approved"
#define REQUISITION_DENIED "Denied"
#define REQUISITION_FULFILLED "Fulfilled"

#define MEMO_PRIORITY_LOW "Low"
#define MEMO_PRIORITY_STANDARD "Standard"
#define MEMO_PRIORITY_URGENT "Urgent"
#define MEMO_PRIORITY_EMERGENCY "Emergency"

#define INSPECTION_CONTAINMENT "Containment Integrity"
#define INSPECTION_SECURITY "Security Compliance"
#define INSPECTION_PERSONNEL "Personnel Readiness"
#define INSPECTION_MEDICAL "Medical Preparedness"
#define INSPECTION_ENGINEERING "Engineering Status"

/datum/disciplinary_record
	var/target_name
	var/target_rank
	var/issuer_name
	var/issuer_rank
	var/action_type
	var/reason
	var/timestamp
	var/resolved = FALSE
	var/appealed = FALSE

/datum/disciplinary_record/New(name, rank, issuer, issuer_rank, action, reason_text)
	target_name = name
	target_rank = rank
	issuer_name = issuer
	issuer_rank = issuer_rank
	action_type = action
	reason = reason_text
	timestamp = gameTimestamp()

/datum/requisition_order
	var/id
	var/requestor_name
	var/requestor_dept
	var/item_name
	var/item_category
	var/quantity = 1
	var/justification
	var/priority = MEMO_PRIORITY_STANDARD
	var/status = REQUISITION_PENDING
	var/reviewer_name
	var/review_notes
	var/timestamp
	var/cost = 0
	var/static/next_id = 1

/datum/requisition_order/New(name, dept, item, category, qty, reason, req_priority, req_cost)
	id = next_id++
	requestor_name = name
	requestor_dept = dept
	item_name = item
	item_category = category
	quantity = qty
	justification = reason
	priority = req_priority
	cost = req_cost
	timestamp = gameTimestamp()

/datum/interdepartmental_memo
	var/id
	var/sender_name
	var/sender_dept
	var/recipient_dept
	var/subject
	var/body
	var/priority = MEMO_PRIORITY_STANDARD
	var/timestamp
	var/read_by = list()
	var/replies = list()
	var/static/next_id = 1

/datum/interdepartmental_memo/New(name, dept, to_dept, subj, msg, prio)
	id = next_id++
	sender_name = name
	sender_dept = dept
	recipient_dept = to_dept
	subject = subj
	body = msg
	priority = prio
	timestamp = gameTimestamp()

/datum/foundation_clearance_request
	var/id
	var/requestor_name
	var/requestor_rank
	var/current_clearance
	var/requested_clearance
	var/justification
	var/supervisor_name
	var/status = "Pending"
	var/reviewer_name
	var/review_notes
	var/timestamp
	var/static/next_id = 1

/datum/foundation_clearance_request/New(name, rank, current, requested, reason, supervisor)
	id = next_id++
	requestor_name = name
	requestor_rank = rank
	current_clearance = current
	requested_clearance = requested
	justification = reason
	supervisor_name = supervisor
	timestamp = gameTimestamp()

/datum/inspection_report
	var/id
	var/inspector_name
	var	inspector_rank
	var	department
	var	inspection_type
	var	findings = list()
	var	rating = 0
	var	notes
	var	timestamp
	var	follow_up_required = FALSE
	var	static/next_id = 1

/datum/inspection_report/New(name, rank, dept, insp_type)
	id = next_id++
	inspector_name = name
	inspector_rank = rank
	department = dept
	inspection_type = insp_type
	timestamp = gameTimestamp()

/obj/machinery/computer/personnel_management_console
	name = "Personnel Management Console"
	desc = "A terminal for managing personnel assignments, transfers, and records."
	icon_screen = "crew"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/machine/personnel_management_console
	req_access = list(ACCESS_ADMIN)

/obj/machinery/computer/personnel_management_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PersonnelManagement")
		ui.open()

/obj/machinery/computer/personnel_management_console/ui_data(mob/user)
	var/list/data = list()
	var/list/personnel = list()
	for(var/mob/living/carbon/human/H in GLOB.mob_living_list)
		if(!H.real_name || H.real_name == "Unknown")
			continue
		var/list/p_data = list()
		p_data["name"] = H.real_name
		p_data["rank"] = H.job || "Unknown"
		var/dept = "Unassigned"
		if(H.mind && H.mind.assigned_role)
			var/datum/job/J = H.mind.assigned_role
			dept = J.title || "Unassigned"
		p_data["department"] = dept
		personnel += list(p_data)
	data["personnel"] = personnel
	return data

/obj/machinery/computer/personnel_management_console/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	if(!allowed(usr))
		to_chat(usr, span_warning("Access denied."))
		return
	switch(action)
		if("transfer")
			var/target_name = params["name"]
			var/new_dept = params["department"]
			if(!target_name || !new_dept)
				return
			var/mob/living/carbon/human/H = get_mob_by_name(target_name)
			if(!H)
				return
			to_chat(H, span_notice("You have been transferred to the [new_dept] department by [usr.real_name]."))
			log_paper("[key_name(usr)] transferred [target_name] to [new_dept]")
			scp_admin_log("PERSONNEL", usr, "Transferred [target_name] to [new_dept]")
			. = TRUE
		if("reassign")
			var/target_name = params["name"]
			var/new_rank = params["rank"]
			if(!target_name || !new_rank)
				return
			var/mob/living/carbon/human/H = get_mob_by_name(target_name)
			if(!H)
				return
			var/old_rank = H.job || "Unknown"
			to_chat(H, span_notice("Your position has been changed from [old_rank] to [new_rank] by [usr.real_name]."))
			log_paper("[key_name(usr)] reassigned [target_name] from [old_rank] to [new_rank]")
			scp_admin_log("PERSONNEL", usr, "Reassigned [target_name]: [old_rank] -> [new_rank]")
			. = TRUE

/obj/machinery/computer/disciplinary_console
	name = "Disciplinary Action Console"
	desc = "A terminal for issuing formal disciplinary actions against Foundation personnel."
	icon_screen = "security"
	icon_keyboard = "security_key"
	circuit = /obj/item/circuitboard/machine/disciplinary_console
	req_access = list(ACCESS_ADMIN)

	var/list/disciplinary_records = list()

/obj/machinery/computer/disciplinary_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DisciplinaryConsole")
		ui.open()

/obj/machinery/computer/disciplinary_console/ui_data(mob/user)
	var/list/data = list()
	var/list/records = list()
	for(var/datum/disciplinary_record/DR in disciplinary_records)
		var/list/r = list()
		r["target_name"] = DR.target_name
		r["target_rank"] = DR.target_rank
		r["issuer_name"] = DR.issuer_name
		r["action_type"] = DR.action_type
		r["reason"] = DR.reason
		r["timestamp"] = DR.timestamp
		r["resolved"] = DR.resolved
		records += list(r)
	data["records"] = records
	var/list/personnel = list()
	for(var/mob/living/carbon/human/H in GLOB.mob_living_list)
		if(H.real_name && H.real_name != "Unknown")
			personnel += list(list("name" = H.real_name, "rank" = H.job || "Unknown"))
	data["personnel"] = personnel
	return data

/obj/machinery/computer/disciplinary_console/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	if(!allowed(usr))
		to_chat(usr, span_warning("Access denied."))
		return
	switch(action)
		if("issue_action")
			var/target_name = params["target"]
			var/action_type = params["action_type"]
			var/reason = params["reason"]
			if(!target_name || !action_type || !reason)
				return
			var/target_rank = "Unknown"
			var/mob/living/carbon/human/target = get_mob_by_name(target_name)
			if(target)
				target_rank = target.job || "Unknown"
			var/datum/disciplinary_record/DR = new(target_name, target_rank, usr.real_name, usr.job, action_type, reason)
			disciplinary_records += DR
			var/mob/living/carbon/human/H = get_mob_by_name(target_name)
			if(H)
				switch(action_type)
					if(DISCIPLINE_WARNING)
						to_chat(H, span_warning("You have received a formal written warning from [usr.real_name]: [reason]"))
					if(DISCIPLINE_SUSPENSION)
						to_chat(H, span_warning("You have been suspended from duty by [usr.real_name]: [reason]"))
					if(DISCIPLINE_DEMOTION)
						to_chat(H, span_warning("You have been demoted by [usr.real_name]: [reason]"))
					if(DISCIPLINE_TERMINATION)
						to_chat(H, span_warning("Your employment has been terminated by [usr.real_name]: [reason]"))
					if(DISCIPLINE_AMNESTIC)
						to_chat(H, span_warning("You have been scheduled for amnestic treatment by [usr.real_name]: [reason]"))
			log_paper("[key_name(usr)] issued [action_type] to [target_name]: [reason]")
			scp_admin_log("DISCIPLINE", usr, "Issued [action_type] to [target_name]: [reason]")
			. = TRUE
		if("resolve")
			var/target_name = params["target"]
			for(var/datum/disciplinary_record/DR in disciplinary_records)
				if(DR.target_name == target_name && !DR.resolved)
					DR.resolved = TRUE
					break
			. = TRUE

/obj/machinery/computer/clearance_review_console
	name = "Clearance Review Console"
	desc = "A terminal for requesting and reviewing security clearance changes."
	icon_screen = "id"
	icon_keyboard = "id_key"
	circuit = /obj/item/circuitboard/machine/clearance_review_console
	req_access = list(ACCESS_ADMIN)

	var/list/clearance_requests = list()

/obj/machinery/computer/clearance_review_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ClearanceReview")
		ui.open()

/obj/machinery/computer/clearance_review_console/ui_data(mob/user)
	var/list/data = list()
	var/list/requests = list()
	for(var/datum/foundation_clearance_request/CR in clearance_requests)
		var/list/r = list()
		r["id"] = CR.id
		r["requestor_name"] = CR.requestor_name
		r["requestor_rank"] = CR.requestor_rank
		r["current_clearance"] = CR.current_clearance
		r["requested_clearance"] = CR.requested_clearance
		r["justification"] = CR.justification
		r["supervisor"] = CR.supervisor_name
		r["status"] = CR.status
		r["reviewer"] = CR.reviewer_name
		r["timestamp"] = CR.timestamp
		requests += list(r)
	data["requests"] = requests
	data["is_reviewer"] = allowed(usr)
	return data

/obj/machinery/computer/clearance_review_console/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	switch(action)
		if("submit_request")
			var/requested = params["requested_clearance"]
			var	justification = params["justification"]
			var	supervisor = params["supervisor"]
			if(!requested || !justification)
				return
			var/mob/living/carbon/human/H = usr
			var/current = "Unknown"
			if(H.wear_id)
				var/obj/item/card/id/ID = H.wear_id.GetID()
				if(ID)
					current = "Foundation Personnel"
			var/datum/foundation_clearance_request/CR = new(usr.real_name, usr.job, current, requested, justification, supervisor)
			clearance_requests += CR
			priority_announce("Clearance review request submitted by [usr.real_name]. Awaiting supervisor approval.", "Clearance Review System", "Clearance Review")
			log_paper("[key_name(usr)] submitted clearance request: [current] -> [requested]")
			. = TRUE
		if("approve_request")
			if(!allowed(usr))
				to_chat(usr, span_warning("Access denied."))
				return
			var/req_id = text2num(params["id"])
			for(var/datum/foundation_clearance_request/CR in clearance_requests)
				if(CR.id == req_id && CR.status == "Pending")
					CR.status = "Approved"
					CR.reviewer_name = usr.real_name
					CR.review_notes = params["notes"]
					var/mob/living/carbon/human/H = get_mob_by_name(CR.requestor_name)
					if(H)
						to_chat(H, span_notice("Your clearance request has been approved by [usr.real_name]. Report to the ID Card Printer."))
					log_paper("[key_name(usr)] approved clearance request #[req_id] for [CR.requestor_name]")
					scp_admin_log("CLEARANCE", usr, "Approved clearance for [CR.requestor_name]: [CR.current_clearance] -> [CR.requested_clearance]")
					break
			. = TRUE
		if("deny_request")
			if(!allowed(usr))
				to_chat(usr, span_warning("Access denied."))
				return
			var/req_id = text2num(params["id"])
			for(var/datum/foundation_clearance_request/CR in clearance_requests)
				if(CR.id == req_id && CR.status == "Pending")
					CR.status = "Denied"
					CR.reviewer_name = usr.real_name
					CR.review_notes = params["notes"]
					var/mob/living/carbon/human/H = get_mob_by_name(CR.requestor_name)
					if(H)
						to_chat(H, span_warning("Your clearance request has been denied by [usr.real_name]."))
					log_paper("[key_name(usr)] denied clearance request #[req_id] for [CR.requestor_name]")
					break
			. = TRUE

/obj/machinery/computer/containment_protocol_console
	name = "Containment Protocol Console"
	desc = "A terminal for modifying containment procedures for SCP objects."
	icon_screen = "ai"
	icon_keyboard = "ai_key"
	circuit = /obj/item/circuitboard/machine/containment_protocol_console
	req_access = list(ACCESS_ADMIN)

	var/list/protocol_log = list()

/obj/machinery/computer/containment_protocol_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ContainmentProtocol")
		ui.open()

/obj/machinery/computer/containment_protocol_console/ui_static_data(mob/user)
	var/list/data = list()
	var/list/scp_list = list()
	for(var/mob/living/scp/S in GLOB.mob_living_list)
		var/list/s = list()
		s["name"] = S.name
		s["scp_id"] = S.SCP
		s["status"] = S.stat == DEAD ? "Neutralized" : (S.breached ? "Breached" : "Contained")
		s["containment_procedures"] = S.containment_procedures || "Standard humanoid containment cell."
		s["recontainment_procedures"] = S.recontainment_procedures || "Standard recontainment protocol."
		scp_list += list(s)
	data["scp_list"] = scp_list
	return data

/obj/machinery/computer/containment_protocol_console/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	if(!allowed(usr))
		to_chat(usr, span_warning("Access denied."))
		return
	switch(action)
		if("update_containment")
			var/scp_id = params["scp_id"]
			var/new_procedures = params["procedures"]
			if(!scp_id || !new_procedures)
				return
			for(var/mob/living/scp/S in GLOB.mob_living_list)
				if("[S.SCP]" == scp_id)
					var/old = S.containment_procedures
					S.containment_procedures = new_procedures
					protocol_log += "[gameTimestamp()] | [usr.real_name] updated containment for [S.name]: [old] -> [new_procedures]"
					log_paper("[key_name(usr)] updated containment procedures for [S.name]")
					scp_admin_log("CONTAINMENT", usr, "Updated containment for [S.name]")
					break
			update_static_data(usr, ui)
			. = TRUE
		if("update_recontainment")
			var/scp_id = params["scp_id"]
			var	new_procedures = params["procedures"]
			if(!scp_id || !new_procedures)
				return
			for(var/mob/living/scp/S in GLOB.mob_living_list)
				if("[S.SCP]" == scp_id)
					var/old = S.recontainment_procedures
					S.recontainment_procedures = new_procedures
					protocol_log += "[gameTimestamp()] | [usr.real_name] updated recontainment for [S.name]: [old] -> [new_procedures]"
					log_paper("[key_name(usr)] updated recontainment procedures for [S.name]")
					scp_admin_log("CONTAINMENT", usr, "Updated recontainment for [S.name]")
					break
			update_static_data(usr, ui)
			. = TRUE

/obj/machinery/computer/facility_inspection_console
	name = "Facility Inspection Console"
	desc = "A terminal for conducting official facility inspections and audits."
	icon_screen = "generic"
	icon_keyboard = "generic_key"
	circuit = /obj/item/circuitboard/machine/facility_inspection_console
	req_access = list(ACCESS_ADMIN)

	var/list/inspection_reports = list()
	var/list/active_inspections = list()

/obj/machinery/computer/facility_inspection_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FacilityInspection")
		ui.open()

/obj/machinery/computer/facility_inspection_console/ui_data(mob/user)
	var/list/data = list()
	var/list/reports = list()
	for(var/datum/inspection_report/IR in inspection_reports)
		var/list/r = list()
		r["id"] = IR.id
		r["inspector"] = IR.inspector_name
		r["department"] = IR.department
		r["type"] = IR.inspection_type
		r["rating"] = IR.rating
		r["findings"] = IR.findings
		r["notes"] = IR.notes
		r["timestamp"] = IR.timestamp
		r["follow_up"] = IR.follow_up_required
		reports += list(r)
	data["reports"] = reports
	return data

/obj/machinery/computer/facility_inspection_console/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	if(!allowed(usr))
		to_chat(usr, span_warning("Access denied."))
		return
	switch(action)
		if("begin_inspection")
			var/department = params["department"]
			var/insp_type = params["type"]
			if(!department || !insp_type)
				return
			var/datum/inspection_report/IR = new(usr.real_name, usr.job, department, insp_type)
			var/rating = 100
			var/list/findings = list()
			switch(insp_type)
				if(INSPECTION_CONTAINMENT)
					var/breached = 0
					var/contained = 0
					for(var/mob/living/scp/S in GLOB.mob_living_list)
						if(S.breached)
							breached++
						else
							contained++
					rating = contained > 0 ? round((contained / max(contained + breached, 1)) * 100) : 0
					if(breached > 0)
						findings += "[breached] SCP object(s) currently breached"
					if(contained > 0)
						findings += "[contained] SCP object(s) properly contained"
				if(INSPECTION_SECURITY)
					var/sec_count = 0
					for(var/mob/living/carbon/human/H in GLOB.mob_living_list)
						if(H.job in list("LCZ Guard", "HCZ Guard", "EZ Guard", "Guard Commander"))
							sec_count++
					rating = min(sec_count * 20, 100)
					findings += "[sec_count] security personnel on duty"
				if(INSPECTION_PERSONNEL)
					var/staff_count = 0
					for(var/mob/living/carbon/human/H in GLOB.mob_living_list)
						if(!istype(H, /mob/living/scp))
							staff_count++
					rating = min(staff_count * 5, 100)
					findings += "[staff_count] personnel on facility"
				if(INSPECTION_MEDICAL)
					var/med_count = 0
					for(var/mob/living/carbon/human/H in GLOB.mob_living_list)
						if(H.job in list("Medical Doctor", "Chief Medical Officer", "Chemist", "Psychiatrist"))
							med_count++
					rating = min(med_count * 25, 100)
					findings += "[med_count] medical personnel on duty"
				if(INSPECTION_ENGINEERING)
					var/eng_count = 0
					for(var/mob/living/carbon/human/H in GLOB.mob_living_list)
						if(H.job in list("Station Engineer", "Chief Engineer", "Atmospheric Technician"))
							eng_count++
					rating = min(eng_count * 25, 100)
					findings += "[eng_count] engineering personnel on duty"
			IR.rating = rating
			IR.findings = findings
			IR.follow_up_required = rating < 50
			inspection_reports += IR
			priority_announce("Facility inspection completed for [department] - [insp_type]. Rating: [rating]%. [IR.follow_up_required ? "FOLLOW-UP REQUIRED." : ""]", "Facility Inspection Office", "Inspection Report")
			log_paper("[key_name(usr)] conducted [insp_type] inspection of [department]: [rating]%")
			scp_admin_log("INSPECTION", usr, "Inspected [department] [insp_type]: [rating]%")
			. = TRUE
		if("add_notes")
			var/req_id = text2num(params["id"])
			var/notes = params["notes"]
			for(var/datum/inspection_report/IR in inspection_reports)
				if(IR.id == req_id)
					IR.notes = notes
					break
			. = TRUE

/obj/machinery/computer/department_requisition_console
	name = "Department Requisition Console"
	desc = "A terminal for submitting and reviewing departmental supply requests."
	icon_screen = "supply"
	icon_keyboard = "cargo_key"
	circuit = /obj/item/circuitboard/machine/department_requisition_console

	var/list/requisition_orders = list()

/obj/machinery/computer/department_requisition_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DepartmentRequisition")
		ui.open()

/obj/machinery/computer/department_requisition_console/ui_data(mob/user)
	var/list/data = list()
	var/list/orders = list()
	for(var/datum/requisition_order/RO in requisition_orders)
		var/list/o = list()
		o["id"] = RO.id
		o["requestor"] = RO.requestor_name
		o["department"] = RO.requestor_dept
		o["item"] = RO.item_name
		o["category"] = RO.item_category
		o["quantity"] = RO.quantity
		o["justification"] = RO.justification
		o["priority"] = RO.priority
		o["status"] = RO.status
		o["cost"] = RO.cost
		o["reviewer"] = RO.reviewer_name
		o["timestamp"] = RO.timestamp
		orders += list(o)
	data["orders"] = orders
	data["is_logistics"] = allowed(usr) || (usr.job in list("Quartermaster", "Cargo Technician", "Logistics Officer"))
	return data

/obj/machinery/computer/department_requisition_console/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	switch(action)
		if("submit_request")
			var/item_name = params["item"]
			var	category = params["category"]
			var	qty = text2num(params["quantity"]) || 1
			var	justification = params["justification"]
			var	priority = params["priority"]
			var	cost = text2num(params["cost"]) || 0
			if(!item_name || !justification)
				return
			var/mob/living/carbon/human/H = usr
			var/dept = "Unknown"
			if(H.mind && H.mind.assigned_role)
				dept = H.job || "Unknown"
			var/datum/requisition_order/RO = new(usr.real_name, dept, item_name, category, qty, justification, priority, cost)
			requisition_orders += RO
			log_paper("[key_name(usr)] submitted requisition for [qty]x [item_name] ([cost] credits)")
			. = TRUE
		if("approve_request")
			if(!(allowed(usr) || (usr.job in list("Quartermaster", "Cargo Technician", "Logistics Officer"))))
				to_chat(usr, span_warning("Access denied."))
				return
			var/req_id = text2num(params["id"])
			for(var/datum/requisition_order/RO in requisition_orders)
				if(RO.id == req_id && RO.status == REQUISITION_PENDING)
					RO.status = REQUISITION_APPROVED
					RO.reviewer_name = usr.real_name
					RO.review_notes = params["notes"]
					priority_announce("Requisition #[req_id] for [RO.item_name] has been approved by [usr.real_name].", "Logistics Department", "Requisition Update")
					log_paper("[key_name(usr)] approved requisition #[req_id]")
					break
			. = TRUE
		if("deny_request")
			if(!(allowed(usr) || (usr.job in list("Quartermaster", "Cargo Technician", "Logistics Officer"))))
				to_chat(usr, span_warning("Access denied."))
				return
			var/req_id = text2num(params["id"])
			for(var/datum/requisition_order/RO in requisition_orders)
				if(RO.id == req_id && RO.status == REQUISITION_PENDING)
					RO.status = REQUISITION_DENIED
					RO.reviewer_name = usr.real_name
					RO.review_notes = params["notes"]
					log_paper("[key_name(usr)] denied requisition #[req_id]")
					break
			. = TRUE
		if("fulfill_request")
			if(!(allowed(usr) || (usr.job in list("Quartermaster", "Cargo Technician", "Logistics Officer"))))
				to_chat(usr, span_warning("Access denied."))
				return
			var/req_id = text2num(params["id"])
			for(var/datum/requisition_order/RO in requisition_orders)
				if(RO.id == req_id && RO.status == REQUISITION_APPROVED)
					RO.status = REQUISITION_FULFILLED
					log_paper("[key_name(usr)] fulfilled requisition #[req_id]")
					break
			. = TRUE

/obj/machinery/computer/interdepartmental_memo_console
	name = "Interdepartmental Memo Console"
	desc = "A terminal for sending and receiving formal interdepartmental communications."
	icon_screen = "mail"
	icon_keyboard = "generic_key"
	circuit = /obj/item/circuitboard/machine/interdepartmental_memo_console

	var/list/memos = list()

/obj/machinery/computer/interdepartmental_memo_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "InterdepartmentalMemo")
		ui.open()

/obj/machinery/computer/interdepartmental_memo_console/ui_data(mob/user)
	var/list/data = list()
	var/list/memo_list = list()
	var/mob/living/carbon/human/H = usr
	var/my_dept = "Unknown"
	if(H.mind && H.mind.assigned_role)
		my_dept = H.job || "Unknown"
	for(var/datum/interdepartmental_memo/M in memos)
		var/list/m = list()
		m["id"] = M.id
		m["sender"] = M.sender_name
		m["sender_dept"] = M.sender_dept
		m["recipient_dept"] = M.recipient_dept
		m["subject"] = M.subject
		m["body"] = M.body
		m["priority"] = M.priority
		m["timestamp"] = M.timestamp
		m["is_relevant"] = (M.recipient_dept == my_dept || M.sender_dept == my_dept || M.recipient_dept == "All Departments")
		memo_list += list(m)
	data["memos"] = memo_list
	data["my_department"] = my_dept
	data["departments"] = list("Command", "Security", "Medical", "Science", "Engineering", "Logistics", "Service", "D-Class Management", "MTF Operations", "All Departments")
	return data

/obj/machinery/computer/interdepartmental_memo_console/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	switch(action)
		if("send_memo")
			var/recipient = params["recipient_dept"]
			var	subject = params["subject"]
			var	body = params["body"]
			var	priority = params["priority"]
			if(!recipient || !subject || !body)
				return
			var/mob/living/carbon/human/H = usr
			var/my_dept = "Unknown"
			if(H.mind && H.mind.assigned_role)
				my_dept = H.job || "Unknown"
			var/datum/interdepartmental_memo/M = new(usr.real_name, my_dept, recipient, subject, body, priority)
			memos += M
			if(priority == MEMO_PRIORITY_EMERGENCY || priority == MEMO_PRIORITY_URGENT)
				priority_announce("Priority memo from [usr.real_name] to [recipient]: [subject]", "Internal Communications", "Interdepartmental Memo")
			log_paper("[key_name(usr)] sent [priority] memo to [recipient]: [subject]")
			. = TRUE

/obj/machinery/computer/emergency_broadcast_console
	name = "Emergency Broadcast Console"
	desc = "A terminal for issuing structured emergency broadcasts and protocols."
	icon_screen = "comm"
	icon_keyboard = "com_key"
	circuit = /obj/item/circuitboard/machine/emergency_broadcast_console
	req_access = list(ACCESS_ADMIN)

	var/last_broadcast = 0
	var/broadcast_cooldown = 30 SECONDS

/obj/machinery/computer/emergency_broadcast_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "EmergencyBroadcast")
		ui.open()

/obj/machinery/computer/emergency_broadcast_console/ui_data(mob/user)
	var/list/data = list()
	data["cooldown_remaining"] = max(0, last_broadcast + broadcast_cooldown - world.time)
	data["can_broadcast"] = (world.time >= last_broadcast + broadcast_cooldown) && allowed(usr)
	return data

/obj/machinery/computer/emergency_broadcast_console/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	if(!allowed(usr))
		to_chat(usr, span_warning("Access denied."))
		return
	if(world.time < last_broadcast + broadcast_cooldown)
		to_chat(usr, span_warning("Emergency broadcast systems recharging. Please wait."))
		return
	switch(action)
		if("broadcast_code_black")
			priority_announce("ATTENTION ALL PERSONNEL. CODE BLACK - TOTAL CONTAINMENT FAILURE. ALL PERSONNEL REPORT TO EMERGENCY STATIONS. THIS IS NOT A DRILL.", "Emergency Broadcast System", "CODE BLACK - TOTAL CONTAINMENT FAILURE", ANNOUNCER_ALERT)
			last_broadcast = world.time
			scp_admin_log("EMERGENCY", usr, "Issued CODE BLACK broadcast")
			. = TRUE
		if("broadcast_biohazard")
			priority_announce("ATTENTION ALL PERSONNEL. BIOHAZARD PROTOCOL ACTIVATED. CONTAMINATION ZONE ACTIVE. ALL NON-ESSENTIAL PERSONNEL EVACUATE AFFECTED AREAS IMMEDIATELY.", "Emergency Broadcast System", "BIOHAZARD ALERT", ANNOUNCER_ALERT)
			last_broadcast = world.time
			scp_admin_log("EMERGENCY", usr, "Issued BIOHAZARD broadcast")
			. = TRUE
		if("broadcast_ci_incursion")
			priority_announce("ATTENTION ALL PERSONNEL. HOSTILE FORCE INCURSION DETECTED. SECURITY PERSONNEL TO DEFENSIVE POSITIONS. ALL OTHERS SHELTER IN PLACE.", "Emergency Broadcast System", "HOSTILE INCURSION ALERT", ANNOUNCER_ALERT)
			last_broadcast = world.time
			scp_admin_log("EMERGENCY", usr, "Issued CI INCURSION broadcast")
			. = TRUE
		if("broadcast_evacuation")
			priority_announce("ATTENTION ALL PERSONNEL. FACILITY EVACUATION ORDERED. PROCEED TO SURFACE LEVEL EVACUATION POINTS IMMEDIATELY. DO NOT DELAY.", "Emergency Broadcast System", "EVACUATION ORDER", ANNOUNCER_ALERT)
			last_broadcast = world.time
			scp_admin_log("EMERGENCY", usr, "Issued EVACUATION broadcast")
			. = TRUE
		if("broadcast_medical_emergency")
			priority_announce("MEDICAL EMERGENCY DECLARED. ALL MEDICAL PERSONNEL REPORT TO INFIRMARY. CASUALTY COLLECTION POINT ESTABLISHED.", "Emergency Broadcast System", "MEDICAL EMERGENCY", ANNOUNCER_ALERT)
			last_broadcast = world.time
			scp_admin_log("EMERGENCY", usr, "Issued MEDICAL EMERGENCY broadcast")
			. = TRUE
		if("broadcast_power_failure")
			priority_announce("CRITICAL POWER FAILURE. ALL NON-ESSENTIAL SYSTEMS SUSPENDED. ENGINEERING PERSONNEL REPORT TO POWER SYSTEMS IMMEDIATELY.", "Emergency Broadcast System", "POWER FAILURE ALERT", ANNOUNCER_ALERT)
			last_broadcast = world.time
			scp_admin_log("EMERGENCY", usr, "Issued POWER FAILURE broadcast")
			. = TRUE
		if("broadcast_custom")
			var/message = params["message"]
			var	code = params["code"] || "EMERGENCY"
			if(!message)
				return
			priority_announce(message, "Emergency Broadcast System", "[code] - EMERGENCY BROADCAST", ANNOUNCER_ALERT)
			last_broadcast = world.time
			scp_admin_log("EMERGENCY", usr, "Issued custom broadcast: [code]")
			. = TRUE

/proc/scp_admin_log(log_type, mob/user, message)
	if(!GLOB.scp_admin_log)
		return
	GLOB.scp_admin_log.log_event(log_type, null, user ? user.ckey : null, null, message, 2)

/obj/item/circuitboard/machine/personnel_management_console
	name = "Personnel Management Console"
	build_path = /obj/machinery/computer/personnel_management_console

/obj/item/circuitboard/machine/disciplinary_console
	name = "Disciplinary Action Console"
	build_path = /obj/machinery/computer/disciplinary_console

/obj/item/circuitboard/machine/clearance_review_console
	name = "Clearance Review Console"
	build_path = /obj/machinery/computer/clearance_review_console

/obj/item/circuitboard/machine/containment_protocol_console
	name = "Containment Protocol Console"
	build_path = /obj/machinery/computer/containment_protocol_console

/obj/item/circuitboard/machine/facility_inspection_console
	name = "Facility Inspection Console"
	build_path = /obj/machinery/computer/facility_inspection_console

/obj/item/circuitboard/machine/department_requisition_console
	name = "Department Requisition Console"
	build_path = /obj/machinery/computer/department_requisition_console

/obj/item/circuitboard/machine/interdepartmental_memo_console
	name = "Interdepartmental Memo Console"
	build_path = /obj/machinery/computer/interdepartmental_memo_console

/obj/item/circuitboard/machine/emergency_broadcast_console
	name = "Emergency Broadcast Console"
	build_path = /obj/machinery/computer/emergency_broadcast_console

/var/list/GLOB/admin_expansion_memos = list()
/var/list/GLOB/admin_expansion_requisitions = list()
/var/list/GLOB/admin_expansion_clearance_requests = list()
/var/list/GLOB/admin_expansion_disciplinary = list()
/var/list/GLOB/admin_expansion_inspections = list()
