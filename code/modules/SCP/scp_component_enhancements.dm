// Advanced Component Enhancement Features
// Adds enhanced tracking, analytics, and optimization features to the component system

// Enhanced Skill Progression Tracker Component
/datum/scp_advanced_component/skill_progression_tracker
	name = "Skill Progression Tracker"
	description = "Advanced tracking and analytics for skill progression patterns"
	version = "1.0.0"
	component_category = "analytics"
	component_priority = COMPONENT_PRIORITY_NORMAL

	// Tracking Data
	var/list/skill_usage_history = list()     // skill_name -> list of usage timestamps
	var/list/skill_progression_milestones = list()  // major progression events
	var/list/daily_skill_stats = list()       // daily aggregated statistics
	var/list/skill_efficiency_ratings = list() // calculated efficiency scores
	var/total_skill_usage_count = 0
	var/session_start_time = 0
	var/last_analytics_update = 0

	// Configuration
	var/max_history_entries = 1000
	var/analytics_update_interval = 300 SECONDS // 5 minutes
	var/efficiency_calculation_window = 1800 SECONDS // 30 minutes

	provided_interfaces = list("progression_tracker", "skill_analytics", "performance_metrics")
	required_interfaces = list("skill_system")

/datum/scp_advanced_component/skill_progression_tracker/on_initialize()
	. = ..()
	session_start_time = world.time
	last_analytics_update = world.time

	// Subscribe to skill system events
	manager.subscribe_to_event(COMPONENT_EVENT_SKILL_USE, src, "on_skill_used")
	manager.subscribe_to_event("skill_level_up", src, "on_skill_level_up")

/datum/scp_advanced_component/skill_progression_tracker/on_update()
	. = ..()

	// Update analytics periodically
	if(world.time - last_analytics_update >= analytics_update_interval)
		update_skill_analytics()
		last_analytics_update = world.time

/datum/scp_advanced_component/skill_progression_tracker/proc/on_skill_used(event_data)
	var/skill_name = event_data["skill_name"]
	var/success = event_data["success"]

	// Track usage
	total_skill_usage_count++

	// Initialize tracking lists if needed
	if(!(skill_name in skill_usage_history))
		skill_usage_history[skill_name] = list()
		skill_efficiency_ratings[skill_name] = list()

	// Add usage record
	var/list/usage_record = list(
		"timestamp" = world.time,
		"success" = success,
		"session_time" = world.time - session_start_time
	)

	skill_usage_history[skill_name] += list(usage_record)

	// Maintain history size limit
	if(length(skill_usage_history[skill_name]) > max_history_entries)
		var/list/L = skill_usage_history[skill_name]
		L.Cut(1, 2)

	// Update efficiency if enough data
	update_skill_efficiency(skill_name)

/datum/scp_advanced_component/skill_progression_tracker/proc/on_skill_level_up(event_data)
	var/skill_name = event_data["skill"]
	var/old_level = event_data["old_level"]
	var/new_level = event_data["new_level"]

	// Record milestone
	var/list/milestone = list(
		"timestamp" = world.time,
		"skill" = skill_name,
		"old_level" = old_level,
		"new_level" = new_level,
		"session_time" = world.time - session_start_time,
		"total_usage" = total_skill_usage_count
	)

	skill_progression_milestones += list(milestone)

	// Notify parent mob
	if(parent_mob)
		to_chat(parent_mob, "<span class='boldnotice'>SKILL MILESTONE: [skill_name] advanced to level [new_level]! Session time: [round((world.time - session_start_time)/600, 0.1)] minutes</span>")

/datum/scp_advanced_component/skill_progression_tracker/proc/update_skill_efficiency(skill_name)
	if(!(skill_name in skill_usage_history))
		return

	var/list/recent_usage = list()
	var/cutoff_time = world.time - efficiency_calculation_window

	// Get recent usage data
	for(var/list/usage_record in skill_usage_history[skill_name])
		if(usage_record["timestamp"] >= cutoff_time)
			recent_usage += list(usage_record)

	if(length(recent_usage) < 3)
		return // Need at least 3 uses for meaningful efficiency calculation

	// Calculate success rate
	var/success_count = 0
	for(var/list/usage_record in recent_usage)
		if(usage_record["success"])
			success_count++

	var/success_rate = success_count / length(recent_usage)

	// Calculate usage frequency (uses per minute)
	var/time_span = recent_usage[length(recent_usage)]["timestamp"] - recent_usage[1]["timestamp"]
	var/usage_frequency = length(recent_usage) / max(1, time_span / 600) // per minute

	// Combined efficiency score (0-100)
	var/efficiency_score = round((success_rate * 70) + (min(usage_frequency, 2) / 2 * 30))

	skill_efficiency_ratings[skill_name] = efficiency_score

/datum/scp_advanced_component/skill_progression_tracker/proc/update_skill_analytics()
	var/current_day = round(world.time / 864000) // Days since world start

	if(!(current_day in daily_skill_stats))
		daily_skill_stats[current_day] = list()

	// Calculate daily stats
	var/list/today_stats = daily_skill_stats[current_day]
	today_stats["total_usage"] = total_skill_usage_count
	today_stats["session_duration"] = world.time - session_start_time
	today_stats["milestones_today"] = 0

	// Count today's milestones
	var/day_start = current_day * 864000
	for(var/list/milestone in skill_progression_milestones)
		if(milestone["timestamp"] >= day_start)
			today_stats["milestones_today"]++

/datum/scp_advanced_component/skill_progression_tracker/proc/get_skill_analytics(skill_name)
	if(!(skill_name in skill_usage_history))
		return list("error" = "No data available for [skill_name]")

	var/list/analytics = list()
	analytics["total_uses"] = length(skill_usage_history[skill_name])
	analytics["efficiency_rating"] = skill_efficiency_ratings[skill_name] || "Calculating..."
	analytics["recent_activity"] = get_recent_activity_summary(skill_name)

	return analytics

/datum/scp_advanced_component/skill_progression_tracker/proc/get_recent_activity_summary(skill_name)
	var/recent_cutoff = world.time - 3600 SECONDS // Last hour
	var/recent_uses = 0

	if(skill_name in skill_usage_history)
		for(var/list/usage_record in skill_usage_history[skill_name])
			if(usage_record["timestamp"] >= recent_cutoff)
				recent_uses++

	return recent_uses

/datum/scp_advanced_component/skill_progression_tracker/get_status_info()
	var/active_skills = 0
	for(var/skill_name in skill_efficiency_ratings)
		if(skill_efficiency_ratings[skill_name] > 50)
			active_skills++

	return "Analytics: [total_skill_usage_count] uses, [length(skill_progression_milestones)] milestones, [active_skills] efficient skills"

// Component Performance Optimizer
/datum/scp_advanced_component/performance_optimizer
	name = "Performance Optimizer"
	description = "Optimizes component performance and memory usage"
	version = "1.0.0"
	component_category = "system"
	component_priority = COMPONENT_PRIORITY_LOW

	// Performance Metrics
	var/processing_time_total = 0
	var/processing_cycles = 0
	var/memory_usage_estimate = 0
	var/optimization_level = 1
	var/last_optimization_check = 0

	// Optimization Settings
	var/auto_optimize = TRUE
	var/optimization_interval = 600 SECONDS // 10 minutes
	var/performance_threshold = 100 // milliseconds
	var/memory_cleanup_threshold = 1000 // estimated units

	provided_interfaces = list("performance_optimizer", "memory_manager", "system_monitor")

/datum/scp_advanced_component/performance_optimizer/on_initialize()
	. = ..()
	last_optimization_check = world.time

/datum/scp_advanced_component/performance_optimizer/on_update()
	var/start_time = world.timeofday
	. = ..()

	// Track processing time
	processing_time_total += world.timeofday - start_time
	processing_cycles++

	// Run optimization checks
	if(auto_optimize && world.time - last_optimization_check >= optimization_interval)
		run_optimization_cycle()
		last_optimization_check = world.time

/datum/scp_advanced_component/performance_optimizer/proc/run_optimization_cycle()
	// Calculate average processing time
	var/avg_processing_time = processing_cycles > 0 ? processing_time_total / processing_cycles : 0

	// Check if optimization is needed
	if(avg_processing_time > performance_threshold)
		optimize_processing_performance()

	// Estimate memory usage and cleanup if needed
	estimate_memory_usage()
	if(memory_usage_estimate > memory_cleanup_threshold)
		cleanup_memory()

/datum/scp_advanced_component/performance_optimizer/proc/optimize_processing_performance()
	// Increase optimization level
	optimization_level = min(optimization_level + 1, 5)

	// Reset performance counters
	processing_time_total = 0
	processing_cycles = 0

	// Notify other components about optimization
	manager.broadcast_event("performance_optimization", list("level" = optimization_level))

/datum/scp_advanced_component/performance_optimizer/proc/estimate_memory_usage()
	memory_usage_estimate = 0

	// Estimate memory usage from other components
	for(var/datum/scp_advanced_component/component in manager.components)
		memory_usage_estimate += estimate_component_memory(component)

/datum/scp_advanced_component/performance_optimizer/proc/estimate_component_memory(datum/scp_advanced_component/component)
	// Simple estimation based on list sizes and string lengths
	var/estimate = 0

	// Check for large lists in component vars
	for(var/var_name in component.vars)
		var/value = component.vars[var_name]
		if(islist(value))
			estimate += length(value) * 5 // Rough estimate
		else if(istext(value))
			estimate += length(value)

	return estimate

/datum/scp_advanced_component/performance_optimizer/proc/cleanup_memory()
	// Signal components to perform memory cleanup
	manager.broadcast_event("memory_cleanup", list("threshold" = memory_cleanup_threshold))

	// Reset memory estimate
	memory_usage_estimate = 0

/datum/scp_advanced_component/performance_optimizer/get_status_info()
	var/avg_processing = processing_cycles > 0 ? round(processing_time_total / processing_cycles, 0.1) : 0
	return "Performance: [avg_processing]ms avg, Level [optimization_level], Memory: [memory_usage_estimate] units"

// Enhanced Component Communication Hub
/datum/scp_advanced_component/communication_hub
	name = "Communication Hub"
	description = "Enhanced inter-component communication with message queuing and filtering"
	version = "1.0.0"
	component_category = "communication"
	component_priority = COMPONENT_PRIORITY_HIGH

	// Communication Infrastructure
	var/list/message_queue = list()
	var/list/message_filters = list()
	var/list/communication_logs = list()
	var/max_queue_size = 100
	var/max_log_entries = 500
	var/message_processing_rate = 10 // messages per tick

	provided_interfaces = list("communication_hub", "message_queue", "event_logger")

/datum/scp_advanced_component/communication_hub/on_initialize()
	. = ..()

	// Subscribe to all events for logging
	for(var/event_type in list(COMPONENT_EVENT_TICK, COMPONENT_EVENT_INTERACT, COMPONENT_EVENT_BREACH, COMPONENT_EVENT_DAMAGE, COMPONENT_EVENT_HEAL, COMPONENT_EVENT_DEATH, COMPONENT_EVENT_SPAWN, COMPONENT_EVENT_DESPAWN, COMPONENT_EVENT_CONTAIN, COMPONENT_EVENT_SKILL_USE, COMPONENT_EVENT_ACTIVATE, COMPONENT_EVENT_DEACTIVATE, COMPONENT_EVENT_REVIVE))
		manager.subscribe_to_event(event_type, src, "log_event")

/datum/scp_advanced_component/communication_hub/on_update()
	. = ..()
	process_message_queue()

/datum/scp_advanced_component/communication_hub/proc/queue_message(recipient, message_type, data)
	if(length(message_queue) >= max_queue_size)
		// Remove oldest message
		message_queue.Cut(1, 2)

	var/list/message = list(
		"timestamp" = world.time,
		"recipient" = recipient,
		"type" = message_type,
		"data" = data,
		"processed" = FALSE
	)

	message_queue += list(message)

/datum/scp_advanced_component/communication_hub/proc/process_message_queue()
	var/processed_count = 0

	for(var/list/message in message_queue)
		if(message["processed"] || processed_count >= message_processing_rate)
			continue

		// Apply filters
		if(!check_message_filters(message))
			message["processed"] = TRUE
			continue

		// Process message
		deliver_message(message)
		message["processed"] = TRUE
		processed_count++

	// Clean up processed messages
	for(var/i = length(message_queue); i >= 1; i--)
		var/list/message = message_queue[i]
		if(message["processed"])
			message_queue.Cut(i, i+1)

/datum/scp_advanced_component/communication_hub/proc/check_message_filters(list/message)
	for(var/list/filter in message_filters)
		if(filter["type"] == message["type"] && filter["action"] == "block")
			return FALSE
	return TRUE

/datum/scp_advanced_component/communication_hub/proc/deliver_message(list/message)
	// Find recipient component and deliver message
	var/datum/scp_advanced_component/recipient = manager.get_component(message["recipient"])
	if(recipient)
		recipient.receive_message(message["type"], message["data"])

/datum/scp_advanced_component/communication_hub/proc/log_event(event_data)
	var/list/log_entry = list(
		"timestamp" = world.time,
		"event_type" = event_data["type"] || "unknown",
		"source" = event_data["source"] || "unknown",
		"data_size" = length(event_data)
	)

	communication_logs += list(log_entry)

	// Maintain log size
	if(length(communication_logs) > max_log_entries)
		communication_logs.Cut(1, 2)

/datum/scp_advanced_component/communication_hub/proc/add_message_filter(message_type, action = "block")
	var/list/filter = list("type" = message_type, "action" = action)
	message_filters += list(filter)

/datum/scp_advanced_component/communication_hub/get_status_info()
	return "Communications: [length(message_queue)] queued, [length(communication_logs)] logged, [length(message_filters)] filters"
