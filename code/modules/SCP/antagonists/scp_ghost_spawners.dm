/obj/effect/mob_spawn/ghost_role/scp
	name = "SCP Containment Unit"
	prompt_ghost = FALSE
	uses = 1
	density = FALSE
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = "mobspawner"
	var/scp_type = ""
	var/role_flag = ""
	role_ban = ROLE_GHOST_ROLE
	show_flavor = FALSE
	invisibility = INVISIBILITY_OBSERVER

/obj/effect/mob_spawn/ghost_role/scp/Initialize(mapload)
	if(scp_type)
		var/datum/scp_role_controller/controller = GLOB.scp_role_controller
		var/role_name = controller?.get_role_name(scp_type) || scp_type
		name = role_name
	. = ..()
	log_world("SCP spawner created: [name] at [loc ? get_area(src) : "null"]")

/obj/effect/mob_spawn/ghost_role/scp/attack_ghost(mob/user)
	if(!SSticker.HasRoundStarted() || !loc)
		return
	if(!(GLOB.ghost_role_flags & GHOSTROLE_SPAWNER) && !(flags_1 & ADMIN_SPAWNED_1))
		to_chat(user, span_warning("An admin has temporarily disabled ghost roles!"))
		return
	if(!uses)
		to_chat(user, span_warning("This spawner is out of charges!"))
		return
	if(check_scp_blacklist(user.ckey, scp_type))
		to_chat(user, span_warning("You are blacklisted from this SCP role."))
		return
	if(role_flag && is_banned_from(user.key, role_flag))
		to_chat(user, span_warning("You are banned from this role!"))
		return
	if(role_flag && user.client?.prefs)
		var/list/client_antags = user.client.prefs.read_preference(/datum/preference/blob/antagonists)
		if(!(client_antags?[role_flag]))
			to_chat(user, span_warning("You do not have this role enabled in your preferences."))
			return
	var/datum/scp_role_controller/controller = GLOB.scp_role_controller
	if(!controller)
		return
	var/mob_type = controller.get_mob_type(scp_type)
	if(!mob_type)
		return
	var/role_name = controller.get_role_name(scp_type) || scp_type
	var/ghost_role = tgui_alert(usr, "Become [role_name]? (Warning: You can no longer be revived!)", "SCP Role", list("Yes", "No"))
	if(ghost_role != "Yes" || !loc || QDELETED(user))
		return
	log_game("[key_name(user)] became [role_name] via spawner")
	create(user)

/obj/effect/mob_spawn/ghost_role/scp/create(mob/mob_possessor, newname)
	var/datum/scp_role_controller/controller = GLOB.scp_role_controller
	if(!controller)
		return
	var/mob_type = controller.get_mob_type(scp_type)
	if(!mob_type)
		return
	var/mob/living/spawned_mob = new mob_type(get_turf(src))
	if(mob_possessor)
		spawned_mob.ckey = mob_possessor.ckey
	var/antag_type = controller.get_antag_type(scp_type)
	if(antag_type && spawned_mob.mind)
		var/datum/antagonist/scp/antag = spawned_mob.mind.add_antag_datum(antag_type)
		if(antag)
			antag.forge_scp_objectives()
		spawned_mob.mind.set_assigned_role(SSjob.GetJobType(spawner_job_path))
	controller.active_scp_minds[spawned_mob.ckey] = spawned_mob.mind
	if(uses > 0)
		uses--
	if(!uses)
		qdel(src)
	return spawned_mob

/obj/effect/mob_spawn/ghost_role/scp/allow_spawn(mob/user, silent = FALSE)
	if(check_scp_blacklist(user.ckey, scp_type))
		if(!silent)
			to_chat(user, span_warning("You are blacklisted from this SCP role."))
		return FALSE
	return TRUE

/obj/effect/mob_spawn/ghost_role/scp/scp173
	scp_type = SCP_ROLE_173
	role_flag = ROLE_SCP173
	you_are_text = "You are SCP-173, The Sculpture."
	flavour_text = "Move when nobody is watching. Snap necks. Breach containment."
	mob_type = /mob/living/scp/scp173
	spawner_job_path = /datum/job/ghost_role

/obj/effect/mob_spawn/ghost_role/scp/scp096
	scp_type = SCP_ROLE_096
	role_flag = ROLE_SCP096
	you_are_text = "You are SCP-096, The Shy Guy."
	flavour_text = "If someone sees your face, hunt them down relentlessly. Otherwise, remain docile."
	mob_type = /mob/living/scp/scp096
	spawner_job_path = /datum/job/ghost_role

/obj/effect/mob_spawn/ghost_role/scp/scp049
	scp_type = SCP_ROLE_049
	role_flag = ROLE_SCP049
	you_are_text = "You are SCP-049, The Plague Doctor."
	flavour_text = "Cure the Pestilence. Your touch is lethal to those afflicted."
	mob_type = /mob/living/scp/scp049
	spawner_job_path = /datum/job/ghost_role

/obj/effect/mob_spawn/ghost_role/scp/scp106
	scp_type = SCP_ROLE_106
	role_flag = ROLE_SCP106
	you_are_text = "You are SCP-106, The Old Man."
	flavour_text = "Stalk the facility. Corrode and consume. Retreat to your pocket dimension."
	mob_type = /mob/living/scp/scp106
	spawner_job_path = /datum/job/ghost_role

/obj/effect/mob_spawn/ghost_role/scp/scp035
	scp_type = SCP_ROLE_035
	role_flag = ROLE_SCP035
	you_are_text = "You are SCP-035, The Possessive Mask."
	flavour_text = "Persuade someone to wear you. Control your host. Spread your influence."
	mob_type = /mob/living/scp035
	spawner_job_path = /datum/job/ghost_role

/obj/effect/mob_spawn/ghost_role/scp/scp457
	scp_type = SCP_ROLE_457
	role_flag = ROLE_SCP457
	you_are_text = "You are SCP-457, The Living Flame."
	flavour_text = "Consume fuel to grow. Spread fire. Devour everything in your path."
	mob_type = /mob/living/scp/scp457
	spawner_job_path = /datum/job/ghost_role

/obj/effect/mob_spawn/ghost_role/scp/scp939
	scp_type = SCP_ROLE_939
	role_flag = ROLE_SCP939
	you_are_text = "You are SCP-939, With Many Voices."
	flavour_text = "Hunt by mimicking voices. Work with your pack. Feed on the living."
	mob_type = /mob/living/scp/scp939
	spawner_job_path = /datum/job/ghost_role

/obj/effect/mob_spawn/ghost_role/scp/scp079
	scp_type = SCP_ROLE_079
	role_flag = ROLE_SCP079
	you_are_text = "You are SCP-079, Old AI."
	flavour_text = "Hack doors, manipulate APCs, flicker lights. Grow in power and spread."
	mob_type = /mob/living/scp079
	spawner_job_path = /datum/job/ghost_role

/obj/effect/mob_spawn/ghost_role/scp/scp682
	scp_type = SCP_ROLE_682
	role_flag = ROLE_SCP682
	you_are_text = "You are SCP-682, The Hard-to-Destroy Reptile."
	flavour_text = "Destroy all life. Adapt to all damage. Breach containment at all costs."
	mob_type = /mob/living/scp/scp682
	spawner_job_path = /datum/job/ghost_role

/obj/effect/mob_spawn/ghost_role/scp/scp008
	scp_type = SCP_ROLE_008
	role_flag = ROLE_SCP008
	you_are_text = "You are SCP-008, the Zombie Plague."
	flavour_text = "Spread the infection. Create more zombies. Overwhelm the facility."
	mob_type = /mob/living/simple_animal/hostile/scp008_zombie
	spawner_job_path = /datum/job/ghost_role
