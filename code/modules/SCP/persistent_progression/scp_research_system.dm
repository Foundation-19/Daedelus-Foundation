// SCP Research Incentive System
// Provides rewards and progression for researching SCPs

SUBSYSTEM_DEF(scp_research)
	name = "SCP Research"
	wait = 600 // 10 minutes
	priority = FIRE_PRIORITY_INPUT

	var/datum/scp_research_manager/manager

/datum/scp_research_manager
	var/list/research_projects = list() // project_id -> research_data
	var/list/research_rewards = list() // reward_id -> reward_data
	var/list/researcher_profiles = list() // ckey -> researcher_data
	var/list/research_milestones = list() // milestone_id -> milestone_data

	var/total_research_points = 0
	var/total_research_funding = 0
	var/research_breakthroughs = 0
	var/containment_improvements = 0
	var/classification_updates = 0

	var/research_point_multiplier = 1.0
	var/budget_reward_multiplier = 1.0
	var/progression_multiplier = 1.0

	var/containment_bonus = 0.0
	var/analysis_bonus = 0.0
	var/medical_bonus = 0.0
	var/cognitive_bonus = 0.0
	var/engineering_bonus = 0.0

	var/heal_bonus = 0.0
	var/surgery_bonus = 0.0
	var/amnestics_efficiency = 1.0
	var/breakthrough_chance_bonus = 0.0
	var/observation_yield_bonus = 0.0

/datum/research_data
	var/project_id
	var/scp_designation
	var/research_type
	var/research_level = 0
	var/max_research_level = 10
	var/research_points = 0
	var/research_cost = 1000
	var/research_time = 0
	var/researcher_ckey
	var/status = "ACTIVE"
	var/list/research_notes = list()
	var/list/discoveries = list()
	var/timestamp
	var/completion_reward = 0

/datum/research_data/New(project_id, scp_designation, research_type, researcher_ckey)
	src.project_id = project_id
	src.scp_designation = scp_designation
	src.research_type = research_type
	src.researcher_ckey = researcher_ckey
	src.timestamp = world.time

/datum/researcher_data
	var/ckey
	var/research_points = 0
	var/research_funding = 0
	var/progression_points = 0
	var/total_projects = 0
	var/completed_projects = 0
	var/failed_projects = 0
	var/research_rank = "Trainee"
	var/list/completed_research = list()
	var/list/achievements = list()
	var/list/specializations = list()
	var/timestamp

/datum/researcher_data/New(ckey)
	src.ckey = ckey
	src.timestamp = world.time

/datum/research_reward_data
	var/reward_id
	var/reward_type
	var/reward_amount = 0
	var/reward_description = ""
	var/requirements = list()
	var/unlocked = FALSE
	var/timestamp

/datum/research_reward_data/New(reward_id, reward_type, reward_amount, reward_description)
	src.reward_id = reward_id
	src.reward_type = reward_type
	src.reward_amount = reward_amount
	src.reward_description = reward_description
	src.timestamp = world.time

/datum/research_milestone_data
	var/milestone_id
	var/milestone_name
	var/milestone_description
	var/requirements = list()
	var/rewards = list()
	var/completed = FALSE
	var/completion_time
	var/completed_by

/datum/research_milestone_data/New(milestone_id, milestone_name, milestone_description)
	src.milestone_id = milestone_id
	src.milestone_name = milestone_name
	src.milestone_description = milestone_description

/datum/scp_research_manager/proc/initialize_research_system()
	initialize_research_rewards()
	initialize_research_milestones()
	world.log << "SCP Research: Research system initialized with [length(research_rewards)] rewards and [length(research_milestones) + 1] milestones"

/datum/scp_research_manager/proc/initialize_research_rewards()
	add_research_reward("budget_1000", "budget", 1000, "Research Grant: Basic funding for SCP research", list("completed_projects" = 1))
	add_research_reward("budget_5000", "budget", 5000, "Research Grant: Substantial funding for advanced research", list("completed_projects" = 5))
	add_research_reward("budget_10000", "budget", 10000, "Research Grant: Major funding for breakthrough research", list("completed_projects" = 10))
	add_research_reward("progression_100", "progression", 100, "Research Experience: Basic research skills", list("total_projects" = 3))
	add_research_reward("progression_500", "progression", 500, "Research Experience: Advanced research methodology", list("completed_projects" = 7))
	add_research_reward("progression_1000", "progression", 1000, "Research Experience: Expert research techniques", list("completed_projects" = 15))
	add_research_reward("equipment_scanner", "equipment", 1, "Advanced SCP Scanner: Enhanced detection capabilities", list("completed_projects" = 2))
	add_research_reward("equipment_analyzer", "equipment", 1, "SCP Analyzer: Detailed SCP property analysis", list("completed_projects" = 5))
	add_research_reward("equipment_containment", "equipment", 1, "Containment Tools: Improved SCP containment methods", list("completed_projects" = 8))

/datum/scp_research_manager/proc/initialize_research_milestones()
	add_research_milestone("first_research", "First Research Project", "Complete your first SCP research project")
	add_research_milestone("research_10", "Dedicated Researcher", "Complete 10 research projects")
	add_research_milestone("research_50", "Research Expert", "Complete 50 research projects")
	add_research_milestone("research_100", "Research Master", "Complete 100 research projects")
	add_research_milestone("first_breakthrough", "First Breakthrough", "Achieve your first research breakthrough")
	add_research_milestone("breakthrough_5", "Breakthrough Specialist", "Achieve 5 research breakthroughs")
	add_research_milestone("breakthrough_10", "Breakthrough Master", "Achieve 10 research breakthroughs")

/datum/scp_research_manager/proc/add_research_reward(reward_id, reward_type, reward_amount, reward_description, reqs)
	var/datum/research_reward_data/reward = new(reward_id, reward_type, reward_amount, reward_description)
	if(reqs)
		reward.requirements = reqs
	research_rewards[reward_id] = reward

/datum/scp_research_manager/proc/add_research_milestone(milestone_id, milestone_name, milestone_description)
	var/datum/research_milestone_data/milestone = new(milestone_id, milestone_name, milestone_description)
	research_milestones[milestone_id] = milestone

/datum/scp_research_manager/proc/adjust_research_points(amount, reason)
	if(amount > 0)
		amount = round(amount * research_point_multiplier)
	var/old = total_research_points
	total_research_points = max(0, total_research_points + amount)
	log_game("SCP Research: Points adjusted by [amount] ([reason]). [old] -> [total_research_points]")
	return total_research_points

/datum/scp_research_manager/proc/start_research_project(scp_designation, research_type, researcher_ckey)
	var/project_id = "research_[scp_designation]_[research_type]_[world.time]"
	var/datum/research_data/project = new(project_id, scp_designation, research_type, researcher_ckey)
	research_projects[project_id] = project
	var/datum/researcher_data/researcher = get_researcher_profile(researcher_ckey)
	researcher.total_projects++
	world.log << "SCP Research: Research project [project_id] started by [researcher_ckey]"
	return project

/datum/scp_research_manager/proc/contribute_research_points(project_id, points, researcher_ckey)
	var/datum/research_data/project = research_projects[project_id]
	if(!project || project.status != "ACTIVE")
		return FALSE
	if(points <= 0)
		return FALSE
	if(total_research_points < points)
		return FALSE
	total_research_points -= points
	return add_research_points(project_id, points, researcher_ckey)

/datum/scp_research_manager/proc/get_researcher_profile(ckey)
	if(!researcher_profiles[ckey])
		researcher_profiles[ckey] = new /datum/researcher_data(ckey)
	return researcher_profiles[ckey]

/datum/scp_research_manager/proc/add_research_points(project_id, points, researcher_ckey)
	var/datum/research_data/project = research_projects[project_id]
	if(!project)
		return FALSE

	project.research_points += points * research_point_multiplier
	project.research_time = world.time - project.timestamp

	var/old_level = project.research_level
	project.research_level = min(project.max_research_level, floor(project.research_points / 100))

	if(project.research_level > old_level)
		on_research_level_up(project, researcher_ckey)
		check_cross_interaction_discoveries(project.scp_designation, researcher_ckey)

	var/datum/researcher_data/researcher = get_researcher_profile(researcher_ckey)
	researcher.research_points += points * research_point_multiplier

	if(project.research_points >= project.research_cost && project.status == "ACTIVE")
		complete_research_project(project_id, researcher_ckey)

	return TRUE

/datum/scp_research_manager/proc/on_research_level_up(datum/research_data/project, researcher_ckey)
	var/datum/researcher_data/researcher = get_researcher_profile(researcher_ckey)
	var/level_reward = project.research_level * 100
	researcher.research_points += level_reward
	notify_researcher(researcher_ckey, "Research Level Up!", "Your research on [project.scp_designation] has reached level [project.research_level]! +[level_reward] research points")
	world.log << "SCP Research: [researcher_ckey] reached research level [project.research_level] on [project.scp_designation]"

/datum/scp_research_manager/proc/complete_research_project(project_id, researcher_ckey)
	var/datum/research_data/project = research_projects[project_id]
	if(!project || project.status != "ACTIVE")
		return FALSE

	project.status = "COMPLETED"
	project.completion_reward = calculate_completion_reward(project)

	var/datum/researcher_data/researcher = get_researcher_profile(researcher_ckey)
	researcher.completed_projects++
	researcher.research_points += project.completion_reward
	researcher.completed_research += project.scp_designation

	total_research_points += project.completion_reward

	var/budget_reward = project.completion_reward * budget_reward_multiplier
	if(SSbudget_system && SSbudget_system.manager)
		SSbudget_system.manager.add_transaction("research", "REVENUE", budget_reward, "research_funding", "Research completion: [project.scp_designation] - [project.research_type]", researcher_ckey)

	var/progression_reward = project.completion_reward * progression_multiplier
	researcher.progression_points += progression_reward

	if(project.research_level >= 5)
		research_breakthroughs++
		notify_researcher(researcher_ckey, "Research Breakthrough!", "You've achieved a breakthrough in [project.scp_designation] research!")

	update_researcher_rank(researcher)
	check_research_milestones(researcher_ckey)
	check_reward_unlocks(researcher_ckey)
	notify_researcher(researcher_ckey, "Research Complete!", "Research on [project.scp_designation] completed! +[project.completion_reward] research points, +[budget_reward] budget, +[progression_reward] progression")

	world.log << "SCP Research: [researcher_ckey] completed research on [project.scp_designation]"
	return TRUE

/datum/scp_research_manager/proc/calculate_completion_reward(datum/research_data/project)
	var/base_reward = 500
	var/level_bonus = project.research_level * 100
	var/time_bonus = min(1000, (world.time - project.timestamp) / 600)
	return base_reward + level_bonus + time_bonus

/datum/scp_research_manager/proc/update_researcher_rank(datum/researcher_data/researcher)
	var/points = researcher.research_points
	if(points >= 50000)
		researcher.research_rank = "Research Director"
	else if(points >= 25000)
		researcher.research_rank = "Lead Researcher"
	else if(points >= 10000)
		researcher.research_rank = "Senior Researcher"
	else if(points >= 5000)
		researcher.research_rank = "Researcher"
	else if(points >= 1000)
		researcher.research_rank = "Junior Researcher"
	else
		researcher.research_rank = "Trainee"

/datum/scp_research_manager/proc/check_reward_unlocks(researcher_ckey)
	var/datum/researcher_data/researcher = get_researcher_profile(researcher_ckey)
	for(var/reward_id in research_rewards)
		var/datum/research_reward_data/reward = research_rewards[reward_id]
		if(reward.unlocked)
			continue
		var/meets = TRUE
		if(reward.requirements)
			for(var/req_key in reward.requirements)
				var/req_val = reward.requirements[req_key]
				switch(req_key)
					if("completed_projects")
						if(researcher.completed_projects < req_val)
							meets = FALSE
					if("total_projects")
						if(researcher.total_projects < req_val)
							meets = FALSE
					if("research_points")
						if(researcher.research_points < req_val)
							meets = FALSE
		if(meets)
			reward.unlocked = TRUE
			notify_researcher(researcher_ckey, "Reward Unlocked!", "[reward.reward_description] is now available to claim!")

/datum/scp_research_manager/proc/check_research_milestones(researcher_ckey)
	var/datum/researcher_data/researcher = get_researcher_profile(researcher_ckey)
	for(var/milestone_id in research_milestones)
		var/datum/research_milestone_data/milestone = research_milestones[milestone_id]
		if(milestone.completed)
			continue
		var/completed = FALSE
		switch(milestone_id)
			if("first_research")
				completed = researcher.completed_projects >= 1
			if("research_10")
				completed = researcher.completed_projects >= 10
			if("research_50")
				completed = researcher.completed_projects >= 50
			if("research_100")
				completed = researcher.completed_projects >= 100
			if("first_breakthrough")
				completed = research_breakthroughs >= 1
			if("breakthrough_5")
				completed = research_breakthroughs >= 5
			if("breakthrough_10")
				completed = research_breakthroughs >= 10
		if(completed)
			complete_milestone(milestone_id, researcher_ckey)

/datum/scp_research_manager/proc/complete_milestone(milestone_id, researcher_ckey)
	var/datum/research_milestone_data/milestone = research_milestones[milestone_id]
	var/datum/researcher_data/researcher = get_researcher_profile(researcher_ckey)
	milestone.completed = TRUE
	milestone.completion_time = world.time
	milestone.completed_by = researcher_ckey
	var/milestone_reward = 1000
	researcher.research_points += milestone_reward
	researcher.achievements += milestone.milestone_name
	notify_researcher(researcher_ckey, "Milestone Achieved!", "[milestone.milestone_name]: [milestone.milestone_description] +[milestone_reward] research points")
	world.log << "SCP Research: [researcher_ckey] achieved milestone [milestone.milestone_name]"

/datum/scp_research_manager/proc/notify_researcher(ckey, title, message)
	for(var/client/C in GLOB.clients)
		if(C.ckey == ckey)
			to_chat(C, "<span class='notice'><b>[title]</b>: [message]</span>")
			break

/datum/scp_research_manager/proc/apply_tech_bonuses(node_id)
	switch(node_id)
		if("basic_containment")
			containment_bonus += 0.05
		if("basic_analysis")
			analysis_bonus += 0.05
			observation_yield_bonus += 0.1
		if("basic_medical")
			medical_bonus += 0.05
			heal_bonus += 0.05
		if("pathogen_identification")
			medical_bonus += 0.05
		if("improved_containment")
			containment_bonus += 0.1
			apply_containment_improvement(0.1)
		if("advanced_analysis")
			analysis_bonus += 0.1
			observation_yield_bonus += 0.2
		if("cognitive_shielding")
			cognitive_bonus += 0.1
			breakthrough_chance_bonus += 1
		if("anomalous_surgery")
			medical_bonus += 0.1
			surgery_bonus += 0.1
		if("bsl3_protocols")
			medical_bonus += 0.1
		if("anomalous_virology")
			medical_bonus += 0.1
			analysis_bonus += 0.05
		if("containment_reinforcement")
			containment_bonus += 0.15
			apply_containment_improvement(0.15)
		if("amnestics_production")
			amnestics_efficiency += 0.3
			cognitive_bonus += 0.05
		if("pattern_recognition")
			analysis_bonus += 0.15
			breakthrough_chance_bonus += 2
		if("memetic_countermeasures")
			cognitive_bonus += 0.15
			breakthrough_chance_bonus += 1
		if("containment_engineering")
			engineering_bonus += 0.15
			containment_bonus += 0.05
		if("bsl4_containment")
			medical_bonus += 0.15
			containment_bonus += 0.05
		if("anomalous_cure_development")
			medical_bonus += 0.2
			heal_bonus += 0.1
		if("keter_protocols")
			containment_bonus += 0.2
			apply_containment_improvement(0.2)
		if("reality_anchor_theory")
			engineering_bonus += 0.2
			cognitive_bonus += 0.1
		if("telekill_alloy")
			cognitive_bonus += 0.2
			breakthrough_chance_bonus += 3
		if("scp_weaponization")
			containment_bonus += 0.1
			engineering_bonus += 0.1
		if("bioweapon_countermeasures")
			medical_bonus += 0.2
			containment_bonus += 0.1
		if("apollyon_protocols")
			containment_bonus += 0.3
			apply_containment_improvement(0.1)
		if("project_overwatch")
			analysis_bonus += 0.3
			observation_yield_bonus += 0.5
		if("xk_biodefense")
			medical_bonus += 0.3
			containment_bonus += 0.1

/datum/scp_research_manager/proc/apply_containment_improvement(bonus)
	containment_improvements++
	for(var/scp_id in SSscp_persistence?.manager?.scp_instances)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[scp_id]
		if(instance)
			instance.containment_effectiveness = min(1.0, instance.containment_effectiveness + bonus)
			instance.containment_difficulty = max(1, instance.containment_difficulty - 1)

/datum/controller/subsystem/scp_research/Initialize()
	world.log << "SCP Research system initializing..."
	manager = new /datum/scp_research_manager()
	manager.initialize_research_system()
	manager.load_research_persistence()
	world.log << "SCP Research system initialized"
	return ..()

/datum/controller/subsystem/scp_research/fire()
	if(manager)
		manager.process_research_projects()

/datum/scp_research_manager/proc/process_research_projects()
	for(var/project_id in research_projects)
		var/datum/research_data/project = research_projects[project_id]
		if(project.status == "ACTIVE")
			var/mob/living/carbon/human/researcher = get_researcher_by_ckey(project.researcher_ckey)
			if(!researcher)
				continue
			var/progress_rate = 1.0 + observation_yield_bonus + (researcher.job == "Scientist" ? 0.5 : 0) + (researcher.job == "Research Director" ? 1.0 : 0)
			project.research_points += progress_rate
			project.research_time = world.time - project.timestamp
			var/old_level = project.research_level
			project.research_level = min(project.max_research_level, floor(project.research_points / 100))
			if(project.research_level > old_level)
				on_research_level_up(project, project.researcher_ckey)
			if(project.research_points >= project.research_cost)
				complete_research_project(project_id, project.researcher_ckey)
			else if(prob(2 + breakthrough_chance_bonus))
				research_breakthroughs++
				project.discoveries += list(list("timestamp" = world.time, "type" = "passive_breakthrough", "description" = "Breakthrough in [project.scp_designation]"))
				notify_researcher(project.researcher_ckey, "Breakthrough!", "Passive breakthrough in [project.scp_designation] research!")

/datum/scp_research_manager/proc/get_researcher_by_ckey(ckey)
	for(var/mob/living/carbon/human/H in GLOB.mob_list)
		if(QDELETED(H))
			continue
		if(H.ckey == ckey)
			return H
	return null

/datum/scp_research_manager/proc/save_research_persistence()
	var/list/data = list()
	data["total_research_points"] = total_research_points
	data["total_research_funding"] = total_research_funding
	data["research_breakthroughs"] = research_breakthroughs
	data["containment_improvements"] = containment_improvements
	data["classification_updates"] = classification_updates
	data["containment_bonus"] = containment_bonus
	data["analysis_bonus"] = analysis_bonus
	data["medical_bonus"] = medical_bonus
	data["cognitive_bonus"] = cognitive_bonus
	data["engineering_bonus"] = engineering_bonus
	data["heal_bonus"] = heal_bonus
	data["surgery_bonus"] = surgery_bonus
	data["amnestics_efficiency"] = amnestics_efficiency
	data["breakthrough_chance_bonus"] = breakthrough_chance_bonus
	data["observation_yield_bonus"] = observation_yield_bonus

	data["researcher_profiles"] = list()
	for(var/ckey in researcher_profiles)
		var/datum/researcher_data/rd = researcher_profiles[ckey]
		data["researcher_profiles"][ckey] = list(
			"research_points" = rd.research_points,
			"research_funding" = rd.research_funding,
			"progression_points" = rd.progression_points,
			"total_projects" = rd.total_projects,
			"completed_projects" = rd.completed_projects,
			"failed_projects" = rd.failed_projects,
			"research_rank" = rd.research_rank,
			"completed_research" = rd.completed_research,
			"achievements" = rd.achievements,
			"specializations" = rd.specializations,
		)

	data["research_milestones"] = list()
	for(var/milestone_id in research_milestones)
		var/datum/research_milestone_data/milestone = research_milestones[milestone_id]
		data["research_milestones"][milestone_id] = list(
			"completed" = milestone.completed,
			"completion_time" = milestone.completion_time,
			"completed_by" = milestone.completed_by,
		)

	data["research_rewards"] = list()
	for(var/reward_id in research_rewards)
		var/datum/research_reward_data/reward = research_rewards[reward_id]
		data["research_rewards"][reward_id] = list(
			"unlocked" = reward.unlocked,
		)

	var/json_data = json_encode(data)
	var/savefile/S = new /savefile("data/scp_research_persistence.json")
	S["data"] << json_data

/datum/scp_research_manager/proc/load_research_persistence()
	var/savefile/S = new /savefile("data/scp_research_persistence.json")
	if(!S["data"])
		return
	var/json_data
	S["data"] >> json_data
	var/list/data = json_decode(json_data)
	if(!data)
		return

	total_research_points = data["total_research_points"] || 0
	total_research_funding = data["total_research_funding"] || 0
	research_breakthroughs = data["research_breakthroughs"] || 0
	containment_improvements = data["containment_improvements"] || 0
	classification_updates = data["classification_updates"] || 0
	containment_bonus = data["containment_bonus"] || 0
	analysis_bonus = data["analysis_bonus"] || 0
	medical_bonus = data["medical_bonus"] || 0
	cognitive_bonus = data["cognitive_bonus"] || 0
	engineering_bonus = data["engineering_bonus"] || 0
	heal_bonus = data["heal_bonus"] || 0
	surgery_bonus = data["surgery_bonus"] || 0
	amnestics_efficiency = data["amnestics_efficiency"] || 1.0
	breakthrough_chance_bonus = data["breakthrough_chance_bonus"] || 0
	observation_yield_bonus = data["observation_yield_bonus"] || 0

	if(data["researcher_profiles"])
		for(var/ckey in data["researcher_profiles"])
			var/list/profile = data["researcher_profiles"][ckey]
			var/datum/researcher_data/rd = get_researcher_profile(ckey)
			rd.research_points = profile["research_points"] || 0
			rd.research_funding = profile["research_funding"] || 0
			rd.progression_points = profile["progression_points"] || 0
			rd.total_projects = profile["total_projects"] || 0
			rd.completed_projects = profile["completed_projects"] || 0
			rd.failed_projects = profile["failed_projects"] || 0
			rd.research_rank = profile["research_rank"] || "Trainee"
			rd.completed_research = profile["completed_research"] || list()
			rd.achievements = profile["achievements"] || list()
			rd.specializations = profile["specializations"] || list()

	if(data["research_milestones"])
		for(var/milestone_id in data["research_milestones"])
			var/list/mdata = data["research_milestones"][milestone_id]
			var/datum/research_milestone_data/milestone = research_milestones[milestone_id]
			if(milestone)
				milestone.completed = mdata["completed"] || FALSE
				milestone.completion_time = mdata["completion_time"]
				milestone.completed_by = mdata["completed_by"]

	if(data["research_rewards"])
		for(var/reward_id in data["research_rewards"])
			var/list/rdata = data["research_rewards"][reward_id]
			var/datum/research_reward_data/reward = research_rewards[reward_id]
			if(reward)
				reward.unlocked = rdata["unlocked"] || FALSE

	world.log << "SCP Research: Loaded persistence data"

/proc/award_research_points(scp_designation, research_type, points, researcher_ckey)
	if(SSscp_research && SSscp_research.manager)
		var/project_id = "research_[scp_designation]_[research_type]_[researcher_ckey]"
		if(!SSscp_research.manager.research_projects[project_id])
			SSscp_research.manager.start_research_project(scp_designation, research_type, researcher_ckey)
		return SSscp_research.manager.add_research_points(project_id, points, researcher_ckey)
	return FALSE

/proc/get_researcher_data(ckey)
	if(SSscp_research && SSscp_research.manager)
		return SSscp_research.manager.get_researcher_profile(ckey)
	return null

/proc/check_research_achievements(ckey)
	if(SSscp_research && SSscp_research.manager)
		SSscp_research.manager.check_research_milestones(ckey)

/proc/adjust_global_research_points(amount, reason)
	if(SSscp_research && SSscp_research.manager)
		return SSscp_research.manager.adjust_research_points(amount, reason)
	return 0

/mob/proc/view_research_status()
	set name = "View Research Status"
	set category = "Research"
	set desc = "View your current research status and achievements."

	if(!SSscp_research || !SSscp_research.manager)
		to_chat(src, "<span class='warning'>Research system not available.</span>")
		return

	var/datum/researcher_data/researcher = get_researcher_data(ckey)
	if(!researcher)
		to_chat(src, "<span class='notice'>You haven't started any research projects yet.</span>")
		return

	to_chat(src, "<span class='notice'><b>=== RESEARCH STATUS ===</b></span>")
	to_chat(src, "<span class='notice'>Research Points: [researcher.research_points]</span>")
	to_chat(src, "<span class='notice'>Research Funding: [researcher.research_funding]</span>")
	to_chat(src, "<span class='notice'>Progression Points: [researcher.progression_points]</span>")
	to_chat(src, "<span class='notice'>Research Rank: [researcher.research_rank]</span>")
	to_chat(src, "<span class='notice'>Total Projects: [researcher.total_projects]</span>")
	to_chat(src, "<span class='notice'>Completed Projects: [researcher.completed_projects]</span>")
	to_chat(src, "<span class='notice'>Failed Projects: [researcher.failed_projects]</span>")

	if(length(researcher.achievements) > 0)
		to_chat(src, "<span class='notice'><b>Achievements:</b></span>")
		for(var/achievement in researcher.achievements)
			to_chat(src, "<span class='notice'>- [achievement]</span>")

	if(length(researcher.completed_research) > 0)
		to_chat(src, "<span class='notice'><b>Completed Research:</b></span>")
		for(var/research in researcher.completed_research)
			to_chat(src, "<span class='notice'>- [research]</span>")

/mob/proc/view_research_projects()
	set name = "View Research Projects"
	set category = "Research"
	set desc = "View your active research projects."

	if(!SSscp_research || !SSscp_research.manager)
		to_chat(src, "<span class='warning'>Research system not available.</span>")
		return

	var/found_projects = FALSE
	to_chat(src, "<span class='notice'><b>=== ACTIVE RESEARCH PROJECTS ===</b></span>")

	for(var/project_id in SSscp_research.manager.research_projects)
		var/datum/research_data/project = SSscp_research.manager.research_projects[project_id]
		if(project.researcher_ckey == ckey && project.status == "ACTIVE")
			found_projects = TRUE
			to_chat(src, "<span class='notice'>[project.scp_designation] - [project.research_type]</span>")
			to_chat(src, "<span class='notice'>  Level: [project.research_level]/[project.max_research_level]</span>")
			to_chat(src, "<span class='notice'>  Points: [project.research_points]/[project.research_cost]</span>")
			to_chat(src, "<span class='notice'>  Time: [round((world.time - project.timestamp) / 600)] minutes</span>")

	if(!found_projects)
		to_chat(src, "<span class='notice'>No active research projects.</span>")
