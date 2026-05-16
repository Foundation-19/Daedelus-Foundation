/datum/species/scp527
	name = "SCP-527"
	id = "scp527"
	say_mod = "says"
	sexes = 0
	species_traits = list()
	inherent_traits = list(
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOBREATH,
		TRAIT_RADIMMUNE,
		TRAIT_VIRUSIMMUNE
	)
	brutemod = 0.8
	burnmod = 1.0
	siemens_coeff = 0
	meat = /obj/item/food/meat/slab/human/mutant
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN
	species_language_holder = /datum/language_holder/universal

/datum/species/scp527/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	H.set_safe_hunger_level()

/datum/species/scp527/on_species_loss(mob/living/carbon/human/H)
	. = ..()

/datum/species/scp527/spec_life(mob/living/carbon/human/H)
	. = ..()
	if(H.stat == DEAD)
		return
