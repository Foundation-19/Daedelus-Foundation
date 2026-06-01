/datum/species/scp3349
	name = "Reality Bender"
	id = "scp3349"
	say_mod = "resonates"
	sexes = 0
	species_traits = list()
	inherent_traits = list(
		TRAIT_REALITY_MANIPULATION
	)
	brutemod = 0.6
	burnmod = 0.6
	siemens_coeff = 0.2

/datum/species/scp3349/spec_life(mob/living/carbon/human/H)
	. = ..()
	if(!H || H.stat == DEAD)
		return
	if(prob(1))
		H.visible_message(span_notice("Reality shimmers faintly around [H]."))




