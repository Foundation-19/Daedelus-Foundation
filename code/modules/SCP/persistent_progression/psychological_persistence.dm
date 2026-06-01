// Psychological Persistence System
// Tracks mental health of staff, psychological effects of SCP exposure, and therapy sessions

SUBSYSTEM_DEF(psychological_persistence)
	name = "Psychological Persistence"
	wait = 900 // 15 seconds
	priority = FIRE_PRIORITY_INPUT

	var/datum/psychological_persistence_manager/manager

/datum/psychological_persistence_manager
	var/list/mental_health_records = list() // ckey -> mental_health_record
	var/list/therapy_sessions = list() // session_id -> therapy_session
	var/list/scp_exposure_effects = list() // exposure_id -> scp_exposure_effect
	var/list/stress_events = list() // stress_id -> stress_event
	var/list/psychological_assessments = list() // assessment_id -> psychological_assessment
	var/list/mental_health_incidents = list() // incident_id -> mental_health_incident

	// Global psychological metrics
	var/total_staff_assessed = 0
	var/average_mental_health = 100
	var/stress_level = 0
	var/therapy_success_rate = 1.0
	var/scp_exposure_cases = 0
	var/mental_health_budget = 300000

/datum/mental_health_record
	var/ckey
	var/real_name
	var/mental_health_score = 100 // 0-100 scale
	var/stress_level = 0 // 0-100 scale
	var/anxiety_level = 0 // 0-100 scale
	var/depression_level = 0 // 0-100 scale
	var/trauma_level = 0 // 0-100 scale
	var/list/psychological_symptoms = list()
	var/list/treatment_history = list()
	var/list/scp_exposures = list()
	var/last_assessment
	var/assessment_frequency = 7 // Days between assessments
	var/risk_level = "LOW" // LOW, MEDIUM, HIGH, CRITICAL
	// Additional properties for real data tracking
	var/scp_exposure_count = 0
	var/list/stress_events = list()
	var/list/therapy_sessions = list()
	var/medication_adherence = 1.0
	var/work_performance_rating = 1.0
	var/social_support_level = 1.0
	var/sleep_quality = 1.0

/datum/mental_health_record/New(var/ckey, var/real_name)
		src.ckey = ckey
		src.real_name = real_name
		src.last_assessment = world.time

/datum/therapy_session
	var/session_id
	var/patient_ckey
	var/therapist_ckey
	var/session_type
	var/session_date
	var/session_duration = 0
	var/session_effectiveness = 1.0
	var/list/session_notes = list()
	var/list/treatment_goals = list()
	var/list/achievements = list()
	var/patient_satisfaction = 0 // 0-100 scale
	var/therapist_rating = 0 // 0-100 scale
	var/status = "SCHEDULED" // SCHEDULED, IN_PROGRESS, COMPLETED, CANCELLED
	// Additional properties for real data tracking
	var/session_progress = 0
	var/therapist_experience = 0
	var/patient_engagement = 0
	var/therapist_rapport = 0
	var/breakthrough_moments = 0
	var/homework_assigned = 0
	var/homework_completed = 0
	var/medication_compliance_discussed = FALSE

/datum/therapy_session/New(var/session_id, var/patient_ckey, var/therapist_ckey, var/session_type)
		src.session_id = session_id
		src.patient_ckey = patient_ckey
		src.therapist_ckey = therapist_ckey
		src.session_type = session_type
		src.session_date = world.time

/datum/scp_exposure_effect
	var/exposure_id
	var/patient_ckey
	var/scp_id
	var/exposure_type
	var/exposure_duration = 0
	var/exposure_intensity = 1 // 1-5 scale
	var/list/psychological_effects = list()
	var/list/physical_symptoms = list()
	var/list/cognitive_impairments = list()
	var/recovery_time = 0
	var/recovery_status = "ONGOING" // ONGOING, RECOVERED, PERMANENT
	var/exposure_date
	var/recovery_date
	// Additional properties for real data tracking
	var/treatment_sessions = 0
	var/medication_compliance = 0
	var/support_network = 0
	var/therapy_effectiveness = 0
	var/symptom_severity = 1
	var/functional_impairment = 0
	var/coping_strategies_learned = 0

/datum/scp_exposure_effect/New(var/exposure_id, var/patient_ckey, var/scp_id, var/exposure_type)
		src.exposure_id = exposure_id
		src.patient_ckey = patient_ckey
		src.scp_id = scp_id
		src.exposure_type = exposure_type
		src.exposure_date = world.time

/datum/stress_event
	var/stress_id
	var/patient_ckey
	var/stress_type
	var/stress_description
	var/stress_intensity = 1 // 1-5 scale
	var/stress_duration = 0
	var/list/stress_symptoms = list()
	var/list/coping_mechanisms = list()
	var/stress_resolution = "UNRESOLVED" // UNRESOLVED, RESOLVED, ESCALATED
	var/event_date
	var/resolution_date
	// Additional properties for real data tracking
	var/coping_mechanisms_used = 0
	var/support_received = 0
	var/therapy_sessions = 0
	var/stress_impact_level = 1
	var/work_performance_affected = FALSE
	var/social_functioning_affected = FALSE
	var/sleep_quality_impact = 0

/datum/stress_event/New(var/stress_id, var/patient_ckey, var/stress_type, var/stress_description)
		src.stress_id = stress_id
		src.patient_ckey = patient_ckey
		src.stress_type = stress_type
		src.stress_description = stress_description
		src.event_date = world.time

/datum/psychological_assessment
	var/assessment_id
	var/patient_ckey
	var/assessor_ckey
	var/assessment_type
	var/assessment_date
	var/assessment_duration = 0
	var/list/assessment_results = list()
	var/list/recommendations = list()
	var/risk_assessment = "LOW"
	var/follow_up_required = FALSE
	var/follow_up_date
	var/assessment_notes = ""

/datum/psychological_assessment/New(var/assessment_id, var/patient_ckey, var/assessor_ckey, var/assessment_type)
		src.assessment_id = assessment_id
		src.patient_ckey = patient_ckey
		src.assessor_ckey = assessor_ckey
		src.assessment_type = assessment_type
		src.assessment_date = world.time

/datum/mental_health_incident
	var/incident_id
	var/patient_ckey
	var/incident_type
	var/incident_description
	var/incident_severity = 1 // 1-5 scale
	var/incident_location
	var/list/involved_personnel = list()
	var/list/incident_effects = list()
	var/incident_date
	var/resolution_date
	var/status = "ACTIVE" // ACTIVE, RESOLVED, ESCALATED
	var/requires_intervention = FALSE

/datum/mental_health_incident/New(var/incident_id, var/patient_ckey, var/incident_type, var/incident_description)
		src.incident_id = incident_id
		src.patient_ckey = patient_ckey
		src.incident_type = incident_type
		src.incident_description = incident_description
		src.incident_date = world.time

// Subsystem initialization
/datum/controller/subsystem/psychological_persistence/Initialize()
	log_game("Psychological persistence subsystem initializing...")
	manager = new /datum/psychological_persistence_manager()
	log_game("Psychological persistence manager created")

	// Load existing psychological data from game systems
	log_game("Loading existing psychological data...")
	manager.load_existing_psychological_data()

	log_game("Mental health records count at initialization: [length(manager.mental_health_records)]")
	return ..()

/datum/controller/subsystem/psychological_persistence/fire()
	if(manager)
		manager.process_psychological()

// Load existing psychological data from game systems
/datum/psychological_persistence_manager/proc/load_existing_psychological_data()
	log_game("Psychological: Loading existing psychological data...")

	// Load from general records (station records)
	if(SSdatacore)
		for(var/datum/data/record/general_record in SSdatacore.get_records(DATACORE_RECORDS_STATION))
			if(general_record.fields[DATACORE_NAME])
				var/ckey = ckey(general_record.fields[DATACORE_NAME])
				if(!(ckey in mental_health_records))
					var/datum/mental_health_record/record = new /datum/mental_health_record(ckey, general_record.fields[DATACORE_NAME])

					// Set initial mental health based on mental status
					if(general_record.fields[DATACORE_MENTAL_HEALTH] == "*Insane*")
						record.mental_health_score = 20
						record.risk_level = "CRITICAL"
					else if(general_record.fields[DATACORE_MENTAL_HEALTH] == "*Unstable*")
						record.mental_health_score = 40
						record.risk_level = "HIGH"
					else if(general_record.fields[DATACORE_MENTAL_HEALTH] == "*Watch*")
						record.mental_health_score = 60
						record.risk_level = "MEDIUM"
					else if(general_record.fields[DATACORE_MENTAL_HEALTH] == "Stable")
						record.mental_health_score = 80
						record.risk_level = "LOW"
					else
						record.mental_health_score = 100
						record.risk_level = "LOW"

					mental_health_records[ckey] = record
					total_staff_assessed++

	log_game("Psychological: Loaded [length(mental_health_records)] mental health records")

// Add mental health record
/datum/psychological_persistence_manager/proc/add_mental_health_record(var/ckey, var/real_name)
	var/datum/mental_health_record/record = new /datum/mental_health_record(ckey, real_name)
	mental_health_records[ckey] = record
	total_staff_assessed++
	return record

// Add therapy session
/datum/psychological_persistence_manager/proc/add_therapy_session(var/patient_ckey, var/therapist_ckey, var/session_type)
	var/session_id = "THERAPY_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/therapy_session/session = new /datum/therapy_session(
		session_id,
		patient_ckey,
		therapist_ckey,
		session_type
	)
	therapy_sessions[session_id] = session
	return session

// Add SCP exposure effect
/datum/psychological_persistence_manager/proc/add_scp_exposure_effect(var/patient_ckey, var/scp_id, var/exposure_type)
	var/exposure_id = "EXPOSURE_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/scp_exposure_effect/effect = new /datum/scp_exposure_effect(
		exposure_id,
		patient_ckey,
		scp_id,
		exposure_type
	)
	scp_exposure_effects[exposure_id] = effect
	scp_exposure_cases++
	return effect

// Add stress event
/datum/psychological_persistence_manager/proc/add_stress_event(var/patient_ckey, var/stress_type, var/stress_description)
	var/stress_id = "STRESS_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/stress_event/event = new /datum/stress_event(
		stress_id,
		patient_ckey,
		stress_type,
		stress_description
	)
	stress_events[stress_id] = event
	return event

// Add psychological assessment
/datum/psychological_persistence_manager/proc/add_psychological_assessment(var/patient_ckey, var/assessor_ckey, var/assessment_type)
	var/assessment_id = "ASSESS_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/psychological_assessment/assessment = new /datum/psychological_assessment(
		assessment_id,
		patient_ckey,
		assessor_ckey,
		assessment_type
	)
	psychological_assessments[assessment_id] = assessment
	return assessment

// Add mental health incident
/datum/psychological_persistence_manager/proc/add_mental_health_incident(var/patient_ckey, var/incident_type, var/incident_description)
	var/incident_id = "MH_INC_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/mental_health_incident/incident = new /datum/mental_health_incident(
		incident_id,
		patient_ckey,
		incident_type,
		incident_description
	)
	mental_health_incidents[incident_id] = incident
	return incident

// Process psychological data
/datum/psychological_persistence_manager/proc/process_psychological()
	// Update mental health records
	update_mental_health_records()

	// Update therapy sessions
	update_therapy_sessions()

	// Update SCP exposure effects
	update_scp_exposure_effects()

	// Update stress events
	update_stress_events()

	// Update psychological assessments
	update_psychological_assessments()

	// Calculate global metrics
	calculate_global_metrics()

	// Save data periodically
	if(world.time % 9000 == 0) // Every 15 minutes
		save_psychological_data()

// Update mental health records
/datum/psychological_persistence_manager/proc/update_mental_health_records()
	for(var/ckey in mental_health_records)
		var/datum/mental_health_record/record = mental_health_records[ckey]

		// Calculate real mental health changes based on actual game data
		record.mental_health_score = calculate_real_mental_health_score(record)

		// Update risk level based on mental health score
		if(record.mental_health_score <= 20)
			record.risk_level = "CRITICAL"
		else if(record.mental_health_score <= 40)
			record.risk_level = "HIGH"
		else if(record.mental_health_score <= 60)
			record.risk_level = "MEDIUM"
		else
			record.risk_level = "LOW"

// Calculate real mental health score based on actual game data
/datum/psychological_persistence_manager/proc/calculate_real_mental_health_score(var/datum/mental_health_record/record)
	var/base_score = 75 // Default mental health score

	// Score decreases based on SCP exposure
	if(record.scp_exposure_count > 0)
		base_score -= record.scp_exposure_count * 5

	// Score decreases based on stress events
	if(length(record.stress_events) > 0)
		base_score -= length(record.stress_events) * 3

	// Score increases based on therapy sessions
	if(length(record.therapy_sessions) > 0)
		base_score += length(record.therapy_sessions) * 2

	// Score decreases based on time since last assessment
	var/time_since_assessment = world.time - record.last_assessment
	base_score -= time_since_assessment / 600000 // Decay over 1000 minutes

	return max(0, min(100, base_score))

// Update therapy sessions with real data
/datum/psychological_persistence_manager/proc/update_therapy_sessions()
	for(var/session_id in therapy_sessions)
		var/datum/therapy_session/session = therapy_sessions[session_id]
		if(session.status == "IN_PROGRESS")
			// Calculate real therapy completion based on actual session progress
			if(session.session_progress >= 100)
				session.status = "COMPLETED"
				session.session_duration = (world.time - session.session_date) / 600 // Convert to minutes
				session.session_effectiveness = calculate_real_therapy_effectiveness(session)
				session.patient_satisfaction = calculate_real_patient_satisfaction(session)

// Calculate real therapy effectiveness based on actual session data
/datum/psychological_persistence_manager/proc/calculate_real_therapy_effectiveness(var/datum/therapy_session/session)
	var/base_effectiveness = 0.7 // Default effectiveness

	// Effectiveness based on therapist experience
	if(session.therapist_experience > 0)
		base_effectiveness += session.therapist_experience * 0.01

	// Effectiveness based on session duration
	var/session_duration = (world.time - session.session_date) / 600 // Minutes
	base_effectiveness += min(0.2, session_duration / 60) // Max 20% from duration

	// Effectiveness based on patient engagement
	base_effectiveness += session.patient_engagement * 0.1

	return min(1.0, base_effectiveness)

// Calculate real patient satisfaction based on actual session data
/datum/psychological_persistence_manager/proc/calculate_real_patient_satisfaction(var/datum/therapy_session/session)
	var/base_satisfaction = 70 // Default satisfaction

	// Satisfaction based on session effectiveness
	base_satisfaction += session.session_effectiveness * 20

	// Satisfaction based on therapist rapport
	base_satisfaction += session.therapist_rapport * 5

	// Satisfaction based on session duration (not too short, not too long)
	var/session_duration = (world.time - session.session_date) / 600 // Minutes
	if(session_duration >= 30 && session_duration <= 90)
		base_satisfaction += 10
	else if(session_duration < 15 || session_duration > 120)
		base_satisfaction -= 10

	return max(0, min(100, base_satisfaction))

// Update SCP exposure effects with real data
/datum/psychological_persistence_manager/proc/update_scp_exposure_effects()
	for(var/exposure_id in scp_exposure_effects)
		var/datum/scp_exposure_effect/effect = scp_exposure_effects[exposure_id]
		if(effect.recovery_status == "ONGOING")
			// Calculate real recovery based on actual treatment and time
			if(calculate_real_recovery_progress(effect) >= 100)
				effect.recovery_status = "RECOVERED"
				effect.recovery_date = world.time
				effect.recovery_time = (world.time - effect.exposure_date) / 600 // Convert to minutes

// Calculate real recovery progress based on actual treatment data
/datum/psychological_persistence_manager/proc/calculate_real_recovery_progress(var/datum/scp_exposure_effect/effect)
	var/base_progress = 0

	// Progress based on time since exposure
	var/time_since_exposure = world.time - effect.exposure_date
	var/time_progress = min(50, time_since_exposure / 360000) // Max 50% from time, 360000 ticks = 60 minutes
	base_progress += time_progress

	// Progress based on treatment sessions
	base_progress += effect.treatment_sessions * 10

	// Progress based on medication compliance
	base_progress += effect.medication_compliance * 5

	// Progress based on support network
	base_progress += effect.support_network * 3

	return min(100, base_progress)

// Update stress events with real data
/datum/psychological_persistence_manager/proc/update_stress_events()
	for(var/stress_id in stress_events)
		var/datum/stress_event/event = stress_events[stress_id]
		if(event.stress_resolution == "UNRESOLVED")
			// Calculate real stress resolution based on actual coping mechanisms
			if(calculate_real_stress_resolution_progress(event) >= 100)
				event.stress_resolution = "RESOLVED"
				event.resolution_date = world.time
				event.stress_duration = (world.time - event.event_date) / 600 // Convert to minutes

// Calculate real stress resolution progress based on actual coping data
/datum/psychological_persistence_manager/proc/calculate_real_stress_resolution_progress(var/datum/stress_event/event)
	var/base_progress = 0

	// Progress based on time since event
	var/time_since_event = world.time - event.event_date
	var/time_progress = min(30, time_since_event / 720000) // Max 30% from time, 720000 ticks = 120 minutes
	base_progress += time_progress

	// Progress based on coping mechanisms used
	base_progress += event.coping_mechanisms_used * 15

	// Progress based on support received
	base_progress += event.support_received * 10

	// Progress based on therapy sessions
	base_progress += event.therapy_sessions * 20

	return min(100, base_progress)

// Update psychological assessments
/datum/psychological_persistence_manager/proc/update_psychological_assessments()
	for(var/assessment_id in psychological_assessments)
		var/datum/psychological_assessment/assessment = psychological_assessments[assessment_id]
		if(assessment.follow_up_required && !assessment.follow_up_date)
			// Schedule follow-up if needed
			assessment.follow_up_date = world.time + (7 * 24 * 60 * 60 * 10) // 7 days in deciseconds

// Calculate global metrics
/datum/psychological_persistence_manager/proc/calculate_global_metrics()
	// Calculate average mental health
	var/total_mental_health = 0
	var/record_count = 0
	for(var/ckey in mental_health_records)
		var/datum/mental_health_record/record = mental_health_records[ckey]
		total_mental_health += record.mental_health_score
		record_count++

	if(record_count > 0)
		average_mental_health = total_mental_health / record_count

	// Calculate therapy success rate
	var/successful_sessions = 0
	var/total_sessions = 0
	for(var/session_id in therapy_sessions)
		var/datum/therapy_session/session = therapy_sessions[session_id]
		if(session.status == "COMPLETED")
			total_sessions++
			if(session.session_effectiveness >= 0.7) // 70% effectiveness threshold
				successful_sessions++

	if(total_sessions > 0)
		therapy_success_rate = successful_sessions / total_sessions

	// Calculate overall stress level
	var/total_stress = 0
	var/stress_count = 0
	for(var/ckey in mental_health_records)
		var/datum/mental_health_record/record = mental_health_records[ckey]
		total_stress += record.stress_level
		stress_count++

	if(stress_count > 0)
		stress_level = total_stress / stress_count

// Save psychological data
/datum/psychological_persistence_manager/proc/save_psychological_data()
	// This would save data to persistent storage
	log_game("Psychological: Saving psychological data to persistent storage")

/datum/psychological_persistence_manager/proc/load_psychological_data()
	// This would load data from persistent storage
	log_game("Psychological: Loading psychological data from persistent storage")
