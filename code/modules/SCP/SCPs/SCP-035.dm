// SCP-035 - The Possessive Mask
// Complete Production-Ready Implementation

/mob/living/scp035
	name = "SCP-035"
	desc = "A white porcelain mask with a sad expression. It seems to be constantly weeping a black, corrosive substance."
	real_name = "SCP-035"
	icon = 'icons/scp/scp-035.dmi'
	icon_state = "tragedy_obj_rot"
	status_flags = GODMODE|CANPUSH
	maxHealth = 200
	health = 200
	density = FALSE
	sight = SEE_TURFS|SEE_MOBS|SEE_OBJS
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LIVING
	hud_possible = list()
	hud_type = /datum/hud

	var/obj/item/clothing/mask/scp035/mask

	var/persistence_id = "SCP-035"
	var/list/persistence_data = list()
	var/last_persistence_save = 0
	var/persistence_save_interval = 300
	var/containment_status = "contained"
	var/breach_count = 0
	var/last_breach_time = 0
	var/list/interaction_history = list()
	var/last_containment_check = 0
	var/containment_check_interval = 30 SECONDS

/mob/living/scp035/Move()
	return FALSE

/mob/living/scp035/Initialize(mapload)
	. = ..()
	mask = new /obj/item/clothing/mask/scp035(get_turf(src))
	mask.linked_mob = src

/mob/living/scp035/Destroy()
	if(mask)
		mask.linked_mob = null
		mask = null
	return ..()

/mob/living/scp035/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(stat == DEAD)
		return
	update_persistence()
	check_containment()
	if(mask && mask.possession_system?.current_host)
		var/mob/living/carbon/human/host = mask.possession_system.current_host
		if(host.stat == DEAD)
			exit_host(host)
			return
		forceMove(host)
	else if(mask)
		forceMove(get_turf(mask))
	if(mask && !mask.possession_system?.current_host)
		if(prob(5))
			for(var/mob/living/carbon/human/H in range(6, src))
				if(H.stat != DEAD && !H.SCP)
					mask.telepathy_system.apply_influence(H)
					break

/mob/living/scp035/proc/enter_host(mob/living/carbon/human/host)
	if(!host || !mask)
		return
	if(mind)
		mind.transfer_to(host)
	else if(key)
		host.ckey = ckey
	mask.possession_system.transfer_host(host)

/mob/living/scp035/proc/exit_host(mob/living/carbon/human/host)
	if(!host || !mask)
		return
	if(host.mind)
		host.mind.transfer_to(src)
	else if(host.key)
		ckey = host.key
	forceMove(get_turf(host))
	if(host.stat != DEAD)
		host.death()

/mob/living/scp035/proc/update_persistence()
	if(world.time < last_persistence_save + persistence_save_interval)
		return
	last_persistence_save = world.time
	persistence_data["containment_status"] = containment_status
	persistence_data["breach_count"] = breach_count
	persistence_data["last_breach_time"] = last_breach_time
	persistence_data["interaction_history"] = interaction_history.Copy()
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[persistence_id]
		if(instance)
			instance.containment_status = containment_status

/mob/living/scp035/proc/check_containment()
	if(world.time < last_containment_check + containment_check_interval)
		return
	last_containment_check = world.time
	if(mask && mask.possession_system?.current_host)
		if(containment_status != "breached")
			breach_containment()
	else if(!mask || !mask.possession_system?.current_host)
		if(containment_status == "breached")
			return_to_containment()

/mob/living/scp035/proc/breach_containment()
	if(containment_status == "breached")
		return
	containment_status = "breached"
	breach_count++
	last_breach_time = world.time
	if(mask)
		mask.containment_status = "breached"
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[persistence_id]
		if(instance)
			instance.containment_status = "breached"
			instance.add_breach_record()

/mob/living/scp035/proc/return_to_containment()
	if(containment_status == "contained")
		return
	containment_status = "contained"
	if(mask)
		mask.containment_status = "contained"
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[persistence_id]
		if(instance)
			instance.containment_status = "contained"

/mob/living/scp035/proc/add_interaction_record(target, interaction_type)
	var/record = "[time2text(world.time, "YYYY-MM-DD hh:mm:ss")]: [interaction_type] with [target ? "[target]" : "unknown"]"
	interaction_history += record
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[persistence_id]
		if(instance)
			instance.add_interaction_record(target, interaction_type)

// Core SCP-035 mask object
/obj/item/clothing/mask/scp035
	name = "SCP-035"
	desc = "A white porcelain mask with a sad expression. It seems to be constantly weeping a black, corrosive substance."
	icon = 'icons/scp/scp-035.dmi'
	icon_state = "tragedy_obj_rot"
	worn_icon_state = "tragedy"
	body_parts_covered = HEAD
	flags_inv = HIDEEYES|HIDEFACE
	dog_fashion = null
	flags_cover = MASKCOVERSMOUTH|MASKCOVERSEYES

	// Core possession system
	var/datum/scp035_possession/possession_system
	var/datum/scp035_corruption/corruption_system
	var/datum/scp035_telepathy/telepathy_system
	var/datum/scp035_personality/personality_system

	// Basic properties
	var/containment_status = "contained"
	var/possession_cooldown = 0
	var/possession_cooldown_time = 300 SECONDS
	var/mob/living/scp035/linked_mob
	var/removing_from_host = FALSE

	// Persistence tracking
	var/possessions_performed = 0
	var/hosts_corrupted = 0
	var/telepathic_communications = 0
	var/total_corrosion_caused = 0
	var/personality_changes_induced = 0
	var/consciousness_transfers = 0

/obj/item/clothing/mask/scp035/Initialize()
	. = ..()

	// Initialize core systems
	possession_system = new /datum/scp035_possession(src)
	corruption_system = new /datum/scp035_corruption(src)
	telepathy_system = new /datum/scp035_telepathy(src)
	personality_system = new /datum/scp035_personality(src)

	// Initialize SCP datum
	SCP = new /datum/scp(
		src,
		"SCP-035",
		SCP_KETER,
		"035",
		SCP_PLAYABLE
	)

	SCP.min_playercount = 20
	SCP.min_time = 30 MINUTES
	SCP.memeticFlags = MVISUAL|MAUDIBLE|MSYNCED //Memetic flags determine required factors for a human to be affected

	// Don't start processing until we have a host
	// START_PROCESSING(SSobj, src)

/obj/item/clothing/mask/scp035/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(possession_system)
	QDEL_NULL(corruption_system)
	QDEL_NULL(telepathy_system)
	QDEL_NULL(personality_system)
	linked_mob = null
	return ..()

/obj/item/clothing/mask/scp035/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_MASK && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			return
		if(linked_mob && linked_mob.key)
			linked_mob.enter_host(H)
		else
			possession_system.transfer_host(H, skip_cooldown = TRUE)

/obj/item/clothing/mask/scp035/unequipped(mob/user, silent = FALSE)
	. = ..()
	if(removing_from_host)
		return
	if(possession_system?.current_host == user)
		possession_system.remove_from_current_host()
	else if(linked_mob && linked_mob.key && ishuman(user))
		linked_mob.exit_host(user)

/obj/item/clothing/mask/scp035/process()
	. = ..()

	// Only process if we have a host or are actively doing something
	if(!possession_system?.current_host)
		return

	// Update all systems with safety checks
	if(possession_system)
		possession_system.update()
	if(corruption_system)
		corruption_system.update()
	if(telepathy_system)
		telepathy_system.update()
	if(personality_system)
		personality_system.update()

// Possession System
/datum/scp035_possession
	var/obj/item/clothing/mask/scp035/mask
	var/mob/living/carbon/human/current_host
	var/list/previous_hosts = list()
	var/list/host_memories = list()
	var/list/personality_traits = list()
	var/possession_strength = 1
	var/max_possession_strength = 10
	var/list/learned_abilities = list()
	var/consciousness_level = 100
	var/max_consciousness = 100

/datum/scp035_possession/New(obj/item/clothing/mask/scp035/mask_ref)
	. = ..()
	mask = mask_ref

	// Initialize personality traits
	personality_traits = list(
		"manipulative" = 1,
		"charismatic" = 1,
		"intelligent" = 1,
		"deceptive" = 1,
		"curious" = 1,
		"ambitious" = 1,
		"ruthless" = 1,
		"charming" = 1
	)

/datum/scp035_possession/proc/update()
	if(!current_host)
		return

	consciousness_level = max(0, consciousness_level - 0.5)

	if(current_host.sanity)
		current_host.sanity.adjust_sanity(-0.1)

	if(consciousness_level <= 20 && consciousness_level > 0)
		if(prob(10))
			to_chat(current_host, "<span class='danger'>Your consciousness is fading! The mask is consuming your mind!</span>")
		if(current_host.sanity)
			current_host.sanity.adjust_sanity(-1)

	if(consciousness_level <= 0)
		complete_corruption(current_host)

/datum/scp035_possession/proc/transfer_host(mob/living/carbon/human/new_host, skip_cooldown = FALSE)
	if(!new_host || new_host.SCP || new_host.stat == DEAD)
		return FALSE

	if(!skip_cooldown && world.time < mask.possession_cooldown)
		return FALSE

	// Backup current host consciousness if exists
	if(current_host)
		backup_host_consciousness()
		remove_from_current_host()

	// Transfer to new host
	current_host = new_host
	mask.possessions_performed++
	mask.possession_cooldown = world.time + mask.possession_cooldown_time

	// Start processing when we have a host
	START_PROCESSING(SSobj, mask)

	// Add to previous hosts
	previous_hosts += current_host.name

	// Create possession record
	var/possession_record = "[time2text(world.time, "YYYY-MM-DD hh:mm:ss")]: [current_host.name] possessed by SCP-035"
	host_memories["[current_host.name]_[world.time]"] = possession_record

	// Apply possession effects
	apply_possession_effects(current_host)

	// Apply sanity effects
	if(current_host.sanity)
		current_host.sanity.add_trauma(TRAUMA_PSYCHOLOGICAL, 15)
		current_host.sanity.hallucination_level = min(current_host.sanity.hallucination_level + 20, current_host.sanity.max_hallucination)
		current_host.sanity.insanity_level = min(current_host.sanity.insanity_level + 10, current_host.sanity.max_insanity)
		to_chat(current_host, "<span class='danger'>The mask's influence is affecting your mental state!</span>")

	// Learn from new host
	learn_host_abilities(current_host)

	// Fire breach hook
	mask.on_possession(current_host)

	// Update persistence
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-035"]
		if(instance)
			instance.add_interaction_record(current_host, "possession")

	return TRUE

/datum/scp035_possession/proc/backup_host_consciousness()
	if(!current_host)
		return

	// Store host consciousness in memory
	var/host_memory = list(
		"name" = current_host.name,
		"job" = current_host.job,
		"abilities" = get_host_abilities(current_host),
		"personality" = get_host_personality(current_host),
		"timestamp" = world.time
	)

	host_memories[current_host.name] = host_memory

/datum/scp035_possession/proc/remove_from_current_host()
	if(!current_host)
		return

	var/mob/living/carbon/human/former_host = current_host
	current_host = null
	consciousness_level = max_consciousness

	mask.removing_from_host = TRUE

	if(mask.linked_mob)
		mask.linked_mob.exit_host(former_host)

	former_host.dropItemToGround(mask)
	former_host.adjustBruteLoss(5)
	if(former_host.stamina)
		former_host.stamina.adjust(-25)
	to_chat(former_host, "<span class='danger'>The mask's influence is removed! You feel weakened!</span>")

	STOP_PROCESSING(SSobj, mask)
	mask.corruption_system.reset_for_new_host()
	mask.removing_from_host = FALSE

/datum/scp035_possession/proc/apply_possession_effects(mob/living/carbon/human/host)
	// Transfer mask to host
	host.equip_to_slot_if_possible(mask, ITEM_SLOT_MASK)

	// Apply personality changes
	mask.personality_changes_induced++

	// Increase possession strength
	possession_strength = min(max_possession_strength, possession_strength + 1)

	// Apply status effects
	host.adjustBruteLoss(-10)
	if(host.stamina)
		host.stamina.adjust(50)

	to_chat(host, "<span class='notice'>You feel the mask's consciousness merging with yours...</span>")
	to_chat(host, "<span class='warning'>The mask's personality traits are influencing you: [jointext(personality_traits, ", ")]</span>")

	// Reset systems for new host
	mask.corruption_system.reset_for_new_host()
	consciousness_level = max_consciousness

/datum/scp035_possession/proc/learn_host_abilities(mob/living/carbon/human/host)
	var/list/host_abilities = get_host_abilities(host)

	for(var/ability in host_abilities)
		if(!(ability in learned_abilities))
			learned_abilities += ability
			to_chat(current_host, "<span class='notice'>You have learned: [ability]</span>")

/datum/scp035_possession/proc/get_host_abilities(mob/living/carbon/human/host)
	var/list/abilities = list()

	// Job-based abilities
	switch(host.job)
		if("Medical Doctor", "Chief Medical Officer", "Paramedic")
			abilities += "Medical Knowledge"
			abilities += "Healing Abilities"
		if("Security Officer", "Head of Security", "Warden")
			abilities += "Combat Training"
			abilities += "Security Clearance"
		if("Scientist", "Research Director")
			abilities += "Research Skills"
			abilities += "Analysis Abilities"
		if("Engineer", "Chief Engineer")
			abilities += "Technical Skills"
			abilities += "Repair Abilities"
		if("Site Director", "Human Resources Director")
			abilities += "Administrative Access"
			abilities += "Command Authority"

	// Trait-based abilities
	if(HAS_TRAIT(host, TRAIT_IGNORESLOWDOWN))
		abilities += "Enhanced Speed"
	if(HAS_TRAIT(host, TRAIT_STUNRESISTANCE))
		abilities += "Enhanced Durability"
	if(HAS_TRAIT(host, TRAIT_RESISTHEAT))
		abilities += "Heat Resistance"

	return abilities

/datum/scp035_possession/proc/get_host_personality(mob/living/carbon/human/host)
	var/list/personality = list()

	// Basic personality assessment based on job and traits
	if(host.job in list("Security Officer", "Head of Security", "Warden"))
		personality["aggressive"] = 1
		personality["disciplined"] = 1
	if(host.job in list("Medical Doctor", "Chief Medical Officer", "Paramedic"))
		personality["compassionate"] = 1
		personality["analytical"] = 1
	if(host.job in list("Scientist", "Research Director"))
		personality["curious"] = 1
		personality["logical"] = 1

	return personality

/datum/scp035_possession/proc/complete_corruption(mob/living/carbon/human/host)
	if(!host || !current_host)
		return

	mask.hosts_corrupted++
	mask.containment_status = "breached"

	if(host.sanity)
		host.sanity.add_trauma(TRAUMA_PSYCHOLOGICAL, 50)
		host.sanity.hallucination_level = host.sanity.max_hallucination
		host.sanity.insanity_level = host.sanity.max_insanity
		host.sanity.adjust_sanity(-30)

	host.visible_message("<span class='danger'>[host] has been completely corrupted by SCP-035!</span>")
	to_chat(host, "<span class='danger'>You have been completely corrupted! Your consciousness is fading...</span>")

	mask.consciousness_transfers++
	remove_from_current_host()

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-035"]
		if(instance)
			instance.add_interaction_record(host, "complete_corruption")

// Corruption System
/datum/scp035_corruption
	var/obj/item/clothing/mask/scp035/mask
	var/corruption_level = 0
	var/max_corruption = 100
	var/corruption_rate = 1
	var/corrosion_damage = 0
	var/max_corrosion = 100

/datum/scp035_corruption/New(obj/item/clothing/mask/scp035/mask_ref)
	. = ..()
	mask = mask_ref

/datum/scp035_corruption/proc/update()
	if(!mask.possession_system.current_host)
		return

	apply_corrosion_effect()

	if(!mask.possession_system.current_host)
		return

	update_corruption()

/datum/scp035_corruption/proc/apply_corrosion_effect()
	if(!mask.possession_system.current_host)
		return

	var/mob/living/carbon/human/host = mask.possession_system.current_host
	corrosion_damage = min(max_corrosion, corrosion_damage + 1)
	mask.total_corrosion_caused++

	if(corrosion_damage >= 20)
		host.adjustBruteLoss(1)
		if(prob(5))
			to_chat(host, "<span class='warning'>The mask's corrosive substance is burning your skin!</span>")

	if(corrosion_damage >= 50)
		host.adjustBruteLoss(2)
		host.adjustToxLoss(1)
		if(prob(5))
			to_chat(host, "<span class='danger'>The corrosion is spreading! You can feel it eating away at you!</span>")

	if(corrosion_damage >= 80)
		host.adjustBruteLoss(3)
		host.adjustToxLoss(2)
		if(prob(5))
			to_chat(host, "<span class='danger'>The corrosion is overwhelming! Your body is being consumed!</span>")

	if(corrosion_damage >= 100)
		mask.possession_system.complete_corruption(host)

/datum/scp035_corruption/proc/update_corruption()
	if(!mask.possession_system.current_host)
		return

	corruption_level = min(max_corruption, corruption_level + corruption_rate)

	apply_corruption_effects()

/datum/scp035_corruption/proc/apply_corruption_effects()
	if(!mask.possession_system.current_host)
		return

	var/mob/living/carbon/human/host = mask.possession_system.current_host

	if(corruption_level >= 20)
		if(host.stamina)
			host.stamina.adjust(-5)
		if(prob(5))
			to_chat(host, "<span class='warning'>You feel the mask's influence growing stronger...</span>")

	if(corruption_level >= 40)
		host.adjustBruteLoss(1)
		if(host.stamina)
			host.stamina.adjust(-10)
		if(prob(5))
			to_chat(host, "<span class='danger'>The mask's corruption is affecting your body!</span>")

	if(corruption_level >= 60)
		host.adjustBruteLoss(2)
		host.adjustToxLoss(1)
		if(host.stamina)
			host.stamina.adjust(-15)
		if(prob(5))
			to_chat(host, "<span class='danger'>Your consciousness is being consumed by the mask!</span>")

	if(corruption_level >= 80)
		host.adjustBruteLoss(3)
		host.adjustToxLoss(2)
		if(host.stamina)
			host.stamina.adjust(-25)
		if(prob(5))
			to_chat(host, "<span class='danger'>The mask's corruption is nearly complete!</span>")

/datum/scp035_corruption/proc/reset_for_new_host()
	corruption_level = 0
	corrosion_damage = 0

// Telepathy System
/datum/scp035_telepathy
	var/obj/item/clothing/mask/scp035/mask
	var/range = 6
	var/max_range = 12
	var/list/affected_targets = list()
	var/list/influence_levels = list()
	var/influence_power = 1

/datum/scp035_telepathy/New(obj/item/clothing/mask/scp035/mask_ref)
	. = ..()
	mask = mask_ref

/datum/scp035_telepathy/proc/update()
	cleanup_dead_mobs()
	scan_for_targets()

	for(var/mob/living/carbon/human/target in affected_targets)
		apply_influence(target)

/datum/scp035_telepathy/proc/cleanup_dead_mobs()
	for(var/mob/living/carbon/human/H in influence_levels)
		if(QDELETED(H))
			influence_levels -= H
			affected_targets -= H

/datum/scp035_telepathy/proc/scan_for_targets()
	var/list/new_targets = list()

	for(var/mob/living/carbon/human/H in range(range, mask))
		if(H.SCP || H.stat == DEAD || H == mask.possession_system.current_host)
			continue

		if(mask.possession_system.current_host && mask.possession_system.current_host.fovangle)
			if(!mask.possession_system.current_host.can_see_cone(H))
				continue

		new_targets += H
		if(!(H in influence_levels))
			influence_levels[H] = 0

	for(var/mob/living/carbon/human/old_target in influence_levels)
		if(!(old_target in new_targets))
			influence_levels -= old_target

	affected_targets = new_targets

/datum/scp035_telepathy/proc/apply_influence(mob/living/carbon/human/target)
	if(!isnum(influence_levels[target]))
		influence_levels[target] = 0

	var/distance = get_dist(mask, target)
	var/influence_gain = calculate_influence_gain(distance)
	var/resistance = calculate_resistance(target)

	influence_levels[target] = min(100, influence_levels[target] + influence_gain - resistance)
	mask.telepathic_communications++

	apply_influence_effects(target, influence_levels[target])

/datum/scp035_telepathy/proc/calculate_influence_gain(distance)
	var/gain = 0

	switch(distance)
		if(0) // Same tile
			gain = 3
		if(1) // Adjacent
			gain = 2
		if(2 to 3)
			gain = 1
		if(4 to 6)
			gain = 0.5
		else
			gain = 0.1

	return gain * influence_power

/datum/scp035_telepathy/proc/calculate_resistance(mob/living/carbon/human/target)
	var/resistance = 0

	// Job-based resistance
	switch(target.job)
		if("Security Officer", "Head of Security", "Warden")
			resistance += 0.5 // Disciplined minds
		if("Scientist", "Research Director")
			resistance += 0.3 // Analytical minds
		if("Medical Doctor", "Chief Medical Officer")
			resistance += 0.2 // Compassionate but focused

	// Trait-based resistance
	if(HAS_TRAIT(target, TRAIT_STUNRESISTANCE))
		resistance += 0.3 // Strong will
	if(HAS_TRAIT(target, TRAIT_RESISTHEAT))
		resistance += 0.2 // Mental toughness

	// Previous exposure builds immunity
	if(target in influence_levels)
		resistance += 0.1

	return resistance

/datum/scp035_telepathy/proc/apply_influence_effects(mob/living/carbon/human/target, influence_level)
	if(influence_level >= 20 && prob(10))
		to_chat(target, "<span class='warning'>You hear whispers in your mind...</span>")

	if(influence_level >= 40)
		if(prob(10))
			to_chat(target, "<span class='danger'>The whispers are getting louder! You feel drawn to the mask!</span>")
		if(target.stamina)
			target.stamina.adjust(-5)

	if(influence_level >= 60)
		if(prob(10))
			to_chat(target, "<span class='danger'>The mask is calling to you! You must wear it!</span>")
		if(target.stamina)
			target.stamina.adjust(-10)
		target.adjustToxLoss(1)

		if(prob(20))
			step_towards(target, mask)

	if(influence_level >= 80)
		if(prob(10))
			to_chat(target, "<span class='danger'>The mask's influence is overwhelming! You need to wear it!</span>")
		if(target.stamina)
			target.stamina.adjust(-15)
		target.adjustToxLoss(2)
		mask.personality_changes_induced++

		if(prob(30))
			force_possession(target)
			return

	if(influence_level >= 100)
		if(!target || target.stat == DEAD || target.SCP)
			return
		if(prob(10))
			to_chat(target, "<span class='danger'>You can't resist anymore! You must wear the mask!</span>")
		if(target.stamina)
			target.stamina.adjust(-25)
		target.adjustToxLoss(5)

		force_possession(target)

/datum/scp035_telepathy/proc/force_possession(mob/living/carbon/human/target)
	if(!target || target.SCP || target.stat == DEAD)
		return

	// Force target to wear the mask
	if(mask.possession_system.transfer_host(target))
		to_chat(target, "<span class='danger'>You are compelled to wear the mask!</span>")

// Personality System
/datum/scp035_personality
	var/obj/item/clothing/mask/scp035/mask
	var/list/personality_traits = list()
	var/current_personality = "default"
	var/list/personality_effects = list()

/datum/scp035_personality/New(obj/item/clothing/mask/scp035/mask_ref)
	. = ..()
	mask = mask_ref

	// Initialize personality traits
	personality_traits = list(
		"manipulative" = 1,
		"charismatic" = 1,
		"intelligent" = 1,
		"deceptive" = 1,
		"curious" = 1,
		"ambitious" = 1,
		"ruthless" = 1,
		"charming" = 1
	)

/datum/scp035_personality/proc/update()
	// Update personality effects
	update_personality_effects()

/datum/scp035_personality/proc/update_personality_effects()
	personality_effects.Cut()

	for(var/trait in personality_traits)
		var/level = personality_traits[trait]
		if(level > 0)
			personality_effects[trait] = level

/datum/scp035_personality/proc/integrate_host_personality(mob/living/carbon/human/host)
	if(!host)
		return

	var/list/host_personality = mask.possession_system.get_host_personality(host)

	for(var/trait in host_personality)
		if(trait in personality_traits)
			personality_traits[trait] = min(5, personality_traits[trait] + host_personality[trait])
		else
			personality_traits[trait] = host_personality[trait]

/obj/item/clothing/mask/scp035/proc/attempt_possession_verb()
	var/list/nearby_targets = list()
	for(var/mob/living/carbon/human/H in range(3, src))
		if(H.SCP || H.stat == DEAD)
			continue
		nearby_targets += H

	if(length(nearby_targets))
		var/mob/living/carbon/human/target = input(usr, "Choose a target to possess:", "SCP-035 Possession") as null|anything in nearby_targets
		if(target)
			possession_system.transfer_host(target)
	else
		to_chat(usr, "<span class='warning'>No suitable targets nearby.</span>")

/obj/item/clothing/mask/scp035/proc/expand_telepathic_range()
	telepathy_system.range = min(telepathy_system.max_range, telepathy_system.range + 2)
	to_chat(usr, "<span class='notice'>Telepathic range expanded to [telepathy_system.range] tiles.</span>")

/obj/item/clothing/mask/scp035/proc/view_possession_status()
	var/message = "<h2>SCP-035 Possession Status</h2>"
	message += "<b>Currently Possessed:</b> [possession_system.current_host ? "Yes" : "No"]<br>"
	message += "<b>Current Host:</b> [possession_system.current_host ? possession_system.current_host.name : "None"]<br>"
	message += "<b>Corruption Level:</b> [corruption_system.corruption_level]/[corruption_system.max_corruption]<br>"
	message += "<b>Consciousness Level:</b> [possession_system.consciousness_level]/[possession_system.max_consciousness]<br>"
	message += "<b>Possession Strength:</b> [possession_system.possession_strength]/[possession_system.max_possession_strength]<br>"
	message += "<b>Telepathic Range:</b> [telepathy_system.range] tiles<br>"
	message += "<b>Possessions Performed:</b> [possessions_performed]<br>"
	message += "<b>Hosts Corrupted:</b> [hosts_corrupted]<br>"
	message += "<b>Telepathic Communications:</b> [telepathic_communications]<br><br>"

	if(length(possession_system.host_memories))
		message += "<h3>Possession History:</h3>"
		for(var/key in possession_system.host_memories)
			message += "[possession_system.host_memories[key]]<br>"
	else
		message += "<i>No possession history yet.</i>"

	to_chat(usr, "<span class='notice'>[message]</span>")

/obj/item/clothing/mask/scp035/proc/view_affected_targets()
	var/message = "<h2>SCP-035 Affected Targets</h2>"

	if(length(telepathy_system.affected_targets))
		message += "<h3>Telepathically Influenced:</h3>"
		for(var/mob/living/carbon/human/H in telepathy_system.affected_targets)
			var/influence_level = telepathy_system.influence_levels[H] || 0
			message += "- [H.name]: Influence Level [influence_level]/100<br>"
	else
		message += "<i>No targets currently affected.</i>"

	to_chat(usr, "<span class='notice'>[message]</span>")

/obj/item/clothing/mask/scp035/proc/view_learned_abilities()
	var/message = "<h2>SCP-035 Learned Abilities</h2>"

	if(length(possession_system.learned_abilities))
		message += "<h3>Abilities from Previous Hosts:</h3>"
		for(var/ability in possession_system.learned_abilities)
			message += "- [ability]<br>"
	else
		message += "<i>No abilities learned yet.</i>"

	to_chat(usr, "<span class='notice'>[message]</span>")

/obj/item/clothing/mask/scp035/proc/remove_mask_verb()
	if(possession_system.current_host)
		var/host_name = possession_system.current_host.name
		possession_system.remove_from_current_host()
		to_chat(usr, "<span class='notice'>Mask removed from [host_name].</span>")
	else
		to_chat(usr, "<span class='warning'>No current host to remove mask from.</span>")

/obj/item/clothing/mask/scp035/proc/use_learned_ability()
	if(!length(possession_system.learned_abilities))
		to_chat(usr, "<span class='warning'>No abilities learned yet.</span>")
		return

	var/ability = input(usr, "Choose an ability to use:", "Use Learned Ability") as null|anything in possession_system.learned_abilities
	if(ability)
		use_ability(ability)

/obj/item/clothing/mask/scp035/proc/use_ability(ability)
	if(!possession_system?.current_host)
		to_chat(usr, "<span class='warning'>You need a host to use abilities.</span>")
		return

	var/mob/living/carbon/human/H = possession_system.current_host

	switch(ability)
		if("Medical Knowledge")
			var/heal_amount = 15 * min(possession_system.possession_strength, 5)
			H.adjustBruteLoss(-heal_amount)
			H.adjustFireLoss(-heal_amount)
			H.adjustToxLoss(-heal_amount * 0.5)
			H.adjustOxyLoss(-heal_amount)
			H.visible_message("<span class='notice'>[H]'s wounds begin to knit closed with unsettling speed.</span>", \
				"<span class='notice'>You draw upon stolen medical knowledge to accelerate healing.</span>")
			hook_scp_interaction(H, "SCP-035", INTERACTION_TYPE_RESEARCH)

		if("Healing Abilities")
			var/list/nearby_hurt = list()
			for(var/mob/living/carbon/human/patient in view(7, H))
				if(patient == H)
					continue
				if(patient.health < patient.maxHealth)
					nearby_hurt += patient
			if(length(nearby_hurt))
				var/mob/living/carbon/human/patient = input(usr, "Choose a target to heal:", "SCP-035 Healing") as null|anything in nearby_hurt
				if(patient)
					var/heal = 20 * min(possession_system.possession_strength, 5)
					patient.adjustBruteLoss(-heal)
					patient.adjustFireLoss(-heal)
					patient.visible_message("<span class='notice'>[H] performs an impossibly precise medical procedure on [patient]!</span>", \
						"<span class='notice'>You apply stolen medical expertise to heal [patient].</span>")
			else
				to_chat(usr, "<span class='warning'>No injured targets nearby to heal.</span>")

		if("Combat Training")
			if(H.stamina)
				H.stamina.adjust(50)
			H.SetStun(0)
			H.SetKnockdown(0)
			H.SetImmobilized(0)
			H.SetParalyzed(0)
			H.scp035_modify_physiology(0.7, 1, 30 SECONDS)
			H.visible_message("<span class='warning'>[H] moves with unnatural combat precision!</span>", \
				"<span class='notice'>You draw upon stolen combat training, shaking off incapacitation.</span>")
			hook_scp_combat(H, "SCP-035", 0, possession_system.possession_strength)

		if("Security Clearance")
			var/obj/item/card/id/id_card = H.get_idcard(TRUE)
			if(id_card)
				id_card.add_access(list(ACCESS_SECURITY, ACCESS_SECURITY_LVL1, ACCESS_SECURITY_LVL2, ACCESS_SECURITY_LVL3), mode = TRY_ADD_ALL_NO_WILDCARD)
				to_chat(usr, "<span class='notice'>You grant yourself temporary security access using stolen credentials.</span>")
				addtimer(CALLBACK(id_card, /obj/item/card/id/proc/remove_access, list(ACCESS_SECURITY, ACCESS_SECURITY_LVL1, ACCESS_SECURITY_LVL2, ACCESS_SECURITY_LVL3)), 60 SECONDS)
				H.visible_message("<span class='warning'>[H]'s ID card flashes with unauthorized security access!</span>")
			else
				to_chat(usr, "<span class='warning'>You need an ID card to grant security access.</span>")

		if("Research Skills")
			var/list/nearby_scps = list()
			for(var/obj/O in view(7, H))
				if(O.SCP)
					nearby_scps += O
			if(length(nearby_scps))
				var/obj/scp_obj = input(usr, "Choose an SCP to analyze:", "SCP-035 Research") as null|anything in nearby_scps
				if(scp_obj)
					var/analysis_quality = min(possession_system.possession_strength * 20, 100)
					to_chat(usr, "<span class='notice'>You analyze [scp_obj] with stolen scientific expertise (Quality: [analysis_quality]%).</span>")
					to_chat(usr, "<span class='info'>SCP-[scp_obj.SCP.designation] - Object Class: [scp_obj.SCP.classification]</span>")
					hook_scp_interaction(H, "SCP-035", INTERACTION_TYPE_RESEARCH)
			else
				to_chat(usr, "<span class='notice'>You scan the area with scientific precision but find no SCPs to analyze.</span>")

		if("Analysis Abilities")
			var/list/nearby_humans = list()
			for(var/mob/living/carbon/human/target in view(7, H))
				if(target != H)
					nearby_humans += target
			if(length(nearby_humans))
				var/mob/living/carbon/human/target = input(usr, "Choose a target to analyze:", "SCP-035 Analysis") as null|anything in nearby_humans
				if(target)
					to_chat(usr, "<span class='notice'>--- Subject Analysis: [target.name] ---</span>")
					to_chat(usr, "<span class='info'>Health: [round(target.health / target.maxHealth * 100)]% | Job: [target.job || "Unknown"]</span>")
					to_chat(usr, "<span class='info'>Brute: [round(target.getBruteLoss())] | Burn: [round(target.getFireLoss())] | Toxin: [round(target.getToxLoss())] | Oxy: [round(target.getOxyLoss())]</span>")
					if(target.sanity)
						to_chat(usr, "<span class='info'>Mental State: [round(target.sanity.sanity_level)]% | Traumas: [length(target.sanity.traumas)]</span>")
					hook_scp_interaction(H, "SCP-035", INTERACTION_TYPE_RESEARCH)
			else
				to_chat(usr, "<span class='warning'>No targets nearby to analyze.</span>")

		if("Technical Skills")
			var/list/nearby_machines = list()
			for(var/obj/machinery/M in view(7, H))
				if(!(M.machine_stat & (BROKEN|NOPOWER)) || M.panel_open)
					nearby_machines += M
			if(length(nearby_machines))
				var/obj/machinery/M = input(usr, "Choose a machine to interface with:", "SCP-035 Engineering") as null|anything in nearby_machines
				if(M)
					M.panel_open = TRUE
					if(M.machine_stat & BROKEN)
						M.set_machine_stat(M.machine_stat & ~BROKEN)
						M.visible_message("<span class='notice'>[H] performs an impossibly fast repair on [M]!</span>")
					else
						M.visible_message("<span class='notice'>[H] interfaces with [M] with uncanny technical skill.</span>")
					to_chat(usr, "<span class='notice'>You apply stolen engineering knowledge to [M].</span>")
					hook_scp_interaction(H, "SCP-035", INTERACTION_TYPE_RESEARCH)
			else
				to_chat(usr, "<span class='warning'>No machines nearby to interface with.</span>")

		if("Repair Abilities")
			var/list/nearby_broken = list()
			for(var/obj/machinery/M in view(7, H))
				if(M.machine_stat & BROKEN)
					nearby_broken += M
			if(length(nearby_broken))
				var/obj/machinery/M = input(usr, "Choose a broken machine to repair:", "SCP-035 Repair") as null|anything in nearby_broken
				if(M)
					M.set_machine_stat(M.machine_stat & ~BROKEN)
					M.panel_open = FALSE
					M.visible_message("<span class='notice'>[H] repairs [M] with inhuman speed!</span>", \
						"<span class='notice'>You draw upon stolen engineering expertise to repair [M].</span>")
					hook_scp_interaction(H, "SCP-035", INTERACTION_TYPE_RESEARCH)
			else
				to_chat(usr, "<span class='notice'>No broken machinery nearby to repair.</span>")

		if("Administrative Access")
			var/obj/item/card/id/id_card = H.get_idcard(TRUE)
			if(id_card)
				id_card.add_access(list(ACCESS_ADMIN, ACCESS_ADMIN_LVL1, ACCESS_ADMIN_LVL2, ACCESS_ADMIN_LVL3, ACCESS_ADMIN_LVL4), mode = TRY_ADD_ALL_NO_WILDCARD)
				to_chat(usr, "<span class='notice'>You grant yourself temporary administrative access using stolen authority.</span>")
				addtimer(CALLBACK(id_card, /obj/item/card/id/proc/remove_access, list(ACCESS_ADMIN, ACCESS_ADMIN_LVL1, ACCESS_ADMIN_LVL2, ACCESS_ADMIN_LVL3, ACCESS_ADMIN_LVL4)), 45 SECONDS)
				H.visible_message("<span class='warning'>[H]'s ID card flashes with unauthorized administrative access!</span>")
			else
				to_chat(usr, "<span class='warning'>You need an ID card to grant administrative access.</span>")

		if("Command Authority")
			var/list/nearby_humans = list()
			for(var/mob/living/carbon/human/target in view(7, H))
				if(target != H && target.sanity)
					nearby_humans += target
			if(length(nearby_humans))
				var/mob/living/carbon/human/target = input(usr, "Choose a target to command:", "SCP-035 Authority") as null|anything in nearby_humans
				if(target)
					if(target.sanity)
						target.sanity.adjust_sanity(-25, "scp035_command")
					target.apply_status_effect(/datum/status_effect/incapacitating/stun, 3 SECONDS)
					target.visible_message("<span class='warning'>[target] freezes under [H]'s commanding presence!</span>", \
						"<span class='danger'>An overwhelming authority compels you to obey!</span>")
					hook_scp_interaction(target, "SCP-035", INTERACTION_TYPE_COMMUNICATION)
			else
				to_chat(usr, "<span class='warning'>No targets nearby to command.</span>")

		if("Enhanced Speed")
			H.add_movespeed_modifier(/datum/movespeed_modifier/scp035_speed)
			to_chat(usr, "<span class='notice'>You move with stolen supernatural speed!</span>")
			addtimer(CALLBACK(H, /mob/proc/remove_movespeed_modifier, /datum/movespeed_modifier/scp035_speed), 30 SECONDS)

		if("Enhanced Durability")
			H.scp035_modify_physiology(0.5, 0.5, 30 SECONDS)
			to_chat(usr, "<span class='notice'>You harden your stolen body against damage!</span>")

		if("Heat Resistance")
			H.scp035_modify_physiology(1, 0.3, 45 SECONDS)
			to_chat(usr, "<span class='notice'>You suppress your stolen body's heat sensitivity!</span>")

		else
			to_chat(usr, "<span class='notice'>You use your [ability].</span>")

/mob/living/carbon/human/proc/scp035_reset_physiology()
	physiology.brute_mod = initial(physiology.brute_mod)
	physiology.burn_mod = initial(physiology.burn_mod)

/mob/living/carbon/human/var/scp035_brute_timer = null
/mob/living/carbon/human/var/scp035_burn_timer = null

/mob/living/carbon/human/proc/scp035_modify_physiology(brute_mult, burn_mult, duration)
	if(brute_mult != 1)
		physiology.brute_mod *= brute_mult
		deltimer(scp035_brute_timer)
		scp035_brute_timer = addtimer(CALLBACK(src, /mob/living/carbon/human/proc/scp035_reset_brute), duration, TIMER_STOPPABLE)
	if(burn_mult != 1)
		physiology.burn_mod *= burn_mult
		deltimer(scp035_burn_timer)
		scp035_burn_timer = addtimer(CALLBACK(src, /mob/living/carbon/human/proc/scp035_reset_burn), duration, TIMER_STOPPABLE)

/mob/living/carbon/human/proc/scp035_reset_brute()
	scp035_brute_timer = null
	physiology.brute_mod = initial(physiology.brute_mod)

/mob/living/carbon/human/proc/scp035_reset_burn()
	scp035_burn_timer = null
	physiology.burn_mod = initial(physiology.burn_mod)

/datum/movespeed_modifier/scp035_speed
	slowdown = -1.5

/obj/item/clothing/mask/scp035/attack(mob/living/carbon/human/M, mob/living/carbon/human/user)
	if(ishuman(M) && !M.SCP && M.stat != DEAD)
		if(linked_mob)
			linked_mob.enter_host(M)
		else
			possession_system.transfer_host(M, skip_cooldown = TRUE)
		return TRUE
	return ..()

// Override examine for SCP-035
/obj/item/clothing/mask/scp035/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-035, a possessive mask that can take control of hosts and corrupt them.</span>")
			to_chat(user, "<span class='info'>Corruption Level: [corruption_system.corruption_level]/[corruption_system.max_corruption], Possession Strength: [possession_system.possession_strength]/[possession_system.max_possession_strength]</span>")
		else
			to_chat(user, "<span class='danger'>A white porcelain mask with a sad expression. It seems to be weeping a black substance...</span>")
			to_chat(user, "<span class='warning'>You feel an overwhelming urge to wear this mask...</span>")

			// Apply initial telepathic influence
			if(!(H in telepathy_system.affected_targets))
				telepathy_system.affected_targets += H
				telepathy_system.influence_levels[H] = 15
				to_chat(user, "<span class='danger'>The mask's telepathic influence begins to affect you!</span>")

// Enhanced status display
/obj/item/clothing/mask/scp035/proc/get_status_tab_items()
	var/list/status_items = list()

	status_items += "Containment Status: [containment_status]"
	status_items += "Currently Possessed: [possession_system.current_host ? "Yes" : "No"]"
	status_items += "Current Host: [possession_system.current_host ? possession_system.current_host.name : "None"]"
	status_items += "Corruption Level: [corruption_system.corruption_level]/[corruption_system.max_corruption]"
	status_items += "Consciousness Level: [possession_system.consciousness_level]/[possession_system.max_consciousness]"
	status_items += "Possession Strength: [possession_system.possession_strength]/[possession_system.max_possession_strength]"
	status_items += "Telepathic Range: [telepathy_system.range] tiles"
	status_items += "Possessions Performed: [possessions_performed]"
	status_items += "Hosts Corrupted: [hosts_corrupted]"
	status_items += "Telepathic Communications: [telepathic_communications]"
	status_items += "Total Corrosion Caused: [total_corrosion_caused]"
	status_items += "Personality Changes Induced: [personality_changes_induced]"
	status_items += "Consciousness Transfers: [consciousness_transfers]"
	status_items += "Previous Hosts: [length(possession_system.previous_hosts)]"
	status_items += "Affected Targets: [length(telepathy_system.affected_targets)]"

	return status_items

/obj/item/clothing/mask/scp035/proc/on_possession(mob/living/carbon/human/host)
	if(!host)
		return
	hook_scp_breach("SCP-035", src)
	hook_scp_interaction(host, "SCP-035", INTERACTION_TYPE_CONTAINMENT)

/obj/item/clothing/mask/scp035/proc/on_corruption(mob/living/carbon/human/host, level)
	if(!host)
		return
	hook_scp_combat(host, "SCP-035", 0, level)

/obj/item/clothing/mask/scp035/proc/on_telepathy(mob/living/carbon/human/target)
	if(!target)
		return
	hook_scp_interaction(target, "SCP-035", INTERACTION_TYPE_COMMUNICATION)


