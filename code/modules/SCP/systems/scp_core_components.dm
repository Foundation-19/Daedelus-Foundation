// Core SCP Components
// Essential components that provide basic SCP functionality

// SCP Identity Component - Converts any mob to an SCP
/datum/scp_advanced_component/scp_identity
	name = "SCP Identity System"
	description = "Provides SCP designation, classification, and core identity"
	version = "2.0.0"
	component_category = "identity"
	component_priority = COMPONENT_PRIORITY_CRITICAL

	// SCP Identity Data
	var/scp_designation = ""
	var/scp_class = ""
	var/scp_name = ""
	var/scp_description = ""
	var/scp_origin = ""
	var/scp_discovered_date = ""
	var/scp_location = ""

	// Containment Status
	var/containment_status = "contained"
	var/containment_level = 1
	var/last_breach_time = 0
	var/breach_count = 0
	var/containment_violations = 0

	// Classification Details
	var/primary_class = ""
	var/secondary_class = ""
	var/disruption_class = ""
	var/risk_class = ""

	// Research Data
	var/research_level = 0
	var/experiment_count = 0
	var/interview_count = 0
	var/test_subjects_used = 0

/datum/scp_advanced_component/scp_identity/on_initialize()
	provided_interfaces = list("scp_identity", "scp_basic_info", "containment_status")

	// Subscribe to relevant events
	manager.subscribe_to_event(COMPONENT_EVENT_BREACH, src)
	manager.subscribe_to_event(COMPONENT_EVENT_CONTAIN, src)

	event_handlers[COMPONENT_EVENT_BREACH] = "on_containment_breach"
	event_handlers[COMPONENT_EVENT_CONTAIN] = "on_containment_restored"

	return TRUE

/datum/scp_advanced_component/scp_identity/proc/set_designation(designation, class_type, name = "", description = "")
	scp_designation = designation
	scp_class = class_type
	scp_name = name || "SCP-[designation]"
	scp_description = description

	// Update mob identity
	parent_mob.name = scp_name
	parent_mob.real_name = scp_name
	var/mob/living/scp/scp_mob = parent_mob
	scp_mob.scp_designation = designation
	scp_mob.scp_class = class_type
	scp_mob.scp_name = scp_name

	// Set default containment level based on class
	set_containment_level_by_class(class_type)

	trigger_event("scp_identity_changed", list("designation" = designation, "class" = class_type))

/datum/scp_advanced_component/scp_identity/proc/set_containment_level_by_class(class_type)
	switch(class_type)
		if("Safe")
			containment_level = 1
		if("Euclid")
			containment_level = 2
		if("Keter")
			containment_level = 3
		if("Apollyon")
			containment_level = 4
		if("Thaumiel")
			containment_level = 2
		if("Neutralized")
			containment_level = 0

/datum/scp_advanced_component/scp_identity/proc/breach_containment()
	if(containment_status == "breached")
		return FALSE

	containment_status = "breached"
	breach_count++
	last_breach_time = world.time
	var/mob/living/scp/scp_mob = parent_mob
	scp_mob.containment_status = containment_status

	trigger_event(COMPONENT_EVENT_BREACH, list("scp" = parent_mob, "time" = world.time))
	return TRUE

/datum/scp_advanced_component/scp_identity/proc/restore_containment()
	if(containment_status == "contained")
		return FALSE

	containment_status = "contained"
	var/mob/living/scp/scp_mob = parent_mob
	scp_mob.containment_status = containment_status

	trigger_event(COMPONENT_EVENT_CONTAIN, list("scp" = parent_mob, "time" = world.time))
	return TRUE

/datum/scp_advanced_component/scp_identity/proc/on_containment_breach(event_data)
	// React to other SCPs breaching
	var/mob/breached_scp = event_data["scp"]
	if(breached_scp != parent_mob)
		// Possibly increase agitation or trigger secondary containment protocols
		trigger_event("scp_breach_detected", list("breached_scp" = breached_scp))

/datum/scp_advanced_component/scp_identity/proc/on_containment_restored(event_data)
	// React to containment being restored
	var/mob/contained_scp = event_data["scp"]
	if(contained_scp != parent_mob)
		trigger_event("scp_contained_detected", list("contained_scp" = contained_scp))

/datum/scp_advanced_component/scp_identity/get_status_info()
	return "SCP-[scp_designation] ([scp_class]) - [containment_status]"

// Advanced Skill System Component
/datum/scp_advanced_component/advanced_skill_system
	name = "Advanced Skill System"
	description = "Comprehensive skill management with leveling, experience, and complex requirements"
	version = "2.0.0"
	component_category = "skills"
	component_priority = COMPONENT_PRIORITY_HIGH

	// Skill Data
	var/list/skills = list() // skill_name -> skill_data
	var/list/skill_categories = list() // category -> list of skills
	var/list/skill_trees = list() // tree_name -> tree_data
	var/list/active_skills = list() // Currently usable skills
	var/list/passive_skills = list() // Always active skills

	// Experience and Leveling
	var/total_experience = 0
	var/skill_points = 0
	var/unspent_skill_points = 0
	var/experience_multiplier = 1.0
	var/max_skill_level = 100
	var/skill_cap_per_level = 5

	// Cooldown Management
	var/list/global_cooldowns = list() // category -> cooldown_time
	var/list/skill_cooldowns = list() // skill_name -> cooldown_time
	var/global_cooldown_reduction = 0
	var/skill_cooldown_reduction = 0

	// Requirements System
	var/list/skill_requirements = list() // skill_name -> requirements
	var/list/requirement_handlers = list() // requirement_type -> handler_proc

/datum/scp_advanced_component/advanced_skill_system/on_initialize()
	provided_interfaces = list("skill_system", "experience_system", "leveling_system")
	required_interfaces = list("scp_identity")

	// Subscribe to events
	manager.subscribe_to_event(COMPONENT_EVENT_TICK, src)
	manager.subscribe_to_event(COMPONENT_EVENT_SKILL_USE, src)

	event_handlers[COMPONENT_EVENT_TICK] = "process_cooldowns"
	event_handlers[COMPONENT_EVENT_SKILL_USE] = "on_skill_used"

	// Initialize default requirement handlers
	setup_requirement_handlers()

	return TRUE

/datum/scp_advanced_component/advanced_skill_system/proc/setup_requirement_handlers()
	requirement_handlers["level"] = "check_level_requirement"
	requirement_handlers["experience"] = "check_experience_requirement"
	requirement_handlers["skill_level"] = "check_skill_level_requirement"
	requirement_handlers["containment_status"] = "check_containment_requirement"
	requirement_handlers["proximity"] = "check_proximity_requirement"
	requirement_handlers["target"] = "check_target_requirement"
	requirement_handlers["time_of_day"] = "check_time_requirement"
	requirement_handlers["health"] = "check_health_requirement"
	requirement_handlers["energy"] = "check_energy_requirement"

/datum/scp_advanced_component/advanced_skill_system/proc/create_skill(skill_name, skill_data)
	var/list/default_data = list(
		"name" = skill_name,
		"description" = "",
		"category" = "general",
		"type" = "active", // active, passive, toggle
		"max_level" = max_skill_level,
		"current_level" = 0,
		"experience" = 0,
		"base_cooldown" = 30 SECONDS,
		"cooldown_per_level" = -1 SECONDS,
		"requirements" = list(),
		"effects" = list(),
		"unlock_requirements" = list(),
		"skill_tree" = "",
		"prerequisites" = list(),
		"conflicts" = list(),
		"enabled" = TRUE
	)

	// Merge with provided data
	for(var/key in skill_data)
		default_data[key] = skill_data[key]

	skills[skill_name] = default_data

	// Add to category
	var/category = default_data["category"]
	if(!(category in skill_categories))
		skill_categories[category] = list()
	skill_categories[category] += skill_name

	// Initialize cooldown
	skill_cooldowns[skill_name] = 0

/datum/scp_advanced_component/advanced_skill_system/proc/add_skill(skill_name, cooldown_time, list/requirements = list())
	// Create default skill data
	var/list/skill_data = list(
		"name" = skill_name,
		"base_cooldown" = cooldown_time,
		"cooldown_per_level" = 0,
		"current_level" = 1,
		"max_level" = 10,
		"current_exp" = 0,
		"exp_to_next" = 100,
		"category" = "general",
		"requirements" = requirements,
		"effects" = list(),
		"enabled" = TRUE
	)

	skills[skill_name] = skill_data

	// Add to category
	var/category = skill_data["category"]
	if(!(category in skill_categories))
		skill_categories[category] = list()
	skill_categories[category] += skill_name

	// Initialize cooldown
	skill_cooldowns[skill_name] = 0

	return TRUE

/datum/scp_advanced_component/advanced_skill_system/proc/can_use_skill(skill_name)
	if(!(skill_name in skills))
		return FALSE

	var/list/skill_data = skills[skill_name]

	// Check if skill is enabled
	if(!skill_data["enabled"])
		return FALSE

	// Check if skill is unlocked
	if(!is_skill_unlocked(skill_name))
		return FALSE

	// Check cooldowns
	if(world.time < skill_cooldowns[skill_name])
		return FALSE

	// Check global category cooldown
	var/category = skill_data["category"]
	if((category in global_cooldowns) && world.time < global_cooldowns[category])
		return FALSE

	// Check requirements
	if(!check_skill_requirements(skill_name))
		return FALSE

	return TRUE

/datum/scp_advanced_component/advanced_skill_system/proc/use_skill(skill_name, target = null, params = list())
	if(!can_use_skill(skill_name))
		return FALSE

	var/list/skill_data = skills[skill_name]
	var/skill_level = skill_data["current_level"]

	// Calculate cooldown
	var/base_cooldown = skill_data["base_cooldown"]
	var/cooldown_per_level = skill_data["cooldown_per_level"]
	var/actual_cooldown = base_cooldown + (cooldown_per_level * skill_level)
	actual_cooldown = max(1 SECOND, actual_cooldown - skill_cooldown_reduction)

	// Set cooldowns
	skill_cooldowns[skill_name] = world.time + actual_cooldown

	// Set global category cooldown if applicable
	var/category = skill_data["category"]
	if(category in global_cooldowns)
		var/remaining = max(0, global_cooldowns[category] - world.time)
		global_cooldowns[category] = world.time + max(0, remaining - global_cooldown_reduction)
	else
		global_cooldowns[category] = world.time

	// Execute skill effects
	execute_skill_effects(skill_name, target, params)

	// Grant experience
	var/exp_gain = calculate_experience_gain(skill_name)
	gain_skill_experience(skill_name, exp_gain)

	// Trigger events
	trigger_event(COMPONENT_EVENT_SKILL_USE, list(
		"skill" = skill_name,
		"level" = skill_level,
		"target" = target,
		"user" = parent_mob
	))

	return TRUE

/datum/scp_advanced_component/advanced_skill_system/proc/execute_skill_effects(skill_name, target, params)
	// Override in SCP-specific skill components
	var/list/skill_data = skills[skill_name]
	var/list/effects = skill_data["effects"]

	for(var/effect in effects)
		execute_skill_effect(effect, skill_data, target, params)

/datum/scp_advanced_component/advanced_skill_system/proc/execute_skill_effect(effect, skill_data, target, params)
	// Base effect execution - override in specialized components
	return

/datum/scp_advanced_component/advanced_skill_system/proc/check_skill_requirements(skill_name)
	var/list/skill_data = skills[skill_name]
	var/list/requirements = skill_data["requirements"]

	for(var/requirement in requirements)
		if(!check_requirement(requirement))
			return FALSE

	return TRUE

/datum/scp_advanced_component/advanced_skill_system/proc/check_requirement(requirement)
	var/req_type = requirement["type"]
	var/handler = requirement_handlers[req_type]

	if(!handler)
		manager.log_warning("Unknown requirement type: [req_type]")
		return TRUE

	return call(src, handler)(requirement)

/datum/scp_advanced_component/advanced_skill_system/proc/check_level_requirement(requirement)
	var/required_level = requirement["value"]
	var/current_level = get_total_level()
	return current_level >= required_level

/datum/scp_advanced_component/advanced_skill_system/proc/check_experience_requirement(requirement)
	var/required_exp = requirement["value"]
	return total_experience >= required_exp

/datum/scp_advanced_component/advanced_skill_system/proc/check_skill_level_requirement(requirement)
	var/skill_name = requirement["skill"]
	var/required_level = requirement["value"]
	var/current_level = get_skill_level(skill_name)
	return current_level >= required_level

/datum/scp_advanced_component/advanced_skill_system/proc/check_containment_requirement(requirement)
	var/required_status = requirement["value"]
	var/datum/scp_advanced_component/scp_identity/identity = manager.get_component_by_interface("scp_identity")
	return identity && identity.containment_status == required_status

/datum/scp_advanced_component/advanced_skill_system/proc/check_proximity_requirement(requirement)
	var/required_range = requirement["value"]
	var/target_type = requirement["target_type"]

	for(var/mob/M in range(required_range, parent_mob))
		if(target_type && !istype(M, target_type))
			continue
		if(M != parent_mob)
			return TRUE

	return FALSE

/datum/scp_advanced_component/advanced_skill_system/proc/check_target_requirement(requirement)
	// Requires a valid target - implementation depends on context
	return TRUE

/datum/scp_advanced_component/advanced_skill_system/proc/check_time_requirement(requirement)
	var/required_time = requirement["value"] // Time in world ticks
	var/current_time = world.time % 864000 // 24 hour cycle
	var/tolerance = requirement["tolerance"] || 36000 // 1 hour tolerance

	return abs(current_time - required_time) <= tolerance

/datum/scp_advanced_component/advanced_skill_system/proc/check_health_requirement(requirement)
	var/required_health = requirement["value"]
	var/comparison = requirement["comparison"] || "greater_equal"

	var/current_health = 0
	if(parent_mob && isliving(parent_mob))
		var/mob/living/L = parent_mob
		current_health = round((L.health / L.maxHealth) * 100)

	switch(comparison)
		if("greater")
			return current_health > required_health
		if("greater_equal")
			return current_health >= required_health
		if("less")
			return current_health < required_health
		if("less_equal")
			return current_health <= required_health
		if("equal")
			return current_health == required_health

	return FALSE

/datum/scp_advanced_component/advanced_skill_system/proc/check_energy_requirement(requirement)
	// Energy system integration - placeholder
	return TRUE

/datum/scp_advanced_component/advanced_skill_system/proc/is_skill_unlocked(skill_name)
	var/list/skill_data = skills[skill_name]
	var/list/unlock_requirements = skill_data["unlock_requirements"]

	for(var/requirement in unlock_requirements)
		if(!check_requirement(requirement))
			return FALSE

	return TRUE

/datum/scp_advanced_component/advanced_skill_system/proc/gain_skill_experience(skill_name, amount)
	if(!(skill_name in skills))
		return

	var/list/skill_data = skills[skill_name]
	var/adjusted_amount = amount * experience_multiplier

	skill_data["experience"] += adjusted_amount
	total_experience += adjusted_amount

	// Check for level up
	check_skill_level_up(skill_name)

/datum/scp_advanced_component/advanced_skill_system/proc/check_skill_level_up(skill_name)
	var/list/skill_data = skills[skill_name]
	var/current_level = skill_data["current_level"]
	var/current_exp = skill_data["experience"]
	var/required_exp = calculate_required_experience(current_level + 1)

	if(current_exp >= required_exp && current_level < skill_data["max_level"])
		level_up_skill(skill_name)

/datum/scp_advanced_component/advanced_skill_system/proc/calculate_required_experience(level)
	// Exponential growth formula
	return round((level * level * 10) + (level * 50))

/datum/scp_advanced_component/advanced_skill_system/proc/level_up_skill(skill_name)
	var/list/skill_data = skills[skill_name]
	var/old_level = skill_data["current_level"]
	var/new_level = old_level + 1

	skill_data["current_level"] = new_level
	skill_data["experience"] = 0 // Reset experience for next level

	// Award skill point
	skill_points++
	unspent_skill_points++

	// Trigger level up effects
	on_skill_level_up(skill_name, old_level, new_level)

	trigger_event("skill_level_up", list(
		"skill" = skill_name,
		"old_level" = old_level,
		"new_level" = new_level,
		"user" = parent_mob
	))

/datum/scp_advanced_component/advanced_skill_system/proc/on_skill_level_up(skill_name, old_level, new_level)
	// Override in SCP-specific components
	return

/datum/scp_advanced_component/advanced_skill_system/proc/get_skill_level(skill_name)
	if(!(skill_name in skills))
		return 0
	return skills[skill_name]["current_level"]

/datum/scp_advanced_component/advanced_skill_system/proc/get_total_level()
	var/total = 0
	for(var/skill_name in skills)
		total += get_skill_level(skill_name)
	return total

/datum/scp_advanced_component/advanced_skill_system/proc/calculate_experience_gain(skill_name)
	var/list/skill_data = skills[skill_name]
	var/base_exp = 10
	var/level_penalty = skill_data["current_level"] * 0.1

	return max(1, round(base_exp - level_penalty))

/datum/scp_advanced_component/advanced_skill_system/proc/process_cooldowns(event_data)
	// Cooldowns are automatically handled by time comparison
	// This is called every tick for any additional cooldown processing
	return

/datum/scp_advanced_component/advanced_skill_system/proc/on_skill_used(event_data)
	// React to other components using skills
	return

/datum/scp_advanced_component/advanced_skill_system/get_status_info()
	var/active_skills_count = 0
	for(var/skill_name in skills)
		if(can_use_skill(skill_name))
			active_skills_count++

	return "Skills: [active_skills_count]/[length(skills)] ready, Level: [get_total_level()], SP: [unspent_skill_points]"

// Advanced Containment System Component
/datum/scp_advanced_component/advanced_containment_system
	name = "Advanced Containment System"
	description = "Comprehensive containment management with protocols, security measures, and breach detection"
	version = "2.0.0"
	component_category = "containment"
	component_priority = COMPONENT_PRIORITY_HIGH

	// Containment Infrastructure
	var/list/containment_protocols = list()
	var/list/security_measures = list()
	var/list/containment_breaches = list()
	var/list/security_alerts = list()

	// Containment Metrics
	var/containment_integrity = 100
	var/max_containment_integrity = 100
	var/integrity_decay_rate = 0.1
	var/integrity_repair_rate = 0.5
	var/containment_resistance = 0
	var/max_containment_resistance = 100

	// Security Systems
	var/security_level = 1
	var/max_security_level = 5
	var/surveillance_coverage = 50
	var/access_restrictions = list()
	var/emergency_protocols = list()

	// Breach Detection
	var/breach_threshold = 10
	var/breach_detection_sensitivity = 75
	var/auto_containment_enabled = TRUE
	var/containment_response_time = 30 SECONDS

/datum/scp_advanced_component/advanced_containment_system/on_initialize()
	provided_interfaces = list("containment_system", "security_system", "breach_detection")
	required_interfaces = list("scp_identity")

	// Subscribe to events
	manager.subscribe_to_event(COMPONENT_EVENT_BREACH, src)
	manager.subscribe_to_event(COMPONENT_EVENT_CONTAIN, src)
	manager.subscribe_to_event(COMPONENT_EVENT_DAMAGE, src)

	event_handlers[COMPONENT_EVENT_BREACH] = "on_containment_breach"
	event_handlers[COMPONENT_EVENT_CONTAIN] = "on_containment_restored"
	event_handlers[COMPONENT_EVENT_DAMAGE] = "on_damage_taken"

	// Initialize default protocols
	setup_default_containment()

	return TRUE

/datum/scp_advanced_component/advanced_containment_system/proc/setup_default_containment()
	add_containment_protocol("Standard Monitoring", "Continuous observation via security cameras")
	add_containment_protocol("Personnel Screening", "Background checks for all personnel")
	add_containment_protocol("Access Control", "Keycard-based access restrictions")

	add_security_measure("Motion Detectors", "Infrared motion detection systems")
	add_security_measure("Emergency Lockdown", "Automatic facility lockdown capability")
	add_security_measure("Backup Power", "Redundant power systems for critical functions")

/datum/scp_advanced_component/advanced_containment_system/proc/add_containment_protocol(protocol_name, description)
	containment_protocols[protocol_name] = list(
		"description" = description,
		"effectiveness" = 10,
		"maintenance_cost" = 5,
		"last_updated" = world.time,
		"status" = "active"
	)

	// Improve containment integrity
	adjust_containment_integrity(5)

/datum/scp_advanced_component/advanced_containment_system/proc/remove_containment_protocol(protocol_name)
	if(protocol_name in containment_protocols)
		containment_protocols -= protocol_name
		adjust_containment_integrity(-5)
		return TRUE
	return FALSE

/datum/scp_advanced_component/advanced_containment_system/proc/add_security_measure(measure_name, description)
	security_measures[measure_name] = list(
		"description" = description,
		"effectiveness" = 15,
		"power_cost" = 10,
		"last_maintenance" = world.time,
		"status" = "operational"
	)

	// Improve security level
	if(security_level < max_security_level)
		security_level++

/datum/scp_advanced_component/advanced_containment_system/proc/remove_security_measure(measure_name)
	if(measure_name in security_measures)
		security_measures -= measure_name
		if(security_level > 1)
			security_level--
		return TRUE
	return FALSE

/datum/scp_advanced_component/advanced_containment_system/proc/adjust_containment_integrity(amount)
	containment_integrity = max(0, min(max_containment_integrity, containment_integrity + amount))

	if(containment_integrity <= breach_threshold)
		trigger_breach_alert()

/datum/scp_advanced_component/advanced_containment_system/proc/trigger_breach_alert()
	var/alert_data = list(
		"time" = world.time,
		"integrity" = containment_integrity,
		"alert_level" = "critical",
		"response_required" = TRUE
	)

	security_alerts += list(alert_data)
	trigger_event("containment_breach_alert", alert_data)

	if(auto_containment_enabled)
		addtimer(CALLBACK(src, PROC_REF(emergency_containment_response)), containment_response_time)

/datum/scp_advanced_component/advanced_containment_system/proc/emergency_containment_response()
	// Implement emergency response procedures
	security_level = max_security_level
	surveillance_coverage = 100

	trigger_event("emergency_containment_active", list("time" = world.time))

/datum/scp_advanced_component/advanced_containment_system/proc/on_containment_breach(event_data)
	// Record breach data
	var/breach_record = list(
		"time" = world.time,
		"cause" = "unknown",
		"duration" = 0,
		"damage_caused" = 0,
		"personnel_affected" = 0
	)

	containment_breaches += list(breach_record)

	// Reduce containment integrity
	adjust_containment_integrity(-20)

/datum/scp_advanced_component/advanced_containment_system/proc/on_containment_restored(event_data)
	// Begin integrity restoration
	addtimer(CALLBACK(src, PROC_REF(restore_containment_integrity)), 0)

/datum/scp_advanced_component/advanced_containment_system/proc/restore_containment_integrity()
	if(QDELETED(src))
		return
	if(containment_integrity < max_containment_integrity)
		adjust_containment_integrity(integrity_repair_rate)
		addtimer(CALLBACK(src, PROC_REF(restore_containment_integrity)), 10 SECONDS)

/datum/scp_advanced_component/advanced_containment_system/proc/on_damage_taken(event_data)
	var/damage_amount = event_data["amount"] || 0

	// Damage to SCP may affect containment integrity
	var/integrity_loss = damage_amount * 0.1
	adjust_containment_integrity(-integrity_loss)

/datum/scp_advanced_component/advanced_containment_system/on_update()
	// Process integrity decay
	if(containment_integrity > 0)
		adjust_containment_integrity(-integrity_decay_rate)

	// Update security measures
	process_security_measures()

/datum/scp_advanced_component/advanced_containment_system/proc/process_security_measures()
	for(var/measure_name in security_measures)
		var/list/measure_data = security_measures[measure_name]

		// Check if maintenance is needed
		if(world.time > measure_data["last_maintenance"] + 3600 SECONDS) // 1 hour
			measure_data["effectiveness"] = max(0, measure_data["effectiveness"] - 1)

			if(measure_data["effectiveness"] <= 0)
				measure_data["status"] = "maintenance_required"

/datum/scp_advanced_component/advanced_containment_system/get_status_info()
	return "Containment: [containment_integrity]%, Security Level: [security_level]/[max_security_level]"

// ---------------------------------------------------------------------------
// Advanced Persistence System
// Provides save/load facilities for SCP-specific long-lived state via a simple
// key/value store scoped to the owning SCP/mob. Designed to be lightweight and
// independent so it can compile even when other subsystems are unavailable.
// ---------------------------------------------------------------------------

var/global/list/ADV_PERSIST_STORE = list()

/datum/scp_advanced_component/advanced_persistence_system
	name = "Advanced Persistence System"
	description = "Persists SCP state across sessions and important lifecycle events"
	component_category = "core"
	component_priority = COMPONENT_PRIORITY_LOW
	update_frequency = 10 SECONDS

	// Local cache of persisted data. Structure:
	// list(key => any_serializable_value)
	var/list/persisted_data

	// Optional namespace/id to distinguish multiple SCPs on the same mob
	var/persistence_namespace = "default"

/datum/scp_advanced_component/advanced_persistence_system/on_initialize()
	if(!persisted_data)
		persisted_data = list()

	// Subscribe to useful lifecycle events if available
	// We guard calls so missing broadcaster won't error
	if(manager)
		// Register with the component manager's event bus
		manager.subscribe_to_event(COMPONENT_EVENT_DEATH, src)
		manager.subscribe_to_event(COMPONENT_EVENT_REVIVE, src)
		// Map handlers for direct dispatch
		if(!event_handlers)
			event_handlers = list()
		event_handlers[COMPONENT_EVENT_DEATH] = PROC_REF(on_scp_death)
		event_handlers[COMPONENT_EVENT_REVIVE] = PROC_REF(on_scp_spawn)

	// Attempt to load any previously saved data for this SCP
	load_all_data()
	return TRUE

/datum/scp_advanced_component/advanced_persistence_system/on_update()
	// Periodic auto-save for safety
	auto_save()

/datum/scp_advanced_component/advanced_persistence_system/get_status_info()
	return "Persisted keys: [length(persisted_data) || 0]"

// Compute a stable owner id for namespacing persistence. Prefer the SCP datum
// if present on the mob, otherwise fall back to mob ckey/name.
/datum/scp_advanced_component/advanced_persistence_system/proc/get_owner_id()
	var/id = ""
	if(parent_mob)
		if(istype(parent_mob.SCP, /datum/scp))
			var/datum/scp/ctrl = parent_mob.SCP
			if(ctrl && istext(ctrl?.designation))
				id = "SCP-[ctrl.designation]"
		if(!length(id))
			id = (parent_mob.ckey) ? "ckey:[parent_mob.ckey]" : "name:[parent_mob.name]"
	return "[persistence_namespace]|[id]"

// Save a single value under a key
/datum/scp_advanced_component/advanced_persistence_system/proc/save_data(key, data)
	if(!persisted_data)
		persisted_data = list()
	persisted_data[key] = data
	return TRUE

// Load a single value by key
/datum/scp_advanced_component/advanced_persistence_system/proc/load_data(key)
	if(!persisted_data)
		return null
	return persisted_data[key]

// Clear a specific key
/datum/scp_advanced_component/advanced_persistence_system/proc/clear_data(key)
	if(!persisted_data)
		return FALSE
	persisted_data -= key
	return TRUE

// Return a shallow copy of all data
/datum/scp_advanced_component/advanced_persistence_system/proc/get_all_data()
	if(!persisted_data)
		return list()
	var/list/copy = list()
	for(var/K in persisted_data)
		copy[K] = persisted_data[K]
	return copy

// Persist the entire structure to a lightweight global store. For now we keep
// data in-memory under a global assoc keyed by owner id to avoid external deps.
// This can be swapped to SSresearch_persistence or savefiles later.
// Global map lives on the component manager to avoid polluting global namespace.
/datum/scp_advanced_component/advanced_persistence_system/proc/auto_save()
	if(!persisted_data)
		return
	ADV_PERSIST_STORE[get_owner_id()] = get_all_data()

// Load from the lightweight global store back into local cache
/datum/scp_advanced_component/advanced_persistence_system/proc/load_all_data()
	var/list/incoming = ADV_PERSIST_STORE[get_owner_id()]
	if(islist(incoming))
		persisted_data = list()
		for(var/K in incoming)
			persisted_data[K] = incoming[K]
		return TRUE
	return FALSE

// Lifecycle hooks to opportunistically save
/datum/scp_advanced_component/advanced_persistence_system/proc/on_scp_death(event_data)
	auto_save()

/datum/scp_advanced_component/advanced_persistence_system/proc/on_scp_spawn(event_data)
	load_all_data()
