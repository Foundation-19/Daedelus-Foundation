// Research Persistence System
// Tracks research projects, discoveries, publications, and scientific progress

SUBSYSTEM_DEF(research_persistence)
	name = "Research Persistence"
	wait = 600 // 1 minute
	priority = FIRE_PRIORITY_INPUT

	var/datum/research_persistence_manager/manager

/datum/research_persistence_manager
	var/list/research_projects = list() // project_id -> research_project
	var/list/scientific_discoveries = list() // discovery_id -> scientific_discovery
	var/list/publications = list() // publication_id -> publication
	var/list/research_facilities = list() // facility_id -> research_facility
	var/list/research_grants = list() // grant_id -> research_grant
	var/list/research_statistics = list() // stat_name -> value

	// Global research metrics
	var/total_research_projects = 0
	var/completed_projects = 0
	var/research_budget = 5000000
	var/research_efficiency = 1.0
	var/scientific_breakthroughs = 0
	var/publication_count = 0
	var/research_staff_count = 0

/datum/research_persistence_project
	var/project_id
	var/project_name
	var/project_description
	var/research_field
	var/lead_researcher
	var/list/researchers = list()
	var/progress = 0
	var/budget_allocated = 0
	var/budget_used = 0
	var/start_date
	var/estimated_completion
	var/actual_completion
	var/status = "ACTIVE" // ACTIVE, COMPLETED, CANCELLED, ON_HOLD
	var/priority = 1
	var/list/discoveries = list()
	var/list/publications = list()
	var/list/research_notes = list()
	// Additional properties for real data tracking
	var/experiments_completed = 0
	var/data_analysis_sessions = 0
	var/peer_consultations = 0
	var/hypothesis_tests_run = 0
	var/prototype_iterations = 0
	var/field_tests_conducted = 0
	var/documentation_pages = 0
	var/conference_presentations = 0
	var/patent_applications = 0
	var/research_equipment_used = 0

/datum/research_persistence_project/New(var/project_id, var/project_name, var/project_description, var/research_field, var/lead_researcher)
		src.project_id = project_id
		src.project_name = project_name
		src.project_description = project_description
		src.research_field = research_field
		src.lead_researcher = lead_researcher
		src.start_date = world.time

/datum/research_scientific_discovery
	var/discovery_id
	var/discovery_name
	var/discovery_description
	var/discovery_type
	var/research_field
	var/discoverer_ckey
	var/discovery_date
	var/significance_level = 1
	var/list/related_projects = list()
	var/list/applications = list()
	var/patent_status = "NONE" // NONE, PENDING, GRANTED, REJECTED
	var/commercial_value = 0

/datum/research_scientific_discovery/New(var/discovery_id, var/discovery_name, var/discovery_description, var/discovery_type, var/research_field, var/discoverer_ckey)
		src.discovery_id = discovery_id
		src.discovery_name = discovery_name
		src.discovery_description = discovery_description
		src.discovery_type = discovery_type
		src.research_field = research_field
		src.discoverer_ckey = discoverer_ckey
		src.discovery_date = world.time

/datum/publication
	var/publication_id
	var/publication_title
	var/publication_abstract
	var/authors = list()
	var/journal_name
	var/publication_date
	var/impact_factor = 1.0
	var/citation_count = 0
	var/peer_review_status = "PENDING" // PENDING, APPROVED, REJECTED, PUBLISHED
	var/doi_number = ""

/datum/publication/New(var/publication_id, var/publication_title, var/publication_abstract, var/authors, var/journal_name)
		src.publication_id = publication_id
		src.publication_title = publication_title
		src.publication_abstract = publication_abstract
		src.authors = authors
		src.journal_name = journal_name
		src.publication_date = world.time

/datum/research_persistence_facility
	var/facility_id
	var/facility_name
	var/facility_type
	var/location
	var/capacity = 100
	var/current_occupancy = 0
	var/equipment_quality = 1.0
	var/maintenance_level = 100
	var/list/active_projects = list()
	var/list/equipment = list()
	var/security_level = 1
	// Additional properties for real data tracking
	var/last_maintenance = 0
	var/usage_hours = 0
	var/safety_incidents = 0
	var/equipment_failures = 0
	var/research_output_rating = 1.0
	var/energy_consumption = 0
	var/operational_cost = 0
	var/staff_assigned = 0

/datum/research_persistence_facility/New(var/facility_id, var/facility_name, var/facility_type, var/location)
		src.facility_id = facility_id
		src.facility_name = facility_name
		src.facility_type = facility_type
		src.location = location

/datum/research_grant
	var/grant_id
	var/grant_name
	var/granting_organization
	var/amount = 0
	var/research_field
	var/recipient_ckey
	var/grant_date
	var/expiration_date
	var/status = "ACTIVE" // ACTIVE, EXPIRED, CANCELLED, COMPLETED
	var/requirements = list()
	var/progress_reports = list()

/datum/research_grant/New(var/grant_id, var/grant_name, var/granting_organization, var/amount, var/research_field, var/recipient_ckey)
		src.grant_id = grant_id
		src.grant_name = grant_name
		src.granting_organization = granting_organization
		src.amount = amount
		src.research_field = research_field
		src.recipient_ckey = recipient_ckey
		src.grant_date = world.time

// Research Persistence Manager Methods
/datum/research_persistence_manager/proc/process_research()
	sync_from_scp_research()
	update_research_statistics()
	process_projects()
	update_facilities()
	process_grants()

	if(world.time % 3000 == 0)
		save_research_data()
		if(SSscp_research?.manager)
			SSscp_research.manager.save_research_persistence()

/datum/research_persistence_manager/proc/sync_from_scp_research()
	if(!SSscp_research || !SSscp_research.manager)
		return
	var/datum/scp_research_manager/M = SSscp_research.manager
	for(var/project_id in M.research_projects)
		var/datum/research_data/scp_project = M.research_projects[project_id]
		if(!research_projects[project_id])
			var/datum/research_persistence_project/p = new /datum/research_persistence_project(project_id, "SCP-[scp_project.scp_designation] Research", "Research on SCP-[scp_project.scp_designation] - [scp_project.research_type]", scp_project.research_type, scp_project.researcher_ckey)
			p.progress = round((scp_project.research_points / max(1, scp_project.research_cost)) * 100)
			p.status = scp_project.status
			research_projects[project_id] = p
		else
			var/datum/research_persistence_project/p = research_projects[project_id]
			p.progress = round((scp_project.research_points / max(1, scp_project.research_cost)) * 100)
			p.status = scp_project.status
			if(scp_project.status == "COMPLETED" && p.status != "COMPLETED")
				p.actual_completion = world.time
				completed_projects++

/datum/research_persistence_manager/proc/add_research_project(var/project_name, var/project_description, var/research_field, var/lead_researcher, var/budget = 0, var/priority = 1)
	var/project_id = "project_[world.time]"
	var/datum/research_persistence_project/project = new /datum/research_persistence_project(project_id, project_name, project_description, research_field, lead_researcher)
	project.budget_allocated = budget
	project.priority = priority

	research_projects[project_id] = project
	total_research_projects++
	return project

/datum/research_persistence_manager/proc/add_scientific_discovery(var/discovery_name, var/discovery_description, var/discovery_type, var/research_field, var/discoverer_ckey, var/significance_level = 1)
	var/discovery_id = "discovery_[world.time]"
	var/datum/research_scientific_discovery/discovery = new /datum/research_scientific_discovery(discovery_id, discovery_name, discovery_description, discovery_type, research_field, discoverer_ckey)
	discovery.significance_level = significance_level

	scientific_discoveries[discovery_id] = discovery
	scientific_breakthroughs++
	return discovery

/datum/research_persistence_manager/proc/add_publication(var/publication_title, var/publication_abstract, var/authors, var/journal_name, var/impact_factor = 1.0)
	var/publication_id = "pub_[world.time]"
	var/datum/publication/publication = new /datum/publication(publication_id, publication_title, publication_abstract, authors, journal_name)
	publication.impact_factor = impact_factor

	publications[publication_id] = publication
	publication_count++
	return publication

/datum/research_persistence_manager/proc/add_research_facility(var/facility_name, var/facility_type, var/location, var/capacity = 100, var/security_level = 1)
	var/facility_id = "facility_[world.time]"
	var/datum/research_persistence_facility/facility = new /datum/research_persistence_facility(facility_id, facility_name, facility_type, location)
	facility.capacity = capacity
	facility.security_level = security_level

	research_facilities[facility_id] = facility
	return facility

/datum/research_persistence_manager/proc/add_research_grant(var/grant_name, var/granting_organization, var/amount, var/research_field, var/recipient_ckey)
	var/grant_id = "grant_[world.time]"
	var/datum/research_grant/grant = new /datum/research_grant(grant_id, grant_name, granting_organization, amount, research_field, recipient_ckey)

	research_grants[grant_id] = grant
	return grant

/datum/research_persistence_manager/proc/update_research_statistics()
	research_statistics["total_projects"] = total_research_projects
	research_statistics["completed_projects"] = completed_projects
	research_statistics["active_projects"] = length(research_projects)
	research_statistics["scientific_discoveries"] = length(scientific_discoveries)
	research_statistics["publications"] = publication_count
	research_statistics["research_budget"] = research_budget
	research_statistics["research_efficiency"] = research_efficiency
	research_statistics["research_staff"] = research_staff_count
	research_statistics["facilities"] = length(research_facilities)
	research_statistics["grants"] = length(research_grants)

/datum/research_persistence_manager/proc/process_projects()
	for(var/project_id in research_projects)
		var/datum/research_persistence_project/project = research_projects[project_id]
		if(project.status == "ACTIVE")
			// Calculate real research progress based on actual game data
			project.progress = calculate_real_research_progress(project)

			// Check for completion
			if(project.progress >= 100)
				project.status = "COMPLETED"
				project.actual_completion = world.time
				completed_projects++

				// Generate discovery based on actual research data
				if(length(project.research_notes) > 5) // Real discovery based on research notes
					var/discovery_name = "Discovery from [project.project_name]"
					var/discovery_description = "A significant discovery made during the completion of [project.project_name]"
					add_scientific_discovery(discovery_name, discovery_description, "EXPERIMENTAL", project.research_field, project.lead_researcher)

// Calculate real research progress based on actual game data
/datum/research_persistence_manager/proc/calculate_real_research_progress(var/datum/research_persistence_project/project)
	var/base_progress = project.progress

	// Progress based on number of researchers
	if(length(project.researchers) > 0)
		base_progress += length(project.researchers) * 3

	// Progress based on budget utilization
	if(project.budget_allocated > 0)
		var/budget_utilization = (project.budget_used / project.budget_allocated) * 100
		base_progress += budget_utilization * 0.3

	// Progress based on research notes (actual research activity)
	base_progress += length(project.research_notes) * 1.5

	// Progress based on experiments completed
	base_progress += project.experiments_completed * 4

	// Progress based on data analysis sessions
	base_progress += project.data_analysis_sessions * 2

	// Progress based on peer consultations
	base_progress += project.peer_consultations * 1.5

	// Progress based on hypothesis tests
	base_progress += project.hypothesis_tests_run * 2.5

	// Progress based on prototype iterations
	base_progress += project.prototype_iterations * 3

	// Progress based on field tests
	base_progress += project.field_tests_conducted * 4

	// Progress based on documentation
	base_progress += project.documentation_pages * 0.5

	// Progress based on presentations and patents
	base_progress += project.conference_presentations * 2
	base_progress += project.patent_applications * 5

	// Progress based on equipment usage
	base_progress += project.research_equipment_used * 0.1

	// Progress based on time elapsed
	var/time_elapsed = world.time - project.start_date
	var/time_factor = min(15, time_elapsed / 12000) // Max 15% from time, 12000 ticks = 20 minutes
	base_progress += time_factor

	// Progress based on priority
	base_progress += project.priority * 2

	return min(100, base_progress)

/datum/research_persistence_manager/proc/update_facilities()
	for(var/facility_id in research_facilities)
		var/datum/research_persistence_facility/facility = research_facilities[facility_id]

		// Calculate real facility wear and tear based on actual usage
		facility.maintenance_level = calculate_real_maintenance_level(facility)

		// Update equipment quality based on maintenance
		if(facility.maintenance_level < 50)
			facility.equipment_quality = max(0.5, facility.equipment_quality - 0.01)

// Calculate real maintenance level based on actual facility usage
/datum/research_persistence_manager/proc/calculate_real_maintenance_level(var/datum/research_persistence_facility/facility)
	var/base_maintenance = facility.maintenance_level

	// Maintenance decreases based on time since last maintenance
	var/time_since_maintenance = world.time - facility.last_maintenance
	var/maintenance_decay = time_since_maintenance / 60000 // Decay over 100 minutes

	// Maintenance decreases based on facility usage hours
	var/usage_decay = facility.usage_hours * 0.1

	// Maintenance decreases based on safety incidents
	var/incident_decay = facility.safety_incidents * 5

	// Maintenance decreases based on equipment failures
	var/failure_decay = facility.equipment_failures * 3

	// Maintenance decreases based on energy consumption (wear and tear)
	var/energy_decay = facility.energy_consumption * 0.05

	// Maintenance decreases based on number of active projects
	var/project_decay = length(facility.active_projects) * 2

	base_maintenance -= maintenance_decay + usage_decay + incident_decay + failure_decay + energy_decay + project_decay

	return max(0, base_maintenance)

/datum/research_persistence_manager/proc/process_grants()
	for(var/grant_id in research_grants)
		var/datum/research_grant/grant = research_grants[grant_id]
		if(grant.status == "ACTIVE")
			// Check for expiration
			if(grant.expiration_date && world.time > grant.expiration_date)
				grant.status = "EXPIRED"

/datum/research_persistence_manager/proc/save_research_data()
	var/list/data = list()

	// Save research projects
	data["research_projects"] = list()
	for(var/project_id in research_projects)
		var/datum/research_persistence_project/project = research_projects[project_id]
		data["research_projects"][project_id] = list(
			"project_name" = project.project_name,
			"project_description" = project.project_description,
			"research_field" = project.research_field,
			"lead_researcher" = project.lead_researcher,
			"researchers" = project.researchers,
			"progress" = project.progress,
			"budget_allocated" = project.budget_allocated,
			"budget_used" = project.budget_used,
			"start_date" = project.start_date,
			"estimated_completion" = project.estimated_completion,
			"actual_completion" = project.actual_completion,
			"status" = project.status,
			"priority" = project.priority,
			"discoveries" = project.discoveries,
			"publications" = project.publications,
			"research_notes" = project.research_notes
		)

	// Save scientific discoveries
	data["scientific_discoveries"] = list()
	for(var/discovery_id in scientific_discoveries)
		var/datum/research_scientific_discovery/discovery = scientific_discoveries[discovery_id]
		data["scientific_discoveries"][discovery_id] = list(
			"discovery_name" = discovery.discovery_name,
			"discovery_description" = discovery.discovery_description,
			"discovery_type" = discovery.discovery_type,
			"research_field" = discovery.research_field,
			"discoverer_ckey" = discovery.discoverer_ckey,
			"discovery_date" = discovery.discovery_date,
			"significance_level" = discovery.significance_level,
			"related_projects" = discovery.related_projects,
			"applications" = discovery.applications,
			"patent_status" = discovery.patent_status,
			"commercial_value" = discovery.commercial_value
		)

	// Save publications
	data["publications"] = list()
	for(var/publication_id in publications)
		var/datum/publication/publication = publications[publication_id]
		data["publications"][publication_id] = list(
			"publication_title" = publication.publication_title,
			"publication_abstract" = publication.publication_abstract,
			"authors" = publication.authors,
			"journal_name" = publication.journal_name,
			"publication_date" = publication.publication_date,
			"impact_factor" = publication.impact_factor,
			"citation_count" = publication.citation_count,
			"peer_review_status" = publication.peer_review_status,
			"doi_number" = publication.doi_number
		)

	// Save research facilities
	data["research_facilities"] = list()
	for(var/facility_id in research_facilities)
		var/datum/research_persistence_facility/facility = research_facilities[facility_id]
		data["research_facilities"][facility_id] = list(
			"facility_name" = facility.facility_name,
			"facility_type" = facility.facility_type,
			"location" = facility.location,
			"capacity" = facility.capacity,
			"current_occupancy" = facility.current_occupancy,
			"equipment_quality" = facility.equipment_quality,
			"maintenance_level" = facility.maintenance_level,
			"active_projects" = facility.active_projects,
			"equipment" = facility.equipment,
			"security_level" = facility.security_level
		)

	// Save research grants
	data["research_grants"] = list()
	for(var/grant_id in research_grants)
		var/datum/research_grant/grant = research_grants[grant_id]
		data["research_grants"][grant_id] = list(
			"grant_name" = grant.grant_name,
			"granting_organization" = grant.granting_organization,
			"amount" = grant.amount,
			"research_field" = grant.research_field,
			"recipient_ckey" = grant.recipient_ckey,
			"grant_date" = grant.grant_date,
			"expiration_date" = grant.expiration_date,
			"status" = grant.status,
			"requirements" = grant.requirements,
			"progress_reports" = grant.progress_reports
		)

	// Save global statistics
	data["global_stats"] = list(
		"total_research_projects" = total_research_projects,
		"completed_projects" = completed_projects,
		"research_budget" = research_budget,
		"research_efficiency" = research_efficiency,
		"scientific_breakthroughs" = scientific_breakthroughs,
		"publication_count" = publication_count,
		"research_staff_count" = research_staff_count
	)

	// Write to JSON file
	var/json_data = json_encode(data)
	var/savefile/S = new /savefile("data/research_persistence.json")
	S["data"] << json_data

	// Save to database
	save_research_data_to_database()

/datum/research_persistence_manager/proc/save_research_data_to_database()
	if(!SSdbcore.Connect())
		world.log << "Research Persistence: Database connection failed, skipping database save"
		return

	// Save research projects to database
	for(var/project_id in research_projects)
		var/datum/research_persistence_project/project = research_projects[project_id]
		var/datum/db_query/query_save_project = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("research_projects")]
			(project_id, project_name, project_description, research_field, lead_researcher, researchers, progress, budget_allocated, budget_used, start_date, estimated_completion, actual_completion, status, priority, discoveries, publications, research_notes)
			VALUES (:project_id, :project_name, :project_description, :research_field, :lead_researcher, :researchers, :progress, :budget_allocated, :budget_used, :start_date, :estimated_completion, :actual_completion, :status, :priority, :discoveries, :publications, :research_notes)
			ON DUPLICATE KEY UPDATE
			project_name = VALUES(project_name), project_description = VALUES(project_description), research_field = VALUES(research_field),
			lead_researcher = VALUES(lead_researcher), researchers = VALUES(researchers), progress = VALUES(progress),
			budget_allocated = VALUES(budget_allocated), budget_used = VALUES(budget_used), start_date = VALUES(start_date),
			estimated_completion = VALUES(estimated_completion), actual_completion = VALUES(actual_completion), status = VALUES(status),
			priority = VALUES(priority), discoveries = VALUES(discoveries), publications = VALUES(publications), research_notes = VALUES(research_notes)
		"}, list(
			"project_id" = project_id,
			"project_name" = project.project_name,
			"project_description" = project.project_description,
			"research_field" = project.research_field,
			"lead_researcher" = project.lead_researcher,
			"researchers" = json_encode(project.researchers),
			"progress" = project.progress,
			"budget_allocated" = project.budget_allocated,
			"budget_used" = project.budget_used,
			"start_date" = project.start_date,
			"estimated_completion" = project.estimated_completion,
			"actual_completion" = project.actual_completion,
			"status" = project.status,
			"priority" = project.priority,
			"discoveries" = json_encode(project.discoveries),
			"publications" = json_encode(project.publications),
			"research_notes" = json_encode(project.research_notes)
		))

		if(!query_save_project.warn_execute())
			world.log << "Research Persistence: Failed to save research project [project_id]"
		qdel(query_save_project)

	// Save scientific discoveries to database
	for(var/discovery_id in scientific_discoveries)
		var/datum/research_scientific_discovery/discovery = scientific_discoveries[discovery_id]
		var/datum/db_query/query_save_discovery = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("research_scientific_discoveries")]
			(discovery_id, discovery_name, discovery_description, discovery_type, research_field, discoverer_ckey, discovery_date, significance_level, related_projects, applications, patent_status, commercial_value)
			VALUES (:discovery_id, :discovery_name, :discovery_description, :discovery_type, :research_field, :discoverer_ckey, :discovery_date, :significance_level, :related_projects, :applications, :patent_status, :commercial_value)
			ON DUPLICATE KEY UPDATE
			discovery_name = VALUES(discovery_name), discovery_description = VALUES(discovery_description), discovery_type = VALUES(discovery_type),
			research_field = VALUES(research_field), discoverer_ckey = VALUES(discoverer_ckey), discovery_date = VALUES(discovery_date),
			significance_level = VALUES(significance_level), related_projects = VALUES(related_projects), applications = VALUES(applications),
			patent_status = VALUES(patent_status), commercial_value = VALUES(commercial_value)
		"}, list(
			"discovery_id" = discovery_id,
			"discovery_name" = discovery.discovery_name,
			"discovery_description" = discovery.discovery_description,
			"discovery_type" = discovery.discovery_type,
			"research_field" = discovery.research_field,
			"discoverer_ckey" = discovery.discoverer_ckey,
			"discovery_date" = discovery.discovery_date,
			"significance_level" = discovery.significance_level,
			"related_projects" = json_encode(discovery.related_projects),
			"applications" = json_encode(discovery.applications),
			"patent_status" = discovery.patent_status,
			"commercial_value" = discovery.commercial_value
		))

		if(!query_save_discovery.warn_execute())
			world.log << "Research Persistence: Failed to save scientific discovery [discovery_id]"
		qdel(query_save_discovery)

	// Save publications to database
	for(var/publication_id in publications)
		var/datum/publication/publication = publications[publication_id]
		var/datum/db_query/query_save_publication = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("research_publications")]
			(publication_id, publication_title, publication_abstract, authors, journal_name, publication_date, impact_factor, citation_count, peer_review_status, doi_number)
			VALUES (:publication_id, :publication_title, :publication_abstract, :authors, :journal_name, :publication_date, :impact_factor, :citation_count, :peer_review_status, :doi_number)
			ON DUPLICATE KEY UPDATE
			publication_title = VALUES(publication_title), publication_abstract = VALUES(publication_abstract), authors = VALUES(authors),
			journal_name = VALUES(journal_name), publication_date = VALUES(publication_date), impact_factor = VALUES(impact_factor),
			citation_count = VALUES(citation_count), peer_review_status = VALUES(peer_review_status), doi_number = VALUES(doi_number)
		"}, list(
			"publication_id" = publication_id,
			"publication_title" = publication.publication_title,
			"publication_abstract" = publication.publication_abstract,
			"authors" = json_encode(publication.authors),
			"journal_name" = publication.journal_name,
			"publication_date" = publication.publication_date,
			"impact_factor" = publication.impact_factor,
			"citation_count" = publication.citation_count,
			"peer_review_status" = publication.peer_review_status,
			"doi_number" = publication.doi_number
		))

		if(!query_save_publication.warn_execute())
			world.log << "Research Persistence: Failed to save publication [publication_id]"
		qdel(query_save_publication)

	// Save research facilities to database
	for(var/facility_id in research_facilities)
		var/datum/research_persistence_facility/facility = research_facilities[facility_id]
		var/datum/db_query/query_save_facility = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("research_facilities")]
			(facility_id, facility_name, facility_type, location, capacity, current_occupancy, equipment_quality, maintenance_level, active_projects, equipment, security_level)
			VALUES (:facility_id, :facility_name, :facility_type, :location, :capacity, :current_occupancy, :equipment_quality, :maintenance_level, :active_projects, :equipment, :security_level)
			ON DUPLICATE KEY UPDATE
			facility_name = VALUES(facility_name), facility_type = VALUES(facility_type), location = VALUES(location),
			capacity = VALUES(capacity), current_occupancy = VALUES(current_occupancy), equipment_quality = VALUES(equipment_quality),
			maintenance_level = VALUES(maintenance_level), active_projects = VALUES(active_projects), equipment = VALUES(equipment), security_level = VALUES(security_level)
		"}, list(
			"facility_id" = facility_id,
			"facility_name" = facility.facility_name,
			"facility_type" = facility.facility_type,
			"location" = facility.location,
			"capacity" = facility.capacity,
			"current_occupancy" = facility.current_occupancy,
			"equipment_quality" = facility.equipment_quality,
			"maintenance_level" = facility.maintenance_level,
			"active_projects" = json_encode(facility.active_projects),
			"equipment" = json_encode(facility.equipment),
			"security_level" = facility.security_level
		))

		if(!query_save_facility.warn_execute())
			world.log << "Research Persistence: Failed to save research facility [facility_id]"
		qdel(query_save_facility)

	// Save research grants to database
	for(var/grant_id in research_grants)
		var/datum/research_grant/grant = research_grants[grant_id]
		var/datum/db_query/query_save_grant = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("research_grants")]
			(grant_id, grant_name, granting_organization, amount, research_field, recipient_ckey, grant_date, expiration_date, status, requirements, progress_reports)
			VALUES (:grant_id, :grant_name, :granting_organization, :amount, :research_field, :recipient_ckey, :grant_date, :expiration_date, :status, :requirements, :progress_reports)
			ON DUPLICATE KEY UPDATE
			grant_name = VALUES(grant_name), granting_organization = VALUES(granting_organization), amount = VALUES(amount),
			research_field = VALUES(research_field), recipient_ckey = VALUES(recipient_ckey), grant_date = VALUES(grant_date),
			expiration_date = VALUES(expiration_date), status = VALUES(status), requirements = VALUES(requirements), progress_reports = VALUES(progress_reports)
		"}, list(
			"grant_id" = grant_id,
			"grant_name" = grant.grant_name,
			"granting_organization" = grant.granting_organization,
			"amount" = grant.amount,
			"research_field" = grant.research_field,
			"recipient_ckey" = grant.recipient_ckey,
			"grant_date" = grant.grant_date,
			"expiration_date" = grant.expiration_date,
			"status" = grant.status,
			"requirements" = json_encode(grant.requirements),
			"progress_reports" = json_encode(grant.progress_reports)
		))

		if(!query_save_grant.warn_execute())
			world.log << "Research Persistence: Failed to save research grant [grant_id]"
		qdel(query_save_grant)

	world.log << "Research Persistence: Saved [length(research_projects)] research projects, [length(scientific_discoveries)] discoveries, [length(publications)] publications, [length(research_facilities)] facilities, and [length(research_grants)] grants to database"

/datum/research_persistence_manager/proc/load_research_data()
	var/savefile/S = new /savefile("data/research_persistence.json")
	if(!S["data"])
		return

	var/json_data
	S["data"] >> json_data

	var/list/data = json_decode(json_data)
	if(!data)
		return

	// Load research projects
	if(data["research_projects"])
		for(var/project_id in data["research_projects"])
			var/list/project_data = data["research_projects"][project_id]
			var/datum/research_persistence_project/project = new /datum/research_persistence_project(project_id, project_data["project_name"], project_data["project_description"], project_data["research_field"], project_data["lead_researcher"])
			project.researchers = project_data["researchers"]
			project.progress = project_data["progress"]
			project.budget_allocated = project_data["budget_allocated"]
			project.budget_used = project_data["budget_used"]
			project.start_date = project_data["start_date"]
			project.estimated_completion = project_data["estimated_completion"]
			project.actual_completion = project_data["actual_completion"]
			project.status = project_data["status"]
			project.priority = project_data["priority"]
			project.discoveries = project_data["discoveries"]
			project.publications = project_data["publications"]
			project.research_notes = project_data["research_notes"]
			research_projects[project_id] = project
			if(project.status == "COMPLETED")
				completed_projects++

	// Load scientific discoveries
	if(data["scientific_discoveries"])
		for(var/discovery_id in data["scientific_discoveries"])
			var/list/discovery_data = data["scientific_discoveries"][discovery_id]
			var/datum/research_scientific_discovery/discovery = new /datum/research_scientific_discovery(discovery_id, discovery_data["discovery_name"], discovery_data["discovery_description"], discovery_data["discovery_type"], discovery_data["research_field"], discovery_data["discoverer_ckey"])
			discovery.discovery_date = discovery_data["discovery_date"]
			discovery.significance_level = discovery_data["significance_level"]
			discovery.related_projects = discovery_data["related_projects"]
			discovery.applications = discovery_data["applications"]
			discovery.patent_status = discovery_data["patent_status"]
			discovery.commercial_value = discovery_data["commercial_value"]
			scientific_discoveries[discovery_id] = discovery

	// Load publications
	if(data["publications"])
		for(var/publication_id in data["publications"])
			var/list/publication_data = data["publications"][publication_id]
			var/datum/publication/publication = new /datum/publication(publication_id, publication_data["publication_title"], publication_data["publication_abstract"], publication_data["authors"], publication_data["journal_name"])
			publication.publication_date = publication_data["publication_date"]
			publication.impact_factor = publication_data["impact_factor"]
			publication.citation_count = publication_data["citation_count"]
			publication.peer_review_status = publication_data["peer_review_status"]
			publication.doi_number = publication_data["doi_number"]
			publications[publication_id] = publication

	// Load research facilities
	if(data["research_facilities"])
		for(var/facility_id in data["research_facilities"])
			var/list/facility_data = data["research_facilities"][facility_id]
			var/datum/research_persistence_facility/facility = new /datum/research_persistence_facility(facility_id, facility_data["facility_name"], facility_data["facility_type"], facility_data["location"])
			facility.capacity = facility_data["capacity"]
			facility.current_occupancy = facility_data["current_occupancy"]
			facility.equipment_quality = facility_data["equipment_quality"]
			facility.maintenance_level = facility_data["maintenance_level"]
			facility.active_projects = facility_data["active_projects"]
			facility.equipment = facility_data["equipment"]
			facility.security_level = facility_data["security_level"]
			research_facilities[facility_id] = facility

	// Load research grants
	if(data["research_grants"])
		for(var/grant_id in data["research_grants"])
			var/list/grant_data = data["research_grants"][grant_id]
			var/datum/research_grant/grant = new /datum/research_grant(grant_id, grant_data["grant_name"], grant_data["granting_organization"], grant_data["amount"], grant_data["research_field"], grant_data["recipient_ckey"])
			grant.grant_date = grant_data["grant_date"]
			grant.expiration_date = grant_data["expiration_date"]
			grant.status = grant_data["status"]
			grant.requirements = grant_data["requirements"]
			grant.progress_reports = grant_data["progress_reports"]
			research_grants[grant_id] = grant

	// Load global statistics
	if(data["global_stats"])
		var/list/stats = data["global_stats"]
		total_research_projects = stats["total_research_projects"]
		research_budget = stats["research_budget"]
		research_efficiency = stats["research_efficiency"]
		scientific_breakthroughs = stats["scientific_breakthroughs"]
		publication_count = stats["publication_count"]
		research_staff_count = stats["research_staff_count"]

// Subsystem initialization
/datum/controller/subsystem/research_persistence/Initialize()
	manager = new /datum/research_persistence_manager()
	manager.load_research_data()
	return ..()

/datum/controller/subsystem/research_persistence/fire()
	if(manager)
		manager.process_research()

/datum/research_persistence_manager/proc/process_persistent_research_with_skills(datum/research_persistence_project/project)
	if(!project)
		return

	// Get lead researcher
	var/mob/living/carbon/human/lead_researcher = get_researcher_by_name(project.lead_researcher)
	if(!lead_researcher)
		return

	// Calculate skill-enhanced research progress
	var/base_progress_rate = 1.0
	var/skill_enhanced_rate = base_progress_rate

	// Apply research skill bonuses
	if(SSskill_integration)
		skill_enhanced_rate = SSskill_integration.manager.apply_research_skill_bonuses(lead_researcher, "research", base_progress_rate)

		// Apply research skill effects
		SSskill_integration.manager.apply_research_skill_effects(lead_researcher, project.project_name)

	// Update project progress
	project.progress += skill_enhanced_rate * 0.05 // Slower progression for balance

	// Check for completion
	if(project.progress >= 100)
		complete_persistent_research_project(project)

	// Check for breakthroughs
	check_persistent_research_breakthrough(project, lead_researcher)

/datum/research_persistence_manager/proc/get_researcher_by_name(researcher_name)
	for(var/mob/living/carbon/human/H in GLOB.mob_list)
		if(QDELETED(H))
			continue
		if(H.real_name == researcher_name)
			return H
	return null

/datum/research_persistence_manager/proc/complete_persistent_research_project(datum/research_persistence_project/project)
	if(!project)
		return

	project.status = "COMPLETED"
	project.progress = 100
	project.actual_completion = world.time

	// Calculate skill-enhanced completion reward
	var/base_reward = 2000 // Base completion reward
	var/enhanced_reward = base_reward

	var/mob/living/carbon/human/lead_researcher = get_researcher_by_name(project.lead_researcher)
	if(lead_researcher && SSskill_integration)
		enhanced_reward = SSskill_integration.manager.apply_research_skill_bonuses(lead_researcher, "breakthrough", base_reward)

	// Award research points
	total_research_projects++
	completed_projects++

	// Award experience to lead researcher
	if(lead_researcher && SSskill_integration)
		SSskill_integration.manager.add_experience(lead_researcher, /datum/skill/research, enhanced_reward * 0.1)

	// Award experience to team members
	award_team_experience(project, enhanced_reward)

	// Announce completion
	announce_persistent_research_completion(project, enhanced_reward)

/datum/research_persistence_manager/proc/award_team_experience(datum/research_persistence_project/project, total_reward)
	var/points_per_member = total_reward * 0.05 / max(length(project.researchers), 1)

	for(var/researcher_name in project.researchers)
		var/mob/living/carbon/human/researcher = get_researcher_by_name(researcher_name)
		if(researcher && SSskill_integration)
			SSskill_integration.manager.add_experience(researcher, /datum/skill/research, points_per_member)

/datum/research_persistence_manager/proc/check_persistent_research_breakthrough(datum/research_persistence_project/project, mob/living/carbon/human/lead_researcher)
	if(!project || !lead_researcher)
		return

	// Calculate skill-enhanced breakthrough chance
	var/base_chance = 1 // 1% base chance
	var/enhanced_chance = base_chance

	if(SSskill_integration)
		enhanced_chance = SSskill_integration.manager.calculate_research_breakthrough_chance(lead_researcher, base_chance)

	if(prob(enhanced_chance))
		trigger_persistent_research_breakthrough(project, lead_researcher)

/datum/research_persistence_manager/proc/trigger_persistent_research_breakthrough(datum/research_persistence_project/project, mob/living/carbon/human/lead_researcher)
	if(!project || !lead_researcher)
		return

	// Add breakthrough discovery
	var/list/breakthrough = list(
		"timestamp" = world.time,
		"type" = "research_breakthrough",
		"description" = "Major breakthrough in [project.project_name]",
		"researcher" = lead_researcher.name
	)
	project.discoveries += list(breakthrough)

	// Award breakthrough experience
	if(SSskill_integration)
		SSskill_integration.manager.add_experience(lead_researcher, /datum/skill/research, 200)

	// Announce breakthrough
	to_chat(lead_researcher, "<span class='boldnotice'>BREAKTHROUGH! You've made a major discovery in [project.project_name]!</span>")

	// Update research metrics
	scientific_breakthroughs++

/datum/research_persistence_manager/proc/announce_persistent_research_completion(datum/research_persistence_project/project, reward)
	if(!project)
		return

	var/completion_message = "RESEARCH PROJECT COMPLETED: [project.project_name] has been completed! Reward: [reward] points"

	// Notify lead researcher
	var/mob/living/carbon/human/lead_researcher = get_researcher_by_name(project.lead_researcher)
	if(lead_researcher)
		to_chat(lead_researcher, "<span class='boldnotice'>[completion_message]</span>")

	// Log completion
	log_game("Research project completed: [project.project_name] - [reward] points")
