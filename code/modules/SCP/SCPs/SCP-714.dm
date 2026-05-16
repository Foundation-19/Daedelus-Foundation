// SCP-714 - The Jade Ring
// A jade ring that provides protection but drains the wearer's energy

/obj/item/clothing/ring/scp714
	name = "jade ring"
	desc = "An ornate jade ring with intricate carvings. It feels cold to the touch."
	icon = 'icons/scp/scp-714.dmi'
	icon_state = "scp-714"
	w_class = WEIGHT_CLASS_SMALL

	var/active = FALSE
	var/wearer_stamina_drain = 2
	var/protection_level = 1
	var/wear_duration = 0

	var/datum/scp714_protection_system/protection_system
	var/datum/scp714_effect_system/effect_system
	var/datum/scp714_research_system/research_system

	var/equip_count = 0
	var/threats_neutralized = 0

/obj/item/clothing/ring/scp714/Initialize()
	. = ..()

	SCP = new /datum/scp(src, "jade ring", SCP_SAFE, "714")

	protection_system = new /datum/scp714_protection_system(src)
	effect_system = new /datum/scp714_effect_system(src)
	research_system = new /datum/scp714_research_system(src)

/obj/item/clothing/ring/scp714/Destroy()
	QDEL_NULL(protection_system)
	QDEL_NULL(effect_system)
	QDEL_NULL(research_system)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/ring/scp714/equipped(mob/living/carbon/human/user, slot)
	..()
	if(slot == ITEM_SLOT_GLOVES)
		active = TRUE
		equip_count++
		hook_scp_interaction(user, "SCP-714", INTERACTION_TYPE_OBSERVATION)
		to_chat(user, "<span class='notice'>The jade ring slides onto your finger, and you feel a protective presence.</span>")
		START_PROCESSING(SSobj, src)

/obj/item/clothing/ring/scp714/unequipped(mob/living/carbon/human/user, silent=FALSE)
	..()
	active = FALSE
	wear_duration = 0
	STOP_PROCESSING(SSobj, src)

/obj/item/clothing/ring/scp714/process()
	if(!active)
		return

	var/mob/living/carbon/human/wearer = loc
	if(!istype(wearer))
		return

	wear_duration++

	if(protection_system)
		protection_system.process_protection(wearer)

	if(effect_system)
		effect_system.process_effects(wearer)

	if(wear_duration % 20 == 0)
		if(wearer.stamina)
			wearer.stamina.adjust(-wearer_stamina_drain)
		if(prob(10))
			to_chat(wearer, "<span class='warning'>The ring's protection comes at a cost - you feel drained.</span>")

/obj/item/clothing/ring/scp714/examine(mob/user)
	. = ..()
	if(ishuman(user))
		to_chat(user, "<span class='notice'>A jade ring with protective properties. Wearing it may drain your energy.</span>")

/datum/scp714_protection_system
	var/obj/item/parent
	var/protection_strength = 50
	var/list/blocked_effects = list("poison", "radiation", "memetic")

/datum/scp714_protection_system/New(obj/item/P)
	parent = P

/datum/scp714_protection_system/proc/process_protection(mob/living/carbon/human/wearer)
	if(!wearer)
		return

	for(var/effect_type in blocked_effects)
		if(effect_type == "poison")
			wearer.reagents?.remove_reagent(/datum/reagent/toxin, 1)
		if(effect_type == "radiation")
			var/datum/component/irradiated/rad_component = wearer.GetComponent(/datum/component/irradiated)
			if(rad_component)
				qdel(rad_component)

/datum/scp714_protection_system/proc/check_protection(mob/living/carbon/human/wearer, effect_type)
	if(effect_type in blocked_effects)
		return protection_strength
	return 0

/datum/scp714_effect_system
	var/obj/item/parent
	var/drowsiness_level = 0
	var/max_drowsiness = 100

/datum/scp714_effect_system/New(obj/item/P)
	parent = P

/datum/scp714_effect_system/proc/process_effects(mob/living/carbon/human/wearer)
	if(!wearer)
		return

	drowsiness_level = min(max_drowsiness, drowsiness_level + 0.5)

	if(drowsiness_level > 50 && prob(5))
		wearer.drowsyness = min(100, wearer.drowsyness + 5)
		to_chat(wearer, "<span class='warning'>You feel sleepy...</span>")

/datum/scp714_research_system
	var/obj/item/parent
	var/list/research_data = list()
	var/protection_events = 0

/datum/scp714_research_system/New(obj/item/P)
	parent = P

/datum/scp714_research_system/proc/record_protection_event(mob/living/carbon/human/wearer, effect_blocked)
	protection_events++
	research_data["[world.time]"] = list("wearer" = wearer.ckey, "blocked" = effect_blocked)

