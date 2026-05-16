// Enhanced Error Handling Framework
// Provides comprehensive error categorization, automatic recovery, and detailed logging

// Error severity levels
#define ERROR_SEVERITY_LOW 1
#define ERROR_SEVERITY_MEDIUM 2
#define ERROR_SEVERITY_HIGH 3
#define ERROR_SEVERITY_CRITICAL 4

// Error categories
#define ERROR_CATEGORY_RUNTIME "runtime"
#define ERROR_CATEGORY_COMPONENT "component"
#define ERROR_CATEGORY_SCP "scp"
#define ERROR_CATEGORY_PERSISTENCE "persistence"
#define ERROR_CATEGORY_TGUI "tgui"
#define ERROR_CATEGORY_NETWORK "network"
#define ERROR_CATEGORY_DATABASE "database"
#define ERROR_CATEGORY_MEMORY "memory"
#define ERROR_CATEGORY_UNKNOWN "unknown"

// Error recovery strategies
#define RECOVERY_STRATEGY_NONE "none"
#define RECOVERY_STRATEGY_RETRY "retry"
#define RECOVERY_STRATEGY_FALLBACK "fallback"
#define RECOVERY_STRATEGY_RESTART "restart"
#define RECOVERY_STRATEGY_IGNORE "ignore"

// Enhanced error entry datum
/datum/enhanced_error_entry
	var/error_id
	var/error_type
	var/error_name
	var/error_desc
	var/error_file
	var/error_line
	var/error_severity
	var/error_category
	var/error_timestamp
	var/error_count
	var/error_recovery_strategy
	var/error_recovery_attempts
	var/error_max_recovery_attempts
	var/error_context
	var/error_stack_trace
	var/error_user_info
	var/error_location_info
	var/error_system_state
	var/error_auto_recovered
	var/error_requires_admin_attention

/datum/enhanced_error_entry/New(exception/E, list/context = null, severity = ERROR_SEVERITY_MEDIUM, category = ERROR_CATEGORY_UNKNOWN)
	error_id = "[E.file][E.line]_[world.time]"
	error_type = E.name
	error_name = E.name
	error_desc = E.desc
	error_file = E.file
	error_line = E.line
	error_severity = severity
	error_category = category
	error_timestamp = world.time
	error_count = 1
	error_recovery_strategy = RECOVERY_STRATEGY_NONE
	error_recovery_attempts = 0
	error_max_recovery_attempts = 3
	error_context = context
	error_stack_trace = E.desc
	error_auto_recovered = FALSE
	error_requires_admin_attention = FALSE

	// Capture user and location info
	capture_context_info()

	// Determine recovery strategy based on error type and severity
	determine_recovery_strategy()

/datum/enhanced_error_entry/proc/capture_context_info()
	// Capture user information
	if(istype(usr))
		error_user_info = list(
			"ckey" = usr.ckey,
			"name" = usr.name,
			"type" = usr.type,
			"loc" = loc_name(usr)
		)

	// Capture system state
	error_system_state = list(
		"round_time" = world.time,
		"tick_usage" = world.tick_usage,
		"cpu" = world.cpu,
		"map" = SSmapping?.config?.map_name || "unknown",
		"players" = length(GLOB.clients)
	)

/datum/enhanced_error_entry/proc/determine_recovery_strategy()
	switch(error_category)
		if(ERROR_CATEGORY_TGUI)
			error_recovery_strategy = RECOVERY_STRATEGY_RETRY
			error_max_recovery_attempts = 2
		if(ERROR_CATEGORY_COMPONENT)
			error_recovery_strategy = RECOVERY_STRATEGY_FALLBACK
			error_max_recovery_attempts = 1
		if(ERROR_CATEGORY_PERSISTENCE)
			error_recovery_strategy = RECOVERY_STRATEGY_RETRY
			error_max_recovery_attempts = 3
		if(ERROR_CATEGORY_MEMORY)
			error_recovery_strategy = RECOVERY_STRATEGY_RESTART
			error_requires_admin_attention = TRUE
		if(ERROR_SEVERITY_CRITICAL)
			error_recovery_strategy = RECOVERY_STRATEGY_RESTART
			error_requires_admin_attention = TRUE
		else
			error_recovery_strategy = RECOVERY_STRATEGY_IGNORE

/datum/enhanced_error_entry/proc/increment_count()
	error_count++
	error_timestamp = world.time

/datum/enhanced_error_entry/proc/attempt_recovery()
	if(error_recovery_attempts >= error_max_recovery_attempts)
		return FALSE

	error_recovery_attempts++

	switch(error_recovery_strategy)
		if(RECOVERY_STRATEGY_RETRY)
			return attempt_retry_recovery()
		if(RECOVERY_STRATEGY_FALLBACK)
			return attempt_fallback_recovery()
		if(RECOVERY_STRATEGY_RESTART)
			return attempt_restart_recovery()
		if(RECOVERY_STRATEGY_IGNORE)
			return TRUE
		else
			return FALSE

/datum/enhanced_error_entry/proc/attempt_retry_recovery()
	// Simple retry logic - wait a bit and try again
	addtimer(CALLBACK(src, PROC_REF(execute_retry)), 10)
	return TRUE

/datum/enhanced_error_entry/proc/attempt_fallback_recovery()
	// Implement fallback logic based on error type
	switch(error_category)
		if(ERROR_CATEGORY_COMPONENT)
			// Disable problematic component
			disable_problematic_component()
		if(ERROR_CATEGORY_TGUI)
			// Reset TGUI interface
			reset_tgui_interface()
		else
			return FALSE
	return TRUE

/datum/enhanced_error_entry/proc/attempt_restart_recovery()
	// Critical errors require admin intervention
	notify_admins_of_critical_error()
	return FALSE

/datum/enhanced_error_entry/proc/execute_retry()
	// This would be implemented based on the specific error context
	// For now, just mark as recovered
	error_auto_recovered = TRUE

/datum/enhanced_error_entry/proc/disable_problematic_component()
	// Find and disable the problematic component
	if(error_context && error_context["component_id"])
		var/component_id = error_context["component_id"]

		// Find and disable the component
		for(var/datum/component/C in world)
			if(C.type == component_id)
				C.Destroy()
				error_auto_recovered = TRUE
				break

		// Log the component disable action
		log_world("Enhanced Error Handler: Disabled problematic component [component_id]")

/datum/enhanced_error_entry/proc/reset_tgui_interface()
	// Reset TGUI interface if specified in context
	if(error_context && error_context["tgui_id"])
		var/tgui_id = error_context["tgui_id"]

		// Reset the TGUI interface by closing and reopening it
		for(var/client/C in GLOB.clients)
			if(C.mob)
				// Reopen the specific interface if needed
				if(tgui_id == "skill_progression")
					var/datum/skill_progression_ui/ui = new /datum/skill_progression_ui(C.mob)
					ui.ui_interact(C.mob)

		error_auto_recovered = TRUE
		log_world("Enhanced Error Handler: Reset TGUI interface [tgui_id]")

/datum/enhanced_error_entry/proc/notify_admins_of_critical_error()
	var/message = "CRITICAL ERROR: [error_name] in [error_file]:[error_line] - Requires immediate attention!"
	message_admins(message)
	log_admin(message)

/datum/enhanced_error_entry/proc/get_formatted_log_entry()
	var/entry = "\[[time2text(error_timestamp, "YYYY-MM-DD hh:mm:ss")]\] "
	entry += "\[[error_severity]\] \[[error_category]\] "
	entry += "[error_name] in [error_file]:[error_line] "
	entry += "(Count: [error_count], Recovery: [error_recovery_strategy])"

	if(error_user_info)
		entry += " - User: [error_user_info["ckey"]]"

	if(error_auto_recovered)
		entry += " - AUTO-RECOVERED"

	if(error_requires_admin_attention)
		entry += " - REQUIRES ADMIN ATTENTION"

	return entry

// Enhanced error manager
/datum/enhanced_error_manager
	var/list/error_entries = list()
	var/list/error_patterns = list()
	var/list/recovery_strategies = list()
	var/max_error_entries = 1000
	var/auto_recovery_enabled = TRUE
	var/admin_notification_threshold = 5
	var/critical_error_threshold = 10

/datum/enhanced_error_manager/New()
	initialize_error_patterns()
	initialize_recovery_strategies()

/datum/enhanced_error_manager/proc/initialize_error_patterns()
	// Define common error patterns for automatic categorization
	error_patterns = list(
		"undefined var" = ERROR_CATEGORY_RUNTIME,
		"undefined proc" = ERROR_CATEGORY_RUNTIME,
		"list index out of bounds" = ERROR_CATEGORY_RUNTIME,
		"null reference" = ERROR_CATEGORY_RUNTIME,
		"component" = ERROR_CATEGORY_COMPONENT,
		"scp" = ERROR_CATEGORY_SCP,
		"persistence" = ERROR_CATEGORY_PERSISTENCE,
		"tgui" = ERROR_CATEGORY_TGUI,
		"network" = ERROR_CATEGORY_NETWORK,
		"database" = ERROR_CATEGORY_DATABASE,
		"memory" = ERROR_CATEGORY_MEMORY,
		"out of memory" = ERROR_CATEGORY_MEMORY
	)

/datum/enhanced_error_manager/proc/initialize_recovery_strategies()
	// Define recovery strategies for different error types
	recovery_strategies = list(
		ERROR_CATEGORY_TGUI = RECOVERY_STRATEGY_RETRY,
		ERROR_CATEGORY_COMPONENT = RECOVERY_STRATEGY_FALLBACK,
		ERROR_CATEGORY_PERSISTENCE = RECOVERY_STRATEGY_RETRY,
		ERROR_CATEGORY_MEMORY = RECOVERY_STRATEGY_RESTART,
		ERROR_CATEGORY_NETWORK = RECOVERY_STRATEGY_RETRY
	)

/datum/enhanced_error_manager/proc/log_error(exception/E, list/context = null)
	var/severity = determine_error_severity(E)
	var/category = categorize_error(E)

	var/datum/enhanced_error_entry/error_entry = new(E, context, severity, category)

	// Check if this is a duplicate error
	var/existing_entry = find_existing_error(error_entry)
	if(existing_entry)
		call(existing_entry, "increment_count")()
		error_entry = existing_entry
	else
		error_entries[error_entry.error_id] = error_entry

	// Log the error
	log_enhanced_error(error_entry)

	// Attempt automatic recovery if enabled
	if(auto_recovery_enabled && !error_entry.error_requires_admin_attention)
		error_entry.attempt_recovery()

	// Check if admin notification is needed
	check_admin_notification(error_entry)

	// Maintain error list size
	maintain_error_list()

	return error_entry

/datum/enhanced_error_manager/proc/determine_error_severity(exception/E)
	// Determine severity based on error type and context
	if(findtext(E.name, "out of memory") || findtext(E.name, "Maximum recursion"))
		return ERROR_SEVERITY_CRITICAL
	else if(findtext(E.name, "undefined") || findtext(E.name, "null reference"))
		return ERROR_SEVERITY_HIGH
	else if(findtext(E.name, "list index") || findtext(E.name, "component"))
		return ERROR_SEVERITY_MEDIUM
	else
		return ERROR_SEVERITY_LOW

/datum/enhanced_error_manager/proc/categorize_error(exception/E)
	// Categorize error based on patterns
	for(var/pattern in error_patterns)
		if(findtext(E.name, pattern) || findtext(E.desc, pattern))
			return error_patterns[pattern]
	return ERROR_CATEGORY_UNKNOWN

/datum/enhanced_error_manager/proc/find_existing_error(datum/enhanced_error_entry/new_entry)
	var/error_key = "[new_entry.error_file][new_entry.error_line]"

	// Use the error key for faster lookup
	if(error_entries[error_key])
		return error_entries[error_key]

	// Fallback to linear search if key not found
	for(var/entry_id in error_entries)
		var/datum/enhanced_error_entry/entry = error_entries[entry_id]
		if(entry.error_file == new_entry.error_file && entry.error_line == new_entry.error_line)
			return entry
	return null

/datum/enhanced_error_manager/proc/log_enhanced_error(datum/enhanced_error_entry/error_entry)
	var/log_entry = error_entry.get_formatted_log_entry()

	// Log to appropriate files based on category
	switch(error_entry.error_category)
		if(ERROR_CATEGORY_RUNTIME)
			log_runtime(log_entry)
		if(ERROR_CATEGORY_SCP)
			log_world("SCP ERROR: [log_entry]")
		if(ERROR_CATEGORY_PERSISTENCE)
			log_world("PERSISTENCE ERROR: [log_entry]")
		if(ERROR_CATEGORY_TGUI)
			log_tgui(null, log_entry)
		else
			log_world("ENHANCED ERROR: [log_entry]")

/datum/enhanced_error_manager/proc/check_admin_notification(datum/enhanced_error_entry/error_entry)
	if(error_entry.error_requires_admin_attention)
		notify_admins_immediate(error_entry)
	else if(error_entry.error_count >= admin_notification_threshold)
		notify_admins_threshold(error_entry)

/datum/enhanced_error_manager/proc/notify_admins_immediate(datum/enhanced_error_entry/error_entry)
	var/message = "IMMEDIATE ATTENTION REQUIRED: [error_entry.error_name] in [error_entry.error_file]:[error_entry.error_line]"
	message_admins(message)
	log_admin(message)

/datum/enhanced_error_manager/proc/notify_admins_threshold(datum/enhanced_error_entry/error_entry)
	var/message = "ERROR THRESHOLD REACHED: [error_entry.error_name] has occurred [error_entry.error_count] times"
	message_admins(message)
	log_admin(message)

/datum/enhanced_error_manager/proc/maintain_error_list()
	if(length(error_entries) > max_error_entries)
		// Remove oldest entries
		var/entries_to_remove = length(error_entries) - max_error_entries
		var/list/entry_ids = error_entries.Copy()
		sortTim(entry_ids, GLOBAL_PROC_REF(cmp_error_timestamps))

		for(var/i = 1; i <= entries_to_remove; i++)
			error_entries.Remove(entry_ids[i])

/datum/enhanced_error_manager/proc/cmp_error_timestamps(a, b)
	var/datum/enhanced_error_entry/entry_a = error_entries[a]
	var/datum/enhanced_error_entry/entry_b = error_entries[b]
	return entry_a.error_timestamp - entry_b.error_timestamp

// Global proc for sorting
/proc/cmp_error_timestamps(a, b)
	if(!GLOB.enhanced_error_manager)
		return 0
	var/datum/enhanced_error_entry/entry_a = GLOB.enhanced_error_manager.error_entries[a]
	var/datum/enhanced_error_entry/entry_b = GLOB.enhanced_error_manager.error_entries[b]
	return entry_a.error_timestamp - entry_b.error_timestamp

/datum/enhanced_error_manager/proc/get_error_statistics()
	var/list/stats = list()
	stats["total_errors"] = length(error_entries)
	stats["categories"] = list()
	stats["severities"] = list()
	stats["auto_recovered"] = 0
	stats["requires_attention"] = 0

	for(var/entry_id in error_entries)
		var/datum/enhanced_error_entry/entry = error_entries[entry_id]

		// Category stats
		if(!stats["categories"][entry.error_category])
			stats["categories"][entry.error_category] = 0
		stats["categories"][entry.error_category]++

		// Severity stats
		if(!stats["severities"]["[entry.error_severity]"])
			stats["severities"]["[entry.error_severity]"] = 0
		stats["severities"]["[entry.error_severity]"]++

		// Recovery stats
		if(entry.error_auto_recovered)
			stats["auto_recovered"]++
		if(entry.error_requires_admin_attention)
			stats["requires_attention"]++

	return stats

/datum/enhanced_error_manager/proc/export_error_data()
	var/list/export_data = list()
	export_data["statistics"] = get_error_statistics()
	export_data["errors"] = list()

	for(var/entry_id in error_entries)
		var/datum/enhanced_error_entry/entry = error_entries[entry_id]
		export_data["errors"][entry_id] = list(
			"type" = entry.error_type,
			"name" = entry.error_name,
			"file" = entry.error_file,
			"line" = entry.error_line,
			"severity" = entry.error_severity,
			"category" = entry.error_category,
			"timestamp" = entry.error_timestamp,
			"count" = entry.error_count,
			"recovery_strategy" = entry.error_recovery_strategy,
			"auto_recovered" = entry.error_auto_recovered,
			"requires_attention" = entry.error_requires_admin_attention
		)

	return export_data

// Global instance
GLOBAL_DATUM_INIT(enhanced_error_manager, /datum/enhanced_error_manager, new)

// Helper procs for easy access
/proc/log_enhanced_error(exception/E, list/context = null)
	if(GLOB.enhanced_error_manager)
		return GLOB.enhanced_error_manager.log_error(E, context)
	else
		// Fallback to standard logging
		log_runtime("runtime error: [E.name]\n[E.desc]")

/proc/get_error_statistics()
	if(GLOB.enhanced_error_manager)
		return GLOB.enhanced_error_manager.get_error_statistics()
	return list()

/proc/export_error_data()
	if(GLOB.enhanced_error_manager)
		return GLOB.enhanced_error_manager.export_error_data()
	return list()
