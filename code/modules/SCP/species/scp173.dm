/datum/species/scp173
	name = "SCP-173"
	id = "scp173"
	say_mod = "rattles"
	sexes = 0
	species_traits = list()
	inherent_traits = list(
		TRAIT_NOBREATH,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RADIMMUNE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER,
		TRAIT_NOHARDCRIT,
		TRAIT_NOSOFTCRIT,
		TRAIT_STABLEHEART,
		TRAIT_STABLELIVER,
		TRAIT_LIMBATTACHMENT
	)
	brutemod = 0.1
	burnmod = 0.1
	siemens_coeff = 0
	meat = /obj/item/food/meat/slab/human/mutant
	skinned_type = /obj/item/stack/sheet/animalhide/human
	disliked_food = NONE
	liked_food = NONE
	toxic_food = NONE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/universal

/datum/species/scp173/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	H.set_safe_hunger_level()
	// SCP-173 specific traits will be handled by the modular systems

/datum/species/scp173/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	// Cleanup will be handled by the modular systems

/datum/species/scp173/spec_life(mob/living/carbon/human/H)
	. = ..()
	if(H.stat == DEAD)
		return

	// SCP-173 specific life mechanics will be handled by modular systems
