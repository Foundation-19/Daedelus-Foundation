// SCP-049 Species Definition

/datum/species/scp049
	name = "SCP-049"
	id = "scp049"
	say_mod = "speaks"
	sexes = 0
	species_traits = list()
	inherent_traits = list(
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOBREATH,
		TRAIT_RADIMMUNE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER,
		TRAIT_NOHARDCRIT,
		TRAIT_NOSOFTCRIT
	)
	brutemod = 0.5
	burnmod = 0.5
	siemens_coeff = 0
	meat = /obj/item/food/meat/slab/human/mutant/zombie
	skinned_type = /obj/item/stack/sheet/animalhide/human
	exotic_blood = /datum/reagent/toxin/plasma
	disliked_food = NONE
	liked_food = NONE
	toxic_food = NONE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/universal

/datum/species/scp049/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	H.set_safe_hunger_level()
	ADD_TRAIT(H, TRAIT_PESTILENCE_IMMUNE, SPECIES_TRAIT)

/datum/species/scp049/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	REMOVE_TRAIT(H, TRAIT_PESTILENCE_IMMUNE, SPECIES_TRAIT)

/datum/species/scp049/spec_life(mob/living/carbon/human/H)
	. = ..()
	if(H.stat == DEAD)
		return

	// SCP-049 specific life mechanics
	if(prob(1))
		H.emote("cough")
