// SCP-178 - 3D Glasses
// A pair of 3D glasses that allow viewing of interdimensional entities

/obj/item/clothing/glasses/scp178
	name = "3D glasses"
	desc = "A pair of cardboard 3D glasses with red and cyan lenses. They seem ordinary enough."
	icon = 'icons/scp/scp-178.dmi'
	icon_state = "scp178"
	w_class = WEIGHT_CLASS_SMALL

	var/active = FALSE
	var/dimension_phase = 0
	var/entities_seen = 0
	var/sanity_drain = 0.5

	var/datum/scp178_perception_system/perception_system
	var/datum/scp178_entity_system/entity_system
	var/datum/scp178_research_system/research_system

	var/activation_count = 0
	var/entities_killed = 0

/obj/item/clothing/glasses/scp178/Initialize()
	. = ..()

	SCP = new /datum/scp(src, "3D glasses", SCP_EUCLID, "178")

	perception_system = new /datum/scp178_perception_system(src)
	entity_system = new /datum/scp178_entity_system(src)
	research_system = new /datum/scp178_research_system(src)

/obj/item/clothing/glasses/scp178/Destroy()
	QDEL_NULL(perception_system)
	if(entity_system)
		for(var/obj/effect/dimension_entity/E in entity_system.visible_entities)
			QDEL_NULL(E)
	QDEL_NULL(entity_system)
	QDEL_NULL(research_system)
	QDEL_NULL(SCP)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/glasses/scp178/equipped(mob/living/carbon/human/user, slot)
	..()
	if(slot == ITEM_SLOT_EYES)
		active = TRUE
		activation_count++
		hook_scp_interaction(user, "SCP-178", INTERACTION_TYPE_OBSERVATION)
		to_chat(user, "<span class='warning'>The world shifts as you put on the glasses...</span>")
		START_PROCESSING(SSobj, src)

/obj/item/clothing/glasses/scp178/unequipped(mob/living/carbon/human/user, silent=FALSE)
	..()
	active = FALSE
	STOP_PROCESSING(SSobj, src)

/obj/item/clothing/glasses/scp178/process()
	if(!active)
		return

	var/mob/living/carbon/human/wearer = loc
	if(!istype(wearer) || wearer.glasses != src)
		return

	dimension_phase++

	if(perception_system)
		perception_system.process_perception(wearer)

	if(entity_system)
		entity_system.process_entities(wearer)

	if(dimension_phase % 50 == 0)
		if(prob(15))
			wearer.adjustOrganLoss(ORGAN_SLOT_BRAIN, sanity_drain)
			to_chat(wearer, "<span class='danger'>You glimpse something... wrong.</span>")
			hook_scp_combat(wearer, "SCP-178", 0, 5)

/obj/item/clothing/glasses/scp178/examine(mob/user)
	. = ..()
	if(ishuman(user))
		to_chat(user, "<span class='notice'>A pair of 3D glasses. Looking through them might reveal hidden things.</span>")

/datum/scp178_perception_system
	var/obj/item/parent
	var/perception_level = 1
	var/max_perception = 10

/datum/scp178_perception_system/New(obj/item/P)
	parent = P

/datum/scp178_perception_system/proc/process_perception(mob/living/carbon/human/viewer)
	if(!viewer)
		return

	if(perception_level < max_perception && prob(5))
		perception_level++

/datum/scp178_entity_system
	var/obj/item/parent
	var/list/visible_entities = list()
	var/entity_aggression = 0
	var/max_aggression = 100

/datum/scp178_entity_system/New(obj/item/P)
	parent = P

/datum/scp178_entity_system/proc/process_entities(mob/living/carbon/human/viewer)
	if(!viewer)
		return

	if(prob(10))
		var/obj/effect/dimension_entity/entity = new(get_turf(viewer))
		visible_entities += entity
		viewer.visible_message("<span class='warning'>[viewer] stares at something you can't see.</span>", "<span class='danger'>A shadowy figure manifests nearby!</span>")

	if(length(visible_entities) > 0 && prob(entity_aggression / 10))
		var/obj/effect/dimension_entity/E = pick(visible_entities)
		if(E && get_dist(E, viewer) <= 2)
			viewer.adjustBruteLoss(5)
			to_chat(viewer, "<span class='danger'>One of the entities claws at you!</span>")
			hook_scp_combat(viewer, "SCP-178", 0, 5)

	entity_aggression = min(max_aggression, entity_aggression + 0.1)

/obj/effect/dimension_entity
	name = "interdimensional entity"
	desc = "A shadowy, vaguely humanoid figure visible only through SCP-178."
	icon = 'icons/turf/shadows.dmi'
	icon_state = "shadow"
	density = FALSE
	anchored = TRUE
	alpha = 100

/obj/effect/dimension_entity/New(loc)
	..()
	QDEL_IN(src, 300)

/datum/scp178_research_system
	var/obj/item/parent
	var/list/research_data = list()
	var/observation_events = 0

/datum/scp178_research_system/New(obj/item/P)
	parent = P

/datum/scp178_research_system/proc/record_observation(mob/living/carbon/human/observer, event_type)
	observation_events++
	research_data["[world.time]"] = list("observer" = observer.ckey, "event" = event_type)
