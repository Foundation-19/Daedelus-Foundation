SUBSYSTEM_DEF(scp_persistence)
	name = "SCP Persistence"
	wait = 300
	priority = FIRE_PRIORITY_PERSISTENT_PROGRESSION
	var/datum/scp_persistence_manager/manager
	var/list/cached_scp_atoms = list()
	var/list/cached_scp_mobs = list()
	var/cache_dirty = TRUE
	

/datum/controller/subsystem/scp_persistence/Initialize()
	manager = new /datum/scp_persistence_manager()
	initialize_chain_breaches()
	init_zone_lighting_controllers()
	minimap_renderer = new()
	log_game("SCP Persistence Subsystem: Initialized")
	return ..()

/datum/controller/subsystem/scp_persistence/fire()
	if(cache_dirty)
		rebuild_scp_cache()
	if(manager)
		manager.process_scp(cached_scp_atoms, cached_scp_mobs)

/datum/controller/subsystem/scp_persistence/proc/rebuild_scp_cache()
	cached_scp_atoms = list()
	cached_scp_mobs = list()
	for(var/atom/A in GLOB.SCP_list)
		var/id = manager?.get_scp_id(A)
		if(id)
			cached_scp_atoms[id] = A
			if(ismob(A))
				cached_scp_mobs[id] = A
	cache_dirty = FALSE

/datum/controller/subsystem/scp_persistence/proc/mark_cache_dirty()
	cache_dirty = TRUE

// SCP Persistence Manager
/datum/scp_persistence_manager
	var/list/datum/scp_instance/scp_instances = list()
	var/list/research_projects = list()
	var/list/containment_protocols = list()
	var/list/anomaly_effects = list()
	var/list/communication_logs = list()
	var/list/environmental_changes = list()
	var/global_containment_stability = 100
	var/active_breaches = 0
	var/research_progress = 0
	var/containment_effectiveness = 1.0

	// SCP Management System
	var/list/enabled_scps = list()
	var/list/disabled_scps = list()
	var/list/scp_configurations = list()
	var/list/scp_restrictions = list()
	var/list/scp_permissions = list()
	var/global_scp_management_mode = "standard" // standard, lockdown, research, emergency
	var/management_override = FALSE
	var/auto_containment_enabled = TRUE
	var/scp_rotation_enabled = FALSE
	var/rotation_interval = 18000 // 30 minutes
	var/last_rotation_time = 0
	var/last_auto_save = 0

	// Player Performance System
	var/list/player_performance_data = list() // ckey -> datum/player_performance
	var/performance_tracking_enabled = TRUE
	var/auto_access_management = TRUE

/datum/scp_persistence_manager/proc/process_scp(list/cached_atoms, list/cached_mobs)
	update_scp_instances(cached_atoms, cached_mobs)

	update_research_projects()

	update_containment_protocols()

	update_anomaly_effects()

	update_environmental_changes()

	calculate_global_metrics()

	process_cross_scp_interactions(cached_atoms)

	if(world.time - last_auto_save >= 6000)
		save_scp_data()
		last_auto_save = world.time

	for(var/client/C in GLOB.clients)
		if(C.mob && istype(C.mob, /mob/living/scp))
			var/mob/living/scp/S = C.mob
			var/datum/player_performance/perf = get_player_performance(C.ckey)
			perf.register_scp_skill_snapshot(S.SCP ? S.SCP.name : (S.name || "SCP"), S.skill_levels)

	process_scp_management()

	if(performance_tracking_enabled)
		process_player_performance()

/datum/scp_persistence_manager/proc/update_scp_instances(list/cached_atoms, list/cached_mobs)
	for(var/scp_id in cached_atoms.Copy())
		var/obj/O = cached_atoms[scp_id]
		if(!O || QDELETED(O))
			cached_atoms -= scp_id
			continue

		if(!is_scp_enabled(scp_id))
			continue

		if(scp_id in scp_instances)
			var/datum/scp_instance/instance = scp_instances[scp_id]
			instance.update_status(O)
			if(istype(O, /mob/living/scp))
				var/mob/living/scp/S = O
				if(!S.skills_restored)
					instance.apply_to_scp(S)
					S.skills_restored = TRUE
		else
			var/datum/scp_instance/new_instance = new /datum/scp_instance(scp_id, O)
			scp_instances[scp_id] = new_instance
			new_instance.update_status(O)
			if(istype(O, /mob/living/scp))
				var/mob/living/scp/S2 = O
				new_instance.apply_to_scp(S2)
				S2.skills_restored = TRUE

// Cross-SCP interactions: proximity-based simple detection and logging
/datum/scp_persistence_manager/proc/process_cross_scp_interactions(list/cached_atoms)
	if(length(scp_instances) < 2)
		return
	for(var/id_a in scp_instances)
		var/obj/A = cached_atoms[id_a]
		if(!A) continue
		for(var/id_b in scp_instances)
			if(id_b == id_a) continue
			var/obj/B = cached_atoms[id_b]
			if(!B) continue
			if(get_dist(A, B) <= 3)
				var/datum/scp_instance/inst_a = scp_instances[id_a]
				var/datum/scp_instance/inst_b = scp_instances[id_b]
				if(inst_a) inst_a.add_interaction_record(null, "proximity:[id_b]")
				if(inst_b) inst_b.add_interaction_record(null, "proximity:[id_a]")

/datum/scp_persistence_manager/proc/get_scp_id(var/atom/A)
	if(ismob(A))
		var/mob/M = A
		if(M.SCP)
			return M.SCP.get_scp_id()
	if(isobj(A))
		var/obj/O = A
		if(O.SCP)
			return O.SCP.get_scp_id()
	if(istype(A, /mob/living/scp))
		var/mob/living/scp/S = A
		if(S.persistence_id && S.persistence_id != "[S.type]")
			return S.persistence_id
	return null

/datum/scp_persistence_manager/proc/update_research_projects()
	for(var/project_id in research_projects.Copy())
		var/datum/research_project/project = research_projects[project_id]
		if(!istype(project))
			research_projects -= project_id
			continue
		project.update_progress()

/datum/scp_persistence_manager/proc/remove_research_project(project_id)
	var/datum/research_project/project = research_projects[project_id]
	if(!project)
		return FALSE
	research_projects -= project_id
	qdel(project)
	return TRUE

/datum/scp_persistence_manager/proc/update_containment_protocols()
	for(var/protocol_id in containment_protocols.Copy())
		var/datum/containment_protocol/protocol = containment_protocols[protocol_id]
		if(!istype(protocol))
			containment_protocols -= protocol_id
			continue
		protocol.update_effectiveness()

/datum/scp_persistence_manager/proc/update_anomaly_effects()
	for(var/effect_id in anomaly_effects.Copy())
		var/datum/anomaly_effect/effect = anomaly_effects[effect_id]
		if(!istype(effect))
			anomaly_effects -= effect_id
			continue
		effect.update_effect()

/datum/scp_persistence_manager/proc/update_environmental_changes()
	for(var/change_id in environmental_changes.Copy())
		var/datum/environmental_change/change = environmental_changes[change_id]
		if(!istype(change))
			environmental_changes -= change_id
			continue
		change.update_change()

/datum/scp_persistence_manager/proc/calculate_global_metrics()
	var/total_containment = 0
	var/instance_count = 0
	active_breaches = 0

	// Calculate global containment stability
	for(var/scp_id in scp_instances)
		var/datum/scp_instance/instance = scp_instances[scp_id]
		total_containment += instance.containment_health
		instance_count++

		if(instance.containment_status == "breached")
			active_breaches++

	if(instance_count > 0)
		global_containment_stability = total_containment / instance_count
		containment_effectiveness = global_containment_stability / 100

	// Calculate research progress
	var/total_progress = 0
	var/project_count = 0

	for(var/project_id in research_projects)
		var/datum/research_project/project = research_projects[project_id]
		total_progress += project.progress
		project_count++

	if(project_count > 0)
		research_progress = total_progress / project_count

/datum/scp_persistence_manager/proc/save_scp_data()
	try
		var/list/serializable_instances = list()
		for(var/scp_id in scp_instances)
			var/datum/scp_instance/instance = scp_instances[scp_id]
			serializable_instances[scp_id] = instance.serialize()

		var/list/serializable_research = list()
		for(var/project_id in research_projects)
			var/datum/research_project/project = research_projects[project_id]
			serializable_research[project_id] = list(
				"project_id" = project.project_id,
				"project_name" = project.project_name,
				"progress" = project.progress,
				"max_progress" = project.max_progress,
				"research_status" = project.research_status,
				"priority_level" = project.priority_level
			)

		var/list/serializable_protocols = list()
		for(var/protocol_id in containment_protocols)
			var/datum/containment_protocol/protocol = containment_protocols[protocol_id]
			serializable_protocols[protocol_id] = list(
				"protocol_id" = protocol.protocol_id,
				"protocol_name" = protocol.protocol_name,
				"effectiveness" = protocol.effectiveness,
				"protocol_status" = protocol.protocol_status,
				"last_maintenance" = protocol.last_maintenance,
				"next_maintenance" = protocol.next_maintenance
			)

		var/list/serializable_effects = list()
		for(var/effect_id in anomaly_effects)
			var/datum/anomaly_effect/effect = anomaly_effects[effect_id]
			serializable_effects[effect_id] = list(
				"effect_id" = effect.effect_id,
				"effect_name" = effect.effect_name,
				"effect_type" = effect.effect_type,
				"effect_strength" = effect.effect_strength,
				"effect_radius" = effect.effect_radius,
				"duration" = effect.duration,
				"effect_status" = effect.effect_status
			)

		var/list/serializable_env = list()
		for(var/change_id in environmental_changes)
			var/datum/environmental_change/change = environmental_changes[change_id]
			serializable_env[change_id] = list(
				"change_id" = change.change_id,
				"change_name" = change.change_name,
				"change_type" = change.change_type,
				"change_strength" = change.change_strength,
				"duration" = change.duration,
				"change_status" = change.change_status
			)

		var/list/data = list(
			"scp_instances" = serializable_instances,
			"research_projects" = serializable_research,
			"containment_protocols" = serializable_protocols,
			"anomaly_effects" = serializable_effects,
			"environmental_changes" = serializable_env,
			"communication_logs" = communication_logs,
			"global_containment_stability" = global_containment_stability,
			"active_breaches" = active_breaches,
			"research_progress" = research_progress,
			"containment_effectiveness" = containment_effectiveness,
			"enabled_scps" = enabled_scps,
			"disabled_scps" = disabled_scps,
			"scp_configurations" = scp_configurations,
			"scp_restrictions" = scp_restrictions,
			"scp_permissions" = scp_permissions,
			"global_scp_management_mode" = global_scp_management_mode,
			"management_override" = management_override,
			"auto_containment_enabled" = auto_containment_enabled,
			"scp_rotation_enabled" = scp_rotation_enabled,
			"rotation_interval" = rotation_interval,
			"last_rotation_time" = last_rotation_time
		)

		var/filename = "data/scp_persistence.json"
		rustg_file_write(json_encode(data), filename)
	catch
		stack_trace("SCP Persistence: Error saving SCP data")

/datum/scp_persistence_manager/proc/load_scp_data()
	var/list/data = null
	try
		var/filename = "data/scp_persistence.json"
		if(fexists(filename))
			var/json_data = file2text(filename)
			data = json_decode(json_data)

		if(data)
			var/list/raw_instances = data["scp_instances"] || list()
			for(var/scp_id in raw_instances)
				var/list/raw = raw_instances[scp_id]
				if(islist(raw))
					var/datum/scp_instance/instance = new /datum/scp_instance(scp_id, null)
					if(raw["containment_status"])
						instance.containment_status = raw["containment_status"]
					if(raw["containment_health"])
						instance.containment_health = raw["containment_health"]
					if(raw["containment_difficulty"])
						instance.containment_difficulty = raw["containment_difficulty"]
					if(raw["current_state"])
						instance.current_state = raw["current_state"]
					if(raw["containment_class"])
						instance.containment_class = raw["containment_class"]
					if(raw["containment_effectiveness"])
						instance.containment_effectiveness = raw["containment_effectiveness"]
					if(raw["research_value"])
						instance.research_value = raw["research_value"]
					if(raw["threat_level"])
						instance.threat_level = raw["threat_level"]
					if(raw["last_breach"])
						instance.last_breach = raw["last_breach"]
					if(islist(raw["breach_history"]))
						instance.breach_history = raw["breach_history"]
					if(islist(raw["interaction_history"]))
						instance.interaction_history = raw["interaction_history"]
					if(raw["reproduction_count"])
						instance.reproduction_count = raw["reproduction_count"]
					if(islist(raw["persisted_skill_levels"]))
						instance.persisted_skill_levels = raw["persisted_skill_levels"]
					if(islist(raw["persisted_skill_experience"]))
						instance.persisted_skill_experience = raw["persisted_skill_experience"]
					if(islist(raw["persisted_skill_cooldowns"]))
						instance.persisted_skill_cooldowns = raw["persisted_skill_cooldowns"]
					if(raw["last_skill_use"])
						instance.last_skill_use = raw["last_skill_use"]
					if(raw["level_up_cooldown"])
						instance.level_up_cooldown = raw["level_up_cooldown"]
					scp_instances[scp_id] = instance
				else
					scp_instances[scp_id] = new /datum/scp_instance(scp_id, null)

			var/list/raw_research = data["research_projects"] || list()
			for(var/project_id in raw_research)
				try
					var/list/rd = raw_research[project_id]
					if(!islist(rd))
						continue
					var/datum/research_project/project = new /datum/research_project(project_id, rd["project_name"], null)
					if(rd["progress"]) project.progress = rd["progress"]
					if(rd["max_progress"]) project.max_progress = rd["max_progress"]
					if(rd["research_status"]) project.research_status = rd["research_status"]
					if(rd["priority_level"]) project.priority_level = rd["priority_level"]
					research_projects[project_id] = project
				catch
					continue

			var/list/raw_protocols = data["containment_protocols"] || list()
			for(var/protocol_id in raw_protocols)
				try
					var/list/pd = raw_protocols[protocol_id]
					if(!islist(pd))
						continue
					var/datum/containment_protocol/protocol = new /datum/containment_protocol(protocol_id, pd["protocol_name"], null)
					if(pd["effectiveness"]) protocol.effectiveness = pd["effectiveness"]
					if(pd["protocol_status"]) protocol.protocol_status = pd["protocol_status"]
					if(pd["last_maintenance"]) protocol.last_maintenance = pd["last_maintenance"]
					if(pd["next_maintenance"]) protocol.next_maintenance = pd["next_maintenance"]
					containment_protocols[protocol_id] = protocol
				catch
					continue

			var/list/raw_effects = data["anomaly_effects"] || list()
			for(var/effect_id in raw_effects)
				try
					var/list/ed = raw_effects[effect_id]
					if(!islist(ed))
						continue
					var/datum/anomaly_effect/effect = new /datum/anomaly_effect(effect_id, ed["effect_name"], null)
					if(ed["effect_type"]) effect.effect_type = ed["effect_type"]
					if(ed["effect_strength"]) effect.effect_strength = ed["effect_strength"]
					if(ed["effect_radius"]) effect.effect_radius = ed["effect_radius"]
					if(ed["duration"]) effect.duration = ed["duration"]
					if(ed["effect_status"]) effect.effect_status = ed["effect_status"]
					anomaly_effects[effect_id] = effect
				catch
					continue

			var/list/raw_comms = data["communication_logs"] || list()
			for(var/log_id in raw_comms)
				if(islist(raw_comms[log_id]))
					communication_logs[log_id] = raw_comms[log_id]

			var/list/raw_env = data["environmental_changes"] || list()
			for(var/change_id in raw_env)
				try
					var/list/cd = raw_env[change_id]
					if(!islist(cd))
						continue
					var/datum/environmental_change/change = new /datum/environmental_change(change_id, cd["change_name"], null)
					if(cd["change_type"]) change.change_type = cd["change_type"]
					if(cd["change_strength"]) change.change_strength = cd["change_strength"]
					if(cd["duration"]) change.duration = cd["duration"]
					if(cd["change_status"]) change.change_status = cd["change_status"]
					environmental_changes[change_id] = change
				catch
					continue
			global_containment_stability = data["global_containment_stability"] || 100
			active_breaches = data["active_breaches"] || 0
			research_progress = data["research_progress"] || 0
			containment_effectiveness = data["containment_effectiveness"] || 1.0
			enabled_scps = data["enabled_scps"] || list()
			disabled_scps = data["disabled_scps"] || list()
			scp_configurations = data["scp_configurations"] || list()
			scp_restrictions = data["scp_restrictions"] || list()
			scp_permissions = data["scp_permissions"] || list()
			global_scp_management_mode = data["global_scp_management_mode"] || "standard"
			management_override = data["management_override"] || FALSE
			auto_containment_enabled = data["auto_containment_enabled"] || TRUE
			scp_rotation_enabled = data["scp_rotation_enabled"] || FALSE
			rotation_interval = data["rotation_interval"] || 18000
			last_rotation_time = data["last_rotation_time"] || 0
	catch
		stack_trace("SCP Persistence: Error loading SCP data")

// SCP Instance Datum
/datum/scp_instance
	var/scp_id
	var/containment_status = "contained"
	var/containment_health = 100
	var/containment_difficulty = 1
	var/current_state = "normal"
	var/list/breach_history = list()
	var/list/research_projects = list()
	var/list/anomaly_effects = list()
	var/list/interaction_history = list()
	var/list/containment_protocols = list()
	var/reproduction_count = 0
	var/list/environmental_changes = list()
	var/list/communication_logs = list()
	var/last_breach = 0
	var/containment_class = "safe"
	var/containment_effectiveness = 1.0
	var/research_value = 100
	var/threat_level = 1

	// Skill persistence
	var/list/persisted_skill_levels = list()
	var/list/persisted_skill_experience = list()
	var/list/persisted_skill_cooldowns = list()
	var/last_skill_use = 0
	var/level_up_cooldown = 0

/datum/scp_instance/New(var/id, var/obj/O)
	scp_id = id
	if(O)
		update_status(O)

/datum/scp_instance/proc/update_status(var/obj/O)
	if(!O)
		return

	if(istype(O, /mob/living))
		var/mob/living/L = O

		if(L.SCP)
			containment_class = L.SCP.classification
			scp_id = L.SCP.get_scp_id()

		containment_health = round((L.health / L.maxHealth) * 100)
		if(L.stat == DEAD)
			containment_status = "terminated"
			current_state = "dead"
		else
			var/area/A = get_area(L)
			var/in_containment = FALSE
			if(A)
				var/area_name = lowertext(A.name)
				if(findtext(area_name, "contain") || findtext(area_name, "scp") || findtext(area_name, "chamber") || findtext(area_name, "cell"))
					in_containment = TRUE
			if(in_containment)
				containment_status = "contained"
				current_state = "normal"
			else
				if(containment_status != "breached")
					containment_status = "breached"
					last_breach = world.time
					add_breach_record()
				current_state = "agitated"

		containment_effectiveness = containment_health / 100

		if(istype(O, /mob/living/scp))
			var/mob/living/scp/S = O
			persisted_skill_levels = islist(S.skill_levels) ? S.skill_levels.Copy() : list()
			persisted_skill_experience = islist(S.skill_experience) ? S.skill_experience.Copy() : list()
			persisted_skill_cooldowns = islist(S.skill_cooldowns) ? S.skill_cooldowns.Copy() : list()
			last_skill_use = S.last_skill_use
			level_up_cooldown = S.level_up_cooldown
	else
		containment_status = "contained"
		containment_health = 100
		current_state = "normal"
		containment_effectiveness = 1.0


// Apply persisted state back onto a live SCP mob
/datum/scp_instance/proc/apply_to_scp(var/mob/living/scp/S)
	if(!S)
		return
	if(islist(persisted_skill_levels) && length(persisted_skill_levels))
		S.skill_levels = persisted_skill_levels.Copy()
	if(islist(persisted_skill_experience) && length(persisted_skill_experience))
		S.skill_experience = persisted_skill_experience.Copy()
	if(islist(persisted_skill_cooldowns) && length(persisted_skill_cooldowns))
		S.skill_cooldowns = persisted_skill_cooldowns.Copy()
	S.last_skill_use = last_skill_use
	S.level_up_cooldown = level_up_cooldown

/datum/scp_instance/proc/add_breach_record()
	var/list/breach_record = list(
		"timestamp" = world.time,
		"containment_health" = containment_health,
		"location" = "Unknown",
		"severity" = "Unknown"
	)
	breach_history += breach_record

/datum/scp_instance/proc/serialize()
	return list(
		"scp_id" = scp_id,
		"containment_status" = containment_status,
		"containment_health" = containment_health,
		"containment_difficulty" = containment_difficulty,
		"current_state" = current_state,
		"breach_history" = breach_history,
		"interaction_history" = interaction_history,
		"containment_class" = containment_class,
		"containment_effectiveness" = containment_effectiveness,
		"research_value" = research_value,
		"threat_level" = threat_level,
		"last_breach" = last_breach,
		"reproduction_count" = reproduction_count,
		"persisted_skill_levels" = persisted_skill_levels,
		"persisted_skill_experience" = persisted_skill_experience,
		"persisted_skill_cooldowns" = persisted_skill_cooldowns,
		"last_skill_use" = last_skill_use,
		"level_up_cooldown" = level_up_cooldown
	)

/datum/scp_instance/proc/add_interaction_record(var/mob/user, var/interaction_type)
	var/list/interaction_record = list(
		"timestamp" = world.time,
		"user" = user ? user.name : "Unknown",
		"interaction_type" = interaction_type,
		"scp_id" = scp_id
	)
	interaction_history += interaction_record

/datum/scp_instance/proc/add_communication_log(var/message, var/source)
	var/list/communication_record = list(
		"timestamp" = world.time,
		"message" = message,
		"source" = source,
		"scp_id" = scp_id
	)
	communication_logs += communication_record

// Research Project Datum
/datum/research_project
	var/project_id
	var/project_name
	var/description
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

/datum/research_project/New(var/id, var/name, var/desc)
	project_id = id
	project_name = name
	description = desc
	start_time = world.time

/datum/research_project/proc/update_progress()
	// Update research progress based on team activity
	if(research_status == "active")
		var/time_elapsed = world.time - start_time
		var/base_progress = time_elapsed / 36000 // 1% per hour

		// Apply team efficiency bonus
		var/team_efficiency = 1.0
		for(var/member in research_team)
			// Calculate individual efficiency based on skills
			team_efficiency += 0.1 // Simplified

		progress = min(max_progress, base_progress * team_efficiency)

		// Check for completion
		if(progress >= max_progress)
			research_status = "completed"
			add_discovery()

/datum/research_project/proc/add_discovery()
	var/list/discovery = list(
		"timestamp" = world.time,
		"project_id" = project_id,
		"discovery_type" = "research_completion",
		"description" = "Research project completed"
	)
	discoveries += discovery

// Containment Protocol Datum
/datum/containment_protocol
	var/protocol_id
	var/protocol_name
	var/description
	var/effectiveness = 1.0
	var/activation_cost = 0
	var/maintenance_cost = 0
	var/list/requirements = list()
	var/list/effects = list()
	var/protocol_status = "active"
	var/last_maintenance = 0
	var/next_maintenance = 0

/datum/containment_protocol/New(var/id, var/name, var/desc)
	protocol_id = id
	protocol_name = name
	description = desc
	last_maintenance = world.time
	next_maintenance = world.time + 36000 // 1 hour

/datum/containment_protocol/proc/update_effectiveness()
	// Update protocol effectiveness based on maintenance
	if(world.time > next_maintenance)
		effectiveness = max(0, effectiveness - 0.1) // Degrade over time
		next_maintenance = world.time + 36000

	// Check if protocol needs maintenance
	if(effectiveness < 0.5)
		protocol_status = "maintenance_required"

/datum/containment_protocol/proc/perform_maintenance()
	effectiveness = 1.0
	last_maintenance = world.time
	next_maintenance = world.time + 36000
	protocol_status = "active"

// Anomaly Effect Datum
/datum/anomaly_effect
	var/effect_id
	var/effect_name
	var/description
	var/effect_type = "passive"
	var/effect_strength = 1.0
	var/effect_radius = 1
	var/duration = -1 // -1 for permanent
	var/start_time = 0
	var/list/affected_areas = list()
	var/list/affected_objects = list()
	var/effect_status = "active"

/datum/anomaly_effect/New(var/id, var/name, var/desc)
	effect_id = id
	effect_name = name
	description = desc
	start_time = world.time

/datum/anomaly_effect/proc/update_effect()
	// Update anomaly effect
	if(duration > 0 && world.time > start_time + duration)
		effect_status = "expired"
		return

	// Apply effect to affected areas and objects
	for(var/area/A in affected_areas)
		apply_area_effect(A)

	for(var/obj/O in affected_objects)
		apply_object_effect(O)

/datum/anomaly_effect/proc/apply_area_effect(var/area/A)
	// Apply effect to area (simplified)
	if(A && effect_status == "active")
		// Modify area properties based on effect type
		switch(effect_type)
			if("temperature")
				// Modify temperature
				return
			if("radiation")
				// Modify radiation levels
				return
			if("reality")
				// Modify reality properties
				return

/datum/anomaly_effect/proc/apply_object_effect(var/obj/O)
	// Apply effect to object (simplified)
	if(O && effect_status == "active")
		// Modify object properties based on effect type
		switch(effect_type)
			if("corruption")
				// Corrupt object
				return
			if("enhancement")
				// Enhance object
				return
			if("transformation")
				// Transform object
				return

// Environmental Change Datum
/datum/environmental_change
	var/change_id
	var/change_name
	var/description
	var/change_type = "permanent"
	var/change_strength = 1.0
	var/affected_area = null
	var/start_time = 0
	var/duration = -1 // -1 for permanent
	var/list/change_effects = list()
	var/change_status = "active"

/datum/environmental_change/New(var/id, var/name, var/desc)
	change_id = id
	change_name = name
	description = desc
	start_time = world.time

/datum/environmental_change/proc/update_change()
	// Update environmental change
	if(duration > 0 && world.time > start_time + duration)
		change_status = "expired"
		return

	// Apply change effects
	if(affected_area && change_status == "active")
		apply_change_effects(affected_area)

/datum/environmental_change/proc/apply_change_effects(var/area/A)
	// Apply environmental change effects (simplified)
	if(A)
		switch(change_type)
			if("temperature")
				// Modify area temperature
				return
			if("atmosphere")
				// Modify atmospheric composition
				return
			if("gravity")
				// Modify gravity
				return
			if("reality")
				// Modify reality properties
				return

// SCP Persistence Verbs
/mob/proc/view_scp_persistence()
	set name = "View SCP Persistence"
	set category = "SCP"

	if(!SSscp_persistence || !SSscp_persistence.manager)
		to_chat(src, span_warning("SCP Persistence system not available."))
		return

	var/datum/scp_persistence_manager/manager = SSscp_persistence.manager

	var/message = "<h2>SCP Persistence Status</h2>"
	message += "<b>Global Containment Stability:</b> [manager.global_containment_stability]%<br>"
	message += "<b>Active Breaches:</b> [manager.active_breaches]<br>"
	message += "<b>Research Progress:</b> [manager.research_progress]%<br>"
	message += "<b>Containment Effectiveness:</b> [manager.containment_effectiveness * 100]%<br><br>"

	message += "<h3>SCP Instances ([length(manager.scp_instances)])</h3>"
	for(var/scp_id in manager.scp_instances)
		var/datum/scp_instance/instance = manager.scp_instances[scp_id]
		message += "<b>[scp_id]:</b> [instance.containment_status] ([instance.containment_health]% health)<br>"

	message += "<h3>Research Projects ([length(manager.research_projects)])</h3>"
	for(var/project_id in manager.research_projects)
		var/datum/research_project/project = manager.research_projects[project_id]
		message += "<b>[project.project_name]:</b> [project.progress]% complete ([project.research_status])<br>"

	to_chat(src, span_notice("[message]"))

/mob/proc/manage_scp_persistence()
	set name = "Manage SCP Persistence"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		to_chat(src, span_warning("You don't have permission to manage SCP persistence."))
		return

	if(!SSscp_persistence || !SSscp_persistence.manager)
		to_chat(src, span_warning("SCP Persistence system not available."))
		return

	var/datum/scp_persistence_manager/manager = SSscp_persistence.manager

	var/action = input(src, "Choose an action:", "SCP Persistence Management") as null|anything in list(
		"Save SCP Data",
		"Load SCP Data",
		"Reset SCP Data",
		"View Detailed Status"
	)

	switch(action)
		if("Save SCP Data")
			manager.save_scp_data()
			to_chat(src, span_notice("SCP data saved successfully."))

		if("Load SCP Data")
			manager.load_scp_data()
			to_chat(src, span_notice("SCP data loaded successfully."))

		if("Reset SCP Data")
			if(alert(src, "Are you sure you want to reset all SCP persistence data?", "Confirm Reset", "Yes", "No") == "Yes")
				manager.scp_instances = list()
				manager.research_projects = list()
				manager.containment_protocols = list()
				manager.anomaly_effects = list()
				manager.communication_logs = list()
				manager.environmental_changes = list()
				to_chat(src, span_notice("SCP persistence data reset."))

		if("View Detailed Status")
			view_scp_persistence()

// SCP Management System Procs
/datum/scp_persistence_manager/proc/process_scp_management()
	// Handle SCP rotation if enabled
	if(scp_rotation_enabled && world.time > last_rotation_time + rotation_interval)
		rotate_scps()

	// Apply management mode effects
	apply_management_mode_effects()

// Enable an SCP
/datum/scp_persistence_manager/proc/enable_scp(scp_id)
	if(!scp_id)
		return FALSE

	if(scp_id in disabled_scps)
		disabled_scps -= scp_id

	if(!(scp_id in enabled_scps))
		enabled_scps += scp_id

	// Initialize configuration if not exists
	if(!(scp_id in scp_configurations))
		scp_configurations[scp_id] = list(
			"enabled" = TRUE,
			"restrictions" = list(),
			"permissions" = list(),
			"containment_level" = "standard",
			"research_allowed" = TRUE,
			"interaction_allowed" = TRUE
		)
	else
		scp_configurations[scp_id]["enabled"] = TRUE

	log_game("SCP Management: [scp_id] enabled")
	return TRUE

// Disable an SCP
/datum/scp_persistence_manager/proc/disable_scp(scp_id)
	if(!scp_id)
		return FALSE

	if(scp_id in enabled_scps)
		enabled_scps -= scp_id

	if(!(scp_id in disabled_scps))
		disabled_scps += scp_id

	if(scp_id in scp_configurations)
		scp_configurations[scp_id]["enabled"] = FALSE

	log_game("SCP Management: [scp_id] disabled")
	return TRUE

// Check if an SCP is enabled
/datum/scp_persistence_manager/proc/is_scp_enabled(scp_id)
	if(management_override)
		return TRUE

	if(scp_id in disabled_scps)
		return FALSE

	if(scp_id in enabled_scps)
		return TRUE

	// Default to enabled if not explicitly managed
	return TRUE

// Set SCP configuration
/datum/scp_persistence_manager/proc/set_scp_configuration(scp_id, config_key, value)
	if(!scp_id || !config_key)
		return FALSE

	if(!(scp_id in scp_configurations))
		scp_configurations[scp_id] = list()

	scp_configurations[scp_id][config_key] = value
	return TRUE

// Get SCP configuration
/datum/scp_persistence_manager/proc/get_scp_configuration(scp_id, config_key)
	if(!scp_id || !config_key)
		return null

	if(scp_id in scp_configurations)
		return scp_configurations[scp_id][config_key]

	return null

// Set global management mode
/datum/scp_persistence_manager/proc/set_management_mode(mode)
	if(!mode || !(mode in list("standard", "lockdown", "research", "emergency")))
		return FALSE

	global_scp_management_mode = mode
	log_game("SCP Management: Global mode changed to [mode]")
	return TRUE

// Apply management mode effects
/datum/scp_persistence_manager/proc/apply_management_mode_effects()
	switch(global_scp_management_mode)
		if("lockdown")
			for(var/scp_id in enabled_scps.Copy())
				if(!is_essential_scp(scp_id))
					disable_scp(scp_id)

		if("research")
			for(var/scp_id in disabled_scps.Copy())
				if(is_research_scp(scp_id))
					enable_scp(scp_id)

		if("emergency")
			for(var/scp_id in enabled_scps.Copy())
				if(!is_essential_scp(scp_id))
					disable_scp(scp_id)

// Check if SCP is essential
/datum/scp_persistence_manager/proc/is_essential_scp(scp_id)
	var/list/essential_scps = list("SCP-173", "SCP-096", "SCP-106")
	return scp_id in essential_scps

// Check if SCP is research-focused
/datum/scp_persistence_manager/proc/is_research_scp(scp_id)
	var/list/research_scps = list("SCP-049", "SCP-914", "SCP-012")
	return scp_id in research_scps

// Rotate SCPs (enable/disable in cycles)
/datum/scp_persistence_manager/proc/rotate_scps()
	if(!scp_rotation_enabled)
		return

	last_rotation_time = world.time

	// Get all available SCPs
	var/list/all_scps = list()
	for(var/scp_id in scp_instances)
		all_scps += scp_id

	// Disable all SCPs
	for(var/scp_id in all_scps)
		disable_scp(scp_id)

	// Enable a random subset
	var/rotation_count = min(5, length(all_scps)) // Enable up to 5 SCPs
	for(var/i = 1 to rotation_count)
		if(length(all_scps) > 0)
			var/selected_scp = pick(all_scps)
			enable_scp(selected_scp)
			all_scps -= selected_scp

	log_game("SCP Management: Rotation completed, [length(enabled_scps)] SCPs enabled")

// Force SCP rotation (admin command)
/datum/scp_persistence_manager/proc/force_scp_rotation()
	rotate_scps()
	log_game("SCP Management: Force rotation executed by admin")

// Get SCP template data for TGUI
/datum/scp_persistence_manager/proc/get_scp_templates()
	var/list/templates = list()

	// This would be populated from the SCP management interface
	// For now, return basic template structure
	templates["SCP-008"] = list(
		"name" = "SCP-008",
		"class" = "Keter",
		"description" = "Zombie plague virus",
		"containment_level" = "Keter"
	)

	templates["SCP-173"] = list(
		"name" = "SCP-173",
		"class" = "Euclid",
		"description" = "Sculpture that moves when not observed",
		"containment_level" = "Euclid"
	)

	templates["SCP-096"] = list(
		"name" = "SCP-096",
		"class" = "Euclid",
		"description" = "Shy Guy - becomes aggressive when its face is seen",
		"containment_level" = "Euclid"
	)

	return templates

// Get player data for TGUI
/datum/scp_persistence_manager/proc/get_player_data()
	var/list/player_data = list()

	for(var/client/C in GLOB.clients)
		if(C.mob && ishuman(C.mob))
			var/mob/living/carbon/human/H = C.mob
			var/list/player_info = list(
				"key" = C.key,
				"name" = H.real_name,
				"job" = H.job,
				"rank" = H.mind ? 1 : 0,
				"clearance" = H.mind ? 1 : 0,
				"online" = TRUE
			)
			player_data += list(player_info)

	return player_data

// Get spawn schedules for TGUI
/datum/scp_persistence_manager/proc/get_spawn_schedules()
	// This would be populated from the SCP management interface
	return list()

// Get containment protocols for TGUI
/datum/scp_persistence_manager/proc/get_containment_protocols()
	var/list/protocols = list()

	protocols["standard"] = list(
		"name" = "Standard Containment",
		"description" = "Basic containment procedures",
		"effectiveness" = 0.7,
		"response_time" = 30,
		"requirements" = list("Security clearance 2+", "Basic training")
	)

	protocols["enhanced"] = list(
		"name" = "Enhanced Containment",
		"description" = "Advanced containment with monitoring",
		"effectiveness" = 0.85,
		"response_time" = 20,
		"requirements" = list("Security clearance 3+", "Advanced training")
	)

	protocols["maximum"] = list(
		"name" = "Maximum Containment",
		"description" = "Highest level containment procedures",
		"effectiveness" = 0.95,
		"response_time" = 10,
		"requirements" = list("Security clearance 4+", "Specialized training")
	)

	protocols["emergency"] = list(
		"name" = "Emergency Protocol",
		"description" = "Emergency containment procedures",
		"effectiveness" = 0.6,
		"response_time" = 5,
		"requirements" = list("Any clearance", "Emergency training")
	)

	return protocols

// SCP Management Verbs
/mob/proc/manage_scp_system()
	set name = "Manage SCP System"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		to_chat(src, span_warning("You don't have permission to manage the SCP system."))
		return

	if(!SSscp_persistence || !SSscp_persistence.manager)
		to_chat(src, span_warning("SCP Persistence system not available."))
		return

	var/datum/scp_persistence_manager/manager = SSscp_persistence.manager

	var/action = input(src, "Choose an action:", "SCP System Management") as null|anything in list(
		"Enable SCP",
		"Disable SCP",
		"Set Management Mode",
		"Toggle Auto-Containment",
		"Toggle SCP Rotation",
		"View SCP Status",
		"Configure SCP",
		"Emergency Lockdown",
		"Research Mode",
		"Standard Mode"
	)

	switch(action)
		if("Enable SCP")
			var/scp_id = input(src, "Enter SCP ID to enable:", "Enable SCP") as text
			if(scp_id)
				if(manager.enable_scp(scp_id))
					to_chat(src, span_notice("[scp_id] enabled successfully."))
				else
					to_chat(src, span_warning("Failed to enable [scp_id]."))

		if("Disable SCP")
			var/scp_id = input(src, "Enter SCP ID to disable:", "Disable SCP") as text
			if(scp_id)
				if(manager.disable_scp(scp_id))
					to_chat(src, span_notice("[scp_id] disabled successfully."))
				else
					to_chat(src, span_warning("Failed to disable [scp_id]."))

		if("Set Management Mode")
			var/mode = input(src, "Choose management mode:", "Set Management Mode") as null|anything in list("standard", "lockdown", "research", "emergency")
			if(mode)
				if(manager.set_management_mode(mode))
					to_chat(src, span_notice("Management mode set to [mode]."))
				else
					to_chat(src, span_warning("Failed to set management mode."))

		if("Toggle Auto-Containment")
			manager.auto_containment_enabled = !manager.auto_containment_enabled
			var/auto_status = manager.auto_containment_enabled ? "enabled" : "disabled"
			to_chat(src, span_notice("Auto-containment [auto_status]."))

		if("Toggle SCP Rotation")
			manager.scp_rotation_enabled = !manager.scp_rotation_enabled
			var/rotation_status = manager.scp_rotation_enabled ? "enabled" : "disabled"
			to_chat(src, span_notice("SCP rotation [rotation_status]."))

		if("View SCP Status")
			view_scp_management_status()

		if("Configure SCP")
			var/scp_id = input(src, "Enter SCP ID to configure:", "Configure SCP") as text
			if(scp_id)
				configure_scp(scp_id)

		if("Emergency Lockdown")
			if(alert(src, "Are you sure you want to initiate emergency lockdown?", "Confirm Lockdown", "Yes", "No") == "Yes")
				manager.set_management_mode("emergency")
				to_chat(src, span_danger("Emergency lockdown initiated!"))

		if("Research Mode")
			manager.set_management_mode("research")
			to_chat(src, span_notice("Research mode activated."))

		if("Standard Mode")
			manager.set_management_mode("standard")
			to_chat(src, span_notice("Standard mode activated."))

// View SCP management status
/mob/proc/view_scp_management_status()
	set name = "View SCP Management Status"
	set category = "Admin"

	if(!SSscp_persistence || !SSscp_persistence.manager)
		to_chat(src, span_warning("SCP Persistence system not available."))
		return

	var/datum/scp_persistence_manager/manager = SSscp_persistence.manager

	var/message = "<h2>SCP Management Status</h2>"
	message += "<b>Global Management Mode:</b> [manager.global_scp_management_mode]<br>"
	message += "<b>Auto-Containment:</b> [manager.auto_containment_enabled ? "Enabled" : "Disabled"]<br>"
	message += "<b>SCP Rotation:</b> [manager.scp_rotation_enabled ? "Enabled" : "Disabled"]<br>"
	message += "<b>Management Override:</b> [manager.management_override ? "Active" : "Inactive"]<br><br>"

	message += "<h3>Enabled SCPs ([length(manager.enabled_scps)])</h3>"
	for(var/scp_id in manager.enabled_scps)
		var/status = manager.is_scp_enabled(scp_id) ? "Active" : "Inactive"
		message += "- [scp_id]: [status]<br>"

	message += "<h3>Disabled SCPs ([length(manager.disabled_scps)])</h3>"
	for(var/scp_id in manager.disabled_scps)
		message += "- [scp_id]<br>"

	message += "<h3>SCP Configurations</h3>"
	for(var/scp_id in manager.scp_configurations)
		var/list/config = manager.scp_configurations[scp_id]
		message += "- [scp_id]: [config["enabled"] ? "Enabled" : "Disabled"]<br>"

	to_chat(src, span_notice("[message]"))

// Configure specific SCP
/mob/proc/configure_scp(scp_id)
	if(!SSscp_persistence || !SSscp_persistence.manager)
		return

	var/datum/scp_persistence_manager/manager = SSscp_persistence.manager

	var/action = input(usr, "Choose configuration option for [scp_id]:", "Configure [scp_id]") as null|anything in list(
		"Set Containment Level",
		"Toggle Research Access",
		"Toggle Interaction Access",
		"Add Restriction",
		"Remove Restriction",
		"View Configuration"
	)

	switch(action)
		if("Set Containment Level")
			var/level = input(usr, "Choose containment level:", "Set Containment Level") as null|anything in list("standard", "enhanced", "maximum", "quarantine")
			if(level)
				manager.set_scp_configuration(scp_id, "containment_level", level)
				to_chat(usr, span_notice("Containment level for [scp_id] set to [level]."))

		if("Toggle Research Access")
			var/current = manager.get_scp_configuration(scp_id, "research_allowed")
			manager.set_scp_configuration(scp_id, "research_allowed", !current)
			var/research_status = current ? "disabled" : "enabled"
			to_chat(usr, span_notice("Research access for [scp_id] [research_status]."))

		if("Toggle Interaction Access")
			var/current = manager.get_scp_configuration(scp_id, "interaction_allowed")
			manager.set_scp_configuration(scp_id, "interaction_allowed", !current)
			var/interaction_status = current ? "disabled" : "enabled"
			to_chat(usr, span_notice("Interaction access for [scp_id] [interaction_status]."))

		if("Add Restriction")
			var/restriction = input(usr, "Enter restriction:", "Add Restriction") as text
			if(restriction)
				var/list/restrictions = manager.get_scp_configuration(scp_id, "restrictions") || list()
				restrictions += restriction
				manager.set_scp_configuration(scp_id, "restrictions", restrictions)
				to_chat(usr, span_notice("Restriction added to [scp_id]."))

		if("Remove Restriction")
			var/list/restrictions = manager.get_scp_configuration(scp_id, "restrictions") || list()
			if(length(restrictions) > 0)
				var/restriction = input(usr, "Choose restriction to remove:", "Remove Restriction") as null|anything in restrictions
				if(restriction)
					restrictions -= restriction
					manager.set_scp_configuration(scp_id, "restrictions", restrictions)
					to_chat(usr, span_notice("Restriction removed from [scp_id]."))

		if("View Configuration")
			var/list/config = manager.scp_configurations[scp_id]
			if(config)
				var/config_message = "<h3>[scp_id] Configuration</h3>"
				for(var/key in config)
					config_message += "<b>[key]:</b> [config[key]]<br>"
				to_chat(usr, span_notice("[config_message]"))

// Player Performance Management Methods
/datum/scp_persistence_manager/proc/process_player_performance()
	// Update performance data for all online players
	for(var/client/C in GLOB.clients)
		if(C.mob && ishuman(C.mob))
			var/mob/living/carbon/human/H = C.mob
			update_player_performance(H.ckey)

/datum/scp_persistence_manager/proc/update_player_performance(var/player)
	if(!player)
		return

	var/ckey = player

	// Get or create player performance datum
	if(!(ckey in player_performance_data))
		player_performance_data[ckey] = new /datum/player_performance(ckey)

	var/datum/player_performance/performance = player_performance_data[ckey]

	// Update basic stats
	performance.total_playtime += 30
	performance.last_updated = world.time

/datum/scp_persistence_manager/proc/get_player_performance(var/ckey)
	if(!(ckey in player_performance_data))
		player_performance_data[ckey] = new /datum/player_performance(ckey)

	return player_performance_data[ckey]

/datum/scp_persistence_manager/proc/get_player_access_level(var/ckey)
	var/datum/player_performance/performance = get_player_performance(ckey)
	return performance.access_level

/datum/scp_persistence_manager/proc/get_player_available_scps(var/ckey)
	var/datum/player_performance/performance = get_player_performance(ckey)
	return performance.get_available_scps()

/datum/scp_persistence_manager/proc/set_player_access_level(var/ckey, var/access_level)
	var/datum/player_performance/performance = get_player_performance(ckey)
	performance.access_level = max(0, min(5, access_level))
	performance.save_performance_data()

/datum/scp_persistence_manager/proc/add_player_achievement(var/ckey, var/achievement_id, var/achievement_name, var/description)
	var/datum/player_performance/performance = get_player_performance(ckey)
	performance.add_achievement(achievement_id, achievement_name, description)

/datum/scp_persistence_manager/proc/add_player_violation(var/ckey, var/violation_type, var/description, var/severity = "minor")
	var/datum/player_performance/performance = get_player_performance(ckey)
	performance.add_violation(violation_type, description, severity)

// Admin commands for player performance management
/mob/proc/manage_player_performance()
	set name = "Manage Player Performance"
	set category = "Admin"

	if(!SSscp_persistence || !SSscp_persistence.manager)
		to_chat(src, span_warning("SCP Persistence system not available."))
		return

	var/datum/scp_persistence_manager/manager = SSscp_persistence.manager

	var/ckey = input(src, "Enter player ckey:", "Manage Player Performance") as text|null
	if(!ckey)
		return

	ckey = ckey(ckey)
	var/datum/player_performance/performance = manager.get_player_performance(ckey)

	var/action = input(src, "Choose action for [ckey]:", "Player Performance Management") as null|anything in list(
		"View Performance",
		"Set Access Level",
		"Add Achievement",
		"Add Violation",
		"Reset Performance"
	)

	switch(action)
		if("View Performance")
			var/message = "<h2>Performance Report for [ckey]</h2>"
			message += "<b>Overall Rating:</b> [performance.overall_rating]<br>"
			message += "<b>Access Level:</b> [performance.access_level]<br>"
			message += "<b>Rounds Played:</b> [performance.rounds_played]<br>"
			message += "<b>Rounds as SCP:</b> [performance.rounds_as_scp]<br>"
			message += "<b>Rounds as Staff:</b> [performance.rounds_as_staff]<br>"
			message += "<b>Total Playtime:</b> [round(performance.total_playtime / 600)] minutes<br><br>"

			message += "<h3>Job Performance</h3>"
			for(var/job_title in performance.job_performance)
				var/list/job_data = performance.job_performance[job_title]
				message += "<b>[job_title]:</b> [job_data["average_score"]] (Rounds: [job_data["rounds_played"]])<br>"

			message += "<h3>SCP Performance</h3>"
			for(var/scp_id in performance.scp_performance)
				var/list/scp_data = performance.scp_performance[scp_id]
				message += "<b>[scp_id]:</b> [scp_data["average_score"]] (Rounds: [scp_data["rounds_played"]])<br>"

			message += "<h3>Achievements ([length(performance.achievements)])</h3>"
			for(var/achievement in performance.achievements)
				var/list/ach_data = achievement
				message += "- [ach_data["name"]]: [ach_data["description"]]<br>"

			message += "<h3>Violations ([length(performance.violations)])</h3>"
			for(var/violation in performance.violations)
				var/list/viol_data = violation
				message += "- [viol_data["type"]] ([viol_data["severity"]]): [viol_data["description"]]<br>"

			to_chat(src, span_notice("[message]"))

		if("Set Access Level")
			var/new_level = input(src, "Enter new access level (0-5):", "Set Access Level") as num|null
			if(!isnull(new_level))
				manager.set_player_access_level(ckey, new_level)
				to_chat(src, span_notice("Access level for [ckey] set to [new_level]."))

		if("Add Achievement")
			var/achievement_id = input(src, "Enter achievement ID:", "Add Achievement") as text|null
			var/achievement_name = input(src, "Enter achievement name:", "Add Achievement") as text|null
			var/description = input(src, "Enter achievement description:", "Add Achievement") as text|null

			if(achievement_id && achievement_name && description)
				manager.add_player_achievement(ckey, achievement_id, achievement_name, description)
				to_chat(src, span_notice("Achievement added for [ckey]."))

		if("Add Violation")
			var/violation_type = input(src, "Enter violation type:", "Add Violation") as text|null
			var/description = input(src, "Enter violation description:", "Add Violation") as text|null
			var/severity = input(src, "Choose severity:", "Add Violation") as null|anything in list("minor", "major")

			if(violation_type && description && severity)
				manager.add_player_violation(ckey, violation_type, description, severity)
				to_chat(src, span_notice("Violation added for [ckey]."))

		if("Reset Performance")
			var/confirm = alert(src, "Are you sure you want to reset performance data for [ckey]?", "Reset Performance", "Yes", "No")
			if(confirm == "Yes")
				manager.player_performance_data -= ckey
				var/filename = "data/player_performance/[ckey].json"
				if(fexists(filename))
					fdel(filename)
				to_chat(src, span_notice("Performance data reset for [ckey]."))
