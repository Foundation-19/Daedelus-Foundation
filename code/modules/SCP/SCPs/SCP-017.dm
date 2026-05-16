// SCP-017 - Shadow Person
// A shadowy humanoid that attacks anything which casts a shadow upon it, engulfing the shadow-caster entirely

/mob/living/scp/scp017
	name = "shadow person"
	desc = "A 1.8-metre-tall shadowy humanoid figure. It seems to absorb the light around it."
	icon = 'icons/scp/scp-017.dmi'
	icon_state = "shadow"
	real_name = "SCP-017"
	use_custom_sprite = TRUE
	status_flags = 0
	maxHealth = 150
	health = 150
	max_scp_health = 150
	scp_health = 150
	max_scp_armor = 50
	scp_armor = 50

	var/engulf_cooldown = 0
	var/engulf_cooldown_time = 3 SECONDS
	var/shadow_detection_range = 7
	var/victims_engulfed = 0

/mob/living/scp/scp017/Initialize(mapload, new_species = "SCP-017")
	. = ..()
	SCP = new /datum/scp(src, "shadow person", SCP_EUCLID, "017", SCP_PLAYABLE)
	SCP.min_playercount = 20
	SCP.min_time = 5 MINUTES

/mob/living/scp/scp017/process_scp_effects()
	. = ..()

	if(stat == DEAD)
		return

	if(engulf_cooldown > world.time)
		return

	var/turf/my_turf = get_turf(src)
	if(!my_turf)
		return

	var/my_lumcount = my_turf.get_lumcount()
	if(my_lumcount < 0.15)
		return

	var/mob/living/shadow_caster = find_shadow_caster(my_turf, my_lumcount)
	if(shadow_caster)
		engulf_target(shadow_caster)

/mob/living/scp/scp017/proc/find_shadow_caster(turf/my_turf, my_lumcount)
	for(var/mob/living/L in range(shadow_detection_range, src))
		if(L == src || L.stat == DEAD)
			continue

		var/turf/their_turf = get_turf(L)
		if(!their_turf)
			continue

		var/their_lumcount = their_turf.get_lumcount()
		if(their_lumcount < 0.15)
			continue

		var/list/line_turfs = get_line(L, src)
		var/caster_index = 0
		var/my_index = 0
		for(var/i in 1 to length(line_turfs))
			var/turf/T = line_turfs[i]
			if(T == their_turf)
				caster_index = i
			if(T == my_turf)
				my_index = i

		if(caster_index <= 0 || my_index <= 0 || my_index <= caster_index)
			continue

		var/casts_shadow = FALSE
		if(L.opacity || L.density)
			casts_shadow = TRUE
		else
			for(var/obj/structure/S in their_turf)
				if(S.opacity || S.density)
					casts_shadow = TRUE
					break

		if(casts_shadow)
			return L

	return null

/mob/living/scp/scp017/proc/engulf_target(mob/living/target)
	if(!target || engulf_cooldown > world.time)
		return

	engulf_cooldown = world.time + engulf_cooldown_time

	src.visible_message(
		"<span class='danger'>[src] lunges at [target], engulfing [target.p_them()] in shadow!</span>",
		"<span class='danger'>You engulf [target] in shadow!</span>"
	)

	if(target in view(1, src))
		target.visible_message(
			"<span class='userdanger'>[target] is swallowed whole by [src]!</span>",
			"<span class='userdanger'>The shadow consumes you utterly!</span>"
		)

		target.death()
		victims_engulfed++

		var/obj/effect/decal/cleanable/ash/A = new /obj/effect/decal/cleanable/ash(get_turf(target))
		A.visible_message("<span class='danger'>Only a small pile of ash remains where [target] once stood.</span>")

		if(ismob(target))
			var/mob/M = target
			M.ghostize(TRUE)
			qdel(target)

		hook_scp_combat(target, "SCP-017", 100, 0)
		hook_player_death_near_scp(target, "SCP-017")
		hook_scp_breach("SCP-017", src)
		SCP.log_interaction(target, "engulf")
		SCP.award_research(target, "combat", 25)
	else
		step_to(src, target)
		if(target in view(1, src))
			engulf_cooldown = 0
			engulf_target(target)

/mob/living/scp/scp017/UnarmedAttack(atom/A)
	if(!istype(A, /mob/living))
		return ..()

	var/mob/living/L = A
	if(L.stat == DEAD)
		return ..()

	engulf_target(L)

/mob/living/scp/scp017/get_status_tab_items()
	. = ..()
	. += "Victims Engulfed: [victims_engulfed]"
	. += "Engulf Cooldown: [max(0, round((engulf_cooldown - world.time) / 10))] seconds"

	var/turf/T = get_turf(src)
	if(T)
		var/lum = round(T.get_lumcount() * 100, 1)
		. += "Local Light Level: [lum]%"

/mob/living/scp/scp017/examine(mob/user)
	. = ..()
	. += "<span class='warning'>A shadowy figure that attacks anything which casts a shadow upon it. Keep it in the dark.</span>"
	if(victims_engulfed > 0)
		. += "<span class='danger'>It has consumed [victims_engulfed] victim\s.</span>"

/mob/living/scp/scp017/scp_death()
	visible_message("<span class='danger'>[src] dissolves into darkness!</span>")
	playsound(src, 'sound/effects/explosion2.ogg', 50)
	..()
