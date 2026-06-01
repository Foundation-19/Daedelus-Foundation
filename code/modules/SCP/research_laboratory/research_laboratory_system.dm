SUBSYSTEM_DEF(research_laboratory)
	name = "Research Laboratory"
	wait = 100
	priority = FIRE_PRIORITY_RESEARCH
	init_order = INIT_ORDER_RESEARCH
	var/datum/research_laboratory_manager/manager

/datum/controller/subsystem/research_laboratory/Initialize()
	manager = new /datum/research_laboratory_manager()
	manager.initialize()
	log_game("Research Laboratory Subsystem: Initialized")
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

	var/list/pending_join_requests = list()
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
		total_research_points = SSscp_research?.manager?.total_research_points
		total_breakthroughs = SSscp_research?.manager?.research_breakthroughs
	if(SSscp_experiments && SSscp_experiments.manager)
		total_experiments_conducted = SSscp_experiments?.manager?.global_experiment_count
		containment_breaches = SSscp_experiments?.manager?.global_catastrophe_count

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
	project_data["status"] = project_data["status"] || "PROPOSED"
	project_data["progress"] = 0
	if(!project_data["scp_targets"])
		var/scp_target = project_data["scp_target"]
		project_data["scp_targets"] = scp_target ? list(scp_target) : list()
		project_data -= "scp_target"
	if(!project_data["team_id"])
		project_data["team_id"] = ""
	research_projects[project_id] = project_data
	return project_id

/datum/research_laboratory_manager/proc/approve_research_project(project_id, approved_by)
	var/list/project = research_projects[project_id]
	if(!project)
		if(SSresearch_persistence?.manager)
			var/datum/research_persistence_project/rp = SSresearch_persistence.manager.research_projects[project_id]
			if(rp)
				rp.status = "APPROVED"
				return TRUE
		if(SSscp_persistence?.manager)
			var/datum/research_project/sp = SSscp_persistence.manager.research_projects[project_id]
			if(sp)
				sp.research_status = "approved"
				return TRUE
		return FALSE
	project["status"] = "APPROVED"
	project["approval_time"] = world.time
	var/source = project["source"]
	if(source == "research_persistence" && SSresearch_persistence?.manager)
		var/datum/research_persistence_project/rp = SSresearch_persistence.manager.research_projects[project_id]
		if(rp)
			rp.status = "APPROVED"
	else if(source == "scp_persistence" && SSscp_persistence?.manager)
		var/datum/research_project/sp = SSscp_persistence.manager.research_projects[project_id]
		if(sp)
			sp.research_status = "approved"
	return TRUE

/datum/research_laboratory_manager/proc/revoke_research_project(project_id)
	var/list/project = research_projects[project_id]
	if(!project)
		if(SSresearch_persistence?.manager)
			var/datum/research_persistence_project/rp = SSresearch_persistence.manager.research_projects[project_id]
			if(rp && rp.status == "APPROVED")
				rp.status = "PROPOSED"
				return TRUE
		return FALSE
	if(project["status"] != "APPROVED")
		return FALSE
	project["status"] = "PROPOSED"
	project -= "approval_time"
	var/source = project["source"]
	if(source == "research_persistence" && SSresearch_persistence?.manager)
		var/datum/research_persistence_project/rp = SSresearch_persistence.manager.research_projects[project_id]
		if(rp)
			rp.status = "PROPOSED"
	return TRUE

/datum/research_laboratory_manager/proc/delete_research_project(project_id)
	var/list/project = research_projects[project_id]
	if(project)
		var/source = project["source"]
		if(source == "scp_persistence" && SSscp_persistence?.manager)
			SSscp_persistence.manager.remove_research_project(project_id)
		else if(source == "research_persistence" && SSresearch_persistence?.manager)
			SSresearch_persistence.manager.remove_research_project(project_id)
		research_projects -= project_id
		return TRUE
	if(SSscp_persistence?.manager && SSscp_persistence.manager.research_projects[project_id])
		SSscp_persistence.manager.remove_research_project(project_id)
		return TRUE
	if(SSresearch_persistence?.manager && SSresearch_persistence.manager.research_projects[project_id])
		SSresearch_persistence.manager.remove_research_project(project_id)
		return TRUE
	return FALSE

/datum/research_laboratory_manager/proc/add_project_scp_target(project_id, scp_id)
	var/list/project = research_projects[project_id]
	if(!project)
		return FALSE
	var/list/targets = project["scp_targets"]
	if(!targets)
		targets = list()
		project["scp_targets"] = targets
	if(scp_id in targets)
		return FALSE
	targets += scp_id
	return TRUE

/datum/research_laboratory_manager/proc/remove_project_scp_target(project_id, scp_id)
	var/list/project = research_projects[project_id]
	if(!project)
		return FALSE
	var/list/targets = project["scp_targets"]
	if(!targets)
		return FALSE
	targets -= scp_id
	return TRUE

/datum/research_laboratory_manager/proc/assign_project_team(project_id, team_id)
	var/list/project = research_projects[project_id]
	if(!project)
		return FALSE
	project["team_id"] = team_id
	return TRUE

/datum/research_laboratory_manager/proc/is_assigned_to_project(project_id, ckey)
	if(!ckey)
		return FALSE
	var/list/project = research_projects[project_id]
	if(!project)
		return FALSE
	if(project["researcher_ckey"] == ckey)
		return TRUE
	var/project_team_id = project["team_id"]
	if(project_team_id)
		var/list/team = research_teams[project_team_id]
		if(team)
			for(var/list/member in team["members"])
				if(member["ckey"] == ckey)
					return TRUE
	return FALSE

/datum/research_laboratory_manager/proc/attach_document(project_id, mob/user, obj/item/paper/document)
	var/list/project = research_projects[project_id]
	if(!project)
		return FALSE
	if(!is_assigned_to_project(project_id, user?.ckey))
		return FALSE
	if(!document)
		return FALSE
	var/doc_id = "doc_[world.time]_[rand(1000, 9999)]"
	var/doc_name = document.name || "Untitled Document"
	var/content_preview = copytext(document.info || "", 1, 80)
	project["attached_documents"] += list(list(
		"doc_id" = doc_id,
		"doc_name" = doc_name,
		"attached_by" = user.ckey,
		"attached_by_name" = user.real_name,
		"attached_time" = world.time,
		"content_preview" = content_preview,
		"raw_info" = document.info,
	))
	qdel(document)
	return TRUE

/datum/research_laboratory_manager/proc/remove_document(project_id, mob/user, doc_id)
	var/list/project = research_projects[project_id]
	if(!project)
		return null
	if(!is_assigned_to_project(project_id, user?.ckey))
		return null
	var/list/new_docs = list()
	var/removed_info
	var/removed_name
	for(var/list/doc in project["attached_documents"])
		if(doc["doc_id"] == doc_id)
			removed_info = doc["raw_info"]
			removed_name = doc["doc_name"]
		else
			new_docs += list(doc)
	project["attached_documents"] = new_docs
	if(isnull(removed_info))
		return null
	var/obj/item/paper/released = new(get_turf(user))
	released.name = removed_name
	released.setText(removed_info)
	user.put_in_hands(released)
	return doc_id

/datum/research_laboratory_manager/var/list/team_name_registry = list()

/datum/research_laboratory_manager/proc/get_next_team_name()
	var/static/list/nato_names = list("Alpha", "Beta", "Charlie", "Delta", "Echo", "Foxtrot", "Golf", "Hotel", "India", "Juliet", "Kilo", "Lima", "Mike", "November", "Oscar", "Papa", "Quebec", "Romeo", "Sierra", "Tango", "Uniform", "Victor", "Whiskey", "Xray", "Yankee", "Zulu")
	for(var/i in 1 to length(nato_names))
		var/base_name = "Research Team [nato_names[i]]"
		if(!(base_name in team_name_registry))
			team_name_registry[base_name] = TRUE
			return base_name
	var/suffix = 2
	while(TRUE)
		var/fallback_name = "Research Team [nato_names[length(nato_names)]]-[suffix]"
		if(!(fallback_name in team_name_registry))
			team_name_registry[fallback_name] = TRUE
			return fallback_name
		suffix++

/datum/research_laboratory_manager/proc/create_research_team(list/team_data)
	var/team_id = "team_[world.time]_[rand(1000, 9999)]"
	if(!team_data["name"])
		team_data["name"] = get_next_team_name()
	else
		team_name_registry[team_data["name"]] = TRUE
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
	if(!researcher.ckey)
		return FALSE
	for(var/list/existing in team["members"])
		if(existing["ckey"] == researcher.ckey)
			return FALSE
	for(var/other_id in research_teams)
		if(other_id == team_id)
			continue
		var/list/other_team = research_teams[other_id]
		for(var/list/existing in other_team["members"])
			if(existing["ckey"] == researcher.ckey)
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

/datum/research_laboratory_manager/proc/request_team_join(team_id, mob/living/carbon/human/requester)
	var/list/team = research_teams[team_id]
	if(!team)
		return FALSE
	if(!requester.ckey)
		return FALSE
	for(var/list/existing in team["members"])
		if(existing["ckey"] == requester.ckey)
			return FALSE
	for(var/other_id in research_teams)
		var/list/other_team = research_teams[other_id]
		for(var/list/existing in other_team["members"])
			if(existing["ckey"] == requester.ckey)
				return FALSE
	for(var/list/req in pending_join_requests)
		if(req["ckey"] == requester.ckey && req["team_id"] == team_id)
			return FALSE
	var/req_id = "joinreq_[world.time]_[rand(1000,9999)]"
	pending_join_requests += list(list(
		"request_id" = req_id,
		"team_id" = team_id,
		"ckey" = requester.ckey,
		"name" = requester.real_name,
		"role" = requester.job || "Unknown",
		"timestamp" = world.time,
	))
	return TRUE

/datum/research_laboratory_manager/proc/approve_join_request(req_id)
	var/list/target_req
	for(var/list/req in pending_join_requests)
		if(req["request_id"] == req_id)
			target_req = req
			break
	if(!target_req)
		return FALSE
	pending_join_requests -= list(target_req)
	var/list/team = research_teams[target_req["team_id"]]
	if(!team)
		return FALSE
	for(var/list/existing in team["members"])
		if(existing["ckey"] == target_req["ckey"])
			return FALSE
	team["members"] += list(list(
		"ckey" = target_req["ckey"],
		"name" = target_req["name"],
		"role" = target_req["role"],
		"join_time" = world.time,
	))
	var/mob/target_mob
	for(var/client/C in GLOB.clients)
		if(C.ckey == target_req["ckey"])
			target_mob = C.mob
			break
	if(target_mob)
		to_chat(target_mob, span_notice("Your request to join team [team["name"] || target_req["team_id"]] has been approved."))
	return TRUE

/datum/research_laboratory_manager/proc/deny_join_request(req_id)
	var/list/target_req
	for(var/list/req in pending_join_requests)
		if(req["request_id"] == req_id)
			target_req = req
			break
	if(!target_req)
		return FALSE
	pending_join_requests -= list(target_req)
	var/mob/target_mob
	for(var/client/C in GLOB.clients)
		if(C.ckey == target_req["ckey"])
			target_mob = C.mob
			break
	if(target_mob)
		to_chat(target_mob, span_warning("Your request to join that research team has been denied."))
	return TRUE

/datum/research_laboratory_manager/proc/is_research_personnel(mob/user)
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/H = user
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card)
		return FALSE
	if(ACCESS_SCIENCE in id_card.access)
		return TRUE
	if(ACCESS_SCIENCE_LVL1 in id_card.access)
		return TRUE
	if(ACCESS_SCIENCE_LVL2 in id_card.access)
		return TRUE
	if(ACCESS_SCIENCE_LVL3 in id_card.access)
		return TRUE
	if(ACCESS_SCIENCE_LVL4 in id_card.access)
		return TRUE
	if(ACCESS_SCIENCE_LVL5 in id_card.access)
		return TRUE
	return FALSE

/datum/research_laboratory_manager/proc/is_command_personnel(mob/user)
	if(!ishuman(user))
		return FALSE
	if(check_rights(R_ADMIN, FALSE, user))
		return TRUE
	var/mob/living/carbon/human/H = user
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card)
		return FALSE
	if(ACCESS_ADMIN_LVL4 in id_card.access)
		return TRUE
	if(ACCESS_ADMIN_LVL5 in id_card.access)
		return TRUE
	return FALSE

/datum/research_laboratory_manager/proc/can_manage(mob/user)
	if(check_rights(R_ADMIN, FALSE, user))
		return TRUE
	if(is_research_personnel(user))
		return TRUE
	if(is_command_personnel(user))
		return TRUE
	return FALSE

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
		for(var/scp_id in SSscp_persistence?.manager?.scp_instances)
			var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances[scp_id]
			targets += list(list(
				"id" = scp_id,
				"status" = instance.containment_status,
				"class" = instance.containment_class,
			))
	return targets

/datum/research_laboratory_manager/proc/get_all_data(mob/user)
	var/list/data = list()

	data["research_projects"] = get_projects_data(user)
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
			"total_research_points" = SSscp_research?.manager?.total_research_points,
			"research_breakthroughs" = SSscp_research?.manager?.research_breakthroughs,
			"containment_improvements" = SSscp_research?.manager?.containment_improvements,
			"classification_updates" = SSscp_research?.manager?.classification_updates,
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
	data["is_researcher"] = is_research_personnel(user)
	data["is_command"] = is_command_personnel(user)
	data["user_ckey"] = user?.ckey
	data["user_name"] = user?.name
	data["user_job"] = ishuman(user) ? user.job : "Unknown"
	data["user_access_level"] = get_user_access_level(user)

	data["researcher_profile"] = null
	data["achievements"] = list()
	data["completed_research"] = list()
	data["active_projects"] = list()
	data["inserted_id"] = null
	data["has_access"] = FALSE
	data["global_metrics"] = list(
		"total_points" = 0,
		"total_funding" = 0,
		"breakthroughs" = 0,
		"containment_improvements" = 0,
	)
	data["milestones"] = list()
	data["rewards"] = list()
	data["test_proposals"] = list()
	data["active_tests"] = list()
	data["completed_tests"] = list()
	data["researcher_stats"] = null
	data["total_tests_conducted"] = 0
	data["total_research_earned"] = 0
	data["total_incidents_during_tests"] = 0
	data["pending_count"] = 0
	data["scp_list"] = list()
	data["subjects"] = list()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.wear_id)
			var/obj/item/card/id/id_card = H.wear_id.GetID()
			if(id_card && (ACCESS_SCIENCE in id_card.access))
				data["has_access"] = TRUE

	if(SSscp_research && SSscp_research.manager)
		var/datum/scp_research_manager/M = SSscp_research.manager

		data["global_metrics"] = list(
			"total_points" = M.total_research_points,
			"total_funding" = M.total_research_funding,
			"breakthroughs" = M.research_breakthroughs,
			"containment_improvements" = M.containment_improvements,
		)

		var/datum/researcher_data/researcher = M.get_researcher_profile(user?.ckey)
		if(istype(researcher))
			data["researcher_profile"] = list(
				"research_points" = researcher.research_points,
				"research_funding" = researcher.research_funding,
				"progression_points" = researcher.progression_points,
				"research_rank" = researcher.research_rank,
				"total_projects" = researcher.total_projects,
				"completed_projects" = researcher.completed_projects,
				"failed_projects" = researcher.failed_projects,
			)
			for(var/achievement in researcher.achievements)
				data["achievements"] += list(list("name" = "[achievement]"))
			for(var/research in researcher.completed_research)
				data["completed_research"] += list(list("name" = "[research]"))

		for(var/project_id in M.research_projects)
			var/datum/research_data/project = M.research_projects[project_id]
			if(!istype(project))
				continue
			if(project.researcher_ckey == user?.ckey && project.status == "ACTIVE")
				var/progress_percent = 0
				if(project.research_cost > 0)
					progress_percent = round((project.research_points / project.research_cost) * 100, 1)
				var/time_minutes = round((world.time - project.timestamp) / 600)
				data["active_projects"] += list(list(
					"project_id" = project_id,
					"scp_designation" = project.scp_designation,
					"research_type" = project.research_type,
					"research_level" = project.research_level,
					"max_research_level" = project.max_research_level,
					"research_points" = project.research_points,
					"research_cost" = project.research_cost,
					"progress_percent" = progress_percent,
					"time_minutes" = time_minutes,
					"discoveries" = length(project.discoveries),
				))

		for(var/milestone_id in M.research_milestones)
			var/datum/research_milestone_data/milestone = M.research_milestones[milestone_id]
			if(!istype(milestone))
				continue
			data["milestones"] += list(list(
				"milestone_id" = milestone_id,
				"name" = milestone.milestone_name,
				"description" = milestone.milestone_description,
				"completed" = milestone.completed,
				"completed_by" = milestone.completed_by ? "[milestone.completed_by]" : null,
			))

		for(var/reward_id in M.research_rewards)
			var/datum/research_reward_data/reward = M.research_rewards[reward_id]
			if(!istype(reward))
				continue
			data["rewards"] += list(list(
				"reward_id" = reward_id,
				"reward_type" = reward.reward_type,
				"reward_amount" = reward.reward_amount,
				"description" = reward.reward_description,
				"unlocked" = reward.unlocked,
			))

		data["researcher_stats"] = null
		if(researcher)
			data["researcher_stats"] = list(
				"total_proposals" = researcher.total_projects,
				"total_completed" = researcher.completed_projects,
				"total_research_earned" = researcher.research_points,
				"total_incidents" = researcher.failed_projects,
				"last_active" = time2text(world.time, "hh:mm:ss"),
			)
		data["total_tests_conducted"] = M.research_breakthroughs + M.containment_improvements
		data["total_research_earned"] = M.total_research_points
		data["pending_count"] = length(data["test_proposals"])

	if(SSscp_testing)
		data["test_proposals"] = SSscp_testing.test_proposals
		data["active_tests"] = SSscp_testing.active_tests
		var/list/recent_completed = list()
		var/completed_ids = list()
		for(var/id in SSscp_testing.completed_tests)
			completed_ids += id
		var/len = length(completed_ids)
		var/start_idx = max(1, len - 19)
		for(var/i in start_idx to len)
			var/cid = completed_ids[i]
			recent_completed[cid] = SSscp_testing.completed_tests[cid]
		data["completed_tests"] = recent_completed
		data["total_tests_conducted"] = SSscp_testing.total_tests_conducted
		data["total_research_earned"] = SSscp_testing.total_research_earned
		data["total_incidents_during_tests"] = SSscp_testing.total_incidents_during_tests
		var/pending_count = 0
		for(var/id in SSscp_testing.test_proposals)
			var/list/P = SSscp_testing.test_proposals[id]
			if(P["status"] == 0)
				pending_count++
		data["pending_count"] = pending_count

	for(var/mob/living/L in GLOB.mob_living_list)
		if(!istype(L, /mob/living/scp))
			continue
		if(L.stat == DEAD)
			continue
		var/status = "contained"
		if("containment_status" in L.vars)
			status = L.vars["containment_status"]
		data["scp_list"] += list(list("name" = L.name, "ref" = REF(L), "status" = status))

	for(var/mob/living/carbon/human/H in GLOB.mob_living_list)
		if(H.stat == DEAD)
			continue
		if(H.job != JOB_DCLASS && H.job != "D-Class Personnel")
			continue
		data["subjects"] += list(list("name" = H.real_name, "ref" = REF(H)))

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
	return SSscp_experiments?.manager?.get_default_certification(job_name)

/datum/research_laboratory_manager/proc/get_projects_data(mob/user)
	var/user_ckey = user?.ckey
	var/list/result = list()
	for(var/project_id in research_projects)
		var/list/project = research_projects[project_id]
		var/list/project_copy = project.Copy()
		project_copy["is_assigned"] = is_assigned_to_project(project_id, user_ckey)
		var/list/docs_out = list()
		for(var/list/doc in project["attached_documents"])
			docs_out += list(list(
				"doc_id" = doc["doc_id"],
				"doc_name" = doc["doc_name"],
				"attached_by_name" = doc["attached_by_name"],
				"attached_time" = doc["attached_time"],
				"content_preview" = doc["content_preview"],
			))
		project_copy["attached_documents"] = docs_out
		result[project_id] = project_copy
	if(SSscp_persistence?.manager)
		for(var/project_id in SSscp_persistence?.manager?.research_projects)
			if(result[project_id])
				continue
			var/datum/research_project/scp_proj = SSscp_persistence?.manager?.research_projects[project_id]
			if(!scp_proj)
				continue
			result[project_id] = list(
				"id" = project_id,
				"name" = scp_proj.project_name || "Unknown",
				"description" = scp_proj.description || "",
				"scp_targets" = list(),
				"research_field" = "",
				"lead_researcher" = "",
				"status" = uppertext(scp_proj.research_status || "APPROVED"),
				"progress" = scp_proj.progress || 0,
				"risk_level" = scp_proj.priority_level || 1,
				"research_points" = scp_proj.research_funding || 100,
				"team_id" = "",
				"source" = "scp_persistence",
			)
	if(SSresearch_persistence?.manager)
		for(var/project_id in SSresearch_persistence?.manager?.research_projects)
			if(result[project_id])
				continue
			var/datum/research_persistence_project/rp_proj = SSresearch_persistence?.manager?.research_projects[project_id]
			if(!rp_proj)
				continue
			result[project_id] = list(
				"id" = project_id,
				"name" = rp_proj.project_name || "Unknown",
				"description" = rp_proj.project_description || "",
				"scp_targets" = rp_proj.research_field ? list(rp_proj.research_field) : list(),
				"research_field" = rp_proj.research_field || "",
				"lead_researcher" = rp_proj.lead_researcher || "",
				"status" = uppertext(rp_proj.status || "APPROVED"),
				"progress" = rp_proj.progress || 0,
				"risk_level" = rp_proj.priority || 1,
				"research_points" = rp_proj.budget_allocated || 100,
				"budget_used" = rp_proj.budget_used || 0,
				"team_id" = "",
				"source" = "research_persistence",
			)
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
	return SSscp_experiments?.manager?.get_available_experiments(user, scp_id)

/datum/research_laboratory_manager/proc/start_scp_experiment(mob/living/carbon/human/user, scp_id, experiment_type)
	if(!SSscp_experiments || !SSscp_experiments.manager)
		return null
	return SSscp_experiments?.manager?.start_experiment(scp_id, experiment_type, user)

/datum/research_laboratory_manager/proc/suspend_scp_experiment(experiment_id, mob/user)
	if(!SSscp_experiments || !SSscp_experiments.manager)
		return FALSE
	return SSscp_experiments?.manager?.suspend_experiment(experiment_id, user)

/datum/research_laboratory_manager/proc/resume_scp_experiment(experiment_id, mob/user)
	if(!SSscp_experiments || !SSscp_experiments.manager)
		return FALSE
	return SSscp_experiments?.manager?.resume_experiment(experiment_id, user)

/datum/research_laboratory_manager/proc/terminate_scp_experiment(experiment_id, mob/user)
	if(!SSscp_experiments || !SSscp_experiments.manager)
		return FALSE
	return SSscp_experiments?.manager?.terminate_experiment(experiment_id, user)

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
			to_chat(H, span_boldnotice("RESEARCH BREAKTHROUGH: [node.name] unlocked!"))

/datum/research_laboratory_manager/proc/apply_containment_bonus(bonus)
	for(var/scp_id in SSscp_persistence?.manager?.scp_instances)
		var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances?[scp_id]
		if(instance)
			instance.containment_effectiveness = min(1.5, instance.containment_effectiveness + bonus)
			instance.containment_difficulty = max(1, instance.containment_difficulty - 1)

/datum/research_laboratory_manager/proc/apply_medical_bonus(bonus)
	if(SSscp_research?.manager)
		SSscp_research?.manager?.medical_bonus += bonus

/datum/research_laboratory_manager/proc/apply_sanity_resistance(bonus)
	if(SSscp_research?.manager)
		SSscp_research?.manager?.cognitive_bonus += bonus

/datum/research_laboratory_manager/proc/apply_research_multiplier(bonus)
	if(SSscp_research?.manager)
		SSscp_research?.manager?.research_point_multiplier += bonus

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

/datum/computer_file/program/research_laboratory
	filename = "research_lab"
	filedesc = "Research Laboratory"
	category = PROGRAM_CATEGORY_SCI
	program_icon_state = "generic"
	extended_desc = "Manage SCP experiments, research teams, technology, testing, and researcher profiles."
	size = 4
	tgui_id = "ResearchLaboratory"
	program_icon = "flask"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_SCIENCE)

/datum/computer_file/program/research_laboratory/ui_data(mob/user)
	var/list/data = get_header_data()
	if(!SSresearch_laboratory || !SSresearch_laboratory.manager)
		return data
	var/list/lab_data = SSresearch_laboratory.manager.get_all_data(user)
	data += lab_data
	return data

/datum/computer_file/program/research_laboratory/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
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
			var/list/scp_targets_list = params["scp_targets"]
			if(!islist(scp_targets_list))
				scp_targets_list = list()
			mgr.create_research_project(list(
				"name" = params["name"],
				"description" = params["description"] || "No description provided.",
				"scp_targets" = scp_targets_list,
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
			if(!mgr.can_manage(usr))
				return
			if(params["project_id"])
				var/approver = ""
				if(ishuman(ui.user))
					var/mob/living/carbon/human/H = ui.user
					approver = H.real_name
				mgr.approve_research_project(params["project_id"], approver)
			. = TRUE

		if("revoke_project")
			if(!mgr.can_manage(usr))
				return
			if(params["project_id"])
				mgr.revoke_research_project(params["project_id"])
			. = TRUE

		if("delete_project")
			if(!mgr.can_manage(usr))
				return
			if(params["project_id"])
				mgr.delete_research_project(params["project_id"])
			. = TRUE

		if("add_project_scp_target")
			if(params["project_id"] && params["scp_id"])
				mgr.add_project_scp_target(params["project_id"], params["scp_id"])
			. = TRUE

		if("remove_project_scp_target")
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
			if(scp_id && exp_type && ishuman(ui.user))
				var/mob/living/carbon/human/H = ui.user
				var/datum/scp_experiment/exp = mgr.start_scp_experiment(H, scp_id, exp_type)
				if(!exp)
					to_chat(H, span_warning("Failed to start experiment."))
				else if(SSdclass_experiments)
					SSdclass_experiments.request_test_subject(H, scp_id, "lab_experiment", 2, FALSE)
					to_chat(H, span_notice("D-Class test subject requested."))
			. = TRUE

		if("suspend_experiment")
			if(!mgr.can_manage(usr))
				return
			var/exp_id = params["experiment_id"]
			if(exp_id)
				mgr.suspend_scp_experiment(exp_id, ui.user)
			. = TRUE

		if("resume_experiment")
			if(!mgr.can_manage(usr))
				return
			var/exp_id = params["experiment_id"]
			if(exp_id)
				mgr.resume_scp_experiment(exp_id, ui.user)
			. = TRUE

		if("terminate_experiment")
			if(!mgr.can_manage(usr))
				return
			var/exp_id = params["experiment_id"]
			if(exp_id)
				mgr.terminate_scp_experiment(exp_id, ui.user)
			. = TRUE

		if("unlock_tech")
			if(!mgr.can_manage(usr))
				return
			var/node_id = params["node_id"]
			if(node_id)
				if(!mgr.unlock_tech_node(node_id, ui.user))
					to_chat(ui.user, span_warning("Cannot unlock this technology."))
			. = TRUE

		if("record_violation")
			var/protocol_id = params["protocol_id"]
			if(protocol_id)
				mgr.record_safety_violation(protocol_id)
				var/list/protocol = mgr.safety_protocols[protocol_id]
				if(protocol)
					to_chat(usr, "<span class='warning'>Safety violation recorded for [protocol["name"]]. Violations: [protocol["violations"]]/[protocol["violation_threshold"]].</span>")
					if(protocol["status"] == "emergency")
						to_chat(usr, "<span class='boldwarning'>EMERGENCY: [protocol["name"]] has exceeded its violation threshold!</span>")
			. = TRUE

		if("attach_document")
			var/project_id = params["project_id"]
			if(!project_id)
				return
			if(!ishuman(ui.user))
				return
			var/mob/living/carbon/human/H = ui.user
			var/obj/item/paper/held_paper = H.get_active_held_item()
			if(!istype(held_paper))
				to_chat(H, span_warning("Hold a paper document in your active hand to attach it."))
				return
			if(mgr.attach_document(project_id, H, held_paper))
				to_chat(H, span_notice("Document attached to project."))
			else
				to_chat(H, span_warning("Cannot attach document. You must be assigned to this project."))
			. = TRUE

		if("remove_document")
			var/project_id = params["project_id"]
			var/doc_id = params["doc_id"]
			if(!project_id || !doc_id)
				return
			if(!ishuman(ui.user))
				return
			var/mob/living/carbon/human/H = ui.user
			var/removed = mgr.remove_document(project_id, H, doc_id)
			if(removed)
				to_chat(H, span_notice("Document removed from project and placed in your hands."))
			else
				to_chat(H, span_warning("Cannot remove document. You must be assigned to this project."))
			. = TRUE

		if("eject_id")
			if(!ishuman(ui.user))
				return
			to_chat(ui.user, span_notice("ID ejection handled by the console slot."))
			. = TRUE

		if("contribute_points")
			var/project_id = params["project_id"]
			var/amount = text2num(params["amount"]) || 0
			if(!project_id || amount <= 0)
				return
			if(!SSscp_research?.manager)
				return
			if(SSscp_research.manager.contribute_research_points(project_id, amount, ui.user?.ckey))
				to_chat(ui.user, span_notice("Contributed [amount] research points to the project."))
			else
				to_chat(ui.user, span_warning("Cannot contribute points. Check available points and project status."))
			. = TRUE

		if("cancel_research")
			var/project_id = params["project_id"]
			if(!project_id)
				return
			if(!SSscp_research?.manager)
				return
			var/datum/research_data/project = SSscp_research.manager.research_projects[project_id]
			if(!project || project.researcher_ckey != ui.user?.ckey)
				return
			project.status = "CANCELLED"
			var/datum/researcher_data/researcher = SSscp_research.manager.get_researcher_profile(ui.user?.ckey)
			if(researcher)
				researcher.failed_projects++
			to_chat(ui.user, span_warning("Research project on [project.scp_designation] cancelled."))
			. = TRUE

		if("claim_reward")
			var/reward_id = params["reward_id"]
			if(!reward_id)
				return
			if(!SSscp_research?.manager)
				return
			var/datum/research_reward_data/reward = SSscp_research.manager.research_rewards[reward_id]
			if(!reward || !reward.unlocked)
				return
			to_chat(ui.user, span_notice("Reward claimed: [reward.reward_description]"))
			SSscp_research.manager.research_rewards -= reward_id
			. = TRUE

		if("submit_proposal")
			var/scp_id = params["scp_id"]
			var/test_type = params["test_type"]
			var/risk_level = text2num(params["risk_level"]) || 1
			var/subject_name = params["subject_name"] || ""
			var/description = params["description"] || ""
			if(!scp_id || !test_type)
				return
			if(!ishuman(ui.user))
				return
			var/mob/living/carbon/human/H = ui.user
			if(SSscp_testing)
				SSscp_testing.submit_test_proposal(H, scp_id, test_type, risk_level, subject_name, description)
			else if(SSscp_research?.manager)
				SSscp_research.manager.adjust_research_points(0, "testing_proposal:[H.ckey]")
				if(risk_level >= 4 && SSethics_committee)
					SSethics_committee.flag_test_for_oversight("test_[world.time]", scp_id, H.real_name, risk_level)
			to_chat(H, span_notice("Test proposal submitted for [scp_id]."))
			. = TRUE

		if("approve_proposal")
			var/proposal_id = params["proposal_id"]
			if(!proposal_id)
				return
			if(!ishuman(ui.user))
				return
			if(SSscp_testing)
				SSscp_testing.approve_proposal(proposal_id, ui.user.real_name)
			else
				to_chat(ui.user, span_notice("Test proposal approved."))
			. = TRUE

		if("reject_proposal")
			var/proposal_id = params["proposal_id"]
			if(!proposal_id)
				return
			if(SSscp_testing)
				SSscp_testing.reject_proposal(proposal_id, "Rejected via Research Laboratory")
			else
				to_chat(ui.user, span_notice("Test proposal rejected."))
			. = TRUE

		if("start_test")
			var/proposal_id = params["proposal_id"]
			if(!proposal_id)
				return
			if(!ishuman(ui.user))
				return
			if(SSscp_testing)
				SSscp_testing.start_test(proposal_id, ui.user)
			else
				to_chat(ui.user, span_notice("Test started."))
			. = TRUE

		if("execute_test")
			var/proposal_id = params["proposal_id"]
			if(!proposal_id)
				return
			if(!ishuman(ui.user))
				return
			if(SSscp_testing)
				SSscp_testing.execute_test(proposal_id, ui.user)
			else if(SSscp_research?.manager)
				SSscp_research.manager.adjust_research_points(50, "test_execution:[ui.user?.ckey || "unknown"]")
				to_chat(ui.user, span_notice("Test executed. +50 research points earned."))
			. = TRUE

		if("cancel_test")
			var/proposal_id = params["proposal_id"]
			if(!proposal_id)
				return
			if(SSscp_testing)
				SSscp_testing.cancel_test(proposal_id)
			else
				to_chat(ui.user, span_notice("Test cancelled."))
			. = TRUE

		if("print_authorization_form")
			var/project_id = params["project_id"]
			if(!project_id)
				return
			var/list/project = mgr.research_projects[project_id]
			if(!project)
				return
			var/obj/item/paper/foundation/test_authorization/P = new /obj/item/paper/foundation/test_authorization(get_turf(ui.user))
			P.autofill_from_project(project, ui.user)
			if(ishuman(ui.user))
				var/mob/living/carbon/human/H = ui.user
				H.put_in_hands(P)
			to_chat(ui.user, span_notice("Authorization form printed for [project["name"] || project_id]."))
			. = TRUE

		if("print_result_form")
			var/project_id = params["project_id"]
			if(!project_id)
				return
			var/list/project = mgr.research_projects[project_id]
			if(!project)
				return
			var/obj/item/paper/foundation/test_result/P = new /obj/item/paper/foundation/test_result(get_turf(ui.user))
			P.autofill_from_project(project, ui.user)
			if(ishuman(ui.user))
				var/mob/living/carbon/human/H = ui.user
				H.put_in_hands(P)
			to_chat(ui.user, span_notice("Result report printed for [project["name"] || project_id]."))
			. = TRUE

/client/proc/open_research_laboratory()
	set name = "Research Laboratory"
	set category = "Admin"
	set desc = "Open the advanced research laboratory system"
	if(!check_rights(R_ADMIN))
		return
	if(!SSresearch_laboratory || !SSresearch_laboratory.manager)
		to_chat(src, span_warning("Research laboratory system not available."))
		return
	var/datum/computer_file/program/research_laboratory/virtual_prog = new()
	virtual_prog.ui_interact(mob)
