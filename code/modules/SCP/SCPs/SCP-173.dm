// SCP-173 - The Sculpture
// Foundation-19 style rewrite: all mechanics inline on the mob, no modular datums.
// Core loop: cannot move/act while observed. Click humans to snap neck. Click doors to pry open.
// Blink system gives humans near 173 a "Blink" verb — blinking creates a 2s window for 173 to act.
// Defecation: 173 passively generates filth in its containment area; at 40+ objects it warns, at 60+ the area breaches.

/mob/living/scp/scp173
	ai_enabled = TRUE
	name = "SCP-173"
	desc = "A tall, thin humanoid figure made of concrete and rebar. Krylon brand spray paint is visible on its surface."
	icon = 'icons/scp/scp-173.dmi'
	icon_state = "173"
	real_name = "SCP-173"
	persistence_id = "SCP-173"
	status_flags = GODMODE | CANPUSH

	var/snap_cooldown = 0
	var/snap_cooldown_time = 4 SECONDS
	var/door_cooldown = 0
	var/door_cooldown_time = 3 SECONDS
	var/light_break_cooldown = 0
	var/light_break_cooldown_time = 3 SECONDS

	var/defecate_timer = 0
	var/defecate_interval = 45 SECONDS
	var/feces_count = 0

	var/kills_count = 0
	var/last_observation_check = 0
	var/observation_check_interval = 1 SECONDS
	var/is_being_observed = FALSE
	var/list/scp173_observers = list()

	var/blink_warning_shown = FALSE
	var/successful_movements = 0
	var/victims_killed = 0
	var/containment_breaches = 0

/mob/living/scp/scp173/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "The Sculpture", SCP_EUCLID, "173", SCP_PLAYABLE)
	SCP.min_playercount = 30
	SCP.min_time = 15 MINUTES

	grant_language(/datum/language/common, TRUE, TRUE)

	RegisterSignal(src, COMSIG_MOB_SAY, PROC_REF(on_speak))
	add_movespeed_modifier(/datum/movespeed_modifier/scp173_fast)

/mob/living/scp/scp173/Destroy()
	for(var/mob/living/carbon/human/H in range(9, src))
		if(H.blink_173 == src)
			H.disable_blink_173()
	scp173_observers = null
	UnregisterSignal(src, COMSIG_MOB_SAY)
	return ..()

/mob/living/scp/scp173/proc/on_speak(mob/living/source, list/speech_args)
	SIGNAL_HANDLER
	speech_args[SPEECH_MESSAGE] = ""

/mob/living/scp/scp173/Move(a, b, flag)
	if(IsBeingWatched())
		return FALSE
	. = ..()
	if(.)
		if(prob(40))
			playsound(src, 'sound/scp/173/rattle.ogg', 30, TRUE)

/mob/living/scp/scp173/face_atom(atom/A)
	if(IsBeingWatched())
		return
	return ..()

/mob/living/scp/scp173/UnarmedAttack(atom/A)
	if(IsBeingWatched())
		to_chat(src, span_warning("You cannot act while being observed!"))
		return

	if(ishuman(A))
		var/mob/living/carbon/human/target = A
		if(target.stat == DEAD)
			return
		if(world.time < snap_cooldown)
			to_chat(src, span_warning("You need a moment before you can snap again."))
			return
		snap_cooldown = world.time + snap_cooldown_time
		target.death()
		playsound(target, 'sound/weapons/genhit.ogg', 80, TRUE)
		if(prob(50))
			playsound(target, pick('sound/scp/spook/NeckSnap1.ogg', 'sound/scp/spook/NeckSnap3.ogg'), 80, FALSE, extrarange = 5)
		visible_message(span_danger("[src] snaps [target]'s neck with devastating force!"), span_notice("You snap [target]'s neck."))
		kills_count++
		on_kill(target)
		return

	if(istype(A, /obj/machinery/door))
		OpenDoor(A)
		return

	if(istype(A, /obj/machinery/light))
		if(world.time < light_break_cooldown)
			return
		light_break_cooldown = world.time + light_break_cooldown_time
		var/obj/machinery/light/L = A
		L.break_light_tube()
		visible_message(span_danger("[src] smashes the light!"))
		return

	if(istype(A, /obj/structure/window))
		var/obj/structure/window/W = A
		W.deconstruct(FALSE)
		return

	if(istype(A, /obj/structure/grille))
		playsound(A, 'sound/effects/grillehit.ogg', 50, TRUE)
		qdel(A)
		return

	if(istype(A, /obj/structure/inflatable))
		var/obj/structure/inflatable/I = A
		I.deflate(violent = TRUE)
		return

	if(istype(A, /obj/structure/closet))
		var/obj/structure/closet/C = A
		C.open()
		for(var/atom/movable/AM in C.contents)
			AM.forceMove(get_turf(C))
		visible_message(span_danger("[src] rips open [C]!"))
		return

	return ..()

/mob/living/scp/scp173/process_ai()
	return

/mob/living/scp/scp173/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(.)
		return
	if(stat == DEAD)
		return

	ProcessObservation()
	ProcessDefecation()
	UpdateBlinkHUD()

	if(!client && !IsBeingWatched())
		handle_AI()

/mob/living/scp/scp173/proc/IsBeingWatched()
	if(stat == DEAD)
		return FALSE
	return is_being_observed

/mob/living/scp/scp173/proc/ProcessObservation()
	if(world.time < last_observation_check + observation_check_interval)
		return
	last_observation_check = world.time

	var/list/current_observers = list()
	var/atom/observe_source = istype(loc, /obj/structure/scp173_cage) ? loc : src

	for(var/mob/living/L in dview(9, observe_source))
		if(L == src || L.stat == DEAD)
			continue

		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			if(H.is_blind() || H.eye_blind > 0)
				continue
			if(!can_see(H, observe_source, 9))
				continue
			current_observers += H

	scp173_observers = current_observers
	var/was_observed = is_being_observed
	is_being_observed = length(current_observers) > 0

	if(is_being_observed && !was_observed)
		for(var/mob/living/carbon/human/H in current_observers)
			on_observation_start(H)
	else if(!is_being_observed && was_observed)
		for(var/mob/living/carbon/human/H in scp173_observers)
			on_observation_end(H)

	var/atom/blink_source = istype(loc, /obj/structure/scp173_cage) ? loc : src
	for(var/mob/living/carbon/human/H in range(9, blink_source))
		if(H.stat != DEAD && H.client)
			if(is_being_observed && !(H in current_observers))
				H.enable_blink_173(src)
			else if(!is_being_observed)
				if(H.blink_173 == src)
					H.disable_blink_173()

/mob/living/scp/scp173/proc/UpdateBlinkHUD()
	if(!is_being_observed)
		blink_warning_shown = FALSE
		return
	if(!blink_warning_shown && length(scp173_observers))
		to_chat(src, span_warning("You are being observed by [length(scp173_observers)] person[length(scp173_observers) > 1 ? "s" : ""]. You cannot move!"))
		blink_warning_shown = TRUE
	else if(blink_warning_shown && !length(scp173_observers))
		blink_warning_shown = FALSE

/mob/living/scp/scp173/proc/OpenDoor(obj/machinery/door/D)
	if(!istype(D))
		return
	if(!D.density)
		return
	if(IsBeingWatched())
		to_chat(src, span_warning("You cannot act while being observed!"))
		return

	var/pry_time = 4 SECONDS
	if(istype(D, /obj/machinery/door/poddoor))
		pry_time = 16 SECONDS

	var/obj/machinery/door/airlock/A = D
	if(istype(A))
		if(A.locked)
			pry_time += 23 SECONDS
		if(A.welded)
			pry_time += 3 SECONDS

	visible_message(span_danger("[src] begins prying [D] open!"), span_notice("You begin forcing [D] open..."))
	if(!do_after(src, pry_time, D))
		return
	if(IsBeingWatched())
		to_chat(src, span_warning("Someone started watching! You freeze!"))
		return

	if(istype(D, /obj/machinery/door/poddoor))
		var/obj/machinery/door/poddoor/P = D
		P.open()
		visible_message(span_danger("[src] forces the blast door open!"), span_notice("You force the blast door open."))
	else if(istype(A))
		A.locked = FALSE
		A.welded = FALSE
		A.open()
		visible_message(span_danger("[src] tears [A] open with inhuman strength!"), span_notice("You tear the airlock open."))
	else
		D.open()
		visible_message(span_danger("[src] forces [D] open!"), span_notice("You force the door open."))

	playsound(D, 'sound/machines/door_open.ogg', 80, TRUE)
	breach_count++
	hook_scp_breach("SCP-173", src)

/mob/living/scp/scp173/proc/ProcessDefecation()
	if(world.time < defecate_timer + defecate_interval)
		return
	defecate_timer = world.time

	var/turf/T = get_turf(src)
	if(!T)
		return

	var/obj/effect/decal/cleanable/dirt = pick(list(
		/obj/effect/decal/cleanable/blood,
		/obj/effect/decal/cleanable/vomit,
		/obj/effect/decal/cleanable/dirt
	))
	new dirt(T)

	feces_count = CountFeces()

	if(feces_count >= 60)
		hook_scp_breach("SCP-173", src)
		breach_count++
	else if(feces_count >= 40)
		to_chat(src, span_warning("The containment chamber is becoming heavily soiled. Personnel should clean it."))

/mob/living/scp/scp173/proc/CountFeces()
	var/count = 0
	for(var/obj/effect/decal/cleanable/C in range(5, src))
		count++
	return count

/mob/living/scp/scp173/get_status_tab_items()
	var/list/status_items = ..()
	status_items += "Observed: [is_being_observed ? "YES" : "NO"]"
	status_items += "Observers: [length(scp173_observers)]"
	status_items += "Kills: [kills_count]"
	status_items += "Breaches: [breach_count]"
	status_items += "Feces: [feces_count][feces_count >= 40 ? " (CRITICAL)" : ""]"
	return status_items

/mob/living/scp/scp173/death(gibbed)
	return ..()

/mob/living/scp/scp173/proc/scp914_refine(setting, obj/machinery/scp914/machine)
	if(!machine)
		return
	switch(setting)
		if(SCP914_ROUGH, SCP914_COARSE)
			snap_cooldown_time = max(8 SECONDS, snap_cooldown_time + 2 SECONDS)
			remove_movespeed_modifier(/datum/movespeed_modifier/scp173_fast)
			add_movespeed_modifier(/datum/movespeed_modifier/scp173_slow)
			visible_message(span_danger("[src] is degraded by SCP-914! It moves more slowly."))
			to_chat(src, span_warning("The refinement damages your structure. You feel slower."))
		if(SCP914_ONE_TO_ONE)
			defecate_interval = max(20 SECONDS, defecate_interval + 10 SECONDS)
			visible_message(span_notice("[src] is transmuted by SCP-914. Its surface changes slightly."))
			to_chat(src, span_notice("You feel... different. Your defecation rate has changed."))
		if(SCP914_FINE, SCP914_VERY_FINE)
			snap_cooldown_time = max(2 SECONDS, snap_cooldown_time - 1 SECONDS)
			remove_movespeed_modifier(/datum/movespeed_modifier/scp173_fast)
			add_movespeed_modifier(/datum/movespeed_modifier/scp173_enhanced)
			if(setting == SCP914_VERY_FINE)
				maxHealth += 100
				health = min(health + 100, maxHealth)
				to_chat(src, span_danger("The refinement empowers you immensely! You are faster, stronger, and more resilient!"))
			else
				to_chat(src, span_notice("The refinement sharpens you. You feel faster and more lethal."))
			visible_message(span_danger("[src] is enhanced by SCP-914! It seems more dangerous!"))
	hook_scp_interaction(src, "SCP-914", INTERACTION_TYPE_EXPERIMENT, list("type" = "173_refinement", "setting" = setting))
	if(machine.output_booth)
		var/turf/output_turf = get_turf(machine.output_booth)
		if(output_turf)
			forceMove(output_turf)

/mob/living/scp/scp173/proc/on_kill(mob/living/carbon/human/victim)
	if(victim && victim.ckey)
		hook_player_death_near_scp(victim, "SCP-173")
		hook_scp_combat(victim, "SCP-173", 100, 0)

/mob/living/scp/scp173/proc/on_observation_start(mob/living/carbon/human/observer)
	if(observer && observer.ckey)
		hook_scp_observation(observer, "SCP-173")

/mob/living/scp/scp173/proc/on_observation_end(mob/living/carbon/human/observer)
	if(observer && observer.ckey)
		stop_scp_survival_tracking(observer, "SCP-173")

// ===== AI System =====

/mob/living/scp/scp173/proc/handle_AI()
	if(stat == DEAD)
		return
	if(IsBeingWatched())
		ai_target = null
		if(length(scp173_observers) >= 3)
			var/atom/flee_dir = get_step_away(src, scp173_observers[1])
			if(flee_dir)
				Move(get_turf(flee_dir))
		return

	ai_target = find_scp173_target()
	if(ai_target)
		move_to_target(ai_target)
		if(get_dist(src, ai_target) <= 1)
			UnarmedAttack(ai_target)
	else
		if(prob(20))
			var/obj/machinery/light/L = locate() in range(5, src)
			if(L && L.on)
				UnarmedAttack(L)
				return
		if(prob(30))
			var/obj/machinery/door/D = locate() in range(2, src)
			if(D && D.density)
				OpenDoor(D)
				return
		if(prob(40))
			step_rand(src)

/mob/living/scp/scp173/proc/find_scp173_target()
	var/mob/living/carbon/human/nearest
	var/shortest_distance = INFINITY
	for(var/mob/living/carbon/human/H in view(10, src))
		if(H.stat == DEAD || H == src)
			continue
		var/d = get_dist(src, H)
		if(d < shortest_distance)
			shortest_distance = d
			nearest = H
	return nearest

/mob/living/scp/scp173/proc/move_to_target(mob/living/target)
	if(!target || IsBeingWatched())
		return
	step_to(src, target)

// ===== Blink System (applied to nearby humans) =====

/mob/living/carbon/human/var/mob/living/scp/scp173/blink_173 = null
/mob/living/carbon/human/var/blink_173_timer = null
/mob/living/carbon/human/var/blink_173_cd = null
/mob/living/carbon/human/var/blinking_173 = FALSE

/mob/living/carbon/human/proc/enable_blink_173(mob/living/scp/scp173/scp)
	if(blink_173 == scp)
		return
	disable_blink_173()
	blink_173 = scp
	add_verb(src, /mob/living/carbon/human/proc/manual_blink)
	if(!blink_173_cd)
		blink_173_cd = addtimer(CALLBACK(src, PROC_REF(do_blink_173)), rand(25 SECONDS, 40 SECONDS), TIMER_STOPPABLE | TIMER_LOOP | TIMER_UNIQUE)

/mob/living/carbon/human/proc/disable_blink_173()
	remove_verb(src, /mob/living/carbon/human/proc/manual_blink)
	if(blink_173_cd)
		deltimer(blink_173_cd)
		blink_173_cd = null
	if(blink_173_timer)
		deltimer(blink_173_timer)
		blink_173_timer = null
	blinking_173 = FALSE
	blink_173 = null

/mob/living/carbon/human/proc/do_blink_173()
	if(!blink_173 || stat == DEAD || !client)
		disable_blink_173()
		return
	if(is_blind())
		return
	blinking_173 = TRUE
	eye_blind += 2
	to_chat(src, span_notice("You blink."))
	blink_173_timer = addtimer(CALLBACK(src, PROC_REF(end_blink_173)), 2 SECONDS, TIMER_STOPPABLE | TIMER_UNIQUE)

/mob/living/carbon/human/proc/end_blink_173()
	blinking_173 = FALSE
	if(blink_173 && stat != DEAD && client)
		blink_173_cd = addtimer(CALLBACK(src, PROC_REF(do_blink_173)), rand(25 SECONDS, 40 SECONDS), TIMER_STOPPABLE | TIMER_UNIQUE)

/mob/living/carbon/human/proc/manual_blink()
	set name = "Blink"
	set category = "IC"
	if(!blink_173)
		to_chat(usr, span_notice("You don't need to blink right now."))
		return
	if(blink_173_cd)
		deltimer(blink_173_cd)
		blink_173_cd = null
	do_blink_173()

/datum/movespeed_modifier/scp173_fast
	id = "scp173_fast"
	priority = 100
	slowdown = -6.6

/obj/structure/scp173_cage
	name = "SCP-173 Containment Cage"
	desc = "A reinforced steel cage designed to contain SCP-173 during transport and cleaning."
	icon = 'icons/scp/cage.dmi'
	icon_state = "open"
	density = TRUE
	layer = ABOVE_MOB_LAYER
	var/resist_cooldown = 0
	var/damage_state = 0
	var/damage_state_max = 5

/obj/structure/scp173_cage/MouseDroppedOn(atom/movable/dropping, mob/user)
	if(locate(/mob/living) in contents)
		to_chat(user, span_warning("\The [src] is already full!"))
		return FALSE
	if(damage_state >= damage_state_max)
		to_chat(user, span_warning("\The [src] is too damaged to operate!"))
		return FALSE
	if(istype(dropping, /mob/living/scp/scp173))
		visible_message(span_warning("[user] starts to put [dropping] into the cage."))
		var/oloc = loc
		if(do_after(user, dropping, 13 SECONDS) && loc == oloc)
			dropping.forceMove(src)
			update_icon()
			visible_message(span_notice("[user] puts [dropping] in the cage."))
			playsound(loc, 'sound/machines/boltsdown.ogg', 50, TRUE)
			return TRUE
		return FALSE
	if(isliving(dropping))
		to_chat(user, span_warning("\The [dropping] won't fit in the cage."))
	return FALSE

/obj/structure/scp173_cage/attack_hand(mob/living/L)
	if(!length(contents))
		return ..()
	visible_message(span_warning("[L] attempts to open \the [src]."))
	if(do_after(L, src, 7 SECONDS))
		visible_message(span_danger("[L] opens \the [src]!"))
		ReleaseContents()

/obj/structure/scp173_cage/relaymove(mob/living/scp/scp173/user, direction)
	if(resist_cooldown > world.time)
		return
	if(user.IsBeingWatched())
		to_chat(user, span_warning("Someone is looking at you!"))
		return
	resist_cooldown = world.time + 5 SECONDS
	if(!do_after(user, src, 1 SECOND))
		return
	if(user.IsBeingWatched())
		to_chat(user, span_warning("Someone is looking at you!"))
		return
	damage_state += 1
	update_icon()
	if(damage_state < damage_state_max)
		visible_message(span_warning("[user] damages \the [src]!"))
		playsound(src, 'sound/effects/grillehit.ogg', 35, TRUE)
		return
	visible_message(span_danger("[user] opens \the [src] from the inside!"))
	ReleaseContents()

/obj/structure/scp173_cage/examine(mob/user)
	. = ..()
	for(var/mob/M in contents)
		to_chat(user, "[icon2html(M, user)] It has [M] inside of it!")
	switch(damage_state)
		if(1 to 2)
			to_chat(user, span_notice("It looks slightly damaged."))
		if(3 to 4)
			to_chat(user, span_warning("It is seriously damaged!"))
		if(5 to INFINITY)
			to_chat(user, span_danger("It is completely broken!"))

/obj/structure/scp173_cage/update_icon()
	. = ..()
	underlays.Cut()

	if(!length(contents))
		plane = initial(plane)
		icon_state = "open"
	else
		plane = GAME_PLANE
		icon_state = "closed"

	switch(damage_state)
		if(1 to 2)
			icon_state = "damage_1"
		if(3 to 4)
			icon_state = "damage_2"
		if(5 to INFINITY)
			icon_state = "damage_3"

	for(var/mob/M in contents)
		underlays += image(M)

/obj/structure/scp173_cage/attackby(obj/item/I, mob/user)
	if(!istype(I, /obj/item/weldingtool))
		return ..()
	if(length(contents))
		to_chat(user, span_warning("\The [src] must be empty to complete this task!"))
		return
	if(damage_state <= 0)
		to_chat(user, span_notice("\The [src] is not damaged."))
		return

	var/obj/item/weldingtool/WT = I
	if(!WT.isOn())
		to_chat(user, span_warning("\The [WT] must be on to complete this task."))
		return
	if(WT.get_fuel() < damage_state)
		to_chat(user, span_warning("You will need more fuel to repair [src]."))
		return
	playsound(src, 'sound/items/Welder2.ogg', 30, TRUE)
	user.visible_message(span_notice("\The [user] starts repairing sections of \the [src]."))
	if(!do_after(user, src, 6 SECONDS + damage_state SECONDS))
		return
	if(!WT.use(damage_state))
		return
	user.visible_message(span_notice("\The [user] successfully repairs a section of \the [src]."))
	damage_state -= 1
	update_icon()
	if(damage_state <= 0)
		visible_message(span_notice("\The [src] is completely repaired!"))
	playsound(loc, 'sound/items/Welder.ogg', 30, TRUE)

/obj/structure/scp173_cage/proc/ReleaseContents()
	if(!length(contents))
		return FALSE
	playsound(loc, 'sound/machines/boltsup.ogg', 50, TRUE)
	for(var/mob/living/L in contents)
		L.forceMove(get_turf(src))
	update_icon()
	return TRUE

/obj/structure/scp173_cage/Destroy()
	ReleaseContents()
	return ..()

/datum/movespeed_modifier/scp173_slow
	id = "scp173_slow"
	priority = 100
	slowdown = -3.0

/datum/movespeed_modifier/scp173_enhanced
	id = "scp173_enhanced"
	priority = 100
	slowdown = -8.0
