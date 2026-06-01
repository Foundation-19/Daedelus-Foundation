// Advanced Modular SCP Component System
// A comprehensive, enterprise-level component architecture for maximum flexibility
// This system allows ANY mob to become an SCP through modular components

// Component System Constants
#define COMPONENT_PRIORITY_CRITICAL    100
#define COMPONENT_PRIORITY_HIGH        75
#define COMPONENT_PRIORITY_NORMAL      50
#define COMPONENT_PRIORITY_LOW         25
#define COMPONENT_PRIORITY_BACKGROUND  10

#define COMPONENT_STATE_INACTIVE       0
#define COMPONENT_STATE_INITIALIZING   1
#define COMPONENT_STATE_ACTIVE         2
#define COMPONENT_STATE_SUSPENDED      3
#define COMPONENT_STATE_ERROR          4
#define COMPONENT_STATE_DESTROYED      5

#ifndef COMPONENT_EVENT_TICK
#define COMPONENT_EVENT_TICK           "tick"
#define COMPONENT_EVENT_ACTIVATE       "activate"
#define COMPONENT_EVENT_DEACTIVATE     "deactivate"
#define COMPONENT_EVENT_DAMAGE         "damage"
#define COMPONENT_EVENT_HEAL           "heal"
#define COMPONENT_EVENT_SKILL_USE      "skill_use"
#define COMPONENT_EVENT_BREACH         "breach"
#define COMPONENT_EVENT_CONTAIN        "contain"
#define COMPONENT_EVENT_INTERACT       "interact"
#define COMPONENT_EVENT_DEATH          "death"
#define COMPONENT_EVENT_REVIVE         "revive"
#endif

// Advanced Component Base Class
/datum/scp_advanced_component
	var/name = "Base Component"
	var/description = "A base SCP component"
	var/version = "1.0.0"
	var/author = "SCP Foundation"

	// Core component properties
	var/component_id = ""
	var/component_type = ""
	var/component_category = "core"
	var/component_state = COMPONENT_STATE_INACTIVE
	var/component_priority = COMPONENT_PRIORITY_NORMAL
	var/mob/parent_mob = null
	var/datum/component_manager_advanced/manager = null

	// Component configuration
	var/list/config = list()
	var/list/dependencies = list()
	var/list/conflicts = list()
	var/list/provided_interfaces = list()
	var/list/required_interfaces = list()

	// Component metadata
	var/creation_time = 0
	var/last_update_time = 0
	var/update_frequency = 0 // 0 = no automatic updates
	var/error_count = 0
	var/max_errors = 5

	// Event system
	var/list/event_handlers = list()
	var/list/subscribed_events = list()

	// Performance monitoring
	var/total_update_time = 0
	var/update_count = 0
	var/last_performance_check = 0

/datum/scp_advanced_component/New(mob/target_mob, component_id, datum/component_manager_advanced/comp_manager)
	src.parent_mob = target_mob
	src.component_id = component_id
	src.manager = comp_manager
	src.creation_time = world.time
	src.component_type = initial(src.type)

	// Initialize component
	if(!initialize())
		component_state = COMPONENT_STATE_ERROR
		manager?.log_error("Failed to initialize component [component_id] of type [component_type]")

/datum/scp_advanced_component/proc/initialize()
	// Override in subclasses for component-specific initialization
	component_state = COMPONENT_STATE_INITIALIZING

	// Check dependencies
	if(!check_dependencies())
		manager?.log_error("Component [component_id] dependencies not met")
		return FALSE

	// Check conflicts
	if(!check_conflicts())
		manager?.log_error("Component [component_id] has conflicts")
		return FALSE

	// Subscribe to events
	subscribe_to_events()

	// Component-specific initialization
	if(!on_initialize())
		return FALSE

	component_state = COMPONENT_STATE_ACTIVE
	return TRUE

/datum/scp_advanced_component/proc/on_initialize()
	// Override in subclasses
	return TRUE

/datum/scp_advanced_component/proc/check_dependencies()
	if(!manager)
		return FALSE

	for(var/dependency in dependencies)
		if(!manager.has_component_interface(dependency))
			manager?.log_error("Component [component_id] missing dependency: [dependency]")
			return FALSE
	return TRUE

/datum/scp_advanced_component/proc/check_conflicts()
	if(!manager)
		return FALSE

	for(var/conflict in conflicts)
		if(manager.has_component_interface(conflict))
			manager?.log_error("Component [component_id] conflicts with: [conflict]")
			return FALSE
	return TRUE

/datum/scp_advanced_component/proc/subscribe_to_events()
	// Override in subclasses to subscribe to specific events
	return

/datum/scp_advanced_component/proc/activate()
	if(component_state != COMPONENT_STATE_INACTIVE && component_state != COMPONENT_STATE_SUSPENDED)
		return FALSE

	component_state = COMPONENT_STATE_ACTIVE
	on_activate()
	trigger_event(COMPONENT_EVENT_ACTIVATE, list("component" = src))
	return TRUE

/datum/scp_advanced_component/proc/on_activate()
	// Override in subclasses
	return

/datum/scp_advanced_component/proc/deactivate()
	if(component_state != COMPONENT_STATE_ACTIVE)
		return FALSE

	component_state = COMPONENT_STATE_INACTIVE
	on_deactivate()
	trigger_event(COMPONENT_EVENT_DEACTIVATE, list("component" = src))
	return TRUE

/datum/scp_advanced_component/proc/on_deactivate()
	// Override in subclasses
	return

/datum/scp_advanced_component/proc/suspend()
	if(component_state != COMPONENT_STATE_ACTIVE)
		return FALSE

	component_state = COMPONENT_STATE_SUSPENDED
	on_suspend()
	return TRUE

/datum/scp_advanced_component/proc/on_suspend()
	// Override in subclasses
	return

/datum/scp_advanced_component/proc/resume()
	if(component_state != COMPONENT_STATE_SUSPENDED)
		return FALSE

	component_state = COMPONENT_STATE_ACTIVE
	on_resume()
	return TRUE

/datum/scp_advanced_component/proc/on_resume()
	// Override in subclasses
	return

/datum/scp_advanced_component/proc/update()
	if(component_state != COMPONENT_STATE_ACTIVE)
		return

	var/start_time = world.timeofday

	try
		on_update()
		last_update_time = world.time
		update_count++

		var/update_time = world.timeofday - start_time
		total_update_time += update_time

		// Performance monitoring
		if(world.time > last_performance_check + 300) // Every 5 minutes
			check_performance()

	catch(var/exception)
		error_count++
		manager?.log_error("Component [component_id] update error: [exception]")

		if(error_count >= max_errors)
			component_state = COMPONENT_STATE_ERROR
			manager?.disable_component(component_id)

/datum/scp_advanced_component/proc/on_update()
	// Override in subclasses for component-specific update logic
	return

/datum/scp_advanced_component/proc/check_performance()
	last_performance_check = world.time

	if(update_count > 0)
		var/avg_update_time = total_update_time / update_count
		if(avg_update_time > 10) // More than 10ms average
			manager?.log_warning("Component [component_id] performance warning: [avg_update_time]ms average")

/datum/scp_advanced_component/proc/handle_event(event_type, event_data)
	if(component_state != COMPONENT_STATE_ACTIVE)
		return

	if(event_type in event_handlers)
		var/handler_proc = event_handlers[event_type]
		if(handler_proc)
			try
				call(src, handler_proc)(event_data)
			catch(var/exception)
				error_count++
				manager?.log_error("Component [component_id] event handler error: [exception]")

/datum/scp_advanced_component/proc/trigger_event(event_type, event_data)
	if(!manager)
		return

	manager.broadcast_event(event_type, event_data, src)

/datum/scp_advanced_component/proc/get_interface(interface_name)
	if(interface_name in provided_interfaces)
		return src
	return null

/datum/scp_advanced_component/proc/get_status_info()
	var/info = "[name] v[version]"
	switch(component_state)
		if(COMPONENT_STATE_ACTIVE)
			info += " (Active)"
		if(COMPONENT_STATE_INACTIVE)
			info += " (Inactive)"
		if(COMPONENT_STATE_SUSPENDED)
			info += " (Suspended)"
		if(COMPONENT_STATE_ERROR)
			info += " (Error)"

	if(error_count > 0)
		info += " - [error_count] errors"

	return info

/datum/scp_advanced_component/proc/get_config(key, default_value = null)
	return config[key] || default_value

/datum/scp_advanced_component/proc/set_config(key, value)
	config[key] = value
	on_config_changed(key, value)

/datum/scp_advanced_component/proc/on_config_changed(key, value)
	// Override in subclasses to react to configuration changes
	return

/datum/scp_advanced_component/proc/cleanup()
	// Override in subclasses for component-specific cleanup
	return

/datum/scp_advanced_component/Destroy()
	cleanup()
	component_state = COMPONENT_STATE_DESTROYED

	// Unsubscribe from events
	if(manager)
		for(var/event in subscribed_events)
			manager.unsubscribe_from_event(event, src)

	parent_mob = null
	manager = null
	return ..()

// Advanced Component Manager
/datum/component_manager_advanced
	var/mob/parent_mob = null
	var/list/components = list() // component_id -> component
	var/list/components_by_type = list() // component_type -> list of components
	var/list/components_by_category = list() // category -> list of components
	var/list/components_by_priority = list() // priority -> list of components
	var/list/component_interfaces = list() // interface_name -> component
	var/list/event_subscribers = list() // event_type -> list of components
	var/list/pending_events = list()

	// Manager configuration
	var/max_components = 50
	var/update_frequency = 1 SECOND
	var/last_update = 0
	var/log_level = 1 // 0=none, 1=errors, 2=warnings, 3=info, 4=debug

	// Performance monitoring
	var/total_update_time = 0
	var/update_cycles = 0
	var/performance_threshold = 50 // milliseconds

	// Error handling
	var/list/error_log = list()
	var/max_log_entries = 100

/datum/component_manager_advanced/New(mob/target_mob)
	parent_mob = target_mob
	parent_mob.vars["advanced_component_manager"] = src
	last_update = world.time
	effect_manager = new /datum/scp_component_effect_manager()
	communicator = new /datum/scp_component_communicator()
	database = new /datum/scp_component_database()
	if(target_mob && target_mob.SCP)
		persistence_key = "scp_[target_mob.SCP.designation]"

/datum/component_manager_advanced/proc/add_component(component_type, component_id, list/component_config = list())
	if(component_id in components)
		log_warning("Component [component_id] already exists")
		return components[component_id]

	if(length(components) >= max_components)
		log_error("Maximum components reached ([max_components])")
		return null

	// Create component instance
	var/datum/scp_advanced_component/component = new component_type(parent_mob, component_id, src)
	if(!component)
		log_error("Failed to create component [component_id] of type [component_type]")
		return null

	// Apply configuration
	for(var/key in component_config)
		component.set_config(key, component_config[key])

	// Register component
	components[component_id] = component

	// Index by type
	var/type_key = "[component_type]"
	if(!(type_key in components_by_type))
		components_by_type[type_key] = list()
	components_by_type[type_key] += component

	// Index by category
	if(!(component.component_category in components_by_category))
		components_by_category[component.component_category] = list()
	components_by_category[component.component_category] += component

	// Index by priority
	var/priority = component.component_priority
	if(!(priority in components_by_priority))
		components_by_priority[priority] = list()
	components_by_priority[priority] += component

	// Register interfaces
	for(var/interface in component.provided_interfaces)
		component_interfaces[interface] = component

	// Activate component
	component.activate()

	log_info("Added component [component_id] of type [component_type]")
	return component

/datum/component_manager_advanced/proc/remove_component(component_id)
	if(!(component_id in components))
		log_warning("Component [component_id] not found")
		return FALSE

	var/datum/scp_advanced_component/component = components[component_id]

	// Deactivate component
	component.deactivate()

	// Unregister from indexes
	var/type_key = "[component.component_type]"
	if(type_key in components_by_type)
		components_by_type[type_key] -= component
		if(!length(components_by_type[type_key]))
			components_by_type -= type_key

	if(component.component_category in components_by_category)
		components_by_category[component.component_category] -= component
		if(!length(components_by_category[component.component_category]))
			components_by_category -= component.component_category

	var/priority = component.component_priority
	if(priority in components_by_priority)
		components_by_priority[priority] -= component
		if(!length(components_by_priority[priority]))
			components_by_priority -= priority

	// Unregister interfaces
	for(var/interface in component.provided_interfaces)
		if(component_interfaces[interface] == component)
			component_interfaces -= interface

	// Remove from main registry
	components -= component_id

	// Destroy component
	qdel(component)

	log_info("Removed component [component_id]")
	return TRUE

/datum/component_manager_advanced/proc/get_component(component_id)
	return components[component_id]

/datum/component_manager_advanced/proc/get_components_by_type(component_type)
	var/type_key = "[component_type]"
	return components_by_type[type_key] || list()

/datum/component_manager_advanced/proc/get_components_by_category(category)
	return components_by_category[category] || list()

/datum/component_manager_advanced/proc/get_component_by_interface(interface_name)
	return component_interfaces[interface_name]

/datum/component_manager_advanced/proc/has_component_interface(interface_name)
	return (interface_name in component_interfaces)

/datum/component_manager_advanced/proc/disable_component(component_id)
	var/datum/scp_advanced_component/component = get_component(component_id)
	if(component)
		component.deactivate()
		log_warning("Disabled component [component_id] due to errors")

/datum/component_manager_advanced/proc/enable_component(component_id)
	var/datum/scp_advanced_component/component = get_component(component_id)
	if(component)
		component.activate()
		log_info("Enabled component [component_id]")

/datum/component_manager_advanced/proc/suspend_component(component_id)
	var/datum/scp_advanced_component/component = get_component(component_id)
	if(component)
		component.suspend()
		log_info("Suspended component [component_id]")

/datum/component_manager_advanced/proc/resume_component(component_id)
	var/datum/scp_advanced_component/component = get_component(component_id)
	if(component)
		component.resume()
		log_info("Resumed component [component_id]")

/datum/component_manager_advanced/proc/update_components()
	if(world.time < last_update + update_frequency)
		return

	var/start_time = world.timeofday
	last_update = world.time

	// Update components by priority (highest first)
	var/list/priorities = list()
	for(var/priority in components_by_priority)
		priorities += priority

	// Sort priorities in descending order
	priorities = sortTim(priorities, /proc/cmp_numeric_dsc)

	for(var/priority in priorities)
		var/list/priority_components = components_by_priority[priority]
		for(var/datum/scp_advanced_component/component in priority_components)
			if(component.component_state == COMPONENT_STATE_ACTIVE)
				component.update()

	// Process pending events
	process_pending_events()

	var/update_time = world.timeofday - start_time
	total_update_time += update_time
	update_cycles++

	// Performance monitoring
	if(update_time > performance_threshold)
		log_warning("Component update cycle took [update_time]ms (threshold: [performance_threshold]ms)")

/datum/component_manager_advanced/proc/broadcast_event(event_type, event_data, source_component = null)
	if(!(event_type in event_subscribers))
		return

	var/list/subscribers = event_subscribers[event_type]
	for(var/datum/scp_advanced_component/component in subscribers)
		if(component != source_component && component.component_state == COMPONENT_STATE_ACTIVE)
			// Queue event for processing
			pending_events += list(list("component" = component, "event_type" = event_type, "event_data" = event_data))

/datum/component_manager_advanced/proc/subscribe_to_event(event_type, datum/scp_advanced_component/component)
	if(!(event_type in event_subscribers))
		event_subscribers[event_type] = list()

	if(!(component in event_subscribers[event_type]))
		event_subscribers[event_type] += component
		component.subscribed_events += event_type

/datum/component_manager_advanced/proc/unsubscribe_from_event(event_type, datum/scp_advanced_component/component)
	if(event_type in event_subscribers)
		event_subscribers[event_type] -= component
		if(!length(event_subscribers[event_type]))
			event_subscribers -= event_type

	component.subscribed_events -= event_type

/datum/component_manager_advanced/proc/process_pending_events()
	var/processed = 0
	var/max_events_per_cycle = 10 // Prevent event processing from taking too long

	while(length(pending_events) && processed < max_events_per_cycle)
		var/list/event_data = pending_events[1]
		pending_events.Cut(1, 2)

		var/datum/scp_advanced_component/component = event_data["component"]
		var/event_type = event_data["event_type"]
		var/data = event_data["event_data"]

		if(component && component.component_state == COMPONENT_STATE_ACTIVE)
			component.handle_event(event_type, data)

		processed++

/datum/component_manager_advanced/proc/get_status_info()
	var/list/status_lines = list()
	status_lines += "Component Manager: [length(components)] components"

	for(var/component_id in components)
		var/datum/scp_advanced_component/component = components[component_id]
		status_lines += "[component_id]: [component.get_status_info()]"

	if(length(pending_events) > 0)
		status_lines += "Pending Events: [length(pending_events)]"

	return status_lines

/datum/component_manager_advanced/proc/get_performance_stats()
	var/list/stats = list()
	stats += "Update Cycles: [update_cycles]"

	if(update_cycles > 0)
		var/avg_time = total_update_time / update_cycles
		stats += "Average Update Time: [avg_time]ms"

	stats += "Active Components: [length(components)]"
	stats += "Event Subscribers: [length(event_subscribers)]"
	stats += "Pending Events: [length(pending_events)]"

	return stats

// Logging system
/datum/component_manager_advanced/proc/log_error(message)
	if(log_level >= 1)
		add_to_log("ERROR", message)

/datum/component_manager_advanced/proc/log_warning(message)
	if(log_level >= 2)
		add_to_log("WARNING", message)

/datum/component_manager_advanced/proc/log_info(message)
	if(log_level >= 3)
		add_to_log("INFO", message)

/datum/component_manager_advanced/proc/log_debug(message)
	if(log_level >= 4)
		add_to_log("DEBUG", message)

/datum/component_manager_advanced/proc/add_to_log(level, message)
	var/timestamp = time2text(world.time, "YYYY-MM-DD hh:mm:ss")
	var/log_entry = "\[[timestamp]\] \[[level]\] [message]"

	error_log += log_entry

	// Maintain log size
	if(length(error_log) > max_log_entries)
		error_log.Cut(1, length(error_log) - max_log_entries + 1)

	// Also output to world log for debugging
	if(log_level >= 4)
		log_game(log_entry)

/datum/component_manager_advanced/proc/get_log_entries(count = 10)
	var/start_index = max(1, length(error_log) - count + 1)
	return error_log.Copy(start_index)

/datum/component_manager_advanced/Destroy()
	// Destroy all components
	for(var/component_id in components)
		var/datum/scp_advanced_component/component = components[component_id]
		qdel(component)

	components.Cut()
	components_by_type.Cut()
	components_by_category.Cut()
	components_by_priority.Cut()
	component_interfaces.Cut()
	event_subscribers.Cut()
	pending_events.Cut()
	error_log.Cut()

	parent_mob = null
	return ..()

// Helper proc for sorting numbers in descending order
// Removed duplicate function - already defined in __HELPERS/cmp.dm
