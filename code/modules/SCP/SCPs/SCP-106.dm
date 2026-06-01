// SCP-106 - The Old Man
// Foundation-19 style: cannot speak, immune to bullets, auto-flees to pocket dimension at low health,
// phases through walls/objects via directional verbs, drags victims to pocket dimension,
// corrosive touch on attack, spooky sound verbs
// All mechanics are contextual - no action buttons needed

/mob/living/scp/scp106
	ai_enabled = TRUE
	name = "SCP-106"
	desc = "An elderly humanoid figure composed of a dark, viscous substance. Where it walks, reality rots."
	icon = 'icons/scp/scp-106.dmi'
	icon_state = "scp106"
	real_name = "SCP-106"
	persistence_id = "SCP-106"

	var/phase_cooldown_time = 2 SECONDS
	var/phase_time = 2 SECONDS
	var/pocket_dimension_cooldown_time = 20 SECONDS
	var/sound_cooldown_time = 4 SECONDS

	var/mob/living/target = null

	var/last_x = -1
	var/last_y = -1
	var/last_z = -1
	var/phasing = FALSE
	var/in_pocket_dimension = FALSE
	var/turf/pocket_dimension_turf = null
	var/area/spawn_area = null

	var/phase_cooldown = 0
	var/pocket_dimension_cooldown = 0
	var/sound_cooldown = 0

	var/corrosion_active = TRUE
	var/last_corrosion_tick = 0
	var/corrosion_tick_interval = 3 SECONDS

	var/cured_count = 0
	var/cures_attempted = 0
	var/cures_successful = 0
	var/containment_breaches = 0
	var/research_progress = 0

/mob/living/scp/scp106/Initialize()
	. = ..()

	SCP = new /datum/scp(src, "The Old Man", SCP_KETER, "106", SCP_PLAYABLE)
	SCP.min_time = 30 MINUTES
	SCP.min_playercount = 20

	maxHealth = SCP106_MAX_HEALTH
	health = maxHealth

	spawn_area = get_area(src)

/mob/living/scp/scp106/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(.)
		return
	if(stat == DEAD)
		return

	if(!in_pocket_dimension && (getBruteLoss() + getFireLoss() + getToxLoss() + getCloneLoss()) >= 200)
		if(!istype(get_area(src), /area/scp/pocket_dimension))
			to_chat(src, span_danger("<i>You flee back to your pocket dimension!</i>"))
			enter_pocket_dimension(TRUE)
			return

	if(in_pocket_dimension)
		process_pocket_dimension_healing()
		return

	process_passive_corrosion()
	process_weakness_damage()

	if(prob(5))
		playsound(src, 'sound/scp/106/breathing.ogg', 25, TRUE, extrarange = 5)

/mob/living/scp/scp106/Destroy()
	target = null
	return ..()

/mob/living/scp/scp106/say(message, bubble_type, list/spans, sanitize, datum/language/language, ignore_spam, forced, filterproof, range)
	to_chat(src, span_notice("You cannot speak."))
	return FALSE

/mob/living/scp/scp106/bullet_act(obj/projectile/P, def_zone)
	if(!P)
		return
	visible_message(span_warning("[P] harmlessly sinks into [src]'s acidic skin!"))
	return FALSE

/mob/living/scp/scp106/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	if(in_pocket_dimension)
		return FALSE
	. = ..()
	if(. && corrosion_active && !QDELETED(src))
		leave_corrosion_pool(get_turf(src))

/mob/living/scp/scp106/UnarmedAttack(atom/A)
	if(in_pocket_dimension)
		if(ismob(A))
			var/mob/living/L = A
			if(L != src && L.stat != DEAD)
				L.adjustToxLoss(rand(15, 25))
				playsound(L, pick('sound/scp/106/decay1.ogg', 'sound/scp/106/decay2.ogg'), rand(15, 30), TRUE)
		return

	if(ismob(A))
		var/mob/living/L = A
		if(L == src || L.stat == DEAD)
			return
		if(istype(L.buckled, /obj/machinery/scp_femur_breaker))
			return
		if(istype(get_area(L), /area/scp/pocket_dimension))
			L.adjustToxLoss(rand(15, 25))
			playsound(L, pick('sound/scp/106/decay1.ogg', 'sound/scp/106/decay2.ogg'), rand(15, 30), TRUE)
			return
		if(L.IsParalyzed() || !ishuman(L))
			WarpMob(L)
			return
		L.Paralyze(20)
		playsound(L, pick('sound/scp/106/decay1.ogg', 'sound/scp/106/decay2.ogg'), rand(15, 30), TRUE)
		visible_message(span_danger("[src] knocks [L] down!"))
		return

	if(istype(A, /obj/structure) || istype(A, /obj/machinery/door))
		corrode_structure(A)
		return

	if(istype(A, /turf/closed/wall/scp_containment))
		corrode_containment_wall(A)
		return

	return ..()

/mob/living/scp/scp106/attack_hand(mob/living/L)
	if(L == src)
		return
	if(!in_pocket_dimension)
		WarpMob(L)

/mob/living/scp/scp106/proc/WarpMob(mob/living/L)
	var/area/scp/pocket_dimension/pd = locate(/area/scp/pocket_dimension) in GLOB.areas
	if(!pd)
		return
	var/list/valid_turfs = list()
	for(var/turf/open/pocket_dimension/T in pd)
		valid_turfs += T
	if(!length(valid_turfs))
		return

	var/turf/T = pick(valid_turfs)
	visible_message(span_danger("[L] is warped away!"))
	playsound(L, pick('sound/scp/106/decay1.ogg', 'sound/scp/106/decay2.ogg', 'sound/scp/106/decay3.ogg'), 50, TRUE)
	if(L.buckled)
		L.buckled.unbuckle_mob(L)
	L.forceMove(T)
	L.Paralyze(20)

/mob/living/scp/scp106/proc/process_passive_corrosion()
	if(!corrosion_active)
		return
	if(world.time < last_corrosion_tick + corrosion_tick_interval)
		return
	last_corrosion_tick = world.time

	var/turf/T = get_turf(src)
	if(T)
		leave_corrosion_pool(T)
		if(prob(30))
			playsound(src, pick('sound/scp/106/decay1.ogg', 'sound/scp/106/decay2.ogg', 'sound/scp/106/decay3.ogg'), 30, TRUE, extrarange = 3)

/mob/living/scp/scp106/proc/process_weakness_damage()
	var/turf/T = get_turf(src)
	if(!T)
		return
	var/light_amount = T.get_lumcount()
	if(light_amount > 0.6)
		adjustBruteLoss(2)
	if(on_fire)
		adjustFireLoss(5)

/mob/living/scp/scp106/proc/process_pocket_dimension_healing()
	adjustBruteLoss(-5)
	adjustFireLoss(-5)
	adjustToxLoss(-5)
	if(health >= maxHealth)
		health = maxHealth

/mob/living/scp/scp106/proc/leave_corrosion_pool(turf/T)
	if(!T || T.density)
		return
	var/obj/effect/scp106_residue/existing = locate(/obj/effect/scp106_residue) in T
	if(existing)
		existing.linger_time = world.time + 45 SECONDS
		return
	new /obj/effect/scp106_residue(T)

/mob/living/scp/scp106/proc/corrode_structure(atom/target)
	target.visible_message(span_danger("[src] touches [target] — it decays before your eyes!"))
	playsound(target, 'sound/scp/106/wall_decay.ogg', 50, TRUE)
	if(istype(target, /obj/machinery/door))
		var/obj/machinery/door/D = target
		addtimer(CALLBACK(D, TYPE_PROC_REF(/obj/machinery/door, open), TRUE), 2 SECONDS)
	else if(istype(target, /obj/structure))
		var/obj/structure/S = target
		S.take_damage(80, BRUTE, "melee")

/mob/living/scp/scp106/proc/corrode_containment_wall(turf/closed/wall/scp_containment/target)
	try_scp_corrode_wall(src, target, 50)

/mob/living/scp/scp106/proc/enter_pocket_dimension(forced = FALSE)
	if(phasing)
		return FALSE

	var/turf/my_turf = get_turf(src)
	if(istype(get_area(my_turf), /area/scp/pocket_dimension))
		return FALSE

	if(!forced)
		if(pocket_dimension_cooldown > world.time)
			to_chat(src, span_warning("You are not ready to enter the pocket dimension just yet."))
			return FALSE
		if(stat != CONSCIOUS)
			return FALSE
		pocket_dimension_cooldown = world.time + 50
		if(!do_after(src, 4 SECONDS, my_turf))
			return FALSE

	var/area/scp/pocket_dimension/pd = locate(/area/scp/pocket_dimension) in GLOB.areas
	if(!pd)
		return FALSE

	var/list/valid_turfs = list()
	for(var/turf/open/pocket_dimension/T in pd)
		valid_turfs += T
	if(!length(valid_turfs))
		return FALSE

	pocket_dimension_cooldown = world.time + pocket_dimension_cooldown_time
	animate(src, alpha = 0, time = 5)
	set_last_xyz()
	sleep(5)
	if(QDELETED(src))
		return FALSE
	animate(src, alpha = 255, time = 5)
	forceMove(pick(valid_turfs))
	in_pocket_dimension = TRUE
	return TRUE

/mob/living/scp/scp106/proc/exit_pocket_dimension()
	if(!in_pocket_dimension)
		return FALSE

	if(pocket_dimension_cooldown > world.time)
		to_chat(src, span_warning("You are not ready to leave the pocket dimension just yet."))
		return FALSE

	var/turf/exit_loc = null
	if(last_x != -1)
		exit_loc = locate(last_x, last_y, last_z)
	if(!exit_loc || exit_loc.density)
		exit_loc = find_nearby_open_turf(last_x != -1 ? locate(last_x, last_y, last_z) : get_turf(src))

	if(!exit_loc)
		return FALSE

	in_pocket_dimension = FALSE
	alpha = 0
	forceMove(exit_loc)
	Paralyze(20)
	animate(src, alpha = 255, time = 5)
	visible_message(span_danger("[src] rises from the floor, black ooze dripping from its form!"), \
		span_notice("You emerge from your pocket dimension."))
	playsound(src, 'sound/scp/106/decay3.ogg', 60, TRUE)
	leave_corrosion_pool(exit_loc)
	pocket_dimension_cooldown = world.time + pocket_dimension_cooldown_time
	return TRUE

/mob/living/scp/scp106/proc/set_last_xyz()
	last_x = x
	last_y = y
	last_z = z

/mob/living/scp/scp106/proc/find_nearby_open_turf(center)
	for(var/turf/open/T in range(5, center))
		if(!T.density)
			return T
	return null

/mob/living/scp/scp106/proc/phase_through_object()
	set name = "Phase Through Object"
	set category = "SCP-106"
	set desc = "Phase through an object in front of you."

	if(world.time < phase_cooldown)
		to_chat(src, span_warning("You can't phase again yet."))
		return

	var/obj/target_object = null
	for(var/obj/O in get_step(src, dir))
		if(!isstructure(O) && !ismachinery(O))
			continue
		if(!O.density)
			continue
		if(istype(O, /obj/machinery/door/airlock/vault))
			to_chat(src, span_warning("You cannot phase through [O]."))
			return
		target_object = O

	if(!istype(target_object))
		to_chat(src, span_warning("There's nothing to phase through in that direction."))
		return

	var/turf/target_turf = get_step(target_object, dir)
	if(target_turf.density)
		to_chat(src, span_warning("The wall is preventing you from phasing in that direction."))
		return

	phase_cooldown = world.time + phase_cooldown_time

	target_turf.visible_message(span_danger("[target_object] corrodes, as something starts to appear from it."))
	var/obj_old_color = target_object.color
	animate(target_object, color = "#555555", time = phase_time)

	var/old_layer = layer
	var/anim_x = 0
	var/anim_y = 0
	layer = FLY_LAYER
	alpha = 128

	if(dir in list(NORTH, NORTHEAST, NORTHWEST))
		anim_y = 32
	if(dir in list(SOUTH, SOUTHEAST, SOUTHWEST))
		anim_y = -32
	if(dir in list(EAST, NORTHEAST, SOUTHEAST))
		anim_x = 32
	if(dir in list(WEST, NORTHWEST, SOUTHWEST))
		anim_x = -32
	animate(src, pixel_x = anim_x, pixel_y = anim_y, time = phase_time)

	playsound(target_object, pick('sound/scp/106/decay1.ogg', 'sound/scp/106/decay2.ogg', 'sound/scp/106/decay3.ogg'), 35, FALSE)

	if(do_after(src, phase_time, target_object))
		forceMove(get_step(src, dir))
		visible_message(span_danger("[src] phases through [target_object]."))
		leave_corrosion_pool(get_turf(src))

	animate(target_object, color = obj_old_color, time = 20 SECONDS)
	layer = old_layer
	alpha = 255
	pixel_x = 0
	pixel_y = 0

/mob/living/scp/scp106/proc/wall_phase()
	set name = "Enter Wall"
	set category = "SCP-106"
	set desc = "Enter the wall to move through it."

	if(phasing)
		return
	if(world.time < phase_cooldown)
		to_chat(src, span_warning("You can't phase again yet."))
		return

	var/turf/step_turf = get_step(src, dir)
	if(!step_turf || !istype(step_turf, /turf/closed/wall))
		to_chat(src, span_warning("There is no wall in that direction to enter."))
		return

	phase_cooldown = world.time + phase_cooldown_time

	var/old_layer = layer
	var/old_color = step_turf.color
	var/anim_x = 0
	var/anim_y = 0
	layer = FLY_LAYER
	alpha = 128

	if(dir in list(NORTH, NORTHEAST, NORTHWEST))
		anim_y = 32
	if(dir in list(SOUTH, SOUTHEAST, SOUTHWEST))
		anim_y = -32
	if(dir in list(EAST, NORTHEAST, SOUTHEAST))
		anim_x = 32
	if(dir in list(WEST, NORTHWEST, SOUTHWEST))
		anim_x = -32

	animate(src, pixel_x = anim_x, pixel_y = anim_y, time = phase_time)
	animate(step_turf, color = "#555555", time = phase_time)
	playsound(step_turf, pick('sound/scp/106/decay1.ogg', 'sound/scp/106/decay2.ogg', 'sound/scp/106/decay3.ogg'), 35, FALSE)

	if(do_after(src, phase_time, step_turf))
		phasing = TRUE
		var/list/valid_turfs = list()
		var/turf/current = get_turf(src)
		for(var/i = 1 to 8)
			var/turf/check = get_step(current, dir)
			if(check && istype(check, /turf/closed/wall))
				current = check
				valid_turfs += current
			else if(check && istype(check, /turf/open))
				valid_turfs += check
				break
			else
				break

		if(length(valid_turfs))
			var/turf/exit = valid_turfs[length(valid_turfs)]
			forceMove(exit)
			leave_corrosion_pool(exit)
			visible_message(span_danger("[src] phases through the wall!"))

		phasing = FALSE
		animate(step_turf, color = old_color, time = 2 SECONDS)
	else
		animate(step_turf, color = old_color, time = 2 SECONDS)

	layer = old_layer
	alpha = 255
	pixel_x = 0
	pixel_y = 0

/mob/living/scp/scp106/proc/drag_victim(mob/living/carbon/human/victim)
	if(!victim || victim.stat == DEAD)
		return
	if(get_dist(src, victim) > 1)
		to_chat(src, span_warning("They are too far away to grab."))
		return
	if(in_pocket_dimension)
		return

	victim.visible_message(span_danger("[src] drags [victim] downward into the floor!"), \
		span_userdanger("[src] pulls you into the floor! Darkness swallows you whole!"))
	playsound(victim, 'sound/scp/106/decay1.ogg', 60, TRUE)
	playsound(src, 'sound/scp/106/laugh.ogg', 40, TRUE)

	victim.adjustBruteLoss(15)

	WarpMob(victim)

/mob/living/scp/scp106/proc/audible_breathe()
	set name = "\[Sound\] Breathing"
	set category = "SCP-106"
	set desc = "Breathe. Creepily."

	if(world.time < sound_cooldown)
		return
	playsound(get_turf(src), 'sound/scp/106/breathing.ogg', rand(35, 65), TRUE)
	sound_cooldown = world.time + sound_cooldown_time

/mob/living/scp/scp106/proc/audible_laugh()
	set name = "\[Sound\] Laugh"
	set category = "SCP-106"
	set desc = "Laugh. Creepily."

	if(world.time < sound_cooldown)
		return
	playsound(get_turf(src), 'sound/scp/106/laugh.ogg', rand(35, 65), TRUE)
	sound_cooldown = world.time + sound_cooldown_time

/mob/living/scp/scp106/proc/toggle_corrosion(on)
	corrosion_active = on

/mob/living/scp/scp106/proc/on_breach()
	containment_breaches++
	hook_scp_breach("SCP-106", src)

/mob/living/scp/scp106/proc/on_recontainment()
	hook_scp_recontainment("SCP-106", list("method" = "femur_breaker"))

/mob/living/scp/scp106/process_ai()
	if(stat == DEAD)
		return
	if(containment_status != "breached")
		return
	if(world.time < last_ai_tick + ai_tick_interval)
		return
	last_ai_tick = world.time

	if(in_pocket_dimension)
		if(health >= maxHealth * 0.9 && world.time >= pocket_dimension_cooldown)
			exit_pocket_dimension()
		return

	var/health_pct = (getBruteLoss() + getFireLoss() + getToxLoss() + getCloneLoss()) / maxHealth
	if(health_pct > 0.7 && !istype(get_area(src), /area/scp/pocket_dimension))
		ai_flee_to_pocket()
		return

	if(prob(8))
		playsound(src, 'sound/scp/106/breathing.ogg', 25, TRUE, extrarange = 5)

	var/mob/living/carbon/human/prey = ai_find_prey()
	if(prey)
		ai_stalk_prey(prey)
	else
		ai_wander_and_corrode()

/mob/living/scp/scp106/proc/ai_flee_to_pocket()
	visible_message(span_danger("[src] sinks into the floor, fleeing to its pocket dimension!"))
	playsound(src, 'sound/scp/106/decay3.ogg', 50, TRUE)
	enter_pocket_dimension(TRUE)

/mob/living/scp/scp106/proc/ai_find_prey()
	var/mob/living/carbon/human/best_target = null
	var/best_score = -INFINITY
	for(var/mob/living/carbon/human/H in view(10, src))
		if(H.stat == DEAD || H == src)
			continue
		if(istype(H.buckled, /obj/machinery/scp_femur_breaker))
			continue
		var/score = 100 - get_dist(src, H) * 10
		if(H.IsParalyzed() || H.IsUnconscious())
			score += 50
		if(H.health < H.maxHealth * 0.5)
			score += 25
		if(istype(get_area(H), /area/scp/pocket_dimension))
			continue
		if(score > best_score)
			best_score = score
			best_target = H
	return best_target

/mob/living/scp/scp106/proc/ai_stalk_prey(mob/living/carbon/human/prey)
	if(get_dist(src, prey) <= 1)
		if(prey.IsParalyzed() || !ishuman(prey))
			WarpMob(prey)
			playsound(src, 'sound/scp/106/laugh.ogg', 40, TRUE)
		else
			prey.Paralyze(20)
			playsound(prey, pick('sound/scp/106/decay1.ogg', 'sound/scp/106/decay2.ogg'), 40, TRUE)
			visible_message(span_danger("[src] knocks [prey] down!"))
		return

	var/turf/target_turf = get_step_towards(src, prey)
	var/blocked = FALSE
	for(var/obj/O in target_turf)
		if(O.density)
			blocked = TRUE
			break
	if(target_turf.density)
		blocked = TRUE

	if(blocked && world.time >= phase_cooldown)
		dir = get_dir(src, prey)
		ai_phase_through_barrier()
		return

	step_to(src, prey)

	if(prob(15))
		playsound(src, pick('sound/scp/106/decay1.ogg', 'sound/scp/106/decay2.ogg', 'sound/scp/106/decay3.ogg'), 30, TRUE, extrarange = 3)

/mob/living/scp/scp106/proc/ai_phase_through_barrier()
	var/turf/step_turf = get_step(src, dir)
	if(!step_turf)
		return

	if(istype(step_turf, /turf/closed/wall))
		var/old_alpha = alpha
		alpha = 128
		animate(step_turf, color = "#555555", time = 5)
		var/list/exit_turfs = list()
		var/turf/current = get_turf(src)
		for(var/i in 1 to 8)
			var/turf/check = get_step(current, dir)
			if(!check)
				break
			if(istype(check, /turf/closed/wall))
				current = check
				exit_turfs += current
			else if(istype(check, /turf/open))
				exit_turfs += check
				break
			else
				break
		if(length(exit_turfs))
			forceMove(exit_turfs[length(exit_turfs)])
			leave_corrosion_pool(get_turf(src))
			visible_message(span_danger("[src] phases through the wall!"))
			playsound(src, pick('sound/scp/106/decay1.ogg', 'sound/scp/106/decay2.ogg', 'sound/scp/106/decay3.ogg'), 35, TRUE)
		animate(step_turf, color = initial(step_turf.color), time = 2 SECONDS)
		alpha = old_alpha
		phase_cooldown = world.time + phase_cooldown_time
		return

	for(var/obj/machinery/door/D in step_turf)
		if(D.density)
			corrode_structure(D)
			phase_cooldown = world.time + phase_cooldown_time
			return
	for(var/obj/structure/S in step_turf)
		if(S.density)
			corrode_structure(S)
			phase_cooldown = world.time + phase_cooldown_time
			return

/mob/living/scp/scp106/proc/ai_wander_and_corrode()
	if(ai_home_turf && get_dist(src, ai_home_turf) > ai_wander_range * 2)
		var/turf/target_turf = get_step_towards(src, ai_home_turf)
		var/blocked = FALSE
		for(var/obj/O in target_turf)
			if(O.density)
				blocked = TRUE
				break
		if(target_turf.density)
			blocked = TRUE
		if(blocked && world.time >= phase_cooldown)
			dir = get_dir(src, ai_home_turf)
			ai_phase_through_barrier()
		else
			step_to(src, ai_home_turf)
	else if(prob(60))
		step_rand(src)

	if(prob(25))
		var/obj/machinery/door/D = locate() in range(2, src)
		if(D && D.density)
			corrode_structure(D)

	if(prob(15))
		var/obj/structure/S = locate() in range(2, src)
		if(S && S.density)
			corrode_structure(S)

/mob/living/scp/scp106/get_status_tab_items()
	var/list/status_items = ..()
	status_items += "Pocket Dimension: [in_pocket_dimension ? "INSIDE" : "Outside"]"
	status_items += "Corrosion: [corrosion_active ? "Active" : "Suppressed"]"
	return status_items

/obj/effect/scp106_residue
	name = "dark residue"
	desc = "A pool of thick, black substance. It seems to eat away at whatever it touches."
	icon = 'icons/effects/effects.dmi'
	icon_state = "greenglow"
	color = "#1a0a0a"
	layer = ABOVE_OPEN_TURF_LAYER
	anchored = TRUE
	var/linger_time = 0
	var/damage_amount = 3
	var/last_damage_tick = 0
	var/damage_interval = 2 SECONDS

/obj/effect/scp106_residue/Initialize(mapload)
	. = ..()
	linger_time = world.time + 45 SECONDS
	START_PROCESSING(SSobj, src)

/obj/effect/scp106_residue/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/scp106_residue/process()
	if(world.time >= linger_time)
		qdel(src)
		return
	if(world.time < last_damage_tick + damage_interval)
		return
	last_damage_tick = world.time
	for(var/mob/living/carbon/human/H in get_turf(src))
		if(H.stat == DEAD || H.SCP)
			continue
		H.adjustBruteLoss(damage_amount)
		H.adjustToxLoss(damage_amount * 0.5)
		if(prob(10))
			to_chat(H, span_warning("The black ooze burns your feet!"))
