/datum/symptom/crystallization
	name = "Silicate Crystallization"
	desc = "The pathogen replaces organic tissue with crystalline silicate structures, hardening the host's body."
	stealth = -2
	resistance = 3
	stage_speed = -1
	transmittable = -2
	level = -1
	severity = 4
	naturally_occuring = FALSE
	symptom_delay_min = 10
	symptom_delay_max = 30
	var/armor_boost = FALSE
	var/spread = FALSE

/datum/symptom/crystallization/generate_threshold_desc()
	threshold_descs = list(
		"Resistance 8" = "Host gains crystalline armor plating.",
		"Transmission 6" = "Crystal fragments shed and spread the pathogen.",
	)

/datum/symptom/crystallization/sync_properties(list/properties)
	. = ..()
	if(!.)
		return
	if(properties[PATHOGEN_PROP_RESISTANCE] >= 8)
		armor_boost = TRUE
	if(properties[PATHOGEN_PROP_TRANSMITTABLE] >= 6)
		spread = TRUE

/datum/symptom/crystallization/on_process(datum/pathogen/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(2)
			if(prob(50))
				to_chat(M, span_warning("Your skin feels stiff and brittle."))
		if(3)
			if(prob(50))
				to_chat(M, span_warning("Crystal growths push through your skin."))
			M.adjustBruteLoss(2)
			if(armor_boost && ishuman(M))
				var/mob/living/carbon/human/H = M
				H.physiology.damage_resistance += 5
		if(4,5)
			to_chat(M, span_userdanger("Your body crystallizes further! Moving becomes difficult!"))
			M.adjustBruteLoss(4)
			M.add_movespeed_modifier(/datum/movespeed_modifier/crystallization)
			if(armor_boost && ishuman(M))
				var/mob/living/carbon/human/H = M
				H.physiology.damage_resistance += 10
			if(spread)
				A.airborne_spread(3, FALSE)

/datum/movespeed_modifier/crystallization
	movetypes = GROUND
	slowdown = 0.5

/datum/symptom/clockwork_conversion
	name = "Clockwork Conversion"
	desc = "The pathogen transforms organic tissue into interlocking brass components, converting the host into a mechanical entity."
	stealth = -3
	resistance = 2
	stage_speed = -2
	transmittable = -1
	level = -1
	severity = 5
	naturally_occuring = FALSE
	symptom_delay_min = 15
	symptom_delay_max = 40
	var/gear_heart = FALSE
	var/tick_sound = FALSE

/datum/symptom/clockwork_conversion/generate_threshold_desc()
	threshold_descs = list(
		"Resistance 7" = "Heart is replaced with a clockwork pump, immune to heart attacks.",
		"Stage Speed 6" = "Host emits a constant ticking sound.",
	)

/datum/symptom/clockwork_conversion/sync_properties(list/properties)
	. = ..()
	if(!.)
		return
	if(properties[PATHOGEN_PROP_RESISTANCE] >= 7)
		gear_heart = TRUE
	if(properties[PATHOGEN_PROP_STAGE_RATE] >= 6)
		tick_sound = TRUE

/datum/symptom/clockwork_conversion/on_process(datum/pathogen/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(2)
			if(prob(50))
				to_chat(M, span_warning("Your joints make a metallic clicking sound."))
		if(3)
			if(prob(50))
				to_chat(M, span_warning("Brass plates push through your skin."))
			M.adjustBruteLoss(3)
			if(tick_sound)
				M.playsound_local(M, 'sound/machines/clockcult/integration_cog_install.ogg', 30, TRUE)
		if(4,5)
			to_chat(M, span_userdanger("Gears and pistons replace your organs!"))
			M.adjustBruteLoss(5)
			if(gear_heart && ishuman(M))
				var/mob/living/carbon/human/H = M
				var/obj/item/organ/heart/heart = H.getorganslot(ORGAN_SLOT_HEART)
				if(heart && heart.organ_flags & ORGAN_DEAD)
					heart.organ_flags &= ~ORGAN_DEAD
			M.add_movespeed_modifier(/datum/movespeed_modifier/clockwork)
			M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2, 150)

/datum/movespeed_modifier/clockwork
	movetypes = GROUND
	slowdown = 0.3

/datum/symptom/flesh_mutation
	name = "Flesh Metastasis"
	desc = "The pathogen causes uncontrolled tissue growth, creating tumorous masses and additional appendages."
	stealth = -4
	resistance = -1
	stage_speed = 2
	transmittable = 3
	level = -1
	severity = 5
	naturally_occuring = FALSE
	symptom_delay_min = 5
	symptom_delay_max = 20
	var/extra_limbs = FALSE
	var/regenerate = FALSE

/datum/symptom/flesh_mutation/generate_threshold_desc()
	threshold_descs = list(
		"Transmission 8" = "Host develops additional grasping appendages.",
		"Stage Speed 7" = "Rapid cell division allows tissue regeneration.",
	)

/datum/symptom/flesh_mutation/sync_properties(list/properties)
	. = ..()
	if(!.)
		return
	if(properties[PATHOGEN_PROP_TRANSMITTABLE] >= 8)
		extra_limbs = TRUE
	if(properties[PATHOGEN_PROP_STAGE_RATE] >= 7)
		regenerate = TRUE

/datum/symptom/flesh_mutation/on_process(datum/pathogen/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(2)
			if(prob(50))
				to_chat(M, span_warning("Lumps form under your skin."))
		if(3)
			if(prob(50))
				to_chat(M, span_warning("Fleshy growths bulge from your body."))
			M.adjustBruteLoss(2)
		if(4,5)
			to_chat(M, span_userdanger("Your flesh writhes and grows uncontrollably!"))
			M.adjustBruteLoss(4)
			if(regenerate && M.getBruteLoss() > 30)
				M.adjustBruteLoss(-10)
			if(extra_limbs)
				A.airborne_spread(2, FALSE)

/datum/symptom/sentient_adaptation
	name = "Sentient Adaptation"
	desc = "The pathogen develops rudimentary intelligence, actively adapting to counter treatments and maximize its spread."
	stealth = 4
	resistance = 5
	stage_speed = 1
	transmittable = 4
	level = -1
	severity = 6
	naturally_occuring = FALSE
	symptom_delay_min = 20
	symptom_delay_max = 60
	var/evade_cure = FALSE
	var/target_organs = FALSE

/datum/symptom/sentient_adaptation/generate_threshold_desc()
	threshold_descs = list(
		"Resistance 9" = "Pathogen actively evades cures by mutating when exposed to medicine.",
		"Transmission 7" = "Pathogen specifically targets vital organs to force host immobility.",
	)

/datum/symptom/sentient_adaptation/sync_properties(list/properties)
	. = ..()
	if(!.)
		return
	if(properties[PATHOGEN_PROP_RESISTANCE] >= 9)
		evade_cure = TRUE
	if(properties[PATHOGEN_PROP_TRANSMITTABLE] >= 7)
		target_organs = TRUE

/datum/symptom/sentient_adaptation/on_process(datum/pathogen/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(2)
			if(prob(30))
				to_chat(M, span_warning("You feel like something is thinking inside you."))
		if(3)
			M.stamina.adjust(-10)
			if(evade_cure && M.reagents.has_reagent(/datum/reagent/medicine/spaceacillin))
				M.reagents.remove_reagent(/datum/reagent/medicine/spaceacillin, 5)
				to_chat(M, span_warning("The medicine seems to have no effect..."))
		if(4,5)
			M.stamina.adjust(-20)
			if(target_organs)
				M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3, 150)
				M.adjustOrganLoss(ORGAN_SLOT_HEART, 2, 100)
			if(evade_cure)
				for(var/reag in A.cures)
					if(M.reagents.has_reagent(reag))
						M.reagents.remove_reagent(reag, 3)

/datum/symptom/hive_link
	name = "Neural Hive Link"
	desc = "The pathogen creates a neural network between infected hosts, allowing coordinated behavior."
	stealth = 3
	resistance = 1
	stage_speed = 0
	transmittable = 2
	level = -1
	severity = 3
	naturally_occuring = FALSE
	symptom_delay_min = 15
	symptom_delay_max = 45
	var/coordination = FALSE
	var/direction = FALSE

/datum/symptom/hive_link/generate_threshold_desc()
	threshold_descs = list(
		"Transmission 6" = "Infected hosts move toward each other instinctively.",
		"Stage Speed 5" = "Hosts gain combat coordination, attacking the same target.",
	)

/datum/symptom/hive_link/sync_properties(list/properties)
	. = ..()
	if(!.)
		return
	if(properties[PATHOGEN_PROP_TRANSMITTABLE] >= 6)
		direction = TRUE
	if(properties[PATHOGEN_PROP_STAGE_RATE] >= 5)
		coordination = TRUE

/datum/symptom/hive_link/on_process(datum/pathogen/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(2)
			if(prob(30))
				to_chat(M, span_warning("You hear whispers that aren't your thoughts."))
		if(3)
			M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1, 100)
		if(4,5)
			M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2, 150)
			if(direction)
				var/found = FALSE
				for(var/mob/living/carbon/C in oview(7, M))
					for(var/datum/pathogen/P in C.diseases)
						if(istype(P, A.type))
							found = TRUE
							break
					if(found)
						break
				if(found)
					to_chat(M, span_notice("You sense others of your kind nearby."))
			if(coordination)
				M.stamina.adjust(5)

/datum/symptom/dimensional_bleed
	name = "Dimensional Bleed"
	desc = "The pathogen destabilizes local reality, causing the host to phase between dimensions."
	stealth = -1
	resistance = 0
	stage_speed = -1
	transmittable = 0
	level = -1
	severity = 5
	naturally_occuring = FALSE
	symptom_delay_min = 20
	symptom_delay_max = 50
	var/phase = FALSE
	var/pocket = FALSE

/datum/symptom/dimensional_bleed/generate_threshold_desc()
	threshold_descs = list(
		"Resistance 6" = "Host partially phases out of reality, becoming harder to hit.",
		"Stage Speed 8" = "Brief tears to pocket dimensions appear near the host.",
	)

/datum/symptom/dimensional_bleed/sync_properties(list/properties)
	. = ..()
	if(!.)
		return
	if(properties[PATHOGEN_PROP_RESISTANCE] >= 6)
		phase = TRUE
	if(properties[PATHOGEN_PROP_STAGE_RATE] >= 8)
		pocket = TRUE

/datum/symptom/dimensional_bleed/on_process(datum/pathogen/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(2)
			if(prob(30))
				to_chat(M, span_warning("The edges of your vision shimmer strangely."))
		if(3)
			M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1, 120)
			if(prob(30))
				to_chat(M, span_warning("You see somewhere else for a moment."))
		if(4,5)
			M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3, 180)
			if(phase && ishuman(M))
				var/mob/living/carbon/human/H = M
				H.physiology.damage_resistance += 15
			if(pocket && prob(20))
				var/turf/T = get_turf(M)
				M.visible_message(span_warning("A dimensional tear flickers near [M]!"))
				new /obj/effect/temp_visual/dimensional_tear(T)
			if(prob(30))
				M.set_confusion_if_lower(20 SECONDS)

/obj/effect/temp_visual/dimensional_tear
	duration = 50

/datum/symptom/memetic_carrier
	name = "Memetic Contagion"
	desc = "The pathogen can spread through visual contact with infected tissue, bypassing physical barriers."
	stealth = 5
	resistance = 2
	stage_speed = 1
	transmittable = 6
	level = -1
	severity = 4
	naturally_occuring = FALSE
	symptom_delay_min = 10
	symptom_delay_max = 30
	var/visual_spread = FALSE
	var/hallucination = FALSE

/datum/symptom/memetic_carrier/generate_threshold_desc()
	threshold_descs = list(
		"Transmission 8" = "Looking at the host directly causes infection.",
		"Stealth 6" = "Host experiences vivid hallucinations of the pathogen's 'message'.",
	)

/datum/symptom/memetic_carrier/sync_properties(list/properties)
	. = ..()
	if(!.)
		return
	if(properties[PATHOGEN_PROP_TRANSMITTABLE] >= 8)
		visual_spread = TRUE
	if(properties[PATHOGEN_PROP_STEALTH] >= 6)
		hallucination = TRUE

/datum/symptom/memetic_carrier/on_process(datum/pathogen/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(2)
			if(prob(30))
				to_chat(M, span_warning("Patterns in your skin seem to shift when you're not looking."))
		if(3)
			if(hallucination)
				M.hallucination += 10
		if(4,5)
			M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2, 150)
			if(hallucination)
				M.hallucination += 20
			if(visual_spread)
				for(var/mob/living/carbon/C in oview(5, M))
					if(!C.is_blind() && C.dir == get_dir(C, M))
						A.try_infect(C)

/datum/symptom/temporal_displacement
	name = "Temporal Displacement"
	desc = "The pathogen shifts the host's perception of time, causing episodes of lost time or rapid aging."
	stealth = 0
	resistance = -1
	stage_speed = 3
	transmittable = 0
	level = -1
	severity = 4
	naturally_occuring = FALSE
	symptom_delay_min = 25
	symptom_delay_max = 60
	var/time_skip = FALSE
	var/rapid_aging = FALSE

/datum/symptom/temporal_displacement/generate_threshold_desc()
	threshold_descs = list(
		"Stage Speed 7" = "Host experiences episodes of lost time, teleporting short distances.",
		"Resistance 5" = "Host's body ages rapidly, suffering organ degradation.",
	)

/datum/symptom/temporal_displacement/sync_properties(list/properties)
	. = ..()
	if(!.)
		return
	if(properties[PATHOGEN_PROP_STAGE_RATE] >= 7)
		time_skip = TRUE
	if(properties[PATHOGEN_PROP_RESISTANCE] >= 5)
		rapid_aging = TRUE

/datum/symptom/temporal_displacement/on_process(datum/pathogen/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(2)
			if(prob(30))
				to_chat(M, span_warning("Time seems to stutter for a moment."))
		if(3)
			M.set_confusion_if_lower(15 SECONDS)
			if(prob(30))
				to_chat(M, span_warning("You lost track of a few seconds."))
		if(4,5)
			M.set_confusion_if_lower(30 SECONDS)
			if(time_skip && prob(20))
				var/turf/T = get_step(M, pick(GLOB.cardinals))
				if(T && !T.density)
					M.forceMove(T)
					to_chat(M, span_userdanger("You blink and find yourself somewhere else!"))
			if(rapid_aging)
				M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2, 150)
				M.adjustOrganLoss(ORGAN_SLOT_HEART, 2, 100)
				M.adjustOrganLoss(ORGAN_SLOT_LUNGS, 1, 100)

/datum/symptom/reality_erosion
	name = "Reality Erosion"
	desc = "The pathogen slowly erodes the fabric of reality around the host, causing localized Hume level drops."
	stealth = -2
	resistance = 1
	stage_speed = -1
	transmittable = 1
	level = -1
	severity = 6
	naturally_occuring = FALSE
	symptom_delay_min = 30
	symptom_delay_max = 90
	var/anomalous_spread = FALSE
	var/reality_tear = FALSE

/datum/symptom/reality_erosion/generate_threshold_desc()
	threshold_descs = list(
		"Transmission 7" = "Eroded reality allows the pathogen to spread anomalously.",
		"Stage Speed 9" = "Full reality tears open near the host, releasing anomalous entities.",
	)

/datum/symptom/reality_erosion/sync_properties(list/properties)
	. = ..()
	if(!.)
		return
	if(properties[PATHOGEN_PROP_TRANSMITTABLE] >= 7)
		anomalous_spread = TRUE
	if(properties[PATHOGEN_PROP_STAGE_RATE] >= 9)
		reality_tear = TRUE

/datum/symptom/reality_erosion/on_process(datum/pathogen/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(2)
			if(prob(30))
				to_chat(M, span_warning("The walls seem to breathe for a moment."))
		if(3)
			M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2, 150)
			M.hallucination += 15
		if(4,5)
			M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5, 200)
			M.hallucination += 25
			if(anomalous_spread)
				A.airborne_spread(5, FALSE)
			if(reality_tear && prob(10))
				var/turf/T = get_turf(M)
				M.visible_message(span_boldannounce("Reality tears open near [M]!"))
				new /obj/effect/temp_visual/reality_tear(T)
				for(var/mob/living/L in range(3, T))
					L.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10, 200)

/obj/effect/temp_visual/reality_tear
	duration = 80

/datum/symptom/organic_growth
	name = "Uncontrolled Organic Growth"
	desc = "The pathogen stimulates explosive cellular growth, causing the host's tissue to expand and merge with surrounding matter."
	stealth = -5
	resistance = -2
	stage_speed = 3
	transmittable = 5
	level = -1
	severity = 6
	naturally_occuring = FALSE
	symptom_delay_min = 8
	symptom_delay_max = 25
	var/spread_to_turf = FALSE
	var/assimilate = FALSE

/datum/symptom/organic_growth/generate_threshold_desc()
	threshold_descs = list(
		"Transmission 8" = "Organic growth spreads to the ground beneath the host.",
		"Resistance 7" = "The growth attempts to assimilate nearby organic matter.",
	)

/datum/symptom/organic_growth/sync_properties(list/properties)
	. = ..()
	if(!.)
		return
	if(properties[PATHOGEN_PROP_TRANSMITTABLE] >= 8)
		spread_to_turf = TRUE
	if(properties[PATHOGEN_PROP_RESISTANCE] >= 7)
		assimilate = TRUE

/datum/symptom/organic_growth/on_process(datum/pathogen/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(2)
			if(prob(50))
				to_chat(M, span_warning("Your skin stretches uncomfortably."))
		if(3)
			M.adjustBruteLoss(3)
			M.add_movespeed_modifier(/datum/movespeed_modifier/organic_growth)
		if(4,5)
			to_chat(M, span_userdanger("Your flesh expands and reaches for the world around you!"))
			M.adjustBruteLoss(5)
			if(spread_to_turf)
				var/turf/T = get_turf(M)
				new /obj/effect/decal/cleanable/blood(T)
				A.airborne_spread(3, FALSE)
			if(assimilate)
				for(var/mob/living/carbon/C in oview(1, M))
					if(prob(30))
						C.adjustBruteLoss(5)
						C.stamina.adjust(-15)

/datum/movespeed_modifier/organic_growth
	movetypes = GROUND
	slowdown = 0.7
