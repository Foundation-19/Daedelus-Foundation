// SCP Sanity Integration
// Integrates sanity system with SCP encounters and effects

// SCP-035 Sanity Integration
/obj/item/clothing/mask/scp035/proc/affect_host_sanity(mob/living/carbon/human/host, severity = 15)
	if(!host || !host.sanity)
		return

	// SCP-035 causes severe psychological trauma
	if(host.sanity)
		host.sanity.add_trauma(TRAUMA_PSYCHOLOGICAL, severity)
	host.sanity.hallucination_level = min(host.sanity.hallucination_level + 20, host.sanity.max_hallucination)
	host.sanity.insanity_level = min(host.sanity.insanity_level + 10, host.sanity.max_insanity)

	to_chat(host, "<span class='danger'>The mask's influence is affecting your mental state!</span>")

// SCP-096 Sanity Integration
/mob/living/simple_animal/hostile/scp096/proc/affect_viewer_sanity(mob/living/carbon/human/viewer)
	if(!viewer || !viewer.sanity)
		return

	// Seeing SCP-096 causes extreme trauma
	if(viewer.sanity)
		viewer.sanity.add_trauma(TRAUMA_PSYCHOLOGICAL, 25)
	if(viewer.sanity)
		viewer.sanity.add_trauma(TRAUMA_SCP_EXPOSURE, 20)
	viewer.sanity.hallucination_level = min(viewer.sanity.hallucination_level + 30, viewer.sanity.max_hallucination)
	viewer.sanity.insanity_level = min(viewer.sanity.insanity_level + 15, viewer.sanity.max_insanity)

	to_chat(viewer, "<span class='danger'>The sight of SCP-096 has traumatized you!</span>")

// SCP-173 Sanity Integration
/obj/structure/scp173/proc/affect_nearby_sanity()
	for(var/mob/living/carbon/human/H in range(5, src))
		if(H.stat == DEAD || !H.sanity)
			continue

		// SCP-173 causes paranoia and anxiety
		if(H.sanity)
			H.sanity.add_trauma(TRAUMA_PSYCHOLOGICAL, 5)
		H.sanity.insanity_level = min(H.sanity.insanity_level + 2, H.sanity.max_insanity)

		if(prob(10))
			to_chat(H, "<span class='warning'>You feel an overwhelming sense of dread...</span>")

// SCP-049 Sanity Integration
/mob/living/simple_animal/hostile/scp049/proc/affect_patient_sanity(mob/living/carbon/human/patient)
	if(!patient || !patient.sanity)
		return

	// SCP-049's "treatment" is psychologically traumatic
	if(patient.sanity)
		patient.sanity.add_trauma(TRAUMA_PSYCHOLOGICAL, 20)
	if(patient.sanity)
		patient.sanity.add_trauma(TRAUMA_PHYSICAL, 15)
	patient.sanity.hallucination_level = min(patient.sanity.hallucination_level + 25, patient.sanity.max_hallucination)

	to_chat(patient, "<span class='danger'>The doctor's 'treatment' has left you mentally scarred!</span>")

// SCP-106 Sanity Integration
/mob/living/simple_animal/hostile/scp106/proc/affect_victim_sanity(mob/living/carbon/human/victim)
	if(!victim || !victim.sanity)
		return

	// SCP-106's pocket dimension is extremely traumatic
	if(victim.sanity)
		victim.sanity.add_trauma(TRAUMA_PSYCHOLOGICAL, 30)
	if(victim.sanity)
		victim.sanity.add_trauma(TRAUMA_SCP_EXPOSURE, 25)
	victim.sanity.hallucination_level = victim.sanity.max_hallucination
	victim.sanity.insanity_level = min(victim.sanity.insanity_level + 20, victim.sanity.max_insanity)

	to_chat(victim, "<span class='danger'>The pocket dimension has shattered your sanity!</span>")

// SCP-3008 Sanity Integration
/area/scp3008/proc/affect_occupant_sanity(mob/living/carbon/human/occupant)
	if(!occupant || !occupant.sanity)
		return

	// The infinite IKEA causes isolation trauma
	if(occupant.sanity)
		occupant.sanity.add_trauma(TRAUMA_ISOLATION, 10)
	occupant.sanity.social_isolation = min(occupant.sanity.social_isolation + 5, occupant.sanity.max_social_isolation)

	if(prob(5))
		to_chat(occupant, "<span class='warning'>The endless corridors are getting to you...</span>")

// Generic SCP Sanity Effects
/datum/scp/proc/apply_sanity_effects(mob/living/carbon/human/target, severity = 10)
	if(!target || !target.sanity)
		return

	// Base SCP exposure effect
	var/scp_number = "unknown"
	if(designation)
		scp_number = designation
	if(target.sanity)
		target.sanity.add_scp_exposure(scp_number, severity)

	// Apply class-specific effects
	var/scp_class_type = "unknown"
	if(classification)
		scp_class_type = classification
	switch(scp_class_type)
		if(SCP_SAFE)
			if(target.sanity)
				target.sanity.add_trauma(TRAUMA_SCP_EXPOSURE, severity * 0.5)
		if(SCP_EUCLID)
			if(target.sanity)
				target.sanity.add_trauma(TRAUMA_SCP_EXPOSURE, severity)
			target.sanity.hallucination_level = min(target.sanity.hallucination_level + 10, target.sanity.max_hallucination)
		if(SCP_KETER)
			if(target.sanity)
				target.sanity.add_trauma(TRAUMA_SCP_EXPOSURE, severity * 1.5)
			target.sanity.hallucination_level = min(target.sanity.hallucination_level + 20, target.sanity.max_hallucination)
			target.sanity.insanity_level = min(target.sanity.insanity_level + 10, target.sanity.max_insanity)
		if(SCP_THAUMIEL)
			if(target.sanity)
				target.sanity.add_trauma(TRAUMA_SCP_EXPOSURE, severity * 0.3)
		if(SCP_NEUTRALIZED)
			if(target.sanity)
				target.sanity.add_trauma(TRAUMA_SCP_EXPOSURE, severity * 0.1)

// Sanity-based SCP resistance
/datum/sanity/proc/check_scp_resistance(scp_id)
	var/resistance = 1.0

	// Previous exposure builds resistance
	if(scp_id in scp_exposures)
		resistance += 0.2

	// High sanity provides resistance
	if(sanity_level > 80)
		resistance += 0.3
	else if(sanity_level < 30)
		resistance -= 0.3

	// Insanity can provide resistance to certain SCPs
	if(insanity_level > 50)
		resistance += 0.2

	return resistance

// Sanity-based SCP vulnerability
/datum/sanity/proc/check_scp_vulnerability(scp_id)
	var/vulnerability = 1.0

	// Low sanity increases vulnerability
	if(sanity_level < 50)
		vulnerability += 0.5
	if(sanity_level < 20)
		vulnerability += 0.5

	// Trauma makes you more vulnerable
	for(var/trauma in traumas)
		var/datum/trauma/T = trauma
		if(T.trauma_type == TRAUMA_SCP_EXPOSURE)
			vulnerability += 0.2

	// Hallucinations can make you vulnerable
	if(hallucination_level > 50)
		vulnerability += 0.3

	return vulnerability

// Sanity-based SCP interaction modifiers
/datum/sanity/proc/get_scp_interaction_modifier(scp_id)
	var/modifier = 1.0

	// High sanity improves interaction
	if(sanity_level > 75)
		modifier += 0.2

	// Low sanity impairs interaction
	if(sanity_level < 40)
		modifier -= 0.3

	// Insanity can have unpredictable effects
	if(insanity_level > 60)
		modifier += (rand(-20, 20) / 100) // Random modifier

	return modifier

// Sanity-based SCP containment effectiveness
/datum/sanity/proc/get_containment_effectiveness()
	var/effectiveness = 1.0

	// High sanity improves containment
	if(sanity_level > 80)
		effectiveness += 0.3
	else if(sanity_level > 60)
		effectiveness += 0.1

	// Low sanity impairs containment
	if(sanity_level < 40)
		effectiveness -= 0.4
	if(sanity_level < 20)
		effectiveness -= 0.3

	// Trauma impairs containment
	for(var/trauma in traumas)
		var/datum/trauma/T = trauma
		effectiveness -= T.severity * 0.01

	return max(0.1, effectiveness)

// Sanity-based SCP research effectiveness
/datum/sanity/proc/get_research_effectiveness()
	var/effectiveness = 1.0

	// Moderate sanity is best for research
	if(sanity_level > 70 && sanity_level < 90)
		effectiveness += 0.2
	else if(sanity_level > 50 && sanity_level < 70)
		effectiveness += 0.1

	// Low sanity impairs research
	if(sanity_level < 40)
		effectiveness -= 0.3
	if(sanity_level < 20)
		effectiveness -= 0.5

	// High insanity can provide unique insights
	if(insanity_level > 70)
		effectiveness += 0.1

	return max(0.1, effectiveness)

// Sanity-based SCP communication effectiveness
/datum/sanity/proc/get_communication_effectiveness()
	var/effectiveness = 1.0

	// High sanity improves communication
	if(sanity_level > 80)
		effectiveness += 0.2
	else if(sanity_level > 60)
		effectiveness += 0.1

	// Low sanity impairs communication
	if(sanity_level < 40)
		effectiveness -= 0.3
	if(sanity_level < 20)
		effectiveness -= 0.5

	// Insanity can make communication unpredictable
	if(insanity_level > 50)
		effectiveness += (rand(-30, 10) / 100)

	return max(0.1, effectiveness)

// Sanity-based SCP combat effectiveness
/datum/sanity/proc/get_combat_effectiveness()
	var/effectiveness = 1.0

	// Moderate sanity is best for combat
	if(sanity_level > 60 && sanity_level < 80)
		effectiveness += 0.1

	// Low sanity impairs combat
	if(sanity_level < 40)
		effectiveness -= 0.2
	if(sanity_level < 20)
		effectiveness -= 0.4

	// High insanity can provide unpredictable combat advantages
	if(insanity_level > 70)
		effectiveness += 0.1

	// Trauma impairs combat
	for(var/trauma in traumas)
		var/datum/trauma/T = trauma
		if(T.trauma_type == TRAUMA_VIOLENCE)
			effectiveness -= T.severity * 0.01

	return max(0.1, effectiveness)

// Sanity-based SCP medical effectiveness
/datum/sanity/proc/get_medical_effectiveness()
	var/effectiveness = 1.0

	// High sanity improves medical skills
	if(sanity_level > 80)
		effectiveness += 0.2
	else if(sanity_level > 60)
		effectiveness += 0.1

	// Low sanity impairs medical skills
	if(sanity_level < 40)
		effectiveness -= 0.3
	if(sanity_level < 20)
		effectiveness -= 0.5

	// Trauma can provide medical insights
	for(var/trauma in traumas)
		var/datum/trauma/T = trauma
		if(T.trauma_type == TRAUMA_PHYSICAL)
			effectiveness += 0.05

	return max(0.1, effectiveness)

// Sanity-based SCP engineering effectiveness
/datum/sanity/proc/get_engineering_effectiveness()
	var/effectiveness = 1.0

	// High sanity improves engineering
	if(sanity_level > 80)
		effectiveness += 0.2
	else if(sanity_level > 60)
		effectiveness += 0.1

	// Low sanity impairs engineering
	if(sanity_level < 40)
		effectiveness -= 0.3
	if(sanity_level < 20)
		effectiveness -= 0.5

	// Insanity can provide creative solutions
	if(insanity_level > 60)
		effectiveness += 0.05

	return max(0.1, effectiveness)

// Sanity-based SCP security effectiveness
/datum/sanity/proc/get_security_effectiveness()
	var/effectiveness = 1.0

	// Moderate sanity is best for security
	if(sanity_level > 70 && sanity_level < 90)
		effectiveness += 0.1

	// Low sanity impairs security
	if(sanity_level < 40)
		effectiveness -= 0.2
	if(sanity_level < 20)
		effectiveness -= 0.4

	// Paranoia can improve security awareness
	if(INSANITY_PARANOIA in insanity_effects)
		effectiveness += 0.1

	return max(0.1, effectiveness)

// Sanity-based SCP administrative effectiveness
/datum/sanity/proc/get_administrative_effectiveness()
	var/effectiveness = 1.0

	// High sanity improves administrative skills
	if(sanity_level > 80)
		effectiveness += 0.2
	else if(sanity_level > 60)
		effectiveness += 0.1

	// Low sanity impairs administrative skills
	if(sanity_level < 40)
		effectiveness -= 0.3
	if(sanity_level < 20)
		effectiveness -= 0.5

	// Insanity can make decisions unpredictable
	if(insanity_level > 50)
		effectiveness += (rand(-20, 10) / 100)

	return max(0.1, effectiveness)

// Sanity-based SCP scientific effectiveness
/datum/sanity/proc/get_scientific_effectiveness()
	var/effectiveness = 1.0

	// High sanity improves scientific skills
	if(sanity_level > 80)
		effectiveness += 0.2
	else if(sanity_level > 60)
		effectiveness += 0.1

	// Low sanity impairs scientific skills
	if(sanity_level < 40)
		effectiveness -= 0.3
	if(sanity_level < 20)
		effectiveness -= 0.5

	// Insanity can provide unique scientific insights
	if(insanity_level > 70)
		effectiveness += 0.1

	return max(0.1, effectiveness)

// Sanity-based SCP psychological effectiveness
/datum/sanity/proc/get_psychological_effectiveness()
	var/effectiveness = 1.0

	// High sanity improves psychological skills
	if(sanity_level > 80)
		effectiveness += 0.2
	else if(sanity_level > 60)
		effectiveness += 0.1

	// Low sanity impairs psychological skills
	if(sanity_level < 40)
		effectiveness -= 0.3
	if(sanity_level < 20)
		effectiveness -= 0.5

	// Personal trauma can provide psychological insights
	for(var/trauma in traumas)
		var/datum/trauma/T = trauma
		if(T.trauma_type == TRAUMA_PSYCHOLOGICAL)
			effectiveness += 0.05

	return max(0.1, effectiveness)

// SCP-073 Sanity Integration
/mob/living/scp/scp073/proc/affect_proximity_sanity()
	for(var/mob/living/carbon/human/H in range(5, src))
		if(H.stat == DEAD || !H.sanity)
			continue
		if(H.sanity)
			H.sanity.add_trauma(TRAUMA_PSYCHOLOGICAL, 3)
		if(prob(10))
			to_chat(H, "<span class='warning'>An unnatural decay clings to the air around you...</span>")

// SCP-076 Sanity Integration
/mob/living/scp/scp076/proc/affect_combat_sanity(mob/living/carbon/human/victim)
	if(!victim || !victim.sanity)
		return
	if(victim.sanity)
		victim.sanity.add_trauma(TRAUMA_VIOLENCE, 20)
		victim.sanity.add_trauma(TRAUMA_PSYCHOLOGICAL, 10)
	victim.sanity.hallucination_level = min(victim.sanity.hallucination_level + 15, victim.sanity.max_hallucination)

/mob/living/scp/scp076/proc/affect_rage_aura()
	if(current_state != "active")
		return
	for(var/mob/living/carbon/human/H in range(7, src))
		if(H.stat == DEAD || !H.sanity)
			continue
		if(H.sanity)
			H.sanity.add_trauma(TRAUMA_VIOLENCE, 2)
		if(prob(5))
			to_chat(H, "<span class='warning'>An overwhelming bloodlust fills your mind!</span>")

// SCP-105 Sanity Integration
/mob/living/scp/scp105/proc/affect_nearby_sanity()
	for(var/mob/living/carbon/human/H in range(3, src))
		if(H.stat == DEAD || !H.sanity)
			continue
		if(prob(8))
			H.sanity.hallucination_level = min(H.sanity.hallucination_level + 2, H.sanity.max_hallucination)

// SCP-408 Sanity Integration
/mob/living/scp/scp408/proc/affect_perception_sanity()
	if(swarm_state == "dormant")
		return
	for(var/mob/living/carbon/human/H in range(disruption_range, src))
		if(H.stat == DEAD || !H.sanity)
			continue
		var/intensity = 1
		if(swarm_state == "active")
			intensity = 3
		else if(swarm_state == "swarm")
			intensity = 5
		if(H.sanity)
			H.sanity.hallucination_level = min(H.sanity.hallucination_level + intensity, H.sanity.max_hallucination)
		if(prob(intensity * 2))
			H.sanity.add_trauma(TRAUMA_PSYCHOLOGICAL, 1)

// SCP-1128 Sanity Integration
/mob/living/scp/scp1128/proc/affect_water_sanity()
	for(var/ckey in aware_victims)
		var/mob/living/carbon/human/H = GLOB.directory[ckey]
		if(!H || H.stat == DEAD || !H.sanity)
			continue
		var/turf/T = get_turf(H)
		if(!T || !istype(T, /turf/open/water))
			continue
		if(H.sanity)
			H.sanity.add_trauma(TRAUMA_SCP_EXPOSURE, 5)
		H.sanity.hallucination_level = min(H.sanity.hallucination_level + 8, H.sanity.max_hallucination)
		if(prob(10))
			to_chat(H, "<span class='danger'>You feel something watching you from beneath the water!</span>")
