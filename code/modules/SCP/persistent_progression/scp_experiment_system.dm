#define EXPERIMENT_PHASE_PREPARATION 1
#define EXPERIMENT_PHASE_EXECUTION 2
#define EXPERIMENT_PHASE_OBSERVATION 3
#define EXPERIMENT_PHASE_CONCLUSION 4

#define EXPERIMENT_OUTCOME_SUCCESS_MAJOR 1
#define EXPERIMENT_OUTCOME_SUCCESS 2
#define EXPERIMENT_OUTCOME_SUCCESS_MINOR 3
#define EXPERIMENT_OUTCOME_NEUTRAL 4
#define EXPERIMENT_OUTCOME_FAILURE_MINOR 5
#define EXPERIMENT_OUTCOME_FAILURE 6
#define EXPERIMENT_OUTCOME_FAILURE_MAJOR 7
#define EXPERIMENT_OUTCOME_CATASTROPHIC 8

#ifndef EXPERIMENT_TYPE_BEHAVIORAL
#define EXPERIMENT_TYPE_BEHAVIORAL 1
#define EXPERIMENT_TYPE_CONTAINMENT 2
#define EXPERIMENT_TYPE_INTERACTION 3
#define EXPERIMENT_TYPE_HAZARD 4
#define EXPERIMENT_TYPE_MEDICAL 5
#define EXPERIMENT_TYPE_TECHNICAL 6
#define EXPERIMENT_TYPE_COGNITIVE 7
#define EXPERIMENT_TYPE_EXPLORATION 8
#define EXPERIMENT_TYPE_CARE 9
#define EXPERIMENT_TYPE_OBSERVATION 10

#define EXPERIMENT_RISK_MINIMAL 1
#define EXPERIMENT_RISK_LOW 2
#define EXPERIMENT_RISK_MEDIUM 3
#define EXPERIMENT_RISK_HIGH 4
#define EXPERIMENT_RISK_CRITICAL 5
#endif

#define EXPERIMENT_ACCESS_NONE 0
#define EXPERIMENT_ACCESS_OBSERVE 1
#define EXPERIMENT_ACCESS_ASSIST 2
#define EXPERIMENT_ACCESS_STANDARD 3
#define EXPERIMENT_ACCESS_ADVANCED 4
#define EXPERIMENT_ACCESS_FULL 5

SUBSYSTEM_DEF(scp_experiments)
	name = "SCP Experiments"
	wait = 600
	priority = FIRE_PRIORITY_INPUT
	var/datum/scp_experiment_manager/manager

/datum/controller/subsystem/scp_experiments/Initialize()
	manager = new /datum/scp_experiment_manager()
	manager.initialize_experiments()
	world.log << "SCP Experiment System: Initialized"
	return ..()

/datum/controller/subsystem/scp_experiments/fire()
	if(manager)
		manager.process_experiments()

/datum/scp_experiment_manager
	var/list/active_experiments = list()
	var/list/experiment_templates = list()
	var/list/completed_experiments = list()
	var/list/researcher_certifications = list()
	var/list/experiment_cooldowns = list()
	
	var/global_experiment_count = 0
	var/global_success_count = 0
	var/global_failure_count = 0
	var/global_catastrophe_count = 0
	
	var/experiment_xp_multiplier = 1.0
	var/experiment_reward_multiplier = 1.0

/datum/scp_experiment_manager/proc/initialize_experiments()
	load_experiment_templates()
	initialize_certifications()
	world.log << "SCP Experiment Manager: Loaded [length(experiment_templates)] experiment templates"

/datum/scp_experiment_manager/proc/load_experiment_templates()
	initialize_all_scp_experiments()
	world.log << "SCP Experiment Manager: Template loading initialized"

/datum/scp_experiment_manager/proc/initialize_certifications()
	for(var/job in list("Scientist", "Research Director", "Senior Researcher", "Research Assistant", 
						"Medical Doctor", "Chief Medical Officer", "Security Officer", "Site Director",
						"Engineer", "Containment Specialist"))
		researcher_certifications[job] = get_default_certification(job)

/datum/scp_experiment_manager/proc/get_default_certification(job)
	switch(job)
		if("Research Director")
			return EXPERIMENT_ACCESS_FULL
		if("Scientist")
			return EXPERIMENT_ACCESS_FULL
		if("Senior Researcher")
			return EXPERIMENT_ACCESS_ADVANCED
		if("Research Assistant")
			return EXPERIMENT_ACCESS_ASSIST
		if("Medical Doctor", "Chief Medical Officer")
			return EXPERIMENT_ACCESS_STANDARD
		if("Engineer")
			return EXPERIMENT_ACCESS_STANDARD
		if("Containment Specialist")
			return EXPERIMENT_ACCESS_ADVANCED
		if("Security Officer")
			return EXPERIMENT_ACCESS_OBSERVE
		if("Site Director")
			return EXPERIMENT_ACCESS_FULL
		else
			return EXPERIMENT_ACCESS_NONE

/datum/scp_experiment_manager/proc/process_experiments()
	for(var/exp_id in active_experiments)
		var/datum/scp_experiment/exp = active_experiments[exp_id]
		if(exp && exp.status == "active")
			exp.process_experiment()

/datum/scp_experiment_manager/proc/can_conduct_experiment(mob/living/carbon/human/user, experiment_type, scp_class, risk_level)
	if(!user || !user.mind)
		return EXPERIMENT_ACCESS_NONE
	
	var/job = user.job
	var/certification = researcher_certifications[job] || EXPERIMENT_ACCESS_NONE
	
	if(certification == EXPERIMENT_ACCESS_NONE)
		return EXPERIMENT_ACCESS_NONE
	
	if(risk_level >= EXPERIMENT_RISK_CRITICAL && certification < EXPERIMENT_ACCESS_FULL)
		return EXPERIMENT_ACCESS_OBSERVE
	
	if(risk_level >= EXPERIMENT_RISK_HIGH && certification < EXPERIMENT_ACCESS_ADVANCED)
		return EXPERIMENT_ACCESS_ASSIST
	
	if(experiment_type == EXPERIMENT_TYPE_MEDICAL)
		if(!(job in list("Medical Doctor", "Chief Medical Officer", "Scientist", "Research Director")))
			return EXPERIMENT_ACCESS_OBSERVE
	
	if(experiment_type == EXPERIMENT_TYPE_TECHNICAL)
		if(!(job in list("Engineer", "Scientist", "Research Director")))
			return EXPERIMENT_ACCESS_ASSIST
	
	return certification

/datum/scp_experiment_manager/proc/get_xp_modifier(mob/living/carbon/human/user, access_level)
	var/modifier = 1.0
	
	switch(access_level)
		if(EXPERIMENT_ACCESS_FULL)
			modifier = 1.0
		if(EXPERIMENT_ACCESS_ADVANCED)
			modifier = 0.9
		if(EXPERIMENT_ACCESS_STANDARD)
			modifier = 0.75
		if(EXPERIMENT_ACCESS_ASSIST)
			modifier = 0.5
		if(EXPERIMENT_ACCESS_OBSERVE)
			modifier = 0.25
		else
			modifier = 0.0
	
	return modifier * experiment_xp_multiplier

/datum/scp_experiment_manager/proc/start_experiment(scp_id, experiment_type, mob/living/carbon/human/researcher)
	if(!researcher || !researcher.ckey)
		return null
	
	var/datum/scp_experiment_template/template = get_experiment_template(scp_id, experiment_type)
	if(!template)
		return null
	
	var/access = can_conduct_experiment(researcher, experiment_type, template.scp_class, template.risk_level)
	if(access < EXPERIMENT_ACCESS_STANDARD)
		to_chat(researcher, "<span class='warning'>You are not certified to conduct this experiment.</span>")
		return null
	
	var/cooldown_key = "[researcher.ckey]_[scp_id]_[experiment_type]"
	if(experiment_cooldowns[cooldown_key] && world.time < experiment_cooldowns[cooldown_key])
		var/remaining = (experiment_cooldowns[cooldown_key] - world.time) / 600
		to_chat(researcher, "<span class='warning'>This experiment is on cooldown for [round(remaining, 0.1)] more minutes.</span>")
		return null
	
	var/exp_id = "exp_[scp_id]_[experiment_type]_[global_experiment_count]"
	var/datum/scp_experiment/experiment = new(exp_id, template, researcher)
	experiment.access_level = access
	
	active_experiments[exp_id] = experiment
	global_experiment_count++
	hook_scp_experiment(researcher, scp_id, experiment_type)
	
	SSscp_persistence.manager?.scp_instances?[scp_id]?.add_interaction_record(researcher, "experiment_started:[experiment_type]")
	
	to_chat(researcher, "<span class='notice'>Experiment [experiment.name] has begun. Phase: Preparation.</span>")
	
	return experiment

/datum/scp_experiment_manager/proc/get_experiment_template(scp_id, experiment_type)
	for(var/template_id in experiment_templates)
		var/datum/scp_experiment_template/T = experiment_templates[template_id]
		if(T.scp_id == scp_id && T.experiment_type == experiment_type)
			return T
	return null

/datum/scp_experiment_manager/proc/complete_experiment(exp_id, outcome, mob/living/carbon/human/researcher)
	var/datum/scp_experiment/exp = active_experiments[exp_id]
	if(!exp)
		return FALSE
	
	var/xp_modifier = get_xp_modifier(researcher, exp.access_level)
	var/xp_change = calculate_xp_change(outcome, xp_modifier)
	var/reward_modifier = calculate_reward_modifier(outcome)
	
	apply_experiment_results(exp, researcher, outcome, xp_change, reward_modifier)
	
	exp.status = "completed"
	exp.outcome = outcome
	exp.completion_time = world.time
	
	completed_experiments[exp_id] = exp
	active_experiments -= exp_id
	
	var/cooldown_key = "[researcher.ckey]_[exp.scp_id]_[exp.experiment_type]"
	experiment_cooldowns[cooldown_key] = world.time + exp.cooldown_time
	
	switch(outcome)
		if(EXPERIMENT_OUTCOME_SUCCESS_MAJOR, EXPERIMENT_OUTCOME_SUCCESS, EXPERIMENT_OUTCOME_SUCCESS_MINOR)
			global_success_count++
		if(EXPERIMENT_OUTCOME_FAILURE_MINOR, EXPERIMENT_OUTCOME_FAILURE, EXPERIMENT_OUTCOME_FAILURE_MAJOR)
			global_failure_count++
		if(EXPERIMENT_OUTCOME_CATASTROPHIC)
			global_catastrophe_count++
			trigger_catastrophe(exp, researcher)
	
	SSscp_persistence.manager?.scp_instances?[exp.scp_id]?.add_interaction_record(researcher, "experiment_completed:[outcome]")
	adjust_global_research_points(max(0, xp_change), "experiment_completion:[exp.scp_id]")
	track_scp_interaction(researcher, exp.scp_id, "experiment", outcome)

	return TRUE

/datum/scp_experiment_manager/proc/calculate_xp_change(outcome, modifier)
	var/base_xp = 0
	switch(outcome)
		if(EXPERIMENT_OUTCOME_SUCCESS_MAJOR)
			base_xp = 200
		if(EXPERIMENT_OUTCOME_SUCCESS)
			base_xp = 100
		if(EXPERIMENT_OUTCOME_SUCCESS_MINOR)
			base_xp = 50
		if(EXPERIMENT_OUTCOME_NEUTRAL)
			base_xp = 0
		if(EXPERIMENT_OUTCOME_FAILURE_MINOR)
			base_xp = -25
		if(EXPERIMENT_OUTCOME_FAILURE)
			base_xp = -50
		if(EXPERIMENT_OUTCOME_FAILURE_MAJOR)
			base_xp = -100
		if(EXPERIMENT_OUTCOME_CATASTROPHIC)
			base_xp = -200
	
	return round(base_xp * modifier)

/datum/scp_experiment_manager/proc/calculate_reward_modifier(outcome)
	switch(outcome)
		if(EXPERIMENT_OUTCOME_SUCCESS_MAJOR)
			return 1.5
		if(EXPERIMENT_OUTCOME_SUCCESS)
			return 1.25
		if(EXPERIMENT_OUTCOME_SUCCESS_MINOR)
			return 1.1
		if(EXPERIMENT_OUTCOME_NEUTRAL)
			return 1.0
		if(EXPERIMENT_OUTCOME_FAILURE_MINOR)
			return 0.9
		if(EXPERIMENT_OUTCOME_FAILURE)
			return 0.75
		if(EXPERIMENT_OUTCOME_FAILURE_MAJOR)
			return 0.5
		if(EXPERIMENT_OUTCOME_CATASTROPHIC)
			return 0.25
	return 1.0

/datum/scp_experiment_manager/proc/apply_experiment_results(datum/scp_experiment/exp, mob/living/carbon/human/researcher, outcome, xp_change, reward_modifier)
	if(!researcher || !researcher.ckey)
		return
	
	if(SSpersistent_progression)
		SSpersistent_progression.award_experience(researcher.ckey, "research_experiment", xp_change, "scp_experiment")
	
	var/datum/researcher_data/rd
	if(SSscp_research && SSscp_research.manager)
		rd = SSscp_research.manager.get_researcher_profile(researcher.ckey)
		if(rd)
			rd.research_points += max(0, xp_change)
			rd.completed_projects++
			
			if(outcome == EXPERIMENT_OUTCOME_SUCCESS_MAJOR)
				rd.achievements += "Major Breakthrough: [exp.scp_id]"
	
	if(reward_modifier > 1.0 && SSbudget_system && SSbudget_system.manager)
		var/budget_reward = round(100 * reward_modifier * experiment_reward_multiplier)
		SSbudget_system.manager.add_transaction("research", "REVENUE", budget_reward, "experiment_reward", 
			"Experiment completion: [exp.name]", researcher.ckey)
	
	notify_experiment_result(researcher, exp, outcome, xp_change)

/datum/scp_experiment_manager/proc/notify_experiment_result(mob/researcher, datum/scp_experiment/exp, outcome, xp_change)
	var/outcome_text = ""
	var/class = "notice"
	
	switch(outcome)
		if(EXPERIMENT_OUTCOME_SUCCESS_MAJOR)
			outcome_text = "MAJOR SUCCESS"
			class = "boldnotice"
		if(EXPERIMENT_OUTCOME_SUCCESS)
			outcome_text = "SUCCESS"
			class = "notice"
		if(EXPERIMENT_OUTCOME_SUCCESS_MINOR)
			outcome_text = "MINOR SUCCESS"
			class = "notice"
		if(EXPERIMENT_OUTCOME_NEUTRAL)
			outcome_text = "INCONCLUSIVE"
			class = "warning"
		if(EXPERIMENT_OUTCOME_FAILURE_MINOR)
			outcome_text = "MINOR FAILURE"
			class = "warning"
		if(EXPERIMENT_OUTCOME_FAILURE)
			outcome_text = "FAILURE"
			class = "warning"
		if(EXPERIMENT_OUTCOME_FAILURE_MAJOR)
			outcome_text = "MAJOR FAILURE"
			class = "danger"
		if(EXPERIMENT_OUTCOME_CATASTROPHIC)
			outcome_text = "CATASTROPHIC FAILURE"
			class = "boldannounce"
	
	var/xp_text = xp_change >= 0 ? "+[xp_change]" : "[xp_change]"
	to_chat(researcher, "<span class='[class]'>Experiment '[exp.name]' completed: [outcome_text]! XP: [xp_text]</span>")

/datum/scp_experiment_manager/proc/trigger_catastrophe(datum/scp_experiment/exp, mob/living/carbon/human/researcher)
	if(!exp || !researcher)
		return
	
	var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances?[exp.scp_id]
	if(instance)
		instance.containment_status = "breached"
		instance.add_breach_record()
		SSscp_persistence.manager.active_breaches++
	
	message_admins("CATASTROPHIC EXPERIMENT FAILURE on [exp.scp_id] by [researcher.key]!")
	
	for(var/mob/living/carbon/human/H in range(10, researcher))
		if(H != researcher)
			to_chat(H, "<span class='danger'>ALERT: Catastrophic experiment failure in [get_area(researcher)]!</span>")

/datum/scp_experiment_manager/proc/register_experiment_template(datum/scp_experiment_template/template)
	if(!template || !template.template_id)
		return FALSE
	experiment_templates[template.template_id] = template
	return TRUE

/datum/scp_experiment_manager/proc/suspend_experiment(experiment_id, mob/user)
	var/datum/scp_experiment/exp = active_experiments[experiment_id]
	if(!exp)
		return FALSE
	if(exp.status != "active")
		return FALSE
	exp.status = "suspended"
	if(user)
		to_chat(user, "<span class='notice'>Experiment [exp.name] has been suspended.</span>")
		log_game("[key_name(user)] suspended experiment [exp.name] ([experiment_id])")
	return TRUE

/datum/scp_experiment_manager/proc/resume_experiment(experiment_id, mob/user)
	var/datum/scp_experiment/exp = active_experiments[experiment_id]
	if(!exp)
		return FALSE
	if(exp.status != "suspended")
		return FALSE
	exp.status = "active"
	if(user)
		to_chat(user, "<span class='notice'>Experiment [exp.name] has been resumed.</span>")
	return TRUE

/datum/scp_experiment_manager/proc/terminate_experiment(experiment_id, mob/user)
	var/datum/scp_experiment/exp = active_experiments[experiment_id]
	if(!exp)
		return FALSE
	exp.status = "terminated"
	exp.outcome = EXPERIMENT_OUTCOME_NEUTRAL
	exp.completion_time = world.time
	completed_experiments[experiment_id] = exp
	active_experiments -= experiment_id
	if(user)
		to_chat(user, "<span class='warning'>Experiment [exp.name] has been terminated.</span>")
		log_game("[key_name(user)] terminated experiment [exp.name] ([experiment_id])")
	return TRUE

/datum/scp_experiment_manager/proc/get_all_active_experiments_data()
	var/list/result = list()
	for(var/exp_id in active_experiments)
		var/datum/scp_experiment/exp = active_experiments[exp_id]
		var/phase_name = get_phase_name(exp.current_phase)
		var/progress = round((exp.phase_progress / max(1, exp.phase_duration)) * 100)
		result[exp_id] = list(
			"id" = exp.experiment_id,
			"name" = exp.name,
			"scp_id" = exp.scp_id,
			"type" = exp.experiment_type,
			"type_name" = get_experiment_type_name(exp.experiment_type),
			"risk_level" = exp.risk_level,
			"risk_name" = get_experiment_risk_name(exp.risk_level),
			"status" = exp.status,
			"phase" = exp.current_phase,
			"phase_name" = phase_name,
			"progress" = progress,
			"phase_progress" = exp.phase_progress,
			"phase_duration" = exp.phase_duration,
			"researcher" = exp.primary_researcher?.name || "Unknown",
			"assistant_count" = length(exp.assistants),
			"start_time" = exp.start_time,
			"data_points" = length(exp.data_collected),
		)
	return result

/datum/scp_experiment_manager/proc/get_experiment_detail(experiment_id)
	var/datum/scp_experiment/exp = active_experiments[experiment_id]
	if(!exp)
		exp = completed_experiments[experiment_id]
	if(!exp)
		return null
	return list(
		"id" = exp.experiment_id,
		"name" = exp.name,
		"scp_id" = exp.scp_id,
		"type" = exp.experiment_type,
		"type_name" = get_experiment_type_name(exp.experiment_type),
		"risk_level" = exp.risk_level,
		"risk_name" = get_experiment_risk_name(exp.risk_level),
		"status" = exp.status,
		"phase" = exp.current_phase,
		"phase_name" = get_phase_name(exp.current_phase),
		"phase_progress" = exp.phase_progress,
		"phase_duration" = exp.phase_duration,
		"researcher" = exp.primary_researcher?.name || "Unknown",
		"assistant_count" = length(exp.assistants),
		"start_time" = exp.start_time,
		"completion_time" = exp.completion_time,
		"outcome" = exp.outcome,
		"data_collected" = exp.data_collected,
		"phase_results" = exp.phase_results,
		"has_scp_parent" = !!exp.scp_parent,
	)

/proc/get_phase_name(phase)
	switch(phase)
		if(EXPERIMENT_PHASE_PREPARATION)
			return "Preparation"
		if(EXPERIMENT_PHASE_EXECUTION)
			return "Execution"
		if(EXPERIMENT_PHASE_OBSERVATION)
			return "Observation"
		if(EXPERIMENT_PHASE_CONCLUSION)
			return "Conclusion"
	return "Unknown"

/datum/scp_experiment_manager/proc/get_available_experiments(mob/living/carbon/human/user, scp_id)
	var/list/available = list()
	
	for(var/template_id in experiment_templates)
		var/datum/scp_experiment_template/T = experiment_templates[template_id]
		if(T.scp_id == scp_id)
			var/access = can_conduct_experiment(user, T.experiment_type, T.scp_class, T.risk_level)
			if(access >= EXPERIMENT_ACCESS_ASSIST)
				available += list(list(
					"id" = T.template_id,
					"name" = T.name,
					"type" = T.experiment_type,
					"risk" = T.risk_level,
					"access" = access,
					"cooldown" = get_cooldown_remaining(user, T)
				))
	
	return available

/datum/scp_experiment_manager/proc/get_cooldown_remaining(mob/living/carbon/human/user, datum/scp_experiment_template/template)
	var/cooldown_key = "[user.ckey]_[template.scp_id]_[template.experiment_type]"
	if(experiment_cooldowns[cooldown_key])
		return max(0, experiment_cooldowns[cooldown_key] - world.time)
	return 0

/datum/scp_experiment_template
	var/template_id
	var/name
	var/description
	var/scp_id
	var/experiment_type
	var/scp_class
	var/risk_level = EXPERIMENT_RISK_LOW
	
	var/list/requirements = list()
	var/list/equipment_needed = list()
	var/list/personnel_required = list()
	
	var/base_duration = 300
	var/cooldown_time = 6000
	
	var/list/phase_data = list()
	var/list/possible_outcomes = list()
	
	var/requires_dcond_approval = FALSE
	var/minimum_clearance = 1

/datum/scp_experiment_template/New(id, scp, type)
	template_id = id
	scp_id = scp
	experiment_type = type

/datum/scp_experiment
	var/experiment_id
	var/name
	var/template_id
	var/scp_id
	var/experiment_type
	var/scp_class
	var/risk_level
	
	var/mob/living/carbon/human/primary_researcher
	var/list/assistants = list()
	var/atom/scp_parent
	
	var/current_phase = EXPERIMENT_PHASE_PREPARATION
	var/status = "pending"
	var/outcome = null
	
	var/phase_progress = 0
	var/phase_duration = 300
	var/total_duration = 0
	var/start_time = 0
	var/completion_time = 0
	
	var/cooldown_time = 6000
	var/access_level = EXPERIMENT_ACCESS_STANDARD
	
	var/list/phase_results = list()
	var/list/data_collected = list()

/datum/scp_experiment/New(id, datum/scp_experiment_template/template, mob/living/carbon/human/researcher)
	experiment_id = id
	template_id = template.template_id
	name = template.name
	scp_id = template.scp_id
	experiment_type = template.experiment_type
	scp_class = template.scp_class
	risk_level = template.risk_level
	phase_duration = template.base_duration
	cooldown_time = template.cooldown_time
	
	primary_researcher = researcher
	start_time = world.time
	status = "active"
	
	find_scp_parent()

/datum/scp_experiment/proc/find_scp_parent()
	if(!scp_id)
		return
	for(var/mob/living/scp/S in GLOB.mob_list)
		if(QDELETED(S))
			continue
		if(S.persistence_id == scp_id)
			scp_parent = S
			return
	for(var/mob/living/carbon/human/H in GLOB.human_list)
		if(QDELETED(H))
			continue
		var/datum/scp/SCP = H.SCP
		if(SCP && SCP.designation == scp_id)
			scp_parent = H
			return
	if(SSscp_persistence && SSscp_persistence.manager)
		for(var/instance_id in SSscp_persistence.manager.scp_instances)
			if(instance_id == scp_id)
				return

/datum/scp_experiment/proc/process_experiment()
	if(status != "active")
		return
	
	phase_progress += 10
	
	if(phase_progress >= phase_duration)
		advance_phase()

/datum/scp_experiment/proc/advance_phase()
	phase_progress = 0
	
	current_phase++
	
	if(current_phase > EXPERIMENT_PHASE_CONCLUSION)
		conclude_experiment()
		return
	
	notify_phase_change()
	
	if(scp_parent && istype(scp_parent, /mob/living/scp/scp173))
		var/mob/living/scp/scp173/scp = scp_parent
		scp.SCP?.log_interaction(primary_researcher, "experiment_phase:[current_phase]")

/datum/scp_experiment/proc/notify_phase_change()
	var/phase_name = ""
	switch(current_phase)
		if(EXPERIMENT_PHASE_PREPARATION)
			phase_name = "Preparation"
		if(EXPERIMENT_PHASE_EXECUTION)
			phase_name = "Execution"
		if(EXPERIMENT_PHASE_OBSERVATION)
			phase_name = "Observation"
		if(EXPERIMENT_PHASE_CONCLUSION)
			phase_name = "Conclusion"
	
	if(primary_researcher)
		to_chat(primary_researcher, "<span class='notice'>Experiment [name] has advanced to: [phase_name] phase.</span>")
	
	for(var/mob/assistant in assistants)
		to_chat(assistant, "<span class='notice'>Experiment [name] has advanced to: [phase_name] phase.</span>")

/datum/scp_experiment/proc/conclude_experiment()
	var/outcome = determine_outcome()
	
	if(SSscp_experiments && SSscp_experiments.manager)
		SSscp_experiments.manager.complete_experiment(experiment_id, outcome, primary_researcher)

/datum/scp_experiment/proc/determine_outcome()
	var/base_success_chance = 50
	
	switch(risk_level)
		if(EXPERIMENT_RISK_MINIMAL)
			base_success_chance += 30
		if(EXPERIMENT_RISK_LOW)
			base_success_chance += 20
		if(EXPERIMENT_RISK_MEDIUM)
			base_success_chance += 0
		if(EXPERIMENT_RISK_HIGH)
			base_success_chance -= 20
		if(EXPERIMENT_RISK_CRITICAL)
			base_success_chance -= 40
	
	var/roll = rand(1, 100)
	
	if(roll <= base_success_chance - 30)
		return EXPERIMENT_OUTCOME_SUCCESS_MAJOR
	else if(roll <= base_success_chance - 15)
		return EXPERIMENT_OUTCOME_SUCCESS
	else if(roll <= base_success_chance)
		return EXPERIMENT_OUTCOME_SUCCESS_MINOR
	else if(roll <= base_success_chance + 15)
		return EXPERIMENT_OUTCOME_NEUTRAL
	else if(roll <= base_success_chance + 30)
		return EXPERIMENT_OUTCOME_FAILURE_MINOR
	else if(roll <= base_success_chance + 45)
		return EXPERIMENT_OUTCOME_FAILURE
	else if(roll <= base_success_chance + 55)
		return EXPERIMENT_OUTCOME_FAILURE_MAJOR
	else
		return EXPERIMENT_OUTCOME_CATASTROPHIC

/datum/scp_experiment/proc/add_assistant(mob/living/carbon/human/assistant)
	if(!assistant || (assistant in assistants))
		return FALSE
	
	assistants += assistant
	to_chat(primary_researcher, "<span class='notice'>[assistant.name] has joined the experiment as an assistant.</span>")
	to_chat(assistant, "<span class='notice'>You have joined experiment [name] as an assistant.</span>")
	return TRUE

/datum/scp_experiment/proc/remove_assistant(mob/living/carbon/human/assistant)
	if(!assistant || !(assistant in assistants))
		return FALSE
	
	assistants -= assistant
	to_chat(primary_researcher, "<span class='notice'>[assistant.name] has left the experiment.</span>")
	to_chat(assistant, "<span class='notice'>You have left experiment [name].</span>")
	return TRUE

/datum/scp_experiment/proc/record_data(key, value)
	data_collected[key] = value

/datum/scp_experiment/proc/record_phase_result(phase, success, notes)
	phase_results["phase_[phase]"] = list(
		"success" = success,
		"notes" = notes,
		"timestamp" = world.time
	)

/mob/proc/view_available_experiments()
	set name = "View Available Experiments"
	set category = "Research"
	set desc = "View experiments available for your clearance level."
	
	if(!ishuman(src))
		return
	
	var/mob/living/carbon/human/H = src
	
	if(!SSscp_experiments || !SSscp_experiments.manager)
		to_chat(H, "<span class='warning'>Experiment system not available.</span>")
		return
	
	var/datum/scp_experiment_manager/manager = SSscp_experiments.manager
	
	var/message = "<h2>Available Experiments</h2>"
	message += "<b>Your Clearance:</b> [manager.get_default_certification(H.job)]<br><br>"
	
	for(var/scp_id in SSscp_persistence?.manager?.scp_instances)
		var/list/experiments = manager.get_available_experiments(H, scp_id)
		if(length(experiments) > 0)
			message += "<h3>[scp_id]</h3>"
			for(var/list/exp in experiments)
				var/access_text = ""
				switch(exp["access"])
					if(EXPERIMENT_ACCESS_FULL)
						access_text = "Full Access"
					if(EXPERIMENT_ACCESS_ADVANCED)
						access_text = "Advanced"
					if(EXPERIMENT_ACCESS_STANDARD)
						access_text = "Standard"
					if(EXPERIMENT_ACCESS_ASSIST)
						access_text = "Assist Only"
					if(EXPERIMENT_ACCESS_OBSERVE)
						access_text = "Observe Only"
				
				var/cooldown_text = ""
				if(exp["cooldown"] > 0)
					cooldown_text = " (On cooldown: [round(exp["cooldown"]/600, 0.1)] min)"
				
				message += "- [exp["name"]] (Risk: [exp["risk"]], Access: [access_text])[cooldown_text]<br>"
	
	to_chat(H, "<span class='notice'>[message]</span>")

/mob/proc/conduct_scp_experiment()
	set name = "Conduct SCP Experiment"
	set category = "Research"
	set desc = "Conduct an experiment on an SCP."
	
	if(!ishuman(src))
		return
	
	var/mob/living/carbon/human/H = src
	
	if(!SSscp_experiments || !SSscp_experiments.manager)
		to_chat(H, "<span class='warning'>Experiment system not available.</span>")
		return
	
	var/datum/scp_experiment_manager/manager = SSscp_experiments.manager
	
	var/list/scp_options = list()
	for(var/scp_id in SSscp_persistence?.manager?.scp_instances)
		scp_options += scp_id
	
	if(!length(scp_options))
		to_chat(H, "<span class='warning'>No SCPs available for experimentation.</span>")
		return
	
	var/selected_scp = input(H, "Select an SCP to experiment on:", "SCP Experiment") as null|anything in scp_options
	if(!selected_scp)
		return
	
	var/list/available_experiments = manager.get_available_experiments(H, selected_scp)
	if(!length(available_experiments))
		to_chat(H, "<span class='warning'>No experiments available for [selected_scp] at your clearance level.</span>")
		return
	
	var/list/experiment_names = list()
	for(var/list/exp in available_experiments)
		experiment_names[exp["name"]] = exp
	
	var/selected_name = input(H, "Select an experiment:", "SCP Experiment") as null|anything in experiment_names
	if(!selected_name)
		return
	
	var/list/selected_exp = experiment_names[selected_name]
	
	var/datum/scp_experiment_template/template = manager.experiment_templates[selected_exp["id"]]
	if(!template)
		to_chat(H, "<span class='warning'>Experiment template not found.</span>")
		return
	
	var/confirm = alert(H, "Start experiment '[template.name]' on [selected_scp]?\nRisk Level: [template.risk_level]\nDuration: [template.base_duration/10] seconds", "Confirm Experiment", "Yes", "No")
	if(confirm != "Yes")
		return
	
	var/datum/scp_experiment/exp = manager.start_experiment(selected_scp, template.experiment_type, H)
	if(exp)
		to_chat(H, "<span class='notice'>Experiment started successfully. Check 'View Active Experiments' for progress.</span>")
	else
		to_chat(H, "<span class='warning'>Failed to start experiment.</span>")

/mob/proc/view_active_experiments()
	set name = "View Active Experiments"
	set category = "Research"
	set desc = "View currently active experiments."
	
	if(!SSscp_experiments || !SSscp_experiments.manager)
		to_chat(src, "<span class='warning'>Experiment system not available.</span>")
		return
	
	var/datum/scp_experiment_manager/manager = SSscp_experiments.manager
	
	var/message = "<h2>Active Experiments</h2>"
	
	if(!length(manager.active_experiments))
		message += "<i>No active experiments.</i>"
	else
		for(var/exp_id in manager.active_experiments)
			var/datum/scp_experiment/exp = manager.active_experiments[exp_id]
			var/phase_name = ""
			switch(exp.current_phase)
				if(EXPERIMENT_PHASE_PREPARATION)
					phase_name = "Preparation"
				if(EXPERIMENT_PHASE_EXECUTION)
					phase_name = "Execution"
				if(EXPERIMENT_PHASE_OBSERVATION)
					phase_name = "Observation"
				if(EXPERIMENT_PHASE_CONCLUSION)
					phase_name = "Conclusion"
			
			var/progress = round((exp.phase_progress / exp.phase_duration) * 100)
			message += "<b>[exp.name]</b> ([exp.scp_id])<br>"
			message += "- Phase: [phase_name] ([progress]%)<br>"
			message += "- Researcher: [exp.primary_researcher?.name || "Unknown"]<br>"
			message += "- Assistants: [length(exp.assistants)]<br><br>"
	
	to_chat(src, "<span class='notice'>[message]</span>")

/proc/get_experiment_type_name(type)
	switch(type)
		if(EXPERIMENT_TYPE_BEHAVIORAL)
			return "Behavioral"
		if(EXPERIMENT_TYPE_CONTAINMENT)
			return "Containment"
		if(EXPERIMENT_TYPE_INTERACTION)
			return "Interaction"
		if(EXPERIMENT_TYPE_HAZARD)
			return "Hazard"
		if(EXPERIMENT_TYPE_MEDICAL)
			return "Medical"
		if(EXPERIMENT_TYPE_TECHNICAL)
			return "Technical"
		if(EXPERIMENT_TYPE_COGNITIVE)
			return "Cognitive"
	return "Unknown"

/proc/get_experiment_risk_name(risk)
	switch(risk)
		if(EXPERIMENT_RISK_MINIMAL)
			return "Minimal"
		if(EXPERIMENT_RISK_LOW)
			return "Low"
		if(EXPERIMENT_RISK_MEDIUM)
			return "Medium"
		if(EXPERIMENT_RISK_HIGH)
			return "High"
		if(EXPERIMENT_RISK_CRITICAL)
			return "Critical"
	return "Unknown"
