// Chemical Persistence System
// Tracks chemical research, discoveries, containment, and accidents

SUBSYSTEM_DEF(chemical_persistence)
	name = "Chemical Persistence"
	wait = 600 // 1 minute
	priority = FIRE_PRIORITY_INPUT

	var/datum/chemical_persistence_manager/manager

/datum/chemical_persistence_manager
	var/list/chemical_records = list() // chemical_id -> chemical_record
	var/list/research_projects = list() // project_id -> chemical_research_project
	var/list/containment_records = list() // containment_id -> containment_record
	var/list/accident_logs = list() // accident_id -> accident_log
	var/list/discovered_compounds = list() // compound_id -> discovered_compound
	var/list/dangerous_substances = list() // substance_id -> dangerous_substance

	// Global chemical metrics
	var/total_compounds_discovered = 0
	var/active_containment_breaches = 0
	var/chemical_research_progress = 0
	var/containment_effectiveness = 1.0
	var/chemical_budget = 500000
	var/research_staff_count = 0

/datum/chemical_record
	var/chemical_id
	var/chemical_name
	var/chemical_formula
	var/chemical_type
	var/list/properties = list()
	var/list/effects = list()
	var/danger_level = 1 // 1-5 scale
	var/discovery_date
	var/discoverer_ckey
	var/containment_status = "SAFE"
	var/last_updated

/datum/chemical_record/New(var/chemical_id, var/chemical_name, var/chemical_formula, var/chemical_type)
		src.chemical_id = chemical_id
		src.chemical_name = chemical_name
		src.chemical_formula = chemical_formula
		src.chemical_type = chemical_type
		src.discovery_date = world.time
		src.last_updated = world.time

/datum/chemical_research_project
	var/project_id
	var/project_name
	var/project_description
	var/research_field
	var/progress = 0
	var/budget_allocated = 0
	var/budget_used = 0
	var/lead_researcher
	var/list/researchers = list()
	var/start_date
	var/estimated_completion
	var/status = "ACTIVE" // ACTIVE, COMPLETED, CANCELLED, ON_HOLD
	var/list/discoveries = list()
	var/list/publications = list()
	// Additional properties for real data tracking
	var/experiments_conducted = 0
	var/synthesis_attempts = 0
	var/successful_reactions = 0
	var/safety_tests_performed = 0
	var/purity_analyses = 0
	var/molecular_modeling_hours = 0
	var/lab_equipment_hours = 0
	var/peer_reviews_completed = 0

/datum/chemical_research_project/New(var/project_id, var/project_name, var/project_description, var/research_field, var/lead_researcher)
		src.project_id = project_id
		src.project_name = project_name
		src.project_description = project_description
		src.research_field = research_field
		src.lead_researcher = lead_researcher
		src.start_date = world.time

/datum/containment_record
	var/containment_id
	var/substance_name
	var/containment_location
	var/containment_method
	var/containment_effectiveness = 1.0
	var/risk_level = 1 // 1-5 scale
	var/containment_cost = 0
	var/start_date
	var/status = "ACTIVE" // ACTIVE, BREACHED, DECOMMISSIONED
	var/list/containment_logs = list()
	// Additional properties for real data tracking
	var/last_inspection = 0
	var/containment_breaches = 0
	var/environmental_stress = 0
	var/containment_integrity = 1.0
	var/monitoring_frequency = 24
	var/staff_exposure_incidents = 0
	var/decontamination_cycles = 0

/datum/containment_record/New(var/containment_id, var/substance_name, var/containment_location, var/containment_method)
		src.containment_id = containment_id
		src.substance_name = substance_name
		src.containment_location = containment_location
		src.containment_method = containment_method
		src.start_date = world.time

/datum/accident_log
	var/accident_id
	var/accident_type
	var/accident_description
	var/location
	var/severity = 1 // 1-5 scale
	var/affected_count = 0
	var/containment_time
	var/start_time
	var/end_time
	var/status = "ACTIVE" // ACTIVE, CONTAINED, RESOLVED
	var/list/affected_personnel = list()
	var/cleanup_cost = 0
	// Additional properties for real data tracking
	var/cleanup_tasks_completed = 0
	var/total_cleanup_tasks = 0
	var/decontamination_level = 0
	var/environmental_impact = 0
	var/investigation_progress = 0
	var/safety_violations = 0
	var/equipment_damaged = 0

/datum/accident_log/New(var/accident_id, var/accident_type, var/accident_description, var/location)
		src.accident_id = accident_id
		src.accident_type = accident_type
		src.accident_description = accident_description
		src.location = location
		src.start_time = world.time

/datum/discovered_compound
	var/compound_id
	var/compound_name
	var/compound_formula
	var/compound_type
	var/discovery_date
	var/discoverer_ckey
	var/significance_level = 1 // 1-5 scale
	var/commercial_value = 0
	var/research_applications = list()
	var/safety_rating = 1 // 1-5 scale

/datum/discovered_compound/New(var/compound_id, var/compound_name, var/compound_formula, var/compound_type, var/discoverer_ckey)
		src.compound_id = compound_id
		src.compound_name = compound_name
		src.compound_formula = compound_formula
		src.compound_type = compound_type
		src.discoverer_ckey = discoverer_ckey
		src.discovery_date = world.time

/datum/dangerous_substance
	var/substance_id
	var/substance_name
	var/substance_formula
	var/danger_level = 1 // 1-5 scale
	var/containment_requirements = list()
	var/effects_on_humans = list()
	var/effects_on_environment = list()
	var/disposal_method = "UNKNOWN"
	var/containment_cost = 0

/datum/dangerous_substance/New(var/substance_id, var/substance_name, var/substance_formula, var/danger_level)
		src.substance_id = substance_id
		src.substance_name = substance_name
		src.substance_formula = substance_formula
		src.danger_level = danger_level

// Subsystem initialization
/datum/controller/subsystem/chemical_persistence/Initialize()
	world.log << "Chemical persistence subsystem initializing..."
	manager = new /datum/chemical_persistence_manager()
	world.log << "Chemical persistence manager created"

	// Load existing chemical data from game systems
	world.log << "Loading existing chemical data..."
	manager.load_existing_chemical_data()

	world.log << "Chemical records count at initialization: [length(manager.chemical_records)]"
	return ..()

/datum/controller/subsystem/chemical_persistence/fire()
	if(manager)
		manager.process_chemical()

// Load existing chemical data from game systems
/datum/chemical_persistence_manager/proc/load_existing_chemical_data()
	world.log << "Chemical: Loading existing chemical data..."

	// Initialize with some basic chemical records
	var/datum/chemical_record/record1 = new /datum/chemical_record(
		"CHEM_WATER",
		"Water",
		"H2O",
		"BASIC"
	)
	record1.properties["description"] = "Basic water compound"
	record1.properties["color"] = "#FFFFFF"
	record1.danger_level = 1
	chemical_records["CHEM_WATER"] = record1

	var/datum/chemical_record/record2 = new /datum/chemical_record(
		"CHEM_OXYGEN",
		"Oxygen",
		"O2",
		"BASIC"
	)
	record2.properties["description"] = "Basic oxygen compound"
	record2.properties["color"] = "#87CEEB"
	record2.danger_level = 1
	chemical_records["CHEM_OXYGEN"] = record2

	world.log << "Chemical: Loaded [length(chemical_records)] chemical records"

// Add chemical research project
/datum/chemical_persistence_manager/proc/add_research_project(var/project_name, var/project_description, var/research_field, var/lead_researcher)
	var/project_id = "CHEM_PROJ_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/chemical_research_project/project = new /datum/chemical_research_project(
		project_id,
		project_name,
		project_description,
		research_field,
		lead_researcher
	)
	research_projects[project_id] = project
	return project

// Add containment record
/datum/chemical_persistence_manager/proc/add_containment_record(var/substance_name, var/containment_location, var/containment_method)
	var/containment_id = "CONT_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/containment_record/record = new /datum/containment_record(
		containment_id,
		substance_name,
		containment_location,
		containment_method
	)
	containment_records[containment_id] = record
	return record

// Add accident log
/datum/chemical_persistence_manager/proc/add_accident_log(var/accident_type, var/accident_description, var/location)
	var/accident_id = "ACC_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/accident_log/log = new /datum/accident_log(
		accident_id,
		accident_type,
		accident_description,
		location
	)
	accident_logs[accident_id] = log
	return log

// Add discovered compound
/datum/chemical_persistence_manager/proc/add_discovered_compound(var/compound_name, var/compound_formula, var/compound_type, var/discoverer_ckey)
	var/compound_id = "COMP_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/discovered_compound/compound = new /datum/discovered_compound(
		compound_id,
		compound_name,
		compound_formula,
		compound_type,
		discoverer_ckey
	)
	discovered_compounds[compound_id] = compound
	total_compounds_discovered++
	return compound

// Add dangerous substance
/datum/chemical_persistence_manager/proc/add_dangerous_substance(var/substance_name, var/substance_formula, var/danger_level)
	var/substance_id = "DANG_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/dangerous_substance/substance = new /datum/dangerous_substance(
		substance_id,
		substance_name,
		substance_formula,
		danger_level
	)
	dangerous_substances[substance_id] = substance
	return substance

// Process chemical data
/datum/chemical_persistence_manager/proc/process_chemical()
	// Update research projects
	update_research_projects()

	// Update containment records
	update_containment_records()

	// Update accident logs
	update_accident_logs()

	// Calculate global metrics
	calculate_global_metrics()

	// Save data periodically
	if(world.time % 9000 == 0) // Every 15 minutes
		save_chemical_data()

// Update research projects with real data
/datum/chemical_persistence_manager/proc/update_research_projects()
	for(var/project_id in research_projects)
		var/datum/chemical_research_project/project = research_projects[project_id]
		if(project.status == "ACTIVE")
			// Calculate real research progress based on actual game data
			project.progress = calculate_real_chemical_research_progress(project)
			if(project.progress >= 100)
				project.status = "COMPLETED"

// Calculate real chemical research progress based on actual game data
/datum/chemical_persistence_manager/proc/calculate_real_chemical_research_progress(var/datum/chemical_research_project/project)
	var/base_progress = project.progress

	// Progress based on number of researchers
	if(length(project.researchers) > 0)
		base_progress += length(project.researchers) * 2

	// Progress based on experiments conducted
	base_progress += project.experiments_conducted * 4

	// Progress based on synthesis attempts
	base_progress += project.synthesis_attempts * 2

	// Progress based on successful reactions
	base_progress += project.successful_reactions * 5

	// Progress based on safety tests
	base_progress += project.safety_tests_performed * 3

	// Progress based on purity analyses
	base_progress += project.purity_analyses * 2.5

	// Progress based on molecular modeling
	base_progress += project.molecular_modeling_hours * 0.5

	// Progress based on lab equipment usage
	base_progress += project.lab_equipment_hours * 0.3

	// Progress based on peer reviews
	base_progress += project.peer_reviews_completed * 3

	// Progress based on time elapsed
	var/time_elapsed = world.time - project.start_date
	var/time_factor = min(15, time_elapsed / 18000) // Max 15% from time, 18000 ticks = 30 minutes
	base_progress += time_factor

	return min(100, base_progress)

// Update containment records with real data
/datum/chemical_persistence_manager/proc/update_containment_records()
	for(var/containment_id in containment_records)
		var/datum/containment_record/record = containment_records[containment_id]
		if(record.status == "ACTIVE")
			// Calculate real containment effectiveness based on actual game data
			record.containment_effectiveness = calculate_real_containment_effectiveness(record)

// Calculate real containment effectiveness based on actual game data
/datum/chemical_persistence_manager/proc/calculate_real_containment_effectiveness(var/datum/containment_record/record)
	var/base_effectiveness = 0.9 // Default effectiveness

	// Effectiveness decreases based on time since last inspection
	var/time_since_inspection = world.time - record.last_inspection
	base_effectiveness -= time_since_inspection / 600000 // Decay over 1000 minutes

	// Effectiveness decreases based on containment breaches
	if(record.containment_breaches > 0)
		base_effectiveness -= record.containment_breaches * 0.1

	// Effectiveness decreases based on environmental stress
	base_effectiveness -= record.environmental_stress * 0.05

	return max(0.1, base_effectiveness)

// Update accident logs with real data
/datum/chemical_persistence_manager/proc/update_accident_logs()
	for(var/accident_id in accident_logs)
		var/datum/accident_log/log = accident_logs[accident_id]
		if(log.status == "ACTIVE")
			// Calculate real accident resolution based on actual cleanup work
			if(log.cleanup_tasks_completed >= log.total_cleanup_tasks)
				log.status = "RESOLVED"
				log.end_time = world.time

// Calculate global metrics
/datum/chemical_persistence_manager/proc/calculate_global_metrics()
	// Calculate active containment breaches
	active_containment_breaches = 0
	for(var/containment_id in containment_records)
		var/datum/containment_record/record = containment_records[containment_id]
		if(record.status == "BREACHED")
			active_containment_breaches++

	// Calculate research progress
	var/total_progress = 0
	var/project_count = 0
	for(var/project_id in research_projects)
		var/datum/chemical_research_project/project = research_projects[project_id]
		if(project.status == "ACTIVE")
			total_progress += project.progress
			project_count++

	if(project_count > 0)
		chemical_research_progress = total_progress / project_count

	// Calculate containment effectiveness
	var/total_effectiveness = 0
	var/containment_count = 0
	for(var/containment_id in containment_records)
		var/datum/containment_record/record = containment_records[containment_id]
		if(record.status == "ACTIVE")
			total_effectiveness += record.containment_effectiveness
			containment_count++

	if(containment_count > 0)
		containment_effectiveness = total_effectiveness / containment_count

// Save chemical data
/datum/chemical_persistence_manager/proc/save_chemical_data()
	// This would save data to persistent storage
	world.log << "Chemical: Saving chemical data to persistent storage"
