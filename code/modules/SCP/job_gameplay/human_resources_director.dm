#define HR_REVIEW_PENDING 0
#define HR_REVIEW_APPROVED 1
#define HR_REVIEW_DENIED 2

#define HR_CLEARANCE_REQUEST 1
#define HR_REASSIGNMENT 2
#define HR_AMNESTIC_AUTH 3
#define HR_EXPOSURE_REVIEW 4

SUBSYSTEM_DEF(human_resources)
	name = "Human Resources"
	wait = 10 SECONDS
	flags = SS_NO_FIRE

	var/list/pending_reviews = list()
	var/list/completed_reviews = list()
	var/list/clearance_requests = list()
	var/list/reassignment_requests = list()
	var/list/amnestic_authorizations = list()
	var/list/exposure_reviews = list()
	var/total_reviews = 0
	var/approved_reviews = 0
	var/denied_reviews = 0
	var/total_reassignments = 0
	var/total_amnestic_auths = 0

/datum/controller/subsystem/human_resources/proc/submit_clearance_request(mob/living/carbon/human/requestor, requested_level, reason)
	if(!requestor || !requested_level)
		return
	var/obj/item/card/id/id_card = requestor.get_idcard(TRUE)
	var/current_level = id_card ? id_card.access : list()
	var/datum/hr_clearance_request/R = new()
	R.requestor_name = requestor.real_name
	R.requestor_job = requestor.job || "Unknown"
	R.current_access = length(current_level)
	R.requested_level = requested_level
	R.reason = reason || "Not specified"
	R.time_filed = world.time
	R.ckey = requestor.ckey
	clearance_requests += list(list(
		"requestor" = R.requestor_name,
		"job" = R.requestor_job,
		"current_access" = R.current_access,
		"requested_level" = R.requested_level,
		"reason" = R.reason,
		"status" = HR_REVIEW_PENDING,
		"time" = R.time_filed,
		"ckey" = R.ckey,
	))
	pending_reviews += R
	return R

/datum/controller/subsystem/human_resources/proc/submit_reassignment_request(mob/living/carbon/human/subject, new_department, reason, mob/living/carbon/human/requestor)
	if(!subject || !new_department)
		return
	var/datum/hr_reassignment_request/R = new()
	R.subject_name = subject.real_name
	R.subject_job = subject.job || "Unknown"
	R.current_department = "Unknown"
	R.new_department = new_department
	R.reason = reason || "Not specified"
	R.requestor_name = requestor ? requestor.real_name : "System"
	R.time_filed = world.time
	total_reassignments++
	reassignment_requests += list(list(
		"subject" = R.subject_name,
		"job" = R.subject_job,
		"current_dept" = R.current_department,
		"new_dept" = R.new_department,
		"reason" = R.reason,
		"requestor" = R.requestor_name,
		"status" = HR_REVIEW_PENDING,
		"time" = R.time_filed,
	))
	return R

/datum/controller/subsystem/human_resources/proc/authorize_amnestic(mob/living/carbon/human/subject, amnestic_class, reason, mob/living/carbon/human/authorizer)
	if(!subject || !amnestic_class)
		return
	total_amnestic_auths++
	amnestic_authorizations += list(list(
		"subject" = subject.real_name,
		"job" = subject.job || "Unknown",
		"class" = amnestic_class,
		"reason" = reason || "Not specified",
		"authorizer" = authorizer ? authorizer.real_name : "Unknown",
		"time" = world.time,
	))
	if(SSraisa)
		var/datum/intel_report/report = new(authorizer, "personnel_action", subject.real_name, subject.job, "CONFIDENTIAL", "Amnestic authorization granted: Class-[amnestic_class] for [subject.real_name]. Reason: [reason]", "Monitor subject for side effects.")
		SSraisa.file_report(report)

/datum/controller/subsystem/human_resources/proc/flag_exposure_review(mob/living/carbon/human/subject, scp_name, exposure_type)
	if(!subject || !scp_name)
		return
	exposure_reviews += list(list(
		"subject" = subject.real_name,
		"job" = subject.job || "Unknown",
		"scp" = scp_name,
		"exposure_type" = exposure_type,
		"reviewed" = FALSE,
		"fit_for_duty" = TRUE,
		"notes" = "",
		"time" = world.time,
	))

/datum/controller/subsystem/human_resources/proc/review_clearance_request(ckey, approved, notes)
	for(var/list/R in clearance_requests)
		if(R["ckey"] == ckey && R["status"] == HR_REVIEW_PENDING)
			R["status"] = approved ? HR_REVIEW_APPROVED : HR_REVIEW_DENIED
			total_reviews++
			if(approved)
				approved_reviews++
				var/mob/living/carbon/human/H = locate() in GLOB.player_list
				if(H && H.ckey == ckey)
					to_chat(H, span_greenannounce("Your clearance request has been approved."))
			else
				denied_reviews++
				var/mob/living/carbon/human/H = locate() in GLOB.player_list
				if(H && H.ckey == ckey)
					to_chat(H, span_warning("Your clearance request has been denied."))
			break

/datum/controller/subsystem/human_resources/proc/review_reassignment(idx, approved, notes)
	if(idx < 1 || idx > length(reassignment_requests))
		return
	var/list/R = reassignment_requests[idx]
	if(R["status"] != HR_REVIEW_PENDING)
		return
	R["status"] = approved ? HR_REVIEW_APPROVED : HR_REVIEW_DENIED
	R["notes"] = notes
	total_reviews++
	if(approved)
		approved_reviews++
	else
		denied_reviews++

/datum/controller/subsystem/human_resources/proc/review_exposure(idx, fit_for_duty, notes)
	if(idx < 1 || idx > length(exposure_reviews))
		return
	var/list/R = exposure_reviews[idx]
	R["reviewed"] = TRUE
	R["fit_for_duty"] = fit_for_duty
	R["notes"] = notes
	total_reviews++
	if(!fit_for_duty && SSpsychology)
		for(var/mob/living/carbon/human/H in GLOB.player_list)
			if(H.real_name == R["subject"])
				SSpsychology.start_evaluation(H, null, "post_incident")
				to_chat(H, span_warning("You have been flagged for mandatory psychological evaluation. Report to the Psychology Department."))
				break

/datum/controller/subsystem/human_resources/proc/get_pending_count()
	. = 0
	for(var/list/R in clearance_requests)
		if(R["status"] == HR_REVIEW_PENDING)
			.++
	for(var/list/R in reassignment_requests)
		if(R["status"] == HR_REVIEW_PENDING)
			.++

/datum/hr_clearance_request
	var/requestor_name = ""
	var/requestor_job = ""
	var/current_access = 0
	var/requested_level = ""
	var/reason = ""
	var/time_filed = 0
	var/ckey = ""

/datum/hr_reassignment_request
	var/subject_name = ""
	var/subject_job = ""
	var/current_department = ""
	var/new_department = ""
	var/reason = ""
	var/requestor_name = ""
	var/time_filed = 0

/obj/item/paper/foundation/hr_clearance_request
	name = "Clearance Request Form"

/obj/item/paper/foundation/hr_reassignment_form
	name = "Personnel Reassignment Form"

/obj/item/paper/foundation/hr_amnestic_authorization
	name = "Amnestic Authorization Form"
