#define MED_RESPONSE_PENDING 0
#define MED_RESPONSE_DISPATCHED 1
#define MED_RESPONSE_EN_ROUTE 2
#define MED_RESPONSE_ON_SCENE 3
#define MED_RESPONSE_COMPLETE 4

SUBSYSTEM_DEF(scp_medical_response)
	name = "SCP Medical Response"
	wait = 15 SECONDS
	flags = SS_NO_FIRE

	var/list/active_incidents = list()
	var/list/incident_log = list()
	var/list/contamination_queue = list()
	var/total_incidents = 0
	var/total_responses = 0
	var/total_decontaminations = 0
	var/avg_response_time = 0

/datum/controller/subsystem/scp_medical_response/proc/report_scp_injury(mob/living/carbon/human/victim, injury_type, severity, source_name)
	if(!victim || victim.stat == DEAD)
		return
	total_incidents++
	var/incident_id = "med_[world.time]_[rand(100,999)]"
	var/area/A = get_area(victim)
	active_incidents += list(list(
		"incident_id" = incident_id,
		"victim_name" = victim.real_name,
		"victim_job" = victim.job || "Unknown",
		"injury_type" = injury_type,
		"severity" = severity,
		"source" = source_name,
		"area" = A ? A.name : "Unknown",
		"status" = MED_RESPONSE_PENDING,
		"responder" = "",
		"time_reported" = world.time,
		"time_responded" = 0,
	))
	if(severity >= 3)
		priority_announce("Medical emergency: [injury_type] reported in [A ? A.name : "unknown location"]. [victim.real_name] requires immediate medical attention.", "MEDICAL ALERT", null, ANNOUNCER_ALERT)
		if(SSfoundation_comms)
			SSfoundation_comms.create_dispatch(null, 2, "Medical emergency: [injury_type] — [victim.real_name] in [A ? A.name : "unknown"]. Severity: [severity]/5.", severity)
	return incident_id

/datum/controller/subsystem/scp_medical_response/proc/report_contamination(mob/living/carbon/human/victim, contaminant_type, source_name)
	if(!victim)
		return
	contamination_queue += list(list(
		"victim_name" = victim.real_name,
		"victim_job" = victim.job || "Unknown",
		"contaminant" = contaminant_type,
		"source" = source_name,
		"area" = get_area_name(victim, TRUE) || "Unknown",
		"decon_required" = TRUE,
		"decon_complete" = FALSE,
		"time" = world.time,
	))
	if(SSraisa)
		var/datum/intel_report/R = new(victim, "contamination", victim.real_name, victim.job, "CONFIDENTIAL", "Anomalous contamination detected: [contaminant_type] from [source_name]. Subject: [victim.real_name]. Decontamination protocol recommended.", "Initiate decon procedures.")
		SSraisa.file_report(R)

/datum/controller/subsystem/scp_medical_response/proc/dispatch_responder(incident_id, mob/living/carbon/human/responder)
	for(var/list/I in active_incidents)
		if(I["incident_id"] == incident_id && I["status"] == MED_RESPONSE_PENDING)
			I["responder"] = responder.real_name
			I["status"] = MED_RESPONSE_DISPATCHED
			I["time_responded"] = world.time
			to_chat(responder, span_notice("<b>MEDICAL DISPATCH:</b> [I["injury_type"]] — [I["victim_name"]] in [I["area"]]. Severity: [I["severity"]]/5. Respond immediately."))
			total_responses++
			return TRUE
	return FALSE

/datum/controller/subsystem/scp_medical_response/proc/update_incident_status(incident_id, new_status)
	for(var/list/I in active_incidents)
		if(I["incident_id"] == incident_id)
			I["status"] = new_status
			if(new_status == MED_RESPONSE_COMPLETE)
				var/response_time = I["time_responded"] ? (world.time - I["time_responded"]) / 10 : 0
				avg_response_time = avg_response_time > 0 ? round((avg_response_time + response_time) / 2, 1) : response_time
				log_incident(I, response_time)
			return TRUE
	return FALSE

/datum/controller/subsystem/scp_medical_response/proc/complete_decontamination(victim_name)
	for(var/list/C in contamination_queue)
		if(C["victim_name"] == victim_name && !C["decon_complete"])
			C["decon_complete"] = TRUE
			C["decon_required"] = FALSE
			total_decontaminations++
			return TRUE
	return FALSE

/datum/controller/subsystem/scp_medical_response/proc/log_incident(list/incident_data, response_time)
	incident_log += list(list(
		"victim" = incident_data["victim_name"],
		"type" = incident_data["injury_type"],
		"severity" = incident_data["severity"],
		"source" = incident_data["source"],
		"responder" = incident_data["responder"],
		"response_time" = response_time,
		"time" = incident_data["time_reported"],
	))
	if(length(incident_log) > 100)
		incident_log.Cut(1, 2)

/obj/item/paper/foundation/scp_injury_report
	name = "SCP Injury Report"

/obj/item/paper/foundation/decontamination_certificate
	name = "Decontamination Certificate"
