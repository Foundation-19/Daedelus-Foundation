#define ETHICS_VIOLATION_MINOR 1
#define ETHICS_VIOLATION_MODERATE 2
#define ETHICS_VIOLATION_SEVERE 3
#define ETHICS_VIOLATION_CRITICAL 4

#define ETHICS_STATUS_PENDING 0
#define ETHICS_STATUS_UNDER_REVIEW 1
#define ETHICS_STATUS_UPHELD 2
#define ETHICS_STATUS_DISMISSED 3

/datum/ethics_violation
	var/violation_id = ""
	var/reporter_name = ""
	var/reporter_job = ""
	var/accused_name = ""
	var/accused_job = ""
	var/violation_type = ""
	var/severity = ETHICS_VIOLATION_MINOR
	var/description = ""
	var/time_reported = 0
	var/status = ETHICS_STATUS_PENDING
	var/review_notes = ""
	var/list/evidence = list()
	var/test_oversight_ref = ""

/datum/ethics_violation/New(reporter, accused, vtype, desc, sever)
	violation_id = "EC-[world.time]-[rand(100,999)]"
	time_reported = world.time
	if(istype(reporter, /mob/living/carbon/human))
		var/mob/living/carbon/human/R = reporter
		reporter_name = R.real_name
		reporter_job = R.job
	if(istype(accused, /mob/living/carbon/human))
		var/mob/living/carbon/human/A = accused
		accused_name = A.real_name
		accused_job = A.job
	violation_type = vtype
	description = desc
	severity = sever

/datum/ethics_violation/proc/review(verdict, notes)
	status = verdict
	review_notes = notes
	if(accused_name && verdict == ETHICS_STATUS_UPHELD)
		var/mob/M = get_mob_by_name(accused_name)
		if(M)
			switch(severity)
				if(ETHICS_VIOLATION_MINOR)
					to_chat(M, span_warning("The Ethics Committee has issued a formal reprimand against you for: [violation_type]."))
				if(ETHICS_VIOLATION_MODERATE)
					to_chat(M, span_warning("The Ethics Committee has issued a formal warning against you for: [violation_type]. Further violations will result in disciplinary action."))
				if(ETHICS_VIOLATION_SEVERE)
					to_chat(M, span_danger("The Ethics Committee has found you in severe violation of ethical protocols for: [violation_type]. Disciplinary action has been recommended."))
				if(ETHICS_VIOLATION_CRITICAL)
					to_chat(M, span_userdanger("The Ethics Committee has found you in CRITICAL violation for: [violation_type]. Immediate suspension and tribunal referral recommended."))

/datum/ethics_violation/proc/get_severity_text()
	switch(severity)
		if(ETHICS_VIOLATION_MINOR)
			return "Minor"
		if(ETHICS_VIOLATION_MODERATE)
			return "Moderate"
		if(ETHICS_VIOLATION_SEVERE)
			return "Severe"
		if(ETHICS_VIOLATION_CRITICAL)
			return "Critical"

/datum/ethics_violation/proc/get_status_text()
	switch(status)
		if(ETHICS_STATUS_PENDING)
			return "Pending"
		if(ETHICS_STATUS_UNDER_REVIEW)
			return "Under Review"
		if(ETHICS_STATUS_UPHELD)
			return "Upheld"
		if(ETHICS_STATUS_DISMISSED)
			return "Dismissed"

SUBSYSTEM_DEF(ethics_committee)
	name = "Ethics Committee"
	wait = 30 SECONDS
	priority = FIRE_PRIORITY_DEFAULT
	var/list/datum/ethics_violation/violations = list()
	var/list/active_test_oversights = list()
	var/total_reviews = 0
	var/upheld_count = 0
	var/dismissed_count = 0

/datum/controller/subsystem/ethics_committee/fire()
	for(var/datum/ethics_violation/V in violations)
		if(V.status == ETHICS_STATUS_PENDING && world.time > V.time_reported + 10 MINUTES)
			V.status = ETHICS_STATUS_UNDER_REVIEW

/datum/controller/subsystem/ethics_committee/proc/file_violation(datum/ethics_violation/V)
	violations += V
	priority_announce("Ethics Committee violation report filed: [V.violation_type] ([V.get_severity_text()]). Case ID: [V.violation_id]", "Ethics Committee", null, ANNOUNCER_DEFAULT)
	return V.violation_id

/datum/controller/subsystem/ethics_committee/proc/get_violations_by_status(stat)
	var/list/result = list()
	for(var/datum/ethics_violation/V in violations)
		if(V.status == stat)
			result += V
	return result

/datum/controller/subsystem/ethics_committee/proc/get_pending_count()
	var/count = 0
	for(var/datum/ethics_violation/V in violations)
		if(V.status == ETHICS_STATUS_PENDING)
			count++
	return count

/datum/controller/subsystem/ethics_committee/proc/flag_test_for_oversight(test_id, scp_name, researcher_name, risk_level)
	var/list/oversight = list(
		"test_id" = test_id,
		"scp_name" = scp_name,
		"researcher" = researcher_name,
		"risk_level" = risk_level,
		"flagged_time" = world.time,
		"approved" = FALSE,
		"denied" = FALSE,
	)
	active_test_oversights[test_id] = oversight
	priority_announce("Ethics Committee: High-risk test flagged for oversight. SCP: [scp_name], Risk Level: [risk_level]. Ethics Liaison review required.", "Ethics Committee", null, ANNOUNCER_DEFAULT)

/datum/controller/subsystem/ethics_committee/proc/approve_test(test_id)
	if(!active_test_oversights[test_id])
		return FALSE
	active_test_oversights[test_id]["approved"] = TRUE
	return TRUE

/datum/controller/subsystem/ethics_committee/proc/deny_test(test_id)
	if(!active_test_oversights[test_id])
		return FALSE
	active_test_oversights[test_id]["denied"] = TRUE
	return TRUE


/obj/item/paper/ethics_violation_form
	name = "Ethics Violation Report Form"
	info = "<b>ETHICS COMMITTEE - VIOLATION REPORT</b><br><br>Accused: ___________<br>Violation Type: ___________<br>Severity: (_) Minor (_) Moderate (_) Severe (_) Critical<br>Description: ___________<br>Witnesses: ___________<br>Reporter Signature: ___________"
