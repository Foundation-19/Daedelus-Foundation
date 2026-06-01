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

/datum/anomalous_evidence
	var/evidence_id = ""
	var/evidence_type = ""
	var/collector_name = ""
	var/location_found = ""
	var/scp_related = ""
	var/description = ""
	var/analysis_result = ""
	var/analyzed = FALSE
	var/time_collected = 0

/datum/facility_directive
	var/directive_id = ""
	var/issuer_name = ""
	var/issuer_job = ""
	var/directive_type = ""
	var/title = ""
	var/content = ""
	var/priority = 0
	var/time_issued = 0
	var/status = "active"
	var/acknowledged_by = list()
	var/expiry_time = 0

/datum/facility_status_report
	var/total_breaches = 0
	var/active_breaches = 0
	var/total_recontainments = 0
	var/power_status = "Nominal"
	var/comms_status = "Online"
	var/security_level = "Green"
	var/casualties = 0
	var/dclass_alive = 0
	var/dclass_escaped = 0
	var/research_points = 0
	var/time_generated = 0

/datum/goi_intel
	var/intel_id = ""
	var/goi_name = ""
	var/intel_type = ""
	var/classification = ""
	var/findings = ""
	var/recommendations = ""
	var/time_filed = 0
	var/analyst_name = ""
	var/verified = FALSE

/datum/goi_communique
	var/communique_id = ""
	var/goi_name = ""
	var/sender_name = ""
	var/sender_job = ""
	var/message = ""
	var/response = ""
	var/time_sent = 0
	var/time_responded = 0
	var/priority = 0
	var/responded = FALSE

/datum/psych_evaluation
	var/eval_id = ""
	var/patient_name = ""
	var/patient_job = ""
	var/evaluator_name = ""
	var/eval_type = ""
	var/findings = ""
	var/recommendations = ""
	var/amnestic_recommended = ""
	var/status = 0
	var/time_started = 0
	var/time_completed = 0
	var/sanity_score = 100
	var/exposure_level = 0
	var/trauma_flags = ""

/datum/scp_exposure_record
	var/person_name = ""
	var/person_job = ""
	var/scp_encountered = ""
	var/exposure_type = ""
	var/exposure_time = 0
	var/symptoms = ""
	var/treated = FALSE
	var/treatment = ""
	var/treatment_time = 0

/datum/vip_protection_detail
	var/detail_id = ""
	var/vip_name = ""
	var/vip_job = ""
	var/assigned_guard = ""
	var/status = "active"
	var/time_created = 0
	var/checkins = 0
	var/last_checkin = 0
	var/checkin_interval = 5 MINUTES
	var/overdue = FALSE

/datum/controller/subsystem/goi_relations
	var/list/datum/goi_intel/intel_database = list()
	var/list/datum/goi_communique/communiques = list()
	var/list/goi_standing = list()
	var/total_intel = 0
	var/total_communiques = 0
