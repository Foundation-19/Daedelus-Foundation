/datum/pathogen/foundation/anthrax
	name = "Anthrax"
	desc = "A lethal bacterial infection caused by Bacillus anthracis. Spores can survive extreme conditions for decades."
	agent = "Bacillus anthracis spores"
	max_stages = 5
	spread_flags = PATHOGEN_SPREAD_AIRBORNE | PATHOGEN_SPREAD_CONTACT_SKIN | PATHOGEN_SPREAD_BLOOD
	spread_text = "Airborne and Contact"
	cure_text = "Spaceacillin and Epinephrine"
	cures = list(/datum/reagent/medicine/spaceacillin, /datum/reagent/medicine/epinephrine)
	cure_chance = 2
	pathogen_flags = PATHOGEN_CURABLE | PATHOGEN_RESIST_ON_CURE | PATHOGEN_NEED_ALL_CURES | PATHOGEN_REGRESS_TO_CURE
	severity = PATHOGEN_SEVERITY_BIOHAZARD
	bsl_level = BSL_3
	transmission_types = list(PATHOGEN_TRANSMISSION_AIRBORNE, PATHOGEN_TRANSMISSION_CONTACT)
	contraction_chance_modifier = 0.6
	stage_prob = 2.5
	cross_scp_interactions = list("SCP-610" = "symbiotic_acceleration")

/datum/pathogen/foundation/anthrax/on_process(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(DT_PROB(0.5, delta_time))
				to_chat(affected_mob, span_warning("You develop a raised, itchy bump on your skin."))
			if(DT_PROB(0.3, delta_time))
				affected_mob.emote("cough")
		if(3)
			if(DT_PROB(0.8, delta_time))
				affected_mob.emote("cough")
			if(DT_PROB(0.5, delta_time))
				affected_mob.adjustOxyLoss(5)
			if(DT_PROB(0.3, delta_time))
				affected_mob.adjustToxLoss(2, FALSE)
		if(4)
			if(DT_PROB(1, delta_time))
				affected_mob.adjustOxyLoss(15)
			if(DT_PROB(0.8, delta_time))
				affected_mob.adjustToxLoss(5, FALSE)
			if(DT_PROB(0.5, delta_time))
				affected_mob.adjustBruteLoss(3)
			if(DT_PROB(0.3, delta_time))
				to_chat(affected_mob, span_userdanger("Black eschar forms on your skin!"))
		if(5)
			if(DT_PROB(2, delta_time))
				affected_mob.adjustOxyLoss(25)
			if(DT_PROB(1.5, delta_time))
				affected_mob.adjustToxLoss(8, FALSE, cause_of_death = "Anthrax toxemia")
			if(DT_PROB(1, delta_time))
				affected_mob.adjustBruteLoss(5)

/datum/pathogen/foundation/rabies
	name = "Rabies"
	desc = "A fatal viral encephalitis transmitted through bites. Once symptoms appear, it is almost universally fatal."
	agent = "Rabies lyssavirus"
	max_stages = 5
	spread_flags = PATHOGEN_SPREAD_BLOOD | PATHOGEN_SPREAD_CONTACT_FLUIDS
	spread_text = "Blood"
	cure_text = "Spaceacillin (early stage only)"
	cures = list(/datum/reagent/medicine/spaceacillin)
	cure_chance = 10
	severity = PATHOGEN_SEVERITY_BIOHAZARD
	bsl_level = BSL_3
	transmission_types = list(PATHOGEN_TRANSMISSION_BLOOD, PATHOGEN_TRANSMISSION_VECTOR)
	contraction_chance_modifier = 0.3
	stage_prob = 1
	cross_scp_interactions = list("SCP-049" = "targeted_by_049")

/datum/pathogen/foundation/rabies/on_process(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	if(stage >= 4)
		pathogen_flags &= ~PATHOGEN_CURABLE

	switch(stage)
		if(2)
			if(DT_PROB(0.3, delta_time))
				to_chat(affected_mob, span_warning("You feel a headache coming on."))
			if(DT_PROB(0.2, delta_time))
				affected_mob.stamina.adjust(-3)
		if(3)
			if(DT_PROB(0.5, delta_time))
				affected_mob.stamina.adjust(-8)
			if(DT_PROB(0.3, delta_time))
				to_chat(affected_mob, span_warning("You feel anxious and agitated."))
			if(DT_PROB(0.2, delta_time))
				affected_mob.set_confusion_if_lower(20 SECONDS)
		if(4)
			if(DT_PROB(0.8, delta_time))
				affected_mob.stamina.adjust(-15)
			if(DT_PROB(0.5, delta_time))
				affected_mob.set_confusion_if_lower(30 SECONDS)
			if(DT_PROB(0.3, delta_time))
				to_chat(affected_mob, span_userdanger("You feel terror and confusion overwhelming you!"))
			if(DT_PROB(0.2, delta_time))
				affected_mob.emote("scream")
		if(5)
			if(DT_PROB(1, delta_time))
				affected_mob.adjustOxyLoss(20)
			if(DT_PROB(0.8, delta_time))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3)
			if(DT_PROB(0.5, delta_time))
				affected_mob.Paralyze(50)
			if(DT_PROB(0.3, delta_time))
				affected_mob.emote("scream")
			if(DT_PROB(0.2, delta_time))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5)

/datum/pathogen/foundation/covid19
	name = "COVID-19"
	desc = "A novel coronavirus causing severe respiratory illness. Highly contagious through airborne transmission."
	agent = "SARS-CoV-2"
	max_stages = 5
	spread_flags = PATHOGEN_SPREAD_AIRBORNE | PATHOGEN_SPREAD_CONTACT_SKIN | PATHOGEN_SPREAD_CONTACT_FLUIDS
	spread_text = "Airborne"
	cure_text = "Spaceacillin and Saline"
	cures = list(/datum/reagent/medicine/spaceacillin, /datum/reagent/medicine/saline_glucose)
	cure_chance = 3
	pathogen_flags = PATHOGEN_CURABLE | PATHOGEN_RESIST_ON_CURE | PATHOGEN_NEED_ALL_CURES | PATHOGEN_REGRESS_TO_CURE
	severity = PATHOGEN_SEVERITY_HARMFUL
	bsl_level = BSL_3
	transmission_types = list(PATHOGEN_TRANSMISSION_AIRBORNE, PATHOGEN_TRANSMISSION_CONTACT)
	contraction_chance_modifier = 1.5
	stage_prob = 2

/datum/pathogen/foundation/covid19/on_process(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(DT_PROB(0.8, delta_time))
				affected_mob.emote("cough")
			if(DT_PROB(0.5, delta_time))
				affected_mob.emote("sneeze")
			if(DT_PROB(0.3, delta_time))
				to_chat(affected_mob, span_warning("You've lost your sense of taste."))
		if(3)
			if(DT_PROB(1, delta_time))
				affected_mob.emote("cough")
			if(DT_PROB(0.5, delta_time))
				affected_mob.adjustOxyLoss(5)
			if(DT_PROB(0.3, delta_time))
				affected_mob.stamina.adjust(-8)
			if(DT_PROB(0.2, delta_time))
				affected_mob.adjust_bodytemperature(5)
		if(4)
			if(DT_PROB(1.5, delta_time))
				affected_mob.adjustOxyLoss(15)
			if(DT_PROB(1, delta_time))
				affected_mob.emote("cough")
			if(DT_PROB(0.5, delta_time))
				affected_mob.stamina.adjust(-12)
			if(DT_PROB(0.3, delta_time))
				to_chat(affected_mob, span_danger("Your lungs burn with every breath!"))
		if(5)
			if(DT_PROB(2, delta_time))
				affected_mob.adjustOxyLoss(25)
			if(DT_PROB(1, delta_time))
				affected_mob.stamina.adjust(-20)
			if(DT_PROB(0.5, delta_time))
				affected_mob.adjustToxLoss(3, FALSE, cause_of_death = "COVID-19 respiratory failure")

/datum/pathogen/foundation/ebola
	name = "Ebola Hemorrhagic Fever"
	desc = "A devastating filovirus causing systemic hemorrhage. Extremely high mortality rate."
	agent = "Zaire ebolavirus"
	max_stages = 5
	spread_flags = PATHOGEN_SPREAD_BLOOD | PATHOGEN_SPREAD_CONTACT_FLUIDS | PATHOGEN_SPREAD_CONTACT_SKIN
	spread_text = "Blood and Fluids"
	cure_text = "SCP-500 or experimental cure"
	cures = list(/datum/reagent/medicine/spaceacillin)
	cure_chance = 1
	severity = PATHOGEN_SEVERITY_BIOHAZARD
	bsl_level = BSL_4
	transmission_types = list(PATHOGEN_TRANSMISSION_BLOOD, PATHOGEN_TRANSMISSION_CONTACT)
	contraction_chance_modifier = 0.5
	stage_prob = 3
	cross_scp_interactions = list("SCP-500" = "instant_cure")

/datum/pathogen/foundation/ebola/on_process(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(DT_PROB(0.5, delta_time))
				to_chat(affected_mob, span_warning("A sudden fever washes over you."))
				affected_mob.adjust_bodytemperature(15)
			if(DT_PROB(0.3, delta_time))
				affected_mob.stamina.adjust(-5)
		if(3)
			if(DT_PROB(0.8, delta_time))
				affected_mob.adjust_bodytemperature(20)
			if(DT_PROB(0.5, delta_time))
				affected_mob.adjustToxLoss(3, FALSE)
			if(DT_PROB(0.3, delta_time))
				affected_mob.emote("vomit")
		if(4)
			if(DT_PROB(1, delta_time))
				affected_mob.adjustToxLoss(5, FALSE)
			if(DT_PROB(0.8, delta_time))
				affected_mob.adjustBruteLoss(3)
			if(DT_PROB(0.5, delta_time))
				affected_mob.vomit(20, TRUE)
			if(DT_PROB(0.3, delta_time))
				to_chat(affected_mob, span_userdanger("Blood pours from your eyes and gums!"))
		if(5)
			if(DT_PROB(2, delta_time))
				affected_mob.adjustToxLoss(8, FALSE, cause_of_death = "Ebola hemorrhagic shock")
			if(DT_PROB(1.5, delta_time))
				affected_mob.adjustBruteLoss(5)
			if(DT_PROB(1, delta_time))
				affected_mob.vomit(30, TRUE)
			if(DT_PROB(0.5, delta_time))
				affected_mob.stamina.adjust(-25)

/datum/pathogen/foundation/marburg
	name = "Marburg Virus Disease"
	desc = "A filovirus closely related to Ebola. Causes severe hemorrhagic fever with high mortality."
	agent = "Marburg marburgvirus"
	max_stages = 5
	spread_flags = PATHOGEN_SPREAD_BLOOD | PATHOGEN_SPREAD_CONTACT_FLUIDS
	spread_text = "Blood and Fluids"
	cure_text = "SCP-500 or experimental cure"
	cures = list(/datum/reagent/medicine/spaceacillin)
	cure_chance = 1
	severity = PATHOGEN_SEVERITY_BIOHAZARD
	bsl_level = BSL_4
	transmission_types = list(PATHOGEN_TRANSMISSION_BLOOD, PATHOGEN_TRANSMISSION_CONTACT)
	contraction_chance_modifier = 0.4
	stage_prob = 2.5
	cross_scp_interactions = list("SCP-500" = "instant_cure")

/datum/pathogen/foundation/marburg/on_process(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(DT_PROB(0.5, delta_time))
				affected_mob.adjust_bodytemperature(12)
			if(DT_PROB(0.3, delta_time))
				to_chat(affected_mob, span_warning("Your muscles ache deeply."))
				affected_mob.stamina.adjust(-5)
		if(3)
			if(DT_PROB(0.8, delta_time))
				affected_mob.adjust_bodytemperature(18)
			if(DT_PROB(0.5, delta_time))
				affected_mob.adjustToxLoss(3, FALSE)
			if(DT_PROB(0.3, delta_time))
				affected_mob.vomit(10, FALSE)
		if(4)
			if(DT_PROB(1, delta_time))
				affected_mob.adjustToxLoss(5, FALSE)
			if(DT_PROB(0.8, delta_time))
				affected_mob.adjustBruteLoss(4)
			if(DT_PROB(0.5, delta_time))
				affected_mob.vomit(20, TRUE)
			if(DT_PROB(0.3, delta_time))
				to_chat(affected_mob, span_userdanger("A rash of purple spots covers your body!"))
		if(5)
			if(DT_PROB(2, delta_time))
				affected_mob.adjustToxLoss(10, FALSE, cause_of_death = "Marburg hemorrhagic shock")
			if(DT_PROB(1.5, delta_time))
				affected_mob.adjustBruteLoss(6)
			if(DT_PROB(1, delta_time))
				affected_mob.vomit(30, TRUE)

/datum/pathogen/foundation/smallpox
	name = "Smallpox"
	desc = "An eradicated variola virus weaponized by the Foundation. Causes characteristic pustular rash and high fever."
	agent = "Variola major"
	max_stages = 5
	spread_flags = PATHOGEN_SPREAD_AIRBORNE | PATHOGEN_SPREAD_CONTACT_SKIN | PATHOGEN_SPREAD_CONTACT_FLUIDS
	spread_text = "Airborne and Contact"
	cure_text = "Spaceacillin (high dose) and Dylovene"
	cures = list(/datum/reagent/medicine/spaceacillin, /datum/reagent/medicine/dylovene)
	cure_chance = 2
	pathogen_flags = PATHOGEN_CURABLE | PATHOGEN_RESIST_ON_CURE | PATHOGEN_NEED_ALL_CURES | PATHOGEN_REGRESS_TO_CURE
	severity = PATHOGEN_SEVERITY_BIOHAZARD
	bsl_level = BSL_4
	transmission_types = list(PATHOGEN_TRANSMISSION_AIRBORNE, PATHOGEN_TRANSMISSION_CONTACT)
	contraction_chance_modifier = 1.0
	stage_prob = 2
	cross_scp_interactions = list("SCP-016" = "triggers_sentient_mode")

/datum/pathogen/foundation/smallpox/on_process(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(DT_PROB(0.5, delta_time))
				affected_mob.adjust_bodytemperature(10)
			if(DT_PROB(0.3, delta_time))
				to_chat(affected_mob, span_warning("You feel feverish and weak."))
				affected_mob.stamina.adjust(-5)
		if(3)
			if(DT_PROB(0.8, delta_time))
				affected_mob.adjust_bodytemperature(15)
			if(DT_PROB(0.5, delta_time))
				to_chat(affected_mob, span_warning("Flat red spots appear on your skin."))
			if(DT_PROB(0.3, delta_time))
				affected_mob.adjustToxLoss(2, FALSE)
		if(4)
			if(DT_PROB(1, delta_time))
				affected_mob.adjustToxLoss(4, FALSE)
			if(DT_PROB(0.8, delta_time))
				affected_mob.adjustBruteLoss(2)
			if(DT_PROB(0.5, delta_time))
				to_chat(affected_mob, span_danger("Raised pustules cover your entire body!"))
			if(DT_PROB(0.3, delta_time))
				affected_mob.stamina.adjust(-10)
		if(5)
			if(DT_PROB(2, delta_time))
				affected_mob.adjustToxLoss(8, FALSE, cause_of_death = "Smallpox")
			if(DT_PROB(1.5, delta_time))
				affected_mob.adjustBruteLoss(4)
			if(DT_PROB(1, delta_time))
				affected_mob.vomit(15, TRUE)
			if(DT_PROB(0.5, delta_time))
				affected_mob.stamina.adjust(-20)

/datum/pathogen/foundation/lassa
	name = "Lassa Fever"
	desc = "An arenavirus endemic to West Africa. Often asymptomatic in early stages but can cause severe hemorrhagic fever."
	agent = "Lassa mammarenavirus"
	max_stages = 5
	spread_flags = PATHOGEN_SPREAD_AIRBORNE | PATHOGEN_SPREAD_CONTACT_FLUIDS
	spread_text = "Airborne and Fluids"
	cure_text = "Spaceacillin and Saline"
	cures = list(/datum/reagent/medicine/spaceacillin, /datum/reagent/medicine/saline_glucose)
	cure_chance = 3
	pathogen_flags = PATHOGEN_CURABLE | PATHOGEN_RESIST_ON_CURE | PATHOGEN_NEED_ALL_CURES | PATHOGEN_REGRESS_TO_CURE
	severity = PATHOGEN_SEVERITY_DANGEROUS
	bsl_level = BSL_4
	transmission_types = list(PATHOGEN_TRANSMISSION_AIRBORNE, PATHOGEN_TRANSMISSION_VECTOR)
	contraction_chance_modifier = 0.5
	stage_prob = 2
	cross_scp_interactions = list("SCP-500" = "instant_cure")

/datum/pathogen/foundation/lassa/on_process(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(DT_PROB(0.3, delta_time))
				to_chat(affected_mob, span_warning("A mild fever develops."))
				affected_mob.adjust_bodytemperature(8)
		if(3)
			if(DT_PROB(0.5, delta_time))
				affected_mob.adjust_bodytemperature(15)
			if(DT_PROB(0.3, delta_time))
				to_chat(affected_mob, span_warning("Your throat is sore."))
			if(DT_PROB(0.2, delta_time))
				affected_mob.stamina.adjust(-5)
		if(4)
			if(DT_PROB(0.8, delta_time))
				affected_mob.adjustToxLoss(4, FALSE)
			if(DT_PROB(0.5, delta_time))
				affected_mob.vomit(15, FALSE)
			if(DT_PROB(0.3, delta_time))
				to_chat(affected_mob, span_danger("You hear ringing in your ears."))
		if(5)
			if(DT_PROB(1.5, delta_time))
				affected_mob.adjustToxLoss(6, FALSE, cause_of_death = "Lassa fever")
			if(DT_PROB(1, delta_time))
				affected_mob.adjustBruteLoss(3)
			if(DT_PROB(0.5, delta_time))
				affected_mob.vomit(25, TRUE)
			if(DT_PROB(0.3, delta_time))
				affected_mob.stamina.adjust(-15)

/datum/pathogen/foundation/nipah
	name = "Nipah Virus Encephalitis"
	desc = "A zoonotic paramyxovirus causing severe brain inflammation. Transmitted from bats and pigs."
	agent = "Nipah henipavirus"
	max_stages = 5
	spread_flags = PATHOGEN_SPREAD_AIRBORNE | PATHOGEN_SPREAD_CONTACT_FLUIDS
	spread_text = "Airborne and Fluids"
	cure_text = "SCP-500 or experimental cure"
	cures = list(/datum/reagent/medicine/spaceacillin)
	cure_chance = 1
	severity = PATHOGEN_SEVERITY_BIOHAZARD
	bsl_level = BSL_4
	transmission_types = list(PATHOGEN_TRANSMISSION_AIRBORNE, PATHOGEN_TRANSMISSION_VECTOR)
	contraction_chance_modifier = 0.3
	stage_prob = 2
	cross_scp_interactions = list("SCP-500" = "instant_cure")

/datum/pathogen/foundation/nipah/on_process(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(DT_PROB(0.3, delta_time))
				to_chat(affected_mob, span_warning("Your head throbs with pain."))
			if(DT_PROB(0.2, delta_time))
				affected_mob.stamina.adjust(-5)
		if(3)
			if(DT_PROB(0.5, delta_time))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2)
			if(DT_PROB(0.3, delta_time))
				affected_mob.set_confusion_if_lower(20 SECONDS)
			if(DT_PROB(0.2, delta_time))
				affected_mob.emote("cough")
		if(4)
			if(DT_PROB(0.8, delta_time))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 4)
			if(DT_PROB(0.5, delta_time))
				affected_mob.set_confusion_if_lower(40 SECONDS)
			if(DT_PROB(0.3, delta_time))
				affected_mob.emote("twitch")
			if(DT_PROB(0.2, delta_time))
				to_chat(affected_mob, span_userdanger("Your mind feels like it's on fire!"))
		if(5)
			if(DT_PROB(1.5, delta_time))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 8)
			if(DT_PROB(1, delta_time))
				affected_mob.Paralyze(50)
			if(DT_PROB(0.5, delta_time))
				affected_mob.emote("scream")
			if(DT_PROB(0.3, delta_time))
				affected_mob.stamina.adjust(-30)
