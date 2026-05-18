/mob/living/scp/scp073
	name = "SCP-073"
	desc = "A man with dark skin, wearing a business suit. Where he walks, plants wither and die. Those who harm him find the harm reflected upon themselves."
	icon = 'icons/mob/human.dmi'
	icon_state = "human_basic"
	real_name = "SCP-073"
	persistence_id = "SCP-073"

	var/damage_reflection_ratio = 1.0
	var/list/reflected_attacks = list()
	var/reflection_cooldown = 0
	var/decay_radius = 3
	var/decay_cooldown = 0
	var/memory_wipe_cooldown = 0
	var/list/touched_by = list()

/mob/living/scp/scp073/Initialize(mapload)
	. = ..()
	SCP = new /datum/scp(src, "SCP-073", SCP_EUCLID, "073", SCP_SENTIENT)
	maxHealth = 300
	health = maxHealth
	fovangle = FOV_DEFAULT
	update_fov_angles()
	update_cone_show()

/mob/living/scp/scp073/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(.)
		return

	process_decay_aura()
	process_memory_effects()
	affect_proximity_sanity()

	if(reflection_cooldown > 0)
		reflection_cooldown -= delta_time

/mob/living/scp/scp073/proc/process_decay_aura()
	if(world.time < decay_cooldown)
		return
	decay_cooldown = world.time + 50

	for(var/obj/structure/flora/F in range(decay_radius, src))
		if(prob(30))
			var/obj/effect/decal/cleanable/ash/A = new /obj/effect/decal/cleanable/ash(get_turf(F))
			A.name = "decayed plant matter"
			qdel(F)

	for(var/obj/structure/glowshroom/G in range(decay_radius, src))
		if(prob(40))
			qdel(G)

/mob/living/scp/scp073/proc/process_memory_effects()
	if(world.time < memory_wipe_cooldown)
		return
	memory_wipe_cooldown = world.time + 300

	for(var/mob/living/carbon/human/H in range(2, src))
		if(H == src || H.stat == DEAD)
			continue
		if(H.sanity)
			H.sanity.add_trauma(TRAUMA_PSYCHOLOGICAL, 2)

/mob/living/scp/scp073/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE)
	if(amount > 0 && !forced)
		. = ..(0, updating_health, forced)
		reflect_damage(amount, "brute")
	else
		return ..()

/mob/living/scp/scp073/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE)
	if(amount > 0 && !forced)
		. = ..(0, updating_health, forced)
		reflect_damage(amount, "burn")
	else
		return ..()

/mob/living/scp/scp073/adjustToxLoss(amount, updating_health = TRUE, forced = FALSE, cause_of_death = "Systemic organ failure")
	if(amount > 0 && !forced)
		. = ..(0, updating_health, forced)
		reflect_damage(amount, "toxin")
	else
		return ..()

/mob/living/scp/scp073/proc/reflect_damage(amount, damage_type)
	if(reflection_cooldown > 0)
		return

	var/mob/living/attacker = get_attacker()
	if(!attacker || !isliving(attacker))
		return

	var/reflected = amount * damage_reflection_ratio

	switch(damage_type)
		if("brute")
			attacker.adjustBruteLoss(reflected)
		if("burn")
			attacker.adjustFireLoss(reflected)
		if("toxin")
			attacker.adjustToxLoss(reflected)

	attacker.visible_message(
		"<span class='danger'>[attacker]'s attack is reflected back upon themselves!</span>",
		"<span class='userdanger'>Your attack is reflected back! The pain is your own!</span>"
	)

	playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)

	reflected_attacks += list(list(
		"attacker" = attacker.real_name,
		"damage_type" = damage_type,
		"amount" = amount,
		"time" = world.time,
	))

	reflection_cooldown = 5

/mob/living/scp/scp073/proc/get_attacker()
	var/mob/living/closest
	var/closest_dist = 5
	for(var/mob/living/L in range(closest_dist, src))
		if(L == src || L.stat == DEAD)
			continue
		if(L.combat_mode)
			var/dist = get_dist(src, L)
			if(dist < closest_dist)
				closest = L
				closest_dist = dist
	return closest

/mob/living/scp/scp073/UnarmedAttack(atom/A)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		touched_by[H.ckey] = world.time
		H.visible_message(
			"<span class='notice'>[src] touches [H] gently.</span>",
			"<span class='warning'>[src] touches you. A strange cold sensation washes over you, and your memories seem to blur...</span>"
		)
		if(H.sanity)
			H.sanity.add_trauma(TRAUMA_PSYCHOLOGICAL, 5)
			H.sanity.hallucination_level = min(H.sanity.hallucination_level + 5, H.sanity.max_hallucination)
		return
	return ..()

/mob/living/scp/scp073/examine(mob/user)
	. = ..()
	if(ishuman(user))
		to_chat(user, "<span class='warning'>This is SCP-073, 'Cain'. Any harm inflicted upon him is reflected back to the attacker. Plants wither in his presence.</span>")
