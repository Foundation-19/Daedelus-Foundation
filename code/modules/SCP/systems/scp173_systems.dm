// SCP-173 Observation System
/datum/scp173_observation_system
	var/mob/living/scp/scp173/owner
	var/is_being_observed = FALSE
	var/observation_quality = 0
	var/list/observers = list()
	var/last_observation_check = 0
	var/observation_check_interval = 1 SECONDS

/datum/scp173_observation_system/New(mob/living/scp/scp173/new_owner)
	owner = new_owner

/datum/scp173_observation_system/Destroy()
	observers = null
	owner = null
	return ..()

/datum/scp173_observation_system/proc/process_observation()
	if(!owner || owner.stat == DEAD)
		return
	if(world.time >= last_observation_check + observation_check_interval)
		check_observation_status()
		last_observation_check = world.time

/datum/scp173_observation_system/proc/check_observation_status()
	var/list/current_observers = list()
	var/total_quality = 0
	for(var/mob/living/carbon/human/H in range(SCP173_OBSERVATION_RANGE, owner))
		if(H.stat == DEAD || H == owner)
			continue
		if(!H.client)
			continue
		if(!H.can_see_cone(owner))
			continue
		if(!can_see(H, owner, SCP173_OBSERVATION_RANGE))
			continue
		current_observers += H
		total_quality += get_observer_quality(H)
	observers = current_observers
	observation_quality = total_quality
	is_being_observed = length(current_observers) > 0

/datum/scp173_observation_system/proc/get_observer_quality(mob/living/carbon/human/H)
	var/quality = 1.0
	if(H.wear_mask)
		quality += 0.2
	if(H.head)
		quality += 0.1
	if(H.health < H.maxHealth * 0.5)
		quality *= 0.8
	var/dist = get_dist(H, owner)
	quality *= max(0.1, 1.0 - (dist * 0.1))
	return quality

// Movement System
/datum/scp173_movement_system
	var/mob/living/scp/scp173/owner
	var/movement_cooldown = 0

/datum/scp173_movement_system/New(mob/living/scp/scp173/new_owner)
	owner = new_owner

/datum/scp173_movement_system/Destroy()
	owner = null
	return ..()

/datum/scp173_movement_system/proc/process_movement()
	if(!owner || owner.stat == DEAD)
		return
	if(owner.observation_system?.is_being_observed)
		return
	if(world.time < movement_cooldown)
		return
	var/mob/living/carbon/human/nearest = find_nearest_target()
	if(nearest)
		step_towards(owner, nearest)
		movement_cooldown = world.time + SCP173_MOVEMENT_COOLDOWN
		if(prob(40))
			playsound(owner, 'sound/scp/173/rattle.ogg', 30, TRUE)
	else
		if(prob(10))
			for(var/turf/closed/wall/scp_containment/C in range(1, owner))
				C.damage_containment(15, "SCP-173 pressure")
				owner.visible_message(span_danger("[owner] pushes against [C] with immense force!"))
				break

/datum/scp173_movement_system/proc/find_nearest_target()
	var/mob/living/carbon/human/nearest
	var/shortest_distance = INFINITY
	for(var/mob/living/carbon/human/H in view(SCP173_TARGET_SCAN_RANGE, owner))
		if(H.stat == DEAD || H == owner)
			continue
		var/d = get_dist(owner, H)
		if(d < shortest_distance)
			shortest_distance = d
			nearest = H
	return nearest

// Containment System
/datum/scp173_containment_system
	var/mob/living/scp/scp173/owner
	var/containment_integrity = SCP173_DEFAULT_CONTAINMENT_INTEGRITY
	var/breach_threshold = SCP173_BREACH_THRESHOLD
	var/is_contained = TRUE
	var/breach_events = 0

/datum/scp173_containment_system/New(mob/living/scp/scp173/new_owner)
	owner = new_owner

/datum/scp173_containment_system/Destroy()
	owner = null
	return ..()

/datum/scp173_containment_system/proc/process_containment()
	if(!owner || owner.stat == DEAD)
		return
	process_containment_status()
	if(!owner.observation_system?.is_being_observed)
		containment_integrity = max(0, containment_integrity - SCP173_UNOBSERVED_INTEGRITY_DECAY)
	if(containment_integrity <= breach_threshold)
		process_breach()
		return
	var/area/current_area = get_area(owner)
	if(current_area && (findtext(current_area.name, "containment") || findtext(current_area.name, "173")))
		is_contained = TRUE
		return
	process_breach()

/datum/scp173_containment_system/proc/process_containment_status()
	if(!owner)
		return
	var/area/current_area = get_area(owner)
	if(current_area && (findtext(current_area.name, "containment") || findtext(current_area.name, "173")))
		is_contained = TRUE
	else
		is_contained = FALSE

/datum/scp173_containment_system/proc/process_breach()
	breach_events++
	if(owner?.observation_system?.is_being_observed)
		return FALSE
	var/mob/living/carbon/human/target = owner
	hook_scp_breach("SCP-173", target)

// Combat System
/datum/scp173_combat_system
	var/mob/living/scp/scp173/owner
	var/attack_cooldown = 2 SECONDS
	var/last_melee_attack = 0
	var/kills_count = 0
	var/list/current_targets = list()

/datum/scp173_combat_system/New(mob/living/scp/scp173/new_owner)
	owner = new_owner

/datum/scp173_combat_system/Destroy()
	current_targets = null
	owner = null
	return ..()

/datum/scp173_combat_system/proc/process_combat()
	if(!owner || owner.stat == DEAD)
		return
	if(owner.observation_system?.is_being_observed)
		return
	if(world.time < last_melee_attack + attack_cooldown)
		return
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in range(1, owner))
		if(H.stat == DEAD || H == owner)
			continue
		targets += H
	if(!length(targets))
		return
	var/mob/living/carbon/human/target = pick(targets)
	perform_kill(target)

/datum/scp173_combat_system/proc/perform_kill(mob/living/carbon/human/target)
	if(!target || target.stat == DEAD)
		return
	target.adjustBruteLoss(SCP173_ATTACK_DAMAGE)
	playsound(target, 'sound/weapons/genhit.ogg', 50, 0)
	last_melee_attack = world.time
	if(target.stat == DEAD)
		kills_count++
		playsound(target, pick('sound/scp/spook/NeckSnap1.ogg', 'sound/scp/spook/NeckSnap3.ogg'), 80, FALSE, extrarange = 5)
		playsound(target, pick('sound/scp/firstpersonsnap.ogg', 'sound/scp/firstpersonsnap2.ogg', 'sound/scp/firstpersonsnap3.ogg'), 60, FALSE)
		owner?.on_kill(target)

// Research System
/datum/scp173_research_system
	var/mob/living/scp/scp173/owner
	var/list/research_data = list()
	var/research_progress = 0
	var/last_research_update = 0

/datum/scp173_research_system/New(mob/living/scp/scp173/new_owner)
	owner = new_owner

/datum/scp173_research_system/Destroy()
	research_data = null
	owner = null
	return ..()

/datum/scp173_research_system/proc/process_research()
	if(!owner || owner.stat == DEAD)
		return
	if(world.time < last_research_update + 10 SECONDS)
		return
	last_research_update = world.time
	research_progress += 1
	var/list/data = list(
		"kills_count" = owner.combat_system?.kills_count || 0,
		"breach_events" = owner.containment_system?.breach_events || 0,
		"is_observed" = owner.observation_system?.is_being_observed || FALSE,
		"observation_quality" = owner.observation_system?.observation_quality || 0,
		"containment_integrity" = owner.containment_system?.containment_integrity || 100,
		"is_contained" = owner.containment_system?.is_contained || TRUE,
		"kills_count_combat" = owner.combat_system?.kills_count || 0
	)
	research_data = data
