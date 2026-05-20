// Sanity System - Comprehensive Mental Health Management
// Fully integrated with the Daedalus Dock codebase

// Sanity states
#define SANITY_NEUTRAL "neutral"
#define SANITY_GOOD "good"
#define SANITY_STRESSED "stressed"
#define SANITY_DISTRESSED "distressed"
#define SANITY_PANIC "panic"
#define SANITY_INSANE "insane"
#define SANITY_CATASTROPHIC "catastrophic"

// Trauma types
#define TRAUMA_SCP_EXPOSURE "scp_exposure"
#define TRAUMA_VIOLENCE "violence"
#define TRAUMA_DEATH "death"
#define TRAUMA_ISOLATION "isolation"
#define TRAUMA_PSYCHOLOGICAL "psychological"
#define TRAUMA_PHYSICAL "physical"

// Hallucination types
#define HALLUCINATION_VISUAL "visual"
#define HALLUCINATION_AUDITORY "auditory"
#define HALLUCINATION_TACTILE "tactile"
#define HALLUCINATION_OLFACTORY "olfactory"

// Insanity effects
#define INSANITY_PARANOIA "paranoia"
#define INSANITY_DELUSIONS "delusions"
#define INSANITY_AGGRESSION "aggression"
#define INSANITY_DEPRESSION "depression"
#define INSANITY_ANXIETY "anxiety"
#define INSANITY_DISSOCIATION "dissociation"

// Core Sanity Datum
/datum/sanity
	var/mob/living/carbon/human/owner
	var/sanity_level = 100
	var/max_sanity = 100
	var/min_sanity = 0

	// Sanity categories
	var/current_sanity_state = SANITY_NEUTRAL
	var/previous_sanity_state = SANITY_NEUTRAL

	// Recovery and damage
	var/sanity_recovery_rate = 0.5
	var/sanity_damage_rate = 0
	var/last_sanity_change = 0

	// Trauma system
	var/list/traumas = list()
	var/list/trauma_resistances = list()
	var/trauma_threshold = 25

	// Hallucination system
	var/hallucination_level = 0
	var/max_hallucination = 100
	var/hallucination_cooldown = 0
	var/list/active_hallucinations = list()

	// Insanity effects
	var/insanity_level = 0
	var/max_insanity = 100
	var/list/insanity_effects = list()

	// SCP interaction tracking
	var/list/scp_exposures = list()
	var/scp_exposure_multiplier = 1.0

	// Environmental factors
	var/list/environmental_factors = list()
	var/environmental_sanity_drain = 0

	// Social factors
	var/social_isolation = 0
	var/max_social_isolation = 100
	var/social_recovery_rate = 1.0

	// Medication and treatment
	var/list/active_medications = list()
	var/treatment_effectiveness = 1.0

	// Persistence tracking
	var/total_sanity_lost = 0
	var/total_sanity_gained = 0
	var/sanity_breakdowns = 0
	var/longest_stable_period = 0
	var/current_stable_period = 0

/datum/sanity/New(mob/living/carbon/human/H)
	. = ..()
	owner = H

	// Initialize trauma resistances
	trauma_resistances = list(
		TRAUMA_SCP_EXPOSURE = 1.0,
		TRAUMA_VIOLENCE = 1.0,
		TRAUMA_DEATH = 1.0,
		TRAUMA_ISOLATION = 1.0,
		TRAUMA_PSYCHOLOGICAL = 1.0,
		TRAUMA_PHYSICAL = 1.0
	)

	// Initialize environmental factors
	environmental_factors = list(
		"lighting" = 0,
		"noise" = 0,
		"crowding" = 0,
		"isolation" = 0,
		"danger" = 0,
		"unfamiliarity" = 0
	)

	// Start processing
	START_PROCESSING(SSobj, src)

/datum/sanity/Destroy()
	clear_all_visual_effects()
	STOP_PROCESSING(SSobj, src)
	owner = null
	return ..()

/datum/sanity/process(delta_time)
	// Don't call parent - we're implementing our own process logic

	// Update sanity level
	update_sanity()

	// Update environmental factors
	update_environmental_factors()

	// Update social isolation
	update_social_isolation()

	// Update hallucinations
	update_hallucinations()

	// Update insanity effects
	update_insanity_effects()

	// Update medications
	update_medications()

	// Check for sanity state changes
	check_sanity_state_change()

	// Update visual effects
	update_visual_effects()

	// Update behavioral effects
	update_behavioral_effects()

	// Check for episodes
	if(!episode_active)
		trigger_episode()

	// Apply job profile modifiers
	apply_job_sanity_profile()

	// Return nothing to continue processing (not PROCESS_KILL)

/datum/sanity/proc/update_sanity()
	var/sanity_change = 0

	// Natural recovery
	if(sanity_level < max_sanity)
		sanity_change += sanity_recovery_rate * treatment_effectiveness

	// Environmental drain
	sanity_change -= environmental_sanity_drain

	// Social isolation effects
	if(social_isolation > 50)
		sanity_change -= (social_isolation - 50) * 0.01

	// Trauma effects
	for(var/trauma in traumas)
		var/datum/trauma/T = trauma
		sanity_change -= T.sanity_drain

	// Insanity effects
	sanity_change -= insanity_level * 0.01

	// Apply change
	adjust_sanity(sanity_change)

	// Update tracking
	if(sanity_change > 0)
		total_sanity_gained += sanity_change
	else if(sanity_change < 0)
		total_sanity_lost += abs(sanity_change)

/datum/sanity/proc/adjust_sanity(amount, reason = "")
	if(amount < 0 && findtext(reason, "scp"))
		var/cognitive_resist = 0
		if(SSscp_research?.manager)
			cognitive_resist = SSscp_research.manager.cognitive_bonus
		if(cognitive_resist > 0)
			amount = round(amount * (1 - cognitive_resist))
	amount = get_conditioned_sanity_change(amount)
	var/old_sanity = sanity_level
	sanity_level = clamp(sanity_level + amount, min_sanity, max_sanity)

	// Check for breakdowns
	if(old_sanity > 50 && sanity_level <= 50)
		sanity_breakdowns++
		trigger_sanity_breakdown()

	// Update stable period tracking
	if(sanity_level > 75)
		current_stable_period++
		if(current_stable_period > longest_stable_period)
			longest_stable_period = current_stable_period
	else
		current_stable_period = 0

	last_sanity_change = world.time

/datum/sanity/proc/update_environmental_factors()
	environmental_factors.Cut()

	if(!owner)
		return

	var/turf/T = get_turf(owner)
	if(!T)
		return

	// Lighting factor
	var/light_level = T.get_lumcount()
	if(light_level < 0.3)
		environmental_factors["lighting"] = (0.3 - light_level) * 10
	else if(light_level > 0.8)
		environmental_factors["lighting"] = (light_level - 0.8) * 5

	// Noise factor
	var/noise_level = 0
	for(var/mob/living/L in range(7, owner))
		if(L != owner)
			noise_level += 1
	environmental_factors["noise"] = min(noise_level * 2, 20)

	// Crowding factor
	var/crowding = 0
	for(var/mob/living/carbon/human/H in range(3, owner))
		if(H != owner)
			crowding += 1
	environmental_factors["crowding"] = min(crowding * 5, 25)

	// Isolation factor
	if(crowding == 0)
		environmental_factors["isolation"] = 10

	// Danger factor
	var/danger_level = 0
	for(var/mob/living/simple_animal/hostile/H in range(5, owner))
		danger_level += 5
	for(var/obj/machinery/computer/security/S in range(10, owner))
		// Security computers indicate danger
		danger_level += 3
	environmental_factors["danger"] = min(danger_level, 30)

	// Calculate total environmental drain
	environmental_sanity_drain = 0
	for(var/factor in environmental_factors)
		environmental_sanity_drain += environmental_factors[factor] * 0.01

/datum/sanity/proc/update_social_isolation()
	if(!owner)
		return

	var/social_contacts = 0
	for(var/mob/living/carbon/human/H in range(7, owner))
		if(H != owner && H.stat != DEAD)
			social_contacts += 1

	if(social_contacts == 0)
		social_isolation = min(social_isolation + 1, max_social_isolation)
	else
		social_isolation = max(social_isolation - social_recovery_rate, 0)

/datum/sanity/proc/update_hallucinations()
	if(hallucination_level <= 0)
		return

	// Reduce hallucination level over time
	hallucination_level = max(0, hallucination_level - 0.5)

	// Generate new hallucinations
	if(world.time > hallucination_cooldown && prob(10))
		generate_hallucination()
		hallucination_cooldown = world.time + 30 SECONDS

/datum/sanity/proc/generate_hallucination()
	if(!owner || hallucination_level < 20)
		return

	var/hallucination_type = pick(HALLUCINATION_VISUAL, HALLUCINATION_AUDITORY, HALLUCINATION_TACTILE)
	var/hallucination = ""

	switch(hallucination_type)
		if(HALLUCINATION_VISUAL)
			hallucination = pick("You see shadows moving in the corner of your eye.", "The walls seem to be breathing.", "You notice someone watching you from the shadows.", "The lights flicker ominously.", "You see writing on the walls that wasn't there before.")
		if(HALLUCINATION_AUDITORY)
			hallucination = pick("You hear whispers in the distance.", "Someone is calling your name.", "You hear footsteps behind you.", "The air hums with an unsettling frequency.", "You hear crying from somewhere nearby.")
		if(HALLUCINATION_TACTILE)
			hallucination = pick("You feel something brush against your skin.", "The air feels thick and oppressive.", "You feel like you're being watched.", "Your skin crawls with an unseen presence.", "You feel a cold hand on your shoulder.")

	if(hallucination)
		to_chat(owner, "<span class='warning'>[hallucination]</span>")
		active_hallucinations += hallucination

/datum/sanity/proc/update_insanity_effects()
	if(insanity_level <= 0)
		return

	// Apply insanity effects based on level
	if(insanity_level >= 20 && !(INSANITY_PARANOIA in insanity_effects))
		add_insanity_effect(INSANITY_PARANOIA)

	if(insanity_level >= 40 && !(INSANITY_ANXIETY in insanity_effects))
		add_insanity_effect(INSANITY_ANXIETY)

	if(insanity_level >= 60 && !(INSANITY_DELUSIONS in insanity_effects))
		add_insanity_effect(INSANITY_DELUSIONS)

	if(insanity_level >= 80 && !(INSANITY_AGGRESSION in insanity_effects))
		add_insanity_effect(INSANITY_AGGRESSION)

/datum/sanity/proc/add_insanity_effect(effect)
	if(effect in insanity_effects)
		return

	insanity_effects += effect

	switch(effect)
		if(INSANITY_PARANOIA)
			to_chat(owner, "<span class='danger'>You feel paranoid. Everyone is watching you.</span>")
		if(INSANITY_ANXIETY)
			to_chat(owner, "<span class='danger'>An overwhelming sense of anxiety grips you.</span>")
		if(INSANITY_DELUSIONS)
			to_chat(owner, "<span class='danger'>Reality seems to shift and change around you.</span>")
		if(INSANITY_AGGRESSION)
			to_chat(owner, "<span class='danger'>You feel an uncontrollable urge to lash out.</span>")

/datum/sanity/proc/update_medications()
	for(var/medication in active_medications)
		var/datum/medication/M = medication
		M.update_effect(owner)

/datum/sanity/proc/check_sanity_state_change()
	var/new_state = get_sanity_state()

	if(new_state != current_sanity_state)
		previous_sanity_state = current_sanity_state
		current_sanity_state = new_state
		on_sanity_state_change(previous_sanity_state, current_sanity_state)

/datum/sanity/proc/get_sanity_state()
	if(sanity_level >= 90)
		return SANITY_GOOD
	else if(sanity_level >= 75)
		return SANITY_NEUTRAL
	else if(sanity_level >= 60)
		return SANITY_STRESSED
	else if(sanity_level >= 40)
		return SANITY_DISTRESSED
	else if(sanity_level >= 20)
		return SANITY_PANIC
	else if(sanity_level >= 5)
		return SANITY_INSANE
	else
		return SANITY_CATASTROPHIC

/datum/sanity/proc/on_sanity_state_change(old_state, new_state)
	if(!owner)
		return

	// Notify owner of state change
	var/state_message = ""
	switch(new_state)
		if(SANITY_GOOD)
			state_message = "You feel mentally stable and clear-headed."
		if(SANITY_NEUTRAL)
			state_message = "You feel relatively normal."
		if(SANITY_STRESSED)
			state_message = "You're feeling stressed and on edge."
		if(SANITY_DISTRESSED)
			state_message = "Your mental state is deteriorating. You feel distressed."
		if(SANITY_PANIC)
			state_message = "You're panicking! Your sanity is slipping away!"
		if(SANITY_INSANE)
			state_message = "You're losing your mind! Reality is breaking down!"
		if(SANITY_CATASTROPHIC)
			state_message = "You've completely lost your sanity! You're beyond help!"

	if(state_message)
		to_chat(owner, "<span class='notice'>[state_message]</span>")

	// Apply state-specific effects
	apply_sanity_state_effects(new_state)

/datum/sanity/proc/apply_sanity_state_effects(state)
	if(!owner)
		return

	switch(state)
		if(SANITY_STRESSED)
			owner.stamina.adjust(-5)
		if(SANITY_DISTRESSED)
			owner.stamina.adjust(-10)
			owner.adjustToxLoss(1)
		if(SANITY_PANIC)
			owner.stamina.adjust(-15)
			owner.adjustToxLoss(2)
			hallucination_level = min(hallucination_level + 10, max_hallucination)
		if(SANITY_INSANE)
			owner.stamina.adjust(-25)
			owner.adjustToxLoss(3)
			hallucination_level = min(hallucination_level + 20, max_hallucination)
			insanity_level = min(insanity_level + 10, max_insanity)
		if(SANITY_CATASTROPHIC)
			owner.stamina.adjust(-50)
			owner.adjustToxLoss(5)
			hallucination_level = max_hallucination
			insanity_level = max_insanity

/datum/sanity/proc/trigger_sanity_breakdown()
	if(!owner)
		return

	to_chat(owner, "<span class='danger'>You experience a mental breakdown!</span>")

	// Apply breakdown effects
	owner.stamina.adjust(-30)
	owner.adjustToxLoss(5)
	hallucination_level = min(hallucination_level + 30, max_hallucination)
	insanity_level = min(insanity_level + 20, max_insanity)

	// Create trauma
	add_trauma(TRAUMA_PSYCHOLOGICAL, 15)

/datum/sanity/proc/add_trauma(trauma_type, severity = 10)
	var/datum/trauma/trauma = new /datum/trauma(trauma_type, severity)
	traumas += trauma

	// Apply immediate sanity damage
	var/damage = severity * (1.0 / trauma_resistances[trauma_type])
	adjust_sanity(-damage)

	to_chat(owner, "<span class='warning'>You've experienced [trauma_type] trauma.</span>")

/datum/sanity/proc/remove_trauma(trauma_type)
	for(var/trauma in traumas)
		var/datum/trauma/T = trauma
		if(T.type == trauma_type)
			traumas -= trauma
			qdel(trauma)
			break

/datum/sanity/proc/add_scp_exposure(scp_id, severity = 10)
	scp_exposures[scp_id] = world.time

	// Apply SCP-specific sanity damage
	var/damage = severity * scp_exposure_multiplier
	adjust_sanity(-damage)

	// Add trauma
	add_trauma(TRAUMA_SCP_EXPOSURE, severity)

	to_chat(owner, "<span class='warning'>You've been exposed to SCP-[scp_id]. Your sanity has been affected.</span>")

/datum/sanity/proc/add_medication(datum/medication/medication)
	active_medications += medication
	medication.apply_effect(owner)

/datum/sanity/proc/remove_medication(medication_type)
	for(var/medication in active_medications)
		var/datum/medication/M = medication
		if(M.type == medication_type)
			M.remove_effect(owner)
			active_medications -= medication
			qdel(medication)
			break

// Trauma Datum
/datum/trauma
	var/trauma_type
	var/severity
	var/sanity_drain
	var/duration
	var/time_created

/datum/trauma/New(type, sev = 10, dur = -1)
	. = ..()
	trauma_type = type
	severity = sev
	duration = dur
	time_created = world.time

	// Calculate sanity drain based on severity
	sanity_drain = severity * 0.1

/datum/trauma/proc/update()
	if(duration > 0 && world.time > time_created + duration)
		return FALSE
	return TRUE

// Medication Datum
/datum/medication
	var/name
	var/effectiveness
	var/duration
	var/time_applied
	var/sanity_boost
	var/trauma_reduction

/datum/medication/New(med_name, eff = 1.0, dur = 300, boost = 10, trauma_red = 0.1)
	. = ..()
	name = med_name
	effectiveness = eff
	duration = dur
	sanity_boost = boost
	trauma_reduction = trauma_red
	time_applied = world.time

/datum/medication/proc/apply_effect(mob/living/carbon/human/target)
	if(!target || !target.sanity)
		return

	target.sanity.sanity_recovery_rate += sanity_boost * effectiveness
	target.sanity.treatment_effectiveness += effectiveness

/datum/medication/proc/remove_effect(mob/living/carbon/human/target)
	if(!target || !target.sanity)
		return

	target.sanity.sanity_recovery_rate -= sanity_boost * effectiveness
	target.sanity.treatment_effectiveness -= effectiveness

/datum/medication/proc/update_effect(mob/living/carbon/human/target)
	if(duration > 0 && world.time > time_applied + duration)
		remove_effect(target)
		return FALSE
	return TRUE

// Predefined medications
/datum/medication/antipsychotic
	name = "Antipsychotic"
	effectiveness = 1.5
	duration = 600
	sanity_boost = 15
	trauma_reduction = 0.2

/datum/medication/antianxiety
	name = "Anti-anxiety"
	effectiveness = 1.2
	duration = 450
	sanity_boost = 10
	trauma_reduction = 0.15

/datum/medication/sedative
	name = "Sedative"
	effectiveness = 1.0
	duration = 300
	sanity_boost = 5
	trauma_reduction = 0.1

// Integration with human mob
/mob/living/carbon/human
	var/datum/sanity/sanity

/mob/living/carbon/human/Initialize()
	. = ..()
	sanity = new /datum/sanity(src)

/mob/living/carbon/human/Destroy()
	QDEL_NULL(sanity)
	return ..()

// Sanity-related verbs
/mob/living/carbon/human/verb/check_sanity()
	set name = "Check Sanity"
	set category = "IC"
	set desc = "Check your current mental state."

	if(!sanity)
		to_chat(src, "<span class='warning'>You can't assess your mental state.</span>")
		return

	var/message = "<h2>Mental Health Assessment</h2>"
	message += "<b>Current Sanity:</b> [sanity.sanity_level]/[sanity.max_sanity]<br>"
	message += "<b>Mental State:</b> [sanity.current_sanity_state]<br>"
	message += "<b>Hallucination Level:</b> [sanity.hallucination_level]/[sanity.max_hallucination]<br>"
	message += "<b>Insanity Level:</b> [sanity.insanity_level]/[sanity.max_insanity]<br>"
	message += "<b>Social Isolation:</b> [sanity.social_isolation]/[sanity.max_social_isolation]<br><br>"

	if(sanity.traumas.len)
		message += "<h3>Active Traumas:</h3>"
		for(var/trauma in sanity.traumas)
			var/datum/trauma/T = trauma
			message += "- [T.trauma_type] (Severity: [T.severity])<br>"

	if(sanity.active_medications.len)
		message += "<h3>Active Medications:</h3>"
		for(var/medication in sanity.active_medications)
			var/datum/medication/M = medication
			message += "- [M.name]<br>"

	if(sanity.insanity_effects.len)
		message += "<h3>Insanity Effects:</h3>"
		for(var/effect in sanity.insanity_effects)
			message += "- [effect]<br>"

	to_chat(src, "<span class='notice'>[message]</span>")

/mob/living/carbon/human/verb/meditate()
	set name = "Meditate"
	set category = "IC"
	set desc = "Take a moment to calm your mind and recover sanity."

	if(!sanity)
		to_chat(src, "<span class='warning'>You can't meditate right now.</span>")
		return

	if(sanity.sanity_level >= sanity.max_sanity)
		to_chat(src, "<span class='notice'>Your mind is already clear.</span>")
		return

	to_chat(src, "<span class='notice'>You begin to meditate, focusing on calming your mind...</span>")

	// Meditation takes time and requires concentration
	if(do_after(src, 30 SECONDS, target = src))
		sanity.adjust_sanity(10)
		sanity.social_isolation = max(0, sanity.social_isolation - 5)
		to_chat(src, "<span class='notice'>You feel more mentally stable after your meditation.</span>")
	else
		to_chat(src, "<span class='warning'>Your meditation was interrupted.</span>")

// SCP Integration
/datum/scp/proc/affect_sanity(mob/living/carbon/human/target, severity = 10)
	if(!target || !target.sanity)
		return

	var/scp_number = "unknown"
	if(designation)
		scp_number = designation
	target.sanity.add_scp_exposure(scp_number, severity)

// Environmental effects
/area/proc/affect_sanity(mob/living/carbon/human/target, modifier = 1.0)
	if(!target || !target.sanity)
		return

	// Different areas can have different sanity effects
	var/sanity_drain = 0

	// Note: Lighting effects would need proper area integration
	// For now, we'll use area names to determine stress levels

	// SCP containment areas
	if(findtext(name, "SCP") || findtext(name, "containment"))
		sanity_drain += 3 * modifier

	// Medical areas (can be stressful)
	if(findtext(name, "medical") || findtext(name, "morgue"))
		sanity_drain += 1 * modifier

	// Security areas (high stress)
	if(findtext(name, "security") || findtext(name, "armory"))
		sanity_drain += 2 * modifier

	if(sanity_drain > 0)
		target.sanity.adjust_sanity(-sanity_drain * 0.01)

// Persistence integration
/datum/sanity/proc/save_data()
	var/list/data = list()

	data["sanity_level"] = sanity_level
	data["max_sanity"] = max_sanity
	data["total_sanity_lost"] = total_sanity_lost
	data["total_sanity_gained"] = total_sanity_gained
	data["sanity_breakdowns"] = sanity_breakdowns
	data["longest_stable_period"] = longest_stable_period
	data["scp_exposures"] = scp_exposures
	data["traumas"] = list()

	for(var/trauma in traumas)
		var/datum/trauma/T = trauma
		data["traumas"] += list(list(
			"type" = T.trauma_type,
			"severity" = T.severity,
			"time_created" = T.time_created
		))

	return data

/datum/sanity/proc/load_data(list/data)
	if(!data)
		return

	sanity_level = data["sanity_level"] || 100
	max_sanity = data["max_sanity"] || 100
	total_sanity_lost = data["total_sanity_lost"] || 0
	total_sanity_gained = data["total_sanity_gained"] || 0
	sanity_breakdowns = data["sanity_breakdowns"] || 0
	longest_stable_period = data["longest_stable_period"] || 0
	scp_exposures = data["scp_exposures"] || list()

	// Load traumas
	traumas.Cut()
	for(var/trauma_data in data["traumas"])
		var/datum/trauma/T = new /datum/trauma(
			trauma_data["type"],
			trauma_data["severity"]
		)
		T.time_created = trauma_data["time_created"]
		traumas += T

// ── Job Sanity Profiles ──

#define SANITY_PROFILE_DEFAULT "default"
#define SANITY_PROFILE_DCLASS "dclass"
#define SANITY_PROFILE_MTF "mtf"
#define SANITY_PROFILE_RESEARCHER "researcher"
#define SANITY_PROFILE_MEDICAL "medical"
#define SANITY_PROFILE_SECURITY "security"
#define SANITY_PROFILE_ENGINEERING "engineering"
#define SANITY_PROFILE_COMMAND "command"

/datum/sanity/proc/determine_job_profile()
	if(!owner)
		return SANITY_PROFILE_DEFAULT

	var/job_title = owner.job

	if(findtext(job_title, "D-Class"))
		return SANITY_PROFILE_DCLASS
	if(findtext(job_title, "MTF") || findtext(job_title, "Mobile Task Force"))
		return SANITY_PROFILE_MTF
	if(findtext(job_title, "Research") || findtext(job_title, "Scientist"))
		return SANITY_PROFILE_RESEARCHER
	if(findtext(job_title, "Medical") || findtext(job_title, "Doctor") || findtext(job_title, "Chemist"))
		return SANITY_PROFILE_MEDICAL
	if(findtext(job_title, "Security") || findtext(job_title, "Guard"))
		return SANITY_PROFILE_SECURITY
	if(findtext(job_title, "Engineer") || findtext(job_title, "Atmos"))
		return SANITY_PROFILE_ENGINEERING
	if(findtext(job_title, "Director") || findtext(job_title, "Command") || findtext(job_title, "Head"))
		return SANITY_PROFILE_COMMAND

	return SANITY_PROFILE_DEFAULT

/datum/sanity/proc/apply_job_sanity_profile()
	var/new_profile = determine_job_profile()
	if(new_profile == job_sanity_profile)
		return

	job_sanity_profile = new_profile

	switch(job_sanity_profile)
		if(SANITY_PROFILE_DCLASS)
			conditioning_resistance = 0.25
			memetic_vulnerability = 0.9
			combat_stress_resistance = 0.15
			medical_horror_resistance = 0.1
			isolation_tolerance = 1.5
			trauma_resistances[TRAUMA_VIOLENCE] = 1.4
			trauma_resistances[TRAUMA_ISOLATION] = 1.5

		if(SANITY_PROFILE_MTF)
			conditioning_resistance = 0.35
			memetic_vulnerability = 0.8
			combat_stress_resistance = 0.4
			medical_horror_resistance = 0.15
			isolation_tolerance = 1.2
			trauma_resistances[TRAUMA_VIOLENCE] = 1.5
			trauma_resistances[TRAUMA_DEATH] = 1.3

		if(SANITY_PROFILE_RESEARCHER)
			conditioning_resistance = 0.1
			memetic_vulnerability = 1.4
			combat_stress_resistance = 0.05
			medical_horror_resistance = 0.1
			isolation_tolerance = 0.8
			trauma_resistances[TRAUMA_SCP_EXPOSURE] = 0.7
			scp_exposure_multiplier = 1.3

		if(SANITY_PROFILE_MEDICAL)
			conditioning_resistance = 0.15
			memetic_vulnerability = 1.0
			combat_stress_resistance = 0.1
			medical_horror_resistance = 0.45
			isolation_tolerance = 0.9
			trauma_resistances[TRAUMA_PHYSICAL] = 1.3
			trauma_resistances[TRAUMA_DEATH] = 1.2

		if(SANITY_PROFILE_SECURITY)
			conditioning_resistance = 0.2
			memetic_vulnerability = 1.0
			combat_stress_resistance = 0.25
			medical_horror_resistance = 0.1
			isolation_tolerance = 1.0
			trauma_resistances[TRAUMA_VIOLENCE] = 1.3

		if(SANITY_PROFILE_ENGINEERING)
			conditioning_resistance = 0.1
			memetic_vulnerability = 1.0
			combat_stress_resistance = 0.1
			medical_horror_resistance = 0.1
			isolation_tolerance = 1.0
			trauma_resistances[TRAUMA_PHYSICAL] = 1.1

		if(SANITY_PROFILE_COMMAND)
			conditioning_resistance = 0.2
			memetic_vulnerability = 1.0
			combat_stress_resistance = 0.2
			medical_horror_resistance = 0.15
			isolation_tolerance = 1.1
			trauma_resistances[TRAUMA_PSYCHOLOGICAL] = 1.3

		else
			conditioning_resistance = 0
			memetic_vulnerability = 1.0
			combat_stress_resistance = 0
			medical_horror_resistance = 0
			isolation_tolerance = 1.0

/datum/sanity/proc/get_conditioned_sanity_change(amount)
	if(amount >= 0)
		return amount

	var/resisted = abs(amount) * conditioning_resistance
	return amount + resisted

/datum/sanity/proc/get_profile_data()
	return list(
		"profile" = job_sanity_profile,
		"conditioning_resistance" = conditioning_resistance,
		"memetic_vulnerability" = memetic_vulnerability,
		"combat_stress_resistance" = combat_stress_resistance,
		"medical_horror_resistance" = medical_horror_resistance,
		"isolation_tolerance" = isolation_tolerance,
	)
