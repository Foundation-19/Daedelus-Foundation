#ifndef ETHICS_VIOLATION_MINOR
#define ETHICS_VIOLATION_MINOR 1
#define ETHICS_VIOLATION_MODERATE 2
#define ETHICS_VIOLATION_SEVERE 3
#define ETHICS_VIOLATION_CRITICAL 4
#endif

#ifndef ETHICS_STATUS_PENDING
#define ETHICS_STATUS_PENDING 0
#define ETHICS_STATUS_UNDER_REVIEW 1
#define ETHICS_STATUS_UPHELD 2
#define ETHICS_STATUS_DISMISSED 3
#endif

#ifndef PSYCH_EVAL_PENDING
#define PSYCH_EVAL_PENDING 0
#define PSYCH_EVAL_IN_PROGRESS 1
#define PSYCH_EVAL_COMPLETE 2
#endif

#ifndef EXPOSURE_NONE
#define EXPOSURE_NONE 0
#define EXPOSURE_LOW 1
#define EXPOSURE_MODERATE 2
#define EXPOSURE_SEVERE 3
#define EXPOSURE_CRITICAL 4
#endif

#ifndef TRIBUNAL_CASE_PENDING
#define TRIBUNAL_CASE_PENDING 0
#define TRIBUNAL_CASE_HEARING 1
#define TRIBUNAL_CASE_DELIBERATION 2
#define TRIBUNAL_CASE_GUILTY 3
#define TRIBUNAL_CASE_NOT_GUILTY 4
#define TRIBUNAL_CASE_DISMISSED 5
#endif

#ifndef SANCTION_REPRIMAND
#define SANCTION_REPRIMAND 1
#define SANCTION_SUSPENSION 2
#define SANCTION_DEMOTION 3
#define SANCTION_TERMINATION 4
#define SANCTION_AMNESTIC 5
#endif

#ifndef DISPATCH_SECURITY
#define DISPATCH_SECURITY 1
#endif

#ifndef THREAT_LEVEL_YELLOW
#define THREAT_LEVEL_YELLOW 1
#endif

/datum/computer_file/program/scp_ethics_review
	filename = "scp_ethics"
	filedesc = "Ethics Committee Review"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Review ethics violations, oversee tests, and file violation reports."
	size = 3
	tgui_id = "ScpEthicsReview"
	program_icon = "balance-scale"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_ADMIN_LVL5)

/datum/computer_file/program/scp_ethics_review/ui_data(mob/user)
	var/list/data = get_header_data()
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		data["access_denied"] = TRUE
		return data
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ADMIN_LVL5 in id_card.access))
		data["access_denied"] = TRUE
		return data
	data["access_denied"] = FALSE
	var/list/violation_list = list()
	for(var/datum/ethics_violation/V in SSethics_committee.violations)
		violation_list += list(list(
			"violation_id" = V.violation_id,
			"reporter" = V.reporter_name,
			"accused" = V.accused_name,
			"type" = V.violation_type,
			"severity" = V.get_severity_text(),
			"severity_num" = V.severity,
			"description" = V.description,
			"status" = V.get_status_text(),
			"status_num" = V.status,
			"notes" = V.review_notes,
			"time" = V.time_reported,
		))
	data["violations"] = violation_list
	data["pending_count"] = SSethics_committee.get_pending_count()
	data["total_reviews"] = SSethics_committee.total_reviews
	data["upheld_count"] = SSethics_committee.upheld_count
	data["dismissed_count"] = SSethics_committee.dismissed_count
	var/list/oversight_list = list()
	for(var/test_id in SSethics_committee.active_test_oversights)
		var/list/O = SSethics_committee.active_test_oversights[test_id]
		oversight_list += list(list(
			"test_id" = test_id,
			"scp_name" = O["scp_name"],
			"researcher" = O["researcher"],
			"risk_level" = O["risk_level"],
			"approved" = O["approved"],
			"denied" = O["denied"],
			"time" = O["flagged_time"],
		))
	data["test_oversights"] = oversight_list
	return data

/datum/computer_file/program/scp_ethics_review/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ADMIN_LVL5 in id_card.access))
		return
	switch(action)
		if("review_uphold")
			var/violation_id = params["violation_id"]
			for(var/datum/ethics_violation/V in SSethics_committee.violations)
				if(V.violation_id == violation_id && V.status != ETHICS_STATUS_UPHELD && V.status != ETHICS_STATUS_DISMISSED)
					V.review(ETHICS_STATUS_UPHELD, params["notes"] || "")
					SSethics_committee.total_reviews++
					SSethics_committee.upheld_count++
					. = TRUE
					break
		if("review_dismiss")
			var/violation_id = params["violation_id"]
			for(var/datum/ethics_violation/V in SSethics_committee.violations)
				if(V.violation_id == violation_id && V.status != ETHICS_STATUS_UPHELD && V.status != ETHICS_STATUS_DISMISSED)
					V.review(ETHICS_STATUS_DISMISSED, params["notes"] || "")
					SSethics_committee.total_reviews++
					SSethics_committee.dismissed_count++
					. = TRUE
					break
		if("file_violation")
			var/accused_name = params["accused"]
			var/accused_job = params["accused_job"] || ""
			var/vtype = params["violation_type"]
			var/desc = params["description"]
			var/evidence = params["evidence"]
			var/severity = text2num(params["severity"]) || ETHICS_VIOLATION_MINOR
			var/datum/ethics_violation/V = new(H, null, vtype, desc, severity)
			V.accused_name = accused_name
			V.accused_job = accused_job
			if(evidence)
				V.evidence += evidence
			SSethics_committee.file_violation(V)
			. = TRUE
		if("approve_test")
			var/test_id = params["test_id"]
			if(SSethics_committee.approve_test(test_id))
				priority_announce("Ethics Committee has approved test [test_id] to proceed.", "Ethics Committee", null, ANNOUNCER_DEFAULT)
				. = TRUE
		if("deny_test")
			var/test_id = params["test_id"]
			if(SSethics_committee.deny_test(test_id))
				priority_announce("Ethics Committee has denied test [test_id]. Testing must not proceed.", "Ethics Committee", null, ANNOUNCER_ALERT)
				. = TRUE
		if("autofill_paper")
			scp_autofill_paper("ethics", H)
			. = TRUE

/datum/computer_file/program/scp_budget_console
	filename = "scp_budget"
	filedesc = "Budget Management"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Manage departmental budgets, approve requests, reallocate resources."
	size = 3
	tgui_id = "ScpBudgetConsole"
	program_icon = "dollar-sign"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE

/datum/computer_file/program/scp_budget_console/ui_data(mob/user)
	var/list/data = get_header_data()
	var/list/dept_list = list()
	for(var/dept in SSfoundation_budget.department_budgets)
		var/datum/department_budget/B = SSfoundation_budget.department_budgets[dept]
		dept_list += list(list(
			"department" = capitalize(dept),
			"allocated" = B.allocated,
			"spent" = B.spent,
			"remaining" = B.remaining,
			"pending" = B.pending_requests,
			"approved" = B.approved_this_round,
			"denied" = B.denied_this_round,
		))
	data["departments"] = dept_list
	data["total_budget"] = SSfoundation_budget.total_budget
	data["total_spent"] = SSfoundation_budget.total_spent
	var/list/req_list = list()
	for(var/datum/budget_request/R in SSfoundation_budget.requests)
		req_list += list(list(
			"request_id" = R.request_id,
			"department" = capitalize(R.department),
			"requester" = R.requester_name,
			"amount" = R.amount,
			"purpose" = R.purpose,
			"justification" = R.justification,
			"status" = R.status,
			"reviewer" = R.reviewer,
			"notes" = R.review_notes,
			"time" = R.time_filed,
		))
	data["requests"] = req_list
	var/mob/living/carbon/human/viewer = user
	var/obj/item/card/id/viewer_id = istype(viewer) ? viewer.get_idcard(TRUE) : null
	data["has_command"] = viewer_id && (ACCESS_ADMIN_LVL5 in viewer_id.access)
	return data

/datum/computer_file/program/scp_budget_console/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card)
		return
	var/has_command = (ACCESS_ADMIN_LVL5 in id_card.access)
	switch(action)
		if("file_request")
			var/department = lowertext(params["department"] || "")
			var/amount = text2num(params["amount"])
			var/purpose = params["purpose"] || ""
			var/justification = params["justification"] || ""
			if(!department || !amount || amount <= 0 || !purpose)
				return
			var/datum/budget_request/R = new(department, H, amount, purpose, justification)
			SSfoundation_budget.file_request(R)
			. = TRUE
		if("approve_request")
			if(!has_command)
				return
			var/request_id = params["request_id"]
			var/notes = params["notes"] || ""
			SSfoundation_budget.approve_request(request_id, H.real_name, notes)
			. = TRUE
		if("deny_request")
			if(!has_command)
				return
			var/request_id = params["request_id"]
			var/notes = params["notes"] || ""
			SSfoundation_budget.deny_request(request_id, H.real_name, notes)
			. = TRUE
		if("reallocate")
			if(!has_command)
				return
			var/from_dept = lowertext(params["from"])
			var/to_dept = lowertext(params["to"])
			var/amount = text2num(params["amount"])
			if(!amount || amount <= 0)
				return
			SSfoundation_budget.reallocate(from_dept, to_dept, amount)
			. = TRUE
		if("autofill_paper")
			scp_autofill_paper("budget", H)
			. = TRUE

/datum/computer_file/program/scp_psychology_console
	filename = "scp_psych"
	filedesc = "Psychology Department"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Conduct evaluations, track SCP exposure, manage counseling and amnestic recommendations."
	size = 3
	tgui_id = "ScpPsychologyConsole"
	program_icon = "brain"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_MEDICAL)

/datum/computer_file/program/scp_psychology_console/ui_data(mob/user)
	var/list/data = get_header_data()
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		data["access_denied"] = TRUE
		return data
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_MEDICAL in id_card.access))
		data["access_denied"] = TRUE
		return data
	data["access_denied"] = FALSE
	var/list/eval_list = list()
	for(var/datum/psych_evaluation/E in SSpsychology.evaluations)
		eval_list += list(list(
			"eval_id" = E.eval_id,
			"patient" = E.patient_name,
			"job" = E.patient_job,
			"evaluator" = E.evaluator_name,
			"type" = E.eval_type,
			"status" = E.status == PSYCH_EVAL_COMPLETE ? "Complete" : "In Progress",
			"findings" = E.findings,
			"recommendations" = E.recommendations,
			"amnestic" = E.amnestic_recommended,
			"sanity_score" = E.sanity_score,
			"exposure" = E.get_exposure_text(),
			"trauma" = E.trauma_flags,
			"time" = E.time_started,
		))
	data["evaluations"] = eval_list
	var/list/exposure_list = list()
	for(var/datum/scp_exposure_record/R in SSpsychology.exposure_records)
		exposure_list += list(list(
			"person" = R.person_name,
			"job" = R.person_job,
			"scp" = R.scp_encountered,
			"type" = R.exposure_type,
			"symptoms" = R.symptoms,
			"treated" = R.treated,
			"treatment" = R.treatment,
			"time" = R.exposure_time,
		))
	data["exposures"] = exposure_list
	data["pending_evals"] = SSpsychology.pending_evals
	data["completed_evals"] = SSpsychology.completed_evals
	data["amnestics_recommended"] = SSpsychology.amnestics_recommended
	data["amnestics_administered"] = SSpsychology.amnestics_administered
	data["counseling_sessions"] = SSpsychology.counseling_sessions
	return data

/datum/computer_file/program/scp_psychology_console/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_MEDICAL in id_card.access))
		return
	switch(action)
		if("start_evaluation")
			var/patient_name = params["patient"]
			var/eval_type = params["eval_type"]
			var/mob/living/carbon/human/patient
			for(var/mob/living/carbon/human/M in GLOB.player_list)
				if(M.real_name == patient_name)
					patient = M
					break
			if(!patient)
				return
			SSpsychology.start_evaluation(patient, H, eval_type)
			. = TRUE
		if("complete_evaluation")
			var/eval_id = params["eval_id"]
			var/findings = params["findings"]
			var/recommendations = params["recommendations"]
			var/amnestic = params["amnestic"]
			var/sanity = text2num(params["sanity"]) || 100
			var/exposure = text2num(params["exposure"]) || EXPOSURE_NONE
			var/trauma = params["trauma"]
			SSpsychology.complete_evaluation(eval_id, findings, recommendations, amnestic, sanity, exposure, trauma)
			. = TRUE
		if("conduct_counseling")
			var/patient_name = params["patient"]
			var/mob/living/carbon/human/patient
			for(var/mob/living/carbon/human/M in GLOB.player_list)
				if(M.real_name == patient_name)
					patient = M
					break
			if(!patient)
				return
			SSpsychology.conduct_counseling(patient, H)
			. = TRUE
		if("assess_sanity")
			var/patient_name = params["patient"]
			for(var/mob/living/carbon/human/M in GLOB.player_list)
				if(M.real_name == patient_name)
					var/list/assessment = SSpsychology.assess_sanity(M)
					to_chat(H, "<span class='notice'>Sanity: [assessment["score"]], Status: [assessment["status"]], Exposure: [assessment["exposure"]]</span>")
					break
			. = TRUE
		if("record_exposure")
			var/person_name = params["person"]
			var/scp_name = params["scp"]
			var/exp_type = params["exposure_type"]
			var/symptoms = params["symptoms"]
			var/mob/living/carbon/human/person
			for(var/mob/living/carbon/human/M in GLOB.player_list)
				if(M.real_name == person_name)
					person = M
					break
			if(person)
				SSpsychology.record_exposure(person, scp_name, exp_type, symptoms)
			. = TRUE
		if("treat_exposure")
			var/person_name = params["person"]
			var/treatment = params["treatment"]
			SSpsychology.treat_exposure(person_name, treatment)
			. = TRUE
		if("autofill_paper")
			scp_autofill_paper("psych", H)
			. = TRUE

/datum/computer_file/program/scp_investigations
	filename = "scp_invest"
	filedesc = "Anomalous Investigations"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Log evidence, analyze findings, manage investigation cases."
	size = 3
	tgui_id = "ScpInvestigationsTerminal"
	program_icon = "search"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_SECURITY)

/datum/computer_file/program/scp_investigations/ui_data(mob/user)
	var/list/data = get_header_data()
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		data["access_denied"] = TRUE
		return data
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_SECURITY in id_card.access))
		data["access_denied"] = TRUE
		return data
	data["access_denied"] = FALSE
	var/list/evidence_list = list()
	for(var/datum/anomalous_evidence/E in SSanomalous_investigations.evidence_log)
		evidence_list += list(list(
			"evidence_id" = E.evidence_id,
			"type" = E.evidence_type,
			"collector" = E.collector_name,
			"location" = E.location_found,
			"scp" = E.scp_related,
			"description" = E.description,
			"analyzed" = E.analyzed,
			"result" = E.analysis_result,
			"time" = E.time_collected,
		))
	data["evidence"] = evidence_list
	var/list/case_list = list()
	for(var/case_name in SSanomalous_investigations.active_cases)
		var/list/C = SSanomalous_investigations.active_cases[case_name]
		case_list += list(list(
			"name" = case_name,
			"description" = C["description"],
			"status" = C["status"],
			"evidence_count" = C["evidence_count"],
			"time" = C["time_opened"],
		))
	data["cases"] = case_list
	data["total_evidence"] = SSanomalous_investigations.total_evidence
	data["analyzed_evidence"] = SSanomalous_investigations.analyzed_evidence
	return data

/datum/computer_file/program/scp_investigations/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_SECURITY in id_card.access))
		return
	switch(action)
		if("analyze_evidence")
			var/evidence_id = params["evidence_id"]
			var/result = params["result"]
			SSanomalous_investigations.analyze_evidence(evidence_id, result)
			. = TRUE
		if("open_case")
			var/scp_name = params["scp_name"]
			var/description = params["description"]
			SSanomalous_investigations.open_case(scp_name, description)
			. = TRUE
		if("close_case")
			var/scp_name = params["scp_name"]
			SSanomalous_investigations.close_case(scp_name)
			. = TRUE
		if("autofill_paper")
			scp_autofill_paper("investigation", H)
			. = TRUE

/datum/computer_file/program/scp_raisa
	filename = "scp_raisa"
	filedesc = "RAISA Intelligence"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Intelligence analysis, surveillance monitoring, information security management."
	size = 3
	tgui_id = "ScpRaisaTerminal"
	program_icon = "eye"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_SECURITY)

/datum/computer_file/program/scp_raisa/ui_data(mob/user)
	var/list/data = get_header_data()
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		data["access_denied"] = TRUE
		return data
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_SECURITY in id_card.access))
		data["access_denied"] = TRUE
		return data
	data["access_denied"] = FALSE
	var/list/report_list = list()
	for(var/datum/intel_report/R in SSraisa.intel_reports)
		report_list += list(list(
			"report_id" = R.report_id,
			"analyst" = R.analyst_name,
			"type" = R.report_type,
			"target" = R.target_name,
			"classification" = R.classification,
			"findings" = R.findings,
			"recommendations" = R.recommendations,
			"status" = R.status,
			"time" = R.time_filed,
		))
	data["reports"] = report_list
	var/list/subject_list = list()
	for(var/datum/surveillance_subject/S in SSraisa.subjects)
		subject_list += list(list(
			"name" = S.subject_name,
			"job" = S.subject_job,
			"threat" = S.threat_assessment,
			"observations" = S.observations,
			"incidents" = S.incidents,
			"flagged" = S.flagged,
			"flag_reason" = S.flag_reason,
			"last_observed" = S.last_observed,
		))
	data["subjects"] = subject_list
	var/list/breach_list = list()
	for(var/datum/info_breach/B in SSraisa.breaches)
		breach_list += list(list(
			"breach_id" = B.breach_id,
			"type" = B.breach_type,
			"source" = B.source,
			"data" = B.data_compromised,
			"severity" = B.severity,
			"contained" = B.contained,
			"notes" = B.response_notes,
			"time" = B.time_detected,
		))
	data["breaches"] = breach_list
	data["total_reports"] = SSraisa.total_reports
	data["active_breaches"] = SSraisa.active_breaches
	data["contained_breaches"] = SSraisa.contained_breaches
	return data

/datum/computer_file/program/scp_raisa/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_SECURITY in id_card.access))
		return
	switch(action)
		if("file_report")
			var/rtype = params["report_type"]
			var/target = params["target"]
			var/target_job = params["target_job"] || ""
			var/classification = params["classification"]
			var/findings = params["findings"]
			var/recommendations = params["recommendations"]
			var/datum/intel_report/R = new(H, rtype, target, target_job, classification, findings, recommendations)
			SSraisa.file_report(R)
			. = TRUE
		if("observe_person")
			var/target_name = params["target"]
			for(var/mob/living/carbon/human/M in GLOB.player_list)
				if(M.real_name == target_name)
					SSraisa.record_observation(M)
					break
			. = TRUE
		if("flag_person")
			var/target_name = params["target"]
			var/reason = params["reason"]
			for(var/mob/living/carbon/human/M in GLOB.player_list)
				if(M.real_name == target_name)
					SSraisa.flag_person(M, reason)
					break
			. = TRUE
		if("contain_breach")
			var/breach_id = params["breach_id"]
			var/notes = params["notes"] || ""
			SSraisa.contain_breach(breach_id, notes)
			. = TRUE
		if("register_breach")
			var/btype = params["breach_type"]
			var/source = params["source"]
			var/data_compromised = params["data"]
			var/severity = text2num(params["severity"]) || 1
			var/datum/info_breach/B = new(btype, source, data_compromised, severity)
			SSraisa.register_breach(B)
			. = TRUE

/datum/computer_file/program/scp_tribunal
	filename = "scp_tribunal"
	filedesc = "Internal Tribunal"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Manage tribunal cases, file charges, render verdicts."
	size = 3
	tgui_id = "ScpTribunalConsole"
	program_icon = "gavel"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_ADMIN_LVL5)

/datum/computer_file/program/scp_tribunal/ui_data(mob/user)
	var/list/data = get_header_data()
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		data["access_denied"] = TRUE
		return data
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ADMIN_LVL5 in id_card.access))
		data["access_denied"] = TRUE
		return data
	data["access_denied"] = FALSE
	var/list/case_list = list()
	for(var/datum/tribunal_case/C in SSinternal_tribunal.cases)
		case_list += list(C.get_data())
	data["cases"] = case_list
	data["total_cases"] = SSinternal_tribunal.total_cases
	data["active_case"] = SSinternal_tribunal.active_case ? TRUE : FALSE
	data["statistics"] = SSinternal_tribunal.get_statistics()
	data["sentencing_guidelines"] = SSinternal_tribunal.sentencing_guidelines
	return data

/datum/computer_file/program/scp_tribunal/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ADMIN_LVL5 in id_card.access))
		return
	switch(action)
		if("file_case")
			var/defendant = params["defendant"]
			var/charges = params["charges"]
			var/evidence = params["evidence"]
			var/datum/tribunal_case/C = new(defendant, H, charges, evidence)
			SSinternal_tribunal.file_case(C)
			. = TRUE
		if("begin_hearing")
			var/case_id = params["case_id"]
			for(var/datum/tribunal_case/C in SSinternal_tribunal.cases)
				if(C.case_id == case_id)
					C.begin_hearing()
					SSinternal_tribunal.active_case = C
					. = TRUE
					break
		if("enter_deliberation")
			var/case_id = params["case_id"]
			for(var/datum/tribunal_case/C in SSinternal_tribunal.cases)
				if(C.case_id == case_id)
					C.enter_deliberation()
					. = TRUE
					break
		if("render_verdict")
			var/case_id = params["case_id"]
			var/guilty = text2num(params["guilty"]) ? TRUE : FALSE
			var/sanction = text2num(params["sanction"]) || SANCTION_REPRIMAND
			var/sanction_desc = params["sanction_text"]
			for(var/datum/tribunal_case/C in SSinternal_tribunal.cases)
				if(C.case_id == case_id)
					C.render_verdict(guilty, sanction, sanction_desc)
					SSinternal_tribunal.active_case = null
					. = TRUE
					break
		if("dismiss_case")
			var/case_id = params["case_id"]
			for(var/datum/tribunal_case/C in SSinternal_tribunal.cases)
				if(C.case_id == case_id)
					C.dismiss_case()
					SSinternal_tribunal.active_case = null
					. = TRUE
					break
		if("add_witness")
			var/case_id = params["case_id"]
			for(var/datum/tribunal_case/C in SSinternal_tribunal.cases)
				if(C.case_id == case_id)
					C.add_witness(params["witness_name"])
					. = TRUE
					break
		if("remove_witness")
			var/case_id = params["case_id"]
			for(var/datum/tribunal_case/C in SSinternal_tribunal.cases)
				if(C.case_id == case_id)
					C.remove_witness(params["witness_name"])
					. = TRUE
					break
		if("add_evidence")
			var/case_id = params["case_id"]
			for(var/datum/tribunal_case/C in SSinternal_tribunal.cases)
				if(C.case_id == case_id)
					C.add_evidence(params["evidence_text"])
					. = TRUE
					break
		if("remove_evidence")
			var/case_id = params["case_id"]
			for(var/datum/tribunal_case/C in SSinternal_tribunal.cases)
				if(C.case_id == case_id)
					C.remove_evidence(params["evidence_idx"])
					. = TRUE
					break
		if("add_note")
			var/case_id = params["case_id"]
			for(var/datum/tribunal_case/C in SSinternal_tribunal.cases)
				if(C.case_id == case_id)
					C.add_note(params["note_text"])
					. = TRUE
					break
		if("set_defense_statement")
			var/case_id = params["case_id"]
			for(var/datum/tribunal_case/C in SSinternal_tribunal.cases)
				if(C.case_id == case_id)
					C.defense_statement = params["statement"]
					. = TRUE
					break
		if("set_prosecution_statement")
			var/case_id = params["case_id"]
			for(var/datum/tribunal_case/C in SSinternal_tribunal.cases)
				if(C.case_id == case_id)
					C.prosecution_statement = params["statement"]
					. = TRUE
					break
		if("set_severity")
			var/case_id = params["case_id"]
			for(var/datum/tribunal_case/C in SSinternal_tribunal.cases)
				if(C.case_id == case_id)
					C.severity_rating = text2num(params["severity"]) || 1
					. = TRUE
					break
		if("set_recommendation")
			var/case_id = params["case_id"]
			for(var/datum/tribunal_case/C in SSinternal_tribunal.cases)
				if(C.case_id == case_id)
					C.recommendation = params["recommendation"]
					. = TRUE
					break
		if("attach_document")
			var/case_id = params["case_id"]
			if(!case_id)
				return
			var/obj/item/paper/held_paper = H.get_active_held_item()
			if(!istype(held_paper))
				to_chat(H, span_warning("Hold a paper document in your active hand to attach it."))
				return
			for(var/datum/tribunal_case/C in SSinternal_tribunal.cases)
				if(C.case_id == case_id)
					if(C.attach_document(H, held_paper))
						to_chat(H, span_notice("Document attached to case [C.case_id]."))
					else
						to_chat(H, span_warning("Failed to attach document."))
					. = TRUE
					break
		if("remove_document")
			var/case_id = params["case_id"]
			var/doc_id = params["doc_id"]
			if(!case_id || !doc_id)
				return
			for(var/datum/tribunal_case/C in SSinternal_tribunal.cases)
				if(C.case_id == case_id)
					C.remove_document(doc_id)
					. = TRUE
					break

/datum/computer_file/program/scp_site_director
	filename = "scp_command"
	filedesc = "Site Command"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Issue directives, monitor facility status, manage site operations."
	size = 4
	tgui_id = "ScpSiteDirectorConsole"
	program_icon = "star"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_ADMIN_LVL5)

/datum/computer_file/program/scp_site_director/ui_data(mob/user)
	var/list/data = get_header_data()
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		data["access_denied"] = TRUE
		return data
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ADMIN_LVL5 in id_card.access))
		data["access_denied"] = TRUE
		return data
	data["access_denied"] = FALSE
	if(!SSsite_command)
		data["status"] = list(
			"total_breaches" = 0,
			"active_breaches" = 0,
			"total_recontainments" = 0,
			"power_status" = "Unknown",
			"comms_status" = "Unknown",
			"casualties" = 0,
			"dclass_alive" = 0,
			"dclass_escaped" = 0,
			"research_points" = 0,
			"time" = 0,
		)
		data["directives"] = list()
		data["total_directives"] = 0
		data["budget_spent"] = 0
		data["budget_total"] = 0
		data["ethics_pending"] = 0
		data["tribunal_cases"] = 0
		data["research_points"] = 0
		data["network_integrity"] = 100
		return data
	if(SSsite_command.current_report)
		var/datum/facility_status_report/R = SSsite_command.current_report
		data["status"] = list(
			"total_breaches" = R.total_breaches,
			"active_breaches" = R.active_breaches,
			"total_recontainments" = R.total_recontainments,
			"power_status" = R.power_status,
			"comms_status" = R.comms_status,
			"casualties" = R.casualties,
			"dclass_alive" = R.dclass_alive,
			"dclass_escaped" = R.dclass_escaped,
			"research_points" = R.research_points,
			"time" = R.time_generated,
		)
	else
		data["status"] = list(
			"total_breaches" = 0,
			"active_breaches" = 0,
			"total_recontainments" = 0,
			"power_status" = "Unknown",
			"comms_status" = "Unknown",
			"casualties" = 0,
			"dclass_alive" = 0,
			"dclass_escaped" = 0,
			"research_points" = 0,
			"time" = 0,
		)
	var/list/dir_list = list()
	for(var/datum/facility_directive/D in SSsite_command.directives)
		dir_list += list(list(
			"directive_id" = D.directive_id,
			"issuer" = D.issuer_name,
			"type" = D.directive_type,
			"title" = D.title,
			"content" = D.content,
			"priority" = D.priority,
			"status" = D.status,
			"acknowledged_count" = length(D.acknowledged_by),
			"time" = D.time_issued,
		))
	data["directives"] = dir_list
	data["total_directives"] = SSsite_command.total_directives
	data["budget_spent"] = SSfoundation_budget ? SSfoundation_budget.total_spent : 0
	data["budget_total"] = SSfoundation_budget ? SSfoundation_budget.total_budget : 0
	data["ethics_pending"] = SSethics_committee ? SSethics_committee.get_pending_count() : 0
	data["tribunal_cases"] = SSinternal_tribunal ? SSinternal_tribunal.total_cases : 0
	data["research_points"] = SSscp_research?.manager ? SSscp_research.manager.total_research_points : 0
	data["network_integrity"] = SSit_network ? SSit_network.overall_integrity : 100
	return data

/datum/computer_file/program/scp_site_director/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ADMIN_LVL5 in id_card.access))
		return
	if(!SSsite_command)
		return
	switch(action)
		if("print_status_report")
			SSsite_command.generate_status_paper(H)
			. = TRUE
		if("issue_directive")
			var/dtype = params["directive_type"]
			var/dtitle = params["title"]
			var/dcontent = params["content"]
			var/priority = text2num(params["priority"]) || 0
			var/expiry = text2num(params["expiry"]) || 0
			var/expiry_ticks = expiry ? expiry MINUTES : 0
			var/datum/facility_directive/D = new(H, dtype, dtitle, dcontent, priority, expiry_ticks)
			SSsite_command.issue_directive(D)
			. = TRUE
		if("acknowledge_directive")
			var/directive_id = params["directive_id"]
			SSsite_command.acknowledge_directive(directive_id, H)
			. = TRUE
		if("rescind_directive")
			var/directive_id = params["directive_id"]
			SSsite_command.rescind_directive(directive_id)
			. = TRUE

/datum/computer_file/program/scp_goi_terminal
	filename = "scp_goi"
	filedesc = "GOI Relations"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Monitor and manage relations with Groups of Interest."
	size = 3
	tgui_id = "ScpGoiTerminal"
	program_icon = "handshake"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_ADMIN_LVL4)

/datum/computer_file/program/scp_goi_terminal/ui_data(mob/user)
	var/list/data = get_header_data()
	data["goi_list"] = list()
	data["standing"] = list()
	data["interactions"] = list()
	if(SSgoi_relations)
		for(var/goi_name in SSgoi_relations.goi_standing)
			var/standing = SSgoi_relations.goi_standing[goi_name]
			data["goi_list"] += list(list("name" = goi_name, "standing" = standing))
			data["standing"][goi_name] = standing
		var/list/intel_list = list()
		for(var/datum/goi_intel/I in SSgoi_relations.intel_database)
			intel_list += list(list("id" = I.intel_id, "goi" = I.goi_name, "type" = I.intel_type, "verified" = I.verified))
		data["intel"] = intel_list
		var/list/comm_list = list()
		for(var/datum/goi_communique/C in SSgoi_relations.communiques)
			comm_list += list(list("id" = C.communique_id, "goi" = C.goi_name, "responded" = C.responded, "message" = C.message, "response" = C.response))
		data["communiques"] = comm_list
		data["total_intel"] = SSgoi_relations.total_intel
		data["total_communiques"] = SSgoi_relations.total_communiques
	data["has_command"] = FALSE
	var/mob/living/carbon/human/H = user
	if(istype(H))
		var/obj/item/card/id/id_card = H.get_idcard(TRUE)
		if(id_card && (ACCESS_ADMIN_LVL5 in id_card.access))
			data["has_command"] = TRUE
	return data

/datum/computer_file/program/scp_goi_terminal/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ADMIN_LVL4 in id_card.access))
		return
	switch(action)
		if("send_communique")
			var/goi_name = params["goi_name"]
			var/comm_type = params["comm_type"]
			var/message = params["message"]
			if(!goi_name || !message)
				return
			if(SSgoi_relations)
				var/datum/goi_communique/C = new(goi_name, comm_type, message, H)
				SSgoi_relations.send_communique(C)
			. = TRUE
		if("adjust_standing")
			var/has_command = id_card && (ACCESS_ADMIN_LVL5 in id_card.access)
			if(!has_command)
				return
			var/goi_name = params["goi_name"]
			var/adjustment = text2num(params["adjustment"]) || 0
			if(!goi_name || !adjustment)
				return
			if(SSgoi_relations)
				SSgoi_relations.adjust_standing(goi_name, adjustment)
			. = TRUE

/proc/scp_autofill_paper(paper_type, mob/user)
	var/turf/T = get_turf(user)
	switch(paper_type)
		if("ethics")
			var/obj/item/paper/foundation/ethics_violation/P = new(T)
			P.autofill_from_console(user)
			user.put_in_hands(P)
			to_chat(user, span_notice("Auto-filled ethics violation report printed."))
		if("budget")
			var/obj/item/paper/foundation/budget_request/P = new(T)
			P.autofill_from_console(user)
			user.put_in_hands(P)
			to_chat(user, span_notice("Auto-filled budget request printed."))
		if("psych")
			var/obj/item/paper/foundation/psych_evaluation/P = new(T)
			P.autofill_from_console(user)
			user.put_in_hands(P)
			to_chat(user, span_notice("Auto-filled psychological evaluation printed."))
		if("investigation")
			var/obj/item/paper/foundation/investigation_report/P = new(T)
			P.autofill_from_console(user)
			user.put_in_hands(P)
			to_chat(user, span_notice("Auto-filled investigation report printed."))

/proc/scp_create_escort_task(mob/living/carbon/human/dclass_subject, mob/living/carbon/human/researcher, scp_ref, test_type = "Standard Exposure", risk_level = 1)
	var/datum/escort_task/escort = new(dclass_subject, researcher, scp_ref, test_type, risk_level)
	SSscp_gameplay.escort_tasks[escort.task_id] = escort
	for(var/mob/living/carbon/human/G in GLOB.player_list)
		if(G.stat == DEAD)
			continue
		if(G.job && (findtext(G.job, "Guard") || findtext(G.job, "Security")))
			to_chat(G, span_warning("<b>ESCORT REQUEST:</b> Research needs [dclass_subject.real_name] escorted for [escort.scp_name] testing. Report to the guard patrol console."))

/datum/computer_file/program/scp_communications
	filename = "scp_comms"
	filedesc = "Communications Center"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Dispatch personnel, monitor threats, and manage facility communications."
	size = 3
	tgui_id = "ScpCommunicationsConsole"
	program_icon = "satellite-dish"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_ADMIN_LVL5)

/datum/computer_file/program/scp_communications/ui_data(mob/user)
	var/list/data = get_header_data()
	var/list/dispatch_list = list()
	for(var/datum/comm_dispatch/D in SSfoundation_comms.dispatches)
		dispatch_list += list(list(
			"dispatch_id" = D.dispatch_id,
			"type" = D.get_type_text(),
			"caller" = D.caller_name,
			"location" = D.caller_location,
			"message" = D.message,
			"priority" = D.priority,
			"responded" = D.responded,
			"responder_count" = length(D.responders),
			"time" = D.time_created,
		))
	data["dispatches"] = dispatch_list
	var/list/threat_list = list()
	for(var/datum/facility_threat/T in SSfoundation_comms.threats)
		threat_list += list(list(
			"threat_id" = T.threat_id,
			"name" = T.threat_name,
			"type" = T.threat_type,
			"level" = T.get_level_text(),
			"level_num" = T.threat_level,
			"location" = T.location,
			"description" = T.description,
			"resolved" = T.resolved,
			"resolved_by" = T.resolved_by,
			"time" = T.time_detected,
		))
	data["threats"] = threat_list
	data["facility_threat_level"] = SSfoundation_comms.facility_threat_level
	data["active_dispatches"] = SSfoundation_comms.active_dispatches
	data["resolved_dispatches"] = SSfoundation_comms.resolved_dispatches
	data["total_announcements"] = SSfoundation_comms.total_announcements
	return data

/datum/computer_file/program/scp_communications/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ADMIN_LVL5 in id_card.access))
		return
	switch(action)
		if("dispatch")
			var/dispatch_type = text2num(params["dispatch_type"]) || DISPATCH_SECURITY
			var/message = params["message"]
			var/priority = text2num(params["priority"]) || 0
			SSfoundation_comms.create_dispatch(H, dispatch_type, message, priority)
			. = TRUE
		if("respond_dispatch")
			var/dispatch_id = params["dispatch_id"]
			SSfoundation_comms.respond_dispatch(dispatch_id, H)
			. = TRUE
		if("register_threat")
			var/tname = params["threat_name"]
			var/ttype = params["threat_type"]
			var/tlevel = text2num(params["threat_level"]) || THREAT_LEVEL_YELLOW
			var/location = params["location"]
			var/desc = params["description"]
			SSfoundation_comms.register_threat(tname, ttype, tlevel, location, desc)
			. = TRUE
		if("resolve_threat")
			var/threat_id = params["threat_id"]
			SSfoundation_comms.resolve_threat(threat_id, H.real_name)
			. = TRUE
		if("make_announcement")
			var/message = params["message"]
			var/is_priority = params["priority"] == "1"
			SSfoundation_comms.total_announcements++
			if(is_priority)
				priority_announce(message, "Communications Director", null, ANNOUNCER_ALERT)
			else
				priority_announce(message, "Communications Director", null, ANNOUNCER_DEFAULT)
			if(SSraisa && ishuman(H))
				var/datum/intel_report/R = new(H, "facility_announcement", "Facility", H.job, is_priority ? "PRIORITY" : "ROUTINE", "Facility announcement: [message]", "Broadcast from Communications Console")
				SSraisa.file_report(R)
			. = TRUE

/datum/computer_file/program/scp_coordination
	filename = "scp_coord"
	filedesc = "Department Coordination"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Coordinate between departments, issue tasks, send interdepartmental memos."
	size = 3
	tgui_id = "ScpCoordinationConsole"
	program_icon = "project-diagram"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_ADMIN_LVL4)

/datum/computer_file/program/scp_coordination/ui_data(mob/user)
	var/list/data = get_header_data()
	var/list/task_list = list()
	for(var/datum/coordination_task/T in SSdepartment_coordination.tasks)
		task_list += list(list(
			"task_id" = T.task_id,
			"type" = T.task_type,
			"department" = T.department,
			"issuer" = T.issuer_name,
			"description" = T.description,
			"priority" = T.priority,
			"status" = T.status,
			"assignee" = T.assignee_name,
			"notes" = T.completion_notes,
			"time" = T.time_issued,
		))
	data["tasks"] = task_list
	data["memos"] = SSdepartment_coordination.interdepartmental_memos
	data["total_tasks"] = SSdepartment_coordination.total_tasks
	data["completed_tasks"] = SSdepartment_coordination.completed_tasks
	return data

/datum/computer_file/program/scp_coordination/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ADMIN_LVL4 in id_card.access))
		return
	switch(action)
		if("issue_task")
			var/dept = params["department"]
			var/ttype = params["task_type"]
			var/desc = params["description"]
			var/priority = text2num(params["priority"]) || 0
			var/datum/coordination_task/T = new(H, dept, ttype, desc, priority)
			SSdepartment_coordination.issue_task(T)
			. = TRUE
		if("assign_task")
			var/task_id = params["task_id"]
			SSdepartment_coordination.assign_task(task_id, H)
			. = TRUE
		if("complete_task")
			var/task_id = params["task_id"]
			var/notes = params["notes"] || ""
			SSdepartment_coordination.complete_task(task_id, notes)
			. = TRUE
		if("send_memo")
			var/from_dept = params["from"]
			var/to_dept = params["to"]
			var/subject = params["subject"]
			var/body = params["body"]
			SSdepartment_coordination.send_memo(from_dept, to_dept, subject, body, H.real_name)
			. = TRUE

/datum/computer_file/program/scp_vip_protection
	filename = "scp_vip"
	filedesc = "VIP Protection"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Manage VIP protection details and monitor personnel safety."
	size = 2
	tgui_id = "ScpVipProtectionConsole"
	program_icon = "shield-alt"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_SECURITY)

/datum/computer_file/program/scp_vip_protection/ui_data(mob/user)
	var/list/data = get_header_data()
	var/list/detail_list = list()
	for(var/datum/vip_protection_detail/D in SSvip_protection.details)
		detail_list += list(list(
			"detail_id" = D.detail_id,
			"vip" = D.vip_name,
			"vip_job" = D.vip_job,
			"guard" = D.assigned_guard,
			"status" = D.status,
			"checkins" = D.checkins,
			"last_checkin" = D.last_checkin,
			"overdue" = D.overdue,
			"time" = D.time_created,
		))
	data["details"] = detail_list
	data["total_details"] = SSvip_protection.total_details
	data["overdue_alerts"] = SSvip_protection.overdue_alerts
	return data

/datum/computer_file/program/scp_vip_protection/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_SECURITY in id_card.access))
		return
	switch(action)
		if("assign_detail")
			var/vip_name = params["vip"]
			var/mob/living/carbon/human/vip
			for(var/mob/living/carbon/human/M in GLOB.player_list)
				if(M.real_name == vip_name)
					vip = M
					break
			if(!vip)
				return
			SSvip_protection.assign_detail(vip, H)
			. = TRUE
		if("release_detail")
			var/detail_id = params["detail_id"]
			SSvip_protection.release_detail(detail_id)
			. = TRUE
		if("checkin")
			var/detail_id = params["detail_id"]
			for(var/datum/vip_protection_detail/D in SSvip_protection.details)
				if(D.detail_id == detail_id)
					D.checkin()
					break
			. = TRUE

/datum/computer_file/program/scp_it_network
	filename = "scp_it"
	filedesc = "IT Network Management"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Monitor and maintain the facility network, server racks, and cybersecurity."
	size = 3
	tgui_id = "ScpItNetworkConsole"
	program_icon = "network-wired"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_ENGINEERING)

/datum/computer_file/program/scp_it_network/ui_data(mob/user)
	var/list/data = get_header_data()
	var/list/node_list = list()
	for(var/datum/network_node/N in SSit_network.nodes)
		node_list += list(list(
			"node_id" = N.node_id,
			"name" = N.node_name,
			"area" = N.area_name,
			"status" = N.get_status_text(),
			"status_num" = N.status,
			"integrity" = N.integrity,
			"scp079_influence" = N.scp079_influence,
			"last_maintenance" = N.last_maintenance,
			"connected_count" = length(N.connected_nodes),
		))
	data["nodes"] = node_list
	var/list/rack_list = list()
	for(var/datum/server_rack/R in SSit_network.server_racks)
		rack_list += list(list(
			"rack_id" = R.rack_id,
			"name" = R.rack_name,
			"area" = R.area_name,
			"temperature" = R.temperature,
			"cpu" = R.cpu_usage,
			"memory" = R.memory_usage,
			"storage" = R.storage_usage,
			"firewall" = R.firewall_strength,
			"maintenance_required" = R.maintenance_required,
			"last_maintenance" = R.last_maintenance,
			"service_count" = length(R.running_services),
			"services" = R.running_services,
		))
	data["racks"] = rack_list
	data["overall_integrity"] = SSit_network.overall_integrity
	data["scp079_presence"] = SSit_network.scp079_network_presence
	data["last_scan"] = SSit_network.last_network_scan
	return data

/datum/computer_file/program/scp_it_network/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ENGINEERING in id_card.access))
		return
	switch(action)
		if("repair_node")
			var/node_id = params["node_id"]
			SSit_network.repair_node(node_id, 25)
			. = TRUE
		if("maintain_rack")
			var/rack_id = params["rack_id"]
			SSit_network.maintain_rack(rack_id)
			. = TRUE
		if("reboot_firewall")
			var/rack_id = params["rack_id"]
			SSit_network.reboot_firewall(rack_id)
			. = TRUE
		if("counter_scp079")
			SSit_network.counter_scp079()
			priority_announce("IT Countermeasures: SCP-079 network activity has been disrupted.", "IT Security", null, ANNOUNCER_DEFAULT)
			. = TRUE
		if("network_scan")
			SSit_network.run_network_scan()
			. = TRUE

/datum/computer_file/program/scp_guard_patrol
	filename = "scp_guard"
	filedesc = "Guard Patrol System"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Assign and manage guard patrol routes, accept escort tasks."
	size = 2
	tgui_id = "GuardPatrolConsole"
	program_icon = "walking"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_SECURITY)

/datum/computer_file/program/scp_guard_patrol/ui_data(mob/user)
	var/list/data = get_header_data()
	var/list/route_data = list()
	if(SSguard_patrols)
		for(var/route_id in SSguard_patrols.routes)
			var/datum/guard_patrol_route/route = SSguard_patrols.routes[route_id]
			var/guard_name = "Unassigned"
			if(route.active_guard_ckey)
				for(var/mob/living/carbon/human/M in GLOB.player_list)
					if(M.ckey == route.active_guard_ckey && M.stat != DEAD)
						guard_name = M.real_name
						break
				if(guard_name == "Unassigned")
					guard_name = "Missing"
			route_data += list(list(
				"route_id" = route.route_id,
				"route_name" = route.route_name,
				"zone" = route.zone,
				"waypoint_count" = length(route.waypoint_ids),
				"guard_name" = guard_name,
				"completed_count" = route.completed_count,
				"on_cooldown" = (world.time < route.last_patrol_time + route.patrol_cooldown),
			))
	data["routes"] = route_data
	var/list/guard_data = list()
	for(var/mob/living/carbon/human/M in GLOB.player_list)
		if(M.stat == DEAD)
			continue
		if(M.job && (findtext(M.job, "Guard") || findtext(M.job, "Security") || findtext(M.job, "MTF")))
			var/assigned_route = ""
			if(SSguard_patrols)
				for(var/r_id in SSguard_patrols.routes)
					var/datum/guard_patrol_route/r = SSguard_patrols.routes[r_id]
					if(r.active_guard_ckey == M.ckey)
						assigned_route = r.route_name
						break
			guard_data += list(list("name" = M.real_name, "ckey" = M.ckey, "job" = M.job, "assigned_route" = assigned_route))
	data["guards"] = guard_data
	var/list/escort_data = list()
	if(SSscp_gameplay)
		for(var/task_id in SSscp_gameplay.escort_tasks)
			var/datum/escort_task/task = SSscp_gameplay.escort_tasks[task_id]
			if(task.status == "expired" || task.status == "delivered" || task.status == "cancelled")
				continue
			escort_data += list(list(
				"task_id" = task.task_id,
				"subject_name" = task.subject ? task.subject.real_name : "Unknown",
				"scp_name" = task.scp_name,
				"test_type" = task.test_type,
				"risk_level" = task.risk_level,
				"status" = task.status,
				"guard_name" = task.escort_guard ? task.escort_guard.real_name : "Unassigned",
			))
	data["escorts"] = escort_data
	return data

/datum/computer_file/program/scp_guard_patrol/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_SECURITY in id_card.access))
		return
	if(!SSguard_patrols)
		return
	switch(action)
		if("assign_guard")
			var/guard_ckey = params["ckey"]
			var/route_id = params["route_id"]
			var/mob/living/carbon/human/guard
			for(var/mob/living/carbon/human/M in GLOB.player_list)
				if(M.ckey == guard_ckey && M.stat != DEAD)
					guard = M
					break
			if(guard)
				SSguard_patrols.assign_guard_to_route(guard, route_id)
			. = TRUE
		if("release_guard")
			var/guard_ckey = params["ckey"]
			var/route_id = params["route_id"]
			var/mob/living/carbon/human/guard
			for(var/mob/living/carbon/human/M in GLOB.player_list)
				if(M.ckey == guard_ckey && M.stat != DEAD)
					guard = M
					break
			if(guard)
				SSguard_patrols.release_guard_from_route(guard, route_id)
			. = TRUE
		if("self_assign")
			var/route_id = params["route_id"]
			SSguard_patrols.assign_guard_to_route(H, route_id)
			. = TRUE
		if("self_release")
			for(var/r_id in SSguard_patrols.routes)
				var/datum/guard_patrol_route/route = SSguard_patrols.routes[r_id]
				if(route.active_guard_ckey == H.ckey)
					SSguard_patrols.release_guard_from_route(H, r_id)
					break
			. = TRUE
		if("accept_escort")
			var/task_id = params["task_id"]
			if(!SSscp_gameplay)
				return
			var/datum/escort_task/task = SSscp_gameplay.escort_tasks[task_id]
			if(task)
				task.assign_guard(H)
			. = TRUE
		if("complete_escort")
			var/task_id = params["task_id"]
			if(!SSscp_gameplay)
				return
			var/datum/escort_task/task = SSscp_gameplay.escort_tasks[task_id]
			if(task && task.escort_guard == H)
				if(task.subject && get_dist(H, task.subject) <= 3)
					task.complete_delivery()
			. = TRUE

/datum/computer_file/program/scp_door_control
	filename = "scp_door"
	filedesc = "SCP Door Control"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Control doors and airlocks across SCP containment zones."
	size = 2
	tgui_id = "SCPDoorControl"
	program_icon = "door-open"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_SECURITY)

/datum/computer_file/program/scp_door_control/ui_data(mob/user)
	var/list/data = get_header_data()
	data["zones"] = list(
		list("name" = "Light Containment", "state" = 0, "state_name" = "Normal"),
		list("name" = "Heavy Containment", "state" = 0, "state_name" = "Normal"),
		list("name" = "Entrance Zone", "state" = 0, "state_name" = "Normal"),
		list("name" = "D-Class Block", "state" = 0, "state_name" = "Normal"),
		list("name" = "Surface", "state" = 0, "state_name" = "Normal"),
	)
	var/total_doors = 0
	var/locked_doors = 0
	for(var/obj/machinery/door/airlock/D in INSTANCES_OF(/obj/machinery/door/airlock))
		var/area/A = get_area(D)
		if(!istype(A, /area/scp))
			continue
		total_doors++
		if(D.locked)
			locked_doors++
	data["total_doors"] = total_doors
	data["locked_doors"] = locked_doors
	return data

/datum/computer_file/program/scp_door_control/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_SECURITY in id_card.access))
		return
	switch(action)
		if("set_zone_state")
			var/zone = params["zone"]
			var/new_state = text2num(params["state"])
			scp_apply_zone_state(zone, new_state, H)
			. = TRUE
		if("emergency_open_all")
			scp_emergency_open_all()
			. = TRUE
		if("emergency_lock_all")
			scp_emergency_lock_all()
			. = TRUE
		if("cycle_airlock")
			var/zone = params["zone"]
			scp_cycle_zone_airlocks(zone)
			. = TRUE

/proc/scp_zone_to_area_type(zone)
	switch(zone)
		if("Light Containment")
			return /area/scp/lcz
		if("Heavy Containment")
			return /area/scp/hcz
		if("Entrance Zone")
			return /area/scp/ez
		if("D-Class Block")
			return /area/scp/dclass
		if("Surface")
			return /area/scp/surface
	return null

/proc/scp_get_scp_areas()
	. = list()
	for(var/area/A in GLOB.areas)
		if(istype(A, /area/scp))
			. += A

/proc/scp_get_zone_doors(zone)
	var/area/zone_type = scp_zone_to_area_type(zone)
	if(!zone_type)
		return list()
	. = list()
	for(var/area/A in scp_get_scp_areas())
		if(!istype(A, zone_type))
			continue
		for(var/obj/machinery/door/airlock/D in A.contents)
			. += D

/proc/scp_apply_zone_state(zone, state, mob/user)
	var/area/zone_type = scp_zone_to_area_type(zone)
	if(!zone_type)
		return
	for(var/area/A in scp_get_scp_areas())
		if(!istype(A, zone_type))
			continue
		for(var/obj/machinery/door/airlock/D in A.contents)
			switch(state)
				if(0)
					D.unlock()
				if(1)
					D.lock()
					D.close()
				if(2)
					D.unlock()
					D.open()
				if(3)
					D.lock()
					D.close()

/proc/scp_emergency_open_all()
	for(var/area/A in scp_get_scp_areas())
		for(var/obj/machinery/door/airlock/D in A.contents)
			D.unlock()
			D.open()

/proc/scp_emergency_lock_all()
	for(var/area/A in scp_get_scp_areas())
		for(var/obj/machinery/door/airlock/D in A.contents)
			D.lock()
			D.close()

/proc/scp_cycle_zone_airlocks(zone)
	var/area/zone_type = scp_zone_to_area_type(zone)
	if(!zone_type)
		return
	for(var/area/A in scp_get_scp_areas())
		if(!istype(A, zone_type))
			continue
		for(var/obj/machinery/door/airlock/D in A.contents)
			if(D.density)
				D.open()
				addtimer(CALLBACK(D, /obj/machinery/door/proc/close), 50)
			else
				D.close()
				addtimer(CALLBACK(D, /obj/machinery/door/proc/open), 50)

/datum/computer_file/program/scp_intercom
	filename = "scp_intercom"
	filedesc = "Facility Intercom"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Broadcast messages across the facility's intercom and PA system."
	size = 2
	tgui_id = "SCPIntercomConsole"
	program_icon = "bullhorn"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_SECURITY)

/datum/computer_file/program/scp_intercom/ui_data(mob/user)
	var/list/data = get_header_data()
	data["zones"] = list("Facility-Wide", "Light Containment", "Heavy Containment", "Entrance Zone", "D-Class Block", "Surface")
	data["emergency_types"] = list(
		list("id" = "breach", "name" = "Containment Breach"),
		list("id" = "biohazard", "name" = "Biohazard"),
		list("id" = "power", "name" = "Power Failure"),
		list("id" = "dclass", "name" = "D-Class Incident"),
		list("id" = "evacuation", "name" = "Evacuation"),
	)
	return data

/datum/computer_file/program/scp_intercom/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_SECURITY in id_card.access))
		return
	switch(action)
		if("broadcast")
			var/message = params["message"]
			var/zone = params["zone"] || "Facility-Wide"
			if(!message)
				return
			scp_intercom_broadcast(message, zone, H)
			. = TRUE
		if("emergency")
			var/emergency_type = params["type"]
			var/zone = params["zone"] || "Facility-Wide"
			scp_intercom_emergency(emergency_type, zone, H)
			. = TRUE

/proc/scp_intercom_get_zone_areas(zone)
	. = list()
	switch(zone)
		if("Light Containment")
			. += /area/scp/lcz
		if("Heavy Containment")
			. += /area/scp/hcz
		if("Entrance Zone")
			. += /area/scp/ez
		if("D-Class Block")
			. += /area/scp/dclass
		if("Surface")
			. += /area/scp/surface
		if("Facility-Wide")
			. += /area/scp

/proc/scp_intercom_broadcast(message, zone, mob/user)
	var/broadcast_text = "<span class='boldannounce'>[zone] Announcement:</span> [html_encode(message)]"
	var/list/target_area_types = scp_intercom_get_zone_areas(zone)
	for(var/mob/M in GLOB.mob_list)
		if(QDELETED(M) || !M.client)
			continue
		if(zone == "Facility-Wide")
			to_chat(M, broadcast_text)
		else
			var/area/mob_area = get_area(M)
			if(mob_area)
				for(var/T in target_area_types)
					if(istype(mob_area, T))
						to_chat(M, broadcast_text)
						break

/proc/scp_intercom_emergency(emergency_type, zone, mob/user)
	var/emergency_text
	switch(emergency_type)
		if("breach")
			emergency_text = "CONTAINMENT BREACH DETECTED. ALL PERSONNEL PROCEED TO NEAREST SAFE ZONE."
		if("biohazard")
			emergency_text = "BIOHAZARD ALERT. HAZMAT PROTOCOLS IN EFFECT."
		if("power")
			emergency_text = "POWER FAILURE DETECTED. EMERGENCY POWER ACTIVE."
		if("dclass")
			emergency_text = "D-CLASS INCIDENT IN PROGRESS. SECURITY PERSONNEL RESPOND."
		if("evacuation")
			emergency_text = "EVACUATION ORDER. ALL NON-ESSENTIAL PERSONNEL PROCEED TO SURFACE EXIT."
	if(!emergency_text)
		return
	var/broadcast_text = "<span class='userdanger'>[zone] EMERGENCY: [emergency_text]</span>"
	var/list/target_area_types = scp_intercom_get_zone_areas(zone)
	for(var/mob/M in GLOB.mob_list)
		if(QDELETED(M) || !M.client)
			continue
		if(zone == "Facility-Wide")
			to_chat(M, broadcast_text)
		else
			var/area/mob_area = get_area(M)
			if(mob_area)
				for(var/T in target_area_types)
					if(istype(mob_area, T))
						to_chat(M, broadcast_text)
						break

/datum/computer_file/program/scp_camera_monitor
	filename = "scp_camera"
	filedesc = "SCP Camera Monitor"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Monitor cameras across SCP containment zones."
	size = 2
	tgui_id = "SCPCameraConsole"
	program_icon = "video"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_SECURITY)

/datum/computer_file/program/scp_camera_monitor/ui_data(mob/user)
	var/list/data = get_header_data()
	data["current_zone"] = "All Zones"
	data["zones"] = list("All Zones", "Light Containment", "Heavy Containment", "Entrance Zone", "D-Class Block", "Surface")
	var/list/cameras = list()
	for(var/obj/machinery/camera/C in INSTANCES_OF(/obj/machinery/camera))
		if(C.machine_stat & NOPOWER)
			continue
		var/area/cam_area = get_area(C)
		if(!istype(cam_area, /area/scp))
			continue
		cameras += list(list("name" = C.c_tag || "Unknown", "area" = cam_area?.name || "Unknown", "status" = C.machine_stat & BROKEN ? "broken" : "active", "ref" = "\ref[C]"))
	data["cameras"] = cameras
	data["camera_count"] = length(cameras)
	return data

/datum/computer_file/program/scp_camera_monitor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(action == "view_camera")
		var/obj/machinery/camera/C = locate(params["ref"])
		if(C && !(C.machine_stat & NOPOWER) && ishuman(ui.user))
			var/mob/living/carbon/human/H = ui.user
			H.reset_perspective(C)
			addtimer(CALLBACK(H, /mob/proc/reset_perspective), 100)
			. = TRUE

/datum/computer_file/program/scp_recontainment_guide
	filename = "scp_recontain"
	filedesc = "Recontainment Protocols"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Reference terminal containing classified recontainment protocols."
	size = 2
	tgui_id = "SCPRecontainmentGuide"
	program_icon = "book"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE

/datum/computer_file/program/scp_recontainment_guide/ui_data(mob/user)
	var/list/data = get_header_data()
	var/list/all_guides = list()
	var/list/entries = new /datum/scp_recontainment_guide().guide_entries
	for(var/key in entries)
		var/list/entry = entries[key]
		all_guides += list(list("designation" = entry["designation"], "class" = entry["class"], "threat" = entry["threat"], "procedures" = entry["procedures"], "warning" = entry["warning"]))
	data["guides"] = all_guides
	return data

/datum/computer_file/program/scp_scp_monitoring
	filename = "scp_monitor"
	filedesc = "SCP Monitoring"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Real-time status of all contained SCPs."
	size = 2
	tgui_id = "SCPMonitoringConsole"
	program_icon = "heartbeat"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE

/datum/computer_file/program/scp_scp_monitoring/ui_data(mob/user)
	var/list/data = get_header_data()
	var/list/scp_list = list()
	if(SSscp_persistence && SSscp_persistence.manager)
		for(var/scp_id in SSscp_persistence.manager.scp_instances)
			var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[scp_id]
			if(!instance)
				continue
			scp_list += list(list("id" = scp_id, "status" = instance.containment_status || "unknown", "health" = instance.containment_health, "last_breach" = instance.last_breach ? round((world.time - instance.last_breach) / 600) : -1, "breach_count" = length(instance.breach_history), "interaction_count" = length(instance.interaction_history)))
		data["global_stability"] = SSscp_persistence.manager.global_containment_stability
		data["active_breaches"] = SSscp_persistence.manager.active_breaches
	else
		data["global_stability"] = 100
		data["active_breaches"] = 0
	data["scps"] = scp_list
	data["time"] = world.time
	return data

/datum/computer_file/program/scp_scp_monitoring/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(action == "acknowledge_breach")
		if(SSscp_persistence?.manager)
			SSscp_persistence.manager.global_containment_stability = min(100, SSscp_persistence.manager.global_containment_stability + 5)
			. = TRUE

/datum/computer_file/program/scp_morgue
	filename = "scp_morgue"
	filedesc = "Morgue Management"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Manage morgue records and issue death certificates."
	size = 2
	tgui_id = "MorgueConsole"
	program_icon = "notes-medical"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_MEDICAL)

/datum/computer_file/program/scp_morgue/ui_data(mob/user)
	var/list/data = get_header_data()
	var/list/bodies = list()
	for(var/mob/living/carbon/human/H in GLOB.mob_living_list)
		if(H.stat != DEAD || !is_station_level(H.z))
			continue
		bodies += list(list("name" = H.real_name, "job" = H.job || "Unknown", "location" = get_area_name(H, TRUE) || "Unknown", "ref" = REF(H), "time_of_death" = gameTimestamp("hh:mm"), "has_certificate" = FALSE))
	data["bodies"] = bodies
	return data

/datum/computer_file/program/scp_morgue/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(action == "issue_certificate")
		var/mob/living/carbon/human/H = locate(params["ref"]) in GLOB.mob_living_list
		if(!H || H.stat != DEAD)
			return
		var/cause = params["cause"] || "Pending Autopsy"
		var/obj/item/paper/death_certificate/cert = new(get_turf(ui.user))
		cert.generate_certificate(H, cause)
		if(GLOB.scp_admin_log)
			GLOB.scp_admin_log.log_event("death_cert", "N/A", ui.user?.ckey || "N/A", H.real_name, "Death certificate issued: [cause]", 2)
		. = TRUE

/datum/computer_file/program/scp_security_codes
	filename = "scp_seccodes"
	filedesc = "Foundation Security Codes"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Manage facility-wide security codes and alert levels."
	size = 2
	tgui_id = "FoundationSecurityConsole"
	program_icon = "exclamation-triangle"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_ADMIN_LVL3)

/datum/computer_file/program/scp_security_codes/ui_data(mob/user)
	var/list/data = get_header_data()
	data["currentLevel"] = SSsecurity_level.current_level
	data["currentCodeName"] = foundation_code_name(SSsecurity_level.current_level)
	data["currentCodeColor"] = foundation_code_color(SSsecurity_level.current_level)
	data["description"] = foundation_code_description(SSsecurity_level.current_level)
	data["procedures"] = foundation_code_procedures(SSsecurity_level.current_level)
	var/list/codes = list()
	for(var/i = 0 to 3)
		codes += list(list("level" = i, "name" = foundation_code_name(i), "color" = foundation_code_color(i), "description" = foundation_code_description(i)))
	data["availableCodes"] = codes
	var/mob/living/carbon/human/H = user
	var/obj/item/card/id/id_card = istype(H) ? H.get_idcard(TRUE) : null
	data["hasAccess"] = id_card && (ACCESS_ADMIN in id_card.access)
	return data

/datum/computer_file/program/scp_security_codes/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ADMIN in id_card.access))
		return
	if(action == "setCode")
		var/new_level = text2num(params["level"])
		if(isnull(new_level) || new_level < SEC_LEVEL_GREEN || new_level > SEC_LEVEL_DELTA)
			return
		if(new_level == SSsecurity_level.current_level)
			return
		var/reason = params["reason"]
		set_foundation_security_code(new_level, reason, H)
		. = TRUE

/datum/computer_file/program/scp_sanity_monitor
	filename = "scp_sanity"
	filedesc = "Sanity Monitor"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Monitor and manage mental health status."
	size = 2
	tgui_id = "SanityPanel"
	program_icon = "brain"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_MEDICAL)

/datum/computer_file/program/scp_sanity_monitor/ui_data(mob/user)
	var/list/data = get_header_data()
	if(!ishuman(user))
		return data
	var/mob/living/carbon/human/H = user
	if(!H.sanity)
		return data
	var/datum/sanity/S = H.sanity
	data["sanity_level"] = S.sanity_level
	data["max_sanity"] = S.max_sanity
	data["sanity_state"] = S.current_sanity_state
	data["sanity_percentage"] = round((S.sanity_level / S.max_sanity) * 100, 0.1)
	data["hallucination_level"] = S.hallucination_level
	data["episode_active"] = S.episode_active
	data["episode_type"] = S.episode_type
	data["recommendations"] = S.get_medical_recommendations()
	data["prognosis"] = S.get_medical_prognosis()
	return data

/datum/computer_file/program/scp_sanity_monitor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!ishuman(ui.user))
		return
	var/mob/living/carbon/human/H = ui.user
	if(!H.sanity)
		return
	var/datum/sanity/S = H.sanity
	switch(action)
		if("medicate_antipsychotic")
			S.add_medication(new /datum/medication/antipsychotic())
			. = TRUE
		if("medicate_antianxiety")
			S.add_medication(new /datum/medication/antianxiety())
			. = TRUE
		if("medicate_sedative")
			S.add_medication(new /datum/medication/sedative())
			. = TRUE
		if("dismiss_episode")
			if(S.episode_active)
				S.end_episode()
			. = TRUE

/datum/computer_file/program/scp_foundation_email
	filename = "scp_email"
	filedesc = "Foundation Email"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Send and receive Foundation interdepartmental messages."
	size = 2
	tgui_id = "FoundationEmail"
	program_icon = "envelope"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE

/datum/computer_file/program/scp_foundation_email/ui_data(mob/user)
	var/list/data = get_header_data()
	var/list/inbox = list()
	for(var/obj/machinery/foundation_email_terminal/T in INSTANCES_OF(/obj/machinery/foundation_email_terminal))
		for(var/msg in T.inbox)
			inbox += list(msg)
		break
	data["inbox"] = inbox
	data["max_messages"] = 50
	return data

/datum/computer_file/program/scp_foundation_email/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("send_message")
			var/recipient = params["recipient"] || "All Staff"
			var/subject = params["subject"] || "No Subject"
			var/body = params["body"] || ""
			if(!ui.user)
				return
			var/sender_name = ui.user?.real_name || "Unknown"
			var/sender_job = "Unknown"
			if(ishuman(ui.user))
				var/mob/living/carbon/human/H = ui.user
				sender_job = H.job || "Unknown"
			var/message = list("sender" = sender_name, "sender_job" = sender_job, "recipient" = recipient, "subject" = subject, "body" = body, "time" = gameTimestamp("hh:mm"), "priority" = params["priority"] || "normal")
			for(var/obj/machinery/foundation_email_terminal/T in INSTANCES_OF(/obj/machinery/foundation_email_terminal))
				if(length(T.inbox) >= T.max_messages)
					T.inbox.Cut(1, 2)
				T.inbox += list(message)
			if(GLOB.scp_admin_log)
				GLOB.scp_admin_log.log_event("email", "N/A", ui.user?.ckey || "N/A", recipient, "[subject]: [body]", 1)
			. = TRUE

/datum/computer_file/program/scp_dclass_work
	filename = "scp_dclass_work"
	filedesc = "D-Class Work Assignments"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "View and accept D-Class work assignments."
	size = 2
	tgui_id = "DclassWorkTerminal"
	program_icon = "hard-hat"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE

/datum/computer_file/program/scp_dclass_work/ui_data(mob/user)
	var/list/data = get_header_data()

	var/list/assignments = list()
	var/list/available = list()
	var/list/history = list()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/datum/dclass_player/player = SSdclass?.manager?.get_dclass_player(H.ckey)

		if(player)
			data["dclass_name"] = H.real_name
			data["dclass_id"] = "D-[player.dclass_number || H.ckey]"
			data["trust_level"] = player.trust_level
			data["trust_name"] = get_trust_name(player.trust_level)
			data["credits"] = player.credits
			data["strikes"] = player.strikes
			data["tests_completed"] = player.tests_completed
			data["behavior_score"] = player.good_behavior_points - player.bad_behavior_points
			data["is_active"] = (H.ckey in SSdclass_experiments?.active_test_subjects)

			if(data["is_active"])
				var/list/active = SSdclass_experiments.active_test_subjects[H.ckey]
				if(active)
					assignments = list(list(
						"scp_id" = active["scp_id"] || "Unknown",
						"test_type" = active["test_type"] || "Standard",
						"danger_level" = active["danger_level"] || 1,
						"voluntary" = active["voluntary"] || FALSE,
						"elapsed" = world.time - (active["start_time"] || world.time),
					))

			var/list/test_list = H.get_available_tests()
			for(var/test_name in test_list)
				var/list/test_info = test_list[test_name]
				available += list(list(
					"name" = test_name,
					"scp_id" = test_info["scp_id"],
					"test_type" = test_info["test_type"],
					"danger_level" = test_info["danger"],
					"reward" = test_info["reward"],
				))

			if(SSdclass_experiments?.test_history)
				var/start = max(1, length(SSdclass_experiments.test_history) - 9)
				for(var/i = length(SSdclass_experiments.test_history), i >= start, i--)
					var/list/record = SSdclass_experiments.test_history[i]
					if(record["ckey"] == H.ckey)
						history += list(list(
							"scp_id" = record["scp_id"] || "Unknown",
							"outcome" = record["outcome"] || "Unknown",
							"danger_level" = record["danger_level"] || 1,
							"reward" = record["reward"] || 0,
							"time" = record["time"] ? time2text(record["time"], "HH:MM") : "Unknown",
						))

	data["assignments"] = assignments
	data["available_tests"] = available
	data["history"] = history
	return data

/datum/computer_file/program/scp_dclass_work/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!ishuman(ui.user))
		return

	var/mob/living/carbon/human/H = usr

	switch(action)
		if("volunteer")
			H.volunteer_for_testing()
			return TRUE
		if("report_complete")
			if(H.ckey in SSdclass_experiments?.active_test_subjects)
				var/list/subject_data = SSdclass_experiments.active_test_subjects[H.ckey]
				if(subject_data)
					SSdclass_experiments.complete_subject_participation(H, "success", subject_data["scp_id"], subject_data["danger_level"])
					return TRUE

/datum/computer_file/program/scp_dclass_work/proc/get_trust_name(trust)
	switch(trust)
		if(DCLASS_TRUST_HOSTILE)
			return "Hostile"
		if(DCLASS_TRUST_SUSPICIOUS)
			return "Uncooperative"
		if(DCLASS_TRUST_NEUTRAL)
			return "Neutral"
		if(DCLASS_TRUST_COOPERATIVE)
			return "Cooperative"
		if(DCLASS_TRUST_TRUSTED)
			return "Trusted"
		else
			return "Unknown"

/datum/computer_file/program/scp_rehabilitation
	filename = "scp_rehab"
	filedesc = "Rehabilitation Management"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Manage rehabilitation of captured operatives."
	size = 2
	tgui_id = "RehabilitationConsole"
	program_icon = "user-check"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_SECURITY)

/datum/computer_file/program/scp_rehabilitation/ui_data(mob/user)
	var/list/data = get_header_data()
	var/list/prisoners = list()
	for(var/mob/living/carbon/human/H in GLOB.mob_living_list)
		if(!H.mind)
			continue
		var/datum/antagonist/rehabilitated/rehab = H.mind.has_antag_datum(/datum/antagonist/rehabilitated)
		if(!rehab)
			continue
		prisoners += list(list("name" = H.real_name, "job" = H.job || "Unknown", "stage" = rehab.rehab_stage, "progress" = rehab.rehab_progress, "required" = rehab.required_progress, "ref" = REF(H)))
	data["prisoners"] = prisoners
	return data

/datum/computer_file/program/scp_rehabilitation/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(action == "advance_rehab")
		var/mob/living/carbon/human/H = locate(params["ref"]) in GLOB.mob_living_list
		if(!H || !H.mind)
			return
		var/datum/antagonist/rehabilitated/rehab = H.mind.has_antag_datum(/datum/antagonist/rehabilitated)
		if(rehab)
			rehab.advance_rehabilitation(params["amount"] || 25)
		. = TRUE
	if(action == "administer_amnestic")
		var/mob/living/carbon/human/H = locate(params["ref"]) in GLOB.mob_living_list
		if(!H || !H.mind)
			return
		var/datum/antagonist/rehabilitated/rehab = H.mind.has_antag_datum(/datum/antagonist/rehabilitated)
		if(rehab)
			for(var/datum/antagonist/A in H.mind.antag_datums)
				if(A != rehab)
					H.mind.remove_antag_datum(A.type)
			rehab.rehab_stage = max(rehab.rehab_stage, 2)
			rehab.rehab_progress = 0
		. = TRUE
	if(action == "release")
		var/mob/living/carbon/human/H = locate(params["ref"]) in GLOB.mob_living_list
		if(!H || !H.mind)
			return
		var/datum/antagonist/rehabilitated/rehab = H.mind.has_antag_datum(/datum/antagonist/rehabilitated)
		if(rehab && rehab.rehab_stage >= 3)
			rehab.complete_rehabilitation()
		. = TRUE

/datum/computer_file/program/scp_contagion_monitor
	filename = "scp_contagion"
	filedesc = "Contagion Monitor"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Track active contagions, quarantine zones, and exposure chains."
	size = 2
	tgui_id = "ContagionConsole"
	program_icon = "biohazard"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_MEDICAL)

/datum/computer_file/program/scp_contagion_monitor/ui_data(mob/user)
	var/list/data = get_header_data()
	var/list/contagions = list()
	var/list/zones = list()
	var/list/chains = list()
	if(GLOB.contagion_tracker)
		for(var/list/contagion in GLOB.contagion_tracker.active_contagions)
			var/mob/living/carbon/human/carrier = contagion["carrier"]
			contagions += list(list("carrier_name" = carrier ? carrier.name : "Unknown", "contagion_type" = contagion["contagion_type"], "spread_count" = contagion["spread_count"], "active" = carrier && carrier.stat != DEAD))
		for(var/list/zone in GLOB.contagion_tracker.quarantine_zones)
			var/area/A = zone["area"]
			zones += list(list("area_name" = A ? A.name : "Unknown", "reason" = zone["reason"], "declared_time" = zone["declared_time"]))
		for(var/ckey in GLOB.contagion_tracker.exposed_personnel)
			var/list/exposures = GLOB.contagion_tracker.exposed_personnel[ckey]
			var/list/exposure_data = list()
			for(var/list/exposure in exposures)
				exposure_data += list(list("contagion_type" = exposure["contagion_type"], "exposure_time" = exposure["exposure_time"], "source" = exposure["source"]))
			chains += list(list("ckey" = ckey, "exposures" = exposure_data))
	data["contagions"] = contagions
	data["quarantine_zones"] = zones
	data["exposure_chains"] = chains
	return data

/datum/computer_file/program/scp_contagion_monitor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!ishuman(ui.user))
		return
	switch(action)
		if("declare_quarantine")
			var/area/A = get_area(ui.user)
			if(A && GLOB.contagion_tracker)
				GLOB.contagion_tracker.declare_quarantine(A, params["reason"] || "Contagion risk detected")
			. = TRUE
		if("lift_quarantine")
			var/area/A = get_area(ui.user)
			if(A && GLOB.contagion_tracker)
				GLOB.contagion_tracker.lift_quarantine(A)
			. = TRUE

/datum/computer_file/program/scp_evacuation
	filename = "scp_evac"
	filedesc = "Facility Evacuation"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Emergency evacuation authorization. Only Site Director or Captain may authorize."
	size = 2
	tgui_id = "FoundationEvacuation"
	program_icon = "helicopter"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_ADMIN_LVL5)

/datum/computer_file/program/scp_evacuation/ui_data(mob/user)
	var/list/data = get_header_data()
	var/evac_called = FALSE
	var/evac_timer = 0
	for(var/obj/machinery/computer/foundation_evacuation/E in INSTANCES_OF(/obj/machinery/computer/foundation_evacuation))
		evac_called = E.evacuation_called
		evac_timer = E.evacuation_timer
		break
	data["evacuation_called"] = evac_called
	data["time_remaining"] = evac_timer ? max(0, (evac_timer - world.time) / 10) : 0
	data["security_level"] = SSsecurity_level ? SSsecurity_level.current_level : 0
	return data

/datum/computer_file/program/scp_evacuation/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ADMIN_LVL5 in id_card.access))
		return
	if(action == "call_evacuation")
		if(SSsecurity_level && SSsecurity_level.current_level < SEC_LEVEL_RED)
			to_chat(H, span_warning("Evacuation requires Code Red or higher security level."))
			return
		priority_announce("EMERGENCY EVACUATION AUTHORIZED. All personnel proceed to surface helipad immediately.", "EVACUATION", null, ANNOUNCER_ALERT)
		. = TRUE
	if(action == "cancel_evacuation")
		priority_announce("Evacuation cancelled. All personnel resume normal duties.", "EVACUATION CANCELLED", null, ANNOUNCER_ALERT)
		. = TRUE

/datum/computer_file/program/scp_human_resources
	filename = "scp_hr"
	filedesc = "Human Resources Management"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Manage clearance requests, personnel reassignments, amnestic authorizations, and exposure reviews."
	size = 3
	tgui_id = "ScpHumanResources"
	program_icon = "id-card"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_ADMIN)

/datum/computer_file/program/scp_human_resources/ui_data(mob/user)
	var/list/data = get_header_data()
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		data["access_denied"] = TRUE
		return data
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ADMIN in id_card.access))
		data["access_denied"] = TRUE
		return data
	data["access_denied"] = FALSE
	if(SShuman_resources)
		data["clearance_requests"] = SShuman_resources.clearance_requests
		data["reassignment_requests"] = SShuman_resources.reassignment_requests
		data["amnestic_authorizations"] = SShuman_resources.amnestic_authorizations
		data["exposure_reviews"] = SShuman_resources.exposure_reviews
		data["pending_count"] = SShuman_resources.get_pending_count()
		data["total_reviews"] = SShuman_resources.total_reviews
		data["approved_reviews"] = SShuman_resources.approved_reviews
		data["denied_reviews"] = SShuman_resources.denied_reviews
		data["total_reassignments"] = SShuman_resources.total_reassignments
		data["total_amnestic_auths"] = SShuman_resources.total_amnestic_auths
	return data

/datum/computer_file/program/scp_human_resources/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ADMIN in id_card.access))
		return
	if(!SShuman_resources)
		return
	switch(action)
		if("approve_clearance")
			SShuman_resources.review_clearance_request(params["ckey"], TRUE, params["notes"] || "")
			. = TRUE
		if("deny_clearance")
			SShuman_resources.review_clearance_request(params["ckey"], FALSE, params["notes"] || "")
			. = TRUE
		if("approve_reassignment")
			var/idx = text2num(params["index"])
			SShuman_resources.review_reassignment(idx, TRUE, params["notes"] || "")
			. = TRUE
		if("deny_reassignment")
			var/idx = text2num(params["index"])
			SShuman_resources.review_reassignment(idx, FALSE, params["notes"] || "")
			. = TRUE
		if("authorize_amnestic")
			var/mob/living/carbon/human/subject
			for(var/mob/living/carbon/human/M in GLOB.player_list)
				if(M.real_name == params["subject"])
					subject = M
					break
			if(subject)
				SShuman_resources.authorize_amnestic(subject, params["class"] || "A", params["reason"] || "", H)
			. = TRUE
		if("review_exposure")
			var/idx = text2num(params["index"])
			SShuman_resources.review_exposure(idx, params["fit"] == "1", params["notes"] || "")
			. = TRUE

/datum/computer_file/program/scp_cell_management
	filename = "scp_cells"
	filedesc = "Cell Management"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Manage D-Class cell assignments, schedules, lockdowns, and incident logs."
	size = 2
	tgui_id = "ScpCellManagement"
	program_icon = "door-closed"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_SECURITY)

/datum/computer_file/program/scp_cell_management/ui_data(mob/user)
	var/list/data = get_header_data()
	if(SScell_management)
		data["cells"] = SScell_management.cells
		data["schedules"] = SScell_management.schedules
		data["incidents"] = SScell_management.incidents
		data["total_incidents"] = SScell_management.total_incidents
		data["total_transfers"] = SScell_management.total_transfers
		data["next_schedule"] = SScell_management.get_schedule_status()
	return data

/datum/computer_file/program/scp_cell_management/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_SECURITY in id_card.access))
		return
	if(!SScell_management)
		return
	switch(action)
		if("lockdown_cell")
			SScell_management.lockdown_cell(text2num(params["index"]))
			. = TRUE
		if("unlockdown_cell")
			SScell_management.unlockdown_cell(text2num(params["index"]))
			. = TRUE
		if("transfer_dclass")
			SScell_management.transfer_dclass(params["name"], params["from"], params["to"])
			. = TRUE
		if("assign_cell")
			SScell_management.assign_cell(params["name"], params["cell_type"])
			. = TRUE
		if("log_incident")
			SScell_management.log_incident(params["type"], params["location"], H.real_name)
			. = TRUE

/datum/computer_file/program/scp_containment_integrity
	filename = "scp_integrity"
	filedesc = "Containment Integrity Monitor"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Monitor containment zone integrity, assign maintenance tasks, track repair progress."
	size = 3
	tgui_id = "ScpContainmentIntegrity"
	program_icon = "shield-alt"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_ENGINEERING)

/datum/computer_file/program/scp_containment_integrity/ui_data(mob/user)
	var/list/data = get_header_data()
	if(SScontainment_integrity)
		data["zones"] = SScontainment_integrity.containment_zones
		data["maintenance_tasks"] = SScontainment_integrity.maintenance_tasks
		data["overall_integrity"] = SScontainment_integrity.overall_integrity
		data["total_breach_repairs"] = SScontainment_integrity.total_breach_repairs
		data["total_maintenance"] = SScontainment_integrity.total_maintenance_done
		data["overdue_tasks"] = SScontainment_integrity.overdue_tasks
		var/list/recent_log = list()
		var/start = max(1, length(SScontainment_integrity.integrity_log) - 20)
		for(var/i = start to length(SScontainment_integrity.integrity_log))
			recent_log += list(SScontainment_integrity.integrity_log[i])
		data["integrity_log"] = recent_log
	return data

/datum/computer_file/program/scp_containment_integrity/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ENGINEERING in id_card.access))
		return
	if(!SScontainment_integrity)
		return
	switch(action)
		if("assign_task")
			SScontainment_integrity.assign_maintenance_task(params["task_id"], H)
			. = TRUE
		if("complete_task")
			var/repair = text2num(params["repair"]) || 25
			SScontainment_integrity.complete_maintenance_task(params["task_id"], repair)
			. = TRUE
		if("repair_zone")
			var/amount = text2num(params["amount"]) || 20
			SScontainment_integrity.repair_zone(params["zone"], amount)
			. = TRUE
		if("generate_task")
			SScontainment_integrity.generate_maintenance_task(params["zone"], params["reason"] || "manual")
			. = TRUE

/datum/computer_file/program/scp_medical_response
	filename = "scp_medresp"
	filedesc = "SCP Medical Response"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Track SCP-related injuries, dispatch responders, manage contamination cases."
	size = 2
	tgui_id = "ScpMedicalResponse"
	program_icon = "ambulance"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_MEDICAL)

/datum/computer_file/program/scp_medical_response/ui_data(mob/user)
	var/list/data = get_header_data()
	if(SSscp_medical_response)
		data["active_incidents"] = SSscp_medical_response.active_incidents
		data["contamination_queue"] = SSscp_medical_response.contamination_queue
		data["total_incidents"] = SSscp_medical_response.total_incidents
		data["total_responses"] = SSscp_medical_response.total_responses
		data["total_decontaminations"] = SSscp_medical_response.total_decontaminations
		data["avg_response_time"] = SSscp_medical_response.avg_response_time
	return data

/datum/computer_file/program/scp_medical_response/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_MEDICAL in id_card.access))
		return
	if(!SSscp_medical_response)
		return
	switch(action)
		if("dispatch_responder")
			SSscp_medical_response.dispatch_responder(params["incident_id"], H)
			. = TRUE
		if("update_status")
			SSscp_medical_response.update_incident_status(params["incident_id"], text2num(params["status"]))
			. = TRUE
		if("complete_decon")
			SSscp_medical_response.complete_decontamination(params["victim"])
			. = TRUE
		if("report_injury")
			var/mob/living/carbon/human/victim
			for(var/mob/living/carbon/human/M in GLOB.player_list)
				if(M.real_name == params["victim"])
					victim = M
					break
			if(victim)
				SSscp_medical_response.report_scp_injury(victim, params["type"], text2num(params["severity"]) || 1, params["source"] || "Unknown")
			. = TRUE

/datum/computer_file/program/scp_pathogen_research
	filename = "scp_pathogen"
	filedesc = "Pathogen Research"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Track anomalous pathogens, manage research projects, develop countermeasures."
	size = 3
	tgui_id = "ScpPathogenResearch"
	program_icon = "microscope"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_MEDICAL)

/datum/computer_file/program/scp_pathogen_research/ui_data(mob/user)
	var/list/data = get_header_data()
	if(SSfoundation_pathogens)
		var/list/infection_list = list()
		for(var/key in SSfoundation_pathogens.active_infections)
			var/list/I = SSfoundation_pathogens.active_infections[key]
			var/mob/living/carbon/human/host = I["host"]
			infection_list += list(list(
				"host_name" = host ? host.real_name : "Unknown",
				"host_job" = host ? (host.job || "Unknown") : "Unknown",
				"pathogen_type" = I["pathogen_type"],
				"bsl" = I["bsl"],
				"progress" = SSfoundation_pathogens.get_research_progress(I["pathogen_type"]),
				"treated" = FALSE,
				"time_detected" = I["time"],
			))
		data["active_infections"] = infection_list
		var/list/research_list = list()
		for(var/pkey in SSfoundation_pathogens.pathogen_research_data)
			var/list/P = SSfoundation_pathogens.pathogen_research_data[pkey]
			var/is_active = SSfoundation_pathogens.active_research[pkey] ? TRUE : FALSE
			var/list/active_data = SSfoundation_pathogens.active_research[pkey]
			research_list += list(list(
				"project_id" = pkey,
				"pathogen" = P["name"],
				"researcher" = active_data ? (active_data["researcher"] ? "[active_data["researcher"]]" : "Unknown") : "",
				"progress" = P["research_stage"],
				"stage" = P["research_stage"] >= 4 ? "complete" : P["research_stage"] >= 3 ? "countermeasure_dev" : P["research_stage"] >= 2 ? "analysis" : "sample_collection",
				"active" = is_active,
				"points_contributed" = P["research_stage"] * 25,
			))
		data["research_projects"] = research_list
		var/list/countermeasure_list = list()
		for(var/list/C in SSfoundation_pathogens.cure_log)
			countermeasure_list += list(list(
				"pathogen" = C["pathogen_type"],
				"developer" = "Foundation",
				"effective" = TRUE,
				"time_developed" = C["time"],
			))
		data["countermeasures"] = countermeasure_list
		data["total_infections"] = length(SSfoundation_pathogens.active_infections)
		data["total_countermeasures"] = length(SSfoundation_pathogens.cure_log)
		data["total_research"] = length(SSfoundation_pathogens.pathogen_research_data)
	return data

/datum/computer_file/program/scp_pathogen_research/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_MEDICAL in id_card.access))
		return
	if(!SSfoundation_pathogens)
		return
	switch(action)
		if("start_research")
			SSfoundation_pathogens.start_research(params["pathogen"], H)
			. = TRUE
		if("contribute_research")
			var/stages = text2num(params["amount"]) ? round(text2num(params["amount"]) / 25) : 1
			if(stages > 0)
				SSfoundation_pathogens.advance_research(params["project_id"], stages)
			. = TRUE

/datum/computer_file/program/scp_containment_robotics
	filename = "scp_robots"
	filedesc = "Containment Robotics"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Build and manage containment bots, track maintenance, coordinate containment assists."
	size = 2
	tgui_id = "ScpContainmentRobotics"
	program_icon = "robot"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_SCIENCE)

/datum/computer_file/program/scp_containment_robotics/ui_data(mob/user)
	var/list/data = get_header_data()
	if(SScontainment_robotics)
		data["registered_bots"] = SScontainment_robotics.registered_bots
		data["construction_queue"] = SScontainment_robotics.construction_queue
		data["total_built"] = SScontainment_robotics.total_bots_built
		data["total_maintenance"] = SScontainment_robotics.total_maintenance_done
		data["total_assists"] = SScontainment_robotics.total_containment_assists
	return data

/datum/computer_file/program/scp_containment_robotics/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_SCIENCE in id_card.access))
		return
	if(!SScontainment_robotics)
		return
	switch(action)
		if("submit_order")
			SScontainment_robotics.submit_construction_order(text2num(params["type"]), H)
			. = TRUE
		if("start_construction")
			SScontainment_robotics.start_construction(text2num(params["index"]), H)
			. = TRUE
		if("advance_construction")
			SScontainment_robotics.advance_construction(text2num(params["index"]), text2num(params["progress"]) || 25, text2num(params["stability"]) || 0)
			. = TRUE

/datum/computer_file/program/scp_ventilation
	filename = "scp_vent"
	filedesc = "Zone Ventilation Control"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Monitor zone air quality, manage ventilation purges, replace filters, emergency venting."
	size = 2
	tgui_id = "ScpVentilation"
	program_icon = "wind"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_ENGINEERING)

/datum/computer_file/program/scp_ventilation/ui_data(mob/user)
	var/list/data = get_header_data()
	if(SSzone_ventilation)
		data["zones"] = SSzone_ventilation.ventilation_zones
		data["alerts"] = SSzone_ventilation.air_quality_alerts
		data["total_purges"] = SSzone_ventilation.total_purge_cycles
		data["total_filters"] = SSzone_ventilation.total_filters_replaced
		data["total_emergency"] = SSzone_ventilation.total_emergency_vents
	return data

/datum/computer_file/program/scp_ventilation/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ENGINEERING in id_card.access))
		return
	if(!SSzone_ventilation)
		return
	switch(action)
		if("start_purge")
			SSzone_ventilation.start_purge(text2num(params["zone"]))
			. = TRUE
		if("emergency_vent")
			SSzone_ventilation.emergency_vent(text2num(params["zone"]))
			. = TRUE
		if("replace_filter")
			SSzone_ventilation.replace_filter(text2num(params["zone"]), text2num(params["amount"]) || 25)
			. = TRUE
		if("report_contamination")
			SSzone_ventilation.report_contamination(text2num(params["zone"]), text2num(params["amount"]) || 10, params["source"] || "Unknown")
			. = TRUE

/datum/computer_file/program/scp_anomalous_chemistry
	filename = "scp_chem"
	filedesc = "Anomalous Chemistry"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Research and synthesize anomalous compounds, track containment chemicals."
	size = 2
	tgui_id = "ScpAnomalousChemistry"
	program_icon = "flask"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_MEDICAL)

/datum/computer_file/program/scp_anomalous_chemistry/ui_data(mob/user)
	var/list/data = get_header_data()
	if(SSanomalous_chemistry)
		data["compounds"] = SSanomalous_chemistry.compound_registry
		data["synthesis_queue"] = SSanomalous_chemistry.synthesis_queue
		data["test_results"] = SSanomalous_chemistry.test_results
		data["total_synthesized"] = SSanomalous_chemistry.total_compounds_synthesized
		data["total_research"] = SSanomalous_chemistry.total_research_contributions
		data["total_containment"] = SSanomalous_chemistry.total_containment_chemicals
	return data

/datum/computer_file/program/scp_anomalous_chemistry/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_MEDICAL in id_card.access))
		return
	if(!SSanomalous_chemistry)
		return
	switch(action)
		if("start_synthesis")
			SSanomalous_chemistry.start_synthesis(params["compound"], text2num(params["amount"]) || 1, H)
			. = TRUE
		if("advance_synthesis")
			SSanomalous_chemistry.advance_synthesis(text2num(params["index"]), text2num(params["progress"]) || 25, text2num(params["stability"]) || 5)
			. = TRUE
		if("stabilize")
			SSanomalous_chemistry.stabilize_compound(text2num(params["index"]), text2num(params["amount"]) || 20)
			. = TRUE
		if("register_compound")
			SSanomalous_chemistry.register_compound(params["name"], params["properties"], params["origin"])
			. = TRUE

/datum/computer_file/program/scp_research_laboratory
	filename = "scp_research_lab"
	filedesc = "SCP Research Laboratory"
	category = PROGRAM_CATEGORY_SCI
	program_icon_state = "generic"
	extended_desc = "Manage research projects, experiments, and team assignments for SCP study."
	size = 4
	tgui_id = "ResearchLaboratory"
	program_icon = "flask"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_SCIENCE)

/datum/computer_file/program/scp_research_laboratory/ui_data(mob/user)
	if(!SSresearch_laboratory || !SSresearch_laboratory.manager)
		return get_header_data()
	var/list/data = get_header_data()
	data += SSresearch_laboratory.manager.get_all_data(user)
	return data

/datum/computer_file/program/scp_research_laboratory/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!SSresearch_laboratory || !SSresearch_laboratory.manager)
		return
	var/datum/research_laboratory_manager/mgr = SSresearch_laboratory.manager

	switch(action)
		if("create_project")
			if(!mgr.can_manage(usr))
				return
			if(!params["name"])
				return
			var/list/scp_targets = params["scp_targets"]
			if(!scp_targets)
				scp_targets = list()
			if(!islist(scp_targets))
				scp_targets = list(scp_targets)
			mgr.create_research_project(list(
				"name" = params["name"],
				"description" = params["description"] || "",
				"scp_targets" = scp_targets,
				"research_field" = params["research_field"] || "General",
			))
			. = TRUE

		if("approve_project")
			if(!mgr.can_manage(usr))
				return
			if(params["project_id"])
				mgr.approve_research_project(params["project_id"])
			. = TRUE

		if("revoke_project")
			if(!mgr.can_manage(usr))
				return
			if(params["project_id"])
				mgr.revoke_research_project(params["project_id"])
			. = TRUE

		if("add_project_scp_target")
			if(!mgr.can_manage(usr))
				return
			if(params["project_id"] && params["scp_id"])
				mgr.add_project_scp_target(params["project_id"], params["scp_id"])
			. = TRUE

		if("remove_project_scp_target")
			if(!mgr.can_manage(usr))
				return
			if(params["project_id"] && params["scp_id"])
				mgr.remove_project_scp_target(params["project_id"], params["scp_id"])
			. = TRUE

		if("assign_project_team")
			if(!mgr.can_manage(usr))
				return
			if(params["project_id"])
				mgr.assign_project_team(params["project_id"], params["team_id"] || "")
			. = TRUE

		if("create_team")
			if(!mgr.can_manage(usr))
				return
			var/team_name = params["name"]
			if(!team_name)
				team_name = ""
			mgr.create_research_team(list("name" = team_name))
			. = TRUE

		if("add_team_member")
			var/team_id = params["team_id"]
			if(team_id && ishuman(usr))
				if(mgr.is_research_personnel(usr))
					mgr.add_team_member(team_id, usr)
				else
					mgr.request_team_join(team_id, usr)
					to_chat(usr, span_notice("Join request submitted. A researcher must approve it."))
			. = TRUE

		if("remove_team_member")
			var/team_id = params["team_id"]
			var/ckey = params["ckey"]
			if(!ishuman(usr))
				return TRUE
			if(team_id && ckey)
				mgr.remove_team_member(team_id, ckey)
			. = TRUE

		if("request_team_join")
			var/team_id = params["team_id"]
			if(team_id && ishuman(usr))
				if(mgr.is_research_personnel(usr))
					mgr.add_team_member(team_id, usr)
				else
					mgr.request_team_join(team_id, usr)
					to_chat(usr, span_notice("Join request submitted. A researcher must approve it."))
			. = TRUE

		if("approve_join_request")
			var/req_id = params["request_id"]
			if(req_id && mgr.can_manage(usr))
				mgr.approve_join_request(req_id)
			. = TRUE

		if("deny_join_request")
			var/req_id = params["request_id"]
			if(req_id && mgr.can_manage(usr))
				mgr.deny_join_request(req_id)
			. = TRUE

		if("start_experiment")
			if(!mgr.can_manage(usr))
				return
			var/scp_id = params["scp_id"]
			var/exp_type = text2num(params["experiment_type"])
			if(scp_id && exp_type && ishuman(usr))
				var/mob/living/carbon/human/H = usr
				var/datum/scp_experiment/exp = mgr.start_scp_experiment(H, scp_id, exp_type)
				if(!exp)
					to_chat(H, "<span class='warning'>Failed to start experiment.</span>")
			. = TRUE

		if("suspend_experiment")
			if(!mgr.can_manage(usr))
				return
			var/exp_id = params["experiment_id"]
			if(exp_id)
				mgr.suspend_scp_experiment(exp_id, usr)
			. = TRUE

		if("resume_experiment")
			if(!mgr.can_manage(usr))
				return
			var/exp_id = params["experiment_id"]
			if(exp_id)
				mgr.resume_scp_experiment(exp_id, usr)
			. = TRUE

		if("record_safety_violation")
			var/protocol_id = params["protocol_id"]
			if(protocol_id)
				mgr.record_safety_violation(protocol_id)
				var/protocol = mgr.safety_protocols[protocol_id]
				if(protocol)
					to_chat(usr, "<span class='warning'>Safety violation recorded for [protocol["name"]]. Violations: [protocol["violations"]]/[protocol["violation_threshold"]].</span>")
					if(protocol["status"] == "emergency")
						to_chat(usr, "<span class='boldwarning'>EMERGENCY: [protocol["name"]] has exceeded its violation threshold!</span>")
			. = TRUE
