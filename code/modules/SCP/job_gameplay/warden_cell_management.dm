SUBSYSTEM_DEF(cell_management)
	name = "Cell Management"
	wait = 20 SECONDS
	flags = SS_NO_FIRE

	var/list/cells = list()
	var/list/incidents = list()
	var/list/schedules = list()
	var/total_incidents = 0
	var/total_transfers = 0
	var/total_cell_assignments = 0

/datum/controller/subsystem/cell_management/Initialize(time)
	. = ..()
	initialize_cells()
	initialize_schedules()

/datum/controller/subsystem/cell_management/proc/initialize_cells()
	cells = list()
	for(var/area/A in GLOB.areas)
		if(!istype(A, /area/scp/dclass))
			continue
		var/area_name = A.name
		var/cell_type = "general"
		if(findtext(area_name, "Cell Block") || findtext(area_name, "cell_block"))
			cell_type = "cell_block"
		else if(findtext(area_name, "Solitary") || findtext(area_name, "solitary"))
			cell_type = "solitary"
		else if(findtext(area_name, "Interrogation") || findtext(area_name, "interrogation"))
			cell_type = "interrogation"
		else if(findtext(area_name, "Recreation") || findtext(area_name, "recreation"))
			cell_type = "recreation"
		else if(findtext(area_name, "Cafeteria") || findtext(area_name, "cafeteria"))
			cell_type = "cafeteria"
		else if(findtext(area_name, "Testing") || findtext(area_name, "testing"))
			cell_type = "testing"
		cells += list(list(
			"area_name" = area_name,
			"area_ref" = REF(A),
			"cell_type" = cell_type,
			"assigned_dclass" = list(),
			"capacity" = cell_type == "solitary" ? 1 : 4,
			"security_level" = 0,
			"lockdown" = FALSE,
		))

/datum/controller/subsystem/cell_management/proc/initialize_schedules()
	schedules = list(
		list("name" = "Morning Roll Call", "time" = "06:00", "type" = "roll_call", "active" = TRUE),
		list("name" = "Breakfast", "time" = "07:00", "type" = "meal", "active" = TRUE),
		list("name" = "Work Assignment", "time" = "08:00", "type" = "work", "active" = TRUE),
		list("name" = "Lunch", "time" = "12:00", "type" = "meal", "active" = TRUE),
		list("name" = "Recreation Period", "time" = "13:00", "type" = "recreation", "active" = TRUE),
		list("name" = "Work Assignment", "time" = "15:00", "type" = "work", "active" = TRUE),
		list("name" = "Dinner", "time" = "17:00", "type" = "meal", "active" = TRUE),
		list("name" = "Evening Roll Call", "time" = "19:00", "type" = "roll_call", "active" = TRUE),
		list("name" = "Lights Out", "time" = "21:00", "type" = "lockdown", "active" = TRUE),
	)

/datum/controller/subsystem/cell_management/proc/assign_cell(dclass_name, cell_type)
	for(var/list/C in cells)
		if(C["cell_type"] != cell_type)
			continue
		if(length(C["assigned_dclass"]) >= C["capacity"])
			continue
		C["assigned_dclass"] += list(dclass_name)
		total_cell_assignments++
		return C["area_name"]
	return null

/datum/controller/subsystem/cell_management/proc/release_from_cell(dclass_name)
	for(var/list/C in cells)
		if(dclass_name in C["assigned_dclass"])
			C["assigned_dclass"] -= list(dclass_name)
			return TRUE
	return FALSE

/datum/controller/subsystem/cell_management/proc/lockdown_cell(idx)
	if(idx < 1 || idx > length(cells))
		return
	var/list/C = cells[idx]
	C["lockdown"] = TRUE
	C["security_level"] = 3
	var/area/A = locate(C["area_ref"])
	if(A)
		for(var/obj/machinery/door/airlock/D in A.contents)
			D.lock()
			D.close()
	log_incident("Cell lockdown", C["area_name"], "Warden")

/datum/controller/subsystem/cell_management/proc/unlockdown_cell(idx)
	if(idx < 1 || idx > length(cells))
		return
	var/list/C = cells[idx]
	C["lockdown"] = FALSE
	C["security_level"] = 0
	var/area/A = locate(C["area_ref"])
	if(A)
		for(var/obj/machinery/door/airlock/D in A.contents)
			D.unlock()
	log_incident("Cell lockdown lifted", C["area_name"], "Warden")

/datum/controller/subsystem/cell_management/proc/log_incident(incident_type, location, logger_name)
	total_incidents++
	incidents += list(list(
		"type" = incident_type,
		"location" = location,
		"logger" = logger_name,
		"time" = world.time,
	))

/datum/controller/subsystem/cell_management/proc/transfer_dclass(dclass_name, from_type, to_type)
	var/release_result = release_from_cell(dclass_name)
	if(!release_result)
		return FALSE
	var/assigned = assign_cell(dclass_name, to_type)
	if(!assigned)
		assign_cell(dclass_name, from_type)
		return FALSE
	total_transfers++
	log_incident("D-Class transfer: [dclass_name] from [from_type] to [to_type]", assigned, "Warden")
	return TRUE

/datum/controller/subsystem/cell_management/proc/get_schedule_status()
	var/current_time = gameTimestamp("hh:mm")
	var/next_event = "None scheduled"
	for(var/list/S in schedules)
		if(!S["active"])
			continue
		if(S["time"] >= current_time)
			next_event = "[S["name"]] at [S["time"]]"
			break
	return next_event

/obj/item/paper/foundation/incident_report
	name = "Incident Report"

/obj/item/paper/foundation/dclass_transfer_form
	name = "D-Class Transfer Authorization"
