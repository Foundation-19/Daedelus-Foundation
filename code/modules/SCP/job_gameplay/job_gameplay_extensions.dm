/datum/controller/subsystem/scp_triage/proc/assist_treatment(patient_id, mob/living/carbon/human/assistant)
	if(!istype(assistant))
		return FALSE
	for(var/list/P in triage_queue)
		if(P["patient_id"] == patient_id && P["status"] == TRIAGE_TREATING)
			update_doctor_stats(assistant.ckey, "assist_treatment")
			if(SSscp_research?.manager)
				SSscp_research.manager.adjust_research_points(5, "medical_assist")
			to_chat(assistant, span_notice("You assist with treating [P["patient_name"]]. +5 research points."))
			return TRUE
	return FALSE

/datum/controller/subsystem/scp_triage/proc/dispatch_trainee(patient_id, mob/living/carbon/human/trainee)
	if(!istype(trainee))
		return FALSE
	for(var/list/P in triage_queue)
		if(P["patient_id"] == patient_id && P["status"] == TRIAGE_AWAITING)
			P["status"] = TRIAGE_TRIAGED
			P["assigned_doctor"] = trainee.real_name
			update_doctor_stats(trainee.ckey, "dispatch_trainee")
			to_chat(trainee, span_notice("You have been dispatched to assist [P["patient_name"]]."))
			return TRUE
	return FALSE

/datum/controller/subsystem/containment_integrity/proc/self_assign_task(task_id, mob/living/carbon/human/engineer)
	if(!istype(engineer))
		return FALSE
	for(var/list/T in maintenance_tasks)
		if(T["task_id"] == task_id && T["status"] == MAINT_SCHEDULED)
			T["assigned_engineer"] = engineer.real_name
			T["assigned_ckey"] = engineer.ckey
			T["status"] = MAINT_IN_PROGRESS
			log_integrity_event("[engineer.real_name] self-assigned maintenance task: [T["reason"]]", "maintenance")
			return TRUE
	return FALSE

/datum/controller/subsystem/containment_integrity/proc/complete_assigned_task(task_id, repair_amount, mob/living/carbon/human/engineer)
	if(!istype(engineer))
		return FALSE
	for(var/list/T in maintenance_tasks)
		if(T["task_id"] == task_id && T["assigned_ckey"] == engineer.ckey && T["status"] == MAINT_IN_PROGRESS)
			T["status"] = MAINT_COMPLETE
			var/zone_name = T["zone"]
			repair_zone(zone_name, repair_amount)
			total_maintenance_done++
			log_integrity_event("[engineer.real_name] completed maintenance: [T["reason"]]", "maintenance")
			if(SSscp_research?.manager)
				SSscp_research.manager.adjust_research_points(10, "containment_maintenance")
			to_chat(engineer, span_notice("Maintenance task completed. +10 research points."))
			return TRUE
	return FALSE

/datum/controller/subsystem/scp_supply/proc/submit_requisition_open(department, item_type, item_name, quantity, priority, justification, mob/living/carbon/human/requestor)
	if(!istype(requestor))
		return null
	return submit_requisition(requestor, department, item_type, item_name, quantity, priority, justification)

/datum/controller/subsystem/scp_service/proc/assistant_task_complete(task_type, mob/living/carbon/human/assistant)
	if(!istype(assistant))
		return FALSE
	var/reward = 5
	switch(task_type)
		if("cleaning")
			total_decon_routes_completed++
			reward = 5
		if("delivery")
			reward = 5
		if("assistance")
			reward = 8
		else
			reward = 3
	if(SSscp_research?.manager)
		SSscp_research.manager.adjust_research_points(reward, "assistant_task:[task_type]")
	to_chat(assistant, span_notice("Task complete. +[reward] research points."))
	return TRUE

/datum/computer_file/program/scp_triage/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H) || !SSscp_triage)
		return
	switch(action)
		if("assist_treatment")
			SSscp_triage.assist_treatment(params["patient_id"], H)
			. = TRUE
		if("dispatch_trainee")
			SSscp_triage.dispatch_trainee(params["patient_id"], H)
			. = TRUE

/datum/computer_file/program/scp_supply/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H) || !SSscp_supply)
		return
	switch(action)
		if("submit_requisition_open")
			SSscp_supply.submit_requisition_open(
				params["department"] || "logistics",
				params["item_type"] || "STANDARD",
				params["item_name"] || "General supplies",
				text2num(params["quantity"]) || 1,
				text2num(params["priority"]) || 1,
				params["justification"] || "",
				H,
			)
			. = TRUE

/datum/controller/subsystem/scp_patrol/proc/accept_patrol_officer(route_id, mob/living/carbon/human/officer)
	return accept_patrol(route_id, officer)

/datum/controller/subsystem/scp_patrol/proc/submit_shift_report(report_text, mob/living/carbon/human/officer)
	if(!istype(officer) || !report_text)
		return FALSE
	patrol_log += list(list(
		"report_id" = "rpt_[world.time]",
		"officer" = officer.real_name,
		"report_text" = report_text,
		"time" = time2text(world.time, "hh:mm:ss"),
		"type" = "shift_report",
	))
	if(guard_stats[officer.ckey])
		guard_stats[officer.ckey]["shift_reports"]++
	if(SSscp_research?.manager)
		SSscp_research.manager.adjust_research_points(8, "patrol_shift_report")
	to_chat(officer, span_notice("Shift report submitted. +8 research points."))
	return TRUE

/datum/controller/subsystem/scp_patrol/proc/respond_to_incident(incident_type, zone, mob/living/carbon/human/officer)
	if(!istype(officer))
		return FALSE
	if(!guard_stats[officer.ckey])
		guard_stats[officer.ckey] = list("name" = officer.real_name, "patrols_completed" = 0, "anomalies_reported" = 0, "breach_responses" = 0, "contraband_seized" = 0, "shift_reports" = 0, "incident_responses" = 0)
	guard_stats[officer.ckey]["incident_responses"]++
	total_breach_responses++
	patrol_log += list(list(
		"report_id" = "inc_[world.time]",
		"officer" = officer.real_name,
		"incident_type" = incident_type,
		"zone" = zone,
		"time" = time2text(world.time, "hh:mm:ss"),
		"type" = "incident_response",
	))
	if(SSfoundation_comms)
		SSfoundation_comms.create_dispatch(null, 2, "Officer [officer.real_name] responding to [incident_type] in [zone].", 1)
	if(SSscp_research?.manager)
		SSscp_research.manager.adjust_research_points(15, "incident_response:[incident_type]")
	to_chat(officer, span_notice("Incident response logged. +15 research points."))
	return TRUE

/datum/computer_file/program/scp_field_work
	filename = "scpfieldwork"
	filedesc = "SCP Field Work Terminal"
	category = PROGRAM_CATEGORY_SCI
	program_icon_state = "research"
	extended_desc = "Field observation tasks, artifact logging, and specimen tracking for SCP researchers and archaeologists."
	size = 8
	tgui_id = "ScpFieldWork"
	program_icon = "microscope"
	available_on_ntnet = TRUE
	required_access = ACCESS_SCIENCE_LVL1

/datum/computer_file/program/scp_field_work/ui_data(mob/user)
	var/list/data = get_header_data()
	var/mob/living/carbon/human/H = user
	data["is_researcher"] = FALSE
	data["is_archaeologist"] = FALSE
	data["is_miner"] = FALSE
	if(istype(H))
		var/job = H.get_assignment()
		data["user_job"] = job
		if(job in list("Research Associate", "Junior Researcher", "Scientist", "Senior Researcher", "Research Director", "Xenobiologist", "Field Agent"))
			data["is_researcher"] = TRUE
		if(job in list("Archaeologist"))
			data["is_archaeologist"] = TRUE
		if(job in list("Prospector", "Shaft Miner"))
			data["is_miner"] = TRUE
	data["anomalous_materials"] = SSscp_supply?.anomalous_materials || list()
	data["containment_zones"] = SScontainment_integrity?.containment_zones || list()
	data["maintenance_tasks"] = list()
	data["specimen_kit_available"] = FALSE
	if(istype(H))
		for(var/obj/item/scp_specimen_kit/kit in H.contents)
			data["specimen_kit_available"] = TRUE
			break
		for(var/list/T in (SScontainment_integrity?.maintenance_tasks || list()))
			if(T["status"] == 1 || (T["status"] == 2 && T["assigned_ckey"] == H.ckey))
				data["maintenance_tasks"] += list(T)
	data["patrol_routes"] = SSscp_patrol?.patrol_routes || list()
	data["user_ckey"] = H?.ckey
	return data

/datum/computer_file/program/scp_field_work/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	switch(action)
		if("log_artifact")
			if(SSscp_supply)
				SSscp_supply.log_anomalous_material(params["item_name"], params["source"] || "field_recovery", params["containment_class"] || "Safe")
				if(SSscp_research?.manager)
					SSscp_research.manager.adjust_research_points(25, "artifact_logging")
				to_chat(H, span_notice("Artifact logged. +25 research points."))
				. = TRUE
		if("log_mineral_sample")
			if(SSscp_supply)
				SSscp_supply.log_anomalous_material(params["item_name"], params["source"] || "mining_recovery", params["containment_class"] || "Safe")
				if(SSscp_research?.manager)
					SSscp_research.manager.adjust_research_points(15, "mineral_sample")
				to_chat(H, span_notice("Mineral sample logged. +15 research points."))
				. = TRUE
		if("submit_supply_request")
			if(SSscp_supply)
				SSscp_supply.submit_requisition_open(
					params["department"] || "science",
					params["item_type"] || "EQUIPMENT",
					params["item_name"] || "General supplies",
					text2num(params["quantity"]) || 1,
					text2num(params["priority"]) || 1,
					params["justification"] || "",
					H,
				)
				. = TRUE
		if("self_assign_maintenance")
			if(SScontainment_integrity)
				SScontainment_integrity.self_assign_task(params["task_id"], H)
				. = TRUE
		if("complete_maintenance")
			if(SScontainment_integrity)
				SScontainment_integrity.complete_assigned_task(params["task_id"], text2num(params["repair_amount"]) || 5, H)
				. = TRUE
		if("accept_patrol")
			if(SSscp_patrol)
				SSscp_patrol.accept_patrol_officer(params["route_id"], H)
				. = TRUE
		if("submit_shift_report")
			if(SSscp_patrol)
				SSscp_patrol.submit_shift_report(params["report_text"], H)
				. = TRUE
		if("respond_to_incident")
			if(SSscp_patrol)
				SSscp_patrol.respond_to_incident(params["incident_type"], params["zone"], H)
				. = TRUE
		if("assistant_task")
			if(SSscp_service)
				SSscp_service.assistant_task_complete(params["task_type"], H)
				. = TRUE

/datum/computer_file/program/scp_engineering_work
	filename = "scpengineeringwork"
	filedesc = "SCP Engineering Work Terminal"
	category = PROGRAM_CATEGORY_ENGI
	program_icon_state = "generic"
	extended_desc = "Containment maintenance, structural integrity repair, and ventilation management for Foundation engineers."
	size = 8
	tgui_id = "ScpEngineeringWork"
	program_icon = "wrench"
	available_on_ntnet = TRUE
	required_access = ACCESS_ENGINEERING

/datum/computer_file/program/scp_engineering_work/ui_data(mob/user)
	var/list/data = get_header_data()
	var/mob/living/carbon/human/H = user
	data["is_senior"] = FALSE
	data["is_junior"] = FALSE
	if(istype(H))
		var/job = H.get_assignment()
		data["user_job"] = job
		if(job in list("Senior Engineer", "Engineering Director", "Assistant Engineering Director", "Chief Engineer"))
			data["is_senior"] = TRUE
		if(job in list("Junior Engineer", "Engineer", "Station Engineer", "Atmospheric Technician"))
			data["is_junior"] = TRUE
	data["containment_zones"] = SScontainment_integrity?.containment_zones || list()
	data["maintenance_tasks"] = list()
	if(istype(H))
		for(var/list/T in (SScontainment_integrity?.maintenance_tasks || list()))
			if(T["status"] == 1 || (T["status"] == 2 && T["assigned_ckey"] == H.ckey))
				data["maintenance_tasks"] += list(T)
	data["ventilation_zones"] = SSzone_ventilation?.ventilation_zones || list()
	data["equipment_status"] = list()
	data["total_repairs"] = SScontainment_integrity?.total_maintenance_done || 0
	data["overall_integrity"] = SScontainment_integrity?.overall_integrity || 100
	return data

/datum/computer_file/program/scp_engineering_work/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	switch(action)
		if("self_assign_maintenance")
			if(SScontainment_integrity)
				SScontainment_integrity.self_assign_task(params["task_id"], H)
				. = TRUE
		if("complete_maintenance")
			if(SScontainment_integrity)
				SScontainment_integrity.complete_assigned_task(params["task_id"], text2num(params["repair_amount"]) || 5, H)
				. = TRUE
		if("repair_zone")
			if(SScontainment_integrity)
				var/amount = text2num(params["repair_amount"]) || 10
				SScontainment_integrity.repair_zone(params["zone_name"], amount)
				SScontainment_integrity.log_integrity_event("[H.real_name] performed structural repair on [params["zone_name"]]", "repair")
				if(SSscp_research?.manager)
					SSscp_research.manager.adjust_research_points(20, "structural_repair")
				to_chat(H, span_notice("Structural repair completed. +20 research points."))
				. = TRUE
		if("repair_equipment")
			to_chat(H, span_notice("Equipment repair functionality available through the Anomalous Chemistry console."))
			. = TRUE
		if("replace_filter")
			if(SSzone_ventilation)
				var/zone_id = text2num(params["zone_id"]) || 1
				SSzone_ventilation.replace_filter(zone_id, H)
				. = TRUE
		if("start_purge")
			if(SSzone_ventilation)
				var/zone_id = text2num(params["zone_id"]) || 1
				SSzone_ventilation.start_purge(zone_id, H)
				. = TRUE
		if("request_maintenance")
			if(SScontainment_integrity)
				SScontainment_integrity.generate_maintenance_task(params["zone_name"] || "LCZ", params["reason"] || "Routine inspection")
				to_chat(H, span_notice("Maintenance task generated."))
				. = TRUE

/datum/computer_file/program/scp_medical_work
	filename = "scpmedicalwork"
	filedesc = "SCP Medical Work Terminal"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "medical"
	extended_desc = "Patient triage assistance, medical dispatch, and SCP contamination response for Foundation medical staff."
	size = 8
	tgui_id = "ScpMedicalWork"
	program_icon = "heartbeat"
	available_on_ntnet = TRUE
	required_access = ACCESS_MEDICAL

/datum/computer_file/program/scp_medical_work/ui_data(mob/user)
	var/list/data = get_header_data()
	var/mob/living/carbon/human/H = user
	data["is_trainee"] = FALSE
	data["is_senior"] = FALSE
	if(istype(H))
		var/job = H.get_assignment()
		data["user_job"] = job
		if(job in list("Medical Resident", "Trainee Doctor", "Medical Intern"))
			data["is_trainee"] = TRUE
		if(job in list("Medical Doctor", "Chief Medical Officer", "Medical Director", "Assistant Medical Director", "Paramedic"))
			data["is_senior"] = TRUE
	data["triage_queue"] = SSscp_triage?.triage_queue || list()
	data["active_cases"] = SSscp_triage?.active_cases || list()
	data["pending_count"] = length(SSscp_triage?.triage_queue || list())
	data["contamination_cases"] = SSscp_medical_response?.contamination_queue || list()
	data["doctor_stats"] = SSscp_triage?.get_doctor_stats(H?.ckey) || list()
	data["total_patients"] = SSscp_triage?.total_patients_triaged || 0
	data["total_decons"] = SSscp_triage?.total_decontaminations || 0
	return data

/datum/computer_file/program/scp_medical_work/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	switch(action)
		if("report_patient")
			if(SSscp_triage)
				var/condition = params["condition"] || "physical_trauma"
				var/severity = text2num(params["severity"]) || 1
				var/source = params["source"] || "Self-reported"
				SSscp_triage.report_patient(H, condition, severity, source)
				. = TRUE
		if("triage_patient")
			if(SSscp_triage)
				var/priority = text2num(params["priority"]) || 1
				SSscp_triage.triage_patient(params["patient_id"], priority, H)
				. = TRUE
		if("diagnose_patient")
			if(SSscp_triage)
				SSscp_triage.diagnose_patient(params["patient_id"], params["diagnosis"], params["treatment_type"], H)
				. = TRUE
		if("treat_patient")
			if(SSscp_triage)
				SSscp_triage.treat_patient(params["patient_id"], H)
				. = TRUE
		if("assist_treatment")
			if(SSscp_triage)
				SSscp_triage.assist_treatment(params["patient_id"], H)
				. = TRUE
		if("dispatch_trainee")
			if(SSscp_triage)
				SSscp_triage.dispatch_trainee(params["patient_id"], H)
				. = TRUE
		if("perform_decontamination")
			if(SSscp_triage)
				SSscp_triage.perform_decontamination(params["patient_id"], H)
				. = TRUE
		if("report_contamination")
			if(SSscp_medical_response)
				SSscp_medical_response.report_contamination(H, params["condition"] || "unknown", params["source"] || "field_report")
				. = TRUE
