// Foundation-19 Job Hooks
// Automatically integrates job assignments with persistent progression

// Hook for when a player is assigned a job
/datum/job/proc/on_job_assigned(mob/living/carbon/human/H)
	if(!H || !H.mind || !H.ckey)
		return

	// Integrate with persistent progression system
	if(SSpersistent_progression && SSpersistent_progression.job_integration)
		SSpersistent_progression.job_integration.on_job_assigned(H, src)

	// Add job-specific experience
	var/datum/persistent_player_data/player_data = SSpersistent_progression.get_player_data(H.ckey)
	if(player_data)
		player_data.set_current_job(title)
		player_data.add_job_experience(title, 25, "Job Assignment")

// Hook for job performance tracking
/datum/job/proc/track_job_performance(mob/living/carbon/human/H, action_type, details = "")
	if(!H || !H.mind || !H.ckey)
		return

	if(SSpersistent_progression && SSpersistent_progression.job_integration)
		SSpersistent_progression.job_integration.on_job_performance(H, title, action_type, details)

// Security job hooks
/datum/job/lcz_guard/proc/on_patrol_completed(mob/living/carbon/human/H)
	track_job_performance(H, "patrol", "Completed LCZ patrol")

/datum/job/hcz_guard/proc/on_patrol_completed(mob/living/carbon/human/H)
	track_job_performance(H, "patrol", "Completed HCZ patrol")

/datum/job/ez_guard/proc/on_patrol_completed(mob/living/carbon/human/H)
	track_job_performance(H, "patrol", "Completed EZ patrol")

/datum/job/mtf_operative/proc/on_mtf_operation(mob/living/carbon/human/H, operation_type)
	track_job_performance(H, "mtf_operation", "MTF Operation: [operation_type]")

/datum/job/mtf_commander/proc/on_mtf_operation_commanded(mob/living/carbon/human/H, operation_type)
	track_job_performance(H, "mtf_operation", "Commanded MTF Operation: [operation_type]")

/datum/job/detective/proc/on_investigation_completed(mob/living/carbon/human/H, case_type)
	track_job_performance(H, "investigation", "Completed investigation: [case_type]")

// Medical job hooks
/datum/job/medical_doctor/proc/on_medical_procedure(mob/living/carbon/human/H, procedure_type, patient)
	track_job_performance(H, "treatment", "Medical procedure: [procedure_type]")

	if(SSpersistent_progression && SSpersistent_progression.job_integration)
		SSpersistent_progression.job_integration.on_medical_procedure(H, procedure_type, patient, "successful")

/datum/job/surgeon/proc/on_surgery_completed(mob/living/carbon/human/H, surgery_type, patient)
	track_job_performance(H, "surgery", "Surgery completed: [surgery_type]")

	if(SSpersistent_progression && SSpersistent_progression.job_integration)
		SSpersistent_progression.job_integration.on_medical_procedure(H, "surgery", patient, "successful")

/datum/job/paramedic/proc/on_emergency_response(mob/living/carbon/human/H, emergency_type)
	track_job_performance(H, "emergency_medical", "Emergency response: [emergency_type]")

/datum/job/virologist/proc/on_virus_research(mob/living/carbon/human/H, virus_type)
	track_job_performance(H, "scp_research", "Virus research: [virus_type]")

// Science job hooks
/datum/job/researcher/proc/on_research_completed(mob/living/carbon/human/H, research_type)
	track_job_performance(H, "scp_research", "Research completed: [research_type]")

/datum/job/senior_researcher/proc/on_research_led(mob/living/carbon/human/H, research_type)
	track_job_performance(H, "scp_research", "Led research: [research_type]")

/datum/job/field_agent/proc/on_field_research(mob/living/carbon/human/H, location)
	track_job_performance(H, "field_research", "Field research at: [location]")

/datum/job/xenobiologist/proc/on_xenobiology_study(mob/living/carbon/human/H, specimen_type)
	track_job_performance(H, "scp_research", "Xenobiology study: [specimen_type]")

/datum/job/roboticist/proc/on_robot_created(mob/living/carbon/human/H, robot_type)
	track_job_performance(H, "construction", "Robot created: [robot_type]")

// Engineering job hooks
/datum/job/engineer/proc/on_maintenance_completed(mob/living/carbon/human/H, system_type)
	track_job_performance(H, "maintenance", "Maintenance completed: [system_type]")

/datum/job/senior_engineer/proc/on_project_led(mob/living/carbon/human/H, project_type)
	track_job_performance(H, "construction", "Project led: [project_type]")

/datum/job/containment_engineer/proc/on_containment_system(mob/living/carbon/human/H, system_type)
	track_job_performance(H, "containment_system", "Containment system: [system_type]")

/datum/job/atmospheric_technician/proc/on_atmosphere_work(mob/living/carbon/human/H, work_type)
	track_job_performance(H, "maintenance", "Atmospheric work: [work_type]")

// Supply job hooks
/datum/job/quartermaster/proc/on_supply_managed(mob/living/carbon/human/H, supply_type, amount)
	track_job_performance(H, "cargo_management", "Supply managed: [supply_type] x[amount]")

/datum/job/cargo_technician/proc/on_cargo_processed(mob/living/carbon/human/H, cargo_type)
	track_job_performance(H, "cargo_management", "Cargo processed: [cargo_type]")

/datum/job/shaft_miner/proc/on_mining_completed(mob/living/carbon/human/H, mineral_type, amount)
	track_job_performance(H, "mining", "Mining completed: [mineral_type] x[amount]")

// Service job hooks
/datum/job/cook/proc/on_meal_prepared(mob/living/carbon/human/H, meal_type)
	track_job_performance(H, "cooking", "Meal prepared: [meal_type]")

/datum/job/janitor/proc/on_area_cleaned(mob/living/carbon/human/H, area_type)
	track_job_performance(H, "cleaning", "Area cleaned: [area_type]")

/datum/job/chaplain/proc/on_counseling_session(mob/living/carbon/human/H, session_type)
	track_job_performance(H, "counseling", "Counseling session: [session_type]")

/datum/job/botanist/proc/on_plant_grown(mob/living/carbon/human/H, plant_type)
	track_job_performance(H, "cooking", "Plant grown: [plant_type]")

// D-Class job hooks
/datum/job/dclass_general/proc/on_testing_participated(mob/living/carbon/human/H, test_type)
	track_job_performance(H, "routine_testing", "Testing participated: [test_type]")

/datum/job/dclass_research/proc/on_research_testing(mob/living/carbon/human/H, test_type, scp_id)
	track_job_performance(H, "research_testing", "Research testing: [test_type] for SCP-[scp_id]")

	if(SSpersistent_progression && SSpersistent_progression.job_integration)
		SSpersistent_progression.job_integration.on_dclass_testing(H, "research", scp_id, "completed")

// Command job hooks
/datum/job/site_director/proc/on_directive_issued(mob/living/carbon/human/H, directive_type)
	track_job_performance(H, "command", "Directive issued: [directive_type]")

/datum/job/guard_commander/proc/on_security_operation_commanded(mob/living/carbon/human/H, operation_type)
	track_job_performance(H, "command", "Security operation commanded: [operation_type]")

/datum/job/research_director/proc/on_research_approved(mob/living/carbon/human/H, research_type)
	track_job_performance(H, "command", "Research approved: [research_type]")

// Global job performance tracking
/proc/track_job_performance_global(mob/living/carbon/human/H, action_type, details = "")
	if(!H || !H.mind || !H.job)
		return

	var/datum/job/J = SSjob.GetJob(H.job)
	if(J)
		J.track_job_performance(H, action_type, details)

// Hook for containment breach responses
/proc/track_containment_breach_response(scp_id, responders)
	if(SSpersistent_progression && SSpersistent_progression.job_integration)
		SSpersistent_progression.job_integration.on_containment_breach(scp_id, responders)

// Hook for SCP interactions
/proc/track_scp_interaction(mob/living/carbon/human/H, scp_id, interaction_type, outcome)
	if(SSpersistent_progression && SSpersistent_progression.job_integration)
		SSpersistent_progression.job_integration.on_scp_interaction(H, scp_id, interaction_type, outcome)

// Hook for round end processing
/proc/process_job_round_end()
	if(SSpersistent_progression && SSpersistent_progression.job_integration)
		SSpersistent_progression.job_integration.on_round_end()

// Automatic job assignment hook
/hook/job_assigned/proc/on_job_assigned_hook(mob/living/carbon/human/H, datum/job/J)
	if(!H || !J)
		return

	// Call the job's on_job_assigned method
	if(istype(J, /datum/job))
		J.on_job_assigned(H)

	return TRUE
