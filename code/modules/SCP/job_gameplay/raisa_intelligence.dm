/datum/intel_report
	var/report_id = ""
	var/analyst_name = ""
	var/report_type = ""
	var/target_name = ""
	var/target_job = ""
	var/classification = ""
	var/findings = ""
	var/recommendations = ""
	var/time_filed = 0
	var/status = "active"

/datum/intel_report/New(analyst, rtype, target, target_job_str, class, findings_text, recs)
	report_id = "RAISA-[world.time]-[rand(100,999)]"
	time_filed = world.time
	if(istype(analyst, /mob/living/carbon/human))
		var/mob/living/carbon/human/A = analyst
		analyst_name = A.real_name
	report_type = rtype
	target_name = target
	target_job = target_job_str
	classification = class
	findings = findings_text
	recommendations = recs

/datum/surveillance_subject
	var/subject_name = ""
	var/subject_job = ""
	var/threat_assessment = 0
	var/observations = 0
	var/incidents = 0
	var/last_observed = 0
	var/flagged = FALSE
	var/flag_reason = ""

/datum/surveillance_subject/New(name, job_str)
	subject_name = name
	subject_job = job_str

/datum/surveillance_subject/proc/observe()
	observations++
	last_observed = world.time

/datum/surveillance_subject/proc/flag(reason)
	flagged = TRUE
	flag_reason = reason

/datum/surveillance_subject/proc/unflag()
	flagged = FALSE
	flag_reason = ""

/datum/surveillance_subject/proc/add_incident()
	incidents++
	threat_assessment = min(100, threat_assessment + 15)
	if(incidents >= 3)
		flag("Multiple incidents recorded")

/datum/info_breach
	var/breach_id = ""
	var/breach_type = ""
	var/source = ""
	var/data_compromised = ""
	var/severity = 0
	var/time_detected = 0
	var/contained = FALSE
	var/response_notes = ""

/datum/info_breach/New(btype, src_name, data, sever)
	breach_id = "INFO-[world.time]-[rand(10,99)]"
	breach_type = btype
	source = src_name
	data_compromised = data
	severity = sever
	time_detected = world.time

/datum/info_breach/proc/contain(notes)
	contained = TRUE
	response_notes = notes

SUBSYSTEM_DEF(raisa)
	name = "RAISA"
	wait = 10 SECONDS
	priority = FIRE_PRIORITY_DEFAULT
	var/list/datum/intel_report/intel_reports = list()
	var/list/datum/surveillance_subject/subjects = list()
	var/list/datum/info_breach/breaches = list()
	var/total_reports = 0
	var/active_breaches = 0
	var/contained_breaches = 0

/datum/controller/subsystem/raisa/fire()
	for(var/datum/info_breach/B in breaches)
		if(!B.contained && world.time > B.time_detected + 15 MINUTES)
			B.severity = min(5, B.severity + 1)

/datum/controller/subsystem/raisa/proc/file_report(datum/intel_report/R)
	intel_reports += R
	total_reports++
	return R.report_id

/datum/controller/subsystem/raisa/proc/get_or_create_subject(mob/living/carbon/human/M)
	var/name = M.real_name
	for(var/datum/surveillance_subject/S in subjects)
		if(S.subject_name == name)
			return S
	var/datum/surveillance_subject/S = new(name, M.job)
	subjects += S
	return S

/datum/controller/subsystem/raisa/proc/record_observation(mob/living/carbon/human/M)
	var/datum/surveillance_subject/S = get_or_create_subject(M)
	S.observe()

/datum/controller/subsystem/raisa/proc/record_incident(mob/living/carbon/human/M)
	var/datum/surveillance_subject/S = get_or_create_subject(M)
	S.add_incident()

/datum/controller/subsystem/raisa/proc/register_breach(datum/info_breach/B)
	breaches += B
	active_breaches++
	priority_announce("RAISA: Information security breach detected. Type: [B.breach_type]. Severity: [B.severity]. Investigation required.", "RAISA Alert", null, ANNOUNCER_ALERT)

/datum/controller/subsystem/raisa/proc/contain_breach(breach_id, notes)
	for(var/datum/info_breach/B in breaches)
		if(B.breach_id == breach_id && !B.contained)
			B.contain(notes)
			active_breaches--
			contained_breaches++
			return TRUE
	return FALSE

/datum/controller/subsystem/raisa/proc/flag_person(mob/living/carbon/human/M, reason)
	var/datum/surveillance_subject/S = get_or_create_subject(M)
	S.flag(reason)


