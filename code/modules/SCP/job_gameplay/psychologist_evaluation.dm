#define PSYCH_EVAL_PENDING 0
#define PSYCH_EVAL_IN_PROGRESS 1
#define PSYCH_EVAL_COMPLETE 2

#define EXPOSURE_NONE 0
#define EXPOSURE_LOW 1
#define EXPOSURE_MODERATE 2
#define EXPOSURE_SEVERE 3
#define EXPOSURE_CRITICAL 4

/datum/psych_evaluation
	var/eval_id = ""
	var/patient_name = ""
	var/patient_job = ""
	var/evaluator_name = ""
	var/eval_type = ""
	var/findings = ""
	var/recommendations = ""
	var/amnestic_recommended = ""
	var/status = PSYCH_EVAL_PENDING
	var/time_started = 0
	var/time_completed = 0
	var/sanity_score = 100
	var/exposure_level = EXPOSURE_NONE
	var/trauma_flags = ""

/datum/psych_evaluation/New(patient, evaluator, etype)
	eval_id = "PSY-[world.time]-[rand(100,999)]"
	time_started = world.time
	if(istype(patient, /mob/living/carbon/human))
		var/mob/living/carbon/human/P = patient
		patient_name = P.real_name
		patient_job = P.job
	if(istype(evaluator, /mob/living/carbon/human))
		var/mob/living/carbon/human/E = evaluator
		evaluator_name = E.real_name
	eval_type = etype

/datum/psych_evaluation/proc/complete(findings_text, recs, amnestic, sanity, exposure, trauma)
	findings = findings_text
	recommendations = recs
	amnestic_recommended = amnestic
	sanity_score = sanity
	exposure_level = exposure
	trauma_flags = trauma
	status = PSYCH_EVAL_COMPLETE
	time_completed = world.time

/datum/psych_evaluation/proc/get_exposure_text()
	switch(exposure_level)
		if(EXPOSURE_NONE)
			return "None"
		if(EXPOSURE_LOW)
			return "Low"
		if(EXPOSURE_MODERATE)
			return "Moderate"
		if(EXPOSURE_SEVERE)
			return "Severe"
		if(EXPOSURE_CRITICAL)
			return "Critical"

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

/datum/scp_exposure_record/New(name, job, scp, exp_type, symp)
	person_name = name
	person_job = job
	scp_encountered = scp
	exposure_type = exp_type
	exposure_time = world.time
	symptoms = symp

/datum/scp_exposure_record/proc/treat(treatment_type)
	treated = TRUE
	treatment = treatment_type
	treatment_time = world.time

SUBSYSTEM_DEF(psychology)
	name = "Psychology"
	wait = 30 SECONDS
	priority = FIRE_PRIORITY_DEFAULT
	var/list/datum/psych_evaluation/evaluations = list()
	var/list/datum/scp_exposure_record/exposure_records = list()
	var/pending_evals = 0
	var/completed_evals = 0
	var/amnestics_recommended = 0
	var/amnestics_administered = 0
	var/counseling_sessions = 0

/datum/controller/subsystem/psychology/proc/start_evaluation(mob/patient, mob/evaluator, eval_type)
	var/datum/psych_evaluation/E = new(patient, evaluator, eval_type)
	evaluations += E
	pending_evals++
	return E.eval_id

/datum/controller/subsystem/psychology/proc/complete_evaluation(eval_id, findings, recommendations, amnestic, sanity, exposure, trauma)
	for(var/datum/psych_evaluation/E in evaluations)
		if(E.eval_id == eval_id && E.status != PSYCH_EVAL_COMPLETE)
			E.complete(findings, recommendations, amnestic, sanity, exposure, trauma)
			pending_evals--
			completed_evals++
			if(amnestic != "None")
				amnestics_recommended++
			return TRUE
	return FALSE

/datum/controller/subsystem/psychology/proc/record_exposure(mob/M, scp_name, exposure_type, symptoms)
	var/datum/scp_exposure_record/R = new(M.real_name, M.job, scp_name, exposure_type, symptoms)
	exposure_records += R
	return R

/datum/controller/subsystem/psychology/proc/treat_exposure(person_name, treatment)
	for(var/datum/scp_exposure_record/R in exposure_records)
		if(R.person_name == person_name && !R.treated)
			R.treat(treatment)
			return TRUE
	return FALSE

/datum/controller/subsystem/psychology/proc/conduct_counseling(mob/patient, mob/doctor)
	counseling_sessions++
	if(ishuman(patient))
		var/mob/living/carbon/human/H = patient
		if(H.sanity)
			H.sanity.adjust_sanity(15, "counseling")
		var/doctor_name = doctor ? doctor.real_name : "the Foundation"
		to_chat(patient, span_notice("You feel slightly better after your counseling session with [doctor_name]."))
		if(doctor)
			to_chat(doctor, span_notice("Counseling session with [patient.real_name] completed. +15 sanity restoration."))

/datum/controller/subsystem/psychology/proc/assess_sanity(mob/living/carbon/human/H)
	if(!istype(H))
		return list("score" = 100, "status" = "Unknown", "exposure" = EXPOSURE_NONE)
	var/score = 100
	var/exposure = EXPOSURE_NONE
	if(H.sanity)
		score = H.sanity.sanity_level
	for(var/datum/scp_exposure_record/R in exposure_records)
		if(R.person_name == H.real_name && !R.treated)
			exposure = max(exposure, EXPOSURE_LOW)
			if(R.exposure_type == "cognitive" || R.exposure_type == "memetic")
				exposure = max(exposure, EXPOSURE_MODERATE)
			if(R.exposure_type == "reality" || R.exposure_type == "dimensional")
				exposure = max(exposure, EXPOSURE_SEVERE)
	var/status = "Stable"
	if(score < 75)
		status = "Mild Distress"
	if(score < 50)
		status = "Moderate Distress"
	if(score < 25)
		status = "Severe Distress"
	if(score < 10)
		status = "Critical"
	return list("score" = score, "status" = status, "exposure" = exposure)



/datum/controller/subsystem/psychology/fire()
	process_suspicion_surveillance()
