// SCP-247 - A Creature of Habit
// A Bengal tiger that produces a memetic effect causing viewers to perceive it as a harmless house cat
// People who see it want to approach and pet it, which is extremely dangerous

/mob/living/simple_animal/hostile/scp247
	name = "a cute kitty"
	desc = "Aww, what an adorable house cat! It looks so friendly and cuddly. You just want to pick it up and pet it!"
	icon = 'icons/scp/scp-247.dmi'
	icon_state = "scp247"
	icon_living = "scp247"
	icon_dead = "scp247_dead"
	health = 200
	maxHealth = 200
	melee_damage_lower = 25
	melee_damage_upper = 40
	attack_sound = 'sound/weapons/bite.ogg'
	environment_smash = 1
	obj_damage = 15
	move_to_delay = 0

	var/memetic_cooldown = 0
	var/memetic_cooldown_time = 15 SECONDS
	var/list/affected_viewers = list()
	var/list/approach_targets = list()
	var/attack_cooldown = 0
	var/attack_cooldown_time = 3 SECONDS

/mob/living/simple_animal/hostile/scp247/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "A Creature of Habit", SCP_EUCLID, "247")
	AIStatus = AI_ON

/mob/living/simple_animal/hostile/scp247/Life()
	. = ..()
	if(stat == DEAD)
		return

	process_memetic_effect()

/mob/living/simple_animal/hostile/scp247/proc/process_memetic_effect()
	if(world.time < memetic_cooldown)
		return

	memetic_cooldown = world.time + memetic_cooldown_time

	for(var/mob/living/carbon/human/H in view(7, src))
		if(H.stat == DEAD || H.SCP)
			continue

		if(!(H in affected_viewers))
			affected_viewers += H
			apply_memetic_effect(H)

/mob/living/simple_animal/hostile/scp247/proc/apply_memetic_effect(mob/living/carbon/human/viewer)
	if(!viewer)
		return

	to_chat(viewer, span_notice("You see the most adorable little cat! It looks so soft and friendly..."))
	to_chat(viewer, span_notice("You feel an overwhelming urge to go pet it!"))

	addtimer(CALLBACK(src, PROC_REF(draw_closer), viewer), 50)

/mob/living/simple_animal/hostile/scp247/proc/draw_closer(mob/living/carbon/human/target)
	if(!target || target.stat == DEAD || QDELETED(src) || stat == DEAD)
		return

	if(get_dist(src, target) > 7)
		return

	if(prob(50))
		step_towards(target, src)
		to_chat(target, span_notice("You take a step toward the cute kitty..."))

	if(get_dist(src, target) <= 1)
		to_chat(target, span_notice("You reach out to pet the adorable cat..."))
		addtimer(CALLBACK(src, PROC_REF(maul_target), target), 20)

/mob/living/simple_animal/hostile/scp247/proc/maul_target(mob/living/carbon/human/target)
	if(!target || target.stat == DEAD || QDELETED(src) || stat == DEAD)
		return

	if(get_dist(src, target) <= 1)
		visible_message(span_danger("The cute cat suddenly reveals rows of enormous fangs and viciously mauls [target]!"))
		target.adjustBruteLoss(rand(melee_damage_lower, melee_damage_upper))
		hook_scp_combat(target, "SCP-247", 0, melee_damage_lower)

/mob/living/simple_animal/hostile/scp247/AttackingTarget()
	if(world.time < attack_cooldown)
		return

	attack_cooldown = world.time + attack_cooldown_time

	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		visible_message(span_danger("The 'cat' lunges with terrifying force, revealing enormous claws and fangs!"))
		H.adjustBruteLoss(rand(melee_damage_lower, melee_damage_upper))
		hook_scp_combat(H, "SCP-247", 0, melee_damage_lower)
		return

	return ..()

/mob/living/simple_animal/hostile/scp247/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, span_warning("This is SCP-247, a Bengal tiger with a memetic disguise. It appears as a harmless house cat to viewers."))
			to_chat(user, span_danger("Do NOT approach it. It is a dangerous predator."))
		else
			to_chat(user, span_notice("What a sweet little kitty! It looks so soft and harmless..."))
			to_chat(user, span_notice("You really want to pet it!"))

/mob/living/simple_animal/hostile/scp247/death(gibbed, cause_of_death = "Unknown")
	affected_viewers = list()
	approach_targets = list()
	visible_message("<span class='danger'>The creature collapses, its true form briefly visible - an enormous Bengal tiger!</span>")
	hook_scp_recontainment("SCP-247", list())
	..()

/mob/living/simple_animal/hostile/scp247/Destroy()
	affected_viewers = list()
	approach_targets = list()
	return ..()
