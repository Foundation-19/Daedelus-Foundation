/datum/species/scp3199
	name = "SCP-3199"
	id = "scp3199"
	say_mod = "hisses"
	sexes = 0
	species_traits = list()
	inherent_traits = list(
		TRAIT_ENHANCED_STRENGTH,
		TRAIT_RAPID_REGENERATION
	)
	brutemod = 0.7
	burnmod = 0.7
	siemens_coeff = 0.3

/datum/species/scp3199/spec_life(mob/living/carbon/human/H)
	. = ..()
	if(!H || H.stat == DEAD)
		return
	if(prob(1))
		H.visible_message("<span class='notice'>A wet albumen sheen coats [H].</span>")




