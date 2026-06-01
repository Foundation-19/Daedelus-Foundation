// Enhanced Error Monitor TGUI Backend
// Provides data and actions for the error monitoring interface

/datum/error_monitor
	var/name = "Error Monitor"

/datum/error_monitor/ui_state(mob/user)
	return GLOB.admin_state

/datum/error_monitor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ErrorMonitor", name)
		ui.open()

/datum/error_monitor/ui_data(mob/user)
	var/list/data = list()

	if(!GLOB.enhanced_error_manager)
		// Provide sample data when no error manager exists
		data["error_statistics"] = list(
			"total_errors" = 3,
			"auto_recovered" = 1,
			"requires_attention" = 1,
			"categories" = list(
				"runtime" = 2,
				"scp" = 1
			),
			"severities" = list(
				"2" = 2,
				"3" = 1
			)
		)
		data["error_entries"] = list(
			list(
				"error_id" = "sample_error_1",
				"type" = "undefined var",
				"name" = "undefined var",
				"desc" = "Sample error description for testing purposes",
				"file" = "code/modules/test.dm",
				"line" = 42,
				"severity" = 2,
				"category" = "runtime",
				"timestamp" = world.time,
				"count" = 1,
				"recovery_strategy" = "retry",
				"auto_recovered" = TRUE,
				"requires_attention" = FALSE
			),
			list(
				"error_id" = "sample_error_2",
				"type" = "list index out of bounds",
				"name" = "list index out of bounds",
				"desc" = "Another sample error for testing the interface",
				"file" = "code/modules/sample.dm",
				"line" = 123,
				"severity" = 3,
				"category" = "runtime",
				"timestamp" = world.time - 100,
				"count" = 5,
				"recovery_strategy" = "fallback",
				"auto_recovered" = FALSE,
				"requires_attention" = TRUE
			)
		)
		data["auto_recovery_enabled"] = TRUE
		data["admin_notification_threshold"] = 5
		data["critical_error_threshold"] = 10
		return data

	var/datum/enhanced_error_manager/manager = GLOB.enhanced_error_manager

	// Get statistics
	data["error_statistics"] = manager.get_error_statistics()

	// Get error entries (limit to recent ones for performance)
	data["error_entries"] = list()
	var/list/entries = manager.error_entries.Copy()
	sortTim(entries, GLOBAL_PROC_REF(cmp_error_timestamps_reverse))

	var/count = 0
	for(var/entry_id in entries)
		if(count >= 100) // Limit to 100 most recent errors
			break

		var/datum/enhanced_error_entry/entry = entries[entry_id]
		data["error_entries"] += list(list(
			"error_id" = entry.error_id || "unknown",
			"type" = entry.error_type || "unknown",
			"name" = entry.error_name || entry.error_type || "unknown",
			"desc" = entry.error_desc || "No description available",
			"file" = entry.error_file || "unknown",
			"line" = entry.error_line || 0,
			"severity" = entry.error_severity || ERROR_SEVERITY_LOW,
			"category" = entry.error_category || ERROR_CATEGORY_UNKNOWN,
			"timestamp" = entry.error_timestamp || world.time,
			"count" = entry.error_count || 1,
			"recovery_strategy" = entry.error_recovery_strategy || RECOVERY_STRATEGY_NONE,
			"auto_recovered" = entry.error_auto_recovered || FALSE,
			"requires_attention" = entry.error_requires_admin_attention || FALSE
		))
		count++

	// Manager settings
	data["auto_recovery_enabled"] = manager.auto_recovery_enabled
	data["admin_notification_threshold"] = manager.admin_notification_threshold
	data["critical_error_threshold"] = manager.critical_error_threshold



	return data

/datum/error_monitor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if(!GLOB.enhanced_error_manager)
		return

	var/datum/enhanced_error_manager/manager = GLOB.enhanced_error_manager

	switch(action)
		if("toggle_auto_recovery")
			manager.auto_recovery_enabled = !manager.auto_recovery_enabled
			. = TRUE

		if("adjust_notification_threshold")
			var/direction = params["direction"]
			if(direction == "increase")
				manager.admin_notification_threshold = min(manager.admin_notification_threshold + 1, 20)
			else if(direction == "decrease")
				manager.admin_notification_threshold = max(manager.admin_notification_threshold - 1, 1)
			. = TRUE

		if("adjust_critical_threshold")
			var/direction = params["direction"]
			if(direction == "increase")
				manager.critical_error_threshold = min(manager.critical_error_threshold + 1, 50)
			else if(direction == "decrease")
				manager.critical_error_threshold = max(manager.critical_error_threshold - 1, 5)
			. = TRUE

		if("clear_error_log")
			if(alert(usr, "Are you sure you want to clear the error log? This action cannot be undone.", "Clear Error Log", "Yes", "No") == "Yes")
				manager.error_entries.Cut()
				. = TRUE

		if("export_all_data")
			var/export_data = manager.export_error_data()
			var/json_data = json_encode(export_data)
			usr << ftp(json_data, "error_data_[time2text(world.time, "YYYYMMDD_HHMMSS")].json")
			to_chat(usr, span_notice("Error data downloaded."))
			. = TRUE

		if("reset_statistics")
			if(alert(usr, "Are you sure you want to reset error statistics? This action cannot be undone.", "Reset Statistics", "Yes", "No") == "Yes")
				manager.error_entries.Cut()
				. = TRUE

		if("export_error_data")
			// Export specific error data (would need error_id from params)
			var/error_id = params["error_id"]
			if(error_id && manager.error_entries[error_id])
				var/datum/enhanced_error_entry/entry = manager.error_entries[error_id]
				var/error_data = list(
					"error_id" = entry.error_id,
					"type" = entry.error_type,
					"name" = entry.error_name,
					"desc" = entry.error_desc,
					"file" = entry.error_file,
					"line" = entry.error_line,
					"severity" = entry.error_severity,
					"category" = entry.error_category,
					"timestamp" = entry.error_timestamp,
					"count" = entry.error_count,
					"recovery_strategy" = entry.error_recovery_strategy,
					"auto_recovered" = entry.error_auto_recovered,
					"requires_attention" = entry.error_requires_admin_attention,
					"user_info" = entry.error_user_info,
					"system_state" = entry.error_system_state
				)

				var/json_data = json_encode(error_data)
				usr << ftp(json_data, "error_[error_id]_[time2text(world.time, "YYYYMMDD_HHMMSS")].json")
				to_chat(usr, span_notice("Error data downloaded."))
				. = TRUE

// Helper proc for sorting error entries by timestamp (reverse order)
/proc/cmp_error_timestamps_reverse(a, b)
	var/datum/enhanced_error_entry/entry_a = GLOB.enhanced_error_manager.error_entries[a]
	var/datum/enhanced_error_entry/entry_b = GLOB.enhanced_error_manager.error_entries[b]
	return entry_b.error_timestamp - entry_a.error_timestamp

// Admin verb to open error monitor
/client/proc/open_error_monitor()
	set name = "Error Monitor"
	set category = "Admin"
	set desc = "Open the enhanced error monitoring interface"

	if(!check_rights(R_ADMIN))
		return

	var/datum/error_monitor/monitor = new()
	monitor.ui_interact(usr)

// Add to admin verbs
GLOBAL_LIST_INIT(admin_verbs_error_monitor, list(/client/proc/open_error_monitor, /client/proc/generate_test_errors))
GLOBAL_PROTECT(admin_verbs_error_monitor)

// Test proc to generate sample errors
/client/proc/generate_test_errors()
	set name = "Generate Test Errors"
	set category = "Admin"
	set desc = "Generate sample errors for testing the error monitor"

	if(!check_rights(R_ADMIN))
		return

	if(!GLOB.enhanced_error_manager)
		to_chat(usr, span_warning("Enhanced error manager not initialized!"))
		return

	// Generate some test errors
	var/exception/E1 = new()
	E1.name = "Test Runtime Error"
	E1.desc = "This is a test runtime error for testing the error monitor interface"
	E1.file = "code/test/test_errors.dm"
	E1.line = 42
	GLOB.enhanced_error_manager.log_error(E1)

	var/exception/E2 = new()
	E2.name = "Test SCP Error"
	E2.desc = "This is a test SCP-related error for testing categorization"
	E2.file = "code/modules/SCP/test_scp.dm"
	E2.line = 123
	GLOB.enhanced_error_manager.log_error(E2)

	var/exception/E3 = new()
	E3.name = "Test TGUI Error"
	E3.desc = "This is a test TGUI error for testing recovery strategies"
	E3.file = "tgui/packages/tgui/test_tgui.dm"
	E3.line = 67
	GLOB.enhanced_error_manager.log_error(E3)

	to_chat(usr, span_notice("Generated 3 test errors. Check the Error Monitor to see them!"))
