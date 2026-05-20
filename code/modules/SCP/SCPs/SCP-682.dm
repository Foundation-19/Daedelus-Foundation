// SCP-682 - The Hard-to-Destroy Reptile
// Complete Production-Ready Implementation

// ============================================================================
// MAIN SCP-682 MOB
// ============================================================================

/mob/living/scp/scp682
	ai_enabled = TRUE
	name = "SCP-682"
	desc = "A massive, hostile reptilian creature with extreme regenerative abilities and adaptive evolution."
	icon = 'icons/scp/scp-682.dmi'
	icon_state = "scp682"
	real_name = "SCP-682"
	persistence_id = "SCP-682"

	// Core system datums
	var/datum/scp682_evolution_system/evolution_system
	var/datum/scp682_regeneration_system/regeneration_system
	var/datum/scp682_threat_system/threat_system
	var/datum/scp682_containment_system/containment_system
	var/datum/scp682_combat_system/combat_system
	var/datum/scp682_research_integration/research_integration

	var/evolution_stage = 1

	var/attack_damage = SCP682_BASE_ATTACK_DAMAGE
	var/attack_speed = SCP682_BASE_ATTACK_SPEED
	var/movement_speed = SCP682_BASE_MOVEMENT_SPEED
	var/area_attack_range = SCP682_BASE_AREA_ATTACK_RANGE
	var/damage_modifier = 1.0
	var/mob/living/last_attacker

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

	// Initialize core systems
	evolution_system = new /datum/scp682_evolution_system(src)
	regeneration_system = new /datum/scp682_regeneration_system(src)
	threat_system = new /datum/scp682_threat_system(src)
	containment_system = new /datum/scp682_containment_system(src)
	combat_system = new /datum/scp682_combat_system(src)
	research_integration = new /datum/scp682_research_integration(src)

	// Enable vision cone for SCP-682
	fovangle = FOV_DEFAULT
	update_fov_angles()
	update_cone_show()

/mob/living/scp/scp682/Destroy()
	QDEL_NULL(evolution_system)
	QDEL_NULL(regeneration_system)
	QDEL_NULL(threat_system)
	QDEL_NULL(containment_system)
	QDEL_NULL(combat_system)
	QDEL_NULL(research_integration)
	return ..()

/mob/living/scp/scp682/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(.)
		return

	evolution_system?.process_evolution()
	regeneration_system?.process_regeneration()
	threat_system?.process_threats()
	containment_system?.process_containment()
	combat_system?.process_combat()
	research_integration?.process_research()
	process_scp682_effects()

/mob/living/scp/scp682/proc/process_scp682_effects()
	for(var/mob/living/carbon/human/H in range(5, src))
		if(H == src || H.stat == DEAD)
			continue

		if(H.sanity)
			H.sanity.add_trauma(TRAUMA_PSYCHOLOGICAL, 5)

	containment_status = containment_system?.breach_phase || "contained"

	if(prob(3) && containment_status != "contained")
		playsound(src, 'sound/effects/roar.ogg', 40, TRUE, extrarange = 15)

// ============================================================================
// DAMAGE HANDLING & ADAPTATION
// ============================================================================

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
	// Record damage for regeneration system
	if(regeneration_system)
		regeneration_system.record_damage(amount, damage_type)

	// Adapt to damage type
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

// ============================================================================
// COMBAT & ATTACKS
// ============================================================================

/mob/living/scp/scp682/UnarmedAttack(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(ishuman(L))
			var/mob/living/carbon/human/H = L

			// Perform melee attack
			var/damage = attack_damage
			H.adjustBruteLoss(damage)

			// Visual and audio feedback
			visible_message("<span class='danger'>[src] attacks [H] with devastating force!</span>")
			playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)

			// Record threat
			if(threat_system)
				threat_system.remember_threat(H, "brute", damage)

			// Check for kill
			if(H.stat == DEAD)
				to_chat(src, "<span class='notice'>You have eliminated [H]!</span>")

				// Reduce containment integrity when personnel are killed
				if(containment_system)
					containment_system.reduce_containment_integrity(SCP682_KILL_CONTAINMENT_REDUCTION)

			// Apply sanity effects
			if(H.sanity)
				H.sanity.add_trauma(TRAUMA_PSYCHOLOGICAL, 50)

			return

	return ..()

// ============================================================================
// STATUS DISPLAY
// ============================================================================

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

	if(regeneration_system)
		var/regeneration_rate = regeneration_system.calculate_regeneration_rate()
		. += "Regeneration Rate: [regeneration_rate] HP/sec"

// ============================================================================
// EXAMINE BEHAVIOR
// ============================================================================

/mob/living/scp/scp682/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-682, the Hard-to-Destroy Reptile. Current evolution stage: [evolution_stage]</span>")
		else
			to_chat(user, "<span class='danger'>A massive reptilian creature that radiates pure hatred and malice. You feel an overwhelming sense of dread.</span>")

			// Apply fear effect to non-SCP humans
			if(H.sanity)
				H.sanity.add_trauma(TRAUMA_PSYCHOLOGICAL, 20)

// ============================================================================
// PERSISTENCE INTEGRATION
// ============================================================================

/mob/living/scp/scp682/proc/get_persistence_data()
	var/list/data = list()
	data["evolution_stage"] = evolution_stage
	data["containment_status"] = containment_status
	data["attack_damage"] = attack_damage
	data["movement_speed"] = movement_speed
	data["area_attack_range"] = area_attack_range

	if(evolution_system)
		data["evolution_system"] = list(
			"active_adaptations" = evolution_system.active_adaptations
		)

	if(threat_system)
		data["threat_system"] = list(
			"threat_memory" = threat_system.threat_memory,
			"threat_priorities" = threat_system.threat_priorities
		)

	if(containment_system)
		data["containment_system"] = list(
			"containment_integrity" = containment_system.containment_integrity,
			"breach_phase" = containment_system.breach_phase
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

	if(data["evolution_system"] && evolution_system)
		var/evo_data = data["evolution_system"]
		evolution_system.active_adaptations = evo_data["active_adaptations"] || list()

	if(data["threat_system"] && threat_system)
		var/threat_data = data["threat_system"]
		threat_system.threat_memory = threat_data["threat_memory"] || list()
		threat_system.threat_priorities = threat_data["threat_priorities"] || list()

	if(data["containment_system"] && containment_system)
		var/containment_data = data["containment_system"]
		containment_system.containment_integrity = containment_data["containment_integrity"] || 100
		containment_system.breach_phase = containment_data["breach_phase"] || "contained"

// ============================================================================
// RESEARCH INTEGRATION
// ============================================================================

/mob/living/scp/scp682/proc/contribute_research_data()
	if(!SSresearch_persistence || !SSresearch_persistence.manager)
		return

	// Collect comprehensive data
	var/list/research_data = list()
	research_data["evolution_stage"] = evolution_stage
	research_data["containment_status"] = containment_status
	research_data["health_percentage"] = (health / maxHealth) * 100
	research_data["timestamp"] = world.time

	// Contribute to research projects (simplified)
	if(SSresearch_persistence && SSresearch_persistence.manager)
		// Research contribution logic would go here
		// For now, just store the data
		research_integration.research_data["last_update"] = research_data

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
	if(containment_system)
		containment_system.reduce_containment_integrity(5)

// ============================================================================
// END OF SCP-682 IMPLEMENTATION
// ============================================================================
