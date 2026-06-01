#define PAPER_AUTOFILL_ETHICS 1
#define PAPER_AUTOFILL_BUDGET 2
#define PAPER_AUTOFILL_PSYCH 3
#define PAPER_AUTOFILL_INVESTIGATION 4

/obj/item/paper/foundation/proc/autofill_from_console(mob/user)
	return

/obj/item/paper/foundation/proc/autofill_from_subsystem(fill_type, mob/user)
	var/list/fields = list()
	switch(fill_type)
		if(PAPER_AUTOFILL_ETHICS)
			if(!SSethics_committee)
				return
			var/list/violations_pending = SSethics_committee.get_violations_by_status(ETHICS_STATUS_PENDING)
			var/list/violations_review = SSethics_committee.get_violations_by_status(ETHICS_STATUS_UNDER_REVIEW)
			fields["pending_count"] = length(violations_pending)
			fields["under_review_count"] = length(violations_review)
			fields["total_violations"] = length(SSethics_committee?.violations)
			fields["total_reviews"] = SSethics_committee?.total_reviews
			fields["upheld_count"] = SSethics_committee?.upheld_count
			fields["dismissed_count"] = SSethics_committee?.dismissed_count
			var/list/violation_summary = list()
			for(var/datum/ethics_violation/V in violations_pending)
				violation_summary += "[V.violation_id]: [V.violation_type] ([V.get_severity_text()]) - Accused: [V.accused_name]"
			for(var/datum/ethics_violation/V in violations_review)
				violation_summary += "[V.violation_id]: [V.violation_type] ([V.get_severity_text()]) - Accused: [V.accused_name] - UNDER REVIEW"
			fields["violation_list"] = jointext(violation_summary, "<br>")
			var/list/oversight_summary = list()
			for(var/test_id in SSethics_committee?.active_test_oversights)
				var/list/O = SSethics_committee.active_test_oversights[test_id]
				oversight_summary += "[test_id]: [O["scp_name"]] - Risk: [O["risk_level"]] - [O["approved"] ? "APPROVED" : O["denied"] ? "DENIED" : "PENDING"]"
			fields["oversight_list"] = jointext(oversight_summary, "<br>")
		if(PAPER_AUTOFILL_BUDGET)
			if(!SSfoundation_budget)
				return
			fields["total_budget"] = SSfoundation_budget?.total_budget
			fields["total_spent"] = SSfoundation_budget?.total_spent
			fields["remaining"] = (SSfoundation_budget?.total_budget || 0) - (SSfoundation_budget?.total_spent || 0)
			var/list/dept_summary = list()
			for(var/dept in SSfoundation_budget?.department_budgets)
				var/datum/department_budget/B = SSfoundation_budget.department_budgets[dept]
				dept_summary += "[capitalize(dept)]: Allocated [B.allocated], Spent [B.spent], Remaining [B.remaining], Pending [B.pending_requests]"
			fields["department_list"] = jointext(dept_summary, "<br>")
			var/list/pending_requests = list()
			for(var/datum/budget_request/R in SSfoundation_budget?.requests)
				if(R.status == "pending")
					pending_requests += "[R.request_id]: [capitalize(R.department)] - [R.amount]cr by [R.requester_name] - [R.purpose]"
			fields["pending_requests"] = jointext(pending_requests, "<br>")
		if(PAPER_AUTOFILL_PSYCH)
			if(!SSpsychology)
				return
			fields["pending_evals"] = SSpsychology.pending_evals
			fields["completed_evals"] = SSpsychology.completed_evals
			fields["counseling_sessions"] = SSpsychology.counseling_sessions
			fields["amnestics_recommended"] = SSpsychology.amnestics_recommended
			fields["amnestics_administered"] = SSpsychology.amnestics_administered
			var/list/exposure_summary = list()
			var/untreated_count = 0
			for(var/datum/scp_exposure_record/R in SSpsychology.exposure_records)
				if(!R.treated)
					untreated_count++
					exposure_summary += "[R.person_name] ([R.person_job]): [R.scp_encountered] - [R.exposure_type] - [R.symptoms]"
			fields["untreated_exposures"] = untreated_count
			fields["exposure_list"] = jointext(exposure_summary, "<br>")
			var/list/eval_summary = list()
			for(var/datum/psych_evaluation/E in SSpsychology.evaluations)
				if(E.status == PSYCH_EVAL_COMPLETE)
					eval_summary += "[E.eval_id]: [E.patient_name] ([E.patient_job]) - Type: [E.eval_type] - Score: [E.sanity_score] - Exposure: [E.get_exposure_text()] - Amnestic: [E.amnestic_recommended]"
			fields["eval_list"] = jointext(eval_summary, "<br>")
		if(PAPER_AUTOFILL_INVESTIGATION)
			if(!SSanomalous_investigations)
				return
			fields["total_evidence"] = SSanomalous_investigations.total_evidence
			fields["analyzed_evidence"] = SSanomalous_investigations.analyzed_evidence
			var/list/case_summary = list()
			for(var/case_name in SSanomalous_investigations.active_cases)
				var/list/C = SSanomalous_investigations.active_cases[case_name]
				case_summary += "[case_name]: [C["status"]] - Evidence: [C["evidence_count"]] - [C["description"]]"
			fields["case_list"] = jointext(case_summary, "<br>")
			var/list/evidence_summary = list()
			for(var/datum/anomalous_evidence/E in SSanomalous_investigations.evidence_log)
				evidence_summary += "[E.evidence_id]: [E.evidence_type] from [E.location_found] - SCP: [E.scp_related || "None"] - [E.analyzed ? "Analyzed: [E.analysis_result]" : "Unanalyzed"]"
			fields["evidence_list"] = jointext(evidence_summary, "<br>")
	return fields

/obj/item/paper/foundation/ethics_violation/autofill_from_console(mob/user)
	var/list/fields = autofill_from_subsystem(PAPER_AUTOFILL_ETHICS, user)
	if(!length(fields))
		return
	var/user_name = user?.real_name || "Unknown"
	var/clearance = "Unknown"
	var/mob/living/carbon/human/U = user
	if(istype(U))
		var/obj/item/card/id/id_card = U.get_idcard(TRUE)
		if(id_card)
			clearance = "[id_card.access.len]"
	setText({"<h2>SCP FOUNDATION - ETHICS COMMITTEE VIOLATION REPORT</h2><hr>
<b>Report ID:</b> AUTO-[world.time]<br>
<b>Date:</b> [time2text(world.realtime, "YYYY-MM-DD")]<br>
<b>Auto-filled from Ethics Committee Console</b><hr>
<b>Reporting Personnel:</b> [user_name]<br>
<b>Clearance Level:</b> [clearance]<hr>
<b>Current Violations Summary:</b><br>
Pending: [fields["pending_count"]] | Under Review: [fields["under_review_count"]] | Total: [fields["total_violations"]]<br>
Total Reviews: [fields["total_reviews"]] | Upheld: [fields["upheld_count"]] | Dismissed: [fields["dismissed_count"]]<hr>
<b>Active Violations:</b><br>
[fields["violation_list"]]<hr>
<b>Test Oversights:</b><br>
[fields["oversight_list"]]<hr>
<b>Violation Severity:</b><br>
(_) Minor (_) Moderate (_) Severe (_) Critical<br>
<b>Violation Type:</b><br>
(_) Unnecessary D-Class Suffering<br>
(_) Testing Without Approval<br>
(_) Cruel and Unusual Procedures<br>
(_) Withholding Medical Treatment<br>
(_) Unauthorized Amnestic Use<br>
(_) SCP Mistreatment<br>
(_) Other: ________________________<hr>
<b>Description of Violation:</b><br>
___________________________________________________________________________<br>
___________________________________________________________________________<br><hr>
<b>Reporting Signature:</b> ________________________ <b>Date:</b> ________<br>
<b>ECL Review:</b> ________________________ <b>Date:</b> ________<br>
<br><i>CLASSIFIED - ETHICS COMMITTEE EYES ONLY</i><br>"}, FALSE)

/obj/item/paper/foundation/budget_request/autofill_from_console(mob/user)
	var/list/fields = autofill_from_subsystem(PAPER_AUTOFILL_BUDGET, user)
	if(!length(fields))
		return
	var/user_name = user?.real_name || "Unknown"
	var/clearance = "Unknown"
	var/mob/living/carbon/human/U = user
	if(istype(U))
		var/obj/item/card/id/id_card = U.get_idcard(TRUE)
		if(id_card)
			clearance = "[id_card.access.len]"
	setText({"<h2>SCP FOUNDATION - BUDGET FUNDING REQUEST</h2><hr>
<b>Request ID:</b> AUTO-[world.time]<br>
<b>Date:</b> [time2text(world.realtime, "YYYY-MM-DD")]<br><hr>
<b>Requesting Personnel:</b> [user_name]<br>
<b>Department:</b> Command / Security / Science / Medical / Engineering / Logistics / Service<br>
<b>Clearance Level:</b> [clearance]<hr>
<b>Current Budget Status:</b><br>
Total Budget: [fields["total_budget"]] credits<br>
Total Spent: [fields["total_spent"]] credits<br>
Remaining: [fields["remaining"]] credits<hr>
<b>Department Breakdown:</b><br>
[fields["department_list"]]<hr>
<b>Pending Requests:</b><br>
[fields["pending_requests"]]<hr>
<b>Amount Requested (credits):</b> ________<br>
<b>Purpose:</b><br>
___________________________________________________________________________<br><hr>
<b>Justification:</b><br>
___________________________________________________________________________<br><hr>
<b>Requesting Signature:</b> ________________________ <b>Date:</b> ________<br>
<b>Department Head Approval:</b> ________________________ <b>Date:</b> ________<br>
<b>Bureaucrat Review:</b> ________________________ <b>Date:</b> ________<br>"}, FALSE)

/obj/item/paper/foundation/psych_evaluation/autofill_from_console(mob/user)
	var/list/fields = autofill_from_subsystem(PAPER_AUTOFILL_PSYCH, user)
	if(!length(fields))
		return
	var/user_name = user?.real_name || "Unknown"
	setText({"<h2>SCP FOUNDATION - PSYCHOLOGICAL EVALUATION</h2><hr>
<b>Evaluation ID:</b> AUTO-[world.time]<br>
<b>Date:</b> [time2text(world.realtime, "YYYY-MM-DD")]<br><hr>
<b>Subject Name:</b> ________________________<br>
<b>Subject Role:</b> ________________________<br>
<b>Evaluating Psychologist:</b> [user_name]<br><hr>
<b>Psychology Department Status:</b><br>
Pending Evaluations: [fields["pending_evals"]] | Completed: [fields["completed_evals"]]<br>
Counseling Sessions: [fields["counseling_sessions"]] | Amnestics Recommended: [fields["amnestics_recommended"]] | Administered: [fields["amnestics_administered"]]<br>
Untreated SCP Exposures: [fields["untreated_exposures"]]<hr>
<b>Evaluation Type:</b> Routine / Post-Incident / Pre-Employment / SCP Exposure Follow-up<hr>
<b>Current Sanity Assessment:</b> Stable / Mild Distress / Moderate Distress / Severe Distress / Critical<br>
<b>SCP Exposure Level:</b> None / Low / Moderate / Severe / Critical<hr>
<b>Active Exposure Records:</b><br>
[fields["exposure_list"]]<hr>
<b>Completed Evaluations Summary:</b><br>
[fields["eval_list"]]<hr>
<b>Behavioral Observations:</b><br>
___________________________________________________________________________<br><hr>
<b>Recommendations:</b><br>
(_) No Action Required<br>
(_) Counseling Sessions Recommended<br>
(_) Amnestic Treatment Recommended (Class: ________)<br>
(_) Temporary Duty Restriction<br>
(_) Permanent Reassignment<br>
(_) Medical Leave<hr>
<b>Evaluating Psychologist Signature:</b> ________________________ <b>Date:</b> ________<br>
<b>Medical Director Review:</b> ________________________ <b>Date:</b> ________<br>
<br><i>CONFIDENTIAL - MEDICAL CLEARANCE REQUIRED</i><br>"}, FALSE)

/obj/item/paper/foundation/investigation_report/autofill_from_console(mob/user)
	var/list/fields = autofill_from_subsystem(PAPER_AUTOFILL_INVESTIGATION, user)
	if(!length(fields))
		return
	var/user_name = user?.real_name || "Unknown"
	var/clearance = "Unknown"
	var/mob/living/carbon/human/U = user
	if(istype(U))
		var/obj/item/card/id/id_card = U.get_idcard(TRUE)
		if(id_card)
			clearance = "[id_card.access.len]"
	setText({"<h2>SCP FOUNDATION - ANOMALOUS INVESTIGATION REPORT</h2><hr>
<b>Report ID:</b> AUTO-[world.time]<br>
<b>Date:</b> [time2text(world.realtime, "YYYY-MM-DD")]<br><hr>
<b>Investigating Agent:</b> [user_name]<br>
<b>Clearance Level:</b> [clearance]<hr>
<b>Investigations Status:</b><br>
Total Evidence: [fields["total_evidence"]] | Analyzed: [fields["analyzed_evidence"]]<hr>
<b>Active Cases:</b><br>
[fields["case_list"]]<hr>
<b>Evidence Log:</b><br>
[fields["evidence_list"]]<hr>
<b>Case Name:</b> ________________________<br>
<b>Investigation Type:</b> Anomalous Evidence / SCP-Related / Personnel / Unknown Phenomenon<hr>
<b>Location of Investigation:</b> ________________________<br>
<b>SCP Designation (if applicable):</b> SCP-________<hr>
<b>Findings:</b><br>
___________________________________________________________________________<br>
___________________________________________________________________________<br><hr>
<b>Analysis Summary:</b><br>
___________________________________________________________________________<br><hr>
<b>Recommended Actions:</b><br>
___________________________________________________________________________<br><hr>
<b>Investigating Agent Signature:</b> ________________________ <b>Date:</b> ________<br>
<b>RAISA Review:</b> ________________________ <b>Date:</b> ________<br>
<br><i>CLASSIFIED - RAISA CLEARANCE REQUIRED</i><br>"}, FALSE)

/datum/controller/subsystem/psychology/proc/process_suspicion_surveillance()
	if(!SSdclass?.manager)
		return
	for(var/ckey in SSdclass?.manager?.dclass_players)
		var/datum/dclass_player/P = SSdclass?.manager?.dclass_players[ckey]
		if(!P || !P.mob || P.suspicion_level < 40)
			continue
		var/datum/surveillance_subject/S = SSraisa.get_or_create_subject(P.mob)
		if(P.suspicion_level >= 80)
			if(!S.flagged)
				S.flag("High suspicion level: [P.suspicion_level]/100")
				var/datum/intel_report/R = new(P.mob, "surveillance", P.mob.real_name, P.mob.job, "CONFIDENTIAL", "D-Class [P.dclass_number] flagged for high suspicion ([P.suspicion_level]/100). Contraband: [length(P.contraband)] items. Escape attempts: [P.escape_attempts].", "Increase surveillance, consider cell search.")
				if(SSraisa)
					SSraisa.file_report(R)
		else if(P.suspicion_level >= 40)
			S.observe()
			if(S.observations % 5 == 0)
				var/datum/intel_report/R = new(P.mob, "surveillance", P.mob.real_name, P.mob.job, "CONFIDENTIAL", "D-Class [P.dclass_number] elevated suspicion ([P.suspicion_level]/100). Monitoring recommended.", "Continue monitoring.")
				if(SSraisa)
					SSraisa.file_report(R)

/proc/process_emergency_shelter_sanity()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD || !H.sanity)
			continue
		var/area/A = get_area(H)
		if(!A)
			continue
		if(istype(A, /area/scp/shelter_alpha) || istype(A, /area/scp/shelter_bravo))
			if(prob(8))
				H.sanity.adjust_sanity(3, "shelter_safety")
				if(prob(20))
					to_chat(H, span_notice("The shelter's reinforced walls provide a sense of security..."))

/datum/controller/subsystem/site_command/proc/generate_status_paper(mob/user)
	var/datum/facility_status_report/R = current_report
	if(!R)
		R = new()
		R.generate()
	var/obj/item/paper/P = new(get_turf(src))
	P.name = "Facility Status Report - [time2text(world.realtime, "YYYY-MM-DD")]"
	P.info = {"<h2>SCP FOUNDATION - FACILITY STATUS REPORT</h2><hr>
<b>Date:</b> [time2text(world.realtime, "YYYY-MM-DD")]<br>
<b>Shift Duration:</b> [round(world.time / 600)] minutes<hr>
<b>SECURITY STATUS</b><br>
Total Breaches: [R.total_breaches] | Active Breaches: [R.active_breaches] | Recontainments: [R.total_recontainments]<br>
Threat Level: [R.security_level] | Comms: [R.comms_status]<hr>
<b>POWER STATUS</b><br>
[R.power_status]<hr>
<b>PERSONNEL STATUS</b><br>
Casualties: [R.casualties] | D-Class Alive: [R.dclass_alive] | D-Class Escaped: [R.dclass_escaped]<hr>
<b>RESEARCH</b><br>
Total Research Points: [R.research_points]<hr>
<b>Report generated by:</b> [user?.real_name || "Automated"]<br>"}
	if(user)
		user.put_in_hands(P)
	return P

/datum/controller/subsystem/foundation_comms/proc/check_threat_escalation()
	if(facility_threat_level >= THREAT_LEVEL_RED && SSsite_command)
		var/has_active = FALSE
		for(var/datum/facility_directive/D in SSsite_command.directives)
			if(D.status == "active" && D.directive_type == "threat_escalation")
				has_active = TRUE
				break
		if(!has_active)
			var/datum/facility_directive/D = new(null, "threat_escalation", "RED THREAT PROTOCOL", "Facility threat level has reached RED. All personnel assume emergency stations. MTF on standby. Containment teams active.", 3, 15 MINUTES)
			SSsite_command.issue_directive(D)
