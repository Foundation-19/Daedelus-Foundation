SUBSYSTEM_DEF(scp_facility_equipment)
	name = "SCP Facility Equipment"
	init_order = INIT_ORDER_MINOR_MAPPING + 1
	flags = SS_NO_FIRE

/datum/controller/subsystem/scp_facility_equipment/Initialize(time)
	spawn_facility_equipment()
	return ..()

/datum/controller/subsystem/scp_facility_equipment/proc/spawn_facility_equipment()
	var/list/ez_offices = list()
	var/list/ez_lobbies = list()
	var/list/lcz_labs = list()
	var/list/hcz_obs = list()
	var/list/ez_briefing = list()
	var/list/dclass_rec = list()

	for(var/area/A in GLOB.areas)
		if(istype(A, /area/scp/ez/offices))
			ez_offices += A
		else if(istype(A, /area/scp/ez/lobby))
			ez_lobbies += A
		else if(istype(A, /area/scp/lcz/testing_lab))
			lcz_labs += A
		else if(istype(A, /area/scp/hcz/observation))
			hcz_obs += A
		else if(istype(A, /area/scp/ez/briefing))
			ez_briefing += A
		else if(istype(A, /area/scp/dclass/recreation))
			dclass_rec += A

	var/photocopier_count = 0

	photocopier_count += try_spawn_in_area(ez_offices, /obj/machinery/photocopier, 1)
	photocopier_count += try_spawn_in_area(lcz_labs, /obj/machinery/photocopier, 1)
	photocopier_count += try_spawn_in_area(dclass_rec, /obj/machinery/photocopier, 1)

	log_world("SCP Facility Equipment: Spawned [photocopier_count] photocopier(s)")

/datum/controller/subsystem/scp_facility_equipment/proc/try_spawn_in_area(list/areas, obj_type, max_count)
	if(!length(areas))
		return 0
	var/spawned = 0
	var/list/shuffled = shuffle(areas)
	for(var/area/A in shuffled)
		if(spawned >= max_count)
			break
		var/list/turfs = list()
		for(var/turf/open/floor/T in A.contents)
			var/blocked = FALSE
			for(var/obj/O in T.contents)
				if(O.density)
					blocked = TRUE
					break
			if(!blocked)
				turfs += T
		if(!length(turfs))
			continue
		var/turf/picked = pick(turfs)
		new obj_type(picked)
		spawned++
	return spawned
