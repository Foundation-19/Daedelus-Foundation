#define SCP513_PHASE_WHISPER 1
#define SCP513_PHASE_STALK 2
#define SCP513_PHASE_HUNT 3
#define SCP513_PHASE_CONSUME 4

#define STALK_BEHAVIOR_DISTANT 1
#define STALK_BEHAVIOR_CIRCLE 2
#define STALK_BEHAVIOR_APPROACH 3
#define STALK_BEHAVIOR_LUNGE 4

/mob/living/carbon/human
	var/datum/element/scp513_stalked/scp513_stalked_ref = null

/obj/item/scp513
	name = "SCP-513"
	desc = "A rusted cowbell. Touching it makes you want to ring it."
	icon = 'icons/scp/scp-513.dmi'
	icon_state = "mindfuckcowbell"
	var/ring_cooldown = 0
	var/ring_cooldown_time = 30 SECONDS
	var/hear_radius = 7
	var/list/affected_mobs = list()
	var/ring_count = 0

/obj/item/scp513/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "A Cowbell", SCP_EUCLID, "513")

/obj/item/scp513/Destroy()
	for(var/mob/living/carbon/human/H in affected_mobs)
		if(H && !QDELETED(H))
			H.RemoveElement(/datum/element/scp513_stalked)
	affected_mobs = list()
	QDEL_NULL(SCP)
	return ..()

/obj/item/scp513/proc/ring_bell(mob/user)
	if(world.time < ring_cooldown)
		return
	ring_cooldown = world.time + ring_cooldown_time
	ring_count++
	visible_message("<span class='danger'>[user] rings SCP-513!</span>")
	playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)
	hook_scp_breach("SCP-513", src)
	for(var/mob/living/carbon/human/H in range(hear_radius, src))
		if(H == user || H.SCP || H.stat == DEAD)
			continue
		if(!(H in affected_mobs))
			affected_mobs += H
			H.AddElement(/datum/element/scp513_stalked)
			to_chat(H, "<span class='danger'>You hear the cowbell ring. Something has noticed you.</span>")
			hook_scp_interaction(H, "SCP-513", INTERACTION_TYPE_OBSERVATION)
		else
			if(H.scp513_stalked_ref)
				H.scp513_stalked_ref.intensify(H)
			to_chat(H, "<span class='warning'>The cowbell rings again... the presence feels closer.</span>")

/obj/item/scp513/attack_self(mob/user)
	ring_bell(user)

/obj/item/scp513/examine(mob/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			. += "<span class='warning'>SCP-513 - Ringing causes SCP-513-1 to stalk all who hear it. Only Class-B amnestics or above can halt the effect; Class-A is insufficient.</span>"
		else
			. += "<span class='danger'>A rusted cowbell. You feel an odd compulsion to ring it.</span>"

/datum/element/scp513_stalked
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	var/phase = SCP513_PHASE_WHISPER
	var/stalk_duration = 0
	var/last_sighting = 0
	var/sanity_drain_rate = 0.3
	var/sighting_cooldown = 60 SECONDS
	var/sighting_interval_min = 90 SECONDS
	var/sighting_interval_max = 300 SECONDS
	var/next_sighting = 0
	var/next_sleep_attempt = 0
	var/sleep_attempt_interval = 120 SECONDS
	var/obj/effect/scp513_1/ghost_effect
	var/sightings_count = 0
	var/sleep_deprivation = 0
	var/last_touch_attempt = 0
	var/touch_attempt_cooldown = 60 SECONDS

/datum/element/scp513_stalked/Attach(datum/target)
	. = ..()
	if(!ishuman(target))
		return ELEMENT_INCOMPATIBLE
	var/mob/living/carbon/human/H = target
	stalk_duration = 0
	phase = SCP513_PHASE_WHISPER
	next_sighting = world.time + rand(sighting_interval_min, sighting_interval_max)
	next_sleep_attempt = world.time + sleep_attempt_interval
	ghost_effect = new /obj/effect/scp513_1(get_turf(H), H)
	H.scp513_stalked_ref = src
	RegisterSignal(H, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	RegisterSignal(H, COMSIG_PARENT_QDELETING, PROC_REF(on_target_destroy))
	to_chat(H, "<span class='warning'>You feel like something is watching you from just out of sight...</span>")

/datum/element/scp513_stalked/Detach(datum/source)
	var/mob/living/carbon/human/H = source
	UnregisterSignal(H, COMSIG_LIVING_LIFE)
	UnregisterSignal(H, COMSIG_PARENT_QDELETING)
	QDEL_NULL(ghost_effect)
	if(H?.client)
		clear_shadow_images(H)
	H.scp513_stalked_ref = null
	. = ..()

/datum/element/scp513_stalked/proc/on_target_destroy(datum/source)
	SIGNAL_HANDLER
	Detach(source)

/datum/element/scp513_stalked/proc/on_life(mob/living/carbon/human/H, delta_time, times_fired)
	SIGNAL_HANDLER
	if(H.stat == DEAD)
		return

	stalk_duration += delta_time
	update_phase(H)

	if(H.sanity)
		H.sanity.adjust_sanity(-sanity_drain_rate * delta_time * phase)

	if(phase >= SCP513_PHASE_STALK)
		sleep_deprivation += 0.15 * delta_time * (phase - 1)
		if(sleep_deprivation > 30 && H.drowsyness < 20)
			H.adjust_drowsyness(min(2, sleep_deprivation * 0.1))
		if(world.time >= next_sleep_attempt)
			attempt_sleep_disruption(H)
			next_sleep_attempt = world.time + sleep_attempt_interval / phase

	if(world.time >= next_sighting)
		trigger_sighting(H)
		sighting_interval_min = max(30 SECONDS, sighting_interval_min - 5 SECONDS * phase)
		sighting_interval_max = max(60 SECONDS, sighting_interval_max - 10 SECONDS * phase)
		next_sighting = world.time + rand(sighting_interval_min, sighting_interval_max)

	if(phase >= SCP513_PHASE_HUNT && world.time >= last_touch_attempt + touch_attempt_cooldown)
		attempt_touch(H)
		last_touch_attempt = world.time

	if(phase >= SCP513_PHASE_CONSUME)
		H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.3 * delta_time)

/datum/element/scp513_stalked/proc/update_phase(mob/living/carbon/human/H)
	var/old_phase = phase
	if(stalk_duration > 6000)
		phase = SCP513_PHASE_CONSUME
	else if(stalk_duration > 3000)
		phase = SCP513_PHASE_HUNT
	else if(stalk_duration > 1200)
		phase = SCP513_PHASE_STALK
	else
		phase = SCP513_PHASE_WHISPER

	if(phase != old_phase)
		on_phase_transition(H, old_phase, phase)

/datum/element/scp513_stalked/proc/on_phase_transition(mob/living/carbon/human/H, old_phase, new_phase)
	switch(new_phase)
		if(SCP513_PHASE_STALK)
			to_chat(H, span_warning("The feeling of being watched intensifies. You can almost sense something moving at the edge of your vision."))
			sanity_drain_rate = 0.5
			if(ghost_effect)
				ghost_effect.appear_interval_min = 40 SECONDS
				ghost_effect.appear_interval_max = 120 SECONDS
		if(SCP513_PHASE_HUNT)
			to_chat(H, span_danger("The presence is no longer just watching. It is hunting you. You see it clearly now — a tall, emaciated figure with long, spindly limbs. It wants to touch you."))
			sanity_drain_rate = 0.8
			if(ghost_effect)
				ghost_effect.appear_interval_min = 20 SECONDS
				ghost_effect.appear_interval_max = 60 SECONDS
				ghost_effect.show_duration_min = 2 SECONDS
				ghost_effect.show_duration_max = 5 SECONDS
		if(SCP513_PHASE_CONSUME)
			to_chat(H, span_userdanger("IT IS HERE. YOU CANNOT ESCAPE. THE FIGURE REACHES FOR YOU WITH UNENDING LIMBS. THERE IS NO SALVATION."))
			sanity_drain_rate = 1.2
			if(ghost_effect)
				ghost_effect.appear_interval_min = 10 SECONDS
				ghost_effect.appear_interval_max = 30 SECONDS
				ghost_effect.show_duration_min = 1 SECOND
				ghost_effect.show_duration_max = 3 SECONDS

/datum/element/scp513_stalked/proc/intensify(mob/living/carbon/human/H)
	stalk_duration += 300
	if(phase < SCP513_PHASE_STALK)
		phase = SCP513_PHASE_STALK
		on_phase_transition(H, SCP513_PHASE_WHISPER, SCP513_PHASE_STALK)
	sightings_count += 2
	if(H.sanity)
		H.sanity.adjust_sanity(-15, "scp513_reexposure")
	to_chat(H, span_danger("The cowbell rings again. The presence surges closer, more aggressive than before!"))

/datum/element/scp513_stalked/proc/trigger_sighting(mob/living/carbon/human/H)
	set waitfor = FALSE
	sightings_count++

	var/list/whisper_sightings = list(
		"You catch a glimpse of a tall, thin figure in your peripheral vision. When you turn, nothing is there.",
		"For a moment, you see a gangly silhouette standing in the doorway. It vanishes when you blink.",
		"A shadowy figure with long limbs seems to be watching you from the corner of the room. It's gone before you can focus on it.",
		"You feel something breathing down your neck. When you spin around, nothing is there - but the air feels cold.",
		"In the reflection of a nearby surface, you see a tall shape standing behind you. You turn to find empty space.",
		"You hear a faint shuffling sound, like something dragging itself across the floor. The sound stops when you listen for it.",
		"A long, thin arm seems to reach toward you from behind a wall. By the time you look, it's withdrawn.",
		"You see pale, spindly fingers curl around a doorframe. When you approach, no one is there.",
	)

	var/list/stalk_sightings = list(
		"SCP-513-1 stands at the far end of the corridor, its elongated arms hanging at its sides. When you blink, it's gone.",
		"You see the figure crouching behind a piece of furniture. Its head tilts as if it notices you noticing it — then it's not there.",
		"A skeletal hand reaches out from the darkness under a desk. You stumble back. There was nothing there. Was there?",
		"The figure presses itself flat against the wall, as if trying to squeeze into the space between reality and shadow. It fades.",
		"You hear wet, labored breathing from inside a locker. You open it. Nothing. But the metal is warm to the touch.",
		"Two pale eyes stare at you from the ceiling. You look up. The tiles are undisturbed. Your heart pounds.",
	)

	var/list/hunt_sightings = list(
		"SCP-513-1 is RIGHT THERE — three meters away. Its mouth hangs open in a silent scream. It takes a step toward you before dissolving.",
		"The figure is behind you. You can feel its cold breath. You spin and see only a retreating shadow that vanishes into the floor.",
		"A long finger traces down your spine. You scream and whirl around. The corridor is empty but your back is ice-cold.",
		"SCP-513-1 lunges at you from the darkness! You throw yourself aside — and it's gone. Your hands are shaking uncontrollably.",
		"It's climbing the wall toward you like a spider, its limbs bending in ways that should be impossible. It reaches for you — then reality snaps back.",
		"The figure stands inches from your face. Its featureless head tilts. You close your eyes and count to three. When you open them, it's gone.",
	)

	var/list/consume_sightings = list(
		"IT TOUCHES YOU. Cold fingers close around your wrist for a fraction of a second. The touch burns like frostbite. You can't stop screaming.",
		"SCP-513-1 wraps its arms around you from behind. The embrace lasts only a heartbeat, but you feel your mind fraying at the edges.",
		"The figure is inside your head now. You see through its eyes for a moment — see yourself from above, small and alone and doomed.",
		"SCP-513-1's limbs extend impossibly, surrounding you from every direction. A cage of pale, cold flesh. Then it releases, and you collapse.",
		"It speaks to you in a voice like cracking bone: 'I AM ALWAYS HERE.' The words echo in your skull long after the figure vanishes.",
		"You feel it feeding on you — draining something vital. Colors fade. Sounds distort. For a moment, you forget your own name.",
	)

	var/list/sighting_pool
	switch(phase)
		if(SCP513_PHASE_WHISPER)
			sighting_pool = whisper_sightings
		if(SCP513_PHASE_STALK)
			sighting_pool = stalk_sightings
		if(SCP513_PHASE_HUNT)
			sighting_pool = hunt_sightings
		if(SCP513_PHASE_CONSUME)
			sighting_pool = consume_sightings
		else
			sighting_pool = whisper_sightings

	var/sighting = pick(sighting_pool)
	var/sighting_class = phase >= SCP513_PHASE_HUNT ? span_userdanger(sighting) : (phase >= SCP513_PHASE_STALK ? span_danger(sighting) : span_warning(sighting))
	to_chat(H, sighting_class)

	var/sanity_damage = 4 + (phase * 3)
	if(H.sanity)
		H.sanity.adjust_sanity(-sanity_damage, "scp513_sighting")

	if(phase >= SCP513_PHASE_HUNT && prob(30 + phase * 10))
		if(H.stamina)
			H.stamina.adjust(-15 - (phase * 5))
		H.adjust_drowsyness(5 * phase)
		to_chat(H, span_warning("You stumble in panic!"))

	if(phase >= SCP513_PHASE_CONSUME && prob(40))
		H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5)
		H.hallucination += 15
		to_chat(H, span_warning("Your vision warps and fractures!"))

	last_sighting = world.time
	hook_scp_combat(H, "SCP-513", phase * 2, phase * 5)

/datum/element/scp513_stalked/proc/attempt_sleep_disruption(mob/living/carbon/human/H)
	if(H.IsSleeping())
		H.SetSleeping(0)
		to_chat(H, span_danger("You jolt awake! A nightmare of long, grasping fingers still lingers in your mind."))
		if(H.sanity)
			H.sanity.adjust_sanity(-5, "scp513_nightmare")
		sleep_deprivation += 10
		return

	if(H.drowsyness > 0 && prob(40 + phase * 15))
		H.adjust_drowsyness(5)
		to_chat(H, span_warning("You feel exhausted, but every time you start to drift off, a sense of being watched snaps you back awake."))
		sleep_deprivation += 5

/datum/element/scp513_stalked/proc/attempt_touch(mob/living/carbon/human/H)
	if(!ghost_effect || QDELETED(ghost_effect))
		return
	var/turf/victim_turf = get_turf(H)
	var/turf/ghost_turf = get_turf(ghost_effect)
	if(!victim_turf || !ghost_turf)
		return
	if(get_dist(victim_turf, ghost_turf) <= 2)
		to_chat(H, span_userdanger("Cold, bony fingers brush against your skin! The touch is like ice and despair!"))
		H.adjustBruteLoss(5 * phase)
		if(H.sanity)
			H.sanity.adjust_sanity(-15, "scp513_touch")
		H.hallucination += 20
		hook_scp_combat(H, "SCP-513", 10, 15)

/datum/element/scp513_stalked/proc/clear_shadow_images(mob/living/carbon/human/H)

/obj/effect/scp513_1
	name = "SCP-513-1"
	desc = "A tall, thin figure with disproportionately long limbs. It seems to flicker in and out of existence."
	icon = 'icons/scp/scp-513-1.dmi'
	icon_state = "visual"
	density = FALSE
	anchored = TRUE
	invisibility = INVISIBILITY_MAXIMUM
	var/mob/living/carbon/human/victim
	var/appear_interval_min = 60 SECONDS
	var/appear_interval_max = 180 SECONDS
	var/next_appear = 0
	var/show_duration_min = 3 SECONDS
	var/show_duration_max = 6 SECONDS
	var/list/active_images = list()
	var/move_interval = 3 SECONDS
	var/next_move = 0
	var/stalk_behavior = STALK_BEHAVIOR_DISTANT

/obj/effect/scp513_1/Initialize(mapload, mob/living/carbon/human/victim_ref)
	. = ..()
	victim = victim_ref
	next_appear = world.time + rand(appear_interval_min, appear_interval_max)
	START_PROCESSING(SSobj, src)

/obj/effect/scp513_1/Destroy()
	STOP_PROCESSING(SSobj, src)
	clear_all_images()
	return ..()

/obj/effect/scp513_1/process()
	if(!victim || victim.stat == DEAD || QDELETED(victim))
		qdel(src)
		return

	var/datum/element/scp513_stalked/ele = victim.scp513_stalked_ref
	if(!ele)
		qdel(src)
		return

	update_behavior(ele.phase)

	if(world.time >= next_move)
		execute_movement()
		next_move = world.time + move_interval

	if(world.time < next_appear)
		return
	next_appear = world.time + rand(appear_interval_min, appear_interval_max)
	manifest_to_victim()

/obj/effect/scp513_1/proc/update_behavior(phase)
	switch(phase)
		if(SCP513_PHASE_WHISPER)
			stalk_behavior = STALK_BEHAVIOR_DISTANT
			move_interval = 4 SECONDS
		if(SCP513_PHASE_STALK)
			stalk_behavior = STALK_BEHAVIOR_CIRCLE
			move_interval = 3 SECONDS
		if(SCP513_PHASE_HUNT)
			stalk_behavior = STALK_BEHAVIOR_APPROACH
			move_interval = 2 SECONDS
		if(SCP513_PHASE_CONSUME)
			stalk_behavior = STALK_BEHAVIOR_LUNGE
			move_interval = 1 SECOND

/obj/effect/scp513_1/proc/execute_movement()
	var/turf/victim_turf = get_turf(victim)
	if(!victim_turf)
		return

	var/list/candidate_turfs = list()

	switch(stalk_behavior)
		if(STALK_BEHAVIOR_DISTANT)
			for(var/turf/T in range(7, victim_turf))
				if(!T.density && get_dist(T, victim_turf) >= 4)
					candidate_turfs += T
		if(STALK_BEHAVIOR_CIRCLE)
			for(var/turf/T in range(6, victim_turf))
				if(!T.density && get_dist(T, victim_turf) >= 3 && get_dist(T, victim_turf) <= 5)
					candidate_turfs += T
		if(STALK_BEHAVIOR_APPROACH)
			for(var/turf/T in range(4, victim_turf))
				if(!T.density && get_dist(T, victim_turf) >= 2 && get_dist(T, victim_turf) <= 3)
					candidate_turfs += T
		if(STALK_BEHAVIOR_LUNGE)
			for(var/turf/T in range(2, victim_turf))
				if(!T.density && get_dist(T, victim_turf) <= 1)
					candidate_turfs += T

	if(!length(candidate_turfs))
		for(var/turf/T in range(5, victim_turf))
			if(!T.density)
				candidate_turfs += T

	if(length(candidate_turfs))
		forceMove(pick(candidate_turfs))

/obj/effect/scp513_1/proc/manifest_to_victim()
	if(!victim?.client)
		return

	var/image/ghost_image = image(icon, icon_state = icon_state, loc = src)
	ghost_image.override = TRUE
	ghost_image.alpha = min(255, 120 + (stalk_behavior * 30))

	if(stalk_behavior >= STALK_BEHAVIOR_APPROACH)
		ghost_image.layer = ABOVE_MOB_LAYER

	victim.client.images += ghost_image
	active_images += ghost_image

	var/duration = rand(show_duration_min, show_duration_max)
	if(stalk_behavior >= STALK_BEHAVIOR_LUNGE)
		duration = rand(1 SECOND, 2 SECONDS)

	addtimer(CALLBACK(src, PROC_REF(remove_ghost_image), ghost_image), duration)

	if(stalk_behavior >= STALK_BEHAVIOR_APPROACH && prob(30))
		playsound(victim, 'sound/scp/scare2.ogg', 30, TRUE)

/obj/effect/scp513_1/proc/remove_ghost_image(image/ghost_image)
	if(victim?.client)
		victim.client.images -= ghost_image
	active_images -= ghost_image
	qdel(ghost_image)

/obj/effect/scp513_1/proc/clear_all_images()
	for(var/image/I in active_images)
		if(victim?.client)
			victim.client.images -= I
		qdel(I)
	active_images = list()
