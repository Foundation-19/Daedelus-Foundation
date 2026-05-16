// SCP-106 System Datums
// Phasing, Pocket Dimensions, Corrosion, Hunting, Containment, and Research
// All cooldowns are server-side and prevent ability spam.

// ========================================
// DIMENSIONAL PHASING SYSTEM
// ========================================

/datum/scp106_phasing_system
	var/mob/living/scp/scp106/owner = null
	var/dimensional_energy = SCP106_INITIAL_DIMENSIONAL_ENERGY
	var/max_dimensional_energy = SCP106_MAX_DIMENSIONAL_ENERGY
	var/phase_range = SCP106_BASE_PHASE_RANGE
	var/max_phase_range = SCP106_MAX_PHASE_RANGE
	var/corrosion_trail = TRUE
	var/phase_cooldown = 0
	var/phase_cooldown_time = SCP106_PHASE_COOLDOWN
	var/last_phase = 0
	var/phase_energy_regen = SCP106_ENERGY_REGEN_AMOUNT
	var/phase_energy_regen_interval = SCP106_ENERGY_REGEN_INTERVAL
	var/last_energy_regen = 0

/datum/scp106_phasing_system/New(mob/living/scp/scp106/new_owner)
	. = ..()
	owner = new_owner

/datum/scp106_phasing_system/Destroy()
	owner = null
	return ..()

/datum/scp106_phasing_system/proc/process_phasing()
	if(world.time >= last_energy_regen + phase_energy_regen_interval)
		dimensional_energy = min(max_dimensional_energy, dimensional_energy + phase_energy_regen)
		last_energy_regen = world.time

	if(phase_cooldown > 0)
		phase_cooldown = max(0, phase_cooldown - 1)

/datum/scp106_phasing_system/proc/phase_through_wall(turf/target_turf)
	if(phase_cooldown > 0)
		to_chat(owner, span_warning("You cannot phase again so soon."))
		return FALSE

	if(dimensional_energy < 20)
		to_chat(owner, span_warning("Not enough dimensional energy to phase."))
		return FALSE

	if(!target_turf || !can_phase_to(target_turf))
		return FALSE

	var/phase_cost = calculate_phase_cost(target_turf)
	if(dimensional_energy < phase_cost)
		to_chat(owner, span_warning("Not enough dimensional energy to phase that far."))
		return FALSE

	dimensional_energy -= phase_cost
	phase_cooldown = phase_cooldown_time
	last_phase = world.time

	var/old_loc = owner.loc
	owner.forceMove(target_turf)

	playsound(owner, 'sound/scp/106/wall_decay.ogg', 50, 0)
	owner.visible_message(span_danger("[owner] sinks through the floor and resurfaces!"))

	if(corrosion_trail && owner.corrosion_system)
		create_corrosion_trail(old_loc, target_turf)

	owner.leave_corrosion_pool(target_turf)

	return TRUE

/datum/scp106_phasing_system/proc/can_phase_to(turf/target)
	if(!target)
		return FALSE
	if(!istype(target, /turf/open))
		return FALSE
	if(get_dist(owner, target) > phase_range)
		return FALSE
	return TRUE

/datum/scp106_phasing_system/proc/calculate_phase_cost(turf/target)
	var/distance = get_dist(owner, target)
	var/base_cost = SCP106_BASE_PHASE_COST
	var/distance_cost = distance * SCP106_PHASE_COST_PER_DISTANCE
	return max(10, base_cost + distance_cost - SCP106_PHASE_MASTERY_DISCOUNT)

/datum/scp106_phasing_system/proc/create_corrosion_trail(turf/start, turf/end)
	var/list/trail_turfs = get_line(start, end)
	for(var/turf/T in trail_turfs)
		if(T != start && T != end)
			owner.leave_corrosion_pool(T)

/datum/scp106_phasing_system/proc/emerge_from_surface()
	var/list/valid_turfs = list()
	for(var/turf/open/T in range(phase_range, owner))
		valid_turfs += T
	if(length(valid_turfs) > 0)
		return phase_through_wall(pick(valid_turfs))
	return FALSE

// ========================================
// POCKET DIMENSION SYSTEM
// ========================================

/datum/scp106_pocket_dimension_system
	var/mob/living/scp/scp106/owner = null
	var/list/active_dimensions = list()
	var/dimension_capacity = SCP106_INITIAL_DIMENSION_CAPACITY
	var/dimension_stability = 100
	var/extraction_difficulty = 50
	var/dimension_energy_cost = 15
	var/dimension_maintenance_interval = 60 SECONDS
	var/last_maintenance = 0

/datum/scp106_pocket_dimension_system/New(mob/living/scp/scp106/new_owner)
	. = ..()
	owner = new_owner

/datum/scp106_pocket_dimension_system/Destroy()
	active_dimensions = null
	owner = null
	return ..()

/datum/scp106_pocket_dimension_system/proc/process_dimensions()
	if(world.time >= last_maintenance + dimension_maintenance_interval)
		maintain_dimensions()
		last_maintenance = world.time

/datum/scp106_pocket_dimension_system/proc/create_pocket_dimension(dimension_type = "decay_chamber")
	if(length(active_dimensions) >= dimension_capacity)
		to_chat(owner, span_warning("You cannot sustain another pocket dimension."))
		return null

	if(!owner.phasing_system || owner.phasing_system.dimensional_energy < dimension_energy_cost)
		to_chat(owner, span_warning("Not enough dimensional energy to create a pocket dimension."))
		return null

	var/dimension_id = "dimension_[world.time]"
	active_dimensions[dimension_id] = list(
		"id" = dimension_id,
		"type" = dimension_type,
		"created_time" = world.time,
		"victims" = list(),
		"torture_level" = 0,
		"stability" = dimension_stability,
		"extraction_difficulty" = extraction_difficulty
	)

	owner.phasing_system.dimensional_energy -= dimension_energy_cost
	return dimension_id

/datum/scp106_pocket_dimension_system/proc/drag_victim_to_dimension(mob/living/carbon/human/victim, dimension_id)
	if(!victim || victim.stat == DEAD)
		return FALSE
	if(!active_dimensions[dimension_id])
		var/fallback_id = active_dimensions[1] ? active_dimensions[1] : null
		if(!fallback_id)
			return FALSE
		dimension_id = fallback_id

	var/list/dimension_data = active_dimensions[dimension_id]
	var/list/victims = dimension_data["victims"]

	victims[victim.name] = list(
		"mob" = victim,
		"capture_time" = world.time,
		"torture_level" = 0,
		"escape_attempts" = 0
	)

	apply_dimension_effects(victim, dimension_data)

	victim.visible_message(span_danger("[victim] is dragged into the floor by [owner]!"))
	playsound(victim, 'sound/scp/106/decay1.ogg', 50, 0)

	return TRUE

/datum/scp106_pocket_dimension_system/proc/manage_dimension_torture(dimension_id)
	if(!active_dimensions[dimension_id])
		return
	var/list/dimension_data = active_dimensions[dimension_id]
	for(var/victim_name in dimension_data["victims"])
		var/list/victim_data = dimension_data["victims"][victim_name]
		var/mob/living/carbon/human/victim = victim_data["mob"]
		if(QDELETED(victim))
			dimension_data["victims"] -= victim_name
			continue
		if(victim.stat != DEAD)
			apply_torture_effects(victim, dimension_data)
			if(prob(3))
				attempt_victim_escape(victim, dimension_data)

/datum/scp106_pocket_dimension_system/proc/apply_dimension_effects(mob/living/carbon/human/victim, list/dimension_data)
	if(victim.sanity)
		victim.sanity.adjust_sanity(-25, "pocket_dimension_entry")
	victim.adjustBruteLoss(10)
	victim.adjustToxLoss(5)

/datum/scp106_pocket_dimension_system/proc/apply_torture_effects(mob/living/carbon/human/victim, list/dimension_data)
	var/torture_level = dimension_data["torture_level"]
	victim.adjustBruteLoss(3 + torture_level * 0.3)
	victim.adjustToxLoss(2 + torture_level * 0.2)
	if(victim.sanity)
		victim.sanity.adjust_sanity(-(5 + torture_level * 0.5), "pocket_dimension_torture")
	dimension_data["torture_level"] = min(100, torture_level + 1)

/datum/scp106_pocket_dimension_system/proc/attempt_victim_escape(mob/living/carbon/human/victim, list/dimension_data)
	var/escape_chance = max(1, 5 - dimension_data["extraction_difficulty"] / 10)
	if(prob(escape_chance))
		release_victim_from_dimension(victim, dimension_data)
		return TRUE
	return FALSE

/datum/scp106_pocket_dimension_system/proc/release_victim_from_dimension(mob/living/carbon/human/victim, list/dimension_data)
	var/list/victims = dimension_data["victims"]
	for(var/victim_name in victims)
		var/list/victim_data = victims[victim_name]
		if(victim_data["mob"] == victim)
			victims -= victim_name
			break

	var/turf/escape_location = owner.pocket_dimension_turf || get_turf(owner)
	if(escape_location)
		victim.forceMove(escape_location)
		victim.visible_message(span_notice("[victim] is ejected from the floor, gasping!"))
		playsound(victim, 'sound/scp/106/decay2.ogg', 50, 0)
		owner.on_pocket_escape(victim)

/datum/scp106_pocket_dimension_system/proc/maintain_dimensions()
	for(var/dimension_id in active_dimensions)
		var/list/dimension_data = active_dimensions[dimension_id]
		dimension_data["stability"] = max(0, dimension_data["stability"] - 1)
		if(dimension_data["stability"] <= 0)
			collapse_dimension(dimension_id)
		else
			manage_dimension_torture(dimension_id)

/datum/scp106_pocket_dimension_system/proc/collapse_dimension(dimension_id)
	if(!active_dimensions[dimension_id])
		return
	var/list/dimension_data = active_dimensions[dimension_id]
	for(var/victim_name in dimension_data["victims"])
		var/list/victim_data = dimension_data["victims"][victim_name]
		var/mob/living/carbon/human/victim = victim_data["mob"]
		if(victim)
			release_victim_from_dimension(victim, dimension_data)
	active_dimensions -= dimension_id

// ========================================
// CORROSION SYSTEM
// ========================================

/datum/scp106_corrosion_system
	var/mob/living/scp/scp106/owner = null
	var/corrosion_potency = 50
	var/corrosion_spread = 2
	var/material_dissolution = 10
	var/environmental_impact = 25
	var/corrosion_cooldown = 0
	var/corrosion_cooldown_time = 10 SECONDS
	var/last_corrosion = 0

/datum/scp106_corrosion_system/New(mob/living/scp/scp106/new_owner)
	. = ..()
	owner = new_owner

/datum/scp106_corrosion_system/Destroy()
	owner = null
	return ..()

/datum/scp106_corrosion_system/proc/process_corrosion()
	if(corrosion_cooldown > 0)
		corrosion_cooldown = max(0, corrosion_cooldown - 1)
		return
	if(!owner || owner.stat == DEAD)
		return
	if(prob(15))
		for(var/turf/closed/wall/scp_containment/C in range(1, owner))
			try_scp_corrode_wall(owner, C, corrosion_potency * 0.3)
			corrosion_cooldown = 5
			return

// ========================================
// HUNTING SYSTEM
// ========================================

/datum/scp106_hunting_system
	var/mob/living/scp/scp106/owner = null
	var/hunt_mode = FALSE
	var/mob/living/carbon/human/current_target = null
	var/stalking_cooldown = 0
	var/stalking_cooldown_time = 45 SECONDS
	var/psychological_pressure_cooldown = 0
	var/psychological_pressure_interval = 60 SECONDS
	var/stalking_phase = SCP106_STALK_INACTIVE
	var/stalking_timer_id = null
	var/stalking_start_time = 0
	var/stalking_duration = 0
	var/last_stalk_event = 0
	var/next_stalk_event_interval = 8 SECONDS

/datum/scp106_hunting_system/New(mob/living/scp/scp106/new_owner)
	. = ..()
	owner = new_owner

/datum/scp106_hunting_system/Destroy()
	deltimer(stalking_timer_id)
	current_target = null
	owner = null
	return ..()

/datum/scp106_hunting_system/proc/process_hunting()
	if(stalking_cooldown > 0)
		stalking_cooldown = max(0, stalking_cooldown - 1)
	if(psychological_pressure_cooldown > 0)
		psychological_pressure_cooldown = max(0, psychological_pressure_cooldown - 1)

	if(hunt_mode && current_target)
		execute_hunt()

	if(stalking_phase != SCP106_STALK_INACTIVE && current_target)
		process_stalking()

	if(!psychological_pressure_cooldown)
		induce_psychological_pressure()
		psychological_pressure_cooldown = psychological_pressure_interval

/datum/scp106_hunting_system/proc/select_preferred_target()
	var/list/candidates = list()
	for(var/mob/living/carbon/human/H in view(10, owner))
		if(H.stat != DEAD && H != owner)
			candidates[H] = calculate_target_score(H)
	if(length(candidates) > 0)
		var/best_score = -INFINITY
		var/mob/living/carbon/human/best_target = null
		for(var/mob/living/carbon/human/H in candidates)
			var/score = candidates[H]
			if(score > best_score)
				best_score = score
				best_target = H
		current_target = best_target
		hunt_mode = TRUE
		begin_stalking(best_target)
		return TRUE
	return FALSE

/datum/scp106_hunting_system/proc/calculate_target_score(mob/living/carbon/human/target)
	var/score = 0
	var/nearby_allies = 0
	for(var/mob/living/carbon/human/H in view(3, target))
		if(H != target && H.stat != DEAD)
			nearby_allies++
	score += (5 - nearby_allies) * 10
	if(target.age < 30)
		score += 15
	if(target.health < 50)
		score += 20
	return score

/datum/scp106_hunting_system/proc/begin_stalking(mob/living/carbon/human/target)
	if(stalking_phase != SCP106_STALK_INACTIVE)
		return FALSE
	if(!target || target.stat == DEAD)
		return FALSE
	current_target = target
	stalking_phase = SCP106_STALK_APPROACH
	stalking_start_time = world.time
	stalking_duration = rand(30 SECONDS, 90 SECONDS)
	last_stalk_event = world.time
	stalking_timer_id = addtimer(CALLBACK(src, /datum/scp106_hunting_system/proc/end_stalking), stalking_duration, TIMER_STOPPABLE)
	to_chat(owner, span_notice("You begin stalking [target]... The hunt has begun."))
	return TRUE

/datum/scp106_hunting_system/proc/process_stalking()
	if(!current_target || current_target.stat == DEAD)
		end_stalking()
		return
	if(world.time < last_stalk_event + next_stalk_event_interval)
		return
	last_stalk_event = world.time
	var/elapsed = world.time - stalking_start_time
	var/progress = elapsed / stalking_duration
	switch(stalking_phase)
		if(SCP106_STALK_APPROACH)
			stalk_event_approach(current_target, progress)
			if(progress >= 0.25)
				stalking_phase = SCP106_STALK_DREAD
		if(SCP106_STALK_DREAD)
			stalk_event_dread(current_target, progress)
			if(progress >= 0.55)
				stalking_phase = SCP106_STALK_TERROR
		if(SCP106_STALK_TERROR)
			stalk_event_terror(current_target, progress)
	next_stalk_event_interval = max(4 SECONDS, 10 SECONDS - (progress * 6 SECONDS))

/datum/scp106_hunting_system/proc/stalk_event_approach(mob/living/carbon/human/target, progress)
	if(prob(40))
		to_chat(target, span_warning("You hear a wet dripping sound nearby..."))
		playsound(target, 'sound/scp/106/decay1.ogg', 15, TRUE)
	else if(prob(30))
		to_chat(target, span_warning("The air feels colder suddenly."))
	if(target.sanity)
		target.sanity.adjust_sanity(-3, "scp106_stalking")

/datum/scp106_hunting_system/proc/stalk_event_dread(mob/living/carbon/human/target, progress)
	if(prob(35))
		var/static/list/dread_messages = list(
			"You catch a glimpse of something black and rotting in your peripheral vision.",
			"You smell rust and decay. It wasn't there a moment ago.",
			"You feel something watching you from the shadows.",
			"A dark stain seems to spread across the floor nearby, then vanishes.",
		)
		to_chat(target, span_warning(pick(dread_messages)))
		playsound(target, 'sound/effects/ghost2.ogg', 25, TRUE)
	else if(prob(25))
		target.visible_message(span_warning("[target] flinches, looking around fearfully..."), span_warning("You feel an overwhelming urge to run."))
	if(target.sanity)
		target.sanity.adjust_sanity(-6, "scp106_stalking")
	if(owner && prob(15))
		var/turf/T = get_turf(target)
		owner.leave_corrosion_pool(get_step(T, pick(GLOB.cardinals)))

/datum/scp106_hunting_system/proc/stalk_event_terror(mob/living/carbon/human/target, progress)
	if(prob(30))
		var/static/list/terror_messages = list(
			"A decayed hand reaches out from the wall beside you, then withdraws!",
			"The floor beneath you bubbles with a foul black substance!",
			"You hear scraping sounds coming from inside the walls.",
			"Something brushes against your leg from below. It's cold and wet.",
		)
		to_chat(target, span_boldwarning(pick(terror_messages)))
		playsound(target, 'sound/effects/phasein.ogg', 40, TRUE)
	else if(prob(20))
		target.visible_message(span_boldwarning("[target] screams, stumbling backwards!"), span_boldwarning("YOU CAN FEEL IT. IT'S RIGHT BEHIND YOU."))
		playsound(target, 'sound/effects/ghost.ogg', 50, TRUE)
	if(target.sanity)
		target.sanity.adjust_sanity(-10, "scp106_stalking")
	if(owner)
		var/turf/T = get_turf(target)
		for(var/i in 1 to rand(1, 3))
			owner.leave_corrosion_pool(get_step(T, pick(GLOB.cardinals)))
	if(prob(20) && target.stamina)
		target.stamina.adjust(-15)

/datum/scp106_hunting_system/proc/end_stalking()
	deltimer(stalking_timer_id)
	stalking_timer_id = null
	stalking_phase = SCP106_STALK_INACTIVE
	if(current_target && current_target.stat != DEAD)
		hunt_mode = TRUE
		to_chat(owner, span_notice("The stalking is over. [current_target] is yours to take."))
		if(current_target.sanity)
			current_target.sanity.adjust_sanity(-5, "scp106_stalking_climax")

/datum/scp106_hunting_system/proc/stalk_target(mob/living/carbon/human/target)
	if(stalking_phase != SCP106_STALK_INACTIVE)
		return begin_stalking(target)
	if(stalking_cooldown > 0)
		return FALSE
	if(!target || target.stat == DEAD)
		return FALSE
	return begin_stalking(target)

/datum/scp106_hunting_system/proc/execute_hunt()
	if(!current_target || current_target.stat == DEAD || get_dist(owner, current_target) > 15)
		current_target = null
		hunt_mode = FALSE
		stalking_phase = SCP106_STALK_INACTIVE
		deltimer(stalking_timer_id)
		return

/datum/scp106_hunting_system/proc/induce_psychological_pressure()
	for(var/mob/living/carbon/human/H in view(7, owner))
		if(H.stat == DEAD || H == owner)
			continue
		if(H.sanity)
			H.sanity.adjust_sanity(-5, "scp106_presence")
		if(prob(20))
			to_chat(H, span_warning("You feel an overwhelming sense of dread..."))

// ========================================
// CONTAINMENT SYSTEM
// ========================================

/datum/scp106_containment_system
	var/mob/living/scp/scp106/owner = null
	var/containment_status = "contained"
	var/breach_capability = SCP106_INITIAL_BREACH_CAPABILITY
	var/max_breach_capability = SCP106_MAX_BREACH_CAPABILITY
	var/escape_motivation = 0
	var/max_escape_motivation = 100
	var/femur_breaker_response = 0
	var/max_femur_breaker_response = 100
	var/containment_integrity = 100
	var/max_containment_integrity = 100
	var/last_breach_attempt = 0
	var/breach_attempt_cooldown = SCP106_BREACH_ATTEMPT_COOLDOWN

/datum/scp106_containment_system/New(mob/living/scp/scp106/new_owner)
	. = ..()
	owner = new_owner

/datum/scp106_containment_system/Destroy()
	owner = null
	return ..()

/datum/scp106_containment_system/proc/process_containment()
	update_containment_status()
	if(escape_motivation >= SCP106_BREACH_MOTIVATION_THRESHOLD && world.time >= last_breach_attempt + breach_attempt_cooldown)
		attempt_containment_breach()
	escape_motivation = min(max_escape_motivation, escape_motivation + SCP106_MOTIVATION_ESCALATION * 0.1)

/datum/scp106_containment_system/proc/update_containment_status()
	var/area/current_area = get_area(owner)
	if(current_area)
		if(findtext(current_area.name, "containment") || findtext(current_area.name, "SCP-106"))
			containment_status = "contained"
		else
			containment_status = "breached"

/datum/scp106_containment_system/proc/attempt_containment_breach()
	if(containment_status == "breached")
		return FALSE
	last_breach_attempt = world.time
	var/breach_chance = breach_capability / 10
	if(prob(breach_chance))
		containment_status = "breached"
		escape_motivation = 0
		owner.visible_message(span_danger("SCP-106 has breached containment!"))
		return TRUE
	return FALSE

/datum/scp106_containment_system/proc/respond_to_femur_breaker()
	femur_breaker_response = min(max_femur_breaker_response, femur_breaker_response + 25)
	if(femur_breaker_response >= 50)
		force_return_to_containment()
		femur_breaker_response = 0
	return TRUE

/datum/scp106_containment_system/proc/force_return_to_containment()
	var/turf/containment_turf = null
	for(var/obj/machinery/scp_femur_breaker/fb as anything in INSTANCES_OF(/obj/machinery/scp_femur_breaker))
		containment_turf = get_turf(fb)
		break
	if(!containment_turf)
		for(var/area/scp/hcz/keter_containment/KA in get_sorted_areas())
			for(var/turf/T in KA.get_contained_turfs())
				if(istype(T, /turf/open))
					containment_turf = T
					break
			if(containment_turf)
				break
	if(!containment_turf)
		return FALSE
	owner.forceMove(containment_turf)
	owner.in_pocket_dimension = FALSE
	containment_status = "contained"
	hook_scp_recontainment("SCP-106", list("method" = "femur_breaker", "integrity" = containment_integrity))
	owner.visible_message(span_notice("SCP-106 has been returned to containment."))
	return TRUE

/datum/scp106_containment_system/proc/resist_re_containment()
	var/resistance_chance = escape_motivation / 10
	if(prob(resistance_chance))
		return TRUE
	return FALSE

/datum/scp106_containment_system/proc/escalate_breach_attempt()
	escape_motivation = min(max_escape_motivation, escape_motivation + SCP106_MOTIVATION_ESCALATION)
	breach_capability = min(max_breach_capability, breach_capability + 5)

// ========================================
// RESEARCH INTEGRATION SYSTEM
// ========================================

/datum/scp106_research_integration
	var/mob/living/scp/scp106/owner = null
	var/list/research_data = list()
	var/last_research_update = 0
	var/research_update_interval = 120 SECONDS

/datum/scp106_research_integration/New(mob/living/scp/scp106/new_owner)
	. = ..()
	owner = new_owner

/datum/scp106_research_integration/Destroy()
	research_data = null
	owner = null
	return ..()

/datum/scp106_research_integration/proc/process_research()
	if(world.time >= last_research_update + research_update_interval)
		update_research_data()
		last_research_update = world.time

/datum/scp106_research_integration/proc/update_research_data()
	research_data["last_update"] = list(
		"dimensional_energy" = owner.phasing_system?.dimensional_energy || 0,
		"active_dimensions" = length(owner.pocket_dimension_system?.active_dimensions) || 0,
		"corrosion_potency" = owner.corrosion_system?.corrosion_potency || 0,
		"containment_status" = owner.containment_system?.containment_status || "unknown",
		"in_pocket_dimension" = owner.in_pocket_dimension,
		"timestamp" = world.time
	)
