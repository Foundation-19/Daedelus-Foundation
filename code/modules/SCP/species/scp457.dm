// SCP-457 Species Definition

/datum/species/scp457
	name = "SCP-457"
	id = "scp457"
	say_mod = "crackles"
	inherent_traits = list(
		TRAIT_FIRE_IMMUNE,
		TRAIT_HEAT_RESISTANT,
		TRAIT_NOBREATH,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE
	)
	exotic_blood = /datum/reagent/fuel
	heatmod = 0.1
	coldmod = 2.0
	brutemod = 0.8
	burnmod = 0.1
	siemens_coeff = 0
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	sexes = 0
	fixed_mut_color = "FF4400"
	meat = /obj/item/food/meat/slab/human/mutant/slime
	skinned_type = /obj/item/stack/sheet/animalhide/human
	disliked_food = NONE
	liked_food = NONE
	toxic_food = NONE
	species_language_holder = /datum/language_holder/universal

/datum/species/scp457/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	H.set_safe_hunger_level()
	ADD_TRAIT(H, TRAIT_FIRE_IMMUNE, SPECIES_TRAIT)
	ADD_TRAIT(H, TRAIT_HEAT_RESISTANT, SPECIES_TRAIT)

/datum/species/scp457/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	REMOVE_TRAIT(H, TRAIT_FIRE_IMMUNE, SPECIES_TRAIT)
	REMOVE_TRAIT(H, TRAIT_HEAT_RESISTANT, SPECIES_TRAIT)

/datum/species/scp457/spec_life(mob/living/carbon/human/H)
	. = ..()
	if(H.stat == DEAD)
		return

	// SCP-457 specific life mechanics
	if(prob(1))
		H.emote("crackle")
