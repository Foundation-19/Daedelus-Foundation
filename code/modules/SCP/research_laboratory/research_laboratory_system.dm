SUBSYSTEM_DEF(research_laboratory)
	name = "Research Laboratory"
	wait = 100
	priority = FIRE_PRIORITY_RESEARCH
	init_order = INIT_ORDER_RESEARCH
	var/datum/research_laboratory_manager/manager

/datum/controller/subsystem/research_laboratory/Initialize()
	manager = new /datum/research_laboratory_manager()
	manager.initialize()
	world.log << "Research Laboratory Subsystem: Initialized"
	return ..()

/datum/controller/subsystem/research_laboratory/fire()
	if(manager)
		manager.tick()

/datum/research_laboratory_manager
	var/list/research_projects = list()
	var/list/active_experiments = list()
	var/list/research_facilities = list()
	var/list/research_teams = list()
	var/list/safety_protocols = list()
	var/list/research_achievements = list()
	var/datum/tech_tree/tech_tree

	var/total_research_points = 0
	var/total_experiments_conducted = 0
	var/total_breakthroughs = 0
	var/research_efficiency = 1.0
	var/safety_rating = 100.0
	var/containment_breaches = 0
	var/research_incidents = 0

/datum/research_laboratory_manager/proc/initialize()
	tech_tree = new /datum/tech_tree()
	tech_tree.initialize()
	sync_from_subsystems()
	initialize_default_facility()
	initialize_default_safety_protocols()

/datum/research_laboratory_manager/proc/sync_from_subsystems()
	if(SSscp_research && SSscp_research.manager)
		total_research_points = SSscp_research.manager.total_research_points
		total_breakthroughs = SSscp_research.manager.research_breakthroughs
	if(SSscp_experiments && SSscp_experiments.manager)
		total_experiments_conducted = SSscp_experiments.manager.global_experiment_count
		containment_breaches = SSscp_experiments.manager.global_catastrophe_count

/datum/research_laboratory_manager/proc/tick()
	sync_from_subperiments()
	for(var/experiment_id in active_experiments)
		var/list/experiment = active_experiments[experiment_id]
		if(experiment["status"] == "active")
			process_lab_experiment(experiment_id)
	update_safety_rating()
	update_facility_metrics()

/datum/research_laboratory_manager/proc/sync_from_subperiments()
	if(!SSscp_experiments || !SSscp_experiments.manager)
		return
	var/datum/scp_experiment_manager/exp_mgr = SSscp_experiments.manager
	for(var/exp_id in exp_mgr.active_experiments)
		if(!active_experiments[exp_id])
			var/datum/scp_experiment/exp = exp_mgr.active_experiments[exp_id]
			active_experiments[exp_id] = list(
				"id" = exp.experiment_id,
				"name" = exp.name,
				"scp_id" = exp.scp_id,
				"type" = exp.experiment_type,
				"risk_level" = exp.risk_level,
				"status" = exp.status,
				"researcher" = exp.primary_researcher?.name || "Unknown",
				"start_time" = exp.start_time,
				"source" = "scp_experiments",
			)
	for(var/exp_id in exp_mgr.completed_experiments)
		active_experiments -= exp_id

/datum/research_laboratory_manager/proc/process_lab_experiment(experiment_id)
	var/list/experiment = active_experiments[experiment_id]
	if(!experiment)
		return
	if(experiment["source"] == "scp_experiments")
		return
	var/progress_rate = experiment["progress_rate"] || 1.0
	experiment["current_progress"] = (experiment["current_progress"] || 0) + progress_rate
	if(experiment["current_progress"] >= (experiment["max_progress"] || 100))
		complete_lab_experiment(experiment_id)

/datum/research_laboratory_manager/proc/complete_lab_experiment(experiment_id)
	var/list/experiment = active_experiments[experiment_id]
	if(!experiment)
		return
	experiment["status"] = "completed"
	experiment["completion_time"] = world.time
	var/points = experiment["research_points"] || 100
	total_research_points += points
	total_experiments_conducted++
	adjust_global_research_points(points, "lab_experiment")

/datum/research_laboratory_manager/proc/update_safety_rating()
	var/active_high_risk = 0
	for(var/exp_id in active_experiments)
		var/list/exp = active_experiments[exp_id]
		if(exp["status"] == "active" && (exp["risk_level"] || 1) >= 4)
			active_high_risk++
	safety_rating = max(0, 100 - (active_high_risk * 10) - (research_incidents * 5))

/datum/research_laboratory_manager/proc/update_facility_metrics()
	for(var/facility_id in research_facilities)
		var/list/facility = research_facilities[facility_id]
		var/active_count = 0
		for(var/exp_id in active_experiments)
			var/list/exp = active_experiments[exp_id]
			if(exp["facility_id"] == facility_id && exp["status"] == "active")
				active_count++
		facility["active_experiments"] = active_count

/datum/research_laboratory_manager/proc/initialize_default_facility()
	var/facility_id = "facility_site53_main"
	research_facilities[facility_id] = list(
		"id" = facility_id,
		"name" = "Site-53 Main Research Wing",
		"status" = "operational",
		"active_experiments" = 0,
		"safety_rating" = 100,
		"location" = "Site-53",
	)
	var/facility_id2 = "facility_site53_containment"
	research_facilities[facility_id2] = list(
		"id" = facility_id2,
		"name" = "Site-53 Containment Research Lab",
		"status" = "operational",
		"active_experiments" = 0,
		"safety_rating" = 100,
		"location" = "Site-53 HCZ",
	)

/datum/research_laboratory_manager/proc/initialize_default_safety_protocols()
	var/protocol_id = "safety_standard"
	safety_protocols[protocol_id] = list(
		"id" = protocol_id,
		"name" = "Standard Research Safety Protocol",
		"description" = "Baseline safety requirements for all SCP experiments.",
		"status" = "active",
		"violations" = 0,
		"violation_threshold" = 5,
	)
	var/protocol_id2 = "safety_high_risk"
	safety_protocols[protocol_id2] = list(
		"id" = protocol_id2,
		"name" = "High-Risk Experiment Protocol",
		"description" = "Additional safety measures for High and Critical risk experiments.",
		"status" = "active",
		"violations" = 0,
		"violation_threshold" = 3,
	)

/datum/research_laboratory_manager/proc/create_research_project(list/project_data)
	var/project_id = "project_[world.time]_[rand(10000, 99999)]"
	project_data["id"] = project_id
	project_data["creation_time"] = world.time
	project_data["status"] = project_data["status"] || "proposed"
	project_data["progress"] = 0
	research_projects[project_id] = project_data
	return project_id

/datum/research_laboratory_manager/proc/approve_research_project(project_id)
	var/list/project = research_projects[project_id]
	if(!project)
		return FALSE
	project["status"] = "approved"
	project["approval_time"] = world.time
	return TRUE

/datum/research_laboratory_manager/proc/delete_research_project(project_id)
	research_projects -= project_id
	return TRUE

/datum/research_laboratory_manager/proc/create_research_team(list/team_data)
	var/team_id = "team_[world.time]_[rand(1000, 9999)]"
	team_data["id"] = team_id
	team_data["creation_time"] = world.time
	team_data["status"] = "active"
	team_data["members"] = list()
	team_data["completed_experiments"] = 0
	team_data["total_research_points"] = 0
	research_teams[team_id] = team_data
	return team_id

/datum/research_laboratory_manager/proc/add_team_member(team_id, mob/living/carbon/human/researcher)
	var/list/team = research_teams[team_id]
	if(!team)
		return FALSE
	team["members"] += list(list(
		"ckey" = researcher.ckey,
		"name" = researcher.real_name,
		"role" = researcher.job || "Researcher",
		"join_time" = world.time,
	))
	return TRUE

/datum/research_laboratory_manager/proc/remove_team_member(team_id, ckey)
	var/list/team = research_teams[team_id]
	if(!team)
		return FALSE
	var/list/new_members = list()
	for(var/list/member in team["members"])
		if(member["ckey"] != ckey)
			new_members += list(member)
	team["members"] = new_members
	return TRUE

/datum/research_laboratory_manager/proc/register_research_facility(list/facility_data)
	var/facility_id = "facility_[world.time]_[rand(1000, 9999)]"
	facility_data["id"] = facility_id
	facility_data["status"] = "operational"
	facility_data["active_experiments"] = 0
	facility_data["safety_rating"] = 100
	research_facilities[facility_id] = facility_data
	return facility_id

/datum/research_laboratory_manager/proc/create_safety_protocol(list/protocol_data)
	var/protocol_id = "safety_[world.time]_[rand(1000, 9999)]"
	protocol_data["id"] = protocol_id
	protocol_data["status"] = "active"
	protocol_data["violations"] = 0
	safety_protocols[protocol_id] = protocol_data
	return protocol_id

/datum/research_laboratory_manager/proc/record_safety_violation(protocol_id)
	var/list/protocol = safety_protocols[protocol_id]
	if(!protocol)
		return
	protocol["violations"] = (protocol["violations"] || 0) + 1
	research_incidents++
	if(protocol["violations"] >= (protocol["violation_threshold"] || 5))
		protocol["status"] = "emergency"

/datum/research_laboratory_manager/proc/get_available_scp_targets()
	var/list/targets = list()
	if(SSscp_persistence && SSscp_persistence.manager)
		for(var/scp_id in SSscp_persistence.manager.scp_instances)
			var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[scp_id]
			targets += list(list(
				"id" = scp_id,
				"status" = instance.containment_status,
				"class" = instance.containment_class,
			))
	return targets

/datum/research_laboratory_manager/proc/get_all_data(mob/user)
	var/list/data = list()

	data["research_projects"] = get_projects_data()
	data["active_experiments"] = get_experiments_data()
	data["research_teams"] = get_teams_data()
	data["research_facilities"] = get_facilities_data()
	data["safety_protocols"] = get_safety_data()
	data["research_achievements"] = get_achievements_data()
	data["researcher_skills"] = get_researcher_skills_data()
	data["scp_targets"] = get_available_scp_targets()
	data["tech_tree"] = tech_tree.get_all_nodes_data()
	data["available_tech"] = tech_tree.get_available_nodes(total_research_points)

	if(SSscp_research && SSscp_research.manager)
		data["scp_research_data"] = list(
			"total_research_points" = SSscp_research.manager.total_research_points,
			"research_breakthroughs" = SSscp_research.manager.research_breakthroughs,
			"containment_improvements" = SSscp_research.manager.containment_improvements,
			"classification_updates" = SSscp_research.manager.classification_updates,
		)

	if(SStechnology_persistence && SStechnology_persistence.manager)
		var/datum/technology_persistence_manager/tech_mgr = SStechnology_persistence.manager
		data["technology_data"] = list(
			"technology_level" = tech_mgr.technology_level,
			"innovation_score" = tech_mgr.innovation_score,
			"research_progress" = tech_mgr.research_progress,
			"breakthrough_chance" = tech_mgr.breakthrough_chance,
		)

	data["system_metrics"] = list(
		"total_research_points" = total_research_points,
		"total_experiments" = total_experiments_conducted,
		"total_breakthroughs" = total_breakthroughs,
		"research_efficiency" = research_efficiency,
		"safety_rating" = safety_rating,
		"containment_breaches" = containment_breaches,
		"research_incidents" = research_incidents,
	)

	data["is_admin"] = check_rights_for(user?.client, R_ADMIN)
	data["user_ckey"] = user?.ckey
	data["user_name"] = user?.name
	data["user_job"] = ishuman(user) ? user.job : "Unknown"
	data["user_access_level"] = get_user_access_level(user)

	return data

/datum/research_laboratory_manager/proc/get_user_access_level(mob/user)
	if(!user || !user.client)
		return EXPERIMENT_ACCESS_NONE
	if(check_rights(R_ADMIN, FALSE, user))
		return EXPERIMENT_ACCESS_FULL
	if(!SSscp_experiments || !SSscp_experiments.manager)
		return EXPERIMENT_ACCESS_NONE
	var/job_name = "Unknown"
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.job)
			job_name = H.job
	return SSscp_experiments.manager.get_default_certification(job_name)

/datum/research_laboratory_manager/proc/get_projects_data()
	var/list/result = list()
	for(var/project_id in research_projects)
		var/list/project = research_projects[project_id]
		result[project_id] = project
	return result

/datum/research_laboratory_manager/proc/get_experiments_data()
	var/list/result = list()
	for(var/exp_id in active_experiments)
		var/list/exp = active_experiments[exp_id]
		result[exp_id] = exp
	if(SSscp_experiments && SSscp_experiments.manager)
		var/datum/scp_experiment_manager/exp_mgr = SSscp_experiments.manager
		for(var/exp_id in exp_mgr.active_experiments)
			if(!result[exp_id])
				var/datum/scp_experiment/scp_exp = exp_mgr.active_experiments[exp_id]
				var/progress = round((scp_exp.phase_progress / max(1, scp_exp.phase_duration)) * 100)
				result[exp_id] = list(
					"id" = scp_exp.experiment_id,
					"name" = scp_exp.name,
					"scp_id" = scp_exp.scp_id,
					"risk_level" = scp_exp.risk_level,
					"risk_name" = get_experiment_risk_name(scp_exp.risk_level),
					"status" = scp_exp.status,
					"current_progress" = progress,
					"max_progress" = 100,
					"researcher" = scp_exp.primary_researcher?.name || "Unknown",
					"team_id" = null,
					"start_time" = scp_exp.start_time,
					"source" = "scp_experiments",
					"skill_bonus" = 0,
					"breakthrough_chance" = 5,
				)
	return result

/datum/research_laboratory_manager/proc/get_teams_data()
	var/list/result = list()
	for(var/team_id in research_teams)
		var/list/team = research_teams[team_id]
		result[team_id] = team
	return result

/datum/research_laboratory_manager/proc/get_facilities_data()
	var/list/result = list()
	for(var/facility_id in research_facilities)
		var/list/facility = research_facilities[facility_id]
		result[facility_id] = facility
	return result

/datum/research_laboratory_manager/proc/get_safety_data()
	var/list/result = list()
	for(var/protocol_id in safety_protocols)
		var/list/protocol = safety_protocols[protocol_id]
		result[protocol_id] = protocol
	return result

/datum/research_laboratory_manager/proc/get_achievements_data()
	var/list/result = list()
	for(var/achievement_id in research_achievements)
		var/list/achievement = research_achievements[achievement_id]
		result[achievement_id] = achievement
	if(SSscp_research && SSscp_research.manager)
		var/datum/scp_research_manager/scp_mgr = SSscp_research.manager
		for(var/ckey in scp_mgr.researcher_profiles)
			var/datum/researcher_data/rd = scp_mgr.researcher_profiles[ckey]
			for(var/achievement in rd.achievements)
				var/ach_id = "scp_[ckey]_[achievement]"
				if(!result[ach_id])
					result[ach_id] = list(
						"id" = ach_id,
						"description" = achievement,
						"unlock_time" = world.time,
						"researcher" = ckey,
					)
	return result

/datum/research_laboratory_manager/proc/get_researcher_skills_data()
	var/list/result = list()
	for(var/mob/living/carbon/human/H in GLOB.human_list)
		if(QDELETED(H))
			continue
		if(!H.mind || !H.job)
			continue
		var/job_title = H.job
		if(job_title in list("Research Director", "Scientist", "Senior Researcher", "Research Assistant", "Junior Researcher", "Assistant Research Director"))
			var/skill_level = 0
			if(H.mind)
				skill_level = H.mind.get_skill_level(/datum/skill/research) || 0
			result[H.real_name] = list(
				"skill_name" = "Research",
				"level" = skill_level,
				"bonus" = skill_level * 2,
				"ckey" = H.ckey,
				"job" = job_title,
			)
	return result

/datum/research_laboratory_manager/proc/get_available_experiments_for_scp(mob/user, scp_id)
	if(!SSscp_experiments || !SSscp_experiments.manager)
		return list()
	if(!ishuman(user))
		return list()
	return SSscp_experiments.manager.get_available_experiments(user, scp_id)

/datum/research_laboratory_manager/proc/start_scp_experiment(mob/living/carbon/human/user, scp_id, experiment_type)
	if(!SSscp_experiments || !SSscp_experiments.manager)
		return null
	return SSscp_experiments.manager.start_experiment(scp_id, experiment_type, user)

/datum/research_laboratory_manager/proc/suspend_scp_experiment(experiment_id, mob/user)
	if(!SSscp_experiments || !SSscp_experiments.manager)
		return FALSE
	return SSscp_experiments.manager.suspend_experiment(experiment_id, user)

/datum/research_laboratory_manager/proc/resume_scp_experiment(experiment_id, mob/user)
	if(!SSscp_experiments || !SSscp_experiments.manager)
		return FALSE
	return SSscp_experiments.manager.resume_experiment(experiment_id, user)

/datum/research_laboratory_manager/proc/terminate_scp_experiment(experiment_id, mob/user)
	if(!SSscp_experiments || !SSscp_experiments.manager)
		return FALSE
	return SSscp_experiments.manager.terminate_experiment(experiment_id, user)

/datum/research_laboratory_manager/proc/unlock_tech_node(node_id, mob/user)
	if(!tech_tree.can_unlock(node_id, total_research_points))
		return FALSE
	var/cost = tech_tree.nodes[node_id].research_cost
	total_research_points -= cost
	adjust_global_research_points(-cost, "tech_unlock:[node_id]")
	if(!tech_tree.unlock_node(node_id, user?.ckey))
		total_research_points += cost
		adjust_global_research_points(cost, "tech_unlock_refund:[node_id]")
		return FALSE
	apply_tech_unlock(node_id, user)
	return TRUE

/datum/research_laboratory_manager/proc/apply_tech_unlock(node_id, mob/user)
	var/datum/tech_node/node = tech_tree.nodes[node_id]
	if(!node)
		return
	log_game("Tech unlocked: [node.name] by [key_name(user)]")
	message_admins("Research tech unlocked: [node.name] by [key_name(user)]")
	switch(node_id)
		if("improved_containment")
			apply_containment_bonus(0.1)
		if("containment_reinforcement")
			apply_containment_bonus(0.15)
		if("keter_protocols")
			apply_containment_bonus(0.2)
		if("apollyon_protocols")
			apply_containment_bonus(0.3)
		if("basic_medical")
			restock_foundation_medical(list(/obj/item/reagent_containers/pill/amnestics/classa = 4))
		if("anomalous_surgery")
			apply_medical_bonus(0.1)
		if("pathogen_identification")
			restock_foundation_medical(list(/obj/item/reagent_containers/syringe/amnesticsc = 2))
		if("amnestics_production")
			restock_foundation_medical(list(/obj/item/reagent_containers/pill/amnestics/classb = 6, /obj/item/reagent_containers/syringe/amnesticsg = 4, /obj/item/reagent_containers/ivbag/amnesticsf = 2))
		if("cognitive_shielding")
			apply_sanity_resistance(0.15)
		if("memetic_countermeasures")
			apply_sanity_resistance(0.2)
			restock_foundation_armory(list(/obj/item/clothing/glasses/scp178 = 4))
		if("telekill_alloy")
			restock_foundation_armory(list(/obj/item/clothing/head/helmet/scp/telekill = 2, /obj/item/clothing/suit/armor/vest/scp/telekill = 2))
		if("basic_analysis")
			apply_research_multiplier(0.1)
		if("advanced_analysis")
			apply_research_multiplier(0.15)
		if("pattern_recognition")
			apply_research_multiplier(0.2)
		if("containment_engineering")
			restock_foundation_armory(list(/obj/item/weldingtool/hugetank = 2, /obj/item/stack/sheet/telekill = 10))
		if("reality_anchor_theory")
			restock_foundation_armory(list(/obj/item/assembly/signaler/anomaly = 2))
		if("scp_weaponization")
			restock_foundation_armory(list(/obj/item/gun/ballistic/automatic/scp/m16 = 2, /obj/item/ammo_box/magazine/scp/m16_mag = 6))
		if("bsl3_protocols")
			restock_foundation_medical(list(/obj/item/clothing/head/bio_hood/general = 2, /obj/item/clothing/suit/bio_suit/general = 2))
		if("bsl4_containment")
			apply_containment_bonus(0.1)
			restock_foundation_medical(list(/obj/item/clothing/head/bio_hood/virology = 2, /obj/item/clothing/suit/bio_suit/virology = 2))
		if("anomalous_cure_development")
			apply_medical_bonus(0.15)
		if("bioweapon_countermeasures")
			apply_medical_bonus(0.2)
			restock_foundation_medical(list(/obj/item/reagent_containers/glass/bottle/bicaridine = 3))
		if("project_overwatch")
			apply_containment_bonus(0.15)
			apply_research_multiplier(0.1)
	for(var/mob/living/carbon/human/H in GLOB.human_list)
		if(QDELETED(H))
			continue
		if(H.job && (H.job in list("Research Director", "Scientist", "Senior Researcher", "Site Director")))
			to_chat(H, "<span class='boldnotice'>RESEARCH BREAKTHROUGH: [node.name] unlocked!</span>")

/datum/research_laboratory_manager/proc/apply_containment_bonus(bonus)
	for(var/scp_id in SSscp_persistence?.manager?.scp_instances)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[scp_id]
		if(instance)
			instance.containment_effectiveness = min(1.5, instance.containment_effectiveness + bonus)
			instance.containment_difficulty = max(1, instance.containment_difficulty - 1)

/datum/research_laboratory_manager/proc/apply_medical_bonus(bonus)
	if(SSscp_research?.manager)
		SSscp_research.manager.medical_bonus += bonus

/datum/research_laboratory_manager/proc/apply_sanity_resistance(bonus)
	if(SSscp_research?.manager)
		SSscp_research.manager.cognitive_bonus += bonus

/datum/research_laboratory_manager/proc/apply_research_multiplier(bonus)
	if(SSscp_research?.manager)
		SSscp_research.manager.research_point_multiplier += bonus

/datum/research_laboratory_manager/proc/restock_foundation_medical(list/items)
	for(var/obj/machinery/vending/foundation_medical/V in INSTANCES_OF(/obj/machinery/vending/foundation_medical))
		for(var/item_type in items)
			var/count = items[item_type]
			if(item_type in V.products)
				V.products[item_type] += count
			else
				V.products[item_type] = count

/datum/research_laboratory_manager/proc/restock_foundation_armory(list/items)
	for(var/obj/machinery/vending/foundation_armory/V in INSTANCES_OF(/obj/machinery/vending/foundation_armory))
		for(var/item_type in items)
			var/count = items[item_type]
			if(item_type in V.products)
				V.products[item_type] += count
			else
				V.products[item_type] = count

/obj/machinery/computer/research_laboratory_console
	name = "Research Laboratory Console"
	desc = "An advanced terminal for managing SCP experiments, research teams, and technology."
	icon = 'icons/obj/computer.dmi'
	icon_state = "research"
	circuit = /obj/item/circuitboard/computer/research_laboratory_console
	req_access = list(ACCESS_SCIENCE)
	var/admin_virtual = FALSE

/obj/machinery/computer/research_laboratory_console/ui_status(mob/user, datum/ui_state/state)
	if(admin_virtual && check_rights_for(user?.client, R_ADMIN))
		return UI_INTERACTIVE
	return ..()

/obj/machinery/computer/research_laboratory_console/ui_close(mob/user)
	. = ..()
	if(admin_virtual)
		qdel(src)

/obj/machinery/computer/research_laboratory_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ResearchLaboratory", "SCP Research Terminal")
		ui.open()

/obj/machinery/computer/research_laboratory_console/ui_data(mob/user)
	if(!SSresearch_laboratory || !SSresearch_laboratory.manager)
		return list()
	return SSresearch_laboratory.manager.get_all_data(user)

/obj/machinery/computer/research_laboratory_console/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!SSresearch_laboratory || !SSresearch_laboratory.manager)
		return
	var/datum/research_laboratory_manager/mgr = SSresearch_laboratory.manager

	switch(action)
		if("create_project")
			if(!params["name"])
				return
			mgr.create_research_project(list(
				"name" = params["name"],
				"description" = params["description"] || "No description provided.",
				"scp_target" = params["scp_target"] || "",
				"research_points" = text2num(params["research_points"]) || 100,
				"risk_level" = text2num(params["risk_level"]) || 1,
				"team_id" = params["team_id"] || "",
				"facility_id" = params["facility_id"] || "",
				"progress_rate" = text2num(params["progress_rate"]) || 1.0,
				"max_progress" = text2num(params["max_progress"]) || 100,
				"breakthrough_chance" = text2num(params["breakthrough_chance"]) || 5,
			))
			. = TRUE

		if("approve_project")
			if(params["project_id"])
				mgr.approve_research_project(params["project_id"])
			. = TRUE

		if("delete_project")
			if(params["project_id"])
				mgr.delete_research_project(params["project_id"])
			. = TRUE

		if("create_team")
			if(!params["name"])
				return
			mgr.create_research_team(list("name" = params["name"]))
			. = TRUE

		if("add_team_member")
			var/team_id = params["team_id"]
			if(team_id && ishuman(usr))
				mgr.add_team_member(team_id, usr)
			. = TRUE

		if("remove_team_member")
			var/team_id = params["team_id"]
			var/ckey = params["ckey"]
			if(team_id && ckey)
				mgr.remove_team_member(team_id, ckey)
			. = TRUE

		if("start_experiment")
			var/scp_id = params["scp_id"]
			var/exp_type = text2num(params["experiment_type"])
			if(scp_id && exp_type && ishuman(usr))
				var/mob/living/carbon/human/H = usr
				var/datum/scp_experiment/exp = mgr.start_scp_experiment(H, scp_id, exp_type)
				if(!exp)
					to_chat(H, "<span class='warning'>Failed to start experiment.</span>")
				else if(SSdclass_experiments)
					SSdclass_experiments.request_test_subject(H, scp_id, "lab_experiment", 2, FALSE)
					to_chat(H, "<span class='notice'>D-Class test subject requested.</span>")
			. = TRUE

		if("suspend_experiment")
			var/exp_id = params["experiment_id"]
			if(exp_id)
				mgr.suspend_scp_experiment(exp_id, usr)
			. = TRUE

		if("resume_experiment")
			var/exp_id = params["experiment_id"]
			if(exp_id)
				mgr.resume_scp_experiment(exp_id, usr)
			. = TRUE

		if("terminate_experiment")
			var/exp_id = params["experiment_id"]
			if(exp_id)
				mgr.terminate_scp_experiment(exp_id, usr)
			. = TRUE

		if("unlock_tech")
			var/node_id = params["node_id"]
			if(node_id)
				if(!mgr.unlock_tech_node(node_id, usr))
					to_chat(usr, "<span class='warning'>Cannot unlock this technology.</span>")
			. = TRUE

		if("record_violation")
			var/protocol_id = params["protocol_id"]
			if(protocol_id)
				mgr.record_safety_violation(protocol_id)
			. = TRUE

/obj/item/circuitboard/computer/research_laboratory_console
	name = "Research Laboratory Console (Computer Board)"
	build_path = /obj/machinery/computer/research_laboratory_console

/client/proc/open_research_laboratory()
	set name = "Research Laboratory"
	set category = "Admin"
	set desc = "Open the advanced research laboratory system"
	if(!check_rights(R_ADMIN))
		return
	if(!SSresearch_laboratory || !SSresearch_laboratory.manager)
		to_chat(src, "<span class='warning'>Research laboratory system not available.</span>")
		return
	var/obj/machinery/computer/research_laboratory_console/virtual_console = new()
	virtual_console.admin_virtual = TRUE
	virtual_console.ui_interact(mob)
