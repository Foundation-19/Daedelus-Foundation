// SCP-1102-RU - The Artist's Case
// A briefcase that contains a portal to another dimension with a ladder

/obj/item/storage/briefcase/scp1102ru
	name = "old plastic case"
	desc = "A strange plastic case covered in cloth. There seems to be an unusual depth to it."
	icon = 'icons/obj/storage.dmi'
	icon_state = "briefcase"
	w_class = WEIGHT_CLASS_BULKY

	var/obj/structure/ladder/scp1102ladder/enter_point
	var/portal_cooldown = 0
	var/portal_cooldown_time = 30 SECONDS
	var/dimension_depth = 1
	var/explorations = 0

	var/datum/scp1102_dimension_system/dimension_system
	var/datum/scp1102_portal_system/portal_system
	var/datum/scp1102_research_system/research_system

/obj/item/storage/briefcase/scp1102ru/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "old plastic case", SCP_SAFE, "1102-RU")

	dimension_system = new /datum/scp1102_dimension_system(src)
	portal_system = new /datum/scp1102_portal_system(src)
	research_system = new /datum/scp1102_research_system(src)

/obj/item/storage/briefcase/scp1102ru/attack_hand(mob/user)
	. = ..()
	if(enter_point && !QDELETED(enter_point))
		return
	enter_point = new /obj/structure/ladder/scp1102ladder(get_turf(src))
	enter_point.linked_case = src

/obj/item/storage/briefcase/scp1102ru/attack_self(mob/living/carbon/human/user)
	if(!user || !istype(user))
		return

	if(portal_cooldown > world.time)
		to_chat(user, "<span class='warning'>The portal is still recharging...</span>")
		return

	if(enter_point && !QDELETED(enter_point))
		qdel(enter_point)
	enter_point = new /obj/structure/ladder/scp1102ladder(get_turf(src))
	enter_point.linked_case = src

	hook_scp_interaction(user, "SCP-1102-RU", INTERACTION_TYPE_EXPLORATION)
	explorations++

	if(dimension_system)
		dimension_system.enter_dimension(user)

	to_chat(user, "<span class='warning'>You feel a strange sensation as you open the case...</span>")
	to_chat(user, "<span class='notice'>You find yourself climbing down a ladder that shouldn't be there.</span>")

	playsound(src, 'sound/effects/explosion1.ogg', 50)
	playsound(enter_point, 'sound/effects/explosion1.ogg', 50)

	user.forceMove(get_turf(enter_point))
	to_chat(user, "<span class='warning'>The case disappears behind you as you descend into an endless void.</span>")

	portal_cooldown = world.time + portal_cooldown_time

/obj/item/storage/briefcase/scp1102ru/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>A case containing a portal to another dimension.</span>")
	to_chat(user, "<span class='notice'>Explorations: [explorations]</span>")

/obj/structure/ladder/scp1102ladder
	name = "strange ladder"
	desc = "A ladder that leads to nowhere. It seems to stretch infinitely in both directions."
	icon = 'icons/obj/structures.dmi'
	icon_state = "ladder11"
	density = FALSE
	anchored = TRUE

	var/obj/item/storage/briefcase/scp1102ru/linked_case
	var/depth_level = 1
	var/visits = 0

	var/datum/scp1102ladder_depth_system/depth_system
	var/datum/scp1102ladder_effect_system/effect_system

/obj/structure/ladder/scp1102ladder/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "ladder", SCP_SAFE, "1102-RU-1")

	depth_system = new /datum/scp1102ladder_depth_system(src)
	effect_system = new /datum/scp1102ladder_effect_system(src)

/obj/structure/ladder/scp1102ladder/use(mob/living/carbon/human/user)
	if(!linked_case)
		to_chat(user, "<span class='warning'>The ladder seems to lead nowhere...</span>")
		return

	if(linked_case.portal_cooldown > world.time)
		to_chat(user, "<span class='warning'>The portal is still recharging...</span>")
		return

	hook_scp_interaction(user, "SCP-1102-RU-1", INTERACTION_TYPE_EXPLORATION)
	visits++

	if(effect_system && prob(30))
		effect_system.apply_dimension_effect(user)

	to_chat(user, "<span class='notice'>You climb back up the ladder...</span>")
	playsound(src, 'sound/effects/explosion1.ogg', 50)
	playsound(linked_case, 'sound/effects/explosion1.ogg', 50)

	user.forceMove(get_turf(linked_case))
	to_chat(user, "<span class='notice'>You emerge from the strange case.</span>")

	linked_case.portal_cooldown = world.time + linked_case.portal_cooldown_time

/obj/structure/ladder/scp1102ladder/proc/descend_deeper(mob/living/carbon/human/user)
	if(!user)
		return

	depth_level++
	hook_scp_interaction(user, "SCP-1102-RU-1", INTERACTION_TYPE_EXPLORATION)

	if(depth_system)
		depth_system.process_depth(depth_level)

	to_chat(user, "<span class='warning'>You climb deeper into the void... Depth level: [depth_level]</span>")

/obj/structure/ladder/scp1102ladder/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>A ladder in an endless void. Current depth: [depth_level]</span>")
	to_chat(user, "<span class='warning'>Climbing deeper may have consequences.</span>")

/datum/scp1102_dimension_system
	var/obj/item/parent
	var/dimension_stability = 100
	var/max_depth = 10
	var/current_depth = 1

/datum/scp1102_dimension_system/New(obj/item/P)
	parent = P

/datum/scp1102_dimension_system/proc/enter_dimension(mob/living/carbon/human/explorer)
	if(!explorer)
		return

	dimension_stability = max(0, dimension_stability - 5)
	current_depth = 1

	if(dimension_stability < 50 && prob(30))
		to_chat(explorer, "<span class='warning'>The dimension feels unstable...</span>")
		explorer.adjust_drowsyness(5)
		hook_scp_combat(explorer, "SCP-1102-RU", 0, 5)

/datum/scp1102_portal_system
	var/obj/item/parent
	var/portal_stability = 100
	var/max_stability = 100
	var/recharge_rate = 1

/datum/scp1102_portal_system/New(obj/item/P)
	parent = P

/datum/scp1102_research_system
	var/obj/item/parent
	var/list/exploration_log = list()
	var/total_depth_achieved = 0

/datum/scp1102_research_system/New(obj/item/P)
	parent = P

/datum/scp1102ladder_depth_system
	var/obj/structure/parent
	var/difficulty_multiplier = 1.0
	var/hazard_chance = 5

/datum/scp1102ladder_depth_system/New(obj/structure/P)
	parent = P

/datum/scp1102ladder_depth_system/proc/process_depth(depth)
	difficulty_multiplier = 1 + (depth * 0.1)
	hazard_chance = 5 + (depth * 2)

/datum/scp1102ladder_effect_system
	var/obj/structure/parent
	var/list/possible_effects = list("void_whispers", "temporal_drift", "gravity_shift")

/datum/scp1102ladder_effect_system/New(obj/structure/P)
	parent = P

/datum/scp1102ladder_effect_system/proc/apply_dimension_effect(mob/living/carbon/human/subject)
	if(!subject)
		return

	var/effect = pick(possible_effects)

	switch(effect)
		if("void_whispers")
			to_chat(subject, "<span class='warning'>You hear whispers from the void...</span>")
			subject.adjust_drowsyness(2)
			hook_scp_combat(subject, "SCP-1102-RU-1", 0, 2)
		if("temporal_drift")
			to_chat(subject, "<span class='warning'>Time seems to shift around you...</span>")
			subject.stamina?.adjust(-20)
		if("gravity_shift")
			to_chat(subject, "<span class='warning'>Gravity fluctuates!</span>")
			if(prob(50))
				subject.Knockdown(30)
