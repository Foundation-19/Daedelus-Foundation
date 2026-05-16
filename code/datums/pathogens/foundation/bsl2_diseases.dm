/datum/pathogen/foundation/mrsa
	name = "MRSA Infection"
	desc = "Methicillin-resistant Staphylococcus aureus. A dangerous antibiotic-resistant bacterial infection."
	agent = "MRSA bacterium"
	max_stages = 4
	spread_flags = PATHOGEN_SPREAD_CONTACT_SKIN | PATHOGEN_SPREAD_CONTACT_FLUIDS
	spread_text = "On contact"
	cure_text = "Diphenhydramine and Spaceacillin"
	cures = list(/datum/reagent/medicine/diphenhydramine, /datum/reagent/medicine/spaceacillin)
	cure_chance = 3
	pathogen_flags = PATHOGEN_CURABLE | PATHOGEN_RESIST_ON_CURE | PATHOGEN_NEED_ALL_CURES | PATHOGEN_REGRESS_TO_CURE
	severity = PATHOGEN_SEVERITY_HARMFUL
	bsl_level = BSL_2
	transmission_types = list(PATHOGEN_TRANSMISSION_CONTACT, PATHOGEN_TRANSMISSION_BLOOD)
	contraction_chance_modifier = 0.7
	stage_prob = 2.5
	cross_scp_interactions = list("SCP-217" = "rapid_gear_conversion")

/datum/pathogen/foundation/mrsa/on_process(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(DT_PROB(0.5, delta_time))
				to_chat(affected_mob, span_warning("A painful boil forms on your skin."))
			if(DT_PROB(0.3, delta_time))
				affected_mob.adjustBruteLoss(1)
		if(3)
			if(DT_PROB(0.8, delta_time))
				affected_mob.adjustBruteLoss(2)
			if(DT_PROB(0.5, delta_time))
				to_chat(affected_mob, span_danger("Pus-filled sores spread across your skin!"))
			if(DT_PROB(0.3, delta_time))
				affected_mob.stamina.adjust(-5)
		if(4)
			if(DT_PROB(1, delta_time))
				affected_mob.adjustBruteLoss(3)
			if(DT_PROB(0.5, delta_time))
				affected_mob.adjustToxLoss(2, FALSE)
			if(DT_PROB(0.3, delta_time))
				affected_mob.emote("groan")

/datum/pathogen/foundation/tuberculosis
	name = "Tuberculosis"
	desc = "A serious bacterial infection primarily affecting the lungs. Spreads through prolonged airborne exposure."
	agent = "Mycobacterium tuberculosis"
	max_stages = 5
	spread_flags = PATHOGEN_SPREAD_AIRBORNE | PATHOGEN_SPREAD_CONTACT_FLUIDS
	spread_text = "Airborne"
	cure_text = "Spaceacillin and Ephedrine"
	cures = list(/datum/reagent/medicine/spaceacillin, /datum/reagent/medicine/ephedrine)
	cure_chance = 2
	pathogen_flags = PATHOGEN_CURABLE | PATHOGEN_RESIST_ON_CURE | PATHOGEN_NEED_ALL_CURES | PATHOGEN_REGRESS_TO_CURE
	severity = PATHOGEN_SEVERITY_DANGEROUS
	bsl_level = BSL_3
	transmission_types = list(PATHOGEN_TRANSMISSION_AIRBORNE)
	contraction_chance_modifier = 0.4
	stage_prob = 1.5
	cross_scp_interactions = list("SCP-049" = "targeted_by_049")

/datum/pathogen/foundation/tuberculosis/on_process(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(DT_PROB(0.5, delta_time))
				affected_mob.emote("cough")
			if(DT_PROB(0.3, delta_time))
				to_chat(affected_mob, span_warning("Your chest feels tight."))
		if(3)
			if(DT_PROB(1, delta_time))
				affected_mob.emote("cough")
			if(DT_PROB(0.5, delta_time))
				affected_mob.adjustOxyLoss(5)
			if(DT_PROB(0.3, delta_time))
				affected_mob.stamina.adjust(-5)
		if(4)
			if(DT_PROB(1.5, delta_time))
				affected_mob.emote("cough")
			if(DT_PROB(1, delta_time))
				affected_mob.adjustOxyLoss(10)
			if(DT_PROB(0.5, delta_time))
				affected_mob.adjustBruteLoss(2)
			if(DT_PROB(0.3, delta_time))
				to_chat(affected_mob, span_danger("You cough up blood!"))
		if(5)
			if(DT_PROB(2, delta_time))
				affected_mob.adjustOxyLoss(15)
			if(DT_PROB(1, delta_time))
				affected_mob.adjustBruteLoss(3)
			if(DT_PROB(0.5, delta_time))
				affected_mob.stamina.adjust(-10)
			if(affected_mob.body_position == LYING_DOWN && DT_PROB(3, delta_time))
				to_chat(affected_mob, span_notice("Your breathing eases slightly."))
				stage--

/datum/pathogen/foundation/pneumonia
	name = "Bacterial Pneumonia"
	desc = "A severe lung infection causing fluid buildup. Can be fatal without treatment."
	agent = "Streptococcus pneumoniae"
	max_stages = 4
	spread_flags = PATHOGEN_SPREAD_AIRBORNE | PATHOGEN_SPREAD_CONTACT_FLUIDS
	spread_text = "Airborne"
	cure_text = "Spaceacillin and Saline"
	cures = list(/datum/reagent/medicine/spaceacillin, /datum/reagent/medicine/saline_glucose)
	cure_chance = 3
	pathogen_flags = PATHOGEN_CURABLE | PATHOGEN_RESIST_ON_CURE | PATHOGEN_NEED_ALL_CURES | PATHOGEN_REGRESS_TO_CURE
	severity = PATHOGEN_SEVERITY_DANGEROUS
	bsl_level = BSL_2
	transmission_types = list(PATHOGEN_TRANSMISSION_AIRBORNE)
	contraction_chance_modifier = 0.6
	stage_prob = 2

/datum/pathogen/foundation/pneumonia/on_process(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(DT_PROB(0.5, delta_time))
				affected_mob.emote("cough")
			if(DT_PROB(0.3, delta_time))
				to_chat(affected_mob, span_warning("It hurts to breathe deeply."))
		if(3)
			if(DT_PROB(1, delta_time))
				affected_mob.adjustOxyLoss(8)
			if(DT_PROB(0.8, delta_time))
				affected_mob.emote("cough")
			if(DT_PROB(0.5, delta_time))
				affected_mob.stamina.adjust(-8)
		if(4)
			if(DT_PROB(1.5, delta_time))
				affected_mob.adjustOxyLoss(15)
			if(DT_PROB(1, delta_time))
				affected_mob.emote("cough")
			if(DT_PROB(0.8, delta_time))
				affected_mob.stamina.adjust(-12)
			if(DT_PROB(0.3, delta_time))
				to_chat(affected_mob, span_userdanger("You can barely breathe!"))

/datum/pathogen/foundation/malaria
	name = "Malaria"
	desc = "A mosquito-borne parasitic disease causing cyclical fevers and chills. Endemic in tropical regions."
	agent = "Plasmodium falciparum"
	max_stages = 5
	spread_flags = PATHOGEN_SPREAD_SPECIAL
	spread_text = "Vector"
	cure_text = "Quinine and Spaceacillin"
	cures = list(/datum/reagent/medicine/spaceacillin)
	cure_chance = 4
	severity = PATHOGEN_SEVERITY_DANGEROUS
	bsl_level = BSL_2
	transmission_types = list(PATHOGEN_TRANSMISSION_VECTOR)
	contraction_chance_modifier = 0.3
	stage_prob = 2

/datum/pathogen/foundation/malaria/on_process(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	var/fever_cycle = (world.time % 600) < 300

	switch(stage)
		if(2)
			if(DT_PROB(0.5, delta_time))
				to_chat(affected_mob, span_warning("You feel cold and shiver uncontrollably."))
			if(DT_PROB(0.3, delta_time))
				affected_mob.stamina.adjust(-5)
		if(3)
			if(fever_cycle)
				if(DT_PROB(0.8, delta_time))
					affected_mob.adjust_bodytemperature(10)
					to_chat(affected_mob, span_warning("You're burning up!"))
			else
				if(DT_PROB(0.8, delta_time))
					affected_mob.adjust_bodytemperature(-10)
					to_chat(affected_mob, span_warning("You're freezing cold!"))
			if(DT_PROB(0.5, delta_time))
				affected_mob.adjustToxLoss(2, FALSE)
		if(4)
			if(DT_PROB(1, delta_time))
				affected_mob.adjustToxLoss(3, FALSE)
			if(DT_PROB(0.8, delta_time))
				affected_mob.stamina.adjust(-10)
			if(DT_PROB(0.5, delta_time))
				affected_mob.emote("shiver")
		if(5)
			if(DT_PROB(1.5, delta_time))
				affected_mob.adjustToxLoss(5, FALSE, cause_of_death = "Cerebral malaria")
			if(DT_PROB(1, delta_time))
				affected_mob.adjustOxyLoss(10)
			if(DT_PROB(0.5, delta_time))
				affected_mob.vomit(10, FALSE)

/datum/pathogen/foundation/dengue
	name = "Dengue Fever"
	desc = "A mosquito-borne viral infection causing severe flu-like symptoms. Can progress to hemorrhagic fever."
	agent = "Dengue virus"
	max_stages = 4
	spread_flags = PATHOGEN_SPREAD_SPECIAL
	spread_text = "Vector"
	cure_text = "Saline and Spaceacillin"
	cures = list(/datum/reagent/medicine/saline_glucose, /datum/reagent/medicine/spaceacillin)
	cure_chance = 3
	pathogen_flags = PATHOGEN_CURABLE | PATHOGEN_RESIST_ON_CURE | PATHOGEN_NEED_ALL_CURES | PATHOGEN_REGRESS_TO_CURE
	severity = PATHOGEN_SEVERITY_HARMFUL
	bsl_level = BSL_2
	transmission_types = list(PATHOGEN_TRANSMISSION_VECTOR)
	contraction_chance_modifier = 0.3
	stage_prob = 3

/datum/pathogen/foundation/dengue/on_process(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(DT_PROB(0.5, delta_time))
				affected_mob.adjust_bodytemperature(8)
			if(DT_PROB(0.3, delta_time))
				to_chat(affected_mob, span_warning("Your joints ache terribly."))
		if(3)
			if(DT_PROB(0.8, delta_time))
				affected_mob.adjust_bodytemperature(12)
			if(DT_PROB(0.5, delta_time))
				affected_mob.stamina.adjust(-8)
			if(DT_PROB(0.3, delta_time))
				to_chat(affected_mob, span_warning("A rash spreads across your skin."))
		if(4)
			if(DT_PROB(1, delta_time))
				affected_mob.adjustToxLoss(3, FALSE)
			if(DT_PROB(0.8, delta_time))
				affected_mob.adjustBruteLoss(2)
			if(DT_PROB(0.5, delta_time))
				to_chat(affected_mob, span_userdanger("Blood seeps from your gums and nose!"))
			if(DT_PROB(0.3, delta_time))
				affected_mob.stamina.adjust(-15)
