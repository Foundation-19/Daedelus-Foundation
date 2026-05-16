/datum/species/scp966
	name = "SCP-966"
	id = "scp966"
	say_mod = "rasps"
	sexes = 0
	species_traits = list()
	inherent_traits = list(
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOBREATH,
		TRAIT_RADIMMUNE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_NIGHT_VISION
	)
	brutemod = 0.7
	burnmod = 0.8
	siemens_coeff = 0
	meat = /obj/item/food/meat/slab/human/mutant
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN
	species_language_holder = /datum/language_holder/universal

/datum/species/scp966/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	H.set_safe_hunger_level()
	H.alpha = 50

/datum/species/scp966/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	H.alpha = 255

/datum/species/scp966/spec_life(mob/living/carbon/human/H)
	. = ..()
	if(H.stat == DEAD)
		return
