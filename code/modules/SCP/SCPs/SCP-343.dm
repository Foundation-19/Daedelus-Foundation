/mob/living/scp/scp343
	ai_enabled = TRUE
	name = "SCP-343"
	desc = "An elderly man who claims to be God. He radiates an aura of divine power and benevolence."
	icon = 'icons/scp/scp-343.dmi'
	icon_state = "scp343"
	real_name = "SCP-343"

	var/divine_energy = 100
	var/max_divine_energy = 100
	var/comfort_range = 5
	var/divine_zone_cooldown = 0
	var/divine_heal_cooldown = 0
	var/manifest_cooldown = 0
	var/vanish_cooldown = 0
	var/wallwalk_active = FALSE
	var/wallwalk_cooldown = 0
	var/cleanse_cooldown = 0

/mob/living/scp/scp343/Initialize()
	. = ..()

	SCP = new /datum/scp(src, "God", SCP_SAFE, "343", SCP_PLAYABLE)
	SCP.min_playercount = 30
	SCP.min_time = 15 MINUTES

	START_PROCESSING(SSobj, src)

	add_verb(src, list(
		/mob/living/scp/scp343/proc/verb_divine_zone,
		/mob/living/scp/scp343/proc/verb_manifest_item,
		/mob/living/scp/scp343/proc/verb_vanish,
		/mob/living/scp/scp343/proc/verb_walk_through_walls,
		/mob/living/scp/scp343/proc/verb_cleanse_area,
	))

/mob/living/scp/scp343/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(wallwalk_active)
		REMOVE_TRAIT(src, TRAIT_PHASING_ABILITY, SCP_TRAIT)
		density = TRUE
	return ..()

/mob/living/scp/scp343/process()
	. = ..()

	if(stat == DEAD)
		return

	update_divine_presence()
	passive_healing_aura()

	if(divine_energy < max_divine_energy)
		divine_energy = min(max_divine_energy, divine_energy + 1)

/mob/living/scp/scp343/proc/update_divine_presence()
	if(prob(5))
		var/obj/effect/temp_visual/divine_presence/presence = new(loc)
		presence.color = "#FFD700"

/mob/living/scp/scp343/proc/passive_healing_aura()
	for(var/mob/living/carbon/human/H in range(comfort_range, src))
		if(H == src || H.SCP)
			continue

		if(H.sanity)
			H.sanity.adjust_sanity(2, "scp343_presence")

		if(H.health < H.maxHealth)
			H.adjustBruteLoss(-1)
			H.adjustFireLoss(-1)

/mob/living/scp/scp343/proc/divine_heal_ability(mob/living/carbon/human/target)
	if(!target || target == src)
		return

	if(world.time < divine_heal_cooldown)
		to_chat(src, span_warning("You need to wait before healing again."))
		return

	if(divine_energy < 30)
		to_chat(src, span_warning("Not enough divine energy."))
		return

	divine_heal_cooldown = world.time + 30 SECONDS
	divine_energy -= 30

	target.adjustBruteLoss(-50)
	target.adjustFireLoss(-50)
	target.adjustToxLoss(-25)
	if(target.sanity)
		target.sanity.adjust_sanity(25, "scp343_healing")

	visible_message(span_notice("[src] channels divine energy, healing [target]!"))

	on_divine_healing(target)

/mob/living/scp/scp343/proc/divine_zone_ability()
	if(world.time < divine_zone_cooldown)
		to_chat(src, span_warning("You need to wait before creating another divine zone."))
		return

	if(divine_energy < 50)
		to_chat(src, span_warning("Not enough divine energy."))
		return

	divine_zone_cooldown = world.time + 60 SECONDS
	divine_energy -= 50

	var/turf/T = get_turf(src)
	new /obj/effect/divine_zone(T)

	visible_message(span_notice("[src] creates a divine zone of healing!"))

	for(var/mob/living/carbon/human/H in range(comfort_range, src))
		if(H != src && !H.SCP)
			on_divine_protection(H)

/mob/living/scp/scp343/proc/manifest_item_ability()
	if(world.time < manifest_cooldown)
		to_chat(src, span_warning("You need to wait before manifesting another item."))
		return

	if(divine_energy < 20)
		to_chat(src, span_warning("Not enough divine energy."))
		return

	manifest_cooldown = world.time + 20 SECONDS
	divine_energy -= 20

	var/static/list/manifestable_items = list(
		"Cheese Wheel" = /obj/item/food/cheese/wheel,
		"Bread Loaf" = /obj/item/food/bread/plain,
		"Meat Steak" = /obj/item/food/meatsteak,
		"Wine Bottle" = /obj/item/reagent_containers/food/drinks/bottle/wine,
		"Beer Bottle" = /obj/item/reagent_containers/food/drinks/bottle/beer,
		"Pizza" = /obj/item/food/pizza/margherita,
		"Sunflower" = /obj/item/food/grown/sunflower,
		"Cigarette" = /obj/item/clothing/mask/cigarette,
	)

	var/choice = input(src, "What would you like to bring into existence?", "Divine Manifestation") as null|anything in manifestable_items
	if(!choice)
		manifest_cooldown = world.time
		divine_energy = min(max_divine_energy, divine_energy + 20)
		return

	var/item_type = manifestable_items[choice]
	var/obj/item/manifested = new item_type(get_turf(src))

	visible_message(span_notice("[src] gestures casually, and \a [manifested] appears from nothing!"))
	to_chat(src, span_notice("You will [choice] into existence."))

	hook_scp_interaction(src, "SCP-343", INTERACTION_TYPE_OBSERVATION)

/mob/living/scp/scp343/proc/vanish_ability()
	if(world.time < vanish_cooldown)
		to_chat(src, span_warning("You need to wait before vanishing again."))
		return

	if(divine_energy < 25)
		to_chat(src, span_warning("Not enough divine energy."))
		return

	vanish_cooldown = world.time + 45 SECONDS
	divine_energy -= 25

	visible_message(span_notice("[src] seems to simply... step out of reality, vanishing without a trace."))
	to_chat(src, span_notice("You step between the folds of creation."))

	var/turf/T = get_turf(src)
	new /obj/effect/temp_visual/divine_vanish(T)

	var/list/valid_turfs = list()
	for(var/turf/candidate in range(15, src))
		if(!candidate.density)
			var/has_dense_contents = FALSE
			for(var/obj/O in candidate)
				if(O.density)
					has_dense_contents = TRUE
					break
			if(!has_dense_contents)
				valid_turfs += candidate

	if(length(valid_turfs) > 0)
		var/turf/destination = pick(valid_turfs)
		forceMove(destination)
		new /obj/effect/temp_visual/divine_appear(destination)
		visible_message(span_notice("[src] appears as if from nowhere, looking entirely unsurprised."))
	else
		to_chat(src, span_warning("There is nowhere for you to reappear. You remain where you are."))

	hook_scp_interaction(src, "SCP-343", INTERACTION_TYPE_CONTAINMENT)

/mob/living/scp/scp343/proc/walk_through_walls_ability()
	if(world.time < wallwalk_cooldown)
		to_chat(src, span_warning("You need to wait before altering your form again."))
		return

	if(divine_energy < 40)
		to_chat(src, span_warning("Not enough divine energy."))
		return

	if(wallwalk_active)
		wallwalk_active = FALSE
		density = TRUE
		REMOVE_TRAIT(src, TRAIT_PHASING_ABILITY, SCP_TRAIT)
		to_chat(src, span_notice("You return to the material plane. Solid matter is once again an obstacle."))
		visible_message(span_notice("[src] becomes fully solid again."))
		return

	wallwalk_active = TRUE
	wallwalk_cooldown = world.time + 30 SECONDS
	divine_energy -= 40

	ADD_TRAIT(src, TRAIT_PHASING_ABILITY, SCP_TRAIT)
	density = FALSE

	to_chat(src, span_notice("You thin the boundary between yourself and the world. You can now pass through solid matter."))
	visible_message(span_notice("[src] seems to become slightly translucent, as if less than entirely present."))

	addtimer(CALLBACK(src, PROC_REF(end_wallwalk)), 30 SECONDS)

/mob/living/scp/scp343/proc/end_wallwalk()
	if(!wallwalk_active)
		return

	wallwalk_active = FALSE
	density = TRUE
	REMOVE_TRAIT(src, TRAIT_PHASING_ABILITY, SCP_TRAIT)

	if(stat != DEAD)
		to_chat(src, span_notice("Your divine focus wanes. You can no longer pass through solid matter."))
		visible_message(span_notice("[src] becomes fully solid again."))

/mob/living/scp/scp343/proc/cleanse_area_ability()
	if(world.time < cleanse_cooldown)
		to_chat(src, span_warning("You need to wait before cleansing again."))
		return

	if(divine_energy < 35)
		to_chat(src, span_warning("Not enough divine energy."))
		return

	cleanse_cooldown = world.time + 40 SECONDS
	divine_energy -= 35

	var/turf/T = get_turf(src)
	visible_message(span_notice("[src] raises a hand, and the area is suffused with golden light. Impurities dissolve."))
	to_chat(src, span_notice("You cleanse the surrounding area of corruption and contamination."))

	new /obj/effect/temp_visual/divine_cleanse(T)

	var/cleansed_count = 0

	for(var/turf/area_turf in range(5, src))
		for(var/obj/effect/decal/cleanable/dirt in area_turf)
			qdel(dirt)
			cleansed_count++

		for(var/obj/effect/decal/cleanable/blood/blood in area_turf)
			qdel(blood)
			cleansed_count++

		for(var/obj/effect/decal/cleanable/plasma/chem in area_turf)
			qdel(chem)
			cleansed_count++

		for(var/obj/effect/hotspot/hotspot in area_turf)
			qdel(hotspot)
			cleansed_count++

		for(var/obj/structure/scp610_creep/creep in area_turf)
			qdel(creep)
			cleansed_count++

		for(var/obj/effect/anomaly/anom in area_turf)
			qdel(anom)
			cleansed_count++

	for(var/mob/living/carbon/human/H in range(5, src))
		if(H.SCP)
			continue

		H.adjustBruteLoss(-10)
		H.adjustFireLoss(-10)
		H.adjustToxLoss(-5)

		var/datum/status_effect/fire_handler/fire_stacks/fs = H.has_status_effect(/datum/status_effect/fire_handler/fire_stacks)
		if(fs)
			qdel(fs)
			cleansed_count++

		H.adjust_fire_stacks(-20)

		if(H.sanity)
			H.sanity.adjust_sanity(15, "scp343_cleanse")

		hook_scp_care(H, "SCP-343", "cleanse")
		cleansed_count++

	to_chat(src, span_notice("[cleansed_count] impurit[cleansed_count == 1 ? "y" : "ies"] cleansed."))

	hook_scp_interaction(src, "SCP-343", INTERACTION_TYPE_CARE)

/mob/living/scp/scp343/UnarmedAttack(atom/A)
	if(ishuman(A) && !combat_mode)
		var/mob/living/carbon/human/target = A
		if(target.stat != DEAD && target != src)
			divine_heal_ability(target)
			return
	return ..()

/mob/living/scp/scp343/proc/verb_divine_zone()
	set name = "Divine Zone"
	set category = "SCP-343"
	divine_zone_ability()

/mob/living/scp/scp343/proc/verb_manifest_item()
	set name = "Manifest Item"
	set category = "SCP-343"
	manifest_item_ability()

/mob/living/scp/scp343/proc/verb_vanish()
	set name = "Vanish"
	set category = "SCP-343"
	vanish_ability()

/mob/living/scp/scp343/proc/verb_walk_through_walls()
	set name = "Walk Through Walls"
	set category = "SCP-343"
	walk_through_walls_ability()

/mob/living/scp/scp343/proc/verb_cleanse_area()
	set name = "Cleanse Area"
	set category = "SCP-343"
	cleanse_area_ability()

/mob/living/scp/scp343/examine(mob/user)
	. = ..()

	if(user == src)
		. += span_notice("You radiate divine power and benevolence.")
		. += span_notice("Divine Energy: [divine_energy]/[max_divine_energy]")
		if(wallwalk_active)
			. += span_notice("You are currently phasing through solid matter.")
	else
		. += span_notice("This elderly man radiates an aura of divine power and benevolence.")
		. += span_notice("You feel a sense of peace and protection in his presence.")

		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.sanity)
				H.sanity.adjust_sanity(5, "scp343_examine")
				. += span_notice("His presence soothes your mind.")

/mob/living/scp/scp343/proc/on_divine_protection(mob/living/carbon/human/protected)
	if(!protected)
		return
	hook_scp_care(protected, "SCP-343", "protection")

/mob/living/scp/scp343/proc/on_divine_healing(mob/living/carbon/human/healed)
	if(!healed)
		return
	hook_scp_care(healed, "SCP-343", "healing")

/obj/effect/temp_visual/divine_presence
	icon = 'icons/effects/effects.dmi'
	icon_state = "purplesparkles"
	duration = 20
	color = "#FFD700"

/obj/effect/temp_visual/divine_vanish
	icon = 'icons/effects/effects.dmi'
	icon_state = "nullification"
	duration = 15
	color = "#FFD700"

/obj/effect/temp_visual/divine_appear
	icon = 'icons/effects/effects.dmi'
	icon_state = "phasein"
	duration = 15
	color = "#FFD700"

/obj/effect/temp_visual/divine_cleanse
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield"
	duration = 30
	color = "#FFD700"

/obj/effect/divine_zone
	name = "divine zone"
	desc = "An area radiating divine comfort and healing."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield"
	color = "#FFD700"
	anchored = TRUE
	var/duration = 30 SECONDS
	var/heal_amount = 5
	var/sanity_amount = 5

/obj/effect/divine_zone/Initialize()
	. = ..()
	QDEL_IN(src, duration)
	START_PROCESSING(SSobj, src)

/obj/effect/divine_zone/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/divine_zone/process()
	for(var/mob/living/carbon/human/H in range(3, src))
		if(H.SCP)
			continue
		if(H.health < H.maxHealth)
			H.adjustBruteLoss(-heal_amount)
			H.adjustFireLoss(-heal_amount)
		if(H.sanity)
			H.sanity.adjust_sanity(sanity_amount, "scp343_divine_zone")

/mob/living/scp/scp343/process_ai()
	if(stat == DEAD)
		return

	var/mob/living/carbon/human/best_target = null
	var/best_health_deficit = 0
	for(var/mob/living/carbon/human/H in view(7, src))
		if(H == src || H.stat == DEAD)
			continue
		var/deficit = H.maxHealth - H.health
		if(deficit > best_health_deficit)
			best_target = H
			best_health_deficit = deficit

	if(best_target)
		if(get_dist(src, best_target) <= 2)
			if(world.time >= divine_heal_cooldown && divine_energy >= 30)
				divine_heal_ability(best_target)
		else
			ai_step_towards(best_target)
		return

	if(prob(5))
		var/benevolent_phrases = list("Peace be with you.", "Do not be afraid.", "All will be well.", "I am here to help.", "Let me ease your suffering.")
		say(pick(benevolent_phrases))

	if(prob(10))
		step_rand(src)
