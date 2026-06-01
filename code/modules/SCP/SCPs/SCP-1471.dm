// SCP-1471 - MalO ver1.0.0
// A phone application that causes an entity to appear in photos and eventually manifest

/obj/item/device/scp1471
	name = "smartphone"
	desc = "A smartphone with an app called 'MalO ver1.0.0' pre-installed."
	icon = 'icons/obj/device.dmi'
	icon_state = "export_scanner"
	w_class = WEIGHT_CLASS_SMALL

	var/installed = TRUE
	var/view_count = 0
	var/manifestation_level = 0
	var/sanity_drain = 0.5

	var/datum/scp1471_manifestation_system/manifestation_system
	var/datum/scp1471_research_system/research_system

	var/user_ckey
	var/activation_time
	var/list/spawned_entities = list()

/obj/item/device/scp1471/Initialize()
	. = ..()

	SCP = new /datum/scp(src, "MalO ver1.0.0", SCP_EUCLID, "1471")

	manifestation_system = new /datum/scp1471_manifestation_system(src)
	research_system = new /datum/scp1471_research_system(src)

/obj/item/device/scp1471/Destroy()
	QDEL_NULL(manifestation_system)
	QDEL_NULL(research_system)
	QDEL_NULL(SCP)
	for(var/obj/effect/scp1471_entity/E in spawned_entities)
		qdel(E)
	spawned_entities = list()
	return ..()

/obj/item/device/scp1471/attack_self(mob/living/carbon/human/user)
	..()

	if(!istype(user))
		return

	if(!user_ckey)
		user_ckey = user.ckey
		activation_time = world.time

	view_count++
	manifestation_level = min(100, view_count / 10)

	hook_scp_interaction(user, "SCP-1471", INTERACTION_TYPE_OBSERVATION)

	if(manifestation_system)
		manifestation_system.check_manifestation(user, manifestation_level)

	var/message = pick(list(
		span_warning("The screen flickers with static..."),
		span_warning("You see a shadowy figure in the corner of the screen..."),
		span_danger("The entity seems closer now..."),
		span_notice("The app shows a photo of somewhere nearby...")
	))
	to_chat(user, message)

	if(view_count % 10 == 0)
		user.adjust_drowsyness(sanity_drain)
		hook_scp_combat(user, "SCP-1471", 0, 5)

/obj/item/device/scp1471/examine(mob/user)
	. = ..()
	to_chat(user, span_notice("A smartphone with the MalO ver1.0.0 app installed."))
	if(ishuman(user) && user.ckey == user_ckey)
		to_chat(user, span_warning("Manifestation progress: [manifestation_level]%"))

/datum/scp1471_manifestation_system
	var/obj/item/parent
	var/manifestation_threshold = 80
	var/entity_spawned = FALSE
	var/manifestation_cooldown = 0

/datum/scp1471_manifestation_system/New(obj/item/P)
	parent = P

/datum/scp1471_manifestation_system/proc/check_manifestation(mob/living/carbon/human/viewer, level)
	if(!viewer || entity_spawned)
		return

	if(level >= manifestation_threshold && manifestation_cooldown <= world.time)
		spawn_entity(viewer)
		manifestation_cooldown = world.time + 5 MINUTES

/datum/scp1471_manifestation_system/proc/spawn_entity(mob/living/carbon/human/target)
	if(!target || entity_spawned)
		return

	entity_spawned = TRUE
	hook_scp_breach("SCP-1471", parent)

	var/turf/spawn_turf = get_edge_target_turf(target, pick(NORTH, SOUTH, EAST, WEST))
	var/obj/effect/scp1471_entity/entity = new(spawn_turf ? spawn_turf : get_turf(target))
	entity.target = target
	var/obj/item/device/scp1471/phone = parent
	if(istype(phone))
		phone.spawned_entities += entity

	target.visible_message(span_danger("A shadowy entity manifests!"), span_danger("The entity from the app has found you!"))

/obj/effect/scp1471_entity
	name = "shadowy entity"
	desc = "A tall, shadowy canine-like creature with a skull-like face."
	icon = 'icons/mob/cult.dmi'
	icon_state = "shade_cult"
	density = FALSE
	anchored = TRUE
	alpha = 80

	var/mob/living/carbon/human/target
	var/distance_to_target = 10
	var/stalk_duration = 0

/obj/effect/scp1471_entity/New(loc)
	..()
	START_PROCESSING(SSobj, src)

/obj/effect/scp1471_entity/process()
	if(!target || target.stat == DEAD)
		qdel(src)
		return

	stalk_duration++

	var/turf/T = get_turf(target)
	if(T)
		distance_to_target = get_dist(src, T)

		if(distance_to_target > 10)
			forceMove(get_step(T, pick(NORTH, SOUTH, EAST, WEST)))

		if(distance_to_target <= 3 && prob(10))
			harass_target()

	if(stalk_duration > 300 && prob(5))
		qdel(src)

/obj/effect/scp1471_entity/proc/harass_target()
	if(!target)
		return

	var/harassment = pick(list(
		"whispers",
		"scratches",
		"breathes"
	))

	switch(harassment)
		if("whispers")
			to_chat(target, span_warning("You hear whispering behind you..."))
		if("scratches")
			to_chat(target, span_warning("Something scratches at the edge of your vision..."))
		if("breathes")
			to_chat(target, span_warning("Cold breath touches your neck..."))

	target.adjust_drowsyness(2)
	hook_scp_combat(target, "SCP-1471", 0, 2)

/obj/effect/scp1471_entity/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/scp1471_research_system
	var/obj/item/parent
	var/list/research_data = list()
	var/viewing_events = 0

/datum/scp1471_research_system/New(obj/item/P)
	parent = P

/datum/scp1471_research_system/proc/record_viewing(mob/living/carbon/human/viewer)
	viewing_events++
	research_data["[world.time]"] = list("viewer" = viewer.ckey, "views" = viewing_events)
