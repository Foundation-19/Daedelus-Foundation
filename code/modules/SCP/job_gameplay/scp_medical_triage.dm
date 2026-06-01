#ifndef TRIAGE_AWAITING
#define TRIAGE_AWAITING 0
#define TRIAGE_TRIAGED 1
#define TRIAGE_TREATING 2
#define TRIAGE_COMPLETE 3
#define TRIAGE_QUARANTINED 4
#endif

#ifndef TRIAGE_PRIORITY_UNASSIGNED
#define TRIAGE_PRIORITY_UNASSIGNED 0
#define TRIAGE_PRIORITY_LOW 1
#define TRIAGE_PRIORITY_MEDIUM 2
#define TRIAGE_PRIORITY_HIGH 3
#define TRIAGE_PRIORITY_CRITICAL 4
#define TRIAGE_PRIORITY_IMMEDIATE 5
#endif

SUBSYSTEM_DEF(scp_triage)
	name = "SCP Medical Triage"
	wait = 15 SECONDS
	flags = SS_NO_FIRE

	var/list/triage_queue = list()
	var/list/active_cases = list()
	var/list/quarantine_list = list()
	var/list/treatment_log = list()
	var/list/doctor_stats = list()
	var/total_patients_triaged = 0
	var/total_decontaminations = 0
	var/total_quarantines = 0
	var/total_research_contributions = 0
	var/avg_triage_time = 0

/datum/controller/subsystem/scp_triage/proc/report_patient(mob/living/carbon/human/patient, condition, severity, source)
	if(!patient || patient.stat == DEAD)
		return
	var/patient_id = "triage_[world.time]_[rand(100,999)]"
	var/area/A = get_area(patient)
	triage_queue += list(list(
		"patient_id" = patient_id,
		"patient_name" = patient.real_name,
		"patient_ref" = REF(patient),
		"condition" = condition,
		"severity" = severity,
		"source" = source,
		"area" = A ? A.name : "Unknown",
		"priority" = TRIAGE_PRIORITY_UNASSIGNED,
		"diagnosed" = FALSE,
		"diagnosis" = "",
		"treatment_type" = "",
		"assigned_doctor" = "",
		"time_reported" = world.time,
		"time_triaged" = 0,
		"time_treated" = 0,
		"status" = TRIAGE_AWAITING,
	))
	if(severity >= 4)
		if(SSfoundation_comms)
			SSfoundation_comms.create_dispatch(null, 2, "Medical emergency: [condition] reported in [A ? A.name : "unknown location"]. [patient.real_name] requires immediate attention.", severity >= 5 ? 2 : 1)
	if(condition == "contamination" || condition == "biohazard")
		if(SSscp_medical_response)
			SSscp_medical_response.report_contamination(patient, condition, source)
		if(SSzone_ventilation)
			var/zone_id = 0
			var/zone = get_containment_zone(A)
			if(zone == "lcz")
				zone_id = 1
			else if(zone == "hcz")
				zone_id = 2
			else if(zone == "ez")
				zone_id = 3
			if(zone_id > 0)
				SSzone_ventilation.report_contamination(zone_id, severity * 5, source)
	return patient_id

/datum/controller/subsystem/scp_triage/proc/triage_patient(patient_id, priority, mob/living/carbon/human/doctor)
	for(var/list/P in triage_queue)
		if(P["patient_id"] == patient_id)
			P["priority"] = priority
			P["status"] = TRIAGE_TRIAGED
			P["assigned_doctor"] = doctor.real_name
			P["time_triaged"] = world.time
			var/triage_time = (world.time - P["time_reported"]) / 10
			avg_triage_time = avg_triage_time > 0 ? round((avg_triage_time + triage_time) / 2, 1) : triage_time
			total_patients_triaged++
			active_cases += list(P)
			triage_queue -= list(P)
			to_chat(doctor, span_notice("<b>TRIAGE:</b> [P["patient_name"]] assigned priority [priority]. Condition: [P["condition"]]. Source: [P["source"]]."))
			var/obj/item/card/id/id_card = doctor.get_idcard(TRUE)
			if(id_card)
				update_doctor_stats(doctor.ckey, "triaged")
			return TRUE
	return FALSE

/datum/controller/subsystem/scp_triage/proc/diagnose_patient(patient_id, diagnosis, treatment_type, mob/living/carbon/human/doctor)
	for(var/list/P in active_cases)
		if(P["patient_id"] == patient_id)
			P["diagnosed"] = TRUE
			P["diagnosis"] = diagnosis
			P["treatment_type"] = treatment_type
			P["status"] = TRIAGE_TREATING
			to_chat(doctor, span_notice("<b>DIAGNOSIS:</b> [P["patient_name"]] diagnosed with [diagnosis]. Treatment: [treatment_type]."))
			if(treatment_type == "amnestic")
				if(SSpsychology)
					SSpsychology.record_exposure(doctor, P["source"] || "Unknown", "amnestic_treatment", "Amnestic treatment recommended by [doctor.real_name]")
			if(treatment_type == "quarantine")
				quarantine_patient(patient_id, 120)
			return TRUE
	return FALSE

/datum/controller/subsystem/scp_triage/proc/treat_patient(patient_id, mob/living/carbon/human/doctor)
	for(var/list/P in active_cases)
		if(P["patient_id"] != patient_id)
			continue
		var/mob/living/carbon/human/patient = locate(P["patient_ref"])
		if(patient && patient.stat != DEAD)
			switch(P["treatment_type"])
				if("standard")
					patient.adjustBruteLoss(-20)
					patient.adjustFireLoss(-15)
					patient.adjustToxLoss(-10, TRUE)
				if("decontamination")
					perform_decontamination(patient_id, doctor)
				if("surgery")
					patient.adjustBruteLoss(-30)
					patient.adjustFireLoss(-20)
		P["status"] = TRIAGE_COMPLETE
		P["time_treated"] = world.time
		treatment_log += list(P)
		active_cases -= list(P)
		total_research_contributions += generate_medical_research(P)
		if(SSscp_research?.manager)
			var/points = P["severity"] * 5
			if(P["diagnosed"])
				points += 5
			SSscp_research?.manager?.adjust_research_points(points, "medical_triage:[doctor.ckey]")
		update_doctor_stats(doctor.ckey, "treated")
		to_chat(doctor, span_greenannounce("<b>TREATMENT COMPLETE:</b> [P["patient_name"]] — [P["diagnosis"] || P["condition"]]. Research points earned."))
		return TRUE
	return FALSE

/datum/controller/subsystem/scp_triage/proc/perform_decontamination(patient_id, mob/living/carbon/human/doctor)
	for(var/list/P in active_cases)
		if(P["patient_id"] != patient_id)
			continue
		var/mob/living/carbon/human/patient = locate(P["patient_ref"])
		if(patient)
			patient.adjustToxLoss(-20, TRUE)
			if(patient.sanity)
				patient.sanity.adjust_sanity(5, "decontamination")
		total_decontaminations++
		if(SSzone_ventilation)
			var/area/A = get_area(patient)
			var/zone_id = 0
			var/zone = get_containment_zone(A)
			if(zone == "lcz")
				zone_id = 1
			else if(zone == "hcz")
				zone_id = 2
			else if(zone == "ez")
				zone_id = 3
			if(zone_id > 0)
				SSzone_ventilation.replace_filter(zone_id, 5)
		if(SSscp_research?.manager)
			SSscp_research?.manager?.adjust_research_points(8, "decon_procedure:[doctor.ckey]")
		update_doctor_stats(doctor.ckey, "decon")
		to_chat(doctor, span_notice("<b>DECONTAMINATION:</b> [P["patient_name"]] decontamination procedure complete."))
		return TRUE
	return FALSE

/datum/controller/subsystem/scp_triage/proc/quarantine_patient(patient_id, duration)
	for(var/list/P in active_cases)
		if(P["patient_id"] != patient_id)
			continue
		P["status"] = TRIAGE_QUARANTINED
		total_quarantines++
		quarantine_list += list(P)
		active_cases -= list(P)
		if(P["condition"] == "biohazard")
			priority_announce("Biohazard quarantine activated for [P["patient_name"]] in [P["area"]]. Medical staff maintain quarantine protocols.", "QUARANTINE ALERT", null, ANNOUNCER_ALERT)
		addtimer(CALLBACK(src, PROC_REF(release_from_quarantine), patient_id), duration SECONDS)
		return TRUE
	return FALSE

/datum/controller/subsystem/scp_triage/proc/release_from_quarantine(patient_id)
	for(var/list/P in quarantine_list)
		if(P["patient_id"] == patient_id)
			P["status"] = TRIAGE_COMPLETE
			P["time_treated"] = world.time
			treatment_log += list(P)
			quarantine_list -= list(P)
			var/mob/living/carbon/human/patient = locate(P["patient_ref"])
			if(patient)
				to_chat(patient, span_notice("You have been released from quarantine."))
			return TRUE
	return FALSE

/datum/controller/subsystem/scp_triage/proc/get_doctor_stats(ckey)
	if(!doctor_stats[ckey])
		doctor_stats[ckey] = list(
			"total_triaged" = 0,
			"total_treated" = 0,
			"total_decontaminations" = 0,
			"total_research" = 0,
			"avg_response_time" = 0,
			"last_active" = world.time,
		)
	return doctor_stats[ckey]

/datum/controller/subsystem/scp_triage/proc/update_doctor_stats(ckey, action)
	var/list/S = get_doctor_stats(ckey)
	if(!S)
		return
	S["last_active"] = world.time
	switch(action)
		if("triaged")
			S["total_triaged"]++
		if("treated")
			S["total_treated"]++
			S["total_research"] += 5
		if("decon")
			S["total_decontaminations"]++

/datum/controller/subsystem/scp_triage/proc/auto_detect_patients()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD || !H.ckey)
			continue
		var/area/A = get_area(H)
		if(!A)
			continue
		var/zone = get_containment_zone(A)
		if(!zone)
			continue
		var/in_triage = FALSE
		for(var/list/P in triage_queue)
			if(P["patient_ref"] == REF(H))
				in_triage = TRUE
				break
		if(in_triage)
			continue
		for(var/list/P in active_cases)
			if(P["patient_ref"] == REF(H))
				in_triage = TRUE
				break
		if(in_triage)
			continue
		if(H.getBruteLoss() > 50)
			report_patient(H, "physical_trauma", 3, "Containment Zone Injury")
		else if(H.getToxLoss() > 30)
			report_patient(H, "biohazard", 2, "Unknown Containment Zone Exposure")

/datum/controller/subsystem/scp_triage/proc/generate_medical_research(list/P)
	var/points = P["severity"] * 3
	if(P["diagnosed"])
		points += 5
	if(P["condition"] == "scp_exposure" || P["condition"] == "anomalous_injury")
		points += 10
	if(P["priority"] >= TRIAGE_PRIORITY_CRITICAL)
		points += 5
	return points

/datum/computer_file/program/scp_triage
	filename = "scp_triage"
	filedesc = "SCP Medical Triage"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Triage patients, diagnose SCP conditions, manage decontamination and quarantine."
	size = 2
	tgui_id = "ScpTriage"
	program_icon = "heartbeat"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_MEDICAL)

/datum/computer_file/program/scp_triage/ui_data(mob/user)
	var/list/data = get_header_data()
	if(SSscp_triage)
		data["triage_queue"] = SSscp_triage.triage_queue
		data["active_cases"] = SSscp_triage.active_cases
		data["quarantine_list"] = SSscp_triage.quarantine_list
		var/list/recent_log = list()
		var/start = max(1, length(SSscp_triage.treatment_log) - 20)
		for(var/i = start to length(SSscp_triage.treatment_log))
			recent_log += list(SSscp_triage.treatment_log[i])
		data["treatment_log"] = recent_log
		data["total_patients_triaged"] = SSscp_triage.total_patients_triaged
		data["total_decontaminations"] = SSscp_triage.total_decontaminations
		data["total_quarantines"] = SSscp_triage.total_quarantines
		data["total_research_contributions"] = SSscp_triage.total_research_contributions
		data["pending_count"] = length(SSscp_triage.triage_queue)
		var/mob/living/carbon/human/H = user
		if(istype(H) && H.ckey)
			data["doctor_stats"] = SSscp_triage.get_doctor_stats(H.ckey)
	return data

/datum/computer_file/program/scp_triage/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_MEDICAL in id_card.access))
		return
	if(!SSscp_triage)
		return
	switch(action)
		if("report_patient")
			var/condition = params["condition"] || "physical_trauma"
			var/severity = text2num(params["severity"]) || 1
			var/source = params["source"] || "Self-reported"
			SSscp_triage.report_patient(H, condition, severity, source)
			. = TRUE
		if("triage_patient")
			var/priority = text2num(params["priority"]) || 1
			SSscp_triage.triage_patient(params["patient_id"], priority, H)
			. = TRUE
		if("diagnose_patient")
			SSscp_triage.diagnose_patient(params["patient_id"], params["diagnosis"], params["treatment_type"], H)
			. = TRUE
		if("treat_patient")
			SSscp_triage.treat_patient(params["patient_id"], H)
			. = TRUE
		if("perform_decontamination")
			SSscp_triage.perform_decontamination(params["patient_id"], H)
			. = TRUE
		if("quarantine_patient")
			var/duration = text2num(params["duration"]) || 120
			SSscp_triage.quarantine_patient(params["patient_id"], duration)
			. = TRUE
		if("release_from_quarantine")
			SSscp_triage.release_from_quarantine(params["patient_id"])
			. = TRUE
