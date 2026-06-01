/mob/living/scp/scp682
	ai_enabled = TRUE
	name = "SCP-682"
	desc = "A massive, hostile reptilian creature with extreme regenerative abilities and adaptive evolution."
	icon = 'icons/scp/scp-682.dmi'
	icon_state = "scp682"
	real_name = "SCP-682"
	persistence_id = "SCP-682"

	var/datum/scp682_evolution_system/evolution_system
	var/datum/scp682_threat_system/threat_system
	var/datum/scp682_combat_system/combat_system

	var/evolution_stage = 1
	var/attack_damage = SCP682_BASE_ATTACK_DAMAGE
	var/attack_speed = SCP682_BASE_ATTACK_SPEED
	var/movement_speed = SCP682_BASE_MOVEMENT_SPEED
	var/area_attack_range = SCP682_BASE_AREA_ATTACK_RANGE
	var/damage_modifier = 1.0
	var/mob/living/last_attacker

	var/breach_phase = "contained"
	var/breach_cooldown = 0

	var/regeneration_rate = SCP682_BASE_REGENERATION_RATE
	var/regeneration_cooldown = 0
	var/damage_scaling = 0
	var/list/recent_damage = list()
	var/last_damage_time = 0

	var/last_research_update = 0

	var/datum/scp682_acid_bath/acid_bath

/mob/living/scp/scp682/Initialize(mapload)
	. = ..()

	SCP = new /datum/scp(
		src,
		"SCP-682",
		SCP_KETER,
		"682",
		SCP_SENTIENT
	)

	SCP.min_playercount = 25
	SCP.min_time = 45 MINUTES

	maxHealth = SCP682_MAX_HEALTH
	health = maxHealth

	evolution_system = new /datum/scp682_evolution_system(src)
	threat_system = new /datum/scp682_threat_system(src)
	combat_system = new /datum/scp682_combat_system(src)

	fovangle = FOV_DEFAULT
	update_fov_angles()
	update_cone_show()

	add_verb(src, list(
		/mob/living/scp/scp682/proc/verb_rampage,
		/mob/living/scp/scp682/proc/verb_berserk,
	))

/mob/living/scp/scp682/Destroy()
	QDEL_NULL(evolution_system)
	QDEL_NULL(threat_system)
	QDEL_NULL(combat_system)
	recent_damage = null
	return ..()

/mob/living/scp/scp682/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(.)
		return

	evolution_system?.process_evolution()
	ProcessRegeneration()
	ProcessContainment()
	combat_system?.process_combat()
	ProcessResearch()
	process_scp682_effects()

/mob/living/scp/scp682/proc/process_scp682_effects()
	for(var/mob/living/carbon/human/H in range(5, src))
		if(H == src || H.stat == DEAD)
			continue

		if(H.sanity)
			H.sanity.add_trauma(TRAUMA_PSYCHOLOGICAL, 5)

	containment_status = breach_phase

	if(prob(3) && containment_status != "contained")
		playsound(src, 'sound/effects/roar.ogg', 40, TRUE, extrarange = 15)

/mob/living/scp/scp682/proc/ProcessRegeneration()
	if(world.time < regeneration_cooldown)
		return

	regeneration_cooldown = world.time + 1 SECONDS

	CleanDamageMemory()

	var/total_rate = regeneration_rate + damage_scaling

	if(evolution_system)
		total_rate += length(evolution_system.active_adaptations) * 5
		total_rate += evolution_system.evolution_stage * 10

	if(health < (maxHealth * 0.2))
		total_rate += SCP682_CRITICAL_REGENERATION_BONUS

	if(total_rate > 0 && health < maxHealth)
		health = min(maxHealth, health + total_rate)

/mob/living/scp/scp682/proc/CleanDamageMemory()
	var/current_time = world.time
	for(var/damage_record in recent_damage.Copy())
		if(current_time - damage_record["time"] > 30 SECONDS)
			recent_damage -= damage_record

/mob/living/scp/scp682/proc/RecordDamage(amount, damage_type)
	last_damage_time = world.time
	recent_damage += list(list("amount" = amount, "type" = damage_type, "time" = world.time))

	var/total_recent_damage = 0
	for(var/damage_record in recent_damage)
		total_recent_damage += damage_record["amount"]
	damage_scaling = total_recent_damage / 100

/mob/living/scp/scp682/proc/ProcessContainment()
	if(world.time >= last_containment_check + SCP682_CONTAINMENT_CHECK_INTERVAL)
		last_containment_check = world.time
		if(containment_status == "contained")
			if(prob(2))
				ReduceContainmentIntegrity(5)
	acid_bath?.process_acid()

/mob/living/scp/scp682/proc/ReduceContainmentIntegrity(amount)
	containment_integrity = max(0, containment_integrity - amount)

	if(containment_integrity <= 0)
		EscalateBreach()

/mob/living/scp/scp682/proc/EscalateBreach()
	if(world.time < breach_cooldown)
		return

	breach_cooldown = world.time + 30 SECONDS

	switch(breach_phase)
		if("contained")
			SetBreachPhase("agitated")
		if("agitated")
			SetBreachPhase("escalating")
		if("escalating")
			SetBreachPhase("full_breach")
		if("full_breach")
			SetBreachPhase("rampage")

/mob/living/scp/scp682/proc/SetBreachPhase(new_phase)
	breach_phase = new_phase

	if(new_phase == "contained")
		remove_movespeed_modifier(/datum/movespeed_modifier/scp682_agitated)
		remove_movespeed_modifier(/datum/movespeed_modifier/scp682_full_breach)
		remove_movespeed_modifier(/datum/movespeed_modifier/scp682_rage)
		hook_scp_recontainment("SCP-682", list("method" = "standard", "integrity" = containment_integrity))
		return
	switch(breach_phase)
		if("agitated")
			add_movespeed_modifier(/datum/movespeed_modifier/scp682_agitated)
			to_chat(src, span_warning("You feel agitated and more aggressive."))
		if("escalating")
			if(!has_movespeed_modifier(/datum/movespeed_modifier/scp682_agitated))
				add_movespeed_modifier(/datum/movespeed_modifier/scp682_agitated)
			to_chat(src, span_danger("Your aggression is escalating!"))
		if("full_breach")
			if(!has_movespeed_modifier(/datum/movespeed_modifier/scp682_full_breach))
				add_movespeed_modifier(/datum/movespeed_modifier/scp682_full_breach)
			to_chat(src, span_danger("You have fully breached containment!"))
			playsound(src, 'sound/effects/roar.ogg', 80, FALSE, extrarange = 25)
		if("rampage")
			if(!has_movespeed_modifier(/datum/movespeed_modifier/scp682_rage))
				add_movespeed_modifier(/datum/movespeed_modifier/scp682_rage)
			to_chat(src, span_danger("You are in a state of complete rampage!"))
			playsound(src, 'sound/effects/roar.ogg', 100, FALSE, extrarange = 40)

/mob/living/scp/scp682/proc/ProcessResearch()
	if(world.time >= last_research_update + 120 SECONDS)
		last_research_update = world.time
		if(!SSresearch_persistence || !SSresearch_persistence.manager)
			return

		var/list/current_data = list()
		current_data["evolution_stage"] = evolution_system?.evolution_stage || 1
		current_data["active_adaptations"] = length(evolution_system?.active_adaptations) || 0
		current_data["threat_memory_size"] = length(threat_system?.threat_memory) || 0
		current_data["breach_phase"] = breach_phase
		current_data["health_percentage"] = (health / maxHealth) * 100
		current_data["timestamp"] = world.time

/mob/living/scp/scp682/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE)
	if(amount > 0 && !forced)
		if(evolution_system && ("damage_resistance_brute" in evolution_system.active_adaptations))
			amount *= 0.5
		amount *= SCP682_INITIAL_BRUTE_MOD
		handle_damage_adaptation(amount, "brute")
	return ..(amount, updating_health, forced)

/mob/living/scp/scp682/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE)
	if(amount > 0 && !forced)
		if(evolution_system && ("damage_resistance_burn" in evolution_system.active_adaptations))
			amount *= 0.5
		amount *= SCP682_INITIAL_BURN_MOD
		handle_damage_adaptation(amount, "burn")
	return ..(amount, updating_health, forced)

/mob/living/scp/scp682/adjustToxLoss(amount, updating_health = TRUE, forced = FALSE, cause_of_death = "Systemic organ failure")
	if(amount > 0 && !forced)
		if(evolution_system && ("damage_resistance_toxin" in evolution_system.active_adaptations))
			amount *= 0.5
		amount *= SCP682_INITIAL_TOX_MOD
		handle_damage_adaptation(amount, "toxin")
	return ..(amount, updating_health, forced)

/mob/living/scp/scp682/proc/handle_damage_adaptation(amount, damage_type)
	RecordDamage(amount, damage_type)

	if(evolution_system)
		evolution_system.adapt_to_damage(damage_type, amount)

	var/mob/living/carbon/human/attacker = get_attacker()
	if(attacker && istype(attacker))
		if(threat_system)
			threat_system.remember_threat(attacker, damage_type, amount)

/mob/living/scp/scp682/proc/get_attacker()
	return last_attacker

/mob/living/scp/scp682/attackby(obj/item/I, mob/living/user, params)
	if(user && isliving(user))
		last_attacker = user
	return ..()

/mob/living/scp/scp682/UnarmedAttack(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(ishuman(L))
			var/mob/living/carbon/human/H = L

			var/damage = attack_damage
			H.adjustBruteLoss(damage)

			visible_message(span_danger("[src] attacks [H] with devastating force!"))
			playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)

			if(threat_system)
				threat_system.remember_threat(H, "brute", damage)

			if(H.stat == DEAD)
				to_chat(src, span_notice("You have eliminated [H]!"))
				ReduceContainmentIntegrity(SCP682_KILL_CONTAINMENT_REDUCTION)

			if(H.sanity)
				H.sanity.add_trauma(TRAUMA_PSYCHOLOGICAL, 50)

			return

	return ..()

/mob/living/scp/scp682/get_status_tab_items()
	. = ..()
	. += "Evolution Stage: [evolution_stage]/10"
	. += "Containment Status: [containment_status]"
	. += "Attack Damage: [attack_damage]"
	. += "Area Attack Range: [area_attack_range]"

	if(evolution_system)
		. += "Active Adaptations: [length(evolution_system.active_adaptations)]"

	if(threat_system)
		. += "Threats in Memory: [length(threat_system.threat_memory)]"

	var/total_regen = regeneration_rate + damage_scaling
	if(evolution_system)
		total_regen += length(evolution_system.active_adaptations) * 5
		total_regen += evolution_system.evolution_stage * 10
	if(health < (maxHealth * 0.2))
		total_regen += SCP682_CRITICAL_REGENERATION_BONUS
	. += "Regeneration Rate: [total_regen] HP/sec"

/mob/living/scp/scp682/process_ai()
	if(stat == DEAD)
		return
	if(containment_status != "breached" && breach_phase == "contained")
		return
	if(world.time < last_ai_tick + ai_tick_interval)
		return
	last_ai_tick = world.time

	if(containment_status == "contained" && breach_phase == "contained")
		if(prob(3))
			ReduceContainmentIntegrity(5)
		return

	switch(breach_phase)
		if("agitated")
			ai_tick_interval = 15
		if("escalating")
			ai_tick_interval = 12
		if("full_breach")
			ai_tick_interval = 8
		if("rampage")
			ai_tick_interval = 5

	var/mob/living/carbon/human/prey = ai_find_target()
	if(prey)
		ai_combat(prey)
	else
		ai_rampage_and_destroy()

	if(prob(5) && breach_phase != "contained")
		playsound(src, 'sound/effects/roar.ogg', 40, TRUE, extrarange = 15)

/mob/living/scp/scp682/proc/ai_find_target()
	var/mob/living/carbon/human/best = null
	var/best_score = -INFINITY
	for(var/mob/living/carbon/human/H in view(12, src))
		if(H.stat == DEAD || H == src)
			continue
		var/score = 100 - get_dist(src, H) * 5
		if(threat_system && (H in threat_system.threat_memory))
			score += 30
		if(H.health < H.maxHealth * 0.5)
			score += 20
		if(score > best_score)
			best_score = score
			best = H
	return best

/mob/living/scp/scp682/proc/ai_combat(mob/living/carbon/human/prey)
	if(get_dist(src, prey) <= 1)
		UnarmedAttack(prey)
		if(breach_phase == "rampage" && prob(30))
			verb_rampage()
		if(prey.stat == DEAD)
			ReduceContainmentIntegrity(SCP682_KILL_CONTAINMENT_REDUCTION)
		return

	if(breach_phase == "rampage" && prob(20))
		verb_rampage()
		return

	var/turf/next_turf = get_step_towards(src, prey)
	var/blocked = FALSE
	for(var/obj/O in next_turf)
		if(O.density)
			blocked = TRUE
			break
	if(next_turf.density)
		blocked = TRUE

	if(blocked)
		for(var/obj/machinery/door/D in range(1, src))
			if(D.density)
				D.open()
				visible_message(span_danger("[src] forces [D] open!"))
				return
		for(var/obj/structure/S in range(1, src))
			if(S.density)
				S.take_damage(80, BRUTE, "melee")
				visible_message(span_danger("[src] smashes through [S]!"))
				return
		for(var/turf/closed/wall/W in range(1, src))
			if(get_dir(src, W) == get_dir(src, prey))
				W.take_damage(50, BRUTE, "melee")
				visible_message(span_danger("[src] batters [W]!"))
				return

	step_to(src, prey)

	if(prob(15) && breach_phase != "contained")
		playsound(src, 'sound/effects/roar.ogg', 30, TRUE, extrarange = 10)

/mob/living/scp/scp682/proc/ai_rampage_and_destroy()
	if(prob(25))
		var/obj/machinery/door/D = locate() in range(3, src)
		if(D && D.density)
			D.open()
			visible_message(span_danger("[src] forces [D] open!"))
			return

	if(prob(15))
		var/obj/structure/S = locate() in range(2, src)
		if(S && S.density)
			S.take_damage(60, BRUTE, "melee")
			visible_message(span_danger("[src] smashes [S]!"))
			return

	if(prob(10))
		ReduceContainmentIntegrity(2)

	if(ai_home_turf && get_dist(src, ai_home_turf) > ai_wander_range * 3)
		step_to(src, ai_home_turf)
	else
		step_rand(src)

/mob/living/scp/scp682/proc/verb_rampage()
	set name = "Rampage"
	set category = "SCP-682"
	visible_message(span_danger("[src] goes on a rampage, lashing out at everything!"))
	playsound(src, 'sound/weapons/punch1.ogg', 80, TRUE)
	for(var/mob/living/L in range(2, src))
		if(L != src)
			L.adjustBruteLoss(40)
			L.adjustFireLoss(20)
			L.visible_message(span_danger("[src] savages [L]!"), span_userdanger("[src] tears into you!"))
	for(var/obj/structure/S in range(2, src))
		S.take_damage(80)
	for(var/obj/machinery/door/D in range(2, src))
		if(D.density)
			D.open()
	if(combat_system)
		combat_system.perform_area_attack()

/mob/living/scp/scp682/proc/verb_berserk()
	set name = "Berserk Frenzy"
	set category = "SCP-682"
	add_movespeed_modifier(/datum/movespeed_modifier/scp682_berserk)
	damage_modifier = 0.5
	visible_message(span_danger("[src] enters a berserk frenzy!"), span_notice("RAGE CONSUMES YOU. DESTROY. KILL."))
	addtimer(CALLBACK(src, PROC_REF(scp682_end_berserk)), 20 SECONDS)

/mob/living/scp/scp682/proc/scp682_end_berserk()
	remove_movespeed_modifier(/datum/movespeed_modifier/scp682_berserk)
	damage_modifier = initial(damage_modifier)
	to_chat(src, span_notice("Your berserk frenzy subsides."))

/datum/movespeed_modifier/scp682_berserk
	id = "scp682_berserk"
	priority = 100
	slowdown = -1.5

/datum/movespeed_modifier/scp682_agitated
	id = "scp682_agitated"
	priority = 80
	slowdown = -0.3

/datum/movespeed_modifier/scp682_full_breach
	id = "scp682_full_breach"
	priority = 90
	slowdown = -0.8

/datum/movespeed_modifier/scp682_rage
	id = "scp682_rage"
	priority = 95
	slowdown = -1.2

/mob/living/scp/scp682/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, span_warning("This is SCP-682, the Hard-to-Destroy Reptile. Current evolution stage: [evolution_stage]"))
		else
			to_chat(user, span_danger("A massive reptilian creature that radiates pure hatred and malice. You feel an overwhelming sense of dread."))
			if(H.sanity)
				H.sanity.add_trauma(TRAUMA_PSYCHOLOGICAL, 20)

/mob/living/scp/scp682/proc/get_persistence_data()
	var/list/data = list()
	data["evolution_stage"] = evolution_stage
	data["containment_status"] = containment_status
	data["attack_damage"] = attack_damage
	data["movement_speed"] = movement_speed
	data["area_attack_range"] = area_attack_range
	data["containment_integrity"] = containment_integrity
	data["breach_phase"] = breach_phase

	if(evolution_system)
		data["evolution_system"] = list(
			"active_adaptations" = evolution_system.active_adaptations
		)

	if(threat_system)
		data["threat_system"] = list(
			"threat_memory" = threat_system.threat_memory,
			"threat_priorities" = threat_system.threat_priorities
		)

	return data

/mob/living/scp/scp682/proc/load_persistence_data(list/data)
	if(!data)
		return

	evolution_stage = data["evolution_stage"] || 1
	containment_status = data["containment_status"] || "contained"
	attack_damage = data["attack_damage"] || 50
	movement_speed = data["movement_speed"] || 1.5
	area_attack_range = data["area_attack_range"] || 3
	containment_integrity = data["containment_integrity"] || 100
	breach_phase = data["breach_phase"] || "contained"

	if(data["evolution_system"] && evolution_system)
		var/evo_data = data["evolution_system"]
		evolution_system.active_adaptations = evo_data["active_adaptations"] || list()

	if(data["threat_system"] && threat_system)
		var/threat_data = data["threat_system"]
		threat_system.threat_memory = threat_data["threat_memory"] || list()
		threat_system.threat_priorities = threat_data["threat_priorities"] || list()

/mob/living/scp/scp682/proc/on_evolution(new_stage)
	evolution_stage = new_stage
	hook_scp_breach("SCP-682", src)
	if(threat_system)
		for(var/mob/living/carbon/human/H in threat_system.threat_memory)
			if(QDELETED(H))
				continue
			hook_scp_combat(H, "SCP-682", 0, 0)

/mob/living/scp/scp682/proc/on_adaptation(damage_type, amount)
	hook_scp_damage("SCP-682", (health / maxHealth) * 100)

/mob/living/scp/scp682/proc/on_breach()
	containment_status = "breached"
	hook_scp_breach("SCP-682", src)

/mob/living/scp/scp682/proc/on_combat_kill(mob/living/carbon/human/victim)
	if(!victim)
		return
	hook_scp_combat(victim, "SCP-682", 100, 0)
	hook_player_death_near_scp(victim, "SCP-682")
	stop_scp_survival_tracking(victim, "SCP-682")
	ReduceContainmentIntegrity(5)
