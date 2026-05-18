/proc/fix_site53_spawns()
	fix_site53_landmarks()
	fix_site53_job_names()
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(create_foundation_ghost_spawners)), 10 SECONDS)

/proc/fix_site53_landmarks()
	var/list/to_remove = list()
	for(var/obj/effect/landmark/L in GLOB.landmarks_list)
		if(istype(L, /obj/effect/landmark/start))
			continue
		if(istype(L, /obj/effect/landmark/latejoin))
			continue
		if(istype(L, /obj/effect/landmark/observer_start))
			continue
		switch(L.name)
			if("JoinLateCryo", "JoinLateDclass", "JoinLateCyborg")
				var/turf/T = get_turf(L)
				if(T)
					SSjob.latejoin_trackers += T
				to_remove += L
			if("Observer-Start")
				var/turf/T = get_turf(L)
				if(T)
					new /obj/effect/landmark/observer_start(T)
				to_remove += L
	for(var/obj/effect/landmark/L in to_remove)
		GLOB.landmarks_list -= L
		qdel(L)
	var/has_newplayer = FALSE
	for(var/T in GLOB.newplayer_start)
		has_newplayer = TRUE
		break
	if(!has_newplayer)
		var/area/dclass = GLOB.areas_by_type[/area/site53/llcz/dclass/cells]
		if(!dclass)
			dclass = GLOB.areas_by_type[/area/scp/dclass/cell_block]
		if(dclass)
			for(var/turf/T in dclass)
				if(!T.is_blocked_turf(TRUE))
					new /obj/effect/landmark/start/new_player(T)
					break
		if(!length(GLOB.newplayer_start))
			for(var/turf/T in world)
				if(is_station_level(T.z) && !T.is_blocked_turf(TRUE))
					new /obj/effect/landmark/start/new_player(T)
					break
	if(!length(SSjob.latejoin_trackers))
		var/area/ez_hall = GLOB.areas_by_type[/area/site53/entrancezone/hallway]
		if(ez_hall)
			for(var/turf/T in ez_hall)
				if(!T.is_blocked_turf(TRUE))
					SSjob.latejoin_trackers += T
					if(length(SSjob.latejoin_trackers) >= 3)
						break
		if(!length(SSjob.latejoin_trackers))
			for(var/turf/T in world)
				if(is_station_level(T.z) && !T.is_blocked_turf(TRUE))
					SSjob.latejoin_trackers += T
					if(length(SSjob.latejoin_trackers) >= 3)
						break
	if(!locate(/obj/effect/landmark/observer_start) in GLOB.landmarks_list)
		var/area/ez_hall = GLOB.areas_by_type[/area/site53/entrancezone/hallway]
		if(ez_hall)
			for(var/turf/T in ez_hall)
				if(!T.is_blocked_turf(TRUE))
					new /obj/effect/landmark/observer_start(T)
					break
		if(!locate(/obj/effect/landmark/observer_start) in GLOB.landmarks_list)
			for(var/turf/T in world)
				if(is_station_level(T.z) && !T.is_blocked_turf(TRUE))
					new /obj/effect/landmark/observer_start(T)
					break
	log_world("Site53 spawn fix: latejoin=[length(SSjob.latejoin_trackers)] newplayer=[length(GLOB.newplayer_start)] observer=[!!locate(/obj/effect/landmark/observer_start) in GLOB.landmarks_list]")

/proc/fix_site53_job_names()
	var/list/name_remap = list(
		"AI" = JOB_AI,
		"Chef" = JOB_COOK,
		"Class D" = JOB_DCLASS,
		"Communications Officer" = JOB_COMMUNICATIONS_DIRECTOR,
		"Emergency Medical Technician" = JOB_PARAMEDIC,
		"Logistics Specialist" = JOB_LOGISTICS_TECHNICIAN,
		"Medical Intern" = JOB_TRAINEE_DOCTOR,
		"Office Worker" = JOB_ASSISTANT,
		"Robot" = JOB_CYBORG,
		"Site Manager" = JOB_HUMAN_RESOURCES_DIRECTOR,
		"Senior Psychotronics Researcher" = JOB_SENIOR_RESEARCHER,
		"Robotics Technician" = JOB_JUNIOR_ENGINEER,
		"Junior Robotics Technician" = JOB_JUNIOR_ENGINEER,
		"Senior Robotics Technician" = JOB_ENGINEER,
		"Communications Technician" = JOB_IT_TECHNICIAN,
	)
	var/fixed = 0
	for(var/obj/effect/landmark/start/S in GLOB.start_landmarks_list)
		if(name_remap[S.name])
			S.name = name_remap[S.name]
			S.tag = "start*[S.name]"
			fixed++
	log_world("Site53 spawn fix: remapped [fixed] job landmark names")

/proc/create_foundation_ghost_spawners()
	var/list/spawn_configs = list(
		list(/obj/effect/mob_spawn/ghost_role/dclass_latejoin, /area/site53/llcz/dclass/cells, 2),
		list(/obj/effect/mob_spawn/ghost_role/foundation_mtf, /area/site53/uez/armory, 1),
		list(/obj/effect/mob_spawn/ghost_role/foundation_goc, /area/site53/uez/armory, 1),
		list(/obj/effect/mob_spawn/ghost_role/chaos_insurgency, /area/site53/surface, 1),
		list(/obj/effect/mob_spawn/ghost_role/scp_witness, /area/site53/uez/hallway, 1),
	)
	var/created = 0
	for(var/list/config in spawn_configs)
		var/spawner_type = config[1]
		var/area_type = config[2]
		var/count = config[3]
		var/area/target_area = GLOB.areas_by_type[area_type]
		if(!target_area)
			log_world("Site53 ghost spawner: could not find area [area_type] for [spawner_type]")
			continue
		var/list/candidate_turfs = list()
		for(var/turf/T in target_area)
			if(!T.is_blocked_turf(TRUE))
				candidate_turfs += T
		if(!length(candidate_turfs))
			log_world("Site53 ghost spawner: no open turfs in [area_type] for [spawner_type]")
			continue
		for(var/i in 1 to min(count, length(candidate_turfs)))
			var/turf/T = pick(candidate_turfs)
			candidate_turfs -= T
			new spawner_type(T)
			created++
	log_world("Site53 ghost spawner: created [created] Foundation ghost role spawners")
