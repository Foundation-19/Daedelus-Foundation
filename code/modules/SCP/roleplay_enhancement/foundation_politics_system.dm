#define POLICY_CONTAINMENT_PRIORITY "containment_priority"
#define POLICY_RESEARCH_PRIORITY "research_priority"
#define POLICY_SECURITY_CRACKDOWN "security_crackdown"
#define POLICY_MEDICAL_MANDATE "medical_mandate"
#define POLICY_RESOURCE_RATIONING "resource_rationing"
#define POLICY_OPEN_DOORS "open_doors"
#define POLICY_MARTIAL_LAW "martial_law"
#define POLICY_SCIENTIFIC_FREEDOM "scientific_freedom"

#define BUDGET_PURCHASE_EMERGENCY_SUPPLIES "emergency_supplies"
#define BUDGET_PURCHASE_SECURITY_GEAR "security_gear"
#define BUDGET_PURCHASE_MEDICAL_KITS "medical_kits"
#define BUDGET_PURCHASE_RESEARCH_GRANT "research_grant"
#define BUDGET_PURCHASE_FACILITY_REPAIR "facility_repair"
#define BUDGET_PURCHASE_INTELLIGENCE "intelligence"

#define TENSION_LOW 25
#define TENSION_MEDIUM 50
#define TENSION_HIGH 75
#define TENSION_CRITICAL 90

SUBSYSTEM_DEF(foundation_politics)
	name = "Foundation Politics"
	wait = 900
	priority = FIRE_PRIORITY_ROLEPLAY
	init_order = INIT_ORDER_ROLEPLAY
	var/datum/foundation_politics_manager/manager

/datum/controller/subsystem/foundation_politics/Initialize()
	manager = new /datum/foundation_politics_manager()
	return ..()

/datum/controller/subsystem/foundation_politics/fire()
	if(manager)
		manager.process_politics_system()

/datum/foundation_politics_manager
	var/list/departments = list()
	var/list/factions = list()
	var/list/political_events = list()
	var/list/alliances = list()
	var/list/conflicts = list()
	var/total_departments = 0
	var/active_factions = 0
	var/political_tensions = 0
	var/power_balance_score = 50
	var/alliance_network_size = 0
	var/conflict_resolution_rate = 0
	var/last_cycle_time = 0
	var/last_member_recalc = 0
	var/last_tension_check = 0
	var/list/department_job_map = list()
	var/list/faction_department_map = list()
	var/list/active_policies = list()
	var/list/budget_purchase_registry = list()
	var/list/policy_effects = list()

/datum/foundation_politics_manager/New()
	. = ..()
	build_job_department_map()
	build_faction_department_map()
	initialize_departments()
	initialize_factions()
	initialize_budget_purchases()
	initialize_policies()
	last_cycle_time = world.time

/datum/foundation_politics_manager/proc/build_job_department_map()
	department_job_map = list(
		"research" = list(
			JOB_RESEARCH_DIRECTOR, JOB_ASSISTANT_RESEARCH_DIRECTOR, JOB_SENIOR_RESEARCHER, JOB_RESEARCHER,
			JOB_JUNIOR_RESEARCHER, "Lab Technician", "Xenobiologist",
			"Roboticist", "Chemist (Science)", "Archaeologist", "Field Agent"
		),
		"security" = list(
			JOB_GUARD_COMMANDER, JOB_LCZ_ZONE_JUNIOR_LIEUTENANT, JOB_HCZ_ZONE_SENIOR_LIEUTENANT,
			JOB_EZ_ZONE_SUPERVISOR, JOB_LCZ_GUARD, JOB_HCZ_GUARD, JOB_EZ_GUARD,
			JOB_SENIOR_LCZ_GUARD, JOB_SENIOR_HCZ_GUARD, JOB_SENIOR_EZ_GUARD,
			JOB_JUNIOR_LCZ_GUARD, JOB_JUNIOR_HCZ_GUARD, JOB_JUNIOR_EZ_GUARD,
			"MTF Commander", "MTF Operative",
			JOB_RAISA_AGENT, JOB_INVESTIGATIONS_AGENT
		),
		"medical" = list(
			JOB_MEDICAL_DIRECTOR, JOB_ASSISTANT_MEDICAL_DIRECTOR, JOB_MEDICAL_DOCTOR, JOB_SURGEON,
			JOB_PARAMEDIC, JOB_CHEMIST, JOB_VIROLOGIST, JOB_PSYCHOLOGIST,
			JOB_TRAINEE_DOCTOR, "Coroner"
		),
		"engineering" = list(
			JOB_ENGINEERING_DIRECTOR, JOB_ASSISTANT_ENGINEERING_DIRECTOR, JOB_SENIOR_ENGINEER, JOB_ENGINEER,
			JOB_JUNIOR_ENGINEER, JOB_ATMOSPHERIC_TECHNICIAN, JOB_CONTAINMENT_ENGINEER,
			"Electrical Engineer", JOB_IT_TECHNICIAN, "Maintenance Technician"
		),
		"administrative" = list(
			JOB_SITE_DIRECTOR, JOB_HUMAN_RESOURCES_DIRECTOR, JOB_INTERNAL_TRIBUNAL_DEPARTMENT_OFFICER,
			JOB_ETHICS_COMMITTEE_LIAISON, JOB_COMMUNICATIONS_DIRECTOR,
			JOB_LOGISTICS_OFFICER, JOB_LOGISTICS_TECHNICIAN,
			"Lawyer"
		)
	)

/datum/foundation_politics_manager/proc/build_faction_department_map()
	faction_department_map = list(
		"conservative" = list("security", "administrative"),
		"progressive" = list("research", "medical"),
		"militant" = list("security"),
		"scientific" = list("research", "medical"),
		"bureaucratic" = list("engineering", "administrative")
	)

/datum/foundation_politics_manager/proc/initialize_budget_purchases()
	budget_purchase_registry = list(
		BUDGET_PURCHASE_EMERGENCY_SUPPLIES = list("cost" = 5000, "dept_type" = list("security", "medical"), "effect" = "emergency_supplies"),
		BUDGET_PURCHASE_SECURITY_GEAR = list("cost" = 8000, "dept_type" = list("security"), "effect" = "security_gear"),
		BUDGET_PURCHASE_MEDICAL_KITS = list("cost" = 4000, "dept_type" = list("medical"), "effect" = "medical_kits"),
		BUDGET_PURCHASE_RESEARCH_GRANT = list("cost" = 10000, "dept_type" = list("research"), "effect" = "research_grant"),
		BUDGET_PURCHASE_FACILITY_REPAIR = list("cost" = 6000, "dept_type" = list("engineering"), "effect" = "facility_repair"),
		BUDGET_PURCHASE_INTELLIGENCE = list("cost" = 3000, "dept_type" = list("administrative", "security"), "effect" = "intelligence")
	)

/datum/foundation_politics_manager/proc/initialize_policies()
	policy_effects = list(
		POLICY_CONTAINMENT_PRIORITY = list("dept_type" = "security", "effect_type" = "speed_boost", "magnitude" = 0.15, "duration" = 6000),
		POLICY_RESEARCH_PRIORITY = list("dept_type" = "research", "effect_type" = "research_bonus", "magnitude" = 0.20, "duration" = 6000),
		POLICY_SECURITY_CRACKDOWN = list("dept_type" = "security", "effect_type" = "access_expansion", "magnitude" = 1, "duration" = 9000),
		POLICY_MEDICAL_MANDATE = list("dept_type" = "medical", "effect_type" = "heal_bonus", "magnitude" = 0.15, "duration" = 6000),
		POLICY_RESOURCE_RATIONING = list("dept_type" = "administrative", "effect_type" = "budget_efficiency", "magnitude" = 0.30, "duration" = 9000),
		POLICY_OPEN_DOORS = list("dept_type" = "administrative", "effect_type" = "access_expansion", "magnitude" = 1, "duration" = 3000),
		POLICY_MARTIAL_LAW = list("dept_type" = "security", "effect_type" = "combat_boost", "magnitude" = 0.10, "duration" = 3000),
		POLICY_SCIENTIFIC_FREEDOM = list("dept_type" = "research", "effect_type" = "sanity_protection", "magnitude" = 0.25, "duration" = 6000)
	)

/datum/foundation_politics_manager/proc/process_politics_system()
	var/cycle_delta = world.time - last_cycle_time
	last_cycle_time = world.time
	if(world.time - last_member_recalc >= 3000)
		recalculate_department_members()
		recalculate_faction_members()
		last_member_recalc = world.time
	for(var/department_id in departments)
		var/datum/department/dept = departments[department_id]
		if(!dept)
			continue
		dept.process_department_politics()
		if(!dept.is_head_online())
			dept.department_influence = max(0, dept.department_influence - 1)
		process_budget_cycle(dept, cycle_delta)
		notify_head_if_needed(dept)
	process_alliances()
	process_rivalries()
	process_faction_interactions()
	update_power_balance()
	process_conflicts()
	auto_generate_events()
	cleanup_expired_events()
	process_active_policies()
	check_tension_thresholds()

/datum/foundation_politics_manager/proc/process_active_policies()
	var/list/to_remove = list()
	for(var/policy_id in active_policies)
		var/list/policy = active_policies[policy_id]
		if(!policy)
			to_remove += policy_id
			continue
		if(world.time > policy["expiry"])
			revoke_policy(policy_id)
			to_remove += policy_id
	for(var/policy_id in to_remove)
		active_policies -= policy_id

/datum/foundation_politics_manager/proc/enact_policy(dept_id, policy_type)
	if(!dept_id || !policy_type)
		return FALSE
	var/datum/department/dept = departments[dept_id]
	if(!dept)
		return FALSE
	if(!dept.is_head_online())
		return FALSE
	var/list/effect_data = policy_effects[policy_type]
	if(!effect_data)
		return FALSE
	if(effect_data["dept_type"] != dept.department_type)
		return FALSE
	if(policy_type in active_policies)
		return FALSE
	var/cost = 15000
	if(dept.department_budget < cost)
		return FALSE
	dept.department_budget -= cost
	dept.department_budget = max(0, dept.department_budget)
	var/duration = effect_data["duration"] || 6000
	active_policies[policy_type] = list(
		"dept_id" = dept_id,
		"policy_type" = policy_type,
		"effect_type" = effect_data["effect_type"],
		"magnitude" = effect_data["magnitude"],
		"enacted_time" = world.time,
		"expiry" = world.time + duration
	)
	apply_policy_effect(policy_type, TRUE)
	var/mob/M = dept.get_head_mob()
	if(M)
		to_chat(M, "<span class='notice'>Policy [policy_type] enacted for [dept.department_name]! Cost: [cost]. Duration: [round(duration/600)] minutes.</span>")
	priority_announce("POLICY UPDATE: [dept.department_name] has enacted [replacetext(policy_type, "_", " ")]. All personnel take note.", null, null, ANNOUNCER_DEFAULT)
	create_political_event("policy_change", "Policy Enacted: [policy_type]", "[dept.department_name] enacted [policy_type].", list(dept_id), 10)
	return TRUE

/datum/foundation_politics_manager/proc/revoke_policy(policy_type)
	if(!(policy_type in active_policies))
		return
	var/list/policy = active_policies[policy_type]
	if(!policy)
		return
	apply_policy_effect(policy_type, FALSE)
	var/datum/department/dept = departments[policy["dept_id"]]
	if(dept)
		var/mob/M = dept.get_head_mob()
		if(M)
			to_chat(M, "<span class='warning'>Policy [policy_type] has expired.</span>")

/datum/foundation_politics_manager/proc/apply_policy_effect(policy_type, applying)
	var/list/policy = active_policies[policy_type]
	if(!policy)
		return
	var/effect_type = policy["effect_type"]
	var/magnitude = policy["magnitude"]
	var/dept_id = policy["dept_id"]
	var/datum/department/dept = departments[dept_id]
	if(!dept)
		return
	switch(effect_type)
		if("speed_boost")
			for(var/ckey in dept.department_members)
				var/mob/living/carbon/human/H = dept.get_mob_by_ckey(ckey)
				if(!H || QDELETED(H) || H.stat == DEAD)
					continue
				if(applying)
					H.add_movespeed_modifier(/datum/movespeed_modifier/policy_speed)
				else
					H.remove_movespeed_modifier(/datum/movespeed_modifier/policy_speed)
		if("research_bonus")
			if(applying)
				dept._research_multiplier = 1 + magnitude
			else
				dept._research_multiplier = 1
		if("access_expansion")
			for(var/ckey in dept.department_members)
				var/mob/living/carbon/human/H = dept.get_mob_by_ckey(ckey)
				if(!H || QDELETED(H) || H.stat == DEAD)
					continue
				var/obj/item/card/id/id_card = H.get_idcard(TRUE)
				if(!id_card)
					continue
				if(applying)
					var/list/grant = list(ACCESS_SCIENCE, ACCESS_MEDICAL) - id_card.access
					if(length(grant))
						id_card.add_access(grant)
						LAZYSET(dept._granted_access, ckey, grant)
				else
					var/list/granted = dept._granted_access?[ckey]
					if(length(granted))
						id_card.remove_access(granted)
						LAZYREMOVE(dept._granted_access, ckey)
		if("heal_bonus")
			if(applying)
				dept._heal_multiplier = 1 + magnitude
			else
				dept._heal_multiplier = 1
		if("budget_efficiency")
			if(applying)
				dept._budget_efficiency = 1 + magnitude
			else
				dept._budget_efficiency = 1
		if("combat_boost")
			for(var/ckey in dept.department_members)
				var/mob/living/carbon/human/H = dept.get_mob_by_ckey(ckey)
				if(!H || QDELETED(H) || H.stat == DEAD)
					continue
				if(applying)
					H.add_movespeed_modifier(/datum/movespeed_modifier/policy_combat)
				else
					H.remove_movespeed_modifier(/datum/movespeed_modifier/policy_combat)
		if("sanity_protection")
			if(applying)
				dept._sanity_protection = magnitude
			else
				dept._sanity_protection = 0

/datum/movespeed_modifier/policy_speed
	slowdown = -0.3

/datum/movespeed_modifier/policy_combat
	slowdown = -0.2

/datum/foundation_politics_manager/proc/execute_budget_purchase(dept_id, purchase_type)
	if(!dept_id || !purchase_type)
		return FALSE
	var/datum/department/dept = departments[dept_id]
	if(!dept)
		return FALSE
	var/list/purchase_data = budget_purchase_registry[purchase_type]
	if(!purchase_data)
		return FALSE
	if(!(dept.department_type in purchase_data["dept_type"]))
		return FALSE
	var/cost = purchase_data["cost"]
	var/efficiency = dept._budget_efficiency || 1
	var/actual_cost = round(cost / efficiency)
	if(dept.department_budget < actual_cost)
		return FALSE
	dept.department_budget -= actual_cost
	dept.department_budget = max(0, dept.department_budget)
	switch(purchase_data["effect"])
		if("emergency_supplies")
			var/list/possible_areas = list()
			for(var/area/A in get_sorted_areas())
				if(istype(A, /area/scp/))
					possible_areas += A
			var/area/target_area = null
			if(length(possible_areas))
				target_area = pick(possible_areas)
				var/turf/spawn_turf = pick(target_area.get_contained_turfs())
				new /obj/item/storage/medkit/regular(spawn_turf)
				new /obj/item/storage/medkit/fire(spawn_turf)
				new /obj/item/flashlight/seclite(spawn_turf)
			for(var/ckey in dept.department_members)
				var/mob/living/carbon/human/H = dept.get_mob_by_ckey(ckey)
				if(H && !QDELETED(H) && H.stat != DEAD)
					to_chat(H, "<span class='notice'>Emergency supplies delivered to [target_area ? target_area.name : "facility"]. Budget spent: [actual_cost]</span>")
		if("security_gear")
			for(var/ckey in dept.department_members)
				var/mob/living/carbon/human/H = dept.get_mob_by_ckey(ckey)
				if(!H || QDELETED(H) || H.stat == DEAD)
					continue
				if(H.job && (H.job == JOB_LCZ_GUARD || H.job == JOB_HCZ_GUARD || H.job == JOB_EZ_GUARD))
					var/obj/item/storage/box/box = new(get_turf(H))
					new /obj/item/restraints/handcuffs(box)
					new /obj/item/assembly/flash(box)
					new /obj/item/melee/baton(box)
					to_chat(H, "<span class='notice'>Security gear delivered. Budget spent: [actual_cost]</span>")
		if("medical_kits")
			for(var/ckey in dept.department_members)
				var/mob/living/carbon/human/H = dept.get_mob_by_ckey(ckey)
				if(!H || QDELETED(H) || H.stat == DEAD)
					continue
				if(H.job && (H.job == JOB_MEDICAL_DOCTOR || H.job == JOB_SURGEON || H.job == JOB_PARAMEDIC))
					new /obj/item/storage/medkit/advanced(get_turf(H))
					new /obj/item/reagent_containers/hypospray/medipen(get_turf(H))
					to_chat(H, "<span class='notice'>Medical supplies delivered. Budget spent: [actual_cost]</span>")
		if("research_grant")
			if(SSscp_research && SSscp_research.manager)
				adjust_global_research_points(2000, "politics_research_grant")
			for(var/ckey in dept.department_members)
				var/mob/living/carbon/human/H = dept.get_mob_by_ckey(ckey)
				if(H && !QDELETED(H) && H.stat != DEAD)
					to_chat(H, "<span class='notice'>Research grant issued! +2000 research points. Budget spent: [actual_cost]</span>")
		if("facility_repair")
			var/repaired = 0
			for(var/obj/machinery/power/apc/A as anything in INSTANCES_OF(/obj/machinery/power/apc))
				if(QDELETED(A))
					continue
				if(A.machine_stat & BROKEN)
					A.set_machine_stat(A.machine_stat & ~BROKEN)
					A.update_appearance()
					repaired++
					if(repaired >= 5)
						break
			for(var/ckey in dept.department_members)
				var/mob/living/carbon/human/H = dept.get_mob_by_ckey(ckey)
				if(H && !QDELETED(H) && H.stat != DEAD)
					to_chat(H, "<span class='notice'>Facility repair team dispatched! [repaired] APCs repaired. Budget spent: [actual_cost]</span>")
		if("intelligence")
			var/list/breach_info = list()
			if(SSscp_persistence && SSscp_persistence.manager)
				for(var/scp_id in SSscp_persistence.manager.scp_instances)
					var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[scp_id]
					if(instance && instance.containment_status == "breached")
						var/area/scp_area = null
						for(var/mob/living/scp/S as anything in INSTANCES_OF(/mob/living/scp))
							if(!QDELETED(S) && S.persistence_id == scp_id)
								scp_area = get_area(S)
								break
						breach_info += "[scp_id]: last seen in [scp_area ? scp_area.name : "unknown"]"
			if(length(breach_info))
				for(var/ckey in dept.department_members)
					var/mob/living/carbon/human/H = dept.get_mob_by_ckey(ckey)
					if(H && !QDELETED(H) && H.stat != DEAD)
						to_chat(H, "<span class='notice'>Intelligence report acquired: [english_list(breach_info)]. Budget spent: [actual_cost]</span>")
			else
				for(var/ckey in dept.department_members)
					var/mob/living/carbon/human/H = dept.get_mob_by_ckey(ckey)
					if(H && !QDELETED(H) && H.stat != DEAD)
						to_chat(H, "<span class='notice'>Intelligence report: All SCPs currently contained. Budget spent: [actual_cost]</span>")
	create_political_event("expenditure", "Budget: [purchase_type]", "[dept.department_name] purchased [purchase_type] for [actual_cost].", list(dept_id), -5)
	return TRUE

/datum/foundation_politics_manager/proc/check_tension_thresholds()
	if(world.time - last_tension_check < 3000)
		return
	last_tension_check = world.time
	if(political_tensions >= TENSION_CRITICAL)
		if(prob(10))
			priority_announce("WARNING: Political tensions in the facility have reached critical levels. Department heads, resolve your conflicts immediately.", null, null, ANNOUNCER_ALERT)
		if(SSsecurity_level && SSsecurity_level.current_level < SEC_LEVEL_RED && prob(5))
			set_foundation_security_code(SEC_LEVEL_RED, "Political tension escalation")
			priority_announce("ELEVATED ALERT: Facility political tensions have triggered automatic security escalation.", null, null, ANNOUNCER_ALERT)
	else if(political_tensions >= TENSION_HIGH)
		if(prob(5))
			var/alert_msg = pick("Inter-departmental friction is impacting operations.", "Political tensions are rising. Heads of staff, coordinate.", "Facility stability is degrading due to political disputes.")
			priority_announce("ADVISORY: [alert_msg]", null, null, ANNOUNCER_DEFAULT)
	else if(political_tensions >= TENSION_MEDIUM)
		if(prob(3))
			for(var/dept_id in departments)
				var/datum/department/dept = departments[dept_id]
				if(dept && dept.is_head_online() && length(dept.department_rivals) > 0)
					var/mob/M = dept.get_head_mob()
					if(M)
						to_chat(M, "<span class='warning'>Your department's political tensions are elevated. Consider diplomacy with rival departments.</span>")
	if(political_tensions <= TENSION_LOW)
		if(prob(5))
			priority_announce("STATUS: Facility political tensions are low. All departments operating smoothly.", null, null, ANNOUNCER_DEFAULT)

/datum/foundation_politics_manager/proc/notify_head_if_needed(datum/department/dept)
	if(!dept)
		return
	var/mob/M = dept.get_head_mob()
	if(!M)
		return
	if(dept.department_budget <= 0 && !dept._budget_warning_issued)
		dept._budget_warning_issued = TRUE
		to_chat(M, "<span class='warning'>[dept.department_name] budget is depleted! Operations are at risk.</span>")
	else if(dept.department_budget > 5000)
		dept._budget_warning_issued = FALSE
	if(dept.goals_completed_this_round > 0 && !dept._recent_goal_event)
		dept._recent_goal_event = TRUE
		to_chat(M, "<span class='notice'>[dept.department_name] has completed [dept.goals_completed_this_round] goal(s) this shift. Use the Politics console to review.</span>")

/datum/foundation_politics_manager/proc/recalculate_department_members()
	for(var/department_id in departments)
		var/datum/department/dept = departments[department_id]
		if(!dept)
			continue
		dept.department_members = list()
		var/list/jobs = department_job_map[department_id]
		if(!jobs)
			continue
		for(var/mob/living/carbon/human/H in GLOB.player_list)
			if(QDELETED(H))
				continue
			if(H.stat == DEAD)
				continue
			if(!H.ckey || !H.job)
				continue
			if(H.job in jobs)
				dept.department_members[H.ckey] = H.job

/datum/foundation_politics_manager/proc/recalculate_faction_members()
	for(var/faction_id in factions)
		var/datum/faction/fac = factions[faction_id]
		if(!fac)
			continue
		fac.faction_members = list()
		var/list/dept_ids = faction_department_map[faction_id]
		if(!dept_ids)
			continue
		for(var/dept_id in dept_ids)
			var/datum/department/dept = departments[dept_id]
			if(!dept)
				continue
			for(var/ckey in dept.department_members)
				fac.faction_members[ckey] = dept_id
		fac.faction_membership = length(fac.faction_members)

/datum/foundation_politics_manager/proc/process_budget_cycle(datum/department/dept, cycle_delta)
	if(!dept)
		return
	if(cycle_delta <= 0)
		return
	var/cycles_elapsed = cycle_delta / 900
	var/efficiency = dept._budget_efficiency || 1
	dept.accumulated_budget_from_members += length(dept.department_members) * 500 * efficiency * cycles_elapsed
	if(dept.accumulated_budget_from_members >= 500)
		var/grant = round(dept.accumulated_budget_from_members)
		dept.department_budget += grant
		dept.accumulated_budget_from_members -= grant
	for(var/alliance_id in alliances)
		var/list/alliance_data = alliances[alliance_id]
		if(!alliance_data)
			continue
		var/list/members = alliance_data["members"]
		if(!members)
			continue
		if(!(dept.department_id in members))
			continue
		var/other_count = length(members) - 1
		if(other_count <= 0)
			continue
		var/share_per_ally = round(dept.department_budget * 0.25 / other_count * cycles_elapsed)
		if(share_per_ally <= 0)
			continue
		var/total_shared = share_per_ally * other_count
		dept.department_budget -= total_shared
		dept.department_budget = max(0, dept.department_budget)
		for(var/other_id in members)
			if(other_id == dept.department_id)
				continue
			var/datum/department/other_dept = departments[other_id]
			if(other_dept)
				other_dept.department_budget += share_per_ally
	var/maintenance = round(dept.department_budget * 0.05 * cycles_elapsed)
	dept.department_budget -= maintenance
	dept.department_budget = max(0, dept.department_budget)
	if(dept.department_budget <= 0)
		dept.department_status = "under_review"
		dept.department_influence = max(0, dept.department_influence - 5)
	else if(dept.department_status == "under_review")
		dept.department_status = "active"

/datum/foundation_politics_manager/proc/spend_budget(dept_id, amount, reason)
	if(!dept_id || amount <= 0)
		return FALSE
	var/datum/department/dept = departments[dept_id]
	if(!dept)
		return FALSE
	if(dept.department_budget < amount)
		return FALSE
	dept.department_budget -= amount
	dept.department_budget = max(0, dept.department_budget)
	create_political_event("expenditure", "Budget Allocation: [reason]", "[dept.department_name] spent [amount] credits on: [reason]", list(dept_id), -5)
	return TRUE

/datum/foundation_politics_manager/proc/process_alliances()
	alliance_network_size = 0
	var/list/processed = list()
	for(var/alliance_id in alliances)
		var/list/alliance_data = alliances[alliance_id]
		if(!alliance_data)
			continue
		var/list/members = alliance_data["members"]
		if(!members || length(members) < 2)
			alliances -= alliance_id
			continue
		alliance_network_size += length(members)
		var/strength = alliance_data["strength"] || 50
		for(var/dept_id in members)
			if(processed[dept_id])
				continue
			processed[dept_id] = TRUE
			var/datum/department/dept = departments[dept_id]
			if(dept)
				dept.department_influence = min(100, dept.department_influence + (strength / 100))
		for(var/faction_id in factions)
			var/datum/faction/fac = factions[faction_id]
			if(!fac)
				continue
			var/faction_member_count = 0
			for(var/dept_id in members)
				if(dept_id in (faction_department_map[faction_id] || list()))
					faction_member_count++
			if(faction_member_count >= 2 && !(alliance_id in fac.faction_allies))
				fac.faction_allies += alliance_id

/datum/foundation_politics_manager/proc/process_rivalries()
	for(var/department_id in departments)
		var/datum/department/dept = departments[department_id]
		if(!dept)
			continue
		for(var/rival_id in dept.department_rivals)
			var/datum/department/rival = departments[rival_id]
			if(!rival)
				dept.department_rivals -= rival_id
				continue
			var/influence_diff = dept.department_influence - rival.department_influence
			if(influence_diff > 0)
				var/budget_shift = round(abs(influence_diff) * 5)
				dept.department_budget += budget_shift
				rival.department_budget -= budget_shift
			else if(influence_diff < 0)
				var/budget_shift = round(abs(influence_diff) * 5)
				rival.department_budget += budget_shift
				dept.department_budget -= budget_shift
			dept.department_budget = max(0, dept.department_budget)
			rival.department_budget = max(0, rival.department_budget)

/datum/foundation_politics_manager/proc/process_faction_interactions()
	for(var/faction_id in factions)
		var/datum/faction/fac = factions[faction_id]
		if(!fac)
			continue
		fac.faction_last_updated = world.time
		update_faction_influence(fac)
		for(var/enemy_id in fac.faction_enemies)
			var/datum/faction/enemy = factions[enemy_id]
			if(!enemy)
				fac.faction_enemies -= enemy_id
				continue
			if(check_faction_ideology_clash(fac, enemy))
				if(prob(15))
					maybe_create_conflict(fac.department_id_representation(), enemy.department_id_representation(), "ideological_clash")

/datum/faction/proc/department_id_representation()
	if(faction_type == "conservative" || faction_type == "militant")
		return "security"
	if(faction_type == "progressive" || faction_type == "scientific")
		return "research"
	if(faction_type == "bureaucratic")
		return "engineering"
	return "administrative"

/datum/foundation_politics_manager/proc/check_faction_ideology_clash(datum/faction/a, datum/faction/b)
	if(!a || !b)
		return FALSE
	if(a.faction_type == "conservative" && (b.faction_type == "progressive" || b.faction_type == "scientific"))
		return TRUE
	if(a.faction_type == "militant" && b.faction_type == "bureaucratic")
		return TRUE
	if(a.faction_type == "progressive" && b.faction_type == "conservative")
		return TRUE
	if(a.faction_type == "scientific" && b.faction_type == "militant")
		return TRUE
	return FALSE

/datum/foundation_politics_manager/proc/maybe_create_conflict(dept_id_a, dept_id_b, reason)
	if(!dept_id_a || !dept_id_b || dept_id_a == dept_id_b)
		return
	for(var/existing_id in conflicts)
		var/list/existing = conflicts[existing_id]
		if(!existing)
			continue
		var/list/parties = existing["parties"]
		if(parties && length(parties) >= 2)
			if((dept_id_a in parties) && (dept_id_b in parties) && existing["type"] == reason)
				return
	var/conflict_id = "conflict_[world.time]_[dept_id_a]_[dept_id_b]"
	conflicts[conflict_id] = list(
		"id" = conflict_id,
		"title" = "Conflict: [dept_id_a] vs [dept_id_b]",
		"type" = reason,
		"description" = "Tension between [dept_id_a] and [dept_id_b] over [reason]",
		"severity" = 50,
		"parties" = list(dept_id_a, dept_id_b),
		"creation_time" = world.time,
		"resolved" = FALSE
	)
	var/datum/department/dept_a = departments[dept_id_a]
	var/datum/department/dept_b = departments[dept_id_b]
	if(dept_a && !(dept_id_b in dept_a.department_rivals))
		dept_a.department_rivals += dept_id_b
	if(dept_b && !(dept_id_a in dept_b.department_rivals))
		dept_b.department_rivals += dept_id_a
	political_tensions = min(100, political_tensions + 10)
	var/mob/MA = dept_a?.get_head_mob()
	var/mob/MB = dept_b?.get_head_mob()
	if(MA)
		to_chat(MA, "<span class='warning'>Political conflict with [dept_b?.department_name || dept_id_b]: [reason]</span>")
	if(MB)
		to_chat(MB, "<span class='warning'>Political conflict with [dept_a?.department_name || dept_id_a]: [reason]</span>")

/datum/department
	var/department_id = ""
	var/department_name = ""
	var/department_type = ""
	var/department_head = ""
	var/department_budget = 0
	var/department_influence = 50
	var/department_status = "active"
	var/list/department_members = list()
	var/list/department_policies = list()
	var/list/department_allies = list()
	var/list/department_rivals = list()
	var/list/department_goals = list()
	var/list/department_achievements = list()
	var/department_creation_date = 0
	var/department_last_updated = 0
	var/accumulated_budget_from_members = 0
	var/goals_completed_this_round = 0
	var/influence_metric_value = 0
	var/_recent_goal_event = FALSE
	var/_head_offline_notified = FALSE
	var/_budget_warning_issued = FALSE
	var/_research_multiplier = 1
	var/_heal_multiplier = 1
	var/_budget_efficiency = 1
	var/_sanity_protection = 0
	var/_last_known_budget = 0
	var/list/_granted_access = list()

/datum/department/New(var/id, var/name, var/department_type, var/head)
	department_id = id
	department_name = name
	src.department_type = department_type
	department_head = head
	department_creation_date = world.time
	department_last_updated = world.time

/datum/department/proc/is_head_online()
	if(!department_head)
		return FALSE
	for(var/client/C in GLOB.clients)
		if(C.ckey == department_head)
			var/mob/M = C.mob
			if(M && !QDELETED(M) && M.stat != DEAD)
				return TRUE
	return FALSE

/datum/department/proc/get_head_mob()
	if(!department_head)
		return null
	for(var/client/C in GLOB.clients)
		if(C.ckey == department_head)
			var/mob/M = C.mob
			if(M && !QDELETED(M) && istype(M, /mob/living/carbon/human))
				return M
	return null

/datum/department/proc/assign_head_from_players()
	var/list/jobs = SSfoundation_politics.manager.department_job_map[department_id]
	if(!jobs)
		return
	var/head_job
	switch(department_id)
		if("research")
			head_job = JOB_RESEARCH_DIRECTOR
		if("security")
			head_job = JOB_GUARD_COMMANDER
		if("medical")
			head_job = JOB_MEDICAL_DIRECTOR
		if("engineering")
			head_job = JOB_ENGINEERING_DIRECTOR
		if("administrative")
			head_job = JOB_SITE_DIRECTOR
	if(!head_job)
		return
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.stat == DEAD)
			continue
		if(!H.ckey || !H.job)
			continue
		if(H.job == head_job)
			department_head = H.ckey
			to_chat(H, "<span class='notice'>You are now the head of the [department_name]. Use the Politics console to manage your department.</span>")
			return
	for(var/ckey in department_members)
		var/mob/living/carbon/human/H = get_mob_by_ckey(ckey)
		if(H && !QDELETED(H) && H.stat != DEAD)
			department_head = ckey
			to_chat(H, "<span class='notice'>You are now the head of the [department_name]. Use the Politics console to manage your department.</span>")
			return

/datum/department/proc/get_mob_by_ckey(target_ckey)
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.ckey == target_ckey)
			return H
	return null

/datum/department/proc/process_department_politics()
	department_last_updated = world.time
	if(!department_head || !is_head_online())
		assign_head_from_players()
	calculate_department_influence()
	process_department_goals()

/datum/department/proc/calculate_department_influence()
	var/new_influence = 20
	influence_metric_value = get_influence_metric()
	switch(department_type)
		if("research")
			new_influence += min(30, influence_metric_value / 100)
		if("security")
			new_influence += min(30, influence_metric_value * 5)
		if("medical")
			new_influence += min(30, influence_metric_value * 3)
		if("engineering")
			new_influence += min(30, influence_metric_value * 3)
		if("administrative")
			new_influence += min(30, influence_metric_value * 2)
	new_influence += length(department_members) * 3
	new_influence += min(10, length(department_achievements) * 2)
	new_influence += min(10, length(department_allies) * 2)
	if(is_head_online())
		new_influence += 5
	else
		new_influence -= 5
	if(department_status == "under_review")
		new_influence -= 10
	if(department_budget <= 0)
		new_influence -= 10
	department_influence = clamp(round(new_influence), 0, 100)

/datum/department/proc/get_influence_metric()
	switch(department_type)
		if("research")
			if(SSscp_research && SSscp_research.manager)
				return SSscp_research.manager.total_research_points
			return 0
		if("security")
			if(GLOB.scp_round_report)
				return GLOB.scp_round_report.total_recontainments
			return 0
		if("medical")
			if(SSmedical_persistence && SSmedical_persistence.manager)
				return SSmedical_persistence.manager.total_patients_treated
			return 0
		if("engineering")
			var/repair_count = 0
			for(var/obj/machinery/M as anything in INSTANCES_OF(/obj/machinery))
				if(QDELETED(M))
					continue
				if(M.machine_stat & (BROKEN|EMPED))
					continue
				if(istype(M, /obj/machinery/power/apc) || istype(M, /obj/machinery/atmospherics))
					repair_count++
			return repair_count
		if("administrative")
			var/active_count = 0
			for(var/mob/living/carbon/human/H in GLOB.player_list)
				if(QDELETED(H))
					continue
				if(H.stat != DEAD && H.ckey && H.job)
					active_count++
			return active_count
	return 0

/datum/department/proc/process_department_goals()
	for(var/i in 1 to length(department_goals))
		var/goal = department_goals[i]
		if(check_goal_completion(goal))
			complete_department_goal(goal)
			department_goals[i] = null
	department_goals -= null

/datum/department/proc/check_goal_completion(goal)
	if(!goal)
		return FALSE
	switch(goal)
		if("advance_scp_knowledge")
			if(SSscp_research && SSscp_research.manager)
				return SSscp_research.manager.total_research_points > 0
			return FALSE
		if("maintain_containment")
			if(SSscp_persistence && SSscp_persistence.manager)
				return SSscp_persistence.manager.active_breaches == 0
			return TRUE
		if("provide_medical_care")
			if(SSmedical_persistence && SSmedical_persistence.manager)
				return SSmedical_persistence.manager.total_patients_treated >= 3
			return FALSE
		if("maintain_facility")
			var/functional_count = 0
			var/total_count = 0
			for(var/obj/machinery/power/apc/A as anything in INSTANCES_OF(/obj/machinery/power/apc))
				if(QDELETED(A))
					continue
				total_count++
				if(!(A.machine_stat & BROKEN))
					functional_count++
			if(total_count == 0)
				return TRUE
			return (functional_count / total_count) >= 0.7
		if("manage_resources")
			return department_budget > 0
		if("develop_containment_protocols")
			if(GLOB.scp_round_report)
				return GLOB.scp_round_report.total_recontainments >= 2
			return FALSE
		if("train_security_personnel")
			return length(department_members) >= 3
		if("develop_tactics")
			if(GLOB.scp_round_report)
				return GLOB.scp_round_report.total_recontainments >= 1
			return FALSE
		if("study_scp_effects")
			if(SSscp_research && SSscp_research.manager)
				return SSscp_research.manager.research_breakthroughs >= 1
			return FALSE
		if("develop_treatments")
			if(SSmedical_persistence && SSmedical_persistence.manager)
				return length(SSmedical_persistence.manager.treatment_logs) >= 5
			return FALSE
		if("develop_containment_systems")
			return length(department_achievements) >= 2
		if("improve_infrastructure")
			var/functional_count = 0
			var/total_count = 0
			for(var/obj/machinery/power/apc/A as anything in INSTANCES_OF(/obj/machinery/power/apc))
				if(QDELETED(A))
					continue
				total_count++
				if(!(A.machine_stat & BROKEN))
					functional_count++
			if(total_count == 0)
				return TRUE
			return (functional_count / total_count) >= 0.85
		if("coordinate_departments")
			return length(department_allies) >= 1
		if("maintain_records")
			return length(department_members) >= 2
	return FALSE

/datum/department/proc/complete_department_goal(goal)
	if(!goal)
		return
	department_achievements += goal
	goals_completed_this_round++
	department_budget += 2000
	department_influence = min(100, department_influence + 5)
	var/mob/M = get_head_mob()
	if(M)
		to_chat(M, "<span class='notice'>Department goal '[goal]' completed! Influence increased, budget +2000.</span>")
	if(SSfoundation_politics && SSfoundation_politics.manager)
		SSfoundation_politics.manager.create_political_event("policy_change", "Goal Completed: [goal]", "[department_name] has achieved the goal: [goal]. Influence rises.", list(department_id), 15)

/datum/faction
	var/faction_id = ""
	var/faction_name = ""
	var/faction_type = ""
	var/faction_leader = ""
	var/faction_influence = 50
	var/faction_membership = 0
	var/faction_goals = list()
	var/faction_ideology = ""
	var/list/faction_allies = list()
	var/list/faction_enemies = list()
	var/list/faction_achievements = list()
	var/faction_creation_date = 0
	var/faction_last_updated = 0
	var/list/faction_members = list()

/datum/faction/New(var/id, var/name, var/type, var/leader)
	faction_id = id
	faction_name = name
	faction_type = type
	faction_leader = leader
	faction_creation_date = world.time
	faction_last_updated = world.time

/datum/foundation_politics_manager/proc/create_political_event(event_type, title, description, list/participants, impact)
	if(!event_type || !title)
		return null
	var/event_id = "event_[world.time]_[rand(100,999)]"
	var/datum/political_event/new_event = new /datum/political_event(event_id, event_type, title, description)
	new_event.event_participants = participants ? participants.Copy() : list()
	new_event.event_impact = impact || 0
	political_events[event_id] = new_event
	return new_event

/datum/foundation_politics_manager/proc/update_faction_influence(datum/faction/faction)
	if(!faction)
		return
	var/new_influence = 20
	new_influence += faction.faction_membership * 3
	new_influence += length(faction.faction_achievements) * 5
	new_influence += length(faction.faction_allies) * 3
	var/list/dept_ids = faction_department_map[faction.faction_id]
	if(dept_ids)
		var/total_dept_influence = 0
		var/dept_count = 0
		for(var/dept_id in dept_ids)
			var/datum/department/dept = departments[dept_id]
			if(dept)
				total_dept_influence += dept.department_influence
				dept_count++
		if(dept_count > 0)
			new_influence += round(total_dept_influence / dept_count) * 0.3
	faction.faction_influence = clamp(round(new_influence), 0, 100)

/datum/foundation_politics_manager/proc/update_power_balance()
	var/total_influence = 0
	var/influence_count = 0
	for(var/dept_id in departments)
		var/datum/department/dept = departments[dept_id]
		if(dept)
			total_influence += dept.department_influence
			influence_count++
	for(var/faction_id in factions)
		var/datum/faction/faction = factions[faction_id]
		if(faction)
			total_influence += faction.faction_influence
			influence_count++
	if(influence_count > 0)
		power_balance_score = round(total_influence / influence_count)
	calculate_political_tensions()

/datum/foundation_politics_manager/proc/calculate_political_tensions()
	political_tensions = 0
	political_tensions += length(conflicts) * 10
	for(var/dept_id in departments)
		var/datum/department/dept = departments[dept_id]
		if(dept)
			political_tensions += length(dept.department_rivals) * 5
	for(var/faction_id in factions)
		var/datum/faction/faction = factions[faction_id]
		if(faction)
			political_tensions += length(faction.faction_enemies) * 5
	political_tensions = clamp(political_tensions, 0, 100)

/datum/foundation_politics_manager/proc/process_conflicts()
	var/list/to_remove = list()
	for(var/conflict_id in conflicts)
		var/list/conflict_data = conflicts[conflict_id]
		if(!conflict_data)
			to_remove += conflict_id
			continue
		if(conflict_data["resolved"])
			to_remove += conflict_id
			continue
		var/list/parties = conflict_data["parties"]
		if(!parties || length(parties) < 2)
			to_remove += conflict_id
			continue
		var/dept_id_a = parties[1]
		var/dept_id_b = parties[2]
		var/datum/department/dept_a = departments[dept_id_a]
		var/datum/department/dept_b = departments[dept_id_b]
		if(!dept_a || !dept_b)
			to_remove += conflict_id
			continue
		var/head_a_online = dept_a.is_head_online()
		var/head_b_online = dept_b.is_head_online()
		if(head_a_online && head_b_online)
			if(attempt_conflict_resolution(conflict_id, dept_a, dept_b))
				resolve_conflict(conflict_id)
				continue
		else
			dept_a.department_influence = max(0, dept_a.department_influence - 1)
			dept_b.department_influence = max(0, dept_b.department_influence - 1)
			var/severity = conflict_data["severity"] || 50
			conflict_data["severity"] = min(100, severity + 2)
		var/creation_time = conflict_data["creation_time"] || 0
		if(creation_time && world.time > creation_time + 54000)
			force_resolve_conflict(conflict_id)
			to_remove += conflict_id
	for(var/conflict_id in to_remove)
		conflicts -= conflict_id

/datum/foundation_politics_manager/proc/attempt_conflict_resolution(conflict_id, datum/department/dept_a, datum/department/dept_b)
	if(!dept_a || !dept_b)
		return FALSE
	var/list/conflict_data = conflicts[conflict_id]
	if(!conflict_data)
		return FALSE
	var/resolution_cost = (conflict_data["severity"] || 50) * 20
	var/combined_budget = dept_a.department_budget + dept_b.department_budget
	if(combined_budget < resolution_cost)
		return FALSE
	var/share_a = round(resolution_cost * (dept_a.department_budget / max(1, combined_budget)))
	var/share_b = resolution_cost - share_a
	dept_a.department_budget -= share_a
	dept_a.department_budget = max(0, dept_a.department_budget)
	dept_b.department_budget -= share_b
	dept_b.department_budget = max(0, dept_b.department_budget)
	return TRUE

/datum/foundation_politics_manager/proc/resolve_conflict(conflict_id)
	if(!conflicts[conflict_id])
		return
	var/list/conflict_data = conflicts[conflict_id]
	conflict_data["resolved"] = TRUE
	conflict_data["resolution_time"] = world.time
	var/list/parties = conflict_data["parties"]
	if(parties && length(parties) >= 2)
		var/datum/department/dept_a = departments[parties[1]]
		var/datum/department/dept_b = departments[parties[2]]
		if(dept_a)
			dept_a.department_rivals -= parties[2]
		if(dept_b)
			dept_b.department_rivals -= parties[1]
		var/mob/MA = dept_a?.get_head_mob()
		var/mob/MB = dept_b?.get_head_mob()
		if(MA)
			to_chat(MA, "<span class='notice'>Conflict with [dept_b?.department_name || parties[2]] resolved through negotiation.</span>")
		if(MB)
			to_chat(MB, "<span class='notice'>Conflict with [dept_a?.department_name || parties[1]] resolved through negotiation.</span>")
	conflict_resolution_rate = min(100, conflict_resolution_rate + 5)
	create_political_event("policy_change", "Conflict Resolved", "Conflict [conflict_id] resolved through negotiation.", parties, 10)

/datum/foundation_politics_manager/proc/force_resolve_conflict(conflict_id)
	if(!conflicts[conflict_id])
		return
	var/list/conflict_data = conflicts[conflict_id]
	conflict_data["resolved"] = TRUE
	var/list/parties = conflict_data["parties"]
	if(parties && length(parties) >= 2)
		var/datum/department/dept_a = departments[parties[1]]
		var/datum/department/dept_b = departments[parties[2]]
		if(dept_a)
			dept_a.department_influence = max(0, dept_a.department_influence - 5)
		if(dept_b)
			dept_b.department_influence = max(0, dept_b.department_influence - 5)
	conflict_resolution_rate = max(0, conflict_resolution_rate - 2)

/datum/foundation_politics_manager/proc/auto_generate_events()
	for(var/dept_id in departments)
		var/datum/department/dept = departments[dept_id]
		if(!dept)
			continue
		if(dept.department_head && !dept.is_head_online())
			if(!dept._head_offline_notified)
				dept._head_offline_notified = TRUE
				create_political_event("scandal", "Leadership Crisis: [dept.department_name]", "[dept.department_name] has no active department head.", list(dept_id), -15)
		else
			dept._head_offline_notified = FALSE
		dept._last_known_budget = max(1, dept.department_budget)
	for(var/alliance_id in alliances)
		var/list/alliance_data = alliances[alliance_id]
		if(!alliance_data)
			continue
		if(!alliance_data["event_generated"])
			alliance_data["event_generated"] = TRUE
			var/list/members = alliance_data["members"]
			create_political_event("alliance", "Alliance Formed", "Departments [english_list(members)] have formed an alliance.", members, 10)

/datum/foundation_politics_manager/proc/cleanup_expired_events()
	var/list/to_remove = list()
	for(var/event_id in political_events)
		var/datum/political_event/event = political_events[event_id]
		if(!event)
			to_remove += event_id
			continue
		if(world.time > event.event_auto_resolve_time && event.event_outcome == "")
			event.event_outcome = "expired"
			event.event_resolution_date = world.time
		if(event.event_resolution_date && world.time > event.event_resolution_date + 18000)
			to_remove += event_id
	for(var/event_id in to_remove)
		political_events -= event_id

/datum/foundation_politics_manager/proc/initialize_departments()
	var/datum/department/research_dept = new /datum/department("research", "Research Department", "research", "")
	research_dept.department_budget = 50000
	research_dept.department_influence = 40
	research_dept.department_goals = list("advance_scp_knowledge", "develop_containment_protocols")
	departments["research"] = research_dept

	var/datum/department/security_dept = new /datum/department("security", "Security Department", "security", "")
	security_dept.department_budget = 40000
	security_dept.department_influence = 40
	security_dept.department_goals = list("maintain_containment", "train_security_personnel")
	departments["security"] = security_dept

	var/datum/department/medical_dept = new /datum/department("medical", "Medical Department", "medical", "")
	medical_dept.department_budget = 35000
	medical_dept.department_influence = 40
	medical_dept.department_goals = list("provide_medical_care", "develop_treatments")
	departments["medical"] = medical_dept

	var/datum/department/engineering_dept = new /datum/department("engineering", "Engineering Department", "engineering", "")
	engineering_dept.department_budget = 45000
	engineering_dept.department_influence = 40
	engineering_dept.department_goals = list("maintain_facility", "improve_infrastructure")
	departments["engineering"] = engineering_dept

	var/datum/department/admin_dept = new /datum/department("administrative", "Administrative Department", "administrative", "")
	admin_dept.department_budget = 60000
	admin_dept.department_influence = 45
	admin_dept.department_goals = list("manage_resources", "coordinate_departments")
	departments["administrative"] = admin_dept

	total_departments = length(departments)

/datum/foundation_politics_manager/proc/initialize_factions()
	var/datum/faction/conservative_faction = new /datum/faction("conservative", "Conservative Coalition", "conservative", "")
	conservative_faction.faction_ideology = "Maintain traditional Foundation protocols and hierarchy"
	conservative_faction.faction_influence = 40
	factions["conservative"] = conservative_faction

	var/datum/faction/progressive_faction = new /datum/faction("progressive", "Progressive Alliance", "progressive", "")
	progressive_faction.faction_ideology = "Advocate for reform and modernization of Foundation practices"
	progressive_faction.faction_influence = 40
	factions["progressive"] = progressive_faction

	var/datum/faction/militant_faction = new /datum/faction("militant", "Militant Faction", "militant", "")
	militant_faction.faction_ideology = "Emphasize security and military-style discipline"
	militant_faction.faction_influence = 40
	factions["militant"] = militant_faction

	var/datum/faction/scientific_faction = new /datum/faction("scientific", "Scientific Council", "scientific", "")
	scientific_faction.faction_ideology = "Prioritize research and scientific advancement"
	scientific_faction.faction_influence = 40
	factions["scientific"] = scientific_faction

	var/datum/faction/bureaucratic_faction = new /datum/faction("bureaucratic", "Bureaucratic Union", "bureaucratic", "")
	bureaucratic_faction.faction_ideology = "Focus on efficiency and proper procedure"
	bureaucratic_faction.faction_influence = 40
	factions["bureaucratic"] = bureaucratic_faction

	active_factions = length(factions)

/datum/foundation_politics_manager/proc/get_player_department(ckey)
	if(!ckey)
		return null
	for(var/dept_id in departments)
		var/datum/department/dept = departments[dept_id]
		if(dept && (ckey in dept.department_members))
			return dept_id
	return null

/datum/foundation_politics_manager/proc/create_department(name, dept_type, head_ckey)
	if(!name || !dept_type)
		return null
	var/dept_id = "[dept_type]_[world.time]"
	var/datum/department/new_dept = new /datum/department(dept_id, name, dept_type, head_ckey)
	new_dept.department_budget = 30000
	new_dept.department_influence = 30
	departments[dept_id] = new_dept
	total_departments = length(departments)
	return new_dept

/datum/foundation_politics_manager/proc/create_faction(name, faction_type, leader)
	if(!name || !faction_type)
		return null
	var/faction_id = "[faction_type]_[world.time]"
	var/datum/faction/new_faction = new /datum/faction(faction_id, name, faction_type, leader)
	new_faction.faction_influence = 30
	factions[faction_id] = new_faction
	active_factions = length(factions)
	return new_faction

/datum/foundation_politics_manager/proc/get_player_faction(ckey)
	if(!ckey)
		return null
	for(var/faction_id in factions)
		var/datum/faction/fac = factions[faction_id]
		if(fac && (ckey in fac.faction_members))
			return faction_id
	return null

/datum/foundation_politics_manager/proc/form_alliance(dept_id_a, dept_id_b)
	if(!dept_id_a || !dept_id_b || dept_id_a == dept_id_b)
		return null
	var/datum/department/dept_a = departments[dept_id_a]
	var/datum/department/dept_b = departments[dept_id_b]
	if(!dept_a || !dept_b)
		return null
	for(var/existing_id in alliances)
		var/list/existing = alliances[existing_id]
		if(!existing)
			continue
		var/list/members = existing["members"]
		if(members && (dept_id_a in members) && (dept_id_b in members))
			return existing_id
	var/alliance_id = "alliance_[world.time]_[dept_id_a]_[dept_id_b]"
	alliances[alliance_id] = list(
		"id" = alliance_id,
		"name" = "[dept_a.department_name] - [dept_b.department_name] Alliance",
		"type" = "mutual",
		"description" = "[dept_a.department_name] and [dept_b.department_name] have formed a mutual alliance.",
		"strength" = 50,
		"members" = list(dept_id_a, dept_id_b),
		"creation_time" = world.time
	)
	if(!(dept_id_b in dept_a.department_allies))
		dept_a.department_allies += dept_id_b
	if(!(dept_id_a in dept_b.department_allies))
		dept_b.department_allies += dept_id_a
	if(dept_id_b in dept_a.department_rivals)
		dept_a.department_rivals -= dept_id_b
	if(dept_id_a in dept_b.department_rivals)
		dept_b.department_rivals -= dept_id_a
	var/mob/MA = dept_a.get_head_mob()
	var/mob/MB = dept_b.get_head_mob()
	if(MA)
		to_chat(MA, "<span class='notice'>Alliance formed with [dept_b.department_name]!</span>")
	if(MB)
		to_chat(MB, "<span class='notice'>Alliance formed with [dept_a.department_name]!</span>")
	return alliance_id

/datum/foundation_politics_manager/proc/break_alliance(alliance_id)
	if(!alliances[alliance_id])
		return
	var/list/alliance_data = alliances[alliance_id]
	var/list/members = alliance_data["members"]
	if(members)
		for(var/dept_id in members)
			var/datum/department/dept = departments[dept_id]
			if(!dept)
				continue
			for(var/other_id in members)
				if(other_id == dept_id)
					continue
				dept.department_allies -= other_id
	alliances -= alliance_id

/datum/foundation_politics_manager/proc/create_rivalry(dept_id_a, dept_id_b)
	if(!dept_id_a || !dept_id_b || dept_id_a == dept_id_b)
		return
	var/datum/department/dept_a = departments[dept_id_a]
	var/datum/department/dept_b = departments[dept_id_b]
	if(!dept_a || !dept_b)
		return
	if(!(dept_id_b in dept_a.department_rivals))
		dept_a.department_rivals += dept_id_b
	if(!(dept_id_a in dept_b.department_rivals))
		dept_b.department_rivals += dept_id_a
	for(var/faction_id in factions)
		var/datum/faction/fac = factions[faction_id]
		if(!fac)
			continue
		var/list/fac_depts = faction_department_map[faction_id]
		if(!fac_depts)
			continue
		var/matches_a = (dept_id_a in fac_depts)
		var/matches_b = (dept_id_b in fac_depts)
		if(matches_a && !matches_b)
			for(var/other_fid in factions)
				var/datum/faction/other_fac = factions[other_fid]
				if(!other_fac || other_fid == faction_id)
					continue
				var/list/other_depts = faction_department_map[other_fid]
				if(other_depts && (dept_id_b in other_depts))
					if(!(other_fid in fac.faction_enemies))
						fac.faction_enemies += other_fid
					if(!(faction_id in other_fac.faction_enemies))
						other_fac.faction_enemies += faction_id
		if(matches_b && !matches_a)
			for(var/other_fid in factions)
				var/datum/faction/other_fac = factions[other_fid]
				if(!other_fac || other_fid == faction_id)
					continue
				var/list/other_depts = faction_department_map[other_fid]
				if(other_depts && (dept_id_a in other_depts))
					if(!(other_fid in fac.faction_enemies))
						fac.faction_enemies += other_fid
					if(!(faction_id in other_fac.faction_enemies))
						other_fac.faction_enemies += faction_id
	for(var/alliance_id in alliances)
		var/list/alliance_data = alliances[alliance_id]
		if(!alliance_data)
			continue
		var/list/members = alliance_data["members"]
		if(members && (dept_id_a in members) && (dept_id_b in members))
			break_alliance(alliance_id)
			break

/datum/foundation_politics_manager/proc/admin_resolve_conflict(conflict_id)
	if(!conflicts[conflict_id])
		return FALSE
	var/list/conflict_data = conflicts[conflict_id]
	conflict_data["resolved"] = TRUE
	conflict_data["resolution_time"] = world.time
	var/list/parties = conflict_data["parties"]
	if(parties && length(parties) >= 2)
		var/datum/department/dept_a = departments[parties[1]]
		var/datum/department/dept_b = departments[parties[2]]
		if(dept_a)
			dept_a.department_rivals -= parties[2]
		if(dept_b)
			dept_b.department_rivals -= parties[1]
	conflict_resolution_rate = min(100, conflict_resolution_rate + 5)
	conflicts -= conflict_id
	return TRUE

/datum/foundation_politics_manager/proc/admin_set_department_head(dept_id, ckey)
	if(!dept_id)
		return FALSE
	var/datum/department/dept = departments[dept_id]
	if(!dept)
		return FALSE
	dept.department_head = ckey
	dept._head_offline_notified = FALSE
	return TRUE

/datum/foundation_politics_manager/proc/admin_adjust_budget(dept_id, amount)
	if(!dept_id)
		return FALSE
	var/datum/department/dept = departments[dept_id]
	if(!dept)
		return FALSE
	dept.department_budget = max(0, dept.department_budget + amount)
	return TRUE

/datum/foundation_politics_manager/proc/admin_add_goal(dept_id, goal)
	if(!dept_id || !goal)
		return FALSE
	var/datum/department/dept = departments[dept_id]
	if(!dept)
		return FALSE
	if(!(goal in dept.department_goals))
		dept.department_goals += goal
	return TRUE

/datum/foundation_politics_manager/proc/admin_remove_goal(dept_id, goal)
	if(!dept_id || !goal)
		return FALSE
	var/datum/department/dept = departments[dept_id]
	if(!dept)
		return FALSE
	dept.department_goals -= goal
	return TRUE

/datum/political_event
	var/event_id = ""
	var/event_type = ""
	var/event_title = ""
	var/event_description = ""
	var/list/event_participants = list()
	var/event_outcome = ""
	var/event_impact = 0
	var/event_creation_date = 0
	var/event_resolution_date = 0
	var/event_auto_resolve_time = 0

/datum/political_event/New(var/id, var/type, var/title, var/description)
	event_id = id
	event_type = type
	event_title = title
	event_description = description
	event_creation_date = world.time
	event_auto_resolve_time = world.time + 54000
