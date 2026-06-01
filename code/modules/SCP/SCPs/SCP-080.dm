// SCP-080 - The Cabinet
// A wardrobe that contains an infinite darkness

/obj/structure/closet/scp080
	name = "antique wardrobe"
	desc = "A large, ornate wooden wardrobe. The doors seem to absorb the light around them."
	icon = 'icons/scp/scp-080.dmi'
	icon_state = "scp080_closed"
	opened = FALSE
	density = TRUE
	anchored = TRUE

	var/darkness_level = 0
	var/people_absorbed = 0
	var/duration_open = 0

	var/datum/scp080_darkness_system/darkness_system
	var/datum/scp080_absorption_system/absorption_system
	var/datum/scp080_research_system/research_system

/obj/structure/closet/scp080/Initialize()
	. = ..()

	SCP = new /datum/scp(src, "the wardrobe", SCP_EUCLID, "080")

	darkness_system = new /datum/scp080_darkness_system(src)
	absorption_system = new /datum/scp080_absorption_system(src)
	research_system = new /datum/scp080_research_system(src)

	START_PROCESSING(SSobj, src)

/obj/structure/closet/scp080/Destroy()
	QDEL_NULL(darkness_system)
	QDEL_NULL(absorption_system)
	QDEL_NULL(research_system)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/closet/scp080/process()
	if(!opened)
		return

	duration_open++
	darkness_level = min(100, darkness_level + 0.5)

	if(darkness_system)
		darkness_system.process_darkness()

	if(absorption_system)
		absorption_system.check_for_victims()

	if(duration_open > 60 && prob(10))
		visible_message(span_warning("Darkness seems to pour out of [src]!"))

/obj/structure/closet/scp080/open()
	. = ..()
	if(!opened)
		hook_scp_breach("SCP-080", src)
		icon_state = "scp080_open"
		visible_message(span_danger("[src] swings open, revealing impenetrable darkness within!"))

/obj/structure/closet/scp080/close()
	. = ..()
	if(opened)
		icon_state = "scp080_closed"
		darkness_level = max(0, darkness_level - 10)
		visible_message(span_notice("[src] closes, the darkness contained within."))

/obj/structure/closet/scp080/attack_hand(mob/living/carbon/human/user)
	..()
	hook_scp_interaction(user, "SCP-080", INTERACTION_TYPE_OBSERVATION)

/obj/structure/closet/scp080/attackby(obj/item/I, mob/living/carbon/human/user, params)
	if(istype(I, /obj/item/flashlight))
		if(opened && darkness_level > 50)
			to_chat(user, span_warning("The light from [I] is swallowed by the darkness!"))
			hook_scp_interaction(user, "SCP-080", INTERACTION_TYPE_CONTAINMENT)
			return
	return ..()

/obj/structure/closet/scp080/examine(mob/user)
	. = ..()
	to_chat(user, span_warning("A wardrobe containing infinite darkness. Those who enter may never return."))
	to_chat(user, span_notice("Darkness level: [darkness_level]%"))
	if(opened)
		to_chat(user, span_danger("It is currently open!"))

/obj/structure/closet/scp080/proc/on_victim_absorbed(mob/living/carbon/human/victim)
	if(!victim)
		return

	people_absorbed++
	hook_scp_combat(victim, "SCP-080", 0, 100)

/datum/scp080_darkness_system
	var/obj/structure/parent
	var/darkness_radius = 3
	var/max_radius = 10
	var/light_absorption_rate = 0.1

/datum/scp080_darkness_system/New(obj/structure/P)
	parent = P

/datum/scp080_darkness_system/proc/process_darkness()
	var/obj/structure/closet/scp080/scp080_parent = parent
	if(!scp080_parent || !scp080_parent.opened)
		return

	darkness_radius = min(max_radius, darkness_radius + light_absorption_rate)

	for(var/obj/machinery/light/L in range(darkness_radius, parent))
		if(L.on)
			L.set_on(FALSE)
			L.visible_message(span_warning("[L] flickers and dies!"))

	for(var/obj/item/flashlight/F in range(darkness_radius, parent))
		if(F.on)
			F.on = FALSE
			F.update_brightness()
			F.visible_message(span_warning("[F] flickers and dies!"))

/datum/scp080_absorption_system
	var/obj/structure/parent
	var/absorption_range = 1
	var/absorption_cooldown = 0
	var/absorption_delay = 50

/datum/scp080_absorption_system/New(obj/structure/P)
	parent = P

/datum/scp080_absorption_system/proc/check_for_victims()
	var/obj/structure/closet/scp080/scp080_parent = parent
	if(!scp080_parent || !scp080_parent.opened || absorption_cooldown > world.time)
		return

	for(var/mob/living/carbon/human/H in range(absorption_range, scp080_parent))
		if(!QDELETED(H) && H.stat != DEAD && prob(20 * (scp080_parent.darkness_level / 100)))
			attempt_absorption(H)
			absorption_cooldown = world.time + absorption_delay
			break

/datum/scp080_absorption_system/proc/attempt_absorption(mob/living/carbon/human/victim)
	if(!victim)
		return

	var/obj/structure/closet/scp080/scp080_parent = parent
	if(!scp080_parent)
		return

	victim.visible_message(span_danger("[victim] is pulled into the darkness of [scp080_parent]!"), span_danger("The darkness pulls you in!"))

	if(do_after(victim, 30, scp080_parent))
		if(prob(70))
			scp080_parent.on_victim_absorbed(victim)
			victim.forceMove(scp080_parent)
			victim.stat = DEAD
			victim.visible_message(span_danger("[victim] disappears into the wardrobe!"))
		else
			to_chat(victim, span_notice("You manage to pull yourself free!"))
			hook_scp_interaction(victim, "SCP-080", INTERACTION_TYPE_SURVIVAL)

/datum/scp080_research_system
	var/obj/structure/parent
	var/list/absorption_log = list()
	var/total_darkness_events = 0

/datum/scp080_research_system/New(obj/structure/P)
	parent = P
