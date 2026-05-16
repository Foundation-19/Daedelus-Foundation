// SCP Component Persistence System
// Advanced persistence and data management for SCP components

// Component Data Serializer
/datum/scp_component_serializer
	var/name = "Component Serializer"
	var/version = "1.0.0"
	var/list/serializable_types = list()
	var/compression_enabled = TRUE
	var/encryption_enabled = FALSE

/datum/scp_component_serializer/New()
	. = ..()
	// Register serializable component types
	register_serializable_types()

/datum/scp_component_serializer/proc/register_serializable_types()
	serializable_types = list(
		"scp_identity",
		"advanced_skill_system",
		"advanced_containment_system"
	)

/datum/scp_component_serializer/proc/serialize_component(datum/scp_advanced_component/component)
	if(!component)
		return null

	var/list/serialized_data = list()
	serialized_data["component_id"] = component.component_id
	serialized_data["component_type"] = component.component_type
	serialized_data["component_category"] = component.component_category
	serialized_data["component_state"] = component.component_state
	serialized_data["component_priority"] = component.component_priority
	serialized_data["config"] = component.config
	serialized_data["version"] = component.version
	serialized_data["timestamp"] = world.time

	// Serialize component-specific data
	var/specific_data = component.get_persistence_data()
	if(specific_data)
		serialized_data["specific_data"] = specific_data

	// Apply compression if enabled
	if(compression_enabled)
		serialized_data = compress_data(serialized_data)

	return serialized_data

/datum/scp_component_serializer/proc/deserialize_component(list/serialized_data, datum/component_manager_advanced/manager)
	if(!serialized_data || !manager)
		return null

	// Decompress data if needed
	if(compression_enabled && serialized_data["compressed"])
		serialized_data = decompress_data(serialized_data)

	var/component_type = serialized_data["component_type"]
	if(!(component_type in serializable_types))
		return null

	// Create component instance
	var/datum/scp_advanced_component/component = create_component_instance(component_type, manager)
	if(!component)
		return null

	// Restore component properties
	component.component_id = serialized_data["component_id"]
	component.component_state = serialized_data["component_state"]
	component.component_priority = serialized_data["component_priority"]
	component.config = serialized_data["config"]

	// Restore component-specific data
	if(serialized_data["specific_data"])
		component.set_persistence_data(serialized_data["specific_data"])

	return component

/datum/scp_component_serializer/proc/create_component_instance(component_type, datum/component_manager_advanced/manager)
	switch(component_type)
		if("scp_identity")
			return new /datum/scp_advanced_component/scp_identity(manager.parent_mob, manager)
		if("advanced_skill_system")
			return new /datum/scp_advanced_component/advanced_skill_system(manager.parent_mob, manager)
		if("advanced_containment_system")
			return new /datum/scp_advanced_component/advanced_containment_system(manager.parent_mob, manager)
		// Advanced persistence system component would be defined elsewhere

	return null

/datum/scp_component_serializer/proc/compress_data(list/data)
	// Implement data compression
	var/list/compressed = list()
	compressed["compressed"] = TRUE
	compressed["data"] = data
	return compressed

/datum/scp_component_serializer/proc/decompress_data(list/compressed_data)
	// Implement data decompression
	if(compressed_data["compressed"])
		return compressed_data["data"]
	return compressed_data

// Component Persistence Database
/datum/scp_component_database
	var/name = "Component Database"
	var/list/stored_components = list()
	var/list/component_history = list()
	var/max_history_entries = 1000
	var/auto_save_enabled = TRUE
	var/auto_save_interval = 300 SECONDS
	var/last_auto_save = 0
	var/datum/scp_component_serializer/serializer = null

/datum/scp_component_database/New()
	. = ..()
	serializer = new /datum/scp_component_serializer()

/datum/scp_component_database/proc/store_component(datum/scp_advanced_component/component, key)
	if(!component || !key)
		return FALSE

	var/serialized_data = serializer.serialize_component(component)
	if(!serialized_data)
		return FALSE

	stored_components[key] = serialized_data
	log_database_event("COMPONENT_STORED", key, component.component_type)
	return TRUE

/datum/scp_component_database/proc/retrieve_component(key, datum/component_manager_advanced/manager)
	if(!key || !(key in stored_components))
		return null

	var/serialized_data = stored_components[key]
	var/datum/scp_advanced_component/component = serializer.deserialize_component(serialized_data, manager)

	if(component)
		log_database_event("COMPONENT_RETRIEVED", key, component.component_type)

	return component

/datum/scp_component_database/proc/delete_component(key)
	if(!key || !(key in stored_components))
		return FALSE

	stored_components -= key
	log_database_event("COMPONENT_DELETED", key, "unknown")
	return TRUE

/datum/scp_component_database/proc/store_manager_state(datum/component_manager_advanced/manager, key)
	if(!manager || !key)
		return FALSE

	var/list/manager_data = list()
	manager_data["components"] = list()
	manager_data["metadata"] = list(
		"timestamp" = world.time,
		"mob_type" = manager.parent_mob?.type,
		"component_count" = length(manager.components)
	)

	// Serialize all components
	for(var/datum/scp_advanced_component/component in manager.components)
		var/serialized_component = serializer.serialize_component(component)
		if(serialized_component)
			manager_data["components"] += list(serialized_component)

	stored_components[key] = manager_data
	log_database_event("MANAGER_STORED", key, "component_manager")
	return TRUE

/datum/scp_component_database/proc/restore_manager_state(key, datum/component_manager_advanced/manager)
	if(!key || !(key in stored_components) || !manager)
		return FALSE

	var/list/manager_data = stored_components[key]
	if(!manager_data || !manager_data["components"])
		return FALSE

	// Clear existing components
	manager.clear_all_components()

	// Restore components
	for(var/list/component_data in manager_data["components"])
		var/datum/scp_advanced_component/component = serializer.deserialize_component(component_data, manager)
		if(component)
			manager.add_component(component)

	log_database_event("MANAGER_RESTORED", key, "component_manager")
	return TRUE

/datum/scp_component_database/proc/auto_save_check()
	if(!auto_save_enabled)
		return

	if(world.time >= last_auto_save + auto_save_interval)
		perform_auto_save()

/datum/scp_component_database/proc/perform_auto_save()
	last_auto_save = world.time

	// Save all active SCP component managers
	for(var/mob/M in GLOB.mob_list)
		if(QDELETED(M))
			continue
		if(M.SCP && M.SCP.uses_advanced_components)
			var/key = "autosave_[M.SCP.designation]_[world.time]"
			store_manager_state(M.SCP.advanced_components, key)

	log_database_event("AUTO_SAVE", "system", "auto_save")

/datum/scp_component_database/proc/get_storage_stats()
	var/list/stats = list()
	stats["total_entries"] = length(stored_components)
	stats["history_entries"] = length(component_history)
	stats["last_auto_save"] = last_auto_save
	stats["auto_save_enabled"] = auto_save_enabled
	return stats

/datum/scp_component_database/proc/log_database_event(event_type, key, component_type)
	var/log_entry = list(
		"timestamp" = world.time,
		"event" = event_type,
		"key" = key,
		"component_type" = component_type
	)

	component_history += list(log_entry)

	// Maintain history size
	if(length(component_history) > max_history_entries)
		component_history.Cut(1, length(component_history) - max_history_entries + 1)

// Enhanced Component with Persistence Support
/datum/scp_advanced_component
	var/persistence_enabled = TRUE
	var/last_persistence_save = 0
	var/persistence_interval = 60 SECONDS

/datum/scp_advanced_component/proc/get_persistence_data()
	// Override in specific components to provide custom persistence data
	var/list/data = list()
	data["basic_properties"] = list(
		"component_state" = component_state,
		"component_priority" = component_priority,
		"config" = config
	)
	return data

/datum/scp_advanced_component/proc/set_persistence_data(list/data)
	// Override in specific components to restore from persistence data
	if(data["basic_properties"])
		var/list/props = data["basic_properties"]
		component_state = props["component_state"]
		component_priority = props["component_priority"]
		config = props["config"]

/datum/scp_advanced_component/proc/should_save_persistence()
	if(!persistence_enabled)
		return FALSE

	return world.time >= last_persistence_save + persistence_interval

/datum/scp_advanced_component/proc/save_persistence_data()
	if(!should_save_persistence() || !manager || !manager.database)
		return FALSE

	last_persistence_save = world.time
	var/key = "component_[component_id]_[world.time]"
	return manager.database.store_component(src, key)

// Enhanced Component Manager with Persistence
/datum/component_manager_advanced
	var/datum/scp_component_database/database = null
	var/persistence_key = ""

/datum/component_manager_advanced/New(mob/target)
	. = ..()
	database = new /datum/scp_component_database()

	if(target && target.SCP)
		persistence_key = "scp_[target.SCP.designation]"

/datum/component_manager_advanced/proc/save_state()
	if(!database)
		return FALSE

	return database.store_manager_state(src, persistence_key)

/datum/component_manager_advanced/proc/restore_state()
	if(!database)
		return FALSE

	return database.restore_manager_state(persistence_key, src)

/datum/component_manager_advanced/proc/clear_all_components()
	for(var/datum/scp_advanced_component/component in components)
		component.on_deactivate()
	components = list()

/datum/component_manager_advanced/proc/process_persistence()
	if(database)
		database.auto_save_check()

	// Process component persistence
	for(var/datum/scp_advanced_component/component in components)
		if(component.should_save_persistence())
			component.save_persistence_data()

// Global Component Database Instance
var/global/datum/scp_component_database/GLOB_COMPONENT_DB = new /datum/scp_component_database()

// Enhanced Skill System Component with Persistence
/datum/scp_advanced_component/advanced_skill_system
	persistence_enabled = TRUE

/datum/scp_advanced_component/advanced_skill_system/get_persistence_data()
	var/list/data = ..()
	data["skills"] = skills
	data["skill_cooldowns"] = skill_cooldowns
	return data

/datum/scp_advanced_component/advanced_skill_system/set_persistence_data(list/data)
	..()
	if(data["skills"])
		skills = data["skills"]
	if(data["skill_cooldowns"])
		skill_cooldowns = data["skill_cooldowns"]

// Enhanced Containment System Component with Persistence
/datum/scp_advanced_component/advanced_containment_system
	persistence_enabled = TRUE

/datum/scp_advanced_component/advanced_containment_system/get_persistence_data()
	var/list/data = ..()
	data["containment_integrity"] = containment_integrity
	data["security_level"] = security_level
	data["containment_protocols"] = containment_protocols
	data["security_measures"] = security_measures
	return data

/datum/scp_advanced_component/advanced_containment_system/set_persistence_data(list/data)
	..()
	if(data["containment_integrity"])
		containment_integrity = data["containment_integrity"]
	if(data["security_level"])
		security_level = data["security_level"]
	if(data["containment_protocols"])
		containment_protocols = data["containment_protocols"]
	if(data["security_measures"])
		security_measures = data["security_measures"]
