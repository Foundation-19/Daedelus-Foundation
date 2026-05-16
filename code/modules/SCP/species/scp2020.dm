// SCP-2020 Species Definition
// "Artie" - Green humanoid with teleportation and phasing abilities

/datum/species/scp2020
	name = "SCP-2020"
	id = "scp2020"
	say_mod = "says"
	sexes = TRUE
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_PHASING_ABILITY,
		TRAIT_TELEPORTATION_MASTERY,
		TRAIT_STEALTH_CAPABILITY,
		TRAIT_DIMENSIONAL_MOVEMENT
	)

	brutemod = 0.8
	burnmod = 0.9
	siemens_coeff = 0.5
	meat = /obj/item/food/meat/slab/human
	skinned_type = /obj/item/stack/sheet/animalhide/human
	exotic_blood = /datum/reagent/blood/scp2020
	disliked_food = NONE
	liked_food = DAIRY
	toxic_food = NONE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/scp2020

/datum/species/scp2020/on_species_gain(mob/living/carbon/human/H, datum/species/old_species, pref_load)
	. = ..()

/datum/species/scp2020/on_species_loss(mob/living/carbon/human/H)
	. = ..()

/datum/species/scp2020/spec_life(mob/living/carbon/human/H)
	. = ..()

	// Enhanced reflexes and supernatural awareness through traits

// Language holder for SCP-2020
/datum/language_holder/scp2020
	understood_languages = list(/datum/language/common, /datum/language/uncommon, /datum/language/draconic)
	spoken_languages = list(/datum/language/common)

// Custom blood type
/datum/reagent/blood/scp2020
	name = "SCP-2020 Blood"
	description = "Slightly luminescent green blood."
	color = "#00FF00"
