#ifndef SCP_TEST_PENDING
#define SCP_TEST_PENDING 0
#define SCP_TEST_APPROVED 1
#define SCP_TEST_IN_PROGRESS 2
#define SCP_TEST_COMPLETE 3
#define SCP_TEST_REJECTED 4
#endif

SUBSYSTEM_DEF(scp_testing)
	name = "SCP Testing Protocol"
	wait = 30 SECONDS
	flags = SS_NO_FIRE

	var/list/test_proposals = list()
	var/list/active_tests = list()
	var/list/completed_tests = list()
	var/list/researcher_stats = list()
	var/total_tests_conducted = 0
	var/total_research_earned = 0
	var/total_incidents_during_tests = 0
	var/total_ethics_violations_from_tests = 0

/datum/controller/subsystem/scp_testing/Initialize(start_timeofday)
	. = ..()
	auto_approve_low_risk()

/datum/controller/subsystem/scp_testing/proc/submit_test_proposal(mob/living/carbon/human/researcher, scp_id, test_type, risk_level, subject_name, description)
	if(!ishuman(researcher) || !scp_id || !test_type)
		return null
	risk_level = clamp(risk_level, 1, 5)
	var/proposal_id = "test_[world.time]_[rand(100,999)]"
	var/ethics_required = risk_level >= 3
	var/list/proposal = list(
		"proposal_id" = proposal_id,
		"researcher" = researcher.real_name,
		"researcher_ckey" = researcher.ckey,
		"scp_id" = scp_id,
		"test_type" = test_type,
		"risk_level" = risk_level,
		"subject_name" = subject_name,
		"description" = description,
		"status" = SCP_TEST_PENDING,
		"ethics_required" = ethics_required,
		"time_submitted" = world.time,
		"time_approved" = 0,
		"time_completed" = 0,
		"outcome" = "",
		"research_points" = 0,
	)
	test_proposals[proposal_id] = proposal
	var/list/stats = get_researcher_stats(researcher.ckey)
	stats["total_proposals"]++
	stats["last_active"] = world.time
	if(ethics_required)
		if(SSethics_committee)
			SSethics_committee.flag_test_for_oversight(proposal_id, scp_id, researcher.real_name, risk_level)
			SSethics_committee.active_test_oversights[proposal_id] = list(
				"test_id" = proposal_id,
				"scp_name" = scp_id,
				"researcher" = researcher.real_name,
				"risk_level" = risk_level,
				"flagged_time" = world.time,
				"approved" = FALSE,
				"denied" = FALSE,
			)
	else
		proposal["status"] = SCP_TEST_APPROVED
		proposal["time_approved"] = world.time
		to_chat(researcher, span_notice("Test proposal [proposal_id] has been auto-approved (low risk)."))
	return proposal_id

/datum/controller/subsystem/scp_testing/proc/approve_proposal(proposal_id, approved_by)
	if(!test_proposals[proposal_id])
		return FALSE
	var/list/proposal = test_proposals[proposal_id]
	if(proposal["status"] != SCP_TEST_PENDING)
		return FALSE
	proposal["status"] = SCP_TEST_APPROVED
	proposal["time_approved"] = world.time
	if(proposal["ethics_required"] && SSethics_committee)
		SSethics_committee.approve_test(proposal_id)
	var/researcher_ckey = proposal["researcher_ckey"]
	for(var/mob/living/carbon/human/H in GLOB.mob_list)
		if(H.ckey == researcher_ckey)
			to_chat(H, span_notice("Your test proposal [proposal_id] for [proposal["scp_id"]] has been approved by [approved_by]."))
			break
	return TRUE

/datum/controller/subsystem/scp_testing/proc/reject_proposal(proposal_id, reason)
	if(!test_proposals[proposal_id])
		return FALSE
	var/list/proposal = test_proposals[proposal_id]
	if(proposal["status"] != SCP_TEST_PENDING && proposal["status"] != SCP_TEST_APPROVED)
		return FALSE
	proposal["status"] = SCP_TEST_REJECTED
	proposal["outcome"] = "Rejected: [reason]"
	if(proposal["ethics_required"] && SSethics_committee)
		SSethics_committee.deny_test(proposal_id)
	var/researcher_ckey = proposal["researcher_ckey"]
	for(var/mob/living/carbon/human/H in GLOB.mob_list)
		if(H.ckey == researcher_ckey)
			to_chat(H, span_warning("Your test proposal [proposal_id] for [proposal["scp_id"]] has been rejected. Reason: [reason]"))
			break
	return TRUE

/datum/controller/subsystem/scp_testing/proc/start_test(proposal_id, mob/living/carbon/human/researcher)
	if(!test_proposals[proposal_id])
		return FALSE
	var/list/proposal = test_proposals[proposal_id]
	if(proposal["status"] != SCP_TEST_APPROVED)
		return FALSE
	if(!ishuman(researcher))
		return FALSE
	var/area/researcher_area = get_area(researcher)
	var/near_scp = FALSE
	if(researcher_area)
		var/area_name = lowertext(researcher_area.name)
		if(findtext(area_name, lowertext(proposal["scp_id"])) || findtext(area_name, "containment") || findtext(area_name, "research") || findtext(area_name, "lab"))
			near_scp = TRUE
	if(!near_scp)
		to_chat(researcher, span_warning("You must be near the SCP containment area or a research lab to start this test."))
		return FALSE
	proposal["status"] = SCP_TEST_IN_PROGRESS
	active_tests[proposal_id] = proposal
	test_proposals -= proposal_id
	var/subject_name = proposal["subject_name"]
	for(var/mob/living/carbon/human/H in GLOB.mob_list)
		if(H.real_name == subject_name || H.name == subject_name)
			to_chat(H, span_warning("You have been selected as a test subject for [proposal["scp_id"]] testing. Report to the containment chamber immediately."))
			break
	to_chat(researcher, span_notice("Test [proposal_id] on [proposal["scp_id"]] is now in progress. Proceed with the test protocol."))
	return TRUE

/datum/controller/subsystem/scp_testing/proc/execute_test(proposal_id, mob/living/carbon/human/researcher)
	if(!active_tests[proposal_id])
		return FALSE
	var/list/proposal = active_tests[proposal_id]
	if(proposal["status"] != SCP_TEST_IN_PROGRESS)
		return FALSE
	if(!ishuman(researcher))
		return FALSE
	var/subject_name = proposal["subject_name"]
	var/mob/living/carbon/human/test_subject = null
	for(var/mob/living/carbon/human/H in GLOB.mob_list)
		if(H.real_name == subject_name || H.name == subject_name)
			test_subject = H
			break
	if(!test_subject || test_subject.stat == DEAD)
		proposal["status"] = SCP_TEST_COMPLETE
		proposal["time_completed"] = world.time
		proposal["outcome"] = "Test subject unavailable or deceased."
		proposal["research_points"] = 0
		completed_tests[proposal_id] = proposal
		active_tests -= proposal_id
		total_tests_conducted++
		to_chat(researcher, span_warning("Test [proposal_id] could not be completed: subject unavailable or deceased."))
		return TRUE
	var/list/outcome = scp_execute_test_outcome(test_subject, proposal["scp_id"], proposal["test_type"], proposal["risk_level"])
	hook_scp_interaction(researcher, proposal["scp_id"], INTERACTION_TYPE_EXPERIMENT)
	proposal["status"] = SCP_TEST_COMPLETE
	proposal["time_completed"] = world.time
	proposal["outcome"] = outcome["message"]
	var/danger_triggered = outcome["danger_triggered"]
	var/points_earned = outcome["research_points"]
	proposal["research_points"] = points_earned
	total_tests_conducted++
	total_research_earned += points_earned
	if(SSscp_research?.manager)
		SSscp_research?.manager?.adjust_research_points(points_earned, "scp_test:[proposal_id]:[researcher.ckey]")
	if(danger_triggered)
		total_incidents_during_tests++
		if(SSscp_medical_response)
			SSscp_medical_response.report_scp_injury(test_subject, "test_injury", proposal["risk_level"], proposal["scp_id"])
		if(proposal["risk_level"] >= 3 && SSethics_committee)
			var/datum/ethics_violation/V = new(researcher, researcher, "Dangerous Test Incident", "Test [proposal_id] on [proposal["scp_id"]] resulted in subject injury during high-risk testing.", ETHICS_VIOLATION_SEVERE)
			SSethics_committee.file_violation(V)
			total_ethics_violations_from_tests++
		priority_announce("Test incident reported: [proposal["scp_id"]] test resulted in subject injury. Researcher: [researcher.real_name].", "TESTING ALERT", null, ANNOUNCER_ALERT)
	else
		to_chat(researcher, span_notice("Test [proposal_id] completed successfully. Research points earned: [points_earned]."))
	var/list/stats = get_researcher_stats(researcher.ckey)
	stats["total_completed"]++
	stats["total_research_earned"] += points_earned
	if(danger_triggered)
		stats["total_incidents"]++
	stats["last_active"] = world.time
	completed_tests[proposal_id] = proposal
	active_tests -= proposal_id
	return TRUE

/datum/controller/subsystem/scp_testing/proc/cancel_test(proposal_id)
	if(!active_tests[proposal_id])
		return FALSE
	var/list/proposal = active_tests[proposal_id]
	if(proposal["status"] != SCP_TEST_IN_PROGRESS)
		return FALSE
	proposal["status"] = SCP_TEST_PENDING
	proposal["time_approved"] = 0
	test_proposals[proposal_id] = proposal
	active_tests -= proposal_id
	var/researcher_ckey = proposal["researcher_ckey"]
	for(var/mob/living/carbon/human/H in GLOB.mob_list)
		if(H.ckey == researcher_ckey)
			to_chat(H, span_warning("Test [proposal_id] has been cancelled and returned to pending status."))
			break
	return TRUE

/datum/controller/subsystem/scp_testing/proc/get_researcher_stats(ckey)
	if(!researcher_stats[ckey])
		researcher_stats[ckey] = list(
			"total_proposals" = 0,
			"total_completed" = 0,
			"total_research_earned" = 0,
			"total_incidents" = 0,
			"last_active" = world.time,
		)
	return researcher_stats[ckey]

/datum/controller/subsystem/scp_testing/proc/get_pending_proposals()
	var/list/result = list()
	for(var/id in test_proposals)
		var/list/P = test_proposals[id]
		if(P["status"] == SCP_TEST_PENDING)
			result[id] = P
	return result

/datum/controller/subsystem/scp_testing/proc/get_active_tests()
	var/list/result = list()
	for(var/id in active_tests)
		var/list/T = active_tests[id]
		if(T["status"] == SCP_TEST_IN_PROGRESS)
			result[id] = T
	return result

/datum/controller/subsystem/scp_testing/proc/get_proposals_by_researcher(ckey)
	var/list/result = list()
	for(var/id in test_proposals)
		var/list/P = test_proposals[id]
		if(P["researcher_ckey"] == ckey)
			result[id] = P
	for(var/id in active_tests)
		var/list/T = active_tests[id]
		if(T["researcher_ckey"] == ckey)
			result[id] = T
	for(var/id in completed_tests)
		var/list/C = completed_tests[id]
		if(C["researcher_ckey"] == ckey)
			result[id] = C
	return result

/datum/controller/subsystem/scp_testing/proc/auto_approve_low_risk()
	var/count = 0
	for(var/id in test_proposals)
		var/list/P = test_proposals[id]
		if(P["status"] == SCP_TEST_PENDING && P["risk_level"] < 3 && !P["ethics_required"])
			P["status"] = SCP_TEST_APPROVED
			P["time_approved"] = world.time
			count++
	return count

/datum/controller/subsystem/scp_testing/proc/check_ethics_override(proposal_id)
	if(!test_proposals[proposal_id])
		return FALSE
	var/list/proposal = test_proposals[proposal_id]
	if(!SSethics_committee)
		return FALSE
	for(var/datum/ethics_violation/V in SSethics_committee.violations)
		if(V.accused_name == proposal["researcher"] && V.status == ETHICS_STATUS_UPHELD && (world.time - V.time_reported) < 10 MINUTES)
			reject_proposal(proposal_id, "Ethics Committee override: active upheld violation against researcher within 10 minutes.")
			return TRUE
	return FALSE


