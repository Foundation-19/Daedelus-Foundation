/datum/pathogen/foundation/common_cold
	name = "Rhinovirus Infection"
	desc = "A common viral infection of the upper respiratory tract. Mild but highly contagious."
	agent = "Human rhinovirus"
	max_stages = 3
	spread_flags = PATHOGEN_SPREAD_AIRBORNE | PATHOGEN_SPREAD_CONTACT_SKIN
	spread_text = "Airborne"
	cure_text = "Rest and Spaceacillin"
	cures = list(/datum/reagent/medicine/spaceacillin)
	cure_chance = 8
	severity = PATHOGEN_SEVERITY_MINOR
	bsl_level = BSL_1
	transmission_types = list(PATHOGEN_TRANSMISSION_AIRBORNE, PATHOGEN_TRANSMISSION_CONTACT)
	contraction_chance_modifier = 1.2
	stage_prob = 3

/datum/pathogen/foundation/common_cold/on_process(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(DT_PROB(1, delta_time))
				affected_mob.emote("sneeze")
			if(DT_PROB(0.5, delta_time))
				affected_mob.emote("cough")
			if(DT_PROB(0.3, delta_time))
				to_chat(affected_mob, span_warning("Your throat feels scratchy."))
		if(3)
			if(DT_PROB(2, delta_time))
				affected_mob.emote("sneeze")
			if(DT_PROB(1, delta_time))
				affected_mob.emote("cough")
			if(DT_PROB(0.5, delta_time))
				to_chat(affected_mob, span_warning("Your nose is running."))
			if(DT_PROB(0.3, delta_time))
				affected_mob.stamina.adjust(-5)
			if(affected_mob.body_position == LYING_DOWN && DT_PROB(10, delta_time))
				to_chat(affected_mob, span_notice("You feel a bit better."))
				stage--

/datum/pathogen/foundation/norovirus
	name = "Norovirus Gastroenteritis"
	desc = "A highly contagious viral infection causing acute gastroenteritis. Spreads rapidly in confined spaces."
	agent = "Norwalk virus"
	max_stages = 4
	spread_flags = PATHOGEN_SPREAD_CONTACT_FLUIDS | PATHOGEN_SPREAD_CONTACT_SKIN | PATHOGEN_SPREAD_AIRBORNE
	spread_text = "Fluids and Contact"
	cure_text = "Hydration and Spaceacillin"
	cures = list(/datum/reagent/medicine/spaceacillin, /datum/reagent/water)
	cure_chance = 4
	pathogen_flags = PATHOGEN_CURABLE | PATHOGEN_RESIST_ON_CURE | PATHOGEN_NEED_ALL_CURES | PATHOGEN_REGRESS_TO_CURE
	severity = PATHOGEN_SEVERITY_MEDIUM
	bsl_level = BSL_2
	transmission_types = list(PATHOGEN_TRANSMISSION_CONTACT, PATHOGEN_TRANSMISSION_FOOD, PATHOGEN_TRANSMISSION_WATER)
	contraction_chance_modifier = 1.5
	stage_prob = 4

/datum/pathogen/foundation/norovirus/on_process(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(DT_PROB(0.5, delta_time))
				to_chat(affected_mob, span_warning("Your stomach churns unpleasantly."))
			if(DT_PROB(0.3, delta_time))
				affected_mob.emote("groan")
		if(3)
			if(DT_PROB(1, delta_time))
				affected_mob.vomit(10, FALSE)
			if(DT_PROB(0.8, delta_time))
				to_chat(affected_mob, span_danger("You feel severely nauseous!"))
				affected_mob.stamina.adjust(-10)
		if(4)
			if(DT_PROB(2, delta_time))
				affected_mob.vomit(20, TRUE)
			if(DT_PROB(1, delta_time))
				affected_mob.adjustToxLoss(3, FALSE)
			if(DT_PROB(1, delta_time))
				affected_mob.adjustToxLoss(2, FALSE)

/datum/pathogen/foundation/strep_throat
	name = "Streptococcal Pharyngitis"
	desc = "A bacterial infection of the throat and tonsils. Can lead to complications if untreated."
	agent = "Group A Streptococcus"
	max_stages = 3
	spread_flags = PATHOGEN_SPREAD_AIRBORNE | PATHOGEN_SPREAD_CONTACT_FLUIDS
	spread_text = "Airborne"
	cure_text = "Spaceacillin"
	cures = list(/datum/reagent/medicine/spaceacillin)
	cure_chance = 6
	severity = PATHOGEN_SEVERITY_MINOR
	bsl_level = BSL_2
	transmission_types = list(PATHOGEN_TRANSMISSION_AIRBORNE, PATHOGEN_TRANSMISSION_CONTACT)
	contraction_chance_modifier = 0.8

/datum/pathogen/foundation/strep_throat/on_process(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(DT_PROB(0.5, delta_time))
				to_chat(affected_mob, span_warning("Your throat is sore and swollen."))
			if(DT_PROB(0.3, delta_time))
				affected_mob.emote("cough")
		if(3)
			if(DT_PROB(1, delta_time))
				to_chat(affected_mob, span_danger("Your throat burns with pain!"))
			if(DT_PROB(0.5, delta_time))
				affected_mob.emote("cough")
			if(DT_PROB(0.3, delta_time))
				affected_mob.stamina.adjust(-5)
				affected_mob.adjust_bodytemperature(5)

/datum/pathogen/foundation/hepatitis_c
	name = "Hepatitis C"
	desc = "A bloodborne viral infection affecting the liver. Chronic cases can lead to cirrhosis."
	agent = "Hepatitis C virus"
	max_stages = 5
	spread_flags = PATHOGEN_SPREAD_BLOOD | PATHOGEN_SPREAD_CONTACT_FLUIDS
	spread_text = "Blood"
	cure_text = "Spaceacillin and Saline"
	cures = list(/datum/reagent/medicine/spaceacillin, /datum/reagent/medicine/saline_glucose)
	cure_chance = 3
	pathogen_flags = PATHOGEN_CURABLE | PATHOGEN_RESIST_ON_CURE | PATHOGEN_NEED_ALL_CURES | PATHOGEN_REGRESS_TO_CURE
	severity = PATHOGEN_SEVERITY_HARMFUL
	bsl_level = BSL_2
	transmission_types = list(PATHOGEN_TRANSMISSION_BLOOD)
	contraction_chance_modifier = 0.5
	stage_prob = 1.5

/datum/pathogen/foundation/hepatitis_c/on_process(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(DT_PROB(0.3, delta_time))
				to_chat(affected_mob, span_warning("You feel a dull ache in your abdomen."))
		if(3)
			if(DT_PROB(0.5, delta_time))
				to_chat(affected_mob, span_warning("Your skin feels itchy."))
			if(DT_PROB(0.3, delta_time))
				affected_mob.adjustToxLoss(1, FALSE)
		if(4)
			if(DT_PROB(0.5, delta_time))
				affected_mob.adjustToxLoss(2, FALSE)
			if(DT_PROB(0.2, delta_time))
				to_chat(affected_mob, span_danger("Your eyes look yellowish."))
		if(5)
			if(DT_PROB(0.8, delta_time))
				affected_mob.adjustToxLoss(3, FALSE, cause_of_death = "Hepatitis C liver failure")
			if(DT_PROB(0.3, delta_time))
				affected_mob.vomit(10, FALSE)
