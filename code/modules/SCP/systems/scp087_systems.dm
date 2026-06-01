// SCP-087 Modular Systems
// Stairwell Descent, Entity, and Horror Systems

// Descent System - Manages the endless stairwell effect
/datum/scp087_descent_system
	var/obj/structure/scp087/owner
	var/descent_level = 0
	var/max_descent_level = 100
	var/descent_intensity = 0
	var/max_descent_intensity = 50
	var/descent_cooldown = 0
	var/descent_cooldown_time = 30 SECONDS
	var/descents_performed = 0

/datum/scp087_descent_system/New(obj/structure/scp087/new_owner)
	owner = new_owner

/datum/scp087_descent_system/proc/process_descent()
	if(!owner)
		return

	// Check for nearby targets to trigger descent effects
	var/list/nearby_targets = list()
	for(var/mob/living/carbon/human/H in range(5, owner))
		if(H.stat != DEAD)
			nearby_targets += H

	// Automatic descent progression when people are nearby
	if(length(nearby_targets) > 0 && prob(3))
		progress_descent()

	// Automatic intensity increase when multiple people are present
	if(length(nearby_targets) > 2 && world.time >= descent_cooldown)
		increase_descent_intensity()

/datum/scp087_descent_system/proc/progress_descent()
	descent_level = min(max_descent_level, descent_level + 1)
	descents_performed++

	// Announce descent to nearby people
	for(var/mob/living/carbon/human/H in range(5, owner))
		if(H.stat != DEAD)
			to_chat(H, span_danger("The stairwell seems to descend deeper into endless darkness..."))

/datum/scp087_descent_system/proc/increase_descent_intensity()
	descent_cooldown = world.time + descent_cooldown_time
	descent_intensity = min(max_descent_intensity, descent_intensity + 5)

	// Create more intense effects as descent increases
	for(var/mob/living/carbon/human/H in range(4, owner))
		if(H.stat != DEAD)
			to_chat(H, span_danger("The darkness below grows more oppressive and infinite..."))
			if(descent_intensity > 30)
				H.adjustBruteLoss(2) // Physical strain from the psychological pressure

// Horror System - Manages psychological effects
/datum/scp087_horror_system
	var/obj/structure/scp087/owner
	var/psychological_horror = 0
	var/max_psychological_horror = 50
	var/horror_intensity = 0
	var/max_horror_intensity = 50
	var/horror_cooldown = 0
	var/horror_cooldown_time = 20 SECONDS
	var/horror_events = 0

/datum/scp087_horror_system/New(obj/structure/scp087/new_owner)
	owner = new_owner

/datum/scp087_horror_system/proc/process_horror()
	if(!owner)
		return

	// Automatic horror buildup when people are nearby
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in range(5, owner))
		if(H.stat != DEAD)
			targets += H

	if(length(targets) > 0 && prob(2))
		increase_psychological_horror()

	// Apply horror effects to nearby targets
	if(psychological_horror > 10 && length(targets) > 0)
		apply_horror_effects(targets)

/datum/scp087_horror_system/proc/increase_psychological_horror()
	psychological_horror = min(max_psychological_horror, psychological_horror + 3)
	horror_events++

/datum/scp087_horror_system/proc/apply_horror_effects(list/targets)
	for(var/mob/living/carbon/human/H in targets)
		// Scale effects based on horror level
		var/horror_intensity_factor = psychological_horror / max_psychological_horror

		if(prob(10 * horror_intensity_factor))
			to_chat(H, span_danger("You feel an overwhelming sense of dread and despair..."))
			H.adjustBruteLoss(3)

		if(prob(5 * horror_intensity_factor))
			to_chat(H, span_danger("The darkness seems to whisper unspeakable things..."))
			if(H.stamina)
				H.stamina.adjust(-10)

/datum/scp087_horror_system/proc/intensify_horror()
	if(world.time < horror_cooldown)
		return

	horror_cooldown = world.time + horror_cooldown_time
	horror_intensity = min(max_horror_intensity, horror_intensity + 10)

	// More intense horror effects
	for(var/mob/living/carbon/human/H in range(6, owner))
		if(H.stat != DEAD)
			to_chat(H, span_danger("The psychological pressure becomes almost unbearable..."))
			if(horror_intensity > 30)
				H.adjustBruteLoss(5)
				if(H.stamina)
					H.stamina.adjust(-15)

// Entity System - Manages the mysterious entity presence
/datum/scp087_entity_system
	var/obj/structure/scp087/owner
	var/entity_encounters = 0
	var/max_entity_encounters = 25
	var/entity_presence = 0
	var/max_entity_presence = 25
	var/entity_cooldown = 0
	var/entity_cooldown_time = 45 SECONDS
	var/entity_events = 0

/datum/scp087_entity_system/New(obj/structure/scp087/new_owner)
	owner = new_owner

/datum/scp087_entity_system/proc/process_entity()
	if(!owner)
		return

	// Check for nearby targets
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in range(4, owner))
		if(H.stat != DEAD)
			targets += H

	// Automatic entity manifestation when people venture too close
	if(length(targets) > 0 && prob(1))
		manifest_entity_presence()

	// Entity encounters become more likely with more people
	if(length(targets) > 1 && world.time >= entity_cooldown && prob(3))
		create_entity_encounter(targets)

/datum/scp087_entity_system/proc/manifest_entity_presence()
	entity_presence = min(max_entity_presence, entity_presence + 2)
	entity_events++

	// Announce entity presence
	for(var/mob/living/carbon/human/H in range(4, owner))
		if(H.stat != DEAD)
			to_chat(H, span_danger("You sense something watching you from the depths below..."))

/datum/scp087_entity_system/proc/create_entity_encounter(list/targets)
	entity_cooldown = world.time + entity_cooldown_time
	entity_encounters = min(max_entity_encounters, entity_encounters + 1)
	entity_events++

	// Create encounter effects
	var/encounter_type = pick("sounds", "movement", "presence", "terror")

	switch(encounter_type)
		if("sounds")
			for(var/mob/living/carbon/human/H in targets)
				to_chat(H, span_danger("You hear something moving in the darkness below..."))
				playsound(owner, 'sound/effects/ghost.ogg', 30, 0)

		if("movement")
			for(var/mob/living/carbon/human/H in targets)
				to_chat(H, span_danger("Something shifts in the shadows far below..."))
				H.adjustBruteLoss(2)

		if("presence")
			for(var/mob/living/carbon/human/H in targets)
				to_chat(H, span_danger("You feel the unmistakable presence of something malevolent..."))
				if(H.stamina)
					H.stamina.adjust(-20)

		if("terror")
			for(var/mob/living/carbon/human/H in targets)
				to_chat(H, span_danger("A wave of pure terror washes over you!"))
				H.adjustBruteLoss(5)
				if(H.stamina)
					H.stamina.adjust(-15)

// Environmental System - Manages darkness and atmospheric effects
/datum/scp087_environmental_system
	var/obj/structure/scp087/owner
	var/darkness_level = 1
	var/max_darkness_level = 5
	var/atmospheric_pressure = 1.0
	var/temperature_drop = 0
	var/darkness_events = 0

/datum/scp087_environmental_system/New(obj/structure/scp087/new_owner)
	owner = new_owner

/datum/scp087_environmental_system/proc/process_environment()
	if(!owner)
		return

	// Automatic darkness progression
	var/list/nearby_people = list()
	for(var/mob/living/carbon/human/H in range(6, owner))
		if(H.stat != DEAD)
			nearby_people += H

	// Darkness increases with prolonged presence
	if(length(nearby_people) > 0 && prob(1))
		increase_darkness()

	// Apply environmental effects
	if(darkness_level > 2)
		apply_environmental_effects(nearby_people)

/datum/scp087_environmental_system/proc/increase_darkness()
	if(darkness_level < max_darkness_level)
		darkness_level++
		darkness_events++

		for(var/mob/living/carbon/human/H in range(6, owner))
			if(H.stat != DEAD)
				to_chat(H, span_danger("The darkness grows deeper and more oppressive..."))

/datum/scp087_environmental_system/proc/apply_environmental_effects(list/targets)
	for(var/mob/living/carbon/human/H in targets)
		// Effects scale with darkness level
		var/darkness_factor = darkness_level / max_darkness_level

		if(prob(5 * darkness_factor))
			to_chat(H, span_danger("The oppressive darkness makes it hard to breathe..."))
			if(H.stamina)
				H.stamina.adjust(-8)

		if(prob(3 * darkness_factor))
			to_chat(H, span_danger("The supernatural cold chills you to the bone..."))
			H.adjustBruteLoss(1)

// Research System - Collects data on SCP-087's effects
/datum/scp087_research_system
	var/obj/structure/scp087/owner
	var/list/research_data = list()

/datum/scp087_research_system/New(obj/structure/scp087/new_owner)
	owner = new_owner

/datum/scp087_research_system/proc/process_research()
	if(!owner)
		return

	// Collect research data
	var/list/current_data = list(
		"descent_level" = owner.descent_system ? owner.descent_system.descent_level : 0,
		"descent_intensity" = owner.descent_system ? owner.descent_system.descent_intensity : 0,
		"psychological_horror" = owner.horror_system ? owner.horror_system.psychological_horror : 0,
		"horror_intensity" = owner.horror_system ? owner.horror_system.horror_intensity : 0,
		"entity_encounters" = owner.entity_system ? owner.entity_system.entity_encounters : 0,
		"entity_presence" = owner.entity_system ? owner.entity_system.entity_presence : 0,
		"darkness_level" = owner.environmental_system ? owner.environmental_system.darkness_level : 1,
		"descents_performed" = owner.descent_system ? owner.descent_system.descents_performed : 0,
		"horror_events" = owner.horror_system ? owner.horror_system.horror_events : 0,
		"entity_events" = owner.entity_system ? owner.entity_system.entity_events : 0,
		"darkness_events" = owner.environmental_system ? owner.environmental_system.darkness_events : 0
	)

	// Store data for research integration
	research_data = current_data

/datum/scp087_research_system/proc/contribute_research_data()
	if(!owner || !owner.SCP)
		return

	// Store research data for later integration
	// Note: Research integration will be handled by the main SCP system
