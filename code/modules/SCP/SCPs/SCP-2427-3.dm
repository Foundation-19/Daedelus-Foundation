/mob/living/simple_animal/hostile/scp2427_3
	name = "mechanical spider"
	desc = "An amalgamation of exposed wires and robotic parts. It has 4 spider-like legs and a metal mask in place of the 'head'."
	icon = 'icons/scp/scp-2427-3.dmi'
	icon_state = "sleep"
	icon_living = "sleep"
	icon_dead = "dead"
	maxHealth = 150
	health = 150
	faction = "scp"
	var/spider_satiety = 100
	var/spider_purity = 100
	var/list/purity_list = list()
	var/list/impurity_list = list()
	var/door_cooldown = 0

/mob/living/simple_animal/hostile/scp2427_3/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "mechanical spider", SCP_EUCLID, "2427-3", SCP_PLAYABLE)
	SCP.min_playercount = 30
/mob/living/simple_animal/hostile/scp2427_3/Life()
	. = ..()
	if(stat == DEAD)
		return

	// Satiety and purity mechanics
	spider_satiety = max(0, spider_satiety - 1)
	spider_purity = max(0, spider_purity - 0.5)

	if(spider_satiety <= 0)
		health = max(0, health - 5)
		to_chat(src, "<span class='notice'>You are starving!</span>")

	if(spider_purity <= 0)
		health = max(0, health - 3)
		to_chat(src, "<span class='notice'>You are becoming impure!</span>")

	// Random purity check
	if(prob(2))
		check_nearby_purity()

/mob/living/simple_animal/hostile/scp2427_3/UnarmedAttack(atom/A)
	. = ..()
	if(isliving(A))
		var/mob/living/L = A
		attack_target(L)
	else if(istype(A, /obj/machinery/door))
		open_door(A)

/mob/living/simple_animal/hostile/scp2427_3/examine(mob/living/user)
	. = ..()
	to_chat(user, "It hums with unstable energy. It seems hungry.")
	check_purity(user)

/mob/living/simple_animal/hostile/scp2427_3/proc/check_purity(mob/living/L)
	if(!istype(L) || L == src || L.stat == DEAD)
		return

	if((L in impurity_list) || (L in purity_list))
		return

	// Very rare chance to be pure
	if(prob(1))
		purity_list |= L
		to_chat(L, "<span class='good'>[src] looks at you with recognition. You are pure.</span>")
		to_chat(src, "<span class='good'>[uppertext(L.name)] IS PURE. IMPOSSIBLE? PURE.</span>")
		playsound(src, 'sound/effects/explosion1.ogg', 50, TRUE)
		return

	// Most are impure
	impurity_list |= L
	to_chat(L, "<span class='userdanger'>You feel unsafe near [src]...</span>")
	to_chat(src, "<span class='warning'>[uppertext(L.name)] IS IMPURE! IMPURE. IMPURE. IMPURE.</span>")
	playsound(src, 'sound/effects/explosion2.ogg', 25, TRUE)

/mob/living/simple_animal/hostile/scp2427_3/proc/check_nearby_purity()
	for(var/mob/living/L in view(7, src))
		if(L.stat == DEAD || L == src)
			continue
		if((L in impurity_list) || (L in purity_list))
			continue
		if(!L.client)
			continue
		check_purity(L)
		break

/mob/living/simple_animal/hostile/scp2427_3/proc/open_door(obj/machinery/door/A)
	if(door_cooldown > world.time)
		return

	if(!istype(A) || !A.density)
		return

	if(!A.Adjacent(src))
		to_chat(src, "<span class='warning'>[A] is too far away.</span>")
		return

	var/open_time = 3 SECONDS
	A.visible_message("<span class='warning'>[src] begins to pry open [A]!</span>")
	playsound(get_turf(A), 'sound/effects/explosion1.ogg', 35, 1)
	door_cooldown = world.time + open_time

	if(!do_after(src, open_time, A))
		return

	A.open(TRUE)
	visible_message("<span class='danger'>[src] slices [A]'s controls, ripping it open!</span>")

/mob/living/simple_animal/hostile/scp2427_3/proc/consume_target(mob/living/target)
	if(!target || target.stat == DEAD)
		return

	// Consume the target
	spider_satiety = min(100, spider_satiety + 25)
	spider_purity = min(100, spider_purity + 10)

	to_chat(src, "<span class='good'>You consume [target] and feel satiated!</span>")
	to_chat(src, "<span class='good'>Your purity has increased!</span>")

	target.gib()

/mob/living/simple_animal/hostile/scp2427_3/proc/attack_target(mob/living/target)
	if(!target || target.stat == DEAD)
		return

	// Don't attack pure beings
	if(target in purity_list)
		to_chat(src, "<span class='warning'>They are pure... We will not harm them.</span>")
		return

	// Basic attack
	target.adjustBruteLoss(15)
	to_chat(target, "<span class='userdanger'>The mechanical spider attacks you!</span>")
	to_chat(src, "<span class='warning'>You attack [target]!</span>")

/mob/living/simple_animal/hostile/scp2427_3/proc/on_purity_check(mob/living/carbon/human/target, is_pure)
	if(!target)
		return
	hook_scp_interaction(target, "SCP-2427-3", INTERACTION_TYPE_OBSERVATION)

/mob/living/simple_animal/hostile/scp2427_3/proc/on_consume(mob/living/carbon/human/victim)
	if(!victim)
		return
	hook_scp_combat(victim, "SCP-2427-3", 100, 0)
	hook_player_death_near_scp(victim, "SCP-2427-3")

/mob/living/simple_animal/hostile/scp2427_3/proc/on_door_breach(obj/machinery/door/door)
	hook_scp_breach("SCP-2427-3", src)
	hook_facility_damage_near_scp("SCP-2427-3", 1)
