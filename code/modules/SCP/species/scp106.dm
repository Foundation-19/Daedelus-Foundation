// SCP-106 Species Definition

/datum/species/scp106
	name = "SCP-106"
	id = "scp106"
	say_mod = "whispers"
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
		TRAIT_NOSOFTCRIT,
		TRAIT_DIMENSIONAL_PHASING
	)
	brutemod = 0.2
	burnmod = 0.2
	siemens_coeff = 0
	meat = /obj/item/food/meat/slab/human/mutant
	skinned_type = /obj/item/stack/sheet/animalhide/human
	exotic_blood = /datum/reagent/toxin/plasma
	disliked_food = NONE
	liked_food = NONE
	toxic_food = NONE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/universal

/datum/species/scp106/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	H.set_safe_hunger_level()
	ADD_TRAIT(H, TRAIT_DIMENSIONAL_PHASING, SPECIES_TRAIT)
	ADD_TRAIT(H, TRAIT_CORROSIVE_TOUCH, SPECIES_TRAIT)

/datum/species/scp106/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	REMOVE_TRAIT(H, TRAIT_DIMENSIONAL_PHASING, SPECIES_TRAIT)
	REMOVE_TRAIT(H, TRAIT_CORROSIVE_TOUCH, SPECIES_TRAIT)

/datum/species/scp106/spec_life(mob/living/carbon/human/H)
	. = ..()
	if(H.stat == DEAD)
		return

	// SCP-106 specific life mechanics
	if(prob(1))
		H.emote("whisper")
