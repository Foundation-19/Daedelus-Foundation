// Medical Persistence System
// Tracks medical records, treatments, outbreaks, research, and health statistics

SUBSYSTEM_DEF(medical_persistence)
	name = "Medical Persistence"
	wait = 600 // 1 minute
	priority = FIRE_PRIORITY_INPUT

	var/datum/medical_persistence_manager/manager

/datum/medical_persistence_manager
	var/list/medical_records = list() // ckey -> medical_record
	var/list/treatment_logs = list() // treatment_id -> treatment_log
	var/list/outbreak_records = list() // outbreak_id -> outbreak_record
	var/list/research_projects = list() // project_id -> medical_research_project
	var/list/disease_tracking = list() // disease_id -> disease_data
	var/list/medical_statistics = list() // stat_name -> value

	// Global medical metrics
	var/total_patients_treated = 0
	var/active_outbreaks = 0
	var/medical_research_progress = 0
	var/containment_effectiveness = 1.0
	var/medical_budget = 1000000
	var/medical_staff_count = 0

/datum/medical_record
	var/ckey
	var/real_name
	var/blood_type = "O+"
	var/dna_hash
	var/list/medical_history = list()
	var/list/allergies = list()
	var/list/current_conditions = list()
	var/list/treatments_received = list()
	var/health_rating = 100
	var/last_updated

/datum/medical_record/New(var/ckey, var/real_name)
		src.ckey = ckey
		src.real_name = real_name
		src.last_updated = world.time

/datum/treatment_log
	var/treatment_id
	var/patient_ckey
	var/treatment_type
	var/treatment_description
	var/doctor_ckey
	var/timestamp
	var/success = TRUE
	var/notes = ""

/datum/treatment_log/New(var/treatment_id, var/patient_ckey, var/treatment_type, var/doctor_ckey)
		src.treatment_id = treatment_id
		src.patient_ckey = patient_ckey
		src.treatment_type = treatment_type
		src.doctor_ckey = doctor_ckey
		src.timestamp = world.time

/datum/outbreak_record
	var/outbreak_id
	var/disease_name
	var/disease_type
	var/severity = 1
	var/affected_count = 0
	var/contained_count = 0
	var/start_time
	var/end_time
	var/status = "ACTIVE" // ACTIVE, CONTAINED, ERADICATED
	var/list/affected_patients = list()
	var/containment_protocols = list()

/datum/outbreak_record/New(var/outbreak_id, var/disease_name, var/disease_type)
		src.outbreak_id = outbreak_id
		src.disease_name = disease_name
		src.disease_type = disease_type
		src.start_time = world.time

/datum/medical_research_project
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
	var/data_samples_collected = 0
	var/lab_hours_invested = 0
	var/equipment_usage_hours = 0
	var/collaboration_count = 0
	var/publication_drafts = 0
	var/peer_reviews_received = 0
	var/research_milestones_completed = 0

/datum/medical_research_project/New(var/project_id, var/project_name, var/project_description, var/research_field, var/lead_researcher)
		src.project_id = project_id
		src.project_name = project_name
		src.project_description = project_description
		src.research_field = research_field
		src.lead_researcher = lead_researcher
		src.start_date = world.time

/datum/disease_data
	var/disease_id
	var/disease_name
	var/disease_type
	var/contagiousness = 1.0
	var/severity = 1.0
	var/mortality_rate = 0.0
	var/incubation_period = 0
	var/treatment_effectiveness = 1.0
	var/list/known_symptoms = list()
	var/list/known_treatments = list()
	var/outbreak_count = 0
	var/total_cases = 0
	var/total_deaths = 0

/datum/disease_data/New(var/disease_id, var/disease_name, var/disease_type)
		src.disease_id = disease_id
		src.disease_name = disease_name
		src.disease_type = disease_type

// Medical Persistence Manager Methods
/datum/medical_persistence_manager/proc/process_medical()
	// Update medical statistics
	update_medical_statistics()

	// Process active outbreaks
	process_outbreaks()

	// Update research progress
	update_research_progress()

	// Save data periodically
	if(world.time % 3000 == 0) // Every 5 minutes
		save_medical_data()

/datum/medical_persistence_manager/proc/add_medical_record(var/ckey, var/real_name)
	if(!(ckey in medical_records))
		medical_records[ckey] = new /datum/medical_record(ckey, real_name)

		// Sync with existing medical records system
		sync_with_medical_records(ckey, real_name)
		return medical_records[ckey]
	return medical_records[ckey]

/datum/medical_persistence_manager/proc/add_treatment(var/patient_ckey, var/treatment_type, var/doctor_ckey, var/description = "", var/success = TRUE, var/notes = "")
	var/treatment_id = "treatment_[world.time]_[patient_ckey]"
	var/datum/treatment_log/treatment = new /datum/treatment_log(treatment_id, patient_ckey, treatment_type, doctor_ckey)
	treatment.treatment_description = description
	treatment.success = success
	treatment.notes = notes

	treatment_logs[treatment_id] = treatment

	// Add to patient's medical record
	var/datum/medical_record/record = medical_records[patient_ckey]
	if(record)
		record.treatments_received += treatment
		record.last_updated = world.time

	total_patients_treated++
	return treatment

/datum/medical_persistence_manager/proc/add_outbreak(var/disease_name, var/disease_type, var/severity = 1)
	var/outbreak_id = "outbreak_[world.time]"
	var/datum/outbreak_record/outbreak = new /datum/outbreak_record(outbreak_id, disease_name, disease_type)
	outbreak.severity = severity

	outbreak_records[outbreak_id] = outbreak
	active_outbreaks++
	return outbreak

/datum/medical_persistence_manager/proc/add_research_project(var/project_name, var/project_description, var/research_field, var/lead_researcher, var/budget = 0)
	var/project_id = "research_[world.time]"
	var/datum/medical_research_project/project = new /datum/medical_research_project(project_id, project_name, project_description, research_field, lead_researcher)
	project.budget_allocated = budget

	research_projects[project_id] = project
	return project

/datum/medical_persistence_manager/proc/update_medical_statistics()
	medical_statistics["total_patients"] = length(medical_records)
	medical_statistics["total_treatments"] = length(treatment_logs)
	medical_statistics["active_outbreaks"] = active_outbreaks
	medical_statistics["research_projects"] = length(research_projects)
	medical_statistics["medical_budget"] = medical_budget
	medical_statistics["containment_effectiveness"] = containment_effectiveness

/datum/medical_persistence_manager/proc/process_outbreaks()
	for(var/outbreak_id in outbreak_records)
		var/datum/outbreak_record/outbreak = outbreak_records[outbreak_id]
		if(outbreak.status == "ACTIVE")
			// Simulate outbreak progression
			if(prob(10)) // 10% chance to spread
				outbreak.affected_count++

			// Check for containment
			if(outbreak.contained_count >= outbreak.affected_count * 0.8)
				outbreak.status = "CONTAINED"
				active_outbreaks--

/datum/medical_persistence_manager/proc/update_research_progress()
	for(var/project_id in research_projects)
		var/datum/medical_research_project/project = research_projects[project_id]
		if(project.status == "ACTIVE")
			// Calculate real research progress based on actual game data
			project.progress = calculate_real_medical_research_progress(project)

			// Check for completion
			if(project.progress >= 100)
				project.status = "COMPLETED"
				medical_research_progress += 10

// Calculate real medical research progress based on actual game data
/datum/medical_persistence_manager/proc/calculate_real_medical_research_progress(var/datum/medical_research_project/project)
	var/base_progress = project.progress

	// Progress based on number of researchers
	if(length(project.researchers) > 0)
		base_progress += length(project.researchers) * 2

	// Progress based on budget utilization
	if(project.budget_allocated > 0)
		var/budget_utilization = (project.budget_used / project.budget_allocated) * 100
		base_progress += budget_utilization * 0.5

	// Progress based on experiments conducted
	base_progress += project.experiments_conducted * 3

	// Progress based on data samples collected
	base_progress += project.data_samples_collected * 1.5

	// Progress based on lab hours invested
	base_progress += project.lab_hours_invested * 0.1

	// Progress based on equipment usage
	base_progress += project.equipment_usage_hours * 0.2

	// Progress based on collaborations
	base_progress += project.collaboration_count * 2

	// Progress based on research milestones
	base_progress += project.research_milestones_completed * 5

	// Progress based on time elapsed
	var/time_elapsed = world.time - project.start_date
	var/time_factor = min(20, time_elapsed / 6000) // Max 20% from time, 6000 ticks = 10 minutes
	base_progress += time_factor

	return min(100, base_progress)

/datum/medical_persistence_manager/proc/save_medical_data()
	var/list/data = list()

	// Save medical records
	data["medical_records"] = list()
	for(var/ckey in medical_records)
		var/datum/medical_record/record = medical_records[ckey]
		data["medical_records"][ckey] = list(
			"real_name" = record.real_name,
			"blood_type" = record.blood_type,
			"dna_hash" = record.dna_hash,
			"medical_history" = record.medical_history,
			"allergies" = record.allergies,
			"current_conditions" = record.current_conditions,
			"health_rating" = record.health_rating,
			"last_updated" = record.last_updated
		)

	// Save treatment logs
	data["treatment_logs"] = list()
	for(var/treatment_id in treatment_logs)
		var/datum/treatment_log/treatment = treatment_logs[treatment_id]
		data["treatment_logs"][treatment_id] = list(
			"patient_ckey" = treatment.patient_ckey,
			"treatment_type" = treatment.treatment_type,
			"treatment_description" = treatment.treatment_description,
			"doctor_ckey" = treatment.doctor_ckey,
			"timestamp" = treatment.timestamp,
			"success" = treatment.success,
			"notes" = treatment.notes
		)

	// Save outbreak records
	data["outbreak_records"] = list()
	for(var/outbreak_id in outbreak_records)
		var/datum/outbreak_record/outbreak = outbreak_records[outbreak_id]
		data["outbreak_records"][outbreak_id] = list(
			"disease_name" = outbreak.disease_name,
			"disease_type" = outbreak.disease_type,
			"severity" = outbreak.severity,
			"affected_count" = outbreak.affected_count,
			"contained_count" = outbreak.contained_count,
			"start_time" = outbreak.start_time,
			"end_time" = outbreak.end_time,
			"status" = outbreak.status,
			"affected_patients" = outbreak.affected_patients,
			"containment_protocols" = outbreak.containment_protocols
		)

	// Save research projects
	data["research_projects"] = list()
	for(var/project_id in research_projects)
		var/datum/medical_research_project/project = research_projects[project_id]
		data["research_projects"][project_id] = list(
			"project_name" = project.project_name,
			"project_description" = project.project_description,
			"research_field" = project.research_field,
			"progress" = project.progress,
			"budget_allocated" = project.budget_allocated,
			"budget_used" = project.budget_used,
			"lead_researcher" = project.lead_researcher,
			"researchers" = project.researchers,
			"start_date" = project.start_date,
			"estimated_completion" = project.estimated_completion,
			"status" = project.status,
			"discoveries" = project.discoveries,
			"publications" = project.publications
		)

	// Save global statistics
	data["global_stats"] = list(
		"total_patients_treated" = total_patients_treated,
		"active_outbreaks" = active_outbreaks,
		"medical_research_progress" = medical_research_progress,
		"containment_effectiveness" = containment_effectiveness,
		"medical_budget" = medical_budget,
		"medical_staff_count" = medical_staff_count
	)

	// Write to JSON file
	var/json_data = json_encode(data)
	var/savefile/S = new /savefile("data/medical_persistence.json")
	S["data"] << json_data

	// Save to database
	save_medical_data_to_database()

/datum/medical_persistence_manager/proc/save_medical_data_to_database()
	if(!SSdbcore.Connect())
		log_game("Medical Persistence: Database connection failed, skipping database save")
		return

	// Save medical records to database
	for(var/ckey in medical_records)
		var/datum/medical_record/record = medical_records[ckey]
		var/datum/db_query/query_save_record = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("medical_records")]
			(ckey, real_name, blood_type, dna_hash, medical_history, allergies, current_conditions, health_rating, last_updated)
			VALUES (:ckey, :real_name, :blood_type, :dna_hash, :medical_history, :allergies, :current_conditions, :health_rating, :last_updated)
			ON DUPLICATE KEY UPDATE
			real_name = VALUES(real_name), blood_type = VALUES(blood_type), dna_hash = VALUES(dna_hash),
			medical_history = VALUES(medical_history), allergies = VALUES(allergies), current_conditions = VALUES(current_conditions),
			health_rating = VALUES(health_rating), last_updated = VALUES(last_updated)
		"}, list(
			"ckey" = ckey,
			"real_name" = record.real_name,
			"blood_type" = record.blood_type,
			"dna_hash" = record.dna_hash,
			"medical_history" = json_encode(record.medical_history),
			"allergies" = json_encode(record.allergies),
			"current_conditions" = json_encode(record.current_conditions),
			"health_rating" = record.health_rating,
			"last_updated" = record.last_updated
		))

		if(!query_save_record.warn_execute())
			log_game("Medical Persistence: Failed to save medical record for [ckey]")
		qdel(query_save_record)

	// Save treatment logs to database
	for(var/treatment_id in treatment_logs)
		var/datum/treatment_log/treatment = treatment_logs[treatment_id]
		var/datum/db_query/query_save_treatment = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("medical_treatment_logs")]
			(treatment_id, patient_ckey, treatment_type, treatment_description, doctor_ckey, timestamp, success, notes)
			VALUES (:treatment_id, :patient_ckey, :treatment_type, :treatment_description, :doctor_ckey, :timestamp, :success, :notes)
			ON DUPLICATE KEY UPDATE
			patient_ckey = VALUES(patient_ckey), treatment_type = VALUES(treatment_type), treatment_description = VALUES(treatment_description),
			doctor_ckey = VALUES(doctor_ckey), timestamp = VALUES(timestamp), success = VALUES(success), notes = VALUES(notes)
		"}, list(
			"treatment_id" = treatment_id,
			"patient_ckey" = treatment.patient_ckey,
			"treatment_type" = treatment.treatment_type,
			"treatment_description" = treatment.treatment_description,
			"doctor_ckey" = treatment.doctor_ckey,
			"timestamp" = treatment.timestamp,
			"success" = treatment.success,
			"notes" = treatment.notes
		))

		if(!query_save_treatment.warn_execute())
			log_game("Medical Persistence: Failed to save treatment log [treatment_id]")
		qdel(query_save_treatment)

	// Save outbreak records to database
	for(var/outbreak_id in outbreak_records)
		var/datum/outbreak_record/outbreak = outbreak_records[outbreak_id]
		var/datum/db_query/query_save_outbreak = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("medical_outbreak_records")]
			(outbreak_id, disease_name, disease_type, severity, affected_count, contained_count, start_time, end_time, status, affected_patients, containment_protocols)
			VALUES (:outbreak_id, :disease_name, :disease_type, :severity, :affected_count, :contained_count, :start_time, :end_time, :status, :affected_patients, :containment_protocols)
			ON DUPLICATE KEY UPDATE
			disease_name = VALUES(disease_name), disease_type = VALUES(disease_type), severity = VALUES(severity),
			affected_count = VALUES(affected_count), contained_count = VALUES(contained_count), start_time = VALUES(start_time),
			end_time = VALUES(end_time), status = VALUES(status), affected_patients = VALUES(affected_patients), containment_protocols = VALUES(containment_protocols)
		"}, list(
					"outbreak_id" = outbreak_id,
		"disease_name" = outbreak.disease_name,
		"disease_type" = outbreak.disease_type,
		"severity" = outbreak.severity,
		"affected_count" = outbreak.affected_count,
		"contained_count" = outbreak.contained_count,
		"start_time" = outbreak.start_time,
		"end_time" = outbreak.end_time,
		"status" = outbreak.status,
			"affected_patients" = json_encode(outbreak.affected_patients),
			"containment_protocols" = json_encode(outbreak.containment_protocols)
		))

		if(!query_save_outbreak.warn_execute())
			log_game("Medical Persistence: Failed to save outbreak record [outbreak_id]")
		qdel(query_save_outbreak)

	// Save research projects to database
	for(var/project_id in research_projects)
		var/datum/medical_research_project/project = research_projects[project_id]
		var/datum/db_query/query_save_project = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("medical_research_projects")]
			(project_id, project_name, project_description, research_field, progress, budget_allocated, budget_used, lead_researcher, researchers, start_date, estimated_completion, status, discoveries, publications)
			VALUES (:project_id, :project_name, :project_description, :research_field, :progress, :budget_allocated, :budget_used, :lead_researcher, :researchers, :start_date, :estimated_completion, :status, :discoveries, :publications)
			ON DUPLICATE KEY UPDATE
			project_name = VALUES(project_name), project_description = VALUES(project_description), research_field = VALUES(research_field),
			progress = VALUES(progress), budget_allocated = VALUES(budget_allocated), budget_used = VALUES(budget_used),
			lead_researcher = VALUES(lead_researcher), researchers = VALUES(researchers), start_date = VALUES(start_date),
			estimated_completion = VALUES(estimated_completion), status = VALUES(status), discoveries = VALUES(discoveries), publications = VALUES(publications)
		"}, list(
			"project_id" = project_id,
			"project_name" = project.project_name,
			"project_description" = project.project_description,
			"research_field" = project.research_field,
			"progress" = project.progress,
			"budget_allocated" = project.budget_allocated,
			"budget_used" = project.budget_used,
			"lead_researcher" = project.lead_researcher,
			"researchers" = json_encode(project.researchers),
			"start_date" = project.start_date,
			"estimated_completion" = project.estimated_completion,
			"status" = project.status,
			"discoveries" = json_encode(project.discoveries),
			"publications" = json_encode(project.publications)
		))

		if(!query_save_project.warn_execute())
			log_game("Medical Persistence: Failed to save research project [project_id]")
		qdel(query_save_project)

	log_game("Medical Persistence: Saved [length(medical_records)] medical records, [length(treatment_logs)] treatment logs, [length(outbreak_records)] outbreak records, and [length(research_projects)] research projects to database")

/datum/medical_persistence_manager/proc/load_medical_data()
	var/savefile/S = new /savefile("data/medical_persistence.json")
	if(!S["data"])
		return

	var/json_data
	S["data"] >> json_data

	var/list/data = json_decode(json_data)
	if(!data)
		return

	// Load medical records
	if(data["medical_records"])
		for(var/ckey in data["medical_records"])
			var/list/record_data = data["medical_records"][ckey]
			var/datum/medical_record/record = new /datum/medical_record(ckey, record_data["real_name"])
			record.blood_type = record_data["blood_type"]
			record.dna_hash = record_data["dna_hash"]
			record.medical_history = record_data["medical_history"]
			record.allergies = record_data["allergies"]
			record.current_conditions = record_data["current_conditions"]
			record.health_rating = record_data["health_rating"]
			record.last_updated = record_data["last_updated"]
			medical_records[ckey] = record

	// Load treatment logs
	if(data["treatment_logs"])
		for(var/treatment_id in data["treatment_logs"])
			var/list/treatment_data = data["treatment_logs"][treatment_id]
			var/datum/treatment_log/treatment = new /datum/treatment_log(treatment_id, treatment_data["patient_ckey"], treatment_data["treatment_type"], treatment_data["doctor_ckey"])
			treatment.treatment_description = treatment_data["treatment_description"]
			treatment.timestamp = treatment_data["timestamp"]
			treatment.success = treatment_data["success"]
			treatment.notes = treatment_data["notes"]
			treatment_logs[treatment_id] = treatment

	// Load outbreak records
	if(data["outbreak_records"])
		for(var/outbreak_id in data["outbreak_records"])
			var/list/outbreak_data = data["outbreak_records"][outbreak_id]
			var/datum/outbreak_record/outbreak = new /datum/outbreak_record(outbreak_id, outbreak_data["disease_name"], outbreak_data["disease_type"])
			outbreak.severity = outbreak_data["severity"]
			outbreak.affected_count = outbreak_data["affected_count"]
			outbreak.contained_count = outbreak_data["contained_count"]
			outbreak.start_time = outbreak_data["start_time"]
			outbreak.end_time = outbreak_data["end_time"]
			outbreak.status = outbreak_data["status"]
			outbreak.affected_patients = outbreak_data["affected_patients"]
			outbreak.containment_protocols = outbreak_data["containment_protocols"]
			outbreak_records[outbreak_id] = outbreak
			if(outbreak.status == "ACTIVE")
				active_outbreaks++

	// Load research projects
	if(data["research_projects"])
		for(var/project_id in data["research_projects"])
			var/list/project_data = data["research_projects"][project_id]
			var/datum/medical_research_project/project = new /datum/medical_research_project(project_id, project_data["project_name"], project_data["project_description"], project_data["research_field"], project_data["lead_researcher"])
			project.progress = project_data["progress"]
			project.budget_allocated = project_data["budget_allocated"]
			project.budget_used = project_data["budget_used"]
			project.researchers = project_data["researchers"]
			project.start_date = project_data["start_date"]
			project.estimated_completion = project_data["estimated_completion"]
			project.status = project_data["status"]
			project.discoveries = project_data["discoveries"]
			project.publications = project_data["publications"]
			research_projects[project_id] = project

	// Load global statistics
	if(data["global_stats"])
		var/list/stats = data["global_stats"]
		total_patients_treated = stats["total_patients_treated"]
		medical_research_progress = stats["medical_research_progress"]
		containment_effectiveness = stats["containment_effectiveness"]
		medical_budget = stats["medical_budget"]
		medical_staff_count = stats["medical_staff_count"]

// Subsystem initialization
/datum/controller/subsystem/medical_persistence/Initialize()
	log_game("Medical persistence subsystem initializing...")
	manager = new /datum/medical_persistence_manager()
	log_game("Medical persistence manager created")

	// Load existing medical records from datacore
	log_game("Loading existing medical records from datacore...")
	manager.load_existing_medical_records()

	log_game("Medical records count at initialization: [length(manager.medical_records)]")
	return ..()

/datum/controller/subsystem/medical_persistence/fire()
	if(manager)
		manager.process_medical()

// Sync with existing medical records system
/datum/medical_persistence_manager/proc/sync_with_medical_records(var/ckey, var/real_name)
	// Check if medical record already exists in datacore
	var/datum/data/record/medical/existing_record = SSdatacore.find_record("name", real_name, DATACORE_RECORDS_MEDICAL)
	if(!existing_record)
		// Create new medical record in datacore if it doesn't exist
		var/datum/data/record/medical/new_record = new /datum/data/record/medical()
		new_record.fields[DATACORE_NAME] = real_name
		new_record.fields[DATACORE_BLOOD_TYPE] = "O+"
		new_record.fields[DATACORE_DISABILITIES] = "None"
		new_record.fields[DATACORE_DISEASES] = "None"
		new_record.fields[DATACORE_NOTES] = "No medical notes."

		// Add to datacore
		SSdatacore.library[DATACORE_RECORDS_MEDICAL].inject_record(new_record)
	else
		// Update existing record if needed
		existing_record.fields[DATACORE_BLOOD_TYPE] = "O+"
		existing_record.fields[DATACORE_DISABILITIES] = "None"
		existing_record.fields[DATACORE_DISEASES] = "None"

// Load all existing medical records from SSdatacore
/datum/medical_persistence_manager/proc/load_existing_medical_records()
	if(!SSdatacore)
		return

	log_game("Medical: Loading existing medical records from datacore...")

	// Load from general records (station records)
	for(var/datum/data/record/general_record in SSdatacore.get_records(DATACORE_RECORDS_STATION))
		if(general_record.fields[DATACORE_NAME])
			var/ckey = ckey(general_record.fields[DATACORE_NAME])
			if(!(ckey in medical_records))
				var/datum/medical_record/medical_record = new /datum/medical_record(ckey, general_record.fields[DATACORE_NAME])

				// Set health rating based on physical and mental status
				var/health_rating = 100
				if(general_record.fields[DATACORE_PHYSICAL_HEALTH] == "*Deceased*")
					health_rating = 0
				else if(general_record.fields[DATACORE_PHYSICAL_HEALTH] == "*Unconscious*")
					health_rating = 25
				else if(general_record.fields[DATACORE_PHYSICAL_HEALTH] == "Physically Unfit")
					health_rating = 50
				else if(general_record.fields[DATACORE_PHYSICAL_HEALTH] == "Active")
					health_rating = 100

				if(general_record.fields[DATACORE_MENTAL_HEALTH] == "*Insane*")
					health_rating = max(0, health_rating - 50)
				else if(general_record.fields[DATACORE_MENTAL_HEALTH] == "*Unstable*")
					health_rating = max(0, health_rating - 25)
				else if(general_record.fields[DATACORE_MENTAL_HEALTH] == "*Watch*")
					health_rating = max(0, health_rating - 10)

				medical_record.health_rating = health_rating
				medical_record.last_updated = world.time
				medical_records[ckey] = medical_record

				log_game("Medical: Loaded general record for [general_record.fields[DATACORE_NAME]] (Health: [health_rating])")

	// Load from medical records (detailed medical data)
	for(var/datum/data/record/medical_record in SSdatacore.get_records(DATACORE_RECORDS_MEDICAL))
		if(medical_record.fields[DATACORE_NAME])
			var/ckey = ckey(medical_record.fields[DATACORE_NAME])
			var/datum/medical_record/existing_record = medical_records[ckey]

			if(existing_record)
				// Update blood type
				if(medical_record.fields[DATACORE_BLOOD_TYPE])
					existing_record.blood_type = medical_record.fields[DATACORE_BLOOD_TYPE]

				// Load current conditions from diseases field
				if(medical_record.fields[DATACORE_DISEASES] && medical_record.fields[DATACORE_DISEASES] != "None")
					existing_record.current_conditions = splittext(medical_record.fields[DATACORE_DISEASES], ",")

				// Load disabilities
				if(medical_record.fields[DATACORE_DISABILITIES] && medical_record.fields[DATACORE_DISABILITIES] != "None")
					existing_record.medical_history += medical_record.fields[DATACORE_DISABILITIES]

				// Load notes
				if(medical_record.fields[DATACORE_NOTES] && medical_record.fields[DATACORE_NOTES] != "No notes.")
					existing_record.medical_history += medical_record.fields[DATACORE_NOTES]

				existing_record.last_updated = world.time

				log_game("Medical: Updated medical record for [medical_record.fields[DATACORE_NAME]] (Blood: [existing_record.blood_type])")
			else
				// Create new record if general record doesn't exist
				var/datum/medical_record/new_record = new /datum/medical_record(ckey, medical_record.fields[DATACORE_NAME])
				if(medical_record.fields[DATACORE_BLOOD_TYPE])
					new_record.blood_type = medical_record.fields[DATACORE_BLOOD_TYPE]
				medical_records[ckey] = new_record

				log_game("Medical: Created new medical record for [medical_record.fields[DATACORE_NAME]]")

	log_game("Medical: Loaded [length(medical_records)] medical records from datacore")

// Add treatment log
/datum/medical_persistence_manager/proc/add_treatment_log(var/patient_ckey, var/treatment_type, var/doctor_ckey)
	var/treatment_id = "TREAT_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/treatment_log/treatment = new /datum/treatment_log(treatment_id, patient_ckey, treatment_type, doctor_ckey)
	treatment.timestamp = time2text(world.time, "YYYY-MM-DD HH:MM:SS")
	treatment.success = TRUE
	treatment.notes = "Treatment administered successfully."
	treatment_logs[treatment_id] = treatment
	return treatment

// Add outbreak record
/datum/medical_persistence_manager/proc/add_outbreak_record(var/disease_name, var/disease_type, var/severity = 1)
	var/outbreak_id = "OUTBREAK_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/outbreak_record/outbreak = new /datum/outbreak_record(outbreak_id, disease_name, disease_type)
	outbreak.severity = severity
	outbreak.affected_count = 0
	outbreak.contained_count = 0
	outbreak.start_time = time2text(world.time, "YYYY-MM-DD HH:MM:SS")
	outbreak.status = "ACTIVE"
	outbreak.affected_patients = list()
	outbreak.containment_protocols = list("Standard quarantine procedures")
	outbreak_records[outbreak_id] = outbreak
	active_outbreaks++
	return outbreak

// Add medical research project
/datum/medical_persistence_manager/proc/add_medical_research_project(var/project_name, var/project_description, var/research_field, var/lead_researcher)
	var/static/project_counter = 0
	project_counter++
	var/project_id = "MED_RESEARCH_[time2text(world.time, "YYYYMMDD_HHMMSS")]_[project_counter]"
	var/datum/medical_research_project/project = new /datum/medical_research_project(project_id, project_name, project_description, research_field, lead_researcher)
	project.progress = 0
	project.budget_allocated = 100000
	project.budget_used = 0
	project.researchers = list(lead_researcher)
	project.start_date = time2text(world.time, "YYYY-MM-DD")
	project.estimated_completion = "TBD"
	project.status = "ACTIVE"
	project.discoveries = list()
	project.publications = list()
	research_projects[project_id] = project
	return project

// Export patient data
/datum/medical_persistence_manager/proc/export_patient_data()
	var/list/export_data = list()
	export_data["patients"] = list()
	export_data["treatments"] = list()
	export_data["outbreaks"] = list()
	export_data["research"] = list()

	// Export patient records
	for(var/ckey in medical_records)
		var/datum/medical_record/record = medical_records[ckey]
		export_data["patients"][ckey] = list(
			"real_name" = record.real_name,
			"blood_type" = record.blood_type,
			"health_rating" = record.health_rating,
			"current_conditions" = record.current_conditions,
			"last_updated" = record.last_updated
		)

	// Export treatment logs
	for(var/treatment_id in treatment_logs)
		var/datum/treatment_log/treatment = treatment_logs[treatment_id]
		export_data["treatments"][treatment_id] = list(
			"patient_ckey" = treatment.patient_ckey,
			"treatment_type" = treatment.treatment_type,
			"doctor_ckey" = treatment.doctor_ckey,
			"timestamp" = treatment.timestamp,
			"success" = treatment.success,
			"notes" = treatment.notes
		)

	// Export outbreak records
	for(var/outbreak_id in outbreak_records)
		var/datum/outbreak_record/outbreak = outbreak_records[outbreak_id]
		export_data["outbreaks"][outbreak_id] = list(
			"disease_name" = outbreak.disease_name,
			"disease_type" = outbreak.disease_type,
			"severity" = outbreak.severity,
			"status" = outbreak.status,
			"start_time" = outbreak.start_time
		)

	// Export research projects
	for(var/project_id in research_projects)
		var/datum/medical_research_project/project = research_projects[project_id]
		export_data["research"][project_id] = list(
			"project_name" = project.project_name,
			"project_description" = project.project_description,
			"research_field" = project.research_field,
			"lead_researcher" = project.lead_researcher,
			"status" = project.status
		)

	return json_encode(export_data)

// Import patient data
/datum/medical_persistence_manager/proc/import_patient_data(var/import_file)
	try
		var/file_content = file2text(import_file)
		var/list/import_data = json_decode(file_content)

		if(!import_data || !import_data["patients"])
			return FALSE

		// Import patient records
		for(var/ckey in import_data["patients"])
			var/list/patient_data = import_data["patients"][ckey]
			var/datum/medical_record/record = new /datum/medical_record(ckey, patient_data["real_name"])
			record.blood_type = patient_data["blood_type"] || "O+"
			record.health_rating = patient_data["health_rating"] || 100
			record.current_conditions = patient_data["current_conditions"] || list()
			record.last_updated = patient_data["last_updated"] || world.time
			medical_records[ckey] = record

		return TRUE
	catch(var/exception)
		log_game("Medical persistence import error: [exception]")
		return FALSE

// Get critical patients count
/datum/medical_persistence_manager/proc/get_critical_patients_count()
	var/critical_count = 0
	for(var/ckey in medical_records)
		var/datum/medical_record/record = medical_records[ckey]
		if(record.health_rating < 30)
			critical_count++
	return critical_count

// Clear persistent storage to ensure only real data is used
/datum/medical_persistence_manager/proc/clear_persistent_storage()
	// Clear all existing data
	medical_records.Cut()
	treatment_logs.Cut()
	outbreak_records.Cut()
	research_projects.Cut()
	active_outbreaks = 0

	// Delete the persistent storage file
	var/savefile/S = new /savefile("data/medical_persistence.json")
	if(S)
		S["data"] << null
		log_game("Medical: Cleared persistent storage file")

	log_game("Medical: Cleared all persistent storage data")




