// SCP-3199: Sapient Biological Entity
// Foundation-19 style: all mechanics inline, no modular datums.
// Passive: auto-produces eggs on timer, ambient smell, containment monitoring, research.
// Click: liquefaction attack on living targets.
// Verb: Protect Hatchlings (in SCP-3199 tab)

/mob/living/scp/scp3199
	name = "SCP-3199"
	desc = "A hairless, 2.9-meter tall entity stained with albumen-like excretion. Its neck can twist 340 degrees in either direction."
	icon = 'icons/scp/scp-3199.dmi'
	icon_state = "scp-3199-grown"
	status_flags = 0
	maxHealth = 100
	health = 100
	persistence_id = "SCP-3199"
	ai_enabled = TRUE

	var/egg_cooldown = 0
	var/egg_time = 3000
	var/next_ambient_note = 0
	var/ambient_note_interval = 12 SECONDS
	var/next_containment_check = 0
	var/containment_breached = FALSE
	var/next_research = 0
	var/research_interval = 30 SECONDS
	var/eggs_produced = 0

/mob/living/scp/scp3199/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "sapient biological entity", SCP_KETER, "3199")

	add_verb(src, list(
		/mob/living/scp/scp3199/proc/verb_protect_hatchlings,
	))

/mob/living/scp/scp3199/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	. = ..()
	if(stat == DEAD)
		return
	ProcessReproduction()
	ProcessContainment()
	ProcessAmbient()
	ProcessResearch()

/mob/living/scp/scp3199/proc/ProcessReproduction()
	if(egg_cooldown > 0)
		egg_cooldown--
		return
	if(prob(2))
		egg_cooldown = egg_time
		visible_message(span_danger("[src] convulses violently, producing a screech!"))
		playsound(src, 'sound/effects/explosion1.ogg', 100, TRUE, 10)
		var/turf/T = get_turf(src)
		if(T)
			var/obj/item/scp3199_egg/egg = new /obj/item/scp3199_egg(T)
			egg.parent_entity = src
			eggs_produced++
			SCP?.log_interaction(src, "egg_production")
			SCP?.award_research(src, "reproduction", 75)
			on_egg_laid(egg)

/mob/living/scp/scp3199/proc/ProcessContainment()
	if(world.time < next_containment_check + 600)
		return
	next_containment_check = world.time
	var/area/A = get_area(src)
	if(!A || istype(A, /area/space))
		if(!containment_breached)
			containment_breached = TRUE
			SCP?.log_interaction(src, "containment_breach")
			SCP?.award_research(src, "containment", 100)
			// Automated announcements removed - dispatch should announce breaches
			// priority_announce("SCP-3199 containment breach detected! All security personnel respond immediately!", "Security Alert", sub_title = "Breach Alert", sound_type = ANNOUNCER_ALERT)
	else
		if(containment_breached)
			containment_breached = FALSE
			SCP?.log_interaction(src, "containment_restored")

/mob/living/scp/scp3199/proc/ProcessAmbient()
	if(world.time < next_ambient_note)
		return
	next_ambient_note = world.time + ambient_note_interval
	if(prob(8))
		visible_message(span_notice("An acrid, albumen-like odor lingers in the air."))

/mob/living/scp/scp3199/proc/ProcessResearch()
	if(world.time < next_research)
		return
	next_research = world.time
	SCP?.award_research(null, "scp3199_behavior", 10)

/mob/living/scp/scp3199/UnarmedAttack(atom/A)
	. = ..()
	if(isliving(A))
		var/mob/living/L = A
		L.adjustBruteLoss(25)
		L.adjustToxLoss(15)
		visible_message(span_danger("[src] liquefies [L]'s internal structure!"))
		SCP?.log_interaction(L, "liquefaction_attack")
		SCP?.award_research(L, "combat", 25)
		if(ishuman(L))
			on_liquefaction_attack(L)

/mob/living/scp/scp3199/process_ai()
	if(stat == DEAD)
		return
	if(containment_status != "breached")
		return
	if(world.time < last_ai_tick + ai_tick_interval)
		return
	last_ai_tick = world.time

	ProcessReproduction()
	ProcessAmbient()

	var/mob/living/carbon/human/prey = ai_find_prey()
	if(prey)
		ai_attack_prey(prey)
		return

	if(ai_protect_hatchlings_check())
		return

	ai_territorial_wander()

/mob/living/scp/scp3199/proc/ai_find_prey()
	var/mob/living/carbon/human/best = null
	var/best_dist = INFINITY
	for(var/mob/living/carbon/human/H in view(9, src))
		if(H.stat == DEAD || H == src)
			continue
		var/d = get_dist(src, H)
		if(d < best_dist)
			best_dist = d
			best = H
	return best

/mob/living/scp/scp3199/proc/ai_attack_prey(mob/living/carbon/human/prey)
	if(get_dist(src, prey) <= 1)
		UnarmedAttack(prey)
		if(prey.stat == DEAD)
			if(prob(15))
				lay_egg_at(get_turf(prey))
		return

	step_to(src, prey)

	if(prob(10))
		playsound(src, 'sound/effects/explosion1.ogg', 40, TRUE, extrarange = 5)

/mob/living/scp/scp3199/proc/ai_protect_hatchlings_check()
	var/mob/living/scp/scp3199/hurt_hatchling = null
	for(var/mob/living/scp/scp3199/H in range(7, src))
		if(H != src)
			if(H.health < H.maxHealth * 0.5)
				hurt_hatchling = H

	if(hurt_hatchling && prob(40))
		if(get_dist(src, hurt_hatchling) > 1)
			step_to(src, hurt_hatchling)
		else
			hurt_hatchling.adjustBruteLoss(-10)
			hurt_hatchling.adjustFireLoss(-10)
		visible_message(span_danger("[src] lets out a protective screech, defending its young!"))
		playsound(src, 'sound/effects/explosion1.ogg', 80, TRUE, 5)
		return TRUE

	return FALSE

/mob/living/scp/scp3199/proc/ai_territorial_wander()
	if(prob(8) && egg_cooldown <= 0)
		var/turf/T = get_turf(src)
		if(T)
			lay_egg_at(T)
		return

	if(ai_home_turf && get_dist(src, ai_home_turf) > ai_wander_range * 2)
		step_to(src, ai_home_turf)
	else
		step_rand(src)

	if(prob(5))
		var/obj/machinery/door/D = locate() in range(2, src)
		if(D && D.density)
			D.open(TRUE)
			visible_message(span_danger("[src] forces [D] open with its massive frame!"))

/mob/living/scp/scp3199/proc/lay_egg_at(turf/T)
	if(!T || egg_cooldown > 0)
		return
	egg_cooldown = egg_time
	visible_message(span_danger("[src] convulses violently, producing a screech!"))
	playsound(src, 'sound/effects/explosion1.ogg', 100, TRUE, 10)
	var/obj/item/scp3199_egg/egg = new /obj/item/scp3199_egg(T)
	egg.parent_entity = src
	eggs_produced++
	SCP?.log_interaction(src, "egg_production")
	SCP?.award_research(src, "reproduction", 75)
	on_egg_laid(egg)

/mob/living/scp/scp3199/proc/verb_protect_hatchlings()
	set name = "Protect Hatchlings"
	set category = "SCP-3199"
	var/hatchling_count = 0
	for(var/mob/living/scp/scp3199/H in range(7, src))
		if(H != src)
			hatchling_count++
	if(hatchling_count > 0)
		visible_message(span_danger("[src] lets out a protective screech, defending its young!"))
		playsound(src, 'sound/effects/explosion1.ogg', 80, TRUE, 5)
		for(var/mob/living/scp/scp3199/H in range(7, src))
			if(H != src && H.health < H.maxHealth)
				H.adjustBruteLoss(-10)
				H.adjustFireLoss(-10)
	else
		to_chat(src, span_warning("No hatchlings nearby to protect."))

/mob/living/scp/scp3199/examine(mob/user)
	. = ..()
	. += span_notice("This entity appears to be a sapient biological organism with unusual reproductive capabilities.")

/mob/living/scp/scp3199/get_status_tab_items()
	. = ..()
	. += "Eggs Produced: [eggs_produced]"
	. += "Egg Cooldown: [egg_cooldown > 0 ? "[round(egg_cooldown / 600, 1)]m" : "Ready"]"
	. += "Containment: [containment_breached ? "BREACHED" : "Intact"]"

/mob/living/scp/scp3199/proc/on_egg_laid(obj/item/scp3199_egg/egg)
	hook_scp_breach("SCP-3199", src)
	hook_facility_damage_near_scp("SCP-3199", 2)

/mob/living/scp/scp3199/proc/on_hatch(mob/living/scp/scp3199/hatchling)
	if(!hatchling)
		return
	hook_scp_breach("SCP-3199", hatchling)

/mob/living/scp/scp3199/proc/on_liquefaction_attack(mob/living/carbon/human/victim)
	if(!victim)
		return
	hook_scp_combat(victim, "SCP-3199", 25, 0)
	if(victim.stat == DEAD)
		hook_player_death_near_scp(victim, "SCP-3199")

// SCP-3199 Egg
/obj/item/scp3199_egg
	name = "SCP-3199 egg"
	desc = "A large off-white egg with a rubbery appearance. Extremely resilient to damage."
	icon = 'icons/scp/scp-3199.dmi'
	icon_state = "3199_egg_cluster"
	w_class = 4
	var/mob/living/scp/scp3199/parent_entity
	var/hatching_cooldown = 0
	var/hatching_time = 18000
	var/heat_sensitivity = TRUE

/obj/item/scp3199_egg/Initialize()
	. = ..()
	hatching_cooldown = hatching_time
	START_PROCESSING(SSobj, src)

/obj/item/scp3199_egg/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/scp3199_egg/process()
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/air = T?.return_air()
	if(air && air.temperature > 350)
		accelerated_hatching()
	if(hatching_cooldown > 0)
		hatching_cooldown--
		if(hatching_cooldown <= 0)
			hatch()

/obj/item/scp3199_egg/proc/accelerated_hatching()
	if(hatching_cooldown > 0)
		hatching_cooldown = max(0, hatching_cooldown - 600)
		icon_state = "egg_hot"
		desc = "A large off-white egg with a rubbery appearance. It's getting hot!"

/obj/item/scp3199_egg/proc/hatch()
	var/turf/egg_turf = get_turf(src)
	var/mob/living/scp/scp3199/hatchling = new /mob/living/scp/scp3199(egg_turf)
	hatchling.name = "SCP-3199 hatchling"
	hatchling.desc = "A juvenile instance of SCP-3199."
	hatchling.maxHealth = 50
	hatchling.health = 50
	if(parent_entity)
		parent_entity.SCP?.log_interaction(hatchling, "egg_hatching")
		parent_entity.SCP?.award_research(hatchling, "reproduction", 50)
	playsound(egg_turf, 'sound/effects/explosion1.ogg', 75, TRUE, 5)
	visible_message(span_danger("The SCP-3199 egg ruptures violently, producing a hatchling!"))
	qdel(src)

/obj/item/scp3199_egg/attackby(obj/item/I, mob/user)
	if(I.force > 0)
		to_chat(user, span_notice("The egg is extremely resilient and resists damage."))
		return
	return ..()

/obj/item/scp3199_egg/examine(mob/user)
	. = ..()
	. += span_notice("This egg appears to be extremely resilient to damage.")
	if(hatching_cooldown > 0)
		var/time_remaining = round(hatching_cooldown / 600, 1)
		. += span_warning("The egg will hatch in approximately [time_remaining] minutes.")
	if(icon_state == "egg_hot")
		. += span_danger("The egg is being affected by heat exposure!")
