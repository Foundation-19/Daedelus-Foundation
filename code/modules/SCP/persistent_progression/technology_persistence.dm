SUBSYSTEM_DEF(technology_persistence)
	name = "Technology Persistence"
	wait = 900 // Check every 15 seconds
	priority = FIRE_PRIORITY_PERSISTENT_PROGRESSION
	var/datum/technology_persistence_manager/manager

/datum/controller/subsystem/technology_persistence/Initialize()
	manager = new /datum/technology_persistence_manager()
	log_game("Technology Persistence Subsystem: Initialized")
	return ..()

/datum/controller/subsystem/technology_persistence/fire()
	if(manager)
		manager.process_technology()

// Technology Persistence Manager
/datum/technology_persistence_manager
	var/list/research_projects = list()
	var/list/technology_tree = list()
	var/list/equipment_blueprints = list()
	var/list/scientific_discoveries = list()
	var/list/research_facilities = list()
	var/list/patents = list()
	var/list/technology_transfers = list()
	var/research_budget = 500000
	var/research_efficiency = 1.0
	var/breakthrough_chance = 0.05
	var/technology_level = 1
	var/research_progress = 0
	var/innovation_score = 0

/datum/technology_persistence_manager/proc/process_technology()
	// Update research projects
	update_research_projects()

	// Update technology tree
	update_technology_tree()

	// Update equipment development
	update_equipment_development()

	// Update research facilities
	update_research_facilities()

	// Process scientific discoveries
	process_scientific_discoveries()

	// Calculate global metrics
	calculate_global_metrics()

	// Save data periodically
	if(world.time % 9000 == 0) // Every 15 minutes
		save_technology_data()

/datum/technology_persistence_manager/proc/update_research_projects()
	// Update ongoing research projects
	for(var/project_id in research_projects)
		var/datum/tech_research_project/project = research_projects[project_id]
		project.update_progress()

/datum/technology_persistence_manager/proc/update_technology_tree()
	// Update technology tree based on completed research
	for(var/tech_id in technology_tree)
		var/datum/technology/tech = technology_tree[tech_id]
		tech.update_status()

/datum/technology_persistence_manager/proc/update_equipment_development()
	// Update equipment development progress
	for(var/blueprint_id in equipment_blueprints)
		var/datum/equipment_blueprint/blueprint = equipment_blueprints[blueprint_id]
		blueprint.update_development()

/datum/technology_persistence_manager/proc/update_research_facilities()
	// Update research facility capabilities
	for(var/facility_id in research_facilities)
		var/datum/research_facility/facility = research_facilities[facility_id]
		facility.update_capabilities()

/datum/technology_persistence_manager/proc/process_scientific_discoveries()
	// Process new scientific discoveries
	for(var/discovery_id in scientific_discoveries)
		var/datum/scientific_discovery/discovery = scientific_discoveries[discovery_id]
		discovery.process_discovery()

/datum/technology_persistence_manager/proc/calculate_global_metrics()
	var/total_progress = 0
	var/project_count = 0
	var/total_innovation = 0

	// Calculate research progress
	for(var/project_id in research_projects)
		var/datum/tech_research_project/project = research_projects[project_id]
		total_progress += project.progress
		project_count++

	if(project_count > 0)
		research_progress = total_progress / project_count

	// Calculate innovation score
	for(var/discovery_id in scientific_discoveries)
		var/datum/scientific_discovery/discovery = scientific_discoveries[discovery_id]
		total_innovation += discovery.innovation_value

	innovation_score = total_innovation

	// Calculate technology level
	technology_level = 1 + (innovation_score / 1000)

/datum/technology_persistence_manager/proc/save_technology_data()
	var/list/data = list(
		"research_projects" = research_projects,
		"technology_tree" = technology_tree,
		"equipment_blueprints" = equipment_blueprints,
		"scientific_discoveries" = scientific_discoveries,
		"research_facilities" = research_facilities,
		"patents" = patents,
		"technology_transfers" = technology_transfers,
		"research_budget" = research_budget,
		"research_efficiency" = research_efficiency,
		"breakthrough_chance" = breakthrough_chance,
		"technology_level" = technology_level,
		"research_progress" = research_progress,
		"innovation_score" = innovation_score
	)

	// Save to JSON file
	var/filename = "data/technology_persistence.json"
	fdel(filename)
	text2file(json_encode(data), filename)

/datum/technology_persistence_manager/proc/load_technology_data()
	var/filename = "data/technology_persistence.json"
	if(fexists(filename))
		var/json_data = file2text(filename)
		var/list/data = json_decode(json_data)

		if(data)
			research_projects = data["research_projects"] || list()
			technology_tree = data["technology_tree"] || list()
			equipment_blueprints = data["equipment_blueprints"] || list()
			scientific_discoveries = data["scientific_discoveries"] || list()
			research_facilities = data["research_facilities"] || list()
			patents = data["patents"] || list()
			technology_transfers = data["technology_transfers"] || list()
			research_budget = data["research_budget"] || 500000
			research_efficiency = data["research_efficiency"] || 1.0
			breakthrough_chance = data["breakthrough_chance"] || 0.05
			technology_level = data["technology_level"] || 1
			research_progress = data["research_progress"] || 0
			innovation_score = data["innovation_score"] || 0

// Technology Research Project Datum
/datum/tech_research_project
	var/project_id
	var/project_name
	var/description
	var/research_field = "general"
	var/progress = 0
	var/max_progress = 100
	var/research_team = list()
	var/start_time = 0
	var/estimated_completion = 0
	var/research_funding = 0
	var/list/discoveries = list()
	var/research_status = "active"
	var/priority_level = 1
	var/list/requirements = list()
	var/list/dependencies = list()
	var/breakthrough_potential = 0.1
	var/technology_impact = 1.0

/datum/tech_research_project/New(var/id, var/name, var/desc, var/field)
	project_id = id
	project_name = name
	description = desc
	research_field = field
	start_time = world.time

/datum/tech_research_project/proc/update_progress()
	// Update research progress based on team activity and funding
	if(research_status == "active")
		var/time_elapsed = world.time - start_time
		var/base_progress = time_elapsed / 72000 // 0.5% per hour

		// Apply funding bonus
		var/funding_bonus = 1.0 + (research_funding / 100000) * 0.5

		// Apply team efficiency bonus
		var/team_efficiency = 1.0
		for(var/member in research_team)
			// Calculate individual efficiency based on skills
			team_efficiency += 0.1 // Simplified

		progress = min(max_progress, base_progress * funding_bonus * team_efficiency)

		// Check for breakthroughs
		if(prob(breakthrough_potential * 100))
			add_breakthrough()

		// Check for completion
		if(progress >= max_progress)
			research_status = "completed"
			add_discovery()

/datum/tech_research_project/proc/add_breakthrough()
	var/list/breakthrough = list(
		"timestamp" = world.time,
		"project_id" = project_id,
		"breakthrough_type" = "research_breakthrough",
		"description" = "Research breakthrough achieved"
	)
	discoveries += breakthrough
	progress = min(max_progress, progress + 10) // Bonus progress

/datum/tech_research_project/proc/add_discovery()
	var/list/discovery = list(
		"timestamp" = world.time,
		"project_id" = project_id,
		"discovery_type" = "research_completion",
		"description" = "Research project completed",
		"technology_impact" = technology_impact
	)
	discoveries += discovery

// Technology Datum
/datum/technology
	var/tech_id
	var/tech_name
	var/description
	var/tech_level = 1
	var/research_cost = 1000
	var/list/prerequisites = list()
	var/list/effects = list()
	var/tech_status = "locked"
	var/research_progress = 0
	var/unlock_time = 0
	var/innovation_value = 100

/datum/technology/New(var/id, var/name, var/desc)
	tech_id = id
	tech_name = name
	description = desc

/datum/technology/proc/update_status()
	// Update technology status based on prerequisites
	if(tech_status == "locked")
		var/prerequisites_met = TRUE
		for(var/prereq in prerequisites)
			if(!is_technology_unlocked(prereq))
				prerequisites_met = FALSE
				break

		if(prerequisites_met)
			tech_status = "available"

	// Update research progress if being researched
	if(tech_status == "researching")
		research_progress += 1
		if(research_progress >= 100)
			tech_status = "unlocked"
			unlock_time = world.time

/datum/technology/proc/is_technology_unlocked(var/tech_id)
	if(!tech_id)
		return FALSE
	var/datum/research_laboratory_manager/mgr = SSresearch_laboratory?.manager
	if(!mgr)
		return FALSE
	var/datum/tech_tree/tree = mgr.tech_tree
	if(!tree)
		return FALSE
	var/datum/tech_node/node = tree.nodes[tech_id]
	if(!node)
		for(var/nid in tree.nodes)
			var/datum/tech_node/n = tree.nodes[nid]
			if(n.node_id == tech_id)
				node = n
				break
	if(!node)
		return FALSE
	return node.unlocked

// Equipment Blueprint Datum
/datum/equipment_blueprint
	var/blueprint_id
	var/blueprint_name
	var/description
	var/equipment_type = "general"
	var/development_progress = 0
	var/max_development = 100
	var/list/requirements = list()
	var/list/components = list()
	var/blueprint_status = "design"
	var/development_cost = 1000
	var/quality_level = 1
	var/list/upgrades = list()

/datum/equipment_blueprint/New(var/id, var/name, var/desc)
	blueprint_id = id
	blueprint_name = name
	description = desc

/datum/equipment_blueprint/proc/update_development()
	// Update equipment development progress
	if(blueprint_status == "development")
		development_progress += 1
		if(development_progress >= max_development)
			blueprint_status = "completed"
			add_upgrade()

/datum/equipment_blueprint/proc/add_upgrade()
	var/list/upgrade = list(
		"timestamp" = world.time,
		"blueprint_id" = blueprint_id,
		"upgrade_type" = "development_completion",
		"description" = "Equipment development completed",
		"quality_level" = quality_level
	)
	upgrades += upgrade

// Scientific Discovery Datum
/datum/scientific_discovery
	var/discovery_id
	var/discovery_name
	var/description
	var/discovery_field = "general"
	var/discovery_type = "theory"
	var/innovation_value = 100
	var/list/applications = list()
	var/discovery_status = "active"
	var/discovery_time = 0
	var/list/researchers = list()
	var/impact_level = 1

/datum/scientific_discovery/New(var/id, var/name, var/desc, var/field)
	discovery_id = id
	discovery_name = name
	description = desc
	discovery_field = field
	discovery_time = world.time

/datum/scientific_discovery/proc/process_discovery()
	// Process scientific discovery effects
	if(discovery_status == "active")
		// Apply discovery effects based on type
		switch(discovery_type)
			if("theory")
				// Apply theoretical effects
				return
			if("experiment")
				// Apply experimental effects
				return
			if("breakthrough")
				// Apply breakthrough effects
				return

// Research Facility Datum
/datum/research_facility
	var/facility_id
	var/facility_name
	var/description
	var/facility_type = "laboratory"
	var/research_capability = 100
	var/equipment_status = 100
	var/list/active_projects = list()
	var/research_efficiency = 1.0
	var/security_level = 1
	var/containment_level = 1
	var/list/specializations = list()
	var/facility_level = 1

/datum/research_facility/New(var/id, var/name, var/desc)
	facility_id = id
	facility_name = name
	description = desc

/datum/research_facility/proc/update_capabilities()
	// Update research facility capabilities
	var/total_equipment = 0
	var/operational_equipment = 0

	// Calculate equipment status (simplified)
	for(var/i = 1; i <= 10; i++)
		total_equipment++
		if(prob(equipment_status))
			operational_equipment++

	if(total_equipment > 0)
		equipment_status = (operational_equipment / total_equipment) * 100
		research_capability = equipment_status
		research_efficiency = equipment_status / 100

// Patent Datum
/datum/patent
	var/patent_id
	var/patent_name
	var/description
	var/patent_holder = "Unknown"
	var/patent_date = 0
	var/patent_duration = 20 // Years
	var/patent_value = 1000
	var/patent_status = "active"
	var/list/licensees = list()
	var/patent_type = "technology"

/datum/patent/New(var/id, var/name, var/desc, var/holder)
	patent_id = id
	patent_name = name
	description = desc
	patent_holder = holder
	patent_date = world.time

// Technology Transfer Datum
/datum/technology_transfer
	var/transfer_id
	var/transfer_name
	var/description
	var/source_organization = "Unknown"
	var/target_organization = "Unknown"
	var/transfer_date = 0
	var/transfer_value = 1000
	var/transfer_status = "pending"
	var/list/technologies = list()
	var/transfer_type = "licensing"

/datum/technology_transfer/New(var/id, var/name, var/desc)
	transfer_id = id
	transfer_name = name
	description = desc
	transfer_date = world.time

// Technology Persistence Verbs
/mob/proc/view_technology_persistence()
	set name = "View Technology Persistence"
	set category = "Technology"

	if(!SStechnology_persistence || !SStechnology_persistence.manager)
		to_chat(src, span_warning("Technology Persistence system not available."))
		return

	var/datum/technology_persistence_manager/manager = SStechnology_persistence.manager

	var/message = "<h2>Technology Persistence Status</h2>"
	message += "<b>Technology Level:</b> [manager.technology_level]<br>"
	message += "<b>Research Progress:</b> [manager.research_progress]%<br>"
	message += "<b>Innovation Score:</b> [manager.innovation_score]<br>"
	message += "<b>Research Budget:</b> $[manager.research_budget]<br>"
	message += "<b>Research Efficiency:</b> [manager.research_efficiency * 100]%<br><br>"

	message += "<h3>Research Projects ([length(manager.research_projects)])</h3>"
	for(var/project_id in manager.research_projects)
		var/datum/tech_research_project/project = manager.research_projects[project_id]
		message += "<b>[project.project_name]:</b> [project.progress]% complete ([project.research_status])<br>"

	message += "<h3>Technologies ([length(manager.technology_tree)])</h3>"
	for(var/tech_id in manager.technology_tree)
		var/datum/technology/tech = manager.technology_tree[tech_id]
		message += "<b>[tech.tech_name]:</b> [tech.tech_status] (Level [tech.tech_level])<br>"

	message += "<h3>Scientific Discoveries ([length(manager.scientific_discoveries)])</h3>"
	for(var/discovery_id in manager.scientific_discoveries)
		var/datum/scientific_discovery/discovery = manager.scientific_discoveries[discovery_id]
		message += "<b>[discovery.discovery_name]:</b> [discovery.discovery_type] ([discovery.innovation_value] innovation)<br>"

	to_chat(src, span_notice("[message]"))

/mob/proc/manage_technology_persistence()
	set name = "Manage Technology Persistence"
	set category = "Technology"

	if(!check_rights(R_ADMIN))
		to_chat(src, span_warning("You don't have permission to manage technology persistence."))
		return

	if(!SStechnology_persistence || !SStechnology_persistence.manager)
		to_chat(src, span_warning("Technology Persistence system not available."))
		return

	var/datum/technology_persistence_manager/manager = SStechnology_persistence.manager

	var/action = input(src, "Choose an action:", "Technology Persistence Management") as null|anything in list(
		"Save Technology Data",
		"Load Technology Data",
		"Reset Technology Data",
		"Add Research Project",
		"Add Technology",
		"View Detailed Status"
	)

	switch(action)
		if("Save Technology Data")
			manager.save_technology_data()
			to_chat(src, span_notice("Technology data saved successfully."))

		if("Load Technology Data")
			manager.load_technology_data()
			to_chat(src, span_notice("Technology data loaded successfully."))

		if("Reset Technology Data")
			if(alert(src, "Are you sure you want to reset all technology persistence data?", "Confirm Reset", "Yes", "No") == "Yes")
				manager.research_projects = list()
				manager.technology_tree = list()
				manager.equipment_blueprints = list()
				manager.scientific_discoveries = list()
				manager.research_facilities = list()
				manager.patents = list()
				manager.technology_transfers = list()
				to_chat(src, span_notice("Technology persistence data reset."))

		if("Add Research Project")
			var/project_name = input(src, "Enter project name:", "Add Research Project") as text
			var/project_desc = input(src, "Enter project description:", "Add Research Project") as text
			var/research_field = input(src, "Enter research field:", "Add Research Project") as text

			if(project_name && project_desc)
				var/project_id = "project_[world.time]"
				var/datum/tech_research_project/new_project = new /datum/tech_research_project(project_id, project_name, project_desc, research_field)
				manager.research_projects[project_id] = new_project
				to_chat(src, span_notice("Research project '[project_name]' added successfully."))

		if("Add Technology")
			var/tech_name = input(src, "Enter technology name:", "Add Technology") as text
			var/tech_desc = input(src, "Enter technology description:", "Add Technology") as text

			if(tech_name && tech_desc)
				var/tech_id = "tech_[world.time]"
				var/datum/technology/new_tech = new /datum/technology(tech_id, tech_name, tech_desc)
				manager.technology_tree[tech_id] = new_tech
				to_chat(src, span_notice("Technology '[tech_name]' added successfully."))

		if("View Detailed Status")
			view_technology_persistence()
