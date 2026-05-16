// SCP-082 Species Definition - Fernand the Cannibal

/datum/species/scp082
	name = "SCP-082"
	id = "scp082"
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
		TRAIT_NOSOFTCRIT,
		TRAIT_ENHANCED_STRENGTH
	)
	brutemod = 0.3
	burnmod = 0.3
	siemens_coeff = 0
	meat = /obj/item/food/meat/slab/human/mutant
	skinned_type = /obj/item/stack/sheet/animalhide/human
	exotic_blood = /datum/reagent/toxin/plasma
	disliked_food = NONE
	liked_food = NONE
	toxic_food = NONE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/universal

/datum/species/scp082/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	H.set_safe_hunger_level()
	ADD_TRAIT(H, TRAIT_ENHANCED_STRENGTH, SPECIES_TRAIT)
	ADD_TRAIT(H, TRAIT_CANNIBALISTIC, SPECIES_TRAIT)

/datum/species/scp082/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	REMOVE_TRAIT(H, TRAIT_ENHANCED_STRENGTH, SPECIES_TRAIT)
	REMOVE_TRAIT(H, TRAIT_CANNIBALISTIC, SPECIES_TRAIT)

/datum/species/scp082/spec_life(mob/living/carbon/human/H)
	. = ..()
	if(H.stat == DEAD)
		return

	if(prob(1))
		H.emote("smile")
