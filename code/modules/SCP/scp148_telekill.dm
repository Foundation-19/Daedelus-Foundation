/obj/item/stack/sheet/telekill
	name = "Telekill alloy"
	desc = "A dull metallic substance that interferes with psionic and memetic phenomena. Foundation standard for anti-memetic equipment."
	singular_name = "telekill sheet"
	icon_state = "sheet-metal"
	inhand_icon_state = "sheet-metal"
	layer = BELOW_OBJ_LAYER
	merge_type = /obj/item/stack/sheet/telekill
	grind_results = list(/datum/reagent/telekill_dust = 10)
	var/memetic_shield_radius = 3
	var/active_shielding = TRUE

/obj/item/stack/sheet/telekill/Initialize()
	. = ..()
	if(active_shielding)
		START_PROCESSING(SSobj, src)

/obj/item/stack/sheet/telekill/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/stack/sheet/telekill/process()
	if(!active_shielding)
		return
	for(var/mob/living/carbon/human/H in hearers(memetic_shield_radius, src))
		if(H.has_status_effect(/datum/status_effect/memetic_shield))
			continue
		H.apply_status_effect(/datum/status_effect/memetic_shield)

/datum/status_effect/memetic_shield
	id = "memetic_shield"
	duration = 30
	alert_type = null
	var/shield_strength = 1.0

/datum/status_effect/memetic_shield/tick()
	return

/obj/item/clothing/head/helmet/scp/telekill
	name = "Telekill helmet"
	desc = "A helmet lined with Telekill alloy. Provides resistance to memetic and cognitohazardous effects."
	icon_state = "telekill_helmet"
	armor = list(MELEE = 35, BULLET = 30, LASER = 10, ENERGY = 10, BOMB = 25, BIO = 100, RAD = 50, FIRE = 50, ACID = 50)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/shield_active = TRUE

/obj/item/clothing/head/helmet/scp/telekill/Destroy()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.remove_status_effect(/datum/status_effect/memetic_shield/strong)
	return ..()

/datum/status_effect/memetic_shield/strong
	id = "memetic_shield_strong"
	duration = -1
	shield_strength = 2.0

/datum/status_effect/memetic_shield/strong/tick()
	return

/obj/item/clothing/suit/armor/vest/scp/telekill/Destroy()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.remove_status_effect(/datum/status_effect/memetic_shield)
	return ..()

/obj/item/storage/box/telekill_kit
	name = "Telekill anti-memetic kit"
	desc = "A sealed Foundation kit containing Telekill alloy equipment for memetic hazard response."

/obj/item/storage/box/telekill_kit/PopulateContents()
	. = ..()
	new /obj/item/clothing/head/helmet/scp/telekill(src)
	new /obj/item/stack/sheet/telekill(src, 5)

/datum/reagent/telekill_dust
	name = "Telekill Dust"
	description = "A powdered form of Telekill alloy. Causes severe organ damage but temporarily immunizes against memetic effects."
	color = "#c0c0d0"
	taste_description = "metal"

/datum/reagent/telekill_dust/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	. = ..()
	M.apply_status_effect(/datum/status_effect/memetic_shield/strong)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2)
	M.adjustToxLoss(1, FALSE)

/obj/structure/telekill_barrier
	name = "Telekill barrier"
	desc = "A floor-mounted Telekill alloy barrier that blocks memetic effects from passing through."
	icon = 'icons/obj/structures.dmi'
	icon_state = "telekill_barrier"
	density = FALSE
	anchored = TRUE
	max_integrity = 200
	var/shield_radius = 4

/obj/structure/telekill_barrier/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/telekill_barrier/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/telekill_barrier/process()
	for(var/mob/living/carbon/human/H in hearers(shield_radius, src))
		if(!H.has_status_effect(/datum/status_effect/memetic_shield))
			H.apply_status_effect(/datum/status_effect/memetic_shield)
