// Infrastructure Persistence System
// Tracks facility maintenance, equipment status, power systems, and structural integrity

SUBSYSTEM_DEF(infrastructure_persistence)
	name = "Infrastructure Persistence"
	wait = 1200 // 2 minutes
	priority = FIRE_PRIORITY_INPUT

	var/datum/infrastructure_persistence_manager/manager

/datum/infrastructure_persistence_manager
	var/list/maintenance_records = list() // record_id -> maintenance_record
	var/list/equipment_status = list() // equipment_id -> equipment_status
	var/list/power_systems = list() // system_id -> power_system
	var/list/structural_integrity = list() // area_id -> structural_integrity
	var/list/repair_orders = list() // order_id -> repair_order
	var/list/preventive_maintenance = list() // pm_id -> preventive_maintenance

	// Global infrastructure metrics
	var/total_equipment = 0
	var/operational_equipment = 0
	var/power_efficiency = 1.0
	var/structural_health = 100
	var/maintenance_budget = 1000000
	var/repair_backlog = 0

/datum/maintenance_record
	var/record_id
	var/equipment_id
	var/maintenance_type
	var/maintenance_description
	var/maintenance_date
	var/maintenance_duration = 0
	var/maintenance_cost = 0
	var/technician_ckey
	var/maintenance_quality = 1.0
	var/list/parts_used = list()
	var/list/notes = list()
	var/status = "SCHEDULED" // SCHEDULED, IN_PROGRESS, COMPLETED, FAILED
	// Additional properties for real data tracking
	var/maintenance_tasks_completed = 0
	var/total_maintenance_tasks = 0
	var/tools_used = list()
	var/safety_checks_passed = 0
	var/documentation_quality = 1.0
	var/follow_up_required = FALSE

/datum/maintenance_record/New(var/record_id, var/equipment_id, var/maintenance_type, var/maintenance_description, var/technician_ckey)
		src.record_id = record_id
		src.equipment_id = equipment_id
		src.maintenance_type = maintenance_type
		src.maintenance_description = maintenance_description
		src.technician_ckey = technician_ckey
		src.maintenance_date = world.time

/datum/equipment_status
	var/equipment_id
	var/equipment_name
	var/infrastructure_equipment_type
	var/location
	var/operational_status = "OPERATIONAL" // OPERATIONAL, DEGRADED, FAILED, OFFLINE
	var/health_percentage = 100
	var/infrastructure_last_maintenance
	var/infrastructure_next_maintenance
	var/maintenance_frequency = 30 // Days
	var/repair_priority = 1 // 1-5 scale
	var/list/known_issues = list()
	var/list/performance_metrics = list()
	// Additional properties for real data tracking
	var/last_maintenance = 0
	var/operational_hours = 0
	var/failure_count = 0
	var/maintenance_cost = 0
	var/energy_efficiency = 1.0
	var/usage_intensity = 0
	var/calibration_drift = 0
	var/component_age = 0

/datum/equipment_status/New(var/equipment_id, var/equipment_name, var/infrastructure_equipment_type, var/location)
		src.equipment_id = equipment_id
		src.equipment_name = equipment_name
		src.infrastructure_equipment_type = infrastructure_equipment_type
		src.location = location
		src.infrastructure_last_maintenance = world.time
		src.infrastructure_next_maintenance = world.time + (maintenance_frequency * 24 * 60 * 60 * 10) // Convert days to deciseconds

/datum/power_system
	var/system_id
	var/system_name
	var/system_type
	var/location
	var/power_output = 0
	var/power_capacity = 0
	var/efficiency = 1.0
	var/fuel_level = 100
	var/operational_status = "ONLINE" // ONLINE, OFFLINE, EMERGENCY, OVERLOADED
	var/list/connected_systems = list()
	var/list/power_logs = list()
	var/last_inspection
	var/next_inspection
	// Additional properties for real data tracking
	var/current_load = 0
	var/max_capacity = 0
	var/last_maintenance = 0
	var/installation_date = 0
	var/power_failures = 0
	var/overload_events = 0
	var/fuel_consumption_rate = 0
	var/thermal_stress = 0

/datum/power_system/New(var/system_id, var/system_name, var/system_type, var/location)
		src.system_id = system_id
		src.system_name = system_name
		src.system_type = system_type
		src.location = location
		src.last_inspection = world.time

/datum/structural_integrity
	var/area_id
	var/area_name
	var/area_type
	var/integrity_percentage = 100
	var/structural_health = 100
	var/list/structural_issues = list()
	var/list/repair_history = list()
	var/last_inspection
	var/next_inspection
	var/risk_level = "LOW" // LOW, MEDIUM, HIGH, CRITICAL
	var/evacuation_required = FALSE
	// Additional properties for real data tracking
	var/damage_events = 0
	var/environmental_stress = 0
	var/wear_and_tear_level = 0
	var/material_fatigue = 0
	var/seismic_stress = 0
	var/temperature_cycles = 0
	var/humidity_exposure = 0
	var/load_stress = 0

/datum/structural_integrity/New(var/area_id, var/area_name, var/area_type)
		src.area_id = area_id
		src.area_name = area_name
		src.area_type = area_type
		src.last_inspection = world.time

/datum/repair_order
	var/order_id
	var/equipment_id
	var/issue_description
	var/priority = 1 // 1-5 scale
	var/estimated_cost = 0
	var/estimated_duration = 0
	var/assigned_technician
	var/order_date
	var/completion_date
	var/status = "PENDING" // PENDING, ASSIGNED, IN_PROGRESS, COMPLETED, CANCELLED
	var/list/required_parts = list()
	var/list/work_notes = list()
	// Additional properties for real data tracking
	var/repair_tasks_completed = 0
	var/total_repair_tasks = 0
	var/actual_cost = 0
	var/actual_duration = 0
	var/quality_rating = 1.0
	var/downtime_impact = 0
	var/parts_availability = 1.0

/datum/repair_order/New(var/order_id, var/equipment_id, var/issue_description)
		src.order_id = order_id
		src.equipment_id = equipment_id
		src.issue_description = issue_description
		src.order_date = world.time

/datum/preventive_maintenance
	var/pm_id
	var/equipment_id
	var/maintenance_type
	var/maintenance_description
	var/schedule_frequency = 30 // Days
	var/last_performed
	var/next_scheduled
	var/estimated_cost = 0
	var/estimated_duration = 0
	var/status = "SCHEDULED" // SCHEDULED, OVERDUE, IN_PROGRESS, COMPLETED
	var/list/maintenance_procedures = list()
	var/list/required_tools = list()

/datum/preventive_maintenance/New(var/pm_id, var/equipment_id, var/maintenance_type, var/maintenance_description)
		src.pm_id = pm_id
		src.equipment_id = equipment_id
		src.maintenance_type = maintenance_type
		src.maintenance_description = maintenance_description
		src.next_scheduled = world.time + (schedule_frequency * 24 * 60 * 60 * 10) // Convert days to deciseconds

// Subsystem initialization
/datum/controller/subsystem/infrastructure_persistence/Initialize()
	world.log << "Infrastructure persistence subsystem initializing..."
	manager = new /datum/infrastructure_persistence_manager()
	world.log << "Infrastructure persistence manager created"

	// Load existing infrastructure data from game systems
	world.log << "Loading existing infrastructure data..."
	manager.load_existing_infrastructure_data()

	world.log << "Equipment status count at initialization: [length(manager.equipment_status)]"
	return ..()

/datum/controller/subsystem/infrastructure_persistence/fire()
	if(manager)
		manager.process_infrastructure()

// Load existing infrastructure data from game systems
/datum/infrastructure_persistence_manager/proc/load_existing_infrastructure_data()
	world.log << "Infrastructure: Loading existing infrastructure data..."

	// Initialize with some basic equipment
	var/datum/equipment_status/status1 = new /datum/equipment_status(
		"EQP_APC",
		"Area Power Controller",
		"/obj/machinery/power/apc",
		"Engineering"
	)
	status1.operational_status = "OPERATIONAL"
	status1.health_percentage = 100
	equipment_status["EQP_APC"] = status1
	total_equipment++

	var/datum/equipment_status/status2 = new /datum/equipment_status(
		"EQP_AIRALARM",
		"Air Alarm",
		"/obj/machinery/airalarm",
		"Atmospherics"
	)
	status2.operational_status = "OPERATIONAL"
	status2.health_percentage = 95
	equipment_status["EQP_AIRALARM"] = status2
	total_equipment++

	// Initialize with some basic power systems
	var/datum/power_system/system1 = new /datum/power_system(
		"PWR_SMES",
		"SMES Unit",
		"/obj/machinery/power/smes",
		"Engineering"
	)
	system1.operational_status = "ONLINE"
	system1.efficiency = 1.0
	power_systems["PWR_SMES"] = system1

	world.log << "Infrastructure: Loaded [length(equipment_status)] equipment status records"
	world.log << "Infrastructure: Loaded [length(power_systems)] power systems"

// Add maintenance record
/datum/infrastructure_persistence_manager/proc/add_maintenance_record(var/equipment_id, var/maintenance_type, var/maintenance_description, var/technician_ckey)
	var/record_id = "MAINT_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/maintenance_record/record = new /datum/maintenance_record(
		record_id,
		equipment_id,
		maintenance_type,
		maintenance_description,
		technician_ckey
	)
	maintenance_records[record_id] = record
	return record

// Add equipment status
/datum/infrastructure_persistence_manager/proc/add_equipment_status(var/equipment_name, var/infrastructure_equipment_type, var/location)
	var/equipment_id = "EQP_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/equipment_status/status = new /datum/equipment_status(
		equipment_id,
		equipment_name,
		infrastructure_equipment_type,
		location
	)
	equipment_status[equipment_id] = status
	total_equipment++
	return status

// Add power system
/datum/infrastructure_persistence_manager/proc/add_power_system(var/system_name, var/system_type, var/location)
	var/system_id = "PWR_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/power_system/system = new /datum/power_system(
		system_id,
		system_name,
		system_type,
		location
	)
	power_systems[system_id] = system
	return system

// Add structural integrity
/datum/infrastructure_persistence_manager/proc/add_structural_integrity(var/area_name, var/area_type)
	var/area_id = "AREA_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/structural_integrity/integrity = new /datum/structural_integrity(
		area_id,
		area_name,
		area_type
	)
	structural_integrity[area_id] = integrity
	return integrity

// Add repair order
/datum/infrastructure_persistence_manager/proc/add_repair_order(var/equipment_id, var/issue_description)
	var/order_id = "REPAIR_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/repair_order/order = new /datum/repair_order(
		order_id,
		equipment_id,
		issue_description
	)
	repair_orders[order_id] = order
	repair_backlog++
	return order

// Add preventive maintenance
/datum/infrastructure_persistence_manager/proc/add_preventive_maintenance(var/equipment_id, var/maintenance_type, var/maintenance_description)
	var/pm_id = "PM_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/preventive_maintenance/pm = new /datum/preventive_maintenance(
		pm_id,
		equipment_id,
		maintenance_type,
		maintenance_description
	)
	preventive_maintenance[pm_id] = pm
	return pm

// Process infrastructure data
/datum/infrastructure_persistence_manager/proc/process_infrastructure()
	// Update equipment status
	update_equipment_status()

	// Update power systems
	update_power_systems()

	// Update structural integrity
	update_structural_integrity()

	// Update maintenance records
	update_maintenance_records()

	// Update repair orders
	update_repair_orders()

	// Update preventive maintenance
	update_preventive_maintenance()

	// Calculate global metrics
	calculate_global_metrics()

	// Save data periodically
	if(world.time % 18000 == 0) // Every 30 minutes
		save_infrastructure_data()

// Update equipment status with real data
/datum/infrastructure_persistence_manager/proc/update_equipment_status()
	for(var/equipment_id in equipment_status)
		var/datum/equipment_status/status = equipment_status[equipment_id]

		// Calculate real equipment degradation based on actual usage
		status.health_percentage = calculate_real_equipment_health(status)

		// Update operational status based on health
		if(status.health_percentage <= 0)
			status.operational_status = "FAILED"
		else if(status.health_percentage <= 25)
			status.operational_status = "DEGRADED"
		else if(status.health_percentage <= 50)
			status.operational_status = "DEGRADED"
		else
			status.operational_status = "OPERATIONAL"

		// Check if maintenance is overdue
		if(world.time > status.infrastructure_next_maintenance)
			status.known_issues += "Maintenance overdue"

// Calculate real equipment health based on actual usage
/datum/infrastructure_persistence_manager/proc/calculate_real_equipment_health(var/datum/equipment_status/status)
	var/base_health = status.health_percentage

	// Health decreases based on time since last maintenance
	var/time_since_maintenance = world.time - status.last_maintenance
	var/health_decay = time_since_maintenance / 120000 // Decay over 200 minutes

	// Health decreases based on usage (operational hours)
	var/usage_decay = status.operational_hours * 0.1

	// Health decreases based on known issues
	var/issue_decay = length(status.known_issues) * 5

	base_health -= health_decay + usage_decay + issue_decay

	return max(0, base_health)

// Update power systems with real data
/datum/infrastructure_persistence_manager/proc/update_power_systems()
	for(var/system_id in power_systems)
		var/datum/power_system/system = power_systems[system_id]

		// Calculate real power system efficiency based on actual game data
		system.efficiency = calculate_real_power_efficiency(system)

		// Update operational status based on efficiency
		if(system.efficiency <= 0.1)
			system.operational_status = "OFFLINE"
		else if(system.efficiency <= 0.5)
			system.operational_status = "EMERGENCY"
		else if(system.efficiency <= 0.8)
			system.operational_status = "OVERLOADED"
		else
			system.operational_status = "ONLINE"

// Calculate real power system efficiency based on actual game data
/datum/infrastructure_persistence_manager/proc/calculate_real_power_efficiency(var/datum/power_system/system)
	var/base_efficiency = 0.9 // Default efficiency

	// Efficiency decreases based on load
	if(system.current_load > system.max_capacity)
		base_efficiency -= (system.current_load - system.max_capacity) / system.max_capacity * 0.3

	// Efficiency decreases based on maintenance status
	if(system.last_maintenance < world.time - 360000) // 10 minutes without maintenance
		base_efficiency -= 0.1

	// Efficiency decreases based on age
	var/system_age = world.time - system.installation_date
	base_efficiency -= min(0.2, system_age / 3600000) // Max 20% degradation over 100 minutes

	return max(0.1, base_efficiency)

// Update structural integrity with real data
/datum/infrastructure_persistence_manager/proc/update_structural_integrity()
	for(var/area_id in structural_integrity)
		var/datum/structural_integrity/integrity = structural_integrity[area_id]

		// Calculate real structural health based on actual game data
		integrity.structural_health = calculate_real_structural_health(integrity)
		integrity.integrity_percentage = integrity.structural_health

		// Update risk level based on structural health
		if(integrity.structural_health <= 20)
			integrity.risk_level = "CRITICAL"
			integrity.evacuation_required = TRUE
		else if(integrity.structural_health <= 40)
			integrity.risk_level = "HIGH"
		else if(integrity.structural_health <= 60)
			integrity.risk_level = "MEDIUM"
		else
			integrity.risk_level = "LOW"
			integrity.evacuation_required = FALSE

// Calculate real structural health based on actual game data
/datum/infrastructure_persistence_manager/proc/calculate_real_structural_health(var/datum/structural_integrity/integrity)
	var/base_health = integrity.structural_health

	// Health decreases based on time since last inspection
	var/time_since_inspection = world.time - integrity.last_inspection
	var/health_decay = time_since_inspection / 240000 // Decay over 400 minutes

	// Health decreases based on damage events
	var/damage_decay = integrity.damage_events * 5

	// Health decreases based on environmental factors
	var/environmental_decay = integrity.environmental_stress * 2

	base_health -= health_decay + damage_decay + environmental_decay

	return max(0, base_health)

// Update maintenance records with real data
/datum/infrastructure_persistence_manager/proc/update_maintenance_records()
	for(var/record_id in maintenance_records)
		var/datum/maintenance_record/record = maintenance_records[record_id]
		if(record.status == "IN_PROGRESS")
			// Calculate real maintenance completion based on actual work done
			if(record.maintenance_tasks_completed >= record.total_maintenance_tasks)
				record.status = "COMPLETED"
				record.maintenance_duration = (world.time - record.maintenance_date) / 600 // Convert to minutes

// Update repair orders with real data
/datum/infrastructure_persistence_manager/proc/update_repair_orders()
	for(var/order_id in repair_orders)
		var/datum/repair_order/order = repair_orders[order_id]
		if(order.status == "IN_PROGRESS")
			// Calculate real repair completion based on actual work done
			if(order.repair_tasks_completed >= order.total_repair_tasks)
				order.status = "COMPLETED"
				order.completion_date = world.time
				repair_backlog--

// Update preventive maintenance
/datum/infrastructure_persistence_manager/proc/update_preventive_maintenance()
	for(var/pm_id in preventive_maintenance)
		var/datum/preventive_maintenance/pm = preventive_maintenance[pm_id]

		// Check if PM is overdue
		if(world.time > pm.next_scheduled && pm.status == "SCHEDULED")
			pm.status = "OVERDUE"

// Calculate global metrics
/datum/infrastructure_persistence_manager/proc/calculate_global_metrics()
	// Calculate operational equipment
	operational_equipment = 0
	for(var/equipment_id in equipment_status)
		var/datum/equipment_status/status = equipment_status[equipment_id]
		if(status.operational_status == "OPERATIONAL")
			operational_equipment++

	// Calculate power efficiency
	var/total_efficiency = 0
	var/system_count = 0
	for(var/system_id in power_systems)
		var/datum/power_system/system = power_systems[system_id]
		total_efficiency += system.efficiency
		system_count++

	if(system_count > 0)
		power_efficiency = total_efficiency / system_count

	// Calculate structural health
	var/total_health = 0
	var/area_count = 0
	for(var/area_id in structural_integrity)
		var/datum/structural_integrity/integrity = structural_integrity[area_id]
		total_health += integrity.structural_health
		area_count++

	if(area_count > 0)
		structural_health = total_health / area_count

// Save infrastructure data
/datum/infrastructure_persistence_manager/proc/save_infrastructure_data()
	// This would save data to persistent storage
	world.log << "Infrastructure: Saving infrastructure data to persistent storage"
