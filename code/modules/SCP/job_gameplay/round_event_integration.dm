#define RESEARCH_MILESTONE_1 1000
#define RESEARCH_MILESTONE_2 5000
#define RESEARCH_MILESTONE_3 15000
#define RESEARCH_MILESTONE_4 30000
#define RESEARCH_MILESTONE_5 50000

#define BUDGET_THRESHOLD_LOW 0.2
#define BUDGET_THRESHOLD_CRITICAL 0.1

#ifndef ETHICS_VIOLATION_SEVERE
#define ETHICS_VIOLATION_SEVERE 3
#endif

#ifndef DISPATCH_SECURITY
#define DISPATCH_SECURITY 1
#define DISPATCH_MEDICAL 2
#define DISPATCH_ENGINEERING 3
#define DISPATCH_MTF 4
#endif

#ifndef TRIBUNAL_CASE_PENDING
#define TRIBUNAL_CASE_PENDING 0
#define TRIBUNAL_CASE_HEARING 1
#endif

/proc/hook_breach_budget_impact(scp_id)
	if(!SSfoundation_budget)
		return
	var/penalty = 500
	if(findtext(scp_id, "682") || findtext(scp_id, "106"))
		penalty = 3000
	else if(findtext(scp_id, "096") || findtext(scp_id, "049") || findtext(scp_id, "457") || findtext(scp_id, "939"))
		penalty = 1500
	var/datum/department_budget/sec_budget = SSfoundation_budget.department_budgets["security"]
	if(sec_budget)
		sec_budget.spend(min(penalty, sec_budget.remaining), "Emergency breach response: SCP-[scp_id]")
	var/datum/department_budget/med_budget = SSfoundation_budget.department_budgets["medical"]
	if(med_budget)
		med_budget.spend(min(penalty / 3, med_budget.remaining), "Breach medical response: SCP-[scp_id]")

/proc/hook_breach_mtf_auto_deploy(scp_id)
	if(!SSscp_persistence || !SSscp_persistence.manager)
		return
	var/active_breaches = SSscp_persistence?.manager?.active_breaches
	var/is_keter = FALSE
	var/is_biohazard = FALSE
	var/is_fire = FALSE
	if(SSscp_persistence?.manager?.scp_instances?[scp_id])
		var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances[scp_id]
		if(instance.containment_class == SCP_KETER)
			is_keter = TRUE
	if(findtext(scp_id, "008") || findtext(scp_id, "049") || findtext(scp_id, "610"))
		is_biohazard = TRUE
	if(findtext(scp_id, "457"))
		is_fire = TRUE
	var/mtf_team_key
	if(is_keter && active_breaches >= 2)
		mtf_team_key = "mtf_nu7"
	else if(is_biohazard)
		mtf_team_key = "mtf_beta7"
	else if(is_fire)
		mtf_team_key = "mtf_epsilon9"
	else if(active_breaches >= 1)
		mtf_team_key = "mtf_epsilon11"
	if(!mtf_team_key)
		return
	for(var/obj/machinery/mtf_deployment_console/console in world)
		var/list/team_data = console.available_teams?[mtf_team_key]
		if(!team_data)
			continue
		if(world.time >= console.deployment_cooldown && active_breaches >= team_data["min_breach"])
			console.deploy_mtf_team(mtf_team_key, team_data, null)
			if(SSfoundation_comms)
				SSfoundation_comms.create_dispatch(null, DISPATCH_MTF, "Automated MTF deployment: [team_data["name"]] dispatched for SCP-[scp_id] breach response.", 2)
		break

/proc/hook_recontainment_budget_recovery(scp_id, list/participants)
	if(!SSfoundation_budget)
		return
	var/recovery = 300
	if(findtext(scp_id, "682") || findtext(scp_id, "106"))
		recovery = 1500
	var/datum/department_budget/sec_budget = SSfoundation_budget.department_budgets["security"]
	if(sec_budget)
		sec_budget.allocate(recovery)
	var/datum/department_budget/sci_budget = SSfoundation_budget.department_budgets["science"]
	if(sci_budget)
		sci_budget.allocate(round(recovery / 2))
	if(participants && length(participants))
		var/datum/department_budget/med_budget = SSfoundation_budget.department_budgets["medical"]
		if(med_budget)
			med_budget.allocate(round(recovery / 4))

/proc/hook_recontainment_security_level_downgrade()
	if(!SSsecurity_level)
		return
	if(SSsecurity_level.current_level <= SEC_LEVEL_GREEN)
		return
	if(!SSscp_persistence || !SSscp_persistence.manager)
		return
	if(SSscp_persistence?.manager?.active_breaches > 0)
		return
	if(SSsecurity_level.current_level == SEC_LEVEL_DELTA)
		set_foundation_security_code(SEC_LEVEL_RED, "All SCPs recontained. Downgrading from Delta.")
	else if(SSsecurity_level.current_level == SEC_LEVEL_RED)
		set_foundation_security_code(SEC_LEVEL_BLUE, "All SCPs recontained. Downgrading from Red.")

/proc/hook_research_milestone_announcement()
	if(!SSscp_research || !SSscp_research.manager)
		return
	var/points = SSscp_research?.manager?.total_research_points
	var/list/thresholds = list(1000, 5000, 15000, 30000, 50000)
	var/list/messages = list(
		"Research Division has achieved 1,000 total research points. Foundation science progresses steadily.",
		"Research Division has achieved 5,000 total research points. Significant contributions to SCP understanding noted.",
		"Research Division has achieved 15,000 total research points. Breakthrough research efforts recognized by Overwatch Command.",
		"Research Division has achieved 30,000 total research points. Advanced containment protocols now available.",
		"Research Division has achieved 50,000 total research points. Overwatch Command commends Site-53 research excellence.",
	)
	var/announced_milestones = 0
	for(var/threshold in thresholds)
		if(points >= threshold)
			announced_milestones++
	var/list/stored_milestones = SSscp_research?.manager?.research_milestones
	if(!stored_milestones["_announced_round_milestones"])
		stored_milestones["_announced_round_milestones"] = 0
	var/prev = stored_milestones["_announced_round_milestones"]
	if(announced_milestones > prev)
		for(var/i in (prev + 1) to announced_milestones)
			if(i <= length(messages))
				priority_announce(messages[i], "Research Milestone", null, ANNOUNCER_DEFAULT)
		stored_milestones["_announced_round_milestones"] = announced_milestones
	if(SSfoundation_budget)
		var/datum/department_budget/sci_budget = SSfoundation_budget.department_budgets["science"]
		if(sci_budget)
			var/bonus = announced_milestones * 500
			if(bonus > 0 && (!stored_milestones["_budget_awarded"] || stored_milestones["_budget_awarded"] < bonus))
				sci_budget.allocate(bonus)
				stored_milestones["_budget_awarded"] = bonus

/proc/hook_budget_threshold_warning()
	if(!SSfoundation_budget)
		return
	for(var/dept_name in SSfoundation_budget.department_budgets)
		var/datum/department_budget/B = SSfoundation_budget.department_budgets[dept_name]
		if(!B || B.allocated == 0)
			continue
		var/ratio = B.remaining / B.allocated
		if(ratio <= BUDGET_THRESHOLD_CRITICAL && B.remaining > 0)
			if(SSfoundation_comms)
				SSfoundation_comms.create_dispatch(null, DISPATCH_SECURITY, "CRITICAL: [capitalize(dept_name)] department budget at [round(ratio * 100)]% remaining. Immediate review required.", 2)
		else if(ratio <= BUDGET_THRESHOLD_LOW)
			if(SSfoundation_comms)
				SSfoundation_comms.create_dispatch(null, DISPATCH_SECURITY, "WARNING: [capitalize(dept_name)] department budget at [round(ratio * 100)]% remaining. Consider reallocation.", 1)

/proc/hook_ethics_violation_escalation()
	if(!SSethics_committee)
		return
	var/pending = SSethics_committee.get_pending_count()
	if(pending >= 5 && SSinternal_tribunal)
		var/has_active = FALSE
		for(var/datum/tribunal_case/C in SSinternal_tribunal.cases)
			if(C.status == TRIBUNAL_CASE_PENDING || C.status == TRIBUNAL_CASE_HEARING)
				has_active = TRUE
				break
		if(!has_active)
			if(SSfoundation_comms)
				SSfoundation_comms.create_dispatch(null, DISPATCH_SECURITY, "Ethics Committee has [pending] pending violations requiring tribunal review. Expedite processing.", 1)

/proc/hook_scp079_network_breach_warning()
	if(!SSit_network)
		return
	if(SSit_network.scp079_network_presence >= 70)
		if(SSfoundation_comms)
			SSfoundation_comms.create_dispatch(null, DISPATCH_SECURITY, "CRITICAL: SCP-079 network influence at [SSit_network.scp079_network_presence]%. Immediate countermeasures required.", 2)
		if(SSraisa)
			var/datum/info_breach/IB = new("SCP-079 Critical Network Intrusion", "SCP-079", "Facility-wide network systems", 3)
			SSraisa.register_breach(IB)
	else if(SSit_network.scp079_network_presence >= 40)
		if(SSfoundation_comms)
			SSfoundation_comms.create_dispatch(null, DISPATCH_SECURITY, "WARNING: SCP-079 network influence at [SSit_network.scp079_network_presence]%. Monitor and counter.", 1)

/proc/hook_death_toll_warning()
	if(!SSraisa)
		return
	var/incident_count = 0
	for(var/datum/surveillance_subject/S in SSraisa.subjects)
		incident_count += S.incidents
	if(incident_count >= 10)
		if(SSfoundation_comms)
			SSfoundation_comms.create_dispatch(null, DISPATCH_SECURITY, "HIGH CASUALTY ALERT: [incident_count] incidents recorded this shift. Overwatch Command monitoring situation.", 2)
		if(SSethics_committee)
			var/datum/ethics_violation/V = new(null, null, "Facility Operations", "[incident_count] incidents recorded this shift. Automated safety review triggered.", ETHICS_VIOLATION_SEVERE)
			V.reporter_name = "System Safety Monitor"
			V.accused_name = "Facility Operations"
			SSethics_committee.file_violation(V)

SUBSYSTEM_DEF(scp_event_integration)
	name = "SCP Event Integration"
	wait = 60 SECONDS
	priority = FIRE_PRIORITY_DEFAULT
	var/last_budget_warning = 0
	var/last_079_warning = 0
	var/last_death_toll_warning = 0
	var/last_ethics_check = 0
	var/last_research_milestone_check = 0
	var/last_integrity_check = 0
	var/last_ventilation_check = 0
	var/last_testing_check = 0
	var/last_supply_check = 0

/datum/controller/subsystem/scp_event_integration/fire()
	if(world.time - last_research_milestone_check >= 2 MINUTES)
		hook_research_milestone_announcement()
		last_research_milestone_check = world.time

	if(world.time - last_budget_warning >= 3 MINUTES)
		hook_budget_threshold_warning()
		last_budget_warning = world.time

	if(world.time - last_ethics_check >= 5 MINUTES)
		hook_ethics_violation_escalation()
		last_ethics_check = world.time

	if(world.time - last_079_warning >= 2 MINUTES)
		hook_scp079_network_breach_warning()
		last_079_warning = world.time

	if(world.time - last_death_toll_warning >= 5 MINUTES)
		hook_death_toll_warning()
		last_death_toll_warning = world.time

	if(world.time - last_integrity_check >= 3 MINUTES)
		hook_containment_integrity_warning()
		last_integrity_check = world.time

	if(world.time - last_ventilation_check >= 2 MINUTES)
		hook_ventilation_contamination_warning()
		last_ventilation_check = world.time

	if(world.time - last_testing_check >= 5 MINUTES)
		hook_testing_ethics_review()
		last_testing_check = world.time

	if(world.time - last_supply_check >= 3 MINUTES)
		hook_supply_status_warning()
		last_supply_check = world.time

/proc/hook_containment_integrity_warning()
	if(!SScontainment_integrity)
		return
	var/critical_zones = 0
	var/low_zones = 0
	for(var/list/Z in SScontainment_integrity.containment_zones)
		if(Z["breached"])
			critical_zones++
		else if(Z["integrity"] <= 50)
			low_zones++
	if(critical_zones > 0 || low_zones >= 2)
		if(SSfoundation_comms)
			SSfoundation_comms.create_dispatch(null, DISPATCH_ENGINEERING, "CONTAINMENT INTEGRITY: [critical_zones ? "[critical_zones] BREACHED" : ""] [low_zones ? "[low_zones] zones critical integrity" : ""]. Engineering response required immediately.", 2)
	if(SScontainment_integrity.overdue_tasks >= 3)
		if(SSfoundation_comms)
			SSfoundation_comms.create_dispatch(null, DISPATCH_ENGINEERING, "[SScontainment_integrity.overdue_tasks] maintenance tasks overdue. Schedule repairs immediately.", 1)

/proc/hook_ventilation_contamination_warning()
	if(!SSzone_ventilation)
		return
	for(var/list/Z in SSzone_ventilation.ventilation_zones)
		if(Z["contamination"] >= 30 && !Z["purge_active"])
			if(SSfoundation_comms)
				SSfoundation_comms.create_dispatch(null, DISPATCH_ENGINEERING, "Air quality alert: [Z["name"]] contamination at [round(Z["contamination"])]%. Ventilation purge recommended.", 1)
		if(Z["filter_integrity"] <= 30)
			if(SSfoundation_comms)
				SSfoundation_comms.create_dispatch(null, DISPATCH_ENGINEERING, "Filter replacement needed: [Z["name"]] filter integrity at [round(Z["filter_integrity"])]%.", 1)

/proc/hook_testing_ethics_review()
	if(!SSscp_testing)
		return
	var/pending = 0
	for(var/list/P in SSscp_testing.test_proposals)
		if(P["ethics_required"] && P["status"] == 0)
			pending++
	if(pending >= 3 && SSethics_committee)
		if(SSfoundation_comms)
			SSfoundation_comms.create_dispatch(null, 1, "[pending] SCP test proposals awaiting ethics review. Ethics Committee should review pending proposals.", 1)

/proc/hook_supply_status_warning()
	if(!SSscp_supply)
		return
	var/pending = length(SSscp_supply.requisition_queue)
	var	screening = length(SSscp_supply.screening_queue)
	if(screening >= 2)
		if(SSfoundation_comms)
			SSfoundation_comms.create_dispatch(null, 1, "[screening] anomalous shipments awaiting security screening. Clearance required for delivery.", 1)
	if(pending >= 5)
		if(SSfoundation_comms)
			SSfoundation_comms.create_dispatch(null, 1, "[pending] supply requisitions pending approval. Departments awaiting equipment deliveries.", 1)
