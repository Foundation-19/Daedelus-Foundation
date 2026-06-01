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
	visible_message(span_danger("[user] rings SCP-513!"))
	playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)
	hook_scp_breach("SCP-513", src)
	for(var/mob/living/carbon/human/H in range(hear_radius, src))
		if(H == user || H.SCP || H.stat == DEAD)
			continue
		if(!(H in affected_mobs))
			affected_mobs += H
			H.AddElement(/datum/element/scp513_stalked)
			to_chat(H, span_danger("You hear the cowbell ring. Something has noticed you."))
			hook_scp_interaction(H, "SCP-513", INTERACTION_TYPE_OBSERVATION)
		else
			to_chat(H, span_warning("The cowbell rings again... the presence feels closer."))

/obj/item/scp513/attack_self(mob/user)
	ring_bell(user)

/obj/item/scp513/examine(mob/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			. += span_warning("SCP-513 - Ringing causes SCP-513-1 to stalk all who hear it. There is no cure.")
		else
			. += span_danger("A rusted cowbell. You feel an odd compulsion to ring it.")

/datum/element/scp513_stalked
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	var/stalk_duration = 0
	var/last_sighting = 0
	var/sanity_drain_rate = 0.3
	var/sighting_cooldown = 60 SECONDS
	var/sighting_interval_min = 90 SECONDS
	var/sighting_interval_max = 300 SECONDS
	var/next_sighting = 0
	var/obj/effect/scp513_1/ghost_effect

/datum/element/scp513_stalked/Attach(datum/target)
	. = ..()
	if(!ishuman(target))
		return ELEMENT_INCOMPATIBLE
	var/mob/living/carbon/human/H = target
	stalk_duration = 0
	next_sighting = world.time + rand(sighting_interval_min, sighting_interval_max)
	ghost_effect = new /obj/effect/scp513_1(get_turf(H), H)
	RegisterSignal(H, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	RegisterSignal(H, COMSIG_PARENT_QDELETING, PROC_REF(on_target_destroy))
	to_chat(H, span_warning("You feel like something is watching you from just out of sight..."))

/datum/element/scp513_stalked/Detach(datum/source)
	. = ..()
	var/mob/living/carbon/human/H = source
	UnregisterSignal(H, COMSIG_LIVING_LIFE)
	UnregisterSignal(H, COMSIG_PARENT_QDELETING)
	QDEL_NULL(ghost_effect)

/datum/element/scp513_stalked/proc/on_target_destroy(datum/source)
	SIGNAL_HANDLER
	Detach(source)

/datum/element/scp513_stalked/proc/on_life(mob/living/carbon/human/H, delta_time, times_fired)
	SIGNAL_HANDLER
	if(H.stat == DEAD)
		return
	stalk_duration += delta_time
	if(H.sanity)
		H.sanity.adjust_sanity(-sanity_drain_rate * delta_time)
	if(world.time >= next_sighting)
		trigger_sighting(H)
		next_sighting = world.time + rand(sighting_interval_min, sighting_interval_max)

/datum/element/scp513_stalked/proc/trigger_sighting(mob/living/carbon/human/H)
	set waitfor = FALSE
	var/list/sightings = list(
		"You catch a glimpse of a tall, thin figure in your peripheral vision. When you turn, nothing is there.",
		"For a moment, you see a gangly silhouette standing in the doorway. It vanishes when you blink.",
		"A shadowy figure with long limbs seems to be watching you from the corner of the room. It's gone before you can focus on it.",
		"You feel something breathing down your neck. When you spin around, nothing is there - but the air feels cold.",
		"In the reflection of a nearby surface, you see a tall shape standing behind you. You turn to find empty space.",
		"You hear a faint shuffling sound, like something dragging itself across the floor. The sound stops when you listen for it.",
		"A long, thin arm seems to reach toward you from behind a wall. By the time you look, it's withdrawn.",
		"You see pale, spindly fingers curl around a doorframe. When you approach, no one is there."
	)
	var/sighting = pick(sightings)
	to_chat(H, span_danger("[sighting]"))
	if(H.sanity)
		H.sanity.adjust_sanity(-8, "scp513_sighting")
	if(prob(30))
		if(H.stamina)
			H.stamina.adjust(-15)
		to_chat(H, span_warning("You stumble in panic!"))
	last_sighting = world.time
	hook_scp_combat(H, "SCP-513", 0, 5)

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

/obj/effect/scp513_1/Initialize(mapload, mob/living/carbon/human/victim_ref)
	. = ..()
	victim = victim_ref
	next_appear = world.time + rand(appear_interval_min, appear_interval_max)
	START_PROCESSING(SSobj, src)

/obj/effect/scp513_1/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/scp513_1/process()
	if(!victim || victim.stat == DEAD || QDELETED(victim))
		qdel(src)
		return
	if(world.time < next_appear)
		return
	next_appear = world.time + rand(appear_interval_min, appear_interval_max)
	var/turf/victim_turf = get_turf(victim)
	if(!victim_turf)
		return
	var/list/candidate_turfs = list()
	for(var/turf/T in range(5, victim_turf))
		if(!T.density && get_dist(T, victim_turf) >= 3)
			candidate_turfs += T
	if(!length(candidate_turfs))
		return
	var/turf/spawn_turf = pick(candidate_turfs)
	forceMove(spawn_turf)
	var/image/ghost_image = image(icon, icon_state = icon_state, loc = src)
	ghost_image.override = TRUE
	ghost_image.alpha = 180
	if(victim.client)
		victim.client.images += ghost_image
		addtimer(CALLBACK(src, PROC_REF(remove_ghost_image), ghost_image), rand(3 SECONDS, 6 SECONDS))

/obj/effect/scp513_1/proc/remove_ghost_image(image/ghost_image)
	if(victim?.client)
		victim.client.images -= ghost_image
	qdel(ghost_image)

