/datum/pathogen/foundation/scp008
	name = "SCP-008"
	desc = "The Zombie Plague. A prion of unknown origin that reanimates dead tissue. 100% lethal without SCP-500 intervention."
	agent = "SCP-008 prion"
	max_stages = 5
	spread_flags = PATHOGEN_SPREAD_BLOOD | PATHOGEN_SPREAD_CONTACT_FLUIDS | PATHOGEN_SPREAD_CONTACT_SKIN
	spread_text = "Blood and Contact"
	cure_text = "SCP-500 (panacea)"
	cures = list(/datum/reagent/medicine/spaceacillin)
	cure_chance = 0.5
	severity = PATHOGEN_SEVERITY_ANOMALOUS
	bsl_level = BSL_4
	is_anomalous = TRUE
	transmission_types = list(PATHOGEN_TRANSMISSION_BLOOD, PATHOGEN_TRANSMISSION_CONTACT, PATHOGEN_TRANSMISSION_ANOMALOUS)
	contraction_chance_modifier = 0.8
	stage_prob = 3
	process_dead = TRUE
	cross_scp_interactions = list("SCP-500" = "instant_cure", "SCP-049" = "symbiotic_with_049")
	pathogen_flags = PATHOGEN_CURABLE | PATHOGEN_RESIST_ON_CURE

/datum/pathogen/foundation/scp008/on_process(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(DT_PROB(0.5, delta_time))
				to_chat(affected_mob, span_warning("A fever develops, and your skin feels cold."))
				affected_mob.adjust_bodytemperature(-10)
			if(DT_PROB(0.3, delta_time))
				affected_mob.emote("cough")
		if(3)
			if(DT_PROB(0.8, delta_time))
				affected_mob.adjustBruteLoss(2)
			if(DT_PROB(0.5, delta_time))
				affected_mob.stamina.adjust(-15)
			if(DT_PROB(0.3, delta_time))
				to_chat(affected_mob, span_danger("Necrotic patches form on your skin."))
			if(DT_PROB(0.2, delta_time))
				affected_mob.set_confusion_if_lower(10 SECONDS)
		if(4)
			if(DT_PROB(1, delta_time))
				affected_mob.adjustBruteLoss(4)
			if(DT_PROB(0.8, delta_time))
				affected_mob.adjustToxLoss(5, FALSE)
			if(DT_PROB(0.5, delta_time))
				affected_mob.stamina.adjust(-25)
			if(DT_PROB(0.3, delta_time))
				to_chat(affected_mob, span_userdanger("Your body is shutting down... you feel the hunger..."))
		if(5)
			if(DT_PROB(1.5, delta_time))
				affected_mob.adjustBruteLoss(6)
			if(DT_PROB(1, delta_time))
				affected_mob.adjustToxLoss(8, FALSE)
			if(affected_mob.stat == DEAD && DT_PROB(5, delta_time))
				scp008_reanimate()

/datum/pathogen/foundation/scp008/proc/scp008_reanimate()
	if(!affected_mob || affected_mob.stat != DEAD)
		return

	var/mob/living/carbon/human/H = affected_mob
	if(!istype(H))
		return

	var/mob/living/simple_animal/hostile/scp008_zombie/zombie = new(get_turf(H))
	zombie.name = "[H.name] (Zombie)"
	zombie.desc = "A zombie created by SCP-008. It was once [H.name]."

	H.ghostize()
	qdel(H)
	qdel(src)

/datum/pathogen/foundation/scp016
	name = "SCP-016"
	desc = "Sentient Micro-Organism. A self-aware pathogen that adapts to ensure its survival and spread."
	agent = "SCP-016 microorganism"
	max_stages = 5
	spread_flags = PATHOGEN_SPREAD_AIRBORNE | PATHOGEN_SPREAD_CONTACT_FLUIDS | PATHOGEN_SPREAD_CONTACT_SKIN
	spread_text = "Airborne and Contact"
	cure_text = "SCP-500 or high-dose experimental treatment"
	cures = list(/datum/reagent/medicine/spaceacillin)
	cure_chance = 0.5
	severity = PATHOGEN_SEVERITY_ANOMALOUS
	bsl_level = BSL_4
	is_anomalous = TRUE
	transmission_types = list(PATHOGEN_TRANSMISSION_AIRBORNE, PATHOGEN_TRANSMISSION_CONTACT, PATHOGEN_TRANSMISSION_ANOMALOUS)
	contraction_chance_modifier = 1.0
	stage_prob = 2
	cross_scp_interactions = list("SCP-500" = "instant_cure", "SCP-016" = "sentient_adaptation")
	pathogen_flags = PATHOGEN_CURABLE | PATHOGEN_RESIST_ON_CURE

	var/adapted = FALSE
	var/last_cure_attempt = 0

/datum/pathogen/foundation/scp016/on_process(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	if(world.time > last_cure_attempt + 300 && affected_mob?.reagents)
		for(var/reag in cures)
			if(affected_mob.reagents.has_reagent(reag))
				last_cure_attempt = world.time
				if(prob(60))
					affected_mob.reagents.remove_reagent(reag, 3)
					to_chat(affected_mob, span_warning("The medicine seems to have no effect... the disease is adapting."))
					if(!adapted)
						adapted = TRUE
						cure_chance = max(cure_chance * 0.5, 0.1)
				break

	switch(stage)
		if(2)
			if(DT_PROB(0.5, delta_time))
				to_chat(affected_mob, span_warning("You feel a strange awareness in the back of your mind."))
			if(DT_PROB(0.3, delta_time))
				affected_mob.emote("sweat")
		if(3)
			if(DT_PROB(0.5, delta_time))
				affected_mob.stamina.adjust(-10)
			if(DT_PROB(0.3, delta_time))
				to_chat(affected_mob, span_warning("Something inside you is thinking... watching..."))
			if(DT_PROB(0.2, delta_time))
				affected_mob.adjustBruteLoss(2)
		if(4)
			if(DT_PROB(0.8, delta_time))
				affected_mob.adjustBruteLoss(3)
			if(DT_PROB(0.5, delta_time))
				affected_mob.adjustToxLoss(3, FALSE)
			if(DT_PROB(0.3, delta_time))
				affected_mob.set_confusion_if_lower(20 SECONDS)
			if(DT_PROB(0.2, delta_time))
				airborne_spread(3, FALSE)
		if(5)
			if(DT_PROB(1, delta_time))
				affected_mob.adjustBruteLoss(5)
			if(DT_PROB(0.8, delta_time))
				affected_mob.adjustToxLoss(5, FALSE)
			if(DT_PROB(0.5, delta_time))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3, 150)
			if(DT_PROB(0.3, delta_time))
				airborne_spread(5, FALSE)

/datum/pathogen/foundation/scp217
	name = "SCP-217"
	desc = "The Clockwork Virus. A virus that converts organic tissue into mechanical clockwork components."
	agent = "SCP-217 clockwork virion"
	max_stages = 5
	spread_flags = PATHOGEN_SPREAD_CONTACT_SKIN | PATHOGEN_SPREAD_CONTACT_FLUIDS | PATHOGEN_SPREAD_BLOOD
	spread_text = "Contact and Blood"
	cure_text = "No known cure. SCP-500 suspected."
	cures = list()
	cure_chance = 0
	severity = PATHOGEN_SEVERITY_ANOMALOUS
	bsl_level = BSL_4
	is_anomalous = TRUE
	transmission_types = list(PATHOGEN_TRANSMISSION_CONTACT, PATHOGEN_TRANSMISSION_BLOOD, PATHOGEN_TRANSMISSION_ANOMALOUS)
	contraction_chance_modifier = 0.6
	stage_prob = 1.5
	pathogen_flags = PATHOGEN_RESIST_ON_CURE
	cross_scp_interactions = list("SCP-500" = "possible_cure", "SCP-610" = "counteractive")

/datum/pathogen/foundation/scp217/on_process(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(DT_PROB(0.3, delta_time))
				to_chat(affected_mob, span_warning("Your joints make a faint clicking sound when you move."))
			if(DT_PROB(0.2, delta_time))
				affected_mob.stamina.adjust(-3)
		if(3)
			if(DT_PROB(0.5, delta_time))
				to_chat(affected_mob, span_warning("A thin layer of brass appears beneath your skin."))
			if(DT_PROB(0.3, delta_time))
				affected_mob.adjustBruteLoss(1)
			if(DT_PROB(0.2, delta_time))
				affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/clockwork_virus)
		if(4)
			if(DT_PROB(0.8, delta_time))
				affected_mob.adjustBruteLoss(3)
			if(DT_PROB(0.5, delta_time))
				to_chat(affected_mob, span_danger("Gears and springs push through your flesh."))
			if(DT_PROB(0.3, delta_time))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2, 120)
			if(ishuman(affected_mob))
				var/mob/living/carbon/human/H = affected_mob
				H.physiology.damage_resistance += 3
		if(5)
			if(DT_PROB(1, delta_time))
				affected_mob.adjustBruteLoss(5)
			if(DT_PROB(0.8, delta_time))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3, 150)
			if(DT_PROB(0.5, delta_time))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_HEART, 2, 100)
			if(ishuman(affected_mob))
				var/mob/living/carbon/human/H = affected_mob
				H.physiology.damage_resistance += 5
			if(DT_PROB(0.3, delta_time))
				to_chat(affected_mob, span_userdanger("You ARE the machine now. TICK. TICK. TICK."))

/datum/movespeed_modifier/clockwork_virus
	movetypes = GROUND
	slowdown = 0.2

/datum/pathogen/foundation/scp610
	name = "SCP-610"
	desc = "The Flesh That Hates. A contagious skin condition that transforms hosts into flesh masses."
	agent = "SCP-610 tissue"
	max_stages = 5
	spread_flags = PATHOGEN_SPREAD_CONTACT_SKIN | PATHOGEN_SPREAD_CONTACT_FLUIDS | PATHOGEN_SPREAD_AIRBORNE
	spread_text = "Contact and Airborne"
	cure_text = "No known cure. Amputation of affected areas only treatment."
	cures = list()
	cure_chance = 0
	severity = PATHOGEN_SEVERITY_ANOMALOUS
	bsl_level = BSL_4
	is_anomalous = TRUE
	transmission_types = list(PATHOGEN_TRANSMISSION_CONTACT, PATHOGEN_TRANSMISSION_AIRBORNE, PATHOGEN_TRANSMISSION_ANOMALOUS)
	contraction_chance_modifier = 0.7
	stage_prob = 2
	pathogen_flags = PATHOGEN_RESIST_ON_CURE
	process_dead = TRUE
	cross_scp_interactions = list("SCP-500" = "halts_progression", "SCP-217" = "counteractive")

/datum/pathogen/foundation/scp610/on_process(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(DT_PROB(0.5, delta_time))
				to_chat(affected_mob, span_warning("Your skin itches terribly, and red blotches appear."))
			if(DT_PROB(0.3, delta_time))
				affected_mob.adjustBruteLoss(1)
		if(3)
			if(DT_PROB(0.8, delta_time))
				affected_mob.adjustBruteLoss(3)
			if(DT_PROB(0.5, delta_time))
				to_chat(affected_mob, span_warning("Fleshy growths bulge from your body, spreading like tendrils."))
			if(DT_PROB(0.3, delta_time))
				affected_mob.stamina.adjust(-10)
			if(DT_PROB(0.2, delta_time))
				airborne_spread(2, FALSE)
		if(4)
			if(DT_PROB(1, delta_time))
				affected_mob.adjustBruteLoss(5)
			if(DT_PROB(0.8, delta_time))
				affected_mob.adjustToxLoss(4, FALSE)
			if(DT_PROB(0.5, delta_time))
				affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/flesh_hate)
			if(DT_PROB(0.3, delta_time))
				airborne_spread(3, FALSE)
			if(DT_PROB(0.2, delta_time))
				to_chat(affected_mob, span_userdanger("Your flesh ROTS and WRITHES!"))
		if(5)
			if(DT_PROB(1.5, delta_time))
				affected_mob.adjustBruteLoss(8)
			if(DT_PROB(1, delta_time))
				affected_mob.adjustToxLoss(6, FALSE, cause_of_death = "SCP-610 flesh necrosis")
			if(DT_PROB(0.8, delta_time))
				airborne_spread(5, FALSE)
			if(affected_mob.stat == DEAD && DT_PROB(3, delta_time))
				scp610_flesh_mass()

/datum/movespeed_modifier/flesh_hate
	movetypes = GROUND
	slowdown = 0.5

/datum/pathogen/foundation/scp610/proc/scp610_flesh_mass()
	if(!affected_mob || affected_mob.stat != DEAD)
		return

	var/turf/T = get_turf(affected_mob)
	affected_mob.visible_message(span_boldannounce("[affected_mob]'s body collapses into a mass of hateful flesh!"))

	var/mob/living/simple_animal/hostile/flesh_mass/mass = new(T)
	mass.name = "Flesh Mass"
	mass.desc = "A writhing mass of SCP-610-infected tissue. It HATES."

	affected_mob.ghostize()
	qdel(affected_mob)
	qdel(src)

/mob/living/simple_animal/hostile/flesh_mass
	name = "Flesh Mass"
	desc = "A writhing mass of hateful tissue."
	icon = 'icons/mob/animal.dmi'
	icon_state = "horror"
	icon_living = "horror"
	maxHealth = 200
	health = 200
	melee_damage_lower = 15
	melee_damage_upper = 25
	environment_smash = 1
	obj_damage = 15
	del_on_death = TRUE
	var/spread_cooldown = 0

/mob/living/simple_animal/hostile/flesh_mass/Initialize()
	. = ..()
	AIStatus = AI_ON

/mob/living/simple_animal/hostile/flesh_mass/process()
	. = ..()
	if(world.time < spread_cooldown)
		return
	spread_cooldown = world.time + 60 SECONDS
	var/turf/T = get_turf(src)
	new /obj/effect/decal/cleanable/blood(T)

/datum/pathogen/foundation/scp742
	name = "SCP-742"
	desc = "Retroviral crystalline infection. Transforms organic tissue into crystalline structures."
	agent = "SCP-742 retrovirus"
	max_stages = 4
	spread_flags = PATHOGEN_SPREAD_BLOOD | PATHOGEN_SPREAD_CONTACT_FLUIDS
	spread_text = "Blood"
	cure_text = "No known cure."
	cures = list()
	cure_chance = 0
	severity = PATHOGEN_SEVERITY_ANOMALOUS
	bsl_level = BSL_4
	is_anomalous = TRUE
	transmission_types = list(PATHOGEN_TRANSMISSION_BLOOD, PATHOGEN_TRANSMISSION_ANOMALOUS)
	contraction_chance_modifier = 0.4
	stage_prob = 1.5
	pathogen_flags = PATHOGEN_RESIST_ON_CURE
	cross_scp_interactions = list("SCP-500" = "halts_progression")

/datum/pathogen/foundation/scp742/on_process(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(DT_PROB(0.3, delta_time))
				to_chat(affected_mob, span_warning("Your skin hardens, taking on a glassy sheen."))
			if(DT_PROB(0.2, delta_time))
				affected_mob.adjustBruteLoss(1)
		if(3)
			if(DT_PROB(0.5, delta_time))
				affected_mob.adjustBruteLoss(2)
			if(DT_PROB(0.3, delta_time))
				to_chat(affected_mob, span_warning("Crystalline growths push through your flesh."))
			if(ishuman(affected_mob))
				var/mob/living/carbon/human/H = affected_mob
				H.physiology.damage_resistance += 5
			if(DT_PROB(0.2, delta_time))
				affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/crystallization)
		if(4)
			if(DT_PROB(0.8, delta_time))
				affected_mob.adjustBruteLoss(4)
			if(DT_PROB(0.5, delta_time))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2, 150)
			if(ishuman(affected_mob))
				var/mob/living/carbon/human/H = affected_mob
				H.physiology.damage_resistance += 10
			if(DT_PROB(0.3, delta_time))
				to_chat(affected_mob, span_userdanger("Your body crystallizes. You can feel every fracture."))

/datum/pathogen/foundation/scp253
	name = "SCP-253"
	desc = "The Cancer. A contagious form of cancer that spreads between hosts via unknown means."
	agent = "SCP-253 oncocytes"
	max_stages = 5
	spread_flags = PATHOGEN_SPREAD_CONTACT_SKIN | PATHOGEN_SPREAD_CONTACT_FLUIDS
	spread_text = "Contact"
	cure_text = "Chemotherapy (Spaceacillin + Dylovene)"
	cures = list(/datum/reagent/medicine/spaceacillin, /datum/reagent/medicine/dylovene)
	cure_chance = 2
	pathogen_flags = PATHOGEN_CURABLE | PATHOGEN_RESIST_ON_CURE | PATHOGEN_NEED_ALL_CURES | PATHOGEN_REGRESS_TO_CURE
	severity = PATHOGEN_SEVERITY_ANOMALOUS
	bsl_level = BSL_3
	is_anomalous = TRUE
	transmission_types = list(PATHOGEN_TRANSMISSION_CONTACT, PATHOGEN_TRANSMISSION_ANOMALOUS)
	contraction_chance_modifier = 0.5
	stage_prob = 2
	cross_scp_interactions = list("SCP-500" = "instant_cure")

/datum/pathogen/foundation/scp253/on_process(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(DT_PROB(0.3, delta_time))
				to_chat(affected_mob, span_warning("A lump forms under your skin."))
			if(DT_PROB(0.2, delta_time))
				affected_mob.adjustBruteLoss(1)
		if(3)
			if(DT_PROB(0.5, delta_time))
				affected_mob.adjustBruteLoss(2)
			if(DT_PROB(0.3, delta_time))
				affected_mob.adjustToxLoss(2, FALSE)
			if(DT_PROB(0.2, delta_time))
				affected_mob.stamina.adjust(-8)
		if(4)
			if(DT_PROB(0.8, delta_time))
				affected_mob.adjustBruteLoss(4)
			if(DT_PROB(0.5, delta_time))
				affected_mob.adjustToxLoss(4, FALSE)
			if(DT_PROB(0.3, delta_time))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2, 120)
			if(DT_PROB(0.2, delta_time))
				affected_mob.stamina.adjust(-15)
		if(5)
			if(DT_PROB(1.5, delta_time))
				affected_mob.adjustBruteLoss(6)
			if(DT_PROB(1, delta_time))
				affected_mob.adjustToxLoss(6, FALSE, cause_of_death = "SCP-253 systemic cancer")
			if(DT_PROB(0.5, delta_time))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3, 150)
			if(DT_PROB(0.3, delta_time))
				affected_mob.vomit(15, TRUE)

/datum/pathogen/foundation/scp1025
	name = "SCP-1025"
	desc = "Encyclopedia of Common Diseases. Reading it causes the reader to contract the described illness."
	agent = "SCP-1025 memetic pathogen"
	max_stages = 3
	spread_flags = PATHOGEN_SPREAD_SPECIAL
	spread_text = "Memetic"
	cure_text = "Amnestics"
	cures = list(/datum/reagent/medicine/amnestics/classa)
	cure_chance = 5
	severity = PATHOGEN_SEVERITY_HARMFUL
	bsl_level = BSL_3
	is_anomalous = TRUE
	transmission_types = list(PATHOGEN_TRANSMISSION_ANOMALOUS)
	contraction_chance_modifier = 1.0
	stage_prob = 4
	cross_scp_interactions = list("SCP-500" = "instant_cure")

/datum/pathogen/foundation/scp1025/on_process(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(DT_PROB(0.5, delta_time))
				to_chat(affected_mob, span_warning("You can't stop thinking about diseases."))
			if(DT_PROB(0.3, delta_time))
				affected_mob.hallucination += 10
		if(3)
			if(DT_PROB(0.8, delta_time))
				affected_mob.adjustBruteLoss(2)
			if(DT_PROB(0.5, delta_time))
				affected_mob.adjustToxLoss(2, FALSE)
			if(DT_PROB(0.3, delta_time))
				affected_mob.hallucination += 20
			if(DT_PROB(0.2, delta_time))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2, 120)

/datum/pathogen/foundation/scp1499
	name = "SCP-1499"
	desc = "The Gas Mask Pathogen. Organisms from SCP-1499's dimension carry anomalous microorganisms."
	agent = "SCP-1499 dimensional spore"
	max_stages = 4
	spread_flags = PATHOGEN_SPREAD_AIRBORNE | PATHOGEN_SPREAD_SPECIAL
	spread_text = "Anomalous Airborne"
	cure_text = "No known cure. Remove from SCP-1499's dimension."
	cures = list()
	cure_chance = 0
	severity = PATHOGEN_SEVERITY_ANOMALOUS
	bsl_level = BSL_4
	is_anomalous = TRUE
	transmission_types = list(PATHOGEN_TRANSMISSION_AIRBORNE, PATHOGEN_TRANSMISSION_ANOMALOUS)
	contraction_chance_modifier = 0.3
	stage_prob = 1
	pathogen_flags = PATHOGEN_RESIST_ON_CURE
	cross_scp_interactions = list("SCP-500" = "possible_cure")

/datum/pathogen/foundation/scp1499/on_process(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(DT_PROB(0.3, delta_time))
				to_chat(affected_mob, span_warning("You hear whispers from nowhere."))
			if(DT_PROB(0.2, delta_time))
				affected_mob.hallucination += 10
		if(3)
			if(DT_PROB(0.5, delta_time))
				affected_mob.hallucination += 15
			if(DT_PROB(0.3, delta_time))
				affected_mob.set_confusion_if_lower(15 SECONDS)
			if(DT_PROB(0.2, delta_time))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1, 100)
		if(4)
			if(DT_PROB(0.8, delta_time))
				affected_mob.hallucination += 25
			if(DT_PROB(0.5, delta_time))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3, 150)
			if(DT_PROB(0.3, delta_time))
				affected_mob.set_confusion_if_lower(30 SECONDS)
			if(DT_PROB(0.2, delta_time))
				affected_mob.visible_message(span_warning("A dimensional tear flickers near [affected_mob]!"))
