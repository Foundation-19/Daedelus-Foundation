// SCP-1499 - The Gas Mask
// A gas mask that transports the wearer to an alien dimension when worn

/obj/item/clothing/mask/gas/scp1499
	name = "strange gas mask"
	desc = "A Soviet GP-5 gas mask with unusual modifications. Looking through the lenses reveals a strange landscape."
	icon = 'icons/scp/scp-1499.dmi'
	icon_state = "scp1499"
	w_class = WEIGHT_CLASS_NORMAL
	flags_cover = MASKCOVERSEYES|MASKCOVERSMOUTH

	var/dimension_active = FALSE
	var/trip_duration = 0
	var/entities_encountered = 0

	var/datum/scp1499_dimension_system/dimension_system
	var/datum/scp1499_entity_system/entity_system
	var/datum/scp1499_research_system/research_system

	var/trips_taken = 0
	var/safe_returns = 0
	var/original_location

/obj/item/clothing/mask/gas/scp1499/Initialize()
	. = ..()

	SCP = new /datum/scp(src, "gas mask", SCP_SAFE, "1499")

	dimension_system = new /datum/scp1499_dimension_system(src)
	entity_system = new /datum/scp1499_entity_system(src)
	research_system = new /datum/scp1499_research_system(src)

/obj/item/clothing/mask/gas/scp1499/Destroy()
	QDEL_NULL(dimension_system)
	QDEL_NULL(entity_system)
	QDEL_NULL(research_system)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/mask/gas/scp1499/equipped(mob/living/carbon/human/user, slot)
	..()
	if(slot == ITEM_SLOT_MASK)
		enter_dimension(user)

/obj/item/clothing/mask/gas/scp1499/unequipped(mob/living/carbon/human/user)
	if(dimension_active)
		exit_dimension(user)
	..()

/obj/item/clothing/mask/gas/scp1499/proc/enter_dimension(mob/living/carbon/human/wearer)
	if(!wearer || dimension_active)
		return

	dimension_active = TRUE
	original_location = get_turf(wearer)
	trips_taken++
	trip_duration = 0

	hook_scp_interaction(wearer, "SCP-1499", INTERACTION_TYPE_EXPLORATION)

	if(dimension_system)
		dimension_system.transport_to_dimension(wearer)

	to_chat(wearer, "<span class='warning'>Reality shifts around you. You find yourself in an alien landscape!</span>")
	START_PROCESSING(SSobj, src)

/obj/item/clothing/mask/gas/scp1499/proc/exit_dimension(mob/living/carbon/human/wearer)
	if(!wearer)
		return

	dimension_active = FALSE
	trip_duration = 0

	if(dimension_system)
		dimension_system.return_from_dimension(wearer, original_location)

	to_chat(wearer, "<span class='notice'>The alien landscape fades as reality returns to normal.</span>")
	hook_scp_interaction(wearer, "SCP-1499", INTERACTION_TYPE_SURVIVAL)
	safe_returns++

	STOP_PROCESSING(SSobj, src)

/obj/item/clothing/mask/gas/scp1499/process()
	var/mob/living/carbon/human/wearer = loc
	if(!istype(wearer) || wearer.wear_mask != src)
		if(dimension_active)
			exit_dimension(wearer)
		return

	trip_duration++

	if(dimension_system)
		dimension_system.process_dimension(wearer, trip_duration)

	if(entity_system)
		entity_system.process_entities(wearer, trip_duration)

	if(trip_duration > 600 && prob(5))
		to_chat(wearer, "<span class='warning'>You feel like you should remove the mask soon...</span>")

/obj/item/clothing/mask/gas/scp1499/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>A gas mask that transports the wearer to an alien dimension.</span>")

/datum/scp1499_dimension_system
	var/obj/item/parent
	var/list/dimension_turfs = list()
	var/dimension_size = 50
	var/alien_architecture = TRUE
	var/dimension_generated = FALSE
	var/dimension_z = 2
	var/list/alien_structures = list()
	var/list/ambient_objects = list()

/datum/scp1499_dimension_system/New(obj/item/P)
	parent = P

/datum/scp1499_dimension_system/proc/ensure_dimension()
	if(dimension_generated)
		return TRUE

	var/list/z_levels = SSmapping.z_list
	if(length(z_levels) < 2)
		dimension_z = world.maxz + 1
		world.incrementMaxZ()
	else
		dimension_z = 2

	generate_alien_terrain()
	dimension_generated = TRUE
	return TRUE

/datum/scp1499_dimension_system/proc/generate_alien_terrain()
	var/center_x = 128
	var/center_y = 128
	var/radius = dimension_size / 2

	for(var/x = center_x - radius, x <= center_x + radius, x++)
		for(var/y = center_y - radius, y <= center_y + radius, y++)
			var/turf/T = locate(x, y, dimension_z)
			if(!T)
				continue

			var/dist = sqrt((x - center_x) ** 2 + (y - center_y) ** 2)
			if(dist > radius)
				continue

			T = T.ChangeTurf(/turf/open/floor/scp1499_alien, flags = CHANGETURF_INHERIT_AIR)
			dimension_turfs += T

			if(prob(3))
				new /obj/structure/scp1499_pillar(T)
				alien_structures += T
			else if(prob(2))
				new /obj/structure/scp1499_flesh_growth(T)
			else if(prob(1))
				new /obj/effect/scp1499_ambient_drip(T)

	for(var/i = 1 to 8)
		var/angle = (i / 8) * 360
		var/struct_x = center_x + cos(angle) * (radius * 0.6)
		var/struct_y = center_y + sin(angle) * (radius * 0.6)
		var/turf/T = locate(round(struct_x), round(struct_y), dimension_z)
		if(T)
			new /obj/structure/scp1499_tower(T)

	var/turf/center_turf = locate(center_x, center_y, dimension_z)
	if(center_turf)
		new /obj/structure/scp1499_altar(center_turf)

	var/turf/entry_turf = locate(center_x, center_y + 5, dimension_z)
	if(entry_turf)
		new /obj/effect/landmark/scp1499_entry(entry_turf)

/datum/scp1499_dimension_system/proc/transport_to_dimension(mob/living/carbon/human/wearer)
	if(!wearer)
		return

	ensure_dimension()

	var/turf/target = locate(128, 133, dimension_z)
	if(!target)
		target = pick(dimension_turfs)
	wearer.forceMove(target)

	if(wearer.sanity)
		wearer.sanity.adjust_sanity(-10, "scp1499_dimension")

/datum/scp1499_dimension_system/proc/return_from_dimension(mob/living/carbon/human/wearer, original_turf)
	if(!wearer)
		return

	if(original_turf)
		wearer.forceMove(original_turf)

	var/obj/item/clothing/mask/gas/scp1499/mask_item = parent
	if(mask_item?.entity_system)
		for(var/obj/effect/scp1499_entity/E in mask_item.entity_system.spawned_entities)
			qdel(E)
		mask_item.entity_system.spawned_entities.Cut()

/datum/scp1499_dimension_system/proc/spawned_entities_cleanup()
	var/obj/item/clothing/mask/gas/scp1499/mask_item = parent
	if(!mask_item?.entity_system)
		return list()
	return mask_item.entity_system.spawned_entities.Copy()

/datum/scp1499_dimension_system/proc/process_dimension(mob/living/carbon/human/wearer, duration)
	if(!wearer)
		return

	if(prob(5))
		wearer.visible_message("<span class='notice'>[wearer] stares blankly into nothing.</span>")

	if(duration > 1800)
		wearer.Sleeping(10)
		hook_scp_combat(wearer, "SCP-1499", 0, 1)

	if(wearer.sanity && prob(3))
		wearer.sanity.adjust_sanity(-2, "scp1499_dimension")

/turf/open/floor/scp1499_alien
	name = "alien surface"
	desc = "A strange, fleshy surface that seems to pulse faintly."
	icon = 'icons/turf/floors.dmi'
	icon_state = "alienplating"
	footstep = FOOTSTEP_MEAT

/obj/structure/scp1499_pillar
	name = "alien pillar"
	desc = "A tall, organic-looking pillar that seems to be growing from the ground."
	icon = 'icons/turf/walls.dmi'
	icon_state = "alien1"
	density = TRUE
	anchored = TRUE
	opacity = TRUE
	max_integrity = 100

/obj/structure/scp1499_flesh_growth
	name = "fleshy growth"
	desc = "A pulsating mass of flesh and sinew. It seems alive."
	icon = 'icons/turf/floors.dmi'
	icon_state = "alienpod1"
	density = FALSE
	anchored = TRUE
	max_integrity = 30

/obj/structure/scp1499_flesh_growth/attack_hand(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	to_chat(H, "<span class='warning'>The growth pulses beneath your touch. It's warm.</span>")
	if(H.sanity)
		H.sanity.adjust_sanity(-5, "scp1499_flesh_touch")

/obj/structure/scp1499_tower
	name = "alien tower"
	desc = "A massive, twisting structure of alien origin. Strange sounds emanate from within."
	icon = 'icons/turf/walls.dmi'
	icon_state = "alien1"
	density = TRUE
	anchored = TRUE
	opacity = TRUE
	max_integrity = 500

/obj/structure/scp1499_altar
	name = "alien altar"
	desc = "A low, flat structure covered in indecipherable symbols. It radiates unease."
	icon = 'icons/turf/floors.dmi'
	icon_state = "alienvault"
	density = TRUE
	anchored = TRUE
	max_integrity = 200

/obj/structure/scp1499_altar/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	to_chat(H, "<span class='danger'>Strange visions flood your mind as you touch the altar!</span>")
	if(H.sanity)
		H.sanity.adjust_sanity(-25, "scp1499_altar")
		H.sanity.hallucination_level = min(H.sanity.hallucination_level + 30, H.sanity.max_hallucination)
	hook_scp_interaction(H, "SCP-1499", INTERACTION_TYPE_EXPLORATION)

/obj/effect/scp1499_ambient_drip
	name = "strange liquid"
	desc = "A pool of dark, viscous liquid that seems to move on its own."
	icon = 'icons/effects/blood.dmi'
	icon_state = "xfloor1"
	anchored = TRUE
	light_power = 2
	light_outer_range = 1
	light_color = LIGHT_COLOR_GREEN

/obj/effect/landmark/scp1499_entry
	name = "SCP-1499 Dimension Entry Point"

/datum/scp1499_entity_system
	var/obj/item/parent
	var/list/spawned_entities = list()
	var/entity_types = list("scout", "soldier", "giant")
	var/max_entities = 5
	var/aggression_level = 0

/datum/scp1499_entity_system/New(obj/item/P)
	parent = P

/datum/scp1499_entity_system/proc/process_entities(mob/living/carbon/human/wearer, duration)
	if(!wearer)
		return

	aggression_level = min(100, aggression_level + 0.1)

	if(length(spawned_entities) < max_entities && prob(5))
		spawn_entity(wearer)

	for(var/obj/effect/scp1499_entity/E in spawned_entities)
		if(get_dist(E, wearer) <= 3 && aggression_level > 50)
			if(prob(10))
				attack_wearer(wearer, E)

/datum/scp1499_entity_system/proc/spawn_entity(mob/living/carbon/human/wearer)
	if(!wearer)
		return

	var/turf/spawn_turf = get_step(wearer, pick(NORTH, SOUTH, EAST, WEST))
	var/obj/effect/scp1499_entity/E = new(spawn_turf)
	E.target = wearer
	spawned_entities += E

	wearer.visible_message("<span class='danger'>A strange entity manifests nearby!</span>", "<span class='danger'>One of the dimension's inhabitants approaches!</span>")
	hook_scp_combat(wearer, "SCP-1499", 0, 5)

/datum/scp1499_entity_system/proc/attack_wearer(mob/living/carbon/human/wearer, obj/effect/scp1499_entity/entity)
	if(!wearer || !entity)
		return

	var/damage = rand(5, 15)
	wearer.adjustBruteLoss(damage)
	to_chat(wearer, "<span class='danger'>[entity] attacks you!</span>")
	hook_scp_combat(wearer, "SCP-1499", 0, damage)

/obj/effect/scp1499_entity
	name = "alien entity"
	desc = "A tall, thin humanoid with no visible facial features. Its skin is pale and leathery."
	icon = 'icons/mob/cult.dmi'
	icon_state = "shade_cult"
	density = TRUE
	anchored = FALSE

	var/mob/living/carbon/human/target
	var/health = 50

/obj/effect/scp1499_entity/proc/die()
	qdel(src)

/datum/scp1499_research_system
	var/obj/item/parent
	var/list/trip_log = list()
	var/total_trip_time = 0

/datum/scp1499_research_system/New(obj/item/P)
	parent = P

/datum/scp1499_research_system/proc/log_trip(mob/wearer, duration, entities_seen)
	total_trip_time += duration
	trip_log["[world.time]"] = list("wearer" = wearer?.ckey, "duration" = duration, "entities" = entities_seen)
