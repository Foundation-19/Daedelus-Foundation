// SCP Management Interface - Comprehensive TGUI System for Admin Control
// This system provides a complete interface for managing SCPs, their spawning, player access, and configurations

/datum/scp_management_interface
	var/client/admin_client
	var/list/available_scps = list()
	var/list/scp_templates = list()
	var/list/player_permissions = list()
	var/list/spawn_schedules = list()
	var/list/containment_protocols = list()

/datum/scp_management_interface/New(client/admin)
	admin_client = admin
	initialize_scp_templates()
	initialize_containment_protocols()
	ui_interact(admin.mob, null)

/datum/scp_management_interface/proc/initialize_scp_templates()
	// Define SCP templates with default configurations
	scp_templates = list(
		"SCP-035" = list(
			"name" = "SCP-035",
			"class" = "Keter",
			"description" = "Possessive mask with corrosive secretion.",
			"containment_level" = "Keter",
			"spawn_conditions" = list(
				"min_players" = 20,
				"min_time" = 30,
				"max_instances" = 1,
				"spawn_probability" = 0.2,
				"allowed_jobs" = list("Scientist", "Security Officer", "Medical Doctor"),
				"restricted_jobs" = list("D-Class"),
				"spawn_locations" = list("Containment Zone", "Research Wing"),
				"time_restrictions" = list("start_hour" = 0, "end_hour" = 24, "allowed_days" = list(1,2,3,4,5,6,7))
			),
			"player_access" = list("allowed_roles" = list("Scientist", "Security Officer"), "restricted_roles" = list("D-Class"), "min_rank" = 2, "requires_clearance" = TRUE, "clearance_level" = 3, "training_required" = list("SCP-035 Handling"), "max_players" = 1),
			"containment_settings" = list("auto_containment" = TRUE, "containment_radius" = 4, "breach_response_time" = 20, "containment_effectiveness" = 0.8, "backup_protocols" = list("Emergency Lockdown")),
			"research_settings" = list("research_allowed" = TRUE, "research_clearance" = 4, "research_restrictions" = list("No direct contact"), "research_goals" = list("Study secretion", "Study possession")),
			"interaction_settings" = list("interaction_allowed" = FALSE, "interaction_clearance" = 5, "interaction_restrictions" = list("No wearing the mask"), "interaction_logging" = TRUE)
		),
		"SCP-049" = list(
			"name" = "SCP-049",
			"class" = "Euclid",
			"description" = "The Plague Doctor.",
			"containment_level" = "Euclid",
			"spawn_conditions" = list("min_players" = 20, "min_time" = 35, "max_instances" = 1, "spawn_probability" = 0.25, "allowed_jobs" = list("Scientist", "Medical Doctor"), "restricted_jobs" = list("D-Class"), "spawn_locations" = list("Containment Zone"), "time_restrictions" = list("start_hour"=0, "end_hour"=24, "allowed_days"=list(1,2,3,4,5,6,7))),
			"player_access" = list("allowed_roles" = list("Scientist", "Medical Doctor"), "restricted_roles" = list("D-Class"), "min_rank" = 2, "requires_clearance" = TRUE, "clearance_level" = 3, "training_required" = list("Biohazard Containment"), "max_players" = 1),
			"containment_settings" = list("auto_containment" = TRUE, "containment_radius" = 6, "breach_response_time" = 15, "containment_effectiveness" = 0.85, "backup_protocols" = list("Emergency Lockdown")),
			"research_settings" = list("research_allowed" = TRUE, "research_clearance" = 4, "research_restrictions" = list("No surgery"), "research_goals" = list("Study cure claims")),
			"interaction_settings" = list("interaction_allowed" = FALSE, "interaction_clearance" = 5, "interaction_restrictions" = list("No patient contact"), "interaction_logging" = TRUE)
		),
		"SCP-2427-3" = list(
			"name" = "SCP-2427-3",
			"class" = "Euclid",
			"description" = "Sapient component of SCP-2427.",
			"containment_level" = "Euclid",
			"spawn_conditions" = list("min_players" = 18, "min_time" = 25, "max_instances" = 1, "spawn_probability" = 0.2, "allowed_jobs" = list("Scientist", "Security Officer"), "restricted_jobs" = list("D-Class"), "spawn_locations" = list("Research Wing"), "time_restrictions" = list("start_hour"=0, "end_hour"=24, "allowed_days"=list(1,2,3,4,5,6,7))),
			"player_access" = list("allowed_roles" = list("Scientist", "Security Officer"), "restricted_roles" = list("D-Class"), "min_rank" = 2, "requires_clearance" = TRUE, "clearance_level" = 3, "training_required" = list("SCP-2427 Handling"), "max_players" = 1),
			"containment_settings" = list("auto_containment" = TRUE, "containment_radius" = 5, "breach_response_time" = 20, "containment_effectiveness" = 0.8, "backup_protocols" = list("Emergency Lockdown")),
			"research_settings" = list("research_allowed" = TRUE, "research_clearance" = 4, "research_restrictions" = list(), "research_goals" = list("Behavior study")),
			"interaction_settings" = list("interaction_allowed" = TRUE, "interaction_clearance" = 4, "interaction_restrictions" = list(), "interaction_logging" = TRUE)
		),
		"SCP-008" = list(
			"name" = "SCP-008",
			"class" = "Keter",
			"description" = "Zombie plague virus",
			"containment_level" = "Keter",
			"spawn_conditions" = list(
				"min_players" = 20,
				"min_time" = 30,
				"max_instances" = 1,
				"spawn_probability" = 0.3,
				"allowed_jobs" = list("Scientist", "Security Officer", "Medical Doctor"),
				"restricted_jobs" = list("D-Class"),
				"spawn_locations" = list("Research Wing", "Containment Zone"),
				"time_restrictions" = list(
					"start_hour" = 0,
					"end_hour" = 24,
					"allowed_days" = list(1, 2, 3, 4, 5, 6, 7)
				)
			),
			"player_access" = list(
				"allowed_roles" = list("Scientist", "Security Officer", "Medical Doctor"),
				"restricted_roles" = list("D-Class"),
				"min_rank" = 1,
				"requires_clearance" = TRUE,
				"clearance_level" = 3,
				"training_required" = list("SCP-008 Safety Protocol", "Containment Procedures"),
				"max_players" = 5
			),
			"containment_settings" = list(
				"auto_containment" = TRUE,
				"containment_radius" = 10,
				"breach_response_time" = 30,
				"containment_effectiveness" = 0.8,
				"backup_protocols" = list("Emergency Lockdown", "Evacuation Protocol")
			),
			"research_settings" = list(
				"research_allowed" = TRUE,
				"research_clearance" = 4,
				"research_restrictions" = list("No direct contact", "Full PPE required"),
				"research_goals" = list("Cure development", "Containment improvement")
			),
			"interaction_settings" = list(
				"interaction_allowed" = FALSE,
				"interaction_clearance" = 5,
				"interaction_restrictions" = list("No physical contact", "Remote observation only"),
				"interaction_logging" = TRUE
			)
		),
		"SCP-173" = list(
			"name" = "SCP-173",
			"class" = "Euclid",
			"description" = "Sculpture that moves when not observed",
			"containment_level" = "Euclid",
			"spawn_conditions" = list(
				"min_players" = 15,
				"min_time" = 20,
				"max_instances" = 1,
				"spawn_probability" = 0.4,
				"allowed_jobs" = list("Scientist", "Security Officer", "Janitor"),
				"restricted_jobs" = list("D-Class"),
				"spawn_locations" = list("Containment Chamber", "Research Wing"),
				"time_restrictions" = list(
					"start_hour" = 0,
					"end_hour" = 24,
					"allowed_days" = list(1, 2, 3, 4, 5, 6, 7)
				)
			),
			"player_access" = list(
				"allowed_roles" = list("Scientist", "Security Officer", "Janitor"),
				"restricted_roles" = list("D-Class"),
				"min_rank" = 2,
				"requires_clearance" = TRUE,
				"clearance_level" = 2,
				"training_required" = list("SCP-173 Observation Protocol"),
				"max_players" = 3
			),
			"containment_settings" = list(
				"auto_containment" = TRUE,
				"containment_radius" = 5,
				"breach_response_time" = 15,
				"containment_effectiveness" = 0.9,
				"backup_protocols" = list("Blink Protocol", "Emergency Response")
			),
			"research_settings" = list(
				"research_allowed" = TRUE,
				"research_clearance" = 3,
				"research_restrictions" = list("Continuous observation required"),
				"research_goals" = list("Movement pattern analysis", "Containment optimization")
			),
			"interaction_settings" = list(
				"interaction_allowed" = TRUE,
				"interaction_clearance" = 3,
				"interaction_restrictions" = list("Never blink simultaneously", "Maintain visual contact"),
				"interaction_logging" = TRUE
			)
		),
		"SCP-096" = list(
			"name" = "SCP-096",
			"class" = "Euclid",
			"description" = "Shy Guy - becomes aggressive when its face is seen",
			"containment_level" = "Euclid",
			"spawn_conditions" = list(
				"min_players" = 25,
				"min_time" = 45,
				"max_instances" = 1,
				"spawn_probability" = 0.2,
				"allowed_jobs" = list("Scientist", "Security Officer"),
				"restricted_jobs" = list("D-Class"),
				"spawn_locations" = list("Containment Zone", "Research Wing"),
				"time_restrictions" = list(
					"start_hour" = 0,
					"end_hour" = 24,
					"allowed_days" = list(1, 2, 3, 4, 5, 6, 7)
				)
			),
			"player_access" = list(
				"allowed_roles" = list("Scientist", "Security Officer"),
				"restricted_roles" = list("D-Class"),
				"min_rank" = 3,
				"requires_clearance" = TRUE,
				"clearance_level" = 4,
				"training_required" = list("SCP-096 Avoidance Protocol", "Emergency Response"),
				"max_players" = 2
			),
			"containment_settings" = list(
				"auto_containment" = TRUE,
				"containment_radius" = 15,
				"breach_response_time" = 10,
				"containment_effectiveness" = 0.7,
				"backup_protocols" = list("Emergency Lockdown", "Evacuation Protocol", "Termination Protocol")
			),
			"research_settings" = list(
				"research_allowed" = TRUE,
				"research_clearance" = 5,
				"research_restrictions" = list("No visual contact", "Remote observation only"),
				"research_goals" = list("Behavioral analysis", "Containment improvement")
			),
			"interaction_settings" = list(
				"interaction_allowed" = FALSE,
				"interaction_clearance" = 5,
				"interaction_restrictions" = list("No visual contact", "No physical proximity"),
				"interaction_logging" = TRUE
			)
		),
		"SCP-3199" = list(
			"name" = "SCP-3199",
			"class" = "Keter",
			"description" = "Sapient biological entity with unique reproductive capabilities and hunting behavior",
			"containment_level" = "Keter",
			"spawn_conditions" = list(
				"min_players" = 30,
				"min_time" = 60,
				"max_instances" = 4,
				"spawn_probability" = 0.15,
				"allowed_jobs" = list("Scientist", "Security Officer", "Medical Doctor"),
				"restricted_jobs" = list("D-Class"),
				"spawn_locations" = list("Containment Zone", "Research Wing", "Medical Bay"),
				"time_restrictions" = list(
					"start_hour" = 0,
					"end_hour" = 24,
					"allowed_days" = list(1, 2, 3, 4, 5, 6, 7)
				)
			),
			"player_access" = list(
				"allowed_roles" = list("Scientist", "Security Officer", "Medical Doctor"),
				"restricted_roles" = list("D-Class"),
				"min_rank" = 4,
				"requires_clearance" = TRUE,
				"clearance_level" = 5,
				"training_required" = list("SCP-3199 Containment Protocol", "Emergency Response", "Biological Hazard Training"),
				"max_players" = 1
			),
			"containment_settings" = list(
				"auto_containment" = TRUE,
				"containment_radius" = 20,
				"breach_response_time" = 5,
				"containment_effectiveness" = 0.9,
				"backup_protocols" = list("Emergency Lockdown", "Evacuation Protocol", "Termination Protocol", "Site Lockdown")
			),
			"research_settings" = list(
				"research_allowed" = TRUE,
				"research_clearance" = 5,
				"research_restrictions" = list("No direct contact", "Remote observation only", "Full PPE required"),
				"research_goals" = list("Reproductive cycle study", "Behavioral analysis", "Containment optimization")
			),
			"interaction_settings" = list(
				"interaction_allowed" = FALSE,
				"interaction_clearance" = 5,
				"interaction_restrictions" = list("No physical contact", "No proximity", "Remote observation only"),
				"interaction_logging" = TRUE
			)
		),
		"Split Personality Necklace" = list(
			"name" = "Split Personality Necklace",
			"class" = "Euclid",
			"description" = "A mysterious necklace that causes split personality disorder when worn.",
			"containment_level" = "Euclid",
			"spawn_conditions" = list(
				"min_players" = 10,
				"min_time" = 15,
				"max_instances" = 3,
				"spawn_probability" = 0.4,
				"allowed_jobs" = list("Scientist", "Security Officer", "Medical Doctor"),
				"restricted_jobs" = list(),
				"spawn_locations" = list("Research Wing", "Containment Zone"),
				"time_restrictions" = list(
					"start_hour" = 0,
					"end_hour" = 24,
					"allowed_days" = list(1, 2, 3, 4, 5, 6, 7)
				)
			),
			"player_access" = list(
				"allowed_roles" = list("Scientist", "Security Officer", "Medical Doctor"),
				"restricted_roles" = list(),
				"min_rank" = 1,
				"requires_clearance" = TRUE,
				"clearance_level" = 2,
				"training_required" = list("Psychological SCP Handling"),
				"max_players" = 3
			),
			"containment_settings" = list(
				"auto_containment" = FALSE,
				"containment_radius" = 0,
				"breach_response_time" = 0,
				"containment_effectiveness" = 1.0,
				"backup_protocols" = list()
			),
			"research_settings" = list(
				"research_allowed" = TRUE,
				"research_clearance" = 3,
				"research_restrictions" = list("Volunteer testing only"),
				"research_goals" = list("Study psychological effects", "Study personality switching")
			),
			"interaction_settings" = list(
				"interaction_allowed" = TRUE,
				"interaction_clearance" = 2,
				"interaction_restrictions" = list("Remove immediately if distress"),
				"interaction_logging" = TRUE
			)
		)
	)

/datum/scp_management_interface/proc/initialize_containment_protocols()
	containment_protocols = list(
		"standard" = list(
			"name" = "Standard Containment",
			"description" = "Basic containment procedures",
			"effectiveness" = 0.7,
			"response_time" = 30,
			"requirements" = list("Security clearance 2+", "Basic training")
		),
		"enhanced" = list(
			"name" = "Enhanced Containment",
			"description" = "Advanced containment with monitoring",
			"effectiveness" = 0.85,
			"response_time" = 20,
			"requirements" = list("Security clearance 3+", "Advanced training")
		),
		"maximum" = list(
			"name" = "Maximum Containment",
			"description" = "Highest level containment procedures",
			"effectiveness" = 0.95,
			"response_time" = 10,
			"requirements" = list("Security clearance 4+", "Specialized training")
		),
		"emergency" = list(
			"name" = "Emergency Protocol",
			"description" = "Emergency containment procedures",
			"effectiveness" = 0.6,
			"response_time" = 5,
			"requirements" = list("Any clearance", "Emergency training")
		)
	)

/datum/scp_management_interface/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "SCPManagementInterface")
		ui.open()

/datum/scp_management_interface/ui_state(mob/user)
	if(!admin_client || !admin_client.holder || !check_rights(R_ADMIN, FALSE, admin_client))
		return GLOB.never_state
	return GLOB.always_state

/datum/scp_management_interface/ui_data(mob/user)
	var/list/data = list()

	// Get current SCP persistence data
	var/list/scp_data = list()
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_persistence_manager/manager = SSscp_persistence.manager
		scp_data = list(
			"global_containment_stability" = manager.global_containment_stability,
			"active_breaches" = manager.active_breaches,
			"research_progress" = manager.research_progress,
			"containment_effectiveness" = manager.containment_effectiveness,
			"enabled_scps" = manager.enabled_scps,
			"disabled_scps" = manager.disabled_scps,
			"global_management_mode" = manager.global_scp_management_mode,
			"management_override" = manager.management_override,
			"auto_containment_enabled" = manager.auto_containment_enabled,
			"scp_rotation_enabled" = manager.scp_rotation_enabled,
			"rotation_interval" = manager.rotation_interval
		)

		// Add detailed SCP instance data
		scp_data["scp_instances"] = list()
		for(var/scp_id in manager.scp_instances)
			var/datum/scp_instance/instance = manager.scp_instances[scp_id]
			if(instance)
				scp_data["scp_instances"] += list(list(
					"id" = scp_id,
					"containment_health" = instance.containment_health,
					"containment_status" = instance.containment_status,
					"interaction_count" = length(instance.interaction_history),
					"last_interaction" = length(instance.interaction_history) > 0 ? time2text(instance.interaction_history[length(instance.interaction_history)]["timestamp"], "YYYY-MM-DD HH:MM") : "Never",
					"enabled" = manager.is_scp_enabled(scp_id)
				))

	data["scp_data"] = scp_data
	data["scp_templates"] = scp_templates
	data["containment_protocols"] = containment_protocols

	// Get player data for access management
	var/list/player_data = list()

	// Add online players
	for(var/client/C in GLOB.clients)
		if(C.mob && ishuman(C.mob))
			var/mob/living/carbon/human/H = C.mob
			var/list/player_info = list(
				"key" = C.key,
				"name" = H.real_name,
				"job" = H.job,
				"rank" = H.mind ? 1 : 1, // Placeholder for rank system
				"clearance" = H.mind ? 1 : 1, // Placeholder for clearance system
				"online" = TRUE
			)
			player_data += list(player_info)

	// Add persistent player data from access management system
	if(player_permissions)
		for(var/ckey in player_permissions)
			var/list/pdata = player_permissions[ckey]
			var/online = FALSE
			var/current_job = pdata["job"] || "Unknown"

			// Check if player is currently online
			for(var/client/C in GLOB.clients)
				if(C.key == ckey)
					online = TRUE
					if(C.mob && ishuman(C.mob))
						var/mob/living/carbon/human/H = C.mob
						current_job = H.job
					break

			var/list/player_info = list(
				"key" = ckey,
				"name" = pdata["name"] || "Unknown",
				"job" = current_job,
				"rank" = pdata["rank"] || 1,
				"clearance" = pdata["clearance"] || 1,
				"online" = online,
				"notes" = pdata["notes"] || "",
				"created_date" = pdata["created_date"] || "Unknown",
				"last_updated" = pdata["last_updated"] || "Never"
			)
			player_data += list(player_info)

	data["player_data"] = player_data

	// Get spawn schedule data
	data["spawn_schedules"] = spawn_schedules

	// Get blacklist data
	data["blacklist_data"] = GLOB.scp_blacklist?.get_all_blacklists_data() || list("entries" = list())

	// Get SCP role types for blacklist dropdown
	var/list/scp_role_types = list()
	var/datum/scp_role_controller/controller = GLOB.scp_role_controller
	if(controller)
		for(var/scp_type in list(SCP_ROLE_173, SCP_ROLE_096, SCP_ROLE_008, SCP_ROLE_035, SCP_ROLE_049, SCP_ROLE_079, SCP_ROLE_106, SCP_ROLE_457, SCP_ROLE_939, SCP_ROLE_682))
			var/role_name = controller.get_role_name(scp_type)
			if(role_name)
				scp_role_types += list(list("type" = scp_type, "name" = role_name))
	data["scp_role_types"] = scp_role_types

	return data

/datum/scp_management_interface/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if(!check_rights(R_ADMIN, FALSE, admin_client))
		return

	switch(action)
		if("enable_scp")
			var/scp_id = params["scp_id"]
			if(scp_id && SSscp_persistence && SSscp_persistence.manager)
				SSscp_persistence?.manager?.enable_scp(scp_id)
				. = TRUE

		if("disable_scp")
			var/scp_id = params["scp_id"]
			if(scp_id && SSscp_persistence && SSscp_persistence.manager)
				SSscp_persistence?.manager?.disable_scp(scp_id)
				. = TRUE

		if("set_management_mode")
			var/mode = params["mode"]
			if(mode && SSscp_persistence && SSscp_persistence.manager)
				SSscp_persistence?.manager?.set_management_mode(mode)
				. = TRUE

		if("toggle_auto_containment")
			if(SSscp_persistence && SSscp_persistence.manager)
				SSscp_persistence?.manager?.auto_containment_enabled = !SSscp_persistence?.manager?.auto_containment_enabled
				. = TRUE

		if("toggle_scp_rotation")
			if(SSscp_persistence && SSscp_persistence.manager)
				SSscp_persistence?.manager?.scp_rotation_enabled = !SSscp_persistence?.manager?.scp_rotation_enabled
				. = TRUE

		if("set_rotation_interval")
			var/interval = text2num(params["interval"])
			if(interval && SSscp_persistence && SSscp_persistence.manager)
				SSscp_persistence?.manager?.rotation_interval = interval * 600 // Convert minutes to ticks
				. = TRUE

		if("set_scp_configuration")
			var/scp_id = params["scp_id"]
			var/config_key = params["config_key"]
			var/value = params["value"]
			if(scp_id && config_key && SSscp_persistence && SSscp_persistence.manager)
				SSscp_persistence?.manager?.set_scp_configuration(scp_id, config_key, value)
				. = TRUE

		if("create_spawn_schedule")
			var/schedule_name = params["name"]
			var/scp_id = params["scp_id"]
			var/min_players = text2num(params["min_players"])
			var/max_players = text2num(params["max_players"])
			var/spawn_probability = text2num(params["spawn_probability"])

			if(schedule_name && scp_id)
				spawn_schedules[schedule_name] = list(
					"scp_id" = scp_id,
					"min_players" = min_players || 10,
					"max_players" = max_players || 50,
					"spawn_probability" = spawn_probability || 0.5,
					"enabled" = TRUE,
					"created_by" = admin_client.key,
					"created_time" = world.time
				)
				. = TRUE

		if("toggle_spawn_schedule")
			var/schedule_name = params["name"]
			if(schedule_name && (schedule_name in spawn_schedules))
				spawn_schedules[schedule_name]["enabled"] = !spawn_schedules[schedule_name]["enabled"]
				. = TRUE

		if("delete_spawn_schedule")
			var/schedule_name = params["name"]
			if(schedule_name && (schedule_name in spawn_schedules))
				spawn_schedules -= schedule_name
				. = TRUE

		if("set_player_permission")
			var/player_key = params["player_key"]
			var/scp_id = params["scp_id"]
			var/permission_type = params["permission_type"]
			var/granted = params["granted"]

			if(player_key && scp_id && permission_type)
				if(!(player_key in player_permissions))
					player_permissions[player_key] = list()
				if(!(scp_id in player_permissions[player_key]))
					player_permissions[player_key][scp_id] = list()

				player_permissions[player_key][scp_id][permission_type] = granted
				. = TRUE

		if("force_spawn_scp")
			var/scp_id = params["scp_id"]
			if(scp_id)
				force_spawn_scp(scp_id)
				. = TRUE

		if("force_scp_rotation")
			if(SSscp_persistence && SSscp_persistence.manager)
				SSscp_persistence?.manager?.force_scp_rotation()
				. = TRUE

		if("force_contain_scp")
			var/scp_id = params["scp_id"]
			if(scp_id)
				force_contain_scp(scp_id)
				. = TRUE

		// Player Access Management handlers
		if("add_player_to_access")
			var/player_key = params["player_key"]
			var/player_name = params["player_name"]
			var/job = params["job"]
			var/rank = text2num(params["rank"] || "1")
			var/clearance = text2num(params["clearance"] || "1")
			var/notes = params["notes"] || ""

			if(player_key && player_name)
				// Add player to the access management system
				if(!player_permissions)
					player_permissions = list()

				player_permissions[player_key] = list(
					"name" = player_name,
					"job" = job,
					"rank" = rank,
					"clearance" = clearance,
					"notes" = notes,
					"created_date" = time2text(world.time, "YYYY-MM-DD HH:MM"),
					"created_by" = admin_client.key,
					"last_updated" = time2text(world.time, "YYYY-MM-DD HH:MM"),
					"updated_by" = admin_client.key
				)

				to_chat(admin_client, span_notice("Player [player_name] ([player_key]) has been added to the Player Access Management system."))
				log_game("SCPManagementInterface: Player [player_key] added by [admin_client.key]")
				. = TRUE

		if("remove_player_from_access")
			var/player_key = params["player_key"]
			if(player_key && player_permissions && player_permissions[player_key])
				var/player_name = player_permissions[player_key]["name"]
				to_chat(admin_client, span_notice("Player [player_name] ([player_key]) has been removed from the Player Access Management system."))
				player_permissions -= player_key
				log_game("SCPManagementInterface: Player [player_key] removed by [admin_client.key]")
				. = TRUE

		if("update_player_permissions")
			var/player_key = params["player_key"]
			var/rank = text2num(params["rank"] || "1")
			var/clearance = text2num(params["clearance"] || "1")
			var/job = params["job"]
			var/notes = params["notes"]

			if(player_key && player_permissions && player_permissions[player_key])
				player_permissions[player_key]["rank"] = rank
				player_permissions[player_key]["clearance"] = clearance
				if(job)
					player_permissions[player_key]["job"] = job
				if(notes)
					player_permissions[player_key]["notes"] = notes
				player_permissions[player_key]["last_updated"] = time2text(world.time, "YYYY-MM-DD HH:MM")
				player_permissions[player_key]["updated_by"] = admin_client.key

				var/player_name = player_permissions[player_key]["name"]
				to_chat(admin_client, span_notice("Player [player_name] ([player_key]) permissions have been updated."))
				log_game("SCPManagementInterface: Player [player_key] permissions updated by [admin_client.key]")
				. = TRUE

		if("view_scp_logs")
			var/scp_id = params["scp_id"]
			if(scp_id)
				view_scp_logs(scp_id)
				. = TRUE

		if("export_scp_data")
			export_scp_data()
			. = TRUE

		if("import_scp_data")
			var/data = params["data"]
			if(data)
				import_scp_data(data)
				. = TRUE

		if("blacklist_add_scp")
			var/ckey = ckey(params["ckey"])
			var/scp_type = params["scp_type"]
			var/reason = params["reason"] || "No reason provided"
			if(ckey && scp_type && GLOB.scp_blacklist)
				GLOB.scp_blacklist.add_scp_blacklist(ckey, scp_type, reason, admin_client.key)
				. = TRUE

		if("blacklist_remove_scp")
			var/ckey = ckey(params["ckey"])
			var/scp_type = params["scp_type"]
			if(ckey && scp_type && GLOB.scp_blacklist)
				GLOB.scp_blacklist.remove_scp_blacklist(ckey, scp_type)
				. = TRUE

		if("blacklist_add_category")
			var/ckey = ckey(params["ckey"])
			var/category = params["category"]
			var/reason = params["reason"] || "No reason provided"
			if(ckey && category && GLOB.scp_blacklist)
				GLOB.scp_blacklist.add_category_blacklist(ckey, category, reason, admin_client.key)
				. = TRUE

		if("blacklist_remove_category")
			var/ckey = ckey(params["ckey"])
			var/category = params["category"]
			if(ckey && category && GLOB.scp_blacklist)
				GLOB.scp_blacklist.remove_category_blacklist(ckey, category)
				. = TRUE

		if("blacklist_add_global")
			var/ckey = ckey(params["ckey"])
			var/reason = params["reason"] || "No reason provided"
			if(ckey && GLOB.scp_blacklist)
				GLOB.scp_blacklist.add_global_blacklist(ckey, reason, admin_client.key)
				. = TRUE

		if("blacklist_remove_global")
			var/ckey = ckey(params["ckey"])
			if(ckey && GLOB.scp_blacklist)
				GLOB.scp_blacklist.remove_global_blacklist(ckey)
				. = TRUE

		if("blacklist_remove_all")
			var/ckey = ckey(params["ckey"])
			if(ckey && GLOB.scp_blacklist)
				GLOB.scp_blacklist.remove_all_blacklists(ckey)
				. = TRUE

/datum/scp_management_interface/proc/force_spawn_scp(scp_id)
	if(!scp_id || !SSscp_persistence || !SSscp_persistence.manager)
		return

	// Find the SCP template
	var/list/template = scp_templates[scp_id]
	if(!template)
		to_chat(admin_client, span_warning("No template found for [scp_id]"))
		return

	// Check spawn conditions
	var/player_count = length(GLOB.clients)
	var/min_players = template["spawn_conditions"]["min_players"]

	if(player_count < min_players)
		to_chat(admin_client, span_warning("Not enough players ([player_count]/[min_players]) to spawn [scp_id]"))
		return

	// Create the SCP object
	var/obj/scp_object = create_scp_object(scp_id, template)
	if(scp_object)
		to_chat(admin_client, span_notice("Successfully spawned [scp_id] at [get_area(scp_object)]"))

		// Log the spawn
		if(SSscp_persistence && SSscp_persistence.manager)
			var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances[scp_id]
			if(instance)
				instance.add_interaction_record(null, "admin_forced_spawn")
	else
		to_chat(admin_client, span_danger("Failed to spawn [scp_id]"))

/datum/scp_management_interface/proc/create_scp_object(scp_id, template)
	// This is a simplified version - in practice, you'd have specific creation logic for each SCP
	switch(scp_id)
		if("SCP-008")
			var/obj/item/reagent_containers/glass/bottle/scp008/scp = new /obj/item/reagent_containers/glass/bottle/scp008()
			scp.forceMove(pick(get_area_turfs(pick(GLOB.the_station_areas))))
			return scp
		if("SCP-173")
			// Create SCP-173 object
			var/mob/living/scp/scp173/scp = new /mob/living/scp/scp173()
			scp.forceMove(pick(get_area_turfs(pick(GLOB.the_station_areas))))
			return scp
		if("SCP-096")
			// Create SCP-096 object
			var/mob/living/scp/scp096/scp = new /mob/living/scp/scp096()
			scp.forceMove(pick(get_area_turfs(pick(GLOB.the_station_areas))))
			return scp
		if("SCP-035")
			var/mob/living/carbon/human/H = new /mob/living/carbon/human()
			H.real_name = "SCP-035 Host"
			H.forceMove(pick(get_area_turfs(pick(GLOB.the_station_areas))))
			return H
		if("SCP-049")
			var/mob/living/scp/scp049/scp = new /mob/living/scp/scp049()
			scp.forceMove(pick(get_area_turfs(pick(GLOB.the_station_areas))))
			return scp
		if("SCP-2427-3")
			var/mob/living/carbon/human/H3 = new /mob/living/carbon/human()
			H3.real_name = "SCP-2427-3"
			H3.forceMove(pick(get_area_turfs(pick(GLOB.the_station_areas))))
			return H3
		if("SCP-3199")
			var/mob/living/scp/scp3199/scp = new /mob/living/scp/scp3199()
			scp.forceMove(pick(get_area_turfs(pick(GLOB.the_station_areas))))
			return scp
		if("Split Personality Necklace")
			var/obj/item/clothing/neck/scp/split_personality_necklace/necklace = new /obj/item/clothing/neck/scp/split_personality_necklace()
			necklace.forceMove(pick(get_area_turfs(pick(GLOB.the_station_areas))))
			return necklace
		else
			return null

/datum/scp_management_interface/proc/force_contain_scp(scp_id)
	if(!scp_id || !SSscp_persistence || !SSscp_persistence.manager)
		return

	var/list/scp_objects = list()
	for(var/obj/O in GLOB.SCP_list)
		if(findtext(O.name, scp_id))
			scp_objects += O

	for(var/mob/M in GLOB.mob_list)
		if(QDELETED(M))
			continue
		if(findtext(M.name, scp_id))
			scp_objects += M

	// Apply containment to all found objects
	for(var/atom/A in scp_objects)
		if(istype(A, /obj/item/reagent_containers/glass/bottle/scp008))
			var/obj/item/reagent_containers/glass/bottle/scp008/scp = A
			scp.containment_breached = FALSE
			scp.containment_status = "contained"
		// Add more SCP-specific containment logic here

	to_chat(admin_client, span_notice("Applied containment to [length(scp_objects)] instances of [scp_id]"))

/datum/scp_management_interface/proc/view_scp_logs(scp_id)
	if(!scp_id || !SSscp_persistence || !SSscp_persistence.manager)
		return

	var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances[scp_id]
	if(!instance)
		to_chat(admin_client, span_warning("No logs found for [scp_id]"))
		return

	var/message = "<h2>SCP [scp_id] Interaction Logs</h2>"
	message += "<b>Total Interactions:</b> [length(instance.interaction_history)]<br>"
	message += "<b>Last Interaction:</b> [length(instance.interaction_history) > 0 ? time2text(instance.interaction_history[length(instance.interaction_history)]["timestamp"], "YYYY-MM-DD HH:MM") : "Never"]<br><br>"

	message += "<h3>Recent Interactions:</h3>"
	var/count = 0
	for(var/list/interaction in instance.interaction_history)
		if(count >= 20) // Limit to last 20 interactions
			break
		message += "<b>[interaction["timestamp"]]:</b> [interaction["type"]] - [interaction["target"] || "No target"]<br>"
		count++

	to_chat(admin_client, span_notice("[message]"))

/datum/scp_management_interface/proc/export_scp_data()
	var/list/export_data = list(
		"scp_templates" = scp_templates,
		"spawn_schedules" = spawn_schedules,
		"player_permissions" = player_permissions,
		"containment_protocols" = containment_protocols
	)

	if(SSscp_persistence && SSscp_persistence.manager)
		export_data["persistence_data"] = list(
			"enabled_scps" = SSscp_persistence?.manager?.enabled_scps,
			"disabled_scps" = SSscp_persistence?.manager?.disabled_scps,
			"scp_configurations" = SSscp_persistence?.manager?.scp_configurations,
			"global_management_mode" = SSscp_persistence?.manager?.global_scp_management_mode
		)

	var/json_data = json_encode(export_data)
	admin_client << ftp(json_data, "scp_management_[time2text(world.time, "YYYYMMDD_HHMMSS")].json")
	to_chat(admin_client, span_notice("SCP management data downloaded."))

/datum/scp_management_interface/proc/import_scp_data(data)
	try
		var/list/import_data = json_decode(data)
		if(import_data)
			if("scp_templates" in import_data)
				scp_templates = import_data["scp_templates"]
			if("spawn_schedules" in import_data)
				spawn_schedules = import_data["spawn_schedules"]
			if("player_permissions" in import_data)
				player_permissions = import_data["player_permissions"]
			if("containment_protocols" in import_data)
				containment_protocols = import_data["containment_protocols"]

			to_chat(admin_client, span_notice("SCP Management Data imported successfully"))
		else
			to_chat(admin_client, span_danger("Failed to parse import data"))
	catch(var/exception/e)
		to_chat(admin_client, span_danger("Error importing data: [e]"))



