/mob/living/scp
	name = "SCP Entity"
	desc = "A mysterious SCP entity."
	real_name = "SCP Entity"
	status_flags = 0
	hud_possible = list()
	hud_type = /datum/hud
	var/scp_designation = ""
	var/scp_class = ""
	var/scp_name = ""
	var/obj_damage = 50
	melee_damage_lower = 15
	melee_damage_upper = 25
	var/melee_damage_type = BRUTE
	var/environment_smash = ENVIRONMENT_SMASH_WALLS
	var/friendly_verb_continuous = "nudges"
	var/friendly_verb_simple = "nudge"
	var/attack_verb_continuous = "attacks"
	var/attack_verb_simple = "attack"
	var/attack_sound = 'sound/weapons/punch1.ogg'
	var/sharpness = NONE
	var/armor_penetration = 10

	var/containment_status = "contained"
	var/breach_count = 0
	var/last_breach_time = 0
	var/scp_health = 100
	var/max_scp_health = 100
	var/scp_armor = 0
	var/max_scp_armor = 50

	var/list/scp_abilities = list()
	var/list/active_effects = list()
	var/list/passive_effects = list()

	var/list/interaction_history = list()
	var/list/affected_targets = list()
	var/list/containment_requirements = list()

	var/persistence_id = ""
	var/list/persistence_data = list()
	var/last_persistence_save = 0
	var/persistence_save_interval = 300

	var/use_custom_sprite = FALSE

	var/list/containment_protocols = list()
	var/list/security_measures = list()
	var/containment_level = 1
	var/containment_integrity = 100
	var/containment_resistance = 0
	var/max_containment_resistance = 100
	var/containment_breach_attempts = 0
	var/last_containment_check = 0
	var/containment_check_interval = 30 SECONDS
	var/containment_tension = 0
	var/corrosion_resource = 0
	var/hack_progress = 0
	var/list/containment_abilities = list()
	var/list/active_containment_effects = list()
	var/breached = FALSE
	var/containment_procedures = "Standard containment procedures."
	var/recontainment_procedures = "Standard recontainment protocol."

	var/ai_enabled = FALSE
	var/ai_active = FALSE
	var/ai_tick_interval = 20
	var/last_ai_tick = 0
	var/ai_target
	var/ai_state = "idle"
	var/ai_wander_range = 10
	var/turf/ai_home_turf

	var/list/skill_cooldowns = list()
	var/list/skill_levels = list()
	var/list/skill_requirements = list()
	var/list/skill_experience = list()
	var/last_skill_use = 0
	var/skill_use_cooldown = 5 SECONDS
	var/level_up_cooldown = 0
	var/level_up_cooldown_time = 60 SECONDS
	var/max_skill_level = 100
	var/skill_experience_rate = 1
	var/skills_restored = FALSE

	var/list/enabled_features = list()
	var/list/feature_configs = list()

/mob/living/scp/Initialize(mapload)
	. = ..()
	scp_health = max_scp_health
	scp_armor = max_scp_armor
	if(!persistence_id)
		persistence_id = "[type]"

	add_movespeed_modifier(/datum/movespeed_modifier/scp_base)

	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.scp_instances[persistence_id] = new /datum/scp_instance(persistence_id, src)

	setup_containment_system()
	setup_modular_features()

/datum/movespeed_modifier/scp_base
	id = "scp_base"
	slowdown = 1.6

/mob/living/scp/Destroy()
	scp_abilities = null
	active_effects = null
	passive_effects = null
	interaction_history = null
	affected_targets = null
	containment_requirements = null
	persistence_data = null
	containment_protocols = null
	security_measures = null
	containment_abilities = null
	active_containment_effects = null
	skill_cooldowns = null
	skill_levels = null
	skill_requirements = null
	skill_experience = null
	enabled_features = null
	feature_configs = null

	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence?.manager?.scp_instances -= persistence_id

	return ..()

/mob/living/scp/proc/setup_modular_features()
	enabled_features = list(
		"skill_system" = TRUE,
		"containment_system" = TRUE,
		"persistence_system" = TRUE,
		"effect_system" = TRUE,
		"ability_system" = TRUE,
		"interaction_system" = TRUE,
	)

/mob/living/scp/proc/process_modular_features()
	return

/mob/living/scp/proc/enable_feature(feature_name)
	enabled_features[feature_name] = TRUE

/mob/living/scp/proc/disable_feature(feature_name)
	enabled_features[feature_name] = FALSE

/mob/living/scp/proc/is_feature_enabled(feature_name)
	return enabled_features[feature_name] || FALSE

/mob/living/scp/proc/configure_feature(feature_name, config_data)
	feature_configs[feature_name] = config_data

/mob/living/scp/proc/get_feature_config(feature_name)
	return feature_configs[feature_name]

/mob/living/scp/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(QDELETED(src))
		return
	process_scp_effects()
	update_persistence()
	check_containment()
	process_modular_features()
	if(ai_enabled && !key && world.time >= last_ai_tick + ai_tick_interval)
		last_ai_tick = world.time
		process_ai()
	if(containment_status == "contained" && stat != DEAD)
		containment_tension = min(100, containment_tension + 0.05)
		if(prob(5))
			containment_tension = min(100, containment_tension + 1)

/mob/living/scp/proc/process_scp_effects()
	for(var/effect in active_effects)
		process_effect(effect)
	for(var/effect in passive_effects)
		process_passive_effect(effect)
	process_skill_effects()

/mob/living/scp/proc/process_effect(effect)
	return

/mob/living/scp/proc/process_passive_effect(effect)
	return

/mob/living/scp/proc/update_persistence()
	if(world.time < last_persistence_save + persistence_save_interval)
		return
	if(!persistence_data)
		return
	last_persistence_save = world.time
	persistence_data["health"] = scp_health
	persistence_data["armor"] = scp_armor
	persistence_data["containment_status"] = containment_status
	persistence_data["breach_count"] = breach_count
	persistence_data["last_breach_time"] = last_breach_time
	persistence_data["interaction_history"] = interaction_history.Copy()
	persistence_data["affected_targets"] = affected_targets.Copy()
	persistence_data["skill_levels"] = islist(skill_levels) ? skill_levels.Copy() : list()
	persistence_data["skill_experience"] = islist(skill_experience) ? skill_experience.Copy() : list()
	persistence_data["skill_cooldowns"] = islist(skill_cooldowns) ? skill_cooldowns.Copy() : list()
	persistence_data["last_skill_use"] = last_skill_use
	persistence_data["level_up_cooldown"] = level_up_cooldown

/mob/living/scp/proc/check_containment()
	if(world.time < last_containment_check + containment_check_interval)
		return
	last_containment_check = world.time
	process_containment_effects()
	check_specific_containment()

/mob/living/scp/proc/check_specific_containment()
	return

/mob/living/scp/proc/breach_containment()
	if(containment_status == "breached")
		return
	containment_status = "breached"
	breach_count++
	last_breach_time = world.time
	to_chat(src, span_danger("You have breached containment!"))
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances[persistence_id]
		if(instance)
			instance.containment_status = "breached"
			instance.add_breach_record()

/mob/living/scp/proc/return_to_containment()
	if(containment_status == "contained")
		return
	containment_status = "contained"
	to_chat(src, span_notice("You have returned to containment."))
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances[persistence_id]
		if(instance)
			instance.containment_status = "contained"

/mob/living/scp/proc/add_containment_protocol(protocol_name, protocol_description)
	if(!(protocol_name in containment_protocols))
		containment_protocols[protocol_name] = protocol_description
		containment_integrity = min(100, containment_integrity + 10)

/mob/living/scp/proc/remove_containment_protocol(protocol_name)
	if(protocol_name in containment_protocols)
		containment_protocols -= protocol_name
		containment_integrity = max(0, containment_integrity - 10)

/mob/living/scp/proc/add_security_measure(measure_name, measure_description)
	if(!(measure_name in security_measures))
		security_measures[measure_name] = measure_description
		containment_level = min(5, containment_level + 1)

/mob/living/scp/proc/remove_security_measure(measure_name)
	if(measure_name in security_measures)
		security_measures -= measure_name
		containment_level = max(1, containment_level - 1)

/mob/living/scp/proc/attempt_containment_breach()
	if(containment_status == "breached")
		return FALSE
	containment_breach_attempts++
	var/breach_chance = calculate_breach_chance()
	if(prob(breach_chance))
		breach_containment()
		return TRUE
	else
		containment_integrity = max(0, containment_integrity - 5)
		return FALSE

/mob/living/scp/proc/calculate_breach_chance()
	var/base_chance = 20
	var/integrity_modifier = (100 - containment_integrity) / 10
	var/level_modifier = (5 - containment_level) * 5
	var/resistance_modifier = containment_resistance / 10
	var/effectiveness_modifier = 0
	if(SSscp_persistence?.manager?.scp_instances?[persistence_id])
		var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances[persistence_id]
		effectiveness_modifier = -((instance.containment_effectiveness - 1.0) * 50)
	var/power_modifier = 0
	var/area/A = get_area(src)
	if(A && !A.powered(AREA_USAGE_ENVIRON))
		power_modifier = 15
	var/cascade_modifier = 0
	if(SSscp_persistence?.manager)
		cascade_modifier = SSscp_persistence?.manager?.active_breaches * 5
	return min(95, max(5, base_chance + integrity_modifier + level_modifier + resistance_modifier + effectiveness_modifier + power_modifier + cascade_modifier))

/mob/living/scp/proc/enhance_containment_resistance(amount = 10)
	containment_resistance = min(max_containment_resistance, containment_resistance + amount)

/mob/living/scp/proc/reduce_containment_integrity(amount = 10)
	containment_integrity = max(0, containment_integrity - amount)

/mob/living/scp/proc/restore_containment_integrity(amount = 10)
	containment_integrity = min(100, containment_integrity + amount)

/mob/living/scp/proc/add_containment_ability(ability_name, ability_proc)
	if(!(ability_name in containment_abilities))
		containment_abilities[ability_name] = ability_proc

/mob/living/scp/proc/remove_containment_ability(ability_name)
	containment_abilities -= ability_name

/mob/living/scp/proc/add_containment_effect(effect_name)
	if(!(effect_name in active_containment_effects))
		active_containment_effects += effect_name

/mob/living/scp/proc/remove_containment_effect(effect_name)
	active_containment_effects -= effect_name

/mob/living/scp/proc/process_containment_effects()
	for(var/effect in active_containment_effects)
		process_containment_effect(effect)

/mob/living/scp/proc/process_containment_effect(effect)
	return

/mob/living/scp/proc/get_containment_report()
	var/report = "<h3>Containment Status Report</h3>"
	report += "<b>Status:</b> [containment_status]<br>"
	report += "<b>Level:</b> [containment_level]/5<br>"
	report += "<b>Integrity:</b> [containment_integrity]%<br>"
	report += "<b>Resistance:</b> [containment_resistance]/[max_containment_resistance]<br>"
	report += "<b>Breach Attempts:</b> [containment_breach_attempts]<br>"
	if(length(containment_protocols))
		report += "<b>Active Protocols:</b><br>"
		for(var/protocol in containment_protocols)
			report += "- [protocol]: [containment_protocols[protocol]]<br>"
	if(length(security_measures))
		report += "<b>Security Measures:</b><br>"
		for(var/measure in security_measures)
			report += "- [measure]: [security_measures[measure]]<br>"
	if(length(active_containment_effects))
		report += "<b>Active Effects:</b><br>"
		for(var/effect in active_containment_effects)
			report += "- [effect]<br>"
	return report

/mob/living/scp/proc/setup_default_containment()
	add_containment_protocol("Standard Containment", "Basic containment procedures for SCP entities")
	add_containment_protocol("Personnel Monitoring", "Regular monitoring of personnel interacting with the SCP")
	add_security_measure("Access Control", "Restricted access to SCP containment area")
	add_security_measure("Surveillance", "24/7 monitoring of SCP containment area")
	if(SCP)
		switch(SCP.classification)
			if(SCP_SAFE)
				containment_level = 2
				containment_integrity = 80
			if(SCP_EUCLID)
				containment_level = 3
				containment_integrity = 70
			if(SCP_KETER)
				containment_level = 4
				containment_integrity = 60
			if(SCP_THAUMIEL)
				containment_level = 5
				containment_integrity = 90
			if(SCP_NEUTRALIZED)
				containment_level = 1
				containment_integrity = 100
	else
		containment_level = 3
		containment_integrity = 70

/mob/living/scp/proc/add_interaction_record(target, interaction_type)
	var/record = "[time2text(world.time, "YYYY-MM-DD hh:mm:ss")]: [interaction_type] with [target ? "[target]" : "unknown"]"
	interaction_history += record
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances[persistence_id]
		if(instance)
			instance.add_interaction_record(target, interaction_type)

/mob/living/scp/proc/add_ability(ability_name, ability_proc)
	scp_abilities[ability_name] = ability_proc

/mob/living/scp/proc/remove_ability(ability_name)
	scp_abilities -= ability_name

/mob/living/scp/proc/add_active_effect(effect_name)
	if(!(effect_name in active_effects))
		active_effects += effect_name

/mob/living/scp/proc/remove_active_effect(effect_name)
	active_effects -= effect_name

/mob/living/scp/proc/add_passive_effect(effect_name)
	if(!(effect_name in passive_effects))
		passive_effects += effect_name

/mob/living/scp/proc/remove_passive_effect(effect_name)
	passive_effects -= effect_name

/mob/living/scp/proc/adjust_scp_health(amount)
	scp_health = max(0, min(max_scp_health, scp_health + amount))
	if(scp_health <= 0)
		scp_death()

/mob/living/scp/proc/adjust_scp_armor(amount)
	scp_armor = max(0, min(max_scp_armor, scp_armor + amount))

/mob/living/scp/proc/scp_death()
	visible_message(span_danger("[src] is neutralized!"))
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances[persistence_id]
		if(instance)
			instance.containment_status = "neutralized"
	hook_scp_recontainment(persistence_id, list())

/mob/living/scp/death(gibbed)
	hook_scp_recontainment(persistence_id, list())
	return ..()

/mob/living/scp/get_status_tab_items()
	. = ..()
	. += "SCP Health: [scp_health]/[max_scp_health]"
	. += "SCP Armor: [scp_armor]/[max_scp_armor]"
	. += "Containment: [containment_status]"
	. += "Containment Level: [containment_level]/5"
	. += "Containment Integrity: [containment_integrity]%"

/mob/living/scp/examine(mob/user)
	. = ..()
	if(ishuman(user))
		if(user.SCP)
			. += span_warning("This is an SCP entity with containment status: [containment_status]")
		else
			. += span_danger("A mysterious entity that seems to defy normal physics.")

/mob/living/scp/proc/view_persistence_data()
	if(!check_rights(R_ADMIN))
		return
	var/message = "<h2>SCP Persistence Data</h2>"
	message += "<b>Persistence ID:</b> [persistence_id]<br>"
	message += "<b>Containment Status:</b> [containment_status]<br>"
	message += "<b>SCP Health:</b> [scp_health]/[max_scp_health]<br>"
	message += "<b>SCP Armor:</b> [scp_armor]/[max_scp_armor]<br>"
	message += "<b>Breach Count:</b> [breach_count]<br>"
	to_chat(src, span_notice("[message]"))

/mob/living/scp/proc/initialize_skill(skill_name, base_cooldown = 30 SECONDS, base_requirements = list())
	if(!(skill_name in skill_levels))
		skill_levels[skill_name] = 0
		skill_experience[skill_name] = 0
		skill_cooldowns[skill_name] = 0
		skill_requirements[skill_name] = base_requirements

/mob/living/scp/proc/can_use_skill(skill_name)
	if(world.time < last_skill_use + skill_use_cooldown)
		return FALSE
	if(world.time < skill_cooldowns[skill_name])
		return FALSE
	var/current_level = skill_levels[skill_name] || 0
	var/requirements = skill_requirements[skill_name] || list()
	for(var/requirement in requirements)
		if(!check_skill_requirement(requirement, current_level))
			return FALSE
	return TRUE

/mob/living/scp/proc/check_skill_requirement(requirement, current_level)
	return TRUE

/mob/living/scp/proc/use_skill(skill_name, experience_gain = 1, cooldown_multiplier = 1.0)
	if(!can_use_skill(skill_name))
		return FALSE
	last_skill_use = world.time
	var/base_cooldown = 30 SECONDS
	if(skill_requirements[skill_name] && skill_requirements[skill_name]["base_cooldown"])
		base_cooldown = skill_requirements[skill_name]["base_cooldown"]
	skill_cooldowns[skill_name] = world.time + (base_cooldown * cooldown_multiplier)
	gain_skill_experience(skill_name, experience_gain)
	return TRUE

/mob/living/scp/proc/gain_skill_experience(skill_name, amount)
	if(!(skill_name in skill_experience))
		skill_experience[skill_name] = 0
	skill_experience[skill_name] += amount * skill_experience_rate
	check_skill_level_up(skill_name)

/mob/living/scp/proc/check_skill_level_up(skill_name)
	if(world.time < level_up_cooldown)
		return
	var/current_level = skill_levels[skill_name] || 0
	var/current_exp = skill_experience[skill_name] || 0
	var/required_exp = calculate_required_experience(current_level)
	if(current_exp >= required_exp && current_level < max_skill_level)
		level_up_skill(skill_name)

/mob/living/scp/proc/calculate_required_experience(current_level)
	return (current_level + 1) * 10 + (current_level * current_level)

/mob/living/scp/proc/level_up_skill(skill_name)
	var/current_level = skill_levels[skill_name] || 0
	var/requirements = skill_requirements[skill_name] || list()
	if(!check_level_up_requirements(skill_name, current_level + 1, requirements))
		return FALSE
	level_up_cooldown = world.time + level_up_cooldown_time
	skill_levels[skill_name] = current_level + 1
	skill_experience[skill_name] = 0
	apply_skill_level_effects(skill_name, current_level + 1)
	return TRUE

/mob/living/scp/proc/check_level_up_requirements(skill_name, new_level, requirements)
	if(new_level > 50 && containment_status != "breached")
		return FALSE
	if(new_level > 75 && breach_count < 3)
		return FALSE
	if(new_level > 90 && containment_integrity > 20)
		return FALSE
	for(var/requirement in requirements)
		if(!check_skill_requirement(requirement, new_level))
			return FALSE
	return TRUE

/mob/living/scp/proc/apply_skill_level_effects(skill_name, new_level)
	return

/mob/living/scp/proc/get_skill_info(skill_name)
	var/current_level = skill_levels[skill_name] || 0
	var/current_exp = skill_experience[skill_name] || 0
	var/required_exp = calculate_required_experience(current_level)
	return "<b>[skill_name]</b> Level: [current_level]/[max_skill_level] Exp: [current_exp]/[required_exp]"

/mob/living/scp/proc/get_all_skills_info()
	var/info = "<h3>Skill Information</h3>"
	for(var/skill in skill_levels)
		info += get_skill_info(skill) + "<br>"
	return info

/mob/living/scp/proc/reset_skill_cooldowns()
	for(var/skill in skill_cooldowns)
		skill_cooldowns[skill] = 0
	last_skill_use = 0
	level_up_cooldown = 0

/mob/living/scp/proc/process_skill_effects()
	for(var/skill in skill_levels)
		process_skill_effect(skill)

/mob/living/scp/proc/process_skill_effect(skill_name)
	return

/mob/living/scp/proc/process_ai()
	if(stat == DEAD)
		return
	if(containment_status != "breached")
		return
	if(!ai_home_turf)
		ai_home_turf = get_turf(src)
	if(ai_state == "idle")
		ai_idle()
	else if(ai_state == "pursuing")
		ai_pursue()
	else if(ai_state == "wandering")
		ai_wander()

/mob/living/scp/proc/ai_idle()
	ai_target = find_ai_target()
	if(ai_target)
		ai_state = "pursuing"
		return
	if(prob(30))
		ai_state = "wandering"

/mob/living/scp/proc/find_ai_target()
	var/closest_dist = INFINITY
	var/closest_mob
	for(var/mob/living/carbon/human/H in view(7, src))
		if(H.stat == DEAD)
			continue
		if(H == src)
			continue
		var/dist = get_dist(src, H)
		if(dist < closest_dist)
			closest_dist = dist
			closest_mob = H
	return closest_mob

/mob/living/scp/proc/ai_pursue()
	if(!ai_target || get_dist(src, ai_target) > 14)
		ai_target = null
		ai_state = "idle"
		return
	if(isliving(ai_target))
		var/mob/living/L = ai_target
		if(L.stat == DEAD)
			ai_target = null
			ai_state = "idle"
			return
	if(!step_to(src, get_step_towards(src, ai_target)))
		if(!step_rand(src))
			ai_state = "idle"
	if(ai_target in view(1, src))
		ai_attack_target(ai_target)

/mob/living/scp/proc/ai_attack_target(target)
	if(isliving(target))
		var/mob/living/L = target
		L.attack_animal(src)
		if(prob(25))
			evolve_from_interaction()

/mob/living/scp/proc/ai_wander()
	if(ai_home_turf && get_dist(src, ai_home_turf) > ai_wander_range)
		step_to(src, get_step_towards(src, ai_home_turf))
	else
		step_rand(src)
	if(prob(40))
		ai_state = "idle"
	ai_target = find_ai_target()
	if(ai_target)
		ai_state = "pursuing"

/mob/living/scp/proc/ai_open_door()
	var/obj/machinery/door/D = locate() in range(1, src)
	if(D && D.density)
		D.open(TRUE)
		return TRUE
	return FALSE

/mob/living/scp/proc/ai_step_towards(atom/target, max_dist = 14)
	if(!target || get_dist(src, target) > max_dist)
		return FALSE
	var/turf/next_step = get_step_towards(src, target)
	if(!next_step)
		return FALSE
	var/blocked = FALSE
	for(var/obj/O in next_step)
		if(O.density)
			if(istype(O, /obj/machinery/door))
				var/obj/machinery/door/D = O
				if(D.density)
					D.open(TRUE)
					return TRUE
			else
				blocked = TRUE
	if(next_step.density)
		blocked = TRUE
	if(blocked)
		if(ai_open_door())
			return TRUE
		var/turf/alt = get_step_rand(src)
		if(alt && !alt.density)
			Move(alt)
		return FALSE
	return step_to(src, target)

/mob/living/scp/proc/ai_has_los(atom/target)
	if(!target)
		return FALSE
	var/turf/T = get_turf(src)
	var/turf/U = get_turf(target)
	if(!T || !U || T.z != U.z)
		return FALSE
	var/distance = get_dist(T, U)
	if(distance > 14)
		return FALSE
	var/turf/current = T
	for(var/i = 1 to distance)
		current = get_step_towards(current, U)
		if(current.density)
			return FALSE
		for(var/obj/O in current)
			if(O.density && !istype(O, /obj/machinery/door))
				return FALSE
	return TRUE

/mob/living/scp/proc/ai_try_attack(atom/target)
	if(!target || get_dist(src, target) > 1)
		return FALSE
	UnarmedAttack(target)
	return TRUE
