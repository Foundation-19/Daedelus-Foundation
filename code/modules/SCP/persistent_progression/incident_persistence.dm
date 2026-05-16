// Incident Persistence System
// Tracks all major incidents, breaches, and anomalies with response times and damage assessments

SUBSYSTEM_DEF(incident_persistence)
	name = "Incident Persistence"
	wait = 300 // 30 seconds
	priority = FIRE_PRIORITY_INPUT

	var/datum/incident_persistence_manager/manager

/datum/incident_persistence_manager
	var/list/incident_records = list() // incident_id -> incident_record
	var/list/breach_events = list() // breach_id -> breach_event
	var/list/response_logs = list() // response_id -> response_log
	var/list/casualty_reports = list() // casualty_id -> casualty_report
	var/list/damage_assessments = list() // damage_id -> damage_assessment
	var/list/containment_events = list() // containment_id -> containment_event

	// Global incident metrics
	var/total_incidents = 0
	var/active_incidents = 0
	var/average_response_time = 0
	var/total_casualties = 0
	var/total_damage_cost = 0
	var/containment_success_rate = 1.0

/datum/incident_record
	var/incident_id
	var/incident_type
	var/incident_description
	var/location
	var/severity = 1 // 1-5 scale
	var/start_time
	var/end_time
	var/status = "ACTIVE" // ACTIVE, CONTAINED, RESOLVED, ESCALATED
	var/list/affected_areas = list()
	var/list/involved_personnel = list()
	var/incident_classification = "UNCLASSIFIED"
	var/response_priority = 1 // 1-5 scale

/datum/incident_record/New(var/incident_id, var/incident_type, var/incident_description, var/location)
		src.incident_id = incident_id
		src.incident_type = incident_type
		src.incident_description = incident_description
		src.location = location
		src.start_time = world.time

/datum/breach_event
	var/breach_id
	var/breach_type
	var/breach_description
	var/breach_location
	var/containment_level = 1 // 1-5 scale
	var/breach_start_time
	var/containment_time
	var/breach_duration = 0
	var/status = "ACTIVE" // ACTIVE, CONTAINED, ESCALATED
	var/list/containment_protocols = list()
	var/list/affected_scps = list()
	var/breach_radius = 0

/datum/breach_event/New(var/breach_id, var/breach_type, var/breach_description, var/breach_location)
		src.breach_id = breach_id
		src.breach_type = breach_type
		src.breach_description = breach_description
		src.breach_location = breach_location
		src.breach_start_time = world.time

/datum/response_log
	var/response_id
	var/incident_id
	var/response_team
	var/response_type
	var/response_start_time
	var/response_end_time
	var/response_duration = 0
	var/response_effectiveness = 1.0
	var/list/response_actions = list()
	var/list/equipment_used = list()
	var/team_leader
	var/status = "DEPLOYED" // DEPLOYED, ON_SITE, COMPLETED, FAILED

/datum/response_log/New(var/response_id, var/incident_id, var/response_team, var/response_type, var/team_leader)
		src.response_id = response_id
		src.incident_id = incident_id
		src.response_team = response_team
		src.response_type = response_type
		src.team_leader = team_leader
		src.response_start_time = world.time

/datum/casualty_report
	var/casualty_id
	var/incident_id
	var/victim_name
	var/victim_ckey
	var/injury_type
	var/injury_severity = 1 // 1-5 scale
	var/injury_location
	var/treatment_required
	var/treatment_provided
	var/outcome = "UNKNOWN" // UNKNOWN, TREATED, RECOVERED, DECEASED
	var/injury_time
	var/treatment_time

/datum/casualty_report/New(var/casualty_id, var/incident_id, var/victim_name, var/victim_ckey, var/injury_type)
		src.casualty_id = casualty_id
		src.incident_id = incident_id
		src.victim_name = victim_name
		src.victim_ckey = victim_ckey
		src.injury_type = injury_type
		src.injury_time = world.time

/datum/damage_assessment
	var/damage_id
	var/incident_id
	var/damage_type
	var/damage_location
	var/damage_severity = 1 // 1-5 scale
	var/estimated_cost = 0
	var/repair_time_estimate = 0
	var/repair_priority = 1 // 1-5 scale
	var/repair_status = "PENDING" // PENDING, IN_PROGRESS, COMPLETED
	var/damage_description
	var/affected_systems = list()

/datum/damage_assessment/New(var/damage_id, var/incident_id, var/damage_type, var/damage_location)
		src.damage_id = damage_id
		src.incident_id = incident_id
		src.damage_type = damage_type
		src.damage_location = damage_location

/datum/containment_event
	var/containment_id
	var/incident_id
	var/containment_method
	var/containment_location
	var/containment_start_time
	var/containment_end_time
	var/containment_duration = 0
	var/containment_success = FALSE
	var/containment_effectiveness = 1.0
	var/list/containment_procedures = list()
	var/containment_cost = 0

/datum/containment_event/New(var/containment_id, var/incident_id, var/containment_method, var/containment_location)
		src.containment_id = containment_id
		src.incident_id = incident_id
		src.containment_method = containment_method
		src.containment_location = containment_location
		src.containment_start_time = world.time

// Subsystem initialization
/datum/controller/subsystem/incident_persistence/Initialize()
	world.log << "Incident persistence subsystem initializing..."
	manager = new /datum/incident_persistence_manager()
	world.log << "Incident persistence manager created"

	// Load existing incident data from game systems
	world.log << "Loading existing incident data..."
	manager.load_existing_incident_data()

	world.log << "Incident records count at initialization: [length(manager.incident_records)]"
	return ..()

/datum/controller/subsystem/incident_persistence/fire()
	if(manager)
		manager.process_incidents()

// Load existing incident data from game systems
/datum/incident_persistence_manager/proc/load_existing_incident_data()
	world.log << "Incident: Loading existing incident data..."

	// Monitor for active incidents in the game world
	// This would integrate with existing game systems to detect incidents
	world.log << "Incident: Monitoring for active incidents..."

// Add incident record
/datum/incident_persistence_manager/proc/add_incident_record(var/incident_type, var/incident_description, var/location)
	var/incident_id = "INC_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/incident_record/record = new /datum/incident_record(
		incident_id,
		incident_type,
		incident_description,
		location
	)
	incident_records[incident_id] = record
	total_incidents++
	active_incidents++
	return record

// Add breach event
/datum/incident_persistence_manager/proc/add_breach_event(var/breach_type, var/breach_description, var/breach_location)
	var/breach_id = "BREACH_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/breach_event/event = new /datum/breach_event(
		breach_id,
		breach_type,
		breach_description,
		breach_location
	)
	breach_events[breach_id] = event
	return event

// Add response log
/datum/incident_persistence_manager/proc/add_response_log(var/incident_id, var/response_team, var/response_type, var/team_leader)
	var/response_id = "RESP_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/response_log/log = new /datum/response_log(
		response_id,
		incident_id,
		response_team,
		response_type,
		team_leader
	)
	response_logs[response_id] = log
	return log

// Add casualty report
/datum/incident_persistence_manager/proc/add_casualty_report(var/incident_id, var/victim_name, var/victim_ckey, var/injury_type)
	var/casualty_id = "CAS_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/casualty_report/report = new /datum/casualty_report(
		casualty_id,
		incident_id,
		victim_name,
		victim_ckey,
		injury_type
	)
	casualty_reports[casualty_id] = report
	total_casualties++
	return report

// Add damage assessment
/datum/incident_persistence_manager/proc/add_damage_assessment(var/incident_id, var/damage_type, var/damage_location)
	var/damage_id = "DAM_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/damage_assessment/assessment = new /datum/damage_assessment(
		damage_id,
		incident_id,
		damage_type,
		damage_location
	)
	damage_assessments[damage_id] = assessment
	return assessment

// Add containment event
/datum/incident_persistence_manager/proc/add_containment_event(var/incident_id, var/containment_method, var/containment_location)
	var/containment_id = "CONT_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/containment_event/event = new /datum/containment_event(
		containment_id,
		incident_id,
		containment_method,
		containment_location
	)
	containment_events[containment_id] = event
	return event

// Process incident data
/datum/incident_persistence_manager/proc/process_incidents()
	// Update incident records
	update_incident_records()

	// Update breach events
	update_breach_events()

	// Update response logs
	update_response_logs()

	// Update casualty reports
	update_casualty_reports()

	// Update damage assessments
	update_damage_assessments()

	// Calculate global metrics
	calculate_global_metrics()

	// Save data periodically
	if(world.time % 6000 == 0) // Every 10 minutes
		save_incident_data()

// Update incident records
/datum/incident_persistence_manager/proc/update_incident_records()
	for(var/incident_id in incident_records)
		var/datum/incident_record/record = incident_records[incident_id]
		if(record.status == "ACTIVE")
			// Simulate incident progression
			if(prob(5)) // 5% chance to resolve
				record.status = "RESOLVED"
				record.end_time = world.time
				active_incidents--

// Update breach events
/datum/incident_persistence_manager/proc/update_breach_events()
	for(var/breach_id in breach_events)
		var/datum/breach_event/event = breach_events[breach_id]
		if(event.status == "ACTIVE")
			// Calculate breach duration
			event.breach_duration = (world.time - event.breach_start_time) / 600 // Convert to minutes

			// Simulate containment
			if(prob(10)) // 10% chance to contain
				event.status = "CONTAINED"
				event.containment_time = world.time

// Update response logs
/datum/incident_persistence_manager/proc/update_response_logs()
	for(var/response_id in response_logs)
		var/datum/response_log/log = response_logs[response_id]
		if(log.status == "DEPLOYED")
			// Simulate response progression
			if(prob(15)) // 15% chance to complete
				log.status = "COMPLETED"
				log.response_end_time = world.time
				log.response_duration = (world.time - log.response_start_time) / 600 // Convert to minutes

// Update casualty reports
/datum/incident_persistence_manager/proc/update_casualty_reports()
	for(var/casualty_id in casualty_reports)
		var/datum/casualty_report/report = casualty_reports[casualty_id]
		if(report.outcome == "UNKNOWN")
			// Simulate treatment outcomes
			if(prob(20)) // 20% chance to update outcome
				report.outcome = pick("TREATED", "RECOVERED", "DECEASED")
				report.treatment_time = world.time

// Update damage assessments
/datum/incident_persistence_manager/proc/update_damage_assessments()
	for(var/damage_id in damage_assessments)
		var/datum/damage_assessment/assessment = damage_assessments[damage_id]
		if(assessment.repair_status == "PENDING")
			// Simulate repair progress
			if(prob(8)) // 8% chance to start repair
				assessment.repair_status = "IN_PROGRESS"

// Calculate global metrics
/datum/incident_persistence_manager/proc/calculate_global_metrics()
	// Calculate average response time
	var/total_response_time = 0
	var/response_count = 0
	for(var/response_id in response_logs)
		var/datum/response_log/log = response_logs[response_id]
		if(log.response_duration > 0)
			total_response_time += log.response_duration
			response_count++

	if(response_count > 0)
		average_response_time = total_response_time / response_count

	// Calculate total damage cost
	total_damage_cost = 0
	for(var/damage_id in damage_assessments)
		var/datum/damage_assessment/assessment = damage_assessments[damage_id]
		total_damage_cost += assessment.estimated_cost

	// Calculate containment success rate
	var/successful_containments = 0
	var/total_containments = 0
	for(var/containment_id in containment_events)
		var/datum/containment_event/event = containment_events[containment_id]
		total_containments++
		if(event.containment_success)
			successful_containments++

	if(total_containments > 0)
		containment_success_rate = successful_containments / total_containments

// Save incident data
/datum/incident_persistence_manager/proc/save_incident_data()
	// This would save data to persistent storage
	world.log << "Incident: Saving incident data to persistent storage"
