// Advanced Component System Extensions for SCP Datum
// This file extends the existing SCP datum without overwriting any original functionality

// Additional variables for advanced component system (added as extensions)
/datum/scp
	// Advanced Component System Integration (NEW - non-overwriting additions)
	/// Advanced component manager for modular SCP functionality
	var/datum/component_manager_advanced/advanced_components
	/// Whether this SCP uses the advanced component system
	var/uses_advanced_components = FALSE
	/// List of component types to initialize for this SCP
	var/list/component_types = list()
	/// Component configuration data
	var/list/component_configs = list()

// Extended compInit to support advanced components
/datum/scp/proc/compInit_advanced()
	// Call original compInit first (if it exists)
	compInit()

	// Initialize advanced component system if enabled
	if(uses_advanced_components && ismob(parent))
		initialize_advanced_components()

/// Initialize the advanced component system for this SCP
/datum/scp/proc/initialize_advanced_components()
	if(!ismob(parent))
		return

	var/mob/mob_parent = parent

	// Create advanced component manager
	advanced_components = new /datum/component_manager_advanced(mob_parent)

	// Add core components
	advanced_components.add_component(/datum/scp_advanced_component/scp_identity, "scp_identity", list(
		"designation" = designation,
		"class" = classification,
		"name" = name
	))

	advanced_components.add_component(/datum/scp_advanced_component/advanced_skill_system, "skill_system")
	advanced_components.add_component(/datum/scp_advanced_component/advanced_containment_system, "containment_system")
	advanced_components.add_component(/datum/scp_advanced_component/advanced_persistence_system, "persistence_system")

	// Add enhancement components
	advanced_components.add_component(/datum/scp_advanced_component/skill_progression_tracker, "progression_tracker")
	advanced_components.add_component(/datum/scp_advanced_component/performance_optimizer, "performance_optimizer")
	advanced_components.add_component(/datum/scp_advanced_component/communication_hub, "communication_hub")

	// Add SCP-specific components based on designation
	add_scp_specific_components()

	// Add custom components from component_types list
	for(var/component_type in component_types)
		var/list/config = component_configs[component_type] || list()
		advanced_components.add_component(component_type, "[component_type]", config)

/// Add SCP-specific components based on designation
/datum/scp/proc/add_scp_specific_components()
	switch(designation)
		if("049")
			advanced_components.add_component(/datum/scp_advanced_component/scp_049_plague_doctor, "plague_doctor")
		if("096")
			advanced_components.add_component(/datum/scp_advanced_component/scp_096_shy_guy, "shy_guy")
		if("106")
			advanced_components.add_component(/datum/scp_advanced_component/scp_106_old_man, "old_man")
		if("173")
			advanced_components.add_component(/datum/scp_advanced_component/scp_173_sculpture, "sculpture")
		if("457")
			advanced_components.add_component(/datum/scp_advanced_component/scp_457_burning_man, "burning_man")
		if("999")
			advanced_components.add_component(/datum/scp_advanced_component/scp_999_tickle_monster, "tickle_monster")
		if("343")
			advanced_components.add_component(/datum/scp_advanced_component/scp_343_god, "god")
		if("082")
			advanced_components.add_component(/datum/scp_advanced_component/scp_082_cannibal, "cannibal")
		if("939")
			advanced_components.add_component(/datum/scp_advanced_component/scp_939_voice_mimic, "voice_mimic")
		if("966")
			advanced_components.add_component(/datum/scp_advanced_component/scp_966_sleep_killer, "sleep_killer")
		if("131")
			advanced_components.add_component(/datum/scp_advanced_component/scp_131_eye_pods, "eye_pods")
		if("3349")
			advanced_components.add_component(/datum/scp_advanced_component/scp_3349_rainbow_serpent, "rainbow_serpent")
		if("5295")
			advanced_components.add_component(/datum/scp_advanced_component/scp_5295_half_cat, "half_cat")

/// Get a component by interface name
/datum/scp/proc/get_component_interface(interface_name)
	if(!advanced_components)
		return null
	return advanced_components.get_component_by_interface(interface_name)

/// Get a component by component ID
/datum/scp/proc/get_component(component_id)
	if(!advanced_components)
		return null
	return advanced_components.get_component(component_id)

/// Add a custom component to this SCP
/datum/scp/proc/add_component(component_type, component_id, list/config = list())
	if(!advanced_components)
		return null
	return advanced_components.add_component(component_type, component_id, config)

/// Remove a component from this SCP
/datum/scp/proc/remove_component(component_id)
	if(!advanced_components)
		return FALSE
	return advanced_components.remove_component(component_id)

/// Trigger an event across all components
/datum/scp/proc/trigger_component_event(event_type, event_data)
	if(!advanced_components)
		return
	advanced_components.broadcast_event(event_type, event_data)

/// Get status information from all components
/datum/scp/proc/get_component_status()
	if(!advanced_components)
		return list()
	return advanced_components.get_status_info()

/// Update all components (called during Life() cycle)
/datum/scp/proc/update_components()
	if(!advanced_components)
		return
	advanced_components.update_components()

/// Enable advanced component system for this SCP
/datum/scp/proc/enable_advanced_components()
	uses_advanced_components = TRUE
	if(parent && ismob(parent))
		initialize_advanced_components()

/// Disable advanced component system for this SCP
/datum/scp/proc/disable_advanced_components()
	uses_advanced_components = FALSE
	if(advanced_components)
		qdel(advanced_components)
		advanced_components = null

// Extended OnExamine to add component status (non-overwriting)
/datum/scp/proc/OnExamine_advanced(datum/source, mob/user, list/examine_list)
	// Add component status information if using advanced components
	if(uses_advanced_components && advanced_components)
		var/list/component_status = get_component_status()
		for(var/status_line in component_status)
			examine_list += span_notice("[status_line]")

// Extended log_breach to trigger component events (non-overwriting)
/datum/scp/proc/log_breach_advanced()
	// Trigger component event if using advanced components
	if(uses_advanced_components)
		trigger_component_event(COMPONENT_EVENT_BREACH, list("scp" = parent, "time" = world.time))

/// Legacy compatibility: Convert existing SCP to use advanced component system
/datum/scp/proc/convert_to_advanced_system()
	if(uses_advanced_components)
		return // Already converted

	enable_advanced_components()

	// Migrate existing data to components
	var/datum/scp_advanced_component/scp_identity/identity = get_component_interface("scp_identity")
	if(identity)
		identity.set_designation(designation, classification, name)

	// Log conversion
	log_admin("SCP-[designation] converted to advanced component system")

/// Legacy compatibility: Convert back to basic system
/datum/scp/proc/convert_to_basic_system()
	if(!uses_advanced_components)
		return // Already basic

	disable_advanced_components()

	// Log conversion
	log_admin("SCP-[designation] converted back to basic system")
