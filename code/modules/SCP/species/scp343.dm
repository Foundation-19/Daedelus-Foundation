/datum/species/scp343
	name = "SCP-343"
	id = "scp343"
	say_mod = "speaks"
	sexes = 1
	species_traits = list()
	inherent_traits = list(
		TRAIT_DIVINE_POWER,
		TRAIT_REALITY_MANIPULATION,
		TRAIT_NOBREATH,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RADIMMUNE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER,
		TRAIT_NOHARDCRIT,
		TRAIT_NOSOFTCRIT
	)
	brutemod = 0.1 // Very resistant to damage
	burnmod = 0.1
	siemens_coeff = 0
	meat = /obj/item/food/meat/slab/human/mutant
	skinned_type = /obj/item/stack/sheet/animalhide/human
	disliked_food = NONE
	liked_food = NONE
	toxic_food = NONE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/universal

/datum/species/scp343/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	H.set_safe_hunger_level()
	ADD_TRAIT(H, TRAIT_DIVINE_POWER, SPECIES_TRAIT)
	ADD_TRAIT(H, TRAIT_REALITY_MANIPULATION, SPECIES_TRAIT)

/datum/species/scp343/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	REMOVE_TRAIT(H, TRAIT_DIVINE_POWER, SPECIES_TRAIT)
	REMOVE_TRAIT(H, TRAIT_REALITY_MANIPULATION, SPECIES_TRAIT)

/datum/species/scp343/spec_life(mob/living/carbon/human/H)
	. = ..()
	if(H.stat == DEAD)
		return

	// SCP-343 specific life mechanics
	if(prob(1))
		H.emote("bless")
