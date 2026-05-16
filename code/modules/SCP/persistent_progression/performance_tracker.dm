/datum/performance_tracker
	var/mob/living/carbon/human/target
	var/list/performance_metrics = list()
	var/list/experience_gained = list()
	var/round_start_time
	var/last_activity_time
	var/list/combat_stats = list()
	var/list/medical_stats = list()
	var/list/research_stats = list()
	var/list/engineering_stats = list()
	var/list/administrative_stats = list()
	var/list/containment_stats = list()

/datum/performance_tracker/New(mob/living/carbon/human/H)
	target = H
	round_start_time = world.time
	last_activity_time = world.time
	initialize_stats()

/datum/performance_tracker/proc/initialize_stats()
	combat_stats = list(
		"combats_won" = 0,
		"arrests_made" = 0,
		"civilians_protected" = 0,
		"breaches_contained" = 0,
		"scp_interactions" = 0
	)

	medical_stats = list(
		"treatments_given" = 0,
		"surgeries_performed" = 0,
		"revivals_completed" = 0,
		"diagnoses_made" = 0,
		"prevention_measures" = 0
	)

	research_stats = list(
		"scp_studies" = 0,
		"experiments_conducted" = 0,
		"documentations_written" = 0,
		"breakthroughs_achieved" = 0,
		"collaborations_made" = 0
	)

	engineering_stats = list(
		"repairs_completed" = 0,
		"constructions_built" = 0,
		"maintenance_tasks" = 0,
		"emergency_responses" = 0,
		"innovations_created" = 0
	)

	administrative_stats = list(
		"coordinations_made" = 0,
		"communications_sent" = 0,
		"decisions_made" = 0,
		"crises_managed" = 0,
		"team_successes" = 0
	)

	containment_stats = list(
		"scp_containments" = 0,
		"breach_responses" = 0,
		"procedures_followed" = 0,
		"containment_research" = 0,
		"innovations_developed" = 0
	)

/datum/performance_tracker/proc/track_combat_performance()
	if(!target || !target.mind)
		return

	var/datum/persistent_player_data/data = SSpersistent_progression.get_player_data(target.ckey)
	if(!data || data.current_class_id != "security")
		return

	// Track combat wins
	if(combat_stats["combats_won"] > 0)
		SSpersistent_progression.award_experience(target.ckey, "security_combat", 0, "Combat Engagement")

	// Track arrests
	if(combat_stats["arrests_made"] > 0)
		SSpersistent_progression.award_experience(target.ckey, "security_arrest", 0, "Successful Arrest")

	// Track protection
	if(combat_stats["civilians_protected"] > 0)
		SSpersistent_progression.award_experience(target.ckey, "security_protection", 0, "Civilian Protection")

	// Track breach containment
	if(combat_stats["breaches_contained"] > 0)
		SSpersistent_progression.award_experience(target.ckey, "security_breach_containment", 0, "Breach Containment")

	// Track SCP interactions
	if(combat_stats["scp_interactions"] > 0)
		SSpersistent_progression.award_experience(target.ckey, "security_scp_interaction", 0, "SCP Security Interaction")

/datum/performance_tracker/proc/track_medical_performance()
	if(!target || !target.mind)
		return

	var/datum/persistent_player_data/data = SSpersistent_progression.get_player_data(target.ckey)
	if(!data || data.current_class_id != "medical")
		return

	// Track treatments
	if(medical_stats["treatments_given"] > 0)
		SSpersistent_progression.award_experience(target.ckey, "medical_treatment", 0, "Medical Treatment")

	// Track surgeries
	if(medical_stats["surgeries_performed"] > 0)
		SSpersistent_progression.award_experience(target.ckey, "medical_surgery", 0, "Surgical Procedure")

	// Track revivals
	if(medical_stats["revivals_completed"] > 0)
		SSpersistent_progression.award_experience(target.ckey, "medical_revival", 0, "Patient Revival")

	// Track diagnoses
	if(medical_stats["diagnoses_made"] > 0)
		SSpersistent_progression.award_experience(target.ckey, "medical_diagnosis", 0, "Medical Diagnosis")

	// Track prevention
	if(medical_stats["prevention_measures"] > 0)
		SSpersistent_progression.award_experience(target.ckey, "medical_prevention", 0, "Disease Prevention")

/datum/performance_tracker/proc/track_research_performance()
	if(!target || !target.mind)
		return

	var/datum/persistent_player_data/data = SSpersistent_progression.get_player_data(target.ckey)
	if(!data || data.current_class_id != "research")
		return

	// Track SCP studies
	if(research_stats["scp_studies"] > 0)
		SSpersistent_progression.award_experience(target.ckey, "research_scp_study", 0, "SCP Research")

	// Track experiments
	if(research_stats["experiments_conducted"] > 0)
		SSpersistent_progression.award_experience(target.ckey, "research_experiment", 0, "Scientific Experiment")

	// Track documentation
	if(research_stats["documentations_written"] > 0)
		SSpersistent_progression.award_experience(target.ckey, "research_documentation", 0, "Research Documentation")

	// Track breakthroughs
	if(research_stats["breakthroughs_achieved"] > 0)
		SSpersistent_progression.award_experience(target.ckey, "research_breakthrough", 0, "Research Breakthrough")

	// Track collaborations
	if(research_stats["collaborations_made"] > 0)
		SSpersistent_progression.award_experience(target.ckey, "research_collaboration", 0, "Research Collaboration")

/datum/performance_tracker/proc/track_engineering_performance()
	if(!target || !target.mind)
		return

	var/datum/persistent_player_data/data = SSpersistent_progression.get_player_data(target.ckey)
	if(!data || data.current_class_id != "engineering")
		return

	// Track repairs
	if(engineering_stats["repairs_completed"] > 0)
		SSpersistent_progression.award_experience(target.ckey, "engineering_repair", 0, "Equipment Repair")

	// Track construction
	if(engineering_stats["constructions_built"] > 0)
		SSpersistent_progression.award_experience(target.ckey, "engineering_construction", 0, "Construction Work")

	// Track maintenance
	if(engineering_stats["maintenance_tasks"] > 0)
		SSpersistent_progression.award_experience(target.ckey, "engineering_maintenance", 0, "System Maintenance")

	// Track emergency response
	if(engineering_stats["emergency_responses"] > 0)
		SSpersistent_progression.award_experience(target.ckey, "engineering_emergency", 0, "Emergency Response")

	// Track innovation
	if(engineering_stats["innovations_created"] > 0)
		SSpersistent_progression.award_experience(target.ckey, "engineering_innovation", 0, "Engineering Innovation")

/datum/performance_tracker/proc/track_administrative_performance()
	if(!target || !target.mind)
		return

	var/datum/persistent_player_data/data = SSpersistent_progression.get_player_data(target.ckey)
	if(!data || data.current_class_id != "administrative")
		return

	// Track coordination
	if(administrative_stats["coordinations_made"] > 0)
		SSpersistent_progression.award_experience(target.ckey, "admin_coordination", 0, "Team Coordination")

	// Track communication
	if(administrative_stats["communications_sent"] > 0)
		SSpersistent_progression.award_experience(target.ckey, "admin_communication", 0, "Effective Communication")

	// Track decision making
	if(administrative_stats["decisions_made"] > 0)
		SSpersistent_progression.award_experience(target.ckey, "admin_decision_making", 0, "Strategic Decision")

	// Track crisis management
	if(administrative_stats["crises_managed"] > 0)
		SSpersistent_progression.award_experience(target.ckey, "admin_crisis_management", 0, "Crisis Management")

	// Track team success
	if(administrative_stats["team_successes"] > 0)
		SSpersistent_progression.award_experience(target.ckey, "admin_team_success", 0, "Team Success")

/datum/performance_tracker/proc/track_containment_performance()
	if(!target || !target.mind)
		return

	var/datum/persistent_player_data/data = SSpersistent_progression.get_player_data(target.ckey)
	if(!data || data.current_class_id != "containment")
		return

	// Track SCP containments
	if(containment_stats["scp_containments"] > 0)
		SSpersistent_progression.award_experience(target.ckey, "containment_scp_interaction", 0, "SCP Containment")

	// Track breach responses
	if(containment_stats["breach_responses"] > 0)
		SSpersistent_progression.award_experience(target.ckey, "containment_breach_response", 0, "Breach Response")

	// Track procedures
	if(containment_stats["procedures_followed"] > 0)
		SSpersistent_progression.award_experience(target.ckey, "containment_procedure", 0, "Containment Procedure")

	// Track containment research
	if(containment_stats["containment_research"] > 0)
		SSpersistent_progression.award_experience(target.ckey, "containment_research", 0, "Containment Research")

	// Track innovation
	if(containment_stats["innovations_developed"] > 0)
		SSpersistent_progression.award_experience(target.ckey, "containment_innovation", 0, "Containment Innovation")

/datum/performance_tracker/proc/update_metric(metric_type, metric_name, value)
	if(!target || !target.mind)
		return

	var/datum/persistent_player_data/data = SSpersistent_progression.get_player_data(target.ckey)
	if(!data)
		return

	switch(metric_type)
		if("combat")
			combat_stats[metric_name] = value
		if("medical")
			medical_stats[metric_name] = value
		if("research")
			research_stats[metric_name] = value
		if("engineering")
			engineering_stats[metric_name] = value
		if("administrative")
			administrative_stats[metric_name] = value
		if("containment")
			containment_stats[metric_name] = value

	data.update_performance_metric("[metric_type]_[metric_name]", value)
	last_activity_time = world.time

/datum/performance_tracker/proc/process_performance_rewards()
	if(!target || !target.mind)
		return

	var/datum/persistent_player_data/data = SSpersistent_progression.get_player_data(target.ckey)
	if(!data)
		return

	switch(data.current_class_id)
		if("security")
			track_combat_performance()
		if("medical")
			track_medical_performance()
		if("research")
			track_research_performance()
		if("engineering")
			track_engineering_performance()
		if("administrative")
			track_administrative_performance()
		if("containment")
			track_containment_performance()

/datum/performance_tracker/proc/calculate_total_performance()
	var/total = 0

	for(var/stat in combat_stats)
		total += combat_stats[stat]
	for(var/stat in medical_stats)
		total += medical_stats[stat]
	for(var/stat in research_stats)
		total += research_stats[stat]
	for(var/stat in engineering_stats)
		total += engineering_stats[stat]
	for(var/stat in administrative_stats)
		total += administrative_stats[stat]
	for(var/stat in containment_stats)
		total += containment_stats[stat]

	return total
