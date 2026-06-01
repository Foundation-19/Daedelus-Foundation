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
	active_adaptations = list()

/datum/scp682_evolution_system/Destroy()
	active_adaptations = null
	owner = null
	return ..()

/datum/scp682_evolution_system/proc/process_evolution()
	if(world.time >= last_evolution_check + evolution_check_interval)
		check_evolution_opportunities()
		last_evolution_check = world.time

/datum/scp682_evolution_system/proc/adapt_to_damage(damage_type, amount)
	if(world.time < evolution_cooldown)
		return

	adaptation_points += (amount * points_per_damage)

	if(prob(SCP682_DAMAGE_ADAPT_CHANCE))
		add_adaptation("damage_resistance_[damage_type]")

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

	to_chat(owner, span_notice("You have adapted to [adaptation_type]!"))
	playsound(owner, 'sound/effects/ghost2.ogg', 40, TRUE)

/datum/scp682_evolution_system/proc/check_evolution_opportunities()
	var/required_points = evolution_stage * 100

	if(adaptation_points >= required_points && evolution_stage < max_evolution_stage)
		evolve_stage()

/datum/scp682_evolution_system/proc/evolve_stage()
	evolution_stage++
	adaptation_points = 0
	evolution_cooldown = world.time + evolution_cooldown_time

	apply_evolution_effects()

	to_chat(owner, span_notice("You have evolved to stage [evolution_stage]!"))
	playsound(owner, 'sound/effects/roar.ogg', 80, FALSE, extrarange = 20)

	owner.on_evolution(evolution_stage)

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
			to_chat(owner, span_danger("You have achieved ultimate evolution!"))

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

	for(var/mob/living/carbon/human/H in view(owner.area_attack_range * 2, owner))
		if(H == owner || H.stat == DEAD)
			continue

		var/threat_score = calculate_threat_score(H)
		if(threat_score > 0)
			threat_priorities[H] = threat_score

	threat_priorities = sort_list(threat_priorities, /proc/cmp_numeric_dsc)

/datum/scp682_threat_system/proc/calculate_threat_score(mob/living/carbon/human/target)
	var/score = 0

	if(target in threat_memory)
		score += threat_memory[target]["damage_dealt"] * 10

	if(target.get_active_held_item())
		score += 50

	if(target.mind && target.mind.assigned_role)
		var/role = target.mind.assigned_role.title
		if(findtext(role, "Security") || findtext(role, "MTF") || findtext(role, "Guard"))
			score += 100

	var/distance = get_dist(owner, target)
	score -= distance * 5

	if(target.health < target.maxHealth * 0.5)
		score -= 25

	return max(0, score)

/datum/scp682_threat_system/proc/remember_threat(threat, damage_type, amount)
	if(!(threat in threat_memory))
		threat_memory[threat] = list()

	threat_memory[threat]["damage_dealt"] = threat_memory[threat]["damage_dealt"] + amount
	threat_memory[threat]["damage_type"] = damage_type
	threat_memory[threat]["last_encounter"] = world.time

	if(owner.evolution_system)
		owner.evolution_system.adapt_to_threat(threat, damage_type)

/datum/scp682_threat_system/proc/get_primary_target()
	if(length(threat_priorities) > 0)
		for(var/mob/living/carbon/human/H in threat_priorities)
			if(!QDELETED(H) && H.stat != DEAD)
				return H
	return null

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

	var/primary_target = owner.threat_system?.get_primary_target()
	if(!primary_target)
		return

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

	var/damage = SCP682_BASE_ATTACK_DAMAGE
	target.adjustBruteLoss(damage)

	owner.visible_message(span_danger("[owner] attacks [target] with devastating force!"))
	playsound(owner, 'sound/weapons/genhit.ogg', 50, TRUE)

	if(owner.threat_system)
		owner.threat_system.remember_threat(target, "brute", damage)

	if(target.health <= 0)
		to_chat(owner, span_notice("You have eliminated [target]!"))

/datum/scp682_combat_system/proc/perform_area_attack()
	if(world.time < area_attack_cooldown)
		return

	area_attack_cooldown = world.time + area_attack_cooldown_time

	for(var/mob/living/carbon/human/H in range(SCP682_BASE_AREA_ATTACK_RANGE, owner))
		if(H == owner)
			continue

		var/damage = SCP682_BASE_ATTACK_DAMAGE * 0.7
		H.adjustBruteLoss(damage)

		if(owner.threat_system)
			owner.threat_system.remember_threat(H, "brute", damage)

	owner.visible_message(span_danger("[owner] performs a devastating area attack!"))
	playsound(owner, 'sound/effects/explosion1.ogg', 50, TRUE)

/datum/scp682_combat_system/proc/perform_charge_attack(mob/living/carbon/human/target)
	if(world.time < charge_cooldown)
		return

	charge_cooldown = world.time + charge_cooldown_time

	step_towards(owner, target)

	var/damage = SCP682_BASE_ATTACK_DAMAGE * 1.5
	target.adjustBruteLoss(damage)

	owner.visible_message(span_danger("[owner] charges at [target] with incredible speed!"))
	playsound(owner, 'sound/effects/explosion2.ogg', 60, TRUE)

	if(owner.threat_system)
		owner.threat_system.remember_threat(target, "brute", damage)

/datum/scp682_combat_system/proc/move_towards_target(target)
	step_towards(owner, target)

/datum/scp682_combat_system/proc/try_breach_containment(target)
	if(world.time < last_combat_action + 30 SECONDS)
		return
	var/breach_damage = 60 + (owner.evolution_system?.evolution_stage || 1) * 15
	for(var/turf/closed/wall/scp_containment/C in range(1, owner))
		if(get_dir(owner, C) == owner.dir)
			try_scp_breach_wall(owner, C, breach_damage, "SCP-682")
			last_combat_action = world.time
			return
