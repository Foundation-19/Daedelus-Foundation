// D-Class Escapists 2 Style System
// Main management system for D-Class gameplay

SUBSYSTEM_DEF(dclass)
	name = "D-Class Management"
	wait = 200
	priority = FIRE_PRIORITY_DCLASS
	var/datum/dclass_manager/manager

/datum/controller/subsystem/dclass/Initialize()
	manager = new /datum/dclass_manager()
	log_world("D-Class Management Subsystem: Initialized")
	return ..()

/datum/controller/subsystem/dclass/fire()
	if(manager)
		manager.process_dclass()

// Main D-Class Manager
/datum/dclass_manager
	var/list/dclass_players = list() // ckey -> datum/dclass_player
	var/list/active_routines = list() // Current daily routines
	var/list/guard_patrols = list() // Guard patrol routes
	var/list/work_assignments = list() // Available work assignments
	var/list/contraband_locations = list() // Hidden contraband spots
	var/list/escape_routes = list() // Available escape routes
	var/current_security_level = 1 // 1-4, higher = more secure
	var/round_start_time = 0
	var/current_day = 1
	var/current_time_slot = "morning" // morning, afternoon, evening, night
	var/last_routine_update = 0
	var/routine_update_interval = 300 // 5 minutes
	var/datum/dclass_faction_manager/faction_manager
	var/datum/dclass_persistence_manager/persistence_manager
	var/datum/dclass_event_manager/event_manager

/datum/dclass_manager/New()
	. = ..()
	round_start_time = world.time
	initialize_routines()
	initialize_guard_patrols()
	initialize_work_assignments()
	initialize_contraband_locations()
	initialize_escape_routes()
	faction_manager = new /datum/dclass_faction_manager()
	initialize_events()
	initialize_persistence()

/datum/dclass_manager/proc/initialize_persistence()
	persistence_manager = new /datum/dclass_persistence_manager()

/datum/dclass_manager/proc/process_dclass()
	// Update current time slot
	update_time_slot()

	// Process daily routines
	if(world.time > last_routine_update + routine_update_interval)
		process_daily_routines()
		last_routine_update = world.time

	// Process guard patrols
	process_guard_patrols()

	// Process work assignments
	process_work_assignments()

	// Process factions
	if(faction_manager)
		faction_manager.process_factions()


	// Process dynamic events
	process_events()

	// Process D-Class players
	for(var/ckey in dclass_players)
		var/datum/dclass_player/player = dclass_players[ckey]
		if(player)
			player.process_player_with_persistence()

// Update current time slot based on round time
/datum/dclass_manager/proc/update_time_slot()
	var/round_time = world.time - round_start_time
	var/time_of_day = (round_time / 600) % 24 // Convert to hours

	if(time_of_day >= 6 && time_of_day < 12)
		current_time_slot = "morning"
	else if(time_of_day >= 12 && time_of_day < 18)
		current_time_slot = "afternoon"
	else if(time_of_day >= 18 && time_of_day < 22)
		current_time_slot = "evening"
	else
		current_time_slot = "night"

// Initialize daily routines
/datum/dclass_manager/proc/initialize_routines()
	active_routines["morning"] = list(
		"06:00" = "cell_inspection",
		"07:00" = "breakfast",
		"08:00" = "work_assignment"
	)
	active_routines["afternoon"] = list(
		"12:00" = "lunch",
		"13:00" = "work_assignment",
		"17:00" = "recreation"
	)
	active_routines["evening"] = list(
		"18:00" = "dinner",
		"19:00" = "showers",
		"20:00" = "lockdown"
	)
	active_routines["night"] = list(
		"22:00" = "lights_out"
	)

// Process daily routines based on current time
/datum/dclass_manager/proc/process_daily_routines()
	var/current_routine = active_routines[current_time_slot]
	if(!current_routine)
		return

	for(var/time in current_routine)
		var/routine_type = current_routine[time]
		execute_routine(routine_type)

// Execute a specific routine
/datum/dclass_manager/proc/execute_routine(routine_type)
	switch(routine_type)
		if("cell_inspection")
			perform_cell_inspection()
		if("breakfast")
			open_cafeteria()
		if("work_assignment")
			assign_work_duties()
		if("lunch")
			open_cafeteria()
		if("recreation")
			open_recreation_areas()
		if("dinner")
			open_cafeteria()
		if("showers")
			open_shower_areas()
		if("lockdown")
			initiate_lockdown()
		if("lights_out")
			initiate_lights_out()

// Initialize guard patrol routes
/datum/dclass_manager/proc/initialize_guard_patrols()
	guard_patrols["cell_block"] = list(
		"route" = list("cell_1", "cell_2", "cell_3", "cell_4", "cell_5"),
		"frequency" = 1800, // Every 30 minutes (reduced from 2 minutes)
		"last_patrol" = 0
	)
	guard_patrols["common_areas"] = list(
		"route" = list("cafeteria", "rec_room", "showers", "work_area"),
		"frequency" = 2400, // Every 40 minutes (reduced from 3 minutes)
		"last_patrol" = 0
	)
	guard_patrols["security_checkpoints"] = list(
		"route" = list("checkpoint_1", "checkpoint_2", "checkpoint_3"),
		"frequency" = 3600, // Every 60 minutes (reduced from 5 minutes)
		"last_patrol" = 0
	)

// Process guard patrols
/datum/dclass_manager/proc/process_guard_patrols()
	for(var/patrol_name in guard_patrols)
		var/list/patrol_data = guard_patrols[patrol_name]
		if(world.time > patrol_data["last_patrol"] + patrol_data["frequency"])
			execute_guard_patrol(patrol_name, patrol_data["route"])
			patrol_data["last_patrol"] = world.time

// Execute a guard patrol
/datum/dclass_manager/proc/execute_guard_patrol(patrol_name, route)
	// Find available guards
	var/list/available_guards = list()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.job && findtext(H.job, "Guard"))
			available_guards += H

	if(length(available_guards) > 0)
		var/mob/living/carbon/human/guard = pick(available_guards)
		// Send guard on patrol (simplified for now)
		// Reduced frequency to prevent spam - only send message occasionally
		if(prob(25)) // 25% chance to send message
			to_chat(guard, "<span class='notice'>You are assigned to patrol [patrol_name].</span>")

// Initialize work assignments
/datum/dclass_manager/proc/initialize_work_assignments()
	work_assignments["kitchen"] = list(
		"name" = "Kitchen Duty",
		"description" = "Assist with food preparation and cleaning",
		"tools" = list("knife", "cleaning_supplies"),
		"access" = list("kitchen", "storage"),
		"risk" = 1,
		"reward" = 25
	)
	work_assignments["maintenance"] = list(
		"name" = "Maintenance",
		"description" = "Repair and maintain facility systems",
		"tools" = list("wrench", "screwdriver", "wire"),
		"access" = list("maintenance_tunnels", "electrical"),
		"risk" = 2,
		"reward" = 35
	)
	work_assignments["laundry"] = list(
		"name" = "Laundry",
		"description" = "Handle facility laundry and uniforms",
		"tools" = list("detergent", "steam_iron"),
		"access" = list("laundry_room", "uniform_storage"),
		"risk" = 1,
		"reward" = 20
	)
	work_assignments["medical"] = list(
		"name" = "Medical Assistance",
		"description" = "Assist medical staff with basic procedures",
		"tools" = list("bandages", "medicine"),
		"access" = list("medical_bay", "pharmacy"),
		"risk" = 3,
		"reward" = 50
	)
	work_assignments["janitorial"] = list(
		"name" = "Janitorial Duty",
		"description" = "Clean and decontaminate SCP containment zones",
		"tools" = list("mop", "anomalous_decon_kit"),
		"access" = list("lcz_common", "hcz_common"),
		"risk" = 2,
		"reward" = 30
	)
	work_assignments["specimen_handling"] = list(
		"name" = "Specimen Handling",
		"description" = "Transport and catalog SCP research specimens under supervision",
		"tools" = list("specimen_kit", "evidence_bags"),
		"access" = list("research_lab", "specimen_storage"),
		"risk" = 4,
		"reward" = 60
	)
	work_assignments["laundry_decon"] = list(
		"name" = "Anomalous Laundry Decon",
		"description" = "Process contaminated clothing through anomalous decontamination wash",
		"tools" = list("detergent", "anomalous_cleaner"),
		"access" = list("laundry_room", "decon_station"),
		"risk" = 2,
		"reward" = 35
	)
	work_assignments["construction"] = list(
		"name" = "Containment Construction",
		"description" = "Assist with building and reinforcing SCP containment cells",
		"tools" = list("wrench", "metal_sheets", "rebar"),
		"access" = list("construction_zone", "material_storage"),
		"risk" = 3,
		"reward" = 45
	)
	work_assignments["testing_subject"] = list(
		"name" = "Testing Subject",
		"description" = "Participate in supervised SCP testing procedures",
		"tools" = list("monitoring_device", "recorder"),
		"access" = list("testing_chamber", "observation_deck"),
		"risk" = 5,
		"reward" = 100
	)
	work_assignments["document_archival"] = list(
		"name" = "Document Archival",
		"description" = "Scan and file SCP documentation into the Foundation archive",
		"tools" = list("scanner", "filing_supplies"),
		"access" = list("archive_room", "records_office"),
		"risk" = 1,
		"reward" = 15
	)
	work_assignments["botany_sample"] = list(
		"name" = "Botany Collection",
		"description" = "Collect and preserve anomalous plant specimens under supervision",
		"tools" = list("sample_kit", "preservation_vials"),
		"access" = list("hydroponics", "specimen_storage"),
		"risk" = 2,
		"reward" = 25
	)

// Process work assignments
/datum/dclass_manager/proc/process_work_assignments()
	// Assign work to available D-Class
	for(var/ckey in dclass_players)
		var/datum/dclass_player/player = dclass_players[ckey]
		if(player && !player.current_work_assignment)
			assign_random_work(player)

// Assign random work to a D-Class player
/datum/dclass_manager/proc/assign_random_work(datum/dclass_player/player)
	var/list/available_work = list()
	for(var/work_id in work_assignments)
		var/list/work_data = work_assignments[work_id]
		if(player.level >= work_data["risk"])
			available_work += work_id

	if(length(available_work) > 0)
		var/selected_work = pick(available_work)
		player.assign_work(selected_work)

// Initialize contraband locations
/datum/dclass_manager/proc/initialize_contraband_locations()
	contraband_locations["kitchen"] = list(
		"knife" = 30,
		"metal_utensils" = 60,
		"cleaning_supplies" = 40
	)
	contraband_locations["maintenance"] = list(
		"wire" = 70,
		"screwdriver" = 50,
		"wrench" = 40,
		"metal_pipe" = 30
	)
	contraband_locations["laundry"] = list(
		"staff_uniform" = 20,
		"fabric_scraps" = 80,
		"thread" = 60
	)
	contraband_locations["medical"] = list(
		"medicine" = 40,
		"bandages" = 70,
		"syringe" = 30,
		"chemicals" = 25
	)

// Initialize escape routes
/datum/dclass_manager/proc/initialize_escape_routes()
	escape_routes["tunnel"] = list(
		"name" = "Tunnel Escape",
		"description" = "Dig through walls or floors",
		"requirements" = list("metal_pipe", "knife"),
		"difficulty" = 3,
		"time_required" = 600, // 10 minutes
		"success_chance" = 40
	)
	escape_routes["disguise"] = list(
		"name" = "Disguise Escape",
		"description" = "Impersonate staff members",
		"requirements" = list("staff_uniform", "fake_id"),
		"difficulty" = 4,
		"time_required" = 120, // 2 minutes
		"success_chance" = 60
	)
	escape_routes["vehicle"] = list(
		"name" = "Vehicle Escape",
		"description" = "Hijack transport vehicles",
		"requirements" = list("lockpick", "wire"),
		"difficulty" = 5,
		"time_required" = 300, // 5 minutes
		"success_chance" = 30
	)

// Routine execution methods
/datum/dclass_manager/proc/perform_cell_inspection()
	// Notify all D-Class of cell inspection
	for(var/ckey in dclass_players)
		var/datum/dclass_player/player = dclass_players[ckey]
		if(player)
			player.notify_cell_inspection()

/datum/dclass_manager/proc/open_cafeteria()
	// Open cafeteria for meal time
	for(var/ckey in dclass_players)
		var/datum/dclass_player/player = dclass_players[ckey]
		if(player)
			player.notify_cafeteria_open()

/datum/dclass_manager/proc/assign_work_duties()
	// Assign work to available D-Class
	for(var/ckey in dclass_players)
		var/datum/dclass_player/player = dclass_players[ckey]
		if(player)
			player.notify_work_assignment()

/datum/dclass_manager/proc/open_recreation_areas()
	// Open recreation areas
	for(var/ckey in dclass_players)
		var/datum/dclass_player/player = dclass_players[ckey]
		if(player)
			player.notify_recreation_open()

/datum/dclass_manager/proc/open_shower_areas()
	// Open shower areas
	for(var/ckey in dclass_players)
		var/datum/dclass_player/player = dclass_players[ckey]
		if(player)
			player.notify_showers_open()

/datum/dclass_manager/proc/initiate_lockdown()
	// Initiate lockdown procedures
	current_security_level = min(4, current_security_level + 1)
	for(var/ckey in dclass_players)
		var/datum/dclass_player/player = dclass_players[ckey]
		if(player)
			player.notify_lockdown()

/datum/dclass_manager/proc/initiate_lights_out()
	// Initiate lights out
	for(var/ckey in dclass_players)
		var/datum/dclass_player/player = dclass_players[ckey]
		if(player)
			player.notify_lights_out()

// Get or create D-Class player data
/datum/dclass_manager/proc/get_dclass_player(ckey) as /datum/dclass_player
	if(!(ckey in dclass_players))
		dclass_players[ckey] = new /datum/dclass_player(ckey)
	return dclass_players[ckey]

// Register a new D-Class player
/datum/dclass_manager/proc/register_dclass_player(mob/living/carbon/human/H)
	if(!H.ckey)
		return

	var/datum/dclass_player/player = get_dclass_player(H.ckey)
	player.mob = H
	player.name = H.real_name
	player.notify_spawn()

// Unregister a D-Class player
/datum/dclass_manager/proc/unregister_dclass_player(ckey)
	if(ckey in dclass_players)
		var/datum/dclass_player/player = dclass_players[ckey]
		player.save_data()
		dclass_players -= ckey

// Get current security level
/datum/dclass_manager/proc/get_security_level()
	return current_security_level

// Set security level
/datum/dclass_manager/proc/set_security_level(level)
	current_security_level = max(1, min(4, level))
	// Notify all players of security level change
	for(var/ckey in dclass_players)
		var/datum/dclass_player/player = dclass_players[ckey]
		if(player)
			player.notify_security_level_change(current_security_level)
