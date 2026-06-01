// SCP Component Effects System
// Advanced dynamic effect system for SCP components

// Effect Base Class
/datum/scp_component_effect
	var/name = "Base Effect"
	var/description = "A base component effect"
	var/effect_id = ""
	var/effect_type = "passive"  // passive, active, triggered, conditional
	var/duration = -1  // -1 for permanent, positive for timed
	var/intensity = 1.0
	var/max_intensity = 10.0
	var/min_intensity = 0.1
	var/effect_state = "inactive"  // inactive, active, suspended, expired
	var/stacks = 1
	var/max_stacks = 1
	var/tick_interval = 30 SECONDS
	var/last_tick = 0
	var/start_time = 0
	var/end_time = 0

	// Target and source
	var/datum/scp_advanced_component/source_component = null
	var/mob/target_mob = null
	var/list/affected_attributes = list()

	// Effect configuration
	var/list/config = list()
	var/list/prerequisites = list()
	var/list/conflicts = list()

/datum/scp_component_effect/New(datum/scp_advanced_component/source, mob/target, list/config_data)
	. = ..()
	source_component = source
	target_mob = target
	config = config_data || list()
	effect_id = generate_effect_id()
	start_time = world.time

	if(duration > 0)
		end_time = start_time + duration

/datum/scp_component_effect/proc/generate_effect_id()
	return "[effect_type]_[name]_[world.time]_[rand(100, 999)]"

/datum/scp_component_effect/proc/can_apply()
	// Check prerequisites
	for(var/prereq in prerequisites)
		if(!check_prerequisite(prereq))
			return FALSE

	// Check conflicts
	if(target_mob && target_mob.SCP && target_mob.SCP.uses_advanced_components)
		var/datum/component_manager_advanced/manager = target_mob.SCP.advanced_components
		for(var/conflict in conflicts)
			if(manager.has_effect(conflict))
				return FALSE

	return TRUE

/datum/scp_component_effect/proc/check_prerequisite(prereq)
	// Override in specific effects
	return TRUE

/datum/scp_component_effect/proc/apply()
	if(!can_apply())
		return FALSE

	effect_state = "active"
	on_apply()
	return TRUE

/datum/scp_component_effect/proc/remove()
	effect_state = "expired"
	on_remove()

/datum/scp_component_effect/proc/process_effect()
	if(effect_state != "active")
		return

	if(world.time < last_tick + tick_interval)
		return

	last_tick = world.time

	// Check if effect has expired
	if(duration > 0 && world.time >= end_time)
		remove()
		return

	on_tick()

/datum/scp_component_effect/proc/modify_intensity(amount)
	intensity = max(min_intensity, min(max_intensity, intensity + amount))
	on_intensity_changed()

/datum/scp_component_effect/proc/add_stack()
	if(stacks < max_stacks)
		stacks++
		on_stack_added()
		return TRUE
	return FALSE

/datum/scp_component_effect/proc/remove_stack()
	if(stacks > 1)
		stacks--
		on_stack_removed()
		return TRUE
	else
		remove()
		return FALSE

// Override these in specific effects
/datum/scp_component_effect/proc/on_apply()
	return

/datum/scp_component_effect/proc/on_remove()
	return

/datum/scp_component_effect/proc/on_tick()
	return

/datum/scp_component_effect/proc/on_intensity_changed()
	return

/datum/scp_component_effect/proc/on_stack_added()
	return

/datum/scp_component_effect/proc/on_stack_removed()
	return

// Specific Effect Types

// Regeneration Effect
/datum/scp_component_effect/regeneration
	name = "Regeneration"
	description = "Heals target over time"
	effect_type = "passive"
	tick_interval = 10 SECONDS
	var/heal_amount = 5

/datum/scp_component_effect/regeneration/on_apply()
	to_chat(target_mob, span_notice("You feel your wounds beginning to heal..."))

/datum/scp_component_effect/regeneration/on_tick()
	if(!target_mob || target_mob.stat == DEAD)
		remove()
		return

	var/actual_heal = heal_amount * intensity * stacks
	if(istype(target_mob, /mob/living))
		var/mob/living/L = target_mob
		L.adjustBruteLoss(-actual_heal)
		L.adjustFireLoss(-actual_heal)

/datum/scp_component_effect/regeneration/on_remove()
	to_chat(target_mob, span_notice("Your regenerative abilities fade."))

// Enhanced Strength Effect
/datum/scp_component_effect/enhanced_strength
	name = "Enhanced Strength"
	description = "Increases physical capabilities"
	effect_type = "passive"
	var/strength_multiplier = 1.5

/datum/scp_component_effect/enhanced_strength/on_apply()
	to_chat(target_mob, span_notice("You feel incredibly strong!"))
	// Apply strength modifiers here

/datum/scp_component_effect/enhanced_strength/on_remove()
	to_chat(target_mob, span_notice("Your enhanced strength fades."))
	// Remove strength modifiers here

// Invisibility Effect
/datum/scp_component_effect/invisibility
	name = "Invisibility"
	description = "Makes target invisible"
	effect_type = "active"
	var/invisibility_level = INVISIBILITY_OBSERVER

/datum/scp_component_effect/invisibility/on_apply()
	to_chat(target_mob, span_notice("You fade from view..."))
	target_mob.invisibility = invisibility_level

/datum/scp_component_effect/invisibility/on_remove()
	to_chat(target_mob, span_notice("You become visible again."))
	target_mob.invisibility = 0

// Psychological Terror Effect
/datum/scp_component_effect/psychological_terror
	name = "Psychological Terror"
	description = "Causes fear and panic in targets"
	effect_type = "triggered"
	tick_interval = 5 SECONDS
	var/terror_intensity = 1

/datum/scp_component_effect/psychological_terror/on_apply()
	to_chat(target_mob, span_danger("An overwhelming sense of dread washes over you..."))

/datum/scp_component_effect/psychological_terror/on_tick()
	if(!target_mob || target_mob.stat == DEAD)
		remove()
		return

	var/terror_messages = list(
		span_danger("You feel like something terrible is about to happen..."),
		span_danger("Your heart pounds with inexplicable fear..."),
		span_danger("You can't shake the feeling that you're being watched..."),
		span_danger("A chill runs down your spine..."),
		span_danger("You feel an overwhelming urge to flee...")
	)

	to_chat(target_mob, pick(terror_messages))
	if(istype(target_mob, /mob/living))
		var/mob/living/L = target_mob
		L.adjustBruteLoss(terror_intensity * intensity)

// Sleep Deprivation Effect
/datum/scp_component_effect/sleep_deprivation
	name = "Sleep Deprivation"
	description = "Prevents sleep and causes fatigue"
	effect_type = "passive"
	tick_interval = 15 SECONDS
	var/fatigue_damage = 2

/datum/scp_component_effect/sleep_deprivation/on_tick()
	if(!target_mob || target_mob.stat == DEAD)
		remove()
		return

	if(istype(target_mob, /mob/living))
		var/mob/living/L = target_mob
		L.adjustToxLoss(fatigue_damage * intensity)

	if(prob(20))
		var/fatigue_messages = list(
			span_warning("You feel incredibly tired but cannot sleep..."),
			span_warning("Your eyelids are heavy, yet rest eludes you..."),
			span_warning("Exhaustion grips you, but sleep is impossible...")
		)
		to_chat(target_mob, pick(fatigue_messages))

// Reality Distortion Effect
/datum/scp_component_effect/reality_distortion
	name = "Reality Distortion"
	description = "Distorts the target's perception of reality"
	effect_type = "conditional"
	tick_interval = 20 SECONDS
	var/distortion_severity = 1

/datum/scp_component_effect/reality_distortion/on_tick()
	if(!target_mob || target_mob.stat == DEAD)
		remove()
		return

	if(prob(30))
		var/distortion_messages = list(
			span_danger("The world around you seems to shift and warp..."),
			span_danger("Reality feels unstable and uncertain..."),
			span_danger("You question what is real and what is not..."),
			span_danger("The boundaries between dream and reality blur...")
		)
		to_chat(target_mob, pick(distortion_messages))

// Effect Manager for Components
/datum/scp_component_effect_manager
	var/name = "Effect Manager"
	var/list/active_effects = list()
	var/list/effect_history = list()
	var/max_history_entries = 100
	var/processing_enabled = TRUE

/datum/scp_component_effect_manager/proc/add_effect(datum/scp_component_effect/effect)
	if(!effect || !effect.can_apply())
		return FALSE

	// Check for existing effect of same type
	var/existing_effect = get_effect_by_type(effect.type)
	if(existing_effect)
		// Try to stack if possible
		return FALSE  // Skip stacking for now to avoid method issues

	active_effects += effect
	effect.apply()
	log_effect_event("EFFECT_ADDED", effect)
	return TRUE

/datum/scp_component_effect_manager/proc/remove_effect(datum/scp_component_effect/effect)
	if(!effect || !(effect in active_effects))
		return FALSE

	active_effects -= effect
	effect.remove()
	log_effect_event("EFFECT_REMOVED", effect)
	return TRUE

/datum/scp_component_effect_manager/proc/get_effect_by_id(effect_id)
	for(var/datum/scp_component_effect/effect in active_effects)
		if(effect.effect_id == effect_id)
			return effect
	return null

/datum/scp_component_effect_manager/proc/get_effect_by_type(effect_type)
	for(var/datum/scp_component_effect/effect in active_effects)
		if(effect.effect_type == effect_type)
			return effect
	return null

/datum/scp_component_effect_manager/proc/has_effect(effect_name)
	for(var/datum/scp_component_effect/effect in active_effects)
		if(effect.name == effect_name)
			return TRUE
	return FALSE

/datum/scp_component_effect_manager/proc/process_effects()
	if(!processing_enabled)
		return

	for(var/datum/scp_component_effect/effect in active_effects)
		effect.process_effect()

		if(effect.effect_state == "expired")
			remove_effect(effect)

/datum/scp_component_effect_manager/proc/clear_all_effects()
	for(var/datum/scp_component_effect/effect in active_effects)
		effect.remove()
	active_effects = list()

/datum/scp_component_effect_manager/proc/get_effect_summary()
	var/list/summary = list()
	summary += "=== Active Effects ==="

	for(var/datum/scp_component_effect/effect in active_effects)
		var/effect_info = "[effect.name] (Intensity: [effect.intensity], Stacks: [effect.stacks])"
		if(effect.duration > 0)
			var/remaining_time = max(0, effect.end_time - world.time)
			effect_info += " - [remaining_time/10] seconds remaining"
		summary += effect_info

	return summary

/datum/scp_component_effect_manager/proc/log_effect_event(event_type, datum/scp_component_effect/effect)
	var/log_entry = list(
		"timestamp" = world.time,
		"event" = event_type,
		"effect_name" = effect.name,
		"effect_id" = effect.effect_id,
		"intensity" = effect.intensity,
		"stacks" = effect.stacks
	)

	effect_history += list(log_entry)

	// Maintain history size
	if(length(effect_history) > max_history_entries)
		effect_history.Cut(1, length(effect_history) - max_history_entries + 1)

// Enhanced Component Manager with Effects
/datum/component_manager_advanced
	var/datum/scp_component_effect_manager/effect_manager = null

/datum/component_manager_advanced/proc/add_effect(effect_type, source_component, config_data)
	if(!effect_manager)
		return FALSE

	var/datum/scp_component_effect/new_effect = new effect_type(source_component, parent_mob, config_data)
	return effect_manager.add_effect(new_effect)

/datum/component_manager_advanced/proc/remove_effect_by_name(effect_name)
	if(!effect_manager)
		return FALSE

	for(var/datum/scp_component_effect/effect in effect_manager.active_effects)
		if(effect.name == effect_name)
			return effect_manager.remove_effect(effect)

	return FALSE

/datum/component_manager_advanced/proc/has_effect(effect_name)
	if(!effect_manager)
		return FALSE

	return effect_manager.has_effect(effect_name)

/datum/component_manager_advanced/proc/process_effects()
	if(effect_manager)
		effect_manager.process_effects()

/datum/component_manager_advanced/proc/get_effects_status()
	if(!effect_manager)
		return list("No effect manager available")

	return effect_manager.get_effect_summary()
