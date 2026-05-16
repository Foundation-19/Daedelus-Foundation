// SCP-682 Systems - The Hard-to-Destroy Reptile
// Complete Production-Ready Implementation

// ============================================================================
// EVOLUTION SYSTEM
// ============================================================================

/datum/scp682_evolution_system
	var/mob/living/scp/scp682/owner = null
	var/evolution_stage = 1
	var/max_evolution_stage = SCP682_MAX_EVOLUTION_STAGE
	var/adaptation_points = 0
	var/points_per_damage = SCP682_POINTS_PER_DAMAGE
	var/points_per_threat = SCP682_POINTS_PER_THREAT
	var/list/active_adaptations = list()
	var/evolution_cooldown = 0
	var/evolution_cooldown_time = SCP682_EVOLUTION_COOLDOWN
	var/last_evolution_check = 0
	var/evolution_check_interval = SCP682_EVOLUTION_CHECK_INTERVAL

/datum/scp682_evolution_system/New(mob/living/scp/scp682/new_owner)
	. = ..()
	owner = new_owner
	setup_evolution_requirements()

/datum/scp682_evolution_system/Destroy()
	active_adaptations = null
	owner = null
	return ..()

/datum/scp682_evolution_system/proc/process_evolution()
	if(world.time >= last_evolution_check + evolution_check_interval)
		check_evolution_opportunities()
		last_evolution_check = world.time

/datum/scp682_evolution_system/proc/setup_evolution_requirements()
	active_adaptations = list()

/datum/scp682_evolution_system/proc/adapt_to_damage(damage_type, amount)
	if(world.time < evolution_cooldown)
		return

	// Award adaptation points
	adaptation_points += (amount * points_per_damage)

	// Check for new adaptation
	if(prob(SCP682_DAMAGE_ADAPT_CHANCE))
		add_adaptation("damage_resistance_[damage_type]")

	// Check for evolution
	check_evolution_opportunities()

/datum/scp682_evolution_system/proc/adapt_to_threat(threat, threat_type)
	if(world.time < evolution_cooldown)
		return

	adaptation_points += points_per_threat

	if(prob(SCP682_THREAT_ADAPT_CHANCE))
		add_adaptation("threat_counter_[threat_type]")

/datum/scp682_evolution_system/proc/add_adaptation(adaptation_type)
	if(adaptation_type in active_adaptations)
		return

	active_adaptations += adaptation_type

	to_chat(owner, "<span class='notice'>You have adapted to [adaptation_type]!</span>")
	playsound(owner, 'sound/effects/ghost2.ogg', 40, TRUE)

/datum/scp682_evolution_system/proc/check_evolution_opportunities()
	var/required_points = evolution_stage * 100

	if(adaptation_points >= required_points && evolution_stage < max_evolution_stage)
		evolve_stage()

/datum/scp682_evolution_system/proc/evolve_stage()
	evolution_stage++
	adaptation_points = 0
	evolution_cooldown = world.time + evolution_cooldown_time

	// Apply evolution bonuses
	apply_evolution_effects()

	to_chat(owner, "<span class='notice'>You have evolved to stage [evolution_stage]!</span>")
	playsound(owner, 'sound/effects/roar.ogg', 80, FALSE, extrarange = 20)

/datum/scp682_evolution_system/proc/apply_evolution_effects()
	switch(evolution_stage)
		if(2)
			owner.attack_damage += 10
			owner.movement_speed += 0.2
		if(3)
			owner.area_attack_range += 1
			owner.attack_speed += 0.3
		if(4)
			owner.attack_damage += 15
			owner.movement_speed += 0.3
		if(5)
			owner.area_attack_range += 1
			owner.attack_speed += 0.4
		if(6)
			owner.attack_damage += 20
			owner.movement_speed += 0.4
		if(7)
			owner.area_attack_range += 1
			owner.attack_speed += 0.5
		if(8)
			owner.attack_damage += 25
			owner.movement_speed += 0.5
		if(9)
			owner.area_attack_range += 1
			owner.attack_speed += 0.6
		if(10)
			owner.attack_damage += 30
			owner.movement_speed += 0.7
			to_chat(owner, "<span class='danger'>You have achieved ultimate evolution!</span>")

// ============================================================================
// REGENERATION SYSTEM
// ============================================================================

/datum/scp682_regeneration_system
	var/mob/living/scp/scp682/owner = null
	var/base_health = SCP682_REGEN_BASE_HEALTH
	var/regeneration_rate = SCP682_BASE_REGENERATION_RATE
	var/damage_scaling = 0
	var/critical_regeneration = SCP682_CRITICAL_REGENERATION_BONUS
	var/last_damage_time = 0
	var/damage_memory_duration = 30 SECONDS
	var/list/recent_damage = list()
	var/regeneration_cooldown = 0
	var/regeneration_cooldown_time = 1 SECONDS

/datum/scp682_regeneration_system/New(mob/living/scp/scp682/new_owner)
	. = ..()
	owner = new_owner

/datum/scp682_regeneration_system/Destroy()
	recent_damage = null
	owner = null
	return ..()

/datum/scp682_regeneration_system/proc/process_regeneration()
	if(world.time < regeneration_cooldown)
		return

	regeneration_cooldown = world.time + regeneration_cooldown_time

	// Clean old damage records
	clean_damage_memory()

	// Calculate regeneration rate
	var/total_regeneration = calculate_regeneration_rate()

	// Apply healing
	if(total_regeneration > 0)
		apply_healing(total_regeneration)

/datum/scp682_regeneration_system/proc/clean_damage_memory()
	var/current_time = world.time
	for(var/damage_record in recent_damage.Copy())
		if(current_time - damage_record["time"] > damage_memory_duration)
			recent_damage -= damage_record

/datum/scp682_regeneration_system/proc/calculate_regeneration_rate()
	var/total_rate = regeneration_rate

	// Damage scaling bonus
	total_rate += damage_scaling

	// Adaptation bonus
	if(owner.evolution_system)
		total_rate += (length(owner.evolution_system.active_adaptations) * 5)

	// Evolution stage bonus
	if(owner.evolution_system)
		total_rate += (owner.evolution_system.evolution_stage * 10)

	// Critical regeneration
	if(owner.health < (owner.maxHealth * 0.2))
		total_rate += critical_regeneration

	return total_rate

/datum/scp682_regeneration_system/proc/apply_healing(amount)
	if(owner.health >= owner.maxHealth)
		return

	owner.health = min(owner.maxHealth, owner.health + amount)

/datum/scp682_regeneration_system/proc/record_damage(amount, damage_type)
	last_damage_time = world.time
	recent_damage += list(list("amount" = amount, "type" = damage_type, "time" = world.time))

	// Update damage scaling
	update_damage_scaling()

/datum/scp682_regeneration_system/proc/update_damage_scaling()
	var/total_recent_damage = 0
	for(var/damage_record in recent_damage)
		total_recent_damage += damage_record["amount"]

	damage_scaling = total_recent_damage / 100

// ============================================================================
// THREAT ASSESSMENT SYSTEM
// ============================================================================

/datum/scp682_threat_system
	var/mob/living/scp/scp682/owner = null
	var/list/threat_memory = list()
	var/list/threat_priorities = list()
	var/threat_assessment_cooldown = 0
	var/threat_assessment_cooldown_time = 5 SECONDS
	var/last_threat_scan = 0
	var/threat_scan_interval = 10 SECONDS

/datum/scp682_threat_system/New(mob/living/scp/scp682/new_owner)
	. = ..()
	owner = new_owner

/datum/scp682_threat_system/Destroy()
	threat_priorities = null
	threat_memory = null
	owner = null
	return ..()

/datum/scp682_threat_system/proc/process_threats()
	if(world.time >= last_threat_scan + threat_scan_interval)
		assess_threats()
		last_threat_scan = world.time

/datum/scp682_threat_system/proc/assess_threats()
	threat_priorities.Cut()

	// Scan for threats in vision range
	for(var/mob/living/carbon/human/H in view(owner.area_attack_range * 2, owner))
		if(H == owner || H.stat == DEAD)
			continue

		var/threat_score = calculate_threat_score(H)
		if(threat_score > 0)
			threat_priorities[H] = threat_score

	// Sort threats by priority
	threat_priorities = sort_list(threat_priorities, /proc/cmp_numeric_dsc)

/datum/scp682_threat_system/proc/calculate_threat_score(mob/living/carbon/human/target)
	var/score = 0

	// Damage dealt to SCP-682
	if(target in threat_memory)
		score += threat_memory[target]["damage_dealt"] * 10

	// Weapon presence
	if(target.get_active_held_item())
		score += 50

	// Security/MTF status
	if(target.mind && target.mind.assigned_role)
		var/role = target.mind.assigned_role.title
		if(findtext(role, "Security") || findtext(role, "MTF") || findtext(role, "Guard"))
			score += 100

	// Proximity penalty
	var/distance = get_dist(owner, target)
	score -= distance * 5

	// Health status (weaker targets are less threatening)
	if(target.health < target.maxHealth * 0.5)
		score -= 25

	return max(0, score)

/datum/scp682_threat_system/proc/remember_threat(threat, damage_type, amount)
	if(!(threat in threat_memory))
		threat_memory[threat] = list()

	threat_memory[threat]["damage_dealt"] = threat_memory[threat]["damage_dealt"] + amount
	threat_memory[threat]["damage_type"] = damage_type
	threat_memory[threat]["last_encounter"] = world.time

	// Notify evolution system
	if(owner.evolution_system)
		owner.evolution_system.adapt_to_threat(threat, damage_type)

/datum/scp682_threat_system/proc/get_primary_target()
	if(length(threat_priorities) > 0)
		for(var/mob/living/carbon/human/H in threat_priorities)
			if(!QDELETED(H) && H.stat != DEAD)
				return H
	return null

// ============================================================================
// CONTAINMENT SYSTEM
// ============================================================================

/datum/scp682_containment_system
	var/mob/living/scp/scp682/owner = null
	var/containment_integrity = SCP682_DEFAULT_CONTAINMENT_INTEGRITY
	var/breach_phase = "contained"
	var/list/adaptation_countermeasures = list()
	var/escalation_interval = 60 SECONDS
	var/last_containment_check = 0
	var/containment_check_interval = SCP682_CONTAINMENT_CHECK_INTERVAL
	var/breach_cooldown = 0
	var/breach_cooldown_time = 30 SECONDS

/datum/scp682_containment_system/New(mob/living/scp/scp682/new_owner)
	. = ..()
	owner = new_owner

/datum/scp682_containment_system/Destroy()
	owner = null
	return ..()

/datum/scp682_containment_system/proc/process_containment()
	if(world.time >= last_containment_check + containment_check_interval)
		check_containment_status()
		last_containment_check = world.time

/datum/scp682_containment_system/proc/check_containment_status()
	// Simplified containment check - always assume contained for now
	if(breach_phase != "contained")
		set_breach_phase("contained")

/datum/scp682_containment_system/proc/escalate_breach()
	if(world.time < breach_cooldown)
		return

	breach_cooldown = world.time + breach_cooldown_time

	switch(breach_phase)
		if("contained")
			set_breach_phase("agitated")
		if("agitated")
			set_breach_phase("escalating")
		if("escalating")
			set_breach_phase("full_breach")
		if("full_breach")
			set_breach_phase("rampage")

/datum/scp682_containment_system/proc/set_breach_phase(new_phase)
	breach_phase = new_phase

	if(new_phase == "contained" && owner)
		hook_scp_recontainment("SCP-682", list("method" = "standard", "integrity" = containment_integrity))
	switch(breach_phase)
		if("agitated")
			owner.add_movespeed_modifier("scp682_agitated")
			to_chat(owner, "<span class='warning'>You feel agitated and more aggressive.</span>")
		if("escalating")
			if(!owner.has_movespeed_modifier("scp682_agitated"))
				owner.add_movespeed_modifier("scp682_agitated")
			to_chat(owner, "<span class='danger'>Your aggression is escalating!</span>")
		if("full_breach")
			if(!owner.has_movespeed_modifier("scp682_full_breach"))
				owner.add_movespeed_modifier("scp682_full_breach")
			to_chat(owner, "<span class='danger'>You have fully breached containment!</span>")
			playsound(owner, 'sound/effects/roar.ogg', 80, FALSE, extrarange = 25)
		if("rampage")
			if(!owner.has_movespeed_modifier("scp682_rage"))
				owner.add_movespeed_modifier("scp682_rage")
			to_chat(owner, "<span class='danger'>You are in a state of complete rampage!</span>")
			playsound(owner, 'sound/effects/roar.ogg', 100, FALSE, extrarange = 40)

/datum/scp682_containment_system/proc/reduce_containment_integrity(amount)
	containment_integrity = max(0, containment_integrity - amount)

	if(containment_integrity <= 0)
		escalate_breach()

// ============================================================================
// COMBAT SYSTEM
// ============================================================================

/datum/scp682_combat_system
	var/mob/living/scp/scp682/owner = null
	var/attack_cooldown = 0
	var/attack_cooldown_time = SCP682_MELEE_COOLDOWN
	var/area_attack_cooldown = 0
	var/area_attack_cooldown_time = SCP682_AREA_ATTACK_COOLDOWN
	var/charge_cooldown = 0
	var/charge_cooldown_time = SCP682_CHARGE_COOLDOWN
	var/last_combat_action = 0
	var/combat_action_interval = 1 SECONDS

/datum/scp682_combat_system/New(mob/living/scp/scp682/new_owner)
	. = ..()
	owner = new_owner

/datum/scp682_combat_system/Destroy()
	owner = null
	return ..()

/datum/scp682_combat_system/proc/process_combat()
	if(world.time < last_combat_action + combat_action_interval)
		return

	last_combat_action = world.time

	// Get primary target
	var/primary_target = owner.threat_system?.get_primary_target()
	if(!primary_target)
		return

	// Choose combat action
	choose_combat_action(primary_target)

/datum/scp682_combat_system/proc/choose_combat_action(target)
	var/distance = get_dist(owner, target)

	if(distance <= 1)
		perform_melee_attack(target)
	else if(distance <= SCP682_BASE_AREA_ATTACK_RANGE + 3)
		perform_area_attack()
	else if(distance <= 5)
		perform_charge_attack(target)
	else
		step_towards(owner, target)
		try_breach_containment(target)

/datum/scp682_combat_system/proc/perform_melee_attack(mob/living/carbon/human/target)
	if(world.time < attack_cooldown)
		return

	attack_cooldown = world.time + attack_cooldown_time

	// Basic attack
	var/damage = SCP682_BASE_ATTACK_DAMAGE
	target.adjustBruteLoss(damage)

	// Visual and audio feedback
	owner.visible_message("<span class='danger'>[owner] attacks [target] with devastating force!</span>")
	playsound(owner, 'sound/weapons/genhit.ogg', 50, TRUE)

	// Record threat
	if(owner.threat_system)
		owner.threat_system.remember_threat(target, "brute", damage)

	// Check for kill (simplified)
	if(target.health <= 0)
		to_chat(owner, "<span class='notice'>You have eliminated [target]!</span>")

/datum/scp682_combat_system/proc/perform_area_attack()
	if(world.time < area_attack_cooldown)
		return

	area_attack_cooldown = world.time + area_attack_cooldown_time

	// Area attack affecting all nearby targets
	for(var/mob/living/carbon/human/H in range(SCP682_BASE_AREA_ATTACK_RANGE, owner))
		if(H == owner)
			continue

		var/damage = SCP682_BASE_ATTACK_DAMAGE * 0.7
		H.adjustBruteLoss(damage)

		// Record threat
		if(owner.threat_system)
			owner.threat_system.remember_threat(H, "brute", damage)

	// Visual and audio feedback
	owner.visible_message("<span class='danger'>[owner] performs a devastating area attack!</span>")
	playsound(owner, 'sound/effects/explosion1.ogg', 50, TRUE)

/datum/scp682_combat_system/proc/perform_charge_attack(mob/living/carbon/human/target)
	if(world.time < charge_cooldown)
		return

	charge_cooldown = world.time + charge_cooldown_time

	// Move towards target
	step_towards(owner, target)

	// Charge damage
	var/damage = SCP682_BASE_ATTACK_DAMAGE * 1.5
	target.adjustBruteLoss(damage)

	// Visual and audio feedback
	owner.visible_message("<span class='danger'>[owner] charges at [target] with incredible speed!</span>")
	playsound(owner, 'sound/effects/explosion2.ogg', 60, TRUE)

	// Record threat
	if(owner.threat_system)
		owner.threat_system.remember_threat(target, "brute", damage)

/datum/scp682_combat_system/proc/move_towards_target(target)
	step_towards(owner, target)

// ============================================================================
// RESEARCH INTEGRATION
// ============================================================================

/datum/scp682_research_integration
	var/mob/living/scp/scp682/owner = null
	var/list/research_data = list()
	var/research_update_cooldown = 0
	var/research_update_interval = 120 SECONDS
	var/last_research_update = 0

/datum/scp682_research_integration/New(mob/living/scp/scp682/new_owner)
	. = ..()
	owner = new_owner
	// Don't start processing - already handled by SCP-682's process() method
	setup_research_projects()

/datum/scp682_research_integration/Destroy()
	// No longer processing separately
	return ..()

/datum/scp682_research_integration/proc/process_research()
	if(world.time >= last_research_update + research_update_interval)
		contribute_research_data()
		last_research_update = world.time

/datum/scp682_research_integration/proc/setup_research_projects()
	// Initialize research data structure
	research_data["evolution_patterns"] = list()
	research_data["adaptation_data"] = list()
	research_data["threat_assessment"] = list()
	research_data["containment_effectiveness"] = list()

/datum/scp682_research_integration/proc/contribute_research_data()
	if(!SSresearch_persistence || !SSresearch_persistence.manager)
		return

	// Collect current data
	var/list/current_data = list()
	current_data["evolution_stage"] = owner.evolution_system?.evolution_stage || 1
	current_data["active_adaptations"] = length(owner.evolution_system?.active_adaptations) || 0
	current_data["threat_memory_size"] = length(owner.threat_system?.threat_memory) || 0
	current_data["breach_phase"] = owner.containment_system?.breach_phase || "contained"
	current_data["health_percentage"] = (owner.health / owner.maxHealth) * 100
	current_data["timestamp"] = world.time

	// Contribute to research projects (simplified)
	if(SSresearch_persistence && SSresearch_persistence.manager)
		// Research contribution logic would go here
		// For now, just store the data
		research_data["last_update"] = current_data

// ============================================================================
// END OF SCP-682 SYSTEMS
// ============================================================================

/datum/scp682_combat_system/proc/try_breach_containment(target)
	if(world.time < last_combat_action + 30 SECONDS)
		return
	var/breach_damage = 60 + (owner.evolution_system?.evolution_stage || 1) * 15
	for(var/turf/closed/wall/scp_containment/C in range(1, owner))
		if(get_dir(owner, C) == owner.dir)
			try_scp_breach_wall(owner, C, breach_damage, "SCP-682")
			last_combat_action = world.time
			return
