// SCP-082 System Datums
// Hospitality, French Language, and Research Systems

// ========================================
// HOSPITALITY SYSTEM
// ========================================

/datum/scp082_hunger_system
	var/mob/living/scp/scp082/owner = null
	var/hunger_level = 50
	var/max_hunger_level = 100
	var/satiation_level = 50
	var/max_satiation_level = 100
	var/last_feeding = 0
	var/hunger_decay_rate = 0.3
	var/hunger_decay_interval = 30 SECONDS
	var/last_hunger_decay = 0

/datum/scp082_hunger_system/New(mob/living/scp/scp082/new_owner)
	. = ..()
	owner = new_owner

/datum/scp082_hunger_system/proc/process_hunger()
	if(world.time >= last_hunger_decay + hunger_decay_interval)
		hunger_level = min(max_hunger_level, hunger_level + hunger_decay_rate)
		satiation_level = max(0, satiation_level - hunger_decay_rate * 0.5)
		last_hunger_decay = world.time

/datum/scp082_hunger_system/proc/apply_hunger_effects()
	if(hunger_level > 70 && owner)
		owner.visible_message("<span class='warning'>[owner] looks extremely hungry and agitated!</span>")

/datum/scp082_hunger_system/proc/attempt_consumption(mob/living/carbon/human/target)
	if(!target || target.health <= 0)
		return FALSE
	if(get_dist(owner, target) > 1)
		return FALSE
	target.visible_message("<span class='danger'>[owner] grabs [target] for consumption!</span>")
	return TRUE

/datum/scp082_hunger_system/proc/complete_consumption(mob/living/carbon/human/target)
	if(!target)
		return
	last_feeding = world.time
	satiation_level = min(max_satiation_level, satiation_level + 30)
	hunger_level = max(0, hunger_level - 30)
	target.death()
	owner.visible_message("<span class='danger'>[owner] finishes consuming [target]!</span>")

/datum/scp082_hunger_system/proc/is_hungry()
	return hunger_level > 70

/datum/scp082_hunger_system/proc/is_starving()
	return hunger_level > 90

// ========================================
// HOSPITALITY TRACKING SYSTEM
// ========================================

/datum/scp082_hospitality_tracking_system
	var/mob/living/scp/scp082/owner = null
	var/intimidation_level = 50
	var/max_intimidation_level = 100
	var/presence_radius = 5
	var/terror_intensity = 30

/datum/scp082_hospitality_tracking_system/New(mob/living/scp/scp082/new_owner)
	. = ..()
	owner = new_owner

/datum/scp082_hospitality_tracking_system/proc/process_hospitality()
	if(!owner)
		return
	update_hospitality_values()

/datum/scp082_hospitality_tracking_system/proc/update_hospitality_values()
	intimidation_level = 50
	if(owner.is_hungry())
		intimidation_level += 15
	if(owner.satiation < 30)
		intimidation_level += 10
	intimidation_level += owner.meals_consumed * 2
	intimidation_level = min(max_intimidation_level, intimidation_level)
	presence_radius = 5 + ((intimidation_level - 50) / 10)
	terror_intensity = 30 + ((intimidation_level - 50) * 0.4)

/datum/scp082_hospitality_tracking_system/proc/apply_passive_intimidation()
	for(var/mob/living/carbon/human/H in range(presence_radius, owner))
		if(H != owner && H.health > 0)
			if(H.sanity)
				var/fear_amount = terror_intensity * 0.1
				H.sanity.adjust_sanity(-fear_amount, "scp082_presence")
			if(prob(5))
				H.visible_message("<span class='warning'>[H] feels uneasy in [owner]'s presence.</span>")

/datum/scp082_hospitality_tracking_system/proc/dominance_display()
	owner.visible_message("<span class='danger'>[owner] roars and beats its chest in a terrifying display!</span>")
	playsound(owner, 'sound/effects/roar.ogg', 100, 0)
	for(var/mob/living/carbon/human/H in range(presence_radius * 1.5, owner))
		if(H != owner && H.health > 0)
			if(H.sanity)
				var/fear_damage = terror_intensity
				H.sanity.adjust_sanity(-fear_damage, "scp082_dominance")
			H.visible_message("<span class='danger'>[H] is terrified by [owner]'s display!</span>")
	return TRUE

// ========================================
// RESEARCH INTEGRATION SYSTEM
// ========================================

/datum/scp082_research_integration
	var/mob/living/scp/scp082/owner = null
	var/list/research_data = list()
	var/last_research_update = 0
	var/research_update_interval = 120 SECONDS

/datum/scp082_research_integration/New(mob/living/scp/scp082/new_owner)
	. = ..()
	owner = new_owner

/datum/scp082_research_integration/proc/process_research()
	if(world.time >= last_research_update + research_update_interval)
		update_research_data()
		last_research_update = world.time

/datum/scp082_research_integration/proc/update_research_data()
	var/current_data = list(
		"satiation" = owner.satiation,
		"meals_consumed" = owner.meals_consumed,
		"conversations_held" = owner.conversations_held,
		"offers_made" = owner.offers_made,
		"is_hungry" = owner.is_hungry(),
		"is_starving" = owner.is_starving(),
		"timestamp" = world.time
	)

	research_data["last_update"] = current_data
