// SCP Advanced Component System Documentation and Help System
// Provides in-game documentation and help for the modular SCP system

// Documentation Manager
/datum/scp_documentation_manager
	var/list/documentation_sections = list()
	var/current_version = "2.0.0"
	var/last_updated = "2025-08-20"

/datum/scp_documentation_manager/New()
	initialize_documentation()

/datum/scp_documentation_manager/proc/initialize_documentation()
	// Core System Overview
	documentation_sections["overview"] = list(
		"title" = "SCP Advanced Component System Overview",
		"content" = list(
			"The SCP Advanced Component System is a modular architecture that allows any mob to become an SCP through composition rather than inheritance.",
			"Key Features:",
			"• Modular component-based design",
			"• Human-mob conversion for sentient SCPs",
			"• Advanced skill and experience systems",
			"• Comprehensive containment management",
			"• Real-time performance optimization",
			"• Inter-component networking and communication",
			"• Persistent data storage and retrieval",
			"• Dynamic effect application system",
			"• Comprehensive testing framework"
		)
	)

	// Component Types
	documentation_sections["components"] = list(
		"title" = "Component Types and Functions",
		"content" = list(
			"Core Components:",
			"• scp_identity: Manages SCP designation, classification, and metadata",
			"• advanced_skill_system: Handles skills, experience, leveling, and cooldowns",
			"• advanced_containment_system: Manages protocols, security, and breach detection",
			"",
			"Enhancement Components:",
			"• skill_progression_tracker: Advanced analytics and milestone tracking",
			"• performance_optimizer: Memory and processing optimization",
			"• communication_hub: Inter-component messaging system",
			"",
			"Specialized Components:",
			"• Individual components for each sentient SCP (049, 082, 096, etc.)",
			"• SCP-specific abilities and behavior patterns",
			"• Customizable parameters and configurations"
		)
	)

	// Human Conversion
	documentation_sections["human_conversion"] = list(
		"title" = "Human-Based SCP Conversion",
		"content" = list(
			"Converted Sentient SCPs:",
			"• SCP-049 (Plague Doctor) - /mob/living/scp/scp049",
			"• SCP-082 (Fernand) - /mob/living/scp/scp082",
			"• SCP-096 (Shy Guy) - /mob/living/scp/scp096",
			"• SCP-106 (Old Man) - /mob/living/scp/scp106",
			"• SCP-343 (God) - /mob/living/scp/scp343",
			"• SCP-457 (Burning Man) - /mob/living/scp/scp457",
			"• SCP-939 (Voice Mimics) - /mob/living/scp/scp939",
			"• SCP-966 (Sleep Killers) - /mob/living/scp/scp966",
			"",
			"Benefits:",
			"• Unified mob systems and interactions",
			"• Access to human equipment and clothing systems",
			"• Consistent medical and damage systems",
			"• Enhanced roleplay capabilities"
		)
	)

	// Admin Commands
	documentation_sections["admin_commands"] = list(
		"title" = "Administrative Commands",
		"content" = list(
			"Testing and Validation:",
			"• run_component_tests() - Comprehensive component system testing",
			"• validate_scp_integration() - Full integration validation",
			"",
			"System Management:",
			"• SCP Management Interface - Spawn and manage SCPs",
			"• Persistence Master Panel - Advanced administrative controls",
			"",
			"Debugging:",
			"• Component status information via examine",
			"• Real-time performance monitoring",
			"• Error logging and diagnostics"
		)
	)

	// Technical Details
	documentation_sections["technical"] = list(
		"title" = "Technical Implementation Details",
		"content" = list(
			"Architecture:",
			"• Non-overwriting design preserves original SCP datum",
			"• Extension-based integration via scp_advanced_extensions.dm",
			"• Priority-based component processing (Critical->Background)",
			"• Event-driven communication system",
			"",
			"Performance:",
			"• Automatic memory management and cleanup",
			"• Processing time monitoring and optimization",
			"• Configurable update frequencies",
			"• Background processing for non-critical tasks",
			"",
			"Persistence:",
			"• Database-driven component state storage",
			"• Automatic save/load functionality",
			"• Serialization of complex component data",
			"• Recovery mechanisms for data integrity"
		)
	)

	// Troubleshooting
	documentation_sections["troubleshooting"] = list(
		"title" = "Troubleshooting and Common Issues",
		"content" = list(
			"Component Not Loading:",
			"• Check if SCP has uses_advanced_components = TRUE",
			"• Verify compInit_advanced() was called",
			"• Ensure component type is properly defined",
			"",
			"Skill System Issues:",
			"• Verify skill requirements are met",
			"• Check cooldown status with can_use_skill()",
			"• Ensure skill was properly added with add_skill()",
			"",
			"Performance Issues:",
			"• Use performance_optimizer component",
			"• Check processing time in component status",
			"• Reduce update frequencies for non-critical components",
			"",
			"Persistence Problems:",
			"• Verify database initialization",
			"• Check component serialization data",
			"• Ensure proper save/load timing"
		)
	)

/datum/scp_documentation_manager/proc/get_documentation(section_key)
	if(section_key in documentation_sections)
		return documentation_sections[section_key]
	return null

/datum/scp_documentation_manager/proc/get_all_sections()
	return documentation_sections.Copy()

// Global documentation manager
var/global/datum/scp_documentation_manager/GLOB_SCP_DOCS = new /datum/scp_documentation_manager()

// Admin verb for accessing documentation
/mob/proc/scp_system_help()
	set name = "SCP System Help"
	set category = "SCP Admin"
	set desc = "Access comprehensive SCP system documentation"

	if(!client || !check_rights(R_ADMIN))
		return

	var/list/section_choices = list()
	for(var/key in GLOB_SCP_DOCS.documentation_sections)
		var/list/section = GLOB_SCP_DOCS.documentation_sections[key]
		section_choices[section["title"]] = key

	var/choice = input(src, "Select documentation section:", "SCP System Help") in section_choices
	if(!choice)
		return

	var/section_key = section_choices[choice]
	var/list/section = GLOB_SCP_DOCS.get_documentation(section_key)

	if(section)
		to_chat(src, "<span class='boldnotice'>=== [section["title"]] ===</span>")
		for(var/line in section["content"])
			if(line == "")
				to_chat(src, "")
			else
				to_chat(src, "<span class='notice'>[line]</span>")

// System Status Overview
/mob/proc/scp_system_status()
	set name = "SCP System Status"
	set category = "SCP Admin"
	set desc = "Display comprehensive system status information"

	if(!client || !check_rights(R_ADMIN))
		return

	to_chat(src, "<span class='boldnotice'>=== SCP Advanced Component System Status ===</span>")
	to_chat(src, "<span class='notice'>Version: [GLOB_SCP_DOCS.current_version]</span>")
	to_chat(src, "<span class='notice'>Last Updated: [GLOB_SCP_DOCS.last_updated]</span>")
	to_chat(src, "")

	// Component System Status
	to_chat(src, "<span class='boldnotice'>Core Systems:</span>")
	to_chat(src, "<span class='notice'>• Advanced Components: [ispath(/datum/scp_advanced_component) ? "✅ Available" : "❌ Missing"]</span>")
	to_chat(src, "<span class='notice'>• Component Manager: [ispath(/datum/component_manager_advanced) ? "✅ Available" : "❌ Missing"]</span>")
	to_chat(src, "<span class='notice'>• SCP Extensions: [ispath(/datum/scp) ? "✅ Available" : "❌ Missing"]</span>")
	to_chat(src, "")

	// Network Systems
	to_chat(src, "<span class='boldnotice'>Network Systems:</span>")
	to_chat(src, "<span class='notice'>• SCP Network Hub: [GLOB_SCP_NETWORK ? "✅ Active ([length(GLOB_SCP_NETWORK.connected_scps)] SCPs)" : "❌ Inactive"]</span>")
	to_chat(src, "<span class='notice'>• Effect System: [ispath(/datum/scp_component_effect) ? "✅ Available" : "❌ Missing"]</span>")
	to_chat(src, "<span class='notice'>• Component Database: [GLOB_COMPONENT_DB ? "✅ Active" : "❌ Inactive"]</span>")
	to_chat(src, "")

	// Converted SCPs Status
	to_chat(src, "<span class='boldnotice'>Human-Converted SCPs:</span>")
	var/list/converted_scps = list(
		"SCP-049" = /mob/living/scp/scp049,
		"SCP-082" = /mob/living/scp/scp082,
		"SCP-096" = /mob/living/scp/scp096,
		"SCP-343" = /mob/living/scp/scp343,
		"SCP-939" = /mob/living/scp/scp939,
		"SCP-966" = /mob/living/scp/scp966
	)

	for(var/scp_name in converted_scps)
		var/scp_type = converted_scps[scp_name]
		var/status = ispath(scp_type) && ispath(scp_type, /mob/living/carbon/human) ? "✅ Converted" : "❌ Not Converted"
		to_chat(src, "<span class='notice'>• [scp_name]: [status]</span>")

	to_chat(src, "")
	to_chat(src, "<span class='notice'>Use 'SCP System Help' for detailed documentation</span>")
	to_chat(src, "<span class='notice'>Use 'Validate SCP Integration' for system testing</span>")

// Quick system statistics
/mob/proc/scp_quick_stats()
	set name = "SCP Quick Stats"
	set category = "SCP Admin"
	set desc = "Display quick system statistics"

	if(!client || !check_rights(R_ADMIN))
		return

	var/active_scps = 0
	var/component_scps = 0

	// Count active SCPs with components
	for(var/mob/living/M in GLOB.mob_list)
		if(QDELETED(M))
			continue
		if(M.SCP)
			active_scps++
			if(M.SCP.uses_advanced_components)
				component_scps++

	to_chat(src, "<span class='boldnotice'>=== Quick SCP Statistics ===</span>")
	to_chat(src, "<span class='notice'>Active SCPs: [active_scps]</span>")
	to_chat(src, "<span class='notice'>Component-Based SCPs: [component_scps]</span>")
	to_chat(src, "<span class='notice'>Network Registered: [GLOB_SCP_NETWORK ? length(GLOB_SCP_NETWORK.connected_scps) : 0]</span>")
	to_chat(src, "<span class='notice'>System Status: [component_scps > 0 ? "✅ Active" : "⚠️ No Components Active"]</span>")

// Component examination helper
/mob/proc/examine_scp_components()
	set name = "Examine SCP Components"
	set category = "SCP Admin"
	set desc = "Examine components of targeted SCP"

	if(!client || !check_rights(R_ADMIN))
		return

	var/mob/living/target = input(src, "Select SCP to examine:", "Component Examination") as null|mob in GLOB.mob_list

	if(!target || !target.SCP)
		to_chat(src, "<span class='warning'>Target is not an SCP.</span>")
		return

	if(!target.SCP.uses_advanced_components)
		to_chat(src, "<span class='warning'>Target SCP does not use advanced components.</span>")
		return

	to_chat(src, "<span class='boldnotice'>=== SCP Component Analysis: [target.SCP.designation] ===</span>")
	to_chat(src, "<span class='notice'>Name: [target.SCP.name]</span>")
	to_chat(src, "<span class='notice'>Classification: [target.SCP.classification]</span>")
	to_chat(src, "")

	// List all components
	if(target.SCP.advanced_components)
		to_chat(src, "<span class='boldnotice'>Active Components:</span>")
		for(var/component_id in target.SCP.advanced_components.components)
			var/datum/scp_advanced_component/component = target.SCP.advanced_components.components[component_id]
			to_chat(src, "<span class='notice'>• [component.name] ([component.version])</span>")
			to_chat(src, "<span class='notice'>  Status: [component.get_status_info()]</span>")
	else
		to_chat(src, "<span class='warning'>No component manager found.</span>")
