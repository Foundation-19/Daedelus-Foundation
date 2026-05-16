/datum/experience_source
	var/source_id
	var/source_name
	var/source_description = "An experience source"
	var/base_experience
	var/class_multiplier = 1.0
	var/rank_multiplier = 0.0
	var/faction_multiplier = 1.0
	var/cooldown_time = 0
	var/max_per_round = -1
	var/list/compatible_classes = list()
	var/category = "general"
	var/hidden = FALSE

// Security Experience Sources
/datum/experience_source/security_combat
	source_id = "security_combat"
	source_name = "Combat Engagement"
	base_experience = 50
	cooldown_time = 300
	max_per_round = 10
	compatible_classes = list("security")

/datum/experience_source/security_arrest
	source_id = "security_arrest"
	source_name = "Successful Arrest"
	base_experience = 25
	cooldown_time = 60
	max_per_round = 20
	compatible_classes = list("security")

/datum/experience_source/security_protection
	source_id = "security_protection"
	source_name = "Civilian Protection"
	base_experience = 30
	cooldown_time = 120
	max_per_round = 15
	compatible_classes = list("security")

/datum/experience_source/security_breach_containment
	source_id = "security_breach_containment"
	source_name = "Breach Containment"
	base_experience = 100
	cooldown_time = 600
	max_per_round = 5
	compatible_classes = list("security")

/datum/experience_source/security_scp_interaction
	source_id = "security_scp_interaction"
	source_name = "SCP Security Interaction"
	base_experience = 75
	cooldown_time = 300
	max_per_round = 8
	compatible_classes = list("security")

// Research Experience Sources
/datum/experience_source/research_scp_study
	source_id = "research_scp_study"
	source_name = "SCP Research"
	base_experience = 40
	cooldown_time = 180
	max_per_round = 12
	compatible_classes = list("research")

/datum/experience_source/research_experiment
	source_id = "research_experiment"
	source_name = "Scientific Experiment"
	base_experience = 60
	cooldown_time = 300
	max_per_round = 8
	compatible_classes = list("research")

/datum/experience_source/research_documentation
	source_id = "research_documentation"
	source_name = "Research Documentation"
	base_experience = 25
	cooldown_time = 120
	max_per_round = 15
	compatible_classes = list("research")

/datum/experience_source/research_breakthrough
	source_id = "research_breakthrough"
	source_name = "Research Breakthrough"
	base_experience = 150
	cooldown_time = 600
	max_per_round = 3
	compatible_classes = list("research")

/datum/experience_source/research_collaboration
	source_id = "research_collaboration"
	source_name = "Research Collaboration"
	base_experience = 35
	cooldown_time = 240
	max_per_round = 10
	compatible_classes = list("research")

// Medical Experience Sources
/datum/experience_source/medical_treatment
	source_id = "medical_treatment"
	source_name = "Medical Treatment"
	base_experience = 30
	cooldown_time = 60
	max_per_round = 20
	compatible_classes = list("medical")

/datum/experience_source/medical_surgery
	source_id = "medical_surgery"
	source_name = "Surgical Procedure"
	base_experience = 80
	cooldown_time = 300
	max_per_round = 6
	compatible_classes = list("medical")

/datum/experience_source/medical_revival
	source_id = "medical_revival"
	source_name = "Patient Revival"
	base_experience = 100
	cooldown_time = 600
	max_per_round = 3
	compatible_classes = list("medical")

/datum/experience_source/medical_diagnosis
	source_id = "medical_diagnosis"
	source_name = "Medical Diagnosis"
	base_experience = 25
	cooldown_time = 120
	max_per_round = 15
	compatible_classes = list("medical")

/datum/experience_source/medical_prevention
	source_id = "medical_prevention"
	source_name = "Disease Prevention"
	base_experience = 50
	cooldown_time = 240
	max_per_round = 8
	compatible_classes = list("medical")

// Engineering Experience Sources
/datum/experience_source/engineering_repair
	source_id = "engineering_repair"
	source_name = "Equipment Repair"
	base_experience = 25
	cooldown_time = 120
	max_per_round = 15
	compatible_classes = list("engineering")

/datum/experience_source/engineering_construction
	source_id = "engineering_construction"
	source_name = "Construction Work"
	base_experience = 40
	cooldown_time = 180
	max_per_round = 10
	compatible_classes = list("engineering")

/datum/experience_source/engineering_maintenance
	source_id = "engineering_maintenance"
	source_name = "System Maintenance"
	base_experience = 30
	cooldown_time = 150
	max_per_round = 12
	compatible_classes = list("engineering")

/datum/experience_source/engineering_emergency
	source_id = "engineering_emergency"
	source_name = "Emergency Response"
	base_experience = 75
	cooldown_time = 300
	max_per_round = 5
	compatible_classes = list("engineering")

/datum/experience_source/engineering_innovation
	source_id = "engineering_innovation"
	source_name = "Engineering Innovation"
	base_experience = 100
	cooldown_time = 600
	max_per_round = 3
	compatible_classes = list("engineering")

// Administrative Experience Sources
/datum/experience_source/admin_coordination
	source_id = "admin_coordination"
	source_name = "Team Coordination"
	base_experience = 35
	cooldown_time = 180
	max_per_round = 10
	compatible_classes = list("administrative")

/datum/experience_source/admin_communication
	source_id = "admin_communication"
	source_name = "Effective Communication"
	base_experience = 25
	cooldown_time = 120
	max_per_round = 15
	compatible_classes = list("administrative")

/datum/experience_source/admin_decision_making
	source_id = "admin_decision_making"
	source_name = "Strategic Decision"
	base_experience = 60
	cooldown_time = 300
	max_per_round = 6
	compatible_classes = list("administrative")

/datum/experience_source/admin_crisis_management
	source_id = "admin_crisis_management"
	source_name = "Crisis Management"
	base_experience = 100
	cooldown_time = 600
	max_per_round = 3
	compatible_classes = list("administrative")

/datum/experience_source/admin_team_success
	source_id = "admin_team_success"
	source_name = "Team Success"
	base_experience = 80
	cooldown_time = 400
	max_per_round = 5
	compatible_classes = list("administrative")

// Containment Experience Sources
/datum/experience_source/containment_scp_interaction
	source_id = "containment_scp_interaction"
	source_name = "SCP Containment"
	base_experience = 50
	cooldown_time = 240
	max_per_round = 8
	compatible_classes = list("containment")

/datum/experience_source/containment_breach_response
	source_id = "containment_breach_response"
	source_name = "Breach Response"
	base_experience = 100
	cooldown_time = 600
	max_per_round = 3
	compatible_classes = list("containment")

/datum/experience_source/containment_procedure
	source_id = "containment_procedure"
	source_name = "Containment Procedure"
	base_experience = 40
	cooldown_time = 180
	max_per_round = 10
	compatible_classes = list("containment")

/datum/experience_source/containment_research
	source_id = "containment_research"
	source_name = "Containment Research"
	base_experience = 60
	cooldown_time = 300
	max_per_round = 6
	compatible_classes = list("containment")

/datum/experience_source/containment_innovation
	source_id = "containment_innovation"
	source_name = "Containment Innovation"
	base_experience = 120
	cooldown_time = 600
	max_per_round = 2
	compatible_classes = list("containment")

// Universal Experience Sources
/datum/experience_source/round_survival
	source_id = "round_survival"
	source_name = "Round Survival"
	base_experience = 200
	cooldown_time = 0
	max_per_round = 1
	compatible_classes = list("security", "research", "medical", "engineering", "administrative", "containment")

/datum/experience_source/admin_award
	source_id = "admin_award"
	source_name = "Admin Award"
	base_experience = 0 // Set by admin
	cooldown_time = 0
	max_per_round = 999
	compatible_classes = list("security", "research", "medical", "engineering", "administrative", "containment")

/datum/experience_source/objective_completion
	source_id = "objective_completion"
	source_name = "Objective Completion"
	base_experience = 40
	cooldown_time = 0
	max_per_round = 10
	compatible_classes = list("security", "research", "medical", "engineering", "administrative", "containment")
	category = "universal"

/datum/experience_source/team_work
	source_id = "team_work"
	source_name = "Teamwork"
	base_experience = 25
	cooldown_time = 180
	max_per_round = 15
	compatible_classes = list("security", "research", "medical", "engineering", "administrative", "containment")
	category = "universal"

/datum/experience_source/roleplay
	source_id = "roleplay"
	source_name = "Roleplay Quality"
	base_experience = 20
	cooldown_time = 300
	max_per_round = 10
	compatible_classes = list("security", "research", "medical", "engineering", "administrative", "containment")
	category = "universal"

/datum/experience_source/teaching
	source_id = "teaching"
	source_name = "Teaching"
	base_experience = 35
	cooldown_time = 600
	max_per_round = 5
	compatible_classes = list("security", "research", "medical", "engineering", "administrative", "containment")
	category = "universal"

/datum/experience_source/first_login
	source_id = "first_login"
	source_name = "First Login"
	base_experience = 50
	cooldown_time = 0
	max_per_round = 1
	compatible_classes = list("security", "research", "medical", "engineering", "administrative", "containment")
	category = "universal"
	hidden = TRUE

/datum/experience_source/daily_login
	source_id = "daily_login"
	source_name = "Daily Login"
	base_experience = 25
	cooldown_time = 86400
	max_per_round = 1
	compatible_classes = list("security", "research", "medical", "engineering", "administrative", "containment")
	category = "universal"

/datum/experience_source/weekly_login
	source_id = "weekly_login"
	source_name = "Weekly Login"
	base_experience = 100
	cooldown_time = 604800
	max_per_round = 1
	compatible_classes = list("security", "research", "medical", "engineering", "administrative", "containment")
	category = "universal"

/datum/experience_source/dclass_survival
	source_id = "dclass_survival"
	source_name = "D-Class Survival"
	base_experience = 100
	cooldown_time = 0
	max_per_round = 1
	compatible_classes = list()
	category = "survival"

/datum/experience_source/dclass_escape
	source_id = "dclass_escape"
	source_name = "D-Class Escape"
	base_experience = 300
	cooldown_time = 0
	max_per_round = 5
	compatible_classes = list()
	category = "survival"

/datum/experience_source/dclass_contraband
	source_id = "dclass_contraband"
	source_name = "Contraband Acquisition"
	base_experience = 25
	cooldown_time = 120
	max_per_round = 20
	compatible_classes = list()
	category = "survival"

/datum/experience_source/dclass_experiment
	source_id = "dclass_experiment"
	source_name = "Experiment Participation"
	base_experience = 40
	cooldown_time = 300
	max_per_round = 15
	compatible_classes = list()
	category = "survival"

/datum/experience_source/dclass_interaction
	source_id = "dclass_interaction"
	source_name = "SCP Interaction"
	base_experience = 35
	cooldown_time = 240
	max_per_round = 10
	compatible_classes = list()
	category = "survival"

/datum/experience_source/dclass_testing
	source_id = "dclass_testing"
	source_name = "D-Class Testing"
	base_experience = 50
	cooldown_time = 240
	max_per_round = 10
	compatible_classes = list("research")
	category = "research"

/datum/experience_source/interview
	source_id = "interview"
	source_name = "SCP Interview"
	base_experience = 45
	cooldown_time = 300
	max_per_round = 8
	compatible_classes = list("research", "containment")
	category = "research"

/datum/experience_source/observation
	source_id = "observation"
	source_name = "SCP Observation"
	base_experience = 30
	cooldown_time = 180
	max_per_round = 15
	compatible_classes = list("research", "containment")
	category = "research"

/datum/experience_source/quarantine
	source_id = "quarantine"
	source_name = "Quarantine Enforcement"
	base_experience = 40
	cooldown_time = 240
	max_per_round = 10
	compatible_classes = list("medical", "security")
	category = "medical"

/datum/experience_source/chemical_synthesis
	source_id = "chemical_synthesis"
	source_name = "Chemical Synthesis"
	base_experience = 35
	cooldown_time = 180
	max_per_round = 12
	compatible_classes = list("medical", "research")
	category = "medical"

/datum/experience_source/patient_care
	source_id = "patient_care"
	source_name = "Patient Care"
	base_experience = 25
	cooldown_time = 120
	max_per_round = 20
	compatible_classes = list("medical")
	category = "medical"

/datum/experience_source/patrol
	source_id = "patrol"
	source_name = "Security Patrol"
	base_experience = 15
	cooldown_time = 300
	max_per_round = 20
	compatible_classes = list("security")
	category = "security"

/datum/experience_source/escort
	source_id = "escort"
	source_name = "Personnel Escort"
	base_experience = 25
	cooldown_time = 180
	max_per_round = 15
	compatible_classes = list("security")
	category = "security"

/datum/experience_source/setup_equipment
	source_id = "setup_equipment"
	source_name = "Equipment Setup"
	base_experience = 20
	cooldown_time = 150
	max_per_round = 15
	compatible_classes = list("engineering")
	category = "engineering"

/datum/experience_source/upgrade_system
	source_id = "upgrade_system"
	source_name = "System Upgrade"
	base_experience = 45
	cooldown_time = 300
	max_per_round = 8
	compatible_classes = list("engineering")
	category = "engineering"

/datum/experience_source/backup_power
	source_id = "backup_power"
	source_name = "Backup Power Management"
	base_experience = 35
	cooldown_time = 240
	max_per_round = 10
	compatible_classes = list("engineering")
	category = "engineering"

/datum/experience_source/document_creation
	source_id = "document_creation"
	source_name = "Document Creation"
	base_experience = 20
	cooldown_time = 120
	max_per_round = 20
	compatible_classes = list("administrative", "research")
	category = "administrative"

/datum/experience_source/resource_allocation
	source_id = "resource_allocation"
	source_name = "Resource Allocation"
	base_experience = 30
	cooldown_time = 240
	max_per_round = 10
	compatible_classes = list("administrative")
	category = "administrative"

/datum/experience_source/meeting_facilitation
	source_id = "meeting_facilitation"
	source_name = "Meeting Facilitation"
	base_experience = 25
	cooldown_time = 300
	max_per_round = 8
	compatible_classes = list("administrative")
	category = "administrative"

/datum/experience_source/containment_check
	source_id = "containment_check"
	source_name = "Containment Verification"
	base_experience = 30
	cooldown_time = 180
	max_per_round = 12
	compatible_classes = list("containment")
	category = "containment"

/datum/experience_source/protocol_update
	source_id = "protocol_update"
	source_name = "Protocol Update"
	base_experience = 40
	cooldown_time = 300
	max_per_round = 8
	compatible_classes = list("containment")
	category = "containment"

/datum/experience_source/transfer_procedure
	source_id = "transfer_procedure"
	source_name = "SCP Transfer"
	base_experience = 60
	cooldown_time = 600
	max_per_round = 3
	compatible_classes = list("containment", "security")
	category = "containment"

/datum/experience_source/proc/can_award(ckey)
	if(!ckey)
		return FALSE

	var/datum/persistent_player_data/player_data = SSpersistent_progression.get_player_data(ckey)
	if(!player_data)
		return FALSE

	if(length(compatible_classes) && !(player_data.current_class_id in compatible_classes))
		return FALSE

	if(max_per_round > 0)
		var/count = 0
		for(var/list/source_data in player_data.experience_sources)
			if(source_data["source"] == source_id)
				count++
		if(count >= max_per_round)
			return FALSE

	if(cooldown_time > 0)
		var/last_award = 0
		for(var/i = length(player_data.experience_sources); i >= 1; i--)
			var/list/source_data = player_data.experience_sources[i]
			if(source_data["source"] == source_id)
				last_award = source_data["timestamp"]
				break

		if(world.time - last_award < cooldown_time)
			return FALSE

	return TRUE

/datum/experience_source/proc/get_final_experience(ckey, amount = 0)
	var/final_amount = amount > 0 ? amount : base_experience

	var/datum/persistent_player_data/player_data = SSpersistent_progression.get_player_data(ckey)
	if(!player_data)
		return final_amount

	var/datum/persistent_class/class = SSpersistent_progression.get_class(player_data.current_class_id)
	if(class)
		final_amount *= class.experience_multiplier
		final_amount *= class_multiplier

	var/datum/persistent_faction/faction = SSpersistent_progression.get_faction(player_data.current_faction_id)
	if(faction)
		final_amount *= faction.experience_multiplier
		final_amount *= faction_multiplier

	if(rank_multiplier > 0)
		final_amount *= (1 + (player_data.current_rank * rank_multiplier))

	return round(final_amount)

/proc/get_all_experience_sources()
	var/list/sources = list()
	for(var/source_type in typesof(/datum/experience_source))
		if(source_type == /datum/experience_source)
			continue
		var/datum/experience_source/source = new source_type()
		sources[source.source_id] = source
	return sources

/proc/get_experience_sources_by_category(category)
	var/list/sources = list()
	for(var/source_type in typesof(/datum/experience_source))
		if(source_type == /datum/experience_source)
			continue
		var/datum/experience_source/source = new source_type()
		if(source.category == category)
			sources[source.source_id] = source
	return sources

/proc/get_experience_sources_for_class(class_id)
	var/list/sources = list()
	for(var/source_type in typesof(/datum/experience_source))
		if(source_type == /datum/experience_source)
			continue
		var/datum/experience_source/source = new source_type()
		if(!length(source.compatible_classes) || (class_id in source.compatible_classes))
			sources[source.source_id] = source
	return sources

/proc/get_visible_experience_sources()
	var/list/sources = list()
	for(var/source_type in typesof(/datum/experience_source))
		if(source_type == /datum/experience_source)
			continue
		var/datum/experience_source/source = new source_type()
		if(!source.hidden)
			sources[source.source_id] = source
	return sources

// SCP Experiment Experience Sources
/datum/experience_source/scp_experiment_success_major
	source_id = "scp_experiment_success_major"
	source_name = "Major Experiment Success"
	base_experience = 200
	cooldown_time = 1800
	max_per_round = 5
	compatible_classes = list("research", "containment")
	category = "scp"

/datum/experience_source/scp_experiment_success
	source_id = "scp_experiment_success"
	source_name = "Experiment Success"
	base_experience = 100
	cooldown_time = 900
	max_per_round = 10
	compatible_classes = list("research", "containment")
	category = "scp"

/datum/experience_source/scp_experiment_success_minor
	source_id = "scp_experiment_success_minor"
	source_name = "Minor Experiment Success"
	base_experience = 50
	cooldown_time = 600
	max_per_round = 15
	compatible_classes = list("research", "containment")
	category = "scp"

/datum/experience_source/scp_experiment_failure
	source_id = "scp_experiment_failure"
	source_name = "Experiment Failure"
	base_experience = -50
	cooldown_time = 300
	max_per_round = 10
	compatible_classes = list("research", "containment")
	category = "scp"

/datum/experience_source/scp_experiment_catastrophic
	source_id = "scp_experiment_catastrophic"
	source_name = "Catastrophic Failure"
	base_experience = -200
	cooldown_time = 3600
	max_per_round = 3
	compatible_classes = list("research", "containment")
	category = "scp"

// Containment Rating Experience Sources
/datum/experience_source/containment_rating_s
	source_id = "containment_rating_s"
	source_name = "S-Rated Containment"
	base_experience = 150
	cooldown_time = 0
	max_per_round = -1
	compatible_classes = list("security", "containment")
	category = "scp"

/datum/experience_source/containment_rating_a
	source_id = "containment_rating_a"
	source_name = "A-Rated Containment"
	base_experience = 100
	cooldown_time = 0
	max_per_round = -1
	compatible_classes = list("security", "containment")
	category = "scp"

/datum/experience_source/containment_rating_b
	source_id = "containment_rating_b"
	source_name = "B-Rated Containment"
	base_experience = 50
	cooldown_time = 0
	max_per_round = -1
	compatible_classes = list("security", "containment")
	category = "scp"

/datum/experience_source/containment_rating_c
	source_id = "containment_rating_c"
	source_name = "C-Rated Containment"
	base_experience = 25
	cooldown_time = 0
	max_per_round = -1
	compatible_classes = list("security", "containment")
	category = "scp"

/datum/experience_source/containment_rating_d
	source_id = "containment_rating_d"
	source_name = "D-Rated Containment"
	base_experience = 0
	cooldown_time = 0
	max_per_round = -1
	compatible_classes = list("security", "containment")
	category = "scp"

/datum/experience_source/containment_rating_f
	source_id = "containment_rating_f"
	source_name = "F-Rated Containment"
	base_experience = -50
	cooldown_time = 0
	max_per_round = -1
	compatible_classes = list("security", "containment")
	category = "scp"

// SCP Interaction Experience Sources
/datum/experience_source/scp_first_contact
	source_id = "scp_first_contact"
	source_name = "First Contact"
	base_experience = 100
	cooldown_time = 0
	max_per_round = -1
	compatible_classes = list("security", "research", "medical", "engineering", "administrative", "containment")
	category = "scp"

/datum/experience_source/scp_observation
	source_id = "scp_observation"
	source_name = "SCP Observation"
	base_experience = 5
	cooldown_time = 300
	max_per_round = 30
	compatible_classes = list("research", "containment")
	category = "scp"

/datum/experience_source/scp_combat
	source_id = "scp_combat"
	source_name = "SCP Combat"
	base_experience = 10
	cooldown_time = 180
	max_per_round = 20
	compatible_classes = list("security", "containment")
	category = "scp"

/datum/experience_source/scp_containment_assist
	source_id = "scp_containment_assist"
	source_name = "Containment Assist"
	base_experience = 25
	cooldown_time = 600
	max_per_round = 10
	compatible_classes = list("security", "containment")
	category = "scp"

/datum/experience_source/scp_research_contribution
	source_id = "scp_research_contribution"
	source_name = "Research Contribution"
	base_experience = 15
	cooldown_time = 300
	max_per_round = 15
	compatible_classes = list("research")
	category = "scp"

/datum/experience_source/scp_care_provided
	source_id = "scp_care_provided"
	source_name = "SCP Care"
	base_experience = 15
	cooldown_time = 300
	max_per_round = 15
	compatible_classes = list("research", "medical")
	category = "scp"

/datum/experience_source/scp_survival
	source_id = "scp_survival"
	source_name = "SCP Survival"
	base_experience = 1
	cooldown_time = 60
	max_per_round = -1
	compatible_classes = list("security", "research", "medical", "engineering", "administrative", "containment")
	category = "scp"

/datum/experience_source/scp_exploration_milestone
	source_id = "scp_exploration_milestone"
	source_name = "Exploration Milestone"
	base_experience = 50
	cooldown_time = 1800
	max_per_round = 10
	compatible_classes = list("security", "containment")
	category = "scp"

// Specialization Experience Sources
/datum/experience_source/scp_specialization_research
	source_id = "scp_specialization_research"
	source_name = "Research Specialization"
	base_experience = 50
	cooldown_time = 3600
	max_per_round = 5
	compatible_classes = list("research")
	category = "scp"

/datum/experience_source/scp_specialization_containment
	source_id = "scp_specialization_containment"
	source_name = "Containment Specialization"
	base_experience = 50
	cooldown_time = 3600
	max_per_round = 5
	compatible_classes = list("security", "containment")
	category = "scp"

/datum/experience_source/scp_specialization_field
	source_id = "scp_specialization_field"
	source_name = "Field Operations"
	base_experience = 50
	cooldown_time = 3600
	max_per_round = 5
	compatible_classes = list("security", "containment")
	category = "scp"

/datum/experience_source/scp_specialization_medical
	source_id = "scp_specialization_medical"
	source_name = "Medical Specialization"
	base_experience = 50
	cooldown_time = 3600
	max_per_round = 5
	compatible_classes = list("medical")
	category = "scp"

/datum/experience_source/scp_milestone
	source_id = "scp_milestone"
	source_name = "SCP Milestone"
	base_experience = 100
	cooldown_time = 0
	max_per_round = -1
	compatible_classes = list("security", "research", "medical", "engineering", "administrative", "containment")
	category = "scp"
