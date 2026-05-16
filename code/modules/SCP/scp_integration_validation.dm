// SCP Component System Integration Validation
// Comprehensive validation to ensure the complete modular system works together

// Integration Test Manager
/datum/scp_integration_validator
	var/list/validation_results = list()
	var/total_validations = 0
	var/passed_validations = 0
	var/failed_validations = 0
	var/test_duration = 0
	var/validation_start_time = 0

/datum/scp_integration_validator/proc/run_full_validation()
	validation_start_time = world.time
	validation_results.Cut()
	total_validations = 0
	passed_validations = 0
	failed_validations = 0

	// Core system validations
	validate_component_system_initialization()
	validate_human_scp_conversion()
	validate_skill_system_integration()
	validate_containment_system_integration()
	validate_networking_system()
	validate_effects_system()
	validate_persistence_system()
	validate_performance_optimization()
	validate_scp_spawning_system()
	validate_component_communication()

	test_duration = world.time - validation_start_time

	return get_validation_summary()

/datum/scp_integration_validator/proc/validate_component_system_initialization()
	var/list/result = list("test" = "Component System Initialization", "status" = "PASS", "details" = list())
	total_validations++

	// Test 1: Check if advanced components are properly defined
	if(!ispath(/datum/scp_advanced_component))
		result["status"] = "FAIL"
		result["details"] += "scp_advanced_component base class not found"

	// Test 2: Check if component manager exists
	if(!ispath(/datum/component_manager_advanced))
		result["status"] = "FAIL"
		result["details"] += "component_manager_advanced not found"

	// Test 3: Check if core components exist
	var/list/required_components = list(
		/datum/scp_advanced_component/scp_identity,
		/datum/scp_advanced_component/advanced_skill_system,
		/datum/scp_advanced_component/advanced_containment_system
	)

	for(var/component_type in required_components)
		if(!ispath(component_type))
			result["status"] = "FAIL"
			result["details"] += "Required component [component_type] not found"

	if(result["status"] == "PASS")
		passed_validations++
		result["details"] += "All core component types properly defined"
	else
		failed_validations++

	validation_results += list(result)

/datum/scp_integration_validator/proc/validate_human_scp_conversion()
	var/list/result = list("test" = "Human SCP Conversion", "status" = "PASS", "details" = list())
	total_validations++

	// Check if converted SCP types exist and inherit from human
	var/list/converted_scps = list(
		/mob/living/scp/scp049,
		/mob/living/scp/scp082,
		/mob/living/scp/scp096,
		/mob/living/scp/scp343,
		/mob/living/scp/scp939,
		/mob/living/scp/scp966
	)

	for(var/scp_type in converted_scps)
		if(!ispath(scp_type))
			result["status"] = "FAIL"
			result["details"] += "Converted SCP type [scp_type] not found"
		else if(!ispath(scp_type, /mob/living/carbon/human))
			result["status"] = "FAIL"
			result["details"] += "SCP type [scp_type] does not inherit from human"

	if(result["status"] == "PASS")
		passed_validations++
		result["details"] += "All 6 core sentient SCPs successfully converted to human inheritance"
	else
		failed_validations++

	validation_results += list(result)

/datum/scp_integration_validator/proc/validate_skill_system_integration()
	var/list/result = list("test" = "Skill System Integration", "status" = "PASS", "details" = list())
	total_validations++

	// Test with a temporary SCP to validate skill system
	var/mob/living/carbon/human/test_scp = new /mob/living/carbon/human()
	var/datum/scp/test_SCP = new /datum/scp(test_scp, "Test SCP", "Safe", "TEST", "SCP_SENTIENT")

	if(test_SCP)
		test_SCP.uses_advanced_components = TRUE
		test_SCP.compInit_advanced()

		// Check if skill system component was added
		var/datum/scp_advanced_component/advanced_skill_system/skill_system = test_SCP.get_component("skill_system")

		if(!skill_system)
			result["status"] = "FAIL"
			result["details"] += "Skill system component not initialized"
		else
			// Test adding a skill
			skill_system.add_skill("Test Skill", 30 SECONDS, list())

			if(!("Test Skill" in skill_system.skills))
				result["status"] = "FAIL"
				result["details"] += "Skill addition failed"
			else
				result["details"] += "Skill system properly integrated and functional"

		// Cleanup
		qdel(test_SCP)
		qdel(test_scp)
	else
		result["status"] = "FAIL"
		result["details"] += "Failed to create test SCP datum"

	if(result["status"] == "PASS")
		passed_validations++
	else
		failed_validations++

	validation_results += list(result)

/datum/scp_integration_validator/proc/validate_containment_system_integration()
	var/list/result = list("test" = "Containment System Integration", "status" = "PASS", "details" = list())
	total_validations++

	// Test containment system functionality
	var/mob/living/carbon/human/test_scp = new /mob/living/carbon/human()
	var/datum/scp/test_SCP = new /datum/scp(test_scp, "Test SCP", "Euclid", "TEST", "SCP_SENTIENT")

	if(test_SCP)
		test_SCP.uses_advanced_components = TRUE
		test_SCP.compInit_advanced()

		var/datum/scp_advanced_component/advanced_containment_system/containment = test_SCP.get_component("containment_system")

		if(!containment)
			result["status"] = "FAIL"
			result["details"] += "Containment system component not initialized"
		else
			// Test containment integrity
			var/initial_integrity = containment.containment_integrity
			containment.adjust_containment_integrity(-20)

			if(containment.containment_integrity >= initial_integrity)
				result["status"] = "FAIL"
				result["details"] += "Containment integrity adjustment failed"
			else
				result["details"] += "Containment system properly integrated and functional"

		qdel(test_SCP)
		qdel(test_scp)
	else
		result["status"] = "FAIL"
		result["details"] += "Failed to create test SCP datum"

	if(result["status"] == "PASS")
		passed_validations++
	else
		failed_validations++

	validation_results += list(result)

/datum/scp_integration_validator/proc/validate_networking_system()
	var/list/result = list("test" = "Component Networking System", "status" = "PASS", "details" = list())
	total_validations++

	// Check if global network hub exists
	if(!GLOB_SCP_NETWORK)
		result["status"] = "FAIL"
		result["details"] += "Global SCP network hub not initialized"
	else
		// Test network registration
		var/mob/living/carbon/human/test_scp = new /mob/living/carbon/human()
		var/datum/scp/test_SCP = new /datum/scp(test_scp, "Test SCP", "Safe", "NET_TEST", "SCP_SENTIENT")

		if(test_SCP)
			test_SCP.uses_advanced_components = TRUE
			test_SCP.compInit_advanced()

			// Register with network
			GLOB_SCP_NETWORK.register_scp(test_scp)

			if(test_scp in GLOB_SCP_NETWORK.connected_scps)
				result["details"] += "Network registration successful"
			else
				result["status"] = "FAIL"
				result["details"] += "Network registration failed"

			// Cleanup
			GLOB_SCP_NETWORK.unregister_scp(test_scp)
			qdel(test_SCP)
			qdel(test_scp)
		else
			result["status"] = "FAIL"
			result["details"] += "Failed to create test SCP for networking"

	if(result["status"] == "PASS")
		passed_validations++
	else
		failed_validations++

	validation_results += list(result)

/datum/scp_integration_validator/proc/validate_effects_system()
	var/list/result = list("test" = "Component Effects System", "status" = "PASS", "details" = list())
	total_validations++

	// Check if effect system types exist
	if(!ispath(/datum/scp_component_effect))
		result["status"] = "FAIL"
		result["details"] += "Effect system base class not found"
	else if(!ispath(/datum/scp_component_effect_manager))
		result["status"] = "FAIL"
		result["details"] += "Effect manager class not found"
	else
		result["details"] += "Effect system classes properly defined"

	if(result["status"] == "PASS")
		passed_validations++
	else
		failed_validations++

	validation_results += list(result)

/datum/scp_integration_validator/proc/validate_persistence_system()
	var/list/result = list("test" = "Component Persistence System", "status" = "PASS", "details" = list())
	total_validations++

	// Check if global database exists
	if(!GLOB_COMPONENT_DB)
		result["status"] = "FAIL"
		result["details"] += "Global component database not initialized"
	else if(!ispath(/datum/scp_component_database))
		result["status"] = "FAIL"
		result["details"] += "Component database class not found"
	else if(!ispath(/datum/scp_component_serializer))
		result["status"] = "FAIL"
		result["details"] += "Component serializer class not found"
	else
		result["details"] += "Persistence system properly initialized"

	if(result["status"] == "PASS")
		passed_validations++
	else
		failed_validations++

	validation_results += list(result)

/datum/scp_integration_validator/proc/validate_performance_optimization()
	var/list/result = list("test" = "Performance Optimization", "status" = "PASS", "details" = list())
	total_validations++

	// Test performance optimizer component
	var/mob/living/carbon/human/test_scp = new /mob/living/carbon/human()
	var/datum/scp/test_SCP = new /datum/scp(test_scp, "Test SCP", "Safe", "PERF_TEST", "SCP_SENTIENT")

	if(test_SCP)
		test_SCP.uses_advanced_components = TRUE
		test_SCP.compInit_advanced()

		var/datum/scp_advanced_component/performance_optimizer/optimizer = test_SCP.get_component("performance_optimizer")

		if(!optimizer)
			result["status"] = "FAIL"
			result["details"] += "Performance optimizer component not found"
		else
			// Run some update cycles
			for(var/i = 1; i <= 5; i++)
				optimizer.on_update()

			if(optimizer.processing_cycles > 0)
				result["details"] += "Performance monitoring active"
			else
				result["status"] = "FAIL"
				result["details"] += "Performance monitoring not working"

		qdel(test_SCP)
		qdel(test_scp)
	else
		result["status"] = "FAIL"
		result["details"] += "Failed to create test SCP"

	if(result["status"] == "PASS")
		passed_validations++
	else
		failed_validations++

	validation_results += list(result)

/datum/scp_integration_validator/proc/validate_scp_spawning_system()
	var/list/result = list("test" = "SCP Spawning System", "status" = "PASS", "details" = list())
	total_validations++

	// Test that SCP management interface can create human-based SCPs
	var/datum/scp_management_interface/test_interface = new()

	// Simulate creating an SCP-096 (which should be human-based now)
	var/mob/living/scp/scp096/test_scp = new /mob/living/scp/scp096()

	if(!test_scp)
		result["status"] = "FAIL"
		result["details"] += "Failed to create SCP-096 instance"
	else if(!istype(test_scp, /mob/living/carbon/human))
		result["status"] = "FAIL"
		result["details"] += "SCP-096 is not human-based"
	else if(!test_scp.SCP || !test_scp.SCP.uses_advanced_components)
		result["status"] = "FAIL"
		result["details"] += "SCP-096 does not have advanced components enabled"
	else
		result["details"] += "SCP spawning system properly creates human-based SCPs with components"

	// Cleanup
	if(test_scp)
		qdel(test_scp)
	qdel(test_interface)

	if(result["status"] == "PASS")
		passed_validations++
	else
		failed_validations++

	validation_results += list(result)

/datum/scp_integration_validator/proc/validate_component_communication()
	var/list/result = list("test" = "Component Communication", "status" = "PASS", "details" = list())
	total_validations++

	// Test inter-component communication
	var/mob/living/carbon/human/test_scp = new /mob/living/carbon/human()
	var/datum/scp/test_SCP = new /datum/scp(test_scp, "Test SCP", "Safe", "COMM_TEST", "SCP_SENTIENT")

	if(test_SCP)
		test_SCP.uses_advanced_components = TRUE
		test_SCP.compInit_advanced()

		var/datum/scp_advanced_component/communication_hub/comm_hub = test_SCP.get_component("communication_hub")

		if(!comm_hub)
			result["status"] = "FAIL"
			result["details"] += "Communication hub component not found"
		else
			// Test message queuing
			comm_hub.queue_message("skill_system", "test_message", list("data" = "test"))

			if(length(comm_hub.message_queue) > 0)
				result["details"] += "Component communication system functional"
			else
				result["status"] = "FAIL"
				result["details"] += "Message queuing failed"

		qdel(test_SCP)
		qdel(test_scp)
	else
		result["status"] = "FAIL"
		result["details"] += "Failed to create test SCP"

	if(result["status"] == "PASS")
		passed_validations++
	else
		failed_validations++

	validation_results += list(result)

/datum/scp_integration_validator/proc/get_validation_summary()
	var/list/summary = list()
	summary["total_validations"] = total_validations
	summary["passed_validations"] = passed_validations
	summary["failed_validations"] = failed_validations
	summary["success_rate"] = total_validations > 0 ? (passed_validations / total_validations) * 100 : 0
	summary["test_duration"] = test_duration
	summary["results"] = validation_results

	return summary

// Admin verb for running integration validation
/mob/proc/validate_scp_integration()
	set name = "Validate SCP Integration"
	set category = "SCP Testing"
	set desc = "Run comprehensive integration validation for the modular SCP system"

	if(!client || !check_rights(R_ADMIN))
		return

	to_chat(src, "<span class='notice'>Starting SCP integration validation...</span>")

	var/datum/scp_integration_validator/validator = new()
	var/list/summary = validator.run_full_validation()

	// Display results
	to_chat(src, "<span class='notice'>=== SCP Integration Validation Results ===</span>")
	to_chat(src, "<span class='notice'>Total Validations: [summary["total_validations"]]</span>")
	to_chat(src, "<span class='notice'>Passed: [summary["passed_validations"]]</span>")
	to_chat(src, "<span class='warning'>Failed: [summary["failed_validations"]]</span>")
	to_chat(src, "<span class='notice'>Success Rate: [round(summary["success_rate"], 0.1)]%</span>")
	to_chat(src, "<span class='notice'>Duration: [round(summary["test_duration"]/10, 0.1)] seconds</span>")

	// Show detailed results
	for(var/list/result in summary["results"])
		var/status_color = result["status"] == "PASS" ? "notice" : "warning"
		to_chat(src, "<span class='[status_color]'>[result["test"]]: [result["status"]]</span>")

		for(var/detail in result["details"])
			to_chat(src, "<span class='notice'>  - [detail]</span>")

	// Overall assessment
	if(summary["success_rate"] >= 90)
		to_chat(src, "<span class='boldnotice'>✅ INTEGRATION VALIDATION: EXCELLENT - System ready for production</span>")
	else if(summary["success_rate"] >= 75)
		to_chat(src, "<span class='notice'>✅ INTEGRATION VALIDATION: GOOD - Minor issues detected</span>")
	else if(summary["success_rate"] >= 50)
		to_chat(src, "<span class='warning'>⚠️ INTEGRATION VALIDATION: FAIR - Several issues need attention</span>")
	else
		to_chat(src, "<span class='danger'>❌ INTEGRATION VALIDATION: POOR - Major issues detected</span>")

	qdel(validator)
