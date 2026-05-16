// SCP Interactive Documentation System - TGUI Backend
// Provides comprehensive documentation and system monitoring for the SCP Foundation

/datum/scp_documentation_interface
	var/name = "SCP Documentation System"
	var/client/admin_client
	var/datum/scp_documentation_manager/doc_manager
	var/list/cached_system_status = list()
	var/last_status_update = 0
	var/status_update_interval = 30 SECONDS

/datum/scp_documentation_interface/New(client/admin)
	admin_client = admin
	doc_manager = GLOB_SCP_DOCS
	refresh_system_status()

/datum/scp_documentation_interface/ui_state(mob/user)
	return GLOB.admin_state

/datum/scp_documentation_interface/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SCPDocumentation", name)
		ui.open()

/datum/scp_documentation_interface/ui_data(mob/user)
	var/list/data = list()

	// Refresh system status if needed
	if(world.time > last_status_update + status_update_interval)
		refresh_system_status()

	// Documentation sections
	data["documentation_sections"] = get_documentation_sections()

	// System status
	data["system_status"] = cached_system_status

	// Active SCPs
	data["active_scps"] = get_active_scps_data()

	// Component statistics
	data["component_stats"] = get_component_statistics()

	// Performance metrics
	data["performance_metrics"] = get_performance_metrics()

	// System information
	data["system_info"] = list(
		"version" = doc_manager.current_version,
		"last_updated" = doc_manager.last_updated,
		"total_sections" = length(doc_manager.documentation_sections),
		"server_time" = time2text(world.time, "YYYY-MM-DD hh:mm:ss")
	)

	return data

/datum/scp_documentation_interface/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("refresh_status")
			refresh_system_status()
			. = TRUE

		if("examine_scp")
			var/scp_id = params["scp_id"]
			if(scp_id)
				examine_scp_details(scp_id)
			. = TRUE

		if("examine_component")
			var/component_id = params["component_id"]
			var/scp_id = params["scp_id"]
			if(component_id && scp_id)
				examine_component_details(scp_id, component_id)
			. = TRUE

		if("export_documentation")
			export_documentation_to_file()
			. = TRUE

		if("run_system_diagnostics")
			run_system_diagnostics()
			. = TRUE

		if("search_documentation")
			var/search_term = params["search_term"]
			if(search_term)
				search_documentation(search_term)
			. = TRUE

/datum/scp_documentation_interface/proc/get_documentation_sections()
	var/list/sections = list()

	for(var/section_key in doc_manager.documentation_sections)
		var/list/section_data = doc_manager.documentation_sections[section_key]
		sections += list(list(
			"id" = section_key,
			"title" = section_data["title"],
			"content" = section_data["content"],
			"category" = get_section_category(section_key)
		))

	return sections

/datum/scp_documentation_interface/proc/get_section_category(section_key)
	switch(section_key)
		if("overview", "components", "human_conversion")
			return "Core System"
		if("admin_commands", "troubleshooting")
			return "Administration"
		if("technical")
			return "Technical"
		else
			return "General"

/datum/scp_documentation_interface/proc/refresh_system_status()
	last_status_update = world.time
	cached_system_status = list()

	// Core systems status
	cached_system_status["core_systems"] = list(
		"advanced_components" = list(
			"available" = ispath(/datum/scp_advanced_component),
			"status" = ispath(/datum/scp_advanced_component) ? "Available" : "Missing",
			"description" = "Advanced modular component system"
		),
		"component_manager" = list(
			"available" = ispath(/datum/component_manager_advanced),
			"status" = ispath(/datum/component_manager_advanced) ? "Available" : "Missing",
			"description" = "Component lifecycle management"
		),
		"scp_extensions" = list(
			"available" = ispath(/datum/scp),
			"status" = ispath(/datum/scp) ? "Available" : "Missing",
			"description" = "SCP datum extensions"
		)
	)

	// Network systems status
	cached_system_status["network_systems"] = list(
		"scp_network" = list(
			"available" = !!GLOB_SCP_NETWORK,
			"status" = GLOB_SCP_NETWORK ? "Active ([length(GLOB_SCP_NETWORK.connected_scps)] SCPs)" : "Inactive",
			"description" = "Inter-SCP communication network"
		),
		"effect_system" = list(
			"available" = ispath(/datum/scp_component_effect),
			"status" = ispath(/datum/scp_component_effect) ? "Available" : "Missing",
			"description" = "Component effect management"
		),
		"component_database" = list(
			"available" = !!GLOB_COMPONENT_DB,
			"status" = GLOB_COMPONENT_DB ? "Active" : "Inactive",
			"description" = "Component persistence database"
		)
	)

	// Subsystem status
	cached_system_status["subsystems"] = list(
		"persistent_progression" = list(
			"available" = !!SSpersistent_progression,
			"status" = SSpersistent_progression ? "Running" : "Not Running",
			"description" = "Player progression and achievement system"
		),
		"scp_persistence" = list(
			"available" = !!SSscp_persistence,
			"status" = SSscp_persistence ? "Running" : "Not Running",
			"description" = "SCP data persistence"
		),
		"scp_progression_integration" = list(
			"available" = !!SSscp_progression_integration,
			"status" = SSscp_progression_integration ? "Running" : "Not Running",
			"description" = "SCP progression integration"
		)
	)

/datum/scp_documentation_interface/proc/get_active_scps_data()
	var/list/scps = list()
	var/active_count = 0
	var/component_count = 0

	for(var/mob/living/M in GLOB.mob_list)
		if(QDELETED(M))
			continue
		if(!M.SCP)
			continue

		active_count++
		var/uses_components = M.SCP.uses_advanced_components
		if(uses_components)
			component_count++

		var/list/scp_data = list(
			"id" = M.SCP.designation,
			"name" = M.SCP.name,
			"classification" = M.SCP.classification,
			"type" = "[M.type]",
			"uses_components" = uses_components,
			"player_controlled" = !!M.ckey,
			"player_name" = M.ckey || "NPC",
			"health" = M.health,
			"max_health" = M.maxHealth,
			"location" = "[get_area_name(M)]",
			"status" = M.stat == DEAD ? "Dead" : (M.stat == UNCONSCIOUS ? "Unconscious" : "Alive")
		)

		// Add component information if available
		if(uses_components && M.SCP.advanced_components)
			scp_data["components"] = get_scp_components_data(M)

		scps += list(scp_data)

	return list(
		"scps" = scps,
		"total_active" = active_count,
		"component_based" = component_count,
		"network_registered" = GLOB_SCP_NETWORK ? length(GLOB_SCP_NETWORK.connected_scps) : 0
	)

/datum/scp_documentation_interface/proc/get_scp_components_data(mob/living/scp_mob)
	var/list/components = list()

	if(!scp_mob.SCP?.advanced_components?.components)
		return components

	for(var/component_id in scp_mob.SCP.advanced_components.components)
		var/datum/scp_advanced_component/component = scp_mob.SCP.advanced_components.components[component_id]
		components += list(list(
			"id" = component_id,
			"name" = component.name,
			"version" = component.version,
			"category" = component.component_category,
			"state" = component.component_state,
			"priority" = component.component_priority,
			"error_count" = component.error_count,
			"update_count" = component.update_count,
			"interfaces" = component.provided_interfaces
		))

	return components

/datum/scp_documentation_interface/proc/get_component_statistics()
	var/list/stats = list(
		"total_components" = 0,
		"active_components" = 0,
		"error_components" = 0,
		"categories" = list(),
		"priorities" = list(),
		"most_used_components" = list()
	)

	var/list/component_usage = list()
	var/list/category_counts = list()
	var/list/priority_counts = list()

	for(var/mob/living/M in GLOB.mob_list)
		if(QDELETED(M))
			continue
		if(!M.SCP?.advanced_components?.components)
			continue

		for(var/component_id in M.SCP.advanced_components.components)
			var/datum/scp_advanced_component/component = M.SCP.advanced_components.components[component_id]

			stats["total_components"]++

			if(component.component_state == COMPONENT_STATE_ACTIVE)
				stats["active_components"]++

			if(component.component_state == COMPONENT_STATE_ERROR)
				stats["error_components"]++

			// Count by type
			var/component_type = "[component.type]"
			component_usage[component_type] = (component_usage[component_type] || 0) + 1

			// Count by category
			var/category = component.component_category
			category_counts[category] = (category_counts[category] || 0) + 1

			// Count by priority
			var/priority = component.component_priority
			priority_counts["[priority]"] = (priority_counts["[priority]"] || 0) + 1

	// Convert to lists for frontend
	for(var/category in category_counts)
		stats["categories"] += list(list("name" = category, "count" = category_counts[category]))

	for(var/priority in priority_counts)
		stats["priorities"] += list(list("priority" = priority, "count" = priority_counts[priority]))

	// Get most used components (top 5)
	var/list/sorted_usage = list()
	for(var/component_type in component_usage)
		sorted_usage += list(list("type" = component_type, "count" = component_usage[component_type]))

	// Sort by count in descending order
	sorted_usage = sortTim(sorted_usage, /proc/cmp_component_usage_dsc, TRUE)
	stats["most_used_components"] = sorted_usage.Copy(1, min(6, length(sorted_usage) + 1))

	return stats

/datum/scp_documentation_interface/proc/get_performance_metrics()
	var/list/metrics = list(
		"total_update_time" = 0,
		"average_update_time" = 0,
		"component_managers" = 0,
		"total_updates" = 0,
		"performance_issues" = list(),
		"memory_usage" = list()
	)

	var/total_time = 0
	var/total_updates = 0
	var/manager_count = 0

	for(var/mob/living/M in GLOB.mob_list)
		if(QDELETED(M))
			continue
		if(!M.SCP?.advanced_components)
			continue

		manager_count++
		var/datum/component_manager_advanced/manager = M.SCP.advanced_components

		total_time += manager.total_update_time
		total_updates += manager.update_cycles

		// Check for performance issues
		if(manager.update_cycles > 0)
			var/avg_time = manager.total_update_time / manager.update_cycles
			if(avg_time > 50) // More than 50ms average
				metrics["performance_issues"] += list(list(
					"scp" = M.SCP.designation,
					"average_time" = avg_time,
					"update_cycles" = manager.update_cycles,
					"severity" = avg_time > 100 ? "High" : "Medium"
				))

	metrics["total_update_time"] = total_time
	metrics["total_updates"] = total_updates
	metrics["component_managers"] = manager_count

	if(total_updates > 0)
		metrics["average_update_time"] = total_time / total_updates

	return metrics

/datum/scp_documentation_interface/proc/examine_scp_details(scp_id)
	for(var/mob/living/M in GLOB.mob_list)
		if(QDELETED(M))
			continue
		if(M.SCP?.designation == scp_id)
			to_chat(admin_client, "<span class='boldnotice'>=== SCP-[scp_id] Detailed Analysis ===</span>")
			to_chat(admin_client, "<span class='notice'>Name: [M.SCP.name]</span>")
			to_chat(admin_client, "<span class='notice'>Classification: [M.SCP.classification]</span>")
			to_chat(admin_client, "<span class='notice'>Type: [M.type]</span>")
			to_chat(admin_client, "<span class='notice'>Player: [M.ckey || "NPC"]</span>")
			to_chat(admin_client, "<span class='notice'>Health: [M.health]/[M.maxHealth]</span>")
			to_chat(admin_client, "<span class='notice'>Location: [get_area_name(M)]</span>")

			if(M.SCP.advanced_components)
				to_chat(admin_client, "<span class='notice'>Components: [length(M.SCP.advanced_components.components)]</span>")
				for(var/component_id in M.SCP.advanced_components.components)
					var/datum/scp_advanced_component/component = M.SCP.advanced_components.components[component_id]
					to_chat(admin_client, "<span class='notice'>  • [component.name] v[component.version] ([component.component_state])</span>")
			return

/datum/scp_documentation_interface/proc/examine_component_details(scp_id, component_id)
	for(var/mob/living/M in GLOB.mob_list)
		if(QDELETED(M))
			continue
		if(M.SCP?.designation == scp_id && M.SCP.advanced_components)
			var/datum/scp_advanced_component/component = M.SCP.advanced_components.components[component_id]
			if(component)
				to_chat(admin_client, "<span class='boldnotice'>=== Component Analysis: [component.name] ===</span>")
				to_chat(admin_client, "<span class='notice'>Version: [component.version]</span>")
				to_chat(admin_client, "<span class='notice'>Category: [component.component_category]</span>")
				to_chat(admin_client, "<span class='notice'>State: [component.component_state]</span>")
				to_chat(admin_client, "<span class='notice'>Priority: [component.component_priority]</span>")
				to_chat(admin_client, "<span class='notice'>Errors: [component.error_count]</span>")
				to_chat(admin_client, "<span class='notice'>Updates: [component.update_count]</span>")
				to_chat(admin_client, "<span class='notice'>Interfaces: [english_list(component.provided_interfaces)]</span>")
			return

/datum/scp_documentation_interface/proc/export_documentation_to_file()
	var/filename = "data/scp_documentation_export_[time2text(world.time, "YYYY-MM-DD_hh-mm-ss")].json"
	var/list/export_data = list(
		"system_info" = list(
			"version" = doc_manager.current_version,
			"last_updated" = doc_manager.last_updated,
			"export_time" = time2text(world.time, "YYYY-MM-DD hh:mm:ss")
		),
		"documentation" = doc_manager.get_all_sections(),
		"system_status" = cached_system_status,
		"active_scps" = get_active_scps_data(),
		"performance_metrics" = get_performance_metrics()
	)

	rustg_file_write(json_encode(export_data), filename)
	to_chat(admin_client, "<span class='notice'>Documentation exported to [filename]</span>")

/datum/scp_documentation_interface/proc/run_system_diagnostics()
	to_chat(admin_client, "<span class='boldnotice'>=== SCP System Diagnostics ===</span>")

	// Check core systems
	var/issues_found = 0

	if(!ispath(/datum/scp_advanced_component))
		to_chat(admin_client, "<span class='warning'>❌ Advanced components not available</span>")
		issues_found++
	else
		to_chat(admin_client, "<span class='notice'>✅ Advanced components available</span>")

	if(!GLOB_SCP_NETWORK)
		to_chat(admin_client, "<span class='warning'>⚠️ SCP Network not initialized</span>")
		issues_found++
	else
		to_chat(admin_client, "<span class='notice'>✅ SCP Network active ([length(GLOB_SCP_NETWORK.connected_scps)] connected)</span>")

	// Check active SCPs with issues
	for(var/mob/living/M in GLOB.mob_list)
		if(QDELETED(M))
			continue
		if(!M.SCP?.advanced_components)
			continue

		var/datum/component_manager_advanced/manager = M.SCP.advanced_components
		var/error_components = 0

		for(var/component_id in manager.components)
			var/datum/scp_advanced_component/component = manager.components[component_id]
			if(component.component_state == COMPONENT_STATE_ERROR)
				error_components++

		if(error_components > 0)
			to_chat(admin_client, "<span class='warning'>⚠️ SCP-[M.SCP.designation] has [error_components] error components</span>")
			issues_found++

	if(issues_found == 0)
		to_chat(admin_client, "<span class='notice'>✅ No issues detected - System is healthy</span>")
	else
		to_chat(admin_client, "<span class='warning'>Found [issues_found] potential issues</span>")

/datum/scp_documentation_interface/proc/search_documentation(search_term)
	var/list/results = list()

	for(var/section_key in doc_manager.documentation_sections)
		var/list/section_data = doc_manager.documentation_sections[section_key]
		var/found_in_title = findtext(lowertext(section_data["title"]), lowertext(search_term))
		var/found_in_content = FALSE

		for(var/line in section_data["content"])
			if(findtext(lowertext(line), lowertext(search_term)))
				found_in_content = TRUE
				break

		if(found_in_title || found_in_content)
			results += list(list(
				"section" = section_key,
				"title" = section_data["title"],
				"match_type" = found_in_title ? "title" : "content"
			))

	to_chat(admin_client, "<span class='boldnotice'>=== Search Results for '[search_term]' ===</span>")
	if(length(results))
		for(var/list/result in results)
			to_chat(admin_client, "<span class='notice'>• [result["title"]] (matched in [result["match_type"]])</span>")
	else
		to_chat(admin_client, "<span class='warning'>No results found for '[search_term]'</span>")

// Helper proc for comparing component usage lists by count
/proc/cmp_component_usage_dsc(list/a, list/b)
	return b["count"] - a["count"]

// Admin verb to open the documentation interface
/client/proc/open_scp_documentation()
	set name = "SCP Documentation"
	set category = "Admin"
	set desc = "Open the interactive SCP documentation system"

	if(!check_rights(R_ADMIN))
		return

	var/datum/scp_documentation_interface/interface = new(src)
	interface.ui_interact(usr)

// Admin verb is added to admin_verbs_admin in admin_verbs.dm
