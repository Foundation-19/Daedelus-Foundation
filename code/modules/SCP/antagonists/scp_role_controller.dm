/datum/scp_role_controller
	var/list/active_scp_minds = list()
	var/list/offered_scp_roles = list()
	var/cooldown_time = 5 MINUTES
	var/list/role_cooldowns = list()

/datum/scp_role_controller/proc/offer_scp_role(mob/dead/observer/ghost, scp_type)
	if(!ghost?.client)
		return FALSE
	if(!ghost.client.prefs)
		return FALSE

	var/role_flag = get_role_flag(scp_type)
	if(!role_flag)
		return FALSE

	var/list/client_antags = ghost.client.prefs.read_preference(/datum/preference/blob/antagonists)
	if(!(client_antags?[role_flag]))
		return FALSE

	var/role_name = get_role_name(scp_type)
	if(!role_name)
		return FALSE

	if(check_scp_blacklist(ghost.ckey, scp_type))
		return FALSE

	if(role_cooldowns[ghost.ckey] && world.time < role_cooldowns[ghost.ckey])
		return FALSE

	var/mob_type = get_mob_type(scp_type)
	if(!mob_type)
		return FALSE

	offered_scp_roles[ghost.ckey] = scp_type

	var/question = "Do you want to play as [role_name]? You will be assigned SCP-specific abilities and objectives."
	var/list/candidates = poll_candidates_for_mob(question, role_flag, role_flag, 20 SECONDS, ghost)

	if(!length(candidates) || !(ghost in candidates))
		offered_scp_roles -= ghost.ckey
		return FALSE

	if(!ghost.key)
		offered_scp_roles -= ghost.ckey
		return FALSE

	return assign_scp_role(ghost, scp_type)

/datum/scp_role_controller/proc/assign_scp_role(mob/dead/observer/ghost, scp_type)
	if(!ghost?.key)
		return FALSE

	if(check_scp_blacklist(ghost.ckey, scp_type))
		return FALSE

	var/mob_type = get_mob_type(scp_type)
	if(!mob_type)
		return FALSE

	var/turf/spawn_turf = get_scp_spawn_turf()
	if(!spawn_turf)
		offered_scp_roles -= ghost.ckey
		return FALSE

	var/mob/living/scp_mob = new mob_type(spawn_turf)

	if(!scp_mob)
		offered_scp_roles -= ghost.ckey
		return FALSE

	scp_mob.ckey = ghost.ckey

	if(ghost.mind)
		ghost.mind.transfer_to(scp_mob, TRUE)
		var/datum/mind/scp_mind = scp_mob.mind
		scp_mind.active = TRUE
	else
		var/datum/mind/scp_mind = new /datum/mind(scp_mob.key)
		scp_mind.current = scp_mob
		scp_mind.active = TRUE
		scp_mind.set_assigned_role(SSjob.GetJobType(/datum/job/ghost_role))
		SSticker.minds += scp_mind

	var/antag_type = get_antag_type(scp_type)
	if(antag_type)
		var/datum/antagonist/scp/antag = scp_mob.mind.add_antag_datum(antag_type)
		if(antag)
			antag.forge_scp_objectives()

	active_scp_minds[scp_mob.ckey] = scp_mob.mind

	role_cooldowns[scp_mob.ckey] = world.time + cooldown_time
	offered_scp_roles -= ghost.ckey

	message_admins("[key_name(scp_mob)] has been assigned as [get_role_name(scp_type)].")
	log_game("[key_name(scp_mob)] was assigned as [get_role_name(scp_type)].")

	return TRUE

/datum/scp_role_controller/proc/offer_all_available_scp_roles()
	var/list/available = get_available_scp_types()
	if(!length(available))
		return

	for(var/mob/dead/observer/ghost in GLOB.player_list)
		if(QDELETED(ghost))
			continue
		if(!ghost.client)
			continue
		for(var/scp_type in available)
			addtimer(CALLBACK(src, PROC_REF(offer_scp_role), ghost, scp_type), rand(1, 30) SECONDS)
			break

/datum/scp_role_controller/proc/offer_scp_role_from_lobby(mob/dead/new_player/player, scp_type)
	if(!player?.client)
		return

	var/role_name = get_role_name(scp_type)
	if(!role_name)
		return

	var/question = "Do you want to play as [role_name]? You will leave the lobby and become an SCP entity."
	var/answer = tgui_alert(player, question, "SCP Role", list("Yes", "No"))
	if(answer != "Yes")
		return

	if(QDELETED(player) || !player.client)
		return

	var/mob/dead/observer/ghost = player.make_me_an_observer(TRUE)
	if(!ghost)
		to_chat(player, span_warning("Failed to enter observer mode."))
		return

	offer_scp_role(ghost, scp_type)

/datum/scp_role_controller/proc/get_available_scp_types()
	var/list/available = list()

	for(var/scp_type in list(SCP_ROLE_173, SCP_ROLE_096, SCP_ROLE_049, SCP_ROLE_106, SCP_ROLE_035, SCP_ROLE_457, SCP_ROLE_939, SCP_ROLE_079, SCP_ROLE_682, SCP_ROLE_008))
		var/mob_type = get_mob_type(scp_type)
		if(!mob_type)
			continue

		var/role_flag = get_role_flag(scp_type)
		if(!role_flag)
			continue

		var/already_active = FALSE
		for(var/ckey in active_scp_minds)
			var/datum/mind/M = active_scp_minds[ckey]
			if(M && M.current && get_antag_type(scp_type))
				var/datum/antagonist/scp/existing_antag = M.has_antag_datum(get_antag_type(scp_type))
				if(existing_antag)
					already_active = TRUE
					break
		if(already_active)
			continue

		available += scp_type

	return available

/datum/scp_role_controller/proc/get_role_flag(scp_type)
	switch(scp_type)
		if(SCP_ROLE_173)
			return ROLE_SCP173
		if(SCP_ROLE_096)
			return ROLE_SCP096
		if(SCP_ROLE_008)
			return ROLE_SCP008
		if(SCP_ROLE_035)
			return ROLE_SCP035
		if(SCP_ROLE_049)
			return ROLE_SCP049
		if(SCP_ROLE_079)
			return ROLE_SCP079
		if(SCP_ROLE_106)
			return ROLE_SCP106
		if(SCP_ROLE_457)
			return ROLE_SCP457
		if(SCP_ROLE_939)
			return ROLE_SCP939
		if(SCP_ROLE_682)
			return ROLE_SCP682

/datum/scp_role_controller/proc/get_role_name(scp_type)
	switch(scp_type)
		if(SCP_ROLE_173)
			return "SCP-173 (The Sculpture)"
		if(SCP_ROLE_096)
			return "SCP-096 (The Shy Guy)"
		if(SCP_ROLE_008)
			return "SCP-008 (Zombie Plague)"
		if(SCP_ROLE_035)
			return "SCP-035 (The Possessive Mask)"
		if(SCP_ROLE_049)
			return "SCP-049 (The Plague Doctor)"
		if(SCP_ROLE_079)
			return "SCP-079 (Old AI)"
		if(SCP_ROLE_106)
			return "SCP-106 (The Old Man)"
		if(SCP_ROLE_457)
			return "SCP-457 (The Living Flame)"
		if(SCP_ROLE_939)
			return "SCP-939 (With Many Voices)"
		if(SCP_ROLE_682)
			return "SCP-682 (The Hard-to-Destroy Reptile)"

/datum/scp_role_controller/proc/get_mob_type(scp_type)
	switch(scp_type)
		if(SCP_ROLE_173)
			return /mob/living/scp/scp173
		if(SCP_ROLE_096)
			return /mob/living/scp/scp096
		if(SCP_ROLE_008)
			return /mob/living/simple_animal/hostile/scp008_zombie
		if(SCP_ROLE_035)
			return /mob/living/scp035
		if(SCP_ROLE_049)
			return /mob/living/scp/scp049
		if(SCP_ROLE_079)
			return /mob/living/scp079
		if(SCP_ROLE_106)
			return /mob/living/scp/scp106
		if(SCP_ROLE_457)
			return /mob/living/scp/scp457
		if(SCP_ROLE_939)
			return /mob/living/scp/scp939
		if(SCP_ROLE_682)
			return /mob/living/scp/scp682

/datum/scp_role_controller/proc/get_antag_type(scp_type)
	switch(scp_type)
		if(SCP_ROLE_173)
			return /datum/antagonist/scp/scp173
		if(SCP_ROLE_096)
			return /datum/antagonist/scp/scp096
		if(SCP_ROLE_008)
			return /datum/antagonist/scp/scp008
		if(SCP_ROLE_035)
			return /datum/antagonist/scp/scp035
		if(SCP_ROLE_049)
			return /datum/antagonist/scp/scp049
		if(SCP_ROLE_079)
			return /datum/antagonist/scp/scp079
		if(SCP_ROLE_106)
			return /datum/antagonist/scp/scp106
		if(SCP_ROLE_457)
			return /datum/antagonist/scp/scp457
		if(SCP_ROLE_939)
			return /datum/antagonist/scp/scp939
		if(SCP_ROLE_682)
			return /datum/antagonist/scp/scp682

/datum/scp_role_controller/proc/get_SCP_for_type(scp_type)
	var/mob_type = get_mob_type(scp_type)
	if(!mob_type)
		return null
	for(var/mob/living/scp/A as anything in INSTANCES_OF(/mob/living/scp))
		if(istype(A, mob_type) && A.SCP)
			return A.SCP
	return null

/datum/scp_role_controller/proc/get_scp_spawn_turf()
	if(length(GLOB.scp_spawn_turfs))
		return pick(GLOB.scp_spawn_turfs)
	if(length(GLOB.station_turfs))
		return pick(GLOB.station_turfs)
	return get_turf(locate(/obj/effect/landmark/latejoin))

/datum/scp_role_controller/proc/get_scp_info_list()
	var/list/info = list()
	var/list/available = get_available_scp_types()
	for(var/scp_type in available)
		var/role_name = get_role_name(scp_type)
		var/role_flag = get_role_flag(scp_type)
		info += list(list(
			"scp_type" = scp_type,
			"name" = role_name,
			"role_flag" = role_flag,
		))
	return info

GLOBAL_DATUM_INIT(scp_role_controller, /datum/scp_role_controller, new())

GLOBAL_LIST_EMPTY(scp_spawn_turfs)

/proc/find_scp_spawn_turfs()
	GLOB.scp_spawn_turfs = list()
	for(var/obj/effect/landmark/scp_spawn/L in GLOB.landmarks_list)
		GLOB.scp_spawn_turfs += get_turf(L)
	if(!length(GLOB.scp_spawn_turfs))
		for(var/area/A in GLOB.areas)
			if(!istype(A, /area/scp) && !istype(A, /area/site53))
				continue
			if(!is_station_level(A.z))
				continue
			for(var/turf/T in A)
				GLOB.scp_spawn_turfs += T
				if(length(GLOB.scp_spawn_turfs) >= 20)
					break
			if(length(GLOB.scp_spawn_turfs) >= 20)
				break
	if(!length(GLOB.scp_spawn_turfs))
		for(var/area/A in GLOB.areas)
			if(!is_station_level(A.z))
				continue
			for(var/turf/T in A)
				GLOB.scp_spawn_turfs += T
				if(length(GLOB.scp_spawn_turfs) >= 10)
					break
			if(length(GLOB.scp_spawn_turfs) >= 10)
				break
	log_world("SCP spawn turfs: found [length(GLOB.scp_spawn_turfs)] turfs")

/obj/effect/landmark/scp_spawn
	name = "SCP Spawn"
	icon_state = "spawn_point"

/proc/create_scp_ghost_spawners()
	var/list/spawner_types = list(
		/obj/effect/mob_spawn/ghost_role/scp/scp173,
		/obj/effect/mob_spawn/ghost_role/scp/scp096,
		/obj/effect/mob_spawn/ghost_role/scp/scp049,
		/obj/effect/mob_spawn/ghost_role/scp/scp106,
		/obj/effect/mob_spawn/ghost_role/scp/scp035,
		/obj/effect/mob_spawn/ghost_role/scp/scp457,
		/obj/effect/mob_spawn/ghost_role/scp/scp939,
		/obj/effect/mob_spawn/ghost_role/scp/scp079,
		/obj/effect/mob_spawn/ghost_role/scp/scp682,
		/obj/effect/mob_spawn/ghost_role/scp/scp008,
	)
	var/list/spawn_turfs = GLOB.scp_spawn_turfs
	if(!length(spawn_turfs))
		for(var/area/A in GLOB.areas)
			if(!is_station_level(A.z))
				continue
			for(var/turf/T in A)
				spawn_turfs += T
			if(length(spawn_turfs) >= 50)
				break
	if(!length(spawn_turfs))
		log_world("SCP ghost spawners: FAILED - no spawn turfs found")
		return
	for(var/spawner_type in spawner_types)
		var/turf/T = pick(spawn_turfs)
		new spawner_type(T)
	log_world("SCP ghost spawners: Created [length(spawner_types)] spawners")
