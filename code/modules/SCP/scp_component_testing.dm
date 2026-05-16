// SCP Component Testing System
// Comprehensive testing framework for validating component system functionality

// Test Results Enumeration
#define TEST_RESULT_PASS     1
#define TEST_RESULT_FAIL     2
#define TEST_RESULT_SKIP     3
#define TEST_RESULT_ERROR    4

// Test Categories
#define TEST_CATEGORY_UNIT        "unit"
#define TEST_CATEGORY_INTEGRATION "integration"
#define TEST_CATEGORY_PERFORMANCE "performance"
#define TEST_CATEGORY_STRESS      "stress"

// Component Test Base Class
/datum/component_test
	var/test_name = "Base Test"
	var/test_description = "A base component test"
	var/test_category = TEST_CATEGORY_UNIT
	var/test_priority = 1

	var/test_result = TEST_RESULT_SKIP
	var/test_duration = 0
	var/test_start_time = 0
	var/test_error_message = ""
	var/test_details = list()

	var/required_components = list()
	var/test_dependencies = list()

/datum/component_test/proc/run_test(datum/component_manager_advanced/manager)
	test_start_time = world.time
	test_result = TEST_RESULT_SKIP

	// Check dependencies
	if(!check_test_dependencies(manager))
		test_result = TEST_RESULT_SKIP
		test_error_message = "Test dependencies not met"
		return

	// Run the actual test
	var/success = execute_test(manager)

	test_duration = world.time - test_start_time

	if(success)
		test_result = TEST_RESULT_PASS
	else
		test_result = TEST_RESULT_FAIL

/datum/component_test/proc/check_test_dependencies(datum/component_manager_advanced/manager)
	for(var/component_type in required_components)
		if(!manager.get_component(component_type))
			return FALSE
	return TRUE

/datum/component_test/proc/execute_test(datum/component_manager_advanced/manager)
	// Override in subclasses
	return TRUE

// Component Manager Test Suite
/datum/component_test_suite
	var/suite_name = "Component Test Suite"
	var/list/tests = list()
	var/list/test_results = list()
	var/total_tests = 0
	var/passed_tests = 0
	var/failed_tests = 0
	var/skipped_tests = 0
	var/error_tests = 0

	var/suite_start_time = 0
	var/suite_duration = 0

/datum/component_test_suite/proc/add_test(datum/component_test/test)
	tests += test

/datum/component_test_suite/proc/run_suite(datum/component_manager_advanced/manager)
	suite_start_time = world.time
	total_tests = length(tests)
	passed_tests = 0
	failed_tests = 0
	skipped_tests = 0
	error_tests = 0

	test_results.Cut()

	for(var/datum/component_test/test in tests)
		test.run_test(manager)
		test_results += list(test)

		switch(test.test_result)
			if(TEST_RESULT_PASS)
				passed_tests++
			if(TEST_RESULT_FAIL)
				failed_tests++
			if(TEST_RESULT_SKIP)
				skipped_tests++
			if(TEST_RESULT_ERROR)
				error_tests++

	suite_duration = world.time - suite_start_time

/datum/component_test_suite/proc/get_suite_summary()
	var/list/summary = list()
	summary["suite_name"] = suite_name
	summary["total_tests"] = total_tests
	summary["passed_tests"] = passed_tests
	summary["failed_tests"] = failed_tests
	summary["skipped_tests"] = skipped_tests
	summary["error_tests"] = error_tests
	summary["suite_duration"] = suite_duration
	summary["success_rate"] = total_tests > 0 ? (passed_tests / total_tests) * 100 : 0

	return summary

// Specific Component Tests

// Skill System Tests
/datum/component_test/skill_system_basic
	test_name = "Skill System Basic Functionality"
	test_description = "Tests basic skill system operations"
	test_category = TEST_CATEGORY_UNIT
	required_components = list("skill_system")

/datum/component_test/skill_system_basic/execute_test(datum/component_manager_advanced/manager)
	var/datum/scp_advanced_component/advanced_skill_system/skill_system = manager.get_component("skill_system")
	if(!skill_system)
		return FALSE

	// Test skill addition
	skill_system.add_skill("Test Skill", 30 SECONDS, list("requires_proximity"))
	if(!("Test Skill" in skill_system.skills))
		test_error_message = "Failed to add skill"
		return FALSE

	// Test skill usage
	if(!skill_system.can_use_skill("Test Skill"))
		test_error_message = "Skill should be available immediately after addition"
		return FALSE

	// Test cooldown
	skill_system.use_skill("Test Skill")
	if(skill_system.can_use_skill("Test Skill"))
		test_error_message = "Skill should be on cooldown after use"
		return FALSE

	return TRUE

/datum/component_test/skill_system_experience
	test_name = "Skill System Experience Tracking"
	test_description = "Tests skill experience and leveling system"
	test_category = TEST_CATEGORY_UNIT
	required_components = list("skill_system")

/datum/component_test/skill_system_experience/execute_test(datum/component_manager_advanced/manager)
	var/datum/scp_advanced_component/advanced_skill_system/skill_system = manager.get_component("skill_system")
	if(!skill_system)
		return FALSE

	// Add a skill and gain experience
	skill_system.add_skill("Experience Test", 10 SECONDS, list())
	skill_system.gain_skill_experience("Experience Test", 100)

	var/list/skill_data = skill_system.skills["Experience Test"]
	if(!skill_data || skill_data["experience"] < 100)
		test_error_message = "Experience not properly tracked"
		return FALSE

	return TRUE

// Containment System Tests
/datum/component_test/containment_system_basic
	test_name = "Containment System Basic Functionality"
	test_description = "Tests basic containment system operations"
	test_category = TEST_CATEGORY_UNIT
	required_components = list("containment_system")

/datum/component_test/containment_system_basic/execute_test(datum/component_manager_advanced/manager)
	var/datum/scp_advanced_component/advanced_containment_system/containment = manager.get_component("containment_system")
	if(!containment)
		return FALSE

	// Test containment integrity
	var/initial_integrity = containment.containment_integrity
	containment.adjust_containment_integrity(-10)

	if(containment.containment_integrity >= initial_integrity)
		test_error_message = "Containment damage not applied"
		return FALSE

	// Test containment repair
	containment.adjust_containment_integrity(5)
	if(containment.containment_integrity <= initial_integrity - 10)
		test_error_message = "Containment repair not applied"
		return FALSE

	return TRUE

// Performance Tests
/datum/component_test/performance_basic
	test_name = "Component Performance Basic"
	test_description = "Tests basic component performance characteristics"
	test_category = TEST_CATEGORY_PERFORMANCE
	required_components = list("performance_optimizer")

/datum/component_test/performance_basic/execute_test(datum/component_manager_advanced/manager)
	var/datum/scp_advanced_component/performance_optimizer/optimizer = manager.get_component("performance_optimizer")
	if(!optimizer)
		return FALSE

	// Simulate some processing cycles
	for(var/i = 1; i <= 10; i++)
		optimizer.on_update()

	// Check that performance metrics are being tracked
	if(optimizer.processing_cycles == 0)
		test_error_message = "Performance metrics not being tracked"
		return FALSE

	// Check that optimization level is reasonable
	if(optimizer.optimization_level < 1 || optimizer.optimization_level > 5)
		test_error_message = "Optimization level out of expected range"
		return FALSE

	return TRUE

// Integration Tests
/datum/component_test/integration_skill_containment
	test_name = "Skill-Containment Integration"
	test_description = "Tests integration between skill and containment systems"
	test_category = TEST_CATEGORY_INTEGRATION
	required_components = list("skill_system", "containment_system")

/datum/component_test/integration_skill_containment/execute_test(datum/component_manager_advanced/manager)
	var/datum/scp_advanced_component/advanced_skill_system/skill_system = manager.get_component("skill_system")
	var/datum/scp_advanced_component/advanced_containment_system/containment = manager.get_component("containment_system")

	if(!skill_system || !containment)
		return FALSE

	// Test that containment damage affects skill requirements
	containment.adjust_containment_integrity(-50)

	// Add a skill that requires containment integrity
	skill_system.add_skill("Containment Skill", 30 SECONDS, list("requires_containment"))

	// The skill should not be available when containment is damaged
	if(skill_system.can_use_skill("Containment Skill"))
		test_error_message = "Skill should not be available with damaged containment"
		return FALSE

	return TRUE

// Stress Tests
/datum/component_test/stress_many_skills
	test_name = "Stress Test - Many Skills"
	test_description = "Tests system performance with many skills"
	test_category = TEST_CATEGORY_STRESS
	required_components = list("skill_system")

/datum/component_test/stress_many_skills/execute_test(datum/component_manager_advanced/manager)
	var/datum/scp_advanced_component/advanced_skill_system/skill_system = manager.get_component("skill_system")
	if(!skill_system)
		return FALSE

	// Add many skills rapidly
	for(var/i = 1; i <= 50; i++)
		skill_system.add_skill("Stress Skill [i]", 10 SECONDS, list())

	// Check that all skills were added
	if(length(skill_system.skills) < 50)
		test_error_message = "Not all skills were added during stress test"
		return FALSE

	// Test that the system can still process skills
	var/processed_count = 0
	for(var/skill_name in skill_system.skills)
		if(skill_system.can_use_skill(skill_name))
			processed_count++

	if(processed_count == 0)
		test_error_message = "System cannot process skills after stress test"
		return FALSE

	return TRUE

// Component Testing Manager
/datum/component_testing_manager
	var/list/test_suites = list()
	var/list/global_results = list()
	var/testing_enabled = TRUE
	var/auto_test_interval = 300 SECONDS // 5 minutes
	var/last_test_time = 0

/datum/component_testing_manager/proc/add_test_suite(datum/component_test_suite/suite)
	test_suites += suite

/datum/component_testing_manager/proc/run_all_tests(datum/component_manager_advanced/manager)
	if(!testing_enabled)
		return

	last_test_time = world.time

	for(var/datum/component_test_suite/suite in test_suites)
		suite.run_suite(manager)
		global_results += list(suite.get_suite_summary())

/datum/component_testing_manager/proc/get_global_summary()
	var/list/summary = list()
	summary["total_suites"] = length(test_suites)
	summary["total_tests"] = 0
	summary["total_passed"] = 0
	summary["total_failed"] = 0
	summary["total_skipped"] = 0
	summary["total_errors"] = 0

	for(var/list/suite_result in global_results)
		summary["total_tests"] += suite_result["total_tests"]
		summary["total_passed"] += suite_result["passed_tests"]
		summary["total_failed"] += suite_result["failed_tests"]
		summary["total_skipped"] += suite_result["skipped_tests"]
		summary["total_errors"] += suite_result["error_tests"]

	summary["overall_success_rate"] = summary["total_tests"] > 0 ? (summary["total_passed"] / summary["total_tests"]) * 100 : 0

	return summary

// Verb for running component tests
/mob/proc/run_component_tests()
	set name = "Run Component Tests"
	set category = "SCP Testing"
	set desc = "Run comprehensive component system tests"

	if(!client || !check_rights(R_ADMIN))
		return

	var/datum/component_testing_manager/testing_manager = new()

	// Add test suites
	var/datum/component_test_suite/unit_suite = new()
	unit_suite.suite_name = "Unit Tests"
	unit_suite.add_test(new /datum/component_test/skill_system_basic())
	unit_suite.add_test(new /datum/component_test/skill_system_experience())
	unit_suite.add_test(new /datum/component_test/containment_system_basic())
	testing_manager.add_test_suite(unit_suite)

	var/datum/component_test_suite/integration_suite = new()
	integration_suite.suite_name = "Integration Tests"
	integration_suite.add_test(new /datum/component_test/integration_skill_containment())
	testing_manager.add_test_suite(integration_suite)

	var/datum/component_test_suite/performance_suite = new()
	performance_suite.suite_name = "Performance Tests"
	performance_suite.add_test(new /datum/component_test/performance_basic())
	testing_manager.add_test_suite(performance_suite)

	var/datum/component_test_suite/stress_suite = new()
	stress_suite.suite_name = "Stress Tests"
	stress_suite.add_test(new /datum/component_test/stress_many_skills())
	testing_manager.add_test_suite(stress_suite)

	// Run tests if we have an SCP with components
	if(SCP && SCP.uses_advanced_components)
		testing_manager.run_all_tests(SCP.advanced_components)

		var/list/global_summary = testing_manager.get_global_summary()

		to_chat(src, "<span class='notice'>=== Component Test Results ===</span>")
		to_chat(src, "<span class='notice'>Total Tests: [global_summary["total_tests"]]</span>")
		to_chat(src, "<span class='notice'>Passed: [global_summary["total_passed"]]</span>")
		to_chat(src, "<span class='warning'>Failed: [global_summary["total_failed"]]</span>")
		to_chat(src, "<span class='notice'>Skipped: [global_summary["total_skipped"]]</span>")
		to_chat(src, "<span class='danger'>Errors: [global_summary["total_errors"]]</span>")
		to_chat(src, "<span class='notice'>Success Rate: [round(global_summary["overall_success_rate"], 0.1)]%</span>")
	else
		to_chat(src, "<span class='warning'>No SCP with advanced components found for testing.</span>")
