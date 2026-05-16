SUBSYSTEM_DEF(facility_persistence)
	name = "Facility Persistence"
	wait = 600 // Check every 10 seconds
	priority = FIRE_PRIORITY_PERSISTENT_PROGRESSION
	var/datum/facility_persistence_manager/manager

/datum/controller/subsystem/facility_persistence/Initialize()
	manager = new /datum/facility_persistence_manager()
	world.log << "Facility Persistence Subsystem: Initialized"
	return ..()

/datum/controller/subsystem/facility_persistence/fire()
	if(manager)
		manager.process_facility()

// Facility Persistence Manager
/datum/facility_persistence_manager
	var/list/room_states = list()
	var/list/equipment_status = list()
	var/list/security_systems = list()
	var/list/power_grid = list()
	var/list/environmental_conditions = list()
	var/list/containment_chambers = list()
	var/list/research_labs = list()
	var/list/medical_facilities = list()
	var/list/engineering_systems = list()
	var/last_round_id = ""
	var/facility_age = 0
	var/facility_health = 100
	var/maintenance_level = 50
	var/security_level = 1
	var/power_efficiency = 1.0
	var/containment_stability = 100

/datum/facility_persistence_manager/proc/process_facility()
	// Update facility states
	update_room_states()
	update_equipment_status()
	update_security_systems()
	update_power_grid()
	update_environmental_conditions()
	update_containment_chambers()
	update_research_labs()
	update_medical_facilities()
	update_engineering_systems()

	// Calculate overall facility health
	calculate_facility_health()

	// Save data periodically
	if(world.time % 3000 == 0) // Every 5 minutes
		save_facility_data()

/datum/facility_persistence_manager/proc/update_room_states()
	for(var/area/A in GLOB.areas)
		if(A.type in room_states)
			var/datum/room_state/state = room_states[A.type]
			state.update_state(A)
		else
			var/datum/room_state/new_state = new /datum/room_state(A.type)
			room_states[A.type] = new_state
			new_state.update_state(A)

/datum/facility_persistence_manager/proc/update_equipment_status()
	for(var/obj/machinery/M as anything in INSTANCES_OF(/obj/machinery))
		if(M.type in equipment_status)
			var/datum/equipment_status/status = equipment_status[M.type]
			status.update_status(M)
		else
			var/datum/equipment_status/new_status = new /datum/equipment_status(M.type)
			equipment_status[M.type] = new_status
			new_status.update_status(M)

/datum/facility_persistence_manager/proc/update_security_systems()
	for(var/obj/machinery/camera/C as anything in INSTANCES_OF(/obj/machinery/camera))
		update_security_component(C, "camera")

	for(var/obj/machinery/door/airlock/A as anything in INSTANCES_OF(/obj/machinery/door/airlock))
		update_security_component(A, "airlock")

	for(var/obj/machinery/computer/security/S as anything in INSTANCES_OF(/obj/machinery/computer/security))
		update_security_component(S, "security_console")

/datum/facility_persistence_manager/proc/update_security_component(var/obj/component, var/component_type)
	var/key = "[component_type]_[component.type]"
	if(key in security_systems)
		var/datum/security_component/comp = security_systems[key]
		comp.update_status(component)
	else
		var/datum/security_component/new_comp = new /datum/security_component(component_type, component.type)
		security_systems[key] = new_comp
		new_comp.update_status(component)

/datum/facility_persistence_manager/proc/update_power_grid()
	// Update power grid status with real data
	var/total_power = 0
	var/active_power = 0


	for(var/obj/machinery/power/P as anything in INSTANCES_OF(/obj/machinery/power))
		if(istype(P, /obj/machinery/power/generator))
			// Calculate real power output based on generator type and condition
			var/power_output = calculate_real_power_output(P)
			total_power += power_output
		else if(istype(P, /obj/machinery/power/apc))
			// Calculate real power usage based on connected equipment
			var/power_usage = calculate_real_power_usage(P)
			active_power += power_usage

	power_efficiency = total_power > 0 ? min(1.0, active_power / total_power) : 0

// Calculate real power output based on generator type and condition
/datum/facility_persistence_manager/proc/calculate_real_power_output(var/obj/machinery/power/generator)
	var/base_output = 1000 // Default output

	// Adjust based on generator type
	if(istype(generator, /obj/machinery/power/supermatter))
		base_output = 5000
	else if(istype(generator, /obj/machinery/power/generator))
		base_output = 3000

	// Adjust based on generator health/damage (simplified)
	if(generator.density)
		base_output *= 0.8 // Assume some wear if dense

	return base_output

// Calculate real power usage based on connected equipment
/datum/facility_persistence_manager/proc/calculate_real_power_usage(var/obj/machinery/power/apc)
	var/total_usage = 0

	// Calculate usage from connected equipment (simplified)
	for(var/obj/machinery/M in get_area(apc))
		if(M.density)
			total_usage += 50 // Base power usage for dense machinery

	return total_usage

/datum/facility_persistence_manager/proc/update_environmental_conditions()
	// Update environmental conditions for each area
	for(var/area/A in GLOB.areas)
		if(A.type in environmental_conditions)
			var/datum/environmental_condition/condition = environmental_conditions[A.type]
			condition.update_condition(A)
		else
			var/datum/environmental_condition/new_condition = new /datum/environmental_condition(A.type)
			environmental_conditions[A.type] = new_condition
			new_condition.update_condition(A)

/datum/facility_persistence_manager/proc/update_containment_chambers()
	// Update SCP containment chamber status
	for(var/area/A in GLOB.areas)
		if(findtext(A.name, "containment") || findtext(A.name, "SCP"))
			if(A.type in containment_chambers)
				var/datum/containment_chamber/chamber = containment_chambers[A.type]
				chamber.update_status(A)
			else
				var/datum/containment_chamber/new_chamber = new /datum/containment_chamber(A.type)
				containment_chambers[A.type] = new_chamber
				new_chamber.update_status(A)

/datum/facility_persistence_manager/proc/update_research_labs()
	// Update research laboratory status
	for(var/area/A in GLOB.areas)
		if(findtext(A.name, "research") || findtext(A.name, "lab"))
			if(A.type in research_labs)
				var/datum/research_lab/lab = research_labs[A.type]
				lab.update_status(A)
			else
				var/datum/research_lab/new_lab = new /datum/research_lab(A.type)
				research_labs[A.type] = new_lab
				new_lab.update_status(A)

/datum/facility_persistence_manager/proc/update_medical_facilities()
	// Update medical facility status
	for(var/area/A in GLOB.areas)
		if(findtext(A.name, "medical") || findtext(A.name, "medbay"))
			if(A.type in medical_facilities)
				var/datum/medical_facility/facility = medical_facilities[A.type]
				facility.update_status(A)
			else
				var/datum/medical_facility/new_facility = new /datum/medical_facility(A.type)
				medical_facilities[A.type] = new_facility
				new_facility.update_status(A)

/datum/facility_persistence_manager/proc/update_engineering_systems()
	// Update engineering system status
	for(var/area/A in GLOB.areas)
		if(findtext(A.name, "engineering") || findtext(A.name, "engine"))
			if(A.type in engineering_systems)
				var/datum/engineering_system/system = engineering_systems[A.type]
				system.update_status(A)
			else
				var/datum/engineering_system/new_system = new /datum/engineering_system(A.type)
				engineering_systems[A.type] = new_system
				new_system.update_status(A)

/datum/facility_persistence_manager/proc/calculate_facility_health()
	var/total_health = 0
	var/component_count = 0

	// Calculate average room health
	for(var/type in room_states)
		var/datum/room_state/state = room_states[type]
		total_health += state.health
		component_count++

	// Calculate average equipment health
	for(var/type in equipment_status)
		var/datum/equipment_status/status = equipment_status[type]
		total_health += status.health
		component_count++

	// Calculate average security system health
	for(var/key in security_systems)
		var/datum/security_component/comp = security_systems[key]
		total_health += comp.health
		component_count++

	if(component_count > 0)
		facility_health = total_health / component_count

	// Update maintenance level based on facility health
	maintenance_level = facility_health

/datum/facility_persistence_manager/proc/save_facility_data()
	var/list/data = list(
		"room_states" = room_states,
		"equipment_status" = equipment_status,
		"security_systems" = security_systems,
		"power_grid" = power_grid,
		"environmental_conditions" = environmental_conditions,
		"containment_chambers" = containment_chambers,
		"research_labs" = research_labs,
		"medical_facilities" = medical_facilities,
		"engineering_systems" = engineering_systems,
		"facility_age" = facility_age,
		"facility_health" = facility_health,
		"maintenance_level" = maintenance_level,
		"security_level" = security_level,
		"power_efficiency" = power_efficiency,
		"containment_stability" = containment_stability
	)

	// Save to JSON file
	var/filename = "data/facility_persistence.json"
	fdel(filename)
	text2file(json_encode(data), filename)

/datum/facility_persistence_manager/proc/load_facility_data()
	var/filename = "data/facility_persistence.json"
	if(fexists(filename))
		var/json_data = file2text(filename)
		var/list/data = json_decode(json_data)

		if(data)
			room_states = data["room_states"] || list()
			equipment_status = data["equipment_status"] || list()
			security_systems = data["security_systems"] || list()
			power_grid = data["power_grid"] || list()
			environmental_conditions = data["environmental_conditions"] || list()
			containment_chambers = data["containment_chambers"] || list()
			research_labs = data["research_labs"] || list()
			medical_facilities = data["medical_facilities"] || list()
			engineering_systems = data["engineering_systems"] || list()
			facility_age = data["facility_age"] || 0
			facility_health = data["facility_health"] || 100
			maintenance_level = data["maintenance_level"] || 50
			security_level = data["security_level"] || 1
			power_efficiency = data["power_efficiency"] || 1.0
			containment_stability = data["containment_stability"] || 100

// Room State Datum
/datum/room_state
	var/room_type
	var/health = 100
	var/damage_level = 0
	var/repair_status = 100
	var/list/modifications = list()
	var/last_inspected = 0
	var/security_level = 1
	var/power_status = 1
	var/air_quality = 100
	var/temperature = 293 // Kelvin
	var/humidity = 50

/datum/room_state/New(var/type)
	room_type = type

/datum/room_state/proc/update_state(var/area/A)
	// Update room state based on current area condition with real data
	if(A)
		// Calculate real damage based on actual area state
		var/damage = calculate_real_room_damage(A)
		damage_level = damage
		health = max(0, 100 - damage_level * 100)

		// Calculate real power status
		power_status = calculate_real_power_status(A)

		// Calculate real environmental conditions
		air_quality = calculate_real_air_quality(A)
		temperature = calculate_real_temperature(A)
		humidity = calculate_real_humidity(A)

		// Update last inspection time
		last_inspected = world.time

// Calculate real room damage based on actual area state
/datum/room_state/proc/calculate_real_room_damage(var/area/A)
	var/total_damage = 0
	var/turf_count = 0

	for(var/turf/T in A)
		turf_count++
		if(T.density)
			total_damage += 0.1

		// Check for damage from objects in the area (simplified)
		for(var/obj/O in T)
			if(O.density)
				total_damage += 0.05

	return turf_count > 0 ? total_damage / turf_count : 0

// Calculate real power status based on area power systems
/datum/room_state/proc/calculate_real_power_status(var/area/A)
	var/power_systems = 0
	var/operational_systems = 0

	for(var/obj/machinery/power/P in A)
		power_systems++
		if(P.density) // Simplified operational check
			operational_systems++

	return power_systems > 0 ? operational_systems / power_systems : 1

// Calculate real air quality based on area conditions
/datum/room_state/proc/calculate_real_air_quality(var/area/A)
	var/base_quality = 100

	// Reduce quality based on damage
	base_quality -= damage_level * 30

	// Reduce quality based on number of dense objects (simplified)
	var/dense_objects = 0
	for(var/obj/O in A)
		if(O.density)
			dense_objects++

	base_quality -= dense_objects * 1

	return max(0, base_quality)

// Calculate real temperature based on area conditions
/datum/room_state/proc/calculate_real_temperature(var/area/A)
	var/base_temp = 293 // 20°C

	// Adjust based on damage (damaged areas may have temperature issues)
	base_temp += damage_level * 15

	// Adjust based on power status (no power = colder)
	if(power_status < 0.5)
		base_temp -= 10

	return base_temp

// Calculate real humidity based on area conditions
/datum/room_state/proc/calculate_real_humidity(var/area/A)
	var/base_humidity = 50

	// Adjust based on damage (damaged areas may have humidity issues)
	base_humidity += damage_level * 20

	// Adjust based on power status (no power = different humidity)
	if(power_status < 0.5)
		base_humidity += 10

	return max(0, min(100, base_humidity))

// Equipment Status Datum
/datum/equipment_status
	var/equipment_type
	var/health = 100
	var/operational = TRUE
	var/efficiency = 1.0
	var/facility_last_maintenance = 0
	var/maintenance_required = FALSE
	var/list/upgrades = list()
	var/power_consumption = 0
	var/heat_generation = 0

/datum/equipment_status/New(var/type)
	equipment_type = type

/datum/equipment_status/proc/update_status(var/obj/machinery/M)
	if(M)
		// Calculate real operational status
		operational = M.density

		// Calculate real health based on actual damage
		health = calculate_real_equipment_health(M)

		// Check if maintenance is required based on real conditions
		maintenance_required = health < 50 || (world.time - facility_last_maintenance) > 360000 // 10 minutes

		// Calculate real efficiency
		efficiency = health / 100

		// Calculate real power consumption
		power_consumption = calculate_real_power_consumption(M)

		// Calculate real heat generation
		heat_generation = calculate_real_heat_generation(M)

		// Update maintenance timestamp
		if(maintenance_required)
			facility_last_maintenance = world.time

// Calculate real equipment health based on actual damage
/datum/equipment_status/proc/calculate_real_equipment_health(var/obj/machinery/M)
	var/base_health = 100

	// Reduce health based on operational status (simplified)
	if(!M.density)
		base_health *= 0.5

	// Reduce health based on time since last maintenance
	var/time_since_maintenance = world.time - facility_last_maintenance
	if(time_since_maintenance > 360000) // 10 minutes
		base_health -= min(20, time_since_maintenance / 3600000 * 10)

	return max(0, base_health)

// Calculate real power consumption based on equipment type and usage
/datum/equipment_status/proc/calculate_real_power_consumption(var/obj/machinery/M)
	var/base_consumption = 100

	// Adjust based on equipment type
	if(istype(M, /obj/machinery/power))
		base_consumption = 500
	else if(istype(M, /obj/machinery/atmospherics))
		base_consumption = 200
	else if(istype(M, /obj/machinery/computer))
		base_consumption = 50

	// Adjust based on operational status (simplified)
	if(!M.density)
		base_consumption *= 0.1 // Minimal power when not operational

	// Adjust based on efficiency
	base_consumption *= efficiency

	return base_consumption

// Calculate real heat generation based on equipment type and usage
/datum/equipment_status/proc/calculate_real_heat_generation(var/obj/machinery/M)
	var/base_heat = 10

	// Adjust based on equipment type
	if(istype(M, /obj/machinery/power))
		base_heat = 50
	else if(istype(M, /obj/machinery/atmospherics))
		base_heat = 20
	else if(istype(M, /obj/machinery/computer))
		base_heat = 5

	// Adjust based on operational status (simplified)
	if(!M.density)
		base_heat *= 0.1

	// Adjust based on efficiency (less efficient = more heat)
	base_heat *= (2.0 - efficiency)

	return base_heat

// Security Component Datum
/datum/security_component
	var/component_type
	var/component_class
	var/health = 100
	var/operational = TRUE
	var/security_level = 1
	var/last_maintenance = 0
	var/list/access_logs = list()
	var/alert_status = 0

/datum/security_component/New(var/type, var/class)
	component_type = type
	component_class = class

/datum/security_component/proc/update_status(var/obj/component)
	if(component)
		// Calculate real operational status
		operational = component.density

		// Calculate real health based on actual damage
		health = calculate_real_security_health(component)

		// Calculate real security level
		security_level = calculate_real_security_level(component)

		// Update alert status (simplified)
		alert_status = health < 50 ? 1 : 0

		// Update maintenance timestamp
		if(health < 50)
			last_maintenance = world.time

// Calculate real security component health
/datum/security_component/proc/calculate_real_security_health(var/obj/component)
	var/base_health = 100

	// Reduce health based on operational status (simplified)
	if(!component.density)
		base_health *= 0.3

	// Reduce health based on time since last maintenance
	var/time_since_maintenance = world.time - last_maintenance
	if(time_since_maintenance > 360000) // 10 minutes
		base_health -= min(30, time_since_maintenance / 3600000 * 15)

	return max(0, base_health)

// Calculate real security level based on component type and condition
/datum/security_component/proc/calculate_real_security_level(var/obj/component)
	var/base_level = 1

	// Adjust based on component type
	if(istype(component, /obj/machinery/camera))
		base_level = 2
	else if(istype(component, /obj/machinery/door/airlock))
		base_level = 3
	else if(istype(component, /obj/machinery/computer/security))
		base_level = 4

	// Reduce level based on health
	if(health < 50)
		base_level = max(1, base_level - 1)

	return base_level



// Environmental Condition Datum
/datum/environmental_condition
	var/area_type
	var/temperature = 293
	var/humidity = 50
	var/air_quality = 100
	var/radiation_level = 0
	var/contamination_level = 0
	var/atmospheric_pressure = 101.325
	var/light_level = 100

/datum/environmental_condition/New(var/type)
	area_type = type

/datum/environmental_condition/proc/update_condition(var/area/A)
	if(A)
		// Calculate real environmental conditions based on actual area state
		var/damage = calculate_real_environmental_damage(A)

		// Calculate real environmental conditions
		air_quality = calculate_real_environmental_air_quality(A, damage)
		temperature = calculate_real_environmental_temperature(A, damage)
		humidity = calculate_real_environmental_humidity(A, damage)
		radiation_level = calculate_real_radiation_level(A)
		contamination_level = calculate_real_contamination_level(A, damage)
		atmospheric_pressure = calculate_real_atmospheric_pressure(A)
		light_level = calculate_real_light_level(A)

// Calculate real environmental damage
/datum/environmental_condition/proc/calculate_real_environmental_damage(var/area/A)
	var/total_damage = 0
	var/turf_count = 0

	for(var/turf/T in A)
		turf_count++
		if(T.density)
			total_damage += 0.1

		// Check for damage from objects in the area (simplified)
		for(var/obj/O in T)
			if(O.density)
				total_damage += 0.05

	return turf_count > 0 ? total_damage / turf_count : 0

// Calculate real air quality
/datum/environmental_condition/proc/calculate_real_environmental_air_quality(var/area/A, var/damage)
	var/base_quality = 100

	// Reduce quality based on damage
	base_quality -= damage * 40

	// Reduce quality based on number of dense objects (simplified)
	var/dense_objects = 0
	for(var/obj/O in A)
		if(O.density)
			dense_objects++

	base_quality -= dense_objects * 1

	// Reduce quality based on contamination
	base_quality -= contamination_level * 0.5

	return max(0, base_quality)

// Calculate real temperature
/datum/environmental_condition/proc/calculate_real_environmental_temperature(var/area/A, var/damage)
	var/base_temp = 293 // 20°C

	// Adjust based on damage
	base_temp += damage * 25

	// Adjust based on equipment count (simplified heat generation)
	var/equipment_count = 0
	for(var/obj/machinery/M in A)
		equipment_count++

	base_temp += equipment_count * 2

	return base_temp

// Calculate real humidity
/datum/environmental_condition/proc/calculate_real_environmental_humidity(var/area/A, var/damage)
	var/base_humidity = 50

	// Adjust based on damage
	base_humidity += damage * 25

	// Adjust based on atmospheric systems
	var/atmospheric_systems = 0
	for(var/obj/machinery/atmospherics/M in A)
		atmospheric_systems++

	if(atmospheric_systems > 0)
		base_humidity += 10

	return max(0, min(100, base_humidity))

// Calculate real radiation level
/datum/environmental_condition/proc/calculate_real_radiation_level(var/area/A)
	var/radiation = 0

		// Check for radiation sources in the area
	for(var/obj/machinery/M in A)
		if(istype(M, /obj/machinery/power/supermatter))
			radiation += 50
		else if(istype(M, /obj/machinery/power/generator))
			radiation += 20

	return radiation

// Calculate real contamination level
/datum/environmental_condition/proc/calculate_real_contamination_level(var/area/A, var/damage)
	var/contamination = damage * 80

	// Add contamination from dense objects (simplified)
	for(var/obj/O in A)
		if(O.density)
			contamination += 5

	return contamination

// Calculate real atmospheric pressure
/datum/environmental_condition/proc/calculate_real_atmospheric_pressure(var/area/A)
	var/base_pressure = 101.325 // Standard atmospheric pressure

	// Adjust based on atmospheric systems
	var/atmospheric_systems = 0
	for(var/obj/machinery/atmospherics/M in A)
		atmospheric_systems++

	if(atmospheric_systems > 0)
		base_pressure += 5

	return base_pressure

// Calculate real light level
/datum/environmental_condition/proc/calculate_real_light_level(var/area/A)
	var/light = 100

	// Reduce light based on damage (simplified)
	var/damage = 0
	for(var/turf/T in A)
		if(T.density)
			damage += 0.1

	light -= damage * 20

	// Check for light sources
	var/light_sources = 0
	for(var/obj/machinery/light/L in A)
		light_sources++

	if(light_sources > 0)
		light += 30

	return max(0, min(100, light))

// Containment Chamber Datum
/datum/containment_chamber
	var/area_type
	var/containment_status = "secure"
	var/breach_level = 0
	var/containment_health = 100
	var/list/containment_protocols = list()
	var/last_breach = 0
	var/containment_class = "safe"
	var/containment_effectiveness = 1.0

/datum/containment_chamber/New(var/type)
	area_type = type

/datum/containment_chamber/proc/update_status(var/area/A)
	if(A)
		// Calculate real containment status based on actual area state
		var/damage = calculate_real_containment_damage(A)

		containment_health = max(0, 100 - damage * 100)
		breach_level = damage * 100

		// Update containment status based on real conditions
		if(breach_level > 50)
			containment_status = "breached"
		else if(breach_level > 25)
			containment_status = "compromised"
		else
			containment_status = "secure"

		containment_effectiveness = containment_health / 100

		// Update containment class based on area type
		containment_class = calculate_real_containment_class(A)

		// Update breach timestamp if breached
		if(containment_status == "breached")
			last_breach = world.time

// Calculate real containment damage
/datum/containment_chamber/proc/calculate_real_containment_damage(var/area/A)
	var/total_damage = 0
	var/turf_count = 0

	for(var/turf/T in A)
		turf_count++
		if(T.density)
			total_damage += 0.1

		// Check for damage to turfs (simplified)
		if(T.density)
			total_damage += 0.2

		// Check for damage from containment systems (simplified)
		for(var/obj/machinery/M in T)
			if(M.density)
				total_damage += 0.1

	return turf_count > 0 ? total_damage / turf_count : 0

// Calculate real containment class based on area type
/datum/containment_chamber/proc/calculate_real_containment_class(var/area/A)
	// Determine containment class based on area name and contents
	if(findtext(A.name, "SCP-173") || findtext(A.name, "173"))
		return "Keter"
	else if(findtext(A.name, "SCP-096") || findtext(A.name, "096"))
		return "Euclid"
	else if(findtext(A.name, "SCP-049") || findtext(A.name, "049"))
		return "Euclid"
	else if(findtext(A.name, "SCP-682") || findtext(A.name, "682"))
		return "Keter"
	else if(findtext(A.name, "containment"))
		return "Safe"
	else
		return "Safe"

// Research Lab Datum
/datum/research_lab
	var/area_type
	var/research_capability = 100
	var/equipment_status = 100
	var/list/active_projects = list()
	var/research_efficiency = 1.0
	var/security_level = 1
	var/containment_level = 1

/datum/research_lab/New(var/type)
	area_type = type

/datum/research_lab/proc/update_status(var/area/A)
	if(A)
		// Calculate real research capability based on actual equipment
		var/equipment_data = calculate_real_research_equipment(A)

		equipment_status = equipment_data["status"]
		research_capability = equipment_data["capability"]
		research_efficiency = equipment_data["efficiency"]

		// Calculate real security level
		security_level = calculate_real_research_security(A)

		// Calculate real containment level
		containment_level = calculate_real_research_containment(A)

		// Update active projects list
		update_active_projects(A)

// Calculate real research equipment data
/datum/research_lab/proc/calculate_real_research_equipment(var/area/A)
	var/equipment_count = 0
	var/operational_equipment = 0
	var/total_capability = 0

	for(var/obj/machinery/M in A)
		equipment_count++
		if(M.density)
			operational_equipment++
			total_capability += calculate_equipment_capability(M)

	var/equipment_status = equipment_count > 0 ? (operational_equipment / equipment_count) * 100 : 0
	var/research_capability = equipment_count > 0 ? total_capability / equipment_count : 0
	var/research_efficiency = equipment_status / 100

	return list(
		"status" = equipment_status,
		"capability" = research_capability,
		"efficiency" = research_efficiency
	)

// Calculate equipment capability based on type
/datum/research_lab/proc/calculate_equipment_capability(var/obj/machinery/M)
	var/capability = 50 // Base capability

	// Adjust based on equipment type (simplified)
	if(istype(M, /obj/machinery/computer))
		capability = 80
	else if(istype(M, /obj/machinery/chem_dispenser))
		capability = 90
	else if(istype(M, /obj/machinery/autolathe))
		capability = 70

	// Adjust based on operational status (simplified)
	if(!M.density)
		capability *= 0.5

	return capability

// Calculate real research security level
/datum/research_lab/proc/calculate_real_research_security(var/area/A)
	var/security_level = 1

	// Check for security systems in the area (simplified)
	for(var/obj/machinery/M in A)
		if(istype(M, /obj/machinery/camera))
			security_level = max(security_level, 2)
		else if(istype(M, /obj/machinery/door/airlock))
			security_level = max(security_level, 3)
		else if(istype(M, /obj/machinery/computer))
			security_level = max(security_level, 2)

	return security_level

// Calculate real research containment level
/datum/research_lab/proc/calculate_real_research_containment(var/area/A)
	var/containment_level = 1

	// Check for containment systems in the area (simplified)
	for(var/obj/machinery/M in A)
		if(istype(M, /obj/machinery/atmospherics))
			containment_level = max(containment_level, 2)
		else if(istype(M, /obj/machinery/atmospherics))
			containment_level = max(containment_level, 2)

	return containment_level

// Update active projects list
/datum/research_lab/proc/update_active_projects(var/area/A)
	active_projects = list()

	// Check for research-related objects that might indicate active projects
	for(var/obj/O in A)
		if(istype(O, /obj/item/paper) || istype(O, /obj/item/clipboard))
			active_projects += "Documentation"
		else if(istype(O, /obj/item/reagent_containers))
			active_projects += "Chemical Research"
		else if(istype(O, /obj/item/stack/sheet))
			active_projects += "Material Research"

// Medical Facility Datum
/datum/medical_facility
	var/area_type
	var/medical_capability = 100
	var/equipment_status = 100
	var/supply_level = 100
	var/patient_capacity = 10
	var/current_patients = 0
	var/medical_efficiency = 1.0

/datum/medical_facility/New(var/type)
	area_type = type

/datum/medical_facility/proc/update_status(var/area/A)
	if(A)
		// Calculate real medical capability based on actual equipment
		var/equipment_data = calculate_real_medical_equipment(A)

		equipment_status = equipment_data["status"]
		medical_capability = equipment_data["capability"]
		medical_efficiency = equipment_data["efficiency"]

		// Calculate real supply level
		supply_level = calculate_real_medical_supplies(A)

		// Calculate real patient capacity and current patients
		var/patient_data = calculate_real_patient_data(A)
		patient_capacity = patient_data["capacity"]
		current_patients = patient_data["current"]

// Calculate real medical equipment data
/datum/medical_facility/proc/calculate_real_medical_equipment(var/area/A)
	var/equipment_count = 0
	var/operational_equipment = 0
	var/total_capability = 0

	for(var/obj/machinery/M in A)
		if(istype(M, /obj/machinery))
			equipment_count++
			if(M.density)
				operational_equipment++
				total_capability += calculate_medical_equipment_capability(M)

	var/equipment_status = equipment_count > 0 ? (operational_equipment / equipment_count) * 100 : 0
	var/medical_capability = equipment_count > 0 ? total_capability / equipment_count : 0
	var/medical_efficiency = equipment_status / 100

	return list(
		"status" = equipment_status,
		"capability" = medical_capability,
		"efficiency" = medical_efficiency
	)

// Calculate medical equipment capability based on type
/datum/medical_facility/proc/calculate_medical_equipment_capability(var/obj/machinery/M)
	var/capability = 50 // Base capability

	// Adjust based on equipment type (simplified)
	if(istype(M, /obj/machinery/chem_dispenser))
		capability = 90
	else if(istype(M, /obj/machinery/computer))
		capability = 80
	else if(istype(M, /obj/machinery/autolathe))
		capability = 75

	// Adjust based on operational status (simplified)
	if(!M.density)
		capability *= 0.5

	return capability

// Calculate real medical supplies level
/datum/medical_facility/proc/calculate_real_medical_supplies(var/area/A)
	var/supply_level = 100

	// Check for medical supplies in the area
	var/medical_items = 0
	for(var/obj/item/I in A)
		if(istype(I, /obj/item/reagent_containers) || istype(I, /obj/item/stack/medical))
			medical_items++

	// Reduce supply level if few medical items
	if(medical_items < 5)
		supply_level -= (5 - medical_items) * 10

	return max(0, supply_level)

// Calculate real patient data
/datum/medical_facility/proc/calculate_real_patient_data(var/area/A)
	var/patient_capacity = 10
	var/current_patients = 0

	// Count actual patients in the area
	for(var/mob/living/carbon/human/H in A)
		if(H.stat == UNCONSCIOUS || H.stat == DEAD)
			current_patients++

	// Adjust capacity based on medical equipment (simplified)
	for(var/obj/machinery/M in A)
		if(istype(M, /obj/machinery/chem_dispenser))
			patient_capacity += 1
		else if(istype(M, /obj/machinery/computer))
			patient_capacity += 1

	return list(
		"capacity" = patient_capacity,
		"current" = current_patients
	)

// Engineering System Datum
/datum/engineering_system
	var/area_type
	var/system_health = 100
	var/operational_status = 100
	var/power_output = 0
	var/efficiency = 1.0
	var/maintenance_required = FALSE
	var/list/connected_systems = list()

/datum/engineering_system/New(var/type)
	area_type = type

/datum/engineering_system/proc/update_status(var/area/A)
	if(A)
		// Calculate real system health based on actual equipment
		var/system_data = calculate_real_engineering_system_health(A)

		system_health = system_data["health"]
		operational_status = system_data["operational"]
		efficiency = system_data["efficiency"]
		maintenance_required = system_data["maintenance_required"]

		// Calculate real power output
		power_output = calculate_real_engineering_power_output(A)

		// Update connected systems
		update_connected_systems(A)

// Calculate real engineering system health
/datum/engineering_system/proc/calculate_real_engineering_system_health(var/area/A)
	var/total_damage = 0
	var/equipment_count = 0
	var/operational_equipment = 0

	for(var/obj/machinery/M in A)
		if(istype(M, /obj/machinery/power) || istype(M, /obj/machinery/atmospherics))
			equipment_count++
			if(M.density)
				operational_equipment++
			else
				total_damage += 0.3

			// Add damage based on operational status (simplified)
			if(!M.density)
				total_damage += 0.2

	var/system_health = equipment_count > 0 ? max(0, 100 - (total_damage / equipment_count) * 100) : 100
	var/operational_status = equipment_count > 0 ? (operational_equipment / equipment_count) * 100 : 100
	var/efficiency = system_health / 100
	var/maintenance_required = system_health < 50 || operational_status < 50

	return list(
		"health" = system_health,
		"operational" = operational_status,
		"efficiency" = efficiency,
		"maintenance_required" = maintenance_required
	)

// Calculate real engineering power output
/datum/engineering_system/proc/calculate_real_engineering_power_output(var/area/A)
	var/power_output = 0

	for(var/obj/machinery/power/P in A)
		if(istype(P, /obj/machinery/power/generator))
			if(P.density) // Simplified operational check
				power_output += 1000 // Base generator output

				// Adjust based on generator type
				if(istype(P, /obj/machinery/power/supermatter))
					power_output += 4000
				else if(istype(P, /obj/machinery/power/generator))
					power_output += 2000

	return power_output

// Update connected systems list
/datum/engineering_system/proc/update_connected_systems(var/area/A)
	connected_systems = list()

	// Check for connected power systems
	for(var/obj/machinery/power/P in A)
		if(istype(P, /obj/machinery/power/apc))
			connected_systems += "Power Distribution"
		else if(istype(P, /obj/machinery/power/generator))
			connected_systems += "Power Generation"

	// Check for connected atmospheric systems
	for(var/obj/machinery/atmospherics/M in A)
		connected_systems += "Atmospheric Control"

	// Check for connected security systems
	for(var/obj/machinery/camera/C in A)
		connected_systems += "Security Monitoring"
