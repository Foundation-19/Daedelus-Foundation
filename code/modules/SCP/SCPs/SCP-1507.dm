// SCP-1507 - Pink Flamingos
// A flock of plastic flamingos that exhibit animalistic behavior and can become hostile

/mob/living/simple_animal/hostile/retaliate/scp1507
	name = "pink flamingo"
	desc = "A pink plastic flamingo that acts like a real one. Its plastic eyes seem to follow you."
	icon = 'icons/scp/scp-1507.dmi'
	maxHealth = 100
	health = 100
	icon_state = "flamingo"
	icon_living = "flamingo"
	icon_dead = "dead"
	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 15
	faction = list("SCP", "flamingo_flock")

	var/static/spawn_count = 1
	var/static/list/all_flamingos = list()

	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"

	var/enrage_potency = 4
	var/max_damage = 25
	var/enraged = FALSE
	var/enrage_threshold = 50

	var/datum/scp1507_flock_system/flock_system
	var/datum/scp1507_combat_system/combat_system
	var/datum/scp1507_behavior_system/behavior_system
	var/datum/scp1507_research_system/research_system

	var/attacks_made = 0
	var/flock_calls = 0

/mob/living/simple_animal/hostile/retaliate/scp1507/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "pink plastic flamingo", SCP_EUCLID, "1507", SCP_PLAYABLE)
	name += " ([spawn_count])"
	spawn_count += 1
	all_flamingos += src

	flock_system = new /datum/scp1507_flock_system(src)
	combat_system = new /datum/scp1507_combat_system(src)
	behavior_system = new /datum/scp1507_behavior_system(src)
	research_system = new /datum/scp1507_research_system(src)

/mob/living/simple_animal/hostile/retaliate/scp1507/Destroy()
	all_flamingos -= src
	QDEL_NULL(flock_system)
	QDEL_NULL(combat_system)
	QDEL_NULL(behavior_system)
	QDEL_NULL(research_system)
	return ..()

/mob/living/simple_animal/hostile/retaliate/scp1507/Life()
	. = ..()
	if(stat == DEAD)
		return

	if(health < enrage_threshold && !enraged)
		enrage()

	if(behavior_system)
		behavior_system.process_behavior()

	if(flock_system)
		flock_system.process_flock()

/mob/living/simple_animal/hostile/retaliate/scp1507/proc/enrage()
	if(enraged)
		return

	enraged = TRUE
	melee_damage_lower = min(melee_damage_lower + enrage_potency, max_damage)
	melee_damage_upper = min(melee_damage_upper + enrage_potency, max_damage)

	to_chat(src, "<span class='danger'>You become enraged!</span>")
	visible_message("<span class='danger'>[src]'s plastic body creaks as it becomes aggressive!</span>")
	playsound(src, 'sound/effects/explosion1.ogg', 50)

	hook_scp_breach("SCP-1507", src)

	if(flock_system)
		flock_system.alert_flock()

/mob/living/simple_animal/hostile/retaliate/scp1507/attack_hand(mob/living/carbon/human/M)
	. = ..()
	if(M.combat_mode)
		enrage()

/mob/living/simple_animal/hostile/retaliate/scp1507/AttackingTarget()
	. = ..()
	if(. && ishuman(target))
		var/mob/living/carbon/human/H = target
		hook_scp_combat(H, "SCP-1507", melee_damage_upper, 0)
		attacks_made++

/mob/living/simple_animal/hostile/retaliate/scp1507/death(gibbed, cause_of_death = "Unknown")
	visible_message("<span class='danger'>[src] shatters into plastic pieces!</span>")
	playsound(src, 'sound/effects/glassbr1.ogg', 50, TRUE)
	if(flock_system)
		flock_system.notify_flock_of_death()
	return ..()

/mob/living/simple_animal/hostile/retaliate/scp1507/proc/call_flock()
	if(flock_system)
		flock_system.call_flock_to_location()
		flock_calls++
		hook_scp_interaction(src, "SCP-1507", INTERACTION_TYPE_COMMUNICATION)

/mob/living/simple_animal/hostile/retaliate/scp1507/proc/coordinate_attack()
	if(!target)
		to_chat(src, "<span class='warning'>You have no target to coordinate against!</span>")
		return

	if(flock_system)
		flock_system.coordinate_attack(target)
		hook_scp_interaction(src, "SCP-1507", INTERACTION_TYPE_COMBAT)

/mob/living/simple_animal/hostile/retaliate/scp1507/examine(mob/user)
	. = ..()
	if(enraged)
		to_chat(user, "<span class='danger'>It looks extremely angry! Its plastic surface is cracked.</span>")
	else
		to_chat(user, "<span class='notice'>It looks like a normal plastic flamingo, but it seems to be watching you.</span>")

	var/nearby_flock = 0
	for(var/mob/living/simple_animal/hostile/retaliate/scp1507/F in range(10, src))
		if(F != src)
			nearby_flock++
	if(nearby_flock > 0)
		to_chat(user, "<span class='warning'>There are [nearby_flock] other flamingos nearby.</span>")

/mob/living/simple_animal/hostile/retaliate/scp1507/proc/on_enrage()
	hook_scp_breach("SCP-1507", src)

/datum/scp1507_flock_system
	var/mob/living/simple_animal/hostile/retaliate/scp1507/parent
	var/flock_call_range = 15
	var/alert_range = 20
	var/coordination_bonus = 1.2

/datum/scp1507_flock_system/New(mob/living/simple_animal/hostile/retaliate/scp1507/P)
	parent = P

/datum/scp1507_flock_system/proc/process_flock()
	if(!parent)
		return

	var/flock_size = 0
	for(var/mob/living/simple_animal/hostile/retaliate/scp1507/F in range(7, parent))
		if(F.stat != DEAD)
			flock_size++

	if(flock_size >= 3 && prob(5))
		parent.enrage()

/datum/scp1507_flock_system/proc/alert_flock()
	if(!parent)
		return

	for(var/mob/living/simple_animal/hostile/retaliate/scp1507/F in range(alert_range, parent))
		if(F != parent && F.stat != DEAD)
			F.enrage()
			F.target = parent.target

/datum/scp1507_flock_system/proc/call_flock_to_location()
	if(!parent)
		return

	parent.visible_message("<span class='notice'>[parent] makes a loud plastic squeaking sound!</span>")
	playsound(parent, 'sound/items/toysqueak1.ogg', 100, TRUE)

	for(var/mob/living/simple_animal/hostile/retaliate/scp1507/F in range(flock_call_range, parent))
		if(F != parent && F.stat != DEAD)
			F.target = null
			F.Goto(parent, F.move_to_delay, 2)

/datum/scp1507_flock_system/proc/coordinate_attack(new_target)
	if(!parent || !new_target)
		return

	parent.visible_message("<span class='warning'>[parent] squawks aggressively!</span>")

	for(var/mob/living/simple_animal/hostile/retaliate/scp1507/F in range(alert_range, parent))
		if(F.stat != DEAD)
			F.target = new_target
			F.enrage()
			F.melee_damage_upper = min(initial(F.melee_damage_upper) * 3, initial(F.melee_damage_upper) + coordination_bonus)

/datum/scp1507_flock_system/proc/notify_flock_of_death()
	if(!parent)
		return

	for(var/mob/living/simple_animal/hostile/retaliate/scp1507/F in range(alert_range, parent))
		if(F.stat != DEAD)
			F.enrage()

/datum/scp1507_combat_system
	var/mob/living/simple_animal/hostile/retaliate/scp1507/parent
	var/peck_combo = 0
	var/combo_timer = 0
	var/combo_window = 30

/datum/scp1507_combat_system/New(mob/living/simple_animal/hostile/retaliate/scp1507/P)
	parent = P

/datum/scp1507_combat_system/proc/process_combo()
	if(!parent)
		return

	if(combo_timer > 0 && world.time > combo_timer)
		peck_combo = 0

/datum/scp1507_combat_system/proc/add_combo()
	peck_combo++
	combo_timer = world.time + combo_window

	if(peck_combo >= 3)
		return peck_combo * 1.5

	return peck_combo

/datum/scp1507_behavior_system
	var/mob/living/simple_animal/hostile/retaliate/scp1507/parent
	var/wander_timer = 0
	var/wander_delay = 50
	var/grazing = FALSE

/datum/scp1507_behavior_system/New(mob/living/simple_animal/hostile/retaliate/scp1507/P)
	parent = P

/datum/scp1507_behavior_system/proc/process_behavior()
	if(!parent || parent.enraged || parent.target)
		return

	wander_timer++
	if(wander_timer >= wander_delay)
		wander_timer = 0
		if(prob(30))
			grazing = TRUE
			parent.visible_message("<span class='notice'>[parent] pecks at the ground.</span>")
		else
			grazing = FALSE

/datum/scp1507_research_system
	var/mob/living/simple_animal/hostile/retaliate/scp1507/parent
	var/list/behavior_log = list()
	var/attack_events = 0

/datum/scp1507_research_system/New(mob/living/simple_animal/hostile/retaliate/scp1507/P)
	parent = P

/datum/scp1507_research_system/proc/log_attack(mob/victim)
	attack_events++
	behavior_log["[world.time]"] = list("victim" = victim?.ckey)
