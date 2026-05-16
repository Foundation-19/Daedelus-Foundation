// Facility Damage Tracking System
// Tracks structural damage, area destruction, and integrates with the round report

/datum/facility_damage_tracker
	var/list/damaged_areas = list()
	var/total_walls_destroyed = 0
	var/total_floors_destroyed = 0
	var/total_windows_broken = 0
	var/total_doors_destroyed = 0
	var/total_machines_destroyed = 0
	var/list/destruction_log = list()

/datum/facility_damage_tracker/proc/log_destruction(atom/source, atom/destroyed, destruction_type)
	var/area/A = get_area(source)
	var/area_name = A ? A.name : "Unknown Area"

	var/list/entry = list(
		"area" = area_name,
		"type" = destruction_type,
		"object" = destroyed.name,
		"time" = world.time,
	)

	destruction_log += list(entry)

	switch(destruction_type)
		if("wall")
			total_walls_destroyed++
		if("floor")
			total_floors_destroyed++
		if("window")
			total_windows_broken++
		if("door")
			total_doors_destroyed++
		if("machine")
			total_machines_destroyed++

	if(!damaged_areas[area_name])
		damaged_areas[area_name] = list("wall" = 0, "floor" = 0, "window" = 0, "door" = 0, "machine" = 0, "total" = 0)

	damaged_areas[area_name][destruction_type]++
	damaged_areas[area_name]["total"]++

/datum/facility_damage_tracker/proc/get_damage_score()
	var/score = 0
	score += total_walls_destroyed * 2
	score += total_floors_destroyed * 1
	score += total_windows_broken * 1
	score += total_doors_destroyed * 3
	score += total_machines_destroyed * 5
	return score

/datum/facility_damage_tracker/proc/get_damage_rating()
	var/score = get_damage_score()
	if(score == 0)
		return "INTACT"
	if(score < 50)
		return "MINOR DAMAGE"
	if(score < 150)
		return "MODERATE DAMAGE"
	if(score < 300)
		return "HEAVY DAMAGE"
	return "CATASTROPHIC DAMAGE"

/datum/facility_damage_tracker/proc/get_worst_areas()
	var/list/worst = list()
	for(var/area_name in damaged_areas)
		worst += list(list("area" = area_name, "damage" = damaged_areas[area_name]["total"]))

	sortTim(worst, GLOBAL_PROC_REF(cmp_damage_list_desc))
	if(length(worst) > 5)
		worst = worst.Cut(1, 6)

	return worst

/proc/cmp_damage_list_desc(list/a, list/b)
	return b["damage"] - a["damage"]

GLOBAL_DATUM_INIT(facility_damage_tracker, /datum/facility_damage_tracker, new())

// Hooks for tracking destruction
/turf/closed/wall/Destroy()
	if(GLOB.facility_damage_tracker)
		GLOB.facility_damage_tracker.log_destruction(src, src, "wall")
	. = ..()

/turf/open/floor/Destroy()
	if(GLOB.facility_damage_tracker)
		GLOB.facility_damage_tracker.log_destruction(src, src, "floor")
	. = ..()

/obj/structure/window/Destroy()
	if(GLOB.facility_damage_tracker)
		GLOB.facility_damage_tracker.log_destruction(src, src, "window")
	. = ..()

/obj/machinery/door/Destroy()
	if(GLOB.facility_damage_tracker)
		GLOB.facility_damage_tracker.log_destruction(src, src, "door")
	. = ..()

/obj/machinery/Destroy()
	if(GLOB.facility_damage_tracker && !istype(src, /obj/machinery/door))
		GLOB.facility_damage_tracker.log_destruction(src, src, "machine")
	. = ..()
