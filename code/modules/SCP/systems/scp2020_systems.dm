// SCP-2020 Modular Systems
// Teleportation, Phasing, and Stealth Systems

// Teleportation System - Manages SCP-2020's teleportation abilities
/datum/scp2020_teleportation_system
	var/mob/living/scp/scp2020/owner
	var/teleport_range = 7
	var/max_teleport_range = 15
	var/teleport_cooldown = 0
	var/teleport_cooldown_time = 30 SECONDS
	var/teleport_mastery = 0
	var/max_teleport_mastery = 100
	var/teleport_events = 0

/datum/scp2020_teleportation_system/New(mob/living/scp/scp2020/new_owner)
	owner = new_owner

/datum/scp2020_teleportation_system/proc/process_teleportation()
	if(!owner)
		return

	// Check for nearby targets or threats
	var/list/nearby_people = list()
	var/list/threats = list()
	for(var/mob/living/carbon/human/H in range(8, owner))
		if(H.stat != DEAD && H != owner)
			nearby_people += H
			// Check if they're a threat (armed, security, etc.)
			if(H.health < H.maxHealth * 0.5 || H.get_active_held_item())
				threats += H

	// Automatic defensive teleportation when threatened
	if(length(threats) > 0 && world.time >= teleport_cooldown && prob(15))
		defensive_teleport(threats)

	// Automatic approach teleportation when hunting/curious
	if(length(nearby_people) > 0 && length(threats) == 0 && world.time >= teleport_cooldown && prob(5))
		approach_teleport(nearby_people)

	// Increase mastery over time
	if(teleport_events > 0 && teleport_mastery < max_teleport_mastery && prob(1))
		increase_teleport_mastery()

/datum/scp2020_teleportation_system/proc/defensive_teleport(list/threats)
	// Find a safe location away from threats
	var/list/safe_turfs = list()
	for(var/turf/T in range(teleport_range, owner))
		if(!T.density)
			var/safe = TRUE
			for(var/mob/living/carbon/human/threat in threats)
				if(get_dist(T, threat) < 4)
					safe = FALSE
					break
			if(safe)
				safe_turfs += T

	if(length(safe_turfs) > 0)
		var/turf/target_turf = pick(safe_turfs)
		perform_teleport(target_turf, "defensive")

/datum/scp2020_teleportation_system/proc/approach_teleport(list/targets)
	// Teleport closer to interesting targets
	var/mob/living/carbon/human/target = pick(targets)
	var/turf/target_turf = get_turf(target)

	if(target_turf)
		var/turf/approach_turf = get_step_towards(target_turf, owner)
		if(approach_turf && !approach_turf.density)
			perform_teleport(approach_turf, "approach")

/datum/scp2020_teleportation_system/proc/perform_teleport(turf/target_turf, teleport_type)
	teleport_cooldown = world.time + teleport_cooldown_time
	teleport_events++

	// Track progression event
	track_scp2020_teleportation(owner, target_turf, teleport_type)

	playsound(owner, 'sound/effects/phasein.ogg', 50)
	owner.forceMove(target_turf)
	playsound(owner, 'sound/effects/phasein.ogg', 50)

	// Announce teleportation
	
	switch(teleport_type)
		if("defensive")
			owner.visible_message("<span class='danger'>[owner] suddenly vanishes from sight!</span>")
		if("approach")
			owner.visible_message("<span class='danger'>[owner] appears suddenly nearby!</span>")

/datum/scp2020_teleportation_system/proc/increase_teleport_mastery()
	teleport_mastery = min(max_teleport_mastery, teleport_mastery + 5)

	// Increase range and reduce cooldown as mastery grows
	if(teleport_mastery > 50)
		teleport_range = min(max_teleport_range, teleport_range + 1)
		teleport_cooldown_time = max(15 SECONDS, teleport_cooldown_time - 1 SECONDS)

// Phasing System - Manages wall phasing abilities
/datum/scp2020_phasing_system
	var/mob/living/scp/scp2020/owner
	var/phasing_cooldown = 0
	var/phasing_cooldown_time = 15 SECONDS
	var/phasing_mastery = 0
	var/max_phasing_mastery = 100
	var/phasing_events = 0

/datum/scp2020_phasing_system/New(mob/living/scp/scp2020/new_owner)
	owner = new_owner

/datum/scp2020_phasing_system/proc/process_phasing()
	if(!owner)
		return

	// Check if blocked by walls and needs to phase
	var/turf/current_turf = get_turf(owner)
	var/blocked = FALSE

	// Check all directions for walls
	for(var/direction in GLOB.cardinals)
		var/turf/check_turf = get_step(current_turf, direction)
		if(check_turf && check_turf.density)
			blocked = TRUE
			break

	// Automatic phasing when movement is blocked and people are nearby
	if(blocked && world.time >= phasing_cooldown)
		var/list/nearby_people = list()
		for(var/mob/living/carbon/human/H in range(6, owner))
			if(H.stat != DEAD && H != owner)
				nearby_people += H

		if(length(nearby_people) > 0 && prob(10))
			attempt_phase_movement()

	// Increase mastery over time
	if(phasing_events > 0 && phasing_mastery < max_phasing_mastery && prob(1))
		increase_phasing_mastery()

/datum/scp2020_phasing_system/proc/attempt_phase_movement()
	// Try to phase through walls in a direction toward nearby people
	var/list/nearby_people = list()
	for(var/mob/living/carbon/human/H in range(8, owner))
		if(H.stat != DEAD && H != owner)
			nearby_people += H

	if(length(nearby_people) == 0)
		return

	var/mob/living/carbon/human/target = pick(nearby_people)
	var/direction = get_dir(owner, target)
	var/turf/target_turf = get_step(get_turf(owner), direction)

	if(target_turf && target_turf.density)
		perform_phase(target_turf)

/datum/scp2020_phasing_system/proc/perform_phase(turf/target_turf)
	phasing_cooldown = world.time + phasing_cooldown_time
	phasing_events++

	playsound(owner, 'sound/effects/phasein.ogg', 50)
	owner.forceMove(target_turf)
	playsound(owner, 'sound/effects/phasein.ogg', 50)

	owner.visible_message("<span class='danger'>[owner] phases through the wall!</span>")

/datum/scp2020_phasing_system/proc/increase_phasing_mastery()
	phasing_mastery = min(max_phasing_mastery, phasing_mastery + 5)

	// Reduce cooldown as mastery grows
	if(phasing_mastery > 50)
		phasing_cooldown_time = max(10 SECONDS, phasing_cooldown_time - 1 SECONDS)

// Stealth System - Manages stealth and evasion abilities
/datum/scp2020_stealth_system
	var/mob/living/scp/scp2020/owner
	var/stealth_level = 0
	var/max_stealth_level = 50
	var/stealth_cooldown = 0
	var/stealth_cooldown_time = 45 SECONDS
	var/stealth_events = 0

/datum/scp2020_stealth_system/New(mob/living/scp/scp2020/new_owner)
	owner = new_owner

/datum/scp2020_stealth_system/proc/process_stealth()
	if(!owner)
		return

	// Check for threats that warrant stealth
	var/list/threats = list()
	for(var/mob/living/carbon/human/H in range(6, owner))
		if(H.stat != DEAD && H != owner)
			// Check if they're a threat (armed, security, etc.)
			if(H.health < H.maxHealth * 0.7 || H.get_active_held_item())
				threats += H

	// Automatic stealth activation when threatened
	if(length(threats) > 1 && world.time >= stealth_cooldown && prob(8))
		activate_stealth()

	// Apply stealth effects
	if(stealth_level > 10)
		apply_stealth_effects()

/datum/scp2020_stealth_system/proc/activate_stealth()
	stealth_cooldown = world.time + stealth_cooldown_time
	stealth_level = min(max_stealth_level, stealth_level + 10)
	stealth_events++

	owner.visible_message("<span class='danger'>[owner] seems to fade slightly from view...</span>")

/datum/scp2020_stealth_system/proc/apply_stealth_effects()
	// Reduce visibility and detection
	var/stealth_factor = stealth_level / max_stealth_level

	// Make it harder for people to target the SCP
	for(var/mob/living/carbon/human/H in range(4, owner))
		if(H.stat != DEAD && H != owner && prob(5 * stealth_factor))
			to_chat(H, "<span class='danger'>You lose sight of the green humanoid for a moment...</span>")

// Hunting System - Manages target acquisition and pursuit
/datum/scp2020_hunting_system
	var/mob/living/scp/scp2020/owner
	var/current_target = null
	var/hunting_intensity = 0
	var/max_hunting_intensity = 100
	var/hunt_cooldown = 0
	var/hunt_cooldown_time = 20 SECONDS
	var/hunting_events = 0

/datum/scp2020_hunting_system/New(mob/living/scp/scp2020/new_owner)
	owner = new_owner

/datum/scp2020_hunting_system/proc/process_hunting()
	if(!owner)
		return

	// Find potential targets
	var/list/potential_targets = list()
	for(var/mob/living/carbon/human/H in range(10, owner))
		if(H.stat != DEAD && H != owner)
			potential_targets += H

	// Select a target if we don't have one
	if(!current_target && length(potential_targets) > 0)
		current_target = pick(potential_targets)
		hunting_intensity = min(max_hunting_intensity, hunting_intensity + 10)

	// Check if current target is still valid
	if(current_target)
		var/mob/living/carbon/human/target = current_target
		if(target.stat == DEAD || get_dist(owner, target) > 15)
			current_target = null
			hunting_intensity = max(0, hunting_intensity - 5)

	// Apply hunting behavior
	if(current_target && world.time >= hunt_cooldown)
		pursue_target()

/datum/scp2020_hunting_system/proc/pursue_target()
	hunt_cooldown = world.time + hunt_cooldown_time
	hunting_events++

	var/mob/living/carbon/human/target = current_target
	var/distance = get_dist(owner, target)

	if(distance > 3)
		// Try to get closer
		owner.visible_message("<span class='danger'>[owner] moves purposefully toward [target]!</span>")
	else
		// Close enough to interact
		owner.visible_message("<span class='danger'>[owner] studies [target] intently...</span>")
		to_chat(target, "<span class='danger'>The green humanoid seems very interested in you...</span>")

// Research System - Collects data on SCP-2020's abilities
/datum/scp2020_research_system
	var/mob/living/scp/scp2020/owner
	var/list/research_data = list()

/datum/scp2020_research_system/New(mob/living/scp/scp2020/new_owner)
	owner = new_owner

/datum/scp2020_research_system/proc/process_research()
	if(!owner)
		return

	// Collect research data (SCP-2020 is harmless — no active abilities)
	var/list/current_data = list(
		"cliche_count" = 0,
		"narrative_count" = 0,
		"dramatic_gestures" = 0
	)

	// Store data for research integration
	research_data = current_data

/datum/scp2020_research_system/proc/contribute_research_data()
	if(!owner || !owner.SCP)
		return

	// Store research data for later integration
	// Note: Research integration will be handled by the main SCP system
