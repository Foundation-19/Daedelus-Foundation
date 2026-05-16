/datum/species/scp5295
	name = "Temporal Entity"
	id = "scp5295"
	// Base physiology modifiers tuned for a resilient but not invulnerable SCP
	brutemod = 0.6
	burnmod = 0.5
	siemens_coeff = 0.2
	// Traits specific to temporal manipulation
	inherent_traits = list(
		TRAIT_TEMPORAL_IMMUNITY,
		TRAIT_REALITY_ANCHORING,
		TRAIT_CHRONOLOGICAL_AWARENESS,
		TRAIT_REALITY_MANIPULATION
	)

	// Species-specific life tick hook if needed later
/datum/species/scp5295/spec_life(mob/living/carbon/human/H)
	. = ..()
	if(!H)
		return
	if(prob(1))
		for(var/mob/living/carbon/human/observer in view(3, H))
			if(observer == H)
				continue
			observer.sanity?.adjust_sanity(-0.2)


