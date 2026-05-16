// SCP-1048 - Builder Bear
// A small teddy bear that is friendly and docile around staff, but secretly collects body parts to build hostile copies of itself

/mob/living/simple_animal/scp1048
	name = "SCP-1048"
	desc = "A small, soft teddy bear with button eyes. It looks adorable and harmless."
	icon = 'icons/scp/scp-1048.dmi'
	icon_state = "bear"
	icon_living = "bear"
	icon_dead = "bear_dead"
	maxHealth = 50
	health = 50
	density = FALSE
	melee_damage_lower = 0
	melee_damage_upper = 0
	attack_sound = null
	environment_smash = ENVIRONMENT_SMASH_NONE
	del_on_death = FALSE
	response_help_continuous = "hugs"
	response_help_simple = "hug"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "hits"
	response_harm_simple = "hit"
	speak = list("...", "..?", "!!")
	speak_emote = list("squeaks softly", "wiggles", "looks up innocently")
	emote_hear = list("squeaks", "makes a soft sound")
	emote_see = list("waves its tiny arms", "hugs itself", "looks around curiously", "waddles in a circle")
	turns_per_move = 3
	faction = list("SCP")

	var/materials_collected = 0
	var/materials_needed = 5
	var/build_cooldown = 0
	var/build_cooldown_time = 90 SECONDS
	var/collection_range = 5
	var/mob/living/follow_target = null
	var/list/copies_spawned = list()
	var/max_copies = 3
	var/cuddle_cooldown = 0

	var/datum/scp1048_behavior_system/behavior_system
	var/datum/scp1048_collection_system/collection_system

	var/body_parts_harvested = 0
	var/infant_parts = 0

/mob/living/simple_animal/scp1048/Initialize()
	. = ..()

	SCP = new /datum/scp(src, "Builder Bear", SCP_EUCLID, "1048")

	SCP.min_playercount = 8
	SCP.min_time = 15 MINUTES

	behavior_system = new /datum/scp1048_behavior_system(src)
	collection_system = new /datum/scp1048_collection_system(src)

/mob/living/simple_animal/scp1048/Destroy()
	copies_spawned = list()
	QDEL_NULL(behavior_system)
	QDEL_NULL(collection_system)
	return ..()

/mob/living/simple_animal/scp1048/Life()
	. = ..()
	if(stat == DEAD)
		return

	if(behavior_system)
		behavior_system.process_behavior()

	if(collection_system)
		collection_system.process_collection()

	if(materials_collected >= materials_needed && world.time >= build_cooldown && length(copies_spawned) < max_copies)
		attempt_build_copy()

/mob/living/simple_animal/scp1048/UnarmedAttack(atom/A)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(world.time >= cuddle_cooldown)
			cuddle_person(H)
		return
	return ..()

/mob/living/simple_animal/scp1048/attack_hand(mob/living/carbon/human/M)
	. = ..()
	if(!M.combat_mode)
		visible_message("<span class='notice'>[src] hugs [M]'s hand affectionately!</span>")
		to_chat(M, "<span class='notice'>[src] feels warm and soft. You feel a bit calmer.</span>")
		hook_scp_interaction(M, "SCP-1048", INTERACTION_TYPE_CARE)

/mob/living/simple_animal/scp1048/proc/cuddle_person(mob/living/carbon/human/H)
	cuddle_cooldown = world.time + 10 SECONDS
	visible_message("<span class='notice'>[src] hugs [H] affectionately! It seems so innocent and friendly.</span>")
	to_chat(H, "<span class='notice'>[src] wraps its tiny arms around you. It's surprisingly warm for a stuffed bear.</span>")
	hook_scp_interaction(H, "SCP-1048", INTERACTION_TYPE_CARE)

/mob/living/simple_animal/scp1048/proc/attempt_build_copy()
	if(length(copies_spawned) >= max_copies)
		return

	build_cooldown = world.time + build_cooldown_time
	materials_collected = 0

	var/copy_type = determine_copy_type()
	if(!copy_type)
		return

	var/turf/T = get_turf(src)
	var/mob/living/simple_animal/hostile/scp1048_copy/copy = new copy_type(T)
	copies_spawned += copy

	visible_message("<span class='danger'>[src] presents a grotesque copy of itself made from harvested materials!</span>")
	playsound(src, 'sound/effects/splat.ogg', 50, TRUE)

	hook_scp_breach("SCP-1048", src)

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-1048"]
		if(instance)
			instance.add_interaction_record(null, "copy_built_[initial(copy.name)]")

/mob/living/simple_animal/scp1048/proc/determine_copy_type()
	var/static/list/copy_types = list(
		/mob/living/simple_animal/hostile/scp1048_copy/scp1048_a,
		/mob/living/simple_animal/hostile/scp1048_copy/scp1048_b,
		/mob/living/simple_animal/hostile/scp1048_copy/scp1048_c
	)

	var/list/available = list()
	for(var/T in copy_types)
		var/found = FALSE
		for(var/mob/living/simple_animal/hostile/scp1048_copy/C in copies_spawned)
			if(C.type == T && !QDELETED(C))
				found = TRUE
				break
		if(!found)
			available += T

	if(!length(available))
		return null

	if(infant_parts > 0)
		infant_parts--
		return /mob/living/simple_animal/hostile/scp1048_copy/scp1048_b

	if(body_parts_harvested >= 3)
		return /mob/living/simple_animal/hostile/scp1048_copy/scp1048_a

	return pick(available)

// Behavior system - friendly docile behavior
/datum/scp1048_behavior_system
	var/mob/living/simple_animal/scp1048/parent
	var/wander_timer = 0
	var/hug_timer = 0

/datum/scp1048_behavior_system/New(mob/living/simple_animal/scp1048/P)
	parent = P

/datum/scp1048_behavior_system/proc/process_behavior()
	if(!parent || parent.stat == DEAD)
		return

	if(!parent.follow_target || QDELETED(parent.follow_target))
		find_friend()
	else
		follow_friend()

	if(parent.follow_target && get_dist(parent, parent.follow_target) <= 1)
		hug_timer++
		if(hug_timer >= 20 && prob(10))
			parent.visible_message("<span class='notice'>[parent] hugs [parent.follow_target]'s leg!</span>")
			hug_timer = 0

/datum/scp1048_behavior_system/proc/find_friend()
	if(!parent)
		return

	var/closest_dist = 999
	var/mob/living/carbon/human/closest_friend = null

	for(var/mob/living/carbon/human/H in range(10, parent))
		if(H.stat == DEAD || H.SCP)
			continue
		var/dist = get_dist(parent, H)
		if(dist < closest_dist)
			closest_dist = dist
			closest_friend = H

	parent.follow_target = closest_friend

/datum/scp1048_behavior_system/proc/follow_friend()
	if(!parent || !parent.follow_target)
		return

	var/mob/living/friend = parent.follow_target
	if(get_dist(parent, friend) > 2)
		step_towards(parent, friend)

// Collection system - secretly harvest body parts
/datum/scp1048_collection_system
	var/mob/living/simple_animal/scp1048/parent
	var/collection_cooldown = 0
	var/collection_delay = 30 SECONDS

/datum/scp1048_collection_system/New(mob/living/simple_animal/scp1048/P)
	parent = P

/datum/scp1048_collection_system/proc/process_collection()
	if(!parent || parent.stat == DEAD)
		return

	if(world.time < collection_cooldown)
		return

	if(parent.materials_collected >= parent.materials_needed)
		return

	var/mob/living/carbon/human/closest_dead = null
	var/closest_dist = parent.collection_range + 1

	for(var/mob/living/carbon/human/H in range(parent.collection_range, parent))
		if(H.stat != DEAD)
			continue
		var/dist = get_dist(parent, H)
		if(dist < closest_dist)
			closest_dist = dist
			closest_dead = H

	if(closest_dead)
		harvest_from_body(closest_dead)

/datum/scp1048_collection_system/proc/harvest_from_body(mob/living/carbon/human/body)
	if(!parent || !body)
		return

	collection_cooldown = world.time + collection_delay
	parent.materials_collected++
	parent.body_parts_harvested++

	var/list/harvest_messages = list(
		"[parent] quietly removes something from the corpse.",
		"[parent] seems to be examining the body closely.",
		"[parent] reaches into the body with tiny arms."
	)
	var/harvest_message = pick(harvest_messages)

	parent.visible_message("<span class='warning'>[harvest_message]</span>")

	if(prob(30))
		parent.infant_parts++

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-1048"]
		if(instance)
			instance.add_interaction_record(null, "material_harvested")

/mob/living/simple_animal/scp1048/examine(mob/user)
	. = ..()
	if(ishuman(user))
		to_chat(user, "<span class='notice'>A small, adorable teddy bear. It looks completely harmless and seems to want a hug.</span>")
		if(materials_collected > 0)
			to_chat(user, "<span class='notice'>Its button eyes seem to watch you carefully...</span>")

/mob/living/simple_animal/scp1048/death(gibbed, cause_of_death = "Unknown")
	visible_message("<span class='danger'>[src] falls over, its stuffing spilling out!</span>")
	return ..()

/mob/living/simple_animal/scp1048/proc/view_build_status()
	var/message = "<h2>SCP-1048 Builder Bear Status</h2>"
	message += "<b>Materials Collected:</b> [materials_collected]/[materials_needed]<br>"
	message += "<b>Body Parts Harvested:</b> [body_parts_harvested]<br>"
	message += "<b>Infant Parts:</b> [infant_parts]<br>"
	message += "<b>Copies Built:</b> [length(copies_spawned)]/[max_copies]<br>"

	if(length(copies_spawned) > 0)
		message += "<h3>Active Copies:</h3>"
		for(var/mob/living/simple_animal/hostile/scp1048_copy/C in copies_spawned)
			if(!QDELETED(C))
				message += "- [C.name] ([C.stat == DEAD ? "Dead" : "Active"])<br>"

	to_chat(src, "<span class='notice'>[message]</span>")

/mob/living/simple_animal/scp1048/proc/view_persistence_data()
	if(!check_rights(R_ADMIN))
		to_chat(usr, "<span class='warning'>You don't have permission to view persistence data.</span>")
		return

	var/message = "<h2>SCP-1048 Persistence Data</h2>"
	message += "<b>Materials Collected:</b> [materials_collected]<br>"
	message += "<b>Body Parts Harvested:</b> [body_parts_harvested]<br>"
	message += "<b>Copies Built:</b> [length(copies_spawned)]<br>"

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-1048"]
		if(instance)
			message += "<b>Interaction History:</b> [length(instance.interaction_history)] records<br>"

	to_chat(usr, "<span class='notice'>[message]</span>")

/mob/living/simple_animal/scp1048/get_status_tab_items()
	. = ..()
	. += "Materials: [materials_collected]/[materials_needed]"
	. += "Copies: [length(copies_spawned)]/[max_copies]"

// === HOSTILE COPIES ===

/mob/living/simple_animal/hostile/scp1048_copy
	name = "SCP-1048 Copy"
	desc = "A grotesque copy of SCP-1048, made from harvested body parts. It is hostile."
	icon = 'icons/scp/scp-1048.dmi'
	icon_state = "bear_copy"
	icon_living = "bear_copy"
	icon_dead = "bear_copy_dead"
	maxHealth = 75
	health = 75
	melee_damage_lower = 10
	melee_damage_upper = 20
	attack_sound = 'sound/weapons/bite.ogg'
	environment_smash = ENVIRONMENT_SMASH_NONE
	del_on_death = FALSE
	stat_attack = UNCONSCIOUS
	robust_searching = TRUE
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LIVING
	faction = list("SCP")

	var/special_ability_cooldown = 0
	var/special_ability_cooldown_time = 30 SECONDS

/mob/living/simple_animal/hostile/scp1048_copy/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "SCP-1048 Copy", SCP_EUCLID, "1048")

/mob/living/simple_animal/hostile/scp1048_copy/AttackingTarget()
	. = ..()
	if(. && ishuman(target))
		var/mob/living/carbon/human/H = target
		hook_scp_combat(H, "SCP-1048-Copy", melee_damage_upper, 0)

// SCP-1048-A: Made from human ears, emits a high-pitched scream causing fear/stun
/mob/living/simple_animal/hostile/scp1048_copy/scp1048_a
	name = "SCP-1048-A"
	desc = "A malformed copy of SCP-1048 constructed entirely from human ears. It writhes and twitches horribly."
	icon_state = "bear_ears"
	icon_living = "bear_ears"
	icon_dead = "bear_ears_dead"
	melee_damage_lower = 5
	melee_damage_upper = 10
	speak_emote = list("screams", "shrieks", "emits a horrifying sound")
	emote_see = list("twitches its ear-limbs", "writhes disturbingly")

	var/scream_range = 7
	var/scream_stun_duration = 40
	var/scream_damage = 5

/mob/living/simple_animal/hostile/scp1048_copy/scp1048_a/Life()
	. = ..()
	if(stat == DEAD)
		return

	if(world.time >= special_ability_cooldown && target)
		if(get_dist(src, target) <= scream_range && prob(15))
			perform_scream()

/mob/living/simple_animal/hostile/scp1048_copy/scp1048_a/proc/perform_scream()
	special_ability_cooldown = world.time + special_ability_cooldown_time

	visible_message("<span class='danger'>[src] emits an earsplitting, inhuman shriek!</span>")
	playsound(src, 'sound/effects/screech.ogg', 100, TRUE)

	for(var/mob/living/carbon/human/H in range(scream_range, src))
		if(H == src || H.SCP)
			continue

		H.Stun(scream_stun_duration)
		var/obj/item/organ/ears/ears = H.getorganslot(ORGAN_SLOT_EARS)
		if(ears)
			ears.adjustEarDamage(0, 15)
		H.do_jitter_animation(20)
		H.adjustBruteLoss(scream_damage)

		to_chat(H, "<span class='userdanger'>A deafening, unnatural scream fills your mind with overwhelming terror!</span>")
		hook_scp_combat(H, "SCP-1048-A", scream_damage, 0)

// SCP-1048-B: Made from a human infant, aggressively attacks personnel
/mob/living/simple_animal/hostile/scp1048_copy/scp1048_b
	name = "SCP-1048-B"
	desc = "A horrifying copy of SCP-1048 made from the body of a human infant. It moves with violent, jerking motions."
	icon_state = "bear_infant"
	icon_living = "bear_infant"
	icon_dead = "bear_infant_dead"
	maxHealth = 60
	health = 60
	melee_damage_lower = 15
	melee_damage_upper = 30
	attack_sound = 'sound/weapons/bite.ogg'
	speak_emote = list("gurgles", "wails", "screams")
	emote_see = list("convulses violently", "lunges with unnatural speed")

/mob/living/simple_animal/hostile/scp1048_copy/scp1048_b/AttackingTarget()
	. = ..()
	if(. && ishuman(target))
		var/mob/living/carbon/human/H = target
		if(prob(25))
			H.Knockdown(20)
			visible_message("<span class='danger'>[src] tackles [H] to the ground with terrifying force!</span>")

// SCP-1048-C: Made from unknown materials, hostile
/mob/living/simple_animal/hostile/scp1048_copy/scp1048_c
	name = "SCP-1048-C"
	desc = "A disturbing copy of SCP-1048 made from unidentifiable organic material. Its form seems to shift and pulse."
	icon_state = "bear_unknown"
	icon_living = "bear_unknown"
	icon_dead = "bear_unknown_dead"
	maxHealth = 100
	health = 100
	melee_damage_lower = 12
	melee_damage_upper = 25
	speak_emote = list("gurgles", "emits a low moan", "crackles")
	emote_see = list("shifts unsettlingly", "pulses with unknown energy")

	var/ability_cooldown = 0
	var/ability_cooldown_time = 45 SECONDS

/mob/living/simple_animal/hostile/scp1048_copy/scp1048_c/Life()
	. = ..()
	if(stat == DEAD)
		return

	if(world.time >= ability_cooldown && target)
		if(prob(8))
			perform_special_ability()

/mob/living/simple_animal/hostile/scp1048_copy/scp1048_c/proc/perform_special_ability()
	ability_cooldown = world.time + ability_cooldown_time

	visible_message("<span class='danger'>[src]'s form ripples and distorts, releasing a wave of nauseating energy!</span>")

	for(var/mob/living/carbon/human/H in range(5, src))
		if(H.SCP || H == src)
			continue

		H.adjustToxLoss(10)
		H.Stun(15)
		H.do_jitter_animation(15)

		to_chat(H, "<span class='userdanger'>A wave of sickening energy washes over you from [src]!</span>")
		hook_scp_combat(H, "SCP-1048-C", 10, 0)

/mob/living/simple_animal/hostile/scp1048_copy/death(gibbed, cause_of_death = "Unknown")
	visible_message("<span class='danger'>[src] collapses into a pile of grotesque organic matter!</span>")
	playsound(src, 'sound/effects/splat.ogg', 50, TRUE)
	return ..()

/mob/living/simple_animal/hostile/scp1048_copy/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='danger'>This is not SCP-1048 itself — it is one of its hostile copies.</span>")

/mob/living/simple_animal/hostile/scp1048_copy/get_status_tab_items()
	. = ..()
	. += "Type: [name]"
